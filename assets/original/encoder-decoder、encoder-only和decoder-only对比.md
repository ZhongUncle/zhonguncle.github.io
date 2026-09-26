
## 三种 Transformer 架构

### Transformer 完整架构

在《Attention is All You Need》这篇论文中，提出了一个名为 Transformer 的架构，由 Encoder-Decoder 构成。

#### 训练时的模型架构

下面这是 Transformer 训练时的模型架构：

<img src="./images/截屏2026-09-19 18.36.17.png" alt="截屏2026-09-19 18.36.17" style="zoom: 33%;" />

左侧是 encoder，右侧是 decoder，右侧多了个 masked 多注意力头，其余部分都是一样的。而这个 masked 多注意力头就是让 decoder 只能看到预测 token 之前的内容，encoder 则是都能看到。

**其实这也是 encoder 和 decoder 的核心区别，也是标题中，encoder-only 和 decoder-only 的区别。**

到这里，我们已经回答了本文的核心问题，但是，实际带来的区别有哪些呢？

比如说我们要训练翻译模型时，已经有准备好的对应语料，比如：

```
Inputs(给Encoder):  我 爱 北京
Outputs(给Decoder): I love Beijing   ← 这是"标准答案"，训练集里本来就有
```

训练目标是让 Decoder 训练出看到`<BOS> I love`，就预测出`Beijing`的能力。为了让 Decoder 在每一步都有"已生成的前缀"可用，训练时直接把正确答案本身喂给它当作"已生成的部分"——这就是"Output Embedding"这一路输入的来源：它不是模型自己生成的，而是训练数据里的标准答案，被当作 Decoder 的输入。

为什么要"shifted right"(向右移位)？

Decoder 在预测第 i 个词时，只应该看到第 1～i-1 个词 (不能看到自己该预测的那个词，否则就是作弊)。所以整个"标准答案"序列要整体向右挪一位，前面补一个`<BOS>`（Begin Of Sequence）：

```
标准答案（Outputs）：         I   love  Beijing
                            ↓
Decoder的实际输入(shifted): <BOS>  I    love
Decoder在每个位置要预测：      I    love  Beijing
```

也就是说，Decoder 输入的第 k 个位置是"答案的第 k-1 个词",要预测的是"答案的第 k 个词"。这样配合 Masked Multi-Head Attention（也被叫做因果掩码），就能保证"预测第 i 个词时只用到前 i-1 个词的信息"，完全不会偷看未来。这样就可以逐步训练处得到下一个词的能力。

> 此外，这里有点 GAN 的感觉，是 Teacher Forcing：:**老师 (标准答案) 全程扶着走，不让学生 (模型) 自己的错误累积**。
>
> 例如上面的训练时，`<BOS> I love`这个"输入"是**从训练集标准答案里直接切下来的**,不管模型自己预测得准不准，下一步永远喂的是"正确的前缀"，比如第二步预测成`likes`而不是`love`,第 3 步依然会拿到正确的`love`去预测，不会被自己的错误"带偏"。

在训练的时候，通过计算对应位置的 Loss，不断调整拟合。并且因为因为答案已知，没有时序或者前后关系，可以并行计算所有位置的 Loss，速度比传统 RNN 要快（推理不是这样）。

训练时更新的权重如下：

| 图中方框                                                     | 是什么权重                                                   |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Input/Output Embedding**(粉色)                             | 一张"词表大小 × d_model"的查找表，每个词对应一个向量，这些向量本身就是参数，训练中会被更新 |
| **Multi-Head Attention / Masked Multi-Head Attention**(橙色) | 每个注意力头都有独立的 $W_Q, W_K, W_V$(把输入投影成 Query/Key/Value 的矩阵) 以及最后合并多头输出的 $W_O$——这些矩阵是核心的可训练参数 |
| **Feed Forward**(蓝色)                                       | 两层全连接网络 (先升维再降维),里面的权重矩阵和偏置都是参数，通常占模型总参数量的大头 |
| **Add & Norm** 里的 **Norm** 部分 (黄色)                      | LayerNorm 有两个小的可学习参数 (缩放γ和偏移β),量很小但也算参数 |
| **Linear**(紫色，最顶上)                                      | 最后把 Decoder 输出映射回"词表大小"维度的矩阵，决定每个词的得分 |

下列部分并不会在训练中更新：

- **Add**(残差连接里的"+"):就是简单的向量相加，没有参数
- **Positional Encoding**(如果用的是原始论文里的正弦/余弦编码):是固定公式算出来的，不参与训练 (但后来很多模型，比如 BERT，把位置编码也做成了可学习参数，这个因具体模型而异)
- **Softmax**:固定的数学函数，没有参数



#### 推理时的模型架构

由于原始论文给的是完整的 Encoder-Decoder 框架，这里推理也是同样的 Encoder-Decoder 框架（训练和推理的架构是一样的，不然 encoder 或者 decoder 部分训练权重就消失了。残缺一部分会影响最后生成的结果的）：

<img src="./images/encoder_decoder_inference_loop_fixed.png" alt="encoder_decoder_inference_loop_fixed" style="zoom:15%;" />

- **左侧 Encoder 只跑一次**:原文进去，双向注意力（指的是前后都能看）处理一遍，产出一组"Encoder 输出向量"——这组向量算完就**固定不变**,不会再重新计算。
- **右侧 Decoder 才是循环的**:每生成一个新 token，都要重新走一遍"Masked 自注意力 → Cross-attention → Feed forward",而**Cross-attention 这一步，每一轮循环都会去查阅左边那组"只算过一次"的 Encoder 输出**——这就是中间那条连接两个色块的箭头所表示的:Encoder 的计算结果被反复"借用",但 Encoder 本身不会跟着每一轮重新算。

比如刚才翻译的例子，推理时没有准备好的译文，只能一步步靠概率选出来。

Encoder 这边只跑一次，和训练时几乎一样：

```
Encoder输入: 我 爱 北京
```
双向自注意力处理一遍，产出一组"Encoder 输出向量"——这一步和训练时几乎没区别，因为原文本来就是已知的，不需要"猜"。

Decoder 这边推理时候的输入是自己的输出（这时候如果出错了就是错了）：

| 步骤  | Decoder 此刻的输入 (已生成部分) | Cross-attention 查阅     | 预测出的下一个词         |
| ----- | ----------------------------- | ----------------------- | ------------------------ |
| 第 1 步 | `<BOS>`                       | Encoder 输出 ("我爱北京") | `I`                      |
| 第 2 步 | `<BOS> I`                     | Encoder 输出 ("我爱北京") | `love`                   |
| 第 3 步 | `<BOS> I love`                | Encoder 输出 ("我爱北京") | `Beijing`                |
| 第 4 步 | `<BOS> I love Beijing`        | Encoder 输出 ("我爱北京") | `<EOS>`(结束符，停止生成) |



### Encoder-only 的 Transformer 架构

一年前我第一次了解到 Bert 这种 Encoder-only 的时候突然意识到：既然 Transformer 能被用来预测下一个词或者挖空猜词，那是不是能用来预测房价呢？毕竟房价和一系列房屋属性（如几室几厅）就像多个 token 一样，可以找到他们之间的关联。当时我让豆包实现的，它选择的就是 Encoder-only 模型（也就是挖去了当前空，然后能看到全文。换言之就是看不到价格，但是可以看到房屋的其他属性）

>Encoder就是完形填空，这里也就需要预测房价这一个东西，所以刚好。

事实证明是可以的，虽然效果并不理想，但是不算随机，最佳 Public Score 仅有 [0.13397](https://www.kaggle.com/code/zhonguncle/house-prices-prediction-using-transformer?scriptVersionId=351231485)。这是因为 Transformer 的被设计的部分很少，模型的大部分关系都是靠训练集学到的（换言之是涌现出来的）。但是预测房价的数据集不够，可能只有几百、几千条，这对于建立一个可用的 Transformer 是远不够用的。

> 我又思考了一个方案，也是有些人想到的：既然当前的一些 LLM 模型已经学到了逻辑、文本等等属于人类的思考方式和关系，那么我们可以把原本表格化的房屋属性和价格转换成一段话，最后留下“价格是____”等待预测即可。但是这个需要微调 LLM，我目前手上的设备无法进行微调测试。



#### 训练时的模型架构

下面是 Encoder-only 的 Transformer 训练时的模型框架：

<img src="./images/encoder_only_transformer_training_generic.png" alt="encoder_only_transformer_training_generic" style="zoom:15%;" />

训练样本是 (`这部电影太好看了`，标签 `正面`)

| 步骤 | 模块                 | 输入                   | 输出                                                 | 作用                                                         |
| ---- | -------------------- | ---------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| 1    | 训练样本             | 语料库                 | `这 部 电 影 太 好 看 了`（8 个 token）+ 标签 `正面` | 输入与标签成对出现                                           |
| 2    | Embedding + 位置编码 | 8 个 token             | 8×d                                                  | 每个 token 变成带位置信息的向量                              |
| 3    | Encoder block × N    | 8×d                    | 8×d                                                  | 双向自注意力加 Feed forward，重复 N 次                       |
| 4    | Encoder 输出向量     | 8×d                    | 8 个上下文向量                                       | 每个位置一个向量                                             |
| 5    | 任务头               | 8×d                    | 类别概率（1×2）                                      | 池化后过 Linear + softmax，假设训练初期得到 `[负面 0.40, 正面 0.60]` |
| 6    | 损失函数             | 类别概率 + 标签 `正面` | 一个标量 loss                                        | 交叉熵，−ln 0.60 ≈ 0.51                                      |
| 7    | 反向传播             | loss                   | 更新后的参数                                         | 梯度传回任务头、Encoder、Embedding，全部参数一起更新         |
| 8    | 下一批数据           | 更新后的模型           | 回到步骤 1                                           | 循环的是训练批次，不是逐词生成                               |





#### 推理时的模型架构

下面是 Encoder-only 的 Transformer 推理时的模型框架：

<img src="./images/encoder_only_transformer_inference_generic.png" alt="encoder_only_transformer_inference_generic" style="zoom:15%;" />

输入 `这部电影太好看了`

| 步骤 | 模块                 | 输入       | 输出                                    | 作用                                                         |
| ---- | -------------------- | ---------- | --------------------------------------- | ------------------------------------------------------------ |
| 1    | 原文输入 tokens      | 一句话     | `这 部 电 影 太 好 看 了`（8 个 token） | 按字切分                                                     |
| 2    | Embedding + 位置编码 | 8 个 token | 8×d                                     | 每个 token 变成带位置信息的向量                              |
| 3    | Encoder block × N    | 8×d        | 8×d                                     | 双向自注意力加 Feed forward，重复 N 次，每个 token 融合整句上下文 |
| 4    | Encoder 输出向量     | 8×d        | 8 个上下文向量                          | 每个位置一个向量                                             |
| 5    | 任务头               | 8×d        | 类别概率（1×2）                         | 池化成 1×d 的整句向量，再过 Linear + softmax，假设得到 `[负面 0.03, 正面 0.97]` |
| 6    | 输出预测结果         | 类别概率   | `正面`                                  | 取最大概率对应的类别                                         |

训练比推理多出标签、损失函数和反向传播，推理只做一次前向。

### Decoder-only 的 Transformer 架构

目前Transformer的最大应用 LLM就是Decoder-only架构的，例如ChatGPT、Claude、DeepSeek。

其实架构工作流程和实际使用是一样的。例如对话式：模型生成内容回答用户输入，而用户的输入就是已经有的信息。

Decoder-only的工作原理就是“续写”：由于 Masked 自注意力，它只能看到之前的内容，并且根据这些之前的内容生成（续写也不用之后的内容，毕竟就没有）。

#### 训练时的模型架构

下面是 Decoder-only 的 Transformer 训练时的模型框架：

<img src="./images/decoder_only_training_flow.png" alt="decoder_only_training_flow" style="zoom:15%;" />

举个例子，用"今天天气真好"训练：

| 步骤 | 模块                 | 输入                          | 输出                              | 作用                                                         |
| ---- | -------------------- | ----------------------------- | --------------------------------- | ------------------------------------------------------------ |
| 1    | 训练样本             | 语料库                        | `今 天 天 气 真 好`（6 个 token） | 一整句直接输入，不用人工加标签，标签就是错位一位的自己       |
| 2    | Embedding + 位置编码 | 6 个 token                    | 6×d                               | 每个 token 变成带位置信息的向量                              |
| 3    | Decoder block × N    | 6×d                           | 6×d                               | Masked 自注意力保证第 i 个位置看不到第 i+1 个及之后的词      |
| 4    | Linear + softmax     | 6×d（每个位置都算）           | 6 个词表概率分布                  | 位置"今"预测下一个词，位置"天"（第一个）预测下一个词，依此类推，6 个位置并行完成 |
| 5    | 交叉熵损失           | 6 个预测分布 + 真实的下一个词 | 一个标量 loss                     | 例如位置"今"应预测"天"，位置"气"应预测"真"；把 6 个位置的损失加总或平均 |
| 6    | 反向传播             | loss                          | 更新后的参数                      | 梯度传回 Decoder 和 Embedding，全部参数一起更新              |
| 7    | 下一批数据           | 更新后的模型                  | 回到步骤 1                        | 循环的是训练批次                                             |

#### 训练时的模型架构

下面是 Decoder-only 的 Transformer 推理时的模型框架：

<img src="./images/decoder_only_inference_flow.png" alt="decoder_only_inference_flow" style="zoom:15%;" />

这里继续用上面那个例子：续写"今天天气"。

| 步骤 | 模块                 | 输入                      | 输出                           | 作用                                                         |
| ---- | -------------------- | ------------------------- | ------------------------------ | ------------------------------------------------------------ |
| 1    | 当前序列             | 提示词                    | `今 天 天 气`（4 个 token）    | 起始序列                                                     |
| 2    | Embedding + 位置编码 | 4 个 token                | 4×d                            | 每个 token 变成带位置信息的向量                              |
| 3    | Decoder block × N    | 4×d                       | 4×d                            | Masked 自注意力让每个位置只看自己和左边，重复 N 次           |
| 4    | Linear + softmax     | 最后一个位置的向量（1×d） | 词表概率                       | 只用最后位置"气"的向量预测下一个词，假设得到 `真 0.6，不 0.2，…` |
| 5    | 采样并拼接           | 词表概率                  | `今 天 天 气 真`（5 个 token） | 采样出"真"，拼回序列                                         |
| 6    | 回到步骤 2           | `今 天 天 气 真`          | 重新完整前向一遍               | 序列变长，重新算全部位置                                     |
| 7    | 循环直到终止         | 逐步变长的序列            | `今天天气真好，适合出门`       | 达到 EOS 或长度上限后停止                                    |
## 测试区别
其实我很好奇这三种架构在同一个任务下的表现差别如何，于是就让 AI 写了 2 个测试看看。

### 实验一：完形填空位置测试
#### 实验设计
用规则生成的合成句子，逐个位置挖空，让三种架构（Decoder-only / Encoder-only / Enc-Dec）去填空。按洞位分成早期、中期、后期三桶统计准确率，另外加了一个 3-gram 前缀基线做对照。

#### 实验结果
单个的测试命令和结果如下（这里合成用的动物是 frog）：

```
% .venv/bin/python demo.py frog         
decoder: 420,413 参数
encoder: 420,413 参数
encdec: 949,565 参数
==============================================================================
原句: the mossy frog followed a shy deer in the pond .
洞位   答案    Decoder-only   Encoder-only   Enc-Dec   
pos1 mossy     rocky ✗        mossy          mossy          ←纯未来信息(只由句尾loc决定)
pos2 frog      frog           frog           frog           
pos3 followed  followed       followed       followed       
pos4 a         a              a              a              
pos5 shy       shy            shy            shy            ←Decoder可经verb→obj链推出
pos6 deer      deer           deer           deer           
pos7 in        in             in             in             ←Decoder可经subj→栖息地链推出
pos8 the       the            the            the            
pos9 pond      pond           pond           pond         
```
全局的测试命令和结果如下：

```
% .venv/bin/python eval.py
decoder: 420,413 参数
encoder: 420,413 参数
encdec: 949,565 参数

===== 完形填空 Top-1 准确率 (按洞位) =====
bucket       decoder     encoder      encdec     unigram     3gram上限
early          49.0%       77.9%       78.2%        0.0%       34.6%
mid            80.3%       87.1%       86.8%        0.0%       79.6%
late           89.1%       90.1%       90.3%       33.0%       65.9%

===== 各模型失败案例 (前5条) =====

[decoder]
  (early) the swift cat [?] a mossy dog in the river .  | 答案=followed 预测=watched
  (early) the muddy [?] barked a lazy cat in the river .  | 答案=dog 预测=frog
  (mid) the quiet fox caught a [?] fox near the lake .  | 答案=muddy 预测=curious
  (late) the misty cat hunted a wild deer [?] the cave .  | 答案=near 预测=in
  (early) the muddy [?] chased a gentle mouse near the forest .  | 答案=fox 预测=frog

[encoder]
  (early) the swift cat [?] a mossy dog in the river .  | 答案=followed 预测=watched
  (mid) the quiet fox caught a [?] fox near the lake .  | 答案=muddy 预测=clever
  (late) the misty cat hunted a wild deer [?] the cave .  | 答案=near 预测=in
  (early) the rocky hawk [?] a hungry bear on the hill .  | 答案=feared 预测=spotted
  (mid) the rocky mouse sniffed a lazy [?] near the cave .  | 答案=fox 预测=cat

[encdec]
  (early) the swift cat [?] a mossy dog in the river .  | 答案=followed 预测=watched
  (mid) the quiet fox caught a [?] fox near the lake .  | 答案=muddy 预测=clever
  (early) the rocky hawk [?] a hungry bear on the hill .  | 答案=feared 预测=spotted
  (mid) the rocky mouse sniffed a lazy [?] near the cave .  | 答案=fox 预测=cat
  (late) the rocky fox spotted a sleepy frog in the [?] .  | 答案=field 预测=forest

```


#### 实验结论
可以看到，在 5000 条测试集，按洞位分桶后，Decoder-only模型在面对早期-中期-晚期的洞时，正确率有明显提升（49% - 80% - 89%），如果带有 Encoder 全程 78–90%，说明挖的洞越靠前，"看不到未来"的代价越大。

> 这么看LLM除了上下文腐烂这个毛病外，太小也不行，所以要适中。



### 实验二：翻译到倒装伪语言

这个任务就没 Encoder-only的事情了，因为Encoder只能完形填空，做不了翻译这种要连续生成的任务。所以这里只对比完整框架和 Decoder-only。

#### 实验设计

把原文和译文拼接成`原文 <SEP> 译文`的形式喂给 Decoder-only 和 Enc-Dec。这种设置下，源信息对 Decoder-only 也完全可见（没有因果掩码挡住输入部分）。

> 这样就可以回答一个问题："Decoder-only 少一部分，会不会比 Encoder-Decoder 弱？" 

#### 实验结果

二者都是 100% 的正确率：

```
% .venv/bin/python translate_eval.py
encdec: 968,840 参数
[encdec] 整句完全正确率 100.0%  词级准确率 100.0%
decoder: 439,688 参数
[decoder] 整句完全正确率 100.0%  词级准确率 100.0%

===== 翻译错误样例 =====

[encdec]

[decoder]

saved results/translate_main.png
```

但是速度差了很多，大概有 5～6倍的差距：

|                      | Enc-Dec | Decoder-only |
| -------------------- | ------- | ------------ |
| epoch 1 loss         | 0.9009  | 1.2425       |
| epoch 3 loss         | 0.0009  | 0.0040       |
| epoch 8 loss         | 0.0001  | 0.0003       |
| 8 轮总耗时           | 19s     | 111s         |
| 单轮耗时（后期稳定） | ~2-2.5s | ~14s         |



#### 实验结论

这里了可以证明Decoder-only 并不会比 Encoder-Decoder 弱。只要把“未来信息”也放进被masked之前的内容里，它和 Enc-Dec 效果一样。而这就完美符合 LLM 的使用方法。

> 未来有机会可以试试看更复杂的，目前手上的设备不够用。

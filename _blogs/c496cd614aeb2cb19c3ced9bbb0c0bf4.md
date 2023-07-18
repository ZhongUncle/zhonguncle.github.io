---
layout: article
category: Non-Tech
date: 2023-06-02
title: 系统学习计算机技术三要素：手快、眼快、脑子快
---
<!-- excerpt-start -->
最近刚好想总结归纳一下自己这些年的学习路径和方法，没想到 CSDN 就搞了这样这样话题，既然这样就不能写一半放草稿箱里，一鼓作气写好，希望能帮到一些人。

这些年的经历告诉我，如果想系统的学习一门计算机相关的技术，那么必须做到“眼快、手快、脑子快”中的至少两点，如果想成为大佬，那么三点缺一不可。

## 什么叫系统学习
一般来说，系统学习就是全面地学习某一技术，从原理、操作各方面进行深入了解，最后形成知识网络体系，对这个技术有全面的了解。

B+ 树的作者有一篇讲博士的博客[《Notes On The PhD Degree》](https://www.cs.purdue.edu/homes/comer/essay.phd.html)，其中有一句：

>To earn a Ph.D., one must accomplish two things. First, one must master a specific subject completely. Second, one must extend the body of knowledge about that subject.（要获得博士学位，必须完成两件事。首先，一个人必须完全掌握一个学科。其次，他必须扩大该学科的知识体系。）

系统的学习一门技术当然不用获得博士学位这么高的要求，虽然并不需要我们去扩充这个技术的体系，但是最终的目标比较像第一个要求：完全掌握一门技术，不论是使用还是原理。不要觉得这个目标太高，正所谓“学其上，仅得其中；学其中，斯为下矣”。

关于如何系统学习，很多人会从知识结构方面来依次介绍，把要学习的部分划分好，这似乎是近些年流行的教育方式。但是我觉得那样划分的结构不一定适合每个人，很多人学前几个部分可能兴致勃勃，但是后面的部分就不想学了。

有些人会告诉你，系统的学习要跟着一本专业书，按照顺序看下来，你就打好基础了。但是说句实话，你可以问问身边的前辈，你想学习的这个技术真的有很全面的专业书吗？

比如说《XX导论》这种书其实只是这个方面的一个大概的介绍，是一本很厚的目录和简介。如果想详细了解，那么这种书是不够的。好在一些方向是有全面的书，比如算法方向 TAOCP 是一本很全面的书。如果你可以阅读英文，那么中文翻译导致的理解错误，以及一些很细致的知识点，对你来说不是问题，你哪怕只钻研完你感兴趣的那部分，你对这部分的理解就超出 99% 的同行了。但是 TAOCP 还没有出完，而且其他一些领域可能并没有这样严肃、经典的书籍。如果你看一些不是那么经典的书，那么必须要跟着书中的代码和教学才能学习，但是很多书中代码环境可能已经不好配置了，学习之路会败于开始。就算硬啃完了，那么也会留下一堆问题，对基础原理的理解也不是通透。

诺奖得主费曼曾经在采访中说道：他和同事做过测试，每个人的记忆方式和大脑都是不一样的，有的人可以边数数变说话，但是有的人就不行。所以要在探索学习方法的过程中了解自己，才能找到适合自己、属于自己的方法，在这个过程中可以参考别人的学习方法，但是不能完全照搬。

在寻找自己的方法的过程中可以走弯路，也必定会走弯路，这是没关系的。这些年我最大的一个感受就是：艺无止境，功不唐捐。每当你花了很多时间精力，研究了一个现在用不到的技术，但是未来的某一天，这个技术或者学习过程中的产生物就会帮到你学习新的知识，甚至是完成一项很困难的工作。

所以趁自己有时间，还有精力有脑子，多去试试看，这样才有机会找到适合自己的学习路径。这个路径也可以借鉴到其他领域，学习其他的技术。
## 眼快
正如前文所说，学习一门计算机技术的时候，阅读视频、博客、文档、书籍等内容是必须的，如果从入门到大佬看的东西进行排序的话，那么大致顺序应该是：

![从入门到大佬看的东西大致顺序](/assets/images/d2785b0bdab9d3d9fda8182f9617babd.png)

但是实际上，很可能是三种混合着来，但是按照比例来说，大致途径是这样的。
### 看博客或视频
有些博客或视频是教程的形式，你可以跟着学习；更多的视频和博客是单独讲解一个问题或者技术中的一部分，这也能解决你遇到的大部分问题。

至于视频和博客的选择，取决于你适合什么样的学习。有些人看文字和配图就可以完成学习，但是有些人是需要动画、幻灯片才能学得会的。这二者没有高低之分，适合什么就用什么方法，不要被“方法”困住，浪费时间浪费精力。**你最终是要学会，而不是一定按照某种方法学会**。
### 阅读书籍，尤其是经典著作

阅读书籍，尤其是读经典著作是你全面掌握一门技术的必要路径和一条捷径。

读完经典著作不一定能让你立刻全面掌握，但是最终技术掌握的程度和侧重取决于你阅读的方式。不少人三十岁了才开始意识到博客并不是学习技术的全部，阅读经典书籍真的非常重要的。这是因为看博客和视频学习某一点真的很快，但是没办法

在一系列博客或者视频之后，你应该已经掌握这门技术的基础使用方法，比如编程的话，可以编写一个简单的计算器之类的。但是哪怕视频和博客中有介绍原理，这时候你对技术的整体、原理和运行机制其实并不了解，一旦任务困难了一些，你可能不能很好完成，甚至是不能完成任务。这时候就需要阅读书籍，不光是沉淀，也是拓宽自己的眼界，读一本经典著作给你带来的眼界拓宽比你刷一百个博主还要宽广（不信你可以试试看），甚至你可以找出他们的错误和纰漏。

当然并不是让你一上来就看 TAOCP 这种吓人的大部头。因为流行书内容都比较浅，但是足够给你构建起一个大致比较完整的技术知识体系框架，哪怕其中一些技术的解释是错误的也没关系。你得先在脑海里有一个框架，接下来才可以逐渐搭建起知识体系，以及纠正这些错误。

但是如果你已经有大致的框架了，你可以直接试着看经典巨著了，不用花大把精力时间在流行书籍上。这个框架没有客观的评判标准，唯一衡量方法就是你遇到一个新的知识点或者问题，能不能关联到以前学的一些东西，如果经常可以，那么就是有大致的框架了。

接下来就去读这项技术的经典著作，最好是英文原文的，因为翻译之后的书失去了英文的一些含义，很多著作的原作其实很随性，并没有那么严肃。这些著作多是业界巨擘编写的，正如数学家阿贝尔所说：

>我之所以在数学上取得成功，是因为研读的是大师的作品，而不是大师学生的作品。

这些业界巨擘耗时几年编写的著作，不光会全面的介绍技术的原理，还会介绍自己的一些想法，以及同时代的一些思想。由于很多大佬已经作古，你无法与他交谈了，但是他们的著作却还在世，所以这些著作对你的帮助是不可估量的，当然这是建立在你想成为真正的大佬。而且他们还有一些论文和博客，甚至是视频，可以作为补充。

计算机技术的发展和进步并不是 1、2、3 连续递进的，而是 a、b、c 同时出现、竞争，然后 c 活下来了，甚至吸收了 a 和 b 的一些特点发展出了你现在的看到的 d。如果你了解同时代的其他技术，那么你的能力提升幅度会更大，创新能力也更强，因为你可以拿前人的想法和技术重新组织自己要做的任务。所以了解同时代的其他想法和技术是很重要的。

下面讲一个故事吧，是一个典型例子：Go。

Go 可是现在的热门语言之一，很多人也都想学学看。但是 Go 虽然大部分源自于 C，但是并行方面却是源自于 ALef，而 Alef 是编写 Unix 和配套程序的那批人为新系统 Plan 9 发明的新语言（虽然也支持 C 和兼容 Unix）。
也就是说，为了编写 Unix，Ritchie 改进了 B 语言，从而发明了 C 语言（C 中的结构体就是为了编写 Unix 添加的）。几十年后，那批人又为了替代 Unix 发明了 Plan 9，为 Plan 9 发明了新语言 Alef（顺道一提，现在的 UTF-8 也是源自 Plan 9（这个观点是错误的，详情看下面的纠正部分））。

而在 Plan 9 替代 Unix 失败的几年后，AT&T 解散了贝尔实验室，Unix 和 Plan 9 的发明者之一 Ken Thompson 去了谷歌。谷歌就借此机会拉拢了一批人开发了 Go（三个主要开发者，两个都是来自贝尔实验室，开发过 Plan 9）。虽然现在很少有人还知道 Plan 9，但是 Go 的开发环境是有 Plan 9 的。

**2023-06-29 添加**：
>这里要纠正我的一个错误，前文说到“UTF-8 也是源自 Plan 9”，这个观点其实不对，是 Ken 先发明了 UTF-8，然后再开发的 Plan 9。
>你可能听过另一种说法“IBM 创造了 UTF-8”，但是这个说法其实也是不对的。IBM 一开始的立项是 FSS/UTF，然后找 Ken 和 Rob Pike（Plan 9 的开发者之一）来改进这个设计。但是 Ken 发现一开始列出的需求和设计就有问题，所以花了一顿晚饭的时间搞定了位包装（bit-packing），等到 Rob Pike 吃完晚饭后，他们叫来了 X/Open 项目的人解释自己的计划，然后发送了框架给 IBM 的人。IBM 认为这个设计要比自己的设计好，所以最终就采纳了这个设计。
>Rob Pike（Plan 9 的开发者之一）在一次演讲中强调解释了这个问题，然后提出如果有人如果有机会挖掘一下，是可以在内部邮件里看到 Ken 发送的邮件。演讲稿和挖掘出的内部邮件请见：[https://www.cl.cam.ac.uk/~mgk25/ucs/utf-8-history.txt](https://www.cl.cam.ac.uk/~mgk25/ucs/utf-8-history.txt)
>在此，我向之前看了这篇文章的人但是被这句话误解的人说一声抱歉。

这些人奠定了现在计算机系统的基础，影响了世界计算机的走向，Unix 和类 Unix 系统现在依旧占着服务器和一些设备的大量份额。作为一个开发人员，就得理解这些人的思路和想法。或者另一个角度来说，他们的想法可以缔造这样的成果，那么也是有可取之处的

**但是书很长很厚，而且读的过程中，你可能还要翻阅其他的书，所以这时候你看的越快，你就学的越多，也就是“眼得快”。**

### 文档和论文
官方文档是你成为大佬必须要看的东西，因为这是开发者与你的直接沟通，没有中间人，没有弯弯绕。程序有什么功能，为什么要有这个程序，程序如何运行都在文档中。
文档是描述工具目的、作用等信息的文稿。而工具往往是原理的实现。所以这个技术使用的一些命令、应用程序或者工具，去看看手册，试一试每个选项的效果和功能，都可以加深你对这个技术和程序的理解。
比如说我一开始学 Git 的时候，看了很多教程，甚至是 GitHub 的教程都不是很懂，但是看了一会官方的《Git Pro》之后，豁然开朗！

而论文是你接触这个技术新发展的途径，未来这个技术会如何发展，需要什么的知识储备，一般论文中都有。

对于一些并不是最前沿的技术，工具的文档和论文可能是你学习的唯一资料，所以要逐渐学会如何找到文档和论文，不然连学习资料都没有。
## 手快
不论你学习什么技术，数据库也好，编程也好，机器学习也好，光看书是没法学会一门技术的。计算机科学虽然带有“科学”二字，但是计算机与工程的关系还是更近一些（关于这个争论你感兴趣可以看看一开始几届图灵奖得主的演讲），所以实践是非常重要的。

要去尝试不同的工具，不同的方法，这些都要手快，这样单位时间内你进行的尝试就更多。慢，并不是时刻都优雅。

实际操作也能让你学到更多、真正学会的，并且验证你学会技术的就是实践，去完成一些 Labs，仿照已经有的项目造一造“轮子”，在这些看上无意义无结果的过程中，你会加深印象，学到更多。

而且得勇于尝试，不能只是照着打了一遍。要改一些代码，看看效果会不会变，会不会出错，为什么出错。

当然手快还有一点就是得记笔记。如果你记忆力超群那是不用记，不然就要养成记笔记的习惯，给自己的项目`README`，不然七八月之后，你啥也不记得了。

## 脑子快

脑子快一方面是指要聪明，不过这个天生的，也没啥细说的，而且聪明也不是系统学习计算机技术的必要条件；另一方面是脑子得活，要经常想一些奇思妙想，然后再手快去试试看，不清楚的地方可以查阅一些书籍资料，这样也能学到不少新东西，甚至是做出创新，而且这样的正反馈会比单纯的从头到尾阅读好得多。

## 总结
我很喜欢 scz 的一句话：你可以什么都不会，但是不能学不会。但是要学会，还学的精、学的全，真的得尽量做到这三点，哪怕脑子笨一些也够成为一个在某一技术领域能力不错的人了。
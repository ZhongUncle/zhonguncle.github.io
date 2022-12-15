---
layout: article
category: SwiftUI
---
## 前言
<!-- excerpt-start -->
之前写了一篇博客来讲如何以 point 和 pixel 两种格式获取 iPhone、iPad 等苹果设备的屏幕尺寸：
[《SwiftUI——得到屏幕尺寸(bounds和nativeBounds)》](https://blog.csdn.net/qq_33919450/article/details/113743159)，但是苹果最近做了修改，所以写这篇博客来作为补充和改进（原博客也进行了修改）。

## 原因及分析
最近一个开源项目收到一个issue，说有个bug，我想不能够啊。一检查还真有一个bug，研究了一下发现是苹果改了`UIScreen.main.bounds.height`的值。但是苹果官方没有提到过这一点，还是说整个屏幕的边界。如下：

![请添加图片描述](https://img-blog.csdnimg.cn/ef8efb9e1367425e975ee7a51bbccca2.png)

以 iPhone 11 Pro 为例，`UIScreen.main.bounds.height`的值从 1125pt 变成 812pt（举 iPhone 11 Pro 的例子是因为原博客刚好只记录了这个数据），而`UIScreen.main.bounds.width`却还是 375pt。这时候可能你会想会不会是减去了上下的 Bar 的安全区域，但是实测不是，就是整个屏幕的高。并且 iPhone 14 Pro 也是同样的情况，所以并不是只属于老设备的。
暂且不知道是 Bug 还是就是硬改了。个人猜测应该是 Bug，原因有 2 点：
1. 原本 iPhone 11 Pro 不论是`bounds`还是`nativeBounds`的高比宽的比率都是`3`。但是现在的`bounds`比率是大约`2.1`。
2. `UIScreen.main.bounds.height`的值是 812pt，但是 iPhone 11 Pro 原本的`UIScreen.main.nativeBounds.height`的值就是 812px，很怀疑是不是数据输入错误了。

基于这些怀疑原因，也向苹果进行了报告。

## 解决方案
这种情况下，如果你使用的比例来控制组件大小，基本上不影响代码。但是如果你使用具体的值来控制组件的大小，或者使用到屏幕的比例了，那么就需要一些解决方案，下面就分别针对二者提出解决方案（如果你有补充欢迎评论哦）：

1. 针对使用具体的值来控制组件的大小的情况，可以使用一个`scale`来乘在原本的值上。`scale`的表达式是一个简单的数学问题，各位拿草稿纸写一下就能知道。`scale`的表达式是:
```
(UIScreen.main.bounds.height/UIScreen.main.bounds.width)/(UIScreen.main.nativeBounds.height/UIScreen.main.nativeBounds.width)
```
这里带入 iPhone 11 Pro 原本屏幕的高度来验证一下：iPhone 11 Pro 的`scale`计算之后得到`2.16533.../3`的四舍五入的值`0.72177...`，这时候将其乘上原本的高度值`1125`就可以得到现在的`812`。
2. 针对使用到比例的代码，要么麻烦一点，对高和宽使用不同的比例；要么使用第一种办法。比如说我做的图片裁剪器，需要使用图片部分 View 的尺寸和比例，但是由于这个地方比例变了，导致出现了 Bug，所以对高和宽使用了不同的比例。

这个情况如果后续有变化这里会说明的，希望能帮到有需要的人～
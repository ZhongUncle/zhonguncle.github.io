---
layout: article
category: SwiftUI
---
苹果在Core Image API中提供了14个大类、共174个图像处理方式以及一些常见滤镜，其中一些滤镜还能处理视频甚至是实时视频，各个滤镜详情参见：[Core Image Filter Reference](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIColorClamp)

首先是如何看这个网页，也就是说这个网页提供了哪些信息，这对我们使用时非常有帮助的。以下面这个截图为例，来讲一下如何看。
![请添加图片描述](https://img-blog.csdnimg.cn/b760cad550984160a1702ba628f4d912.jpg?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAemhvbmd1bmNsZQ==,size_20,color_FFFFFF,t_70,g_se,x_16)
按照各部分来介绍：

 1. 滤镜名称。一般情况下，和部分3的本地名称一样。
 2. 滤镜功能的介绍。这里是“使用盒形卷积内核模糊图像”。
 3. 这个是本地显示名称，是我们在代码中调用滤镜的时候需要使用的名称。
 4. 参数及参数介绍。这是我们在调用滤镜时需要告诉代码的一些信息，比如这里的inputImage是输入的图片，几乎每个滤镜都会有这个参数。这里的inputRadius是滤镜模糊的程度，如果我们不做调整也就是默认值10.00。不同滤镜的参数都不一样，要自己在使用的时候查阅一下。使用的时候名称需要变形一下，需要加上加上kCI-和-Key，这个等会使用的时候细说。
 5. 这部分是滤镜所属的大类，看网页的时候可以发现苹果将其分成多个大类，我们可以通过查看这里的大类来查找相似的。但是我们会发现这里有的大类已经没有了，可能是苹果删除调整了一些滤镜和大类，但是每个滤镜下的还没有调整。
 6. 滤镜的使用效果。大部分滤镜都会有这部分来展示使用效果。
 7. 可以使用这些滤镜的系统。由于这些API都很早了，所以目前的设备都是可以使用的。

苹果将其分成17个大类，如下：

 - CICategoryBlur（模糊）
 - CICategoryColorAdjustment（颜色调整）
 - CICategoryColorEffect（颜色特效）
 - CICategoryCompositeOperation（合成操作）
 - CICategoryDistortionEffect（变形特效）
 - CICategoryGenerator（生成，例如条形码二维码）
 - CICategoryGeometryAdjustment（几何调整）
 - CICategoryGradient（渐变）
 - CICategoryHalftoneEffect（网格特效）
 - CICategoryReduction（简化图片）
 - CICategorySharpen（锐化图片）
 - CICategoryStylize（风格化图片，就是杂项）
 - CICategoryTileEffect（瓦片特效）
 - CICategoryTransition（过渡、渐变）
 
 各位可以根据需求去查找自己需要的。

接下来我们具体说说，在SwiftUI中如何使用这些官方提供的filter（滤镜或者处理方式）。
首先我们需要创建一个函数，来调用filter API，就调用刚才举例子的`CIBoxBlur`吧。头文件是`import SwiftUI`即可。我对几乎每一行代码都进行了注释，以确保各位都能很好的理解：
```swift
func blurFilter(inputImage: UIImage) -> UIImage {
    //创建一个CIContext()，用来放置处理后的内容
    let context = CIContext()
    //将输入的UIImage转变成CIImage
    let inputCIImage = CIImage(image: inputImage)!
    
    //创建用于处理图片的滤镜（Filter）
    let filter = CIFilter(name: "CIBoxBlur")!
    //这个setValue设置值的时候，后面的forKey参数跟的是文档给的参数的名字的变形，比如这里官网给的是inputRadius，加上kCI-和-Key就是应该填的参数了。
    //这里设置模糊度————也可以不写这个，就会按照默认的来
    filter.setValue(10, forKey: kCIInputRadiusKey)
    //设置输入图片
    filter.setValue(inputCIImage, forKey: kCIInputImageKey)

    // 获取经过滤镜处理之后的图片，并且将其放置在开头设置好的CIContext()中
    let result = filter.outputImage!
    let cgImage = context.createCGImage(result, from: result.extent)
    
    //返回处理好的图片
    return UIImage(cgImage: cgImage!)
}
```
这时候我们就可以很简单的使用这个滤镜了，如下：

```swift
//设置输入的图片
let image: UIImage = UIImage(named: "test")!

//获取输出图片
let outputImage = blurFilter(inputImage: image)

struct FilterView: View {
    var body: some View {
        Image(uiImage: outputImage)
            .resizable()
    }
}
```
我们就能看到处理之后的图片显示在屏幕上啦！我们来处理一下之前的截图。
![请添加图片描述](https://img-blog.csdnimg.cn/12a8a4dd2e3c445abaf86ffd2375d5de.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAemhvbmd1bmNsZQ==,size_19,color_FFFFFF,t_70,g_se,x_16)
效果还不错！

由于这些API都非常古早了，和SwiftUI搭配使用会有一些小坑，之前查阅了半天没找到解决办法，也是自己研究了才发现解决之道。
但是别看是很老的API，一些效果也过时了，就觉得这个没啥用。他们是可以嵌套的，就能做出更多的效果。

获取系统相册里的照片请查看：[https://blog.csdn.net/qq_33919450/article/details/121792908](https://blog.csdn.net/qq_33919450/article/details/121792908)
调用系统相机拍照请查看：[https://blog.csdn.net/qq_33919450/article/details/121860731](https://blog.csdn.net/qq_33919450/article/details/121860731)

希望可以帮助到有需要的人哦～
---
layout: article
category: Swift
date: 2022-09-23
title: 「SwiftUI」如何使用自带的原生图表（Charts）
---
<!-- excerpt-start -->
## 简介
在 WWDC2022 上，苹果为 SwiftUI 提供了图表相关的包`Charts`，这下就不用自己费劲实现图表功能了。代码量一下子从四五百行变成了十几行，甚至几行（还记得当时为了写图表功能写的快吐血了）。所以就想好好研究一下自带的图表功能，这样方便以后的开发和使用。

`Charts`支持 iOS/iPadOS 16.0、macOS 13.0、Mac Catalyst 16.0、tvOS 16.0 和 watchOS 9.0 及更新的系统上使用，如果是老系统的话还是得手写。

包`Charts`支持六种样式的图表，但是通过组合可以实现多种图表，下面是发布会演示的图集：

<img alt="WWDC演示的图集" src="/assets/images/ef9a47a53ed944458bb07c671b916a1b.png" style="box-shadow: 0px 0px 0px 0px">

除了这些，还有更多的样式可以实现，所以`Charts`真的需要好好研究一下。


但是本文主要介绍三种：条状图（BarMark）、点图（PointMark）和线图（LineMark）。下面会先介绍图表的基础使用方法，然后依次并详细介绍每种样式的使用方式（每种样式的使用方法大致相同，但是各有各的特色，比如线图可以一次显示多条线，条状图可以在一个图表中自定义显示多种颜色）。

![三种图表样式](/assets/images/4e8a855bc7144809aabdebab02568e1f.png)

## 基础使用方法
在开始制作图表之前，首先要准备好数据。假设我们要统计物体的形状。

数据如下：

| 样式 | 数量 |
|--|--|
| 立方体 | 5 |
| 球体 | 4 |
|锥体 | 4 |

这里的数据结构是一对一的，一个类型对应一个数量，可以说是“一维”的。

### 定义数据结构和数据
以下数据结构和数据适用于三种样式的图表，属于基础款。

为数据结构定义的结构体如下：

```swift
struct ToyShape: Identifiable {
    var type: String
    var count: Double
    var id = UUID()
}
```

初始化的存放数据的数组如下：

```swift
var data: [ToyShape] = [
    .init(type: "立方体", count: 5),
    .init(type: "球体", count: 4),
    .init(type: "锥体", count: 4)
]
```

### 如何创建一个简单的图表
**三种样式的基础图表使用方法几乎一样，所以这里只用讲一种即可。**

首先需要导入`Charts`包，如下：

```swift
import Charts
```

然后使用方法很简单，首先创建一个`Chart`界面，作为展示数据的容器：

```swift
Chart {
	//添加数据
}
```

接下来就是将数据变成点/线/条，对应的是`PointMark()`/`LineMark()`/`BarMark()`。
下面使用条状图进行演示，如果想换样式，只需要改成对应的名称，并且为了少写代码，或者方便更改，这里建议使用`ForEach`（后面会介绍如果不用`ForEach`，直接使用`Chart`也可以实现同样的效果），除了使代码简洁之外，还可以通过一些手段来进行排序（利用`ForEach`的`id`属性）：

```swift
Chart {
    ForEach(data) { shape in
        BarMark(
        	//这里的x表示图表的x轴，这里的y表示图表的y轴
        	//需要注意的是这里的数据类型是PlottableValue
            x: .value("形状", shape.type),
            y: .value("总数", shape.count)
        )
    }
}
```

这时候显示效果如下：

![条状图](/assets/images/27fabe7ae5834eed92fcf72e3bdcea7f.png)

可以看到效果不错。而且这样的话，如果想换成其他样式只要把代码中的`BarMark`更改即可，不用依次去改。

或者可以直接在`Chart`后面加个括号来实现同样的效果，如下：

```swift
Chart(data) { shape in
    BarMark(
        //这里的x表示图表的x轴，这里的y表示图表的y轴
        x: .value("形状", shape.type),
        y: .value("总数", shape.count)
    )
}
```

如下改成线图：

```swift
Chart {
    ForEach(data) { shape in
        LineMark(
            x: .value("形状", shape.type),
            y: .value("总数", shape.count)
        )
    }
}
```

![线图](/assets/images/7af1b1312eca4133be967dc90da10472.png)

点图：

```swift
Chart {
    ForEach(data) { shape in
        PointMark(
            x: .value("形状", shape.type),
            y: .value("总数", shape.count)
        )
    }
}
```

![点图](/assets/images/fac2e68ce1a14ad79a70734cb16c7c87.png)

### 定义“二维”数据结构和初始化存放数据的数组
上一节只根据物体的形状进行了统计，那如果在加上颜色呢？

假设数据如下：

| 数量 | 粉色 | 黄色 | 紫色 | 绿色 | 总数 |
|--|--|--|--|--|--|
| 立方体 | 1 | 1 | 1 | 2 |5|
| 球体 | 2 | 1 | 1 | 0 | 4 |
| 锥体 | 0 | 2 | 1 | 1 | 4 |
| 总数 | 3 | 4 | 3 | 3 | 13 |

这样多数据结构可以说是一对二了，颜色和形状对应一个数量，可以称之为“二维”数据，比之前的“一维”难了一些。


那么就需要更改数据结构和存放数据的数组了，如下：

```swift
//数据结构需要多一个颜色
struct ToyShape: Identifiable {
    var color: String
    var type: String
    var count: Double
    var id = UUID()
}

//初始化存放数据的数组
var stackedBarData: [ToyShape] = [
    .init(color: "绿色", type: "立方体", count: 2),
    .init(color: "绿色", type: "球体", count: 0),
    .init(color: "绿色", type: "锥体", count: 1),
    .init(color: "紫色", type: "立方体", count: 1),
    .init(color: "紫色", type: "球体", count: 1),
    .init(color: "紫色", type: "锥体", count: 1),
    .init(color: "粉色", type: "立方体", count: 1),
    .init(color: "粉色", type: "球体", count: 2),
    .init(color: "粉色", type: "锥体", count: 0),
    .init(color: "黄色", type: "立方体", count: 1),
    .init(color: "黄色", type: "球体", count: 1),
    .init(color: "黄色", type: "锥体", count: 2)
]
```

下面继续先以条状图为例，这里倒不是为了省事，而是为了方便理解，后面会依次解释说明三种样式。

### 如何创建一个可以显示“二维”数据的图表
对于这种“二维”数据，需要在`BarMark()`后面加上一个`foregroundStyle(by:)`方法才可以显示，并且在图表左下方，还会显示一个图例。

那么来写一个图表，用于显示不同形状中，不同颜色的占比。代码如下：

```swift
Chart {
	ForEach(stackedBarData) { shape in
		BarMark(
			//这样写就是显示不同形状中，不同颜色的占比
			x: .value("形状", shape.type),
			y: .value("总数", shape.count)
		)
		//这里由于颜色都可以和系统自带的对应不上，后面会介绍如何自定义颜色来进行正确的显示
		.foregroundStyle(by: .value("颜色", shape.color))
	}
}
```

显示效果如下：

![二维条状图](/assets/images/58c77b53ab6d48fd8571fc3e8a29c524.png)

这里就可以很直观的看到不同形状中，不同颜色的占比了。**但是如果你仔细看会发现这里颜色对应的不对**

那么线图和点图是如何显示的呢?

线图看起来会很复杂，如下：

![二维线图](/assets/images/8e12a8530e314a5bbabf5727083b8d76.png)

每一根线表示一种颜色，每个 X 轴区域对应一个形状。

点图和线图阅读方式一样，不同颜色点表示不同的颜色，每个 X 轴区域对应一个形状，但是看起来就简单不少，如下：

![二维点图](/assets/images/9a3d723c968344c3bdb87db7945bfe93.png)

### 自定义图表的颜色
上一节的图表中，由于颜色都可以和系统自带的对应不上，就需要开发者手动自定义一下来显示正确的颜色。
开发者需要在`Chart`后面使用`chartForegroundStyleScale()`关键字让`绿色`、`紫色`、`粉色`和`黄色`字符串和颜色（系统自带的或者自定义的颜色）进行关联，如下：

```swift
Chart {
	ForEach(stackedBarData) { shape in
		BarMark(
			x: .value("形状", shape.type),
			y: .value("总数", shape.count)
		)
		.foregroundStyle(by: .value("颜色", shape.color))
	}
}
//这里将字符串和系统自带的颜色进行对应，以便显示正确的颜色
.chartForegroundStyleScale(["绿色": .green, "紫色": .purple, "粉色": .pink, "黄色": .yellow])
```

现在显示效果如下：

![自定义图表的颜色](/assets/images/7b6a65e5e0374678bc2f29b39a36f0b9.png)

可以看到颜色显示正确了。

## 进阶使用方法
下面就来讲述一些刚才没有讲到的使用方法。

### 添加对比线（Rule Mark）
我不太清楚这个东西的中文名，但是一般用于对比，有时候也会用于做图，所以将其称为对比线。

有时候能看到在图表中有一根水平线，来表示超过某一数据，比如下图中的蓝色水平线，可以用来对比数据：

![图表中的蓝色水平线](/assets/images/0da80f5940c847a8a8eb1767ff645999.png)

方法很简单，就是在`Chart`的域中（就是大括号里）加上一个`RuleMark`，如下：

```swift
RuleMark(y: .value("对比线", 3))
	.foregroundStyle(.blue)
```

这里使用的是纵坐标`y`，那么可不可以使用横坐标`x`呢？答案是可以的，但是一般不使用于柱状图，而是用于线图和点图较多。因为柱状图没有使用的必要，而点图和线图中，可以用于定位点或者划分区域。

当然这个`RuleMark`也可以控制其起点和终点，这里继续以上图为例：

```swift
RuleMark(xStart: .value("起点", "立方体"), xEnd: .value("终点", "球体"), y: .value("值", 3))
	.foregroundStyle(.blue)
```

增加起点和终点之后，效果如下：

![给水平线设置起点和终点](/assets/images/d4efaf2d3d3644ba82450eec6f6a11c1.png)

当然`RuleMark`也可以直接用于作图，如下为一个统计每个月种什么的图表：

![直接用`RuleMark`作图](/assets/images/568b4d7d39584f2b912707f3ef20d009.png)

### 给线图带上点
刚才演示的线图都是一条条折线，但是如果我们想加上点来让数据更容易理解呢？
开头提到各种样式是可以叠加的，所以可以直接加上点图来实现。

```swift
import SwiftUI
import Charts

struct ToyShape: Identifiable {
    var type: String
    var count: Double
    var id = UUID()
}

var data: [ToyShape] = [
    .init(type: "Cube", count: 5),
    .init(type: "Sphere", count: 4),
    .init(type: "Pyramid", count: 4)
]

struct ContentView: View {
    var body: some View {
        VStack {
            Chart(data) { data in
                LineMark(
                    x: .value("Shape Type", data.type),
                    y: .value("Total Count", data.count)
                )
                
                //加上点图来组合形成
                PointMark(
                    x: .value("Shape Type", data.type),
                    y: .value("Total Count", data.count)
                )
            }
        }
        .padding()
    }
}
```

![给线图带上点](/assets/images/4b81d3e1eeed453f836f905e477caaa6.png)

### 自定义图表颜色
这个和其他组件一样，直接使用`Chart`的`foregroundStyle`属性即可，如下：

```swift
import SwiftUI
import Charts

struct ToyShape: Identifiable {
    var type: String
    var count: Double
    var id = UUID()
}

var data: [ToyShape] = [
    .init(type: "Cube", count: 5),
    .init(type: "Sphere", count: 4),
    .init(type: "Pyramid", count: 4)
]

struct ContentView: View {
    var body: some View {
        VStack {
            Chart(data) { data in
                LineMark(
                    x: .value("Shape Type", data.type),
                    y: .value("Total Count", data.count)
                )
                
                PointMark(
                    x: .value("Shape Type", data.type),
                    y: .value("Total Count", data.count)
                )
            }
            //这里就可以更改颜色
            .foregroundStyle(Color.pink)
        }
        .padding()
    }
}
```

如果想修改其中的点图或者线图的颜色，在对应的`LineMark`或`PointMark`后面使用`foregroundStyle`属性即可。

![自定义图表颜色为红色](/assets/images/27400270d3734cc48577a731f4afd4a2.png)


## 提醒
由于图表有很多东西可以挖，所以一篇博客肯定写不完，后续还会继续写相关的博客，如果写了会在这里贴出链接。

如果你看完本文还有一些问题没有解决，那么请查阅官方文档[《Swift Charts》](https://developer.apple.com/documentation/charts)，因为目前在 macOS 上，`Charts`还是 Beta 版本，所以本文的一些内容可能后面会被修改，如果您发现有不能用的地方，还请评论告知一下我哦。

希望能帮到有需要的人～
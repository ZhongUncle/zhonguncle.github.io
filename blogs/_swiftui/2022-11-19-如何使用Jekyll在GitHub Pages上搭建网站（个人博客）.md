---
layout: article
---
**本文很长，建议使用侧边栏进行跳转。**

Jekyll 是一个基于 Ruby 语言的，用于搭建静态网站的生成器，主要用于搭建博客网站（官方自己的介绍为：Jekyll is a blog-aware, static site generator in Ruby）。但是虽然是静态网站，但是可以实现一些使用数据库的动态网站的效果和功能，是很不错的一个框架。官网为：[https://jekyllrb.com](https://jekyllrb.com)。

虽然 Jekyll 官网提供了教学 [《step-by-step》](https://jekyllrb.com/docs/step-by-step/01-setup/)，GitHub 也提供了教学[《About Github Pages and Jekyll》](https://docs.github.com/cn/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll)，但是二者需要交叉起来看，所以这个框架还是有点简单并且复杂的。并且有一些细节没有提到。
因此，写此文来记录一下。

本文将利用 GitHub Pages 和 Jekyll 搭建一个博客网站，这也是 GitHub 推荐的搭配。**但是本文不阐述 Jekyll 的原理，只讲步骤。** 因为这样看上去简洁一点，如果你对其他相关内容可以阅读下面列出的我的其他博客：
- 如果想查看 Jekyll 的原理、机制和结构等内容，等还请移步另外一篇博客：[《Jekyll 的机制、转换步骤和结构介绍》](https://blog.csdn.net/qq_33919450/article/details/127886006)
- 如果想快速查看一些常用的 Jekyll 命令还请移步：[《Jekyll 选项（options）和子命令（subcommand）小手册》](https://blog.csdn.net/qq_33919450/article/details/127886698)
- 如果想快速查看一些常用的 Jekyll 语句和结构还请移步：[《Jekyll 选项（options）和子命令（subcommand）小手册》](https://blog.csdn.net/qq_33919450/article/details/127886698)


## 准备工作
### 安装Jekyll
Jekyll 安装方式非常简单，只要在终端/命令行输入以下命令即可：
```bash
gem install jekyll bundler
```
安装完毕之后，可以使用下面这条命令来查看安装的版本：
```bash
$ jekyll -v
jekyll 4.3.1
```
### 创建并设置GitHub pages
#### 创建GitHub pages
安装完之后，就要创建并且设置一下 GitHub Pages 了。

创建 GitHub Pages 的方法很简单：
1. 首先，创建一个名为`用户名.github.io`的 GitHub 仓库（用户名不区分大小写）；
2. 然后将这个空仓库克隆到本地。

这个时候就已经创建完毕了，可以通过`https://用户名.github.io`来访问了，并且可以像普通的 Git 项目一样进行处理和推送了（不过由于是空项目，所以不会显示什么，感兴趣可以自己推送一个网页看看）。

#### 设置GitHub pages
接下来还要调整一下该仓库的一些设置，来方便后续的工作流程。

在该仓库的设置界面，点开“Settings”->“Pages”界面，然后在“Branch”部分选择自己想要的分支（这里是默认的`main`分支），然后选择`/docs`文件夹。这样`https://用户名.github.io`就会只显示`/docs`文件夹下的内容，而不是根文件。如下：
![请添加图片描述](https://img-blog.csdnimg.cn/c3d6cb5194324d4382c0073b3b8b3835.png)
### 创建配置Jekyll的_config.yml文件
如果你是一个细心的人，会发现默认的空白仓库中是没有`docs`这个文件夹的。所以是需要我们手动创建的，但是 Jekyll 生成的文件夹在默认情况下是叫`_site`，这该怎么办呢？
如果你经常使用终端/命令行，那一定很熟悉 UNIX 命令格式`命令 -选项 参数`，如果你使用这种常规格式就会发现没有效果。这是因为 Jekyll 的命令并不是 UNIX 命令格式，它的参数需要去访问特定文件获得，而这个文件便是`_config.yml`。

所以，我们在克隆到本地的空白仓库中创建一个名为`_config.yml`的文件（也就是仓库的根目录下），然后输入以下内容：

```bash
destination: docs
```

`destination`参数表示生成的目的文件夹名称。

更多的参数可以查看官方文档：[https://jekyllrb.com/docs/configuration/options/](https://jekyllrb.com/docs/configuration/options/)

到这里，准备工作基本上已经完成，可以开始了。

## 一个简单的开始（了解工作流程）
首先来进行一个简单的开始，了解体会一下 Jekyll 的工作流程。

### 创建/修改文件
第一步，和所有网站一样，创建一个`index.html`文件（可以理解成开发的过程），内容如下：

```html
<!DOCTYPE html>
<html>
	<head>
	    <meta charset="utf-8">
	    <title>Home</title>
  	</head>
  	<body>
    	<h1>Hello World!</h1>
  	</body>
</html>
```
这是一个很简单的纯 HTML 文件，没有使用到 Jekyll 语句，但是作为理解工作流程非常有效。

### 生成静态网站
在开发完成之后，使用终端，在仓库目录下，输入以下命令来生成我们所需的静态网站：

```bash
jekyll build
```
这时候就可以发现，原本只有`index.html`和`_config.yml`2个文件的文件夹中，多了一个名为`docs`的文件夹。点开可以发现，内容就是生成的静态网站。
如果之前没有在`_config.yml`文件中进行设置，那么这里生成的文件夹应该名为`_site`。

### 在本地进行开发和演示
但是此时你可能会想：“我每次开发完都得重新生成一次静态网站，这样如果检查细节上的修改，不得烦死人啊！而且检查网站还得搭建一个本地服务器”

Jekyll 也考虑到这点，所以需要使用下面这条简单的命令，即可满足需求：

```bash
jekyll serve
```

这个命令将会在`http://localhost:4000`运行一个本地网络服务器，并且实时进行重新生成，而不用自己去搭建服务器和手动重新生成。

### 完成开发之后进行推送
在完成开发之后，就可以进行常规的提交推送了。这里专门写一节是因为这里有几个问题要说一下。

第一，如果你使用的是终端，那么有时候会有一些大范围的修改，导致`commit`的时候需要手动删掉很多`#`，很麻烦，所以建议使用`git commit -am`来跳过文本编辑器。

第二，每次提交推送还是有点麻烦，建议写个脚本，这样就只用输入一个单词，再输入一次密码即可。脚本内容如下：

```bash
#!/bin/bash

jekyll build
git add .
git commit -am
git push myblog main
```
**`myblog`部分记得改成你的仓库的地址，分支如果不是`main`也要记得更改。**

## 确定网站设计
在会基础的 Jekyll 工作流程之后，就需要确定博客网站需要哪些部分和内容，例如主页上显示什么，需不需要各种专栏等等内容。然后我们就针对每个功能和内容进行开发即可。

首先确定一下博客网站需要哪几种页面。思考一下发现就需要三种：主页、博客专栏页面、博客内容页面。

然后就是思考设计。作为非 UI 专业人士，这里使用 Procreate 绘制一个大概的图，明白什么意思即可。
主页设计如下：
![请添加图片描述](https://img-blog.csdnimg.cn/56e37abb2ec246768bd2f651ab4b05f1.png)

专栏页面的设计如下：![请添加图片描述](https://img-blog.csdnimg.cn/8f18f81d05fc4717a11c474932ebe9a0.png)

博客页面的设计如下：
![请添加图片描述](https://img-blog.csdnimg.cn/492b89267351493aae4c92a221e30961.png)

这里使用两种 CSS 
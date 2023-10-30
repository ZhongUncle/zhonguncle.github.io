---
layout: article
category: MCU
date: 2023-08-28
title: 使用树莓派Pico、DHT11和SSD1306搭建一个温度湿度计（只使用官方库，以及官方案例代码的错误之处和解决方案）
---
<!-- excerpt-start -->
最近想树莓派 Pico、DHT11 温湿度传感器和 SSD1306 OLED 屏幕做一个温度湿度计，树莓派官方案例也分别有这两个设备的案例，我就想做个简单的温度湿度计作为学习微控制器的开始，结果遇到了一个大坑，所以写本文记录一下整个过程。

本文最后会实现一个能在 SSD1306 OLED 屏幕上显示当前环境的温度和湿度，并且还要通过 USB 输出这些信息。

**由于本文很长，建议通过侧边栏方便阅读。**

本文的完整代码我放到了[GitHub-ZhongUncle/pico-temp-hum-oled](https://github.com/ZhongUncle/pico-temp-hum-oled)，并且在`build`目录下放了编译好的内容，方便读者进行尝试。

## 开发工具和环境准备
需要安装`pico-sdk`和配置相关环境变量。这部分请参阅我的另外一篇博客[《如何使用Mac终端给树莓派pico构建C/C++程序进行开发，以及遇到各种问题该怎么处理，不使用任何IDE或编辑器（例如VS Code）》](/blogs/5e449fdb610b2a4d7ee8ee742fbfe736.html)，这里就不再赘述了。
## 准备材料
实现这个需要以下材料：
- 树莓派 Pico 或 Pico W；
- SSD1306 OLED屏幕；
- DHT11 温湿度传感器；
- 导线若干；
- 面包板；
- 面包板电源（可选，因为传感器和屏幕的供电 Pico 就可以满足）。


DHT11 的针脚有 3 针和 4 针两种：

<img alt="" src="/assets/images/3079eef6fd384391a6ba3349fd3ee1bd.jpeg" height="200px">


如果是 4 针的，那么不连接针脚 3：

<img alt="" src="/assets/images/2f883839ec814d74a017ecc0d3e75c88.jpeg" height="200px">

如果你看过官方文档或者其他一些教程，那么你会看到还需要一个电阻（10k 或 4.7k 欧姆）来拉取（pull up）数据线，但是这个电阻实际上不影响官方代码不能运行，实际正常运行也不需要，所以有没有这个电阻都可以。


## 连线
Pico 的针脚图如下：

![请添加图片描述](/assets/images/1fa9d6e58bca4d9ba3483fbf7417f3dd.png)

整个电路的电源通过 Pico 实现，使用 Pin 38 作为地线，Pin 36 作为电源线，3.3V 满足这两个传感器的需求。一般传感器上都标有电源和地线标识，所以这两种按照标识连接即可。

SSD1306 的`SCL`连接到 Pin 7，而`SDA`连接到 Pin 6。选择这两个针脚是因为这是 Pico 默认的 I2C 协议接口，而 SSD 1306 是按照 I2C 协议通信的。你也可以根据情况修改针脚，但本文并没有修改默认针脚。

修改默认针脚或者指定其他针脚方法可以看看我的这两篇博客，第一篇适合任何情况，比较通用，第二篇更适合只有一个 I2C 外围设备的情况：

- [《Pico如何使用C/C++选择使用哪个I2C控制器，以及SDA和SCL针脚》](/blogs/5f1a7fd5d52116befdae2e8e54b10888.html)
- [《用C/C++修改I2C默认的SDA和SCL针脚》](/blogs/911891686f4a77e37082c2b4210451c9.html)

> 如果你对 I2C 不了解，那么可以看看这篇介绍：[BASICS OF THE I2C COMMUNICATION PROTOCOL](https://www.circuitbasics.com/basics-of-the-i2c-communication-protocol/)

DHT11 的`data`针脚可以连接到 Pico 的任意 GP 针脚，推荐 GP15 或 GP16，因为这两个一般在面包板上离传感器近，需要的导线比较短。

连接出来效果如下：

![请添加图片描述](/assets/images/4587d3df85af421497617e2442adc8ee.jpeg)

## 项目结构
**本文中实现的项目我放到了 GitHub 上，你可以弄到本地看看效果。**

新建一个文件夹`pico-temp-hum`，在里面新建 3 个文件`font.h`、`pico-temp-hum.c`、`CMakeLists.txt`和一个空白目录`build`，再将`pico-sdk`里的`pico_sdk_import.cmake`文件复制到这里。

```
$ mkdir pico-temp-hum
$ cd pico-temp-hum
$ touch font.h pico-temp-hum.c CMakeLists.txt
$ mkdir build
$ cp ../pico-sdk/pico_sdk_init.cmake pico_sdk_init.cmake
```

这时候项目结构看起来如下：

<img alt="" src="/assets/images/bcbca1ea28e24d62934dc7fb166aad8f.png" style="box-shadow: 0px 0px 0px 0px">

接下来就可以写代码了。
## 代码
### `font.h`
首先是`font.h`文件，这里是存放字体信息的文件。

SSD1306 有两种版本：128x32 和 128x64，像素纵向按 8 行划分为多页（page）。比如上图中的 128x64 版本在 RAM 是下面这样排列的：

```
       | COL0 | COL1 | COL2 | COL3 |  ...  | COL126 | COL127 |
PAGE 0 |      |      |      |      |       |        |        |
PAGE 1 |      |      |      |      |       |        |        |
PAGE 2 |      |      |      |      |       |        |        |
PAGE 3 |      |      |      |      |       |        |        |
PAGE 4 |      |      |      |      |       |        |        |
PAGE 5 |      |      |      |      |       |        |        |
PAGE 6 |      |      |      |      |       |        |        |
PAGE 7 |      |      |      |      |       |        |        |
--------------------------------------------------------------
```

在每个页内部如下（也就是按行和列确定像素）：

```
      | COL0 | COL1 | COL2 | COL3 |  ...  | COL126 | COL127 |
COM 0 |      |      |      |      |       |        |        |
COM 1 |      |      |      |      |       |        |        |
:     |      |      |      |      |       |        |        |
COM 7 |      |      |      |      |       |        |        |
-------------------------------------------------------------
```

所以使用高度为 8 的字体比较好。这里我们使用 MicroPython 项目的字体，这种字体是 8x8
 格式的，宽度和高度非常适合 SSD1306，因为 128 刚好是 8 的倍数。

在`font.h`中输入以下内容（毕竟这字体不是自己做的，还是不要删注释吧）：

```c
/*
 * This file is part of the MicroPython project, http://micropython.org/
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2013, 2014 Damien P. George
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
#ifndef MICROPY_INCLUDED_STM32_FONT_PETME128_8X8_H
#define MICROPY_INCLUDED_STM32_FONT_PETME128_8X8_H

static const uint8_t font[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 32=
    0x00, 0x00, 0x00, 0x4f, 0x4f, 0x00, 0x00, 0x00, // 33=!
    0x00, 0x07, 0x07, 0x00, 0x00, 0x07, 0x07, 0x00, // 34="
    0x14, 0x7f, 0x7f, 0x14, 0x14, 0x7f, 0x7f, 0x14, // 35=#
    0x00, 0x24, 0x2e, 0x6b, 0x6b, 0x3a, 0x12, 0x00, // 36=$
    0x00, 0x63, 0x33, 0x18, 0x0c, 0x66, 0x63, 0x00, // 37=%
    0x00, 0x32, 0x7f, 0x4d, 0x4d, 0x77, 0x72, 0x50, // 38=&
    0x00, 0x00, 0x00, 0x04, 0x06, 0x03, 0x01, 0x00, // 39='
    0x00, 0x00, 0x1c, 0x3e, 0x63, 0x41, 0x00, 0x00, // 40=(
    0x00, 0x00, 0x41, 0x63, 0x3e, 0x1c, 0x00, 0x00, // 41=)
    0x08, 0x2a, 0x3e, 0x1c, 0x1c, 0x3e, 0x2a, 0x08, // 42=*
    0x00, 0x08, 0x08, 0x3e, 0x3e, 0x08, 0x08, 0x00, // 43=+
    0x00, 0x00, 0x80, 0xe0, 0x60, 0x00, 0x00, 0x00, // 44=,
    0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x00, // 45=-
    0x00, 0x00, 0x00, 0x60, 0x60, 0x00, 0x00, 0x00, // 46=.
    0x00, 0x40, 0x60, 0x30, 0x18, 0x0c, 0x06, 0x02, // 47=/
    0x00, 0x3e, 0x7f, 0x49, 0x45, 0x7f, 0x3e, 0x00, // 48=0
    0x00, 0x40, 0x44, 0x7f, 0x7f, 0x40, 0x40, 0x00, // 49=1
    0x00, 0x62, 0x73, 0x51, 0x49, 0x4f, 0x46, 0x00, // 50=2
    0x00, 0x22, 0x63, 0x49, 0x49, 0x7f, 0x36, 0x00, // 51=3
    0x00, 0x18, 0x18, 0x14, 0x16, 0x7f, 0x7f, 0x10, // 52=4
    0x00, 0x27, 0x67, 0x45, 0x45, 0x7d, 0x39, 0x00, // 53=5
    0x00, 0x3e, 0x7f, 0x49, 0x49, 0x7b, 0x32, 0x00, // 54=6
    0x00, 0x03, 0x03, 0x79, 0x7d, 0x07, 0x03, 0x00, // 55=7
    0x00, 0x36, 0x7f, 0x49, 0x49, 0x7f, 0x36, 0x00, // 56=8
    0x00, 0x26, 0x6f, 0x49, 0x49, 0x7f, 0x3e, 0x00, // 57=9
    0x00, 0x00, 0x00, 0x24, 0x24, 0x00, 0x00, 0x00, // 58=:
    0x00, 0x00, 0x80, 0xe4, 0x64, 0x00, 0x00, 0x00, // 59=;
    0x00, 0x08, 0x1c, 0x36, 0x63, 0x41, 0x41, 0x00, // 60=<
    0x00, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x00, // 61==
    0x00, 0x41, 0x41, 0x63, 0x36, 0x1c, 0x08, 0x00, // 62=>
    0x00, 0x02, 0x03, 0x51, 0x59, 0x0f, 0x06, 0x00, // 63=?
    0x00, 0x3e, 0x7f, 0x41, 0x4d, 0x4f, 0x2e, 0x00, // 64=@
    0x00, 0x7c, 0x7e, 0x0b, 0x0b, 0x7e, 0x7c, 0x00, // 65=A
    0x00, 0x7f, 0x7f, 0x49, 0x49, 0x7f, 0x36, 0x00, // 66=B
    0x00, 0x3e, 0x7f, 0x41, 0x41, 0x63, 0x22, 0x00, // 67=C
    0x00, 0x7f, 0x7f, 0x41, 0x63, 0x3e, 0x1c, 0x00, // 68=D
    0x00, 0x7f, 0x7f, 0x49, 0x49, 0x41, 0x41, 0x00, // 69=E
    0x00, 0x7f, 0x7f, 0x09, 0x09, 0x01, 0x01, 0x00, // 70=F
    0x00, 0x3e, 0x7f, 0x41, 0x49, 0x7b, 0x3a, 0x00, // 71=G
    0x00, 0x7f, 0x7f, 0x08, 0x08, 0x7f, 0x7f, 0x00, // 72=H
    0x00, 0x00, 0x41, 0x7f, 0x7f, 0x41, 0x00, 0x00, // 73=I
    0x00, 0x20, 0x60, 0x41, 0x7f, 0x3f, 0x01, 0x00, // 74=J
    0x00, 0x7f, 0x7f, 0x1c, 0x36, 0x63, 0x41, 0x00, // 75=K
    0x00, 0x7f, 0x7f, 0x40, 0x40, 0x40, 0x40, 0x00, // 76=L
    0x00, 0x7f, 0x7f, 0x06, 0x0c, 0x06, 0x7f, 0x7f, // 77=M
    0x00, 0x7f, 0x7f, 0x0e, 0x1c, 0x7f, 0x7f, 0x00, // 78=N
    0x00, 0x3e, 0x7f, 0x41, 0x41, 0x7f, 0x3e, 0x00, // 79=O
    0x00, 0x7f, 0x7f, 0x09, 0x09, 0x0f, 0x06, 0x00, // 80=P
    0x00, 0x1e, 0x3f, 0x21, 0x61, 0x7f, 0x5e, 0x00, // 81=Q
    0x00, 0x7f, 0x7f, 0x19, 0x39, 0x6f, 0x46, 0x00, // 82=R
    0x00, 0x26, 0x6f, 0x49, 0x49, 0x7b, 0x32, 0x00, // 83=S
    0x00, 0x01, 0x01, 0x7f, 0x7f, 0x01, 0x01, 0x00, // 84=T
    0x00, 0x3f, 0x7f, 0x40, 0x40, 0x7f, 0x3f, 0x00, // 85=U
    0x00, 0x1f, 0x3f, 0x60, 0x60, 0x3f, 0x1f, 0x00, // 86=V
    0x00, 0x7f, 0x7f, 0x30, 0x18, 0x30, 0x7f, 0x7f, // 87=W
    0x00, 0x63, 0x77, 0x1c, 0x1c, 0x77, 0x63, 0x00, // 88=X
    0x00, 0x07, 0x0f, 0x78, 0x78, 0x0f, 0x07, 0x00, // 89=Y
    0x00, 0x61, 0x71, 0x59, 0x4d, 0x47, 0x43, 0x00, // 90=Z
    0x00, 0x00, 0x7f, 0x7f, 0x41, 0x41, 0x00, 0x00, // 91=[
    0x00, 0x02, 0x06, 0x0c, 0x18, 0x30, 0x60, 0x40, // 92='\'
    0x00, 0x00, 0x41, 0x41, 0x7f, 0x7f, 0x00, 0x00, // 93=]
    0x00, 0x08, 0x0c, 0x06, 0x06, 0x0c, 0x08, 0x00, // 94=^
    0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, // 95=_
    0x00, 0x00, 0x01, 0x03, 0x06, 0x04, 0x00, 0x00, // 96=`
    0x00, 0x20, 0x74, 0x54, 0x54, 0x7c, 0x78, 0x00, // 97=a
    0x00, 0x7f, 0x7f, 0x44, 0x44, 0x7c, 0x38, 0x00, // 98=b
    0x00, 0x38, 0x7c, 0x44, 0x44, 0x6c, 0x28, 0x00, // 99=c
    0x00, 0x38, 0x7c, 0x44, 0x44, 0x7f, 0x7f, 0x00, // 100=d
    0x00, 0x38, 0x7c, 0x54, 0x54, 0x5c, 0x58, 0x00, // 101=e
    0x00, 0x08, 0x7e, 0x7f, 0x09, 0x03, 0x02, 0x00, // 102=f
    0x00, 0x98, 0xbc, 0xa4, 0xa4, 0xfc, 0x7c, 0x00, // 103=g
    0x00, 0x7f, 0x7f, 0x04, 0x04, 0x7c, 0x78, 0x00, // 104=h
    0x00, 0x00, 0x00, 0x7d, 0x7d, 0x00, 0x00, 0x00, // 105=i
    0x00, 0x40, 0xc0, 0x80, 0x80, 0xfd, 0x7d, 0x00, // 106=j
    0x00, 0x7f, 0x7f, 0x30, 0x38, 0x6c, 0x44, 0x00, // 107=k
    0x00, 0x00, 0x41, 0x7f, 0x7f, 0x40, 0x00, 0x00, // 108=l
    0x00, 0x7c, 0x7c, 0x18, 0x30, 0x18, 0x7c, 0x7c, // 109=m
    0x00, 0x7c, 0x7c, 0x04, 0x04, 0x7c, 0x78, 0x00, // 110=n
    0x00, 0x38, 0x7c, 0x44, 0x44, 0x7c, 0x38, 0x00, // 111=o
    0x00, 0xfc, 0xfc, 0x24, 0x24, 0x3c, 0x18, 0x00, // 112=p
    0x00, 0x18, 0x3c, 0x24, 0x24, 0xfc, 0xfc, 0x00, // 113=q
    0x00, 0x7c, 0x7c, 0x04, 0x04, 0x0c, 0x08, 0x00, // 114=r
    0x00, 0x48, 0x5c, 0x54, 0x54, 0x74, 0x20, 0x00, // 115=s
    0x04, 0x04, 0x3f, 0x7f, 0x44, 0x64, 0x20, 0x00, // 116=t
    0x00, 0x3c, 0x7c, 0x40, 0x40, 0x7c, 0x3c, 0x00, // 117=u
    0x00, 0x1c, 0x3c, 0x60, 0x60, 0x3c, 0x1c, 0x00, // 118=v
    0x00, 0x1c, 0x7c, 0x30, 0x18, 0x30, 0x7c, 0x1c, // 119=w
    0x00, 0x44, 0x6c, 0x38, 0x38, 0x6c, 0x44, 0x00, // 120=x
    0x00, 0x9c, 0xbc, 0xa0, 0xa0, 0xfc, 0x7c, 0x00, // 121=y
    0x00, 0x44, 0x64, 0x74, 0x5c, 0x4c, 0x44, 0x00, // 122=z
    0x00, 0x08, 0x08, 0x3e, 0x77, 0x41, 0x41, 0x00, // 123={
    0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, // 124=|
    0x00, 0x41, 0x41, 0x77, 0x3e, 0x08, 0x08, 0x00, // 125=}
    0x00, 0x02, 0x03, 0x01, 0x03, 0x02, 0x03, 0x01, // 126=~
    0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, // 127
};

#endif // MICROPY_INCLUDED_STM32_FONT_PETME128_8X8_H
```

> 我在参考 Mac OS 3.2 的系统字体创作字体，这种字体很好看，也是位图字体。我在实现了一些字母发现确实要比一些常见的字体好看的多，但是实现难度不小。因为这种字体的宽度和高度并不是 8 或 8 的倍数，所以需要做一些调整。如果搞定了，那么会替换上面和 GitHub 项目里的内容。

### `pico-temp-hum.c`
#### 头文件
首先是添加头文件：

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <math.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "hardware/gpio.h"
#include "ssd1306_font.h"
```

#### SSD1306相关代码
然后是添加一堆后面可能会使用到的宏，主要是 SSD1306 的命令。介绍还请看注释：

```c
//根据你SSD1306的规格设置SSD1306_HEIGHT为32或64
#define SSD1306_HEIGHT              64
#define SSD1306_WIDTH               128

#define SSD1306_I2C_ADDR            _u(0x3C)

//SSD1306时钟速率，一般是400000（40MHz），但是会有频闪现象，为了减缓频闪和提升响应速度，建议使用1000000（100MHz）
#define SSD1306_I2C_CLK             1000000

//SSD1306的命令（更多可以参阅SSD1306数据表 https://www.digikey.com/htmldatasheets/production/2047793/0/0/1/ssd1306.html）
#define SSD1306_SET_MEM_MODE        _u(0x20)
#define SSD1306_SET_COL_ADDR        _u(0x21)
#define SSD1306_SET_PAGE_ADDR       _u(0x22)
#define SSD1306_SET_HORIZ_SCROLL    _u(0x26)
#define SSD1306_SET_SCROLL          _u(0x2E)

#define SSD1306_SET_DISP_START_LINE _u(0x40)

#define SSD1306_SET_CONTRAST        _u(0x81)
#define SSD1306_SET_CHARGE_PUMP     _u(0x8D)

#define SSD1306_SET_SEG_REMAP       _u(0xA0)
#define SSD1306_SET_ENTIRE_ON       _u(0xA4)
#define SSD1306_SET_ALL_ON          _u(0xA5)
#define SSD1306_SET_NORM_DISP       _u(0xA6)
#define SSD1306_SET_INV_DISP        _u(0xA7)
#define SSD1306_SET_MUX_RATIO       _u(0xA8)
#define SSD1306_SET_DISP            _u(0xAE)
#define SSD1306_SET_COM_OUT_DIR     _u(0xC0)
#define SSD1306_SET_COM_OUT_DIR_FLIP _u(0xC0)

#define SSD1306_SET_DISP_OFFSET     _u(0xD3)
#define SSD1306_SET_DISP_CLK_DIV    _u(0xD5)
#define SSD1306_SET_PRECHARGE       _u(0xD9)
#define SSD1306_SET_COM_PIN_CFG     _u(0xDA)
#define SSD1306_SET_VCOM_DESEL      _u(0xDB)

//页高
#define SSD1306_PAGE_HEIGHT         _u(8)
//页的数量
#define SSD1306_NUM_PAGES           (SSD1306_HEIGHT / SSD1306_PAGE_HEIGHT)
//页面内容的缓冲区域，这部分内容在渲染之后会显示到屏幕上
#define SSD1306_BUF_LEN             (SSD1306_NUM_PAGES * SSD1306_WIDTH)

#define SSD1306_WRITE_MODE         _u(0xFE)
#define SSD1306_READ_MODE          _u(0xFF)
```

然后添加一个结构体，用来存放渲染区域的数据，包括起始列、起始页，这样我们既可以渲染整个屏幕，也可以只渲染一部分：

```c
struct render_area {
    uint8_t start_col;
    uint8_t end_col;
    uint8_t start_page;
    uint8_t end_page;

    int buflen;
};
```

然后添加一个函数用来计算渲染区域的长度，将值赋予给上面结构体对象的`buflen`变量。因为我们可能需要清零渲染屏幕的缓冲，这个需要知道渲染区域的长度，不然会导致一些内容没有被清理或者覆盖掉，具体情况后面会提及：

```c
void calc_render_area_buflen(struct render_area *area) {
    //计算渲染区域的长度
    area->buflen = (area->end_col - area->start_col + 1) * (area->end_page - area->start_page + 1);
}
```

接下来是 SSD1306 命令相关的代码，SSD1306 的支持一系列的命令来操作屏幕，命令具体情况请查看数据表：

```c
void SSD1306_send_cmd(uint8_t cmd) {
    // I2C write process expects a control byte followed by data
    // this "data" can be a command or data to follow up a command
    // Co = 1, D/C = 0 => the driver expects a command（控制为1，数据或命令为0）
    //I2C写入进程需要一个控制字节和数据。数据可以也是一个命令或者跟着命令的数据。比如说
    uint8_t buf[2] = {0x80, cmd};
    //第一个参数表示用的哪个i2c控制器，i2c0或i2c1。这里默认为i2c0
    //第二个参数是要读取的设备的7位地址。这个前面定义宏的时候设置了，为0x3C
    //第三个参数是指向接收数据的缓冲的指针。你可能会疑问上面不是数组吗？C里面数组名其实就是指针）
    //第四个参数是接收数据的长度（单位为字节）。这里就为2
    //第五个参数如果是真，那么主机在交换数据之后保持对bus的控制。这里为false
    i2c_write_blocking(i2c_default, SSD1306_I2C_ADDR, buf, 2, false);
}

void SSD1306_send_cmd_list(uint8_t *buf, int num) {
    for (int i=0;i<num;i++)
        SSD1306_send_cmd(buf[i]);
}

void SSD1306_send_buf(uint8_t buf[], int buflen) {
    //水平地址模式下，列地址指针自动增加并且包括下一个页，所以可以一个交换就可以发送包含整个帧的缓冲
	//复制帧缓冲到一个新的缓冲中是为了在开始添加一个控制字节
    uint8_t *temp_buf = malloc(buflen + 1);

    temp_buf[0] = 0x40;
    memcpy(temp_buf+1, buf, buflen);

    i2c_write_blocking(i2c_default, SSD1306_I2C_ADDR, temp_buf, buflen + 1, false);

    free(temp_buf);
}
```

然后编写 SSD1306 的初始化函数。需要注意`cmds[]`里的命令都是上面宏区域定义过的，有些后面会跟着需要设置的值，但是有些命令是自身决定设置值的。这只是个简单的数组，并不是什么特殊的数据结构：

```c
void SSD1306_init() {
    /* 这里是重置进程为默认情况的完整流程，但是不同厂商的可能不一样 */
    uint8_t cmds[] = {
        SSD1306_SET_DISP,               //关闭显示器
        /* 内存映射 */
        SSD1306_SET_MEM_MODE,           //设置内存地址模式。0为横向地址模式，1为纵向地址模式，2为页地址模式
        0x00,                           //设置为横向寻址模式
        /* 分辨率和布局 */
        SSD1306_SET_DISP_START_LINE,    //设置显示的开始行为0（后面没有设置参数就为0）
        SSD1306_SET_SEG_REMAP | 0x01,   //重新映射分区，列地址127被映射到SEG0
        SSD1306_SET_MUX_RATIO,          //设置多路传输速率
        SSD1306_HEIGHT - 1,             //显示为高度减去1（因为这里是从0开始的）
        SSD1306_SET_COM_OUT_DIR | 0x08, //输出扫描方向。这里是从底部往上扫描，也就是COM[N-1]到COM0
        SSD1306_SET_DISP_OFFSET,        //设置显示的偏移量
        0x00,                           //设置为无偏移
        SSD1306_SET_COM_PIN_CFG,        //设置COM（common）针脚硬件配置。板子会指定一个特殊值

/* 128x32分辨率会使用0x02，128x64分辨率可以使用0x12，如果不能正常工作，那么使用0x22或0x32 */
#if ((SSD1306_WIDTH == 128) && (SSD1306_HEIGHT == 32))
        0x02,
#elif ((SSD1306_WIDTH == 128) && (SSD1306_HEIGHT == 64))
        0x12,
#else
        0x02,
#endif
        
        /* 计时和驱动规划 */
        SSD1306_SET_DISP_CLK_DIV,       //设置显示的时钟除法比（divide ratio，这个中文术语是啥？）
        0x80,                           //标准频率中1的除法比
        SSD1306_SET_PRECHARGE,          //设置每次交换的周期
        0xF1,                           //板子上产生的Vcc
        SSD1306_SET_VCOM_DESEL,         //设置VCOMH取消级别
        0x30,                           //0.83xVcc
        /* 显示 */
        SSD1306_SET_CONTRAST,           //设置对比度
        0xFF,							//设置为满的0xFF
        SSD1306_SET_ENTIRE_ON,          //设置整个显示器来跟随RAM内容（也就是显示 RAM的内容）
        SSD1306_SET_NORM_DISP,          //设置常规显示（不是颠倒的）
        SSD1306_SET_CHARGE_PUMP,        //设置充电泵 set charge pump
        0x14,                           //板子上产生的Vcc
        SSD1306_SET_SCROLL | 0x00,      //设置这个会停用水平滚动。这很重要，因为如果启用了滚动，那么当内存写入将出错
        SSD1306_SET_DISP | 0x01, //打开显示器
    };

    SSD1306_send_cmd_list(cmds, count_of(cmds));
}
```

#### 渲染相关的代码

接下来编写渲染函数，这会将缓冲里的数据渲染到显示器上：

```c
void render(uint8_t *buf, struct render_area *area) {
    //用*area更新显示器的某个区域
    uint8_t cmds[] = {
        SSD1306_SET_COL_ADDR,
        area->start_col,
        area->end_col,
        SSD1306_SET_PAGE_ADDR,
        area->start_page,
        area->end_page
    };
    
    SSD1306_send_cmd_list(cmds, count_of(cmds));
    SSD1306_send_buf(buf, area->buflen);
}
```

接下来是处理字符，需要将之前那个字符集找到需要的字符，然后经过转换和传递，最后将其显示到屏幕上：

```c
/* 从字符集从获取字符ch的下标 */
static inline int GetFontIndex(uint8_t ch) {
    if (ch >= ' ' && ch <= 127) {
        return  ch - ' ';
    }
    else return  0; //如果没找到返回空格的下标
}

/* 输出一个字符ch到buf，起始位置为（x, y） */
static void WriteChar(uint8_t *buf, int16_t x, int16_t y, uint8_t ch) {
	//如果超出屏幕了
    if (x > SSD1306_WIDTH - 8 || y > SSD1306_HEIGHT - 8)
        return;

    //之前说过每一行其实是一页，一页的高度是8个像素，这里的y也是行的上界。
    y = y/8;
	
	//获取字符ch的下标
    int idx = GetFontIndex(ch);
    //这里是计算了实际初始位置，也就是第几行（y * 128）的第几个（x）
    int fb_idx = y * 128 + x;

	//输出字符ch的每一位
    for (int i=0;i<8;i++) {
        buf[fb_idx++] = font[idx * 8 + i];
    }
}

/* 输出多个字符就是输出字符串了 */
static void WriteString(uint8_t *buf, int16_t x, int16_t y, char *str) {
    if (x > SSD1306_WIDTH - 8 || y > SSD1306_HEIGHT - 8)
        return;

    while (*str) {
        WriteChar(buf, x, y, *str++);
        x+=8;
    }
}
```

#### DHT11运行原理

接下来编写代码从 DHT11 中读取数据。在这之前需要知道 DHT11 的工作机制，才知道如何编写代码。整体流程如下：

![请添加图片描述](/assets/images/9cbfb88ed5ea4c87800b294e05c9f44a.png)

其中各部分如下：

![请添加图片描述](/assets/images/f4dd56b1b79846249f36dadbf9f1f7ec.png)

传递数据的时候根据以下信号来判断是`0`还是`1`：
![请添加图片描述](/assets/images/8e3ce9ad0f1b407eb0d7c7c9317884f7.png)

![请添加图片描述](/assets/images/f91aa0f0bc8444e4a7a1079bf133e6ae.png)

这里的时长要需要注意：
1. 最开始 Pico 发送万开始信号和拉低电压必须不少于 18ms，这样 DHT11 才能获取信号；
2. 接下来 Pico 拉高电压等待 DHT11 回应需要 20～40us。**这点一定要注意**，因为`pico-examples`中相关代码并没有等待回应的时间，这会导致无法获取数据，或者获取数据一段时间后失败；
3. DHT11 发送回应并且会保持 80us，然后再拉高电平再保持80us；
4. 传递数据的时候，50us 低电平和 26～28us 高电平意味着数据一位`0`，50us 低电平和 70us 高电平意味着数据一位`1`。
5. 此外，DHT11在通电的前 1000ms 内无法获取数据，最快响应时间为6秒，最慢为 30s。每次通信大约需要 4ms。

DHT11 发送的 40 位数据先发高位的，内容为：8 位湿度整数数 + 8位湿度浮点数 + 8 位温度整数数 + 8位温度浮点数 + 8 位校验和。
#### DHT11相关代码和运行原理

首先设置连接的 GPIO 针脚是哪一个，以及设置最大时长：

```c
const uint DHT_PIN = 16;
const uint MAX_TIMINGS = 85;
```

然后声明一个结构体用来存放 DHT11 获取的湿度和温度：

```c
typedef struct {
    float humidity;
    float temperature;
} dht_reading;
```

接下来编写从 DHT11 读取数据的函数：
```c
void read_from_dht(dht_reading *result) {
    //信号值有40bit，也就是5个字节
    int data[5] = {0, 0, 0, 0, 0};
    //纪录上一种信号的类型
    uint last = 1;
    //纪录当前信号是第几位数据
    uint j = 0;
	
	/* Pico发送信号阶段 */ 
    //信号方向是DHT_PIN到GPIO_OUT，给DHT11发送一些信号。这里的dir是direction
    gpio_set_dir(DHT_PIN, GPIO_OUT);
    //给DHT_PIN输出低电平，并且维持18ms，这样让DHT11可以获取到这个信号
    gpio_put(DHT_PIN, 0);
    sleep_ms(18);
    //给DHT_PIN输出高电平，维持40us，用来等待 DHT11 的回应
    gpio_put(DHT_PIN,1);
    sleep_us(40);

	/* DHT发送信号阶段 */ 
    //反转信号方向，从DHT_PIN到GPIO_IN，这样来获取DHT11的数据
    gpio_set_dir(DHT_PIN, GPIO_IN);
    
	//这里开始获取和处理DHT11的输出的信号
    for (uint i = 0; i < MAX_TIMINGS; i++) {
    	//count用来计时的，单位为255
        uint count = 0;
        //如果获取的电平与上一个信号的电平相同，那么一直循环，这个用来消耗上文提到的等待时间
        //一开始DHT11有80us的低电平来作为回复，所以第一次循环的时候last为1（高电平）就直接跳过循环了，然后last也变成了0（低电平）。这样第二次循环的时候就会进入下面的循环耗时间。DHT11拉高电平之后就重复一遍这个操作
        //后续DHT11信号前面的50us也是这样处理的
        while (gpio_get(DHT_PIN) == last) {
        	//开始迭代计数进行计时
            count++;
            sleep_us(1);
            //如果当前时常已经超过100us，那么这次整个外层迭代跳过，但是由于break只能跳过一层迭代，所以外层还要break一次
            //选择任意大于信号最大周期的值即可，不一定是100
            if (count == 100) 
            	break;
        }
        //将当前电平赋值给DHT_PIN
        last = gpio_get(DHT_PIN);
        //这个判断可不是多余的，这是用来彻底跳出外层迭代。不然会出现先显示湿度和温度的整数部分，再显示湿度和温度的浮点部分。一次获取无法获取完整的数据
        if (count == 100) 
			break;

		//这里开始获取数据了
		//i>=4是因为前三个循环里分别是回应保持低电平、拉高电平和第一个数据位开始的50us
		//i % 2 == 0是因为奇数次都是数据位开始的50us，没有存放的数据
        if ((i >= 4) && (i % 2 == 0)) {
        	//j/8刚好可以表示这是第几个字节
        	//右移一位，这样8bit的数据只用设置最右的一位即可
            data[j / 8] <<= 1;
            //如果当前信号超过35，那么将最右一位设置为1
            //这个35是因为26～28表示0，大于这个范围的便表示1了，但是由于通信时间可能需要一段时间，所以留了一些冗余
            if (count > 35) 
            	data[j / 8] |= 1;
            j++;
        }
    }

	//获取到40位数据并且校验和(data[4] == ((data[0] + data[1] + data[2] + data[3]) & 0xFF))也是对的，那么将结果保存到result指针指向的结构体中
    if ((j >= 40) && (data[4] == ((data[0] + data[1] + data[2] + data[3]) & 0xFF))) {
        result->humidity = (float) ((data[0] << 8) + data[1]) / 10;
        if (result->humidity > 100) {
            result->humidity = data[0];
        }
        result->temperature = (float) (((data[2] & 0x7F) << 8) + data[3]) / 10;
        if (result->temperature > 125) {
            result->temperature = data[2];
        }
        if (data[2] & 0x80) {
            result->temperature = -result->temperature;
        }
    } else {
    	//如果数据不对那么打印debug信息
        printf("Bad data\n");
    }
}
```

#### `main`函数
这里是整个程序的主体了，将使用上面声明的函数来实现需要的效果：

```c
int main() {
    stdio_init_all();
    /* 初始化 GPIO */
    gpio_init(DHT_PIN);
    
    /* 初始化默认的i2c控制器以及针脚 */
    i2c_init(i2c_default, SSD1306_I2C_CLK);
    gpio_set_function(PICO_DEFAULT_I2C_SDA_PIN, GPIO_FUNC_I2C);
    gpio_set_function(PICO_DEFAULT_I2C_SCL_PIN, GPIO_FUNC_I2C);
    gpio_pull_up(PICO_DEFAULT_I2C_SDA_PIN);
    gpio_pull_up(PICO_DEFAULT_I2C_SCL_PIN);
    
    /* 初始化SSD1306 */
    SSD1306_init();

    /* 初始化 frame_area 渲染区域（大小为SSD1306_WIDTH乘以SSD1306_NUM_PAGES） */
    struct render_area frame_area = {
        start_col: 0,
        end_col : SSD1306_WIDTH - 1,
        start_page : 0,
        end_page : SSD1306_NUM_PAGES - 1
    };
    
    /* 计算frame_area图像缓冲长度 */
    calc_render_area_buflen(&frame_area);
    
    /* 声明一个数组来存放缓冲，长度为上面的计算的 */
    uint8_t buf[SSD1306_BUF_LEN];
    /* 预先清空缓冲和屏幕 */
    //给这个数组每个元素分配为0（因为可能这个内存之前没有被清空，这样会显示花屏）
    memset(buf, 0, SSD1306_BUF_LEN);
    //然后渲染这个缓冲
    render(buf, &frame_area);
    
    //存放温度和湿度的字符串，方便后面渲染到屏幕上
    char temp[16];
    char hum[16];

	//第一次之前等待1000ms，不然可能第一次获取数据会失败
	sleep_ms(1000);
	
    /* 不断循环获取数据并且渲染到屏幕上 */
    while (true) {
    	//声明一个dht_reading变量：reading，然后将从DHT11读取的数据存放到reading中
        dht_reading reading;
        read_from_dht(&reading);
        
        //给这个数组每个元素分配为0，不然上次显示的内容可能还在缓冲中，这样下次渲染显示会出问题
        memset(buf, 0, SSD1306_BUF_LEN);
		
		//生成字符串用来打印，分别存放到temp和hum字符数组中，然后再将其写入到缓冲数组buf中
        sprintf(temp, "temp = %.02f C", reading.temperature);
        //这个printf是给串口USB输出，后面演示可以看到
        printf("temp = %.02f C\n", reading.temperature);
        WriteString(buf, 0, 0, temp);
        sprintf(hum, "hum  = %.02f %%", reading.humidity);
        printf("hum  = %.02f %%\n", reading.humidity);
        //由于行高为8，所以第二行写入的y值要加8，当然你如果想让行距好看一些，可以设置为10，比如说这里
        WriteString(buf, 0, 8, hum);
        
        //渲染缓冲
        render(buf, &frame_area);
        
        //等待6000ms，因为DHT11的最小响应时间为6秒
        sleep_ms(6000);
    }
}
```

### `CMakeLists.txt`

然后在`CMakeLists.txt`文件中放入以下内容：

```
cmake_minimum_required(VERSION 3.12)

include(pico_sdk_import.cmake)

project(pico-temp-hum)

pico_sdk_init()

if (TARGET tinyusb_device)
	add_executable(pico-temp-hum
        	pico-temp-hum.c
        )

    # 添加依赖项
    target_link_libraries(pico-temp-hum pico_stdlib hardware_adc hardware_i2c)

    # 激活USB输出，关闭UART输出（也可以全开）
    pico_enable_stdio_usb(pico-temp-hum 1)
    pico_enable_stdio_uart(pico-temp-hum 0)

    # 创建映射/bin/hex/uf2等文件
    pico_add_extra_outputs(pico-temp-hum)

elseif(PICO_ON_DEVICE)
    message(WARNING "not building hello_usb because TinyUSB submodule is not initialized in the SDK")
endif()
```


## 构建项目以及烧录

首先进入`build`目录：

```
$ cd build
```

然后使用以下命令进行构建：

```
$ cmake .. && make -j6
...
[ 98%] Building C object CMakeFiles/pico-temp-hum.dir/Users/zhongyijiang/Desktop/pico/pico-sdk/src/rp2_common/hardware_i2c/i2c.c.obj
[100%] Linking CXX executable pico-temp-hum.elf
[100%] Built target pico-temp-hum
```

接下来将其烧录到 Pico 上。先按住 Pico 上的“BOOTSEL”按钮，再插入线缆连接到电脑，这时候 Pico 会进入 USB 存储模式。

然后将构建出来的`pico-temp-hum.uf2`拖入其中即可。如果是只能使用终端那么可以使用以下命令：

```
$ cp pico-temp-hum.uf2 /Volumes/RPI-RP2/pico-temp-hum.uf2
```

这是 macOS 的版本，如果你使用的是 Ubuntu 或者 WSL，那么将`/Volumes/`改成`/dev/`即可（`RPI-RP2`可能也需要小写）。

这时候会显示异常弹出，这是正常的不用担心。

## 最终成果
这时候你就能看到这样的效果啦：

![请添加图片描述](/assets/images/d81f513cd42a487a94ab511d8b00622f.jpeg)

如果你使用串行交流程序查看的话，比如`minicom`，使用的命令如下：

```
$ minicom -D /dev/cu.usbmodem1431301 -b 115200
```

这里的`cu.usbmodem1431301`不是一定的，每次连接的值都有可能不同，需要根据实际情况进行修改。

在串行交流程序中会看到下面的情况：

<img alt="" src="/assets/images/64f939e019b94483af63d9284333179b.png" style="box-shadow: 0px 0px 0px 0px">

可以看到除了`%`因为传递问题没显示好，其他都一切正常，和 OLED 上显示的一样。

我将完整的项目放到了[GitHub-ZhongUncle/pico-temp-hum-oled](https://github.com/ZhongUncle/pico-temp-hum-oled)，并且在`build`目录下放了编译好的内容，方便读者进行尝试。

## 扩展阅读
这里有一些扩展资料，是我在研究过程中发现或者参考的，还有一些我在这个过程中写的博客，感兴趣可以看看。

[《SSD1306 Advance Information》](https://www.digikey.com/htmldatasheets/production/2047793/0/0/1/SSD1306.pdf) 这个相当于 SSD1306 的参数表，里面介绍了很多信息，包括文中提到的命令等信息。

[《DHT11 Humidity & Temperature Sensor》](https://www.mouser.com/datasheet/2/758/DHT11-Technical-Data-Sheet-Translated-Version-1143054.pdf) 这是一份 DHT11 的文档，介绍了一些相关信息和运行机制，上文中的截图就来自于此。需要注意不同厂商的 DHT11 文档不一样，这份虽然不长，但是内容详尽得多。

[https://learn.sparkfun.com/tutorials/i2c/all](https://learn.sparkfun.com/tutorials/i2c/all) 这是一篇介绍 I2C 的文章，如果不了解 I2C 可以看看。

[https://forums.raspberrypi.com/viewtopic.php?t=338243](https://forums.raspberrypi.com/viewtopic.php?t=338243) 这篇帖子有人询问如何修改默认 I2C 针脚，然后树莓派官方工程师回答了方法：

![请添加图片描述](/assets/images/d430b95834c54b88bd104ef003be72bb.png)

但是其中定义在源代码中的方法不太对，正如他所说的不确定。所以我通过实践总结了这些方法，并且写了一篇博客：[《用C/C++修改I2C默认的SDA和SCL针脚》](/blogs/911891686f4a77e37082c2b4210451c9.html)

然后我经过自己刨根问底式的探究了如何制定某个针脚，而不是使用默认值或者修改默认值：[《Pico如何使用C/C++选择使用哪个I2C控制器，以及SDA和SCL针脚》](/blogs/5f1a7fd5d52116befdae2e8e54b10888.html)


此外，对于`_u`这个宏是什么意思我是通过这篇帖子知道的：[#define _u macro?](https://forums.raspberrypi.com/viewtopic.php?t=330222#:~:text=#ifndef%20_u%20#ifdef%20__ASSEMBLER__%20#define%20_u%20%28x%29%20x,where%20the%20u%20suffix%20would%20have%20been%20illegal.)

希望能帮到有需要的人～
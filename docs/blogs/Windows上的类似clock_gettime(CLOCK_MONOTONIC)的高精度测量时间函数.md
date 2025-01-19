>2024年4月11更新
>感谢评论提醒，我之前写[《如何在C/C++中测量一个函数或者功能的运行时间（串行和并行，以及三种方法的实际情况对比）》](https://blog.csdn.net/qq_33919450/article/details/134653349)的时候只实验了 Linux 和 Mac 这种类 Unix 系统，没考虑到 Windows。

本文只考虑第一方（微软）的时间测量功能，有一些第三方高精度测量时间的库这里不讨论。

Windows 中高精度测量时间间隔最佳方法是 QPC（QueryPerformanceCounter，查询性能计数器）。

QPC 不依赖于外部时间参考，是一个差动时钟（Difference Clocks），而不是一般我们常说的绝对时间（例如“2020/3/18 14:29:59”，有时也被很形象地称为墙上时间）类似`clock()`。并且 QPC 并不会受标准时间、系统时间的影响，类似`clock_gettime()`中的`CLOCK_MONOTONIC`。

>QPC 使用硬件计数器来计算时间。
>一般在 x86 架构设备上， QPC 来测量时间是通过访问处理器的的 TSC（时间戳计数器）来实现的，不过某些设备的 BIOS 可能不能正确设置 CPU 特性，比如设置成可变 TSC，那这个就会受其他一些因素的影响了。或者拥有多个处理器的设备，因为这样就有两个 TSC 来源了，他们俩不一定一样。如果出现这种情况，那么 Windows 会使用平台计数器或者主板上其他的计时器，而不是 TSC。这样的话成本会高 0.8～1.0 微秒。
>虽然主要是使用 TSC 实现的，但是微软官方不建议使用使用 RDTSC/RDTSCP（后者多一个指定 CPU）来直接获取 TSC 信息，因为这样软件程序的兼容性会大大降低（比如说程序运行在可变 TSC 或者没有 TSC 的设备系统上，代码可能无法运行或者误差较大）。
>一般 C/C++ 编译器是有内置函数`__builtin_ia32_rdtsc()`或`__builtin_ia32_rdtscp()`，所以你可以直接使用`uint64_t rdtsc = rdtsc();`这句代码来获取计数器的计数，然后做差，类似`clock()`的使用方法，不过你还要计算一下 TSC 频率来获取准确时间。
>**TSC 只是其中之一，Windows 8 及之后版本的 Windows 会使用多个硬件计数器来检测误差，并尽量补偿。**

但是 QPC 精度比`clock_gettime()`方法低两个数量级，只能达到 100 纳秒，做不到`clock_gettime()`的 1 纳秒精度，不过大多情况都足够使用了。

下面是 QPC 的一个例子（第一行是为说明需要导入哪个库）：

```c
#include <windows.h>

int main()
{
    LARGE_INTEGER StartingTime, EndingTime, ElapsedMicroseconds;
    LARGE_INTEGER Frequency;

    QueryPerformanceFrequency(&Frequency);
    QueryPerformanceCounter(&StartingTime);
	
    ...需要被测量的代码

    QueryPerformanceCounter(&EndingTime);
    printf(" %.1f us", 1000000*((double)EndingTime.QuadPart - StartingTime.QuadPart)/ Frequency.QuadPart);   
}
```

`LARGE_INTEGER`是 Windows 上的一个 union，它的内容如下：

```c
typedef union _LARGE_INTEGER {
  struct {
    DWORD LowPart;
    LONG  HighPart;
  } DUMMYSTRUCTNAME;
  struct {
    DWORD LowPart;
    LONG  HighPart;
  } u;
  LONGLONG QuadPart;
} LARGE_INTEGER;
```

它是 Windows 上用来存放 64 位整数的一个数据类型。如果编译器内置了对 64 位整数的支持，请使用 QuadPart 成员来存储 64 位整数。否则，请使用 LowPart 和 HighPart 成员来存储 64 位整数。可以看到上面例子中是使用`QuadPart`成员变量来读取一个 64 位的整数。

>如果你对 union 不熟悉，请看我的另外一篇博客：[C——Union是什么？Union和Struct这么像，区别在哪？为什么还要创造出union呢？需要在哪里使用呢？](https://blog.csdn.net/qq_33919450/article/details/130613405)

`QueryPerformanceFrequency`是获取计数器频率。前文也提到过， QPC 是通过 TSC 之类的硬件计数器实现的，所以需要知道晶振的频率，通过`计数/频率`来计算出时间。

`QueryPerformanceCounter`用来获取当前计数值。

`printf(" %.1f us", 1000000*((double)EndingTime.QuadPart - StartingTime.QuadPart)/ Frequency.QuadPart);`就是用来打印计算出的时间。`((double)EndingTime.QuadPart - StartingTime.QuadPart)/ Frequency.QuadPart`就是`计数/频率`这个公式了。前面的`1000000`用来转换单位，表示微秒。如果你要计算毫秒就是`1000`，纳秒就是`1000000000`。

需要注意针对不同单位使用不同的`%.xf`。前面提到的精度只有 100 纳秒，如果你使用`1000000000`，以纳秒为单位，会发现整数最右边两位永远是`0`，如下：

![请添加图片描述](https://img-blog.csdnimg.cn/direct/25c52ad13a254b5aa7d5a7e61358f6cb.png =x350)

所以打印微秒时使用`%.1f`，纳秒时使用`%.f`或`%.0f`即可。再多的位数就超出精度范围了（当然或许会有对齐等情况的需要，所以还是看自己，这只是一个建议）。

希望能帮到有需要的人～

## 参考资料/扩展阅读

[Acquiring high-resolution time stamps - Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps)：这篇是微软官方关于获取高精度时间的文章，如果你想了解一些关于 Windows 如何获取时间的底层和其他知识可以看看。我觉得最值得看的就是关于误差的那部分[Resolution, Precision, Accuracy, and Stability](https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps#resolution-precision-accuracy-and-stability)，介绍了通过硬件计数器获取时间的时候会造成误差的一些原因，是一个不错的扩展。

[Time - Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/sysinfo/time)：介绍 Windows 上各种时间的专栏。

[LARGE_INTEGER union (winnt.h) - Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-large_integer-r1)：`LARGE_INTEGER`的介绍。



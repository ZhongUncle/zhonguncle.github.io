---
layout: article
category: Web
date: 2022-06-03
title: Python 如何输出数据
---
<!-- excerpt-start -->
输出数据有从格式上来说有两种：格式化输出和直接输出。比如 C 语言中最常见的`printf`函数名中的`f`就是 formatted（被格式化）的意思，可以通过`%d`等换算符（conversions）来打印不同的数据类型。

Python 也分这两种：一般用于直接输出的有表达式，`str()`和`print()`函数（需要注意的是它不光只能用于直接输出）；格式化输出有很多种，后面细说。

## 直接输出
直接输出有以下几种方式：
### 表达式
通过表达式可以直接输出结果，如下：

```python
>>> 1+1
2
```

### str()
`str()`会直接以字符串输出括号里的内容。如下：

```python
>>> str(b'Zoot!')
"b'Zoot!'"
```

### print()
`print()`以字符串（string）格式输出。

```python
# 输出数字
>>> print(123)
123
# 输出字符串
>>> print("abc")
abc
# 一次性输出三个变量的值，变量用逗号隔开，那么输出的值会用空格隔开
>>> a=1
>>> b=2
>>> c="abc"
>>> print(a,b,c)
1 2 abc
# 一次性输出两个值，用逗号隔开，那么输出的字符串会用空格隔开
>>> print("Hello","World!")
Hello World!
# 一次性输出两个值，不用逗号隔开，那么输出的字符串就是连起来的
>>> print("Hello""World!")
HelloWorld!
# 一次性输出两个值，用逗号隔开，并且设置分隔符是句点，那么输出的字符串会用句点隔开
# 这个可以用来输出网址、路径之类的格式明确的的东西（这个已经算有点格式化了）
>>> print("www","python","org",sep=".")
www.python.org
```

这里其实比较特殊的是最后几个，尤其是最后一个还可以设置分隔符。这是 Python 提供的参数，`print()`函数默认的完整样式如下：

```python
print(*objects, sep=' ', end='\n', file=sys.stdout, flush=False)
```

参数含义如下：

 - `*objects`：输入的对象，例如之前的`"Hello","World!"`。
 - `sep=' '`：分隔符，必须是字符串。这里默认设置为空格，也可以设置为`None`。
 - `end='\n'`：设置字符串最后分隔符，必须是字符串。这里默认是`\n`，也可以设置为`None`。如果没有给定`*objects`，那么`print()`只输出`end`设置的内容。
 - `file`：设置输出的位置。这里默认设置为`sys.stdout`，也就是标准输出（不知道这个的话去查一下吧，系统的一部分）。
 - `flush`：如果为`True`，那么强制刷新数据流（stream）。这个可能比较难懂，不过运行完下面的代码，并且按照注释来再做一次，就应该知道了：

```python
#!/usr/bin/env python3

import time

print("---RUNOOB EXAMPLE ： Loading 效果---")

print("Loading",end = "")
for i in range(20):
	# 运行完把这里的 False 修改成 True，看看就知道了
    print(".",end = '',flush = False)
    time.sleep(0.5)
```

## 各种格式化输出

除了之前在`print()`中提及的设置分隔符之外，还有一些方法可以格式化输出。

#### 格式化的字符串文字（Formatted String Literals）
格式化的字符串文字（Formatted String Literals），简称为 f 字符串（f-strings）。

在开头的单引号或者三重引号之前使用`f`或者`F`，并且在字符串中，能在一对大括号之间写 Python 表达式，用于引用变量或字面值。

官方示例如下：

简单的引用变量：

```python
>>> year = 2016
>>> event = 'Referendum'
>>> f'Results of the {year} {event}'
'Results of the 2016 Referendum'
```

控制浮点数的位数，这里设置成小数点后 3 位：

```python
>>> import math
>>> print(f'The value of pi is approximately {math.pi:.3f}.')
The value of pi is approximately 3.142.
```
在`:`后面设置一个整数将设置该字段的最小字符宽度，这可以用来列对齐。

```python
>>> for name, phone in table.items():
...     print(f'{name:10} ==> {phone:10d}')
... 
Sjoerd     ==>       4127
Jack       ==>       4098
Dcab       ==>       7678
```

#### str.format()
这个方式的格式就是名字，就是把引用的变量和值放到`.format()`的括号里了，如下：

```python
>>> yes_votes = 42_572_654
>>> no_votes = 43_132_495
>>> percentage = yes_votes / (yes_votes + no_votes)
# 这里的第一对单引号就是`str`字符串，后面`.format()`括号里就是对应的变量
>>> '{:-9} YES votes  {:2.2%}'.format(yes_votes, percentage)
' 42572654 YES votes  49.67%'
```

那个数字的可能有点难理解，这里有个字符串的：

```python
>>> print('We are the {} who say "{}!"'.format('knights', 'Ni'))
We are the knights who say "Ni!"
```

当然这是默认情况，还可以使用变量对应的符号来引用。后面括号里第一个字符串对应着序号`0`，以此类推。具体如下：

```python
>>> print('{0} and {1}'.format('spam', 'eggs'))
spam and eggs
>>> print('{1} and {0}'.format('spam', 'eggs'))
eggs and spam
```

也可以使用关键词参数，用参数的名称来引用值，如下：

```python
>>> print('This {food} is {adjective}.'.format(
...       food='spam', adjective='absolutely horrible'))
This spam is absolutely horrible.
```

上面二者可以混合使用，如下：

```python
>>> print('The story of {0}, {1}, and {other}.'.format('Bill', 'Manfred',other='Georg'))
The story of Bill, Manfred, and Georg.
```

还可以通过引用位置序号和使用名称来获取一个表中的变量，可以通过用中括号`[]`来框住变量名。具体使用方法如下：

```python
>>> table = {'Sjoerd': 4127, 'Jack': 4098, 'Dcab': 8637678}
# 中括号框住了需要引用的变量名
>>> print('Jack: {0[Jack]:d}; Sjoerd: {0[Sjoerd]:d}; '
...       'Dcab: {0[Dcab]:d}'.format(table))
Jack: 4098; Sjoerd: 4127; Dcab: 8637678
```

当然这样还要先写个`0`然后中括号`[]`不太方便，那么可以使用两个星号`**`来简化。如下：

```python
>>> table = {'Sjoerd': 4127, 'Jack': 4098, 'Dcab': 8637678}
>>> print('Jack: {Jack:d}; Sjoerd: {Sjoerd:d}; Dcab: {Dcab:d}'.format(**table))
Jack: 4098; Sjoerd: 4127; Dcab: 8637678
```

更详细的介绍看这里：[https://docs.python.org/3.8/library/string.html#formatstrings](https://docs.python.org/3.8/library/string.html#formatstrings)


本文参考官方文档：[https://docs.python.org/3.8/tutorial/inputoutput.html](https://docs.python.org/3.8/tutorial/inputoutput.html)

希望可以帮到有需要的人哦～
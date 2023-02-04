---
layout: article
category: Web
title: Python 中的 try…except…finally 语句
---
<!-- excerpt-start -->
`try…except…finally`语句被用于处理错误，返回信息。格式如下：

```python
try:
	代码块
except:
	代码块
finally:
	代码块
```

`try`表示尝试执行这块代码。如果尝试不成功，那么会返回`except`部分的内容。但是无论尝试执行结果如何都会返回`finally`的内容。

举个例子：

```python
#!/usr/bin/python3

try:
        x>3
except:
        print('error')
finally:
        print('finally')
```
返回如下：

```bash
$ ./try.py 
error
finally
```
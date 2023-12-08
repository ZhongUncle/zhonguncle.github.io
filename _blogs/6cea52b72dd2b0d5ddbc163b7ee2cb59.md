---
layout: article
category: Web
date: 2022-06-09
title: How Python parses and obtains URL parameters and uses
excerpt: "ZhongUncle will introduce how to parse and obtains the URL parameters in Python, and how to use them"
---
The steps for Python to parse and obtain URL parameters are as follows.

URL for example is `https://www.example.com/?keyword=abc&id=12`

## First import `urllib.parse` in Python3
This module is used to parse the URL into parts (note that it is parsing a string, so it needs to be quoted):

```python
>>> from urllib import parse
```

or

```python
>>> from urllib.parse import urlparse
```

## Then use `urlparse` to convert the string to the URL

```python
>>> url=parse.urlparse("https://www.example.com/?keyword=abc&id=12")
```

or directly

```python
>>> url=urlparse("https://www.example.com/?keyword=abc&id=12")
```

Now the `url` variable contains each part of the URL, as follows:

```python
>>> url
ParseResult(scheme='https', netloc='www.example.com', path='/', params='', query='keyword=abc&id=12', fragment='')
```

You can access the content in the following ways. Here we will access `query` part as an example:

```python
>>> url.query
'keyword=abc&id=12'
```

## Convert to dictionary
If you want it returns **dictionary**, use `parse.parse_qs`:

```python
>>> parad=parse.parse_qs(url.query)
>>> parad
{'keyword': ['abc'], 'id': ['12']}
```

You also can get the value of some queries, as follows:

```python
>>> para.get('id')
['12']
```

or directly

```python
>>> parse.parse_qs(url.query).get('id')
['12']
```

## Convert to list format
If you want it returns **list**, use `parse.parse_qs`:

```python
>>> paral=parse.parse_qsl(url.query)
>>> paral
[('keyword', 'abc'), ('id', '12')]
```

It is not as convenient and directly to use as dictionary, as follows:

```python
>>> paral[0][0]
'keyword'
```

For a more details, you can view the official documentation: [https://docs.python.org/3/library/urllib.parse.html](https://docs.python.org/3/library/urllib.parse.html)

I hope these will help someone in need~
# tools
## badurls.sh
用于查找所有网页中引用的其他页面链接是否正确。因为我会在修改博客的标题之后修改文件名，这就可能会导致链接错误，所以这个工具就可以用来查找哪个文件中的哪个链接出现了问题。

使用方法就是在 /docs/blogs 下使用以下命令：

```
$ badurls.sh 
/blogs/5e449fdb610b2a4d7ee8ee742fbfe736.html in 2a5e3991b4968e941a82aa12b3e2a9fa.html
/blogs/6a9f2929e74ab84354bed126ebd135b3.html in 2a5e3991b4968e941a82aa12b3e2a9fa.html
/blogs/0f4ba4e0246a182921e1d34a66bea790.html in 4693280e7d152780ee5ed9d12d080386.html
/blogs/6a9f2929e74ab84354bed126ebd135b3.html in 514d58f2961fd8f7d36176bdb1208af0.html
/blogs/a6dab84ce4891d654646336e2ae01e69.html in 589dba6103e6828777f8c9d196585565.html
/blogs/2022-07-08-Swift%20%E5%A6%82%E4%BD%95 in c137b537d8da113ee090df6660cf1490.html
```

## someurl.sh
用于在所有页面中查找某个链接。因为博客大多是备份自CSDN，所以一些图片的链接或者博客的引用链接会使用CSDN的，这个以前没什么问题，但是现在要翻译成英文，引用的也应该是英文的。

使用方法就是在 /docs/blogs 下使用以下命令：

```
$ someurl.sh csdn
<a href="https://blog.csdn.net/qq_33919450">CSDN</a> in 045fa379a8cd9921e75ce86a360345a3.html
<a href="https://blog.csdn.net/qq_33919450">CSDN</a> in 096b0a6f079768ecbf051361faebb334.html
<a href="https://blog.csdn.net/qq_33919450">CSDN</a> in 0eda9cbefc97fa9c8eaefd427b091cdb.html
...
```
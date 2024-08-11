---
layout: article
category: Web
date: 2023-01-10
title: How to use Java like script (How to run single Java file like script)
excerpt: "Java supports running a single Java code file like a script on Unix like systems. But at the bottom, it unlikes the real scripts, it still needs to be compiled. You can run it as script under Linux, macOS, WSL and cannot be used under Windows PowerShell or CommandLine."
originurl: "https://blog.csdn.net/qq_33919450/article/details/128634215"
---
Java supports running a single Java code file like a script on Unix like systems. But at the bottom, it unlikes the real scripts, it still needs to be compiled. You can run it as script under Linux, macOS, WSL and cannot be used under Windows PowerShell or CommandLine.

Due to I cannot find detailed explanations, so I write this blog to explain how to write Java "scripts".

First, not use the `.java` suffix of Java code files , they should be directly the file name, such as `HelloJava`. Here, use vim to create a new file called `HelloJava`:

```
$ vi HelloJava
```

Then like other language, add a description and version in the first line:

```bash
//Linux
#!/path/to/your/bin/java --source 19

//macOS
#!/usr/bin/java --source 19
```

If you don't know the version of Java, you can use `java -version` to check.

```
$ java -version
java version "19.0.1" 2022-10-18
Java(TM) SE Runtime Environment (build 19.0.1+10-21)
Java HotSpot(TM) 64-Bit Server VM (build 19.0.1+10-21, mixed mode, sharing)
```

The content of the 'script' is as follows:

```bash
#!/usr/bin/java --source 19
 
public class HelloJava {
 
    public static void main(String[] args) {
        System.out.println("Hello, world!");
    }
}
```

After using `:wq` to save and quit vi, need modify the mode of file. If you don't modify `umusk`, you need change this to get the permission to excute the file. It's easy, like：

```bash
chmod +x HelloJava
```
After that, you can run it like a script:

```
$ ./HelloJava
Hello, world!
```

If you don't want to use relative addresses and the storage location is fixed, simply add the directory to the `PATH` environment variable. You can find more details in [How to directly use scripts in Linux (configure all bin directories included in the $PATH variable)](https://zhonguncle.github.io/blogs/8e8b0e450e6d5457740a6379c3b723b6.html).


I guess Java doesn't use suffixes here for distinguishes between source files and "script files". In Unix-like systems, only users/developers need to know the type of file, and the suffix has no practical significance. The distinction between files is usually based on the content or block at the beginning of the file.

I hope these will help someone in need~
---
layout: article
category: Go
date: 2023-07-12
title: How to install Go Tour tutorial in local
excerpt: "How to install Go Tour tutorial in local, and what to do if the other language versions cannot be installed."
originurl: 
---
Go officially has an online tutorial [A Tour of Go](https://go.dev/tour/welcome/1), where you can learn Go programming online, and it has a Chinese version. The original English page is as follows:

<img alt="" src="/assets/images/212b3a345e1f45e49401f3ee5d1b27c1.png" style="box-shadow: 0px 0px 0px 0px">

Surprisingly, Go provides an offline version (available in various languages). After downloading and installing, you can compile and run locally to view the results. You do not need to connect to the Internet to use a remote server, which improves efficiency and performance (details on this will be discussed separately later). There is a section on comparison).
## Preparations before installing the offline version
Before installing the offline version, you first need to install Go locally, since compilation is done locally. Secondly, you need to prepare a workspace to store the downloaded modules and source code, as well as the compiled binary execution file.

### Install Go
Not much to say about installing Go. You can install it directly using the software package management tool. Download it from the official website ([https://go.dev/dl/](https://go.dev/dl/)) and install it using the GUI. Installation of the device is also very easy.

### Set up workspace (worksapce)
The focus is on preparation of the work space. Go generally has a workspace (not required now, but was required in the early days), which is essentially a directory, so that various packages, modules, source codes, and compiled binary executable files can be well managed. Go uses the environment variable `GOPATH` to find the workspace.

The structure of the workspace is generally as follows:

<img alt="" src="/assets/images/03e672a1bab746818a6536c9b5b896dc.png" style="box-shadow: 0px 0px 0px 0px">

There are generally three directories:
- bin: stores the built binary execution file;
- pkg: stores some modules and packages;
- src: stores Go source code.

So create this directory and three of them wherever you want:

```
$ mkdir workspace
$ cd workspace
$ mkdir bin pkg src
```

Then add the following command to your Shell configuration file (such as `.bashrc`, `.bash_profile` or `.zshenv`) to set the environment variable `GOPATH` (the following address needs to be modified according to your own situation):

```
export GOPATH=~/Desktop/go
```

Then restart the terminal or use the `source configuration file` to update the environment variables.

## Kind tips
Before installing the offline version, please note: try to install the original English version, and then use the browser to translate it. The update frequency of other language versions is less than ideal, which may cause some problems.

For example, if you go to the Chinese version of the source code ([https://github.com/Go-zh/tour](https://github.com/Go-zh/tour)), it says that the installation method is:

```
$ go get -u github.com/Go-zh/tour
```

`go get` has been deprecated. The error message will prompt to use `go install`. The English version has been updated. The correct installation method for the Chinese version is:

```
$ go install github.com/Go-zh/tour@latest
```

Moreover, the Chinese version has not been updated for a long time, so there may be some problems when using it. If your English is not very good, it is recommended to use the English version and the computer translation of the browser is enough.

If you have installed the Chinese version and found that it cannot run, and then install the English original version, it will prompt that something is already installed. At this time, you need to manually delete the `tour` executable file in the `bin` directory, and then use `go clean -modcache` to clean it up. The module is cached and can be installed at this time. Of course, if your directories are originally empty, you can delete them and reinstall them.

## Install offline version
If you set up your `GOPATH` and workspace as described before, then the next step is simple. Enter in the terminal (don’t worry about the current working directory, because it will be automatically installed in the `GOPATH` directory):

```
$ go install golang.org/x/website/tour@latest
```

The last `@latest` means to install the latest version. If you want to install a specific version, just change `latest` to the version number.

If you encounter an error such as "Request Refused", make sure there is no error in the entered address and try again after a while. Sometimes network problems can also cause the request to be rejected. If that still doesn't work, you can try changing DNS or other methods.

## Use offline version
After completing the installation, enter the `bin` directory in the workspace and you will see an executable file named `tour`:

```
$ cd $GOPATH/bin
$ls
tour
```

Run the executable file to run A Tour of Go locally, and the web page will automatically open in the default browser [http://127.0.0.1:3999/basics/1](http://127.0.0.1:3999/ basics/1), as follows:

<img alt="" src="/assets/images/eeed26c7c3f04d1f8da2d45014d18242.png" style="box-shadow: 0px 0px 0px 0px">

The running speed is similar to the local running speed of `go run`, except that it may be slightly slower the first time.
## Performance difference between online version and offline version
If the Internet speed is good, there is almost no big difference between the two when using them.

For example, if you use quick sort to sort 35 integers and output them, the speed of the two is almost the same (offline version on the left, online version on the right):

![Please add image description](/assets/images/49e5f7e074a84364ab9e7340bd2d01da.gif)

Although both the local version and the online version have CPU usage time and memory size limits, the local version is much more relaxed than the online version.

For example, when expanding the array to 2000 integers, the offline version takes about 36 seconds to complete. The online version will display `timeout running program` in about 6 seconds, while the local use of `go run` takes about 35 seconds (use The compiled executable program runs in about 31 seconds).

I hope these will help someone in need~
---
layout: article
category: Web
title: 在Ubuntu服务器上，安装和使用Nginx和PHP7，以及部分排错方法
---
<!-- excerpt-start -->
最近需要研究一下 PHP 语言，但是发现 PHP 不同于 Python、JavaScript 等脚本语言可以直接在本地查看，而是需要在服务器上运行。这就需要搭建一个环境来学习。当然有很多网站也提供了已经搭建好的网站，但是因为我觉得既然要学习，这也是需要学习的东西。不然在别人搭建好的地方练的炉火纯青，结果自己在服务器上弄的时候，“门”都进不去，那就极度尴尬了。

这里使用的是 Ubuntu 20.04.4 LTS，腾讯轻量云服务器。计划安装 PHP7 和使用 Nginx。

## 安装和启动 Nginx
第一步当然是实现服务器框架，这里使用 Nginx。

首先是安装 Nginx：

```bash
$ sudo apt update
$ sudo apt install nginx
```

安装完成之后，使用以下命令启动 nginx 服务：
```bash
# 二者都可
$ sudo systemctl start nginx
$ sudo systemctl start nginx.service
```

关闭 nginx 服务：
```bash
# 二者都可
$ sudo systemctl stop nginx
$ sudo systemctl stop nginx.service
```

重启 nginx 服务：
```bash
# 二者都可
$ sudo systemctl restart nginx
$ sudo systemctl restart nginx.service
```

## 安装 PHP
然后就是安装 PHP。如果你阅读过其他文章，会发现很多人会提到需要安装 PHP-FPM（FastCGI 进程管理器，用来处理一些用户请求，一般就是处理 PHP 脚本的沟通协议）。但是从 PHP 5.3.3 开始，PHP-FPM 就包含在PHP core中，按理来说不用自己安装了（问题本节后面说，一定要看一下），下面图是官网机翻：

![请添加图片描述](/assets/images/d75e5fbe075e424b86b524a3220bbfe9.png)

PHP 可以直接使用`apt`来安装，依次执行以下命令：

```bash
$ sudo apt update
$ sudo apt install php
```

安装完的话，使用`php -v`来查看版本号，以此来确定是否安装好，如下：

```bash
$ php -v
PHP 7.4.3 (cli) (built: Jun 13 2022 13:43:30) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.3, Copyright (c), by Zend Technologies
```
这时候 PHP 就安装好了。

但是！如果你直接部署，之后查看会显示“502 Bad Gateway”。
这是因为 Ubuntu 的软件包库里的`PHP7.4`并不包含 PHP-FPM。所以需要自己再安装一下。好在提供了一个包，不然就得从头编译 PHP 了，方法如下：

```bash
$ sudo apt install php7.4-fpm
```

## 部署环境

### Nginx
首先打开 Nginx 的部署文件，这样来更改一些设置（这里需要使用`sudo`来调用 root 权限）：

```bash
$ sudo vi /etc/nginx/nginx.conf
```
在里面找一个位置，写入以下代码：

```bash
		server {
                listen  80;
                server_name     xxx.x.x.x;
                root    /home/lighthouse/;
                index   index.html index.htm index.php;
		
                location \ {
                        index index.html;
                }

				# 这里表示以“.php”结尾的文件会按照以下内容执行
                location ~ \.php$ {
                        fastcgi_pass      127.0.0.1:9000;
                        fastcgi_index     index.php;
                        include           fastcgi.conf;
                }
        }
```
Nginx 就算简单部署完成了。

### PHP-FPM
如果按照前文安装了 PHP-FPM，那么在目录`/etc/php/7.4`下，会多一个目录`fpm`，进入这个目录里的`pool.d`目录，如下：

```bash
$ cd /etc/php/7.4/fpm/pool.d
$ ls
www.conf
```
会看到有一个名为`www.conf`的文件，这个文件控制着 PHP-FPM 的一些行为。

因为前面配置 Nginx 的时候，让 fastcgi（也就是 PHP-FPM 监听本机的端口 9000）。但是在`www.conf`中只让其监听`/run/php/php7.4-fpm.sock`，这是一个 socket，但是一般是空的。

所以在`www.conf`添加下面这行，来监听端口 9000:

```bash
listen = 9000
```
如下：

![请添加图片描述](/assets/images/b53f908df689444a89d9f8e1200ef445.png)

## 使用
然后就是简单的使用了。
前面由于设置`/home/lighthouse/`为根目录，所以在下面新建一个`index.php`文件，在里面输入以下内容来查看一些服务器 PHP 的信息：

```bash
<?php
        phpinfo();
?>
```

然后在浏览器中输入以下地址（xxx.x.x.x 是服务器的 ip）：

```bash
xxx.x.x.x/index.php
```
然后就可以看到以下画面：

![请添加图片描述](/assets/images/14476407844c45f4b26c9af74d0b0eb5.png)

## 一些排错方法
在配置和使用的时候可能会出现一些奇怪的问题，这里来介绍一些可能会使用到的方法。

### 查找nginx的错误日志
在`/etc/nginx/nginx.conf`文件中可以找到错误日志，日志中记录了错误发生的时间、状态和原因等信息，这样方便我们排错。
例如在`/etc/nginx/nginx.conf`中有“日志设置”部分，这部分说明了错误日志的位置：

```bash
# Logging Settings
##

access_log /var/log/nginx/access.log;
# 这个就是错误日志
error_log /var/log/nginx/error.log;
```

然后使用以下命令即可查看：

```bash
$ sudo less /var/log/nginx/error.log
```

可能会出现的问题如下（连接不到推送流）：

```bash
2022/06/23 19:33:39 [error] 6972#6972: *1 connect() failed (111: Connection refused) while connecting to upstream, client: xxx.xxx.xxx.xx, server: xxx.x.x.x, request: "GET /index.php HTTP/1.1", upstream: "fastcgi://127.0.0.1:9000", host: "xxx.x.x.x"

```
这个问题就是因为没有安装 PHP-FPM 导致的，并且有时还有可能导致以下这种问题（协议不对）：

```bash
2022/06/23 19:33:39 [error] 6972#6972: *1 upstream sent unsupported FastCGI protocol version: 72 while reading response header from upstream, client: xxx.xxx.xxx.xx, server: xxx.x.x.x, request: "GET /index.php HTTP/1.1", upstream: "fastcgi://127.0.0.1:9000", host: "xxx.x.x.x"
```
手动安装一下 PHP-FPM 即可解决这个问题。

### 查找 PHP 配置文件`php.ini`
有些时候需要调整 PHP 的配置文件，使用以下命令可以直接查看`php.ini`，如下：
```bash
$ php -ini
phpinfo()
PHP Version => 7.4.3

System => Linux VM-12-10-ubuntu 5.4.0-121-generic #137-Ubuntu SMP Wed Jun 15 13:33:07 UTC 2022 x86_64
Build Date => Jun 13 2022 13:43:30
Server API => Command Line Interface
Virtual Directory Support => disabled
Configuration File (php.ini) Path => /etc/php/7.4/cli
Loaded Configuration File => /etc/php/7.4/cli/php.ini
......
```
特别长，但是在开头能看到上文这一部分。

其中：

```bash
Configuration File (php.ini) Path => /etc/php/7.4/cli
```

说明了配置文件`php.ini`的路径`/etc/php/7.4/cli`。

希望可以帮到有需要的人～
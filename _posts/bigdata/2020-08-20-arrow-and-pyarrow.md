---
layout: post
title: Arrow and Pyarrow  
categories: [big data]
description: 版本1.0.0实践细节
keywords: Arrow, Plasma
catalog: true
multilingual: false
tags: big data
---

## 前言
Apache Arrow是一个用于内存分析的跨语言开发平台。它定义了一种标准的、语言无关的列式内存数据格式。
这种格式支持平的和嵌套的数据。它还提供了一些计算库和零拷贝流式消息和内部进程通信。
Arrow的主要用处可以是大数据的快速移动和处理。由于是开发平台，Arrow包含了许多组件：
- Arrow列式内存格式：一个标准和高效的内存表示。可用于平的和嵌套的数据
- Arrow IPC格式：一种高效的序列化格式，并且带有元信息，可用于进程和异构环境间的通信
- Arrow Flight RPC协议：基于Arrow IPC格式，用于远程服务交换arrow数据与应用定义的语义数据
- C++, C, C#, Go, Python, Matlib, Java等等库
- Grandiva: 一个LLVM编译器
- Plasma对象存储：一个共享内存blob存储

本文主要展示一些python的实践案例， 希望能够总结以期有进一步了解Arrow.

## Dive into
下面让我们去看一看pyarrow的源代码（1.0.0)
### pyarrow项目目录
<img src="{{site.baseurl}}/assets/images/screenshots/Screen Shot 2020-08-28 at 3.53.07 PM.png">

pip安装的pyarrow少了一些cython编写的pyx代码，这些文件被编译成pxd或so后可以被py代码import, 比如`from pyarrow.lib import (ChunkedArray, RecordBatch, Table)`
是从lib.so中导入的。

### __init__.py源码解读
首先导入版本号，如果不是通过包安装，那么版本通过解析`git describe`确定版本。
接着导入cython的pyarrow.lib库，由于Cython有个bug(https://github.com/cython/cython/issues/3603), 这里暂时关掉gc。
然后有一个`show_versions`的函数可以查看c++版本信息：
```
>>> pa.show_versions()
pyarrow version info
--------------------
Package kind: manylinux2010
Arrow C++ library version: 1.0.0
Arrow C++ compiler: GNU 8.3.1
Arrow C++ compiler flags:  -fdiagnostics-color=always -O3 -DNDEBUG
Arrow C++ git revision: b0d623957db820de4f1ff0a5ebd3e888194a48f0
Arrow C++ git description: apache-arrow-0.16.0-1340-gb0d623957
```
然后导入Cython定义的各种类型
导入buffer和IO相关。关于Pyarrow的memory和IO, 下面会介绍。
导入异常，
导入序列化相关，到这lib模块导入完毕。
然后从hdfs.py，ipc.py, filesystem.py, serialization.py,types.py导入相关模块
定义启动server函数和一些其他的包工具函数。

### plasma.py文件源码解读
这个文件一上来要导入TensorFlow相关库，暂时跳过。
主要功能函数式，用来启动plasma server.
```
def start_plasma_store(plasma_store_memory,
                       use_valgrind=False, use_profiler=False,
                       plasma_directory=None, use_hugepages=False,
                       external_store=None):
# plasma_store_memory定义存储大小
# use_valgrind定义是否使用valgrind和use_profiler互斥
# use_profiler定义是否测试性能
# plasma_directory定义mmap文件位置
# use_hugepages是否使用大文件存储，需要划分文件格式
# external_store溢出的对象存储到外部位置，由于plasma超过预设空间时候会溢出对象。 
```
这个函数会默认创建`/tmp/test_plasma-plasma.sock`用于客户端sock连接, 然后就是普通的shell命令行选取参数启动server.



        
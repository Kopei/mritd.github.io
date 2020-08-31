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

### pyarrow.\__init\__.py源码解读
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


### pyarrow的内存和IO管理
本节主要总结pyarrow的内存管理和IO管理，涉及buffer, memory pool和file-like or stream-like对象
#### 访问和分配内存
在`pyarrow.__init__.py`可以看到代码的引入:
```python
# Buffers, allocation
from pyarrow.lib import (Buffer, ResizableBuffer, foreign_buffer, py_buffer,
                         Codec, compress, decompress, allocate_buffer)

from pyarrow.lib import (MemoryPool, LoggingMemoryPool, ProxyMemoryPool,
                         total_allocated_bytes, set_memory_pool,
                         default_memory_pool, logging_memory_pool,
                         proxy_memory_pool, log_memory_allocations,
                         jemalloc_set_decay_ms)
```
**pyarrow.Buffer**
`Buffer`对象是C++代码`arrow::Buffer`的封装，作为基础工具管理C++中的arrow内存。一个buffer代表一段连续的内存空间。
大部分buffer拥有他们各自的内存，但是也有例外。Buffer对象可以允许array类安全地和属于或不属于他们的内存交互。`arrow::Buffer`
允许一个buffer访问另一个buffer通过zero-copy, 同时保持内存的生命周期和清晰的父子关系。
`arrow::Buffer`有很多种实现，但是对外接口是一致的：一个数据指针和长度。有点类似python自带的buffer和`memoryview`对象
```python
# https://github.com/apache/arrow/blob/67983cf56f/python/pyarrow/io.pxi
>>> import pyarrow as pa
>>> data=b'aaaaaaaaaaaaaaaaaaaaaa'
>>> buf = pa.py_buffer(data)  # buf是zero-copy的data对象memory view, buf不会分配内存.
>>> buf
<pyarrow.lib.Buffer object at 0x7fabc0e05d30>
>>> buf.size
22
>>> buf.to_pybytes()  # 这个转化是会复制数据。
b'aaaaaaaaaaaaaaaaaaaaaa'

```
外部的内存，只要有指针和size，保持接口一致，也可以通过`foreign_buffer()`来访问。
在创建buffer之后，可以通过memoryview或python buffer装换，这种转化是zero-copy.

**Memory Pools**
所有内存分配和释放(malloc/free)都可通过`arrow::MemoryPool`来追踪。代码在[memory.pxi](https://github.com/apache/arrow/blob/67983cf56f/python/pyarrow/memory.pxi)
```python
>>> import pyarrow as pa
>>> pa.total_allocated_bytes()
0
>>> buf = pa.allocate_buffer(1024,resizable=True)
>>> pa.total_allocated_bytes()
1024
>>> buf.resize(2048)
>>> pa.total_allocated_bytes()
2048
>>> buf=None
>>> pa.total_allocated_bytes()
0
```

#### 输入输出
Arrow C++库有几个抽象接口用于不同IO类型：
- 只读流
- 随机可访问只读文件
- 只写流
- 随机可访问只写文件
- 可读可写可随机访问文件

在`pyarrow.__init__.py`可以看到代码的引入:
```python
# I/O
from pyarrow.lib import (HdfsFile, NativeFile, PythonFile,
                         BufferedInputStream, BufferedOutputStream,
                         CompressedInputStream, CompressedOutputStream,
                         TransformInputStream, transcoding_input_stream,
                         FixedSizeBufferWriter,
                         BufferReader, BufferOutputStream,
                         OSFile, MemoryMappedFile, memory_map,
                         create_memory_map, have_libhdfs,
                         MockOutputStream, input_stream, output_stream)
from pyarrow.lib import (ChunkedArray, RecordBatch, Table, table,
                         concat_arrays, concat_tables)
```

为了能够和python自带`file`对象行为一致，arrow定义了`NativeFile`(其实是个stream).代码在[io.pxi](https://github.com/apache/arrow/blob/67983cf56f/python/pyarrow/io.pxi)
`NativeFile`是所有arrow流的基类，arrow流可以是可读，可写，也可以支持`seek`.`NativeFile`暴露的方法用于读写python的数据对象，然后把他们变成stream传递给其他arrow工具，比如Arrow IPC.
cython代码中定义了好几种NativeFile子类:
- OSFile, 使用操作系统的描述符
- MemoryMappedFile, 使用memory maps做zero-copy读和写。
- BufferReader, 把对象转成arrow buffer使用Zero-copy reader
- BufferOutputStream, 内存中写数据，最后生成buffer
- FixedSizeBufferWriter, 再一句生成的buffer中写数据
- HdfsFile, hadoop生态读写数据
- PythonFile, 在C++中交互python文件对象,可以对python文件对象使用c++的方法，但是可能有GIL的限制。
- CompressedInputStream and CompressedOutputStream, 从流中压缩和解压数据。

**高级API**
**input streams**
`input_streams()`函数可以从各种输入创建可读`NativeFile`
```python
>>> buf = memoryview(b'some data')
>>> stream = pa.input_stream(buf)
>>> stream.read(4)
b'some'
>>> stream.read()
b' data'
>>> stream.read()
b''
```

**output streams**
同理，`output_stream`把stream写成文件。
```python
>>> with pa.output_stream('example1.dat') as stream:
...     stream.write(b'some data')
... 
9
>>> f = open('example1.dat', 'rb')
>>> f.read()
b'some data'
```

#### OSFile和Memory Mapped Files
对于在磁盘上的文件，pyarrow提供标准系统级别的文件api和memory-mapped文件。memory-mapped是在用户态创建虚拟空间来映射磁盘上的内容。
通过对這段虚拟内存的讀取和修改, 实现对文件的讀取和修改。使用虚拟内存映射进行文件读写有几个好处：
- 可以不用读取整个文件进入物理内存，文件已经在虚拟内存中
- 可以用对内存的操作命令来操作文件
- 由于实际上这个mapped文件还是文件，与进程无关，所以这段虚拟内存可以共享给多个进程。

```python
>>> mmap = pa.memory_map('example1.dat')
>>> mmap.read()
b'some data'
>>> mmap.seek(5)
5
>>> buf=mmap.read_buffer(4)  # read into arrow buffer
>>> buf.to_pybytes()
b'data'
```

#### 内存中buffer读写
```python
>>> writer = pa.BufferOutputStream()
>>> writer.write(b'hello, friends')

>>> buf = writer.getvalue()
>>> reader = pa.BufferReader(buf)
>>> reader.seek(7)
>>> reader.read(7)
b'friends'
```

### plasma
plasma是arrow的一个共享对象存储，plasma只能用在单机上，客户端和服务端使用unix domain socket通信。plasma中的对象是不可变的。
#### pyarrow.plasma
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



        
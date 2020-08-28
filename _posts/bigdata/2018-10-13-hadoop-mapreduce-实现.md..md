---
layout: post
title: Hadoop MapReduce 实现
categories: [big data]
description: 记录实现细节
keywords: hadoop, map reduce
catalog: true
multilingual: false
tags: big data
---

虽然Hadoop现在有一点过时, 但是一般的金融公司还是会用它出隔日的报表(离线计算), 本文主要关注其`Map Reduce`的实现.

### 函数编程
`Map/Reduce`的思想借鉴于函数式编程. `Map`是进行过滤和排序, 比如把一组学生按名字排序到队列, 一个名字一个队列, 然后`Reduce`方法进行总结, 比如对队列里的名字做统计, 得出名字出现频率. 这种思想是`split-apply-combine`的一种特例(见[pandas groupby](https://www.kopei.top/2018/08/31/pandas/)).

我们知道多线程编程的局限在于访问共享资源的竞争问题, 一般需要锁, 信号量(semaphore)等技术去协调, 不然死锁等问题将会出现.

但是我们可以完全换个思路, 比如消除需要访问共享资源的限制, 这样我们就不需要锁之类的技术了.这也是函数计算的一个基本概念. **数据通过函数的参数传递**, 同一时间只有一个激活的函数运行,这样就避免了冲突.

可以把函数连接作有向无环图`Direct Acylic Graph`, 由于函数没有隐藏的依赖, 这样多个DAG就可以并行运行.

### Map/Reduce函数
`Map/Reduce`是一种特殊(简单)的DAG. 图如下所示: 每个`map`函数把一组数据按key分为`key/value`对, 然后不同`key`的元素跑到不同的计算节点, 在那里进行`reduce`合并.
<blockquote class="imgur-embed-pub" lang="en" data-id="YrZrBZN"><a href="//imgur.com/YrZrBZN"></a></blockquote><script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>
``` 
map(input_records) {
emit(k1, v1)
...
emit(k2, v2)
...
```
```
reduce(key, values) {
aggregate = initialize()
while (values.has_next){
    aggregate = merge(values.next)
}
collect(key, aggregate)
}
```
可以有多个`map/reduce`组合替代一个并行的算法:
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-10-14%20%E4%B8%8B%E5%8D%884.25.43.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-10-14%20%E4%B8%8B%E5%8D%884.25.43.png)

### 分布式文件系统(HDFS)
Hadoop需要分布式文件系统, 用于处理大文件的顺序读写.每一个大文件会被分割成块, 存储在不同数据节点.
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-10-14%20%E4%B8%8B%E5%8D%884.28.11.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-10-14%20%E4%B8%8B%E5%8D%884.28.11.png)
主节点`NameNode`会记录所有文件的目录结构和各个块所在的位置. 主节点作为中心控制点一般会有`hot standby`的复制.

想要读取文件, 客户端会计算所需块在文件的偏移位置, 得出块的索引, 然后对`NameNode`做出请求, 然后`NameNode`会返回哪个`DataNode`有数据, 客户端就会直接和`DataNode`联系.

想要写入一个文件, 客户端会先和`NameNode`通信, 作为响应, `NameNode`会告诉客户端现在有哪些`DataNode`并且谁是主节点和哪些是从复制. 然后客户端就会把文件上传到所有`DataNode`, 不过`DataNode`这时还只会存储在buffer, 等到所有节点都存完缓存, 客户端发起`commit`给主节点, 主节点就会提交更新, 同时通知从节点更新, 等到所有从节点都`commit`, 主节点就会返回客户端提交成功. (所以DFS写是强一致性) 最后客户端还需告诉`NameNode`所有更新信息. 包括块分布的位置和元信息都会写入`NameNode`的操作日志`operation log`. 这个日志十分重要, 可以用于灾后恢复. `NameNode`也会通过不间断地`checkpoint`维护它的持久化状态.

当`NameNode`挂了, 所有的写操作将会失效, 读操作可能不受影响, 只要在客户端与`DataNode`的句柄有效. 需要恢复`NameNode`, 从节点会从上一次的`checkpoint`状态恢复, 并做操作日志回放.

当一个`DataNode`挂了, `NameNode`会从心跳中检查到, `NameNode`就会把它从集群中移除, 然后把它存储的chunk在其他节点写入. 这样做才能维护hadoop所需的`replication factor`.

如果这个挂掉的`DataNode`后来恢复了, 那么将会重新加入集群, 它会给`NameNode`报告所有它有的块, 每一个块是有版本号的, 所以`NameNode`可以检查是否这个`DataNode`数据是否已经过时, 如果是那么这个节点将会被后续回收.


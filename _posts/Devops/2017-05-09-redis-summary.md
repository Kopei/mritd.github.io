---
layout: post
title: Redis使用总结
categories: [devops]
description: 
keywords: redis
catalog: true
multilingual: false
tags: devops, redis
---

`Redis`是我们常用的内存型key-value数据库, 它有着强大的读写能力(benchmark是几万IOPS). 而最初redis的源码只有2万行, 十分适合学习和研究. 本文主要总结一下redis的devops相关使用.

### 单线程模型
`Redis`使用了单线程架构和I/O多路复用模型来实现高性能的内存数据库服务, 当几个客户端同时发送命令时, redis会先将命令存在队列, 然后通过epoll作为IO复用实现, 通过事件一条一条的执行命令.
单线程避免了线程切换的开销和竞争. 但是单线程有一个问题的, 对于每个命令的执行时间是有要求的。如果某个命令执行过长，会造成其他命令的阻塞，对于Redis这种高性能的服务来说是致命的，所以Redis是面向快速执行场景的数据库。

### 数据类型和内部编码
`Redis`是KV数据库, 这个`V`的类型大致可以分为5类: Hash/String/List/Set/Zset/, 每一种数据结构都有多种内部编码实现, 通过`type`可以看类型, 通过`object encoding`可以看编码实现
```c
127.0.0.1:6379> object encoding hello
"embstr"
```

### 内存理解
需要了解`Redis`内存使用情况, 可以使用`info memory`. Redis进程内消耗主要包括：自身内存+对象内存+缓冲内存+内存碎片.
- 对象存储: 对象内存是Redis内存占用最大的一块，存储着用户所有的数据.
- 缓冲内存主要包括：客户端缓冲、复制积压缓冲区、AOF缓冲区。
- Redis默认的内存分配器采用jemalloc，可选的分配器还有：glibc、tcmalloc。内存分配器为了更好地管理和重复利用内存，分配内存策略一般采用固定范围的内存块进行分配.比如当保存5KB对象时jemalloc可能会采用8KB的块存储，而剩下的3KB空间变为了内存碎片不能再分配给其他对象存储。


### 持久化
Redis支持RDB和AOF两种持久化机制，持久化功能有效地避免因进程退出造成的数据丢失问题，当下次重启时利用之前持久化的文件即可实现数据恢复。
RDB持久化是把当前进程数据生成快照保存到硬盘的过程，触发RDB持久化过程分为手动触发和自动触发。`bgsave`命令：Redis进程执行fork操作创建子进程，RDB持久化过程由子
进程负责，完成后自动结束。阻塞只发生在fork阶段，一般时间很短。运行`bgsave`命令对应的Redis日志如下：
```c++
* Background saving started by pid 3151
* DB saved on disk
* RDB: 0 MB of memory used by copy-on-write
* Background saving terminated with success
```
Redis内部还存在自动触发RDB的持久化机制，例如以下场景：
- 使用save相关配置，如“save m n”。表示m秒内数据集存在n次修改时，自动触发bgsave。
- 如果从节点执行全量复制操作，主节点自动执行bgsave生成RDB文件并发送给从节点
- 执行debug reload命令重新加载Redis时，也会自动触发save操作。
- 默认情况下执行shutdown命令时，如果没有开启AOF持久化功能则自动执行bgsave。
AOF（append only file）持久化：以独立日志的方式记录每次写命令，重启时再重新执行AOF文件中的命令达到恢复数据的目的。AOF的主要作用是解决了数据持久化的实时性.
AOF的工作流程操作：命令写入（append）、文件同步（sync）、文件重写（rewrite）、重启加载（load）

### redis发生阻塞
当Redis阻塞时，这时应用方会收到大量Redis超时异常，比如Jedis客户端会抛出JedisConnectionException异常.(CacheCloud是搜狐开源的监控工具可以看看). 发生阻塞一般分为两大原因:
- 内部原因: 不合理地使用API或数据结构、CPU饱和、持久化阻塞等。
不合理使用API是指对复杂度较大的指令执行大量数据操作. `redis`提供`slowlog get {n}`查询慢查询, 默认命令执行时间在10ms以上的会存在一个定长为128的队列.。慢查询本身只记录了命令执行
时间，不包括数据网络传输时间和命令排队时间，因此客户端发生阻塞异常后，可能不是当前命令缓慢，而是在等待其他命令执行. 发现是滥用api造成慢查询后, 可以采取两个方法:
  - 修改为低算法度的命令，如hgetall改为hmget等，禁用keys、sort等命令。
  - 调整大对象：缩减大对象数据或把大对象拆分为多个小对象，防止一次命令操作过多的数据. `redis-cli --bigkeys`可以统计大对象.
CPU饱和是指单线程跑满了整个CPU, CPU饱和是非常危险的，将导致Redis无法处理更多的命令，严重影响吞吐量和应用方的稳定性.`redis-cli --stat`可以查看统计. 当CPU饱和, 垂直扩展是没有用的, 需要水平集群化分摊IOPS.如果只有几百或几千IOPS的Redis实例就接近CPU饱和是很不正常的，有可能使用了高算法复杂度的命令。还有一种情况是过度的内存优化，这种情况有些隐蔽，需要我们根据info
commandstats统计信息分析出命令不合理开销时间.
对于开启了持久化功能的Redis节点，需要排查是否是持久化导致的阻塞。持久化引起主线程阻塞的操作主要有：fork阻塞、AOF刷盘阻塞、HugePage写操作阻塞。可以执行`info stats`命令获取到`latest_fork_usec`指标，表示Redis最近一次fork操作耗时，如果耗时很大，比如超过1秒，则需要做出优化调整，如避免使用过大的内存实例和规避fork缓慢的操作系统等.
- 外部原因: CPU竞争、内存交换、网络问题等.
CPU竞争主要分为: 进程竞争, 绑定CPU竞争.当Redis父进程创建子进程进行RDB/AOF重写时，如果做了CPU绑定，会与父进程共享使用一个CPU。子进程重写时对单核CPU使用率通常在90%
以上，父进程与子进程将产生激烈CPU竞争，极大影响Redis稳定性。因此对于开启了持久化或参与复制的主节点不建议绑定CPU。
内存交换(swap)对`redis`有极大的性能影响, 可以查看`cat /proc/{redis process id}/smaps | grep Swap`内存交换信息.如果交换量都是0KB或者个别的是4KB，则是正常现象，说明Redis进程
内存没有被交换。预防内存交换的方法有：
  - 保证机器充足的可用内存。
  - 确保所有Redis实例设置最大可用内存（maxmemory），防止极端情况下Redis内存不可控的增长。
  - 降低系统使用swap优先级，如`echo 10>/proc/sys/vm/swappiness`
网路问题分为: 连接拒绝、网络延迟、网卡软中断等。 拒绝连接的情况又有网路闪断, redis拒接连接和连接溢出. 可以查看`redis-cli -p 6384 info Stats | grep rejected_connections`查看redis拒绝连接数, 默认连接数是10000. 连接溢出是指操作系统或者Redis客户端在连接时的问题. 操作系统一般会对进程使用的资源做限制，其中一项是对进程可打开最
大文件数控制，通过ulimit-n查看，通常默认1024。由于Linux系统对TCP连接也定义为一个文件句柄，因此对于支撑大量连接的Redis来说需要增大这个值，如设置ulimit-n65535，防止Too many open files错误;系统对于特定端口的TCP连接使用backlog队列保存, linux默认是128, Redis默认的长度为511，通过tcp-backlog参数设置。如果Redis用于高并发场景为了防止缓慢连接占用，可适当增大这个设置，但必须大于操作系统允许值才能生效, 使用`echo 511>/proc/sys/net/core/somaxconn`命令进行修改。

### Sentinel
Redis Sentinel是Redis的高可用实现方案.
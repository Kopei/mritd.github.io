---
layout: post
title: 高性能mysql笔记
categories: [mysql]
description:
keywords: mysql
catalog: true
multilingual: false
tags: mysql
---

## 此笔记只针对mysql5.5

### mysql的架构
- mysql采用存储和处理分离的架构。
- mysql可以开启线程池，处理客户端的请求。
- select语句会在缓存中先查找，没有hit才会到解释器。
- 解释器创建内部数据结构并做优化，最后才到存储器API。优化决策时用户可以使用hint关键字来影响mysql的决策过程，也可能使用explain来看看mysql是怎么决策的。
- 优化器会查询存储引擎提供一些信息来帮助优化。

### mysql的并发控制
- mysql在服务层和存储层都做了并发控制， 一般使用锁来控制并发。
- 存储引擎有自己的锁策略和颗粒度，但是服务层的策略高于存储层。比如alter table 使用应用层的表锁，忽略存储层锁机制。
- 行锁只有在存储层实现, 一般通过多版本并发控制MVCC, 提升并发性能。简单原理是一个事务看到的是某一时刻数据的备份。
- 可以显式地加锁：
  - `select ... lock in share mode;`
  - `select ... for update;`

### MVCC(Multi-Version concurrent control)
- 实现机制： 基于某个时间点的快照。非阻塞度，行锁写
- InnoDB在每个行记录后面保存两个隐藏的列(时间上根据mysql版本不同，有更多的隐藏列, 5.7是3个字段）， 一个行的创建时间，一个是过期时间。时间都是系统版本号。
- 在repeartable read隔离等级下， mvcc的操作：
  - select:
  1. 只会查到当前事务版本号前面或等于当前版本号（事务修改过）的行。
  2. 删除的行也会作比较。
  - insert:
  1. 插入一条数据，加2个隐藏的列
  - delete:
  1. 删除一行，在删除列加入当前系统版本
  - update:
  1. 插入一条新的记录，把老的记录删除行更新系统版本。
### InnoDB
- 它是被设计为处理大量短时事务。
- 使用next-key locking实现防止幻读。

### 事务只有在存储引擎实现
- 需要格外小心事务中混合了事务型和非事务型表

### ACID是一个事务的标准特征
- mysql主要关心两个隔离等级，Read commited 和 repeatable read。 read commited也是nonrepeatable read, 一个事务在commit之前对其他事务都是不可见的。
repeatable read是mysql默认隔离等级，保证同一个事务多次读取同样记录结果一致。
- 在多个事务里可能出现死锁现象, innoDB处理的方式是将最少行级排它锁进行回滚。

### 使用事务日志可以提高存储引擎修改表数据效率
- 做法类似redis, 仅仅持久化事务日志，在内存中更新数据，然后后台再慢慢写入磁盘。

### Mysql提供两种事务性存储引擎InnoDB, NBD cluster
- 自动提交auto-commit： 默认开启，即便不是显式开启，每个查询还是会默认进行事务。

### Mysql的复制方式
- 主库记录二进制日志，备库将主库日志复制到中继日志（relay log)后，重放二进制日志。同一时间点主备数据可能不一致。

### 设计mysql备份方案
- 逻辑备份恢复太慢，采用ExtraBackup快照备份是物理备份较好的选择。
- 保留多个备份集
- 定期恢复
- **expire_logs_bin** 设置足够长，保留二进制日志文件用于基于时间点的恢复。
- 监控和检查备份是否正常？监控恢复需要耗费多少资源和时间？
- 选择在线备份，可能是导致mysql服务中断
- 逻辑备份导出的文件要么是sql要么是类似csv的文本；物理备份就是直接复制原始文件。
  - 逻辑备份的优点：
  1. 逻辑备份可以消除底层存储引擎的影响
  2. 如果内存保存着正确数据但是磁盘坏了，不能复制一个正确的物理备份， 仍可能导出一个正常的逻辑备份。

  - 逻辑备份的缺点：
  1. 需要消耗cpu，恢复时间较长，需要建index等。
  2. ASCII形式的数据可能比原始数据大
  3. 恢复时可能由于bug或者浮点表示问题，无法保证还原一模一样的数据。
  
  - 物理备份的优点：
  1. 恢复快速， 不需要执行任何sql或构建索引。
  
  - 物理备份的缺点：
  1. 原始文件比逻辑备份大
  2. 可能不总是夸平台
- 使用check tables或mysqlcheck 检查恢复操作。

### 推荐的备份方案
- 先一周使用一次使用物理备份，启动mysql实例，运行mysqlcheck, 然后在服务器负载低时周期性地mysqldump执行逻辑备份，30分钟备份一次bin-log,热备份完flush logs。

### 需要备份什么？
- 二进制文件, InnoDB事务日志
- 代码，如存储过程
- 配置
- 服务器配置
- 操作系统配置
### 增量备份存在中间增量出错，导致整个备份不可用的风险

### 备份中如果要保持数据一致性
- 使用InnoDB，能够保证一个事务内数据一致备份到另处。但是如果应用逻辑写的不对，导致本应该是一个事务到了两个事务，备份在两个事务之中可能数据不一致。
- mysqldump --single-transaction 在InnoBD开始dump开启事务，隔离等级必须是repeatable read. 但是dump时不能执行ALTER TABLE, CREATE TABLE, DROP TABLE, RENAME TABLE, TRUNCATE TABLE。**To dump large tables, combine the --single-transaction option with the --quick option.**

### 使用LVM镜像做mysql备份的基本思路
- 获取读锁
- 将缓存中的数据写到磁盘
- 建立快照
- 释放读锁

### LVM CoW原理
- 给一个卷打一个快照，只记录元信息，当源卷发生写，把需要改变的那部分数据在未改变前复制到快照。这样，读取快照时，既能保证拍照时的数据一致，又能省时间性能。
- LVM快照的一些限制：
  - 所有文件必须在同一个逻辑卷（分区）
  - 需要有足够空间

### Mysql的索引
- 索引在mysql也叫key， mysql有单列索引和多列索引。多列索引根据左序排列。
- 索引的类型：
  - B-Tree索引， MyISAM使用压缩的索引指向数据的物理位置；innodb使用索引指向数据的主键。
- 一个典型的B+树索引
<img src="../images/B+tree.png" width="450" height="450">
- 对于下面这个多列索引：索引根据建表时指定key的值，按大小排序
```sql
    create table people (
    last_name VARCHAR(50), not NULL,
    first_name VARCHAR (50), not NULL ,
    dob DATE , not NULL ,
    gender enum('m', 'f') not NULL ,
    key(last_name, first_name, dob)
    );
```
<img src="../images/multi-col-index.png" width="450" height="450">
- 对于多列索引，B+tree适合的查询方式有：
  - 完全匹配
  - 最左列完全匹配，仅适用于第一个column,即last_name
  - 键值范围, 仅适用于第一个column，即last_name值的范围
  - 键值前缀, 仅适用于第一个column，即last_name begin with
  - 完全匹配一个列，范围匹配另一个列
  - 仅仅查询索引

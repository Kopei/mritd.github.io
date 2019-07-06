---
layout: post
comments: true
title: Mysql 索引总结
categories: [database]
description: 
keywords: mysql
catalog: true
multilingual: false
tags: mysql
---

## mysql索引的作用和意义
当我们使用sql语句查询时往往要加where, 使用索引我们可以快速查找到满足where条件的行. 

### mysql如何使用索引
mysql大部分索引使引用B-tree, 如(PRIMARY KEY, UNIQUE, INDEX, FULLTEXT), 空间数据类型使用R-tree, 内存表还支持hash索引, InnoDB使用反向列表(inverted list)作为FULLTEXT的索引.

mysql会用索引做如下操作:
- 使用索引快速找到满足where条件语句的行.
- 如果在查找时有多个索引选择, mysql使用那个能找到最少数据行的索引.
- 如果使用多列索引, 最左边的列将被用于优化.
- 在执行join其它表的时候
- 计算有索引的列min(),max()时
- 当使用最左边的索引排序和分组表时

### 如何使用主键索引
作为查询条件使用最多的列可以设置为主键(Primary key). 主键有附属索引, 用于提升查询性能.主键是不能为空的,所以性能也比较好. 如果表比较大, 同时又不知道选哪个列作为索引时, 可以创建一个自增的列作为索引. 用这个列作为其他表的外键方便join.

### 如何使用外键优化表查询
有时候如果有一个张大表, 可以把这张大表分成若干小表, 把不太常用的字段放在一起, 通过外键和主表关联, 这样子表既有主键用于快速查询又可以做join操作. 查询也可能使用更少的内存和IO, 因为相应的数据列都已经物理上在一起了.

### 普通列索引
最常见的索引是单列索引, mysql把列的值复制一份在数据结构, 用于快速查询.大部分数据结构采用B-tree, 可以快速定位到单个值, 一组值或值的范围. 在sql where语句对应`=, >, <=, BETWEEN, IN`等等.

每个存储引擎的定义了每张表的索引最大值和最大长度. 基本上, 所有存储引擎至少支持16个索引和单个索引256字节以上.

#### TEXT/BLOB的索引
`Index Prefixes`指创建索引时, 可以指定这个字段的开头一部分N个字节作为索引, 这样索引的长度将被限制, 特别适用于TEXT/BLOB这样没有长度的字段上.
```sql
create table test (blob_col BLOB, index(blob_col(10)))
```
如果一个查询超出`index prefixes`的长度, 超出的部分将会被排除.


### 多列索引


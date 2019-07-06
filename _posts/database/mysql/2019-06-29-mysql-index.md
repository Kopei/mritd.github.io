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
 
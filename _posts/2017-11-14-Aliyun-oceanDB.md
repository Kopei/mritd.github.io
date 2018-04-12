---
layout: post
title: OceanDB小结
categories: [db]
description: 
keywords: oceanDB, aliyun
catalog: true
multilingual: false
tags: db, aliyun
---
## 阿里自研的分布式关系型数据库

### 主要特点
- 支持SQL92和高度兼容Mysql，有一个类似mysql的sql语法，但是有一些限制。
- 多个副本，分布在多区域，可抵御单机、机架及机房故障。
- 准内存数据库。
- 底层Paxos协议，通过3个以上节点投票保持数据强一致。
- 支持**跨行跨表事务**




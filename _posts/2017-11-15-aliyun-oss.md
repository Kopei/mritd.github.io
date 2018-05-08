---
layout: post
title: Aliyun OSS 小结
categories: [storage]
description:
keywords: oss, aliyun
catalog: true
multilingual: false
tags: oss, aliyun
---
## OSS的原理
对象存储将数据当成对象, 可以通过对对象的HTTP verb进行增删改查操作. oss的bucket是一个平铺的大文件夹(看起来你可以像传统文件系统那样有目录层级,但是实际上是平的),里面存储的文件名可以当成key, 文件为value, 这样仿佛oss是一个键值对存储,但是有微小的差别: oos还可以有元属性, 存储大数据有优化但不保证数据强一致性.  

### 使用限制
- 冷备份恢复读取需要1分钟
- 上传5G的数据需要采用断点续传，但不能大于48.8TB
- **上传同名文件会覆盖原有文件**
- 删除文件无法恢复

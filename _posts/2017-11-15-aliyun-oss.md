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
### 使用限制
- 冷备份恢复读取需要1分钟
- 上传5G的数据需要采用断点续传，但不能大于48.8TB
- **上传同名文件会覆盖原有文件**
- 删除文件无法恢复

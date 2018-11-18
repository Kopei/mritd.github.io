---
layout: post
title: aws和aliyun的存储
categories: [cloud]
description: aws和aliyun的对象存储,块存储,文件存储
keywords: [cloud, aliyun, aws]
catalog: true
multilingual: false
tags: cloud
---

## 本文主要介绍aws存储产品(EBS, OSS, EFS), 并对比阿里云的产品

### aws EBS的突发性能和IO积分
aws的块存储pg2的类型有一个IO credits, 可以用于突发容量不是很大存储的IOPS. 从下图可以看出, 在存储容量小于1T时,可以用IO credit提高IOPS, 直到3000IOPS. 存储容量越大,累计io credits越快.
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-05-10%20%E4%B8%8B%E5%8D%882.09.56.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-05-10%20%E4%B8%8B%E5%8D%882.09.56.png)
aws在在初始的时候给gp2分配5.4M的IO credits, 这些积分足够在30分钟内将性能维持到3000IOPS, 从上图我们也可以看出, gp2的IOPS随着容量变大而变大, 直到3.3T左右, IOPS达到10000. 3.3T容量以前平均iops是100/GB.

### aliyun的NAS吞吐量计算公式:
`文件系统吞吐上限（MB/s）= 0.15MB/s * 文件系统存储空间（GB） + 150MB/s（最大10GB/s)`

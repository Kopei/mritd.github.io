---
layout: post
title: Deep Learning Book Notes--Chapter 5
categories: [AI]
description: http://www.deeplearningbook.org/contents/ml.html
keywords: Deep learning
catalog: true
multilingual: false
tags: AI
---

## Summary 


### Statistical learning theory tells us:
如果测试集和训练集都是从一个叫`data generating process`的数据集中产生, 我们可以做一些假设, 测试集和训练集将相互独立并且以相同的概率分布. 有了这个假设我们才能对训练集和测试集误差做数学上研究.

### 取决机器学习算法性能的因素是:
- 尽可能的减少训练误差
- 使测试误差尽可能接近训练误差

### 欠拟合
模型的训练误差不够小

### 过拟合
模型的测试误差和训练误差过大

### 可以通过调节capacity(容量)来调节拟合
- 调节容量的方法之一是: 选择一个`hypothesis space`(假设空间).这个假设空间是能够表达所有解决方案的函数集.换个角度讲, 就是改变输入集特征的数值, 同时可以增加这些特征的新参数. 比如把一个model从线性空间改成多项式空间, 那么容量将会变大.
- 另一调节容量的方式是: 指定模型从某些类别的函数选择. 这叫`Representational capacity`

### VC维度可以来量化容量
VC维度可以测量一个二元分类器的容量. 定义为: 存在一个最大值m, 分类器使m个样本可以被任意标记.

### 统计学习理论中最重要的结论阐述了训练误差和泛化误差之间差异的上界随着模型容量增长而增长，但随着训练样本增多而下降
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-09-21%20at%2021.28.04.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-09-21%20at%2021.28.04.png)

### 随着训练集增加, 容量也需要增加, 否则将出现欠拟合
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-09-21%20at%2021.28.51.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-09-21%20at%2021.28.51.png)

### no free lauch theorem
在所有可能的数据生成分布上平均之后，每一个分类算法在未事先观测的点上都有相同的错误率.
所以我们只需要对特定Task设计最好算法就行.

### 正则化
正则化是指我们修改学习算法，使其降低泛化误差而非训练误差.
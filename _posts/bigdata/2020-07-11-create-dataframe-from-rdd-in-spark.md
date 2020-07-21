---
layout: post
title: Spark RDD转成Dataset的两种方式
categories: [big data]
description: spark rdd to dataframe
keywords: spark, dataframe, rdd
catalog: true
multilingual: false
tags: big data
---

## RDD to Datasets
`Spark SQL`支持两种方式把RDD转为Datasets. 第一种是使用反射`reflection`取得到RDD的schema, 这种方式需要预先知道数据的结构。
第二种方式是通过可编程接口对运行时的RDD进行构建datasets的schema， 这种方法更加动态。


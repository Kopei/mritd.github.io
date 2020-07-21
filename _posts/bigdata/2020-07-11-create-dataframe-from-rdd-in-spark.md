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
`Spark SQL`支持两种方式把RDD转为Datasets. 第一种是使用反射`reflection`取得到RDD的schema, 这种方式需要预先知道数据的结构。如果是scala的接口，RDD包含`case class`(定义了表的结构)可以自动转化RDD到dataframe。
第二种方式是通过可编程接口对运行时的RDD进行构建datasets的schema， 这种方法更加动态。当`case classes`没有预先定义（比如，记录的结构被编码成了字符串）,一个DataFrame可以通过如下三步创建：
- 从原RDD创建一个新的RDD Rows;
- 通过创建`StructType`来代表结构和第一步的Rows对应上去.
- 通过`SparkSession.createDataFrame`方法把结构应用到Rows上.


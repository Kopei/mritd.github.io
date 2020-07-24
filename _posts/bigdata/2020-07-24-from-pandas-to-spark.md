---
layout: post
title: 从Pandas到Spark
categories: [big data]
description: 如何把pandas移植到spark
keywords: pandas, spark
catalog: true
multilingual: false
tags: big data
---

## 前言
本文主要讨论如何把pandas移植到spark, 他们的dataframe共有一些特性如操作方法和模式。pandas的灵活性比spark强， 但是经过一些改动spark基本上能完成相同的工作。
同时又兼具了扩展性的优势，当然他们的语法和用法稍稍有些不同。

## 主要不同处：

### 分布式处理
pandas只能单机处理， 把dataframe放进内存计算。spark是集群分布式地，可以处理的数据可以大大超出集群的内存数。

### 懒执行
spark不执行任何`transformation`直到需要运行`action`方法，`action`一般是存储或者展示数据的操作。这种将`transformation`延后的做法可以让spark调度知道所有的执行情况，用于优化执行顺序和读取需要的数据。
懒执行也是scala的特性之一。通常，在pandas我们总是和数据打交道， 而在spark,我们总是在改变产生数据的执行计划。

### 数据不可变
scala的函数式编程通常倾向使用不可变对象， 每一个spark transformation会返回一个新的dataframe(除了一些meta info会改变）

### 没有索引
spark是没有索引概念的.

### 单条数据索引不方便
pandas可以快速使用索引找到数据，spark没有这个功能，因为在spark主要操作的是执行计划来展示数据， 而不是数据本身。

### spark sql
因为有了SQL功能的支持， spark更接近关系型数据库。

## 两者的一些操作例子
### projections
pandas的投影可以直接通过`[]`操作
```
>>> person_pd[['age','name']]
   age     name
0   23    Alice
1   21      Bob
2   27  Charlie
3   24      Eve
4   19  Frances
5   31   George
```


pyspark也可以直接`[]`来选取投影， 但是这是一个语法糖， 实际是用了`select`方法
```
>>> res[['Quarter']].show()
+-------+
|Quarter|
+-------+
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
+-------+
only showing top 20 rows
>>> res.select('Quarter').show()
+-------+
|Quarter|
+-------+
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
|Q1 2012|
+-------+
only showing top 20 rows
```
### simple transformations
`select`实际上接受任何`column`对象， 一个`column`对象概念上是dataframe的一列。一列可以是dataframe的一列输入，也可以是一个计算结果或者多个列的`transformation`结果。
以改变一列为大写为例：
```
>>> ret = pd.DataFrame(person_pd['name'].apply(lambda x: x.upper()))
>>> ret
      name
0    ALICE
1      BOB
2  CHARLIE
3      EVE
4  FRANCES
5   GEORGE
```
```
import pyspark.sql.functions as sf

result = persons.select(
  sf.upper(persons.name)
)
```
### 增加一列
```
def create_salutation(row):
  sex = row[0]
  name = row[1]
  if sex == 'male':
    return 'Mr '+name
  else:
    return "Mrs "+name
   
result = persons_pd.copy()
result['salutation'] = result[['sex','name']].apply(create_salutation, axis=1, result_type='expand')
result
age	height	name	sex	salutation
0	23	156	Alice	female	Mrs Alice
1	21	181	Bob	male	Mr Bob
2	27	176	Charlie	male	Mr Charlie
3	24	167	Eve	female	Mrs Eve
4	19	172	Frances	female	Mrs Frances
5	31	191	George	female	Mrs George
```
spark sql有个控制流方法`when`可以使代码更简洁， 配合`withColumn`增加一列
```
result = persons.withColumn(
    "salutation",
    sf.concat(sf.when(persons.sex == 'male', "Mr ").otherwise("Mrs "), persons.name).alias("salutation")
)
```


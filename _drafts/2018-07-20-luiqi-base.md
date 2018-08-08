---
layout: post
title: Luigi基础概念
categories: [python]
description: 
keywords: python, luigi
catalog: true
multilingual: false
tags: python
---

## 基础模块
想要构建一个基本的Luigi工作流, 需要创建`Task`和`Target`类, 还有`Parameter`类.
使用这些类来定义任务的好处是在代码里定义依赖, 而不是使用DSL.

### Target
`Target`是Task output返回的结果. `Target`类对应磁盘上的一个文件, HDFS上的一个文件或者某种`checkpoint`(比如数据库的条目). 理论上只需要实现`exists`方法,用于返回文件是否存在就可以实现这个类. `Target`有多个子类:
`LocalTarget`, `HdfsTarget`, `S3Target`, `ssh.RemoteTarget`, `ftp.RemoteTarget`, `mysqldb.MysqlTarget`, `redshift.RedshiftTarget`, 所以基本上不需要自己subclass.
`Target`类是对文件的映射, 支持原子性操作, 也支持open()和Gzip.

### Task
Task是实际做任务的地方. 通过`run()`, `output()`, `requires()`设置任务的行为. `Task`通过其它`Task`产生的`Targets`作为输入, 结果产生也是`Target`.
任务之间可以通过`requires()`指定依赖.
每个任务通过`output()`指定输出, `input()`指定输入.

- requires()
返回本task需要的其它tasks, 可以是task对象或封装的dicts, lists, tuples. VEP

### Parameter
`Parameter`可以给每个task增加参数, 用于定制化一些额外信息.

## Luigi的模式
Luigi没有中间文件的概念, 所以如果两个依赖的任务运行一半失败, 中间结果将会被保留.

### 如何触发多个任务
在每个不相关的任务链的结尾加一个相同的`dummy task`, 这样只需要触发这个任务就会触发多个任务, 类似`make`.
实际使用时, 在Luigi中使用`WrapperTask`来封装和唤起其它tasks就行了, 它不会有输出output.
```python
class AllReports(luigi.WrapperTask):
    date = luigi.DateParameter(default=datetime.date.today())
    def requires(self):
        yield SomeReport(self.date)
        yield SomeOtherReport(self.date)
        yield CropReport(self.date)
        yield TPSReport(self.date)
        yield FooBarBazReport(self.date)
```

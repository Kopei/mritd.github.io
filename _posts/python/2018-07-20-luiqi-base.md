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
`Target`类是对文件的映射, 如果只有一个target支持原子性操作, 也支持open()和Gzip. 多个targets需要用户保持文件的原子性操作.

### Task
Task是实际做任务的地方. 通过`run()`, `output()`, `requires()`设置任务的行为. `Task`通过其它`Task`产生的`Targets`作为输入, 结果产生也是`Target`.
任务之间可以通过`requires()`指定依赖.
每个任务通过`output()`指定输出, `input()`指定输入.

- requires()
返回本task需要的其它tasks, 可以是task对象或封装的dicts, lists, tuples. 

- 如果需要依赖外部task, 那么可以封装`ExternalTask`, 然后把这个task作为当前task的requires
```python
class LogFiles(luigi.ExternalTask):
    def output(self):
        return luigi.contrib.hdfs.HdfsTarget('/log')
```

- run()
run()函数是实际的任务运行地方, 如果有requires那么就会先解决依赖, 然后跑run的逻辑. input()会把requires的输出封装成targets, 用作run()的输入.
```python
class TaskWithManyInputs(luigi.Task):
    def requires(self):
        return {'a': TaskA(), 'b': [TaskB(i) for i in xrange(100)]}

    def run(self):
        f = self.input()['a'].open('r')
        g = [y.open('r') for y in self.input()['b']]
```

- task的事件和回调
luigi有事件系统能够注册事件回调, 然后使用自定义的task触发任务.
```python
@luigi.Task.event_handler(luigi.Event.SUCCESS)
def celebrate_success(task):
    """Will be called directly after a successful execution
       of `run` on any Task subclass (i.e. all luigi Tasks)
    """
    ...

@luigi.contrib.hadoop.JobTask.event_handler(luigi.Event.FAILURE)
def mourn_failure(task, exception):
    """Will be called directly after a failed execution
       of `run` on any JobTask subclass
    """
    ...
    
luigi.run()

```

### Parameter
`Parameter`可以给每个task增加参数, 用于定制化一些额外信息.

- 使用@inherits, @requires来传递多个task直接的参数, 考虑如下问题:
```python
class TaskA(luigi.ExternalTask):
    param_a = luigi.Parameter()

    def output(self):
        return luigi.LocalTarget('/tmp/log-{t.param_a}'.format(t=self))

class TaskB(luigi.Task):
    param_b = luigi.Parameter()
    param_a = luigi.Parameter()

    def requires(self):
        return TaskA(param_a=self.param_a)

class TaskC(luigi.Task):
    param_c = luigi.Parameter()
    param_b = luigi.Parameter()
    param_a = luigi.Parameter()

    def requires(self):
        return TaskB(param_b=self.param_b, param_a=self.param_a)
```
对上述代码,下游的task将会需要写上所有上游需要的参数, 这样就会产生参数爆炸, 如果想要简化参数, 可以是使用`@inherits`和`requires`
```python
import luigi
from luigi.util import inherits

class TaskA(luigi.ExternalTask):
    param_a = luigi.Parameter()

    def output(self):
        return luigi.LocalTarget('/tmp/log-{t.param_a}'.format(t=self))

@inherits(TaskA)
class TaskB(luigi.Task):
    param_b = luigi.Parameter()

    def requires(self):
        t = self.clone(TaskA)  # or t = self.clone_parent()

        return t

@inherits(TaskB)
class TaskC(luigi.Task):
    param_c = luigi.Parameter()

    def requires(self):
        return self.clone(TaskB)
```

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

### luigi的执行模型
luigi的执行模型很简单, 一个worker的进程执行所有tasks, 所以如果有成千上万个tasks, 扩展性将成为问题.

### 调度
luigi的调度由单独的`luigid`中心化管理, 多个worker执行run()时, 每次都会从依赖树从头向下遍历, 找到需要执行的task运行, 跳过已完成的task. 见
[gif](https://www.arashrouhani.com/luigid-basics-jun-2015/#/)


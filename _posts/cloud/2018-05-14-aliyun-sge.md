---
layout: post
comments: true
title: 使用阿里云的批量计算做SGE
categories: [cloud]
description:
keywords: [cloud, aliyun, sge]
catalog: true
multilingual: false
tags: cloud
---

## 前言
阿里云批量计算支持SGE集群, 版本是GE6.2, 只支持centos. 使用aliyun镜像市场已经打包好的镜像可以方便的起一个集群, 然后使用`batchcompute_sge`sdk管理和定制自己想要的sge集群特性, 比如动态扩展执行节点.


## SGE是什么?
Sun Grid Engine (SGE)是一个经典的UNIX批量计算调度系统. SGE可以使用网格有效地利用计算资源, 把节点的CPU当成slots来分配资源, 而不用管计算资源是何种结构. 理论上, 只要网络稳定, 一个简单的sge安装就可以满足小量用户使用而不需要任何维护. 但是SGE的背后是复杂的, 真正掌握SGE可能需要6到12个月. SGE具备一个典型的批量计算特征:
- 接受外部job请求
- 可以暂存未运行job
- 把暂存的job送到一个或多个执行节点
- 管理job运行, 中心化存储结果文件
- LOGs
SGE的架构主要围绕两个概念构建: queue队列和parallel environment平行环境.

### sge架构
SGE由头节点和计算节点组成, master host头节点运行`sge_master`. 这个守护进程控制GE的调度和组件(队列和job). sge_master维护着组件状态表, 用户访问权限等. sge_master也会处理从执行节点周期性传来的job状态, 负载等信息. 通常头节点也是提交节点和管理节点.
计算节点通常运行着`sge_execd`, 通常是执行节点`execution host`, 但是也可以是管理节点或提交节点, 不同于在master做管理节点, 把运行节点当管理节点需要注册这台host`qconf -ah <hostname>`; 提交节点就是用户提交job运行的节点, `qconf -as <hostname>`可以把一个计算节点作为提交节点. 在运行的job还有一个守护进程`sge_shepherd`, 它会作如下操作:
- 由`sge_execd`唤醒用于处理job
- 设置脚本前置的参数(跑Prolog)和PE
- 系统调用`setuid`成为用户
- 用子进程开始job, 控制job
- 处理停止,恢复,终止信号, 处理checkpointing
- 跑Epilog脚本, 清理环境, 关闭PE

### sge queue
队列是一类对资源需求相似job的容器, 他们能够同时在多个节点运行. 逻辑上说, 队列是并行环境的孩子, 虽然它可以有多个父亲. 一个队列可以在一个节点上, 也可以在多个节点上.
在多个节点上的队列叫做服务器场队列, 使用上如同在一个节点上一样. 一个节点也可以有多个队列. 应该把同一个属性的job分到同一个队列, 这样队列上属性的改变会影响到对应job, 比如暂停一个队列会暂停所以队列中的job. 默认安装的队列名是all.q, 可以定义额外的队列用于不同计算资源需求, 这样sge调度器可以选择合适的job到合适的网格节点运行.  

### parallel environment
并行环境（PE）是SGE的核心概念，代表了一系列设置，可以告诉Grid Engine如何启动，停止和管理由使用此环境的队列运行的作业. 可以使用PE设置一个队列所有job分配的最大slots, 也可以设置parallel messaging的参数, 用于并行计算. 使用如下命令可以管理PE:
```
qconf -spl ##show all pe
qconf -sp <PE name>
qconf -mp <PE name>
qconf -Ap ./my-PE-template.txt
qconf -ape <PE name>
```
创建PE的时候有几个关键属性要注意:
- slots: job可以占用的最大slots
- allocation_rule: 此设置控制如何将作业槽分配给主机。它可以有四个可能的值：
  - a number: 每个host会给job槽分配固定数字的slot, 直到满足job slots要求.
  - $fill_up: 会把当前host所有slots分配给job, 不够再到下一个host请求资源, 直到满足
  - round_robin: 使用轮询的方式从每个host索取资源, 直到满足job需求
  - pe_slots: 只占用某一台节点的资源. 这就意味着sge只会把job调度到某个满足slots要求的节点
- control_slaves: 控制MPI slaves
- job_is_first_task: job是否是并行计算的一部分
- accounting_summary: 如果`control_slaves`设为True, 可以使用这个配置查看子任务的统计信息


## 简单使用sge

## 用户权限管理
SGE有4个角色: Managers, Operators, Owners, Users.
- Managers: 就是admin, 具有有权限
- Operators: 除了没有add, delete, modify队列, 具有manager所有权限.
- Owners: 队列拥有者, 可以对他所有的队列做任何操作.
- Users: 没有管理集群和队列的权限, 只能使用队列.

## 使用sdk调整执行节点
- 调整队列
- 调整执行节点
- 调整host subgroups
```
qconf -ahgrp <hostgroupname>  ## add host group to group list
```

## SGE节点组的概念
就像Unix操作系统一样, 可以把节点分组, 组名用@开头. 组和组可以嵌套, 叫做subgroups(和/etc/group不同)
``` bash
qconf -shgrpl
@allhosts
```

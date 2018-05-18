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
### qsub
使用`qsub`提交job后, 调度器会对job做调度并且直接返回qsub是否调度成功. 例子:
```
$ qsub -cwd -b y -o my.txt -q all.q@iZuf63555dkqqm58d7dc9nZ hostname
Your job 8 ("hostname") has been submitted
$ qstat -j 8
==============================================================
job_number:                 8
exec_file:                  job_scripts/8
submission_time:            Tue May 15 11:39:27 2018
owner:                      rookie
uid:                        500
group:                      rookie
gid:                        500
sge_o_home:                 /home/rookie
sge_o_log_name:             rookie
sge_o_path:                 /usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/rookie/bin
sge_o_shell:                /bin/bash
sge_o_workdir:              /home/rookie
sge_o_host:                 iZuf668cj7e7k2ws1y6pdkZ
account:                    sge
cwd:                        /home/rookie
mail_list:                  rookie@iZuf668cj7e7k2ws1y6pdkZ
notify:                     FALSE
job_name:                   hostname
stdout_path_list:           NONE:NONE:my.txt
jobshare:                   0
hard_queue_list:            all.q@iZuf63555dkqqm58d7dc9nZ
env_list:                   
script_file:                hostname
error reason    1:          can't get password entry for user "rookie". Either the user does not exist or NIS error!
scheduling info:            (Collecting of scheduler job information is turned off)
```
上述job执行失败, 由于新创建的用户没有加入sge entry. 如果执行成功会在执行节点的当前目录看到`my.txt`, 默认是用户家目录. 参数详解:
- -o <output file>: 输出文件的路径. 如果不指定文件名, 默认采用<job_name>.o<job_id>
- -e <errorfile>: 指定错误文件, 默认采用 <job_name>.e<job_id>格式
- -b y/n: 执行的是脚本还是二进制job.
- -N [name]: job 名称
- -A [account name] 这个job的资源消耗记在谁的头上
- -r [y,n]: 这个job是否可重新跑, 默认y
- -cwd: qsub的-cwd选项告诉Sun Grid Engine，该作业应该在调用qsub的相同目录中执行
- -q: 指定节点上的队列
- -S [shell path]: 指定使用哪个shell
- -pe <parallel environment> [<number of cores>]: 执行并行job时需要指定CPU核数.  
- -l resource=value,.. : 指定资源需求, 使job在满足需求的队列上运行. `-l`可以在qsub, qsh, qrsh, qlogin, qalter上使用. `resource`这个键值可以是queue或host相关, 可以是queue相关的资源属性:
  - qname
  - hostname
  - notify
  - calendar
  - min_cpu_interval
  - tmpdir
  - seq_no
  - s_rt
  - h_rt
  - s_cpu
  - h_cpu
  - s_data
  - h_data
  - s_stack
  - h_stack
  - s_core
  - h_core
  - s_rss
  - h_rss
host相关是资源属性有:
  - slots
  - s_vmem
  - h_vmem
  - s_fsize
  - h_fsize

### 输出参数
有三个参数可以配置输出流
- -e path_list: 设置标准错误输出流路径
- -j y[es]n[o]: 合并标准输出和标准错误流
- -o path_list: 设置标准输出路径

### 执行脚本中设置参数
在job的执行脚本头上写入`#$`可以设置job的qsub参数, 这样就不需要在命令行输入参数.

### 指定队列
```
qsub -q queue_name job
qsub -q queue_name@hostname job
qsub -q queue_name@@hostgroupname job
qsub -q '*@@hostgroupname' job # 可以使用通配符匹配
```

### SGE 环境变量继承关系
execd -> shepherd -> shell -> job, 后续继承的环境变量可以被覆盖


### 默认job参数, 在提交节点设置$HOME/.sge_request
可以设置以上这个文件来让job启用默认参数, 比如邮件通知方式:
```
-M <email-address>  # -M root@localhost 邮件会给执行节点root发邮件
-m baes  ## will notify whether job is begin, aborted, end, suspend.  
-v PYTHONPATH ## environment variables
-V   # pass all environment variables, 这个参数可能有bug
-pe smp 2 ## pe settings
```
如下三个文件是默认参数读取的文件, 可以被覆盖.
$SGE_ROOT/$SGE_CELL/common/sge_request
$HOME/.sge_request
$PWD/.sge_request

### qdel job_id
### qhost 查看所有节点状态
### qstat 查看queue和job的状态
qstat输出的job`state`有d(eletion),  E(rror), h(old), r(unning), R(estarted),q(ueued), s(uspended), S(uspended), t(ransfering), T(hreshold) or w(aiting).  `qstat -explain c -j <job_id>`可以查看具体job跑失败的原因. 下面是一些例子:
```
qstat -u '*' Displays list of all jobs from all users.
qstat -g c    show available nodes and load
qstat -u joeuser  -- useful in seeing list of jobs from particular user. Especially when particular user job are having troubles
qstat -u hpc1***: Displays list of all jobs belonging to user hpc1***
qstat -f: gives full information about jobs and queues. Provides a full listing of the job that has the listed Job ID (or all jobs if no Job ID is given).  See qstat -f below.
qstat -j job_number -- provide detailed information why the pending job is not being scheduled. See qstat -j below
qhost -F
qstat -g t -- command is useful for showing where all of your parallel tasks are running, otherwise you only see where the "master" task (MPI task #0) is running.
qstat -s p shows pending jobs, which is all those with state "qw" and "hqw".
qstat -s h shows hold jobs, which is all those with state "hqw".
```

## 用户权限管理
SGE有4个角色: Managers, Operators, Owners, Users.
- Managers: 就是admin, 具有有权限
- Operators: 除了没有add, delete, modify队列, 具有manager所有权限.
- Owners: 队列拥有者, 可以对他所有的队列做任何操作.
- Users: 没有管理集群和队列的权限, 只能使用队列.

### 配置用户Access list
只要用户在一个提交节点和一个执行节点有ID, 那么就可以使用SGE. 但是管理员可以限制用户对某些队列的访问限制, 也可以限制对一些工具的使用比如PE. 指定访问权限需要定义`User Access List`, 可以使用unix的user和group定义user access list. 然后根据这个list来限制对资源的读写权限.
```
qconf -au username[,...] access-list-name[,...]
qconf -sul ##查看所有user access list
```

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

## 执行节点动态拓展
使用`qstat -u '*' -s p`检查`qw`或`hwq`队列的长度, 相应地启动执行节点进行动态拓展; 同时当队列为空时, 减少执行节点到一定数目

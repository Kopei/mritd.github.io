---
layout: post
title: Kubernetes Pod含义
categories: [kubernetes]
description: pod一群鲸鱼
keywords: kubernetes
catalog: true
multilingual: false
tags: kubernetes
---
> 官网文档 [https://kubernetes.io/docs/concepts/workloads/pods/pod/](https://kubernetes.io/docs/concepts/workloads/pods/pod/)

### 什么是Pod？
Pod的本身含义是**一群鲸鱼**的意思, 而Docker的Logo刚好是🐳。所以简单说pod就是一组容器。（不一定是docker container) pod里的容器共享存储，网络和运行的容器环境。共享的东西包括cgroup, 命名空间, Ip, 端口和其他隔离方面的东西

### pod内部通讯
由于pod里面的容器共享ip, 容器间的通讯可以通过内部进程通信（SystemV semaphores， POSIX shared memory）或localhost.

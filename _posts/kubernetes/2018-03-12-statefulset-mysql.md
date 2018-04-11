---
layout: post
title:
---

> [https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)

### 前言
之前说到[使用aliyun容器服务搭建mysql](/k8s-mysql), 但是想要k8s在生产跑mysql，还是需要一些额外的考虑。本文参照k8s官网的推荐，在aliyun
上配置一个主-从的mysql集群，希望能够使用容器搭建一个生产环境的mysql集群。


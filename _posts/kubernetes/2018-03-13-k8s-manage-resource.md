---
layout: post
title: K8S管理容器的计算资源
categories: [kubernetes]
description: 简单先记录一下
keywords: kubernetes
catalog: true
multilingual: false
tags: kubernetes
---
> [https://v1-8.docs.kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/](https://v1-8.docs.kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)

### 前言
k8s可以给pod设置计算资源用量， 当遇到违反某些不满足性能的条件时，k8s会有一套机制来处理。限制资源在编排模拟中使用`limits`或`requests`. 
`requests`指定资源的最小要求，`limits`指定最大用量。详细关系是 `0 <= request <=Node Allocatable`和`request <= limit <= Infinity`。
具体查看[resource-qos](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/node/resource-qos.md)

### 





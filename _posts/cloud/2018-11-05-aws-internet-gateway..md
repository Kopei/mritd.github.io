---
layout: post
title: AWS的VPC组件
categories: [cloud]
description: 记录aws VPC的相关
keywords: aws, vpc, igw, acl
catalog: true
multilingual: false
tags: aws, vpc, igw, acl
---

### IGW
`Internet Gateway`(IGW)是一个水平扩展, 冗余, 高可用的aws VPC组件. 主要的作用是能让你的VPC和英特网连接. 一个`IGW`可以作为`VPC`路由表中的`target`, 会把虚机的IP地址做NAT(网络地址转换), 以让英特网认为私有的虚机具有公网的IP, 从而做到私有虚机和英特网能够通讯.

### DHCP 
`Dynamic Host Configuration Protocal`(DHCP)提供了一个标准用于通过TCP/IP传输配置信息给主机.
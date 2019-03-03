---
layout: post
title: 一台虚机多个IP
categories: [cloud]
description: 一台云主机可以有多个IP, 这么做有很多个好处
keywords: cloud, ip
catalog: true
multilingual: false
tags: cloud
---

一个云主机可以被分配多个IP, 这样做的好处有:
- 一台虚机运行多个web应用, 然后每个ip一个应用,每个ip一张ssl证书
- 防火墙或者负载均衡器需要多个IP
- 如果一台虚机宕机, 那么可以把多个ip的一个转移到另一台备用主机, 做到高可用.
下面以AWS为例子介绍一台主机多个IP是怎么工作的.

### 多个IP地址是如何工作的?
ip需要绑定到网卡, 以下主要以IPv4为例做介绍
- 多个IPv4私有地址可以绑定到任何网路接口, 网路接口可以绑定或解绑到主机.
- IPv4的地址必须是在子网的网段内
- 网路接口是有安全组的, 所以对应的IP就应该遵循这个安全组规则.
- 多个IP地址可以被分配给网路接口, 网路接口可以是绑定到运行着或者非运行着的主机.
- 一个已经被分配的ip可以从一个网卡分配到另一个网卡.
- 虽然主机的主网卡不能被移走, 但是主网卡的第二个ip可以被移动到另一个网卡.
- 每一个IPv4地址可以被分配一个弹性IP, 反之亦然
- 当一个Ipv4的私有地址被分配到另一个网卡时, 它对应的弹性IP会跟随移走.
- 当一个IPv4私有地址从网卡移走, 那么弹性IP会自动和这个IP解绑.
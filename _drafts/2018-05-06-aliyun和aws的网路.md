---
layout: post
comments: true
title: 阿里云和aws的网路特点
categories: [cloud]
description:
keywords: [cloud, aliyun, aws]
catalog: true
multilingual: false
tags: cloud
---

### 阿里云高速通道支持不同区域vpc直连，这个比aws的vpc peering好， vpc peering只能用于同一区域，且不同ip段连接。

### aws的弹性网路接口（ENI)，是一个虚拟网卡，只能用于VPC中的实例。阿里云未找到相应的产品。我们可以在虚机默认的主网卡上额外添加网路接口，由于它是弹性的，所以可以把它从一个实例移除，
 然后放到另一个虚机上，并保留原有的网路属性。 那么有哪些网路属性呢？ 一个弹性网路接口可以有如下属性：
 - 有一个主要IPv4私有地址
 - 一个或多个辅助私有地址
 - 每一个私有IP可以有一个弹性IP
 - 一个公有IP(取决于子网是否分配公有IP的属性设置）
 - 一个或多个IPv6地址
 - 一个或多个安全组
 - 一个MAC地址
 - 一个源/目标检查标记
 - 一个描述

### aws的弹性IP不支持IPv6， 弹性IP地址只能在一个特定区域中使用。一个运行着一个弹性IP的实例是不收取ip费用的，但是闲置的弹性IP aws将按小时收费。而aliyun总是收取EIP保有费的（除非EIP和VPC中虚机绑定），
包年包月还不能释放；后付费可以用按量或者按带宽选择。

### aws VPC flow logs. flow log用于捕获有关传入和传出 VPC 中网络接口的 IP 流量的信息。流日志数据使用 Amazon CloudWatch Logs 存储。创建流日志后，您可以在 Amazon CloudWatch Logs 中查看和检索其数据。
可以为 VPC、子网或网络接口创建流日志。如果为子网或 VPC 创建流日志，则会监视 VPC 或子网中的每个网络接口。

### 使用aws的Direct Connect除了常规的优势： 减少流量费、网速保证、私有链接外，它比vpn连接最大的优势时，支持10G带宽，而vpn只能到4Gbps. 实现direct connect需要2个组件：物理链路和virtual interface(VIF)。
想要把流量通过direct connect 路由到VPC, 那么需要在aws这边创建私有VIF；如果需要连接公有的aws服务，那么需要创建公有VIF.没有VIF有如下组件：
- Virtual Local Area Network ID. 这个VLAN id是唯一的
- 需要连接的IP地址， 支持IPv6.
- 只支持BGP路由协议

### aws LoadBalancer有三种类型： classic, network, application. 见下图：

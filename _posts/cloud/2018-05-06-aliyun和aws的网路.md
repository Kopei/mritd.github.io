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

## 本文主要介绍aws网络产品, 并对比阿里云的产品

### 阿里云高速通道支持不同区域vpc直连，这个比aws的vpc peering好， vpc peering只能用于同一区域，且是不同ip段连接。

### aws每个区域的默认 VPC 数量是5个, 每个vpc默认子网有200个, VPC 的网段从/16 到 /28.

### aws的弹性网路接口（ENI)，是一个虚拟网卡，只能用于VPC中的实例。阿里云叫弹性网卡。我们可以在虚机默认的主网卡上额外添加网路接口，由于它是弹性的，所以可以把它从一个实例移除， 然后放到另一个虚机上，并保留原有的网路属性。 那么ENI有哪些网路属性呢？ 一个弹性网路接口可以有如下属性：
 - 有一个主要IPv4私有地址
 - 一个或多个辅助私有地址
 - 每一个私有IP可以有一个弹性IP
 - 一个公有IP(取决于子网是否分配公有IP的属性设置）
 - 一个或多个IPv6地址
 - 一个或多个安全组
 - 一个MAC地址
 - 一个源/目标检查标记
 - 一个描述

### aws的弹性IP不支持IPv6， 弹性IP地址只能在一个特定区域中使用。一个运行着一个弹性IP的实例是不收取ip费用的，但是闲置的弹性IP aws将按小时收费。而aliyun总是收取EIP保有费的（除非EIP和VPC中虚机绑定），包年包月还不能释放；后付费可以用按量或者按带宽选择。

### aws VPC flow logs. flow log用于捕获有关传入和传出 VPC 中网络接口的 IP 流量的信息。流日志数据使用 Amazon CloudWatch Logs 存储。创建流日志后，您可以在 Amazon CloudWatch Logs 中查看和检索其数据。可以为 VPC、子网或网络接口创建流日志。如果为子网或 VPC 创建流日志，则会监视 VPC 或子网中的每个网络接口。

### 使用aws的Direct Connect除了常规的优势： 减少流量费、网速保证、私有连接外，它比vpn连接最大的优势是，支持10G带宽，而vpn只能到4Gbps. 实现direct connect需要2个组件：物理链路和virtual interface(VIF)。
想要把流量通过direct connect 路由到VPC, 那么需要在aws这边创建私有VIF；如果需要连接公有的aws服务，那么需要创建公有VIF.每个VIF有如下组件：
- Virtual Local Area Network ID. 这个VLAN id是唯一的
- 需要连接的IP地址， 支持IPv6.
- 只支持BGP路由协议

### aws LoadBalancer有三种类型： Classic, Network, Application LoadBalancer. 见下图：
![http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-05-06%20%E4%B8%8B%E5%8D%888.21.58.png](http://p0iombi30.b
kt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-05-06%20%E4%B8%8B%E5%8D%888.21.58.png)
![http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-05-06%20%E4%B8%8B%E5%8D%888.37.46.png](http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95
%E5%BF%AB%E7%85%A7%202018-05-06%20%E4%B8%8B%E5%8D%888.37.46.png)

### aws CloudFront 是一个能加速你的静态和动态内容的web服务.除了能分发静态内容,还能分发动态内容和流内容.

### aws Route 53的5中路由方式:
- sample routing. 简单匹配dns数据库中的记录, 比如一个域名对应一个IP
- weighted routing. 加权路由是按比例分发流量
- latency-based routing. 基于延迟时间选择延迟低的分发流量
- geolocation routing. 根据用户的IP所在地分发流量, 有时候可能定位用户IP, 那么需要定义一个默认路由, 方式路由出现no answer.
- failover routing. 失效转移路由.作为辅助路由, 当主要路由健康检查失败, 那么切换到这个路由.

### aws有三种提供vpn连接的方式：
- Virtual Private Gateway。VGW是高可用和可扩展的。 给VPC绑定一个VGW, 就可以通过IPsec建立安全连接。 VGW支持静态路由和BGP方式， 如果是静态路由，那么对方网路的IP段不能和VPC相同。
- AWS VPN CloudHub. CloudHub是高可用和可扩展的。如果有多个站点需要建立安全通信，可以使用CloudHUB, 这样不仅可以访问VPC内资源，还可以在站点间建立通信。
- 第三方的software VPN








>>>>>>> 978e114c0b8738e4c19ddcd80d9753c1f4c53fb2:_drafts/2018-05-06-aliyun和aws的网路.md

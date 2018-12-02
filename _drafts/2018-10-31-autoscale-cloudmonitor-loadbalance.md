---
layout: post
title: 云计算的自动扩展,监控和负载均衡
categories: [cloud]
description: 主要看看aws和阿里云的服务
keywords: auto-scale, load balance
catalog: true
multilingual: false
tags: cloud
---

上云的一个巨大好处是可以动态设置计算资源, 根据负载的增减相应配置服务器的数量, 这种可扩展性是本地数据中心不可比拟的. 下面就来看看主要云厂商的`auto scale`功能, 自动扩展一般是和监控和负载均衡一起使用的, 这里也顺便带一下.

### 自动扩展的组件
想要配置自动扩展的功能, 一般需要配置三个组件: 1.`launch configuration`伸缩配置, 2.`Auto scaling group`自动伸缩组, 3.`scaling policy`伸缩策略. 


### 冷却时间
冷却时间是指，在同一伸缩组内，一个伸缩活动执行完成后的一段锁定时间。在这段锁定时间内，该伸缩组不执行其他的伸缩活动。

### 计费
云厂商支持扩展的虚机可以是按需或者竞价计费, 一般按小时收费, 不过现在有些厂商支持按秒收费.
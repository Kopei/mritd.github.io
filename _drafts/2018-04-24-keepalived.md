---
layout: post
title: Keepalived简单使用
categories: [linux]
description:
keywords: Keepalived
catalog: true
multilingual: false
tags: linux
---

## Keepalived简介
Keepalived是一个用C写的路由软件, 目的是为了给linux系统或linux相关基础设施提供高可用和负载均衡.
keepalived负载均衡的功能依赖于LVS([Linux Virtual Server](http://www.linux-vs.org/))内核模块, 这个模块提供Layer4负载均衡.
而高可用则通过VRRP([Virtual Router Redundancy Protocol](https://datatracker.ietf.org/wg/vrrp/documents/))实现, VRRP可以做到路由失效转移.
另外, Keepalived提供了一些hooks实现VRRP有限状态机, 用于和底层协议的交互. 上述这两个协议可以同时或者单独使用, 来构造一个强健的基础设施.

## LoadBalancer的高可用
做负载均衡的时候, 往往需要考虑负载均衡器(有时叫director, lvs router)本身的可用性, 而keepalived就是一个框架同时提供负载均衡和高可用.

---
layout: post
title: Openshift的网路
comment: true
update_date: 2018-02-28
categories: [openshift, kubernetes]
description: 
keywords: openshift
catalog: true
multilingual: false
tags: kubernetes, openshift
---

> https://docs.openshift.org/latest/architecture/networking/networking.html

### 前言
openshift的网路架构是建立在kubernetes的service上的。K8S的[Service](https://kubernetes.io/docs/concepts/services-networking/service/)是一组pods和访问这些pods的逻辑抽象，service解耦了下游pods的网路变化。但是由于Service也会变化，所以openshift在master运行[skyDNS](https://github.com/skynetservices/skydns)来解决service网路的变化。

### SDN
Software Define Networking软件定义集群网络使openshift的pods相互能够通信，SDN使用Open vSwitch(OVS)来管理配置网路。有三种SDN插件可以配置pods网路：
- ovs-subnet, 提供所有的pods直接相互通信
- ovs-multitenant, 能够提供项目级别的pods和service隔离。每一个项目都有一个VNID, 这个网路内项目之间的pods不能相互通信。VNID 0是一个例外，可以和所有pods通信，可以提供负载均衡等服务。Openshift正是使用br0的tag VNID功能，做到网络的隔离。
- ovs-networkpolicy, 这里用户可以自己定义网路规则。

在master上，Openshift SDN分配网络给运行节点并且注册到etcd, SDN会给新的节点分配新的子网，可以定义的网段有10.128.0.0/14, node节点定义在10.128.0.0/23。SDN是不会给master配置集群网络访问，所以master节点是不能访问集群网络的，除非它也作为运行节点。

在运行节点，SDN先在etcd注册，然后会创建三个网络装置: br0,tun0,vxlan_sys_4789
- br0, ovs的网桥，pods会和它连在一起。SDN也会在这个网桥上配置非子网的流量进出规则。
- tun0, ovs的内部端口，在br0的port 2, 是子网的网关，负责pods访问外部网络。SDN会通过配置netfilter和路由规则使集群子网NAT访问外部网络。
  `eth0 (in A’s netns) → vethA → br0 → tun0 → (NAT) → eth0 (physical device) → Internet`
- vxlan_sys_4798, OVS的VXLAN，在br0的port 1, 提供容器访问远程节点。
  `eth0 (in A’s netns) → vethA → br0 → vxlan0 → network → vxlan0 → br0 → vethB → eth0 (in B’s netns)`
  
SDN会对每个新的pod作4件事：
- 分配子网内的一个新的ip给pod。
- 连接宿主机边pod的veth网络接口到OVS的br0。
- 在OVS数据库增加一条OpenFlow规则，让到新pod的流量导入正确的OVS端口。
- 如果是多租户情况， 给流量打上标记VNID, 并且使其正确流向对应VNID. 没有匹配的VNID将会采用默认规则。

SDN运行节点也会跟踪master节点对子网的更新, 当新的子网加入，br0会在新增一条Openflow规则，使vxlan0能够访问远程子网。
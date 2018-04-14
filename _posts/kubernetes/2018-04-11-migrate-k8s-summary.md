---
layout: post
title: 本地rails系统迁移到阿里云容器服务小结
categories: [kubernetes]
description: k8s实验性迁移小结
keywords: kubernetes
catalog: true
multilingual: false
tags: kubernetes
---

> 实验性迁移小结

## 迁移目标
本文主要记录了将本地rails迁移到云上容器服务的过程, 包括如何部分重构本地应用代码和一些思考. 迁移本地应用的目的主要是为了能够将应用变得高可用和更好的扩展性, 以及为了更好的容器管理.

## 原来的系统状况
本地的rails系统是一个典型的数据库-网页应用, 原来采用docker compose构建部署, 用到的技术栈主要有, 结构图如下:
- rails5.0
- mysql5.7
- sidekiq
- redis
- nginx

![http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-04-11%20%E4%B8%8B%E5%8D%883.52.27.png](http://p0iombi30.bkt.cloud
dn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-04-11%20%E4%B8%8B%E5%8D%883.52.27.png)

## 迁移后的系统
迁移k8s后系统, 系统变得更加模块化(当然没有微服务化). 结构如下图:
![http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-04-11%20%E4%B8%8B%E5%8D%883.45.43.png](http://p0iombi30.bkt.cloud
dn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-04-11%20%E4%B8%8B%E5%8D%883.45.43.png)

## 一些细节和原来本地的问题
新的部署主要把原来多个进程从一个容器分离了出来, 用docker提倡的一个进程一个container; 把`rake db:migrate`等操作做成k8s的job; 并且把底层的存储用了云上的OSS和NAS. 由于是实验性的部署, 并没有使用managed service, 如rds和redis, 这部分还是自己搭建的, 以后会切换为云上的服务. 大致细节图:
![http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-04-11%20%E4%B8%8B%E5%8D%884.18.43.png](http://p0iombi30.bkt.cloud
dn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-04-11%20%E4%B8%8B%E5%8D%884.18.43.png)
- 如上图, sidekiq和rails在同一个pod(还在考虑要不要分出来), 连接的redis使用的是helm部署(没有使用pv), mysql采用的[官网](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)StatefulSet例子 , 并且在集群前面搭建一个mycat,做读写分离, 底层的存储使用k8s的动态pv. mysql集群的问题是mycat不是HA, 所以需要继续改进, 可能是考虑`vitess`或`galera`.
- **本地问题** assets需要用nginx来处理. 务必做到开发,测试, 生产各个环境一致.必须是用k8s `Secret`来处理敏感信息,但是不要commit进代码库,可以直接使用的k8s控制台创建.
- **其它思考**.
  - google墙的问题
  - 需要各种正向反向代理, 以便内网用户能够访问应用; 需要反向代理以便使用集团的各种服务,比如邮箱服务.
  - 由于本地gitlab网络不能出去, 所以需要搭一个自动构建/推送镜像上云的流程.(走外网费流量)
  - 后续集成managed service(non-native service)需要集成进k8s, 这里还没有经验.
  - 如何给每个开发设置kubectl权限. 现在是采用RBAC+Namespace来控制, 有一些笨拙,网上有推荐使用OpenID.
  - 部署自动化, 由于有了service, 进行金丝雀,蓝绿部署变得比较方便.不过还是需要手动干预,后续要考虑自动化
  - 阿里云的Docker registry和helm仓库有点弱, 我想在控制台删个镜像都要用api.
  - CI/CD. 也是上一条思考相关. k8s集成jenkins看起来比较方便(推荐jenkinsfile), 不过考虑是不是看看其他集成方案.
  - 日志管理还没有深入研究.
  - 有了k8s, 可以考虑将微服务化应用. 如果微服务化了,服务的治理会是个问题.
  - 开发需要使用新的工具, 如telepresence, helm,  Kubeval等. 用`helm`打包成`chart`可以方便的部署一整个应用.

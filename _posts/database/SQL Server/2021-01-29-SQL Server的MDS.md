---
layout: post
title: SQL Server的主数据服务MDS简介
categories: [database]
description: 
keywords: SQLServer
catalog: true
multilingual: false
tags: database, Master data
---

## Master Data Services简介
SQLServer的MDS可以用来管理组织的主数据，并且通过Excel分享这些信息。


在MDS中，Model是主数据结构的最高级别容器。你可以创建model来管理相似数据组，比如管理所有线上产品。一个Model可以是**一个Entity或者多个Entities**. 比如一个产品model包含产品，颜色和风格， 颜色entity包含所有的颜色。Entity可以有两种属性：*free-form*和*domain-based*属性，*free-form*可以直接用于描述entity，*domain-based*需要通过一个domain的entity来表现(就是entity的一个属性是另一个entity)。



## MDS使用流程
创建一个model --> 创建多个entities --> 创建*domain-based* entities --> 创建*free-form* entities --> 创建属性组 --> 导入entities数据 --> 使用业务逻辑确保数据质量 --> 创建层级结构 --> 创建显式层级如需 --> 把组聚为集合如需 --> 创建自定义元数据 --> 给model打个版本号 --> 创建订阅视图 --> 配置权限


## 
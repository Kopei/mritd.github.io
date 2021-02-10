---
layout: post
title: SQL Server的主数据服务MDS简介
categories: [database]
description: 主数据管理和MDS
keywords: SQLServer
updated_at: 2021-02-09 17:30:00 +0000
catalog: true
multilingual: false
tags: database, Master data
---

## 关于主数据管理系统

MDM(Master Data Management)是从企业各个数据源采集数据，使用统一的标准和业务流程构建单一数据视图，并且将主数据分发, 作为企业内部其他系统依赖的数据金标准。

主数据系统一般需要收集如下信息：

- 人(客户，供应商，雇员，患者等)
- 物(产品，业务单元，部件，装备等)
- 地点(地址，仓储，地理区域等)
- 抽象(账户，合同，时间等)

MDM 一般的做法流程是：

1. 从不同的数据源导入到 staging 数据库
2. 把 staged 的数据和领域属性映射，再做标准化和归一化，清洗，应用业务规则，富集数据，最后打上版本
3. 通过 API 把数据发布给相关用户

另外，主数据的修改需要记录， 方便审计。

### 主数据管理系统一般具有的功能

- `Domain`. 能够把主数据和领域分开和关联。
- `Repository/Entity`. 一个仓库或实体定义主数据的结构。
- `Attributes`. 仓库的属性
- `Attribute Groups`. 基于业务领域，有方法可以把相似类型的属性分组在一起。
- `Business Processes`. 一个好的业务流程可以方便治理数据
- `Business Rules`. 业务规则是限制某个属性取值的范围
- `Permissions`. 鉴权授权，典型 MDM 的角色有：Data stewards(数据管家)，approvers(审批人)，requesters(发起人)
- `UI`.
- `Web Services`.
- `Data Publish`. 推送的机制把数据送到订阅的用户。
- `Data Quality`.

基于上述特点，典型的 MDM 架构应该是：
<img src="{{site.baseurl}}/assets/images/2021-02/MDM_architecture.png" />

## Master Data Services 简介

基于 SQLServer 的 MDS 可以用来管理组织的主数据，使用`WCF(Windows Communication Foundation)`提供 SOA 接口，并且可以通过 Excel 分享这些信息。

在 MDS 中，Model 是主数据结构的最高级别容器。你可以创建 model 来管理相似数据组，比如管理所有线上产品。一个 Model 可以是**一个 Entity 或者多个 Entities**. 比如一个产品 model 包含产品，颜色和风格， 颜色 entity 包含所有的颜色。Entity 可以有两种属性：*free-form*和*domain-based*属性，*free-form*可以直接用于描述 entity，*domain-based*需要通过一个 domain 的 entity 来表现(就是 entity 的一个属性是另一个 entity)。

MDS 是一个典型的三级架构：数据库层、服务层、WEB/Add-in 层。
<img src="{{site.baseurl}}/assets/images/2021-02/mds-architecture.png" />
MDS 一般要和 DQS 和 SSIS 结合使用，用于数据的集成和ETL。

### MDS 的组件

- `Configuration Manager`, 配置管理工具用于配置数据库和 web 应用。
- `Master Data Manager`, Web 应用用于管理任务，配置接口和视图。
- `MDSModelDeploy.exe`, 部署工具。
- `MDS Web Service`, SOA
- `Add-in for Excel`, excel 插件。

## MDS 使用流程

创建一个 model --> 创建多个 entities --> 创建*domain-based* entities --> 创建*free-form* entities --> 创建属性组 --> 导入 entities 数据 --> 使用业务逻辑确保数据质量 --> 创建层级结构 --> 创建显式层级如需 --> 把组聚为集合如需 --> 创建自定义元数据 --> 给 model 打个版本号 --> 创建订阅视图 --> 配置权限

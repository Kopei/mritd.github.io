---
layout: post
title: 使用平行变更做到数据库迁移零停机
---
> [zero-downtime-deployment-with-a-database](https://spring.io/blog/2016/05/31/zero-downtime-deployment-with-a-database)

### 前言
现存问题
  - 由于没有专业数据DBA，不能做复杂的、颗粒度细的备份恢复工作，同时复杂的数据库备份和恢复增加了CI部署流程的复杂性。
  - 蓝绿部署时需要能够回滚数据库迁移， 回滚应用需要能兼容老版本。
  
### 引文介绍
这篇[文章](https://spring.io/blog/2016/05/31/zero-downtime-deployment-with-a-database)很好的介绍了一种零停机、向后兼容的部署方式, 是[Parallel Change](https://martinfowler.com/bliki/ParallelChange.html)在部署方面的一种实践。大致意思是：**在现存版本升级到新版本时，如果需要更改数据库结构，比如更改了字段名称，需要在业务逻辑和数据库层面配合做一种中间版本，此数据库和业务逻辑中间版本向后兼容，在蓝绿部署的时候如有意外能顺利回滚业务代码，而不回滚数据库，然后就能够平滑、无停机地过渡到新版本**。文中使用[Flyway](http://flywaydb.org/)做迁移工具，Java spring boot做演示，相应地，Django, Rails也应该适用。



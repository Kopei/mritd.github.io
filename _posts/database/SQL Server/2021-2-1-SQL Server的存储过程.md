---
layout: post
title: SQL Server的存储过程
categories: [database]
description: 简介
keywords: SQLServer
catalog: true
multilingual: false
tags: database, stored procedures
---

## 简介

SQL Server 的存储过程是微软基于 ANSI SQL 的扩展，和其他数据库的过程类似是一组或多组事务性 SQL 语句。它的特点是：

- 接受多个输入参数，可以返回多个值。
- 包含编程语句用于操作数据库，包括调用其他存储过程。
- 返回调用成功与否的状态。

### 使用存储过程的好处

- **减少服务端、客户端的网络流量**， 存储过程的代码是一次性批量传输给服务端，不像普通语句是一行一次传输给客户端，这样减少了网络流量。
- **更安全**， 不同的用户和客户端可以运行存储过程操作底层的数据库对象，即便这个用户没有底层对象的权限。（减少了单独对用户的授权的便捷性，但是更安全了？）`EXECUTE AS`语句用来作为执行过程用户。存储过程是可以被加密的。
- **复用代码**
- **更容易维护**
- **更好的性能**，因为第一次运行后执行计划会被保留。

### 存储过程的类型

- **自定义** 用户自定义的存储过程可以用于所有数据库(除了 Resource 数据库).
- **临时** 临时存储过程也是一种用户自定义过程，存储在`tempdb`库中，它的生命周期就是连接的时间。临时存储过程又分为`local`和`global`, 它们的区别在于名字、可见性和可用性。`local`存储过程以`#`开头命名，只对当前连接用户可见，连接关闭将删除过程。`global`存储过程以`##`命名开头，这个过程创建后对所有用户可见，当最后一个会话关闭后将删除过程。
- **系统** 系统存储过程存储在`Resource`数据库，逻辑上以`sys`表出现。另外`msdb`数据库也有系统存储过程存在`dbo`表中，用于调度警告和任务。一般系统存储过程以`sp_`命名开头。用户可以扩展系统存储过程，一般以`xp_`命名开头，见官网资料 [https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/general-extended-stored-procedures-transact-sql?view=sql-server-2017](General Extended Stored Procedures)
- **扩展自定义** 用户可以使用 C 语言来创建外部 DLL,不过为了将来的兼容性不建议使用。

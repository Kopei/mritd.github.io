---
layout: post
title: SQL Server的触发器
categories: [database]
description: 简介sql server的logon trigger
keywords: SQLServer 
catalog: true
multilingual: false
tags: database, trigger
---

## SQL Server的Trigger简介
SQL Server主要有三种trigger: `DDL Trigger`, `DML Trigger`, `Logon Trigger`.下面将分别介绍。
`SQL Server`的`Logon Trigger`是触发器在用户建立会话后将触发对应的存储过程。更加具体一点是在用户真正建立会话之前，认证成功之后的阶段。认证失败的时候触发器是不会触发的。
我们可以使用`logon trigger`来审计和控制服务端会话，比如追溯登入活动，限制特定账号的登入会话数。
实际上`logon trigger`对应于`AUDIT_LOGIN`事件，`AUDIT_LOGIN`可以用于[Event Notifications](https://docs.microsoft.com/en-us/sql/relational-databases/service-broker/event-notifications?view=sql-server-2017)。
`Event Notifications`和`Trigger`的主要区别是，触发器是同步的，`Event Notification`是异步的。


`DDL Trigger`是在各种DDL(Data Definition Language)事件时触发的存储过程。这些事件主要包括事务语句：`CREATE, ALTER, DROP, GRANT, DENY, REVOKE, UPDATE STATISTICS`. 某些系统存储过程运行DDL类似的操作也可以触发DDL触发器。 一般我们使用`DDL Trigger`来：
- 防止数据库结构改变
- 结构变化需要对应一些改变
- 记录结构改变


`DML Trigger`是当DML(Data Manipulation Language)事件发生时触发的存储过程。DML事件包含: `INSERT, UPDATE, DELETE`语句。`DML trigger`可以被用来保证业务规则和数据完整性, 尤其在底层一些contraints不能很好满足需要的时候。

## Logon Trigger
### 触发器的执行顺序
如果在`LOGON`事件定义了多个触发器， 触发器执行的先后顺序是可以在`sp_settriggerorder`中定义的。SQL Server不能保证其它触发器的执行顺序。

### 管理事务
在SQL Server真正触发trigger前，SQL Server会创建一个隐式的事务，此时事务计数为1.在所有`logon trigger`完成执行，事务才会`commit`. 当`logon trigger`执行完，事务计数为0时，SQL Server会报错。什么时候`logon trigger`会将事务计数置0呢？一般有两种情况，`ROLLBACK TRANSACTION`和不正确的`COMMIT TRANSACTION`数(每次commit会减一计数).
在`logon trigger`使用`ROLLBACK`时需要注意：
- 任何rollback前的数据修改将被回滚，包括在同一个事件之前已执行的触发。后续的trigger不会再触发。
- **注意**，当前trigger`ROLLBACK`后面的语句将会继续执行，数据修改将不会被回滚。

## DDL Trigger
### DDL Trigger的类型
`DDL Trigger`有两种类型： 事务型(Transact-SQL)和通用语言型(Common Language Runtime). 事务型的`DDL Trigger`应对服务级别或者数据库级别的事件，如修改服务配置(ALERT SERVER CONFIGUATION)或删除表(DROP TABLE);`CLR Trigger`是在.net写的`assembly`代码。
### DDL Trigger的范围
DDL Trigger触发对应的事件可以是当前数据库或者当前服务器，取决于具体事件。数据库范围的DDL Trigger存储在数据库上, 运行`select * sys.triggers`视图可以看到数据库层面的`DDL Trigger`;服务器层面的`DDL Trigger`存储在`master`数据库，运行`select * from sys.server_triggers`可以查看服务器层面的`DDL Trigger`。

## DML Trigger
### DML Trigger的类型
`DML Trigger`有三种trigger：`AFTER Trigger`,`INSTEAD OF Trigger`和`CLR Trigger`.
- `After Trigger`是在`INSERT, UPDATE, MERGE, DELETE`语句运行后触发的触发器。如果发生`constraint`, 这个trigger是不会触发的。
- `INSTEAD OF trigger`覆盖标准的触发器语句，所以可以用来处理错误或者在`insert, update, delete`之前做数值检查。这个触发器主要的两个优势是能让不能修改的视图支持更新，另一个优势是可以让你的批处理部分处理成功，部分处理失败。
- `CLR Trigger`

AFTER触发器和INSTEAD OF触发器的区别:
<img src="{{site.baseurl}}/assets/images/2021-02/comparison of after&instead of trigger.png"/>

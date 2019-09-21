---
layout: post
title: AMQP-0-9-1模型总结
categories: [middleware]
description: 
keywords: rabbitmq
catalog: true
multilingual: false
tags: rabbitmq,amqp
updated_at: 2019-08-04 18:30:00 +0000
---

## AMQP-0-9-1模型
`AMQP(Advanced Message Queue Protocol`模型很简单, 就是`publisher`将消息发给`exchanger`中间人, 然后`exchanger`中间人按规则将消息的副本塞入队列中(这个过程叫`binding`), 接着中间人消息推送给订阅队列的消费者`consumer`或者消费者主动去拉取消息.


当发布消息的时候, 发布者可以给消息设置一些消息的元信息, 然后中间人就会使用这些信息作为消息路由的规则.由于网络是不稳定的, `AMQP`有消息确认的概念: 消费者拿到消息后需要通知中间人确认拿到消息, 然后中间人会把队列中的消息删除, 否则中间人会重发消息给另一个消费者(如果存在). 如果消息没有被确认, 同时又不能重发消息(不存在另一个消费者), 那么消息是可以被返回给发送者或者丢弃的. 可以设置`dead letter queue`来处理消息消费失败的情况. 


## `AMQP`是一个可编程协议
`queue/exchange/binding`在`AMQP`中都是实体(entity), 所以`AMQP`的实体/路由规则等是需要应用自己定义实现的. (就是再rabbitmq代码里定义)

### Exchange和exchange类型
`Exchange`接受生产者发送的消息, 然后根据路由规则将消息送给零个或多个队列. 路由规则取决于`exchange type`和`binding`. `AMQP`有4种交换类型:
```
|-----------------+----------------|
| name | default pre-declared names|
|-----------------+----------------|
| direct(default) | (empty string) and amq.direct|
|-----------------+----------------|
| fanout          |  amq.fanout    |
|-----------------+----------------|
| topic           | amq.topic      |
|-----------------+----------------|
| headers         | amq.match(amq.headers in rabbitmq)|
|-----------------+----------------|
```
`headers exchange`用的比较少, 说一下.  这种类型的中间人不使用`routing key`作为路由规则, 而是使用生产者在消息中的头部`x-match`定义的k-v值. 

### 队列
`queue`是存放消息的buffer, 与`exchange`分享一些共同的属性, 同时有一些自己属性可以定义:
- Name
- Durable (survive during restart)
- Exclusive (only use by one consumer)
- Auto-delete (delete when last consumer unsubscribes)
- Arguments (optional, )
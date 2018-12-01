---
layout: post
title: DNS和Route53简介
categories: [cloud]
description: DNS的概念和Route53
keywords: DNS, route53
catalog: true
multilingual: false
tags: cloud
---

## DNS基本概念
DNS(Domain Name Service)是人们使用英特网的基础服务，DNS提供的服务就像一个电话本一样, 计算机可以用它找到域名对应的IP地址。`DNS`采用层级的结构， 不同层采用`.`来分层。顶层是root, 用一个`.`表示，后面就是TLD了。
`Top Level Domain`(TLD)顶级域名是域名中的最后一个部分， 比如`.com`. TLD又分为通用顶级域名和地域顶级域名如`.cn`. `Internet Corporation for Assigned Names and Numbers`(ICANN)
负责管理和分配部分顶级域名， 这些顶级域名下可以再分配我们常见的域名，这些域名会在`Network Information Center`(InterNIC)注册， 每个域名会在一个叫`Whois`的数据库注册， 以维护域名的唯一性。
这里有一个误区，域名如`example.com`, 一般所说的二级域名是应该是`example`(而国内的运营商叫做一级域名, .com叫顶级域名)， 其他的二级域名/三级依次往后叫.

### host和Subdomain
有了域名， 域名拥有者可以把自己的服务或主机定义成`host`, 比如大部分的web服务都可以通过`www`这个`host`访问。
`TLD`是可以被按层级扩展成多个子域名的。如`example.com`中`example`就是`SLD`(Second-level domain), 又如`sina.com.cn`中`.com`是`SLD`. `SLD`和`host`主要的区别在于host定义的是一个资源，
而`SLD`是一个域名的扩展。不管是`SLD`还是`host`, 我们都从域名的左边读起， 可以看到越左边的部分意义越具体。

### Name Server
名字服务器就是实际把域名解析成Ip的服务器。由于域名实在太多，名字服务器需要转发解析请求到其他服务器。如果某个域名是这台名字服务器管理的， 那么这个NS的解析相应我们认为是权威的。（`authoritative`）

### Zone file
`zone file`区域档案是DNS服务器存储域名和IP映射记录的文本。一个`zone file`定义了一个dns域, 多个`zone file`通常用来定义一个域。每个文件中的记录称为资源记录（`resource record`）。
`zone file`有两个指令需要注意， 一个是`$ORIGIN`参数设定， 代表了本NS管理的域。`$TTL`表示解析记录在缓存中默认过期时间。

### DNS Record Types
- `SOA Start Of Authority`, 每个区域文件的一条强制记录， 记录每个域的dns基本信息，具体包括：
  - 这个区域的DNS server名称
  - 这个区域的管理员
  - 当前文件的版本
  - 二级域名服务器重试、更新、过期信息的时间设置
  - RR的TTL默认时间
- `A` and `AAAA`. `A`把一个`host`映射到IPv4地址， `AAAA`映射到IPv6地址。
- `CNAME` 别名.可以为你的`A`或者`AAAA`记录映射的服务取别名.
- `MX`(Mail Exchange), 邮件交换主机记录. 此记录是用来宣告一个域底下哪一个`A`记录为专门负责邮件进出. 由于一个网域底下的`MX`记录可以超过一笔, 所以, 在众多`MX`记录里要排列出优先順序就必须倚靠`MX`记录里的另一项设定---`Preference`值, 值越小, 优先权越高, 最小的值为0. 同时`MX`不能指向`CNAME`.
- `NS`(Name Server). 指定哪个`Name Server`可以得到某个域名的权威解析, 用于TLD顶级域名服务器解析会用到.
- `PTR`(Pointer)反向解析, 把IP解析到域名.
- aws还支持一种叫`alias`的record, 指向aws的某个公网服务。

### Fully Qualified Domain Name(FQDN)
按ICANN的标准FQDN是需要按`.`结尾的，虽然通常我们并没有这么做. 具体语法如下图所示
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/fqdn-explained.jpg](https://s3.ap-southeast-1.amazonaws.com/kopei-public/fqdn-explained.jpg)

### 浏览器解析DNS步骤
浏览器输入域名后， 从域名解析到实际的IP, 会走如下步骤：
- 计算机先检查浏览器缓存是否存在， 如果是使用chrome, 可以在地址栏输入`chrome://net-internals/#dns`查看缓存信息。
- 浏览器的缓存有一些限制， 比如缓存的条目数只有1000等等，所以如果不命中缓存， 那么就会查询本地hosts文件是否存在对应的ip。
- 如果还是不中那么检查本地设置的域名解析服务器`Resolving Name Servers`（`/etc/resolv.conf`设置的DNS首选项）缓存是否命中。
- 如果还是没有命中，那么就会查询`Resolving Name Servers`(通常是ISP供应商提供)。后续还会往root服务器迭代查询， root服务器又会重定向到TLD服务器，TLD再重定向到`Domain-Level Name Servers`等等。 但是基本上是本地设置的DNS服务器帮助用户做了和上层服务的交互。
下图很好解释流整个dns解析流程.
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-10-28%20%E4%B8%8B%E5%8D%887.51.42.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-10-28%20%E4%B8%8B%E5%8D%887.51.42.png)

### Route53提供的服务
Route53提供三个服务：域名注册，DNS服务，健康检查。

### 使用Route53和其他服务提高系统韧性
1. 每个区域有一个负载均衡器， 均衡器下的服务器分布在不同可用区。
2. 每个可用区都需要是自动伸缩。
3. 负载均衡器需要设置健康检查。
4. 每个负载均衡器上面是Route53， Route53设置别名记录`alias record`指向每个负载均衡器， 同时设置路由规则采用最小延时规则， 开启每个均衡器的健康检查。
5. 所有静态和动态内容使用CDN缓存。



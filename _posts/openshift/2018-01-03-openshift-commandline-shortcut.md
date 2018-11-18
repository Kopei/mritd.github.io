---
layout: post
title: Openshift Commandline CheatSheet
categories: [openshift, kubernetes]
description: 
keywords: openshift
catalog: true
multilingual: false
tags: kubernetes, openshift
---

#### 创建新的project
`oc new-project postgres --display-name='postgres' --description='postgres'`
#### 切换project
`oc project myproject`
#### 删除project
`oc delete project myproject`

#### 创建资源. 从json(yml)生成一个OpenStack可以用模板。
```bash
    oc create -f Filename.json(.yml)
    oc process -f file.json|oc create -f -  ##处理模板生产构建配置，然后创建资源
```

#### 创建app， 就是部署
```bash
oc new-app (IMAGE | IMAGESTREAM | TEMPLATE | PATH | URL ...) [options]
oc new-app --name=dbinit --strategy=docker https://github.com/devops-with-openshift/liquibase-example.git  ##将会从这个仓库拉代码，build on Dockerfile
```
#### 取消一个正在构建的app
`oc cancel-build buildname`

#### 修改一个资源的配置
```bash
oc patch dc postgresql -p '{"spec":{"strategy":{"type":"Recreate"}}}'
```

#### 设置应用配置
```bash
oc set env dc postgresql POSTGRESQL_ADMIN_PASSWORD=password
```

#### 从docker镜像仓库导入最新的镜像信息
```bash
oc import-image docker.io/busybox:latest --confirm ##把上游的镜像仓库镜像加入本地命名空间
```

#### 展示资源的信息
```bash
oc get pods #展示pod资源的信息
oc get rc redis  #展示replication controller
oc get -o wide pods  #展示详情
oc get -o template pod myapp --template={{ .currentState.statusn }}
```

#### 设置trigger配置
```bash
oc set triggers dc/registry --auto
oc set triggers bc/webapp --from-webhook
oc set triggers bc/webapp --from-imagej=namespace/image:latest
```
#### 将模板转化为资源
`oc process -f template.json| oc create -f -`

#### 导出资源，用于其它地方使用
```bash
oc export service -o json  # 导出资源为json
oc export svc --as-template=test # 导出所有服务，作为模板
oc export Resource -l name=test # 导出资源，打上标签
```

#### pod同步容器内外文件
`oc rsync dir POD:dir`

#### 查看pod日志
`oc logs $(oc get pods -l name=cats -o name)`

#### 开启一个容器的shell
```bash
   oc get pods
   oc rsh mypod
```

#### 简写对应
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-01-03%20%E4%B8%8B%E5%8D%883.07.32.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-01-03%20%E4%B8%8B%E5%8D%883.07.32.png)


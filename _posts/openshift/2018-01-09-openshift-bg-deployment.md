---
layout: post
title: OpenShift Blue-Green Deployment
categories: [openshift, kubernetes]
description: 
keywords: openshift
catalog: true
multilingual: false
tags: kubernetes, openshift
---

### OpenShift的蓝绿部署
使用`oc patch route`切换路由
```bash
oc new-project bluegreen --display-name="Blue Green Deployments"  --description="Blue Green Deployments"
oc new-app https://github.com/devops-with-openshift/bluegreen#master  --name=blue
oc expose service blue --name=bluegreen #注意route的名称
oc new-app https://github.com/devops-with-openshift/bluegreen#green  --name=green
##切换
oc patch route/bluegreen -p '{"spec": {"to":{"name":"green"}}}'
```

### 蓝绿最佳适用场景
无状态的服务实现蓝绿部署较为轻松， 因为不需要考虑旧实例的长事务和数据的迁移和回滚。



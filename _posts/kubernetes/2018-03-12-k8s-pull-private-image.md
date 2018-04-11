---
layout: post
title: K8S使用私有镜像
---

> [https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account)
### 前言
如果想要k8s能够拉取使用私有镜像需要创建secret, 然后有两种方法指定secret, 拉取image。 一是在pod的编排模板指定`imagePullSecret`, 二是修改`service account`的配置，本文讲述第二种方法。

### 第一步 创建imagePullSecret
```yml
$ kubectl create secret docker-registry myregistrykey --docker-server=DOCKER_REGISTRY_SERVER --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL
secret "myregistrykey" created.

$ kubectl get secrets myregistrykey
NAME             TYPE                              DATA    AGE
myregistrykey    kubernetes.io/.dockerconfigjson   1       1d
```
如果是使用aliyun的私有镜像，`docker-server`可是设置成vpc的server地址，这样省一点流量。

### 第二步 修改serviceaccount
```yml
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "myregistrykey"}]}'
```
完成！

---
layout: post
title: K8S的StatefulSets
categories: [kubernetes]
description: k8s的有状态副本集
keywords: kubernetes
catalog: true
multilingual: false
tags: kubernetes
update_date: 2018-03-08
---

## 前言
K8S的StatefulSets是一个负载API对象用于管理有状态的应用。StatefulSets会给每个pod维护一个独特的标记， 所以这些pods是不能交换的。
注意，V1.9才是稳定版本， 可以通过apiserver发送`--runtime-config`禁用这个控制器。

## 应用场景
StatefulSets适合如下应用场景：
- 稳定、唯一的网络标识
- 稳定、持久的存储
- 有序的部署和扩展
- 有序的删除和终止
- 有序的自动化滚动更新
如果不需要持久化，应该考虑Deployment或ReplicaSet控制器.

## 局限
- 版本1.9
- 如果是给pod提供存储，那么必须预先配置好PV, 或者通过PersistentVolume Provisioner提供
- 删除或者向下缩减StatefulSet并不会删除相应的volume, 出于安全考虑。
- 需要创建一个Headless Service（clusterIP: None）负责pods的网络标识

## StatefulSet的组件
下面这个例子创建一个无头的service, 一个有状态的pod，挂载在声明模板的PV.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx # has to match .spec.template.metadata.labels
  serviceName: "nginx"
  replicas: 3 # by default is 1
  template:
    metadata:
      labels:
        app: nginx # has to match .spec.selector.matchLabels
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "my-storage-class"
      resources:
        requests:
          storage: 1Gi
```

## Pod Identity
StatefulSets有一个唯一的identity，由有序的（由0开始分配给pod），稳定的网络标识符和稳定的存储组成。pod更换node也不会改变这个id。
- 序号从0开始
- 稳定的网络ID, StatefulSets中pod的主机名由`$(statefulset name)-$(ordinal)`规则组成，所以上述yml文件中，pods的名称分别web-0,web-1,web-2； 而StatefulSets的域名则为`$(service name).$(namespace).svc.cluster.local`；pod的域名则为`$(podname).$(governing service domain)`，`$(governing service domain)`是`serviceName`. 见下图：
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-03-07%20%E4%B8%8B%E5%8D%883.31.13.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-03-07%20%E4%B8%8B%E5%8D%883.31.13.png)

## 更新StatefulSet
1.7版本以后，StatefulSet控制器支持自动更新。更新策略取决于StatefulSet对象的`spec.updateStrategy`字段，这个功能可以用于更新容器镜像，
资源用量，标签，pods的注释(如果改了其它设置，就需要删除statefulsets重新create), 1.9支持`RollingUpdate`和`OnDelete`两种更新策略。
- `RollingUpdate`将会把statefulset的pods按倒叙更新。首先让updateStrategy使用rollingupdate
```bash
kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate"}}}'
statefulset "web" patched
```
  然后更换pod的image， 这个过程中，pod将倒序终止，再更新。如果某个pod更新失败，将会对整个statefulsets做回滚。
  ```bash
    kubectl patch statefulset web --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image",    "value":"gcr.io/google_containers/nginx-slim:0.8"}]'
    statefulset "web" patched
  ```
  可以使用`kubectl rollout status sts/<name>`查看更新状态。这个策略有一个属性`partition`可以用于**分段**更新，就是制定更新一部分pods,
  使用这个特性，就可以进行金丝雀测试（灰度）。
  ```bash
     kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":3}}}}'
     statefulset "web" patched
  ```

## 删除StatefulSet
简单删除命令：
```bash
kubectl delete -f file.yml
kubectl delete statefulsets <statefuleset_name>
```
如果想要保留pods，可以使用参数`--cascade=false`

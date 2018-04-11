---
layout: post
title: Kubernetes Deployment
---

### k8s的部署控制器Deployment
k8s的`Deployment`提供了`pods`和`ReplicaSets`的更新.
只需在Deployment对象声明你想要的部署状态, `Deployment`控制器就会更新到需要的状态.所以这种方式是声明式的.
除非第一次部署,k8s采用的部署方式是rolling update(滚动更新). 大致意思是保证服务可用的情况下, 创建一定量的新pods,然后删除一定量的pods,循环这些步骤直到部署完成.

### 一个例子
```
---
apiVersion: apps/v1beta2 # for versions before 1.8.0 use apps/v1beta1
kind: Deployment   # apiVersion, kind, metadata, spec这四个字段必须要
metadata:
  name: appweb
spec:
  selector:
    matchLabels:  # 多个label做and处理. 部署时会自动加一个hash label, 用于区分部署版本
      app: appweb
      tier: backend
      version: 1.0
  replicas: 2
  template:
    metadata:
      labels:
        app: appweb
        tier: backend
        version: 1.0
    spec:
      containers:
      - name: app
        image:  registry-vpc.cn-shanghai.aliyuncs.com/web1.0
        env:
          - name: app_WEB_DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: appsecrets
                key: app_WEB_DATABASE_URL
          - name: WORKER_PROCESSES
            value: "2"
          - name: JOB_WORKER_URL
            value: "redis://redis-master:6379/0"
          - name: RAILS_ENV
            value: "production"
          - name: REDIS_CACHE_URL
            value: "redis://redis-master:6379/1"
        ports:
          - containerPort: 7007
        volumeMounts:
          - name: app-pvc
            mountPath: "/app/public/"
        livenessProbe:
          httpGet:
            path: /login
            port: 7007
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 3
        readinessProbe:
          httpGet:
            path: /login
            port: 7007
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 3
      volumes:
        - name: app-pvc
          persistentVolumeClaim:
            claimName: app-pvc

```
### 部署时需要注意的地方:
- Deployment的模板使用label来找到对应的容器, 所以不建议修改label.如果必须修改请看[label selector update](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#label-selector-updates)
- 在一个deploy过程中如果再进行另一个deploy,那么之前那个deploy的pod会立刻删除.
- 每次部署都会创建一个部署版本, 如果部署完后又进行扩展(scale), 那么此时进行rollback将不会回滚扩展的部分.因为rollback只会根据(.spec.template)指定来回滚. 可用在每次更新部署的时候,指定`--record`把部署命令记录到部署更新版本记录里.
- 查看部署历史`kubectl rollout history deployment/appweb`, 可以指定具体版本号`kubectl rollout history deployment/appweb --revision=2`
- 回滚到上一个版本命令`kubectl rollout undo deployment/appweb`

### 使用金丝雀(灰度)部署
k8s的金丝雀部署其实就是在现有的版本上再部署只有一个pod的新deployment,用另一个label来区别两个deployment.
并把这个新的pod加入原来的service.代码概要如下:
```
apiVersion: apps/v1  # old deployment
kind: Deployment
metadata:
  name: app-production
spec:
  selector:
    matchLabels:
      env: production
      app: web
      .....
---
apiVersion: v1
kind: Service
metadata:
  name: app-Service
spec:
  selector:
    app: web
.....
```
```
apiVersion: apps/v1 # new deployment
kind: Deployment
metadata:
  name: app-canary
spec:
  selector:
    matchLabels:
      app: web
      env: canary
      .....
```
如果发布测试没有问题, 那么可以直接运行`kubectl set image deployment/app-production registry-vpc.cn-shanghai.aliyuncs.com/web2.0`滚动更新, 然后删除金丝雀部署.

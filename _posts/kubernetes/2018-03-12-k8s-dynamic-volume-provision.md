---
layout: post
title:
---
> [https://v1-8.docs.kubernetes.io/docs/concepts/storage/dynamic-provisioning/](https://v1-8.docs.kubernetes.io/docs/concepts/storage/dynamic-provisioning/)

### 前言
动态卷配置允许按需创建存储卷。如果没有动态配置，管理员必须手动配置创建新的存储， 然后创建PV对象。动态卷配置的功能能让管理员不必预先配置存储。
而是当用户需要的时候自动配置存储。它可以按用户需要的用量配置存储空间，不像静态那样可能出现超额分配用量。

### 背景
动态配置数据卷的实现是基于`StorageClass`API对象。管理员可以配置很多`StorageClass`对象，每一个都可以指定一个存储供应商。管理员可以给一个
集群定义和暴露多个存储，每一个都有不同的参数配置。这样能减轻配置存储的复杂度，使用户简单选择存储服务。

### 开启动态配置数据卷
- 首先需要创建StorageClass对象, 可以指定使用哪个供应商和那些参数，如下例：
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
```

如果使用aliyun的NAS作为provisioner, 需要先安装aliyun nas的插件
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: alicloud-nas
provisioner: alicloud/nas
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: alicloud-nas-controller
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: run-alicloud-nas-controller
subjects:
  - kind: ServiceAccount
    name: alicloud-nas-controller
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: alicloud-disk-controller-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: alicloud-nas-controller
  namespace: kube-system
spec:
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: alicloud-nas-controller
    spec:
      tolerations:
      - effect: NoSchedule
        operator: Exists
        key: node-role.kubernetes.io/master
      - effect: NoSchedule
        operator: Exists
        key: node.cloudprovider.kubernetes.io/uninitialized
      nodeSelector:
         node-role.kubernetes.io/master: ""
      serviceAccount: alicloud-nas-controller
      containers:
        - name: alicloud-nas-controller
          image: registry.cn-hangzhou.aliyuncs.com/acs/alicloud-nas-controller:v1.8.4
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: alicloud/nas
            - name: NFS_SERVER
              value: 0cd8b4a576-mmi32.cn-hangzhou.nas.aliyuncs.com  # 指定创建的NAS挂载点
            - name: NFS_PATH
              value: /
      volumes:
        - name: nfs-client-root
          nfs:
            server: 0cd8b4a576-mmi32.cn-hangzhou.nas.aliyuncs.com   # 指定创建的NAS挂载点
            path: /
```

### 使用动态配置数据卷
用户需要在PVC指定`StorageClassName`, 如下
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim1
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 30Gi
```

### 设置默认动态配置
如果有个用户在`PersistentVolumeClaim`没有指定`storageClassName`， 那么可以配置默认的`storageClassName`使用。具体是在创建的`storageClassName`中annotation
`storageclass.kubernetes.io/is-default-class`




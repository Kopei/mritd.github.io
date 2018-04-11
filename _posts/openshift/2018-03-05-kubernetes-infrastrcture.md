---
layout: post
title: Openshift中Kubernetes的基础设施
update_date: 2018-03-07
---

## 前言
主要是从Openshift Origin的[Doc](https://docs.openshift.org/latest/architecture/infrastructure_components/kubernetes_infrastructure.html#master-components)看到的, 对应k8s 1.7. 加上官网的Doc. 

## Masters
masters上的组件含有API server, controller manager server和etcd(可以单独host)。 master管理k8s集群中的nodes，调度节点上的pods.
- API server. 可以是一个独立的进程运行。API server验证和配置pods、services和replication controller; 分配pods到节点，根据service的配置同步pod的信息。
- ETCD. 存储主机的状态， 其他组件查看etcd的动态，使自身做相应状态变化。ETCD使用RAFT算法，所以最后以2n+1来部署。
- Controller Manager Server. 这个服务可以是单个进程，如果是多个进程那么就只有一个leader.
  - 监控etcd的复制状态变化，然后调用API做到相应的复制改变; 
  - node控制器， 监控节点是否健康。
  - endpoints控制器，控制endpoint对象植入。
  - 账号和token控制器
- scheduler（openshift 没有提到），k8s官网写了。scheduler用于还未在node创建的pod监控，然后调度一个node让pod运行。scheduler会考虑资源的各种要求，包括：软硬件，策略限制，affinity and anti-affinity specifications，数据地区，内部负载影响和期限。
- HAProxy. 如果master是HA, 默认采用HAProxy作为master api server负载均衡器. 当然也可以选择自定义的。
- cloud-controller-manager。 用于和云供应商服务交互，云供应商有如下服务：
  - 节点控制器
  - 路由控制器
  - 服务控制器（k8s service)
  - 卷控制器
## Nodes
节点提供容器的运行环境。每个节点都运行着master管理需要的服务和pods运行需要的服务（具体有Docker, kubelet, service proxy)
Node对象定义
```yaml
apiVersion: v1 
kind: Node 
metadata:
  creationTimestamp: null
  labels: 
    kubernetes.io/hostname: node1.example.com
  name: node1.example.com 
spec:
  externalID: node1.example.com 
status:
  nodeInfo:
    bootID: ""
    containerRuntimeVersion: ""
    kernelVersion: ""
    kubeProxyVersion: ""
    kubeletVersion: ""
    machineID: ""
    osImage: ""
    systemUUID: ""
```

### Nodes中的Kubelet
其实是一个agent. kubelet用来通过manifest控制node的container健康运行， kubelet不会管理不是k8s创建的容器。 container manifest是一个描述pod的yaml文件。manifest可以通过4种方式提供给kubelet:
- 命令行指定的文件地址
- Http endpoint
- 监控etcd服务
- kubelet作为http服务，监听http请求，提交新的manifest

### Nodes中的service proxy
每一个节点有一个简单的网络proxy, 能够让TCP或UDP把流量导向后端pods

### Nodes中的Addons附加插件
Addons(小怪？)是实现集群功能的pods和service， 还有一些其他附加功能. addon对象在kube-system创建，它们是有命名空间的。
- DNS. Kubernetes的服务需要DNS服务器， 被k8s启动的容器会自动包含dns服务器
- UI界面
- Container Resource Monitoring
- Cluster-level Logging

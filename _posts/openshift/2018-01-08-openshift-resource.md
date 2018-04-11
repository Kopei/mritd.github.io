---
layout: post
title: What is OpenShift Resource
---
> Openshift的资源定义类似Rest的资源

### OpenShift中的资源
`oc get -h` 有一行说明`Possible resources include builds, buildConfigs, services, pods, etc. To see a list of common
resources, use 'oc get'.`. 所以任何构建，构建配置，服务，pod都是OpenShift的资源。由于Kubernetes采用Restful的架构，所以用rest的角度看待OpenShift资源应该更加合适，一个资源就是一个对象，有对应的类型、数据、和其它资源的关系，一组标准HTTP方法. 资源和OOP的对象类似，但是只有特定GET, PUT,POST等这几个标准HTTP方法。

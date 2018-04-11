---
layout: post
title: 三种docker数据持久的方式
---

### docker提供三种方式把数据挂载到容器
- volumes
volumes是宿主机上docker管理的文件系统， 比如在/var/lib/docker/volumes/。 一个volume可以同时被多个容器挂载。使用`docker volume create --driver`
可以指定远程的文件系统。
- bind mounts
宿主机其他任意不是docker管理的文件系统
- tmpfs
tmpfs是挂载在宿主机的内存中，可以用于临时挂载非持久化数据，比如secret. --tmpfs
docker17.08以后可以考虑使用--mount同一参数


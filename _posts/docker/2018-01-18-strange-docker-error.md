---
layout: post
title: 一次奇怪的Docker Daemon Error
---

### 前言
环境：
```bash
cat /etc/centos-release
CentOS Linux release 7.1.1503 (Core) 
ansible --version
ansible 2.3.1.0
  config file = /etc/ansible/ansible.cfg
  configured module search path = Default w/o overrides
  python version = 2.7.5 (default, Aug  4 2017, 00:39:18) [GCC 4.8.5 20150623 (Red Hat 4.8.5-16)]
```

### 问题出现
用ansible安装部署docker时发现有容器一直起不来。安装的docker daemon是按docker官网[https://docs.docker.com/engine/installation/linux/docker-ce/centos/#install-docker-ce](https://docs.docker.com/engine/installation/linux/docker-ce/centos/#install-docker-ce)安装的，然后log发现报错`Error response from daemon: OCI runtime create failed: unable to retrieve OCI runtime error`。

### 排查
搜索查看[issue](https://github.com/moby/moby/issues/35972),发现是安装的docker-ce版本太新!而centos太旧，Centos7.1选择docker-ce-17.06.3.ce这个版本可用，17.12还是太新！
```bash
docker info
Server Version: 18.01.0-ce
Storage Driver: devicemapper
```

### 措施，其他问题再现
卸载docker-ce, 重新安装。然后发现容器还是起不来！
尝试删除/var/lib/docker, 报错
```bash
error: driver \"devicemapper\" failed to remove root filesystem for 6f009dff997d9fe3f19c736d6dd662d7ff55cea2ec04ac5bba287b83684cac5b: remove /var/lib/docker/devicemapper/mnt/0efe8e6bc86a2ff1e1877979275c36d119995043ce231aeed661c15d26873692: device or resource busy
```

### 解决
看看到底是mount到其它什么地方了
```bash
find /proc/*/mounts | xargs grep  0efe8e6bc86a2ff1e187797927
grep: /proc/1449/mounts: No such file or directory
/proc/7280/mounts:/dev/mapper/docker-8:6-67114038-0efe8e6bc86a2ff1e1877979275c36d119995043ce231aeed661c15d26873692 /var/lib/docker/devicemapper/mnt/0efe8e6bc86a2ff1e1877979275c36d119995043ce231aeed661c15d26873692 xfs rw,relatime,nouuid,attr2,inode64,logbsize=64k,sunit=128,swidth=128,noquota 0 0

ps 7280
  PID TTY      STAT   TIME COMMAND
  7280 ?        Ssl    0:03 /usr/libexec/colord

kill -9 7280 
yum install -y docker-ce-17.06.3.ce 
systemctl start docker
```






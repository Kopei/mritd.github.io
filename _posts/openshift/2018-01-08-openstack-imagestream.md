---
layout: post
title: OpenStack ImageStream
---

### OpenShift的Image Stream
按照官方的解释[mage stream](https://docs.openshift.com/enterprise/3.1/architecture/core_concepts/builds_and_image_streams.html#image-streams)一个镜像流是一组tag的镜像. 这些镜像可以是来自：
- openshift的私有镜像
- 其它镜像流
- 外部镜像仓库
OpenShift的build,deployment组件可以监控image stream. 用于触发新的build或者deploy

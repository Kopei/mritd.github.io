---
layout: post
title: 使用Docker Cloud自动化部署
categories: [docker]
description: 最新消息，似乎免费的构建服务已经下线了
keywords: docker 
catalog: true
multilingual: false
tags: docker
---

### Docker cloud介绍
Docker cloud有点像云上的jenkins docker自动化构建部署工具，可以把云上的git仓库，部署的节点虚机整合在一起，做到提交代码就可以自动构建，测试，部署。

### 例子: 设置aliyun作为部署节点
docker cloud可以结合github, bitbucket仓库做到每次有新的pull request都进行一次重新构建。但是由于我本地直接用pycharm结合docker remote进行开发，所以开发测试完，我的image也已经构建好，所以我没有把git仓库和docker cloud整合，而是直接push到docker hub private repo。然后设置aliyun作为部署节点，当有image更新时自动重新部署。
- 设置aliyun node
  - 选中图中Infrastructure下的`Node`选项
  ![node1](http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-02%20%E4%B8%8B%E5%8D%883.37.46.png)
  - 点击`bring your own node`, 将截图中脚本在aliyun的虚机上运行。**注意**！！这里虚机必须没有安装过docker daemon. 同时安全组开通6783/tcp，6783/udp和2375/tcp端口。
  ![node2](http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-02%20%E4%B8%8B%E5%8D%883.45.39.png)
  - 等待5分钟，查看timeline, 直到log显示下图，正确部署节点。
  ![node3](http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-02%20%E4%B8%8B%E5%8D%883.49.11.png)
  **注意**！！由于cloud.docker.com是在aws上，当中可能网络timeout,导致部署失败。这就需要删除dokcercloud-agent, 重新安装。
  ```bash
     yum remove dockercloud-agent
     rm -rf /etc/docker
     rm -rf /etc/dockercloud-agent
  ```
- 设置自动部署service
  - 从hub仓库中创建一个service, 设置成auto redeploy. **注意**当前只支持image的latest tag自动重新部署。
  ![http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-02%20%E4%B8%8B%E5%8D%884.14.04.png](http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-02%20%E4%B8%8B%E5%8D%884.14.04.png)
  - 选中AUTOREDEPLOY， 其他可以默认设置。
  ![http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-02%20%E4%B8%8B%E5%8D%884.14.35.png](http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-02%20%E4%B8%8B%E5%8D%884.14.35.png)

- 重新push image, 测试是否设置成功，在service的timeline应该看到如下截图，说明设置成功。
  ![http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-02%20%E4%B8%8B%E5%8D%884.16.47.png](http://p0iombi30.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-02-02%20%E4%B8%8B%E5%8D%884.16.47.png)

### 总结 
这里只是简单介绍一下docker cloud的应用。还有一些其他功能比如swarm等商业功能没有触及，但是总体感觉docker越来越商业化。
---
layout: post
title: OpenShift A/B Deployment
---

### OpenShift的AB部署
AB test原理就不讲了。直接上代码
```bash
oc new-project cotd --display-name='A/B Deployment Example'  --description='A/B Deployment Example'
oc new-app --name='cats' -l name='cats'  php:5.6~https://github.com/devops-with-openshift/cotd.git  -e SELECTOR=cats
oc expose service cats --name=cats -l name='cats'
oc new-app --name='city' -l name='city'  php:5.6~https://github.com/devops-with-openshift/cotd.git -e SELECTOR=cities 
oc expose srv/city --name=city -l name='city'
```
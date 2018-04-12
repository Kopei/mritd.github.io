---
layout: post
title: OpenShift Annotation
categories: [openshift, kubernetes]
description: 
keywords: openshift
catalog: true
multilingual: false
tags: kubernetes, openshift
---

### OpenShift的Annotation
Openshift的Annotation是一个键值对，用于机器识别等其它用途。它不像label适用于人类识别，所以可以存较大的值。
```bash
oc annotate route/ab haproxy.router.openshift.io/balance=roundrobin
```
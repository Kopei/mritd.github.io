---
layout: post
title: Apollo client的缓存机制
categories: [frontend, apollo]
description: 概要apollo client的`apollo-cache-inmemory`
keywords: apollo
catalog: true
multilingual: false
tags: frontend
---

## Apollo client2.0的缓存实现
`Apollo client2.0`使用`apollo-client-inmemory`作为客户端数据的缓存实现, 主要使用包中的`InMemoryCache`作为`data store`来缓存数据. 除了作为缓存客户端缓存的好处外, 还有一个`InMemoryCache`还有一个好处是当遵循特定的标识符规则, 每次对后端做`mutation`后可以自动跟新缓存.

### `InMemoryCache`的配置
引入cache:
```ecmascript 6
import {InMemoryCache} from 'apollo-client-inmemory';
const cache = new InMemoryCache();
```

`InMemoryCache`的构造器可以有如下配置:
- `addTypename: boolean`是否需要在`document`中添加__typename, 默认为true.
- `dataIdFromObject`, 由于`InMemoryCache`是会`normalize`数据再存入`store`, 具体做法是先把数据分成一个个对象, 然后给每个对象创建一个全局标识符`_id`, 然后把这些对象以一种扁平的数据格式存储. 默认情况下, `InMemoryCache`会找到`__typename`和边上主键`id`值作为标识符`_id`的值. 如果`id`或者`__typename`没有指定, 那么`InMemoryCache`会`fall back`查询`query`的对象路径. **但是我们也可以使用`dataIdFromObject`来自定义对象的唯一表示符**: 

```ecmascript 6
import { InMemoryCache, defaultDataIdFromObject } from 'apollo-cache-inmemory';

const cache = new InMemoryCache({
  dataIdFromObject: object => {
    switch (object.__typename) {
      case 'foo': return object.key; // use `key` as the primary key
      case 'bar': return `bar:${object.blah}`; // use `bar` prefix and `blah` as the primary key
      default: return defaultDataIdFromObject(object); // fall back to default handling
    }
  }
});
```
- `fragmentMatcher`, `fragment matcher`默认使用`heuristic fragment matcher`
- `cacheRedirects`(以前叫`cacheResolvers`, `customResolvers`), 在发出请求之前将查询重定向到缓存中的另一个条目的函数映射。

### 自动缓存更新
假设我们有一个query:
```
{
    post(id: '4'){
        id
        score
    }
}
```
然后我们再做一个mutation
```
mutation {
    updatePost(id: '4'){
        id
        score
    }
}
```
如果保持这个`id`匹配, 每次更新都会自定更新`data store`中`score`字段的数据, 如果query有多个字段, 那么mutation的结果数据尽量要能更新前一次的query, 以利用上诉特点保持cache的数据鲜活.
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
`Apollo client2.0`使用`apollo-client-inmemory`作为客户端数据的缓存实现, 主要使用包中的`InMemoryCache`作为`data store`来缓存数据. `InMemoryCache`除了作为客户端缓存的功能外, 还有一个好处是只有当遵循特定的标识符规则(给缓存加特定的id), 每次对后端做`mutation`后可以自动更新缓存.

### `InMemoryCache`的配置
引入cache:

```javascript
import {InMemoryCache} from 'apollo-client-inmemory';
const cache = new InMemoryCache();
```

`InMemoryCache`的构造器可以有如下配置:
- `addTypename: boolean`, 指定是否需要在`document`中添加__typename, 默认为true.
- `dataIdFromObject`, 由于`InMemoryCache`是会`normalize`数据再存入`store`, 具体做法是先把数据分成一个个对象, 然后给每个对象创建一个全局标识符`_id`, 然后把这些对象以一种扁平的数据格式存储. 默认情况下, `InMemoryCache`会找到`__typename`和边上主键`id`值作为标识符`_id`的值(如`__typename:id`). 如果`id`或者`__typename`没有指定, 那么`InMemoryCache`会`fall back`查询`query`的对象路径. **但是我们也可以使用`dataIdFromObject`来自定义对象的唯一表示符**: 

```javascript
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
如果保持这个`id`匹配, 每次更新都会自定更新`data store`中`score`字段的数据, 如果query有多个字段, 那么只要mutation的结果数据尽量保持更新前一次的query的数据一致, 就可以利用上诉特点保持cache的数据鲜活.

### 和Cache直接交互
可以使用apollo client的类方法直接对cache做读写操作. 方法有: `readQuery`, `readFragment`, `writeQuery`,
`writeFragment`.
- `readQuery`, 从cache中读取数据, 有一个字段没有存在则会报错.
```javascript
const { todo } = client.readQuery({
  query: gql`
    query ReadTodo($id: Int!) {
      todo(id: $id) {
        id
        text
        completed
      }
    }
  `,
  variables: {
    id: 5,
  },
});
```
- `readFragment`, 读取已有数据的片段, 如果某个字段不存在则报错
```javascript
const todo = client.readFragment({
  id: '5',
  fragment: gql`
    fragment myTodo on Todo {
      id
      text
      completed
    }
  `,
});
```
- `writeFragment`和`writeQuery`, 用法和read差不多, 除了需要多一个参数`data`:
```javascript
client.writeFragment({
  id: 'typename:5', //复合键用于表示cache中数据
  fragment: gql`
    fragment myTodo on Todo {
      completed
    }
  `,
  data: {
    completed: true,
  },
});
```

### 忽略cache
有两者情况可能需要绕过缓存, 一种是想直接访问后端然后写入缓存, 另一种是完全不使用缓存(适合敏感信息).
```javascript
client.query({
    query: gql(queries.getUser),
    fetchPolicy: 'network-only'  // 'no-cache'
});
```
### mutation后cache的更新
`refetchQueries`是mutation后更新cache的简单方法, 但是它会从后端再做一次请求而显得不那么优秀. Mutation组件有一个`update`prop可以用于手动更新cache, 而不用重新fetch.
```javascript
import CommentAppQuery from '../queries/CommentAppQuery';

const SUBMIT_COMMENT_MUTATION = gql`
  mutation SubmitComment($repoFullName: String!, $commentContent: String!) {
    submitComment(
      repoFullName: $repoFullName
      commentContent: $commentContent
    ) {
      postedBy {
        login
        html_url
      }
      createdAt
      content
    }
  }
`;

const CommentsPageWithMutations = () => (
  <Mutation mutation={SUBMIT_COMMENT_MUTATION}>
    {mutate => {
      <AddComment
        submit={({ repoFullName, commentContent }) =>
          mutate({
            variables: { repoFullName, commentContent },
            update: (store, { data: { submitComment } }) => {
              // Read the data from our cache for this query.
              const data = store.readQuery({ query: CommentAppQuery });
              // Add our comment from the mutation to the end.
              data.comments.push(submitComment);
              // Write our data back to the cache.
              store.writeQuery({ query: CommentAppQuery, data });
            }
          })
        }
      />;
    }}
  </Mutation>
);
```
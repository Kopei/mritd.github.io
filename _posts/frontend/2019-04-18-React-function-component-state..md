---
layout: post
title: React函数式组件的状态
categories: []
description: 使用recompose或hooks可以让无状态函数带有状态
keywords: hooks, hoc, function component
catalog: true
multilingual: false
tags: React, hooks
---

## React无状态组件
React的`Component`分为有状态的`class component`和无状态的`function component`, `class component`的好处是可以完全控制组件的生命周期, 坏处是写起来麻烦. `function component`的好处是可以使用高阶函数式的编程方式编写代码, 缺点是没有状态可以控制.所以一般需要状态初始化或者其他一些状态操控时, 以前可以用[recompose](https://github.com/acdlite/recompose), 使用HOC让组件带有状态, 但是后来这个库的作者加入了React团队, v16.8版本后, 我们应该使用[Hooks](https://reactjs.org/docs/hooks-overview.html)来管理组件状态和生命周期.

### recompose和hooks写法对比
使用recompose给组件设置状态及其他类似`componentDidMount`的功能时, 需要先定义好相应的状态和生命周期函数, 然后compose进组件:
```javascript
const { Component } = React;
const { compose, lifecycle, branch, renderComponent } = Recompose;

const withUserData = lifecycle({
  state: { loading: true },
  componentDidMount() {
    fetchData().then((data) =>
      this.setState({ loading: false, ...data }));
  }
});

const enhance = compose(
  withUserData
);

const User = enhance(({ name, status }) =>
  <div className="User">{ name }—{ status }</div>
);

const App = () =>
  <div>
    <User />
  </div>;
```
而如果使用`Hooks`那么改写起来方便一点.
```javascript
import React, {useState, useEffect} from 'react'
const User = ({name, statue}) =>{
    const [loading, toggleLoading] = useState(true); //set default loading=true
    useEffect( () =>{
        fetchDate().then((data) => loading = false) ; //useEffect替代componentDidMount, 主要不会合并状态!
    }
    return (<div className="User">{ name }—{ status }</div>)
    }
    
const App = () =>
  <div>
    <User />
  </div>;
}
```
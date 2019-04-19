---
layout: post
title: D3-selection总结
categories: [frontend]
description: D3的特点是让数据和DOM绑定, 然后使用数据驱动的方式进行各种变换. 如何将数据和selection绑定是本节的关注点.
keywords: D3
catalog: true
multilingual: false
tags: D3, data-driven
---

## 什么是D3.selections?
`D3`的selection概念其实很简单, 就是一组元素节点. 具体代码表达就是`d3.selectAll('div')`, 所有选中的`div`就是selection. 然后基于这个selection就可以做各种操作.

### D3-selection
在selection上我们可以做到操作有: 
- 设置属性attribute
- 设置样式
- 设置属性property
- 修改HTML或text内容
- 等等...
使用`data join`的`enter`和`exit` selections, 我们可以增删数据对应的元素.
selection的方法返回一般是当前selection的副本, 或者一个新的selection, 这样能使用链式方法的形式给选中的selection做相应的处理.
selection是不可变的`immutable`, 但是元素是可变的.

### D3-join 方法
- `selection.data([data[,key]])`: 将指定的数据和选中的元素进行绑定, 返回一个新的selection. `data`可以是任意值(数字或对象)的数组, 或者是一个返回一组矩阵的函数. 当一个数据绑定到元素时, 数据将会绑定在元素的`__data__`property, 这样再次select的时候,数据仍旧保持绑定.
 
数据会被分配给selection中的每个组, 如果selection有多个组(如d3.selectAll...selectAll), 那么数据应该被函数的形式指定.
`data`方法中含有一个`key`参数可以用来指定data中的数据按什么方式绑定到元素, 默认不加参数采用按索引位置顺序一一绑定.一个例子:
```javascript
<div id="Ford"></div>
<div id="Jarrah"></div>
<div id="Kwon"></div>
<div id="Locke"></div>
<div id="Reyes"></div>
<div id="Shephard"></div>

var data = [
    { name: 'Locke', number:14 },
    { name: 'Ford', number: 53 },
    { name: 'Kwon', number: 3 },
    { name: 'Shephard', number: 38 },
    { name: 'Reyes', number: 18 },
    { name: 'Jarrah', number: 88 }
]

d3.selectAll("div")
    .data(data, function (d) {
        return d ? d.name : this.id
    })
    .text(function (d) {
        return d.number;
    });
```
上面这个例子达到的效果是让每个元素的text按`div`的`#id`顺序展示数字.

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
`D3`的selection概念其实很简单, 就是一组元素节点. 具体代码表达就是`d3.selectAll('div')`, 所有选中的`div`就是selection,有的翻译叫它`选择集`, 然后基于这个selection就可以做各种操作.

### D3-selection
在selection上我们可以做到操作有: 
- 设置属性attribute
- 设置样式
- 设置属性property
- 修改HTML或text内容
- 等等...

在绑定数据后返回的新selection上使用`data join`的`enter`,`exit`, `append`,`remove`, 我们可以**增删改**数据对应的元素.
selection的方法返回一般是当前selection的副本, 或者一个新的selection, 这样能使用链式方法的形式给选中的selection做相应的处理.
selection是不可变的`immutable`, 但是元素是可变的.

### D3-join 方法
- `selection.data([data[,key]])`: 将指定的数据和选中的元素进行绑定, 返回一个新的selection. `data`可以是任意值(数字或对象)的数组, 或者是一个返回一组矩阵的函数. 当一个数据绑定到元素时, 数据将会绑定在元素的`__data__`property, 这样再次select的时候,数据仍旧保持绑定.
 
  `data`数据是会被分配给selection的每个组, 如果selection有多个组(如d3.selectAll...selectAll), 那么data参数应该以函数的形式指定. 如下图所示一个selection对象`_groups`数组中有多个对象.
  ![https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-04-22%20at%2010.16.51.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-04-22%20at%2010.16.51.png)

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
  上面这个例子达到的效果是让每个元素的text按`div`的`#id`和`data`映射的关系来展示展示数字.结果如下:
  ```
  53
  88
  3
  14
  18
  38
  ```
  `update`和`enter`的selections以数据的顺序返回, 而`exit`selection保留原来的selection顺序.
  如果`data`方法不传入参数, 方法返回选中元素的数据数组.
  
- `selection.join(enter[,update][,exit])`: 给绑定的数据做对应的增加/移除/排序元素操作, 返回**合并**的`enter`/`update`selection. 想要更加颗粒度地控制join中的是三个操作, 可以显式地传入`enter, update, exit`方法来控制元素:
  ```javascript 
  svg.selectAll("circle")
  .data(data)
  .join(
    enter => enter.append("circle").attr("fill", "green"),
    update => update.attr("fill", "blue")
  )
    .attr("stroke", "black");
  ```

- `selection.enter()`: 返回`enter selection`. 什么是`enter selection`呢? 其实就是数据多于元素的情况下, 需要预留位置新给元素.而这个预留的`palceholder`就是返回值. 在使用`data()`函数后, 当前selection对象会增加`_enter`和`_exit`属性,
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-04-22%20at%2013.54.46.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-04-22%20at%2013.54.46.png)
如上图所示, 绑定数据后,`_enter`的值是`EnterNode`数组, 这时候使用`enter()`就会进入`_enter`属性(就是返回`enter selection`了), 把还没有找到DOM的数据找出来调用`append()`生成最终需要生成的DOM.如下图所示, 调用`append`后,最终要多余生成的`rect`就生成了.
![https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-04-22%20at%2014.00.17.png](https://s3.ap-southeast-1.amazonaws.com/kopei-public/screen_shot%202019-04-22%20at%2014.00.17.png)

- `selection.exit()`: 返回`exit`selection, 就是返回那些没有数据可以再绑定的元素.
- `selection.datum([value])`: 读取或设置选中的selection的__data__.
  ```
  d3.selectAll('div').datum(33).text(d=>d)  //所有的div渲染成33
  ```
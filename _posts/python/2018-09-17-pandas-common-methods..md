---
layout: post
title: Pandas的常用函数
categories: [python]
description: 常用方法
keywords: python, pandas
catalog: true
multilingual: false
tags: python, pandas
---


## 前言
`Pandas`有一些常用方法, 可以作为回调函数用于其它函数.


### pandas.DataFrame.reindex
`reindex`方法用于把`DataFrame`按新的索引转化, 同时可选填充空值或者其他方法(如`ffill`, 按前项填充). 默认情况下, 重新索引过的`DataFrame`会复制原来`DataFrame`, 除非索引没有变或者设置`copy=False`.
```python
>>> frame5 = pd.DataFrame(np.arange(9).reshape((3,3)), index=['a','b','c'], columns=['Ohio','Texas','California'])
>>> frame5
   Ohio  Texas  California
a     0      1           2
b     3      4           5
c     6      7           8
>>> frame5 = frame5.reindex(['a','b','c','d'])
>>> frame5
   Ohio  Texas  California
a   0.0    1.0         2.0
b   3.0    4.0         5.0
c   6.0    7.0         8.0
d   NaN    NaN         NaN
```

### 丢弃某些行或列
对于`DataFrame`, 想要删除某行或列是很方便的, 直接通过`drop([])`方法可以实现, 默认删除行, 如果需要删除列, 可以设置参数`axis=1`.
```python
>>> frame5
   Ohio  Texas  California
a   0.0    1.0         2.0
b   3.0    4.0         5.0
c   6.0    7.0         8.0
d   NaN    NaN         NaN
>>> frame5.drop(['a'])
   Ohio  Texas  California
b   3.0    4.0         5.0
c   6.0    7.0         8.0
d   NaN    NaN         NaN
>>> frame5.drop(['Ohio'], axis=1)
   Texas  California
a    1.0         2.0
b    4.0         5.0
c    7.0         8.0
d    NaN         NaN
```

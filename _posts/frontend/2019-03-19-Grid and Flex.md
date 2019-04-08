---
layout: post
title: Grid and Flex Design
categories: [frontend]
description: a short summary about grid and flex design
keywords: grid, flex
catalog: true
multilingual: false
tags: frontend
---

## Flex Background Summary
`Flexbox layout`布局主要提供了一种为容器(`container`)中项目(`item`)布局, 对齐和分布空间的方式. 这种`flex`的布局方式可以不需要知道空间的大小或者动态改变大小.
`Flex`主要的想法是给容器能够灵活地改变容器内项目的高度/宽度/排序, 使其能适应当前的空间.一个`flex`的容器能够把它的项目扩展到多余的空间, 或者收缩大小防止屏幕变小时项目溢出.
`Floxbox`的布局和传统的布局不同, 它不固定排列的方向(而block基于垂直方向, inline基于水平方向).
`Flowbox`布局比较适合组件和小型布局, 而`Grid`适合更大的布局.

## Grid Background Summary
`Grid Layout`是一个二维的布局系统, 既可以处理行又可以处理列. 应用`Grid`CSS的父元素称为`Grid Container`, 子元素称为`Grid Items`.
`implicit grid and explicit grid`隐含和显式网格, 隐含网格指网格项目多出来或者网格项目布局在显式网格外面的情况.

### Grid属性表
Grid 容器的属性:
```
display: grid|inline-grid;
grid-template-columns: <track-size> ... | <line-name> <track-size> ...;
grid-template-rows: <track-size> ... | <line-name> <track-size> ...;
grid-template-areas: "<grid-area-name>|.|none| ..."
                     "...";
grid-template: none|<grid-template-rows>/<grid-template-columns> | <line-names>?<string><track-size>?
               <line-names>?+/<explicit-track-list>?;
grid-column-gap: <line-size>
grid-row-gap: <line-size>
grid-gap: <grid-row-gap> <grid-column-gap>
justify-items: start|end|center|stretch;
align-items: start|end|center|stretch;
place-items: <align-items> / <justify-items>;
justify-content: start|end|center|stretch|space-around|space-between|space-evenly;
align-content: start|end|center|stretch|space-around|space-between|space-evenly;
place-content: <align-centent>/<justify-centent>;
grid-auto-columns: <track-size> ...;
grid-auto-rows: <track-size> ...;
grid-auto-flow: row|column|row dense|column dense;
grid: <grid-template> | <grid-template-rows> / [ auto-flow && dense? ] <grid-auto-columns>? | [ auto-flow && dense? ] <grid-auto-rows>? / <grid-template-columns>
```
Grid 项目的属性:
```
grid-column-start: <number>|<name>|span <number>|span <name>|auto
grid-column-end: <number> | <name> |span <number> | span <name> |auto
grid-row-start: <number> | <name> |span <number> | span <name> |auto
grid-row-end: <number> | <name> |span <number> | span <name> |auto
grid-column: <start-line> / <end-line> | <start-line> / span <value>;
grid-row: <start-line> / <end-line> | <start-line> / span <value>;
grid-area: <name> | <row-start> / <column-start> / <row-end> / <column-end>;
justify-self: start | end | center | stretch;
align-self: start | end | center | stretch;
place-self: <align-self>/<justify-self>;
```


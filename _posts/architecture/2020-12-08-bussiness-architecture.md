---
layout: post
title: 业务架构与设计原则
categories: [architecture]
description: 
keywords: 企业架构
catalog: true
multilingual: false
tags: architecture
---

## 企业业务架构
企业的业务架构定义了企业的结构，这个结构包含了企业的治理结构，业务流程，服务和产品，业务信息和利益相关者。业务架构为实现企业战略目标勾画出一个可行的、方向性的系统。所以简单地可以认为企业业务架构是一个组织工作的蓝图。通过使用组织架构，企业可以以较小的代价和时间来面对挑战和处理问题，这是因为我们已经知道业务中所有重要的依赖，关系和信息流。企业不管大小都应该有业务架构。 业务架构不一定需要全放面描述或者按照一定的标准创建。设计和描述组织的工作是复杂和困难的， 所以我们需要一些工具来帮助加速这一过程。

### 开源工具
- **Collection** 常见设计原则 [https://principles.design/](https://principles.design/)
- **Archi** 架构图工具 [https://www.archimatetool.com/](https://www.archimatetool.com/)
- **Causal Loop Diagram** 流程图工具。 [https://nocomplexity.com/causalloopdiagram/](https://nocomplexity.com/causalloopdiagram/)
- **Camunda Modeler** 用于编辑BPMN(Business Process Model and Notation)的桌面工具。[https://camunda.com/download/modeler/](https://camunda.com/download/modeler/)
- **Protege** 用于规划拓扑图 [https://protege.stanford.edu/](https://protege.stanford.edu/)
- **DrawIO** 是一个线上项目用于创建流程图。类似国内的有processon. [https://app.diagrams.net/](https://app.diagrams.net/)

## 业务架构设计原则
有一个清晰的业务原则对于成功的企业至关重要。有原则也是在限定的时间和资源下构建好的架构的基础，这些原则需要所有的利益相关者都参与和同意。

### 一些常见的原则
#### solution space解决的空间
**原则：**永不尝试使用技术的手段解决非技术的问题。<br>
**原因：**技术当然可以帮助解决一些问题， 但是技术永远不可能是完备的手段。任何非技术的活动，过程，行为改变等等都可能是解决问题的手段。<br>
**言下之意：**解决问题的时候不要仅仅盯着技术。

#### start simple简单先行
**原则：**简单先行 <br>
**原因：**简单开发一个产品其实是赢得对于构建下一步产品的权利。<br>
**言下之意：**当投入大量时间和金钱时，复杂性就会出现，简单的调整也会产生更大的影响。当产品变得成熟时，修复向后兼容性的问题将更加复杂。<br>

#### 快速构建MVP（Minimal Viable Product)
**原则：**如果你的MVP需要一年的时间构建， 那么这不是MVP <br>
**原因：**最好MVP不要超过一个月构建。<br>
**言下之意：**MVP不是用来贩卖的，而是从后续的阶段中学习如何贩卖。<br>

#### make it easy first then make it fast先简单做然后快速做
**原则：**先简单做， 然后快速做，最后做的漂亮. <br>
**原因：**开发新项目的成本是很高的，做一个优秀的产品更加复杂和昂贵。所以在做MVP的时候，尝试着让产品易用和易改。 <br>
**言下之意：**一些性能之类的问题可以后面再考虑。<br>

#### use open data, open stardards, open source and open innovation使用公开数据，公开标准，公开源代码，公开创意
 **原则：**use open data, open stardards, open source and open innovation. <br>
 **原因：**这个原则提供了一个框架使用公开的方式去技术赋能开发。<br>
 **言下之意：** <br>
- 采用并扩展存在的公开标准
- 尽量以API的方式开放数据和功能， 越大的社区使用你的产品越好
- 把投资软件当做公益
- 尽可能的开源代码

#### Strategic focus焦距策略
 **原则：**投资决策受业务需求驱动。<br>
 **原因：**一个业务领头和面向业务的架构在满足战术目标，不断改变的需求和客户期待上更可能成功。<br>
 **言下之意：**架构需要完全和整个公司的战略目标对齐。<br>

#### make things open保持分享
 **原则：**make things open: it makes things better.<br>
 **原因：**尽可能地分享我们在做的东西。和同事， 和用户，和世界分享代码，分享设计，分享想法，分享创意，分享失败。越多的人关注你越可能你的产品可以成功。<br>

#### maximise benefit to the enterprise最大化企业的利益
 **原则：**信息管理的决定是为了最大化企业的利益。<br>
 **原因：**这个原则内嵌了“服务高于个人”的意思。从企业的角度做决定永远比从组织的角度出发对企业有更长远的价值。<br>
 **言下之意：**达到最大化企业的利益需要我们修正计划和管理信息的方式。技术不能完全解决这个改变。所以组织可能需要做一些牺牲来满足企业利益， 比如调整开发的优先级，改变一些喜欢的工具等等。<br>

#### Reliability可靠性
 **原则：**信息系统需要可靠，准确，及时。<br>

#### Reuse and Improve复用与提高
 **原则：**复用与提高 <br>
 **原因：**避免资源浪费，只有在不满足需求的时候才升级原有的解决方案。<br>
 **言下之意：** <br>
- 尽可能使用、修改、扩展现有工具，平台和框架。
- 开发模块化的软件是提倡的方式。

#### Reuse before buy, buy before build
**原则：**尽可能复内部it资产，不满足的情况下才考虑买外部IP, 最后才是定制化构建新的产品。<br>
**原因：** <br>
- 购买标准的IT解决方案只要它们不是快要淘汰都比自定制化便宜， 并且享有后续维护。
- 定制化的产品后续的维护可能是否昂贵。<br>
**言下之意：** <br>
- 为了保证IT资产能够尽可能复用，业务单元必须保证治理部门不认为业务实践与行业标准实践有重大的不一致。
- 有些商业化的软件是可以配置的，需要评估配置功能的复杂度是否和自己定制的复杂度相近。
- license合规性也是需要考虑的。

#### Routine Tasks are automated where appropriate 尽可能自动化日常活动
 **原则：**尽可能自动化日常活动 <br>
 **原因：**自动化节约人力，提高效率和有更高的容错。<br>
 **言下之意：** <br>
- 需要专业知识去分析可以自动化流程的过程。
- 不是日常的任务不需要自动化。
- 自动化流程可以是一个流程接着另一个流程， 业务单元需要集成到整个工作流当中。

#### Give before receiving
 **原则：**先于奉献 <br>
 **原因：**奉献是建立一段关系的真正方式。仅仅关注于从联系中可以得到什么是不能构建相互共赢和可持续关系的。<br>
 **言下之意：**维护和利益相关者的关系是十分必要的。<br>

#### 信息管理和所有人有关
 **原则：**组织中所有参与信息管理决策的人都需要参与完成业务指标 <br>
 **原因：**信息系统的用户是关键利益相关者，是实际使用技术解决业务需求的人。为了保障信息系统和业务对齐，所有企业中的组织都需要参与到信息系统环境中的各方面。<br>
 **言下之意：**为了整体上作为一个团队，利益相关者需要接受开发信息系统环境的责任。保障必要的资源来完成这条原则。<br>

#### Be Collaborative
 **原则：**相互协助 <br>
 **原因：**If you want to go fast, go alone. If you want to go far, go together.<br>
 **言下之意：** <br>
- 让各个不同领域的专家参与项目
- 跨部门合作
- 把好的工作经验，结果，进展记录下来，并且分享它们。

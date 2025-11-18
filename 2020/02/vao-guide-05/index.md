# VAO 基础入门（五） -  基础配置要点


## 系列目录：

- [VAO 基础入门（一）-  简介](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO 基础入门（二）-  安装与部署](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO 基础入门（三）-  基本组件 · 上篇](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO 基础入门（四）-  基本组件 · 下篇](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO 基础入门（五）-  基础配置要点](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO 基础入门（六）-  成功灾备计划的第一步](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO 基础入门（七）-  Plan Step  · 上篇](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO 基础入门（八）-  Plan Step  · 下篇](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO 基础入门（九）-  文档模板解析](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)

在前几篇中，我们把 VAO 的基本架构、基本组件都盘点了一遍，所涉及到的内容都是在 Administration 中的设置，也就是具有 VAO 管理员权限的账户所能进行的操作。VAO 的管理员可以在这里为每组应用分别设定不同的 Scope，同时将这些 Scope 分派给相关的人员进行使用，利用这一特性，可以有效的进行分组和隔离，是不是有点类似多租户或者多用户？但是又有很大差异。

本篇内容针对之前所提到的这些配置，说明一些可能需要注意的地方。

## 基础架构

vCenter 添加

在安装和初始化配置过程中，我们把 vCenter 添加入 VAO 了，这时候之前的帖子如果大家有印象，可能会留意到我都没有提到过内嵌的 VBR 和 Veeam ONE 的配置，实际上在初始化配置完成之后，VAO 非常智能的将我们在初始化阶段填写的 vCenter 的信息写入到了 VBR 和 Veeam ONE 之中，因此我们不需要再次在 VBR 和 Veeam ONE 里面重新添加了。

VBR 添加

在 VAO 中，可以管理多个 VBR 或 Enterprise Manager 副本，在管理非内嵌的 VBR 时，需要做的只是通过推送的方式在 VAO 的控制台上，将 VAO Agent 推送到 VBR 上即可接管该 VBR。这个操作也相当简单，通过这样的方式，可以很方便的管理到一个大规模的备份/灾备环境。

Active Directory

在项目实施中，往往很多用户环境没有 Active Directory，而 VAO 又必须要有 AD 才能工作，这时候特别头疼，但是回过来其实这事情却又很简单。大家可以想想 VDI 的项目，也都是必须 AD 才能工作的，那他们那些项目不都得急死了？那倒不会的，因为很简单，没有 AD 我们就造个 AD 嘛，为了项目成功，没有条件创造个条件呗，这事完全难不倒我们这些攻城狮。

## Scope

Scope 特别难理解，但是想通了又特别简单，因此这个配置要点说明，我强烈建议大家回过去到我的第三篇，加强理解下 Scope 的概念，并且通过实战，到 VAO 中设置一些复杂的场景来理解这个 Scope。只有真枪实弹动过手，才能把这个 Scope 吃透，才能用好 VAO，这是最最关键的一个组件。

另外，对于 Scope，不能仅仅从 Users and Scopes 中去看这个 Scopes，需要从 Scopes 的 2 个维度结合起来看，这样这个概念才会生动的显现在我们面前：

1. 授权使用这个 Scope 的用户；
2. Scope 包含的 5 大 Components 和对应的 DataLabs；

## Datalabs

请先理解 VBR 中所有 DataLab 的配置，如果还不会配置 VBR 中的 DataLab，那么将会玩不转 VAO，因为这是 VAO 的必要组件和必要条件。

DataLabs 的配置在 VAO 中几乎没有任何操作，只是通过 Assign 的动作分配给对应的 Scope，在 VAO 中想知道自己的 DataLabs 是如何配置是件非常困难的事情，假如我们需要用到大量的 DataLabs，这时候可能只能回到 VBR 中逐个逐个点开配置去查看，这个非常不科学。那么我在这里有个很不错的小技巧可以提供给大家，在 VAO 的 DataLabs 信息中，会从 VBR 上取得这个 DataLabs 的 Name、Description、Platform 和 VBR Server Name，这时候大家完全可以利用好这个 Description，只需要在 VBR 中创建 DataLabs 时，将 Virtual Lab Summary 的内容 Copy 出来，贴到这个 Virtual Lab 的 Description 中，这样这段关于该 DataLabs 的详细配置情况就会被读取到 VAO 中，那么我们也就能够很清楚的知道这个 DataLabs 的具体配置了。如下图，最终我的效果。

![3ZScnI.png](https://s2.ax1x.com/2020/02/19/3ZScnI.png)

## Recovery Locations

设置相对复杂，而且设置完成后就固化下来了，然而这个只是一个计算资源的逻辑组合，他实际上只存在于 VAO 之中，不管在 vCenter、VBR 还是 VeeamONE 之中都不会有这个 Recovery Locations 存在。因此这也是一个非常好的消息，这个 Recovery Locations 无论设置成什么样子，他都不会影响除了 VAO 之外的其他任何组件的正常运行。

小小的 Tips 给到大家，那就是任性的去设置 Recovery Locations 吧，放肆的组合吧，就算不会被实际的 Orchestration Plan 使用到，放在那边又何妨？难说哪天有需要就用到了呢？

当然，最终回归回来，在这里还是需要合理，合理的按需配置才能降低这套系统的复杂程度，最终实现为我们的高效的灾备服务。

以上就是 VAO 中 Administration 部分的配置要点，从下一篇开始，将进入真正的使用环节，谢谢大家关注本系列。


# VRO v6 基础入门（一） -  简介


随着 Veeam 旗舰产品 Veeam Availability Suite v10 的发布，Veeam Availability Orchestrator（以下简称 VAO) 也会在不久更新为 v3.0 版本，目前来说 VAO 产品还是处于 v2.0 版本。对于绝大多数同学来说，可能这个产品非常神秘，看似功能非常高大上，但是也不知道如何使用，我的这个基础入门系列将会和大家分享一些本人对于 VAO 的一些研究。

## 什么是 VAO？

简单来说，他是 VAS 加强版。它需要和 VAS 一起工作，离不开 VAS；VAO 还需要和 VMware vSphere 一起工作，它仅限于支持 VMware 的虚拟化环境。

 - 能够通过软件的设置，来保证企业实施的灾备基础架构的满足所要求的 RPO 和 RTO；
 - 能够尽可能自动化的完成灾备的切换过程，该操作同时支持备份存档和复制存档；
 - 能够通过数据实验室，来确保灾备的精准可靠，所有灾备演练将在数据实验室中 1:1 的完整演练。

VAO 替代了 VBR 中 Recovery、Failover 以及 Surebackup 的操作，可以说是对于这 3 个关键操作的进一步加强，在这些关键操作中，可以加入各种自定义的步骤和脚本，使之能够更加接近实际业务场景中的使用。对于管理员来说，合理的设计这 3 个操作中的额外步骤能极大程度的降低 IT 运维中灾备流程的复杂度。

## VAO 支持哪些场景使用？

VAO 支持的数据中心从简单到复杂，都可以使用，以下仅简单从最基本的架构举两个例子：

### 单个数据中心

![390jqx.png](https://s2.ax1x.com/2020/02/16/390jqx.png)

单个数据中心内，加入 VAO 的组件后，和原有 VAS 的架构几乎没有太大差别，所有 VBR 上的操作不会有任何改变，常规的所有备份恢复操作都在 VBR 上可以完成，而 VAO 则在这里开始担当关键业务的 RPO 和 RTO 的确保任务。通常来说关键业务出现宕机后，都会在原始位置实现恢复，因此也没有特别的专用资源用于恢复准备。

因此，在这种场景下，唯一需要改变的是选择一些关键的 VM，由 VAO 来接管这些 VM 的 RPO 和 RTO。

### 一主一备数据中心

![390OMR.png](https://s2.ax1x.com/2020/02/16/390OMR.png)

稍微复杂点，也是很典型的场景，就是跨区域的主备数据中心，主中心承担生成业务，而备中心承担灾备业务。我们通常 VAS 的设计会将备份存档拷贝到灾备中心进行存放，也可能会将一些关键的 VM 直接 1:1 的复制到灾备中心。而这时候，在灾备中心的数据恢复流程都将可以被编制到 VAO 的 Failover Plan 或 Recovery Plan 中，同时这些 Plan 也将会被在相应的 Datalabs 中做完整的恢复演练。

这种场景下，原先 VAS 的架构也没有太大变化，和单数据中心非常相似，只是我们可以规划一部分资源专用于灾备恢复。

## VAO 支持的两种 Plan

VAO 本身并不提供备份和复制功能，所有对于源数据的提取功能，都会在 VAS/VBR 中完成。VAO 中提供了两种 Plan：Restore Plan 和 Failover Plan。

### Restore Plan

这是对应 VBR 中的 Backup & Restore 功能，所有对备份存档（.vbk，.vib，.vrb 等）的恢复，都归为这一类。

### Failover Plan

这是对应 VBR 中的 Replication & Failover 功能，所有对于 Replicas 的故障切换，都归为这一类。

这两种 Plan 支持的操作：

```
  - DataLabs 测试
  - 资源可用性测试
  - 完整报告自动生成
  - 一键式全自动恢复、故障切换
```

## VAO 额外支持的 DataLabs 功能

作为 Veeam 产品看家本领，DataLabs 功能在 VAO 中也是极大增强，在 VAO 中不仅能将 DataLabs 用于以上两种 Plan 的测试，还能利用 VAO 中强大的脚本和步骤添加功能，自动化的生成各种复杂的用于测试的环境。通过这种增强，复杂的测试用例，复杂的环境部署工作将会被简化成一键式的按钮，极大提升 DataLabs 的使用效率。

以上就是 VAO 的简介，欢迎关注 VAO 基础入门系列，在最近一段时间我会陆续更新以下内容：

- [VAO 基础入门（一）-  简介](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO 基础入门（二）-  安装与部署](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO 基础入门（三）-  基本组件 · 上篇](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO 基础入门（四）-  基本组件 · 下篇](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO 基础入门（五）-  基础配置要点](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO 基础入门（六）-  成功灾备计划的第一步](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO 基础入门（七）-  Plan Step  · 上篇](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO 基础入门（八）-  Plan Step  · 下篇](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO 基础入门（九）-  文档模板解析](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)


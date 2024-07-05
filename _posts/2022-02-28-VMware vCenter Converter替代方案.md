---
layout: post
title: vCenter Converter 下架后 p2v 怎么玩
tags: VMware
---

月初，VMware 官网博客发了一则 [通告](https://blogs.vmware.com/vsphere/2022/02/vcenter-converter-unavailable-for-download.html)，他们将 vCenter Converter 从 VMware 产品下载清单中移除了，也就是说，我们以后再也无法在 VMware 官网下载到这一产品了。从 VMware 官方的说法是，vCenter Converter 多年没更新，产品有一些安全隐患并且不太稳定。而在我看来，VMware 是将他们最强力的武器给拿下来了。

## 这个工具能干啥？

可能不少朋友并没有接触过这个工具，但是对于 VMware 管理员来说，这个工具可以说是他们的最佳搭档，这个工具的装机率之高，可以说是 VMware 自身一大堆产品中，仅次于 vCenter，绝大多数环境中都是装完 vCenter 立刻同时装上 vCenter Converter。

这个工具是早期 VMware 成功的重要功臣，早在 VI3.0 的年代，就普遍被管理员使用，当时它的基础功能很简单，目标也非常简单：帮助管理员将物理机转化成 VMware 上的虚拟机。这可是帮到管理员的大忙了，全自动的完成物理到虚拟的转换，工作负载变成了虚拟机状态运行在 VMware 平台。

早期的 Converter 工具仅限于 Windows 的转换，后期它的功能越来越强大，同时支持 Windows 和 Linux 系统，还能支持从其他虚拟化平台转换成 VMware vSphere 上的虚拟机。

[![bK5D8H.png](https://s4.ax1x.com/2022/02/28/bK5D8H.png)](https://imgtu.com/i/bK5D8H)

## 工作过程

vCenter Converter 一般会有两种实现方式，分别是热迁移和冷迁移。其中热迁移相对系统要求较高，如果一切顺利的情况下，整个过程业务基本上没有中断，但是数据一致性上因为业务持续在运行并不是太高；而冷迁移相对系统要求低，适用性广，并且因为系统关机状态进行，迁移前后数据完全一致。

这两种迁移转换方式，都会存在较长的转换时间，这个时间基本上是取决于源系统的磁盘容量大小。

## 替代方案

这里隆重介绍下 Veeam 的神技能：**Instant Recovery**！

这个技术在 v10 开始就不断突破，在目前 v11 的版本里面可以说是已经脱胎换骨。原本这只是一个即时挂载，快速恢复的功能，然而想象力创造力无限的 Veeam 用户提出了将物理机的备份存档在虚拟化平台即时恢复的概念后，Veeam 的研发团队将这一概念落地成了实实在在的功能并且将这功能进一步延伸扩展：

- 将 Hyper-V 上虚拟机的备份存档，即时恢复到 VMware vSphere
- 将 Veeam Agent for Microsoft Windows 或 Linux 的备份存档，即时恢复到 VMware vSphere
- 将 Nutanix AHV 上虚拟机的备份存档，即时恢复到 VMware vSphere
- 将 Amazon EC2 上虚拟机的备份存档，即时恢复到 VMware vSphere
- 将 Microsoft Azure 上虚拟机的备份存档，即时恢复到 VMware vSphere
- 将 Google Compute Engine 上虚拟机的备份存档，即时恢复到 VMware vSphere
- 将 RHV 上虚拟机的备份存档，即时恢复到 VMware vSphere

因此，任何迁移，只需要通过 Veeam 进行备份，然后 Instant Recovery，最后 Migration 恢复的虚拟机至生成虚拟化系统即可。

## 技术要点和操作建议

最后敲黑板来划下重点，功能很强大，但是用的时候一定要注意以下问题：

1. 热迁移数据偏差量问题，非常建议在做 Instant Recovery 之前做一次最后的增量备份，并且保证这次增量在几分钟内完成，如果增量花的时间久，可以在这个增量做完之后立刻再做下一个增量，最后的增量备份完成后，立马将源机关机，然后使用这个最新的增量还原点进行下一步的即时恢复。这样做的效果可以实现 10 分钟以内的停机完成迁移。
2. 在做 Instant Recovery 的时候，对于 Windows 系统成功率几乎是 100%的，但是对于 Linux 系统，可能会存在一些这样或者那样的问题，建议在备份前，检查 Linux 系统，确保正确安装了`dracut`和`mkinitrd`，这个能大大提升恢复成功率。
3. 注意 IRcache 目录的空间大小，这几年很多物理机的内存容量会特别大，比如一台服务器配置 256GB/512GB 内存，可能非常常见。对于这些机器的 Instant Recovery，IRcache 的容量一定要预留比内存大。

[![bK5BPe.png](https://s4.ax1x.com/2022/02/28/bK5BPe.png)](https://imgtu.com/i/bK5BPe)

4. 迁移方法可以用 Storage vMotion，也可以使用 Veeam Quick Migration。这两个各有优劣，具体可以参考我之前的帖子。

好了，以上就是今天的内容，希望 VMware 的 vCenter Converter 的下架不会对大家的日常工作造成太多困扰。

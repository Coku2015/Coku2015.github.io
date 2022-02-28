---
layout: post
title: vCenter Converter下架后p2v怎么玩
tags: VMware
---



月初，VMware官网博客发了一则[通告](https://blogs.vmware.com/vsphere/2022/02/vcenter-converter-unavailable-for-download.html)，他们将vCenter Converter从VMware产品下载清单中移除了，也就是说，我们以后再也无法在VMware官网下载到这一产品了。从VMware官方的说法是，vCenter Converter多年没更新，产品有一些安全隐患并且不太稳定。而在我看来，VMware是将他们最强力的武器给拿下来了。

## 这个工具能干啥？

可能不少朋友并没有接触过这个工具，但是对于VMware管理员来说，这个工具可以说是他们的最佳搭档，这个工具的装机率之高，可以说是VMware自身一大堆产品中，仅次于vCenter，绝大多数环境中都是装完vCenter立刻同时装上vCenter Converter。

这个工具是早期VMware成功的重要功臣，早在VI3.0的年代，就普遍被管理员使用，当时它的基础功能很简单，目标也非常简单：帮助管理员将物理机转化成VMware上的虚拟机。这可是帮到管理员的大忙了，全自动的完成物理到虚拟的转换，工作负载变成了虚拟机状态运行在VMware平台。

早期的Converter工具仅限于Windows的转换，后期它的功能越来越强大，同时支持Windows和Linux系统，还能支持从其他虚拟化平台转换成VMware vSphere上的虚拟机。

[![bK5D8H.png](https://s4.ax1x.com/2022/02/28/bK5D8H.png)](https://imgtu.com/i/bK5D8H)

## 工作过程

vCenter Converter一般会有两种实现方式，分别是热迁移和冷迁移。其中热迁移相对系统要求较高，如果一切顺利的情况下，整个过程业务基本上没有中断，但是数据一致性上因为业务持续在运行并不是太高；而冷迁移相对系统要求低，适用性广，并且因为系统关机状态进行，迁移前后数据完全一致。

这两种迁移转换方式，都会存在较长的转换时间，这个时间基本上是取决于源系统的磁盘容量大小。

## 替代方案

这里隆重介绍下Veeam的神技能：**Instant Recovery**！

这个技术在v10开始就不断突破，在目前v11的版本里面可以说是已经脱胎换骨。原本这只是一个即时挂载，快速恢复的功能，然而想象力创造力无限的Veeam用户提出了将物理机的备份存档在虚拟化平台即时恢复的概念后，Veeam的研发团队将这一概念落地成了实实在在的功能并且将这功能进一步延伸扩展：

- 将Hyper-V上虚拟机的备份存档，即时恢复到VMware vSphere
- 将Veeam Agent for Microsoft Windows或Linux的备份存档，即时恢复到VMware vSphere
- 将Nutanix AHV上虚拟机的备份存档，即时恢复到VMware vSphere
- 将Amazon EC2上虚拟机的备份存档，即时恢复到VMware vSphere
- 将Microsoft Azure上虚拟机的备份存档，即时恢复到VMware vSphere
- 将Google Compute Engine上虚拟机的备份存档，即时恢复到VMware vSphere
- 将RHV上虚拟机的备份存档，即时恢复到VMware vSphere

因此，任何迁移，只需要通过Veeam进行备份，然后Instant Recovery，最后Migration恢复的虚拟机至生成虚拟化系统即可。

## 技术要点和操作建议

最后敲黑板来划下重点，功能很强大，但是用的时候一定要注意以下问题：

1. 热迁移数据偏差量问题，非常建议在做Instant Recovery之前做一次最后的增量备份，并且保证这次增量在几分钟内完成，如果增量花的时间久，可以在这个增量做完之后立刻再做下一个增量，最后的增量备份完成后，立马将源机关机，然后使用这个最新的增量还原点进行下一步的即时恢复。这样做的效果可以实现10分钟以内的停机完成迁移。
2. 在做Instant Recovery的时候，对于Windows系统成功率几乎是100%的，但是对于Linux系统，可能会存在一些这样或者那样的问题，建议在备份前，检查Linux系统，确保正确安装了`dracut`和`mkinitrd`，这个能大大提升恢复成功率。
3. 注意IRcache目录的空间大小，这几年很多物理机的内存容量会特别大，比如一台服务器配置256GB/512GB内存，可能非常常见。对于这些机器的Instant Recovery，IRcache的容量一定要预留比内存大。

[![bK5BPe.png](https://s4.ax1x.com/2022/02/28/bK5BPe.png)](https://imgtu.com/i/bK5BPe)

4. 迁移方法可以用Storage vMotion，也可以使用Veeam Quick Migration。这两个各有优劣，具体可以参考我之前的帖子。

好了，以上就是今天的内容，希望VMware的vCenter Converter的下架不会对大家的日常工作造成太多困扰。


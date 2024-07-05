---
layout: post
title: Backup Copy 新模式，让 3-2-1 的黄金法则覆盖更广
tags: VBR

---

## Backup Copy 理论基础

Veeam 的 Backup Copy 是实现数据保护 3-2-1 黄金法则的基础，也是 VBR 的基础功能之一。它的功能非常简单，实现的效果就是将一个还原点（Restore Point）完完整整的拷贝一份，变成一个新的可以使用的还原点。什么是还原点？在 VBR 中它是某个 VM 或者 Server 某个时间点的记录，利用还原点，可以从 VBR 的存储库中将数据还原回该时间点的那份内容。对于还原点来说，它可能包含了一个文件，比如 vbk 全备份存档，也有可能包含了一组文件，一个 vbk 和一系列的 vib，这取决于备份作业或者备份拷贝作业如何创建他们。

Backup Copy 制作的备份链和普通的 Backup 作业制作的备份链略有不同，Backup Copy 通常制作的备份链是永久增量的模型，也就是说，第一次的传输，Backup Copy 会创建一个。vbk 的全备份存档，在第二次开始的后续传输中，Backup Copy 会基于第一次的。vbk 形成一份。vib 的增量存档，并且一直创建下去。

Backup Copy 默认使用合成全备份的技术生成并创建全备份存档，只是这个全备份存档必须是基于 GFS 策略来创建，举个例子来说，如下图所示：

![tttSpR.png](https://s1.ax1x.com/2020/06/02/tttSpR.png)

这个 Backup Copy 作业设置了 14 个还原点（Restore Points），每天运行一次作业，那么实际上在运行了一个周期后，它将得到如下结果：

![ttwkYF.png](https://s1.ax1x.com/2020/06/02/ttwkYF.png)

如果开启了 GFS 每周的全备份后，Weekly Backup 如果设置成 2 份，如下图设置。

![ttwspQ.png](https://s1.ax1x.com/2020/06/02/ttwspQ.png)

那么这样的设置将得到如下结果，其中前两个全备份存档是根据 GFS 的策略要求，所创建出来的 Weekly Full 的存档。

![tt0lBq.png](https://s1.ax1x.com/2020/06/02/tt0lBq.png)

## V10 的新变化

在 V10 版本中，Veeam 的 Backup Copy 发生了一些变化，原来的 Backup Copy 模式继续保留，但是新增了一种全新的模式，因此这两种模式有了各自的名字：Immediate Copy 和 Periodic Copy。新增的模式叫做 Immediate Copy，老的模式赋予了新的名字 Periodic Copy。两种模式有一些区别，他们支持的内容会不一样，如下表所示。

| 支持的备份存档             | Immediate Copy | Periodic Copy |
| -------------------------- | -------- | -------- |
| vSphere 和 Hyper-V 虚拟机备份 | 支持     | 支持     |
| VBR 集中管理的 Veeam Agent   | 支持     | 支持     |
| SQL 和 Oracle 的日志备份      | 支持     | 不支持   |
| 非集中管理的 Veeam Agent    | 不支持   | 支持     |
| Oracle RMAN 和 SAP HANA      | 支持     | 不支持   |
| Nutanix AHV                | 不支持   | 支持     |
| AWS EC2                    | 不支持   | 支持     |
| Microsoft Azure 虚拟机     | 不支持   | 支持     |

除此之外，这两种 Copy 模式，在备份存档的生成上，有一些区别，对于 Immediate Copy 而言，他会根据主备份任务的设定，当主备份任务执行完成后，立刻生成一份备份拷贝存档。Immediate Copy 是主备份任务的 1：1 的完全还原点镜像。但是需要特别注意的，它不是简单的备份文件的镜像，并不是 vbk、vib 的文件拷贝。举个例子来说，在主备份任务中如果设置了每个周六创建 Synthetic Full 的备份作业，会在周六生成全备份存档，而在这个备份存档生成后，Immediate Copy 作业会运行并创建对应的 Copy 存档，这个创建出来的存档和主备份任务创建出来的 vbk 全备份不一样，它创建出来的是一份 vib 的增量备份。由于 Immediate Copy 的特点，它适用于所有需要进行应用程序日志复制的备份作业，因此在异地容灾时，对于关键的数据库系统，通过 Immediate Copy 能提升 RPO 级别。

两种备份模式正常情况下无法切换，假如要使用全新的 Immediate Copy 功能，可以禁用老的 Backup Copy 任务，只需要简单的创建新的 Immediate Copy 勾选 Include database transaction log backups 即可。

以上就是今天的内容，为了数据更安全，赶紧把 Backup Copy 做起来吧。

 
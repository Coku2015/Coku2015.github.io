---
layout: post
title: Backup Copy新模式，让3-2-1的黄金法则覆盖更广
tags: ['VBR']

---

## Backup Copy理论基础

Veeam的Backup Copy是实现数据保护3-2-1黄金法则的基础，也是VBR的基础功能之一。它的功能非常简单，实现的效果就是将一个还原点（Restore Point）完完整整的拷贝一份，变成一个新的可以使用的还原点。什么是还原点？在VBR中它是某个VM或者Server某个时间点的记录，利用还原点，可以从VBR的存储库中将数据还原回该时间点的那份内容。对于还原点来说，它可能包含了一个文件，比如vbk全备份存档，也有可能包含了一组文件，一个vbk和一系列的vib，这取决于备份作业或者备份拷贝作业如何创建他们。

Backup Copy制作的备份链和普通的Backup作业制作的备份链略有不同，Backup Copy通常制作的备份链是永久增量的模型，也就是说，第一次的传输，Backup Copy会创建一个.vbk的全备份存档，在第二次开始的后续传输中，Backup Copy会基于第一次的.vbk形成一份.vib的增量存档，并且一直创建下去。

Backup Copy默认使用合成全备份的技术生成并创建全备份存档，只是这个全备份存档必须是基于GFS策略来创建，举个例子来说，如下图所示:

![tttSpR.png](https://s1.ax1x.com/2020/06/02/tttSpR.png)

这个Backup Copy作业设置了14个还原点（Restore Points），每天运行一次作业，那么实际上在运行了一个周期后，它将得到如下结果：

![ttwkYF.png](https://s1.ax1x.com/2020/06/02/ttwkYF.png)

如果开启了GFS每周的全备份后，Weekly Backup如果设置成2份，如下图设置。

![ttwspQ.png](https://s1.ax1x.com/2020/06/02/ttwspQ.png)

那么这样的设置将得到如下结果，其中前两个全备份存档是根据GFS的策略要求，所创建出来的Weekly Full的存档。

![tt0lBq.png](https://s1.ax1x.com/2020/06/02/tt0lBq.png)

## V10的新变化

在V10版本中，Veeam的Backup Copy发生了一些变化，原来的Backup Copy模式继续保留，但是新增了一种全新的模式，因此这两种模式有了各自的名字：Immediate Copy和Periodic Copy。新增的模式叫做Immediate Copy，老的模式赋予了新的名字Periodic Copy。两种模式有一些区别，他们支持的内容会不一样，如下表所示。

| 支持的备份存档             | Immediate Copy | Periodic Copy |
| -------------------------- | -------- | -------- |
| vSphere和Hyper-V虚拟机备份 | 支持     | 支持     |
| VBR集中管理的Veeam Agent   | 支持     | 支持     |
| SQL和Oracle的日志备份      | 支持     | 不支持   |
| 非集中管理的Veeam Agent    | 不支持   | 支持     |
| Oracle RMAN和SAP HANA      | 支持     | 不支持   |
| Nutanix AHV                | 不支持   | 支持     |
| AWS EC2                    | 不支持   | 支持     |
| Microsoft Azure 虚拟机     | 不支持   | 支持     |

除此之外，这两种Copy模式，在备份存档的生成上，有一些区别，对于Immediate Copy而言，他会根据主备份任务的设定，当主备份任务执行完成后，立刻生成一份备份拷贝存档。Immediate Copy是主备份任务的1：1的完全还原点镜像。但是需要特别注意的，它不是简单的备份文件的镜像，并不是vbk、vib的文件拷贝。举个例子来说，在主备份任务中如果设置了每个周六创建Synthetic Full的备份作业，会在周六生成全备份存档，而在这个备份存档生成后，Immediate Copy作业会运行并创建对应的Copy存档，这个创建出来的存档和主备份任务创建出来的vbk全备份不一样，它创建出来的是一份vib的增量备份。由于Immediate Copy的特点，它适用于所有需要进行应用程序日志复制的备份作业，因此在异地容灾时，对于关键的数据库系统，通过Immediate Copy能提升RPO级别。

两种备份模式正常情况下无法切换，假如要使用全新的Immediate Copy功能，可以禁用老的Backup Copy任务，只需要简单的创建新的Immediate Copy勾选Include database transaction log backups即可。

以上就是今天的内容，为了数据更安全，赶紧把Backup Copy做起来吧。

 
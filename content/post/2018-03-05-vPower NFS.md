---
layout: post
title: Veeam黑科技之vPower NFS
tags: ['VMware', '黑科技']
categories: 黑科技
---



什么是vPower？





这是Veeam的突破性科技，可以说是创造了一个时代，引领了当今虚拟化数据保护新的技术潮流。这项科技彻底颠覆了原有传统IT环境数据保护过程中恢复数据的流程，将漫长的恢复数据过程提升至分钟级，让超大容量的数据恢复变得不再那么可怕。



Veeam的vPower技术不仅仅支持VMware vSphere，同时能够支持Microsoft Hyper-V平台，并且两者实现的效果几乎完全一致。本文仅以VMware vSphere为例介绍vPower的原理。



这项科技的核心内容其实非常非常的简单，我认为这也是Veeam的科学家太聪明了，简单但是及其巧妙的运用虚拟化的手段直接让常规磁盘存储设备中存放的被压缩和重删后的数据能够模拟成前端Hypervisor程序可以识别的文件格式，然后运行起来。从技术上说，这是一个非常简单的架构，ESXi 主机直接访问vPower NFS Server，实现虚拟机恢复运行。

 

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU2FvCd8FPVLZpCpniaFGDBr7OdGia7pibrI1bcnPia68eJCbrjb7H82qBYSjnlxWRfjVtwTe8GWckMToA/640?wx_fmt=png)



这里面有个非常核心的角色，那就是有一台Windows Server，上面启动vPower NFS服务，来充当一台NFS Server。那么相信熟悉VMware的各位一定能想到，VMware在使用Datastore时，除了常规的VMFS这样的Block Level的使用方式外，还可以使用NFS 作为Datastore。Veeam正是用这种方式让ESXi能够访问到备份文件并直接启动。ESXi在访问Veeam搭建的这台vPower NFS Server的时候，能够透过Veeam的专利技术协议vPower识别到在这个Datastore中模拟出来的VMDK，看上去这些VMDK和正常的VM所使用的完全一样，Veeam的这个模拟技术骗过了ESXi。而事实上，这个NFS Datastore上的VMDK却是Veeam通过数据块指向技术，将ESXi需要访问的数据块再次定向到压缩重删后的备份文件中。



通常的这类访问，是一个单向重定向技术，也就是说在备份存档中的数据块只负责提供被读取的权限，而当有交互数据需要写入时，Veeam的vPower技术又能很好的屏蔽这些写请求，使之写入至其他位置，确保备份存档的完整性和有效性。





哪里用的了vPower技术？





Instant VM Recovery – 直接恢复备份存档时，使用了vPower。

SureBackup – [《全自动验证备份存档》](http://mp.weixin.qq.com/s?__biz=MzU4NzA1MTk2Mg==&mid=2247483830&idx=1&sn=3fee7103411facb64c243c32b0e0ff65&chksm=fdf0a763ca872e75b75ca65be5f81791549bac6322e5f161ec5becc5be23eef27833ea47b9f3&scene=21#wechat_redirect)，此功能可以查看之前的推送了解详细原理。

U-AIR – 恢复任意的应用程序的对象。

On-demand Sandbox – 隔离的沙盒用于测试开发等等各种场景。

Instant File level recovery – 任何操作系统的文件级别恢复。



以上这5种Veeam技术中，都会使用到vPower NFS Service，也就是说，vPower NFS Service如果出现故障，那将直接影响以上这5个Veeam的重要功能，当然这个故障基本不可能发生。



限制条件？





目前只要是存放在磁盘上的VM存档都支持使用vPower NFS Service。而存放在磁带以及Cloud Repository中的VM存档因为离线和异地等性能问题，无法支持这个操作。



vPower写请求位置





对于不同的技术中使用vPower，其实这点上会有一些不一样。在Instant VM Recovery和SureBackup中，Veeam使用了两种不同的技术去处理虚拟机运行产生的变化数据块，以应对对于Instant VM Recovery和SureBackup的不同用途。

 

SureBackup中，vPower处理临时产生的数据变化量会存放于Virtual Lab所指定的Datastore的VMDK redo log中，因此通常的虚拟机VMDK都会被修改为non-persistent磁盘。



而对于Instant VM Recovery的特点是，虚拟机启动后，通常管理员会进行下一步的迁移回生产主机/存储的操作，因此无法使用SureBackup中这种non-persistent磁盘和redo log的存储机制，而是使用Veeam自己特有的vPower NFS缓存技术来存储新增的数据变化量，这个缓存技术的使用使得VMware层面上来看挂载起来的虚拟机时，是一个完整合规的可以使用vMotion技术的VM。





vPower技术配置要点





配置入口：在配置Repository的位置，每个Repository都会有它独立对应的vPower NFS Server。



必要端口：

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU2FvCd8FPVLZpCpniaFGDBr7OLUV4YRXrTBy39LWn0U1icmTISO0auAy4O0Khd5FuVnsfDpcZzOJz4w/640?wx_fmt=png)

以上2049+和1058+这两个端口系统会自动侦测，如果不可用会自动增加探测更新成可用端口，而6161和111则不会自动更改，如有必要可以手动更改。



特别注意点：因为在vPower NFS Server之中引入了vPower NFS缓存技术，因此在实际使用中需要特别注意这个缓存容量的预留和变化。默认情况下，这个缓存位于C:\Programdata\Veeam\Backup\NFSdatastore 目录下，我们一般会预留至少100GB的剩余空间给这个目录，当然这个目录也可以被定为到其他目录中。

而在执行Instant VM recovery的任务过程中，Veeam也同样提供了修改vPower NFS Cache目录的功能，可以将Cache重定向至有足够空间的生产存储上。

对于SureBackup，VMDK的redo log则会被存放在VirtualLab所指定的ESXi Datastore中，完全不用担心以上这一Cache目录容量。



Instant VM Recovery的扩展用法





使用Instant VM Recovery其实远不止虚拟机立刻开机这样简单的功能，在此我仅以一些特殊的例子来说明一下。







使用IR进行恢复磁盘HotAdd操作

- 不连接网络，不开机的情况下，启动Instant VM Recovery；
- 注册完虚拟机后，将IR出来的虚拟机中的虚拟磁盘Attach到生产环境的VM中；
- 把挂载的磁盘在操作系统内联机；
- 在操作系统内拷贝还原数据；
- 卸载磁盘；
- 取消IR操作。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU2FvCd8FPVLZpCpniaFGDBr7XHvSkNicalDK2nLAp91jgGHNZ4XffZyP43LTIefmY0sjN5S2cbqOYZw/640?wx_fmt=png)







利用空VMDK恢复非标文件系统数据

- 不连接网络，恢复后开机，启动Instant VM Recovery；
- 创建一个新的VMDK
- 将这个VMDK Attach到IR出来的VM中
- 登入系统，按照特殊需求格式化VMDK磁盘并拷贝数据
- 从IR出来的VM中移除新VMDK并投入生产系统使用
- 停止IR虚拟机。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU2FvCd8FPVLZpCpniaFGDBr7hSZZp2py64oRdJrMsoAO6kFIZsBCCHLRlKLR9Zia5nItGuYPI4qeAuA/640?wx_fmt=png)
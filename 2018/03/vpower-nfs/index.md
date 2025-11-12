# Veeam 黑科技之 vPower NFS


什么是 vPower？

这是 Veeam 的突破性科技，可以说是创造了一个时代，引领了当今虚拟化数据保护新的技术潮流。这项科技彻底颠覆了原有传统 IT 环境数据保护过程中恢复数据的流程，将漫长的恢复数据过程提升至分钟级，让超大容量的数据恢复变得不再那么可怕。

Veeam 的 vPower 技术不仅仅支持 VMware vSphere，同时能够支持 Microsoft Hyper-V 平台，并且两者实现的效果几乎完全一致。本文仅以 VMware vSphere 为例介绍 vPower 的原理。

这项科技的核心内容其实非常非常的简单，我认为这也是 Veeam 的科学家太聪明了，简单但是及其巧妙的运用虚拟化的手段直接让常规磁盘存储设备中存放的被压缩和重删后的数据能够模拟成前端 Hypervisor 程序可以识别的文件格式，然后运行起来。从技术上说，这是一个非常简单的架构，ESXi 主机直接访问 vPower NFS Server，实现虚拟机恢复运行。

 

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU2FvCd8FPVLZpCpniaFGDBr7OdGia7pibrI1bcnPia68eJCbrjb7H82qBYSjnlxWRfjVtwTe8GWckMToA/640?wx_fmt=png)

这里面有个非常核心的角色，那就是有一台 Windows Server，上面启动 vPower NFS 服务，来充当一台 NFS Server。那么相信熟悉 VMware 的各位一定能想到，VMware 在使用 Datastore 时，除了常规的 VMFS 这样的 Block Level 的使用方式外，还可以使用 NFS 作为 Datastore。Veeam 正是用这种方式让 ESXi 能够访问到备份文件并直接启动。ESXi 在访问 Veeam 搭建的这台 vPower NFS Server 的时候，能够透过 Veeam 的专利技术协议 vPower 识别到在这个 Datastore 中模拟出来的 VMDK，看上去这些 VMDK 和正常的 VM 所使用的完全一样，Veeam 的这个模拟技术骗过了 ESXi。而事实上，这个 NFS Datastore 上的 VMDK 却是 Veeam 通过数据块指向技术，将 ESXi 需要访问的数据块再次定向到压缩重删后的备份文件中。

通常的这类访问，是一个单向重定向技术，也就是说在备份存档中的数据块只负责提供被读取的权限，而当有交互数据需要写入时，Veeam 的 vPower 技术又能很好的屏蔽这些写请求，使之写入至其他位置，确保备份存档的完整性和有效性。

哪里用的了 vPower 技术？

Instant VM Recovery – 直接恢复备份存档时，使用了 vPower。

SureBackup – [《全自动验证备份存档》](http://mp.weixin.qq.com/s?__biz=MzU4NzA1MTk2Mg==&mid=2247483830&idx=1&sn=3fee7103411facb64c243c32b0e0ff65&chksm=fdf0a763ca872e75b75ca65be5f81791549bac6322e5f161ec5becc5be23eef27833ea47b9f3&scene=21#wechat_redirect)，此功能可以查看之前的推送了解详细原理。

U-AIR – 恢复任意的应用程序的对象。

On-demand Sandbox – 隔离的沙盒用于测试开发等等各种场景。

Instant File level recovery – 任何操作系统的文件级别恢复。

以上这 5 种 Veeam 技术中，都会使用到 vPower NFS Service，也就是说，vPower NFS Service 如果出现故障，那将直接影响以上这 5 个 Veeam 的重要功能，当然这个故障基本不可能发生。

限制条件？

目前只要是存放在磁盘上的 VM 存档都支持使用 vPower NFS Service。而存放在磁带以及 Cloud Repository 中的 VM 存档因为离线和异地等性能问题，无法支持这个操作。

vPower 写请求位置

对于不同的技术中使用 vPower，其实这点上会有一些不一样。在 Instant VM Recovery 和 SureBackup 中，Veeam 使用了两种不同的技术去处理虚拟机运行产生的变化数据块，以应对对于 Instant VM Recovery 和 SureBackup 的不同用途。

 

SureBackup 中，vPower 处理临时产生的数据变化量会存放于 Virtual Lab 所指定的 Datastore 的 VMDK redo log 中，因此通常的虚拟机 VMDK 都会被修改为 non-persistent 磁盘。

而对于 Instant VM Recovery 的特点是，虚拟机启动后，通常管理员会进行下一步的迁移回生产主机/存储的操作，因此无法使用 SureBackup 中这种 non-persistent 磁盘和 redo log 的存储机制，而是使用 Veeam 自己特有的 vPower NFS 缓存技术来存储新增的数据变化量，这个缓存技术的使用使得 VMware 层面上来看挂载起来的虚拟机时，是一个完整合规的可以使用 vMotion 技术的 VM。

vPower 技术配置要点

配置入口：在配置 Repository 的位置，每个 Repository 都会有它独立对应的 vPower NFS Server。

必要端口：

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU2FvCd8FPVLZpCpniaFGDBr7OLUV4YRXrTBy39LWn0U1icmTISO0auAy4O0Khd5FuVnsfDpcZzOJz4w/640?wx_fmt=png)

以上 2049+和 1058+这两个端口系统会自动侦测，如果不可用会自动增加探测更新成可用端口，而 6161 和 111 则不会自动更改，如有必要可以手动更改。

特别注意点：因为在 vPower NFS Server 之中引入了 vPower NFS 缓存技术，因此在实际使用中需要特别注意这个缓存容量的预留和变化。默认情况下，这个缓存位于 C:\Programdata\Veeam\Backup\NFSdatastore 目录下，我们一般会预留至少 100GB 的剩余空间给这个目录，当然这个目录也可以被定为到其他目录中。

而在执行 Instant VM recovery 的任务过程中，Veeam 也同样提供了修改 vPower NFS Cache 目录的功能，可以将 Cache 重定向至有足够空间的生产存储上。

对于 SureBackup，VMDK 的 redo log 则会被存放在 VirtualLab 所指定的 ESXi Datastore 中，完全不用担心以上这一 Cache 目录容量。

Instant VM Recovery 的扩展用法

使用 Instant VM Recovery 其实远不止虚拟机立刻开机这样简单的功能，在此我仅以一些特殊的例子来说明一下。

使用 IR 进行恢复磁盘 HotAdd 操作

- 不连接网络，不开机的情况下，启动 Instant VM Recovery；
- 注册完虚拟机后，将 IR 出来的虚拟机中的虚拟磁盘 Attach 到生产环境的 VM 中；
- 把挂载的磁盘在操作系统内联机；
- 在操作系统内拷贝还原数据；
- 卸载磁盘；
- 取消 IR 操作。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU2FvCd8FPVLZpCpniaFGDBr7XHvSkNicalDK2nLAp91jgGHNZ4XffZyP43LTIefmY0sjN5S2cbqOYZw/640?wx_fmt=png)

利用空 VMDK 恢复非标文件系统数据

- 不连接网络，恢复后开机，启动 Instant VM Recovery；
- 创建一个新的 VMDK
- 将这个 VMDK Attach 到 IR 出来的 VM 中
- 登入系统，按照特殊需求格式化 VMDK 磁盘并拷贝数据
- 从 IR 出来的 VM 中移除新 VMDK 并投入生产系统使用
- 停止 IR 虚拟机。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU2FvCd8FPVLZpCpniaFGDBr7hSZZp2py64oRdJrMsoAO6kFIZsBCCHLRlKLR9Zia5nItGuYPI4qeAuA/640?wx_fmt=png)


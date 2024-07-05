---
layout: post
title: 新年第一篇 - Veeam 9.5U3 集中管理 Agent 详解
tags: Agent
categories: 数据保护
---

# VBR 中的 Agent 集中管理

本次更新加入了 Agent 的集中管理，界面上发生了很大变化，原有的 Backup & Replication 更名成为 Home，而原有的 Virtual Machine 更名为 Inventory。Agent 的管理功能都会搬到 Inventory 下面的 Physical & Cloud Infrastructure 下。

![17owIe.png](https://s2.ax1x.com/2020/02/12/17owIe.png)

Veeam 管理 Agent 的方式还是和其他 Veeam 的功能非常类似，非常简单的 3 部曲方式：

- 创建 Protection Group – 定义并自动发现需要保护的对象。
- 创建 Job 或者 Policy – 定义备份任务或者备份策略实现备份。
- 执行 Restore – 通过多种还原手段实现数据还原。

我们先来一起熟悉下 Physical & Cloud Infrastructure 界面。

在这个节点中会出现一些类似文件夹的图标，在软件升级完成后，会立刻出现 Manually Added、Unmanaged 这两个系统内置文件夹，而在我们开始创建新的 Protection Group 后，又会出现一些我们创建的文件夹，每一个文件夹就是一个 Protection Group，里面会包含一组需要保护的服务器或者工作站。

创建 Protection Group

![17oaVO.png](https://s2.ax1x.com/2020/02/12/17oaVO.png)

又是老套路，Veeam 经典的向导式操作方式，创建 Protection Group

![17odaD.png](https://s2.ax1x.com/2020/02/12/17odaD.png)

 

支持 3 种添加 Protection Group 的方式，其实也就是 3 种不同的服务器/工作站添加模式

- Individual computers

![17oNqK.png](https://s2.ax1x.com/2020/02/12/17oNqK.png)

这种方式可以手工逐台 Computers 添加，支持 Host Name 或者 IP address，然后 Credentials 中输入合适的账号密码即可。

- Microsoft Active Directory objects

 

![17otr6.png](https://s2.ax1x.com/2020/02/12/17otr6.png)

![17oBPH.png](https://s2.ax1x.com/2020/02/12/17oBPH.png)

 这种方式需要先点击 Change 按钮设定 AD 相关信息，包括 AD 的域名和域管理员账号，然后就可以找到 AD 中的所有对象，按照对象的方式动态添加被保护的服务器/工作站。 

![17oDGd.png](https://s2.ax1x.com/2020/02/12/17oDGd.png)

自动排除不需要使用 Agent 进行保护的对象，特别是虚拟机。

- Computers from CSV files

![17orRA.png](https://s2.ax1x.com/2020/02/12/17orRA.png)

这种模式只需手工编辑 host name 或者 ip 地址到一个 CSV 文件，然后指定从这个文件读取 host 列表即可。

![17osxI.png](https://s2.ax1x.com/2020/02/12/17osxI.png)

为不同的 Host 分别指定合适的管理员账号。

![17o6Mt.png](https://s2.ax1x.com/2020/02/12/17o6Mt.png)

设定自动发现和扫描的间隔，在扫描完成后是否进行 Agent 和 Windows CBT 驱动的自动推送安装，安装完成后如果有需要重新启动，是否自动启动。

![17ogqf.png](https://s2.ax1x.com/2020/02/12/17ogqf.png)

检测推送分发 Agent 的服务器的状态，检测完成后，Protection Group 就创建完成了。

Veeam Agent for Windows 和 Veeam Agent for Linux 略有不同，我们先看看 Windows 的。

## Veeam Agent for Windows 的集中管理 

![17oRZ8.png](https://s2.ax1x.com/2020/02/12/17oRZ8.png)

在自动发现了一组机器后，Protection Group 中会罗列出所有自动扫描到的机器，在这个 Protection Group 中，我设定了不自动安装 Agent，这时候对于需要安装 Agent 的机器，我可以通过屏幕上方的工具栏进行 Agent 的安装和卸载工作，同时我还能完成该服务器/工作站的重启、恢复介质的创建工作，在原先，这些工作都能够在 Veeam Agent for Windows 的客户端上完成，现在已经全部集成到了 VBR 上。

对于 Windows 服务器，创建备份任务也非常的简单，只要点击 Add to Backup 即可，还是经典的向导界面：

![17oWdS.png](https://s2.ax1x.com/2020/02/12/17oWdS.png)

在这里我不详细展开介绍 Workstation 和 Managed by Agent 内容，这些选项能够为我们在远程站点备份数据的时候带来帮助，功能和之前的 2.0 版本中非常相似，我们重点来看看 Managed by backup server 这个选项的功能。

![17ofIg.png](https://s2.ax1x.com/2020/02/12/17ofIg.png)

设定备份任务名字

![17o4iQ.png](https://s2.ax1x.com/2020/02/12/17o4iQ.png)

选择被保护的服务器，在这里还能定义保护的服务器的顺序。

![1HPNUH.png](https://s2.ax1x.com/2020/02/12/1HPNUH.png)

选择保护模式，还是和之前的完全一样。

![1HPdPA.png](https://s2.ax1x.com/2020/02/12/1HPdPA.png)

选择备份至哪个存储库，一样可以在高级选项中设定 Synthetic full 和 Active full 的时间。

![1HPw8I.png](https://s2.ax1x.com/2020/02/12/1HPw8I.png)

应用感知，也是 Veeam 经典模式。

![1HPtVe.png](https://s2.ax1x.com/2020/02/12/1HPtVe.png)

依旧是经典的计划任务设定。这样就完成了一个 Windows Agent 的备份任务设置。

![1HPU5d.png](https://s2.ax1x.com/2020/02/12/1HPU5d.png)

任务执行情况，在执行过程中会截断日志并且收集 Windows 的驱动程序，用于后续的恢复。

![1HP02t.png](https://s2.ax1x.com/2020/02/12/1HP02t.png)

在 Home 界面中，能够找到备份下来的存档，选中备份存档，可以执行一系列 Veeam 支持的恢复操作，依旧还是 Veeam 经典的管理方式，和虚拟化的恢复完全一致。

![1HPBxP.png](https://s2.ax1x.com/2020/02/12/1HPBxP.png)

而物理机的裸机恢复则是由 Recovery Media 来完成，向导式的 Recovery Media 生成界面也从客户端搬迁至 VBR 中。

## Veeam Agent for Linux 的集中管理

![1HPrKf.png](https://s2.ax1x.com/2020/02/12/1HPrKf.png)

和 Windows 不一样，Linux Agent 少了 Recovery Media 创建、CBT 驱动安装以及 Reboot 按钮。 

![1HPsr8.png](https://s2.ax1x.com/2020/02/12/1HPsr8.png)

创建备份任务，也是向导模式，只是没有了 Cluster 支持，暂时 Linux 平台无法支持 Cluster 模式。

![1HPyqS.png](https://s2.ax1x.com/2020/02/12/1HPyqS.png)

备份任务名称和描述设定

![1HPcVg.png](https://s2.ax1x.com/2020/02/12/1HPcVg.png)

选择被保护的服务器/工作站。

![1HPWPs.png](https://s2.ax1x.com/2020/02/12/1HPWPs.png)

选择备份模式

![1HPfGn.png](https://s2.ax1x.com/2020/02/12/1HPfGn.png)

选择备份存储库和还原点数量。

![1HPh2q.png](https://s2.ax1x.com/2020/02/12/1HPh2q.png)

设定 Linux 的应用感知，主要通过 Script 来实现，同样文件系统的索引也是在这一步来进行。

![1HPIMV.png](https://s2.ax1x.com/2020/02/12/1HPIMV.png)

经典的计划任务界面，设定时间后，就创建好 Linux 备份任务了。

![1HPorT.png](https://s2.ax1x.com/2020/02/12/1HPorT.png)

备份任务执行也是经典 Veeam 界面，相信大家都很熟悉了。

![1HPHZF.png](https://s2.ax1x.com/2020/02/12/1HPHZF.png)

对于 Linux 存档的恢复，在 VBR 中操作相对来说较少，仅支持文件级恢复、还原至 Azure 以及导出成虚拟磁盘这几项，而如果需要进行裸机还原，则需要在 Veeam 官网下载 Linux 专用的 Recovery Media。

电梯直达链接：https://download2.veeam.com/veeam-recovery-media-2.0.0.400_x86_64.iso

另外，如果需要查看更详细的 Release Notes 和下载更新包，可以点击阅读原文。
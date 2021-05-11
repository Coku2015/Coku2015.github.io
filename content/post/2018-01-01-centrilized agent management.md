---
layout: post
title: 新年第一篇 - Veeam 9.5U3集中管理Agent详解
tags: Agent
categories: 数据保护
---



# VBR中的Agent集中管理

本次更新加入了Agent的集中管理，界面上发生了很大变化，原有的Backup & Replication更名成为Home，而原有的Virtual Machine更名为Inventory。Agent的管理功能都会搬到Inventory下面的Physical & Cloud Infrastructure下。

![17owIe.png](https://s2.ax1x.com/2020/02/12/17owIe.png)

Veeam管理Agent的方式还是和其他Veeam的功能非常类似，非常简单的3部曲方式：

- 创建Protection Group – 定义并自动发现需要保护的对象。
- 创建Job或者Policy – 定义备份任务或者备份策略实现备份。
- 执行Restore – 通过多种还原手段实现数据还原。

我们先来一起熟悉下Physical & Cloud Infrastructure界面。

在这个节点中会出现一些类似文件夹的图标，在软件升级完成后，会立刻出现Manually Added、Unmanaged这两个系统内置文件夹，而在我们开始创建新的Protection Group后，又会出现一些我们创建的文件夹，每一个文件夹就是一个Protection Group，里面会包含一组需要保护的服务器或者工作站。

创建Protection Group

![17oaVO.png](https://s2.ax1x.com/2020/02/12/17oaVO.png)

又是老套路，Veeam经典的向导式操作方式，创建Protection Group

![17odaD.png](https://s2.ax1x.com/2020/02/12/17odaD.png)

 

支持3种添加Protection Group的方式，其实也就是3种不同的服务器/工作站添加模式

- Individual computers

![17oNqK.png](https://s2.ax1x.com/2020/02/12/17oNqK.png)

这种方式可以手工逐台Computers添加，支持Host Name或者IP address，然后Credentials中输入合适的账号密码即可。

- Microsoft Active Directory objects

 

![17otr6.png](https://s2.ax1x.com/2020/02/12/17otr6.png)

![17oBPH.png](https://s2.ax1x.com/2020/02/12/17oBPH.png)

 这种方式需要先点击Change按钮设定AD相关信息，包括AD的域名和域管理员账号，然后就可以找到AD中的所有对象，按照对象的方式动态添加被保护的服务器/工作站。 

![17oDGd.png](https://s2.ax1x.com/2020/02/12/17oDGd.png)

自动排除不需要使用Agent进行保护的对象，特别是虚拟机。

- Computers from CSV files

![17orRA.png](https://s2.ax1x.com/2020/02/12/17orRA.png)

这种模式只需手工编辑host name或者ip地址到一个CSV文件，然后指定从这个文件读取host列表即可。

![17osxI.png](https://s2.ax1x.com/2020/02/12/17osxI.png)

为不同的Host分别指定合适的管理员账号。

![17o6Mt.png](https://s2.ax1x.com/2020/02/12/17o6Mt.png)

设定自动发现和扫描的间隔，在扫描完成后是否进行Agent和Windows CBT驱动的自动推送安装，安装完成后如果有需要重新启动，是否自动启动。

![17ogqf.png](https://s2.ax1x.com/2020/02/12/17ogqf.png)

检测推送分发Agent的服务器的状态，检测完成后，Protection Group就创建完成了。

Veeam Agent for Windows和Veeam Agent for Linux略有不同，我们先看看Windows的。

## Veeam Agent for Windows 的集中管理 

![17oRZ8.png](https://s2.ax1x.com/2020/02/12/17oRZ8.png)

在自动发现了一组机器后，Protection Group中会罗列出所有自动扫描到的机器，在这个Protection Group中，我设定了不自动安装Agent，这时候对于需要安装Agent的机器，我可以通过屏幕上方的工具栏进行Agent的安装和卸载工作，同时我还能完成该服务器/工作站的重启、恢复介质的创建工作，在原先，这些工作都能够在Veeam Agent for Windows的客户端上完成，现在已经全部集成到了VBR上。

对于Windows服务器，创建备份任务也非常的简单，只要点击Add to Backup即可，还是经典的向导界面：

![17oWdS.png](https://s2.ax1x.com/2020/02/12/17oWdS.png)

在这里我不详细展开介绍Workstation和Managed by Agent内容，这些选项能够为我们在远程站点备份数据的时候带来帮助，功能和之前的2.0版本中非常相似，我们重点来看看Managed by backup server这个选项的功能。

![17ofIg.png](https://s2.ax1x.com/2020/02/12/17ofIg.png)

设定备份任务名字

![17o4iQ.png](https://s2.ax1x.com/2020/02/12/17o4iQ.png)

选择被保护的服务器，在这里还能定义保护的服务器的顺序。

![1HPNUH.png](https://s2.ax1x.com/2020/02/12/1HPNUH.png)

选择保护模式，还是和之前的完全一样。

![1HPdPA.png](https://s2.ax1x.com/2020/02/12/1HPdPA.png)

选择备份至哪个存储库，一样可以在高级选项中设定Synthetic full和Active full的时间。

![1HPw8I.png](https://s2.ax1x.com/2020/02/12/1HPw8I.png)

应用感知，也是Veeam经典模式。

![1HPtVe.png](https://s2.ax1x.com/2020/02/12/1HPtVe.png)

依旧是经典的计划任务设定。这样就完成了一个Windows Agent的备份任务设置。

![1HPU5d.png](https://s2.ax1x.com/2020/02/12/1HPU5d.png)

任务执行情况，在执行过程中会截断日志并且收集Windows的驱动程序，用于后续的恢复。

![1HP02t.png](https://s2.ax1x.com/2020/02/12/1HP02t.png)

在Home界面中，能够找到备份下来的存档，选中备份存档，可以执行一系列Veeam支持的恢复操作，依旧还是Veeam经典的管理方式，和虚拟化的恢复完全一致。



![1HPBxP.png](https://s2.ax1x.com/2020/02/12/1HPBxP.png)

而物理机的裸机恢复则是由Recovery Media来完成，向导式的Recovery Media生成界面也从客户端搬迁至VBR中。

## Veeam Agent for Linux的集中管理

![1HPrKf.png](https://s2.ax1x.com/2020/02/12/1HPrKf.png)

和Windows不一样，Linux Agent少了Recovery Media创建、CBT驱动安装以及Reboot按钮。 

![1HPsr8.png](https://s2.ax1x.com/2020/02/12/1HPsr8.png)

创建备份任务，也是向导模式，只是没有了Cluster支持，暂时Linux平台无法支持Cluster模式。

![1HPyqS.png](https://s2.ax1x.com/2020/02/12/1HPyqS.png)

备份任务名称和描述设定

![1HPcVg.png](https://s2.ax1x.com/2020/02/12/1HPcVg.png)

选择被保护的服务器/工作站。

![1HPWPs.png](https://s2.ax1x.com/2020/02/12/1HPWPs.png)

选择备份模式

![1HPfGn.png](https://s2.ax1x.com/2020/02/12/1HPfGn.png)

选择备份存储库和还原点数量。

![1HPh2q.png](https://s2.ax1x.com/2020/02/12/1HPh2q.png)

设定Linux的应用感知，主要通过Script来实现，同样文件系统的索引也是在这一步来进行。

![1HPIMV.png](https://s2.ax1x.com/2020/02/12/1HPIMV.png)

经典的计划任务界面，设定时间后，就创建好Linux备份任务了。

![1HPorT.png](https://s2.ax1x.com/2020/02/12/1HPorT.png)

备份任务执行也是经典Veeam界面，相信大家都很熟悉了。

![1HPHZF.png](https://s2.ax1x.com/2020/02/12/1HPHZF.png)

对于Linux存档的恢复，在VBR中操作相对来说较少，仅支持文件级恢复、还原至Azure以及导出成虚拟磁盘这几项，而如果需要进行裸机还原，则需要在Veeam官网下载Linux专用的Recovery Media。

电梯直达链接：https://download2.veeam.com/veeam-recovery-media-2.0.0.400_x86_64.iso

另外，如果需要查看更详细的Release Notes和下载更新包，可以点击阅读原文。
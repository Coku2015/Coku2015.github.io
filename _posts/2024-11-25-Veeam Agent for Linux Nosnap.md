---
layout: post
title: 使用无快照模块的 Veeam Agent for Linux 备份各种魔改 Linux
tags: 备份
categories: Linux Agent
---

Linux 高度自由的开源系统让每个人都有自己使用它自己的使用方式，这让对于操作系统深度依赖的备份软件变的各种不适。细微的一些变化就会引起备份失败，因此备份软件通常都会有一个兼容列表，不在列表中的系统通常无法工作。

这类问题普遍存在于开源世界，虽然没办法一把解决这个问题，但是如果能解决大部分，那也是不错的，不是吗？

在 Veeam Linux Agent 中，有一种非常特殊的工作模式，我把它称为万金油模式。它不需要加载 Veeamsnap 驱动程序，不需要使用 dkms 模块编译驱动程序，因此能够适配绝大多数环境，实现非标准环境的数据备份。

我们知道，Veeam 官方支持的 Linux 操作系统列表有限，国内常见的欧拉、龙晰、统信、麒麟等系统，按照常规的 Veeam Linux Agent 配置步骤来进行是肯定无法安装的，这时候手工安装 Veeam Linux Agent no-snap 的模式，就能解决这个问题，让这些系统也能够备份至 Veeam 的存储库中。

另外，如果稍稍加一些小条件，还能实现整机备份和 BMR 恢复。

本文以 OpenEuler 为例，来给大家详细说说整个过程以及其中的注意事项。

### 去哪里找这个 Agent?
和其他的 Veeam Agent for Linux 一样，我们有两种方式可以获取到这个 Agent 安装包。
一种是在 VBR 的控制台上，我们只需创建一个类型为`Computers with pre-installed backup agents`的 Protection group。

![Xnip2024-11-23_13-15-37](https://s2.loli.net/2024/11/24/E6OepKzJVAI3YoL.png)

在创建向导中，可以找到各种 Linux 版本的 Nosnap 的 Agent，本次实验我们用于 Red Hat 系魔改的 Euler 系统，所以我们选择`Red Hat 9 x64 no-snap - 6.2.0.101`即可。

![Xnip2024-11-23_13-18-08](https://s2.loli.net/2024/11/24/IaeRylhOztMubLN.png)

在设置完 Export 路径后，就可以点击 Apply 生成 no-snap 的安装包，在 Export path 中，就能找到对应的这个 rpm 包。

![Xnip2024-11-23_13-18-33](https://s2.loli.net/2024/11/24/XQIZ1Rq4j2iafmk.png)

另外，我们还能够在 Veeam 官方的软件 repository 中，直接下载到这个 nosnap 的包。

网址如下：https://repository.veeam.com/backup/linux/agent/rpm/el/9/x86_64/

最新版本需要下载两个文件，一个是 veeam-nosnap-6.2.0.101-1.el9.x86_64.rpm，另外一个是 veeam-libs-6.2.0.101-1.x86_64.rpm。

### 安装和配置
这个包安装非常简单，直接一个`yum install ~/nosnap/veeam*`命令即可。yum 会自动解析当前需要的依赖包，一般来说也没什么额外的依赖包需要，安装在几秒钟内顺利完成。

![Xnip2024-11-23_16-54-58](https://s2.loli.net/2024/11/24/n48HXxrb2ZCM19T.png)

安装完成后，我们可以回到 VBR 控制台上，找一个合适的 Protection Group 或者新建一个 Protection Group，然后再将这台机器添加进来，这样 VBR 就能管理这台 OpenEuler 了。

![Xnip2024-11-23_16-59-37](https://s2.loli.net/2024/11/24/3sDrLqCpFEWOZen.png)

为新的 Protection Group 起个名字：

![Xnip2024-11-23_17-00-01](https://s2.loli.net/2024/11/24/PdnbtLm2J8qH3Ne.png)

以 IP 地址的方式添加目标计算机：

![Xnip2024-11-23_17-05-49](https://s2.loli.net/2024/11/24/oOxPqcJHu1Sa7nB.png)

添加后，走完向导，VBR 会检测下目标服务器上已经安装的 Agent，发现已经安装后，就不会再去检测兼容性和安装条件了，直接使用已安装的配置。

![Xnip2024-11-23_17-07-32](https://s2.loli.net/2024/11/24/9A4ITO5cFqPQaZX.png)

这时候，VBR 控制台上正确的显示了当前的操作系统为 OpenEuler。

![Xnip2024-11-23_17-07-53](https://s2.loli.net/2024/11/24/LZlMQ6Nuib4njco.png)

### 备份模式
no-snap Linux agent 其实并不是完全没有 snap，这个 Agent 它其实有两种工作模式，一种是真的不拍快照，这样对于有些处于打开状态的文件，比如备份那一刻，某个文件正在编辑，那么这个文件可能就只能被跳过了；而另外一种则是不调用 Veeamsnap，使用 LVM 卷的 snapshot 替代 Veeamsnap 进行工作，这个模式几乎就和 Veeamsnap 非常相似了，不同之处在于，两者快照技术的不同，LVM snapshot 的所有前提条件都需要被正常满足才能让这个模式正常工作。

### LVM 快照前提条件

简单来说，一句话，有足够的 Free PE. 大家可以通过 vgdisplay 命令查到这个空间，如下图。

![Xnip2024-11-23_16-58-44](https://s2.loli.net/2024/11/24/Ek2dSUHqQ1fvFXn.png)

LVM 卷快照，会将快照的变化数据存放在这个区域，因此在做 LVM 分区规划的时候需要提前考虑这部分区域空间分配，至少要留出总磁盘容量的 10%~20%。

### 备份和恢复

备份恢复没有什么特别的，Veeam Agent 能够自动感知到底层的配置，自动使用 LVM 卷的快照能力备份数据。而在恢复选项上，所有常规能使用的恢复手段，对于这个备份存档也都可用，包括 BMR 恢复。

使用 LVM 卷快照备份，我们可以在备份作业设置时，选择`Entire Machine`或者`Volume level backup`模式。

![Xnip2024-11-23_17-09-07](https://s2.loli.net/2024/11/24/4Cb2fH8iqGsrDN6.png)

这样在备份作业进行时，能够正常调用快照进行备份。

![Xnip2024-11-23_17-17-05](https://s2.loli.net/2024/11/24/PMusKBy1efhD4aZ.png)

备份完成后，正常的所有恢复选项都可以使用，包括 BMR、FLR、应用程序对象恢复、跨平台迁移等等、

如果需要进行裸机 BMR 恢复，就需要到 Veeam 官方的软件仓库中下载合适的 Recovery Media 来引导裸机服务器。下载地址为：

https://repository.veeam.com/backup/linux/agent/veeam-recovery-media/x64/veeam-recovery-amd64-6.0.0.iso

### BMR 恢复过程

我们用这个下载的 ISO 引导服务器后，目标服务器会立刻自动进入 Veeam 的引导界面，这个界面上，我们选择第一项`Veeam recovery 6.1.0-23-amd64`就行了。

![Xnip2024-11-24_15-03-40](https://s2.loli.net/2024/11/24/HAIP3QlkRTZi1Gu.png)

选择后，系统会提示 SSH 连接，如果不方便控制台操作，可以选择 Start SSH now，这样 Veeam Recovery Media 也支持远程 SSH 控制进行恢复。

![Xnip2024-11-24_15-03-55](https://s2.loli.net/2024/11/24/5QoZpFyjKvODNXs.png)

接下来，会有个使用前的惯例，接受许可协议。两个选项都选上`X`后选`Continue`继续。

![Xnip2024-11-24_15-04-42](https://s2.loli.net/2024/11/24/6VGHbxczotvSlpm.png)

这时候系统会进入 Veeam Recovery Media 的恢复主菜单，上面有卷恢复、文件恢复、设置网络、退回到 shell 以及重启关机这些菜单。

![Xnip2024-11-24_15-04-59](https://s2.loli.net/2024/11/24/dqheRHX3WU6FYTw.png)

使用前，我们先配置下网络，这样我们一会儿就能通过网卡连接到 VBR 服务器上读取备份存档。网络配置也不复杂，常规的 IPv4 的 IP 地址即可，同时根据需要配置上 DNS 服务器。

![Xnip2024-11-24_15-06-23](https://s2.loli.net/2024/11/24/K2b87FR9MnGXUva.png)

配置完成 IP 后，直接点 restore Volume 就会弹出选择备份位置的窗口，这里我们选 VBR 备份服务器。

![Xnip2024-11-24_15-07-03](https://s2.loli.net/2024/11/24/eZPVfU3h8i9T7Rw.png)

需要注意的是，为了更安全的恢复，我们需要从备份服务器上为相关的备份存档创建一个 Token。Token 创建后，需要妥善保存，默认可以使用 24 小时。

![Xnip2024-11-24_15-08-38](https://s2.loli.net/2024/11/24/3fYDH9STz6GlKOd.png)

在备份服务器的连接界面上，输入 IP 地址和端口，选择 Recovery Token 并输入刚刚生成的 Token 后点击 Next 来连接。

![Xnip2024-11-24_15-11-32](https://s2.loli.net/2024/11/24/sMgAy1BY7H6PWZm.png)

如果自签名证书不信任的情况下，系统有可能会像我一样弹出一个警告，这搞关系不大，直接选 Accept 即可。

![Xnip2024-11-24_15-11-54](https://s2.loli.net/2024/11/24/cts6G5fNOLxA8Uh.png)

这时候，我们的还原点就会出现，选择这个还原点进行下一步。

![Xnip2024-11-24_15-12-27](https://s2.loli.net/2024/11/24/iE8qUojA6XgRTL7.png)

这时候系统自动读取当前分区，如果分区大小相同的情况下，这时候，自动选择右边的相关设备进行 Mapping 即可。Mapping 完成后按 S 键就能开始进行自动还原了。

![Xnip2024-11-24_15-13-52](https://s2.loli.net/2024/11/24/zudAtVTZkNIPKef.png)

其他的恢复方法，还有即时虚拟机恢复、文件级恢复，导出成 VHD 和 VMDK 等等。



### 注意事项

以上的 no-snap 的方式进行数据备份和恢复，Veeam 官方的系统支持列表依然非常重要，不在官方支持列表中的各种操作系统，虽然能够正常工作了，但是 Veeam 官方售后不会对这些操作系统进行售后支持，任何技术问题，可能需要我们聪明的 Linux 系统管理员自己搞定了。


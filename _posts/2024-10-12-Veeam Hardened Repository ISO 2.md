---
layout: post
title: 【社区预览版】Managed Hardened Repository ISO by Veeam（下）
tags: 备份
categories: Repository
---

上一期，我给大家介绍了国庆前 Veeam 发布的 Veeam Managed Hardened Repository 社区预览版，今天这一篇，我手把手带大家一步一步来安装和配置这个系统。

本次帖子中的部署，为了方便我使用了 VMware 平台上的虚拟机进行部署，大家如果有条件完全可以在物理硬件上进行部署，部署过程中如果发现任何问题，可以随时联系我进行反馈。

###  虚拟机配置

本次安装环境如下：

- vSphere 虚拟机 Guest OS 类型：Redhat Enterprise Linux 9
- vCPU：2 个
- RAM： 8G
- 2 个虚拟磁盘，一个 150G，一个 200GB

需要注意的是，不管是用虚拟机还是物理机进行这个系统的安装，必须启用 UEFI 中的安全引导 (secure boot) 功能，这是强制的必要条件，也是安全加固过程中的重要手段之一。

在 VMware 虚拟机的配置页面上，可以找到下图确认，默认情况下对于 Redhat 9，这个选项是启用状态。

![Xnip2024-10-12_15-03-48](https://s2.loli.net/2024/10/12/usJjLcoBGiUdOKr.png)

### 安装系统

开机后从光驱引导，会进入“Install Hardened Repository”安装界面，需要注意的是，如果安装界面下图不同，提示 Rocky Linux 9 的安装界面，那么上一步的 Secure Boot 配置出现了问题。

![Xnip2024-10-09_19-20-48](https://s2.loli.net/2024/10/12/21wZWnl7OqrvNIX.png)



接下去，ISO 进入简单的引导，就可以进入图形化安装界面。

![Xnip2024-10-09_19-22-43](https://s2.loli.net/2024/10/12/P7cSH3z5bUnDqxm.png)

安装界面非常简单，可以看到左上角的系统名称提示：Rocky Linux provided by Veeam，而右上角会有红色的 Pre-release/Testing 的提醒，不建议在生产环境中使用。

这个界面和绝大多数 Redhat 系的 Linux 安装界面非常相似，只是更加简洁，在这个界面上，需要做 4 个设置：

- Keyboard
- Installation Destination
- Time & Date
- Network & Host Name

这些设置基本上都非常简单，属于一看就懂的，也无需多解释。

#### Keyboard

键盘设置，只需要点进去确认下，我们国内大多数都是用 us 键盘布局。

![Xnip2024-10-09_19-23-21](https://s2.loli.net/2024/10/12/mwBYW9yS3XPIxk2.png)

#### Installation Destination

这部分可以点进去确认下，一般安装程序会自动识别现有磁盘，最小空间的用于安装系统，另外大的空间会用于 VBR 的 Hardened Repository 空间。点击 Return 可以回前一页。

![Xnip2024-10-09_19-24-21](https://s2.loli.net/2024/10/12/Hti8Z3LBxAK29QJ.png)

#### Time & Date

这里需要设定下时区和 NTP Server。我把时区设置为 Asia/Shanghai，时间服务器加上了阿里云的 ntp.aliyun.com。

![Xnip2024-10-09_19-29-28](https://s2.loli.net/2024/10/12/nmjE5YCxis8gvKq.png)

#### Network

在网络设置里，网卡会被自动识别出来，然后可以配置上 IP 地址和主机名，这里如果有多块网卡，可以设置网卡的 bonding。

![Xnip2024-10-12_16-40-36](https://s2.loli.net/2024/10/12/29Oon8rF6qP5dSW.png)

这样设置之后，Begin Installation 按钮就会蓝色亮起，点它就能进入全自动的安装过程了。

![Xnip2024-10-12_16-47-53](https://s2.loli.net/2024/10/12/FT6UiLvGs2jax4q.png)

安装非常快，大约几分钟，系统就装完，可以点击 Reboot System 进入安装完成后的 Hardened Repository 系统。

![Xnip2024-10-12_16-49-00](https://s2.loli.net/2024/10/12/nZsGYJzW7LPTi2k.png)

### 配置 Hardened Repository

系统重新引导后，会看到 Rocky Linux 的引导界面，这样系统就安装成功了，选第一项就能进入 Hardened Repository 系统。

![Xnip2024-10-09_19-56-58](https://s2.loli.net/2024/10/12/ed3bxf2RurMaWhE.png)

进入系统后，会看到非常简洁的命令行欢迎界面，如下图，它会提示当前是 Veeam Hardened Repository 系统，它的 IP 地址是：10.10.1.83，以及一个登入提示。

![Xnip2024-10-12_16-57-26](https://s2.loli.net/2024/10/12/aPZBtFkpgl7TcYj.png)

输入 vhradmin 就能进行登入，默认密码是 vhradmin，但是需要注意的是，在第一次登入的时候，就会提示进行密码修改，这个密码修改会有严格的复杂性要求和时间要求，请在登入前提前准备好以下复杂性的避免：

- 至少一个数字
- 至少一个小写字母
- 至少一个特殊字符
- 15 个字符以上
- 4 个连续的字符不能属于同一类（比如密码中连续 4 个小写字母或者连续 4 个数字）
- 一天只能修改一次密码

密码修改完成后，就会进入首次配置界面，需要 Accept 一下 License Agreement。

![Xnip2024-10-09_21-20-56](https://s2.loli.net/2024/10/12/Z5oLmFErNA4bfzt.png)

点击 I Accept 之后，会进入 Configurator 的主菜单。

![Xnip2024-10-09_21-21-35](https://s2.loli.net/2024/10/12/l4dH2bNuApIe7oY.png)

这个 Configurator 有一些基本配置，其中 Network settings、Time Settings 和 Change hostname 在安装阶段已经设置过了，在这个菜单中，还能进行调整。

除了这个之外，还有几项配置功能：

- Proxy Settings
- Change Password
- Reset time lock
- Start SSH
- Logout
- Reboot
- Shutdown



这些配置大部分没啥特别，一看名字就知道干啥用。有两个需要注意，Proxy Setting，可以帮助管理员设置无法直接上网的系统通过 Proxy 访问 repository.veeam.com 网站，完成 Hardened repository 系统的在线更新；而 Reset time lock 用于 Hardened repository 长期处于关机后，时间出现重大的改变的时候，进行系统时间的解锁。



#### Start SSH

这个 Configurator 的最重要的功能，就是 Start SSH 菜单，这是首次在 VBR 中配置注册需要打开的，否则 VBR 中目前就无法完成首次配置，在首次配置完成后，需要回来 Stop SSH。

点击 Start SSH 后，屏幕上会出现用于在 VBR 中配置需要的所有信息，包括用户名、密码、主机名、IP 地址、系统指纹等。

![Xnip2024-10-12_17-20-33](https://s2.loli.net/2024/10/12/EVbW9kRTd7ZeINP.png)

这时候，需要回到 VBR 中进行配置了，在配置结束前，保持这个屏幕不要点击 Continue 按钮。

在 VBR 中添加选择 Hardened Repository 类型，进入 Linux 主机的添加，在这里输入用户名密码，不需要勾选`Use "su" if "sudo" fails`

![img](https://s2.loli.net/2024/10/12/3AdjnWTVqxswNuC.png)

接下去只要一路 Next 就能完成这个 Linux 主机的添加。添加完成后，会返回 Repository 的添加向导。在 Repository 向导中，需要选择一下挂载的空间目录，如下图：

![Xnip2024-10-12_17-34-19](https://s2.loli.net/2024/10/12/VQG9FlrpAtxPIa7.png)

目录的路径是/mnt/veeam-repository01，这个路径下的文件系统已经被正确的格式化成了 XFS，能够支持 fast clone 功能。配置完成后，在 Repository 列表中，能够看到配置结果。

![Xnip2024-10-12_17-37-43](https://s2.loli.net/2024/10/12/bpW5A3EtKDjrm7I.png)

这时候，回到 Hardened Repository 的 Linux 控制台，如果时间超过了内置的 timeout 时间，该控制台会返回到最初始的登陆界面，我们需要重新登入然后 stop SSH

![img](https://s2.loli.net/2024/10/12/IY4vSLXzFfNPEaW.png)

这样，Hardened Repository 系统就完全准备完了，可以进行接下去的备份和还原测试了。




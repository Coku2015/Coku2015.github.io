---
layout: post
title: 【社区预览版】Managed Hardened Repository ISO by Veeam（上）
tags: 备份
categories: Repository
---

自从Veeam v11起，Veeam推出了加固的备份存储库，这个存储库已经在全球范围内被Veeam的客户广泛使用，很多客户使用自己的Linux系统构建了加固存储库，为Veeam提供安全可靠的数据存储，成功抵抗了各种勒索病毒的攻击。

在过去的几年里，为了能帮大家更方便的配置加固存储库，我曾经出过不少脚本和工具方便大家使用：

-  [用了这个方法，您的备份数据再也不怕被勒索了](https://blog.backupnext.cloud/2021/03/hardened-linux-repository/)
- [Veeam Hardened Linux Repository Configurator](https://blog.backupnext.cloud/2022/02/Veeam-hardened-linux-repository-configurator/)
- [Ubuntu系统用于Veeam加固存储库的进一步安全加固](https://blog.backupnext.cloud/2024/02/Veeam-hardened-ubuntu/)



在9/30，Veeam R&D团队正式发布了Hardened Repository的另外一种部署方式，一个用于从“零”开始搭建系统的Linux ISO，管理员可以用这个Veeam封装的ISO快速部署裸机服务器，安装Hardened Repository操作系统，安装完成后，该系统就已经部署了Veeam Hardened Repository的一系列最佳实践，管理员可以在VBR中进行后续的配置和管理。



### 功能说明

这是一个Veeam封装的Linux系统安装盘，Linux系统使用的是Rocky Linux，在这个系统安装完成后，对于底层系统会自动应用DISA STIG安全配置文件，禁用SSH并启用时间修改保护。该系统内置了Hardened Repository Configurator工具，该工具能够：

- 配置系统网络
- 设置HTTP代理
- 修改主机名
- 修改vhradmin这个user的密码
- 临时启用SSH
- 升级OS和Veeam组件
- 重置时间更改保护
- 注销/重启/关机
- 10分钟后自动注销。

### 系统需求

这个Linux系统可以安装在任何[Redhat官方兼容列表](https://catalog.redhat.com/hardware)中所列出的物理硬件上，对于CPU和内存的需求，请遵循Veeam帮助文档中列出的最佳实践的要求，对于存储，必须准备至少两个物理卷，比如/dev/sda、/dev/sdb，而安装操作系统的卷最小的容量为100GB，否则系统安装过程中就会出现报错。

该系统仅支持内置Raid卡或者磁盘控制器的存储系统，对于通过iSCSI或者FC挂载到服务器上的LUN，无法正常工作。对于软Raid和假Raid系统，也无法支持。所有存储的配置必须在安装系统前完成，系统安装开始后，该系统安装程序会识别到相关磁盘并进行自动格式化。

系统安装过程中，安装程序会自动选择容量最小的磁盘安装操作系统，所以在磁盘选择配置的时候，请务必保证期望安装系统的磁盘小于数据盘。



### 操作系统安全设计逻辑

这个Hardened Repository安装盘设计了以下安全配置：

- 自动应用DISA STIG安全配置文件。这个包括密码复杂度要求、应用程序白名单、UEFI安全启动等等。
- 安装完成后禁用所有网络服务侦听，包括禁用SSH。
- 在这个系统上配置了两个用户，一个是veeamsvc，另外一个是vhradmin。
  - veeamsvc用来运行VBR的所有服务，并且密码是通过Hardened Repository Configurator自动生成的，该用户具有sudo权限，在VBR中配置Hardened Repository会用到这个账号进行一次性配置。
  - vhradmin账号没有任何的sudo权限，并且只能运行Hardened Repository Configurator这个程序，用于维护系统的基本配置。这个账号的默认密码为“vhradmin”，该密码会强制在第一次登陆时修改。

- 所有安全自动更新来自repository.veeam.com源，如需获取自动更新，需要开通这个网站的访问权限。




目前，这个加固存储库系统开始了社区预览版，版本号是0.1.15，有兴趣的朋友可以到[Veeam社区论坛](https://forums.veeam.com/veeam-backup-replication-f2/hardened-repository-iso-managed-by-veeam-t95750.html)下载试用。因为是技术预览版，不建议在生产环境中商用，并且暂时也没有Veeam的技术支持。在未来，Veeam计划会发布正式的完整产品版本，到那个版本，Veeam官方的技术支持将会对这个ISO部署的Linux系统提供全面完整的技术支持。

还需要注意的是，这个预览阶段，产品也不支持升级到未来的正式版本，到时候正式版本还是需要完整重新安装。

这个社区技术预览版的所有技术支持，都可以直接在论坛下载贴中提问和回复，如果有需要，也可以公众号上留言联系我。

以上就是本期内容，在下一期我会为大家带来详细的安装说明。

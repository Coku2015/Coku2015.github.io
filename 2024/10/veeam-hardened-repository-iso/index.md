# 【社区预览版】Managed Hardened Repository ISO by Veeam（上）


自从 Veeam v11 起，Veeam 推出了加固的备份存储库，这个存储库已经在全球范围内被 Veeam 的客户广泛使用，很多客户使用自己的 Linux 系统构建了加固存储库，为 Veeam 提供安全可靠的数据存储，成功抵抗了各种勒索病毒的攻击。

在过去的几年里，为了能帮大家更方便的配置加固存储库，我曾经出过不少脚本和工具方便大家使用：

-  [用了这个方法，您的备份数据再也不怕被勒索了](https://blog.backupnext.cloud/2021/03/hardened-linux-repository/)
- [Veeam Hardened Linux Repository Configurator](https://blog.backupnext.cloud/2022/02/Veeam-hardened-linux-repository-configurator/)
- [Ubuntu 系统用于 Veeam 加固存储库的进一步安全加固](https://blog.backupnext.cloud/2024/02/Veeam-hardened-ubuntu/)



在 9/30，Veeam R&D 团队正式发布了 Hardened Repository 的另外一种部署方式，一个用于从“零”开始搭建系统的 Linux ISO，管理员可以用这个 Veeam 封装的 ISO 快速部署裸机服务器，安装 Hardened Repository 操作系统，安装完成后，该系统就已经部署了 Veeam Hardened Repository 的一系列最佳实践，管理员可以在 VBR 中进行后续的配置和管理。



### 功能说明

这是一个 Veeam 封装的 Linux 系统安装盘，Linux 系统使用的是 Rocky Linux，在这个系统安装完成后，对于底层系统会自动应用 DISA STIG 安全配置文件，禁用 SSH 并启用时间修改保护。该系统内置了 Hardened Repository Configurator 工具，该工具能够：

- 配置系统网络
- 设置 HTTP 代理
- 修改主机名
- 修改 vhradmin 这个 user 的密码
- 临时启用 SSH
- 升级 OS 和 Veeam 组件
- 重置时间更改保护
- 注销/重启/关机
- 10 分钟后自动注销。

### 系统需求

这个 Linux 系统可以安装在任何[Redhat 官方兼容列表](https://catalog.redhat.com/hardware)中所列出的物理硬件上，对于 CPU 和内存的需求，请遵循 Veeam 帮助文档中列出的最佳实践的要求，对于存储，必须准备至少两个物理卷，比如/dev/sda、/dev/sdb，而安装操作系统的卷最小的容量为 100GB，否则系统安装过程中就会出现报错。

该系统仅支持内置 Raid 卡或者磁盘控制器的存储系统，对于通过 iSCSI 或者 FC 挂载到服务器上的 LUN，无法正常工作。对于软 Raid 和假 Raid 系统，也无法支持。所有存储的配置必须在安装系统前完成，系统安装开始后，该系统安装程序会识别到相关磁盘并进行自动格式化。

系统安装过程中，安装程序会自动选择容量最小的磁盘安装操作系统，所以在磁盘选择配置的时候，请务必保证期望安装系统的磁盘小于数据盘。



### 操作系统安全设计逻辑

这个 Hardened Repository 安装盘设计了以下安全配置：

- 自动应用 DISA STIG 安全配置文件。这个包括密码复杂度要求、应用程序白名单、UEFI 安全启动等等。
- 安装完成后禁用所有网络服务侦听，包括禁用 SSH。
- 在这个系统上配置了两个用户，一个是 veeamsvc，另外一个是 vhradmin。
  - veeamsvc 用来运行 VBR 的所有服务，并且密码是通过 Hardened Repository Configurator 自动生成的，该用户具有 sudo 权限，在 VBR 中配置 Hardened Repository 会用到这个账号进行一次性配置。
  - vhradmin 账号没有任何的 sudo 权限，并且只能运行 Hardened Repository Configurator 这个程序，用于维护系统的基本配置。这个账号的默认密码为“vhradmin”，该密码会强制在第一次登陆时修改。

- 所有安全自动更新来自 repository.veeam.com 源，如需获取自动更新，需要开通这个网站的访问权限。




目前，这个加固存储库系统开始了社区预览版，版本号是 0.1.15，有兴趣的朋友可以到[Veeam 社区论坛](https://forums.veeam.com/veeam-backup-replication-f2/hardened-repository-iso-managed-by-veeam-t95750.html)下载试用。因为是技术预览版，不建议在生产环境中商用，并且暂时也没有 Veeam 的技术支持。在未来，Veeam 计划会发布正式的完整产品版本，到那个版本，Veeam 官方的技术支持将会对这个 ISO 部署的 Linux 系统提供全面完整的技术支持。

还需要注意的是，这个预览阶段，产品也不支持升级到未来的正式版本，到时候正式版本还是需要完整重新安装。

这个社区技术预览版的所有技术支持，都可以直接在论坛下载贴中提问和回复，如果有需要，也可以公众号上留言联系我。

以上就是本期内容，在下一期我会为大家带来详细的安装说明。


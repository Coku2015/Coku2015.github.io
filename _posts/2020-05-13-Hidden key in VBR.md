---
layout: post
title: VBR 中的那些隐藏键
tags: VBR
---

VBR 升级到 v10 之后增加了很多全新的功能，也多了很多隐藏的快捷键，今天我就来说说这些隐藏的秘密。

### [Ctrl]+鼠标右键

在不少操作中，可以用到这个 Ctrl+鼠标右键调出特别的菜单，一般来说，如果不按住 Ctrl 键，那么直接鼠标右键是看不见这些隐藏的菜单的。

#### NAS 备份中执行一次全新的作业

正常的 NAS 文件备份在 Veeam 中都是永久增量备份，然而还是有些用户会需要用到执行一次全新的全备份，在 NAS 备份中 Veeam 一样提供了这个功能，只需要选中需要执行的备份作业，按住 Ctrl 键后，再点击鼠标右键，那么这个全备份的按钮就会出现。

![start new backup chain.png](https://helpcenter.veeam.com/docs/backup/vsphere/images/file_share_backup_job_start_new_backup_chain.png)

执行完这个全备份后，会出现一个和普通虚拟机全备份/合成全备份稍微不一样的情况，那就是之前的备份数据将会被移动到 Disk(Imported) 之中，新的备份链将会替代之前的，变成活跃的 NAS 永久增量备份链。

#### Oracle/SAP HANA Backup 作业 Force delete

当配置并运行了 Oracle 或者 SAP HANA 的 Backup 作业后，VBR 会出现类型为 Oracle Rman backup 或者 SAP Backup 的作业，右键点击这些作业会有 Delete 的选项，但是这个 Delete 必须要求首先将 RMAN 或者 SAP HANA 的备份存档删除掉。这时候如果不希望删除存档，但是只想删除备份作业，可以使用 Ctrl+鼠标右键，会出现 Force Delete 选项。

![YapNbq.png](https://s1.ax1x.com/2020/05/13/YapNbq.png)

#### SOBR 的 Run tiering job now

我觉得不少朋友肯定会为 4 小时往云上传一次数据的死板设定犯愁，其实有个右键菜单藏起来了，对着 Scale-Out Backup Repository 按住 Ctrl 再点鼠标右键，你就会发现这个立即运行 Tiering 作业的按钮。

![Ya9L6J.png](https://s1.ax1x.com/2020/05/13/Ya9L6J.png)

### 方向左右键

在 VBR 的 Jobs 中，双击每个备份作业，可以查看最新的备份作业执行详情，然而如果要去看一些更早的历史作业，可能就会迷失在 VBR 的控制台中了。稍微复杂一点的操作是，打开 History 面板，然后找希望查看的日期逐个查看，也可以通过搜索进行一些关键字的过滤。

其实我们完全不需要打开 History 面板，VBR 提供了在每个作业详情中查看历史作业的方法，只需要在详细任务信息界面按左右方向键，就能查看过往信息，虽然说不能像 History 中那样灵活选择，但是在快速排错时，是一个很不错的选择。

![Yan3Tg.gif](https://s1.ax1x.com/2020/05/13/Yan3Tg.gif)

### 其他隐藏的鼠标右键

有些界面中，藏着一些鼠标右键可用的菜单，很不容易被发现，但是有时候却是很有用的，多数情况下，这些右键操作并不想干扰用户的正常操作，所以并没那么容易被发现。

#### SureBackup Statistics 窗口中的右键

双击一条 SureBackup Job，弹出 Statistics 窗口，能够看到上一次作业执行时上面的每一台 VM 的成功失败状态。除此之外，在这个静态的查看窗口，藏着一个 Start 按钮，选中 Statistics 窗口中的任意一台 VM，除了能够在下面的详细日志中查看执行情况外，还能右键再次 Start 这个 Datalab。

这个 Start 按钮主要是为我们在 SureBackup 失败时做一些 Troubleshooting 用途，点击 Start 之后，在 Session log 中会显示 SureBackup 切换进入了 Troubleshooting mode，在这个模式中，SureBackup Job 不会因为失败或者成功被立刻终止，它会保持运行状态，一直到我们手工终止结束它。这里请确保 Troubleshooting 或者使用结束后，执行 Stop 按钮。

![YaQ25D.png](https://s1.ax1x.com/2020/05/13/YaQ25D.png)

#### 存放于含有 Capacity Tier 的备份存档

通常在打开 Backups 的属性对话框右键点击备份存档时，普通的备份存档只有 copy path 的按钮，这是为了让我们快速的从文件系统中找到该 vbk、vib 文件。

但是有些时候，如果是 SOBR 中含有 Capacity Tier，条件满足的情况下，右键点这些备份存档，会出现新的右键菜单。

![YaJmEq.png](https://s1.ax1x.com/2020/05/13/YaJmEq.png)

Ok，以上就是今天的一些隐藏按钮，如果觉得好用，赶紧点赞用起来哟。另外，如果您发现了更多的，也可以留言告诉我。

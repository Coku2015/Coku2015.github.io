---
layout: post
title: 送 | 从送你的备份中恢复数据方法详解
tags: Agent
categories: 数据恢复
---

昨天的推送中，介绍了《[备份软件的安装和备份方法](http://mp.weixin.qq.com/s?__biz=MzU4NzA1MTk2Mg==&mid=2247484028&idx=1&sn=c88b416a54456eb8df03733e22104ed6&chksm=fdf0a4a9ca872dbf1ac970478b6eaa2e9ec0a61bc5dc8324beaf460a6ce6b6b5ef8886758d30&scene=21#wechat_redirect)》。不讲一下恢复，我觉得大家一定会认为我在耍流氓。那么今天的这篇，我就来详解下 Veeam Agent for Microsoft Windows 免费版的数据恢复方法。

## 三大恢复场景
备份方法只有一种，但是做完备份后，Veeam 最擅长是给你无数种恢复方法，让你用最短的时间恢复你想要的数据。

### 1. 文件还原

最方便的是打开 Veeam Control panel，点击任何一个柱状条，每一个柱状条就是一个还原点。

![1qdPKA.png](https://s2.ax1x.com/2020/02/13/1qdPKA.png)

点击进去后，能够看到增量备份的详细日志，而在窗口最下方，可以看到两个按钮，其中一个是还原单个文件，另外一个则是整卷还原。

![1qdiDI.png](https://s2.ax1x.com/2020/02/13/1qdiDI.png)

点击 Restore Files，可以打开文件级还原的浏览器。这个窗口和我们常用的 Windows 资源管理器非常相似，在这里我们可以浏览到备份存档中的所有文件，提取里面的单个文件进行恢复。Veeam 提供了还原、覆盖、复制和查看属性等一系列丰富的操作，完成数据恢复。

![1qddM9.png](https://s2.ax1x.com/2020/02/13/1qddM9.png) 如果觉得这个还不够，点击 Open in Explorer 按钮还能直接在 Windows 资源管理器中打开，那么这时候，你可以查看备份存档中的任意格式的文件，找到需要的内容进行恢复。

### 2. 整卷还原

文件还原隔壁的按钮就是整卷还原了。

![1qdwrR.png](https://s2.ax1x.com/2020/02/13/1qdwrR.png)

点开来以后依旧是 Veeam 向导，用来做整卷恢复，由于是直接从备份作业中点开的向导，所以可以省去备份存档的选择步骤，直接进入还原点选择。

![1qd0q1.png](https://s2.ax1x.com/2020/02/13/1qd0q1.png)

点击 Next 以后进入磁盘分区的映射

![1qdDVx.png](https://s2.ax1x.com/2020/02/13/1qdDVx.png)

映射完成后就进入恢复了。

因为操作系统运行的关系，整卷还原需要非常小心，有一些需要注意的地方：

> - 不能将操作系统所在的卷还原到正在运行中的原系统。

> - 不能将操作系统卷还原至有 windows swap 文件所在的卷

> - 不能将卷还原至存放着 vbk 文件的磁盘分区中。

### 3. 整机还原

当你的整个系统崩溃以后，可以进行整机恢复。使用之前配置的 ISO，最方便的方法是刻录成一个可引导的 U 盘，用该 U 盘来启动系统。这时候系统会进入一个 Windows PE 恢复界面。

![1qdV58.png](https://s2.ax1x.com/2020/02/13/1qdV58.png)

这是 Veeam 免费提供的非常强大的恢复套件，除了整合了 Veeam BMR 之外，还会有一些系统急救修复工具，就算不是用 Veeam BMR 功能，这个急救包也能在关键时刻起作用。

如果 U 盘引导的系统就是原来的电脑，这时候网卡驱动会自动被识别出来。

对于 BMR，恢复方式也是经典的 Veeam 向导方式。点击 Bare Metal Recovery 就可以进入向导。

![1qdEUf.png](https://s2.ax1x.com/2020/02/13/1qdEUf.png) 进入向导后，如果找不到本地磁盘驱动器，还可以加载磁盘驱动，来识别磁盘内的备份数据，当然比较简单的方式就是直接使用 Network Storage，找 NAS 中的数据。

![1qdePS.png](https://s2.ax1x.com/2020/02/13/1qdePS.png)

选择 Share Folder 后，点击 Next，可以进行 NAS 的一些简单配置，依旧是 CIFS 的的 UNC 路径，必要的情况下需要输入用户名和密码。

![1qdn2Q.png](https://s2.ax1x.com/2020/02/13/1qdn2Q.png)

如果配置文件夹路径正确，点击 Next 之后，就可以读取到文件夹中的所有备份存档。

![1qduvj.png](https://s2.ax1x.com/2020/02/13/1qduvj.png)

选择合适的备份存档之后，点击 Next 进入还原点的选择。

![1qdMKs.png](https://s2.ax1x.com/2020/02/13/1qdMKs.png)

点击 Next 选择还原模式。可以进行整机还原，也可以只还原系统卷，最强大的是可以支持定制手工还原的高级模式，进行分区的重新构建和映射。

![1qdQrn.png](https://s2.ax1x.com/2020/02/13/1qdQrn.png)![1qdlbq.png](https://s2.ax1x.com/2020/02/13/1qdlbq.png)

设置完磁盘映射后，就能开始还原过程，经过一段时间的等待，系统将会被恢复出来。

![1qd8aV.png](https://s2.ax1x.com/2020/02/13/1qd8aV.png)

这么好的免费产品还有技术支持？

这是真的，如果你碰到问题，你的英语足够好，你可以在 Veeam Control Panel 中找到 Support 界面

![1qdG5T.png](https://s2.ax1x.com/2020/02/13/1qdG5T.png)

这里你可以通过在线文档和在线论坛来查找资料和提交反馈意见，更重要的是，还有原厂的技术支持，通过 Technical Support 来提交一个 case。

![1qdYPU.png](https://s2.ax1x.com/2020/02/13/1qdYPU.png)

如果是免费用户，那么当我们的技术支持工程师空闲的时候，我们会尽量通过邮件的方式来回复你碰到的问题。

今天的内容看上去比昨天的备份还要短，还要简单，如果昨天还没用上 Veeam 的，今天赶紧装一套吧，数据备份永远不会晚，快点备份起来吧。

更多内容，可以关注我的公众号，下一期我会来介绍一些备份的场景，可以更近距离来接触这套优秀的个人备份软件。
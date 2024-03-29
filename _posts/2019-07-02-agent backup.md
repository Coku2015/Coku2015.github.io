---
layout: post
title: 送 | 为裸奔中的电脑送一个备份保护
tags: Agent
categories: 数据保护
---

### 上一个时代的 Norton Ghost

不知道有多少人还记得 Norton Ghost，我对于 Ghost 的记忆要追溯到刚接触到 PC 那段时间，差不多 20 年前吧，那是在电脑城装完组装机，第一件事情就是使用 Ghost 做一个系统备份。

![1jWmhF.jpg](https://s2.ax1x.com/2020/02/14/1jWmhF.jpg)

而也是从那时起，Ghost 成为每一个电脑的标配。一直到 10 年前的 Win7 时代甚至是今天的 Win10，很多个人电脑的启动项中还保留着两项，其中第二项就是，“使用一键 Ghost 恢复系统”。可以说，Ghost 在那时，几乎是人手一个。

确实，Ghost 非常好用，但是这已经是上一个时代的工具了，Symantec 旗下 Norton Ghost 团队也早在 2013 年 3 月底就停止更新和支持这款工具了。流传在民间的这一工具仅剩可用的版本也一直停留在 v11 版本，实在是有点可惜。

不过没关系，虽然 Ghost 没了，但是我们现在有了一个完美的替代品，这就是 Veeam Agent for Microsoft Windows 免费版！

今天的主题，我思考了许久，开始一直担心大家对免费软件的看法。通常我们大多数会想到的是，残缺的功能，黑心厂商为了赚钱挖了好多坑，使用中还会不断来一些广告和提醒，告诉你得赶紧付费了。这样的使用体验太崩溃，一般碰到这样的软件，我的大多数选择是卸载！

而 Ghost 的好用之处其实很大原因是当时的互联网并不发达，而这个软件本身也没有太多商业因素的考虑，很纯粹的软件，零广告零捆绑。我今天要安利的 Veeam 免费工具，在这点上和 Ghost 及其相似！

### Veeam Agent for Microsoft Windows 免费版

同样是零广告零捆绑，下载安装即可使用，且功能全面。唯一缺点，我觉得就是暂时只有英文版了。不过问题不大，我今天就带大家 Step by Step 来一遍，保证你能用上它。

#### 下载安装

下载安装非常简单，到 Veeam 官网 https://www.veeam.com 注册账号，进入下载页面，就能找到这个免费的软件下载。拿到最新版本 VeeamAgentWindows_3.0.1.1039.exe 后，双击就可以进入安装向导，整个安装过程只需要 4 步即可完成。

**Step 1**：有个简单的介绍，以及同意使用协议，有兴趣的朋友可以详细阅读，当然不想读也没问题，打钩 2 个"*I accept"* 就能激活 Install 按钮。

![1XlWvt.png](https://s2.ax1x.com/2020/02/14/1XlWvt.png)

**Step 2：**自动安装，注意这里不能更改安装路径，软件会自动装入 Windows 的默认软件安装目录中。

![1Xl4Df.png](https://s2.ax1x.com/2020/02/14/1Xl4Df.png)

**Step 3：**大约几分钟后，安装完成，如果有在电脑上插入了 usb 外置驱动器设备，会自动发现外置 usb 驱动器设备，并提示配置备份作业。我们可以跳过这个步骤不配置。

![1Xl5b8.png](https://s2.ax1x.com/2020/02/14/1Xl5b8.png)

**Step 4：**在最后一步，会提示软件已经安装成功，并且会提示创建还原用的 Recovery Media。这个还原介质非常重要，它将能够在你的系统全部崩溃后帮你恢复你的系统和数据。

![1XlTUg.png](https://s2.ax1x.com/2020/02/14/1XlTUg.png)

#### 安装完成后的第一件事：恢复盘创建

这个步骤也非常简单，标准的 Veeam 式向导会带大家完成创建过程。

**Step 1:** 点击 Finish 按钮之后，就会进入 Recovery Media 创建向导，过程也非常简单，首先选择可启动的介质类型，这里可以是 ISO 镜像也可以是 U 盘，如果有插入恢复用 U 盘的话，可以直接选择该 U 盘，在我的这个介绍中，我们选择 ISO 镜像，其过程和 U 盘大同小异，并且未来 ISO 镜像也可以通过其他途径做成 U 盘。

![1XjwS1.png](https://s2.ax1x.com/2020/02/14/1XjwS1.png)

**Step 2:** 这里默认 Veeam 会提供两个非常有用的选项，就是网卡驱动和网络配置，这对于从网络上恢复数据非常有帮助，减少了恢复时的一些配置步骤。选择 ISO image file 之后点击 next 进入下一步，会提示 ISO 文件的存放路径，这里可以是本地路径，也可以是网络 UNC 路径，如果是 CIFS 共享的 UNC 路径，可能需要提供用户名密码。

![1Xj0Qx.png](https://s2.ax1x.com/2020/02/14/1Xj0Qx.png)

**Step 3:** 点击下一步，是一个 Summary 界面，告诉您刚刚配了些什么。

![1XjBy6.png](https://s2.ax1x.com/2020/02/14/1XjBy6.png)

**Step 4:** 点击 Create 就能创建这个 ISO 镜像了。几分钟之后，这个恢复盘就创建好了，做恢复的时候用它引导启动就对了，当然这个 ISO 中并不完全包含数据。

![1XjDOK.png](https://s2.ax1x.com/2020/02/14/1XjDOK.png)

### 备份作业配置

打开 Veeam Control Panel，软件会提示一下，是否在免费版模式运行，还是输入一个商业版授权，这也是这个软件仅有的唯一一次提示，只需要点击否，继续运行免费版即可。

![1Xl75Q.png](https://s2.ax1x.com/2020/02/14/1Xl75Q.png)

点击右上角的三条线图标后打开主菜单，点击加号 Add New Job 开始创建备份作业。

![1qdtGF.png](https://s2.ax1x.com/2020/02/13/1qdtGF.png)

备份作业创建过程也非常简单，依旧是经典的 Veeam 式向导。

**Step 1：** 定义一个备份作业名称，写上一些描述说明。

![1Xlq8s.png](https://s2.ax1x.com/2020/02/14/1Xlq8s.png)

**Step 2：** 选择备份模式，对于免费版来说，可以选择备份完整计算机以及外置 USB 驱动器，也可以选择备份某个磁盘卷，还能够备份部分文件。我们选择备份完整计算机。

![1XlL2n.png](https://s2.ax1x.com/2020/02/14/1XlL2n.png)

**Step 3：** 选择备份目的地，这时候可以是 USB、火线、eSATA 等等各种连接方式的硬盘，也可以是网络上共享的 NAS 卷还可以是 Veeam 集中管理的备份存储等等。因为是个人用途，我们一般会选择备份至移动硬盘，或者是家用 NAS 中，本例子中，我选择将数据备份至家里的群晖 NAS 上。

![1XjYo4.png](https://s2.ax1x.com/2020/02/14/1XjYo4.png)

**Step 4：**共享文件夹位置设置，选择了 Share folder 选项后，点击下一步，进入 Share Folder 设定，信息也很简单，输入 UNC 路径、用户名密码后就能读到信息，包括 NAS 卷的剩余容量等等。在这个页面上，同时可以设置备份数据保留 的份数、压缩重删技术的使用、加密方式等等。那如果是非常重要的数据，加密会是一个好选择。

![1XjGeU.png](https://s2.ax1x.com/2020/02/14/1XjGeU.png)

**Step 5：** 点击下一步后，可以做一些备份计划任务的设定，这套备份软件是自动运行的，也就是设定完这些内容后，它会在后台自动运行，无需人工干预每天自动备份，这是非常省心的一件事情，不会因为不记得备份而丢失数据。这个计划作业提供了相当丰富的选项，我觉得甚至是可以为这个计划任务的设定专门写一篇推送来介绍，此处我就暂时不详细展开说明了。

![1XjJwF.png](https://s2.ax1x.com/2020/02/14/1XjJwF.png)

**Step 6：** 点击 Apply，备份作业就创建好了。依旧会进入 summary 界面告诉你上面的步骤配置了 一些什么内容。点击 finish，就能完成备份作业的配置，也可以把“Run the job when I click finish”的复选框打上勾。

![1Xj3LT.png](https://s2.ax1x.com/2020/02/14/1Xj3LT.png)

### 备份作业运行

作业配置完成后，根据计划任务的设定，备份会自动在设定的时间或者设定的场景中进行，一般来说第一次会进行全备份，而在之后，则会进行永久增量备份。

我的电脑在配置完成后做完一次全备份，然后又做了一次增量备份，这个备份情况如下：

![1qdPKA.png](https://s2.ax1x.com/2020/02/13/1qdPKA.png)

备份下来的存档，我们可以在 Windows 资源管理器内查看到，他们分别是一些 vbm 文件、vbk 文件和 vib 文件。其中 vbm 是备份作业元数据文件，记录着备份链的信息，vbk 文件是全备份存档，而 vib 是增量备份存档，增量备份文件是依附于全备份的。 

![1qdUxJ.png](https://s2.ax1x.com/2020/02/13/1qdUxJ.png)

以上，就是一个最最简单的 Veeam Agent 个人电脑备份方法，你学会了吗？如果觉得不错的话，赶紧去 Veeam 官网下载一份安装上使用起来吧。下一期，我将会介绍从 Veeam 备份存档中恢复数据的方法，帮助大家更深入的使用 Veeam Agent for Microsoft Windows 免费版。

更多内容，可以关注本人的公众号收听更多推送。
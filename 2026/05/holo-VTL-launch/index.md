# Holo VTL 正式发布


我在备份圈做了好多年，经常遇到同一个问题：想测试磁带备份功能，但手头没有真实磁带库。

真实磁带库不便宜，随便一台入门级的要几万起步，调试也麻烦。测试环境里这东西更是稀缺。不少人只能跳过磁带相关的功能验证，或者直接用生产环境的磁带库做测试，风险不小。

今天，我正式发布了 **Holo VTL**，这是我自己开发的一个开源虚拟磁带库项目。

项目地址：[https://github.com/Holo-VTL/Holo](https://github.com/Holo-VTL/Holo)

---

### Holo VTL 是什么？

简单说，Holo VTL 是一个运行在普通 Linux 服务器上的虚拟磁带库。

安装完之后，它会在你的服务器上模拟出一套完整的磁带库设备，包括磁带驱动器、槽位和磁带介质，然后通过标准 iSCSI 协议暴露出去。备份软件连接之后，看到的是一台真实的磁带库，识别、Inventory、写数据，全都能做。

Holo VTL 的名字来自"全息"（Hologram）——名字的意思是，哪怕是一个碎片，也能反映整体的图像。

目前第一个正式版本已经发布：**Holo@v1.0.0**，MIT License 开源。

---

### 它长什么样？

安装完成之后，可以通过浏览器打开 Web 控制台：

```
http://<服务器IP>/ui/
```

**系统概览页**

首页是一个 Dashboard，显示当前系统状态，包括已配置的虚拟磁带库、驱动器数量、磁带数量、存储占用等基本信息。

![Xnip2026-05-09_13-50-13](https://files.seeusercontent.com/2026/05/09/rq3E/Xnip2026-05-09_13-50-13.png)

**存储管理页**

在存储管理页面，可以查看和管理虚拟磁带的存储状态，包括每盘磁带的容量信息、压缩比、使用情况。

![Xnip2026-05-09_13-50-29](https://files.seeusercontent.com/2026/05/09/Zpj8/Xnip2026-05-09_13-50-29.png)

**VTL 机架视图**

这是我个人比较喜欢的一个页面——用可视化的机架形式展示虚拟磁带库的当前状态，能直观看到哪些槽位有磁带、哪些驱动器处于加载状态。在这个视图上还能模拟磁带出库，让进入离线的保管库中。

![Xnip2026-05-09_13-52-29](https://files.seeusercontent.com/2026/05/09/h8Vs/Xnip2026-05-09_13-52-29.png)

整体 UI 不复杂，目标就是让管理员能快速看清状态，做日常管理，不需要全靠命令行。

---

### 安装只需要一行命令

Holo VTL 目前支持主流 Linux 发行版，包括 RHEL 8/9/10、Rocky Linux、Alma Linux、Ubuntu 20.04/24.04/25.04、Debian 12/13，以及 openSUSE Leap 15.6。

在线安装，需要root权限：

```bash
curl -fsSL https://raw.githubusercontent.com/Holo-VTL/Holo/main/scripts/install.sh | bash
```

如果是离线环境，从 Releases 页下载安装包之后：

```bash
bash install.sh --offline
```

安装脚本会自动处理所有依赖，包括 iSCSI target 组件、TCMU 驱动、systemd 服务配置。装完之后，打开浏览器就可以用了。

---

### 从零到配合 Veeam 使用的完整流程

下面以 Veeam Backup & Replication 为例，走一遍完整的使用流程。

#### 第一步：在 Holo VTL 中创建虚拟磁带库

打开 Web 控制台，创建一个新的虚拟磁带库。可以选择磁带库型号，Holo VTL 内置了 48 种磁带驱动器配置，包括 IBM LTO 系列（LTO-3 到 LTO-9）、HP Ultrium、Quantum、Dell PowerVault 等主流型号，以及 50+ 种磁带库配置。推荐如果 Tape Server 使用 Windows 的用户选择 IBM 或者 HP 系列的虚拟带库，因为它自带这两个品牌的驱动，而使用 Linux 作为 Tape Server 则没有任何驱动限制。

![Xnip2026-05-09_13-54-01](https://files.seeusercontent.com/2026/05/09/6vRn/Xnip2026-05-09_13-54-01.png)

> **注意：** 要成功发布 iSCSI Target，必须先完成虚拟带库的全部配置，包括机械臂、驱动器和初始化磁带。否则备份服务器将无法正确识别虚拟设备。

配置项包括：驱动器数量、槽位数量、初始磁带数量和 IE 口数量。

![Xnip2026-05-09_13-54-17](https://files.seeusercontent.com/2026/05/09/Yti6/Xnip2026-05-09_13-54-17.png)

完成创建后，Holo VTL 会通过 iSCSI 将这套虚拟设备暴露出来，等待备份服务器连接，网页上能够查看当前发布的目标。

![Xnip2026-05-09_13-56-44](https://files.seeusercontent.com/2026/05/09/iUb9/Xnip2026-05-09_13-56-44.png)

#### 第二步：在 Veeam 服务器上连接 iSCSI Target

在 Veeam 的 Tape Server 上，打开 iSCSI Initiator，添加 Holo VTL 服务器的 IP 地址，连接对应的 iSCSI Target。

![Xnip2026-05-09_14-04-08](https://files.seeusercontent.com/2026/05/09/9lbH/Xnip2026-05-09_14-04-08.png)

连接成功之后，在 Windows 设备管理器中应该能看到新增的磁带设备：Tape Drive 和 Medium Changer。

![Xnip2026-05-09_14-07-55](https://files.seeusercontent.com/2026/05/09/g7Pe/Xnip2026-05-09_14-07-55.png)



#### 第三步：在 Veeam 中添加 Tape Infrastructure

打开 Veeam 控制台，进入 **Tape Infrastructure** 视图，扫描已添加的服务器。

如果 一切正常，Veeam 会识别到 Holo VTL 提供的虚拟磁带库。

![Xnip2026-05-09_14-10-51](https://files.seeusercontent.com/2026/05/09/fHm3/Xnip2026-05-09_14-10-51.png)

#### 第四步：执行 Inventory

在 Veeam 的 Tape 视图中，对磁带库执行 Inventory 操作。Veeam 会扫描所有槽位，识别每盘虚拟磁带的条码和状态。

![Xnip2026-05-09_14-13-56](https://files.seeusercontent.com/2026/05/09/nz8X/Xnip2026-05-09_14-13-56.png)

#### 第五步：创建 Tape Backup Job

Inventory 完成之后，就可以在 Veeam 中创建 Tape Backup Job 了，把已有的备份数据写入虚拟磁带，流程和使用真实磁带库完全一样。

![Xnip2026-05-09_14-15-09](https://files.seeusercontent.com/2026/05/09/Enq3/Xnip2026-05-09_14-15-09.png)

#### 第六步：查看结果

Job 运行完成后，可以在 Veeam 中查看任务状态，也可以回到 Holo VTL 的 Web 控制台，查看虚拟磁带的实际使用情况——容量变化、数据写入量都能看到。

![Xnip2026-05-09_14-16-45](https://files.seeusercontent.com/2026/05/09/cUt1/Xnip2026-05-09_14-16-45.png)

整个流程走下来，Veeam 实际上是在对一套虚拟磁带库做完整的备份操作，从发现设备、Inventory、写入数据，到任务完成，和真实硬件没有本质区别。

---

### 适合哪些场景？

**备份软件测试。** 想验证备份软件的磁带功能，但没有真实设备——这是 Holo VTL 最直接的用途。

**学习和实验环境。** 想搞清楚 VTL、iSCSI、磁带库、Media Pool、Tape Job 这些概念，有一个可以动手操作的环境比只看文档有效得多。

**备份流程验证。** 测试磁带轮换策略、介质保留策略、归档流程，先在虚拟环境里跑通再上生产。

**开发和兼容性测试。** 如果你在开发和备份、归档、存储相关的系统，可以用 Holo VTL 模拟磁带库设备做集成测试。

---

### 它不是什么

说清楚这个同样重要。

Holo VTL 不是一个完整的备份平台，也不是文件同步工具。它的定位是"虚拟磁带库设备"，更像是备份体系中的虚拟硬件层——为备份软件提供标准的磁带库设备接口，本身不负责管理备份策略、调度任务或存储数据的业务逻辑，这些都交给备份软件来做。

---

### 遇到报错怎么排查？

作为第一个版本，碰到问题是正常的，尤其是不同备份软件、不同 SCSI 命令序列之间的兼容性，很难一次性覆盖完。

如果你在使用过程中遇到备份软件报错，建议按下面这个流程收集信息再来找我：

**第一步：打开详细日志。** 在 Holo VTL Web 控制台的**关于（About）**页面，找到日志级别设置，切换到打开详细日志模式。

![Xnip2026-05-09_15-01-09](https://files.seeusercontent.com/2026/05/09/9gpH/Xnip2026-05-09_15-01-09.png)

**第二步：重现问题。** 日志开启后，在备份软件里重新执行出错的操作（备份或恢复），让错误再发生一次。

**第三步：下载日志包。** 同样在 About 页面，点击"下载日志包"按钮，会生成一个包含完整诊断信息的压缩包。

**第四步：发给我。** 把日志包发到 **coku2015@gmail.com**，邮件里简单描述一下：用的是什么备份软件、做了什么操作、报了什么错。我会尽快看。

---

### 开源信息

Holo VTL 使用 MIT License 开源，项目地址：

**[https://github.com/Holo-VTL/Holo](https://github.com/Holo-VTL/Holo)**

如果你对这个项目感兴趣，欢迎：

- ⭐ Star 项目
- 提交 Issue 反馈使用问题
- 测试你用的备份软件的兼容性，把结果告诉我
- 提交 Pull Request

接下去我会继续完善 Web UI 体验、补充更多的详细配置文档、测试更多备份软件的兼容性。如果你用的是 Veeam 或者其他任何备份软件，有任何问题都可以在 GitHub Issues 里找我，或者直接在博客留言。

---

*这是我用 Codex 和 Claude Code 制作的小项目， Holo VTL 的第一个公开版本，也是一个起点。希望它能帮到需要测试和学习磁带备份的朋友。*


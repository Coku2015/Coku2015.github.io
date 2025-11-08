# Veeam 重磅发布 Software Appliance：官网下载与文档结构大升级




## 前言：Veeam Software Appliance 发布背景

昨天 Veeam 官网悄悄上线了一个新产品：[Veeam Software Appliance](https://www.veeam.com/blog/veeam-software-appliance.html)。对很多朋友来说，Veeam 过去一直都是 Windows 安装包 + 手动配置的传统模式，而这个 Software Appliance 明显走的是另一条路：安装和安全都做了预设，大大简化了上手流程。比如：它基于预加固的 Rocky Linux 平台，自带不可变存储、零信任访问控制和自动补丁，无需再单独采购 Windows 授权或自己做安全加固；用 ISO 或 OVA 就能直接部署，无论在虚拟机、物理机还是云上都可以跑。



## 亮相新品：Veeam Software Appliance 概览

本次更新，Veeam 官方一次性放出“三件套”。如果大家平时用 Veeam 做备份，看到名字可能有点懵，下面我简单捋一捋：

- **Veeam Software Appliance**
这是这次的“主角”，也就是我们熟悉的 Veeam 备份软件本体，包含了备份服务器（Veeam Backup &Replication）和企业管理器（Enterprise Manager）。不同的是，现在不用再在 Windows 上装一堆安装包了，而是直接提供了一个 ISO 或者 OVA 镜像，服务器用它引导后，就能进入系统安装界面，一次性把系统和软件都装好，省心又安全。
- **Veeam Infrastructure Appliance**
这个可以理解成备份基础架构的“扩展包”。在 Veeam 环境里，支持分布式部署各种角色服务器，比如 Proxy、Tape Server、Gateway Server、Mount Server，还有最关键的数据存储库——Hardened Repository，现在通过这个 Appliance 可以用于安装这些角色。它和 Software Appliance 一样，都是基于 Rocky Linux 预先构建好的，拿来就能用，部署和维护成本都降下来了。
- **Veeam ONE v13**
这个并不是 Software Appliance 版本，它和以前一样，是 Windows 下的安装包，这个算是常规升级版，负责监控和分析整个备份/恢复环境。可以从 V12 的 Veeam ONE 升级到 v13，同时能兼容旧版（V12 Windows 版 VBR）的监控，也能支持新版 Appliance 的监控。对于我们要同时管理老环境和新环境的小伙伴来说，这点特别重要，对于想提前尝鲜 V13 的，能实现平滑过渡。

需要注意的是，对于备份服务器来说，本次 Software Appliance 的 v13 版本仅支持全新安装，已有的 v12 版本暂时还不支持升级和迁移，如果是已经在使用 Veeam 朋友想升级的话，可能还需要等待一段时间，在下次更新时，Veeam 会推出平滑过渡的升级方案。

另外，Veeam Software Appliance 将不再支持社区版许可，因此就算想试用，都需要额外从官网下载测试许可导入才能让这个 Appliance 工作起来。



## 官网全面焕新：下载与文档手册新体验

伴随新品发布，Veeam 官网也进行了一些调整。无论是产品下载入口、文档手册页面还是手册内部结构，这可能会对大家造成一定困扰。接下来我们来看看具体的一些变化吧。

### 软件下载页

按照这次发布的内容，一共三个组件，下载位置有点不同。

#### Veeam Software Appliance 本体下载

在 Veeam 中文官网的右上角下载按钮，可以进入下载页，进入后找到 Veeam Data Platform 的下载，直达电梯 (https://www.veeam.com/cn/products/data-platform-trial-download.html?tab=extensions)，这时候可以看到下载选项中多了一个`Pre-Hardened Software Appliance（Linux）`标签卡，点击切换就能找到备份服务器本体下载，如下图：

![image-20250904160720733](https://s2.loli.net/2025/09/04/6zKVev3XusdPBcZ.png)

这里可以找到这个 Appliance 的版本发布说明，也可以选择 ISO 或者 OVA 格式下载，在最右边还可以申请许可证密钥，如果没有购买正式许可，请务必在这里点击申请密钥申请测试许可，才能使用这个 Appliance。



#### Veeam Infrastructure Appliance

在上面这个页面下方，可以看到有个更多下载，切换到`扩展程序及其他`，可以看到有个 Veeam Infrastructure Appliance，点击前面的 + 号，可以打开这个组件的下载框进行下载。

![Xnip2025-09-04_16-12-43](https://s2.loli.net/2025/09/04/swqNxkVcCljIQBe.png)



#### VeeamONE v13

Veeam ONE 的下载页面藏的比较深，如果官网首页直接找的话，可能会找不到，这里给一个直达的电梯 (https://www.veeam.com/cn/products/free/monitoring-analytics-download.html)，虽然是社区版，但是产品安装包是同一个。熟悉 Veeam 网站的朋友也可以从 my.veeam.com 中进入找到 v13 的下载。

![Xnip2025-09-04_17-35-06](https://s2.loli.net/2025/09/04/FR9mAehSBdMwX8b.png)



### V13 使用手册

除了软件下载之外，官网文档也有明显优化，Software Appliance 和 Veeam ONE 都推出了对应 v13 的新文档。文档结构也进行了重组，而不是以前大部分功能都写在 vSphere 备份的文档中，毕竟 Veeam 现在的功能已经不再是 VMware 专用备份工具啦。



文档入口：

Veeam Software Appliance 使用手册

https://helpcenter.veeam.com/docs/vbr/userguide/overview.html?ver=13

Enterprise Manager 使用手册

https://helpcenter.veeam.com/docs/vbr/em/introduction.html?ver=13

Veeam Explorer 使用手册

https://helpcenter.veeam.com/docs/vbr/explorers/explorers_introduction.html?ver=13

Proxmox 备份使用手册

https://helpcenter.veeam.com/docs/vbproxmoxve/userguide/overview.html?ver=2

VeeamONE v13 使用手册

https://helpcenter.veeam.com/docs/one/userguide/about_one.html?ver=13





## 系列文章预告与快速上手指南

本系列文章将在后续深入讲解 Veeam Software Appliance 的功能亮点、部署要点以及全面的使用介绍，帮助读者更高效地利用 Veeam 的最新资源。如果你也正在探索如何快速掌握新版 Veeam 体验，敬请关注接下来的更新








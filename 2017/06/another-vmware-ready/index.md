# 好消息好消息，Veeam 又通过一项 VMware Ready 认证！


上周，前方又传来一个激动人心的消息，Veeam 通过了 vSphere 6.5 刚刚开放的 VMware Web Client Plug-in Ready 认证。厉害了，这个太厉害了。具体 VMware 官网查询链接 https://www.vmware.com/resources/compatibility/search.php?deviceCategory=wcp

![1T0COx.png](https://s2.ax1x.com/2020/02/11/1T0COx.png)

什么？什么？你还不知道啥是 VMware Ready？好吧，我先来普及下这个认证。简单来说使用通过认证的 plug-in 有这么几个好处：

1. 符合 VMware Web Plug-in 的最佳实践，会被收录至各种白皮书、教科书。
2. 用户体验极佳，可以说是几乎和 VMware 原厂软件完全一致。
3. 插件经过 VMware 原厂严格测试，使用该插件，完全不会影响 vCenter 的性能，不用担心非原厂插件破坏 vCenter。
4. 插件故障，VMware 给保修，这个很重要。一站式解决问题。

那么，这么好的插件，它能做点啥呢，我们来看下这个功能强大的小插件。

这个插件部署完成之后，会在 vSphere Web Client 上出现一个新的图标，和其他的 Web Client 插件一样，点击即可进入。

![1T0961.png](https://s2.ax1x.com/2020/02/11/1T0961.png)

在这个插件中，我们能够查看到当前的备份基础架构情况：

![1T0Sp9.png](https://s2.ax1x.com/2020/02/11/1T0Sp9.png)

能够看到最近 24 小时、7 天、14 天的虚拟机备份情况：

![1T0plR.png](https://s2.ax1x.com/2020/02/11/1T0plR.png)

能够看到备份任务的执行和计划情况：

![1TwjkF.png](https://s2.ax1x.com/2020/02/11/1TwjkF.png)

还能够看到最近 7 天、14 天、1 个月处理的虚拟机数量：

![1T0im6.png](https://s2.ax1x.com/2020/02/11/1T0im6.png)

能够查看备份存储库的容量，再也不担心日常运维的时候忘记存储快满了：

![1T0F0K.png](https://s2.ax1x.com/2020/02/11/1T0F0K.png)

并且以上这些内容，如果有部署 Veeam ONE，能够直接点击跳转查看完整的相关报告。如此这样，基础架构运维，是不是突然发现，简单了好多？

除此之外，该插件还提供了快速备份的功能，在每个 VM 的右键菜单中，我们可以找到 Backup 选项：

![1T0kTO.png](https://s2.ax1x.com/2020/02/11/1T0kTO.png)

VeeamZIP，立即执行 Active Full 类型的全备份，是一种快速备份的简单方法。

VeeamZIP to ... 则会跳转至 ZIP 设置界面，该界面也集成在 vSphere Web Client 中，而不用进入 Veeam Console。

Quick Backup 则是进行快速的增量或反向增量备份，用于单次的即时备份。

最后来看下 VeeamZIP 设置界面，该界面位于每台 VM 的 Manage 选项卡下的最后一项 VeeamZIP 中，如图：

![1T0EkD.png](https://s2.ax1x.com/2020/02/11/1T0EkD.png)

这里可以简单设置备份服务器、备份存储库、Key、VeeamZIP 删除时间、压缩级别、是否进行客户端静默等选项，几乎与 Veeam Console 中的 VeeamZIP 设置选项一致。同时这里也提供 VeeamZIP 任务触发按钮。当执行 VeeamZIP 任务或者 Quick Backup 任务时，vSphere Web Client 的任务栏还会出现 Veeam 的任务进度：

![1T0ZfH.png](https://s2.ax1x.com/2020/02/11/1T0ZfH.png)

好了，以上就是全部 Veeam vSphere Web Client Plugin 的功能，简单小巧，又非常好用，还带保修。


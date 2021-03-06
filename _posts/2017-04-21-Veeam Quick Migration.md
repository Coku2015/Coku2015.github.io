---
layout: post
title: Veeam黑科技之Quick Migration
tags: 迁移
categories: Veeam小工具
---


vSphere和Hyper-V都拥有自己的一些迁移技术，而Veeam作为一个数据保护软件，从数据保护的角度出发，为IT管理员提供了另外一种迁移技术。在Veeam软件中，该技术通常叫做Quick Migration。

熟悉Veeam的朋友，可能此时能立刻想到，在Veeam进行Instant VM Recovery的时候，有一个选项叫做Quick Migration，这是Instant VM Recovery执行过程中的一个可选步骤，当我们需要把数据从备份存储迁移至生产存储时，如果没有VMware Enterprise Plus许可时，无法使用高大上的Storage vMotion完成这个任务时，又或者在恢复时无vCenter可用，仅仅是只有单个ESXi节点提供服务时，这时候Quick Migration是一个非常好的选择。仅仅是付出比Storage vMotion略多些许的停机时间，获得的是更广泛的支持性，不失为一个绝佳的补充方案。

然后，Quick Migration的用法还远不止这些，我简单来举几个例子：

### 跨vCenter、Datacenter的VM迁移

这个话题通常会是一个复杂的手工操作，又或者是高大上的一些解决方案，而有了Veeam的加入，这一操作变得及其简单，Quick Migration即可完成，只要有合适的Proxy可用，那么Veeam就可以去做这样的迁移操作，并且这个迁移操作是不需要借助备份的，也就是说Veeam的这个迁移是可以直接进行，而不需要备份或者复制操作作为前提条件的。

这个操作非常简单，Veeam的界面上有这个按钮，只要按了按照向导即可完成。同样迁移过程中，Veeam一样支持Thin/Thick转换和磁盘重定向等基本操作。

![1TwZMq.jpg](https://s2.ax1x.com/2020/02/11/1TwZMq.jpg)



### LAN free迁移

什么？迁移虚拟机还能LAN free？对的你没看错，Veeam的Quick Migration可以通过合理的架设Proxy，实现LAN free。利用Direct SAN Access技术，无论是Fiber Channel还是Direct NFS技术都可以用于Quick Migration中，从而避免了VMKernel带宽不够用的问题，这个在大容量虚拟机的迁移上，能够帮助有效的控制数据流。

当然，以上这些我们也许可以通过其他的方法或者工具进行类似的实现，只是在此Veeam提供了一种更多的选择，让我们手上有更多的工具去完成日常虚拟化数据管理中所面临的挑战。
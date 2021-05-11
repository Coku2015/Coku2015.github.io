---
layout: post
title: Veeam黑科技之Direct NFS Access
tags: ['VMware']
categories: 黑科技
---



最近这些天，碰到不少在VMware环境中使用NFS作为datastore的用户，发现NFS的场景是越来越多了。在以前，可能仅仅会是部分NetApp的用户去使用NFS作为VMware的datastore，而现在，随着各种超融合技术的兴起，市场上几个主流的超融合平台，比如Nutanix和Cisco HyperFlex在为VMware提供存储服务的时候都采用了NFS的方式去提供datastore。

这在以往来说，并不是一个好消息，当datastore是NFS协议的时候，虚拟机的备份可用的数据传输方式只能通过效率最差的Network方式，受限于备份仅仅能使用VMKernel的40%最大网络吞吐量，即使是有足够的带宽，实际传输时，吞吐量依然低下。

![17fbSx.png](https://s2.ax1x.com/2020/02/12/17fbSx.png)

在Veeam Backup & Replication v9.0之后，使用Veeam去备份存放在NFS数据存储上的虚拟机的时候，有了一种全新的数据传输方式，Veeam把它称之为Direct NFS Access。很容易联想到VMware备份中的另外一种数据传输方式Direct SAN Access，在SAN备份中遵循VMware的数据提取方式，能不经过前端ESXi主机而是直接访问SAN存储读写数据。同样在NFS数据存储上，Veeam也能够提供类似的直接存储访问，而不经过前端ESXi主机。



![17fL6K.png](https://s2.ax1x.com/2020/02/12/17fL6K.png)

**这么强大的功能，如何使用？**



Veeam的功能向来是强大却又极其简单。。这个Direct NFS Access的功能也是如此，以下我们来看看如何去进行这个功能的配置。



首先在VMware上面，我们有一台虚拟机存放在NFS的datastore中，如图：



![1T0mpd.png](https://s2.ax1x.com/2020/02/11/1T0mpd.png)

在NFS服务器端，设置除了ESXi能访问这个卷之外，Veeam的Proxy也有读写的权限，本例中我在我的FreeNAS上做了一个访问设定，其中10.10.1.130是ESXi，而10.10.1.171则是Veeam Backup Proxy：

![17fjmD.jpg](https://s2.ax1x.com/2020/02/12/17fjmD.jpg)

然后，在Veeam的控制台，我们指定一下使用备份首选的备份网络，为NFS的存储访问网络：

![17hptA.png](https://s2.ax1x.com/2020/02/12/17hptA.png)

接下来，如果NFS数据存储是新添加的，在添加之后还未进行存储扫描，则可以做一个VMware基础架构的Rescan动作，确保识别到NFS数据存储。

![17hF6f.png](https://s2.ax1x.com/2020/02/12/17hF6f.png)

好了，所有设定完成，直接去执行备份任务即可，在备份任务执行过程中，Veeam会自动感知到可以使用Direct NFS Access的方式进行数据读取，就会优先采用这种方式读取：

![17h9fI.png](https://s2.ax1x.com/2020/02/12/17h9fI.png)

上图中我们看到读取方式标注为[nfs]，而常规其他的几种分别是[san]、[hotadd]、[nbd]，这是最大的区别。

而在备份日志文件中，同样能找到数据读取的相关记录：

![17hi1P.jpg](https://s2.ax1x.com/2020/02/12/17hi1P.jpg)



好了，这就是简单的Direct NFS Access的配置方法，具体更详细的说明，可以点击阅读原文，参考Veeam官方手册查看详细内容。
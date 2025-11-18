# Veeam 黑科技之 Direct NFS Access


最近这些天，碰到不少在 VMware 环境中使用 NFS 作为 datastore 的用户，发现 NFS 的场景是越来越多了。在以前，可能仅仅会是部分 NetApp 的用户去使用 NFS 作为 VMware 的 datastore，而现在，随着各种超融合技术的兴起，市场上几个主流的超融合平台，比如 Nutanix 和 Cisco HyperFlex 在为 VMware 提供存储服务的时候都采用了 NFS 的方式去提供 datastore。

这在以往来说，并不是一个好消息，当 datastore 是 NFS 协议的时候，虚拟机的备份可用的数据传输方式只能通过效率最差的 Network 方式，受限于备份仅仅能使用 VMKernel 的 40%最大网络吞吐量，即使是有足够的带宽，实际传输时，吞吐量依然低下。

![17fbSx.png](https://s2.ax1x.com/2020/02/12/17fbSx.png)

在 Veeam Backup & Replication v9.0 之后，使用 Veeam 去备份存放在 NFS 数据存储上的虚拟机的时候，有了一种全新的数据传输方式，Veeam 把它称之为 Direct NFS Access。很容易联想到 VMware 备份中的另外一种数据传输方式 Direct SAN Access，在 SAN 备份中遵循 VMware 的数据提取方式，能不经过前端 ESXi 主机而是直接访问 SAN 存储读写数据。同样在 NFS 数据存储上，Veeam 也能够提供类似的直接存储访问，而不经过前端 ESXi 主机。

![17fL6K.png](https://s2.ax1x.com/2020/02/12/17fL6K.png)

**这么强大的功能，如何使用？**

Veeam 的功能向来是强大却又极其简单。这个 Direct NFS Access 的功能也是如此，以下我们来看看如何去进行这个功能的配置。

首先在 VMware 上面，我们有一台虚拟机存放在 NFS 的 datastore 中，如图：

![1T0mpd.png](https://s2.ax1x.com/2020/02/11/1T0mpd.png)

在 NFS 服务器端，设置除了 ESXi 能访问这个卷之外，Veeam 的 Proxy 也有读写的权限，本例中我在我的 FreeNAS 上做了一个访问设定，其中 10.10.1.130 是 ESXi，而 10.10.1.171 则是 Veeam Backup Proxy：

![17fjmD.jpg](https://s2.ax1x.com/2020/02/12/17fjmD.jpg)

然后，在 Veeam 的控制台，我们指定一下使用备份首选的备份网络，为 NFS 的存储访问网络：

![17hptA.png](https://s2.ax1x.com/2020/02/12/17hptA.png)

接下来，如果 NFS 数据存储是新添加的，在添加之后还未进行存储扫描，则可以做一个 VMware 基础架构的 Rescan 动作，确保识别到 NFS 数据存储。

![17hF6f.png](https://s2.ax1x.com/2020/02/12/17hF6f.png)

好了，所有设定完成，直接去执行备份任务即可，在备份任务执行过程中，Veeam 会自动感知到可以使用 Direct NFS Access 的方式进行数据读取，就会优先采用这种方式读取：

![17h9fI.png](https://s2.ax1x.com/2020/02/12/17h9fI.png)

上图中我们看到读取方式标注为 [nfs]，而常规其他的几种分别是 [san]、[hotadd]、[nbd]，这是最大的区别。

而在备份日志文件中，同样能找到数据读取的相关记录：

![17hi1P.jpg](https://s2.ax1x.com/2020/02/12/17hi1P.jpg)

好了，这就是简单的 Direct NFS Access 的配置方法，具体更详细的说明，可以点击阅读原文，参考 Veeam 官方手册查看详细内容。


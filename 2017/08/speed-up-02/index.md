# 加速！加速！加速！（二）


上一期，我们讨论了 [备份引擎的加速](https://mp.weixin.qq.com/s?__biz=MzU4NzA1MTk2Mg==&mid=2247483745&idx=1&sn=c9b28d97eec1426dece66490a9655b43&chksm=fdf0a7b4ca872ea207c5d96dfdac2646fdc1b8a507b5e85cd267fdd720d3dff7d0b5e546680b&scene=21#wechat_redirect)，这对尽可能快的完成备份提升 RPO 有着极其重要的意义。然而除了这个数据传输引擎之外，在备份时还有一个加速器，那就是 vSphere 通讯加速技术。

**Broker Service**

这是 Veeam9.5 中新增加的一个特性，简单来说这项科技给备份带来的帮助是在 Veeam 和 VMware vCenter 之间加入了一个过渡服务，当 Veeam 每次发起任务时，需要查询 vSphere 信息时，可以替代性的去查询 BrokerService 而不用直接去找 vSphere。

如下图，这是有无 BrokerService 的一个直观对比，没有 Broker 时，每次备份任务都会去直接和 vCenter 通讯，其获取返回结果的耗时完全取决于 vCenter 性能和网络状况。而在有了 Broker 之后，Veeam 则会去查询 Broker 中缓存的信息，而由 Broker 保持和 vCenter 处于 update 状态。

 

![1745GR.jpg](https://s2.ax1x.com/2020/02/12/1745GR.jpg)

那么这个 Broker 事实上在 Veeam 软件中是以一个服务的形式存在，因此我们在 Services.msc 中可以查看到这个 Service:

 

![1744i9.png](https://s2.ax1x.com/2020/02/12/1744i9.png)

这个 Broker 在工作的时候，VMwarevCenter 中清单基础架构的任何变化都会实时的被推送至 Broker 的缓存中，而如果 Veeam 未收到任何推送变化的情况下，默认 Veeam 会每 15 分钟（900 秒）进行一次强制更新缓存，确保缓存内容的准确性。

 

![174oxx.png](https://s2.ax1x.com/2020/02/12/174oxx.png)

 

所以，这带来的好处显而易见，以下是一组软件中截图的对比，在无 Broker 的情况下，Veeam 备份任务通过查询 vCenter 来创建备份虚拟机列表，消耗了 40 秒时间：

 

![174IR1.jpg](https://s2.ax1x.com/2020/02/12/174IR1.jpg)

而在有了 Broker 之后，Veeam 备份任务查询 Broker 来创建备份虚拟机列表，仅需要耗时 1 秒：

 

![174fIJ.jpg](https://s2.ax1x.com/2020/02/12/174fIJ.jpg)

这可以说效率提升了 40 倍以上！！

 

好吧，为了让你的备份速度飞起来，升级到 Veeam 9.5Update2 吧。

**下期预告：**

备份速度快不算啥，这都不是啥大事，划重点的来了，真正要快的还原技术，而 Veeam 除了有 Instant VM Recovery 之外，其他的那些还原技术会不会也很快？下期为你揭晓答案。


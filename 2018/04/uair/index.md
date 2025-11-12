# 利用 Veeam U-Air 恢复 MySQL 数据库


常常被问及 Veeam 是否支持某某数据库/应用程序的对象恢复，其实这个问题的答案和问题中提到的 某某数据库/应用程序 完全没有关系，这类问题的答案永远是肯定的。因为 Veeam 有一个超强的恢复工具：U-AIR（Universal Application-Item Recovery）

今天我就以 MySQL 为例，给大家详解一下这个恢复工具。

先来看看今天的备份存档，这是一个安装在 CentOS 上的 MySQL 5.1.7，我使用 Veeam Backup & Replication 对其进行备份，备份过程中执行了 Pre-freezing 和 Post-freezing 脚本确保其数据一致性，关于此脚本，大家可以参考 Veeam 官网的白皮书，因为 Veeam 白皮书实在太详尽，我就不在此处担当复读机啦。

具体链接如下：

https://www.veeam.com/wp-consistent-protection-mysql-mariadb.html

对于源虚拟机上，我的 MySQL 中有以下这些测试数据：

![1blj8P.png](https://s2.ax1x.com/2020/02/12/1blj8P.png)

然后这个状态的这台 MySQL 虚拟机我做了一次备份，这时候因为一些意外原因，我的 veeamlab 这个 database 被破坏了，我需要通过备份，将这个 veeamlab database 还原出来。此时，坏了的 veeamlab 将会被我弃用，而我会新建一个空的 veeamlab_recovered 作为新的目标还原库，而这时 MySQL 则是一切正常状态。

![1blvgf.png](https://s2.ax1x.com/2020/02/12/1blvgf.png)

接下去，我的还原过程开始了，启动 Universal Lab Request Wizard 来申请一个之前的备份存档，用于还原，申请过程非常简单。

![1blxv8.png](https://s2.ax1x.com/2020/02/12/1blxv8.png)

给出需要申请的 VM Name，这里完全支持模糊名称。

![1b1PEj.png](https://s2.ax1x.com/2020/02/12/1b1PEj.png)

还原点我选择最新一份。

![1b1iUs.png](https://s2.ax1x.com/2020/02/12/1b1iUs.png)

完成之后提交申请。

![1b1ACq.png](https://s2.ax1x.com/2020/02/12/1b1ACq.png)

至此，U-AIR 恢复申请提交完成，须等待备份管理员审核还原申请。

我接下去通过 Veeam Enterprise Manager 来到备份管理员视图，进行此次还原申请的审核。

![1b1mKU.png](https://s2.ax1x.com/2020/02/12/1b1mKU.png)

Approve 过程也非常简单，在这里完全用到 Veeam SureBackup/Virtual Lab 的功能，具体 SureBackup/Virtual Lab 的配置可参考之前的推文 。《[备份存档能不能被恢复，这件事情上只有真正做过才知道。](http://mp.weixin.qq.com/s?__biz=MzU4NzA1MTk2Mg==&mid=2247483830&idx=1&sn=3fee7103411facb64c243c32b0e0ff65&chksm=fdf0a763ca872e75b75ca65be5f81791549bac6322e5f161ec5becc5be23eef27833ea47b9f3&scene=21#wechat_redirect)》

这个审批过程，Veeam 会自动找到合适的虚拟机备份存档：

![1b1V2V.png](https://s2.ax1x.com/2020/02/12/1b1V2V.png)

![1b1ZvT.png](https://s2.ax1x.com/2020/02/12/1b1ZvT.png)

会选择合适 Virtual Lab 和 SureBackup Job 作为还原的临时环境：

![1qniF0.png](https://s2.ax1x.com/2020/02/13/1qniF0.png)

![1qn9wn.png](https://s2.ax1x.com/2020/02/13/1qn9wn.png)

如此，审批过程就结束了，接下去，在数据库管理员这端，等待一小段时间后，将会获得临时还原环境的访问信息。

![1qnFYV.png](https://s2.ax1x.com/2020/02/13/1qnFYV.png)

通过 172.20.1.139，我 ssh 到这台还原环境中，而此时我原来的 10.10.1.139 还是处于正常运行状态。检查临时的还原环境中的数据库情况如下：

![1qnVlF.png](https://s2.ax1x.com/2020/02/13/1qnVlF.png)

![1qnZy4.png](https://s2.ax1x.com/2020/02/13/1qnZy4.png)

数据一切正常，接下去，我需要做一件事情，就是将这里的数据提取出来，然后传输至原来的 10.10.1.139 中，进行还原。我使用 mysqldump 命令来提取数据。

提取完后，数据存放至/tmp/mysql/veeamlab.sql 文件中。

![1qneOJ.png](https://s2.ax1x.com/2020/02/13/1qneOJ.png)

然后我们回到原机器 10.10.1.139 中，使用 Virtual Lab 中 Static IP Mapping 技术，我设定了能够让所有机器通过 10.10.1.138 这个地址访问到虚拟实验室中的临时还原环境，这时候，我可以从 10.10.1.138 中抽取这个 dump 进行还原。

![1qnnm9.png](https://s2.ax1x.com/2020/02/13/1qnnm9.png)

还原命令依旧非常简单：

![1qnuwR.png](https://s2.ax1x.com/2020/02/13/1qnuwR.png)

至此，所有数据还原工作完成，我们看到我们希望还原的数据已经全部找回。数据库管理员可以提前终止 UAIR 环境，也可以让它在使用时间到期后自动回收。

好了，今天恢复 MySQL 的样例就是这些，这个恢复没有太多前提条件，唯一的条件就是使用 Veeam Backup & Replication，有了 Veeam 您就能和我一样进行如此轻松的进行**任何**数据库/应用程序对象的恢复了。


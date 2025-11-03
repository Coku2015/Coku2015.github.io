# Veeam Availability for Nutanix AHV 配置和使用系列（一）


Veeam Availability for Nutanix AHV（下文简称 VAN）正式发布了，本文详细介绍下这一新工具的使用方法。

此次的软件发布以 Proxy Appliance 形式，到 Veeam 官网直接下载 Zip 包解压即可得到一个 Disk Image，这是一个 vmdk 文件。和其他 Veeam 软件一样，这里官网依旧能够申请到一个 30 天的试用许可。

VAN 的架构解析：

由于 VAN 的特殊性，这个下载得到的 Appliance 并不能直接使用工作，它是 Veeam Backup & Replication 的一部分，需要依赖 Veeam Backup & Replication 一起才能实现 Nutanix AHV 的数据保护。其架构如下图：

![1jWetU.png](https://s2.ax1x.com/2020/02/14/1jWetU.png)

所以，如果是一个单一的 AHV 环境，我们还是首先需要部署一套 VBR，完了之后再开始 VAN 的部署，而 VBR 中也需要激活相应的 Zero-Socket VBR ENT+的许可，才能完全发挥 VAN 的所有功能。本文对于 VBR 部分就不详细展开说明，请参考官网手册。

VAN 部署方法：

1. 上传镜像至 Nutanix 镜像库中，在 Prism 上选择配置镜像。

![1qdra6.png](https://s2.ax1x.com/2020/02/13/1qdra6.png)

2. 打开配置镜像对话框，选择上传镜像。

![1qd2xH.png](https://s2.ax1x.com/2020/02/13/1qd2xH.png)

3. 为新的镜像输入名称、备注，选择镜像类型为 Disk，选择合适的 Storage Container，然后指定刚刚解压开来的这个 vmdk 的路径后，点击保存。

![1qdWMd.png](https://s2.ax1x.com/2020/02/13/1qdWMd.png)

4. 等待一段时间，AHV 系统经过上传、初始化之后，任务栏在完成所有任务后，我们再次打开配置镜像对话框后，会发现我们上传的 VeeamProxy 这个镜像意见处于 Active 的状态了。

![1qdgRe.png](https://s2.ax1x.com/2020/02/13/1qdgRe.png)

5. 接下去我们开始利用这个 Image 来创建 VM，这个 VM 就是 Nutanix 中用来提取数据的引擎，它和 VMware 环境的中的 Proxy 非常相似，只是这个是 Veeam 封装起来的一个 Linux。

创建 VM 过程也是非常简单，按照手册中的建议配置填即可，2vCPU/2Core/4GB Memory，新增一块磁盘，选择镜像库中的源作为磁盘，然后指定一个网络地址用于初始化访问。

![1qd7i8.png](https://s2.ax1x.com/2020/02/13/1qd7i8.png)

![1qccJ1.png](https://s2.ax1x.com/2020/02/13/1qccJ1.png)![1qcso9.png](https://s2.ax1x.com/2020/02/13/1qcso9.png)

6. 这样，VeeamProxy for AHV 就创建好了。在 AHV 上开启这个虚拟机，经过简单的初始化后，即可进入系统，系统命令行提示，可以通过一个 https 的地址访问到 VAN 并进行初始化配置。到这个步骤，其实 Nutanix 上的所有操作已经完成，接下去就是进入 VAN 界面进行 Veeam Proxy 的初始化配置了。

![1qcWQK.png](https://s2.ax1x.com/2020/02/13/1qcWQK.png)

7. 浏览器打开 Proxy Appliance 地址，纯黑的界面，配上绿色的 Veeam Logo。输入默认的 Admin 后即可进入 Proxy Appliance 首次配置向导。

![1qcfsO.png](https://s2.ax1x.com/2020/02/13/1qcfsO.png)

8. 新的 Proxy Appliance 第一次进入可以选择是全新安装或者从配置文件进行恢复，这里我先选择了全新 Install。

![1qchLD.png](https://s2.ax1x.com/2020/02/13/1qchLD.png)

9. 进入安装向导后，首先需要接受一个最终用户许可协议（End User License Agreement），勾选 Accept 之后点击下一步。

![1qc5ee.png](https://s2.ax1x.com/2020/02/13/1qc5ee.png)

10. 重新设定 Admin 的密码，进入下一步网络设定。

![1qcood.png](https://s2.ax1x.com/2020/02/13/1qcood.png)

11. 为 Proxy 设定主机名以及 ip 地址。

![1qc7FA.png](https://s2.ax1x.com/2020/02/13/1qc7FA.png)

12. 回顾一下设定内容后，点击 Finish 后系统会进行一轮重启，然后初始化配置就完成了。

![1qcHJI.png](https://s2.ax1x.com/2020/02/13/1qcHJI.png)

13. 接下去再次进入 Proxy Appliance 的 web console，会提示输入 License，所有 Nutanix 的许可都会在 Proxy Appliance 上直接管理。从这步开始，需要对这个 Proxy Appliance 进行三项基础配置设定，使其能够进入正常工作状态。

![1qcbWt.png](https://s2.ax1x.com/2020/02/13/1qcbWt.png)

14. 点击右上角齿轮配置图标，进入配置界面，在这里分别激活 License、配置 VBR Server 以及添加 Nutanix Cluster。操作交互方式也非常简单，一些基础信息足够完成配置。

首先是 License，和其他 Veeam 的 License 一样，导入。lic 文件即可。

![1qcOQf.png](https://s2.ax1x.com/2020/02/13/1qcOQf.png)

15. VBR 的配置也非常简单，IP 地址、默认端口、用户名密码即可完成

![1qcXy8.png](https://s2.ax1x.com/2020/02/13/1qcXy8.png)

16. 最后就是 Nutanix Cluster，填入 CVM 地址用户名密码即可配置完成。

![1qcjOS.png](https://s2.ax1x.com/2020/02/13/1qcjOS.png)

以上就是 VAN 的初始化配置，在做完这些配置以后，我们就可以开始对 AHV 中的 VM 进行数据保护了。

关于 AHV 的备份和恢复，我会在下一期中详细介绍。


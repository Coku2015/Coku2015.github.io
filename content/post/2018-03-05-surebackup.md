---
layout: post
title: 备份存档能不能被恢复，这件事情上只有真正做过才知道。
tags: VMware
categories: 数据保护
---



Veeam有一个非常特别的功能，它能够全自动的在线验证备份存档的可用性，确保备份下来的内容是能够被正常恢复的。



![1blqUA.png](https://s2.ax1x.com/2020/02/12/1blqUA.png)

该功能之所以能够确保恢复，是因为它会将备份存档在一个隔离的环境中以一个正常的虚拟机的形态启动起来，然后通过一系列的仿真测试去全自动的测试这个虚拟机的状态，包括了虚拟机的心跳、虚拟机网络的连通性甚至是虚拟机内应用程序和服务的运行状况，在测试完成之后，它还会生成一份验证报告，给出该备份存档可恢复性的相关结论。

Veeam SureBackup适用于VMware和Hyper-V的备份，本文仅以VMware环境为例说明SureBackup的技术原理以及使用方法。

### 如何工作？

Veeam SureBackup在工作时，会依次执行以下步骤完成整个验证过程：

> 1. Veeam Backup & Replication会将Application Group和被验证的虚拟机发布到一个隔离的沙盒环境中，通常我们称作为“数据实验室（DataLab.）”。这些虚拟机是直接从备份存储库的被压缩重删后的备份文件中启动，而不需要被预先还原至VMware的Datastore中。实现这一功能需要依赖Veeam的Instant VM Recovery和vPower NFS Service。
> 2. Veeam Backup & Replication对Application Group和被验证的虚拟机执行一系列的自动化校验测试，通常包含虚拟机心跳、网络ping和应用程序脚本测试，其中应用程序脚本可以通过自定义的方式加入。
> 3. 在基础验证完成后，还可以选择让Veeam SureBackup对备份存档从文件层面执行一次CRC校验，确保在执行任务的过程中未修改原始备份存档。
> 4. 在SureBackup任务结束后，Veeam Backup & Replication对这些虚拟机执行“Unpublish“动作，并且生成一份测试报告，此报告会通过Email的方式发送给指定的管理员。 
>

在整个验证过程中，Veeam会保证所有虚拟机的备份存档处于只读状态，所有因虚拟机运行产生的数据会存放在虚拟机Redo Log中，这些Redo Log通常会存放于VMware的生成存储上，而当验证过程结束时，Veeam会删除这些Redo Log，释放临时空间。

### 验证过程中的组件

和通常备份的基础架构不一样的是，执行Veeam SureBackup时，会需要用到几个SureBackup专用的对象。

1. Application Group - 在验证某些虚拟机时，这些虚拟机需要依赖一些其他的虚拟机才能正常启动和工作，Application Group就是为这些虚拟机正常工作提供所需的其他依赖应用程序和服务。通常我们会将运行这些应用程序和服务的虚拟机放入应用组，为验证提供依赖条件。举例来说，当我们需要去验证一台Exchange服务器时，该Exchange服务的启动需要有AD和DNS服务，因此，我们可以在Application   Group中加入提供AD和DNS服务的虚拟机，用来为Exchange提供启动依赖。
2. Virtual Lab - 这是一个隔离的虚拟化沙盒环境，Application Group中的虚拟机和被验证的虚拟机都会在这个沙盒中启动起来。
3. SureBackup Job - 这是来自动或者手动执行验证备份存档的任务。它能够定时定期执行，也能够手动执行。

### SureBackup 实战

如上面提到的，SureBackup有3个专用对象，因此在使用和配置SureBackup过程中显然需要进行这3个对象的设置。

#### Application Group

这也是整个生产环境基础架构中最最重要的服务之一，其他应用程序的启动和运行都依赖这些机器。简单来说，Application Group就是定义一组虚拟机，这组虚拟机非常重要，其他被验证的虚拟机没有这组虚拟机无法工作。也就是当我们的环境中存在这样的虚拟机，那我们就需要将他定义为Application Group，以便其他机器在被校验时能够访问到这些虚拟机和服务。

当然，Application Group中的这些虚拟机也是从备份镜像中启动起来，需要预先被备份，而不是直接使用生产环境的虚拟机。SureBackup对于Application Group中的虚拟机，也会定义一系列的校验和检测，确保Application Group中的虚拟机首先正常工作，然后才开始后续的其他虚拟机验证。当Application Group中的虚拟机验证失败的情况下，SureBackup将会中止工作，不会继续后续的虚拟机验证，这是因为SureBackup默认Application Group无法正常工作的情况下其他被验证的虚拟机也无法正常启动。因此，请不要在Application Group中放置非必要的虚拟机；如果被验证的虚拟机无需其他应用程序和服务依赖，则请不要在Application Group中放置虚拟机。

- **配置方法**

Application Group的创建非常简单，将Veeam Backup &Replication 主界面切换到Backup Infrastructure下，在清单面板中选择SureBackup节点，这时候在右边的内容显示区域，可以找到Add Application Group。

![1HPjR1.png](https://s2.ax1x.com/2020/02/12/1HPjR1.png)

点击这个链接会弹出Veeam经典的向导设置界面。

首先是设定Application Group Name和Description，这个可以根据需要设定，没什么特别要求，方便识别和符合企业/组织的命名规范即可。

![1HPvxx.png](https://s2.ax1x.com/2020/02/12/1HPvxx.png)

接下来是设定这个Application Group中有哪些虚拟机，这就如上文解释的，我们可以将备份存档、复制存档或存储快照存档中的VM加入到Application Group中，这3种添加模式分别对应了Veeam SureBackup的3种分支功能：SureBackup/SureReplica/Ondemand Sandbox for StorageSnapshot。此处暂且不详细展开去讨论这3种分支功能的具体使用。我们就是用通常备份验证中用的最多的From Backup。这也是上文中提到，Application Group中的虚拟机也必须是预先被备份，而不能是直接选择生产环境中的相关虚拟机。

![1HPqIJ.png](https://s2.ax1x.com/2020/02/12/1HPqIJ.png)

选择完虚拟机后，可以为这些选择的虚拟机设定一些验证选项，这也是上文提到的，Application Group中的虚拟机必须首先被验证能正常工作，才能进行后续操作。这里的验证选项包括内置的一些服务器角色，比如DNS Server、Domain Controller、Global Catalog、Mail Server、SQL Server、Web Server等，选中这些服务器角色时，Veeam会自动使用适合这些角色的预定义脚本验证这些角色服务器。（关于Domain Controller的Authoritative Restore和Non-Authoritative Restore知识点，本文不详细阐述，读者可自行百度。）

![1HiPde.png](https://s2.ax1x.com/2020/02/12/1HiPde.png)

在这个验证选项中还有启动选项、测试脚本和账户凭据设置，在此就不一一详述，这些都是对应验证过程中一些详细的设定选项，对于特别的应用程序在测试中有帮助，具体可以参考Veeam官网手册说明。

这样，一个Application Group就基本设置完成了，可以通过最后一个Summary页面回顾下设定的内容。

![1HipqO.png](https://s2.ax1x.com/2020/02/12/1HipqO.png)



#### Virtual Lab

这是被验证的虚拟机所运行的隔离环境，在这个环境中Veeam Backup & Replication将会逐个启动Application Group中的虚拟机，然后再启动需要被验证的虚拟机。

Virtual Lab本身其实几乎不消耗任何资源，它可以在任意的ESXi主机上被部署，当需要被验证的虚拟机启动的时候，Virtual Lab才会请求计算资源分配给这些虚拟机。Virtual Lab会在隔离环境中创造出一套网络，它将生产环境中的网络完整的镜像至Virtual Lab创造出来的这套网络中，在Virtual Lab中启动的虚拟机和原虚拟机拥有一模一样的IP地址配置，因此在Virtual Lab中启动的这些虚拟机能够和生产环境一样正常的工作。

在Virtual Lab之中，有非常重要的概念，分别是：Proxy Appliance、IP Masquerading、Static IP Mapping。

##### **Proxy Appliance**

为了和生产网络能够通讯，Veeam Backup & Replication又使用了一个Proxy appliance。这个Proxy Appliance是一个基于Linux的轻量级虚拟机，它会被创建在每一个Virtual Lab中，通过这个Proxy Appliance的多个网卡将Virtual Lab中的虚拟机和生产环境进行连通。

##### **IP Masquerading**

Veeam建立起一套规则，让生产网络能够通过特定的IP地址访问隔离网络，同时又不用修改隔离网络内的IP地址配置，那么这套重要规则就是IP Masquerading。



![1HiAJA.png](https://s2.ax1x.com/2020/02/12/1HiAJA.png)



每一个生产网络中的IP地址，在隔离网络中，都会通过IP Masquerading建立起一个一一对应的地址，比如生产网络中的地址是172.16.10.10，IP Masquerading规则是172.16.10.X/24对应172.18.10.X/24，那么这台虚拟机的备份存档在Virtual Lab中启动起来后的Masquerade IP地址会自动被分配为172.18.10.10。

这个规则会通过静态路由的形式被添加至VBR备份服务器和Virtual Lab Client的所运行的桌面上。当有网络访问172.18.10.10时，Proxy Appliance会充当一个NAT服务器的角色，将访问转发至Virtual Lab内的这台虚拟机上。而实际上Virtual Lab内的这台虚拟机此时启动后的IP地址本身并没有发生变化。

##### **Static IP Mapping**

上面提到这样的静态路由仅会被添加至VBR备份服务器和Virtual Lab Client，那么当有很多客户端的都需要访问这个Virtual Lab中的虚拟机时，手动逐台添加静态路由会很不方便。

![1HiERI.png](https://s2.ax1x.com/2020/02/12/1HiERI.png)

这时候，在这种场景下Veeam提供Static IP Mapping为更多的虚拟机的访问提供方便快速的设置方法。我们可以利用172.16.10.X网络中其中一个空闲的IP：172.16.10.99做一个静态映射，将其映射给172.18.10.10，这时候网络上的所有客户的都可以通过172.16.10.99这个IP地址访问到Virtual Lab中的这台虚拟机，而不用逐台添加172.18.10.X的静态路由。

- **配置Virtual Lab**

因为Virtual Lab的配置有3种不同模式，本文不详细讨论3种模式的区别，仅以最常用的Advanced Single-Host Virtual Lab为例介绍配置方法。

将Veeam Backup &Replication 主界面切换到Backup Infrastructure下，在清单面板中选择SureBackup节点，这时候在右边的内容显示区域，可以找到Add Virtual Lab。

![1blyB4.png](https://s2.ax1x.com/2020/02/12/1blyB4.png)

点击这个链接会弹出Veeam经典的向导设置界面。

首先是设定Virtual Lab Name和Description，这个可以根据需要设定，没什么特别要求，方便识别和符合企业/组织的命名规范即可。

![1bl6HJ.png](https://s2.ax1x.com/2020/02/12/1bl6HJ.png)

选择主机，选择此Virtual Lab是运行哪一个ESXi主机上，每一个Virtual Lab仅允许运行在一个ESXi主机上。

![1blsuF.png](https://s2.ax1x.com/2020/02/12/1blsuF.png)

选择数据存储，Virtual Lab中产生的临时数据和Virtual Lab必要的一些运行文件会存放在这个Datastore中，包括临时的虚拟机Redo log也会存放在这个Datastore中。它的容量主要还是取决于Virtual Lab开启后数据的改变情况，在一般没有太多改变的时候，这个容量要求并不太高。

![1blDjU.png](https://s2.ax1x.com/2020/02/12/1blDjU.png)

设置Proxy Appliance，这一步需要设置是否使用Proxy Appliance以及如何将Proxy Appliance连接到生产网络。一般来说，全自动的验证和数据实验室都是需要Proxy Appliance的，因此默认都会启用Proxy Appliance。而在不选择使用Proxy Appliance的场景中，则所有的验证都需要通过手工进入虚拟机内控制台去操作实现。在启用Proxy Appliance后，需要配置Proxy Appliance的虚拟机名称、IP地址设定以及是否通过Internet代理连接互联网。

![1blh36.png](https://s2.ax1x.com/2020/02/12/1blh36.png)

设置隔离网络，在这里配置所有Application Group和需要被验证的虚拟机所连接的网络至隔离网络的一一对应关系。假设在生产环境中有4个不同的端口组，那么在这个隔离网络设置中就需要4个不同端口组与之对应。

![1blBcT.png](https://s2.ax1x.com/2020/02/12/1blBcT.png)

Network Setting，这个步骤中，为Proxy Appliance连接到每个隔离网络的那块vNIC设定IP地址，并且为每个隔离网络设置IP Masquerading规则。一般来说连接到隔离网络的那块vNIC都会指定实际生产网络中该网段的网关地址，这样的网络配置不会产生冲突也不需要对Virtual Lab中启动的虚拟机进修改。

![1blgE9.png](https://s2.ax1x.com/2020/02/12/1blgE9.png)

Static IP Mapping，这里按需进行定义即可，如果没有很多客户端访问的时候，可以不作任何设定。

![1bl4gK.png](https://s2.ax1x.com/2020/02/12/1bl4gK.png)

如此，查看下此Virtual Lab配置后，即可完成设定。

![1blouD.png](https://s2.ax1x.com/2020/02/12/1blouD.png)

SureBackup Job

 最后，就是设定哪些虚拟机需要进行验证、在哪个Virtual Lab中验证以及在什么时候验证。这个工作全部在SureBackup Job中进行。

 启动SureBackup Job的创建向导 

![1Himsf.png](https://s2.ax1x.com/2020/02/12/1Himsf.png)

设定SureBackup Job名称和描述。

![1blY7j.png](https://s2.ax1x.com/2020/02/12/1blY7j.png)

选择在哪个Virtual Lab中运行SureBackup Job

![1blUNn.png](https://s2.ax1x.com/2020/02/12/1blUNn.png)

选择是否需要Application Group、需要哪个Application Group才能运行

![1HiVzt.png](https://s2.ax1x.com/2020/02/12/1HiVzt.png)

选择哪个备份Job在备份完成后需要被验证

![1blJBQ.png](https://s2.ax1x.com/2020/02/12/1blJBQ.png)

这里还能对备份Job中单个VM进行详细设定，设定的内容是和Application Group中类似。

![1blahq.png](https://s2.ax1x.com/2020/02/12/1blahq.png)

设置验证完成后如何通知管理员

![1bl3jS.png](https://s2.ax1x.com/2020/02/12/1bl3jS.png)

置SureBackup Job在什么时候运行，通常可以选择After this Job选项，选择在备份结束后立刻跟着验证备份结果。



![1blNAs.png](https://s2.ax1x.com/2020/02/12/1blNAs.png)

如此，SureBackup就设定完成了。如果设置的内容一切正常，配置正确，那么SureBackup验证就会自动进行，确保备份时有效可用的。

![1bl03V.png](https://s2.ax1x.com/2020/02/12/1bl03V.png)

而在邮箱中就能收到如下的报告哦。

![1blw90.png](https://s2.ax1x.com/2020/02/12/1blw90.png)

最后，SureBackup这一功能包含在Veeam Backup &Replication产品的Enterprise和Enterprise Plus版本中，而在Standard版本中并不包含此功能，在Standard版本中如需验证备份存档可用性，那只能通过完全手动的方式进行喽。
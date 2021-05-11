---
layout: post
title: VMware VAIO技术概览
tags: Veeam CDP
categories: VMware

---

下周，Veeam即将发布旗舰产品VAS套件全新的v11版本，在这个版本中最重要的一个功能就是Veeam CDP。我相信不少朋友期待这个功能已经很久了，而事实上Veeam通过接近5年的精雕细琢，终于在v11中正式发布了这个功能。由于这个CDP功能在使用VMware相关技术时和以往的备份复制有很大的不同，今天我想带大家提前来做一些准备，介绍一些CDP背后使用的VMware相关技术和API接口，以帮助大家更好的理解这个CDP技术。

## vSphere APIs for I/O filtering简介

Veeam CDP使用的是VMware vSphere APIs for I/O Filtering （VAIO）技术，这个技术早在vSphere 6.0U1的时候就发布了第一版，而到了vSphere 6.5开始这个技术逐渐成熟。简单来说，VAIO是一个框架，它可以为使用这个框架的一系列应用程序提供在虚拟机I/O路径中插入I/O过滤器（I/O Filters）的能力。而这些I/O过滤器则可以在I/O路径中来捕获虚拟机的I/O，从而实现在I/O写入物理磁盘前的各种处理。

VMware定义了I/O过滤器的4种使用场景，分别是：

- 复制(Replication)
- 缓存(Caching)
- 存储I/O控制(Storage I/O control)
- 加密(Encryption)

其中存储I/O控制和加密这两种场景目前仅限于VMware自己使用，而复制和缓存这两种场景则开放给第三方厂商制作第三方的解决方案。和备份解决方案利用VADP接口一样，利用VAIO接口的第三方解决方案同样会通过严格的VMware Ready认证，认证之后可以在VMware官网上查询到第三方组件的兼容性列表。

## vSphere APIs for I/O filtering技术原理

VAIO由两部分组成，一部分是VMware端的VAIO过滤器框架(VAIO Filter Framework)，这部分是VMware在每个ESXi中标准化提供的内容，从vSphere 6.0U1以后就已经内置在ESXi核心中了；另外一部分是I/O过滤器，这些过滤器都会在VAIO过滤器框架中逐个运行。如下图，一台虚拟机在运行时，它的I/O路径会从客户机操作系统(GuestOS)经过VAIO过滤器框架再进入VMDK之中，而在经过VAIO过滤器框架的时候，会逐个逐个被框架定义好的过滤器进行处理，当VAIO过滤器框架中所有的过滤器都完成处理后，这个I/O请求就会被移到最终的VMDK中。

![filters](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.storage.doc/images/GUID-E2E70213-2D67-4662-BFA7-82BD1893820B-high.png)

很显然，通过上面这个过程，大家可以看到，VAIO工作的时候是针对某一台虚拟机的，VAIO框架为每台虚拟机定义了各自可以使用的过滤器，因此每台虚拟机在各自的I/O路径上如果发生任何的I/O错误，甚至是过滤器层面的错误，也被严格的隔离在这台虚拟机之内，并不会影响整台ESXi以及其他虚拟机。

另外，VAIO框架还做了一些限定，I/O过滤器根据使用场景对应定义了4个大类，在每台ESXi上每一类的I/O过滤器只能同时存在一个。比如，对于复制类的I/O过滤器，如果Veeam提供的CDP过滤器已经存在，那么其他厂商的过滤器就无法在这台ESXi上进行安装了。

## vSphere APIs for I/O filtering管理技巧

通常来说，除了内置的I/O过滤器之外，第三方的I/O过滤器一般都会由第三方厂商提供集成安装服务，因此在vSphere Client中并无相关的安装按钮。然而，在vSphere Client中，管理员可以很方便的找到自己的Cluster和ESXi上的VAIO部署和使用情况，了解当前的状态。

### 在Cluster中查看

选中需要查看的Cluster，找到右边的Configure标签，然后可以在Configuration节点下找到I/O Filters来查看当前群集中Filters的安装状况，如下图。

[![yfhsb9.png](https://s3.ax1x.com/2021/02/19/yfhsb9.png)](https://imgchr.com/i/yfhsb9)

### 在ESXi中查看

选中需要查看的ESXi，找到右边的Configure标签，然后可以在Storage节点下找到I/O Filters来查看当前ESXi上Filters的安装情况，如下图。

[![yfhrDJ.png](https://s3.ax1x.com/2021/02/19/yfhrDJ.png)](https://imgchr.com/i/yfhrDJ)

在ESXi上和在Cluster上看到的I/O过滤器情况略有不同，在ESXi上可以看到VMware自己使用的两种过滤器类型，其中spm是数据存储I/O控制用的过滤器，vmwarevmcrypt则是加密用的过滤器。

特别要注意的是，在图中显示的Type列中会列出各个过滤器的类型，每种类型有且只能有一个过滤器。

### I/O过滤器存储策略

I/O过滤器的使用必须配合着vSphere中VM Storage Policy来进行，通常来说在I/O过滤器的使用过程中，第三方软件会全自动来配置相关的VM Storage Policy，而配置完成后，在vSphere Client的VM Storage Policy中能找到配置好的VM Storage Policy，比如Veeam CDP的过滤器，如下图：

[![yfhcU1.png](https://s3.ax1x.com/2021/02/19/yfhcU1.png)](https://imgchr.com/i/yfhcU1)

当虚拟机使用了I/O过滤器进行处理后，可以选中某个虚拟机，找到Configure标签，在Policies节点下，能看到当前的Policies使用和分配情况，如下图：

[![yfh6ER.png](https://s3.ax1x.com/2021/02/19/yfh6ER.png)](https://imgchr.com/i/yfh6ER)

## vSphere APIs for I/O filtering安装排错技巧

VAIO由框架和过滤器组成，框架方面集成在ESXi内，天然具备；因此绝大多数可能碰到的问题都会集中在过滤器方面，特别是过滤器的安装过程，会有可能碰到一些挑战。然而这个过滤器的安装其实就是一个标准的ESXi VIB软件包的安装，这时候碰到的问题其实也相当简单，可以做如下检查和排错：

- VIB软件包URL是否能够正常被访问？
- 厂商提供的VIB软件包是否正确？
- 升级和卸载过程中VIB软件包要求的ESXi主机维护模式状态是否正确？
- VIB软件包安装后可能会要求ESXi主机重启
- 自动切换维护模式过程中，切换失败？
- 和其他同类过滤器的VIB软件包冲突？

关于已经安装好的软件包的状况，可以通过选中ESXi，在右边的Configure标签中，找到System节点下的Packages来查看VIB软件包的清单，如下图。

[![yfhg4x.png](https://s3.ax1x.com/2021/02/19/yfhg4x.png)](https://imgchr.com/i/yfhg4x)

以上就是今天的内容，希望这些内容能够对大家后面了解Veeam CDP有所帮助。


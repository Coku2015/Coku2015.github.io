---
layout: post
title: VMware VAIO 技术概览
tags: ['Veeam CDP']
categories: VMware

---

下周，Veeam 即将发布旗舰产品 VAS 套件全新的 v11 版本，在这个版本中最重要的一个功能就是 Veeam CDP。我相信不少朋友期待这个功能已经很久了，而事实上 Veeam 通过接近 5 年的精雕细琢，终于在 v11 中正式发布了这个功能。由于这个 CDP 功能在使用 VMware 相关技术时和以往的备份复制有很大的不同，今天我想带大家提前来做一些准备，介绍一些 CDP 背后使用的 VMware 相关技术和 API 接口，以帮助大家更好的理解这个 CDP 技术。

## vSphere APIs for I/O filtering 简介

Veeam CDP 使用的是 VMware vSphere APIs for I/O Filtering （VAIO）技术，这个技术早在 vSphere 6.0U1 的时候就发布了第一版，而到了 vSphere 6.5 开始这个技术逐渐成熟。简单来说，VAIO 是一个框架，它可以为使用这个框架的一系列应用程序提供在虚拟机 I/O 路径中插入 I/O 过滤器（I/O Filters）的能力。而这些 I/O 过滤器则可以在 I/O 路径中来捕获虚拟机的 I/O，从而实现在 I/O 写入物理磁盘前的各种处理。

VMware 定义了 I/O 过滤器的 4 种使用场景，分别是：

- 复制 (Replication)
- 缓存 (Caching)
- 存储 I/O 控制 (Storage I/O control)
- 加密 (Encryption)

其中存储 I/O 控制和加密这两种场景目前仅限于 VMware 自己使用，而复制和缓存这两种场景则开放给第三方厂商制作第三方的解决方案。和备份解决方案利用 VADP 接口一样，利用 VAIO 接口的第三方解决方案同样会通过严格的 VMware Ready 认证，认证之后可以在 VMware 官网上查询到第三方组件的兼容性列表。

## vSphere APIs for I/O filtering 技术原理

VAIO 由两部分组成，一部分是 VMware 端的 VAIO 过滤器框架 (VAIO Filter Framework)，这部分是 VMware 在每个 ESXi 中标准化提供的内容，从 vSphere 6.0U1 以后就已经内置在 ESXi 核心中了；另外一部分是 I/O 过滤器，这些过滤器都会在 VAIO 过滤器框架中逐个运行。如下图，一台虚拟机在运行时，它的 I/O 路径会从客户机操作系统 (GuestOS) 经过 VAIO 过滤器框架再进入 VMDK 之中，而在经过 VAIO 过滤器框架的时候，会逐个逐个被框架定义好的过滤器进行处理，当 VAIO 过滤器框架中所有的过滤器都完成处理后，这个 I/O 请求就会被移到最终的 VMDK 中。

![filters](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.storage.doc/images/GUID-E2E70213-2D67-4662-BFA7-82BD1893820B-high.png)

很显然，通过上面这个过程，大家可以看到，VAIO 工作的时候是针对某一台虚拟机的，VAIO 框架为每台虚拟机定义了各自可以使用的过滤器，因此每台虚拟机在各自的 I/O 路径上如果发生任何的 I/O 错误，甚至是过滤器层面的错误，也被严格的隔离在这台虚拟机之内，并不会影响整台 ESXi 以及其他虚拟机。

另外，VAIO 框架还做了一些限定，I/O 过滤器根据使用场景对应定义了 4 个大类，在每台 ESXi 上每一类的 I/O 过滤器只能同时存在一个。比如，对于复制类的 I/O 过滤器，如果 Veeam 提供的 CDP 过滤器已经存在，那么其他厂商的过滤器就无法在这台 ESXi 上进行安装了。

## vSphere APIs for I/O filtering 管理技巧

通常来说，除了内置的 I/O 过滤器之外，第三方的 I/O 过滤器一般都会由第三方厂商提供集成安装服务，因此在 vSphere Client 中并无相关的安装按钮。然而，在 vSphere Client 中，管理员可以很方便的找到自己的 Cluster 和 ESXi 上的 VAIO 部署和使用情况，了解当前的状态。

### 在 Cluster 中查看

选中需要查看的 Cluster，找到右边的 Configure 标签，然后可以在 Configuration 节点下找到 I/O Filters 来查看当前群集中 Filters 的安装状况，如下图。

[![yfhsb9.png](https://s3.ax1x.com/2021/02/19/yfhsb9.png)](https://imgchr.com/i/yfhsb9)

### 在 ESXi 中查看

选中需要查看的 ESXi，找到右边的 Configure 标签，然后可以在 Storage 节点下找到 I/O Filters 来查看当前 ESXi 上 Filters 的安装情况，如下图。

[![yfhrDJ.png](https://s3.ax1x.com/2021/02/19/yfhrDJ.png)](https://imgchr.com/i/yfhrDJ)

在 ESXi 上和在 Cluster 上看到的 I/O 过滤器情况略有不同，在 ESXi 上可以看到 VMware 自己使用的两种过滤器类型，其中 spm 是数据存储 I/O 控制用的过滤器，vmwarevmcrypt 则是加密用的过滤器。

特别要注意的是，在图中显示的 Type 列中会列出各个过滤器的类型，每种类型有且只能有一个过滤器。

### I/O 过滤器存储策略

I/O 过滤器的使用必须配合着 vSphere 中 VM Storage Policy 来进行，通常来说在 I/O 过滤器的使用过程中，第三方软件会全自动来配置相关的 VM Storage Policy，而配置完成后，在 vSphere Client 的 VM Storage Policy 中能找到配置好的 VM Storage Policy，比如 Veeam CDP 的过滤器，如下图：

[![yfhcU1.png](https://s3.ax1x.com/2021/02/19/yfhcU1.png)](https://imgchr.com/i/yfhcU1)

当虚拟机使用了 I/O 过滤器进行处理后，可以选中某个虚拟机，找到 Configure 标签，在 Policies 节点下，能看到当前的 Policies 使用和分配情况，如下图：

[![yfh6ER.png](https://s3.ax1x.com/2021/02/19/yfh6ER.png)](https://imgchr.com/i/yfh6ER)

## vSphere APIs for I/O filtering 安装排错技巧

VAIO 由框架和过滤器组成，框架方面集成在 ESXi 内，天然具备；因此绝大多数可能碰到的问题都会集中在过滤器方面，特别是过滤器的安装过程，会有可能碰到一些挑战。然而这个过滤器的安装其实就是一个标准的 ESXi VIB 软件包的安装，这时候碰到的问题其实也相当简单，可以做如下检查和排错：

- VIB 软件包 URL 是否能够正常被访问？
- 厂商提供的 VIB 软件包是否正确？
- 升级和卸载过程中 VIB 软件包要求的 ESXi 主机维护模式状态是否正确？
- VIB 软件包安装后可能会要求 ESXi 主机重启
- 自动切换维护模式过程中，切换失败？
- 和其他同类过滤器的 VIB 软件包冲突？

关于已经安装好的软件包的状况，可以通过选中 ESXi，在右边的 Configure 标签中，找到 System 节点下的 Packages 来查看 VIB 软件包的清单，如下图。

[![yfhg4x.png](https://s3.ax1x.com/2021/02/19/yfhg4x.png)](https://imgchr.com/i/yfhg4x)

以上就是今天的内容，希望这些内容能够对大家后面了解 Veeam CDP 有所帮助。

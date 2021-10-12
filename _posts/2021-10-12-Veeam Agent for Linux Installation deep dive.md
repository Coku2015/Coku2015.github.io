---
layout: post
title: Veeam Agent for Linux 安装深度分析
tags: 备份
categories: Linux Agent
---

## 一. 组成和作用
Veeam Agent for Linux（以下简称VAL）由两部分组成，一个是Veeam主程序，另外一个是Veeamsnap驱动程序。以centos/redhat举例，如果想让Veeam Agent for Linux正常工作，一般来说我们需要安装上两个程序，分别是：

```
veeam-<xxxxxxxxxxx>.rpm
veeamsnap-<xxxxxxxxxxx>.rpm
```

其中，Veeamsnap驱动程序负责系统快照和变化数据块追踪工作，而Veeam主程序则负责其他所有相关的工作，当Veeam主程序被安装时，依赖包Veeamsnap会被自动安装。

## 二. 安装过程
在安装时，VAL需要安装一系列Linux依赖包，这些依赖包会自动通过Linux的包管理器去Linux相关的软件镜像源中搜索，关于这部分，可以参考[《Veeam Agent for Linux基础知识》](https://blog.backupnext.cloud/2020/09/Veeam-Linux-Agent-101/)。
大部分比较顺滑的情况，是通过VBR进行VAL的推送安装，VBR会自动处理以下的所有安装逻辑，自动判断自动安装最合适的软件包，但是在这背后，有多种特殊情况存在。

### 2.1. dkms编译安装
对于Veeamsnap来说，它是一个Linux内核外的驱动程序，对于不同的Linux系统，绝大多数情况下无法通用。因此Veeam采用了DKMS来帮助维护这个驱动程序，安装`veeamsnap-<xxxxxxxxxxx>.rpm`时，会将Veeamsnap模块自动添加至dkms中并执行编译和安装模块的过程。

关于DKMS，它是Dell创建的开源项目，全称是Dynamic Kernel Module Support，用于维护内核外的驱动程序, 详细内容可以参考https://www.cnblogs.com/wwang/archive/2011/06/21/2085571.html

要正确安装并编译Veeamsnap快照驱动，就需要首先安装并配置dkms能正常工作，这部分在绝大多数Linux系统中并不算复杂，Veeamsnap会去自动寻找dkms依赖包并把和dkms相关的gcc、make、kernel-header自动装上，然后使用它们进行安装和编译驱动过程。

### 2.2. 预编译安装包
对于特定的Linux发行版，Veeam还制作了无需编译安装的Veeamsnap，这些Veeamsnap安装包我们称为kmod-veeamsnap，这些安装包和上面提到的`veeamsnap-<xxxxxxxxxxx>.rpm`功能完全相同，只是在使用时，无需通过dkms编译，而是直接使用。这时候dkms编译的前提条件和依赖对于kmod-veeamsnap就完全不需要了。

已经预编译的系统包括：

- 内核版本2.6.32-131.0.15以上的Radhat 6
- 内核版本3.10.0-123以上的CentOS/Radhat 7.0-7.9
- CentOS/Radhat 8
- SLES
- openSUSE

这些系统的kmod安装包都可以在http://repository.veeam.com/.private/rpm中找到。

需要注意的是，因为是预编译的软件包，对于不同的系统需要选择不同的驱动，这时候这个选择Veeam需要借助python3脚本来完成，这时候Linux系统需要依赖Python3。在安装`kmod-veeamsnap--<xxxxxxxxxxx>.rpm`时，VAL会自动寻找python3依赖包，安装并使用，最终完成kmod-veeamsnap的安装。

### 2.3. 启用安全引导（UEFI的Secure  Boot）
对于启用了UEFI安全引导的Linux系统，要使用kmod-veeamsnap，需要将kmod-veeamsnap的证书导入到UEFI控制台中。这个证书可以先使用veeamsnap-ueficert-5.0.1.4493-1.noarch.rpm这个包获取，具体步骤如下：
1. 下载并安装veeamsnap-ueficert-5.0.1.4493-1.noarch.rpm
```shell
curl -O http://repository.veeam.com/.private/rpm/el/8/x86_64/veeamsnap-ueficert-5.0.1.4493-1.noarch.rpm
rpm -ivh veeamsnap-ueficert*
```

2. 执行导入命令
```shell
mokutil --import veeamsnap-ueficert.crt
```
3. 重启Linux系统进入UEFI Bios控制台里，去分配下这个证书

后续的kmod-veeamsnap安装过程和2.2中没任何区别。

### 2.4. 😂😂不使用Veeamsnap

以上这些veeamsnap都没条件使用时，从VAL 5.0.1起，Veeam提供snapless的备份方式，提供了不依赖veeamsnap工作的VAL主程序：
http://repository.veeam.com/.private/rpm/el/8/x86_64/veeam-nosnap-5.0.1.4493-1.el8.x86_64.rpm

这个程序无法支持快照备份，只能通过File level snapshot-less的方式进行文件备份，如下图：

![](https://helpcenter.veeam.com/docs/agentforlinux/userguide/images/backup_job_mode.png)

当然，在VBR中也有同样的选项：

![](https://helpcenter.veeam.com/docs/backup/agents/images/agent_job_mode_linux.png)

这个主程序可以直接单独安装，在安装的时候它不会再去要求veeamsnap的依赖，而其他的常规依赖包依然是通过Linux包管理器自动获取。

以上就是今天的内容，希望对大家安装VAL有帮助。
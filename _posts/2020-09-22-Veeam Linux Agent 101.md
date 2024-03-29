---
layout: post
title: Veeam Agent for Linux 基础知识
tags: VBR
categories: 数据保护

---

自从年初 Veeam Agent for Linux 4.0（简称 VAL）随着 VBR V10 推出以来，这个功能越来越强大的备份代理使用也越来越广，不管是云上还是云下、虚拟还是物理，总有场景会用到 VAL。然而我们发现对于刚刚接触 VAL 的朋友们其实还是会受到这个代理安装过程的困扰，就算是全自动的推送安装，依然会有朋友会碰到各种各样的安装问题。这让本来以使用体验极佳著称的 Veeam 备份软件变得很尴尬，“It just works!”的口号都不敢随便喊了。

其实，Veeam 还是那么简单，VAL 一样是这种简单极致的体验，就算是在大众门槛略高的 Linux 开源世界，只需要稍稍注意，就可以体验到 VAL 的极致简单使用体验。当然这需要一点点小技巧，对于熟练使用 Linux 的朋友，这些都不是问题，而对于不少只是因为要备份才接触 Linux 的备份管理员来说，会略有一些挑战。这主要原因是来自于 VAL 的软件安装依赖包，和 Windows 不一样的是，Veeam 在所有 Windows Server 所需要安装的依赖包都集成在 Veeam 软件中，VBR 会全自动的去推送所有缺失的依赖包。而对于 Linux 来说，在 Veeam 软件包中其实并不包含任何的依赖包，**<u>所有这些依赖包都来自于 Linux 系统本身的 Software Package Manager</u>**，这里要划个重点！

什么是 Package Manager？

打个比方，这个就是和手机的应用市场类似，每一个 Linux 系统都内置了这样的 Package Manager，而不同发行版的 Linux 可能会使用不一样的 Package Manager。Package Manager 非常的智能，通常在主流的 Linux 发行版中安装软件最简单的方法就是通过 Package Manager 的一行命令就完成了，Package Manager 会全自动的完成所有依赖组件的安装，最终交付相应软件给管理员使用。

在 VAL 支持的多种操作系统中，不同的系统使用不同的 Package Manager，下面就是这些系统所对应使用的 Package Manager 清单。

| Linux 发行版                       | 默认常见的 Package Manager |
| --------------------------------- | ------------------------- |
| CentOS/Redhat/Oracle Linux/Fedora | yum                       |
| Debian/Ubuntu                     | Apt                       |
| SLES/openSUSE                     | zypper                    |

很显然，不管使用什么方式，我们要正常安装 VAL，第一个前提条件就是 Package Manager 能够正常的工作，这个在有互联网连接的 Linux 系统中，完全没问题，绝大多数情况下系统安装完成后就自带了合适的软件安装源；然而在无法访问互联网的服务器数据中心，如果没有合理配置内部源，就会碰到各种报错了。处理方法也很简单，只需要去对应的 Linux 发行版的官网，下载当前版本的最新版 ISO，并制作成本地源即可。比如，CentOS6.x 就下载 CentOS 6.10 的 iso，CentOS 7.x 就下载 CentOS 7.8.2003 的 iso 镜像，然后挂载到 CentOS 中。本文以常见的 CentOS 7.6 为例说明下这个配置的全过程。

1. 首先找一个 CentOS 7.8.2003 的镜像下载点，比如阿里云的
   https://mirrors.aliyun.com/centos/7.8.2003/isos/x86_64/
2. 在 CentOS 中，挂上这个刚刚下载到的镜像。

```bash
[centos@localhost ~]$ sudo mkdir /mnt/cdrom
[centos@localhost ~]$ sudo mount /dev/cdrom /mnt/cdrom
```

3. 备份并移动/etc/yum.repo.d/CentOS-Base.repo，确保系统不使用默认互联网上的 yum 源。

```bash
[centos@localhost ~]$ sudo mv /etc/yum.repo.d/CentOS-Base.repo ~/CentOS-Base.repo
```

4. 编辑/etc/yum.repo.d/CentOS-Media.repo，其中需要修改 baseurl 字段和 enabled 字段。baseurl 指向本地源的 iso 路径，为第二步中挂载的路径/mnt/cdrom；enabled 为启用这个源配置文件。

```bash
[centos@localhost ~]$ sudo vi /etc/yum.repo.d/CentOS-Media.repo

# CentOS-Media.repo
#
#  This repo can be used with mounted DVD media, verify the mount point for
#  CentOS-7.  You can use this repo and yum to install items directly off the
#  DVD ISO that we release.
#
# To use this repo, put in your DVD and use it with the other repos too:
#  yum --enablerepo=c7-media [command]
#
# or for ONLY the media repo, do this:
#
#  yum --disablerepo=\* --enablerepo=c7-media [command]

[c7-media]
name=CentOS-$releasever - Media
baseurl=file:///mnt/cdrom/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

~
"/etc/yum.repos.d/CentOS-Media.repo" 22L, 630C

```

5. 配置完成后，执行 yum clean all 和 yum makecache 命令更新 yum 信息并检查可用性，用 yum repolist 列出本地源详细信息。
```bash
[centos@localhost ~]$ sudo yum clean all
[centos@localhost ~]$ sudo yum makecache
[centos@localhost ~]$ sudo yum repolist
```

6. 接下去，回到 VBR 中，不管是使用 VBR 的推送 VAL 安装还是手工执行 standalone 版本的 VAL 安装，都将会畅通无阻，所有缺失的依赖包，VBR 会让 yum 自动去光盘镜像中找相关的内容安装上。

以上就是今天的推送，希望帮到那些刚接触 Veeam Agent for Linux 的朋友们。另外，近期我推出了一个全新的每日一图的公众号，在那边大家能够每天收到一个非常简单的 Veeam 操作示例，帮助大家快速了解配置 Veeam 的方法，也欢迎大家关注。

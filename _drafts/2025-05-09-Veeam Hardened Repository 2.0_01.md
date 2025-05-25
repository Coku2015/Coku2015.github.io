---
layout: post
title: Managed Hardened Repository ISO by Veeam 2.0
tags: 备份
categories: Repository
---

现在软件发布的节奏是越来越快，Veeam Hardened Repository也在几个月前更新了2.0的版本，并且下一个版本它将会被整合到Veeam的JeOS中，所谓的JeOS就是Veeam Just Enough OS，Veeam限定精简操作系统。这个系统已经进入Beta阶段。

本期话题，我们来看看最近更新的这个Veeam Hardened Repository的一些新变化，相比之前的1.0版本，这个版本的变化还是非常大的，加入了很多新的功能，甚至是改变了我们的一些使用和操作方法。

### 新增功能

#### Repair mode

- 仅重新安装操作系统，同时保留数据分区不变。
- 该修复功能无法用于从Ubuntu或者其他Linux发行版 的迁移操作。如果做了类似操作，系统将无法启动，需要手工修复`/etc/fstab`文件

#### Live boot

- 提供一个可用于故障排查的实时系统。这主要是为Veeam支持团队设计的功能，但是有经验的Linux用户也可以自行使用，该系统中包含了一些常规的性能和系统管理工具，比如fio或者iperf等。
- 该系统中vhradmin用户的主目录下，提供了3个脚本，分别用于挂载数据盘、挂载操作系统盘以及收集硬件信息。

#### 全自动安装

- 使用常规的kickstart脚本，用于大规模自动无人值守安装。可以参考redhat的kickstart文档。
- 要实现“零接触安装”，需要在Grub启动引导程序中的内核参数中添加`auto=1`，同时，在ks.cfg文件中，确保已设置键盘布局、时区、并禁用光驱作为安装源。

#### 其他功能

- 新增IPv6 DHCP功能支持。
- 允许Repository被Ping，限制为每秒5次，用于故障排查。
- 安装菜单进行了一些优化，包括pre-release文字警告已经去掉。

### 深入解析新功能之Repair Mode

这个修复模式，简单来说就是能够不影响数据的情况下重装Hardened Repository的系统。


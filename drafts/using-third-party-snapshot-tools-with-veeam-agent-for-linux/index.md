# 在Veeam Agent for Linux中使用第三方快照技术


关于Veeam Agent for Linux的话题，这几年来，我有写过好几篇。推送安装过程如果有困难，可以看这篇基础入门；而想了解更多VeeamSnap工作原理的，可以参考这篇进阶版。

今天我想来分享一个目前在这个Agent中还处于实验阶段的功能，这个功能能够使Veeam Agent for Linux借助第三方快照引擎来为备份创建快照，比如在Linux中最常见的LVM卷快照、BtrFS快照，从而避免一些VeeamSnap无法安装的尴尬问题。本文以LVM卷快照引擎为例，来介绍这个功能的使用方法。

## 一、适用场景

- 除了[官网Userguide手册](https://helpcenter.veeam.com/docs/agentforlinux/userguide/system_requirements.html?ver=50)中提到的这些受支持的Linux发行版之外，其他的各种安装在x86平台下的Linux系统。
- 对于受支持的Linux发行版，使用了过高版本的内核（kernel），该内核不受VeeamSnap支持。
- 不想或者不适合安装内核外驱动编译模块dkms，但是又需要使用快照进行整机备份

以上这些场景中，只要操作系统使用LVM2管理磁盘，就可以通过本文的方法实现整机备份。

## 二、前置条件

要让Veeam Agent for Linux借助第三方快照引擎来执行备份，首先需要我们在Linux上安装特殊的Agent安装包，对应rpm和deb不同的Linux系统，可以分别从以下地址下载安装包



由于这个技术目前还处于实验支持阶段，Veeam Support的响应及时度会略低于其他功能，具体关于实验支持的说明可以参考[这个链接](https://www.veeam.com/kb2976)。



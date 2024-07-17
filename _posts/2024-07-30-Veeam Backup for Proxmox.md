---
layout: post
title: Veeam Backup for Proxmox beta版本尝鲜
tags: Backup
---

最近听说Proxmox非常火爆，而在上个月的VeeamON全球发布会上，Veeam发布了今年下半年的一系列新产品，其中有个重要更新，就是支持了新的虚拟化平台Proxmox。

目前，Veeam Backup for Proxmox的Beta版已经发布，今天我们就来看看VB for Proxmox的功能。

## 适配兼容概况

VB for Proxmox是以VBR plugins方式发布的，它的工作原理和其他几个KVM类的虚拟化平台相似，需要在VBR安装后再额外安装上这个Plugins。

适配的VBR版本： v12.1.2.127以上

Proxmox PVE版本：8.2以上


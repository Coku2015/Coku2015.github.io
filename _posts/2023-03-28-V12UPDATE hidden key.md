---
layout: post
title: VBR v12中的那些隐藏键
tags: VBR

---

在VBR v10的时候，产品中加入了一些隐藏功能，最近v12发布后，隐藏按键和功能又多了一些。

### [Ctrl]+鼠标右键

#### Repair 修复VACM文件

我们知道，v12更新后几乎所有的数据都能够安全地储存在Veeam Hardened Repository(VHR)中，但是对于Oracle RMAN、SAP Hana和新推出的SQL Plugins，他们的 Backup job metadata (VACM)是无法实现WORM功能的。这时候会出现一种情况就是黑客恶意删除了VACM文件，造成VACM文件丢失。

在Enterprise Plugin备份存档中，按住Ctrl后点击鼠标右键，可以调出两个新菜单，其中一个是Repair按钮，这个按钮可以用于修复备份作业的metadata文件。

[![pp6CfN8.png](https://s1.ax1x.com/2023/03/28/pp6CfN8.png)](https://imgse.com/i/pp6CfN8)

#### Remove from configuration

在使用Veeam Hardened Repository(VHR)后，数据存放在这些存储库中非常安全，黑客如果攻破了VBR也无法通过Delete from disk按钮从备份服务器上删除备份存档。但是，在v11的VBR中，除了有个Delete from disk按钮之外，我们还有个Remove from configuration按钮，这个按钮并不删除VHR里的数据，而是用于删除VBR后台数据库中的记录。当我们按下这个按钮后，备份记录就从VBR控制台消失，虽然这对备份运维来说是一个非常重要的功能，但这在某种程度上也给黑客入侵提供了一些便利。

在v12中，Remove from configuration按钮被隐藏起来了，这样可以避免一些不必要的误操作，如果真需要使用这个功能，一样可以通过Ctrl+右键调出这个功能。

[![pp6CgBt.png](https://s1.ax1x.com/2023/03/28/pp6CgBt.png)](https://imgse.com/i/pp6CgBt)



#### Rebalance 重新平衡SOBR容量

SOBR使用时间久了，特别是不同容量混用存放大量虚拟机的时候，很容易碰到几个Extent之间容量不平衡，在v12中，新增了Rebalance按钮可以用来平均分配备份存档至各个Extent中。这个按钮也是通过Ctrl+右键调出来。

[![pp6CWAf.png](https://s1.ax1x.com/2023/03/28/pp6CWAf.png)](https://imgse.com/i/pp6CWAf)

### 新增隐藏的鼠标右键

由于全新的Per-vm backup chain的能力，在备份作业历史记录中，每一个机器都新增了全新的右键按钮。这个按钮包含两种功能，一个是Active full全备份，另外一个是Retry。在以前的版本中，这两个功能都仅针对整个备份作业有效，也就是说，当我有个作业中有4个虚拟机/物理机时，我如果需要进行一次全新的Active Full操作，那么这4个机器将会都被同时执行Active Full，无法为单台机器进行单独操作；而v12中，每一台机器都可以单独进行操作了。

[![pp6C2HP.png](https://s1.ax1x.com/2023/03/28/pp6C2HP.png)](https://imgse.com/i/pp6C2HP)

### 隐藏的时间戳

这个功能其实我是用来凑数的，并不是v12新增的。在备份作业历史记录中，右键点击Action附近，可以调出一列新的内容，这是每一个备份步骤的开始时间，这个功能对于排查错误非常有用，特别是在分析排查一些性能问题的时候特别有帮助。

[![pp6CcnI.png](https://s1.ax1x.com/2023/03/28/pp6CcnI.png)](https://imgse.com/i/pp6CcnI)

好了，以上就是本期隐藏按钮更新。欢迎下载v12探索新功能，有啥新发现也可以留言告诉我。


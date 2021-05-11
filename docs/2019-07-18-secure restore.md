---
layout: post
title: 恢复 | 让那些病毒木马无所遁形
tags: VMware
categories: 数据恢复
---



安全和备份是IT架构中两大重要的基础组件，通常情况下无论是个人家用和企业商用，都是必不可少的。然而很尴尬的是，作为安全类的杀毒软件，需要面对各种病毒和木马以及他们的变种，甚至是不断出现的新型病毒。有些病毒软件还具备了反杀毒功能，可以反向击杀杀毒软件，令人防不胜防。

传统IT中，为每一台操作系统安装杀毒软件的方法显然不足以做到全面的防护，甚至是很容易被病毒软件破坏。而结合虚拟化技术之后，杀毒引擎被整合入虚拟化层，利用虚拟化的技术可以避免很多传统杀毒软件植入式安装带来的问题。

然而这依旧无法解决一个重要问题，就是每款杀毒软件都有自己的强项，再优秀的杀毒软件都有需要更新病毒库的时候，总有那么一些病毒，是无法被某个软件杀死的。根据AV-Test的报告，市面上的杀毒软件种类几十种，查杀能力在不同版本时各不相同。

![3SXn00.jpg](https://s2.ax1x.com/2020/02/16/3SXn00.jpg)



前些天，在设计一个分布式的备份架构设计时，突然想到Veeam的Mount Server的特殊作用：可以在不同的Mount Server上安装不同的杀毒软件，形成多套不同杀毒引擎。使用Secure Restore时，只需要合理选择Mount Server即可实现使用不同的引擎进行病毒查杀。



## 操作方法



### 配置Mount Server

在VBR中，Mount Server是个很基本的组件，没有太多要求，只需要是一台Windows Server，并且是Veeam Managed Server，即可成为Mount Server。如果说一定得有个前提条件，我觉得应该是网络上，作为Mount Server，这个Windows就必须要能够和VBR通讯，也必须要和Repository通讯。具体通讯端口要求，可参看官网手册。

https://helpcenter.veeam.com/docs/backup/vsphere/used_ports.html?ver=95u4#mount

进入VBR console 后，只要找到Backup Infrastructure下面的Managed Servers节点，在其中将希望添加的Windows Server添加进去即可。

![3SXOEV.png](https://s2.ax1x.com/2020/02/16/3SXOEV.png)

添加方式是经典的Veeam向导模式：

1. 首先填入Mount Server的FQDN或者IP地址，描述中可以填入杀毒软件名称用以识别。
   ![3SXj4U.png](https://s2.ax1x.com/2020/02/16/3SXj4U.png)
2. 下一步后填入管理员用户名密码，用于推送安装Mount Server的组件。
   ![3SjSgJ.png](https://s2.ax1x.com/2020/02/16/3SjSgJ.png)
3. 预览需要安装的组件，并完成添加。

​    ![3SXxCF.png](https://s2.ax1x.com/2020/02/16/3SXxCF.png)



### 为Repository选择Mount Server

由于每个Repository都有其一一对应的Mount Server，因此当我们要用到某个特殊的杀毒软件时，我们只需要编辑Repository的设定，选择对应的Mount Server即可。

![3SXz34.png](https://s2.ax1x.com/2020/02/16/3SXz34.png)

剩下步骤，就是进入各种支持Secure Restore的恢复操作中，执行正常的恢复步骤。



以上就是今天的内容，不是很复杂，但是很有意思，希望能帮助到被病毒困扰的管理员们。
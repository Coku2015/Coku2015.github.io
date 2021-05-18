---
layout: post
title: Kasten K10入门系列03 - K10备份和恢复
tags: Kubernetes
categories: Kubernetes

---

## Kasten K10入门系列目录

[Kasten K10入门系列01 - 快速搭建K8S单节点测试环境](https://blog.backupnext.cloud/2020/12/Setting-up-quick-demo-for-K10-01/)

[Kasten K10入门系列02 - K10安装](https://blog.backupnext.cloud/2021/05/K10-setup/)

## 正文

之前我介绍了K10的安装，整个安装过程其实就是一行`helm install`命令，在安装完成后，后续的使用可以通过浏览器打开K10的仪表盘，进行K10备份系统的配置、K10备份策略管理和数据恢复。

和所有的备份系统一样，在开始备份工作之前，需要为K10配置一个数据存放的位置，用于存放备份数据。目前K10支持将数据存放至对象存储中，暂时还没加入VBR Repository。在K10的Settings中可以找到Locations设置，这就是K10的备份存储库，在这个Locations中，如图使用New Profiles按钮即可。

[![ghQEBq.png](https://z3.ax1x.com/2021/05/18/ghQEBq.png)](https://imgtu.com/i/ghQEBq)

新建时需要提供S3的访问地址、access key和secret key就可以完成Locations Profile的配置了。在配置完成后，后续的备份策略设置中就可以将备份数据Export指向到这个备份存储库中。

在K10中，不需要去添加备份对象，K10能够自动发现当前K10实例运行的Kubernetes Cluster中的所有Application，这一点上，和以往的备份软件有很大的不同。

初始化的配置除了设置Locations之外，还需要去启用K10 Disaster Recovery，只有启用了这一步操作后，K10才能在当前Kubernetes Cluster出现任何故障时，恢复我们之前备份的数据。这个Disaster Recovery将当前群集中K10的备份catalog库储存到了对象存储中，群集出现任何问题，都可以在新的群集中恢复备份存档的catalog，提取数据恢复。

[![ghQAun.png](https://z3.ax1x.com/2021/05/18/ghQAun.png)](https://imgtu.com/i/ghQAun)

配置K10 DR时，管理员需要将K10 DR启用后显示在屏幕上的Cluster ID记录下来，妥善保存好，用于后续的K10 catalog的恢复。



## 备份

K10的备份都是通过Policy来发起。在仪表盘正中间位置就是Policy相关的内容，包括显示当前的Policy总数和新建Policy。

[![ghQicj.png](https://z3.ax1x.com/2021/05/18/ghQicj.png)](https://imgtu.com/i/ghQicj)

要保护一个Application，需要管理员通过new policy来打开Policy的配置页面。如下图，在这个配置页面中需要填入一些相关信息才能完成备份策略的创建。

[![ghQVH0.jpg](https://z3.ax1x.com/2021/05/18/ghQVH0.jpg)](https://imgtu.com/i/ghQVH0)

创建完成后，可以在Policies中查看到这个Policy，并且可以通过run once来做一个单次备份作业的发起和运行，而正常情况，Policy就会根据计划任务的设置，自动在设定的时间运行。

[![ghQP3Q.png](https://z3.ax1x.com/2021/05/18/ghQP3Q.png)](https://imgtu.com/i/ghQP3Q)

## 恢复

数据完成备份后，可以在Applications中看到应用的状态变成了Compliant

[![ghQSN8.png](https://z3.ax1x.com/2021/05/18/ghQSN8.png)](https://imgtu.com/i/ghQSN8)

而在Restore Points中能看到不同的还原点。

[![ghQp4S.png](https://z3.ax1x.com/2021/05/18/ghQp4S.png)](https://imgtu.com/i/ghQp4S)

选择还原点后，可以还原整个应用，也可以删除还原点。

[![ghQC9g.png](https://z3.ax1x.com/2021/05/18/ghQC9g.png)](https://imgtu.com/i/ghQC9g)



以上就是本节内容K10的基本备份和恢复，完全图形化界面，使用非常简单。更多内容欢迎关注本系列后续更新。
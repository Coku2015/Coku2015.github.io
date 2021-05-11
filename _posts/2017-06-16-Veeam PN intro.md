---
layout: post
title: VeeamON 2017系列之另类VPN -- Veeam PN
tags: VeeamON
categories: Veeam小工具
---



# 前言

在上个月的VeeamON大会上，Veeam发布了一个全新的产品，这个产品其实和备份是完全没有关系，叫Veeam PN，全称是Veeam Powered Network。这是一款轻量级的SDN解决方案，能够迅速打通多个站点，实现站点-站点之间的通讯，也可以实现终端-站点的通讯。由于此解决方案功能过于强大，本文不想展开全面介绍，详细内容可以参考Veeam KB2271和VeeamPN帮助手册。

今天的内容，我想来介绍下我的使用场景，在我的Home Lab中使用Veeam PN。

先来说说需求，其实这个需求并不复杂，我相信绝大多数的VPN解决方案都能够实现，也就是当我不在家的时候，任意一个地方，我都能连回家里的实验室，进行工作。

实现这个功能，大多数方法可能是基于VPN的方式，也就是说得搭建VPN环境，那么各种环境中搭建方法可能各式各样，而Veeam PN为我这样的环境提供了一个非常简单的部署方法，只需几分钟，鼠标点击几下，就能完成这样的搭建。

# 架构组件

这整个架构中里面一共有3个组件：

1. Veeam Hub

相当于接入点，充当了集中控制所有端点的一个唯一入口。Veeam Hub可以部署在任意的位置，任意的一个有互联网接入的站点、云端都可以，唯一的要求就是能够和其他站点通过广域网互联互通，有公网地址。

2. Veeam Site Gateway

每个站点的出口连接Hub的网关。这里的每个站点的概念为1个子网，也就是说每个子网都需要一个site Gateway。对于Site Gateway的要求，是有internet接入而不必有公网地址。

3. VPN客户端

终端连接入私网的客户端，Veeam PN可以使用任何支持OpenVPN的客户端，具体客户端下载可以自行百度查找。



![1TMJfS.png](https://s2.ax1x.com/2020/02/11/1TMJfS.png)

如图，简单架构就是这样。对于我Home Lab，目前仅有一个网段，是10.100.1.0/24，所以在我的Lab中我需要的组件就是一个Hub和一个Site Gateway。这两个组件的部署非常简单，其实是同一个OVA的不同工作模式，具体下载地址可以点击**阅读原文**查看。



# 安装配置

在vSphere Client中，和常规部署OVA一样，导入这个虚拟设备进行部署，导入后，可以进入这个Ubuntu系统进行IP地址和主机名。

![1TQsHI.png](https://s2.ax1x.com/2020/02/11/1TQsHI.png)

因为我的这个Hub和Site Gateway都部署在家中，所以我需要重复上面的步骤导入两次，生成2个虚拟机，分别配置为Hub和Site Gateway：

![1TQ6Et.png](https://s2.ax1x.com/2020/02/11/1TQ6Et.png)

接下去，可以通过网页分别访问Hub和Site Gateway进行详细配置，整个配置过程非常简单，首先来看下Hub，我们进入Hub的网页：

Https://10.100.1.40/

![1TQwge.png](https://s2.ax1x.com/2020/02/11/1TQwge.png)

Username：root

Password:VeeamPN

进去后会提示修改密码并选择角色：

![1TQg4f.png](https://s2.ax1x.com/2020/02/11/1TQg4f.png)

先选择Hub，进行下一步：

![1TQrDA.png](https://s2.ax1x.com/2020/02/11/1TQrDA.png)

简单填入一些个性化信息后可以点击下一步，其中加密等级保持默认2048位就可以了。

![1TQRC8.png](https://s2.ax1x.com/2020/02/11/1TQRC8.png)

设置公网IP或者DNS，我在这里输入了我自己的对外internet DDNS域名，端口保持默认。点击Finish就能完成Hub的基础设置。

然后我们来添加一个Site和一个客户端接入点，点击Clients，Add按钮就能打开向导

![1TMQeI.png](https://s2.ax1x.com/2020/02/11/1TMQeI.png)

选择添加一个Site或者一个计算机，Entire Site就是加一个site Gateway，而standalone computer就是远程单独接入点：

![1TMuyd.png](https://s2.ax1x.com/2020/02/11/1TMuyd.png)

我们先加一个Site，选择Entire Site后next：

![1TM8Ff.png](https://s2.ax1x.com/2020/02/11/1TM8Ff.png)

任意输入一个名字标识，然后添加子网段地址，比如我家Lab是10.100.1.0/24

![1TMnQH.png](https://s2.ax1x.com/2020/02/11/1TMnQH.png)

点击Finish之后，就会自动下载一个.xml文件，这个文件将会在Site Gateway配置过程中用到。

然后我们来再重复前面Add Client步骤来添加一个接入点：

![1TMlwt.png](https://s2.ax1x.com/2020/02/11/1TMlwt.png)

接入点只需要一个名称来标识，没有更多信息需要配置，点击下一步和Finish之后，浏览器会自动下载一个.ovpn文件，这个文件可以在任何的OpenVPN客户端中载入并连接。

接下去可以打开Site Gateway的页面进行Site Gateway的连接Hub配置。

进入site Gateway页面之后依旧是修改密码和初始化向导，只是不同的是初始化向导中选择Site Gateway，而不是network Hub

![1TQg4f.png](https://s2.ax1x.com/2020/02/11/1TQg4f.png)

Next之后，选择刚刚从Hub上下载到的.xml文件导入点击Finish就完成了Site Gateway配置，这样这个Site就自动连接到Hub上了。

![1TQcUP.png](https://s2.ax1x.com/2020/02/11/1TQcUP.png)



最后，我们来配置OpenVPN Client。目前在所有操作系统平台上，包括手机上，都可以找到合适的Client，本文就以最常见的Windows为例，可以安装**openvpn-install-2.4.2-I601.exe**

过程也极其简单，一路next完了之后，双击快捷方式后import之前下载下来的.ovpn文件即可进行连接，整个连接过程也不需要输入用户名密码之类的，就和通常OpenVPN的连接是完全一样的。



至此，我就能在外面任何地方轻松的连上自己家里的实验室了。
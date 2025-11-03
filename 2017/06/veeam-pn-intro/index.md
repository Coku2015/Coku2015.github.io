# VeeamON 2017 系列之另类 VPN -- Veeam PN


# 前言

在上个月的 VeeamON 大会上，Veeam 发布了一个全新的产品，这个产品其实和备份是完全没有关系，叫 Veeam PN，全称是 Veeam Powered Network。这是一款轻量级的 SDN 解决方案，能够迅速打通多个站点，实现站点-站点之间的通讯，也可以实现终端-站点的通讯。由于此解决方案功能过于强大，本文不想展开全面介绍，详细内容可以参考 Veeam KB2271 和 VeeamPN 帮助手册。

今天的内容，我想来介绍下我的使用场景，在我的 Home Lab 中使用 Veeam PN。

先来说说需求，其实这个需求并不复杂，我相信绝大多数的 VPN 解决方案都能够实现，也就是当我不在家的时候，任意一个地方，我都能连回家里的实验室，进行工作。

实现这个功能，大多数方法可能是基于 VPN 的方式，也就是说得搭建 VPN 环境，那么各种环境中搭建方法可能各式各样，而 Veeam PN 为我这样的环境提供了一个非常简单的部署方法，只需几分钟，鼠标点击几下，就能完成这样的搭建。

# 架构组件

这整个架构中里面一共有 3 个组件：

1. Veeam Hub

相当于接入点，充当了集中控制所有端点的一个唯一入口。Veeam Hub 可以部署在任意的位置，任意的一个有互联网接入的站点、云端都可以，唯一的要求就是能够和其他站点通过广域网互联互通，有公网地址。

2. Veeam Site Gateway

每个站点的出口连接 Hub 的网关。这里的每个站点的概念为 1 个子网，也就是说每个子网都需要一个 site Gateway。对于 Site Gateway 的要求，是有 internet 接入而不必有公网地址。

3. VPN 客户端

终端连接入私网的客户端，Veeam PN 可以使用任何支持 OpenVPN 的客户端，具体客户端下载可以自行百度查找。

![1TMJfS.png](https://s2.ax1x.com/2020/02/11/1TMJfS.png)

如图，简单架构就是这样。对于我 Home Lab，目前仅有一个网段，是 10.100.1.0/24，所以在我的 Lab 中我需要的组件就是一个 Hub 和一个 Site Gateway。这两个组件的部署非常简单，其实是同一个 OVA 的不同工作模式，具体下载地址可以点击**阅读原文**查看。

# 安装配置

在 vSphere Client 中，和常规部署 OVA 一样，导入这个虚拟设备进行部署，导入后，可以进入这个 Ubuntu 系统进行 IP 地址和主机名。

![1TQsHI.png](https://s2.ax1x.com/2020/02/11/1TQsHI.png)

因为我的这个 Hub 和 Site Gateway 都部署在家中，所以我需要重复上面的步骤导入两次，生成 2 个虚拟机，分别配置为 Hub 和 Site Gateway：

![1TQ6Et.png](https://s2.ax1x.com/2020/02/11/1TQ6Et.png)

接下去，可以通过网页分别访问 Hub 和 Site Gateway 进行详细配置，整个配置过程非常简单，首先来看下 Hub，我们进入 Hub 的网页：

Https://10.100.1.40/

![1TQwge.png](https://s2.ax1x.com/2020/02/11/1TQwge.png)

Username：root

Password:VeeamPN

进去后会提示修改密码并选择角色：

![1TQg4f.png](https://s2.ax1x.com/2020/02/11/1TQg4f.png)

先选择 Hub，进行下一步：

![1TQrDA.png](https://s2.ax1x.com/2020/02/11/1TQrDA.png)

简单填入一些个性化信息后可以点击下一步，其中加密等级保持默认 2048 位就可以了。

![1TQRC8.png](https://s2.ax1x.com/2020/02/11/1TQRC8.png)

设置公网 IP 或者 DNS，我在这里输入了我自己的对外 internet DDNS 域名，端口保持默认。点击 Finish 就能完成 Hub 的基础设置。

然后我们来添加一个 Site 和一个客户端接入点，点击 Clients，Add 按钮就能打开向导

![1TMQeI.png](https://s2.ax1x.com/2020/02/11/1TMQeI.png)

选择添加一个 Site 或者一个计算机，Entire Site 就是加一个 site Gateway，而 standalone computer 就是远程单独接入点：

![1TMuyd.png](https://s2.ax1x.com/2020/02/11/1TMuyd.png)

我们先加一个 Site，选择 Entire Site 后 next：

![1TM8Ff.png](https://s2.ax1x.com/2020/02/11/1TM8Ff.png)

任意输入一个名字标识，然后添加子网段地址，比如我家 Lab 是 10.100.1.0/24

![1TMnQH.png](https://s2.ax1x.com/2020/02/11/1TMnQH.png)

点击 Finish 之后，就会自动下载一个。xml 文件，这个文件将会在 Site Gateway 配置过程中用到。

然后我们来再重复前面 Add Client 步骤来添加一个接入点：

![1TMlwt.png](https://s2.ax1x.com/2020/02/11/1TMlwt.png)

接入点只需要一个名称来标识，没有更多信息需要配置，点击下一步和 Finish 之后，浏览器会自动下载一个。ovpn 文件，这个文件可以在任何的 OpenVPN 客户端中载入并连接。

接下去可以打开 Site Gateway 的页面进行 Site Gateway 的连接 Hub 配置。

进入 site Gateway 页面之后依旧是修改密码和初始化向导，只是不同的是初始化向导中选择 Site Gateway，而不是 network Hub

![1TQg4f.png](https://s2.ax1x.com/2020/02/11/1TQg4f.png)

Next 之后，选择刚刚从 Hub 上下载到的。xml 文件导入点击 Finish 就完成了 Site Gateway 配置，这样这个 Site 就自动连接到 Hub 上了。

![1TQcUP.png](https://s2.ax1x.com/2020/02/11/1TQcUP.png)

最后，我们来配置 OpenVPN Client。目前在所有操作系统平台上，包括手机上，都可以找到合适的 Client，本文就以最常见的 Windows 为例，可以安装** openvpn-install-2.4.2-I601.exe**

过程也极其简单，一路 next 完了之后，双击快捷方式后 import 之前下载下来的。ovpn 文件即可进行连接，整个连接过程也不需要输入用户名密码之类的，就和通常 OpenVPN 的连接是完全一样的。

至此，我就能在外面任何地方轻松的连上自己家里的实验室了。


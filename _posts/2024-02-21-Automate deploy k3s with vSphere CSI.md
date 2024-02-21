---
layout: post
title: 一键部署脚本：K3S+vSphere CSI
tags: VMware, Kubernetes, Instant Recovery
---

之前分享过两篇关于使用K10即时恢复Kubernetes上应用的方法，这个功能对于Kubernetes环境还是有一些要求的。当时给大家详细分享了手工部署的过程，今天我为大家带来一个一键部署的脚本，只要有VMware基础环境，能够正常连接Github/k8s.io网络，那么这个脚本会非常方便，启动脚本后只需要等待10分钟左右，你就可以直接使用这个单节点的k3s环境了。

脚本仓库地址：

https://github.com/Coku2015/k3s_vsphere

## 前提条件

在使用这个脚本之前，需要提前准备一下能够用于自动化部署的镜像和虚拟机自定义规范，脚本会自动调用这个镜像和规范来部署k3s环境。

### 虚拟机镜像

我推荐使用Ubuntu 20.04LTS作为运行k3s的环境，虚拟机模版镜像的制作也推荐基于这个版本。

模版虚拟机，我一般硬件配置比较低1vCPU，2GB内存和50GB硬盘就足够了。

虚拟机模版的安装可以有多种方法，最简单直接的是用iso进行一个最小化的安装，在安装结束后，为了能够进行后续的全自动远程配置，需要在这个模版中做一些调整，首先是启用密钥对认证远程登录：

```bash
# 在你的Linux机器上创建远程连接的密钥对
$ ssh-keygen
# 创建完成后，你会得到id_rsa和id_rsa.pub两个文件，分别是私钥和公钥。
# 用下面这个命令远程复制到模版机器上，假设ubuntu的用户名为ubuntu
$ ssh-copy-id ubuntu@ubuntu_template_vm
# 试试拷贝完成后的效果, 正常还是会提示输入密码。
$ ssh ubuntu@ubuntu_template_vm
```

接下去，ssh远程进入这台Ubuntu后`sudo -i`到root直接运行以下命令，进行进一步调整：

```bash
# 修改ssh密钥对登录免密码
$ sed -i 's/#\?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# 重启ssh服务
$ systemctl restart sshd
# 加入sudo免密码(如果username不是ubuntu，请修改下面的命令)
$ echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/ubuntu
$ curtin in-target --target=/target -- chmod 440 /etc/sudoers.d/ubuntu
# 修复 VMware 自定义配置问题，详情可以参考VMware KB56409
$ sed -i '/^\[Unit\]/a After=dbus.service' /lib/systemd/system/open-vm-tools.service
$ awk 'NR==11 {$0="#D /tmp 1777 root root -"} 1' /usr/lib/tmpfiles.d/tmp.conf | tee /usr/lib/tmpfiles.d/tmp.conf
# 禁用 Cloud Init
$ touch /etc/cloud/cloud-init.disabled
# 更新系统
$ apt clean
$ apt update -y
$ apt upgrade -y
# 删除machine-id，避免模版部署后同ID冲突
$ rm /etc/machine-id
$ touch /etc/machine-id
```

好了，这样配置完成后，退出ssh，然后再试下ssh至这台模版机器，看看是否还需要密码验证，并且`sudo -i`试试提权是否需要密码，如果都不要，那么恭喜你，模版制作完成了。接下去只需要将这台虚拟机关机，转换成模版即可。

### 虚拟机自定义规范

除了制作模版之外，我们还需要配置一个虚拟机自定义规范。

1. 在vSphere Client的快捷方式中，找到虚拟机自定义规范按钮，点击进入。

[![pFttbcV.png](https://s11.ax1x.com/2024/02/21/pFttbcV.png)](https://imgse.com/i/pFttbcV)

2. 点击新建按钮后，弹出一个新建向导。

3. 设置一个名称，选择Linux操作系统。这个名称会在后续的脚本中使用到

[![pFttXBF.png](https://s11.ax1x.com/2024/02/21/pFttXBF.png)](https://imgse.com/i/pFttXBF)

4. 设置计算机名称，我们选择使用虚拟机名称，表示和虚拟机同名，然后在下方域名中随便填入个合适的域名，这步不能省略，必须填上任意文字。

[![pFttOnU.png](https://s11.ax1x.com/2024/02/21/pFttOnU.png)](https://imgse.com/i/pFttOnU)

5. 选择时区，我选择我所在的亚洲 - 上海。

[![pFttqXT.png](https://s11.ax1x.com/2024/02/21/pFttqXT.png)](https://imgse.com/i/pFttqXT)

6. 自定义脚本这里不用配置，直接点下一步。

[![pFttH10.png](https://s11.ax1x.com/2024/02/21/pFttH10.png)](https://imgse.com/i/pFttH10)

7. 设置网络，需要选择`手动选择自定义设置`，然后选择下方的网卡1，再点击编辑，进行下一步调整。

[![pFtNShR.png](https://s11.ax1x.com/2024/02/21/pFtNShR.png)](https://imgse.com/i/pFtNShR)

8. 打开网络设置界面，在IPV4里，左边选择`当使用规范时，提示用户输入IPv4地址`，右边填入你环境中的子网掩码和网关。IPv6默认不做配置，点击确定保存配置。

[![pFttxAJ.png](https://s11.ax1x.com/2024/02/21/pFttxAJ.png)](https://imgse.com/i/pFttxAJ)

9. 设置DNS，配上环境中的能上互联网的默认DNS服务器地址。

[![pFttj74.png](https://s11.ax1x.com/2024/02/21/pFttj74.png)](https://imgse.com/i/pFttj74)

10. 点击完成保存设置。

[![pFttzN9.png](https://s11.ax1x.com/2024/02/21/pFttzN9.png)](https://imgse.com/i/pFttzN9)

这样自定义规范机配置好了，可以在后续的脚本中直接调用第一步设置的名称使用了。

## 脚本使用说明

### 脚本使用环境拓扑介绍：

[![pFtIS5d.png](https://s11.ax1x.com/2024/02/21/pFtIS5d.png)](https://imgse.com/i/pFtIS5d)

在Linux控制机上，使用git clone下载脚本仓库。

```bash
$ git clone https://github.com/Coku2015/k3s_vsphere.git
```

下载后进入脚本目录：

```bash
$ cd k3s_vsphere
```

用vi编辑器打开脚本，找到脚本开头部分，修改其中的环境变量参数。

```bash
#######################  Environment Variables Section  ######################
###  Modify the following environment variables to match your environment  ###
MY_SSH_USER="ubuntu"
MY_VSPHERE_SERVER="172.16.0.100"
MY_VSPHERE_USERNAME="administrator@vsphere.local"
MY_VSPHERE_PASSWORD="VMware123!"
MY_DATACENTER="MyDatacenter"
MY_VM_TEMPLATE="Ubuntu20.04LTS"
MY_DATASTORE="localdatastore"
#######################  Environment Section End   ###########################
```

其中第一个MY_SSH_USER是Ubuntu模版的用户名，其他信息都是比较常规的vSphere访问信息，根据实际情况填写即可。

填写完成后，保存退出，然后就能执行脚本啦，对了，还需要注意，脚本运行需要root权限安装相关软件。

执行命令运行脚本：

```bash
$ bash deploy_k3s_with_vspherecsi.sh
```

这时候会提示输入一些本次自动部署的配置，一共三个，第一个为部署的虚拟机名称，只需要输入一个前缀，脚本会自动为虚拟机名称加上4个随机数字作为唯一标识；第二个为虚拟机的IP地址，根据自己环境的空闲IP地址情况按实际情况输入即可；第三个为k3s的版本，可以到k3s官网查询相关需要的版本，理论上任何stable版本都能支持:

```bash
+----------------------------------------------------------------------+
|              K3S with vSphere CSI automation script                  |
+----------------------------------------------------------------------+
|  This script is used to create a single node k3s cluster on vSphere. |
+----------------------------------------------------------------------+
|  Intro: https://blog.backupnext.cloud                                |
|  Bug Report: Lei.wei@veeam.com                                       |
+----------------------------------------------------------------------+

Please enter the VM name:
(Default VM name will be ‘k3s-cluster-<4 random number>’):
Please enter the IP address for the VM:
(Default IP address will be ‘192.168.1.<random number>’):10.10.1.103
Please enter the k3s version:
(Default version will be ‘v1.28.6+k3s2’):v1.27.10+k3s2
```

输入完成后，脚本就开始自动部署了，大约10分钟左右，你就能像我一样获得一个直接可以使用的k3s测试环境了。
[![pFtI9PA.png](https://s11.ax1x.com/2024/02/21/pFtI9PA.png)](https://imgse.com/i/pFtI9PA)


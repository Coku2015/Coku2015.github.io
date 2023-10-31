---
layout: post
title: Kasten K10 入门系列 01 - 快速搭建 K8S 单节点测试环境
tags: Kubernetes
categories: Kubernetes

---

#### Release Notes: v1.2

*2021/06/04 - 加入本地 Registry，内置 K10 v4.0.3 镜像，可以在安装 k10 时使用*`--set global.airgapped.repository=localhost:5000` *来直接调用本地的 docker 镜像库*

*Virtual Appliance 版本更新为 v1.2，对应网盘中文件为：
UbuntuK10-v1.2.ova*

#### Release Notes: v1.1

*2021/05/03 日 - 尝试了 Stateful MySQL 的部署，将一体机中内置的 Demo 应用改成了 Helm 安装的 MySQL，这样，可以通过这个 vApp 来快速 Demo 和测试有状态应用的备份和恢复。*

*Virtual Appliance 版本更新为 v1.1，对应网盘中文件为：
UbuntuK10-v1.1.ova*

自从 Veeam 收购 Kasten 之后，最近玩 K8S 特别多，最大的体会是，茫茫多的各种命令和对互联网的强烈需求，假如连不了网，特别是连不了国外的容器镜像站点时，通常的情况就是抓瞎，啥都干不了。当然，这在各位 K8S 和容器大拿眼里，并不是什么问题，而对于广大非软件开发专业的系统管理员和系统工程师来说，挑战着实不小。

要搭建一套 Kasten K10 的 Lab 环境，其基础条件是 K8S 群集，Kasten K10 是原生的云应用，它赖以运行的环境和备份恢复的对象都是 K8S。因此，摆在我们面前的难题变成了简单快速不费劲的搭建一套 K8S 环境并且部署一个简单的有状态应用。这在没有网络的情况下，实在是太为难了。不过，办法总比困难多，不是吗？这点小小的阻碍完全难不倒熟练使用虚拟化技术的虚拟化管理员，在做了一番功课之后，我借鉴了 Veeam 日本的同事分享的快速部署脚本，使用了虚拟化中独特的 OVF（Open Virtualization Format）方式，将这个过程封装成了一个虚拟一体机（Virtual Appliance），让这个 Demo Lab 的搭建过程大大简化，实现了不需要任何网络下载，即可搭建出这样一套单节点群集，并且内置了包含 MySQL 数据库的 WordPress 应用。

先放上这个虚拟一体机的下载链接：

https://cloud.189.cn/t/mAnyMrA36vam（访问码：wd69）

需要说明的一点是，这个虚拟一体机为个人测试研究所用，不得用于任何商业目的，本人不保证这个设备的安全性、可靠性和稳定性，请各位使用者自行判断。

## 虚拟一体机使用说明：

熟练使用 VMware 虚拟化的管理员，可以将该 OVA 文件导入到 VMware vSphere 或者 VMware Workstation，导入过程中，导入向导会提示配置网络和 IP 地址信息如下图，特别注意其中 Netmask 需要用 CIDR 格式：

[![DziVDU.png](https://s3.ax1x.com/2020/12/07/DziVDU.png)](https://imgchr.com/i/DziVDU)

在导入完成后，虚拟一体机的首次启动中，会自动配置设备的 IP 地址。等到配置完成后，可以使用 ssh 连接登入系统进行 K8S 环境的基础配置。访问的初始用户名密码为：

```PlainTXT
username: k10
Password: P@ssw0rd
```

进入系统后，使用`sudo -i`命令进入 root 用户。

K8S 群集初始化需要按顺序执行/root/目录下的 5 个脚本文件，分别是：

```PlainTXT
0-minio.sh
1-createk8s.sh
2-loadimage.sh
3-storage.sh
4-wordpress.sh
```

脚本执行过程中所涉及到的需要用到的相关文件，我已经全部放置在/root/目录下了，脚本会自动调用这些文件。

## 这些脚本都用来干啥？

#### 0-minio.sh

这个脚本会使用开源对象存储领域第一块招牌 minio(https://minio.io) ，创建出一套本地的对象存储，命令执行后，对象存储就运行起来了，可以通过 https://<虚拟一体机 IP>:9000 来访问对象存储的 web 界面，web 界面的初始用户名密码：

```PlainTXT
username: minioadmin
Password: minioadmin
```

#### 1-createk8s.sh

这个脚本是使用 Kind 技术（K8S in Docker），在容器中运行 K8S 的节点来快速部署 K8S 的群集，K8S 所用到的容器镜像已经提前被内置在这个一体机中，因此不需要去网上下载 1.3G 左右的 K8S docker 镜像。可以在运行脚本之前通过以下命令来确认 K8S docker image 已经就位：

```bash
$ docker images list | grep kind
```

在脚本运行完成后，就可以正常使用 kubectl 的命令来查看所有 K8S 的资源了，这时候 kubectl 的所有命令都能正常使用了。比如，你可以试试这个：

```bash
$ kubectl get nodes
```

#### 2-loadimage.sh

这个脚本其实没什么特别秘密，纯粹是为后面第四第五个脚本做准备，它会将本地的 docker 镜像 push 到`localhost:5000`这个本地镜像库中，同时将内置在本地 Ubuntu 中的部分 docker images 加载到 Kind 中，供 Kind 使用。

#### 3-storage.sh

这个脚本为 K8S 群集创建本地的 CSI Hostpath driver，其用到的脚本可以在（https://github.com/kubernetes-csi/csi-driver-host-path）中找到，我对这个脚本要用到的互联网下载链接做了修改，更改为所有 yaml 文件都用本地/root/文件夹中的文件，并且对于这个脚本中用到的所有 docker image，也提前从互联网上 pull 下来并在上一步加载至 Kind 中。

在运行脚本前，可以通过以下命令查询部署前的 storage class：

```bash
$ kubectl get sc
```

在脚本运行完成后，可以通过再次运行这个命令，查看到新配置好的 storage class。

另外，这一步中会部署多个 pod 到 default 的 namespace，查看这一步部署状况的另外一个有用命令为：

```bash
$ kubectl get pod
```

#### 4-wordpress.sh

该脚本作用也很简单，部署一个 WordPress 应用，内置 Stateful 的 MySQL 数据库，部署完成后，需要运行以下命令进行端口转发后，使用浏览器访问以下地址进行后续配置 http://<虚拟一体机 IP>。

```bash
$ kubectl port-forward --address 0.0.0.0 svc/wordpress 80:80 -n wordpress
```

以上就是这个虚拟 k8s 一体机的简要使用说明，在部署完这套环境后，即可使用（https://docs.kasten.io）上的文档进行 Kasten 的正常安装配置使用了。

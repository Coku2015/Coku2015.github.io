---
layout: post
title: Kasten K10入门系列04 - K10安装包下载
tags: Kubernetes
categories: Kubernetes

---

## Kasten K10入门系列目录

[Kasten K10入门系列01 - 快速搭建K8S单节点测试环境](https://blog.backupnext.cloud/2020/12/Setting-up-quick-demo-for-K10-01/)

[Kasten K10入门系列02 - K10安装](https://blog.backupnext.cloud/2021/05/K10-setup/)

[Kasten K10入门系列03 - K10备份和恢复](https://blog.backupnext.cloud/2021/05/K10-configuration/)

## 正文

K10的下载很纠结，我相信习惯了Veeam软件的下载使用方式的朋友，一定会从各种程度上对于K10的下载和使用感觉到很不舒服。没错，这就对了，哪怕是像我这样下载k10软件超过100次以上的，也依旧觉得这种开源世界中的软件下载方式绝对是属于反人类的下载方式。

在Kasten K10的官网手册中，给出了软件的部署方式，然而这个软件竟然没有下载链接，原因可能是软件作者认为互联网畅通无阻，网络下载速度远大于本地磁盘速度，任何大小的软件都是下载无需等待的。然而，不巧的是，软件正好存放在gcr.io这样的普通人类无法访问的“火星”，这对普通人的使用造成了极大的阻碍。

好在Kasten K10还是考虑到了这一点，给出了一些看似还行的解决办法，比如使用[Jfrog artifactory](https://kb.kasten.io/knowledge/jfrog)作为替换的镜像下载站。这对于在线安装来说，没有任何问题，有了这个镜像站，国内普通用户不用掌握特殊技巧就能完成在线安装了。

然而，当我们需要通过Air-gap方式，将镜像下载到自己私有的镜像库时，这时候就会发现Jfrog artifactory无法和Kasten K10官网手册中所提供的offline脚本一起配合使用了。不过没关系，我制作了个小脚本，可以实现利用非gcr.io来下载kasten镜像。

首先放上官网的Air-gap下载说明：[官方下载方法说明](https://docs.kasten.io/latest/install/offline.html#preparing-k10-container-images-for-air-gapped-use)

## 脚本使用前提条件

简单来说，这个脚本需要在Linux环境中运行，这个Linux机器需要有以下条件：

- 能够正常访问`源镜像库<source>`，脚本中内置了Jfrog的镜像库地址，如需修改请编辑脚本文件;
- 能够正常访问`目标镜像库<target>`;
- 安装了jq软件，可以使用jq命令，可以通过以下链接了解[jq](https://stedolan.github.io/jq/)；
- 安装了docker，可以通过以下链接了解[docker](https://docs.docker.com/get-started/)；

## 脚本使用方法

脚本下载：

```bash
$ curl -O https://blog.backupnext.cloud/k10offline.sh
```

需要提醒的是，脚本下载后，请务必查看内容，确保正确再使用。

修改脚本执行权限：

```bash
$ chmod +x k10offline.sh
```

脚本命令和参数：

```bash
$ ./k10offline.sh <k10-ver> <target repo>
```

其中k10-ver是k10的版本，比如最新版本为`4.0.3`。

target repo是目标私有镜像库，比如`private.target.repo/kasten`

举个例子，按照上面的配置，这条命令变成了：

```bash
$ ./k10offline.sh 4.0.3 private.target.repo/kasten
```

运行这个命令，接下去k10的镜像就会自动上传至private.target.repo/kasten中，而在安装k10时，就可以使用这个私有镜像库了：

```bash
$ helm install k10 k10-4.0.3.tgz --namespace kasten-io \
    --set global.airgapped.repository=private.target.repo/kasten
```


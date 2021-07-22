---
layout: post
title: Kasten K10入门系列05 - K10安装包下载（2）
tags: Kubernetes
categories: Kubernetes
---

## Kasten K10入门系列目录

[Kasten K10入门系列01 - 快速搭建K8S单节点测试环境](https://blog.backupnext.cloud/2020/12/Setting-up-quick-demo-for-K10-01/)

[Kasten K10入门系列02 - K10安装](https://blog.backupnext.cloud/2021/05/K10-setup/)

[Kasten K10入门系列03 - K10备份和恢复](https://blog.backupnext.cloud/2021/05/K10-configuration/)

[Kasten K10入门系列04 - K10安装包下载](https://blog.backupnext.cloud/2021/06/K10offline-script/)

## 正文

在上一篇中，我们介绍了通过脚本实现从网络上下载并推送k10安装镜像至私有镜像库，今天我想来分享一些离线的镜像包，在完全无法访问外网的环境中，这也许是一种最方便的方式。

首先放上下载链接：

https://cloud.189.cn/web/share?code=zIVZ3uaIzUr2（访问码：8fbw）

## 内容说明

在这个下载链接中，K10安装包按版本都放置在每个版本号命名的文件夹中。在版本号文件夹里面，会包含两个文件：

- kasten_k10_offline_images_<版本号>.tar.gz : 镜像包
- k10_<版本号>.json : 推送至私有镜像库的配置文件

在这个镜像包中，包含了所有k10的安装镜像(4.0.8版本，其他版本可能会略有不同)：

| 原始Repository       | 镜像名   |
| -------------------- | -------- | 
| ghcr.io/kanisterio | kanister-tools | 
| quay.io/datawire | ambassador | 
| quay.io/prometheus | prometheus | 
| jimmidyson | configmap-reload | 
| quay.io/dexidp | dex | 
| gcr.io/kasten-images | frontend | 
| gcr.io/kasten-images | kanister | 
| gcr.io/kasten-images | aggregatedapis | 
| gcr.io/kasten-images | config | 
| gcr.io/kasten-images | auth | 
| gcr.io/kasten-images | bloblifecyclemanager | 
| gcr.io/kasten-images | catalog | 
| gcr.io/kasten-images | crypto | 
| gcr.io/kasten-images | dashboardbff | 
| gcr.io/kasten-images | executor | 
| gcr.io/kasten-images | jobs | 
| gcr.io/kasten-images | logging | 
| gcr.io/kasten-images | metering | 
| gcr.io/kasten-images | state | 
| gcr.io/kasten-images | upgrade | 
| gcr.io/kasten-images | cephtool | 
| gcr.io/kasten-images | datamover | 
| gcr.io/kasten-images | k10tools | 
| gcr.io/kasten-images | restorectl | 
| gcr.io/kasten-images | k10offline | 

## 前提条件

和上一篇中的脚本使用差不多，需要准备一台Linux服务器，在这台服务器上：

- 能够正常访问`目标镜像库<target>`;
- 安装了jq软件，可以使用jq命令，可以通过以下链接了解[jq](https://stedolan.github.io/jq/)；
- 安装了docker，可以通过以下链接了解[docker](https://docs.docker.com/get-started/)；

## 使用方法

将上面对应版本下载到的文件，离线传送至Linux服务器上，使用以下命令加载镜像包至本地docker缓存：

``` shell
docker load < kasten_k10_offline_images_4.0.8.tar.gz
```

加载后，可以通过以下命令，查看确认镜像状况：

```shell
docker images
```

下载推送脚本：

```shell
curl -O https://blog.backupnext.cloud/kasten_private_repo.sh
```

需要提醒的是，脚本下载后，请务必查看内容，确保正确再使用。

修改脚本执行权限：

```bash
chmod +x kasten_private_repo.sh
```

脚本命令和参数：

```bash
./kasten_private_repo.sh <k10-ver> <target repo>
```

其中k10-ver是k10的版本，比如最新版本为`4.0.8`。

target repo是目标私有镜像库，比如`private.target.repo/kasten`

举个例子，按照上面的配置，这条命令变成了：

```bash
./kasten_private_repo.sh 4.0.8 private.target.repo/kasten
```

运行这个命令，接下去k10的镜像就会自动上传至private.target.repo/kasten中，而在安装k10时，就可以使用这个私有镜像库了：

```shell
helm install k10 k10-4.0.8.tgz --namespace kasten-io \
    --set global.airgapped.repository=private.target.repo/kasten
    --set metering.mode=airgap
```

以上就是今天的第二种离线安装方法。

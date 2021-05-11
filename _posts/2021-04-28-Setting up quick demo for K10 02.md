---
layout: post
title: Kasten K10入门系列 - 快速搭建K8S单节点测试环境（下篇）
tags: Kubernetes
categories: Kubernetes
---

在[上一篇](https://blog.backupnext.cloud/_posts/2020-12-07-Setting-up-quick-demo-for-K10-01/)中，我为大家提供了一个简易的ova镜像，这个镜像用于在vSphere上快速搭建单节点K8S演示环境。也许有些朋友并不喜欢这种ova的方式，而更喜欢自己安装整个环境，那么我今天的这篇就来详细介绍下这个环境的安装方法。

这个基础环境的安装说明以Ubuntu 20.04LTS为例，如果有需要其他版本的朋友，请自行根据这些命令修改，在开始之前，需要首先有一个能够正常访问互联网（部分国际网站需要特殊访问渠道）的Ubuntu 20.04服务器能够使用，并且使用了root用户登录到这台服务器。

### 步骤一：安装并启用Docker服务

```bash
root@UK10:~# curl -fsSL https://get.docker.com -o get-docker.sh && \
>		sh get-docker.sh
```

安装完毕后，可以查看下docker版本信息

```bash
root@UK10:~# docker version
```

### 步骤二： 下载kind。

```bash
root@UK10:~# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
root@UK10:~# chmod +x ./kind && mv ./kind /usr/local/bin/kind
```

### 步骤三：安装kubectl

```bash
root@UK10:~# apt-get update && apt-get install -y apt-transport-https gnupg2
root@UK10:~# curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
root@UK10:~# cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
>	deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
>	EOF
root@UK10:~# apt-get update && apt-get install -y kubectl
root@UK10:~# kubectl completion bash >/etc/bash_completion.d/kubectl
root@UK10:~# source /etc/bash_completion.d/kubectl
root@UK10:~# echo 'export KUBE_EDITOR=vi' >>~/.bashrc
```

### 步骤四：安装Helm 3

```bash
root@UK10:~# curl -O https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
root@UK10:~# bash ./get-helm-3
```

### 步骤五：下载Hostpath CSI驱动

```bash
root@UK10:~# git clone https://github.com/kubernetes-csi/csi-driver-host-path.git
```

### 步骤六：创建3个配置脚本，按顺序执行这3个脚本，全自动配置KinD环境

​		脚本一：部署对象存储

```bash
# !/bin/bash
mkdir -p /minio/data
chown minio-user:minio-user /minio
mkdir -p ~/.minio
cd /minio
curl -Lo ./minio https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x ./minio 
mv ./minio  /usr/local/bin/minio
apt install -y golang-go
curl -o  generate_cert.go "https://golang.org/src/crypto/tls/generate_cert.go?m=text"
IPADDR=`hostname -I | cut -d" " -f1`
go run generate_cert.go -ca --host $IPADDR
unset IPADDR
mkdir -p ~/.minio
mv cert.pem ~/.minio/public.crt
mv key.pem ~/.minio/private.key
cd

echo ""
echo "*************************************************************************************"
echo "Next Step"
echo "MINIO_ACCESS_KEY=minioadmin MINIO_SECRET_KEY=minioadmin /usr/local/bin/minio server /minio/data"
```

​		脚本二： 用Kind在容器中开k8s群集

```bash
# !/bin/bash
kind create cluster --name k10-demo --image kindest/node:v1.18.2 --wait 600s
kubectl cluster-info --context kind-k10-demo

echo "******************************************************************************"
echo "Next Step: Run Script 2, load local docker images in to your kind cluster."
```

​		脚本三：

```bash
# !/bin/bash
SNAPSHOTTER_VERSION=v2.1.1

# Apply VolumeSnapshot CRDs
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml

# Create Snapshot Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${SNAPSHOTTER_VERSION}/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml

##Install the CSI Hostpath Driver
git clone https://github.com/kubernetes-csi/csi-driver-host-path.git
cd csi-driver-host-path
./deploy/kubernetes-1.18/deploy.sh
kubectl apply -f ./examples/csi-storageclass.yaml
kubectl patch storageclass standard \
    -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass csi-hostpath-sc \
    -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
cd

echo ""
echo "*************************************************************************************"
echo "There is no more action."
```


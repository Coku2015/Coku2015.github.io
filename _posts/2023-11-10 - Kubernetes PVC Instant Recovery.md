---
layout: post
title: 极速恢复：Kubernetes容器即时恢复技术详解
tags: VMware, Kubernetes, Instant Recovery
---

还记不记得去年我曾经介绍过 VMware 的 FCD 磁盘，并且通过 VBR 的 Instant Disk Recovery 试玩过 K8S 上的即时数据恢复？今年这个功能终于在最新的 K10 中联合 VBR 正式推出了。今天就跟我一起通过一个 Demo 来看看它是如何工作的吧。

## vSphere CSI

使用 Instant Recovery 功能离不开 vSphere，第一个前提要求是 Kubernetes 的 Storage Class 必须使用 vSphere Cloud Native Storage(CNS)。

关于 vSphere CSI 的详细配置，可以参考 [VMware 官网链接]

今天的例子中，我的 Kubernetes 使用了轻量级的 K3S 1.25s1 版本，默认部署的 K3S 会禁用大多数 Cloud Provider，因此这需要额外安装 VMware Cloud Manager

调整 k3s 的安装参数适配 vSphere，然后启动 K3S 集群

准备配置文件

csi-vsphere.conf

ccmfile_yaml

vsphere-csi-driver-ccr-ccs.yaml

storageclass.yaml

整个安装过程相对来说比较简单。

```bash
#安装 ccm
kubectl apply -f ccmfile_yaml
#创建 csi 管理 namespace
kubectl create namespace vmware-system-csi
#禁止调度
kubectl taint nodes $nodeid node-role.kubernetes.io/control-plane=:NoSchedule
#确认上一条命令执行情况
kubectl describe nodes | egrep "Taints:|Name:"
#创建连 vc 用的用户名密码的 secret
kubectl create secret generic vsphere-config-secret --from-file=/home/lei/csi-vsphere.conf --namespace=vmware-system-csi
#创建并启动 csi 驱动
kubectl apply -f vsphere-csi-driver-ccr-ccs.yaml
#确定 pod 全部启动后，重新启用容器调度
kubectl taint nodes $nodeid node-role.kubernetes.io/control-plane=:NoSchedule-
#创建存储类
kubectl apply -f storageclass.yaml
```

安装完成后，部署个应用使用这个 Storage Class 试试。

```bash
dddd
```

## K10 安装和配置

K10 安装没什么特别，还是依旧使用

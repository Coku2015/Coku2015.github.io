# 极速恢复：Kubernetes 容器即时恢复技术详解（下）- 备份与恢复


上一期我们把基础 Kubernetes 环境搭建好了，这期我们来详细说说备份和恢复。

## K10 安装和配置

首先是 K10 安装，没啥特别之处，用官网标准的安装手册去进行 Helm 安装即可，唯一需要注意的是，支持即时恢复的 K10 需要 6.0.8 以上的版本，而VBR需要用到v12版本以上。我这里放一下我用的K10安装参数，供大家参考：

```bash
# 更新 Helm 仓库
helm repo update && helm fetch kasten/k10
# 创建 Namespace
kubectl create ns kasten-io
# 安装 K10
helm install k10 kasten/k10 --namespace=kasten-io \
    --set global.airgapped.repository=ccr.ccs.tencentyun.com/kasten \
    --set metering.mode=airgap \
    --set auth.tokenAuth.enabled=true \
    --set externalGateway.create=true
```

安装完成之后可以通过 Loadbalancer 进入 K10 主页进行下一步配置。访问 K10 网页我配置了 token 认证，因为是 1.25 版本了，因此需要按照以下步骤获取 token：

```bash
# 创建临时 token
kubectl --namespace kasten-io create token k10-k10-token --duration=24h
# 用这个 token 为 k10-k10 账号创建 secret
desired_token_secret_name=k10-k10-token

kubectl apply --namespace=kasten-io --filename=- <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: ${desired_token_secret_name}
  annotations:
    kubernetes.io/service-account.name: "k10-k10"
EOF

kubectl get secret ${desired_token_secret_name} --namespace kasten-io -ojsonpath="{.data.token}" | base64 --decode
```

在我的这个 Demo 中，K10 会调用 vSphere 的虚拟磁盘快照来进行数据备份的操作，同时会用到 VBR 的 Repository 作为存储库。

进入 K10 主页后，在右侧的 Profile 中找到 Location，我们需要为 K10 配置一个 S3 的对象存储和一个 VBR 的 Repository，其中 S3 对错存储用于存储 Metadata 和 YAML 配置，而 VBR 的 repository 用于 vmdk 数据备份存储，也就是 pvc 的备份。

![Xnip2023-11-06_13-08-02](http://image.backupnext.cloud/uPic/Xnip2023-11-06_13-08-02.jpg)

在 Profile 下面，还有个 Infrastructure，使用 New Profile 按钮新增一个 vCenter 的连接，配置信息非常简单，和任何设备添加 vCenter 几乎没区别，IP 地址、用户名、密码，3 要素。

![Xnip2023-11-06_13-21-01](http://image.backupnext.cloud/uPic/Xnip2023-11-06_13-21-01.jpg)

## 备份配置

接下来，就可以进行备份策略的配置了。在使用了 vSphere CSI 后备份策略稍有不同，在 Snapshot Retention 上，可以看到 K10 自动感知到这是 VMware CSI，给出了 VMware 平台中 Snapshot 保留的最佳实践，并提示 K10 不需要保留 local snapshot，因此我将 Snapshot 设置为 0。

![Xnip2023-11-07_18-42-02](http://image.backupnext.cloud/uPic/Xnip2023-11-07_18-42-02.jpg)

在 Export Location Profile 中，可以选择 Wasabi S3 对象存储作为第一级备份 Export 目标，在这里其实 S3 并不存放 vmdk 数据，仅仅是存放应用的 metadata 和 yaml 配置，此处 VBR 的 Location Profile 处于不可选状态。

在这个`Enable Backups via Snapshot Exports`之后，会有个新增的选项`Export snapshot data in block mode`，勾选这个选项后，可以选择 Veeam Backup Location Profile。

![Xnip2023-11-07_18-43-14](http://image.backupnext.cloud/uPic/Xnip2023-11-07_18-43-14.jpg)

其他配置没有什么特别，这样配置后的 Policy 如下：

![Xnip2023-11-07_18-44-47](/images/posts/assets/Xnip2023-11-07_18-44-47.jpg)

备份自动运行后，可以从 Dashboard 进入查看到详细的备份 Action 详情，其中 VBR 的导出部分由 Kanister 完成：

![Xnip2023-11-07_18-49-54](/images/posts/assets/Xnip2023-11-07_18-49-54.jpg)

![Xnip2023-11-07_18-49-33](/images/posts/assets/Xnip2023-11-07_18-49-33.jpg)

而在 VBR 中，可以看到 K10 的 Policy 和 K10 的备份存档也已经出现：

![Xnip2023-11-07_18-53-18](/images/posts/assets/Xnip2023-11-07_18-53-18.jpg)

关于 VBR 中 K10 的操作，可以参考 [Veeam 官方的手册](https://helpcenter.veeam.com/docs/backup/kasten_integration/overview.html?ver=110)。

## 即时恢复

好了接下来到了我们今天的重头戏了，使用 K10 进行容器的即时恢复。

这个即时恢复是在 K10 的控制台中操作，在 K10 的图形化界面中，找到备份下来的存档，点击 restore 按钮，可以看到之前备份下来的还原点。和其他的容器还原一样，选择还原点之后会弹出还原设置窗口。K10 能够自动感知到 vSphere CSI 的支持，在还原选项中能够看到 Enable Instant Recovery 选项。我们只需要选中这个选项，在后面的还原中 K10 就会自动去使用这个能力了。

![Xnip2023-11-07_18-55-22](/images/posts/assets/Xnip2023-11-07_18-55-22.jpg)

我们做一些基本配置，比如修改下 namespace 的名字来新建一个应用，然后点击还原，即时还原任务就会开始。

稍等片刻后，我们可以看到容器已经被恢复了，这时候来到 VBR 上，能够看到一个新的 FCD 的即时还原任务已经启动完成。数据还是通过 Veeam 经典的 vPower 技术挂载到 vSphere 上。

![Xnip2023-11-07_18-59-11](/images/posts/assets/Xnip2023-11-07_18-59-11.jpg)

使用下 kubectl get pv,pvc 来看下目前的数据卷状态，对于 Kubernetes 来说，毫无感知，无缝恢复。

![Xnip2023-11-07_19-01-48](/images/posts/assets/Xnip2023-11-07_19-01-48.jpg)

这时候查看 vSphere 上容器卷的情况，会发现经典的 vPower 技术挂载的 NFS 卷已经被使用在容器的 PV 和 PVC 上了

![Xnip2023-11-07_19-03-37](/images/posts/assets/Xnip2023-11-07_19-03-37.jpg)

接下去我们一样还需要通过 Migrate to Production 功能，借助 Storage vMotion 或者 Veeam Quick Migration 功能，将虚拟磁盘文件迁移至虚拟化平台。

![Xnip2023-11-07_19-06-37](/images/posts/assets/Xnip2023-11-07_19-06-37.jpg)

系统会自动用 storage vMotion 或者是 quick migration 全自动完成数据的迁移，整个迁移过程 k8s 应用在线正常运行，完全无感知。

![Xnip2023-11-07_19-36-26](/images/posts/assets/Xnip2023-11-07_19-36-26.jpg)

迁移完成后，可以在 vSphere Client 中看到容器卷已经运行在 vSAN 上了。

![Xnip2023-11-07_19-37-31](/images/posts/assets/Xnip2023-11-07_19-37-31.jpg)

好了，以上这个就是容器的即时恢复，喜欢的朋友赶紧动手试玩下吧，同时也不要忘了一键三连，关注、点赞、在看！


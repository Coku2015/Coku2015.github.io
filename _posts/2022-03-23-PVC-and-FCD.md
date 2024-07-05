---
layout: post
title: 头等舱磁盘（First Class Disks）详解
tags: VMware
---

在 Veeam 推出 v11 版本后，细心的朋友也许注意到了在做即时磁盘恢复时，有下面这个选项：

[![q3e6I0.png](https://s1.ax1x.com/2022/03/23/q3e6I0.png)](https://imgtu.com/i/q3e6I0)

这是在 6.5 以后的 vSphere 中，VMware 引入了一种全新的磁盘格式，叫”头等舱磁盘（First Class Disks）“。这个名字足够霸气，而实际上，这类虚拟磁盘也确实有着自己独特的”特权“。今天我就来和大家详解下这类 FCD。

## 背景

先说说背景，这个 FCD 在早期的 vSphere 中，曾经被叫做是 Improved Virtual Disk（IVD）。所以，FCD 的本质，其实就是个 VMware 的虚拟磁盘：vmdk。我们知道在 vSphere 中，每台虚拟机都会拥有一个或多个虚拟磁盘，这些虚拟磁盘的日常管理都和其对应的虚拟机一一关联。让我们来以物理环境和虚拟环境做一个简单的类比：

- 一台物理服务器，连接了存储设备上的多个存储卷，假如存储设备有快照功能，这时候存储是可以对单个卷进行快照操作的。

- 一台 VMware 虚拟机，上面有多个 vmdk，执行快照只能对整个虚拟机进行，无法对单个 vmdk 进行。

FCD 就是在这样的背景下诞生，FCD 的管理完全独立于 VM 的生命周期，vmdk 变成一个单独的存储对象进行管理，它独立于任何的虚拟机。我们可以不需要关心这个磁盘的挂载状态，直接对磁盘完成创建、删除、快照、备份、还原和其他磁盘生命周期管理的操作。

FCD 诞生后，使用的场景非常多，比如 VDI、OpenStack Cinder 等。今天我们来说一个我最近在 Homelab 中一直使用的重要场景，为 Kubernetes 环境提供持久存储的 vSphere Cloud Native Storage(CNS)。

## Kubernetes 使用 vSphere FCD

FCD 存放在每个 Datastore 的 fcd 目录下，如图：

[![qMJXFA.png](https://s1.ax1x.com/2022/03/22/qMJXFA.png)](https://imgtu.com/i/qMJXFA)

每个 FCD 由一个 vmdk 文件和一个 vmfd 文件组成，也就是说，相比普通的 vmdk 多了一个 vmfd 文件。

FCD 在 vSphere Client 上是看不到的，实际上所有 FCD 的日常管理，都是通过 API 进行的。一个比较方便的入口是通过 vSphere Mob 进行管理：

https://<vCenter IP>/vslm/mob//?moid=VStorageObjectManager

在这个 Mob 管理器中，可以对 FCD 进行创建、挂载、克隆、快照管理、删除等一系列操作。

只是这个 Mob 管理器实际上操作也不太够，通过 PowerCLI 可以进行更多的补充，比如通过 PowerCLI 来查询当前 vCenter 中所有注册的 FCD 磁盘。

[Get-VDisk](https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.storage/commands/get-vdisk/#Default)

[![qMU6pR.png](https://s1.ax1x.com/2022/03/22/qMU6pR.png)](https://imgtu.com/i/qMU6pR)

每个 FCD 都有其唯一的标识 UUID 来识别，这个 UUID 存放在 vCenter 的 catalog 中，因此不管是 vSphere Mob 还是 PowerCLI 中，操作这些 FCD 的时候都需要这个 ID。

当这些 FCD 和 Kubernetes 中的 PVC 关联上之后，vSphere Client 中就能够通过每个 Datastore 下的 Monitor-> Cloud Native Storage -> Container Volumes 看到这些 FCD。

[![qMd7OP.png](https://s1.ax1x.com/2022/03/22/qMd7OP.png)](https://imgtu.com/i/qMd7OP)

其中，Volume Name 对应 Kubernetes 中 PVC Name，而 Volume ID 则是 vSphere 中 FCD 的 UUID。

当 vSphere 为 Kubernetes Worker Node 提供 PVC 存储的时候，实际上这些 FCD 都会被 attach 到每一个 Worker Node 的虚拟机中。比如我这台 Worker Node：

[![qMBsQs.png](https://s1.ax1x.com/2022/03/22/qMBsQs.png)](https://imgtu.com/i/qMBsQs)

这样就很容易理解，Kubernetes 中的应用是如何往它们的持久化 PVC 中写入数据了。实际上工作的时候，就是这些 Worker Node 虚拟机在往这些 vmdk 中写入数据。

## K10 的备份

当 K10 使用 vSphere Integration 进行 Kubernetes 上应用的备份时，K10 不再需要 VolumeSnapshot CRD 来完成 PVC 卷的快照，此时替代的方法是 vSphere FCD Snapshot。本文开篇我们提到过，FCD 的生命周期管理是完全独立于虚拟机的，这时候当我们发起备份任务的时候，K10 不需要对整个 Worker Node 进行 Snapshot，而是换成了对某个 FCD 进行 Snapshot，从而实现了 Kubernetes 平台上 PVC 的 Snapshot。

[![qMriv9.png](https://s1.ax1x.com/2022/03/22/qMriv9.png)](https://imgtu.com/i/qMriv9)

FCD 的 Snapshot 和普通 vmdk 的 Snapshot 结构完全一致，也是由父磁盘和子磁盘组成，一样是差异磁盘的模式，文件组成和文件名的结构也完全一样。因此 vmdk 上被诟病多年的问题，FCD 上依然存在，然而不也是一种优势吗？

因为这个原因，在 K10 备份的时候，我们不建议将 Snapshot 保留超过 3 份，为了性能和容量考虑，我建议 1 份 Snapshot 就已经足够了，其他的数据挪到 Repository 中吧。

K10 备份下来的数据，其中一部分可以导出至 VBR 中，这部分数据其实就是 FCD 的快照镜像，在 VBR 接收到这份数据后，VBR 可以利用强大的恢复能力来对 FCD 进行恢复。

事实上在 VBR 中，VBR 可以将任何的数据卷转换成 VMware 上的 FCD，只需要使用 VBR Instant Disk Recovery 功能。

## 即时 PVC 恢复小实验

我在我的 Lab 中使用 VBR 的 Instant Disk Recovery 做了一个 PVC 恢复的小实验，试着强强联合，让他们碰撞出一些火花。

### 场景

在我的 Tanzu 集群中，有一个叫 leihomedemo3 的 app，这个 app 非常简单，就是个 alpine linux，当前这个 alpine 并没有挂载任何数据卷。我想通过即时 FCD 恢复技术，将一个之前备份下来的 FCD 恢复并挂载到这个 alpine linux 的/data 目录。

### 步骤

1. 在 VBR 中，找到 k10 的备份存档，使用 Instant Disk Recovery 按钮打开恢复向导并选择最新的还原点。
   [![q3wqHI.png](https://s1.ax1x.com/2022/03/23/q3wqHI.png)](https://imgtu.com/i/q3wqHI)
2. 在 Mount Mode 中，选择 First class disk(FCD)。
   [![q3e6I0.png](https://s1.ax1x.com/2022/03/23/q3e6I0.png)](https://imgtu.com/i/q3e6I0)
3. 在 Disks 中，可以看到要恢复的磁盘的一些信息，这一步我保持默认，不做任何修改。
   [![q30nv4.png](https://s1.ax1x.com/2022/03/23/q30nv4.png)](https://imgtu.com/i/q30nv4)
4. 在 Destination 中，选择我的环境中运行着 Tanzu 的 Cluster。
   [![q30rIP.png](https://s1.ax1x.com/2022/03/23/q30rIP.png)](https://imgtu.com/i/q30rIP)
5. 接下去 Write Cache 之后的步骤都不做任何修改，一直到 Finish，就开始启动即时磁盘恢复了。大约几十秒之后，这个 FCD 就被成功挂载了。在即时恢复的 Session 中，可以看到这个磁盘被注册成 FCD，它的 ID 是 540eedc6-9a48-4f07-9ec1-cd3b9ec9a67e。
   [![q30zIx.png](https://s1.ax1x.com/2022/03/23/q30zIx.png)](https://imgtu.com/i/q30zIx)
6. 有了这个 FCD ID 之后，我来到 Tanzu 集群中，通过下面的 yaml 文件，将这个 FCD 绑定成 pvc。

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: vbrinstant
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
provisioner: csi.vsphere.vmware.com
parameters:
  datastoreurl: ds:///vmfs/volumes/ae2b924e-83e53e07/
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: vbrinstantrecoverypv
  annotations:
    pv.kubernetes.io/provisioned-by: csi.vsphere.vmware.com
spec:
  storageClassName: vbrinstant
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  csi:
    driver: "csi.vsphere.vmware.com"
    volumeAttributes:
      type: "vSphere CNS Block Volume"
    volumeHandle: "540eedc6-9a48-4f07-9ec1-cd3b9ec9a67e"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: vbrinstantrecoverypvc
  namespace: leihomedemo3
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: vbrinstant
```

到 Tanzu 控制台上执行命令：

```
k10@tceconsole:~/demo$ kubectl apply -f vbrdemopvc.yaml 
storageclass.storage.k8s.io/vbrinstant unchanged
persistentvolume/vbrinstantrecoverypv created
persistentvolumeclaim/vbrinstantrecoverypvc created
k10@tceconsole:~/demo$ kubectl get pvc -n leihomedemo3
NAME                    STATUS   VOLUME                 CAPACITY   ACCESS MODES   STORAGECLASS   AGE
vbrinstantrecoverypvc   Bound    vbrinstantrecoverypv   1Gi        RWO            vbrinstant     28s
```

绑定成功了，FCD 就正式转换成了 Container Volume，此时从 vSphere Client 中也就能看到绑定后的 pv 卷了。

[![q3DcuQ.png](https://s1.ax1x.com/2022/03/23/q3DcuQ.png)](https://imgtu.com/i/q3DcuQ)

7. 修改 deployment，加入挂载卷，修改完后，deployment 重启，几秒钟后，重启完成，这时候 pod 内就能看到数据了。

   ```yaml
   k10@tceconsole:~/demo$ kubectl edit deploy -n leihomedemo3 demo-app 
   ## 在 container 部分加入挂载卷
         containers:
         - name: demo-container
           volumeMounts:
           - name: data
             mountPath: /data
   ## 在 template spec 中加入 pvc 卷名称
       spec:
         volumes:
         - name: data
           persistentVolumeClaim:
             claimName: vbrinstantrecoverypvc
             
   deployment.apps/demo-app edited          
   k10@tceconsole:~/demo$ kubectl exec --namespace=leihomedemo3 demo-app-7758b547ff-gf4n8 -- ls -l /data/
   total 24
   -rw-rw-r--    1 1000     117            811 Mar 15 05:49 depoly-pvc.yaml
   drwx------    2 root     root         16384 Mar 12 14:01 lost+found
   -rw-rw-r--    1 1000     117             13 Mar 12 14:33 mytest
   ```

8. 在 VBR 中，依然可以使用老套路，Migration to Production，将 PVC 从 vbr 的 cache 中迁移至生成系统的 Datastore 里。
   [![q36tRP.png](https://s1.ax1x.com/2022/03/23/q36tRP.png)](https://imgtu.com/i/q36tRP)

9. 整个迁移过程，系统没有任何中断，迁移完成后，在 Tanzu 中无需做任何修改，系统使用一切正常。唯一一点点小瑕疵在于，此时通过`kubectl get pvc -n leihomedemo3` 查询到 pvc，看到它依然是位于 VBR 挂载上来的 StorageClass。修改的方法也不算复杂，并且不修复也不影响使用：

   ```
   k10@tceconsole:~/demo$ kubectl delete -n leihomedemo3 pvc vbrinstantrecoverypvc 
   persistentvolumeclaim "vbrinstantrecoverypvc" deleted
   ## 系统会卡在这一步，通过 ctrl+c 直接结束命令即可，然后运行下面这个命令强制解除
   k10@tceconsole:~/demo$ kubectl patch pvc -n leihomedemo3 vbrinstantrecoverypvc -p '{"metadata":{"finalizers":null}}'
   ## 将步骤 6 中用到过的绑定的 yaml 中的 pv 和 pvc 部分的 storageClassName: vbrinstant 修改为 storageClassName:isonfs，然后重新应用这个 yaml 即可。
   k10@tceconsole:~/demo$ kubectl apply -f vbrdemopvc.yaml 
   storageclass.storage.k8s.io/vbrinstant unchanged
   persistentvolume/vbrinstantrecoverypv configured
   persistentvolumeclaim/vbrinstantrecoverypvc created
   ```

   

   以上就是 FCD，这个全新的头等舱磁盘的分享。更多内容欢迎关注我的更新。

   

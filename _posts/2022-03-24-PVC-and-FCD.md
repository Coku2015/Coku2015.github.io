---
layout: post
title: 头等舱磁盘（First Class Disks）详解
tags: VMware
---

在Veeam推出v11版本后，细心的朋友也许注意到了在做即时磁盘恢复时，有下面这个选项：

[![q3e6I0.png](https://s1.ax1x.com/2022/03/23/q3e6I0.png)](https://imgtu.com/i/q3e6I0)

这是在6.5以后的vSphere中，VMware引入了一种全新的磁盘格式，叫”头等舱磁盘（First Class Disks）“。这个名字足够霸气，而实际上，这类虚拟磁盘也确实有着自己独特的”特权“。今天我就来和大家详解下这类FCD。

## 背景

先说说背景，这个FCD在早期的vSphere中，曾经被叫做是Improved Virtual Disk（IVD）。所以，FCD的本质，其实就是个VMware的虚拟磁盘：vmdk。我们知道在vSphere中，每台虚拟机都会拥有一个或多个虚拟磁盘，这些虚拟磁盘的日常管理都和其对应的虚拟机一一关联。让我们来以物理环境和虚拟环境做一个简单的类比：

- 一台物理服务器，连接了存储设备上的多个存储卷，假如存储设备有快照功能，这时候存储是可以对单个卷进行快照操作的。

- 一台VMware虚拟机，上面有多个vmdk，执行快照只能对整个虚拟机进行，无法对单个vmdk进行。

FCD就是在这样的背景下诞生，FCD的管理完全独立于VM的生命周期，vmdk变成一个单独的存储对象进行管理，它独立于任何的虚拟机。我们可以不需要关心这个磁盘的挂载状态，直接对磁盘完成创建、删除、快照、备份、还原和其他磁盘生命周期管理的操作。

FCD诞生后，使用的场景非常多，比如VDI、OpenStack Cinder等。今天我们来说一个我最近在Homelab中一直使用的重要场景，为Kubernetes环境提供持久存储的vSphere Cloud Native Storage(CNS)。

## Kubernetes使用vSphere FCD

FCD存放在每个Datastore的fcd目录下，如图：

[![qMJXFA.png](https://s1.ax1x.com/2022/03/22/qMJXFA.png)](https://imgtu.com/i/qMJXFA)

每个FCD 由一个vmdk文件和一个vmfd文件组成，也就是说，相比普通的vmdk多了一个vmfd文件。

FCD在vSphere Client上是看不到的，实际上所有FCD的日常管理，都是通过API进行的。一个比较方便的入口是通过vSphere Mob进行管理：

https://<vCenter IP>/vslm/mob//?moid=VStorageObjectManager

在这个Mob管理器中，可以对FCD进行创建、挂载、克隆、快照管理、删除等一系列操作。

只是这个Mob管理器实际上操作也不太够，通过PowerCLI可以进行更多的补充，比如通过PowerCLI来查询当前vCenter中所有注册的FCD磁盘。

[Get-VDisk](https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.storage/commands/get-vdisk/#Default)

[![qMU6pR.png](https://s1.ax1x.com/2022/03/22/qMU6pR.png)](https://imgtu.com/i/qMU6pR)

每个FCD都有其唯一的标识UUID来识别，这个UUID存放在vCenter的catalog中，因此不管是vSphere Mob还是PowerCLI中，操作这些FCD的时候都需要这个ID。

当这些FCD和Kubernetes中的PVC关联上之后，vSphere Client中就能够通过每个Datastore下的Monitor-> Cloud Native Storage -> Container Volumes看到这些FCD。

[![qMd7OP.png](https://s1.ax1x.com/2022/03/22/qMd7OP.png)](https://imgtu.com/i/qMd7OP)

其中，Volume Name对应Kubernetes中PVC Name，而Volume ID则是vSphere中FCD的UUID。

当vSphere为Kubernetes Worker Node提供PVC存储的时候，实际上这些FCD都会被attach到每一个Worker Node的虚拟机中。比如我这台Worker Node：

[![qMBsQs.png](https://s1.ax1x.com/2022/03/22/qMBsQs.png)](https://imgtu.com/i/qMBsQs)

这样就很容易理解，Kubernetes中的应用是如何往它们的持久化PVC中写入数据了。实际上工作的时候，就是这些Worker Node虚拟机在往这些vmdk中写入数据。

## K10的备份

当K10使用vSphere Integration进行Kubernetes上应用的备份时，K10不再需要VolumeSnapshot CRD来完成PVC卷的快照，此时替代的方法是vSphere FCD Snapshot。本文开篇我们提到过，FCD的生命周期管理是完全独立于虚拟机的，这时候当我们发起备份任务的时候，K10不需要对整个Worker Node进行Snapshot，而是换成了对某个FCD进行Snapshot，从而实现了Kubernetes平台上PVC的Snapshot。

[![qMriv9.png](https://s1.ax1x.com/2022/03/22/qMriv9.png)](https://imgtu.com/i/qMriv9)

FCD的Snapshot和普通vmdk的Snapshot结构完全一致，也是由父磁盘和子磁盘组成，一样是差异磁盘的模式，文件组成和文件名的结构也完全一样。因此vmdk上被诟病多年的问题，FCD上依然存在，然而不也是一种优势吗？

因为这个原因，在K10备份的时候，我们不建议将Snapshot保留超过3份，为了性能和容量考虑，我建议1份Snapshot就已经足够了，其他的数据挪到Repository中吧。

K10备份下来的数据，其中一部分可以导出至VBR中，这部分数据其实就是FCD的快照镜像，在VBR接收到这份数据后，VBR可以利用强大的恢复能力来对FCD进行恢复。

事实上在VBR中，VBR可以将任何的数据卷转换成VMware上的FCD，只需要使用VBR Instant Disk Recovery功能。

## 即时PVC恢复小实验

我在我的Lab中使用VBR的Instant Disk Recovery做了一个PVC恢复的小实验，试着强强联合，让他们碰撞出一些火花。

### 场景

在我的Tanzu集群中，有一个叫leihomedemo3的app，这个app非常简单，就是个alpine linux，当前这个alpine并没有挂载任何数据卷。我想通过即时FCD恢复技术，将一个之前备份下来的FCD恢复并挂载到这个alpine linux的/data目录。

### 步骤

1. 在VBR中，找到k10的备份存档，使用Instant Disk Recovery按钮打开恢复向导并选择最新的还原点。
   [![q3wqHI.png](https://s1.ax1x.com/2022/03/23/q3wqHI.png)](https://imgtu.com/i/q3wqHI)
2. 在Mount Mode中，选择First class disk(FCD)。
   [![q3e6I0.png](https://s1.ax1x.com/2022/03/23/q3e6I0.png)](https://imgtu.com/i/q3e6I0)
3. 在Disks中，可以看到要恢复的磁盘的一些信息，这一步我保持默认，不做任何修改。
   [![q30nv4.png](https://s1.ax1x.com/2022/03/23/q30nv4.png)](https://imgtu.com/i/q30nv4)
4. 在Destination中，选择我的环境中运行着Tanzu的Cluster。
   [![q30rIP.png](https://s1.ax1x.com/2022/03/23/q30rIP.png)](https://imgtu.com/i/q30rIP)
5. 接下去Write Cache之后的步骤都不做任何修改，一直到Finish，就开始启动即时磁盘恢复了。大约几十秒之后，这个FCD就被成功挂载了。在即时恢复的Session中，可以看到这个磁盘被注册成FCD，它的ID是540eedc6-9a48-4f07-9ec1-cd3b9ec9a67e。
   [![q30zIx.png](https://s1.ax1x.com/2022/03/23/q30zIx.png)](https://imgtu.com/i/q30zIx)
6. 有了这个FCD ID之后，我来到Tanzu集群中，通过下面的yaml文件，将这个FCD绑定成pvc。

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

到Tanzu控制台上执行命令：

```
k10@tceconsole:~/demo$ kubectl apply -f vbrdemopvc.yaml 
storageclass.storage.k8s.io/vbrinstant unchanged
persistentvolume/vbrinstantrecoverypv created
persistentvolumeclaim/vbrinstantrecoverypvc created
k10@tceconsole:~/demo$ kubectl get pvc -n leihomedemo3
NAME                    STATUS   VOLUME                 CAPACITY   ACCESS MODES   STORAGECLASS   AGE
vbrinstantrecoverypvc   Bound    vbrinstantrecoverypv   1Gi        RWO            vbrinstant     28s
```

绑定成功了，FCD就正式转换成了Container Volume，此时从vSphere Client中也就能看到绑定后的pv卷了。

[![q3DcuQ.png](https://s1.ax1x.com/2022/03/23/q3DcuQ.png)](https://imgtu.com/i/q3DcuQ)

7. 修改deployment，加入挂载卷，修改完后，deployment重启，几秒钟后，重启完成，这时候pod内就能看到数据了。

   ```yaml
   k10@tceconsole:~/demo$ kubectl edit deploy -n leihomedemo3 demo-app 
   ## 在container部分加入挂载卷
         containers:
         - name: demo-container
           volumeMounts:
           - name: data
             mountPath: /data
   ## 在template spec中加入pvc卷名称
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

8. 在VBR中，依然可以使用老套路，Migration to Production，将PVC从vbr的cache中迁移至生成系统的Datastore里。
   [![q36tRP.png](https://s1.ax1x.com/2022/03/23/q36tRP.png)](https://imgtu.com/i/q36tRP)

9. 整个迁移过程，系统没有任何中断，迁移完成后，在Tanzu中无需做任何修改，系统使用一切正常。唯一一点点小瑕疵在于，此时通过`kubectl get pvc -n leihomedemo3` 查询到pvc，看到它依然是位于VBR挂载上来的StorageClass。修改的方法也不算复杂，并且不修复也不影响使用：

   ```
   k10@tceconsole:~/demo$ kubectl delete -n leihomedemo3 pvc vbrinstantrecoverypvc 
   persistentvolumeclaim "vbrinstantrecoverypvc" deleted
   ## 系统会卡在这一步，通过ctrl+c直接结束命令即可，然后运行下面这个命令强制解除
   k10@tceconsole:~/demo$ kubectl patch pvc -n leihomedemo3 vbrinstantrecoverypvc -p '{"metadata":{"finalizers":null}}'
   ## 将步骤6中用到过的绑定的yaml中的pv和pvc部分的storageClassName: vbrinstant修改为storageClassName:isonfs，然后重新应用这个yaml即可。
   k10@tceconsole:~/demo$ kubectl apply -f vbrdemopvc.yaml 
   storageclass.storage.k8s.io/vbrinstant unchanged
   persistentvolume/vbrinstantrecoverypv configured
   persistentvolumeclaim/vbrinstantrecoverypvc created
   ```

   

   以上就是FCD，这个全新的头等舱磁盘的分享。更多内容欢迎关注我的更新。

   


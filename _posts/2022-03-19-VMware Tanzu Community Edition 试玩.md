---
layout: post
title: Tanzu Community Edition（TCE）试玩
tags: VMware
---

最近刷新了下Homelab，开始在Homelab中玩玩Tanzu。去年VMware开源了Tanzu Community Edition，正好利用这个机会装上配上k10玩一把。

## 硬件部分

我的环境由2台机器组成，一台是服役了6年多的Dell Precision M4800，另外一台是新加入的NUC11 猎豹峡谷。其中猎豹峡谷的配置如下：

- CPU：Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
- 内存：ADATA 32GB×2 DDR4-3200
- 硬盘：aigo NVMe SSD P2000 1TB
- 网卡：Intel Corporation Ethernet Controller I225-V



## 软件部分

M4800上，使用DellEMC的自定义ESXi镜像，从DellEMC的官网能够下载到，里面包含了所有Dell硬件的驱动。

NUC11上安装ESXi最大的挑战来自于网卡驱动，这个网卡是2.5GbE的网卡，VMware官方驱动中并不包含。不过大神们总有解决办法，社区版网卡驱动[戳这里](https://williamlam.com/2021/02/new-community-networking-driver-for-esxi-fling.html)就能找到。

两台主机都安装vSphere 7.0.3，vCenter版本也是7.0.3.

[![bqZqXR.png](https://s1.ax1x.com/2022/03/13/bqZqXR.png)](https://imgtu.com/i/bqZqXR)



## 开动安装TCE

### 环境准备

首先我需要一个控制台来安装并操作TCE，[TCE的官方手册](https://tanzucommunityedition.io/docs/latest/cli-installation/)上提供了macOS、Linux和Windows的三种平台安装。我选择在我的环境中安装一台Ubuntu 20.04 LTS的虚拟机来安装Tanzu CLI软件。

这台Ubuntu，并不是一台最小化安装的普通Ubuntu，需要另外准备以下环境：

- 安装Docker，并配置non-root用户使用Docker。配置方法很简单，只需要使用non-root用户，在安装完docker之后，按顺序执行下列命令即可。

  ```shell
  ## 1. 先加docker组
  k10@tceconsole:~$ sudo groupadd docker
  ## 2. 把当前用户加到docker组里
  k10@tceconsole:~$ sudo usermod -aG docker $USER
  ## 3. 接下去最好注销后重新登录，或者直接用下面的命令激活
  $ newgrp docker 
  ## 4. 试试docker命令，是否正常
  k10@tceconsole:~$ docker run hello-world
  ```

- 安装kubectl，这个没啥特别，根据官网指引或者其他的说明直接安装即可。

有了这些条件后，就可以使用TCE官网手册中的安装方法来安装Tanzu CLI了

在Tanzu CLI安装好之后，还需要从VMware官网[下载OVA镜像](https://customerconnect.vmware.com/downloads/get-download?downloadGroup=TCE-0100)，这个镜像是用来在vSphere中部署k8s node的，我选择了`ubuntu-2004-kube-v1.21.5+vmware.1-tkg.1-12483545147728596280-tce-010.ova`。

下载完成后，在vSphere中导入这个ova，并立刻将这个ova转换成模板，如下图在vSphere中可以看到这样的状态即可：

[![qVeOOg.png](https://s1.ax1x.com/2022/03/19/qVeOOg.png)](https://imgtu.com/i/qVeOOg)

另外，我还要在我的环境中配置一个DHCP服务器，在部署集群时，TCE必须依赖DHCP服务才能完成所有工作。

最后，是用下面的命令准备图形化安装第一步要用的ssh public key

```shell
## 创建一个SSH 密钥对
k10@tceconsole:~$ ssh-keygen -t rsa -b 4096 -C "administrator@backupnext.cloud"
## 获取下这个公钥备用
k10@tceconsole:~$ cat .ssh/id_rsa.pub
```

### 部署管理集群

TCE和其他Tanzu一样，都由管理集群（Management Cluster）和工作负载集群（Workload Cluster）组成，我在我的环境中首先需要配置一个管理集群，配置启动方法非常简单，只需要运行下面的命令即可：

```shell
k10@tceconsole:~$ tanzu management-cluster create --ui --bind 0.0.0.0:8080 --browser none
```

命令运行后，我在我本地的浏览器中，打开`http://<ubuntuip>:8080/ `就可以进入Tanzu 安装向导图形界面了。

1. 选择部署平台，VMware vSphere
   [![qVQTYj.png](https://s1.ax1x.com/2022/03/19/qVQTYj.png)](https://imgtu.com/i/qVQTYj)
2. 填入vCenter信息并连接，这里连接后，需要将前面准备好的SSH公钥填入到SSH Public Key框中。
   [![qVQokQ.png](https://s1.ax1x.com/2022/03/19/qVQokQ.png)](https://imgtu.com/i/qVQokQ)
3. 设置管理集群信息，我选择了Development模式，这样在我的小Lab中只需要一台Control Plane节点，并且我将Instance Type选择了small的最小配置。我填写了Management Cluster Name为`leihome`，启用了Machine Health Checks。Control Plane Endpoint Provider选择Kube-vip，指定Control Plane Endpoint地址为10.10.1.182，设定了Worker Node Instance Type为Small，Audit Logging为不Enable。
   [![qVbam4.png](https://s1.ax1x.com/2022/03/20/qVbam4.png)](https://imgtu.com/i/qVbam4)
4. VMware NSX Advanced Load Balancer和Metadata部分，都禁用不选择。
5. 在第五步Resource中，指定部署到VM Folder为`/HomelabDC/vm/tkg`，Datastore为`/HomelabDC/datastore/localnvme`，Cluster、Hosts、and Resource Pools选择`TanzuCE`这个资源池。
   [![qVQ40S.png](https://s1.ax1x.com/2022/03/19/qVQ40S.png)](https://imgtu.com/i/qVQ40S)
6. Kubernetes Network步骤中，配置没进行修改，保持默认。
   [![qVQhm8.png](https://s1.ax1x.com/2022/03/19/qVQhm8.png)](https://imgtu.com/i/qVQhm8)
7. Identity Management步骤中，禁用Identity Management Settings。
   [![qVQWOf.png](https://s1.ax1x.com/2022/03/19/qVQWOf.png)](https://imgtu.com/i/qVQWOf)
8. OS image步骤中，选择准备工作中已经导入的虚拟机模板node节点。
   [![qVQ7fs.png](https://s1.ax1x.com/2022/03/19/qVQ7fs.png)](https://imgtu.com/i/qVQ7fs)
9. 然后以上配置就完成了，Review下configuration之后，就进入了全自动的配置，大约半小时左右管理集群将会被自动部署完并且可以使用。

管理集群部署完成后，回到我的Ubuntu控制台上，执行命令:

```shell
## 查询下前面安装的管理集群
k10@tceconsole:~$ tanzu management-cluster get
  NAME     NAMESPACE   STATUS   CONTROLPLANE  WORKERS  KUBERNETES        ROLES       
  leihome  tkg-system  running  1/1           1/1      v1.21.5+vmware.1  management  


Details:

NAME                                                        READY  SEVERITY  REASON  SINCE  MESSAGE
/leihome                                                    True                     8d            
├─ClusterInfrastructure - VSphereCluster/leihome            True                     8d            
├─ControlPlane - KubeadmControlPlane/leihome-control-plane  True                     8d            
│ └─Machine/leihome-control-plane-2mz2v                     True                     8d            
└─Workers                                                                                          
  └─MachineDeployment/leihome-md-0                                                                 
    └─Machine/leihome-md-0-6f69758844-zpfsj                 True                     8d            


Providers:

  NAMESPACE                          NAME                    TYPE                    PROVIDERNAME  VERSION  WATCHNAMESPACE  
  capi-kubeadm-bootstrap-system      bootstrap-kubeadm       BootstrapProvider       kubeadm       v0.3.23                  
  capi-kubeadm-control-plane-system  control-plane-kubeadm   ControlPlaneProvider    kubeadm       v0.3.23                  
  capi-system                        cluster-api             CoreProvider            cluster-api   v0.3.23                  
  capv-system                        infrastructure-vsphere  InfrastructureProvider  vsphere       v0.7.10  
## 获取kubectl的管理权限
k10@tceconsole:~$ tanzu management-cluster kubeconfig get leihome --admin
Credentials of cluster 'leihome' have been saved 
You can now access the cluster by running 'kubectl config use-context leihome-admin@leihome'
## 试下kubectl
k10@tceconsole:~$ kubectl get node
NAME                            STATUS   ROLES                  AGE   VERSION
leihome-control-plane-2mz2v     Ready    control-plane,master   8d    v1.21.5+vmware.1
leihome-md-0-6f69758844-zpfsj   Ready    <none>                 8d    v1.21.5+vmware.1
```

这样，管理集群就全部完成了，这时候，回到vCenter上，也能够看到2台对应的node虚拟机。

[![qZPdxJ.png](https://s1.ax1x.com/2022/03/20/qZPdxJ.png)](https://imgtu.com/i/qZPdxJ)



### 部署Workload集群

在管理集群部署完成后，以上的集群配置会以yaml文件自动保存在`~/.config/tanzu/tkg/clusterconfigs/`目录下，部署Workload集群的方法非常简单，只需要利用自动生成的管理集群的yaml文件，稍加修改，即可使用。

通过以下命令，先创建一份并修改用于部署Workload集群的yaml文件：

```shell
k10@tceconsole:~$ cp  ~/.config/tanzu/tkg/clusterconfigs/pkwmre6kuu.yaml ~/.config/tanzu/tkg/clusterconfigs/workload1.yaml
k10@tceconsole:~$ vi ~/.config/tanzu/tkg/clusterconfigs/workload1.yaml
```

修改文件中以下字段：

```yaml
CLUSTER_NAME: leihome-workload-01
VSPHERE_CONTROL_PLANE_ENDPOINT: 10.10.1.191
VSPHERE_WORKER_MEM_MIB: "8192"
```

其中`CLUSTER_NAME`是Workload集群的名称，我这里使用`leihome-workload-01`，`VSPHERE_CONTROL_PLANE_ENDPOINT`是这个Workload集群的APIServer的访问地址，设置为固定IP比较合适，我使用`10.10.1.191`，`VSPHERE_WORKER_MEM_MIB`是Workload集群的内存，我的环境中默认Small配置的4GB不太够用，我设置成了`8192`。

修改完成后，运行如下命令，就能自动部署Workload集群了。

```shell
k10@tceconsole:~$ tanzu cluster create leihome-workload-01 --file ~/.config/tanzu/tkg/clusterconfigs/workload1.yaml
```

大约10来分钟，Workload集群就会部署完成，部署后和管理集群一样，默认配置为一个Control Plane和一个Worker。我计划多运行几个应用程序，因此我用下面这条命令来增加Worker Node：

```shell
k10@tceconsole:~$ tanzu cluster scale leihome-workload-01 --worker-machine-count=2
Successfully updated worker node machine deployment replica count for cluster leihome-workload-01
Workload cluster 'leihome-workload-01' is being scaled
```

Workload集群部署完成后，和管理集群一样，需要获取下Workload集群的访问权限：

```shell
## 获取当前的Workload集群列表
k10@tceconsole:~$ tanzu cluster list
  NAME                 NAMESPACE  STATUS   CONTROLPLANE  WORKERS  KUBERNETES        ROLES   PLAN  
  leihome-workload-01  default    running  1/1           2/2      v1.21.5+vmware.1  <none>  dev 
## 获取leihome-workload-01这个Workload集群的访问权限
k10@tceconsole:~$ tanzu cluster kubeconfig get leihome-workload-01 --admin
Credentials of cluster 'leihome-workload-01' have been saved 
You can now access the cluster by running 'kubectl config use-context leihome-workload-01-admin@leihome-workload-01'
## 用kubectl查下当前的context清单
k10@tceconsole:~$ kubectl config get-contexts 
CURRENT   NAME                                            CLUSTER               AUTHINFO                    NAMESPACE
*         leihome-admin@leihome                           leihome               leihome-admin               
          leihome-workload-01-admin@leihome-workload-01   leihome-workload-01   leihome-workload-01-admin   
## 用kubectl命令切换下集群，开始使用部署出来的集群
k10@tceconsole:~$ kubectl config use-context leihome-workload-01-admin@leihome-workload-01 
Switched to context "leihome-workload-01-admin@leihome-workload-01".
## 获取下node
k10@tceconsole:~$ kubectl get node
NAME                                        STATUS   ROLES                  AGE     VERSION
leihome-workload-01-control-plane-c4k4q     Ready    control-plane,master   7d18h   v1.21.5+vmware.1
leihome-workload-01-md-0-668d8747d6-4hd6z   Ready    <none>                 7d18h  v1.21.5+vmware.1
leihome-workload-01-md-0-668d8747d6-hcs4k   Ready    <none>                 7d18h   v1.21.5+vmware.1
```

回到vCenter中，可以看到3台Workload Node虚拟机已经运行起来了。

[![qZYjl4.png](https://s1.ax1x.com/2022/03/20/qZYjl4.png)](https://imgtu.com/i/qZYjl4)

以上过程，Kubernetes集群的计算资源就已经算是配置完成了。

### 存储资源配置

Tanzu集群可以通过vSphere CSI使用vSphere 7.0上的datastore存放持久化数据，但是默认情况下并没有自动将datastore和Tanzu集群关联，这时候我通过下面这个yaml文件，将datastore的访问开放给Workload。

```yaml
kind: StorageClass  
apiVersion: storage.k8s.io/v1  
metadata:  
  name: standard  
  annotations:  
    storageclass.kubernetes.io/is-default-class: "true"  
provisioner: csi.vsphere.vmware.com  
parameters:  
  datastoreurl: ds:///vmfs/volumes/622a19d3-91aee82b-59df-1c697aafcbf9/
```

其中最下面一行datastoreurl可以通过vCenter中datastore的summary中的地址获取，如图：

[![qZNnv4.png](https://s1.ax1x.com/2022/03/20/qZNnv4.png)](https://imgtu.com/i/qZNnv4)

配置这个新的StorageClass，并取消原来default的storage Class作为默认Storage Class：

```shell
## 添加新的Storage Class，连接vSphere上的Datastore
k10@tceconsole:~$ kubectl apply -f ~/storage/localnvme.yaml
## 取消原来自动配上的Hostpath作为默认Storage Class，当然也可以直接删除掉default的storage class
k10@tceconsole:~$ kubectl patch storageclass default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
## 用kubectl查询下目前的sc状况
k10@tceconsole:~$ kubectl get sc
NAME                 PROVISIONER              RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
default              csi.vsphere.vmware.com   Delete          Immediate           true                   7d19h
standard (default)   csi.vsphere.vmware.com   Delete          Immediate           false                  7d18h
```

### 开个测试demo应用试下环境

这个小demo很简单，就是个alpine Linux，挂一个数据目录/data，这个data目录实际上就会映射至vSphere的Datastore中，分配一个vmdk文件。关于这个vmdk文件，我先卖个关子，在下期推送中详细讨论。

小Demo的yaml：

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
  labels:
    app: demo
    pvc: demo
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
  labels:
    app: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: demo-container
        image: alpine:3.7
        resources:
            requests:
              memory: 256Mi
              cpu: 100m
        command: ["tail"]
        args: ["-f", "/dev/null"]
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: demo-pvc
```

创建过程很简单，下面2条命令即可，创建完成后，拷贝个文件进持久数据卷试试：

```shell
k10@tceconsole:~$ kubectl create ns leihomedemo
k10@tceconsole:~$ kubectl apply -n leihomedemo -f ~/demo/demoapp.yaml
k10@tceconsole:~$ kubectl cp mytest leihomedemo/demo-app-696f676d47-dsbcr:/data/
k10@tceconsole:~$ kubectl exec --namespace=leihomedemo demo-app-696f676d47-dsbcr -- ls -l /data
total 24
drwx------    2 root     root         16384 Mar 12 14:01 lost+found
-rw-rw-r--    1 1000     117             13 Mar 12 14:33 mytest
```

一切正常，环境完美运行。接下去我会安装Kasten K10，并配置K10和vbr来备份这个demo app。这部分内容我在下一期推送中分享。




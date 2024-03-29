---
layout: post
title: 虚拟化嵌套 TKGs 实验环境自动化脚本
tags: VMware, Tanzu
---

学习了一段时间 vSphere with Tanzu，发现功能非常强大，但是搭建这个学习环境成本略高。经过一些资料搜索和亲自试验，摸索出一些门道，记录在此篇博客中，方便那些希望学习 vSphere with Tanzu 的朋友快速搭建实验环境。

先放出本文涉及到的脚本的 Github 地址：

https://github.com/Coku2015/Nested-TKGs-automate-deployment

本文的脚本改编自 [William Lam](https://williamlam.com/2020/11/complete-vsphere-with-tanzu-homelab-with-just-32gb-of-memory.html) 的博客，原版的脚本适用于自动化部署 VMware 完整的 Tanzu Kubernetes 产品，适应的场景会比较丰富，有强大脚本能力的小伙伴可以参考大神的脚本进行按需改编。

本文分为上下两部分，其中第一部分为虚拟化基础架构搭建，第二部分为 Tanzu Kubernetes Cluster 创建。对于环境准备条件，将在本文开头一次性给出。

## 0. 条件准备

本文中环境为 vSphere 虚拟化嵌套环境，所有 VM 将会被部署至 vSphere vCenter 管理的物理 ESXi 服务器上，因此在宿主机上建议预留以下资源用于部署：

- vCPU：9 个
- 内存：40.5GB
- 磁盘：1421GB（分配容量）

这套环境部署完成后，将会生成 4 个虚拟机，分别是：

- Nested ESXi （基本配置）：4vCPU/24GB 内存/1TB 磁盘/3 个网卡
- vCenter（基本配置）：2vCPU/12GB 内存/400GB 磁盘
- haproxy: 2vCPU/4GB 内存/5GB 磁盘
- openwrt router: 1vCPU/0.5G 内存/1GB 磁盘

在嵌套的 ESXi 中，将会部署 Tanzu Kubernetes 环境：

- 1 台 Supervisor VM：2vCPU/8GB 内存
- 1 台 K8S Control Plane：2vCPU/4GB 内存
- 2 台 K8S Worker Node：2vCPU/4GB 内存

部署完成后整个环境的拓扑如下：

[![j1npXq.png](https://s1.ax1x.com/2022/07/02/j1npXq.png)](https://imgtu.com/i/j1npXq)

在环境准备中，我们一共会需要以下镜像，这些镜像需要提前下载：

- [x] [Nested ESXi 7.0u3c](https://download3.vmware.com/software/vmw-tools/nested-esxi/Nested_ESXi7.0u3c_Appliance_Template_v1.ova)
- [x] [vCenter 7.0u3e](https://my.vmware.com/web/vmware/downloads.)
- [x] [haproxy.ova](https://cdn.haproxy.com/download/haproxy/vsphere/ova/haproxy-v0.2.0.ova)
- [x] [Openwrt router](https://github.com/Coku2015/Nested-TKGs-automate-deployment/raw/main/tkgrouter.ova)

在本文的第二部分中，系统还会全自动的在 Nested ESXi 中开启一组虚拟机，这些虚拟机属于 vSphere with Tanzu 管理。这需要订阅 VMware 官方的 Content Library，当然也可以手工下载 Content Library 中的内容，创建自己的本地的 Content Library。

在宿主机的环境中，需要准备一个接入 IP，这个接入 IP 将会被这套嵌套环境用于上联口，在我的环境中我使用 SHLAB_NET1 这个端口组来提供这个接入；而环境中的其他网络地址，都将会使用没有上联口的内部通讯地址。

因此，需要在宿主机 ESXi 上创建一个包含 3 个端口组的虚拟交换机，比如我的环境中，如下图所示。这 3 个端口组所在的虚拟交换机还需要打开混杂模式，用于嵌套的 ESXi 的通讯访问。

[![j1upPe.png](https://s1.ax1x.com/2022/07/02/j1upPe.png)](https://imgtu.com/i/j1upPe)

最后，我们还需要一台 VM 控制台，这台 VM 需要同时能够访问宿主机的 vCenter 和 Tanzu Lab 内部网络，我们将会在这台 VM 上运行本文提到的自动化脚本。

这个脚本全自动部署这套环境时，会用到 VMware vSphere PowerCLI 脚本，这首先需要安装 [Powershell 7](https://github.com/PowerShell/PowerShell)。

在 Powershell 7 中，执行在线安装命令，就能快速安装最新版的 VMware PowerCLI：

```powershell
PS C:\> Install-Module VMware.PowerCLI -Scope CurrentUser
```

关于 PowerCLI 的配置和安装，可以参考：

[Getting Started with VMware PowerCLI – A Beginner’s Guide](https://www.altaro.com/vmware/vmware-powercli-guide/)

所以最终当我搭建完成这个 Lab 后，环境网络连接如下：

[![j1GANq.png](https://s1.ax1x.com/2022/07/02/j1GANq.png)](https://imgtu.com/i/j1GANq)

## Part 1. vSphere with Tanzu 基础架构搭建

在准备完以上条件后，我们还需要根据实际环境，将脚本中的一些参数进行设置：

```powershell
# vCenter Server used to deploy vSphere with Tanzu  Basic Lab
$VIServer = "172.19.226.20"
$VIUsername = "administrator@vsphere.local"
$VIPassword = "P@ssw0rd"
```
这段设置用于部署这套环境的物理 ESXi 主机所在的 vCenter。

```powershell
# Full Path to both the Nested ESXi 7.0 VA, Extracted VCSA 7.0 ISO & HA Proxy OVAs
$NestedESXiApplianceOVA = "C:\Temp\Nested_ESXi7.0u3c_Appliance_Template_v1.ova"
$VCSAInstallerPath = "E:\"
$HAProxyOVA = "C:\Temp\haproxy-v0.2.0.ova"
$tkgrouterOVA = "C:\Temp\tkgrouter.ova"
```
这段需要配置所有 OVA 镜像的目录，其中 VCSA 需要将 ISO 挂载，并指定挂载后的 ISO 路径。

```powershell
# TKG Content Library URL
$TKGContentLibraryName = "TKG-Content-Library"
$TKGContentLibraryURL = "https://wp-content.vmware.com/v2/latest/lib.json"
```
这段为新建的 tkg vc 配置 Content Library，用于全自动部署 K8S 虚拟机。

```powershell
#tkgrouter configuration
$tkgrouterdisplayname = "tkgopenwrt"
$WANNETWORK = "SHASELAB_NET01"
$WANIP = "172.19.226.149"
$WANGW = "172.19.226.1"
$WANDNS1 = "172.19.226.21"
$WANDNS2 = "172.19.192.10"
$WANNETMASK = "255.255.255.0"
$TKGMGMTNETWORK = "TKG-MGMT"
$TKGMGMTIP = "10.10.1.1"
$TKGWORKLOADNETWORK = "TKG-Workload"
$TKGWORKLOADIP = "10.10.2.1"
$TKGFRONTENDNETWORK = "TKG-Frontend"
$TKGFRONTENDIP = "10.10.3.1"
```
这段为 Openwrt 路由器配置相关网络。

```powershell
# Nested ESXi VMs to deploy
$NestedESXiHostnameToIPs = @{
    "tkgesxi1" = "10.10.1.100";
}
```
这段设定 Nested ESXi 主机的主机名和 IP 地址，当需要部署多个 ESXi 的时候，只需要每行加一个即可。

```powershell
# Nested ESXi VM Resources
$NestedESXivCPU = "4"
$NestedESXivMEM = "24" #GB
$NestedESXiCapacityvDisk = "1000" #GB
```
ESXi 最小的资源配置，可以根据实际需求增加相关资源。

```powershell
# VCSA Deployment Configuration
$VCSADeploymentSize = "tiny"
$VCSADisplayName = "tkgsvc"
$VCSAIPAddress = "10.10.1.101"
$VCSAHostname = "10.10.1.101" #Change to IP if you don't have valid DNS
$VCSAPrefix = "24"
$VCSASSODomainName = "tkg.local"
$VCSASSOPassword = "P@ssw0rd"
$VCSARootPassword = "P@ssw0rd"
$VCSASSHEnable = "true"
```
VCSA 的配置。

```powershell
# HA Proxy Configuration
$HAProxyDisplayName = "tkghaproxy"
$HAProxyHostname = "haproxy.tkg.local"
$HAProxyDNS = "10.10.1.1"
$HAProxyManagementNetwork = "TKG-Mgmt"
$HAProxyManagementIPAddress = "10.10.1.102/24" # Format is IP Address/CIDR Prefix
$HAProxyManagementGateway = "10.10.1.1"
$HAProxyFrontendNetwork = "TKG-Frontend"
$HAProxyFrontendIPAddress = "10.10.3.2/24" # Format is IP Address/CIDR Prefix
$HAProxyFrontendGateway = "10.10.3.1"
$HAProxyWorkloadNetwork = "TKG-Workload"
$HAProxyWorkloadIPAddress = "10.10.2.2/24" # Format is IP Address/CIDR Prefix
$HAProxyWorkloadGateway = "10.10.2.1"
$HAProxyLoadBalanceIPRange = "10.10.3.64/26" # Format is Network CIDR Notation
$HAProxyOSPassword = "P@ssw0rd"
$HAProxyPort = "5556"
$HAProxyUsername = "wcp"
$HAProxyPassword = "P@ssw0rd"
```
3 网卡的 HAproxy 的配置，分别对应 3 个网段，其中 10.10.3.x 为 Load Balance 使用。这段的内容非常重要，里面的很多信息，将在 Part 2 中手工填写步骤中用到。

```powershell
# General Deployment Configuration for Nested ESXi, VCSA & HA Proxy VM
$VMDatacenter = "SHALABDC"
$VMCluster = "SHALAB"
$VMNetwork = "TKG-Mgmt"
$VMDatastore = "SHASEESX_DS_01"
$VMNetmask = "255.255.255.0"
$VMGateway = "10.10.1.1"
$VMDNS = "172.19.226.21"
$VMNTP = "172.19.226.21"
$VMPassword = "P@ssw0rd"
$VMDomain = "shlab.local"
$VMSyslog = "10.10.1.1"
$VMFolder = "Lab Infra"
# Applicable to Nested ESXi only
$VMSSH = "true"
$VMVMFS = "false"
```
通用环境参数设置，需要特别注意的时候，环境中必须能够访问 NTP Server，不管是内部还是外部，否则 vCenter 服务部署将会失败。

```powershell
# Name of new vSphere Datacenter/Cluster when VCSA is deployed
$NewVCDatacenterName = "tkgs-dc"
$NewVCVSANClusterName = "tkgs-Cluster"
$NewVCVDSName = "tkgs-VDS"
$NewVCMgmtPortgroupName = "tkgs-mgmt"
$NewVCWorkloadPortgroupName = "tkgs-workload"
```
新 vCenter 上网络端口组的设置

```powershell
# Tanzu Configuration
$StoragePolicyName = "tkgs-demo-storage-policy"
$StoragePolicyTagCategory = "tkgs-demo-tag-category"
$StoragePolicyTagName = "tkgs-demo-storage"
```
Tanzu 存储策略的设置。

在这些脚本参数设定完成后，可以直接在 Powershell 7 中运行这个脚本。脚本启动后，会提示当前即将部署的环境概括，询问是否继续，回答 Y 之后，就开始全自动的部署了。

[![j3gfFx.png](https://s1.ax1x.com/2022/07/03/j3gfFx.png)](https://imgtu.com/i/j3gfFx)

部署过程根据不同的硬件性能和资源状况大概会历时 30~45 分钟，在我的环境中，整个部署过程历时 40 分钟，整个过程会有一些黄色的 Warning 警告，那些可以忽略，如下图：

[![j3zkff.png](https://s1.ax1x.com/2022/07/03/j3zkff.png)](https://imgtu.com/i/j3zkff)

[![j3zwA1.png](https://s1.ax1x.com/2022/07/03/j3zwA1.png)](https://imgtu.com/i/j3zwA1)

安装完成后，可以通过浏览器访问 vCenter web Client，检查安装完成后各组件的情况。

在脚本安装完成后，我们还需要通过 SSH 连接到 haproxy 这台虚拟机中，进行一些调整，调整可以通过脚本完成。

```shell
#!/bin/bash

touch /etc/sysctl.d/999-tanzu.conf
chmod +x /etc/sysctl.d/999-tanzu.conf

IFS=$'\n'
for i in $(sysctl -a | grep rp_filter | grep 1);
do
    SYSCTL_SETTING=$(echo ${i} | awk '{print $1}')
    # Update live system
    sysctl -w ${SYSCTL_SETTING}=0
    # Persist settings upon reboot
    echo "${SYSCTL_SETTING}=0" >> /etc/sysctl.d/999-tanzu.conf
done
```

另外，默认情况下，Tanzu 在启用 Supervisor Cluster 的时候，会部署 3 个 Supervisor VM，这对于测试环境来说，有点浪费资源，从 vSphere 7.0U3 开始，可以进行一些调整，降低这个资源的需求。我们需要在开启 Supervisor Cluster 之前 ssh 进入 vCenter Appliance 进行调整，方法如下：

- ssh 进入 vCenter Appliance，编辑文件/etc/vmware/wcp/wcpsvc.yaml
- 找到文件中的`minmasters`和`maxmasters`这两个值默认都是 3，我们将这两个值都修改成 1
- 找到文件中`controlplane_vm_disk_provisioning`默认是 thick，可以将这个修改成 thin，节省磁盘空间。
- 修改完成后保存，然后执行`service-control --restart wcp`重启 wcp 服务。

到目前为止，启用 Supervisor Cluster 前的准备都已经完成。

## Part 2. 启用 Tanzu Kubernetes Cluster

### 2.1 启用 Supervisor Cluster

进入 vCenter 后，在主页面导航栏中找到 Worload Management，从这里进去开始 Tanzu Kubernetes 的管理。点击右边的`Get Started`开始创建 Supervisor Cluster。当然这个过程也完全可以通过 Powershell 脚本方式来完成，这个不在本文中展开讨论，本文通过 GUI 图形化界面来完成 Supervisor Cluster 的创建。

[![j8V3yq.png](https://s1.ax1x.com/2022/07/03/j8V3yq.png)](https://imgtu.com/i/j8V3yq)

Supervisor Cluster 的创建会进入一个 8 个步骤的向导。

1. vCenter Server and Network 步骤，这里我们的这个 Lab 没有 NSX，只能选择 VDS。点击 Next 进入下一步。
    [![j8VTnP.png](https://s1.ax1x.com/2022/07/03/j8VTnP.png)](https://imgtu.com/i/j8VTnP)
    
2. Cluster 步骤，选择 tkgs-Cluster，点击 Next 进入下一步。
    [![j8ZfET.png](https://s1.ax1x.com/2022/07/03/j8ZfET.png)](https://imgtu.com/i/j8ZfET)
    
3. Storage 步骤，选择 Control Plane Storage Policy 为`tkgs-demo-storage-policy`。点击 Next 进入下一步。
    [![j8Zv5D.png](https://s1.ax1x.com/2022/07/03/j8Zv5D.png)](https://imgtu.com/i/j8Zv5D)
    
4. Load Balancer 步骤，这里需要填入 haproxy 的相关信息，Name 中填入 tkghaproxy，Load Balancer Type 修改为 HAproxy，Management IP Address 为 Part 1 中配置信息里`$HAProxyManagementIPAddress = "10.10.1.102/24"`的地址，同时需要补充默认的 HAProxy 的服务端口`5556`，Username 为`wcp`，Password 为`P@ssw0rd`，Virtual IP Ranges 为`10.10.3.64-10.10.3.127`。
    HAProxy Management TLS Certificate 的内容，需要 ssh 至 HAProxy 中找到/etc/haproxy/ca.crt 文件获取。
    点击 Next 进入下一步。
    [![j8udMj.png](https://s1.ax1x.com/2022/07/03/j8udMj.png)](https://imgtu.com/i/j8udMj)
    
5. Management Network 步骤，Network Mode 选择 Static，Network 选择 TKGs-MGMT，为 Supervisor 配置一个静态 IP。点击 Next 进入下一步。
    [![j8u5e1.png](https://s1.ax1x.com/2022/07/03/j8u5e1.png)](https://imgtu.com/i/j8u5e1)
    
6. Workload Network 步骤，选择 Network Mode 为 DHCP，Portgroup 为 tkgs-workload。点击 Next 进入下一步。
    [![j8uLSe.png](https://s1.ax1x.com/2022/07/03/j8uLSe.png)](https://imgtu.com/i/j8uLSe)
    
7. Tanzu Kubernetes Grid Service 步骤，选择 Content Library 为 TKG-Content-Library。点击 Next 进入最后一步。
    [![j8uxeI.png](https://s1.ax1x.com/2022/07/03/j8uxeI.png)](https://imgtu.com/i/j8uxeI)
    
8. Review and Confirm 步骤，将 Control Plane Size 从 Small 更改为 Tiny，这时候需要注意的是，还需要回到步骤 6 中，重新点下 Next 按钮，使 Internal Network for Kubernetes Services 从 10.96.0.0/23 自动更新为 10.96.0.0/24。
    [![j8KD6H.png](https://s1.ax1x.com/2022/07/03/j8KD6H.png)](https://imgtu.com/i/j8KD6H)
    
9. 点击 Finish 后，Supervisor Cluster 就开始进入自动部署过程，Workload Management 界面切换成如下图：
    [![j8KIXj.png](https://s1.ax1x.com/2022/07/03/j8KIXj.png)](https://imgtu.com/i/j8KIXj)
    
### 2.2 部署 Tanzu Kubernetes Cluster

等待大约 30 分钟后，就能看到 Tanzu Supervisor Cluster 进入 Running 状态，Control Plane Node 获取到了正确的 ip 地址。
[![j8lO4P.png](https://s1.ax1x.com/2022/07/03/j8lO4P.png)](https://imgtu.com/i/j8lO4P)

1. 这时候我们可以切换到 Namespace 标签卡下，创建 Namespace 了，需要注意的是，这个 Namespace 并非 Kubernetes 的 Namespace，这是 vSphere Tanzu 的 Namespace，我们的 Tanzu Kubernetes Cluster 将会创建在这个 Namespace 之下。
    [![j8114x.png](https://s1.ax1x.com/2022/07/03/j8114x.png)](https://imgtu.com/i/j8114x)
2. 创建完 Namespace，会看到当前这个 Namespace 的 config Status，为了进行接下去的配置，我们需要在 Namespace 的管理中进行 3 项设置，分别是 Permissions、Storage 和 VM Service 设置。首先是 Permissions，我们通过 Add Permissions 按钮添加一个管理员用户。
    [![j81fVs.png](https://s1.ax1x.com/2022/07/03/j81fVs.png)](https://imgtu.com/i/j81fVs)
3. 通过 Add Storage 按钮，为 Namespace 新增数据存储空间。
    [![j81LqJ.png](https://s1.ax1x.com/2022/07/03/j81LqJ.png)](https://imgtu.com/i/j81LqJ)
4. 通过 Add VM Class 按钮，为 Namespace 添加各种规格的 VM，后续的 Kubernetes 的 Node 都会自动根据选择的规格来配置相应的 CPU 和内存。推荐可以将这里默认的 16 个规格都选择上。
    [![j83ise.png](https://s1.ax1x.com/2022/07/03/j83ise.png)](https://imgtu.com/i/j83ise)
5. 通过 Add Content Library 按钮，将 Tanzu Content Library 再次关联上。
    [![j83mJP.png](https://s1.ax1x.com/2022/07/03/j83mJP.png)](https://imgtu.com/i/j83mJP)
6. Namespace 全部配置完成后，如下图，这时候就完成了我们 Tanzu Kubernetes Cluster 创建的所有准备工作了。
    [![j83NWV.png](https://s1.ax1x.com/2022/07/03/j83NWV.png)](https://imgtu.com/i/j83NWV)
7. 在上图的 Status 卡片中，最下面一行，有个 Link to CLI Tools，我们需要点击 Open，打开一个新网页，在这个网页上，我们能够下载到 kubectl vsphere plugins，这个命令行 plugins 将帮助我们管理和使用 Tanzu Kubernetes Cluster。
    [![j83fyD.png](https://s1.ax1x.com/2022/07/03/j83fyD.png)](https://imgtu.com/i/j83fyD)
8. 根据网页上的提示，下载安装完成后，我们来到 CLI 控制台上，使用 CLI 登入我们的 Supervisor Cluster。server 地址为中 Control Plane Node 中看到的 IP 地址。此时一切正确的情况下，命令行会提示输入用户名密码，该用户名密码为步骤 2 中设置的管理员用户。登入后，会看到 Logged in successfully 的信息。

    ```shell
    c:\bin>kubectl-vsphere.exe login --server=10.10.3.65 --insecure-skip-tls-verify
    
    Username: administrator@tkg.local
    KUBECTL_VSPHERE_PASSWORD environment variable is not set. Please enter the         password below
    Password:
    Logged in successfully.
    
    You have access to the following contexts:
       10.10.3.65
       tkgs
    
    If the context you wish to use is not in this list, you may need to try
    logging in again later, or contact your cluster administrator.
    
    To change context, use `kubectl config use-context <workload name>`
    
    c:\bin>
    ```

9. 这时，我们已经成功登入了 Supervisor Cluster，接下去我们会使用以下的 yaml 配置文件来创建 Tanzu Kubernetes Cluster。

    ```yaml
    apiVersion: run.tanzu.vmware.com/v1alpha1
    kind: TanzuKubernetesCluster
    metadata:
      name: sedemo-tkc-01
      namespace: tkgs
    spec:
      distribution:
        version: v1.21
      topology:
        controlPlane:
          class: best-effort-xsmall
          count: 1
          storageClass: tkgs-demo-storage-policy
        workers:
          class: best-effort-small
          count: 2
          storageClass: tkgs-demo-storage-policy
      settings:
        storage:
          classes: ["tkgs-demo-storage-policy"]              #Named PVC storage     classes
          defaultClass: tkgs-demo-storage-policy
    ```

	其中，metadata 下的 name 为创建出来的 cluster 的名字，Namespace 则是 vSphere 中我们刚刚创建的 Namespace 名称。
	spec 下的内容里，distribution 为需要创建的 Kubernetes 的版本。topology-controlplane-class/topology-workers-class 分别是对应步骤 14 中，我们所设定的 VM class 类型，此处分别选择为 best-effort-xsmall 和 best-effort-small。数量分别是 1 和 2。
	运行下面的命令，Tanzu Kubernetes Cluster 会自动在 vCenter 中创建出来：

    ```shell
    c:\bin>kubectl apply -f tkc.ymal
    tanzukubernetescluster.run.tanzu.vmware.com/sedemo-tkc-01 created
    ```

    等待几分钟后，在 vCenter 中，能够看到被创建出来的 3 台 VM，如图。

    [![j8JgWq.png](https://s1.ax1x.com/2022/07/03/j8JgWq.png)](https://imgtu.com/i/j8JgWq)

10. 再次回到 CLI 控制台，执行如下登录命令，我们可以登入到 Tanzu Kubernetes Guest Cluster 中。

    ```shell
    c:\bin>kubectl vsphere login --server=10.10.3.65 --tanzu-kubernetes-cluster-name sedemo-tkc-01 --tanzu-kubernetes-cluster-namespace tkgs --vsphere-username administrator@tkg.local --insecure-skip-tls-verify
    
    KUBECTL_VSPHERE_PASSWORD environment variable is not set. Please enter the password below
    Password:
    Logged in successfully.
    
    You have access to the following contexts:
       10.10.3.65
       sedemo-tkc-01
       tkgs
    
    If the context you wish to use is not in this list, you may need to try
    logging in again later, or contact your cluster administrator.
    
    To change context, use `kubectl config use-context <workload name>`
    ```

至此，我们已经能够正常访问我们的 Kubernetes cluster 了，可以通过所有常规的 kubectl 命令执行所有的管理任务。
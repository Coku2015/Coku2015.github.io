# Veeam Agent for Linux 安装深度分析


## 一。组成和作用
Veeam Agent for Linux（以下简称 VAL）由两部分组成，一个是 Veeam 主程序，另外一个是 Veeamsnap 驱动程序。以 centos/redhat 举例，如果想让 Veeam Agent for Linux 正常工作，一般来说我们需要安装上两个程序，分别是：

```
veeam-<xxxxxxxxxxx>.rpm
veeamsnap-<xxxxxxxxxxx>.rpm
```

其中，Veeamsnap 驱动程序负责系统快照和变化数据块追踪工作，而 Veeam 主程序则负责其他所有相关的工作，当 Veeam 主程序被安装时，依赖包 Veeamsnap 会被自动安装。

## 二。安装过程
在安装时，VAL 需要安装一系列 Linux 依赖包，这些依赖包会自动通过 Linux 的包管理器去 Linux 相关的软件镜像源中搜索，关于这部分，可以参考 [《Veeam Agent for Linux 基础知识》](https://blog.backupnext.cloud/2020/09/Veeam-Linux-Agent-101/)。
大部分比较顺滑的情况，是通过 VBR 进行 VAL 的推送安装，VBR 会自动处理以下的所有安装逻辑，自动判断自动安装最合适的软件包，但是在这背后，有多种特殊情况存在。

### 2.1. dkms 编译安装
对于 Veeamsnap 来说，它是一个 Linux 内核外的驱动程序，对于不同的 Linux 系统，绝大多数情况下无法通用。因此 Veeam 采用了 DKMS 来帮助维护这个驱动程序，安装`veeamsnap-<xxxxxxxxxxx>.rpm`时，会将 Veeamsnap 模块自动添加至 dkms 中并执行编译和安装模块的过程。

关于 DKMS，它是 Dell 创建的开源项目，全称是 Dynamic Kernel Module Support，用于维护内核外的驱动程序，详细内容可以参考 https://www.cnblogs.com/wwang/archive/2011/06/21/2085571.html

要正确安装并编译 Veeamsnap 快照驱动，就需要首先安装并配置 dkms 能正常工作，这部分在绝大多数 Linux 系统中并不算复杂，Veeamsnap 会去自动寻找 dkms 依赖包并把和 dkms 相关的 gcc、make、kernel-header 自动装上，然后使用它们进行安装和编译驱动过程。

### 2.2. 预编译安装包
对于特定的 Linux 发行版，Veeam 还制作了无需编译安装的 Veeamsnap，这些 Veeamsnap 安装包我们称为 kmod-veeamsnap，这些安装包和上面提到的`veeamsnap-<xxxxxxxxxxx>.rpm`功能完全相同，只是在使用时，无需通过 dkms 编译，而是直接使用。这时候 dkms 编译的前提条件和依赖对于 kmod-veeamsnap 就完全不需要了。

已经预编译的系统包括：

- 内核版本 2.6.32-131.0.15 以上的 Radhat 6
- 内核版本 3.10.0-123 以上的 CentOS/Radhat 7.0-7.9
- CentOS/Radhat 8
- SLES
- openSUSE

这些系统的 kmod 安装包都可以在 http://repository.veeam.com/.private/rpm 中找到。

需要注意的是，因为是预编译的软件包，对于不同的系统需要选择不同的驱动，这时候这个选择 Veeam 需要借助 python3 脚本来完成，这时候 Linux 系统需要依赖 Python3。在安装`kmod-veeamsnap--<xxxxxxxxxxx>.rpm`时，VAL 会自动寻找 python3 依赖包，安装并使用，最终完成 kmod-veeamsnap 的安装。

### 2.3. 启用安全引导（UEFI 的 Secure  Boot）
对于启用了 UEFI 安全引导的 Linux 系统，要使用 kmod-veeamsnap，需要将 kmod-veeamsnap 的证书导入到 UEFI 控制台中。这个证书可以先使用 veeamsnap-ueficert-5.0.1.4493-1.noarch.rpm 这个包获取，具体步骤如下：
1. 下载并安装 veeamsnap-ueficert-5.0.1.4493-1.noarch.rpm，比如 Redhat8：
```shell
curl -O http://repository.veeam.com/.private/rpm/el/8/x86_64/veeamsnap-ueficert-5.0.1.4493-1.noarch.rpm
rpm -ivh veeamsnap-ueficert*
```

2. 执行导入命令
```shell
mokutil --import veeamsnap-ueficert.crt
```
3. 重启 Linux 系统进入 UEFI Bios 控制台里，去分配下这个证书

后续的 kmod-veeamsnap 安装过程和 2.2 中没任何区别。

### 2.4. 😂😂不使用 Veeamsnap

以上这些 veeamsnap 都没条件使用时，从 VAL 5.0.1 起，Veeam 提供 snapless 的备份方式，提供了不依赖 veeamsnap 工作的 VAL 主程序，比如 Redhat 8：
http://repository.veeam.com/.private/rpm/el/8/x86_64/veeam-nosnap-5.0.1.4493-1.el8.x86_64.rpm

这个程序无法支持快照备份，只能通过 File level snapshot-less 的方式进行文件备份，如下图：

![](https://helpcenter.veeam.com/docs/agentforlinux/userguide/images/backup_job_mode.png)

当然，在 VBR 中也有同样的选项：

![](https://helpcenter.veeam.com/docs/backup/agents/images/agent_job_mode_linux.png)

这个主程序可以直接单独安装，在安装的时候它不会再去要求 veeamsnap 的依赖，而其他的常规依赖包依然是通过 Linux 包管理器自动获取。

以上就是今天的内容，希望对大家安装 VAL 有帮助。


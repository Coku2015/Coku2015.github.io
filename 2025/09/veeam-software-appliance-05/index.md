# 把复杂留给 Veeam：Infrastructure Appliance 上手指南


Veeam 在 v13 中不仅把备份主服务器做成了预加固的 Software Appliance，同时也推出了专门用于承载角色服务的 **Veeam Infrastructure Appliance**。如果把 Software Appliance 看作“指挥中心”，那么 Infrastructure Appliance 更像是一台预配置、上手即用的“任务执行单位”：它为 Proxy、Mount Server、Hardened Repository 等角色提供了一个统一、受控并且合规的运行环境。

## 一、为什么选用 Infrastructure Appliance

选择 Infrastructure Appliance 的理由可以归结为三句话：**快速、简单、安全**。Veeam 基于 Rocky 9 构建的 JeOS（Just enough OS）镜像，把操作系统和运行时依赖做成了受控的、最小化的分发单元。你部署一个 Infrastructure Appliance，等于把一台仅用于备份角色的、按最佳实践调优过的 Linux 服务器直接“拿来即用”。

从实务角度看，这带来的好处很直接：部署不再受传统操作系统安装和补丁管理的复杂性所拖累；角色支持覆盖 Proxy、Mount Server、Gateway Server、Hardened Repository 等常见组件；而在安全合规上，Appliance 出厂即内置 DISA STIG 与 FIPS 策略、默认启用 UEFI Secure Boot，并通过证书认证替代开放式 SSH 登录，显著缩减攻击面。对分布式或多站点部署而言，Infrastructure Appliance 能快速扩展执行节点的能力，并把维护复杂度降到最低。



## 二、部署与配置：一步到位的体验

在部署 Veeam Infrastructure Appliance 之前，需要先确认目标资源满足最基本的要求。建议的最小配置常见如下：
- 四核 x86-64 CPU 或 vCPU
- 8 GB RAM
- 至少两个 120 GiB 的磁盘，系统盘推荐 SSD/NVMe（系统盘必须是容量最小的盘）
- 1 Gbps 或更高的网络带宽。 

若在 vSphere 中部署，请把虚拟机 OS 类型设为 RHEL 9（或兼容的选项），以便与 Rocky Linux 9 的内核/驱动匹配。



### 安装

实际部署流程并不复杂：下载官方提供的 ISO，将其挂载到目标主机或虚拟机并引导启动，安装菜单会列出 Infrastructure Appliance 的多个安装选项（含对 iSCSI & NVMe/TCP 的支持以及 Hardened Repository 角色）。

![Xnip2025-09-13_19-05-11](https://s2.loli.net/2025/09/22/sxE4q1Bbhlj6VtQ.png)

接着选择 Install（或在恢复场景选择 Reinstall），等待自动化步骤完成并重启，系统随后会进入初始化向导。

![Xnip2025-09-13_19-05-40](https://s2.loli.net/2025/09/22/lOjAPiJCwWIthDH.png)

整个过程和 Veeam Software Appliance 几乎完全一致，[具体可以参考之前的帖子](https://blog.backupnext.cloud/2025/09/Veeam-Software-Appliance-02/)。初始化配置完成后，可直接通过 Host Management 的 WebUI 或 TUI 进行后续管理：包括网络与主机名设置、时间同步（NTP/NTS）、证书与访问控制配置等。对于没有 Linux 经验的用户，这种“向导式”的体验大幅降低了上手门槛，没有 Linux 经验都能轻松通过 Host Management WebUI 和 TUI 完成所有必要的操作。


### 在 VBR 中添加普通受管理的 Linux 角色服务器

通过 Veeam Infrastructure Appliance ISO 安装完成后，需要到 VBR 中添加，Backup Infrastructure 下找到 Managed Servers 中找到 Linux Server 的添加向导，选择 Add New 就行了。在向导的 Access 步骤中，和以往不一样，直接选择 `Connect using certificate-based authentication(recommand)`即可，这个选项不需要打开 SSH 端口，也无需输入用户名密码，而是直接通过 Veeam 自有的协议和证书进行连接。

![Xnip2025-09-22_18-19-23](https://s2.loli.net/2025/09/22/P7ZvYKMlGgihCuN.png)

其他步骤，没有任何改变，和以往老版本的配置完全一致。



### 在 VBR 中配置 Hardened Repository

对于 Hardened Repository，添加 Linux 角色服务器的过程完全一致，但是在 Server 的目录呈现部分，Veeam 对于 Linux 系统的路径做了处理，仅将 Hardened Repository 中唯一可以存放数据的路径呈现给客户：

![Xnip2025-09-22_18-58-29](https://s2.loli.net/2025/09/22/efd2PLKaJHRMAZi.png)

在文件夹设置中，一样只列出了仅限备份可选的文件夹，当然`New Folder`的选项还是保留了，用户可以在这个设定 Folder 的时候创建新的文件夹，选择新的文件夹。

![Xnip2025-09-22_19-03-30](https://s2.loli.net/2025/09/22/ZViAF7cN9Oldywp.png)

其他的设置，和之前版本的 Hardened Repository 保持一致。



## 三、实践中的最佳做法与安全设计原则

### 最佳实践
把 Appliance 当作“黑盒”并不等于把它丢进机房就完事了，要让它稳定跑起来，实际上只需要遵循以下这些：

**角色与资源匹配：**在部署前先确认该节点要承担的角色（Proxy、Mount Server、Hardened Repository 等），并据此划分资源。举例来说，Proxy 的计算需求会随并发任务上升而增加；建议至少 2 核 CPU 起步，并按每两个并发任务额外增加 1 核；内存从 2 GB 起跳，且对 I/O 敏感的 Repository 应优先选用企业级 SSD/NVMe 和硬件 RAID，当然 SATA 盘作为备份存储性价比之王，也是非常推荐的。

**硬件和固件兼容：** Infrastructure Appliance 要求启用 UEFI Secure Boot；对于 Hardened Repository，推荐硬件 RAID 控制器并避免使用一些不受支持的虚拟化或软件 RAID 方案。提前确认固件/BIOS 与 NVMe 控制器兼容性，能够避免后续无法识别系统盘或性能异常的问题。

**网络与时间：** 建议为 Appliance 使用静态 IP，并配置至少三台以上可信的 NTP/NTS 源，确保时间同步稳定；时间漂移会导致 MFA、证书验证或计划任务出现异常。

**集中化管理与配对：**初始配置完成后应立刻通过 Backup Console 把 Appliance 配对到 Veeam Backup & Replication（VBR）管理下，纳入统一策略、日志与补丁管理体系；这样可以保证策略一致性与便于后续审计。同时，还可以在配置完成后，关闭 Host Management WebUI 的访问，进一步减少系统的受攻击面。

**保持 JeOS 原设。** JeOS 被设计为“只装必要组件”的最小系统，内置 DISA STIG、FIPS 与自动更新机制。擅自修改底层系统设置（例如随意开启额外服务、手动更改内核参数或使用包管理器随意升级）会带来风险：可能导致系统无法正常接受官方更新、失去合规性，甚至影响 VBR 对该节点的识别与支持。因此，除非官方指示或有充分验证，建议只通过 Host Management 或 VBR 提供的接口进行所有配置变更。目前，Veeam 官网已经更新了[KB4772](https://www.veeam.com/kb4772) 来明确说明这个问题。

### 安全特性
Infrastructure Appliance 的安全与更新设计是其核心特点之一。系统默认启用多项安全控制措施，例如 UEFI Secure Boot、DISA STIG 与 FIPS 策略，Host Management 提供对证书、访问请求、基础设施锁定与审批流程的集中化控制；其中 Security Officer 的审批机制可用于启用 SSH、授权临时 root 访问、重置用户密码、批准配对请求等敏感操作，从而实现内置的“四眼”审计流程。

更新方面，Appliance 使用 Veeam Updater 组件进行集中化的补丁管理。管理员可以在每个 Appliance 的 Host Management 中设定更新策略，也可以通过 Veeam Backup & Replication 的备份控制台集中管理所有 Appliance 的更新。系统会对更新包做数字签名与校验，确保来源可信、避免篡改。所有更新操作与日志均可在控制台中查看与导出，便于合规审计。

此外，Appliance 还提供一套应急维护功能：可以通过 Recovery LiveCD 的 ISO 来进行应急系统修复和维护。


## 四、结语：把复杂留给 Veeam，把安全留给你

Veeam Infrastructure Appliance 的价值并非只在“省事”，而在于把基础设施中的重复性、风险性工作封装成受控、可审计的流程，让运维把注意力放在架构与策略上，而不是日常的系统修补与兼容调试。把 Software Appliance 作为中枢、Infrastructure Appliance 作为可复制的执行单元，你可以在多站点、分布式场景下快速扩容、统一管理并保持合规与安全。

如果你刚开始规划和试用新版本，建议先在测试环境中演练几次完整的安装与配对流程：明确每台 Appliance 的角色、调整资源配比、验证时间与网络配置，然后把这些步骤固化成标准操作流程。这样既能享受 Appliance 带来的“即装即用”，也能把长期运维的复杂性和风险降到最低。


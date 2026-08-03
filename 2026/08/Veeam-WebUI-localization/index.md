# Veeam Backup & Replication v13.1 Web UI 简体中文包发布：让新一代 VBR WebUI 真正好用起来



差不多 7 年前，我做过一个 Chrome 插件，把 Veeam Enterprise Manager 的 Web 界面汉化成了中文。

那时候中文用户想要个中文界面，是真的难。插件做完扔出去，没想到后来被 Veeam R&D 采纳，正式做进了 EM 的中文版。

结果 7 年过去，Veeam 的新一代 Web UI 来了，中文又没了。

这一次情况有点不一样。v13.1 的 Web UI 已经不是当年那个“看看状态、点点按钮”的企业管理器页面，它将会是下一代Veeam备份服务器的操作入口，日常运维都得靠它。可它内置的语言里，依然没有简体中文。

原因也不复杂。Veeam 海外和国内的市场策略，决定了官方大概率不会再支持简体中文语言。然而这对现在的AI来说，根本不是个事。我决定周末自己动手做一个 Veeam Backup & Replication Web UI 的简体中文本地化包。

项目地址：

[https://github.com/Coku2015/Veeam-Chinese-UI-Packages](https://github.com/Coku2015/Veeam-Chinese-UI-Packages)

当前支持版本：

```text
Veeam Backup & Replication Web UI 13.1.0.411
```

## 先说清楚：v13.1 的 Web UI 为什么值得单独关注

如果过去你一直把 Veeam 的 Windows Console 当主力，v13.1 之后，Web UI 的地位真的不一样了。

它已经不是初代的试验品了。跨平台恢复、多虚拟化平台管理、Agent 管理、非结构化数据保护、恶意软件检测控制平面、RBAC，这些重活正在一项项搬进浏览器。下面挑几个关键的说。

### 1. Instant Recovery 进了 Web UI，而且能跨平台

v13.1 里，Web UI 支持从镜像级备份直接发起 Instant Recovery，覆盖的目标平台比以前多得多。

别小看这个变化。管理员可以在同一个浏览器界面里处理跨平台恢复，不用在 Console、插件和各种恢复入口之间来回切。

今天很多企业早就不是单一虚拟化平台了。VMware、Hyper-V、Nutanix AHV、Proxmox VE 经常同时存在。恢复能力要是还绑死在某个单一管理工具里，运维体验必然是割的。Web UI 正在往“统一恢复入口”这个方向走。

### 2. AHV 和 Proxmox VE 的 Web UI 覆盖大幅补齐

v13.1 对多虚拟化平台的支持相当激进。除了传统的 VMware vSphere 和 Hyper-V，Veeam 还在持续扩展 Nutanix AHV、Proxmox VE，并引入了 Sangfor aSV、Citrix XenServer、XCP-ng、Platform9、VergeOS 等平台能力，当然后面这些平台暂时还没进入WebUI的统一管理。

更关键的是，AHV 和 Proxmox VE 的备份作业、还原操作、基础架构管理，在 Web UI 里获得了更完整的覆盖。

这对正在做虚拟化平台迁移、替代或混合部署的团队很重要：Web UI 开始变成跨虚拟化平台的统一操作平面。

### 3. Agent 管理和远程裸机恢复进了 Web UI

v13.1 继续扩展 Agent 场景的 Web UI 能力，包括保护组、Windows/Linux Agent 备份作业管理，还有常见的恢复操作。

Veeam Agent for Windows 的 Remote Bare Metal Recovery 也能通过 Web UI 发起和管理了。终端用户只要把机器启动到预配置的恢复环境，管理员就能在 Web UI 里跑完后续恢复流程。

对分支机构、远程办公、无人值守站点来说，这个特别实用。过去这类操作往往得有人现场盯着；现在远程恢复让管理员可以更集中地把活干完。

### 4. 非结构化数据保护完整进入 Web UI

文件共享、对象存储这些非结构化数据源，相关的备份作业、监控和恢复操作，在 v13.1 里也获得了完整的 Web UI 覆盖。

非结构化数据通常体量大、变化频繁、对象类型杂。把这部分管理能力放进 Web UI，管理员就能在一个界面里看数据源、作业状态和恢复操作，不用再多个入口来回切。

### 5. Malware Detection 控制平面进了 Web UI

v13.1 的恶意软件检测能力进一步增强，完整控制平面进了 Web UI，包括事件管理、细粒度排除规则，还有端到端的调查工作流。

这下 Web UI 不只是“备份作业管理界面”，也开始管安全运营了。检测结果、策略调整、调查和响应，都能在一个界面里完成。

勒索软件已经是备份系统必须正面应对的现实。这一点，价值很直接。

### 6. Web UI 自己也越来越像现代管理入口

除了上面这些“重活”，v13.1 的 Web UI 还带来不少直接影响日常体验的变化：

- 默认主题刷新
- 用户级个性化设置
- 扩展语言支持
- Veeam ONE 告警面板集成
- 邮件服务器和通知设置可以直接在 Web UI 里配
- Backup Copy Job 详情视图增强
- Microsoft Active Directory 和 Microsoft SQL Server 的应用项级恢复进入 Web UI
- 完整高级 RBAC，包括自定义角色、作用域可见性和集中角色管理
- 支持创建空作业，先把作业模板建好，再后续添加保护对象

趋势很清楚：VBR Web UI 正在变成一个更轻量、更统一的入口，更适合日常运维和跨平台恢复。

## 简体中文包：我们补上了这块拼图

Veeam v13.1 Web UI 内置了 English、German、French、Japanese，没有简体中文。

对中文管理员来说，这事很糟糕，体验感极差。能力已经这么完整了，要是能用熟悉的中文界面操作，学习、演示、交付、培训、日常运维都会顺很多。

所以我做了这个非官方的简体中文本地化包。

目标很明确：

- 在原有语言基础上增加“简体中文”
- 不覆盖原版多语言 UI，保留 English、German、French、Japanese
- 用 Veeam 备份领域的专业中文术语
- 同时支持两种平台：Windows Backup Server 和 Linux Appliance
- 支持一键安装，安装前自动备份官方原版语言文件；也支持一键卸载还原，方便后续升级，不影响官方售后支持

## 使用方法

### Linux Appliance 安装

先进入 Veeam Appliance Console，选择：

```text
Enable SSH server
```

![Xnip2026-08-02_19-21-44](https://files.seeusercontent.com/2026/08/02/7quO/Xnip2026-08-02_19-21-44.jpg)



然后在本机用 `scp` 把安装包传到 Appliance：

```bash
scp VeeamWebUiZhCN-13.1.0.411-linux.tar.gz veeamadmin@vbrvsaip:/tmp/
```

其中 `vbrvsaip` 换成你 Veeam Backup Server / Linux Appliance 的主机名或 IP。

回到 Veeam Appliance Console，选择：

```text
Enter shell
```

进入 Shell 后执行：

```bash
cd /tmp
tar xvf VeeamWebUiZhCN-13.1.0.411-linux.tar.gz
bash VeeamWebUiZhCN-13.1.0.411/linux/install-veeam-webui-zh-cn.sh
```

![Xnip2026-08-02_19-24-46](https://files.seeusercontent.com/2026/08/02/Ypm9/Xnip2026-08-02_19-24-46.jpg)



执行完不用重启任何 VBR 服务，回到网页 Web UI，刷新一下就能看到中文界面。

卸载还原：

```bash
cd /tmp
bash VeeamWebUiZhCN-13.1.0.411/linux/uninstall-veeam-webui-zh-cn.sh
```

### Windows 安装

在 Veeam Backup Server 上，以管理员身份打开 PowerShell：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd C:\Users\Administrator\Downloads\VeeamWebUiZhCN-13.1.0.411\windows
.\Install-VeeamWebUiZhCN.ps1
```

卸载还原：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd C:\Users\Administrator\Downloads\VeeamWebUiZhCN-13.1.0.411\windows
.\Uninstall-VeeamWebUiZhCN.ps1
```

装完之后，浏览器强制刷新一下，然后在语言菜单里选“简体中文”。

## 中文 UI 效果展示

### Web UI 简体中文界面

![Xnip2026-08-02_17-27-51](https://files.seeusercontent.com/2026/08/02/Bjy8/Xnip2026-08-02_17-27-51.jpg)



![Xnip2026-08-02_17-28-09](https://files.seeusercontent.com/2026/08/02/Tx2d/Xnip2026-08-02_17-28-09.jpg)

## 注意事项

这个本地化包是非官方项目，不是 Veeam 官方 hotfix。

安装前请确认 Web UI build 和中文包版本一致。建议在升级 Veeam 前先卸载中文包，升级完成后再装匹配新 build 的版本。

如果安装脚本提示 hash 不匹配，说明目标文件可能已经升级或被改过，不建议强行安装不匹配的版本。

## 结语

7 年前那个汉化插件，最后变成了官方 EM 中文版。

新一代 Web UI 上线，中文又缺位了。市场策略的事我们左右不了，但能自己动手补上，总比干等着强。

v13.1 是个面向多虚拟化平台、多工作负载和现代化运维体验的重要版本，Web UI 在这版里扛起了更多核心能力，也更适合当日常操作、恢复和监控的统一入口。

希望这个简体中文包，能让更多中文用户更顺手地用上 v13.1 的新 Web UI。也欢迎下载、测试、反馈，后续一起把更多 Veeam 产品的中文 UI 补齐。

项目地址：

[https://github.com/Coku2015/Veeam-Chinese-UI-Packages](https://github.com/Coku2015/Veeam-Chinese-UI-Packages)

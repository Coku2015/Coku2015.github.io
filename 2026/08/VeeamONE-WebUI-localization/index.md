# Veeam ONE v13.1 Web UI 简体中文包发布：让监控和分析也用上中文


上周发了 VBR Web UI 的简体中文包。

这一篇，轮到 Veeam ONE。

Veeam 这套体系里，VBR 负责干活——备份、复制、恢复。Veeam ONE 负责盯着——监控、分析、报警、安全态势。两个凑在一起，才是完整的运维闭环。

而 Veeam ONE 的 Web UI，同样没有简体中文。

所以这周，我把它也补上了。

项目地址还是同一个：

[https://github.com/Coku2015/Veeam-Chinese-UI-Packages](https://github.com/Coku2015/Veeam-Chinese-UI-Packages)

当前支持版本：

```text
Veeam ONE Web UI 13.1.0.7034
```

## Veeam ONE：备份体系里“盯着看”的那一个

很多人对 Veeam 的印象停留在 VBR。但实际上，Veeam 生态里有个专门负责监控和分析的产品，就是 Veeam ONE。

它干的事和 VBR 不一样。VBR 是去把数据备份下来、恢复回去。Veeam ONE 则是站在旁边，盯着整个备份基础架构和虚拟化平台，告诉你哪里有风险、哪里该优化、容量还剩多少、有没有可疑活动。

具体来说，Veeam ONE 主要管这几块：

- **监控**：盯着 Veeam 备份服务器、仓库、代理这些组件，也盯着 VMware、Hyper-V 等虚拟化平台的资源。
- **告警**：内置大量告警规则，备份失败、仓库快满、作业超时，都会及时提醒。
- **分析**：v13 引入了全新的 Veeam Analytics Service，监控后端更可扩展、更可靠，跨混合平台给出一致的异常检测。
- **报表**：容量规划、合规审计这类长期看得见的输出。
- **安全态势**：Threat Center 把备份系统的零信任状态和安全合规汇总成评分和调查工作流。

VBR 是手，Veeam ONE 是眼。

## 这一版的 Web UI，正在变成主入口

和 VBR 一样，Veeam ONE 也在往 Web UI 走。

v13 这一代，Veeam ONE 的 Web UI 地位明显提升，不再是装完顺带看一眼的附属页面。监控、告警、仪表盘、Threat Center 这些日常要用的能力，越来越集中在 Web UI 里完成。REST API 也跟上了，方便和外部系统集成。

VBR v13.1 那边还专门把 Veeam ONE 的告警面板集成进了 VBR Web UI——这也说明两个产品的 Web UI 本来就是打通的，不是各管各的。

既然是天天要盯的入口，中文界面就实打实有用：告警一眼看懂，分析不用猜，给老板演示、给新人培训都轻松不少。

## 简体中文包：让这套监控分析平面说中文

Veeam ONE Web UI 内置了 English、Japanese、Deutsch、Français 等语言，同样没有简体中文。

所以我们做了这个非官方中文包。目标跟上次 VBR 包一致：

- 在原有语言基础上增加“简体中文”
- 不覆盖原版多语言，保留 English、Japanese、Deutsch、Français
- 使用 Veeam 监控和分析领域的专业中文术语
- 一键安装，安装前自动备份官方原版语言文件
- 一键卸载并还原，不影响官方售后支持

装上之后，登录页和主界面都会出现 `zh-CN (简体中文)` 这个选项，选中即可。

## 一个额外的“顺带”好处

这个包还有个值得一提的地方。

Veeam ONE 带有远程插件资源，专门给 Analytics 和 Threat Center 用。VBR 连上 Veeam ONE 之后，VBR Web UI 里的“分析”页面，加载的就是 Veeam ONE 这些资源。

所以装了这个中文包，VBR 那边的分析页也会跟着变中文——前提是 VBR 真的连了 Veeam ONE。

没连的话，VBR 不会加载这些远程资源，原有页面不会有任何变化，两边互不影响。

这也是为什么上周的 VBR 包没法单独搞定那个分析页：那块本来就不归 VBR 管。两个包配合起来，才算覆盖完整。

> [!note] 
> VBR的中文包，如果要配合VeeamONE的，需要重新下载本周新发布的，才能支持分析模块中文版。


## 使用方法

在 Veeam ONE Server 上，以管理员身份打开 PowerShell：

```powershell
Invoke-WebRequest -Uri "https://github.com/Coku2015/Veeam-Chinese-UI-Packages/raw/main/VeeamONE%20WebUI%20Chinese%20Package/VeeamONE-13.1.0.7034/VeeamOneWebUiZhCN-13.1.0.7034-windows.zip" -OutFile "$env:USERPROFILE\Downloads\VeeamOneWebUiZhCN-13.1.0.7034-windows.zip"
Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\VeeamOneWebUiZhCN-13.1.0.7034-windows.zip" -DestinationPath "$env:USERPROFILE\Downloads" -Force
Set-ExecutionPolicy -Scope Process Bypass
cd "$env:USERPROFILE\Downloads\VeeamOneWebUiZhCN-13.1.0.7034\windows"
.\Install-VeeamOneWebUiZhCN.ps1
```

卸载还原：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd "$env:USERPROFILE\Downloads\VeeamOneWebUiZhCN-13.1.0.7034\windows"
.\Uninstall-VeeamOneWebUiZhCN.ps1
```

安装完成后，对登录页和 Web UI 各做一次 `Ctrl+F5` 强制刷新，在语言菜单里选择 `zh-CN (简体中文)`。

## 中文 UI 效果展示

首页主界面

![Xnip2026-08-09_20-38-13](https://files.seeusercontent.com/2026/08/09/gr4F/Xnip2026-08-09_20-38-13.jpg)

### 登录页语言选择

![Xnip2026-08-09_20-37-33](https://files.seeusercontent.com/2026/08/09/so0Y/Xnip2026-08-09_20-37-33.jpg)

### Veeam ONE 警报预览

Veeam ONE 警报预览

![Xnip2026-08-09_20-39-34](https://files.seeusercontent.com/2026/08/09/r0Ns/Xnip2026-08-09_20-39-34.jpg)

### 配置页面

![Xnip2026-08-09_20-40-12](https://files.seeusercontent.com/2026/08/09/xN6o/Xnip2026-08-09_20-40-12.jpg)

### VBR 连接 Veeam ONE 后，分析页变中文

VBR 分析页中文

![Xnip2026-08-09_20-51-45](https://files.seeusercontent.com/2026/08/09/mq6F/Xnip2026-08-09_20-51-45.jpg)



## 注意事项

这个本地化包是非官方项目，不是 Veeam 官方 hotfix。

安装前请确认 Veeam ONE 的 Web UI build 与中文包版本一致（13.1.0.7034）。建议在升级 Veeam ONE 前先卸载中文包，升级完成后再安装匹配新 build 的版本。

安装脚本会备份被修改的 Web UI 静态文件，卸载脚本会校验并还原。

如果安装脚本提示 hash 不匹配，说明 Veeam ONE 的文件可能已经升级或被修改，请不要强行安装不匹配的版本。

## 结语

上周补了 VBR，这周补 Veeam ONE。

Veeam 这套备份体系，“做”和“看”两边都该有顺手的中文界面。VBR 负责干活，Veeam ONE 负责盯着，两个 Web UI 中文包加起来，才算把日常运维最常盯的两个入口都照顾到了。

而因为两个产品的 Web UI 本来就是打通的，Veeam ONE 这个包还能顺带让 VBR 的分析页也说上中文。

希望这个包能帮到更多盯着监控大屏的中文管理员。

欢迎下载、测试、反馈。项目地址：

[https://github.com/Coku2015/Veeam-Chinese-UI-Packages](https://github.com/Coku2015/Veeam-Chinese-UI-Packages)

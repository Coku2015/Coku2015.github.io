---
layout: post
title: 你必须知道的：Veeam Software Appliance 全新的管理使用方法
tags: VBR
---

在前两期里，我们一起完成了 Veeam Software Appliance 的“落地”——从下载 ISO、制作启动盘到自动化安装，再到最初的 TUI 初始化和基本管理，很多小伙伴已经顺利把这台“备份小钢炮”跑了起来。 

但当系统真正跑起来之后，新的问题也随之而来： 
- Veeam Software Appliance 到底有哪些新功能？ 
- 这个基于 Linux 的 Appliance 和以前的 Windows 版有什么不同？ 
- WebUI 和 TUI 两个控制台该用哪个？ 
- 用户管理如何完成？ 
- 升级更新又该怎么做？ 

本期，我们就从这些大家最关心的问题入手，带你熟悉 **Veeam Software Appliance  新功能** 和 **Appliance 独有的管理方式**，并且手把手梳理 **两个主机控制台 UI 的使用场景**，让你在安装完之后也能用得顺手、管得安心。

## 开箱即用，安全默认 

说到 Veeam Software Appliance，最直观的感受就是：**不用再担心安全加固和补丁维护**。以往我们习惯了在 Windows 上安装 Veeam，再自己做补丁、调权限、配防火墙；而 Appliance 则是 **出厂就预先加固好的 Linux 平台**，系统内核、权限模型、服务状态都按最佳实践配置完毕，从安装那一刻起就是“安全默认”（Secure-by-Default）。 

更重要的是，这种内置的安全和简化管理不仅体现在系统管理层面，还延伸到用户体系访问控制和自动化升级和更新等方面。换句话说，你不需要成为 Linux 安全专家，也能在 Veeam Software Appliance 上用到这些“硬核”的安全特性。


## Appliance 独有的管理方式

很多小伙伴装好 Veeam Software Appliance 后，第一反应还是像管理传统 Linux 服务器那样，想着能不能 ssh 进去改配置、自己跑 yum update。其实大可不必——也不建议这样做。

Appliance 对底层 Linux 已经做了深度封装和加固，系统内核、软件包、服务依赖都按 Veeam 的最佳实践打包好了。你无需、也不应该手动改动这些底层组件，而是要通过它自带的管理工具和界面来操作：

- 平时的网络、主机名、时区、服务启停等基础设置，直接在 Host Management Web UI 或 TUI 中完成，避免自己去编辑系统文件；

![Xnip2025-09-07_20-03-25](https://s2.loli.net/2025/09/07/Gt4EvqTSY9n7Ouk.png)

- 如果确实要调整 Veeam 相关的配置文件，比如修改`/etc/hosts`文件，可以借助 Import / Export Configuration 功能：在 Logs and Services → Host Configuration 下导出配置、修改后再导入，这样系统才能正确识别并应用；

![Xnip2025-09-07_20-05-06](https://s2.loli.net/2025/09/07/NBUFalOxVfsmY7d.png)

- 升级或打补丁也要用 Appliance 内置的更新机制，不要用 yum 之类的包管理器手动更新。

这样既能保证系统稳定和安全，又能在需要调整时保持“官方支持”的姿势，一举两得。

### Host Management：WebUI 与 TUI 功能对比表

Appliance 有着独特的管理方式，两个 UI 需要交替使用，功能一览表如下：

| 功能类别 | 操作项 | WebUI 支持 | TUI 支持 |
|----------|--------|------------|----------|
| **网络配置** | 修改主机名 | ✅ | ✅ |
|            | 管理域设置 | ✅ | ❌ |
|            | 配置网络接口 | ✅ | ✅ |
|            | 配置 HTTP/HTTPS 代理 | ❌ | ✅ |
| **时间设置** | 修改时区、配置 NTP 时间服务器 | ✅ | ✅ |
| **远程访问** | 禁用 WebUI | ✅ | ✅ |
|            | 启用 WebUI | ❌ | ✅ |
|            | 启用/禁用 SSH | ✅ | ✅ |
|            | 打开 root shell | ❌ | ✅ |
| **用户与权限** | 添加用户、编辑用户、重置用户密码 | ✅ | ❌ |
|            | 修改 Host Admin 密码 | ✅ | ✅ |
|            | 解锁用户、启用/禁用 MFA、重置 MFA | ✅ | ❌ |
|            | 重置 Security Officer 密码恢复令牌 | ✅ | ❌ |
| **备份基础设施** | 启用远程数据收集、启用/禁用基础设施锁定、启用托管服务器配对 | ✅ | ❌ |
| **更新管理** | 配置更新策略、检查更新、安装更新、查看更新历史 | ✅ | ❌ |
| **系统维护** | 启动/停止/重启 Veeam 服务 | ✅ | ❌ |
|            | 重启 Veeam Appliance | ✅ | ✅ |
|            | 查看/导出事件日志、导入/导出配置文件、下载日志包 | ✅ | ❌ |
|            | 查看证书指纹 | ✅ | ✅ |
|            | 生成新 WebUI 证书 | ❌ | ✅ |
| **安全控制** | 审批授权请求、管理配置备份口令 | ✅ | ❌ |



## 重构的用户体系

在传统的 Veeam Backup & Replication（以下简称 VBR）中，用户权限管理主要依赖于 Windows 本地或域账户，并通过 VBR 控制台进行角色分配。而在 Veeam Software Appliance 中，用户体系被重新设计，**Host Management 层引入了独立的用户角色模型**，实现了更细致的安全隔离与运维控制。

### 一、Host Management 用户角色体系概览

Veeam Software Appliance  的 Host Management 控制台（WebUI）内置了四类用户角色，每类角色对应不同的管理职责：

| 角色名称 | 描述 | 使用场景 |
|----------|------|----------|
| **Host Administrator（veeamadmin）** | 拥有完整主机管理权限，可访问 WebUI 与 TUI，执行网络配置、用户管理、更新维护等操作。 | 适用于负责 Appliance 运维的系统管理员 |
| **Security Officer（veeamso）** | 专注于安全控制，仅可访问 WebUI，负责审批敏感操作、管理密码恢复令牌、配置备份口令等。 | 适用于安全审计、合规管理人员 |
| **User** | 权限受限，无法访问 Host Management 控制台，仅用于标识普通用户身份。 | 适用于需要登录但无主机管理权限的用户 |
| **Service Account**| 用于系统服务或自动化任务，权限受限，不支持 MFA。 | 适用于脚本、API 调用或集成服务账号 ||

> ⚠️ 默认账户 `veeamadmin` 与 `veeamso` 不可删除，建议在部署完成后立即修改密码并启用 MFA。


### 二、用户创建与角色分配流程

用户创建需通过 WebUI 完成，流程如下：

1. 登录 Veeam Host Management WebUI。
2. 进入主菜单 `Users and Roles`。
3. 点击 `Add`，填写用户名、密码、描述。
4. 选择角色（每个用户仅能分配一个角色）。
5. 根据角色类型启用或跳过 MFA 配置。
6. 审核信息并点击 `Finish` 完成创建。

> 密码必须满足复杂度要求：至少 15 位，包含大小写字母、数字、特殊字符，且同类字符不得连续超过 3 个。
> 


### 三、角色使用建议与场景匹配

为确保系统安全与职责清晰，建议按以下场景分配用户角色：

- **Host Administrator**：用于日常运维人员，负责主机配置、更新、用户管理等操作。
- **Security Officer**：用于安全审计人员，负责审批敏感操作、管理配置备份口令等。
- **User**：用于需要登录但无管理权限的普通用户，例如查看日志或接收通知。
- **Service Account**：用于自动化脚本、API 调用等场景，建议禁用 MFA 并限制权限。

> 📌 注意：Host Administrator 与 Security Officer 的职责分离是 Veeam Software Appliance  安全架构的核心，建议启用“四眼审批”机制，确保敏感操作需双人确认。


### 四、用户管理操作能力

| 操作项 | Host Administrator | Security Officer |
|--------|--------------------|------------------|
| 添加/编辑/删除用户 | ✅ | ❌ |
| 重置密码 | ✅ | ✅（需审批） |
| 解锁用户 | ✅ | ❌ |
| 启用/禁用 MFA | ✅ | ❌ |
| 审批敏感操作（如 SSH、root shell） | ❌ | ✅ |
| 管理配置备份口令 | ❌ | ✅ |


### 五、MFA 与安全官机制

- **MFA 支持**：基于 TOTP，兼容主流认证器（如 Microsoft Authenticator）。
- **Security Officer 登录流程**：
  - 首次登录需设置强密码并启用 MFA。
  - 系统生成恢复令牌，用于未来敏感操作审批。
  - 该令牌必须妥善保存，遗失将无法恢复。



### 六、与 VBR RBAC 的区别说明

Veeam Software Appliance  的 Host Management 用户体系仅用于主机层管理，与 VBR 控制台中的 RBAC（如 Backup Operator、Restore Operator 等）是**两个独立体系**。

- Host Management 用户仅管理 Appliance 本身，不涉及备份任务权限。
- VBR 控制台中的 RBAC 将在后续文章中详细介绍，适用于备份任务、恢复操作等权限控制。


通过合理配置 Host Management 用户体系，Veeam Software Appliance 实现了运维与安全职责的分离，构建了更安全、可审计的管理架构。建议在部署初期就明确角色分配，避免权限滥用或安全隐患。



## 升级和更新

在传统的 Veeam Backup & Replication 部署中，升级往往意味着管理员需要手动下载补丁、验证兼容性、安排维护窗口，甚至还要处理操作系统层面的更新。这种方式既繁琐又容易因人为操作失误或补丁遗漏带来安全隐患。而在 Veeam Software Appliance 中，升级机制被彻底重构，成为其“天生安全”架构的重要组成部分。

Veeam Software Appliance 内置的 **Veeam Updater 服务** 会每日自动向 Veeam 官方仓库（`repository.veeam.com`）获取最新更新信息并写入配置数据库。更新内容不仅包括操作系统与安全补丁（强制安装，无法跳过或取消，确保系统始终合规），也包括 Veeam B&R 组件（支持主版本、次版本及私有修复补丁，可按策略自动或手动安装）。整个过程通过 REST API 与 Veeam Identity Service 进行授权通信，确保更新操作的完整性与安全性。

![Configuring Updates](https://s2.loli.net/2025/09/07/dekRMqLCWUp1xtn.png)

管理员可以通过 WebUI 或 Veeam 控制台灵活配置更新策略，例如：

- 仅自动安装安全更新或扩展到次版本更新
- 按周或月设定维护窗口
- 设置强制更新的最大延迟时间（默认 30 天，可延长至 90 天）
- 配置 HTTP/HTTPS 代理访问外部仓库。

即使选择手动安装，超过合规期限后仍会强制安装更新，即使当前有备份任务运行也会中断作业以完成更新。

对于无法访问互联网的环境，Veeam Software Appliance 也支持配置本地离线镜像仓库作为更新源。只需提供本地仓库地址及其服务器证书，就能获得与在线仓库相同的自动更新体验。

相比传统 Veeam 软件的手动更新，Veeam Software Appliance 在操作系统和组件更新、安全性保障、更新源配置、以及日志与审计方面都有显著不同：系统补丁自动推送并强制安装，Veeam 组件可自动检测并按策略安装，支持离线镜像仓库，同时所有更新日志集中管理且可导出审计。

在执行更新之前，仍建议管理员先导出配置文件备份当前设置；可通过 WebUI 查看更新历史与详细日志（路径 `https://<hostname>/updater/updates`）；若收到  Veeam Support 提供的 Private Hotfix，也可以通过 WebUI 上传并安装。

这一全新的更新机制不仅让补丁管理从繁琐的手动操作变成可控、可审计、可自动化的流程，也在安全性与合规性上树立了新的标杆，为现代化备份基础设施提供了更高的可靠性与运维效率。



## 小结

Veeam Software Appliance 把很多复杂工作隐藏在了“界面后面”，这既是优势也是责任——把管理、权限、更新节奏都规划好，才能既享受“开箱即用”的便利，又保证长期安全与合规。下一篇我会分享大家关心的离线镜像仓库搭建，手把手带你把本地仓库搭起来并保持同步，感兴趣的别错过。

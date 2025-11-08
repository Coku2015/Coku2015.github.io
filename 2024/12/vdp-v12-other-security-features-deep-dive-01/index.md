# VDP 安全技术系列（一） - 免账户和 SSH 服务管理 Linux 备份代理


## 系列目录

数据保护不只是备份，它关乎企业的安全的最后一道防线。Veeam 通过零信任设计理念，将安全性融入到产品的每一处细节。从备份的开始到恢复的最后一步，Veeam 不断打磨每一个功能，以满足现代安全需求。本系列汇聚了 VDP v12 版本后新增的安全小技巧，简单易用，却能为数据安全保驾护航。

- 第一篇：免账户和 SSH 服务管理 Linux 备份代理
- 第二篇：使用 gMSA 技术托管 Windows 账号
- 第三篇：四眼认证模式：双人控制管理备份系统操作
- 第四篇：启用多因子认证（MFA）：加强备份系统账户保护
- 第五篇：减少备份中涉及的网络端口
- 第六篇：使用 Syslog 将日志托管至 SIEM 系统



在任何系统中，获取账号权限都是黑客攻击的起点，备份系统也不例外。账号存储和管理存在一定的安全风险，因此在设计和配置系统时，减少不必要的账号自动记忆和保存是保障安全的重要措施。在备份解决方案中，，Veeam Agent for Linux 引入了免账号管理功能，这能够大大增强了系统的安全性。通过这种方式，用户无需将账号信息存储在系统中，从而有效降低了潜在的安全漏洞和数据泄露的风险。这种免账号管理机制不仅提升了备份的安全防护等级，还简化了管理员的管理流程，对于特殊的系统还能避免使用 SSH 管理协议，使得整体系统更加安全可靠。

另外，对于堡垒机托管 root 密码的环境，这种部署方式也能适应不断变化的账号密码，避免来备份系统中修改存放的密码。

### 工作原理

在部署 Veeam Agent for Linux 前，管理员先到 Linux 机器上，预先安装 Veeam 的部署服务包和临时证书，有了这个服务包后，当 VBR 发起 Agent 推送/管理操作时，VBR 会检测到 Linux 系统上的这个组件，和这个组件建立连接后，检查必要的证书，如果是临时证书，那么 VBR 会下发正式证书替换当前的临时证书。在这之后，VBR 都会用这个有效证书和 Linux 机器通讯，管理和安装相关的 Agent 组件。这个过程完全不需要用到在备份服务器上输入 Linux 机器的管理员用户名和密码。

### 操作步骤

接下来，就跟着我一步一步来看下怎么使用这个功能。

1. 首先需要从 VBR 上导出一下这个预安装的软件包和临时证书，导出需要用到以下 powershell 命令：

```powershell
Generate-VBRBackupServerDeployerKit -ExportPath "C:\Users\Administrator\Documents"
```

打开 VBR 服务器左上角三条横线的汉堡图标，找到 Console 菜单下的 Powershell，输入以上命令，就能获取到这份 Deployer Kit。

![Xnip2024-12-01_17-08-32](https://s2.loli.net/2024/12/01/E6DBGaJICS3oOXn.png)

到导出的目录下，可以看到以下文件：

![Xnip2024-12-01_17-10-38](https://s2.loli.net/2024/12/01/qV6faYzIAFTPKhn.png)

其中，rpm 包是用于 redhat 系的安装包，而 deb 则是 debian 系的安装包。根据不同系统，需要拷贝 client-cert.pem、server-cert.p12 和一个 rpm 或 deb 软件包到目标的 Linux 的机器上。

2. 运行命令安装 rpm 包：

```bash
yum install veeamdeployment-12.2.0.334-1.x86_64.rpm
```

3. 接着运行命令安装证书：

```bash
/opt/veeam/deployment/veeamdeploymentsvc --install-server-certificate server-cert.p12
/opt/veeam/deployment/veeamdeploymentsvc --install-certificate client-cert.pem
/opt/veeam/deployment/veeamdeploymentsvc --restart 
```

4. 回到 VBR 控制台，创建保护组，在保护组的创建向导中，添加 Linux 主机时，选择`Connect using certificate-based authentication`，添加完可以使用`Test Now`按钮测试可连接性。此时，使用`certificate-base authentication`模式时，VBR 将不再需要任何的 ssh 服务来部署 Veeam Agent for Linux。

![Xnip2024-12-01_17-22-34](https://s2.loli.net/2024/12/01/35JDuQFcG4Naneh.png)

5. 一切正常后，就可以安装正常方式完成 Protection Group 的创建，推送 Agent 了。推送过程中，VBR 将会更新目标服务器上的临时证书，将它更新成正式的通讯证书，并安装 Transport service。

![Xnip2024-12-01_19-19-23](https://s2.loli.net/2024/12/01/P2dLmMn6aBKoUTE.png)



以上就是关于 Linux Agent 管理的安全小技巧，希望对您的 IT 系统的安全有帮助，下一期我将带大家来看看 Windows 系统该如何使用免密码的管理方式。


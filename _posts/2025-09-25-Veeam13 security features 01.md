---
layout: post
title: 让 VBR 登陆更安全：v13 版本 SAML + Azure EntraID 集成全攻略
tags: Backup, Security
---

v13 版本，新增的功能中，最重要的是安全特性的加强。从本期开始，我会为大家通过实战应用的方式，详细介绍 v13 中推出的全新安全功能。

今天先来说说身份认证。在企业级备份架构中，管理控制台的账户安全与访问治理至关重要。Veeam Backup & Replication（VBR）在 v13 中支持基于 SAML 的单点登录（SSO），这意味着可以把身份认证集中到组织现有的身份提供者（IdP）——例如 Azure EntraID。通过 SAML 集成，你可以把 VBR 的登录与公司的账号生命周期、组策略、MFA 和审计统一管理：运维更加清晰，权限回收更及时，实现更高的合规性。本文以 Azure EntraID 为例，为大家详细展示这个集成的具体方法。其他类似方案，比如国内的 Authing 或者国外的 Okta 和 Auth0 大家可以自己按照 Azure 的方法试试看。



## 配置准备

要配置和使用 SAML 集成，前提条件非常简单，使用最新上线的 Veeam Software Appliance 安装 VBR 即可。当然因为使用网络服务，这时候配置 SSO 还是有些必要条件的：

- VBR 服务器必须能够访问 Azure 的 EntraID 的相关 endpoint。
- 时间同步，VBR 上必须正确配置 NTP 服务器，时间不能有偏差，SAML 是基于时间戳的，如果偏差会认证失败。
- Azure EntraID 的管理员账号，要有创建企业应用和分配用户的权限。
- VBR 管理员权限，这是配置 VBR 账号和身份集成的基础。
- VBR Console 所在的 Windows 必须正确解析 VBR 的主机名或者 FQDN，否则 SP/IdP Metadata 里的 URL 对不上。

## 配置方法

以下配置，分为 Azure 部分和 VBR 部分，并且有一定的顺序，因此推荐按顺序进行。

### 在 VBR 中生成 SP 信息并导出 Metadata

1. 首先用 veeamadmin 账号登入 VBR 控制台，在 VBR 中，打开左上角三条横线的汉堡图标，在下拉菜单中选择`Users and Roles`

![Xnip2025-09-24_17-55-19](https://s2.loli.net/2025/09/24/qy8vVwXd1gTJCUZ.png)

2. 切换到 v13 新增的 Identity Provider 界面，默认情况下，这里的`Enable SAML Authentication`处于未被选中的状态，勾选启用，然后在下面先看到 Service Provider（SP）Information 部分。在身份认证中，VBR 现在就相当于是应用程序的服务提供者（SP），因此我们在这里要先为 VBR 安装一个证书，点击 Install。

![Xnip2025-09-24_17-57-13](https://s2.loli.net/2025/09/24/vPmNyV2KuMIeaSf.png)

3. 可以从本地的证书库中选择一个，选择`Select an existing certificate from the certificate store`，点击下一步。

![Xnip2025-09-24_18-05-26](https://s2.loli.net/2025/09/24/pmOMAduU3aLvrSh.png)

4. 在证书库中，找到 Friendly Name 为`Veeam Backup Server Certificate`的这个证书后，点击 Finish 完成。

![Xnip2025-09-24_19-28-09](https://s2.loli.net/2025/09/24/qQ36kWyloODrenZ.png)

5. 此时，SP Information 部分会看到 Certificate 已经有信息出现了，`CN=<备份服务器FQDN>`。接下去的操作，我们需要点击 Install 下方的 Download 按钮，将 SP 这边的 xml 文件下载下来，保存好。这个文件会在稍后 Azure 那边配置时使用到。

### 在 Azure EntraID 中上传 SP Metadata 并分配用户。

1. 首先来为 VBR 创建一个安全组，命名为 VBR Users。并为这个组添加一个 User，比如我把我自己的账号加了进来。

![Xnip2025-09-24_19-40-09](https://s2.loli.net/2025/09/24/6ArDuKk4c5nmC9j.png)

2. 在 EntraID 中，找到 Enterprise apps，我们需要为 VBR 的身份认证，创建一个新的 Application，点击`New Application`来创建。

![Xnip2025-09-24_19-42-30](https://s2.loli.net/2025/09/24/1oCcNp9ZVa4HSA2.png)

3. 在创建时，不要从 catalog 中选择，点击`Create your own application`然后在右边的弹框中，输入 app 名称，然后选择`Integrate any other application you don't find in the gallery(Non-gallery)`,比如我的叫 vbrsso。

![Xnip2025-09-24_19-44-43](https://s2.loli.net/2025/09/24/9ip6ufav1oPqAb4.png)

4. 这个 Application 创建完成后，会自动转到 Application Overview 界面，上面的 Getting Started 界面已经清楚的列出了接下去的步骤。可以按照上面 1、2、3、4、5 的步骤根据需要逐个配置。对于 VBR 来说，我们只需要配置两个`Assign users and groups`和`Set up single sign on`。

![Xnip2025-09-24_19-53-39](https://s2.loli.net/2025/09/24/5U38hXekxZHgv9f.png)

5. 将第一步中创建的 Group，VBR Users 分配给这个应用后，点击第二个步骤，`Set up single sign on`，会进入单点登陆的配置界面，在这里，我们选择 SAML 这个选项来和 VBR 集成。

![Xnip2025-09-24_19-55-58](https://s2.loli.net/2025/09/24/MVTL9FXKoy5keui.png)

6. 进入 SAML 配置界面后，这里清晰的列出了 1-2-3-4 的步骤，然而我们不需要逐个去编辑这里的内容，只需要找到上方`Upload metadata file`，点击后将我们刚刚从 VBR 上导出的 xml 文件上传后保存，即可完成这里单点登陆的配置。上传后可以看到 Basic SAML Configuration 中 URL 已经被正确的更新成我的 VBR 的 FQDN 了。

![Xnip2025-09-24_19-59-11](https://s2.loli.net/2025/09/24/xhUFLdrAP82qXSI.png)

7. 接下去，找到上图中第三步中的 SAML Certificates 框里的最后一行，Federation Metadata XML 旁边的 Download 按钮，再从 Azure EntraID 中下载一份自动生成的 XML 文件。

![Xnip2025-09-24_20-03-36](https://s2.loli.net/2025/09/24/Usl1VRH9LrATicq.png)

至此，Azure 上的设置就全部完成了。



### 回 VBR，更新配置 IdP 信息

1. 还是回到 VBR 中 Users & Roles 下的 Identity Provider 界面，找到 Identity Provider（IdP）Information 设置，这是单点登陆中身份提供商的信息，也就是 Azure EntraID 来作为这个身份提供商。点击旁边的 Browse，上传刚刚从 Azure 中下载下来的 XML 文件。上传完成后，会看到下面所有 IdP 的信息已经正确更新成微软的网址了。

![Xnip2025-09-24_20-10-12](https://s2.loli.net/2025/09/24/5fZX7jxBQDIrSah.png)

2. 点击 OK 完成设置后，我们就可以重新再打开`Users and Roles`，来增加 User 了。点击`Add...`后，会出现`External user or group`的选项，我们选择它。

![Xnip2025-09-24_20-15-01](https://s2.loli.net/2025/09/24/Ha4YEzhSA27O1tR.png)

3. 在弹出的 Add User 对话框中，输入完整的 Azure EntraID 的邮箱，比如我的是`lei.wei@xbbm365.backupnext.cloud`。

![Xnip2025-09-24_20-17-04](https://s2.loli.net/2025/09/24/RC9eID4i5OmVzSN.png)

4. 这样，整个配置就完成了，我们来试试登陆。打开 VBR 客户端，我们能看到客户端上已经出现`Sign in with SSO`选项，我们直接点击这个。

![Xnip2025-09-24_20-20-38](https://s2.loli.net/2025/09/24/gIzswZoxpBbDqiP.png)

5. 点击后，登陆窗口会自动弹出标准的微软登陆界面，输入密码后，还会弹出微软的 MFA 批准登陆。

![Xnip2025-09-24_20-22-44](https://s2.loli.net/2025/09/24/WyT7Rhi4qKlXbDI.png)

6. 手机 Authenticator 批准后，VBR Console 就能顺利跳转登陆啦。
7. 我们再打开网页试试看，在 WebUI 中，我们一样能看到有新的 Sign in With SSO 选项啦。

![Xnip2025-09-24_20-26-16](https://s2.loli.net/2025/09/24/Pqj25XhY68Mok31.png)

8. 同样，批准登陆后，我们能够访问 Veeam 权限的 Web UI，而在 Web UI 的右上角，我们还能看到已经正确显示访问用户的账号和邮箱了。

![Xnip2025-09-24_20-29-11](https://s2.loli.net/2025/09/24/JDPmahNHG849E6B.png)

### 在 Azure 中查看登录审计信息

在 Azure EntraID 的管理审计界面中，能够清晰的看到 VBR 中登陆的信息。

![Xnip2025-09-24_20-50-56](https://s2.loli.net/2025/09/24/U8HrSw5j374KCmk.png)



## 配置小结

按照以上方法，VBR 和 Azure EntraID 的集成就能轻松配置完成。需要注意的是，这样配置的用户它仅仅是备份系统的用户，它并不能像 veeamadmin 和 veeamso 账号一样去登陆 Appliance 的 Veeam Management Console，这个 SSO 账号是无法管理 Appliance 的。

从安全上来看，这样的配置能够有效的分离备份系统的权限，备份系统的身份认证和备份基础架构的账号完全分离开来了，这也更加符合大型企业和组织的使用规范。


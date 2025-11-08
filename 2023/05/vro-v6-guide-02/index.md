# VRO 基础入门（二） -  安装与部署


## 系列目录：

- [VRO 基础入门（一）-  简介](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-01/)
- [VRO 基础入门（二）-  安装与部署](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-02/)
- [VRO 基础入门（三）-  基本组件 · 上篇](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-03/)
- [VRO 基础入门（四）-  基本组件 · 下篇](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-04/)
- [VRO 基础入门（五）-  成功灾备计划的第一步](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-05/)
- [VRO 基础入门（六）-  数据实验室](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-06/)
- [VRO 基础入门（七）-  Plan Step  · 上篇](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-07/)
- [VRO 基础入门（八）-  Plan Step  · 下篇](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-08/)
- [VRO 基础入门（九）-  文档模板解析](https://blog.backupnext.cloud/2023/10/VRO-v6-Guide-09/)
- [VRO 基础入门（十）-  使用 VRO 搭配 K10 实现全自动容器灾备](https://blog.backupnext.cloud/2023/11/VRO-v6-Guide-10/)

## VRO 安装包获取

Veeam 官网可以直接下载 VRO 试用版，**Veeam Data Platform — Premium **的安装包就是我今天文章中用到的安装包，[直达电梯](https://www.veeam.com/downloads.html) 在此，可以直接前往下载。

这个安装包是一套完整的 VRO 套件，其中包括 VRO 主程序、内嵌的 VBR 以及内嵌的 VeeamONE，需要注意的是，这个安装包虽然包含了`内嵌的 VBR`和`内嵌的 VeeamONE`但是这两个软件都无法被提取出来单独安装，这两个内嵌的软件都是 VRO 工作的必要组件，它们是跟着 VRO 一起工作的。

这两个内嵌的 VBR 和 VeeamONE 和正常的软件没有任何区别，在安装完 VRO 后可以使用 VBR 或者 VeeamONE 控制台的访问方式远程访问使用，目前在这个安装包中包含的 VBR 是 V12 版本，VeeamONE 是 V12 版本。

## 安装前提条件

非常重要的三点提示：

> - 请不要在已经安装了 VBR 或者 VeeamONE 的服务器上安装 VRO 软件包。
> - 请不要在域控制器上安装 VRO 软件包。
> - 请不要在一台已经安装了 PostgreSQL 的服务器上安装 VRO

一般来说，我建议如果是进行 VRO 的安装，都应该准备一台全新的 Windows 服务器来安装 VRO 的安装包。

安装完成后，可以将您原来的 VBR 加入到 VRO 环境中来由 VRO 纳管，也可以使用 VRO 内嵌的 VBR 来进行常规的备份和复制任务。

其他更多的安装前提条件，请参考官网的 [前提条件说明](https://helpcenter.veeam.com/docs/vdro/userguide/system_requirements.html?ver=60)。

## 安装方法

安装包是个 ISO 文件，通过挂载 ISO 的方式打开这个镜像后自动运行，可以找到 VRO 的安装按钮：

![installing_vao_splash.png](https://helpcenter.veeam.com/docs/vdro/userguide/images/installing_vao_splash.png)

整个安装过程非常简单，和 Veeam 其他产品的安装一样，跟着向导无脑点完下一步就能做完最基础的安装。

需要注意的是，在安装过程中会要求输入用户名密码，此处的用户名密码为 VRO、VBR、VeeamONE 的服务和它们的数据库需要使用的用户名密码，因此此密码要求的最小权限为这台 VRO Server 的 Windows 本地管理员权限，隶属于本地 Administrators 组即可。

这个账号虽然和后续灾备所使用的灾备管理员的账号没有任何关系，但是在后续的初始化配置的第一步需要输入此账号来登入 VRO 的 UI 界面。

![installing_vao_account.png](https://helpcenter.veeam.com/docs/vdro/userguide/images/installing_vao_account.png)

整个安装过程根据不同的硬件能力会大约持续 20-30 分钟，安装完成后这台服务器上就可以使用 VRO 了。由于 VRO 都是基于浏览器的访问，因此我一般会推荐我们从其他电脑的桌面端，通过 Chrome 或者 Edge 浏览器来打开 VRO 的控制台。

## 初始化配置

1. 安装结束后，请先不要去打开内置的 VBR 和 VeeamONE 的控制台，而是打开浏览器进入 VRO 的控制台开始初始化配置，系统只有在初始化配置完成后才能够正常工作，进入初始化配置的界面请访问：https://VROIP:9898/
   ![accessing_vao_ui.png](https://helpcenter.veeam.com/docs/vdro/userguide/images/accessing_vao_ui.png)
   这时候浏览器会提示输入凭据，请使用上图安装时所用到的凭据作为初始化登入使用的凭据。特别注意，这个凭据只在初始化配置时使用 1 次，在初始化配置完成后，将会使用初始化配置步骤 3 中设定的 VRO 灾备管理员的凭据。

2. 登入账号后，系统进入初始化向导，在 Welcome 页面中描述了这个基础配置向导的一些任务，点击 Next 进入下一步服务器配置。
   ![initial_config_welcome01.png](https://helpcenter.veeam.com/docs/vdro/userguide/images/initial_config_welcome01.png)

3. 在服务器配置步骤中，有两个重要内容要选择，一个是选择灾备管理员，通过图中“Choose users and groups”按钮打开添加向导，在右边配置用户属于哪个域（Domain），选择 Account Type 是 User 还是 group，最后从 Account 列表中选取合适的账号点击 Add 即可完成用户配置。这里配置的账号将会用户此次初始化配置之后的 VRO 使用和访问。
在 Server Details 中，可以为 VRO 服务器配置一些基础信息，这些信息会在报表中被使用到。

   ![initial_config_agent_creds01.png](https://helpcenter.veeam.com/docs/vdro/userguide/images/initial_config_agent_creds01.png)

4. 在基础架构配置步骤中，可以添加用于连接基础架构系统的凭据（Add Credentials）、部署 Orchestrator Agent（其实这个步骤就是添加 VBR）、连接 vCenter 以及连接存储系统。在这个步骤中添加的 vCenter 和存储系统的配置会被自动同步至内嵌的 VBR 和 VeeamONE 中，因此内嵌的 VBR 和 VeeamONE 组件中不需要做任何额外的配置。当然，这些步骤都是可选步骤，我们可以在这个向导里完成最初始的设定，也可以在后期从 VRO 的 Configuration 中再进行调整和配置。
   
   ![initial_config_service_creds01.png](https://helpcenter.veeam.com/docs/vdro/userguide/images/initial_config_service_creds01.png)
   
5. 配置完以上步骤后，点击 Finish 就能完成所有的初始化配置。在点击完 Finish 后，网页将会重新刷新回到最开始的 VRO UI 登入界面，使用上面第二步中设定的账号密码就能登入 VRO 正式的 UI 界面了。
   ![images/initial_config_finish01.png](https://helpcenter.veeam.com/docs/vdro/userguide/images/initial_config_finish01.png)

欢迎各位来到 VRO！接下去就可以正式开始使用 VRO 了。在下一篇中，我会详细介绍 VRO 的各个组件。


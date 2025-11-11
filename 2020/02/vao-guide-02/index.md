# VAO 基础入门（二） -  安装与部署


## 系列目录：

- [VAO 基础入门（一）-  简介](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO 基础入门（二）-  安装与部署](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO 基础入门（三）-  基本组件 · 上篇](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO 基础入门（四）-  基本组件 · 下篇](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO 基础入门（五）-  基础配置要点](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO 基础入门（六）-  成功灾备计划的第一步](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO 基础入门（七）-  Plan Step  · 上篇](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO 基础入门（八）-  Plan Step  · 下篇](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO 基础入门（九）-  文档模板解析](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)

## VAO 安装包获取

Veeam 官网可以直接下载 VAO，[直达电梯](https://www.veeam.com/availability-orchestrator-download.html)

这个安装包是一套完整的 VAO 套件，其中包括 VAO 主程序、内嵌的 VBR 以及内嵌的 VeeamONE，需要注意的是，这个安装包虽然包含了`内嵌的 VBR`和`内嵌的 VeeamONE`但是这两个软件都无法被提取出来单独安装，这两个内嵌的软件都是 VAO 工作的必要组件，它们是跟着 VAO 一起工作的。

这两个内嵌的 VBR 和 VeeamONE 和正常的软件没有任何区别，在安装完 VAO 后可以以常规的访问方式访问使用，目前在这个安装包中包含的 VBR 是 9.5U4 版本，VeeamONE 是 9.5U4 版本；在 VAO 安装完成后，使用 VBR 和 VeeamONE 的正常升级方式将这两个组件升级至 9.5U4a 或者 4b 的版本。

## 安装前提条件

非常重要的两点提示：

> - 请不要在已经安装了 VBR 或者 VeeamONE 的服务器上安装 VAO 软件包。
> - 请不要在域控制器上安装 VAO 软件包。

一般来说，我们建议不管您是否已经安装了 VBR，如果是进行 VAO 的安装，都应该准备一台全新的 Windows 服务器来安装 VAO 的安装包。

安装完成后，您可以将您原来的 VBR 加入到 VAO 环境中来由 VAO 纳管，也可以使用 VAO 内嵌的 VBR 来进行常规的备份和复制任务。

其他更多的安装前提条件，请参考官网的 [前提条件说明](https://helpcenter.veeam.com/docs/vao/deployment/system_requirements.html?ver=20)。

## 安装过程

安装包是个 ISO 文件，通过挂载 ISO 的方式打开这个镜像后自动运行，可以找到 VAO 的安装按钮：

![3PrjeA.png](https://s2.ax1x.com/2020/02/17/3PrjeA.png)

整个安装过程非常简单，和 Veeam 其他产品的安装一样，跟着向导无脑点完下一步就能做完最基础的安装，安装完成后，请务必将 VBR 9.5U4a 和 VeeamONE 9.5U4a 的补丁打上，这一步千万不要忘了，因为 9.5U4a 这个补丁修复了很多 VAO 碰到的问题。

关于 VBR 9.5U4a 的升级，同样也可以参考我之前的 [博文](https://blog.backupnext.cloud/_posts/2020-02-13-How-to-upgrade-VBR/)。

需要注意的是，在安装过程中会要求输入用户名密码，此处的用户名密码为 VAO、VBR、VeeamONE 的服务和它们的数据库需要使用的用户名密码，因此此密码要求的最小权限为这台 VAO Server 的 Windows 本地管理员权限，隶属于本地 Administrators 组即可。

这个账号虽然和后续灾备所使用的灾备管理员的账号没有任何关系，但是在后续的初始化配置的第一步需要输入此账号来登入 VAO 的 UI 界面。

![3PgvP1.png](https://s2.ax1x.com/2020/02/17/3PgvP1.png)

## 初始化配置

1. 安装结束后，请不要去打开内置的 VBR 和 VeeamONE 的控制台，请立刻开始初始化配置，系统只有在初始化配置完成后才能够正常工作，进入初始化配置的界面请访问：https://VAOIP:9898/
   ![3PWOaQ.png](https://s2.ax1x.com/2020/02/17/3PWOaQ.png)
   这时候浏览器会提示输入用户名密码，请使用上图安装时所用到的用户名密码作为初始化登入使用的用户名密码。特别注意，这个密码只在初始化配置时使用 1 次，在初始化配置完成后，将会使用初始化配置过程中设定的 VAO 灾备管理员的用户名密码。

2. 登入账号后，系统进入初始化向导，Welcome 页面中有些信息，有兴趣的话可以阅读一下，这页很简单，只需读完后点击 Next。
   ![3PfDoQ.png](https://s2.ax1x.com/2020/02/17/3PfDoQ.png)

3. 输入一些 VAO 服务器的基础管理信息，这些信息在后续的文档模板中都会有用到。当然这些信息在配置完成后都能在 Configuration 中进行修改，不用担心填错。
   ![3Pf2Q0.png](https://s2.ax1x.com/2020/02/17/3Pf2Q0.png)

4. 此处需要填入 VAO 灾备管理员的账号，需要注意的是，此处的账号为初始化配置结束后登入 VAO UI 的灾备管理员的账号，此账号需要属于域账号，因此在整个 VAO 的部署中，Active Directory 是必要条件，如果环境中没有 AD 域，那就创建一个 VAO 专用的 AD 域吧。
   ![3Pfczq.png](https://s2.ax1x.com/2020/02/17/3Pfczq.png)
   请一定记住此处填入的灾备管理员的账号，在这个向导结束后，安装阶段使用的本地管理员账号将再也无法登入系统进行初始化配置，替代的是此处填入的账号。

5. 接下来进入 VBR 的配置界面，假如您的系统中已经有 VBR 在工作了，您希望新部署的 VAO 和之前已经在使用的 VBR 一起工作，那么请在这一页中填入已有的 VBR 系统或者 Enterprise Manager 的服务器地址。
   否则，请点击 Skip 跳过此页配置，使用 VAO 内嵌的 VBR 来作为主备份服务器。

   ![3Pf6Wn.png](https://s2.ax1x.com/2020/02/17/3Pf6Wn.png)
   对于很多全新的环境来说，一般部署的时候都可以选择 Skip 跳过此页，而使用内嵌在 VAO 系统中的 VBR 进行备份和复制作业。
   

`本文将不讨论和已部署 VBR 的环境混合使用，因此后面的文章只限于讨论不输入 VBR 地址，直接点击 Skip 跳过 VBR 的配置。`

6. 在跳过 VBR 配置后，进入 vCenter 的配置，这里我们可以将生产站点的 vCenter 管理员账户填入到此处，为了方便配置，我们建议配置一个专用于 VAO 的账户，且该账户隶属于 vCenter 权限中的管理员权限组。
   ![3Pf0eS.png](https://s2.ax1x.com/2020/02/17/3Pf0eS.png)
   此步骤也是在这个向导中的非必要步骤，但是需要注意的是，vCenter 为 VAO 工作是必须连接的组件，即使在此处点击 Skip 跳过后，依然需要在后续的 Configuration 中将 vCenter 配置上去，并且需要在 Configuration 中将每一个会使用到的 vCenter 注册到 VAO 中。
   另外，VAO 不支持 ESXi 直连方式工作，因此没有 vCenter 的环境将无法使用 VAO。
   
   配置完以上步骤后，点击 Finish 就能完成所有的初始化配置。在点击完 Finish 后，网页将会重新刷新回到最开始的 VAO UI 登入界面，使用上面第四步中设定的账号密码就能登入 VAO 正式的 UI 界面了。

![3Pqq4f.png](https://s2.ax1x.com/2020/02/17/3Pqq4f.png)

欢迎各位来到 VAO！接下去就可以正式开始使用 VAO 了。在下一篇中，我会详细介绍 VAO 的各个组件。


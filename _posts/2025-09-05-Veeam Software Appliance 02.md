---
layout: post
title: 有手就能装！Veeam Software Appliance 一步一步带你部署
tags: VBR
---

在上一篇文章里，我们和大家一起认识了 Veeam 最新发布的几款产品，尤其是 **Veeam Software Appliance** 这个全新的备份软件“本体”。很多朋友可能看完之后觉得概念上有点明白了，但还是不清楚真正下载回来以后应该怎么用、怎么装、怎么配置。别急，从这篇开始，我们就动手实战，带大家一步步搞定 **Veeam Software Appliance** 的部署和使用。

Veeam 官方为这个 Appliance 提供了两种部署方式：**ISO 镜像**和 **OVA 模板**。为了不让大家一上来就“菜单太多”，本篇我们先专注在 **ISO 镜像**这种方式上。和我们平时在操作系统里“挂载一个 ISO 文件”不一样，这个 ISO 是一张完整的系统引导盘，你需要用它来启动服务器或虚拟机，就像给一台新电脑装系统一样。

## 准备工作：获取 ISO 镜像
上一篇我们已经给出了下载链接，这里就不再重复贴地址，但在正式动手之前，我一定要**郑重提醒大家一件事**：无论你从哪里下载 Veeam Software Appliance 的 ISO，**一定要校验你下载的 ISO 文件的 MD5/SHA-1 校验值！**

为什么要这么做？
在今天的网络环境里，下载大文件并不总是“干干净净”的。比如：
- 有些公共 Wi-Fi 或被恶意软件感染的电脑，会**劫持浏览器的下载请求**，把你重定向到看似一样的“下载地址”；

- 攻击者也可能在中间链路里“掉包”，把原本的官方包替换成植入后门的恶意版本；

- 即便是官方站点，如果遭遇短暂的入侵或 DNS 污染，也有可能导致你拿到的不是原版文件。
  这些情况用户肉眼完全看不出来，界面、文件名、大小都可能一模一样。  

  **唯一可靠的办法**就是比对 Veeam 官网提供的 MD5 或 SHA-1 校验码——就像比对“指纹”，指纹一致才是真身。

### 不同系统的比对方法
无论是 Windows、Linux 还是 macOS 用户，现在我们都有非常方便的比对方法，这里大家一定要记得快速比较下载到的文件。下面我把比较方法列出，不同的系统只要复制粘贴到命令行，就能直接比较啦。

💻 **Windows** 
在 PowerShell 中执行（官网文件名为 `VeeamSoftwareAppliance_13.0.0.4967_20250822.iso`）：

```powershell
# 校验 MD5
if ((Get-FileHash .\VeeamSoftwareAppliance_13.0.0.4967_20250822.iso -Algorithm MD5).Hash.ToLower() -eq "30bb0eef0dca6544c36a2728642d35c9") {
    Write-Host "✅ MD5 校验一致"
} else {
    Write-Host "❌ MD5 校验不一致，请重新下载"
}

# 校验 SHA-1
if ((Get-FileHash .\VeeamSoftwareAppliance_13.0.0.4967_20250822.iso -Algorithm SHA1).Hash.ToLower() -eq "1aa8624419c71adcf5425d87c8cf53f90fafd1f6") {
    Write-Host "✅ SHA-1 校验一致"
} else {
    Write-Host "❌ SHA-1 校验不一致，请重新下载"
}
```

🍏**macOS**

```bash
# 校验 MD5
if [ "$(md5 -q VeeamSoftwareAppliance_13.0.0.4967_20250822.iso)" = "30bb0eef0dca6544c36a2728642d35c9" ]; then
  echo "✅ MD5 校验一致"
else
  echo "❌ MD5 校验不一致，请重新下载"
fi

# 校验 SHA-1
if [ "$(shasum -a 1 VeeamSoftwareAppliance_13.0.0.4967_20250822.iso | awk '{print tolower($1)}')" = "1aa8624419c71adcf5425d87c8cf53f90fafd1f6" ]; then
  echo "✅ SHA-1 校验一致"
else
  echo "❌ SHA-1 校验不一致，请重新下载"
fi
```

💻**Linux**
```bash
# 校验 MD5
if [ "$(md5sum VeeamSoftwareAppliance_13.0.0.4967_20250822.iso | awk '{print tolower($1)}')" = "30bb0eef0dca6544c36a2728642d35c9" ]; then
  echo "✅ MD5 校验一致"
else
  echo "❌ MD5 校验不一致，请重新下载"
fi

# 校验 SHA-1
if [ "$(sha1sum VeeamSoftwareAppliance_13.0.0.4967_20250822.iso | awk '{print tolower($1)}')" = "1aa8624419c71adcf5425d87c8cf53f90fafd1f6" ]; then
  echo "✅ SHA-1 校验一致"
else
  echo "❌ SHA-1 校验不一致，请重新下载"
fi
```

校验码就是“官方指纹”，只有完全一致才能确定拿到的是真正的官方原版文件，这是避开网上下载的程序被植入恶意程序的唯一方法。


## ISO 使用方式详解

在文章开头我们提到过，这个 ISO 与以往的 Veeam 软件安装包不同，它并不是单纯的软件 ISO，而是**包含操作系统和 Veeam 软件的一体化镜像**。换句话说，这个 ISO 本身就能像全新的操作系统安装盘一样，引导服务器或虚拟机启动，并进行完整的系统部署。 

由于如今大家很少有“全新装系统”的需求，很多读者朋友拿到这种 ISO 可能会一时不知如何下手。其实，它大致有三种典型的使用场景：

1. **光盘刻录**（传统方式，方法简单，这里不展开） 
2. **虚拟机挂载 ISO**（直接在虚拟化平台加载 ISO 启动，方法也很直观） 
3. **制作可启动 U 盘**（将 ISO 烧录进 U 盘，插入服务器用 U 盘引导即可安装） 

前两种方式相对容易操作，这里就不详细展开了；**我们重点介绍第三种方式——用 Rufus 制作启动 U 盘**。 
Rufus 是一款非常轻量级、无需安装、功能强大的 U 盘启动盘制作工具，尤其值得一提的是，它内置了 **MD5 与 SHA-1 校验功能**，正好可以配合我们上一章节中提到的校验方法，帮助你快速验证下载的 ISO 文件完整性。下面我们就来看看 Rufus 的下载安装与使用步骤。

Rufus 使用步骤非常简单：

1. 打开 Rufus 官方网站：[https://rufus.ie/](https://rufus.ie/) 
2. 在页面中选择最新版本的 **类型是便携版** 下载到本地。 
3. 下载完成后，双击即可直接运行，无需安装，它有全中文的使用界面，非常友好。

![Xnip2025-09-05_10-17-20](https://s2.loli.net/2025/09/05/mWvzktf8qDCI6iu.png)




##  安装和初始化配置

### 引导安装

当我们用刚才制作好的 U 盘引导服务器或虚拟机时，屏幕上出现的不是传统操作系统安装界面，而是 **Veeam Software Appliance** 的专用安装菜单。这张 ISO 里已经把操作系统和 Veeam 软件打包在一起，启动后就是“一体化”的安装体验。

主菜单清晰列出了两个主要组件：

- **Veeam Backup & Replication **
- **Veeam Backup Enterprise Manager**
- **UEFI Firmware Settings **

![Xnip2025-09-05_10-30-48](https://s2.loli.net/2025/09/05/6EY2FXanMDJSLAx.png)

为了方便，还附带了一个 **UEFI 设置选项**，可以在不退出安装程序的情况下调整引导参数。

在 VBR 或 Enterprise Manager 的子菜单中，你会看到两个操作：

- **Install** – 全新安装，删除所有数据（推荐在新环境使用）  
- **Reinstall** – 保留数据的重新安装  

![Xnip2025-09-05_10-32-10](https://s2.loli.net/2025/09/05/4dOfGTLXFE8awCA.png)

如果你选择 **Install**，系统会立刻弹出提示：**“即将清空当前服务器挂载磁盘上的所有数据”**。只要你点击 **Yes** 确认，之后就进入全自动安装流程

![Xnip2025-09-05_10-33-09](https://s2.loli.net/2025/09/05/YtiIaqmczlMbf6B.png)

没有繁琐的分区、没有一堆选项，全程几乎无需操作，就像给电脑做一个 Ghost 还原一样简单。

![Xnip2025-09-05_10-33-30](https://s2.loli.net/2025/09/05/34k7flnwXqQbKLI.png)

安装完成后，右下角的 Reboot System 就会亮起，点击或者等待几秒后系统自动重启，即可进入 VBR。

这个 Appliance 安装完成之后，默认会包含两个常规的设备管理控制台，一个是酷炫纯文本的界面（TUI），另外一个是浏览器访问的 Web 界面（WebUI）

### 初始化配置

重启后进入系统，会直接进入 TUI，在这里需要首先做一些初始化配置，才能正常使用备份服务器。

在初始化配置向导的第一步，首先是 Veeam EULA 和一些第三方许可的确认界面，直接用键盘方向键操作或者 Tab 键操作即可，选中 Accept 进入下一步。

![Xnip2025-09-05_10-46-17](https://s2.loli.net/2025/09/05/vdPjZ1KNF697kIy.png)

第二步是配置主机名，像我这里，配置了完整的 FQDN，并在我的 DNS Server 上做好了解析。

![Xnip2025-09-05_10-47-14](https://s2.loli.net/2025/09/05/72NaoGJf6lcukMb.png)

下一步是配置网络，我的环境中，没有 IPv6 的要求，我就只配置了 IPv4 的地址。

![Xnip2025-09-05_10-49-19](https://s2.loli.net/2025/09/05/jDcMdVJt42zqbQ6.png)

配置完成后，可以点击 Next 进入下一步。

![Xnip2025-09-05_10-50-41](https://s2.loli.net/2025/09/05/8vARZeu6tgGkCcO.png)

再往下是时区和时间配置，这个对于备份系统来说非常重要，时间同步不仅用于登陆时的多因子验证，还要用于日常备份的各种操作，包括数据不可变。

![Xnip2025-09-05_10-51-26](https://s2.loli.net/2025/09/05/Qavj6VnflUeZmtX.png)

然后是设置第一个管理员的密码，默认管理员用户名叫 veeamadmin，密码有非常严格的复杂度要求，为了 lab 环境使用方便，我一般会设置为：

- `123Q123q123!123`

![Xnip2025-09-05_10-52-01](https://s2.loli.net/2025/09/05/AqQJU3EORTjpC98.png)

接下来会提示绑定多因子验证的设备，大家可以任选合适的手机上的 MFA 工具扫码绑定，我一般喜欢用微软的 Authenticator，这个支持备份数据，还是比国内的一些 App 要靠谱。

![Xnip2025-09-05_10-54-57](https://s2.loli.net/2025/09/05/yOeAlIwQoDFPZ5T.png)

下一步是 Security Officer 选项，这个在复杂的生产环境是比较建议配置的，我的 Lab 我就直接勾选 Skip setting 了。

![Xnip2025-09-05_10-55-28](https://s2.loli.net/2025/09/05/nbrQ4pTP3OEa8Cc.png)

最后来到 Summary 界面，做一些配置检查后，点击 Finish 就可以完成初始化配置了。

![Xnip2025-09-05_10-55-48](https://s2.loli.net/2025/09/05/Z6nSF3Pl5qmc9RA.png)

配置完成后，就进入了日常待机的主画面。

![Xnip2025-09-05_11-41-09](https://s2.loli.net/2025/09/05/rRx9XeYkE2BtdLP.png)

接下去，我们就可以通过主画面的提示进一步进入 TUI 的高级配置中，进行一些主机配置的维护和调整，其中包括了主机配置、远程访问配置、修改密码、重启系统等等常规维护功能。

![Xnip2025-09-05_11-42-47](https://s2.loli.net/2025/09/05/6TaJhMgX9fHVzU3.png)



### 使用 WebUI 进行高级配置

在 TUI 上提示了两个地址，一个是 Host Management console，另外一个是 Veeam Backup & Replication web UI。对于 Appliance 的进阶高级管理配置，可以通过 Host Management console 进入进行配置。进入的时候一样会提示输入密码和 MFA 的验证码。

以上，Veeam Backup & Replication 就安装完成了，至于 Veeam Backup Enterprise Manager，安装过程类似，就不在这里详细说明了，留给大家自己探索喽。


## 小结 & 下期预告

这一期，我带大家从头到尾走了一遍 **Veeam Software Appliance** 的 ISO 使用流程：

从官网下载镜像并校验完整性 → 使用 Rufus 制作启动 U 盘 → 引导服务器自动安装 → 在 TUI 界面完成最基础的初始化与管理。 
你会发现整个过程几乎不需要复杂操作，只要准备好介质、跟着步骤点几下，任何人都能完成。

下一期，我们将正式走进 **V13 版本**的产品界面，深入体验它们的功能与新特性，看看全新版本到底有多强大。


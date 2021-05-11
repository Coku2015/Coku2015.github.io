---
layout: post
title: 使用vSphere PowerCLI快速完成Veeam备份管理员角色创建
tags: ['Automation']

---

为Veeam定制一个最小化的vSphere权限账号对于系统管理安全来说非常有必要，但是随着软件的升级功能的增强，对于vSphere上需要用到的权限也越来越多，Veeam在官方的UserGuide中提到了详细的[细颗粒度权限要求](https://helpcenter.veeam.com/docs/backup/permissions/cumulativepermissions.html?ver=100)，此时如果手工去逐个比对、选择，其实还是挺费时挺麻烦的一件事情。

最近我看到一个非常不错的[PowerCLI脚本](https://www.virtualhome.blog/2020/04/22/creating-a-vcenter-role-for-veeam-with-powercli/)，使用这个脚本能够快速方便的创建这个Veeam专用角色，今天来和大家分享一下。

这个脚本的前提条件，是安装vSphere PowerCLI，脚本是通过VMware自动化的vSphere PowerCLI管理工具来实现的。安装方法在VMware官网的[Blog](https://blogs.vmware.com/PowerCLI/2018/03/installing-powercli-10-0-0-macos.html)中有详细说明，我这里给个简化版的步骤：

1. 首先下载安装[PowerShell Core 7](https://github.com/PowerShell/PowerShell)，这是PowerCLI运行的必要条件。PowerShell Core比Windows PowerShell更强大，不熟悉的朋友也可以通过下载链接进去了解详细。安装过程非常简单，如果是Windows下，.MSI安装包双击后跟着向导就能装完。

2. 打开PowerShell 7快捷方式后，运行以下命令来安装vSphere PowerCLI。
```powershell
Install-Module -Name VMware.PowerCLI -Scope CurrentUser
```
   安装完成后输入以下命令，能够看到如下结果：
```powershell
Get-Module -Name VMware.* -ListAvailable
```

![tr87i6.png](https://s1.ax1x.com/2020/06/05/tr87i6.png)
3. 运行这个PS脚本，运行过程中会提示输入vCenter的IP地址、用户名密码以及希望创建的角色名称，根据实际情况输入即可。运行结果如下图：

![trJG38.png](https://s1.ax1x.com/2020/06/05/trJG38.png)

4. 回到vSphere Client，找到Administration下的Access Control，在Roles下面，能够找到刚刚用脚本创建出来的VBR Backup Admin的角色。接下去就可以去创建Veeam专用用户了。

![trYFbj.png](https://s1.ax1x.com/2020/06/05/trYFbj.png)

5. 在Administration的最底部，找到Single Sign On下面的Users and Groups，在Users下面，把Domain切换成vSphere登录的Domain，然后Add User添加新用户。
6. 添加完用户后，回到vCenter节点，授权这个新用户访问指定的vCenter，并给予VBR Backup Admin的权限，如下图：

![trtWfx.png](https://s1.ax1x.com/2020/06/05/trtWfx.png)

以上就是快速简单的添加备份角色的方法，安全又可靠，脚本链接如下：
https://github.com/falkobanaszak/vCenter-role-for-Veeam/blob/master/New_vCenterRole_Veeam.ps1






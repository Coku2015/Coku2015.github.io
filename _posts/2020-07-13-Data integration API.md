---
layout: post
title: 数据集成 API 真的就只是 API？
tags: Automation Powershell

---

Veeam 发布 v10 之后，推出了一个全新的功能，但是这个功能深深的埋藏在了 Powershell API 之下，并且被冠了一个令人高不可攀的名称：数据集成 API。我相信很多朋友看完这个名字，就可能不太想了解这个功能。对于系统管理员来说，有点略复杂了，还要开发什么东西才能把这个用起来？算了还是不用了。

## 功能

其实这个功能并不是那么的复杂，我们先来了解下怎么回事。

这个功能其实是通过 iSCSI 的磁盘服务，将备份存档通过 iSCSI 发布给相关服务器使用。它是数据利用的新形态，也就是说任何的 Veeam 的镜像级备份存档，都可以通过这种形式挂载给服务器去访问里面的数据。它和即时虚拟机恢复有那么一点点像，但是完全不一样的是，它完全不依赖于虚拟化环境，不依赖 VMware 和 Hyper-V，而是将数据直接通过 iSCSI 服务发布给 Windows 或者 Linux 系统访问。在 VBR 中，绝大多数镜像级的备份存档都支持这种形式的发布：

- VMware 镜像级备份
- VMware 镜像级复制
- Hyper-V 镜像级备份
- Hyper-V 镜像级复制
- Veeam Agent for Windows 的镜像级备份
- Veeam Agent for Linux 的镜像级备份

## 原理

iSCSI 挂载的工作原理非常简单，在 API 发起后，VBR 的挂载服务器相当于变成一台 iSCSI 的存储机头，它能为所有可以访问 iSCSI 存储的系统提供 iSCSI 的服务，而这里面提供出去的数据则是 VBR 的存档，管理员可以按需从备份或复制存档中选择需要的数据。在这个数据集成服务建立起来后，数据使用者可以通过 iSCSI 的存储协议，直接挂载发布出来的卷，读取其中的数据，使用其中的数据。如图所示，在数据集成服务将备份存档发布后，备份系统变成了一套 iSCSI 的存储系统，里面存放的数据是之前的历史备份数据。

![U1SPje.png](https://s1.ax1x.com/2020/07/11/U1SPje.png)

## 使用方法

因为它以 API 形式开放给用户使用，因此在 VBR 控制台上并没有直接的按钮来使用，但是这完全挡不住我们使用这么优秀的功能。可以直接使用本文最后面的这个 Powershell 的脚本来实现这个功能，需要做的很简单，只要 copy 脚本内容到记事本，存成。ps1 文件，然后在 VBR 服务器的 Powershell 控制台中执行这个交互式脚本即可，按照脚本执行过程中的提示输入必要的信息就能成功将存档通过 iSCSI 发布出来了。

执行脚本后，会看到 Powershell 控制台上输入内容后会看到以下效果：

![UJfszR.png](https://s1.ax1x.com/2020/07/13/UJfszR.png)

而此时，在 VBR 上会看到发布出来的磁盘信息，它以 Instant Recovery 显示在 VBR 控制台中。

![UJfTSA.png](https://s1.ax1x.com/2020/07/13/UJfTSA.png)

接下来，我们可以来到 iSCSI 客户端上，比如刚刚在脚本执行时输入 IP 地址的机器 10.10.1.175 上，打开 Windows 的 iSCSI Initiator，填入 iSCSI 的 target 为 10.10.1.201，端口默认 3260，来挂载这个 iSCSI 卷了。

在使用结束后，不要忘了在 VBR 上点击 Stop Publishing 来回收这个 iSCSI 卷。

以上就是简单实用的新功能，iSCSI 发布。赶紧下载 VBR 装上试一下吧。

附上脚本：

```powershell
# 本脚本是 Veeam DataIntegration API 的使用样例
# 用于通过 iSCSI 方式将备份数据挂载给指定的系统进行使用
# 使用脚本需要至少有 7 个还原点以上，否则请修改脚本使用
# 脚本暂时仅限 VMware、Hyper-V 的主备份存档，如需 Agent、Backup Copy、Replication、Storage Snapshot，请根据需求修改脚本。
#
# 脚本作者：Wei Lei
# Email:lei.wei@veeam.com
# 脚本版本：v1.1
################# Update log ######################
# 更新了 VBR 用户名密码错误后立刻停止脚本；
# 更新了还原点选择错误后，自动终止脚本；
###################################################

# Script Start
# VBR Server (Server Name, FQDN or IP)
$vbrServer = Read-Host "请输入 VBR 地址，可以是域名或者 IP"
# VBR Credentials
Write-Host "请在弹出对话框中输入 VBR 的用户名密码。"
$Credential=Get-Credential -Message 请输入 VBR 的用户名密码
$vbrusername = $Credential.Username
$vbrpassword = $Credential.GetNetworkCredential().password

#region Connect
# Load Veeam Snapin
If (!(Get-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue))
{
    If (!(Add-PSSnapin -PassThru VeeamPSSnapIn))
    {
        Write-Error "Unable to load Veeam snapin" -ForegroundColor Red
        Exit
  }
}

# Connect to VBR server
$OpenConnection = (Get-VBRServerSession).Server
If ($OpenConnection -ne $vbrServer)
{
    Disconnect-VBRServer
    Try
    {
        Connect-VBRServer -user $vbrusername -password $vbrpassword -server $vbrServer -ErrorAction Stop
    }
    Catch
    {
        Write-Host "无法连接到 VBR 服务器 - $vbrServer" -ForegroundColor Red
        exit
    }
}
#endregion

$VMName = Read-Host "请输入需要用于挂载的虚拟机名称"
$IP =Read-Host "要挂载到哪台服务器（IP 地址）？"
$backup = Get-VBRBackup
$backup = @($backup | ?{$_.JobType -eq "Backup"})
$points = Get-VBRRestorePoint -Backup $backup -Name $VMName | Sort-Object –Property CreationTime –Descending | Select-Object -First 7
if ($points -eq $null)
{
    Write-Host "找不到这台虚拟机的还原点。 - $VMName" -ForegroundColor Red
    exit
}

While($InNumber -ne 7)
    {
    Write-Host "##############已找到虚拟机 $VMName 的最近 7 个还原点##############" -ForegroundColor Green
    $i = 0
    foreach ($pt in $points) 
    {
    $ptctime = $pt.CreationTime
    $i = $i + 1
    Write-Host "#" $i . $ptctime ";"
    }
    Write-Host "#############################################################" -ForegroundColor Green
    
    $InNumber = Read-Host "请选择还原点（1-7）"
    $ss =@()

    switch($InNumber)
    {
        1
        {
            $pt = $points | Select-Object -Index 0
            $pttime = $pt.CreationTime
            Write-Host "已选择还原点 $pttime 。" -ForegroundColor Green
            $ss = Publish-VBRBackupContent -RestorePoint $pt -AllowedIps $IP -RunAsync
        }
        2
        {
            $pt = $points | Select-Object -Index 1
            $pttime = $pt.CreationTime
            Write-Host "已选择还原点 $pttime 。" -ForegroundColor Green
            $ss = Publish-VBRBackupContent -RestorePoint $pt -AllowedIps $IP -RunAsync
        }
        3
        {
            $pt = $points | Select-Object -Index 2
            $pttime = $pt.CreationTime
            Write-Host "已选择还原点 $pttime 。" -ForegroundColor Green
            $ss = Publish-VBRBackupContent -RestorePoint $pt -AllowedIps $IP -RunAsync
        }
        4
        {
            $pt = $points | Select-Object -Index 3
            $pttime = $pt.CreationTime
            Write-Host "已选择还原点 $pttime 。" -ForegroundColor Green
            $ss = Publish-VBRBackupContent -RestorePoint $pt -AllowedIps $IP -RunAsync
        }
        5
        {
            $pt = $points | Select-Object -Index 4
            $pttime = $pt.CreationTime
            Write-Host "已选择还原点 $pttime 。" -ForegroundColor Green
            $ss = Publish-VBRBackupContent -RestorePoint $pt -AllowedIps $IP -RunAsync
        }
        6
        {
            $pt = $points | Select-Object -Index 5
            $pttime = $pt.CreationTime
            Write-Host "已选择还原点 $pttime 。" -ForegroundColor Green
            $ss = Publish-VBRBackupContent -RestorePoint $pt -AllowedIps $IP -RunAsync
        }
        7
        {
            $pt = $points | Select-Object -Index 6
            $pttime = $pt.CreationTime
            Write-Host "已选择还原点 $pttime 。" -ForegroundColor Green
            $ss = Publish-VBRBackupContent -RestorePoint $pt -AllowedIps $IP -RunAsync
        }
        Default 
        { 
        Write-Error "请输入 1-7 之间的数字！"
        Invoke-Command {exit}
        }
    }
    Write-Host "正在挂载还原点。.."
    $state = $ss.StateString
    $ssid = $ss.id
    While ($state -ne "Virtual disks published...")
    {
        Start-Sleep -s 5
        $ss = Get-VBRPublishedBackupContentSession
        $sss = $ss | ?{$_.id -eq $ssid}
        $state = $sss.StateString
    }
    Write-Host "虚拟机 $VMName 的还原点 $pttime 已挂载。" -ForegroundColor Green
    $mountinfo = Get-VBRPublishedBackupContentInfo -Session $sss
    $mountinfomode = $mountinfo.mode
    $mountinfoserverip = $mountinfo.serverips
    $mountinfoserverport = $mountinfo.serverport
    $mountinfodiskname = $mountinfo.disks.diskname
    Write-Host "    挂载点已经通过 $mountinfomode 挂载"
    Write-Host "    挂载磁盘信息： $mountinfodiskname "
    Write-Host "    iSCSI 客户端连接访问地址：$mountinfoserverip "
    Write-Host "    iSCSI 客户端连接访问端口：$mountinfoserverport "
    Invoke-Command {exit}
}

```

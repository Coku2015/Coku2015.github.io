# VDP 安全技术系列（二） - 使用 gMSA 技术托管 Windows 账号


## 系列目录

数据保护不只是备份，它关乎企业的安全的最后一道防线。Veeam 通过零信任设计理念，将安全性融入到产品的每一处细节。从备份的开始到恢复的最后一步，Veeam 不断打磨每一个功能，以满足现代安全需求。本系列汇聚了 VDP v12 版本后新增的安全小技巧，简单易用，却能为数据安全保驾护航。

- 第一篇：免账户和 SSH 服务管理 Linux 备份代理
- 第二篇：使用 gMSA 技术托管 Windows 账号
- 第三篇：四眼认证模式：双人控制管理备份系统操作
- 第四篇：启用多因子认证（MFA）：加强备份系统账户保护
- 第五篇：减少备份中涉及的网络端口
- 第六篇：使用 Syslog 将日志托管至 SIEM 系统



上一篇，我们详细介绍了在 Linux 系统中如何通过免账户和 SSH 服务来管理备份代理。而在 Windows 系统中，情况有所不同，尤其是在 Veeam 备份平台的各种操作场景中，经常会涉及本地管理员账号的使用。例如，在执行虚拟机的 Guest Processing、Indexing 等任务时，以及在管理 Windows 代理或进行各种还原操作时。Veeam 通常会将这些账号储存在本地数据库中，这样做会带来一些潜在的安全风险，攻击者可能会通过破解 Veeam 本地数据库来窃取生成系统的高权限账号；并且还会带来管理上的复杂性，需要定期根据生产系统的需求同步修改存储在备份系统的账户密码，来确保安全性和合规性。

今天，我们就来介绍一种全新的账号使用方式——内置在 Windows 系统中的专用服务账号。Veeam 利用这种技术，可以在进行 Guest Processing 和 Indexing 过程中避免记录 Windows 系统的账户密码，从而进一步减少账号密码泄露的风险。

这个技术叫做 Group Managed Service Account (gMSA)。gMSA 其实是在 Windows 2012 版及以后的版本中推出的技术，尽管已经有 10 多年的历史了，但因其使用相对较少，因此关于它的教程和资料并不常见。

希望这篇文章能够帮助大家更好地理解和应用这一技术！

### 技术背景

gMSA 是一种在 Windows 系统中用于管理和存储服务账户密码的技术，它可以提高安全性并简化管理。它有以下这些特点：

- 动态密码管理：gMSA 的密码是由 AD 管理的，并且会定期自动更改，任何人无法获取也不需要使用这个账号的密码。
- 减少密码风险：使用 gMSA 不需要管理员记住服务密码，系统会自动从 AD 中去调取需要的密码进行工作，并且动态自动更新进一步加强了它的安全性。
- 简化使用流程：在使用了 gMSA 后，备份系统上就不需要去定期手工更新和配置账号密码了，降低了复杂性。

gMSA 技术通过动态管理和自动更新密码的方式，在确保服务稳定性和安全性的前提下，极大地简化了服务账户的管理和维护。它特别适合那些对安全性有较高要求且需要长期运行的备份系统。

### 适用环境

- 必须有 Windows 2012 以上的 AD 管理的环境，所有需要使用这个技术的虚拟机的操作系统必须是 Windows 2012 以上版本。
- 无法用于 Linux 操作系统，即使是将 Linux 系统加入到满足条件的 AD 域中。
- 必须使用 guest Interaction proxy 作为应用感知的处理系统，VIX 模式在这里不工作。
- 所有涉及到的相关系统都必须能够正常访问 AD 资源，能够从 AD 中去取得需要的账号和权限。

### 环境准备和配置步骤

1. 要使用这一技术，首先要对 AD 环境做一些准备工作。前面我们提到，必须在 Windows 2012 及以上版本中进行操作。进入 AD 的管理单元后，检查一个关键条件是否满足：默认的 `Managed Service Accounts` OU 必须正常存在。这个 OU 是系统内置的，默认情况下会存在于 AD 中。如下图：

![Xnip2024-12-08_22-32-43](https://s2.loli.net/2024/12/08/wIigxRL9j5vPhTJ.png)

如果这个 OU 不存在或被意外删除了，那么就无法使用 gMSA 技术。可能需要联系微软技术支   持来恢复这个默认的 OU，手工创建同名 OU 是无效的。


2. 在检查完这个 OU 正常后，需要在域控制器上做一些配置，接下去要做的这些配置大部分要通过 Powershell 的命令来完成。因此需要首先确保 AD 上正确安装了 AD 的 Powershell 管理模块，这个可以通过 Windows 的功能和特性模块来确定安装情况。具体位置如下图：

![Xnip2024-12-08_22-46-07](https://s2.loli.net/2024/12/08/y5CnPvMz4bDR8F7.png)

3. 打开 Powershell，首先要创建一个 root Key，用于自动管理 gMSA 的密码，用以下命令即可：

```powershell
Add-KdsRootKey -EffectiveImmediately
```

需要注意的是，这条命令打完后，虽然参数是立即生效，但是根据我的经验和网上的评论，是隔天生效的，因此如果是跟着我的步骤进行操作的，可以不用接着往下做了，明天回来才能继续进行。

4. 在 AD 中创建一个安全组，在接下去的操作中，我们会把涉及到的相关的所有服务器都放入到这个安全组中，只有在这个组中的服务器，才会被授权使用 gMSA 账号。而不在这个安全组中的计算机，将无权访问 gMSA 账号，这一步骤非常重要。

这个安全组具体创建在哪个 OU 中没有关系，我的这个实验中，我就将它创建在 Users 的 OU 下，如图：

![Xnip2024-12-08_22-58-29](https://s2.loli.net/2024/12/08/gd3pCzl86ufk5wJ.png)

5. 将 VBR 中涉及到的所有服务器，全都添加至这个 Security Group 的 Members 中。我的实验中，会用到两台服务器，一台是需要使用 gMSA 账号管理的备份目标 V100SQL，另外一台是用于做 guest Interaction proxy 的 Win001。如图在 Members 中我已经将他们添加好了：

![Xnip2024-12-08_23-03-05](https://s2.loli.net/2024/12/08/GwcDWO5NlzHpgUJ.png)

需要额外注意的是，在添加 Members 的时候，默认情况下搜索对象时是搜索不到 Computer Name 的，必须在 Select object type 时，加上 Computers 的类型才能够搜索到并添加上。

6. 创建 gMSA 账号，以上准备完成后，接着只需要用以下这个命令，即可完成 gMAS 账号的创建：

```powershell
$gMSAName = 'gmsa01'
$gMSAGroupName = 'gMSAGroup'
$gMSADNSHostName = 'gmsa01.v100lab.local'
New-ADServiceAccount -Name $gMSAName -DNSHostName $gMSADNSHostName -PrincipalsAllowedToRetrieveManagedPassword $gMSAGroupName -Enabled $True
```

创建完成后，gMSA 账号就会出现在`Managed Service Accounts`这个OU下面：

![Xnip2024-12-08_23-11-16](https://s2.loli.net/2024/12/08/fmsdPyVDSknqKWo.png)

7. 这样，AD 上面的配置基本上就完成了，接下去的操作，我们需要到每一台要使用 gMSA 账号的 Windows 系统上进行配置了。在配置之前，我们需要刷新一下刚刚创建的 AD 对象信息，将它同步过来，一般可以通过执行以下命令完成：

```MS-DOS
C:\WINDOWS\system32\klist.exe -lh 0 -li 0x3e7 purge
```

也可以简单粗暴一点，直接重启对应的系统。像我在本次实验中，为了能正常配置，在第六步完成后，我就将我所有的 VM 重启了一遍。

8. 接下来，我先来配置一下 Guest Interaction Proxy，这个配置相对简单一些，允许它进行账号的获取和使用即可，因为我们的 Guest Interaction Proxy 会通过这个账号去发起一些备份操作，因此它需要获得账号的使用权。按照步骤 5 的配置，实际上我们已经正常获得了使用权，此处我们只需要进行一个简单的验证，如果验证结果通过，我们也就无需做更多配置：

```powershell
PS C:\Users\Administrator.V100LAB> Test-ADServiceAccount gmsa01$
True
```

用这个 Test 的命令，只需要保证输出为 True，如果这个输出不为 True 则说明账号没配置成功，需要往上回去检查 1-7 步骤，看看是哪里没有正确配置。

9. 然后，来到目标服务器上，进行相关权限的配置。首先需要做的是将 gmsa 账号装入该目标服务器，命令如下：

```powershell
#测试账号
Test-ADServiceAccount gmsa01$
#安装账号
Install-ADServiceAccount "gmsa01$"
```

一切正常的话，会发现账号已经被安装上了。

10. 配置 gMSA 的本地权限，和其他账号一样，用于 VBR 的备份，我们需要将 gMSA 账号添加到操作系统的本地管理员组，同时对于包含 SQL 的机器，我们需要同样将 gMSA 账号加入到 SQL Server 的 sysadmin 组中。

![Xnip2024-12-08_23-25-56](https://s2.loli.net/2024/12/08/zSQB9o8nMbpRTGY.png)

在添加 SQL 权限时，搜索账号需要特别注意勾选 Service Accounts 选项，否则是搜不到 gmsa 账号的。

![Xnip2024-12-08_23-27-29](https://s2.loli.net/2024/12/08/e3TRqiLrcxzwDkf.png)

以上添加完成后，gMSA 账号的配置就完成了，接下去可以回到 VBR 中配置和测试 gMSA 的账号了。



11. 在 VBR 的备份作业中，开启应用感知选项，在右侧的 Add Credentials 中，可以找到`Managed Service Account...`点击后，会弹出一个仅需要输入用户名的对话框，这样的方式，我们只需要账号，无需密码，就可以将它用于应用感知。从而实现了 VBR 中免密配置应用感知。

![Xnip2024-12-08_23-30-26](https://s2.loli.net/2024/12/08/gyYSJMb6vFpQPZ4.png)

12. 点击 Test Now，测试下这个 gMSA，看看能否正常工作。

![Xnip2024-12-08_23-33-52](https://s2.loli.net/2024/12/08/8VKG3TyZFAsnPoc.png)

可以看到，在使用 gMSA 情况下，Test 是不会去测试 VIX 工作方式的，仅通过 RPC 方式进行验证。



### 总结

以上就是 Windows 下，配置免密的备份账号的方法，例子中以 SQL Server 作为备份对象，如果其他应用程序，也需要配置相应的权限，否则应用感知就会失败。


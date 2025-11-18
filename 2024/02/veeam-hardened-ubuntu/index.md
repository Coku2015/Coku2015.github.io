# Ubuntu系统用于Veeam加固存储库的进一步安全加固


Veeam v12版本发布后，官方手册给出了基于Ubuntu20.04系统构建Veeam加固存储库后[进一步系统安全加固的方法](https://helpcenter.veeam.com/docs/backup/vsphere/hardened_repository_ubuntu_configuring_stig.html?ver=120)，并且提供了全自动配置的脚本，因此在使用我的[Configurator](https://github.com/Coku2015/Veeam_Repo_Configurator)构建完Ubuntu存储库后，可以用这个自动化配置脚本进行更安全的加固。

**由于官方脚本包含了一些美国军方的合规配置，并不适合中国用户使用，我将Veeam官方的脚本进行了一些修改，并进行了重新发布，以适合中国用户使用。**

脚本下载地址：

https://github.com/Coku2015/veeam-hardened-repository

**系统要求:**

- 必须以root用户身份运行
- 必须在一台干净安装的Ubuntu 20.04系统上运行
- 仅支持 Veeam Backup & Replication v12 以上版本

**使用说明:**

1. 通过 SSH 连接到 Ubuntu 20.04 服务器上
2. 复制脚本内容到该服务器上
3. 使用以下命令运行脚本:
```bash
sudo bash veeam.harden.sh > output.txt 2>&1
```

注意: 如果你需要更详细的输出，只需运行以下的命令:
```bash
sudo bash veeam.harden.sh
```

## 脚本加固内容说明

UBTU-20-010005 - Ubuntu 操作系统必须允许用户直接对所有连接类型发起会话锁定。

UBTU-20-010007 - Ubuntu 操作系统必须强制执行 24 小时/1 天作为最短密码生命周期。新用户的密码必须有 24 小时/1 天的最短密码有效期限制。

UBTU-20-010008 - Ubuntu 操作系统必须强制执行 60 天最长密码生存期限制。新用户的密码必须有 60 天的最长密码有效期限制。

UBTU-20-010013 - 在不活动超时后，Ubuntu 操作系统必须自动终止用户会话。

UBTU-20-010014 - Ubuntu 操作系统必须要求用户在权限升级或更改角色时重新进行身份验证。

UBTU-20-010016 - Ubuntu 操作系统默认文件系统权限必须定义为所有经过身份验证的用户只能读取和修改自己的文件。

UBTU-20-010035 - Ubuntu 操作系统必须使用强身份验证器来建立非本地维护和诊断会话。

UBTU-20-010036 - Ubuntu 操作系统在一段时间不活动后必须立即终止与 SSH 流量关联的所有网络连接。

UBTU-20-010037 - Ubuntu 操作系统必须在会话结束时或 10 分钟不活动后立即终止与 SSH 流量关联的所有网络连接。

UBTU-20-010038 - 在授予任何本地或远程系统连接之前，Ubuntu 操作系统必须显示标准强制性 DoD 通知和同意横幅。

UBTU-20-010043 - Ubuntu 操作系统必须将 SSH 守护程序配置为使用采用 FIPS 140-2 批准的加密哈希的消息身份验证代码 (MAC)，以防止未经授权的信息泄露和/或检测传输过程中信息的更改。

UBTU-20-010047 - Ubuntu 操作系统不得允许通过 SSH 进行无人值守或自动登录。

UBTU-20-010048 - 必须配置 Ubuntu 操作系统以禁用远程 X 连接，除非是为了满足记录和验证的任务要求。

UBTU-20-010049 - Ubuntu 操作系统 SSH 守护程序必须阻止远程主机连接到代理显示。

UBTU-20-010050 - Ubuntu 操作系统必须通过要求至少使用一个大写字符来强制密码复杂性。

UBTU-20-010051 - Ubuntu 操作系统必须通过要求至少使用一个小写字符来强制密码复杂性。

UBTU-20-010052 - Ubuntu 操作系统必须通过要求至少使用一个数字字符来强制密码复杂性。

UBTU-20-010053 - Ubuntu 操作系统在更改密码时必须要求更改至少 8 个字符。

UBTU-20-010054 - Ubuntu 操作系统必须强制要求密码长度至少为 15 个字符。

UBTU-20-010055 - Ubuntu 操作系统必须通过要求至少使用一个特殊字符来强制密码复杂性。

UBTU-20-010056 - Ubuntu 操作系统必须禁止使用字典单词作为密码。

UBTU-20-010057 - 必须配置 Ubuntu 操作系统，以便在更改密码或建立新密码时必须使用 pwquality。

UBTU-20-010070 - Ubuntu 操作系统必须禁止密码重复使用至少五代。

UBTU-20-010072 - Ubuntu 操作系统必须自动锁定帐户，直到管理员在尝试登录 3 次失败后释放锁定的帐户。

UBTU-20-010074 - 必须配置 Ubuntu 操作系统，以便每 30 天或更短时间运行一次以检查文件完整性的脚本是默认脚本。

UBTU-20-010075 - Ubuntu 操作系统必须在登录尝试失败后的登录提示之间强制执行至少 4 秒的延迟。

UBTU-20-010100 - Ubuntu 操作系统必须为影响 /etc/passwd 的所有帐户创建、修改、禁用和终止事件生成审核记录。

UBTU-20-010101 - Ubuntu 操作系统必须为影响 /etc/group 的所有帐户创建、修改、禁用和终止事件生成审核记录。

UBTU-20-010102 - Ubuntu 操作系统必须为影响 /etc/shadow 的所有帐户创建、修改、禁用和终止事件生成审核记录。

UBTU-20-010103 - Ubuntu 操作系统必须为影响 /etc/gshadow 的所有帐户创建、修改、禁用和终止事件生成审核记录。

UBTU-20-010104 - Ubuntu 操作系统必须为影响 /etc/opasswd 的所有帐户创建、修改、禁用和终止事件生成审核记录。

UBTU-20-010118 - Ubuntu 操作系统必须在审核失败时默认关闭（除非可用性是首要问题）。

UBTU-20-010122 - 必须配置 Ubuntu 操作系统，以便未经授权的用户无法读取或写入审核日志文件。

UBTU-20-010123 - Ubuntu 操作系统必须配置为仅允许授权用户拥有审核日志文件。

UBTU-20-010124 - Ubuntu 操作系统必须仅允许授权组拥有审核日志文件。

UBTU-20-010128 - 必须配置 Ubuntu 操作系统，以便未经授权的用户无法对审核日志目录进行写访问。

UBTU-20-010133 - 必须配置 Ubuntu 操作系统，以便未经授权的用户无法写入审计配置文件。

UBTU-20-010134 - Ubuntu 操作系统必须仅允许授权帐户拥有审核配置文件。

UBTU-20-010135 - Ubuntu 操作系统必须仅允许授权组拥有审核配置文件。

UBTU-20-010136 - Ubuntu 操作系统必须为成功/不成功使用 su 命令生成审核记录。

UBTU-20-010137 - Ubuntu 操作系统必须为成功/不成功使用 chfn 命令生成审核记录。

UBTU-20-010138 - Ubuntu 操作系统必须为成功/不成功使用 mount 命令生成审核记录。

UBTU-20-010139 - Ubuntu 操作系统必须为成功/不成功使用 umount 命令生成审核记录。

UBTU-20-010140 - Ubuntu 操作系统必须为 ssh-agent 命令的成功/不成功使用生成审核记录。

UBTU-20-010141 - Ubuntu 操作系统必须为成功/不成功使用 ssh-keysign 命令生成审核记录。

UBTU-20-010142 - Ubuntu 操作系统必须为 setxattr、fsetxattr、lsetxattr、removexattr、fremovexattr 和 lremovexattr 系统调用的任何使用生成审核记录。

UBTU-20-010148 - Ubuntu 操作系统必须为 chown、fchown、fchownat 和 lchown 系统调用的成功/不成功使用生成审核记录。

UBTU-20-010152 - Ubuntu 操作系统必须为 chmod、fchmod 和 fchmodat 系统调用的成功/不成功使用生成审核记录。

UBTU-20-010155 - Ubuntu 操作系统必须为 creat、open、openat、open_by_handle_at、truncate 和 ftruncate 系统调用的成功/不成功使用生成审核记录。

UBTU-20-010161 - Ubuntu 操作系统必须为 sudo 命令的成功/不成功使用生成审核记录。

UBTU-20-010162 - Ubuntu 操作系统必须为成功/不成功使用 sudoedit 命令生成审核记录。

UBTU-20-010163 - Ubuntu 操作系统必须为成功/不成功使用 chsh 命令生成审核记录。

UBTU-20-010164 - Ubuntu 操作系统必须为成功/不成功使用 newgrp 命令生成审核记录。

UBTU-20-010165 - Ubuntu 操作系统必须为 chcon 命令的成功/不成功使用生成审核记录。

UBTU-20-010166 - Ubuntu 操作系统必须为成功/不成功使用 apparmor_parser 命令生成审核记录。

UBTU-20-010167 - Ubuntu 操作系统必须为成功/不成功使用 setfacl 命令生成审核记录。

UBTU-20-010168 - Ubuntu 操作系统必须为 chacl 命令的成功/不成功使用生成审核记录。

UBTU-20-010169 - Ubuntu操作系统必须为tallylog文件的使用和修改生成审核记录。

UBTU-20-010170 - Ubuntu操作系统必须为faillog文件的使用和修改生成审核记录。

UBTU-20-010171 - Ubuntu操作系统必须生成lastlog文件的使用和修改的审计记录。

UBTU-20-010172 - Ubuntu 操作系统必须为成功/不成功使用 passwd 命令生成审核记录。

UBTU-20-010173 - Ubuntu 操作系统必须为成功/不成功使用 unix_update 命令生成审核记录。

UBTU-20-010174 - Ubuntu 操作系统必须为成功/不成功使用 gpasswd 命令生成审核记录。

UBTU-20-010175 - Ubuntu 操作系统必须为成功/不成功使用 chage 命令生成审核记录。

UBTU-20-010176 - Ubuntu 操作系统必须为成功/不成功使用 usermod 命令生成审核记录。

UBTU-20-010177 - Ubuntu 操作系统必须为成功/不成功使用 crontab 命令生成审核记录。

UBTU-20-010178 - Ubuntu 操作系统必须为成功/不成功使用 pam_timestamp_check 命令生成审核记录。

UBTU-20-010179 - Ubuntu 操作系统必须为 init_module 和 finit_module 系统调用的成功/不成功使用生成审核记录。

UBTU-20-010181 - Ubuntu 操作系统必须为成功/不成功使用delete_module 系统调用生成审核记录。

UBTU-20-010182 - Ubuntu 操作系统必须生成审计记录和报告，其中包含所有可审计事件和操作的时间、地点、类型、来源和结果的信息。

UBTU-20-010198 - Ubuntu 操作系统必须在系统启动时启动会话审核。

UBTU-20-010199 - Ubuntu 操作系统必须将审核工具配置为 0755 或更宽松的模式。

UBTU-20-010200 - Ubuntu 操作系统必须将审核工具配置为root 所有者。

UBTU-20-010201 - Ubuntu 操作系统必须将审核工具配置为 root 所属组。

UBTU-20-010205 - Ubuntu操作系统必须使用加密机制来保护审计工具的完整性。

UBTU-20-010211 - Ubuntu 操作系统必须防止所有软件以高于执行该软件的用户的权限级别执行，并且必须配置审核系统以审核特权功能的执行。

UBTU-20-010230 - Ubuntu 操作系统必须记录审核记录的时间戳，这些时间戳可以映射到协调世界时 (UTC) 或格林威治标准时间 (GMT)。

UBTU-20-010244 - Ubuntu 操作系统必须为特权活动、非本地维护、诊断会话和其他系统级访问生成审核记录。

UBTU-20-010267 - Ubuntu 操作系统必须为任何成功/不成功使用 unlink、unlinkat、rename、renameat 和 rmdir 系统调用生成审核记录。

UBTU-20-010277 - Ubuntu 操作系统必须为 /var/log/wtmp 文件生成审核记录。

UBTU-20-010278 - Ubuntu 操作系统必须为 /var/run/utmp 文件生成审核记录。

UBTU-20-010279 - Ubuntu 操作系统必须为 /var/log/btmp 文件生成审核记录。

UBTU-20-010296 - 当尝试使用 modprobe 命令成功/失败时，Ubuntu 操作系统必须生成审核记录。

UBTU-20-010297 - 当尝试使用 kmod 命令成功/失败时，Ubuntu 操作系统必须生成审核记录。

UBTU-20-010298 - 当尝试使用 fdisk 命令成功/失败时，Ubuntu 操作系统必须生成审核记录。

UBTU-20-010400 - Ubuntu 操作系统必须将所有帐户和/或帐户类型的并发会话数限制为 10 个。

UBTU-20-010403 - Ubuntu 操作系统必须监视远程访问方法。

UBTU-20-010404 - Ubuntu 操作系统必须使用 FIPS 140-2 批准的加密哈希算法对所有存储的密码进行加密。

UBTU-20-010405 - Ubuntu 操作系统不得安装 telnet 软件包。

UBTU-20-010406 - Ubuntu 操作系统不得安装 rsh-server 软件包。

UBTU-20-010407 - Ubuntu 操作系统必须配置为禁止或限制使用 PPSM CAL 和漏洞评估中定义的功能、端口、协议和/或服务。

UBTU-20-010408 - Ubuntu操作系统必须阻止直接登录root帐户。

UBTU-20-010411 - Ubuntu 操作系统必须在所有公共目录上设置粘滞位，以防止通过共享系统资源传输未经授权和意外的信息。

UBTU-20-010412 - Ubuntu 操作系统必须配置为使用 TCP syncookie。

UBTU-20-010413 - Ubuntu 操作系统必须禁用内核核心转储，以便在系统初始化失败、关闭失败或中止失败时无法进入安全状态。

UBTU-20-010416 - Ubuntu 操作系统必须生成错误消息，提供纠正措施所需的信息，而不泄露可能被对手利用的信息。

UBTU-20-010417 - Ubuntu 操作系统必须将 /var/log 目录配置为 syslog 所属组。

UBTU-20-010418 - Ubuntu 操作系统必须将 /var/log 目录配置为 root 所有。

UBTU-20-010419 - Ubuntu 操作系统必须将 /var/log 目录配置为模式“0755”或较宽松。

UBTU-20-010420 - Ubuntu 操作系统必须将 /var/log/syslog 文件配置为由 adm 组拥有。

UBTU-20-010421 - Ubuntu 操作系统必须将 /var/log/syslog 文件配置为 syslog 所有。

UBTU-20-010422 - Ubuntu 操作系统必须使用 0640 或更低的许可模式配置 /var/log/syslog 文件。

UBTU-20-010423 - Ubuntu 操作系统必须具有包含设置为 0755 或更宽松模式的系统命令的目录。

UBTU-20-010424 - Ubuntu 操作系统必须具有包含 root 拥有的系统命令的目录。

UBTU-20-010425 - Ubuntu 操作系统必须具有包含 root 拥有的系统命令组的目录。

UBTU-20-010426 - Ubuntu 操作系统库文件的许可模式必须为 0755 或更低。

UBTU-20-010427 - Ubuntu 操作系统库目录必须具有 0755 或更低的许可模式。

UBTU-20-010428 - Ubuntu 操作系统库文件必须由root 拥有。

UBTU-20-010429 - Ubuntu 操作系统库目录必须由 root 拥有。

UBTU-20-010430 - Ubuntu 操作系统库文件必须由 root 或系统帐户归组所有。

UBTU-20-010431 - Ubuntu 操作系统库目录必须由 root 归组所有。

UBTU-20-010432 - Ubuntu 操作系统必须配置为保留故障事件的日志记录。

UBTU-20-010433 - Ubuntu 操作系统必须安装应用程序防火墙才能控制远程访问方法。

UBTU-20-010434 - Ubuntu 操作系统必须启用并运行简单防火墙 (ufw)。

UBTU-20-010438 - 必须配置 Ubuntu 操作系统的 Advance Package Tool (APT)，以防止在未验证补丁、服务包、设备驱动程序或 Ubuntu 操作系统组件是否已使用组织认可和批准的证书进行数字签名的情况下安装这些补丁、服务包、设备驱动程序或 Ubuntu 操作系统组件。

UBTU-20-010439 - Ubuntu 操作系统必须配置为使用 AppArmor。

UBTU-20-010448 - Ubuntu 操作系统必须实现地址空间布局随机化，以保护其内存免受未经授权的代码执行。

UBTU-20-010449 - 必须配置 Ubuntu 操作系统，以便 Advance Package Tool (APT) 在安装更新版本后删除所有软件组件。

UBTU-20-010450 - Ubuntu 操作系统必须使用文件完整性工具来验证所有安全功能的正确运行。

UBTU-20-010451 - 如果基线配置被未经授权的方式更改，Ubuntu操作系统必须通知指定人员。当发现基线配置发生更改或任何安全功能运行异常时，文件完整性工具必须通知系统管理员。

UBTU-20-010453 - Ubuntu 操作系统必须在登录时显示上次成功登录帐户的日期和时间。

UBTU-20-010454 - Ubuntu 操作系统必须启用应用程序防火墙。

UBTU-20-010456 - Ubuntu 操作系统必须将系统命令设置为 0755 或更宽松的模式。

UBTU-20-010457 - Ubuntu 操作系统必须具有 root 或系统帐户拥有的系统命令。

UBTU-20-010458 - Ubuntu 操作系统必须具有 root 或系统帐户拥有的系统命令组。

UBTU-20-010460 - Ubuntu 操作系统必须禁用 x86 [Ctrl+Alt+Delete] 组合键。

UBTU-20-010462 - Ubuntu 操作系统不得将帐户配置为空白或空密码。

UBTU-20-010463 - Ubuntu 操作系统不得允许使用空白或空密码配置的帐户。

UBTU-20-010461 - Ubuntu 操作系统必须禁用通用串行总线 (USB) 大容量存储驱动程序的自动挂载。


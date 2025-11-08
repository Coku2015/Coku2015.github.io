# Veeam Hardened Linux Repository Configurator


## 脚本用途
根据Veeam最佳实践，一键脚本配置Linux系统，操作系统配置完成后，可以回到VBR控制台完成存储库的添加。
关于手工配置和原理介绍，请参考以下帖子：

[veeam-v11-hardened-linux-repository-配置指南-centos8](https://community.veeam.com/vug-china-85/veeam-v11-hardened-linux-repository-配置指南-centos8-1188)

[加固的备份存储库hardened-repository配置指南-ubuntu](https://community.veeam.com/vug-china-85/加固的备份存储库hardened-repository配置指南-ubuntu-1093)

[veeam-hardened-repository-quick-starter](https://community.veeam.com/vug-china-85/veeam-hardened-repository-quick-starter-1410)


## 使用前提条件
1. 确保系统满足使用Veeam Hardened Linux Repository的最低要求。
2. 服务器上有未格式化的磁盘/dev/sdb，/dev/sdc等。
3. 必须使用root账号运行本脚本。

## 系统要求
本脚本在Redhat 8.2/CentOS 8.2/Ubuntu 20.04以上版本中测试通过，其他系统版本暂不支持。

## 脚本仓库

https://github.com/Coku2015/Veeam_Repo_Configurator

## 脚本使用详解
下载脚本：
```bash
curl -O https://ghproxy/https://raw.githubusercontent.com/Coku2015/Veeam_Repo_Configurator/main/HLRepo_configurator.sh
```

运行脚本
```bash
bash HLRepo_configurator.sh
```

1. 脚本运行后，会首先检测当前是否为root用户以及相应的操作系统，如果不是则退出脚本。
2. 提示用户设定Veeam存储管理用户、密码和备份数据的存放路径，这些信息将会用于VBR控制台上的后续配置。
[![bkKvAe.png](https://s4.ax1x.com/2022/02/24/bkKvAe.png)](https://imgtu.com/i/bkKvAe)
3. 为服务器上空闲的磁盘创建LVM卷，并格式化成xfs文件系统，启用reflink功能用于VBR的fast clone功能。
4. 往/etc/fstab文件中添加记录并挂载格式化后的磁盘空间，分配用户权限。
[![bkKzhd.png](https://s4.ax1x.com/2022/02/24/bkKzhd.png)](https://imgtu.com/i/bkKzhd)
5. 回VBR控制台配置备份存储库，配置完成后，脚本会锁定Veeam存储管理用户，禁止登陆，同时提示用户禁用SSH访问，进一步加固系统。
[![bkKxtH.png](https://s4.ax1x.com/2022/02/24/bkKxtH.png)](https://imgtu.com/i/bkKxtH)


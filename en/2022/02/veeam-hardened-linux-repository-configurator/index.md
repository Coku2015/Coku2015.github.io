# Veeam Hardened Linux Repository Configurator


## Script Purpose
According to Veeam best practices, this one-click script configures a Linux system. After the operating system configuration is complete, you can return to the VBR console to complete the repository addition.

For manual configuration and principle introduction, please refer to the following posts:

[veeam-v11-hardened-linux-repository-配置指南-centos8](https://community.veeam.com/vug-china-85/veeam-v11-hardened-linux-repository-配置指南-centos8-1188)

[加固的备份存储库hardened-repository配置指南-ubuntu](https://community.veeam.com/vug-china-85/加固的备份存储库hardened-repository配置指南-ubuntu-1093)

[veeam-hardened-repository-quick-starter](https://community.veeam.com/vug-china-85/veeam-hardened-repository-quick-starter-1410)

## Prerequisites for Use
1. Ensure the system meets the minimum requirements for using Veeam Hardened Linux Repository.
2. The server has unformatted disks such as /dev/sdb, /dev/sdc, etc.
3. This script must be run using the root account.

## System Requirements
This script has been tested on Redhat 8.2/CentOS 8.2/Ubuntu 20.04 and above versions. Other system versions are not currently supported.

## Script Repository

https://github.com/Coku2015/Veeam_Repo_Configurator

## Detailed Script Usage
Download the script:
```bash
curl -O https://ghproxy/https://raw.githubusercontent.com/Coku2015/Veeam_Repo_Configurator/main/HLRepo_configurator.sh
```

Run the script:
```bash
bash HLRepo_configurator.sh
```

1. After the script runs, it will first detect whether the current user is root and the corresponding operating system. If not, the script will exit.
2. It will prompt the user to set the Veeam storage management user, password, and the storage path for backup data. This information will be used for subsequent configuration in the VBR console.
[![bkKvAe.png](https://s4.ax1x.com/2022/02/24/bkKvAe.png)](https://imgtu.com/i/bkKvAe)
3. Create LVM volumes for idle disks on the server, format them as XFS file system, and enable reflink functionality for VBR's fast clone feature.
4. Add records to the /etc/fstab file and mount the formatted disk space, allocating user permissions.
[![bkKzhd.png](https://s4.ax1x.com/2022/02/24/bkKzhd.png)](https://imgtu.com/i/bkKzhd)
5. Return to the VBR console to configure the backup repository. After the configuration is complete, the script will lock the Veeam storage management user, prohibit login, and prompt the user to disable SSH access to further harden the system.
[![bkKxtH.png](https://s4.ax1x.com/2022/02/24/bkKxtH.png)](https://imgtu.com/i/bkKxtH)


# Veeam Agent for Linux 101


Since Veeam Agent for Linux 4.0 (VAL) launched alongside VBR v10 earlier this year, this increasingly powerful backup agent has seen widespread adoption across various scenarios—cloud and on-premises, virtual and physical—there's always a use case for VAL. However, we've found that newcomers to VAL often struggle with the agent installation process. Even with fully automated push installations, many users encounter various installation issues. This has created an awkward situation for Veeam backup software, which is renowned for its excellent user experience, making the "It just works!" slogan difficult to confidently claim.

In reality, Veeam remains just as simple, and VAL delivers that same extremely simple experience. Even in the Linux open-source world, where the entry barrier is slightly higher, with just a little attention, you can experience VAL's extremely simple user experience. Of course, this requires a few small tricks. For friends skilled in Linux usage, these aren't problems at all. But for many backup administrators who only encounter Linux for the purpose of backup, it can be somewhat challenging. The main reason stems from VAL's software installation dependency packages. Unlike Windows, where Veeam integrates all required dependency packages into the Veeam software itself for all Windows Server installations, VBR automatically pushes all missing dependency packages. For Linux, however, the Veeam software package doesn't actually contain any dependency packages—**<u>all these dependency packages come from the Linux system's own Software Package Manager</u>**. This is a key point to emphasize!

What is a Package Manager?

To put it simply, it's similar to your phone's app store. Every Linux system comes with such a Package Manager built-in, and different distributions of Linux might use different Package Managers. Package Managers are very intelligent. In most mainstream Linux distributions, the simplest way to install software is typically through a single command from the Package Manager. The Package Manager automatically completes the installation of all dependency components and ultimately delivers the corresponding software for the administrator to use.

Among the various operating systems supported by VAL, different systems use different Package Managers. Below is the list of Package Managers corresponding to these systems.

| Linux Distribution                  | Default Common Package Manager |
| ----------------------------------- | ------------------------------ |
| CentOS/Redhat/Oracle Linux/Fedora   | yum                            |
| Debian/Ubuntu                       | Apt                            |
| SLES/openSUSE                       | zypper                         |

Obviously, regardless of the installation method used, the first prerequisite for properly installing VAL is that the Package Manager can function normally. In Linux systems with internet connectivity, this is completely fine—in the vast majority of cases, appropriate software installation sources are included after system installation. However, in server data centers without internet access, if internal sources aren't properly configured, various errors will occur. The solution is also very simple—just go to the corresponding Linux distribution's official website, download the latest ISO for the current version, and create a local source. For example, download CentOS 6.10 for CentOS 6.x, download CentOS 7.8.2003 for CentOS 7.x, then mount it in CentOS. This article uses the common CentOS 7.6 as an example to explain the complete configuration process.

1. First, find a CentOS 7.8.2003 mirror download site, such as Alibaba Cloud's
   https://mirrors.aliyun.com/centos/7.8.2003/isos/x86_64/
2. In CentOS, mount the just-downloaded image.

```bash
[centos@localhost ~]$ sudo mkdir /mnt/cdrom
[centos@localhost ~]$ sudo mount /dev/cdrom /mnt/cdrom
```

3. Backup and move /etc/yum.repo.d/CentOS-Base.repo to ensure the system doesn't use the default internet yum source.

```bash
[centos@localhost ~]$ sudo mv /etc/yum.repo.d/CentOS-Base.repo ~/CentOS-Base.repo
```

4. Edit /etc/yum.repo.d/CentOS-Media.repo, where you need to modify the baseurl field and the enabled field. The baseurl should point to the local source's ISO path, which is the mounted path /mnt/cdrom from step 2; enabled should be set to enable this source configuration file.

```bash
[centos@localhost ~]$ sudo vi /etc/yum.repo.d/CentOS-Media.repo

# CentOS-Media.repo
#
#  This repo can be used with mounted DVD media, verify the mount point for
#  CentOS-7.  You can use this repo and yum to install items directly off the
#  DVD ISO that we release.
#
# To use this repo, put in your DVD and use it with the other repos too:
#  yum --enablerepo=c7-media [command]
#
# or for ONLY the media repo, do this:
#
#  yum --disablerepo=\* --enablerepo=c7-media [command]

[c7-media]
name=CentOS-$releasever - Media
baseurl=file:///mnt/cdrom/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

~
"/etc/yum.repos.d/CentOS-Media.repo" 22L, 630C

```

5. After configuration is complete, execute `yum clean all` and `yum makecache` commands to update yum information and check availability, use yum repolist to list local source detailed information.
```bash
[centos@localhost ~]$ sudo yum clean all
[centos@localhost ~]$ sudo yum makecache
[centos@localhost ~]$ sudo yum repolist
```

6. Next, returning to VBR, whether using VBR's push VAL installation or manually executing the standalone version of VAL installation, everything will proceed smoothly. All missing dependency packages will be automatically found by yum from the optical disc image and installed.

That's all for today's post. I hope this helps friends who are just getting started with Veeam Agent for Linux. Additionally, I recently launched a brand new daily image WeChat official account where everyone can receive a very simple Veeam operation example every day, helping everyone quickly understand Veeam configuration methods. You're all welcome to follow.


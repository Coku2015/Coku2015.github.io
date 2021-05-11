---
layout: post
title: 用了这个方法，您的备份数据再也不怕被勒索了
tags: VBR, v11实用技巧
---

勒索病毒自从2017年5月12日大规模爆发以来，在过去的4年里，也不断的自我进化，产生各种变种病毒，并且学会了各种弱点攻击，甚至是买通了门卫大叔...

[![6TARg0.jpg](https://z3.ax1x.com/2021/03/22/6TARg0.jpg)](https://imgtu.com/i/6TARg0)

但是不管怎么样，门卫大叔是我们最值得信赖的，是我们的最后一道防线，我今天就想来和大家聊聊如何基于这最后一道防线，来构建我们安全的备份数据环境。

### 实现效果

先来说说实现效果：

- 存放数据的设备我们选用大容量磁盘的机架式服务器，满配SATA硬盘，实现机架上容量密度最大化且每TB容量成本最低，这部分非常容易实现，咨询各大服务器厂商购买这样的服务器就行了。
- 这台机架服务器上线提供服务后，禁用所有账号的远程登录行为。唯一可访问的方式被限制在使用服务器上外接显示器、键盘和鼠标才能访问控制台。上架后对机柜进行上锁，控制机柜钥匙。
- 网络交换机和防火墙上，无需修改和设置这台服务器的任何访问，因为本身端口和服务的限制，这台服务器只被开放了Veeam服务用到的2500-3300的数据传输端口，这个数据传输链路仅限Veeam Datamover组件访问。
- 对于Veeam服务，只允许将数据写入到这个存储设备和从这个设备读取数据，而无法进行这些写入数据的修改和删除。

简单来说，就是这台设备只留了单通道使数据从Veeam进入这台服务器，进入后就被封起来了，只让外界通过Veeam的透明数据封存边界能读取数据并使用数据。

### 实现工具

非常简单，只需要Linux和Veeam v11，任何Veeam版本都具备这个功能，包括社区版。在v11新产品特性中，它叫Hardened Linux Repository。它有两部分功能组成：

1. Single-use credentials for hardened repository

   这个功能，用来完成对数据存储设备的初始配置，在初始配置时，会使用到一个单次使用的配置用途的账号，这个账号不会记忆留存于Veeam的任何服务上，并且在初始配置结束后，就可以禁用这个账号的远程访问以及sudo权限了。

2. immutable flag

   这个功能，用来建立透明的数据封存边界，允许Veeam写入并读取数据，但是不允许Veeam来删除和修改已写入的数据。当然为了平衡容量，immutable被设计成一个时间周期，指定周期内的短期数据才会进入封存边界内，而超过了这个周期的数据自动从边界内退出来，从而实现过期后可以被删除后释放空间。

### 配置方法

以下配置方法包括Linux服务器上的配置和Veeam存储库的配置，其中Linux以Ubuntu 20.04LTS为例子来说明，其他发行版请各位大拿自行修改。

#### Ubuntu Repository预配置

1. 创建用于一次性登录配置的用户。

```bash
admin@hardenedrepo:~$ sudo useradd -m veeamrepo
admin@hardenedrepo:~$ sudo passwd veeamrepo
```

2. 准备好相应备份空间格式化完成，并挂载到Ubuntu中的目录，比如/backupdata，请通过以下命令确认挂载结果。

```bash
admin@hardenedrepo:~$ df -h | grep /backupdata
```

3. 赋予veeamrepo管理备份空间的权限。

```bash
admin@hardenedrepo:~$ sudo chown -R veeamrepo:veeamrepo /backupdata
```

4. 修改sudoers配置文件，临时赋予veeamrepo用户sudo权限。

```bash
admin@hardenedrepo:~$ sudo vi /etc/sudoers
```

   			添加以下信息到sudoers文件后，保存。

```bash
veeamrepo			ALL=(ALL:ALL) ALL
```

这样，Ubuntu这边就算配置完成了，可以到Veeam中配置Hardened Repository了。

#### VBR的配置

1. 选择配置Repository，配置类型为Direct attached Storage -> Linux。整个过程和以往普通的Linux Repository无任何区别，唯一不同的是，在配置New Linux Server的SSH Connection时，选择使用“Single-use credentials for hardened repository...”这个方式作为Credentials的选项，如下图：

[![6TAWvV.png](https://z3.ax1x.com/2021/03/22/6TAWvV.png)](https://imgtu.com/i/6TAWvV)

2. 填入veeamrepo的账号和密码，并允许自动提权使用sudo。接下去其他步骤和普通Linux存储库添加完全一致。

[![6TAjKK.png](https://z3.ax1x.com/2021/03/22/6TAjKK.png)](https://imgtu.com/i/6TAjKK)

3. 在创建repository向导的Repository步骤中，勾选Mark recent backups immutable for: xx days 的复选框，并在空格处填入具体的天数，如下图：

[![6TA4DU.png](https://z3.ax1x.com/2021/03/22/6TA4DU.png)](https://imgtu.com/i/6TA4DU)

这样，VBR中的Repository也配置完成，我们需要再回到Ubuntu中，做一些后续的进一步安全加固，来确保数据的安全。

#### Ubuntu加固处理配置

1. 重新修改/etc/sudoers文件，取消veeamrepo用户的sudo权限，收回管理员权限。修改方法很简单，只需要将之前添加的内容前加上#注释即可。
2. 关闭ssh服务，禁止任何用户通过ssh登录。

```bash
admin@hardenedrepo:~$ sudo systemctl disable ssh
admin@hardenedrepo:~$ sudo systemctl stop ssh
```

3. 关闭其他相关网络服务，不允许其他任何非Veeam应用的访问。

至此，所有配置完成，剩下的就是像使用其他普通存储一样，去使用这个存储库了，所有Veeam的功能，不管是备份、即时恢复、细颗粒度对象恢复、备份校验以及数据实验室，都不受任何影响。

以上就是今天的内容，更详细的配置过程，请参考官网的用户手册。
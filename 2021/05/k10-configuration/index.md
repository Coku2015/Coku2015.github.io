# Kasten K10 入门系列 03 - K10 备份和恢复


## Kasten K10 入门系列目录

[Kasten K10 入门系列 01 - 快速搭建 K8S 单节点测试环境](https://blog.backupnext.cloud/2020/12/Setting-up-quick-demo-for-K10-01/)

[Kasten K10 入门系列 02 - K10 安装](https://blog.backupnext.cloud/2021/05/K10-setup/)

## 正文

之前我介绍了 K10 的安装，整个安装过程其实就是一行`helm install`命令，在安装完成后，后续的使用可以通过浏览器打开 K10 的仪表盘，进行 K10 备份系统的配置、K10 备份策略管理和数据恢复。

和所有的备份系统一样，在开始备份工作之前，需要为 K10 配置一个数据存放的位置，用于存放备份数据。目前 K10 支持将数据存放至对象存储中，暂时还没加入 VBR Repository。在 K10 的 Settings 中可以找到 Locations 设置，这就是 K10 的备份存储库，在这个 Locations 中，如图使用 New Profiles 按钮即可。

[![ghQEBq.png](https://z3.ax1x.com/2021/05/18/ghQEBq.png)](https://imgtu.com/i/ghQEBq)

新建时需要提供 S3 的访问地址、access key 和 secret key 就可以完成 Locations Profile 的配置了。在配置完成后，后续的备份策略设置中就可以将备份数据 Export 指向到这个备份存储库中。

在 K10 中，不需要去添加备份对象，K10 能够自动发现当前 K10 实例运行的 Kubernetes Cluster 中的所有 Application，这一点上，和以往的备份软件有很大的不同。

初始化的配置除了设置 Locations 之外，还需要去启用 K10 Disaster Recovery，只有启用了这一步操作后，K10 才能在当前 Kubernetes Cluster 出现任何故障时，恢复我们之前备份的数据。这个 Disaster Recovery 将当前群集中 K10 的备份 catalog 库储存到了对象存储中，群集出现任何问题，都可以在新的群集中恢复备份存档的 catalog，提取数据恢复。

[![ghQAun.png](https://z3.ax1x.com/2021/05/18/ghQAun.png)](https://imgtu.com/i/ghQAun)

配置 K10 DR 时，管理员需要将 K10 DR 启用后显示在屏幕上的 Cluster ID 记录下来，妥善保存好，用于后续的 K10 catalog 的恢复。另外，在启用 K10 DR 时，系统会提示输入一个“通行码（passphrase）”，用于在恢复时，创建 dr-secret。因此这个通行码也需要和 Cluster ID 一样，被妥善保管。

![dr_policy_form](https://docs.kasten.io/latest/_images/dr_policy_form1.png)

## 备份

K10 的备份都是通过 Policy 来发起。在仪表盘正中间位置就是 Policy 相关的内容，包括显示当前的 Policy 总数和新建 Policy。

[![ghQicj.png](https://z3.ax1x.com/2021/05/18/ghQicj.png)](https://imgtu.com/i/ghQicj)

要保护一个 Application，需要管理员通过 new policy 来打开 Policy 的配置页面。如下图，在这个配置页面中需要填入一些相关信息才能完成备份策略的创建。

[![ghQVH0.jpg](https://z3.ax1x.com/2021/05/18/ghQVH0.jpg)](https://imgtu.com/i/ghQVH0)

创建完成后，可以在 Policies 中查看到这个 Policy，并且可以通过 run once 来做一个单次备份作业的发起和运行，而正常情况，Policy 就会根据计划任务的设置，自动在设定的时间运行。

[![ghQP3Q.png](https://z3.ax1x.com/2021/05/18/ghQP3Q.png)](https://imgtu.com/i/ghQP3Q)

## 恢复

数据完成备份后，可以在 Applications 中看到应用的状态变成了 Compliant

[![ghQSN8.png](https://z3.ax1x.com/2021/05/18/ghQSN8.png)](https://imgtu.com/i/ghQSN8)

而在 Restore Points 中能看到不同的还原点。

[![ghQp4S.png](https://z3.ax1x.com/2021/05/18/ghQp4S.png)](https://imgtu.com/i/ghQp4S)

选择还原点后，可以还原整个应用，也可以删除还原点。

[![ghQC9g.png](https://z3.ax1x.com/2021/05/18/ghQC9g.png)](https://imgtu.com/i/ghQC9g)

以上就是本节内容 K10 的基本备份和恢复，完全图形化界面，使用非常简单。更多内容欢迎关注本系列后续更新。


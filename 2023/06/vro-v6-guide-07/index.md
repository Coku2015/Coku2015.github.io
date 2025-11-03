# VRO 基础入门（七） -  Plan Step · 上篇


## 系列目录：

- [VRO 基础入门（一）-  简介](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-01/)
- [VRO 基础入门（二）-  安装与部署](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-02/)
- [VRO 基础入门（三）-  基本组件 · 上篇](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-03/)
- [VRO 基础入门（四）-  基本组件 · 下篇](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-04/)
- [VRO 基础入门（五）-  成功灾备计划的第一步](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-05/)
- [VRO 基础入门（六）-  数据实验室](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-06/)
- [VRO 基础入门（七）-  Plan Step  · 上篇](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-07/)
- [VRO 基础入门（八）-  Plan Step  · 下篇](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-08/)
- [VRO 基础入门（九）-  文档模板解析](https://blog.backupnext.cloud/2023/10/VRO-v6-Guide-09/)
- [VRO 基础入门（十）-  使用 VRO 搭配 K10 实现全自动容器灾备](https://blog.backupnext.cloud/2023/11/VRO-v6-Guide-10/)

在之前的帖子中，我们详细讨论了 Orchestration Plan 的创建过程。在每个 Orchestration Plan 中除了基础的这些创建步骤之外，这个系统重最重要的是它的自动化流程，这个自动化流程是通过 Powershell 脚本来实现。在 VRO 中，这些 Powershell 的自动化脚本被封装在 Plan Step 中，由 VRO 的 Orchestration Plan 来调度执行和传递参数。

每个 Orchestration Plan 创建时，会带入默认的几个 Plan Steps，这几个基本上就是我们每次灾备都会涉及的开机关机等操作。管理员可以编辑 Orchestration Plan，在其中加入一些额外的 Steps。

## Orchestration Plan 的详细管理和使用方法
在 VRO 的主界面中，找到左边的 Orchestration Plans，点击它后进入 Orchestration Plans 仪表盘，选择一条我们要编辑的 Plan，点击 Plan 名字，即可进入该 Plan 内。

[![pCm6f56.png](https://s1.ax1x.com/2023/06/13/pCm6f56.png)](https://imgse.com/i/pCm6f56)

在 Plan Details 中，可以看到从左到右的 5 个按钮分别是 Run、Halt、Check、Undo 和 Edit，其中包含了三大经典按键：Run 是执行键，Halt 是暂停键，Undo 是取消键。除了这 3 个之外，Check 是 Plan 检查就绪状态的按键，如果就绪状态 failed，那么这个计划在执行时很大可能就会失败；Edit 是今天要详细介绍的，我们用来加入自动化流程的主要按键。点击 Edit 之后，能进入 Plan 的编辑界面。

[![pCm6cr9.png](https://s1.ax1x.com/2023/06/13/pCm6cr9.png)](https://imgse.com/i/pCm6cr9)

在 Plan Edit 界面中，整个布局呈从左到右的顺序排列，在最左边的框中是计划的分组，点击左边的框中的内容后往右依次会展示这个对象下的包含的对象和可用操作。

[![pCm6gbR.png](https://s1.ax1x.com/2023/06/13/pCm6gbR.png)](https://imgse.com/i/pCm6gbR)

在最左边的框中有 Pre-Plan Steps 和 Post-Plan Steps 这两个默认的分组和用户定义分组，其中位于两个默认组中间的用户定义分组是有比较多的调整内容的部分，可以通过 Add 或 Properties 打开设置向导，进行一些配置，这些配置和之前提到的创建 Orchestration Plan 中的部分内容基本相同，换句话说就是在创建完 Plan 后，还需要调整创建过程中的部分参数，可以来这里调整。

[![pCm6WUx.png](https://s1.ax1x.com/2023/06/13/pCm6WUx.png)](https://imgse.com/i/pCm6WUx)

而对于 Pre-Plan steps 和 Post Plan steps 这两个 Group 来说，这两个 Step 并不包含任何的实际机器，因此使用者无法调整这两个 Plan 的任何属性。然而 VRO 能够让我们往这两个 Plan Steps 的 Group 中添加一些 steps，这就能够让我们能够在 VRO 的正式执行 Plan 之前或者之后执行一些自定义流程了。点击 Pre-Plan Step 后，右边的框会出现具体 Steps 的选项，默认情况下，里面没有任何记录，可以通过 Add 按钮来添加，如下图。

[![pCm6RV1.png](https://s1.ax1x.com/2023/06/13/pCm6RV1.png)](https://imgse.com/i/pCm6RV1)

在这里可以添加的 VRO 系统内置的 Step 有：

- Generate Event - 生成一个 Windows 事件，记录在 Windows event viewer 中。
- Send Email - 发送电子邮件。
- Veeam Job Actions - 操作 VBR 上的备份或者复制作业，可以进行 Enable、Disable、Start、Stop 这 4 个操作。
- VM Power Actions - 操作 VC 上的虚拟机开关机，这对于灾备中心切换前关闭不重要的机器释放资源用于切换会非常有用。
- 其他任何用户定义的 Powershell 脚本。

对于用户定义分组，里面包含的是实际要做 restore 或者 failover 的机器，这时候，当我选择某个机器时，VRO 就会让我定义这台机器执行 restore 或者 failover 时我需要加入的 Step，对于已经添加的 Step，也可以修改执行先后顺序和定义详细参数。

[![pCmgf1O.png](https://s1.ax1x.com/2023/06/13/pCmgf1O.png)](https://imgse.com/i/pCmgf1O)

在这里出厂内置的 Step 有以下这些，我做了个简单的分类：

- 应用验证类：12 个（AD、Exchange、Sharepoint、SQL 和 IIS）
- 虚拟机验证类：2 个（心跳和 ping 包）
- 事件通知类：2 个（Windows Event 和邮件）
- 资源操作类：3 个（虚拟机开关机、Windows 服务启动、源虚拟机关机）

## Plan Step 通用参数

在每个 Plan Step 中，都会包含一个最基础的`Common Parameter`，这是对于这个 Plan Step 执行的基本控制条件，包含以下内容：

 - During Failback & Undo : 决定在 Failback 和 Undo Failover 操作时是否执行脚本
 - During Lab Test                : 决定在 Datalab 测试中是否使用脚本
 - Critical step                       : 定义这个 Step 对于整个 Plan 是否重要，如果是，则失败后立刻停止计划
 - Timeout                              : 定义整个 Step 执行超时时间
 - Retries                                 : 定义失败重试次数

这些参数可以在每个 Orchestration Plan 中为每个 step 单独调整。

[![pCmgW9K.png](https://s1.ax1x.com/2023/06/13/pCmgW9K.png)](https://imgse.com/i/pCmgW9K)

## 自定义脚本

VRO 还提供了自定义脚本功能，管理员可以在 VBR 服务器或者恢复后的系统上直接调用使用 Powershell 脚本，完成各种骚操作。

举个例子，数据中心某应用架构如下：

![3a3EyF.png](https://s2.ax1x.com/2020/02/26/3a3EyF.png)

典型的三层架构，Oracle 数据库在 AIX 小机上，中间件和应用服务器跑在 VMware vSphere 上面。灾备系统设计之初，Oracle 数据库通过 OGG 做了复制，实现了数据级同步。

这样的架构，通常 Veeam 使用 VBR 的时候会建议用户对虚拟化平台也做一个保护，确保在主数据中心出现故障的时候能够应用系统和数据库都切换至灾备中心。而在使用了 Veeam 的解决方案后，通常我们的用户都会发现，VBR 不仅能够很好的完成虚拟化平台的灾备复制任务，同时他的灾备演练能力也极其强大，系统会真实的被恢复出来并且提供恢复后的演练访问，真枪实弹的完成整个演习过程，并且还是全自动的。

但是，管理员很快会发现，很尴尬的一点是，应用系统没有数据库的数据支持，就算恢复了，也没办法正常工作，这样的测试还是无法最终等效于实际灾备场景。

## VRO 来帮忙

这事情借助 VRO，可以完美的解决。整个过程会是这样：

1. 启动应用系统的 Failover / Restore Plan，可以在真正的恢复过程前的 Step 中，加入 Powershell 脚本，和灾备站点的 AIX 进行通讯。
2. AIX 上脚本执行后，新的 LPAR 部署出来。
3. 再来一个脚本，将一个虚拟网卡 attach 到新部署出来的 LPAR 上，并让这个网卡和我们在虚拟化环境中创建出来的沙盒隔离网络相连，隔离网络无法直接路由访问到生产，所以是相对隔离的环境。
4. 第三个脚本搞起，让最新的一份 Oracle 数据库运行在这个新的 LPAR 上。
5. 一切准备结束，启动虚拟化灾备平台中的应用和中间件副本，这样在这个隔离环境中，起来的应用和中间件就可以访问 AIX 数据库了。
6. 到这里还没完工，系统都跑起来了，让这套系统别停下，飞一会儿吧，可以在上面做一系列测试、开发等等操作。
7. 经过一段漫长的测试，系统使用完毕，灾备管理员被通知可以回收了。灾备管理员操作 VRO，让系统进入下一步流程。
8. vSphere 上的虚拟机被 Undo Failover 到演练之前的状态，这个非常简单，和 VBR 上几乎没差别。
9. 一个新的脚本被触发，通知 AIX，请删除这个 LPAR 和他上面的数据库，确保测试的数据不会被复制回生产中。

以上这个过程，是不是很不错？这样的过程不仅可以是加入和 AIX 的配合，同样各种系统不管是 HPUX 还是 Oracle Exadata 都可以搞一搞。对了，还有公有云，一起加入到这个灾备 Party 中吧，有了 VRO，这都不是事。

所以，有了自定义脚本和计划任务的调度，VRO 神通广大，几乎能做任何由 Powershell 可以实现的事情。在下一篇，我会来详细介绍如何玩转这个自定义脚本。


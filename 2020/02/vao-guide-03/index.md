# VAO 基础入门（三） -  基本组件 · 上篇


## 系列目录：

- [VAO 基础入门（一）-  简介](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO 基础入门（二）-  安装与部署](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO 基础入门（三）-  基本组件 · 上篇](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO 基础入门（四）-  基本组件 · 下篇](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO 基础入门（五）-  基础配置要点](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO 基础入门（六）-  成功灾备计划的第一步](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO 基础入门（七）-  Plan Step  · 上篇](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO 基础入门（八）-  Plan Step  · 下篇](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO 基础入门（九）-  文档模板解析](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)

VAO 引入了一套非常特殊的概念，它为该产品中使用的组件定义了一系列名称，随着版本的更新和迭代，这里的组件和名称可能会发生一些变化。目前 VAO 的版本是 v2.0，因此本文所述内容仅适用于 v2.0 之后的版本，而后续版本中如果有新的变化，我会在后续的更新中说明。

## Scope

#### 定义和用途

Scope 是 VAO 的最核心的概念，在 v2.0 中首次引入了这个概念。每个 Scope 中包含了灾备中需要一系列元素，VAO 把这些元素称为 Plan Components：

```
 - VM Groups
 - Recovery Locations
 - Plan Steps
 - Credentials
 - Template Jobs
```

打个比方，Scope 是一间房间，那么在这个房间中所放置的各种家具就是以上这些 Plan Components。对于灾备来说，以上这些 Plan Components 将会在 Orchestration Plan 中被具体使用到。可以说 Orchestration Plan 是将这些 Plan Components 有序的组合起来，最终可以让我们实现一键的灾备恢复。

另外，Scope 中还有个非常特殊的 Component -- Datalab，每一个 Datalab 对应某个 Scope 中，也就是说，每个 Scope 都有**一个或多个**独立的属于自己的 DataLab。

关于 Plan Components 和 DataLab，将在 [VAO 基础入门（四）-  基本组件 · 下篇](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/) 中详细介绍。

#### 分类和创建方式

VAO 中的 Scope 可以大致分为两类，一类是系统内置的名称叫`Default`的 Scope，这个 Scope 无法删除，无法修改名称，并且 Administrator 的 Role 会被包含在这个 Scope 中，在 VAO 的其他 Scope 中是无法选择添加 Administrators Role。当您要授予任何用户执行`Administration`配置操作时，您就需要将该用户添加至`Default` Scope 下的 Administrators Role。还记不记得在前一篇推送中提到的初始化步骤，在初始化过程中所添加的用户，默认就会被添加到这个 Administrators Role 下面。当然我们可以来添加更多的用户到 Administrator Role 中。

第二类是除了 Default 之外增加的 Scope，对于每一个 Scope，可以修改名称，可以删除。而这些 Scope 的 Roles 仅限于 Plan Authors。在每个 Scope 下的 Plan Authors Role 中，我们可以为这个 Scope 加入不同的用户。如下图所示。

![3F05i6.png](https://s2.ax1x.com/2020/02/18/3F05i6.png)

在 VAO 中，这个 Scope 非常难理解，不过没关系，我还是来继续打这个比方：

我们可以把 Scope 想象成一个一个的房间，每个房间都会有把锁，而这把锁配了多把钥匙，我们现在把这些钥匙分给不同的用户，那么这些用户都能通过 A 钥匙进入`房间（Scope A）`，通过 B 钥匙进入`房间（Scope B）`，通过 C 钥匙进入`房间（Scope C）`。这样，就形成了 VAO 中特殊的一种权限的管理：

```
当前有房间（Scope）：A、B、C、D

用户 1：拥有房间 A、B 的钥匙。

用户 2：拥有房间 B、C、D 的钥匙。

用户 3：拥有房间 D 的钥匙。
```

转换成 VAO 中的 Scope 管理：

```
房间（Scope A）：用户 1

房间（Scope B）：用户 1、用户 2

房间（Scope C）：用户 2

房间（Scope D）：用户 2、用户 3
```

而分钥匙的方法，就是在 VAO 中设置`User and Scopes`，在 VAO 中，通过拥有 Administrator Role 的 User 登录后，可以至`Administration`界面下面，找到`Permission->Users and Scope`来设定以上的管理权限，如下图：

![3k3G4J.png](https://s2.ax1x.com/2020/02/18/3k3G4J.png)

按照这样设定完成后，我们用 User 1 再次登入 VAO 的系统后，我们可以看到 Dashborad 上显示的当前用户的 Scope 如下图所示：

![3k38N4.png](https://s2.ax1x.com/2020/02/18/3k38N4.png)

类似的，User 2 登入系统后，将会看到房间 B、C、D，而 User 3 登入系统后，将只会看到房间 D。

#### 配置 Scope 中的 Plan Components

进入`Administration`界面，在`Permissions`下，可以找到`Plan Components`，在这个界面上，可以为每个`Scope`设定每种 Components。如下图，可以在红框位置选择 Scope 来切换并且设定。

![3k3YC9.png](https://s2.ax1x.com/2020/02/18/3k3YC9.png)

这里面大家可以注意到这是一个复选框，也就是说，可以同时选择多个 Scope 进行相关设定，但是为了更准确的设置相关内容，我还是建议大家逐个勾选设定会比较好。

## Datalabs

VAO 的 Datalab 其实就是 VBR 中的 Virtual Lab，只要在 VBR 中配置了 Virtual Lab 后，VAO 就能直接识别到。在识别到这些 Virtual Labs 之后，VAO 需要做一个分配的动作，将这些 Virtual Lab 按照实际使用的需求分配给不同的 Scope。特别注意，每一个 Virtual Lab 只能分配给一个指定的 Scope。

要分配 Datalab，可以使用 Administrator 账号进入`Administration`界面，找到`Permission`下面的`Datalab Assignment`，在这个页面下，勾选中间 VAO 扫描到的 Virtual Lab 名称，然后点击 Assign 按钮。

当点击了 Assign 按钮后会弹出 Assign Datalab to Scope 的对话框，在这里选择需要分配给哪个 Scope 即可。如下图所示。

![3kt6XR.png](https://s2.ax1x.com/2020/02/18/3kt6XR.png)

如果需要调整或者重新分配 Datalab，可以勾选 Virtual Lab 名称，然后点击 Unassign 按钮，稍等片刻之后就可以重新分配给其他的 Scope 了。

#### Lab Groups

我相信熟悉 DataLabs 的同学一定会好奇，我们 VBR 上的 Datalabs 的功能包含三个核心组件：Virtual Lab、Application Group 和 Surebackup Job。那么在 VAO 中我们将 DataLab 和 VBR 的 Virtual Lab 做了一一的对应，剩下的 Application Group 和 Surebackup Job 去哪里了？

在 VAO 中，也有一个和 VBR 中的 Application Group 一一对应的组件，那就是 Lab Groups。在 Administration 控制台中并没有这个 Lab Groups 的设定，这个 Lab Groups 需要使用每个用户的账号登入自己的 VAO 控制台中，用各自的账号进入 DataLabs 主页面进行设置。和 Virtual Lab 不同的是，Lab Groups 并不是从 VBR 的 Application Group 中继承，在 VAO 中，这个 Lab Group 是全新创建的，需要用 VAO 中的对象来创建。

![3kwKJK.png](https://s2.ax1x.com/2020/02/18/3kwKJK.png)

一般来说，Lab Group 可以保持空的状态，这和我们之前在 Application Group 的说明中提到的完全一致，除非是业务有依赖关系，必须依赖某个系统才能运行，那么此时，我们需要将这个被其他系统依赖的系统放入 Lab Group 之中。

![3kwMRO.png](https://s2.ax1x.com/2020/02/18/3kwMRO.png)

而 Surebackup Job，在 VAO 中就不需要用到了，这个 Job 会自动集成入 Orchestration Plan 之中，这里就不展开讨论，在后面的章节会详细介绍。

以上就是本章节的主要内容，谢谢关注。


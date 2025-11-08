# VRO 基础入门（三） -  基本组件 · 上篇


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

作为一套灾备管理系统，权限管理是至关重要的，因此，我想先来说说 VRO 中的角色权限管理。在 VRO 中的角色权限管理并不叫 RBAC，VRO 通过 Scope 来控制所有用户的访问权限，Scope 控制了用户在 VRO 中能访问哪些备份和灾备资源以及能对这些资源进行什么样的操作。

## Scope 的操作权限

先来说说 Scope 的操作权限，和其他系统 RBAC 的权限分类设定类似，在 VRO 中，这些权限分类我们叫做 Scope Inclusions，包含以下五类：

 - Groups
 - Recovery Locations
 - Plan Steps
 - Credentials
 - Template Jobs

对于拥有这五类 Scope Inclusions 中某一个资源的操作权限的 Scope 来说，该 Scope 就能使用这个对象。这里这五大类的对象都可以同时属于不同的 Scope。

另外，Scope 中还有个非常特殊的对象 -- Datalab，每一个 Datalab 都和一个 Scope 一一对应，也就是说，每个 Scope 都有**一个或多个**独立的属于自己的 DataLab。

关于 Scope Inclusions 将在 [VRO 基础入门（四）-  基本组件 · 下篇](https://blog.backupnext.cloud/_posts/2020-02-20-VRO-Guide-04/) 中详细介绍。

## Scope 的创建和用户分配
每个 Scope 可以分配 3 类不同的角色类型，分别是：
- Administrators - 可以做所有操作
- Plan Authors - 可以启用、禁用、重置、创建、编辑和测试灾备计划
- Plan Operators - 只能处理一些启用状态的灾备计划

VRO 中内置了一个 Admin Scope，默认情况下，在这个 Scope 中的 Administrator 权限最大，能做所有的操作。使用者可以通过新建 Scope 来为不同的用户限定不同的权限，执行不同的操作。

对于用户新建的 Scope，我们可以修改名称，可以删除。而这些 Scope 的 Roles 仅限于 Plan Authors 和 Plan Operators。以 Plan Authors 举例子，在每个 Scope 下的 Plan Authors Role 中，我们可以为这个 Scope 加入不同的用户。如下图所示。

![3F05i6.png](https://s2.ax1x.com/2020/02/18/3F05i6.png)

在 VRO 中，这个 Scope 非常难理解，不过没关系，我来打这个比方说明：

我们可以把 Scope 想象成一个一个的房间，每个房间都会有把锁，而这把锁配了多把钥匙，我们现在把这些钥匙分给不同的用户，那么这些用户都能通过 A 钥匙进入`房间（Scope A）`，通过 B 钥匙进入`房间（Scope B）`，通过 C 钥匙进入`房间（Scope C）`。这样，就形成了 VRO 中特殊的一种权限的管理：

```
当前有房间（Scope）：A、B、C、D

用户 1：拥有房间 A、B 的钥匙。

用户 2：拥有房间 B、C、D 的钥匙。

用户 3：拥有房间 D 的钥匙。
```

转换成 VRO 中的 Scope 管理：

```
房间（Scope A）：用户 1

房间（Scope B）：用户 1、用户 2

房间（Scope C）：用户 2

房间（Scope D）：用户 2、用户 3
```

而分钥匙的方法，就是在 VRO 中设置`User and Scopes`，在 VRO 中，通过拥有 Administrator Role 的 User 登录后，可以至`Administration`界面下面，找到`Permission->Users and Scope`来设定以上的管理权限，如下图：

[![p9qF3nI.png](https://s1.ax1x.com/2023/05/26/p9qF3nI.png)](https://imgse.com/i/p9qF3nI)

按照这样设定完成后，我们用 test01 再次登入 VRO 的系统后，我们可以看到 Dashborad 上显示的当前用户的 Scope 如下图所示：

[![p9qFljA.png](https://s1.ax1x.com/2023/05/26/p9qFljA.png)](https://imgse.com/i/p9qFljA)

类似的，test02 这个用户登入系统后，将会看到房间 B、C、D，而 test03 登入系统后，将只会看到房间 D。

#### 配置 Scope Inclusions

进入`Administration`界面，在`Permissions`下，可以找到`Scope Inclusions`，在这个界面上，可以为每个`Scope`设定不同的可用组件。如下图，可以在红框位置选择 Scope 来切换并且设定。
[![p9qF8Bt.png](https://s1.ax1x.com/2023/05/26/p9qF8Bt.png)](https://imgse.com/i/p9qF8Bt)

这里面大家可以注意到这是一个复选框，也就是说，可以同时选择多个 Scope 进行相关设定，但是为了更准确的设置相关内容，我还是建议大家逐个勾选设定会比较好。

## Datalabs

VRO 的 Datalab 其实就是 VBR 中的 Virtual Lab，只要在 VBR 中配置了 Virtual Lab 后，VRO 就能直接识别到。在识别到这些 Virtual Labs 之后，VRO 需要做一个分配的动作，将这些 Virtual Lab 按照实际使用的需求分配给不同的 Scope。特别注意，每一个 Virtual Lab 只能分配给一个指定的 Scope。

要分配 Datalab，可以使用 Administrator 账号进入`Administration`界面，找到`Permission`下面的`Datalab Configuration`，在这个页面下，勾选中间 VRO 扫描到的 Virtual Lab 名称，然后点击 Edit 按钮。

[![p9qk324.png](https://s1.ax1x.com/2023/05/26/p9qk324.png)](https://imgse.com/i/p9qk324)

当点击了 Edit 按钮后会打开 Edit DataLab Configuration 的对话框，在这里选择需要分配给哪个 Scope 即可。如下图所示：

[![p9qkEvj.png](https://s1.ax1x.com/2023/05/26/p9qkEvj.png)](https://imgse.com/i/p9qkEvj)

如果需要调整或者重新分配 Datalab，可以勾选 Virtual Lab 名称，然后同样点击 Edit 按钮回到前面的向导界面，就能通过 Clear 按钮取消关联。

#### Lab Groups

我相信熟悉 DataLabs 的同学一定会好奇，我们 VBR 上的 Datalabs 的功能包含三个核心组件：Virtual Lab、Application Group 和 Surebackup Job。那么在 VRO 中我们将 DataLab 和 VBR 的 Virtual Lab 做了一一的对应，剩下的 Application Group 和 Surebackup Job 去哪里了？

在 VRO 中，也有一个和 VBR 中的 Application Group 一一对应的组件，那就是 Lab Groups。在 Administration 控制台中并没有这个 Lab Groups 的设定，这个 Lab Groups 需要使用每个用户的账号登入自己的 VRO 控制台中，用各自的账号进入 DataLabs 主页面进行设置。和 Virtual Lab 不同的是，Lab Groups 并不是从 VBR 的 Application Group 中继承，在 VRO 中，这个 Lab Group 是全新创建的，需要用 VRO 中的对象来创建。

[![p9qFM1H.png](https://s1.ax1x.com/2023/05/26/p9qFM1H.png)](https://imgse.com/i/p9qFM1H)

一般来说，Lab Group 可以保持空的状态，这和我们之前在 Application Group 的说明中提到的完全一致，除非是业务有依赖关系，必须依赖某个系统才能运行，那么此时，我们需要将这个被其他系统依赖的系统放入 Lab Group 之中。

[![p9qFQcd.png](https://s1.ax1x.com/2023/05/26/p9qFQcd.png)](https://imgse.com/i/p9qFQcd)

而 Surebackup Job，在 VRO 中就不需要用到了，这个 Job 会自动集成入 Orchestration Plan 之中，这里就不展开讨论，在后面的章节会详细介绍。

以上就是本章节的主要内容，谢谢关注。


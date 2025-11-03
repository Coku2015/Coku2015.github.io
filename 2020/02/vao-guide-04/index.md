# VAO 基础入门（四） -  基本组件 · 下篇


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

## Plan Components

以下这些组件，需要针对每个 Scope 进行设置，上一篇中已经介绍了具体设置位置，接下来我们来看看这些 Components 都有些什么以及他们的设置方法。

#### VM Groups

VM Groups 定义了在这个 Scope 下面，能管理哪些虚拟机，简单来说就是圈一个范围，哪些虚拟机是属于这个 Scope 可以操作的，我们的 Orchestration Plan 针对哪些生产的 VM 进行操作。

和简单的 VM 勾选不一样的是，在 VAO 中，我们没办法很自由的去随意选择哪台 VM 属于哪个 Scope，在 VAO 中我们只能选择所谓的 VM Groups。

然而很尴尬的是，VAO 本身并不能创建任何的 VM Groups，这些 Groups 是通过 VAO 内嵌的 Veeam ONE 中的 Business View 引擎来获取的。Business View 的系统分组引擎是 VAO 中非常重要的一个组成部分，它的具体内容可以参考官网手册：

https://helpcenter.veeam.com/docs/vao/categorization/about.html?ver=20

https://helpcenter.veeam.com/docs/one/monitor/bv_categorization_model.html?ver=100

在 Business View 的分组引擎中有 3 种使用方式：

 ```
   1. vSphere Tags
   2. 通过。CSV 文件导入
   3. 通过 VeeamONE 的自定义分组策略
 ```

这 3 种方式并没有天然的特殊优劣，还是取决于 IT 管理员对哪种更熟悉，使用更便捷。

##### vSphere Tags

这个分组方式需要在 vSphere 上面进行，通过为不同的 VM 打入不同的 Tags 来实现分组，相同 Tags 名称的虚拟机会被归入同一个 VM Groups 中，而这个 VM Groups 的名称就是在 vSphere 中的 Tags 的名称。

这种分组方式无法在 Veeam 系统中做任何修改，只需要在 vSphere 上操作即可，操作完成后 VAO 中稍等一小段时间即可收到操作结果，这个操作是全自动的同步。

##### 通过。CSV 文件导入

可以手工或者自动进行，这个操作需要在 VAO 内嵌的 VeeamONE 上进行，打开 VeeamONE Monitor 的控制台，在 Server Setting 中可以找到 Business View 的标签卡，在这里分别有自动从。CSV 文件同步的选项和手工立刻从。CSV 文件做单次导入的选项。

需要注意的是，这种方式导入的分组方式需要合理的组织。CSV 文件的结构，如下表所示：

| Server       | ObjectType     | MoRef | Category1 |
| ------------ | -------------- | ----- | --------- |
| server.local | VirtualMachine | vm-01 | Group1    |
| server.local | VirtualMachine | vm-02 | Excluded  |

这个。CSV 文件可以是手工创建更新，也可以是第三方系统生成。

个人认为，这种方式比较呆，不那么容易使用。

##### 通过 VeeamONE 的自定义分组策略

在 VeeamONE 的 Business View 视图下，右键菜单中会有 Add Category 菜单，这里可以打开 Category 的创建向导，这也是一种分组方式，可以根据一些特定的属性匹配来全自动实现分组，但是实际上使用过程中会发现这里的分组条件并不是那么的灵活，相比。CSV 会更加不容易使用。

因此，我还是推荐大家使用 vSphere Tags 来进行分组，在 vSphere 中操作完成后，只需要等待一段时间后，即可在 VAO 中出现相关 VM Groups。如下图所示：

![3E8owV.png](https://s2.ax1x.com/2020/02/19/3E8owV.png)

这里面，VM Groups 的名称组合方式为 *vSphere Tags Category Name* - *vSphere Tag Name* ，因此我们看到 vSphere 上 VAO Backup 这个 Tag 到 VAO 中的 VM Groups 中显示为：VAO Tags Group - VAO Backup。选中这个 VM Group 后，在画面右边，可以看到该 VM Group 中包含的虚拟机列表，点击上方 Include 按钮，就可以把这个 VM Group 加入到当前选择的 Scope 下面。

#### Recovery Locations

Recovery Locations 是我们的 Orchestration Plan 恢复时所要使用的物理计算资源，它包括了 Compute、Storage、Network 三大核心资源。转换成 vSphere 上，分别有如下的对应关系：

| VAO Recovery Locations 名称 | vSphere 资源              |
| -------------------------- | ------------------------ |
| Compute                    | ESXi、Cluster            |
| Storage                    | Datastore                |
| Network                    | 虚拟交换机上的端口组名称 |

在 VAO 中，和选择 VM Group 一样，我们并不能直接选择某个 ESXi、Datastore 作为我们的 Recovery Location，只能通过 VAO 内嵌的 Veeam ONE 中的 Business View 引擎来获取的。和上的 VM Group 设置一样，我们可以通过 vSphere Tags 将 ESXi 或者 Cluster、Datastore 进行分组，分组完成后 VAO 就能读取到这些信息。稍微复杂一定，这些信息还需要通过 Recovery Locations 的添加向导进行一定顺序的编排，确保 ESXi、Datastore 和虚拟交换机上的端口组的对应关系。

Recovery Locations 是在 Administration 中 Configuration 下的 Recovery Locations 中设置的，进入这个设置界面后，会看到 VAO 已经内置了一个默认的 Recovery Location，这是还原到虚拟机的原始所在位置，对于这个默认的 Recovery Location，我们只能对他做编辑操作，并不能删除它，而编辑操作可调整的内容也非常少。

我们可以新建新的 Recovery Location 用于还原到一个新的位置。我们可以在这里创建多个 Recovery Location。通过 Add 按钮，我们可以打开添加向导：

1. Location Info 中，只需要填入名称和描述即可。
   ![3ENar9.png](https://s2.ax1x.com/2020/02/19/3ENar9.png)

2. Compute Resources 选择步骤中，将合适的 ESXi 或者 Cluster 对应的 Tags 选中点 Add 添加至这个 Recovery Location 中。当然这里的内容显示也不是那么的直观，VAO 提供了一个查看的按钮，点击右边的 View Resource 按钮，就可以看到这个 Tags 下面包含的 ESXi 或者 Cluster。如果此处的 Tags 是分配给某个 Cluster 的，那么在 View Resources 中只能看到 Cluster 的名称，并且在实际执行 plan 的时候 VAO 需要 Cluster 的 DRS 策略来决定将恢复出来的 VM 放置到哪个 ESXi Host 上。
   ![3ENy8O.png](https://s2.ax1x.com/2020/02/19/3ENy8O.png)

3. Storage Resources 选择步骤中，请务必小心选择，在 VAO 中很弱智的一点是，即使这个页面上已经提示了 Only Storage resources available to the previously selected Compute resources are shown here，Storage Resources 依然会将部分无关的 Storage Group 罗列进来，只是在左边显示的时候并没有显示绿色的勾子，而是显示成绿色半圆加上白色半圆，这是对于以上的 Compute Resource 部分可用的意思，我们需要做的是确保选择的 Storage Group 是显示绿色勾子的，也就是必须对于我们上一层选择的 Compute Resources 是完全可用的，才能避免在后续的 Orchestration Plan 中出现各种告警和失败。
   ![3EN62D.png](https://s2.ax1x.com/2020/02/19/3EN62D.png)

4. Resource Usage，设定存储资源的使用上限，确保存储资源不会被耗尽。
   ![3ENcxe.png](https://s2.ax1x.com/2020/02/19/3ENcxe.png)

5. Instant VM Recovery，选择是否启用 IVR。
   ![3ENdbR.png](https://s2.ax1x.com/2020/02/19/3ENdbR.png)

6. Re-IP Rules，在 VAO 中内置了灾备恢复或者切换后修改 IP 地址的功能，当我们需要对恢复的系统更换 IP 时，可以用这里的 Re-IP Rules 进行修改。根据这里设置的规则，VAO 自动对符合条件的系统应用这个规则。这个规则的设定也非常简单，它可以是 IP 子网的一一对应关系，换句话说，就是他只更换对应系统的子网，而最后一位的地址则不更换。比如，源虚拟机的地址是 10.10.1.25，对应规则是从 10.10.1.x 更换成 10.10.3.x，那么这个更换结果是 10.10.3.25。

   当然这里也可以是单个 IP 地址 Re-Mapping。
   ![3ENsPK.png](https://s2.ax1x.com/2020/02/19/3ENsPK.png)

7. 
   Network Mapping 中，可以设定源 VM 的端口组至灾备端切换需要使用的端口组。这里会将源 vCenter 和目标 vCenter 中的所有端口组都罗列出来，我们只需要去选择一一对应关系即可，而不像前面的 Compute 和 Storage 那样在 vSphere 中设定 Tags 来实现。
   ![3END56.png](https://s2.ax1x.com/2020/02/19/3END56.png)

在 Configuration 下面创建完 Recovery Locations 之后，我们需要在 Plan Components 中，为某个 Scope 选择所能用的 Recovery Locations，和 VM Groups 一样，切换到 Recovery Locations 标签卡后，勾选需要的 Recovery Locations 之后，点击 Include 即可。

![3EwBOe.png](https://s2.ax1x.com/2020/02/19/3EwBOe.png)

#### Plan Steps

Plan Steps 是所有我们在 Orchestration Plan 中可以用的操作，Veeam 系统内置了绝大多数恢复或者验证系统时要用的步骤。当然我们也可以额外再添加一些新的自定义脚本。添加新的自定义脚本需要通过管理员账号进入 Administration，找到 Configuration 下面的 Plan Steps，在这里进行新的 Step 的定义，此处也可以对于内置的一些 Step 做一些修改。

定义完成之后，还是需要回到 Plan Components 中，为某个 Scope 选择所能使用的 Plan Step，在 Plan Steps 标签卡下，勾选需要的 Step 后，点击 Include，确保已经包含即可。

![3EBSv8.png](https://s2.ax1x.com/2020/02/19/3EBSv8.png)

#### Credentials

Credentials 是我们在灾备中需要用到的用户名密码，用于执行一些操作系统内的自动化脚本，这里 VAO 会从 VBR 中将所有已经设置的用户名密码继承过来，稍微有些不同的是，对于用户名密码，我们可以在这个标签卡下点击 Add 来新增。我们在这个标签卡下需要做的事情也很简单，只需将需要使用到的用户名密码在这里勾选点击 Include 即可。

![3EsxoQ.png](https://s2.ax1x.com/2020/02/19/3EsxoQ.png)

#### Template Jobs

VAO 在做完灾备切换和灾备恢复后，能第一时间即刻对新恢复出来的系统进行数据保护，确保第一时间系统时处于被保护的状态，这一功能需要 VAO 有一个 VBR 备份作业的模板作为参考。在每一个 Scope 中，都可以设定需要使用的 Template Job。这个 Template Job 并不是在 VAO 中设定的，它是直接从 VBR 中进行获取，获取的规则也很简单，只要 VBR 的 Backup Job 中作业的 Description 中写入了** [VAO TEMPLATE]** 字样就能被 VAO 正确获取。

以上就是 VAO 所有的基础组件，谢谢阅读并关注。


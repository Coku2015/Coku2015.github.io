# VRO 基础入门（六）-  数据实验室


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

Veeam 的产品怎么可以少了数据实验室（Datalab)，在 VRO 中，加强版的 Datalab 会比 VBR 中的功能更强大。今天我们就来说说这个加强版的数据实验室。

VRO 的数据实验室目前支持以下几种 Plan：

- Replica Plan
- Restore Plan（vSphere 和 Agent）
- Storage Plan

在数据实验室中，这几种 Plan 都会启动整个恢复流程，只是这个流程启动后，完全不影响生产系统。VRO 正确的选择数据实验室的网络和所有指定的恢复步骤完成所有的灾备测试。

和 VBR 中的 Virtual Lab 不一样的是，在 VRO 中 Datalab 可以独立启动，启动后的 Datalab 实际上是为我们开启了一套隔离网络，这套隔离网络的基础网络服务由 Datalab 的 Proxy 提供，而基础依赖应用则由 Lab Group 来提供。

在 VRO 中启动 Datalab 只需要打开 VRO 控制台，找到左边的 Datalabs 选择它，然后在中间内容显示区域会看到已分配的 Datalab，选中后，可以点击上方 Run 按钮来启动这个 Datalab。

[![pCFQDyV.png](https://s1.ax1x.com/2023/06/07/pCFQDyV.png)](https://imgse.com/i/pCFQDyV)

Datalab 启动后可以把它理解为数据实验室的路由器被启动了，这时候任何放入这个网络的机器就能正常使用这个数据实验室网络了。

## Datalab 测试

在 Orchestration Plan 的 Verity 按钮下，可以找到 Run Datalab test 的按钮，点击这个按钮后，会启动一个 DataLab test 的向导，通过这个向导中选择一些合适的选项，可以对于整个灾备计划做一次近乎真实的演练，整个演练过程甚至会 100%模拟实际的 Plan 执行，包括了其中所有设置的自定义脚本，只是在分配网络的时候会选择 Datalab 的隔离网络。因此管理员能从这样的演练过程中清楚的掌握实际灾备环境中恢复的状况以及需要的恢复时间。

[![pCFQ6wF.png](https://s1.ax1x.com/2023/06/07/pCFQ6wF.png)](https://imgse.com/i/pCFQ6wF)

3 种类型的 Plan 在执行 Datalab test 时，步骤上几乎没有太大差别，今天我就仅以 Restore Plan 为例子来说明整个过程。

1. 打开 Datalab Test 向导后，我们首先需要选择 Test Method。这里 Quick Test 和 Full Restore Test 的区别是即时恢复和完整恢复的差异，在做 Datalab Test 时，一般我们会选择 Quick Test，而在长期使用测试环境时，可以选择 Full Restore Test。
[![pCFQyeU.png](https://s1.ax1x.com/2023/06/07/pCFQyeU.png)](https://imgse.com/i/pCFQyeU)

2. 在 Datalab 步骤中，我们看到在前面开启 Datalab 后，这里 Datalab 已经处于 running 状态了，我们可以选中它，然后点击下一步。
[![pCFQrLT.png](https://s1.ax1x.com/2023/06/07/pCFQrLT.png)](https://imgse.com/i/pCFQrLT)

3. 在 Recovery Location 步骤中，我这里选择在原位置还原，因为是 Datalab 测试，所以 Datalab 会自动为我的测试机器重命名。点击下一步。
[![pCFQwzq.png](https://s1.ax1x.com/2023/06/07/pCFQwzq.png)](https://imgse.com/i/pCFQwzq)

4. 在 Power Options 步骤中，可以选择测试完立刻关机，也可以选择测试完继续运行一段时间，这时候用这种方式，我们可以开启数据实验室用于各种实验环境的搭建。
[![pCFQaJs.png](https://s1.ax1x.com/2023/06/07/pCFQaJs.png)](https://imgse.com/i/pCFQaJs)

5. 在 Ransomware Scan 步骤中，借助 VBR 的 secure Restore 能力，VRO 能够全自动的寻找所有还原点中没有被勒索病毒污染的还原点实现干净还原。
[![pCFQdWn.png](https://s1.ax1x.com/2023/06/07/pCFQdWn.png)](https://imgse.com/i/pCFQdWn)

6. 在 Summary 中，还是国际惯例，总结下前面的选项，点击 Finish 就可以启动数据实验室测试。
[![pCFQBQ0.png](https://s1.ax1x.com/2023/06/07/pCFQBQ0.png)](https://imgse.com/i/pCFQBQ0)

7. 在数据实验室启动后，点击 Plan 名字就能进入数据实验室的详细验证步骤查看，如下图。
      [![pCFQco4.png](https://s1.ax1x.com/2023/06/07/pCFQco4.png)](https://imgse.com/i/pCFQco4)

## 日常计划任务测试

除了可以手工执行 Datalab test 之外，VRO 也可以全自动按计划任务执行 Datalabs Test。在 VRO 的仪表盘中，找到 Lab Calendar 部分，在这里可以看到 Create Schedule 按钮，就是用来设置全自动的 Datalab test 计划任务。

[![pCFct7F.png](https://s1.ax1x.com/2023/06/07/pCFct7F.png)](https://imgse.com/i/pCFct7F)

点击 Create Schedule 按钮后，会启动 Create Test Schedule 向导

1. 在 Scope 步骤中先选择下 Scope，设置下权限，点击下一步。
[![pCFcrX6.png](https://s1.ax1x.com/2023/06/07/pCFcrX6.png)](https://imgse.com/i/pCFcrX6)

2. 在 Schedule Info 步骤中，设置计划任务的名称和描述，比如我这里设置了 Daily Verification。点击下一步。
[![pCFcD6x.png](https://s1.ax1x.com/2023/06/07/pCFcD6x.png)](https://imgse.com/i/pCFcD6x)

3. 在 Choose Plans 步骤中，选择需要验证的 Plan，然后点击 Add 添加。在这个步骤中，可以多选多个 Plan，这样这些 Plan 就都能够按照这个计划任务的设定进行测试。
[![pCFcB11.png](https://s1.ax1x.com/2023/06/07/pCFcB11.png)](https://imgse.com/i/pCFcB11)

4. 在 Datalab 步骤中，选择一个 Datalab，点击下一步。
[![pCFcUk4.png](https://s1.ax1x.com/2023/06/07/pCFcUk4.png)](https://imgse.com/i/pCFcUk4)

5. 在 Recurrence and Start 步骤中，设定计划任务，比如我这里设置每周一三五运行测试计划，点击下一步。
[![pCFcatJ.png](https://s1.ax1x.com/2023/06/07/pCFcatJ.png)](https://imgse.com/i/pCFcatJ)

6. 在 Restore Options 步骤中，选择恢复模式，推荐日常测试选择 Quick Test，点击下一步。
[![pCFcY0U.png](https://s1.ax1x.com/2023/06/07/pCFcY0U.png)](https://imgse.com/i/pCFcY0U)

7. 在 Power Options 步骤中，选择默认的选项 Test then power off immediately，点击下一步。
[![pCFc360.png](https://s1.ax1x.com/2023/06/07/pCFc360.png)](https://imgse.com/i/pCFc360)

8. 在 Ransomware Scan 步骤中，可以选择病毒扫描，这里我们保持默认不勾选，点击下一步。
[![pCFc8XV.png](https://s1.ax1x.com/2023/06/07/pCFc8XV.png)](https://imgse.com/i/pCFc8XV)

9. 在 Summary 步骤中，可以查看以上设置，并且可以通过 copy to clipboard 来复制这里的信息。点击 Finish 按钮就可以结束向导完成设置。
[![pCFcJmT.png](https://s1.ax1x.com/2023/06/07/pCFcJmT.png)](https://imgse.com/i/pCFcJmT)

10. 回到 VRO 仪表盘 Lab Calendar 界面，我们可以看到日历表中已经出现了每天的验证计划。
[![pCFcdh9.png](https://s1.ax1x.com/2023/06/07/pCFcdh9.png)](https://imgse.com/i/pCFcdh9)

11. 如果再次点击其中一个计划任务的名字，我们可以重新编辑这个计划任务，并且还能删除和禁用这个计划任务。
[![pCFcynK.png](https://s1.ax1x.com/2023/06/07/pCFcynK.png)](https://imgse.com/i/pCFcynK)

以上就是 VRO 中数据实验室的具体设置和使用方法。

更多内容欢迎关注本人公众号，


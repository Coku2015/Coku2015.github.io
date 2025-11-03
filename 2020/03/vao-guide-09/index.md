# VAO 基础入门（九） -  文档模板解析


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

本系列的最后一篇，我来介绍一下 VAO 的文档系统。

VAO 能够全自动的为管理员生成灾备需要的系统文档，文档的内容为 VAO 系统自动根据 Orchestration Plan 的设置和执行自动生成。VAO 文档系统的强大在于所有的内容系统根据配置和运行会全自动生成，因此管理员只需要专心关注自己的灾备即可，这些后续的基础保障，繁琐的文档制定，全部交给 VAO 来完成。

VAO 生成的每个文档会包含两部分，第一部分是灾备管理员定义的 Report Template；第二部分是系统根据 Report Type 生成的动态内容。无论什么类型的文档，在文档的开头部分都会使用 Report Template 中所定义的内容，而第二部分则根据 Report Type 不同自动填充相关内容。

我们先来看个实际的例子，了解一下什么是 Report Template 中的内容，什么是根据 Report Type 自动生成的，如下图：

![3fvwlT.jpg](https://s2.ax1x.com/2020/03/03/3fvwlT.jpg)

左边是一个 VAO 最终生成的 Readiness Check 的 Report，右边是我们在编辑器中打开的 Report Template。可以看到红色框所示的内容就是来自于 Report Template 的，而图中左边文档的后半部分内容则是根据这个 Report Type，自动产生的内容。

## Report Type

先来说说这个 Report Type，也许聪明的你，在前几篇介绍 Orchestration Plan 的时候已经有看到，在每个 Plan 的右键菜单或者工具栏上有一些 Report 可以生成，它们分别是：
| Report 类型 | 作用 |
|------|------|
| Plan Definition Report | 记录灾备计划设置详情 |
| Readiness Check Report | 灾备计划可用性检测报告，包含恢复目标位置和灾备中心的可用性检测 |
| Datalab test Reort | 数据实验室测试报告 |
| Excution Report | 灾备执行情况报告 |

这些 Report 就是 VAO 能够生成的所有 Report 文档，这些文档都会有一个 VAO 已经内置设计好的内容，能够和灾备管理员定义的 Report Template 组合起来，最终形成一份完整可以阅读的 Report。

这部分 VAO 已经内置的内容，我们无法做任何的更改，系统都会根据实际的报告类型、当前灾备计划的设定、灾备计划的运行和执行来自动生成这个内容，因此我们也不需要对这里的内容做更改设定。

所以，此部分的内容目前只包含英语版本，我们没有任何方法去修改其中相关信息，当然如果我们的 Plan 中如果包含中文的信息，VAO 还是能够正确的传递给 Report，生成相关内容。

## Report Template

Report Template 的内容是管理员可以根据自己需求进行定制每个文档的前半部分，在 VAO 出厂软件中，已经内置了 8 国语言的默认模版，需要注意的是，这些默认模版都是无法编辑的，但是是可以直接被 Report 系统调用在 Orchestration Plan 中使用的。如果需要编辑这些模版，或者创建自己的模版，需要首先从这些模版 Clone 一份自己的拷贝，然后在这个基础上进行修改。

修改这些文档需要用 Word，要求是 Word 2010 SP2 以上版本，也就是说，需要在当前打开 VAO 网页的电脑上，同时安装了 Word 2010 SP2 以上版本，才能正常的进行编辑。点击 VAO 界面中的 Edit 按钮后，系统会自动从网页浏览器切换至 Microsoft Word 中进行编辑。

和普通的 Word 编辑完全不一样的是，这个模板的编辑是个动态文档的编辑，可以加入很多 VAO 中的变量，让 VAO 系统在生成 Report 的时候自动填充。

## 如何使用 Word 编辑动态文档

1. 首先需要选择一个内置的 Template 作为我们要编辑的对象，点击 Clone 按钮启动创建自己的 Template。比如我这里选择`Veeam Default Template（ZH）`。
   ![3hiViQ.png](https://s2.ax1x.com/2020/03/03/3hiViQ.png)
   
2. 在 Clone Template 对话框中，选择分配给自己名下的哪个 Scope，然后为这个 Template 起个响亮的名字，填写一段描述，就能完成模板创建。
   ![3hi5TS.png](https://s2.ax1x.com/2020/03/03/3hi5TS.png)

3. 创建完成后，在 Template 清单中就能看的这个模板，并且上面的工具栏按钮也可以对这个模板进行操作了，可以点击 Edit 进行内容编辑。在这里 VAO 并不提供内置的文档编辑器，这个 Edit 按钮会直接调用当前浏览器所在的计算机打开 Word 进行编辑，要求管理员必须已经正确安装了 Microsoft Word。
   ![3hFmkD.png](https://s2.ax1x.com/2020/03/03/3hFmkD.png)

4. 点击 Edit 之后，会切换到 Word 程序，需要注意的是，Word 不会立即打开文档，而是需要一个访问的权限，这里需要的权限必须是当前在浏览器中登入 VAO 的用户，否则这个 Word 将打不开该文档模板。
   ![3hkOaT.png](https://s2.ax1x.com/2020/03/03/3hkOaT.png)

5. 打开文档后，即可正常进行 Word 的编辑了。这个文档并不是全文档都可以编辑，您会发现很多区域被黄色的荧光标注了，这部分内容才是允许编辑的区域，在这里可以任意的加上需要的文字和图片内容。所以，可以看到，这个文档的标题、页眉和页脚是不可被修改的，而其他部分，都是可修改的。
   ![3hEw1H.png](https://s2.ax1x.com/2020/03/03/3hEw1H.png)

6. 因为这是个动态文档，所以在这里我们可以调用很多很多 VAO 的变量内容来取得数据，VAO 系统已经给我们做了一些示例，在 Clone 出来的这个文档中，仔细观察这些文字，会发现有一些文字内容被 [] 包围，这部分内容就是这个文档中动态的变量内容。这个编辑和我们正常的 Word 编辑稍微有些不同，我们来看看如何进行操作。
   要编辑这个变量数据，首先我们可以按正常方式输入一段文字内容，为了区分和普通文字的不同，建议也和 VAO 默认文档一样，加上 []，比如：`[Hi，我是变量]`，在上方工具栏，找到`开发工具`，打开`设计模式`。
   ![3heF6H.png](https://s2.ax1x.com/2020/03/03/3heF6H.png)

7. 在打开设计模式后，会发现这个文档变得好奇怪，之前藏起来的很多内容显现出来了，这时候别被这些多出来的内容吓到，他们实际上并不存在，关掉设计模式后他们会自动藏回去，这只是我们的变量设置结果而已。
   接下去，我们对`[Hi, 我是变量]`进行设置，选中这段文字，然后需要点击设计模式左边的第一个`Aa`按钮，就能将这段文字变成和模板中一样的变量了，然后再点击设计模式下方的属性，可以打开变量设定的对话框，它是使用 Word 的内容控件来实现的，设定这个内容控件的属性即可完成。
   ![3hmKV1.png](https://s2.ax1x.com/2020/03/03/3hmKV1.png)

8. 这个变量设置非常简单，只需要输入一个标题和一个标记，一般来说，这两个设置成一样的就行了，标题跟着标记的内容来填写。VAO 内置了以下可用的所有标记，所有标记都是以`“~”`开头，选择需要的标记填入到上面的这个属性框中点确定即可。

   | 变量名            | 作用说明             |
   | ----------------- | :------------------- |
   | ~Created          | Report 生成时间       |
   | ~TimeZone         | Report 生成时区       |
   | ~PlanType         | VAO 计划类型          |
   | ~PlanName         | VAO 计划名称          |
   | ~PlanDescription  | VAO 计划描述          |
   | ~PlanContactName  | 灾备计划联系人姓名   |
   | ~PlanContactEmail | 灾备计划联系人邮箱   |
   | ~PlanContactTel   | 灾备计划联系人电话   |
   | ~Site             | 站点名称             |
   | ~SiteScopeName    | 站点范围名称         |
   | ~SiteDescription  | 站点描述             |
   | ~SiteContactName  | 站点联系人姓名       |
   | ~SiteContactEmail | 站点联系人邮箱       |
   | ~SiteContactTel   | 站点联系人电话       |
   | ~ServerName       | 服务器名称           |
   | ~VmsInPlan        | 在该计划中的虚拟机   |
   | ~GroupsInPlan     | 在该计划中的虚拟机组 |
   | ~ReportType       | Report 类型           |
   | ~TargetRTO        | 该计划的目标期望 RTO  |
   | ~TargetRPO        | 该计划的目标期望 RPO  |

9. 在根据需要写完这个文档之后，只需要按照正常保存或者关闭这个文件就可以将文档提交至 VAO 服务器了，千万记得不要使用另存为，另存为之后，就不会更新至 VAO 服务器，这个编辑也就白搭了。

Report Template 编辑完成后，就可以回到 VAO 网页 UI 中查看修改结果了，管理员也可以根据不同的 Scope 的设置，为不同的 Orchestration Plan 选择并使用这个新创建的 Report Template。

以上就是 VAO 的所有内容，希望对大家了解 VAO 有帮助，感谢关注和阅读！


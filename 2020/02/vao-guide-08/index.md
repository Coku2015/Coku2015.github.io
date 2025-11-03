# VAO 基础入门（八） -  Plan Step · 下篇


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

上一篇，我介绍了 Plan Step 的基本概况，今天我来详细分解下在 Plan Step 中的自定义脚本，我会通过一个脚本使用例子，来带大家使用一下自定义脚本。

## 创建和设置

配置自定义的脚本需要使用隶属于 Administrators 组的账户登入 VAO 平台。进入 Administration 控制台后，可以在 Configuration 下面找到 Plan Steps，在这里可以管理所有的 Plan Steps，当然除了创建自定义的 Steps 之外，也可以在这里对 OOTB 的那些 Steps 进行一些个性化的配置。

![3wzhTJ.png](https://s2.ax1x.com/2020/02/27/3wzhTJ.png)

点击 Add 按钮即可进入添加向导，过程也非常简单，为它起个响亮的名字，比如：`远程的骚操作测试`。在 File 栏，点击 Browse 从当前的客户端上去选择制作好的 powershell 脚本吧。

![30MFTs.png](https://s2.ax1x.com/2020/02/27/30MFTs.png)

点击 Next 进入 Step Visibility 步骤，如果不希望所有的灾备管理员都看到这个骚脚本的话，可以不勾上这个界面的复选框。

![308ao4.png](https://s2.ax1x.com/2020/02/27/308ao4.png)

最后还是老样子，Summary 总结一下，点 Finish 就创建完成了。但是，这只是创建完成，别想着就马上拿去用，这里特别敲黑板强调一下：

Custom Script 可以有两种不同执行位置，一种是在灾备的机器上执行，另外一种是在 VBR 上执行。这个必须手工在创建完 Plan Step 之后点击这个 Step 名称，浏览到右边如图位置进行调整，默认值是在 VBR 上执行。比如我今天要做的这个测试就是需要调整一下，更改成 In-Guest OS。

![30smI1.png](https://s2.ax1x.com/2020/02/27/30smI1.png)

需要注意的是，这个 Step 的设置是全局的，也就是说，如果将这个 Step 提供给所有的 Scope 使用，那么这项配置内容是所有的 Scope 共享的，不能做计划任务中做更改。因此管理员如果有必要，需要做这个 Plan Steps 的管理页面中根据实际需求逐个定义。

##  Hello！My Script

那么接下来，让我们来配置一个 Script 跑一把吧。来个简单的，内容如下：

```powershell
###########
#Lei Wei - 02/28/20
#
# 这个脚本是骚操作的代表，请仔细往后看
#
# v1.0
 
$S = Get-Date;
 
Add-Content c:\vao_log.txt "$S - Recording date "
```

如果一切正常，在 VAO 中将会看到如下信息：

![30RZZD.jpg](https://s2.ax1x.com/2020/02/27/30RZZD.jpg)

## 让我们变得更复杂一点

好在这个脚本实在太简单了，几乎不可能会出现报错，那么如果复杂一点，脚本成功或者报错，VAO 能否捕获这些错误让我们的管理员能够更方便的知道系统发生了什么问题呢？请看以下代码：

```powershell
###########
#Lei Wei - 02/27/20
#
# 这个脚本是骚操作的代表，请仔细往后看
#
# v1.1

try {
$S = Get-Date;
Add-Content c:\vao_log.txt "$S - Recording date. "
Write-Host "准确计时，骚操作成功"
}
Catch {
Write-Error " 不知道哪里坏了，失败了！"
Write-Error $_.Exception.Message
}
```

在更换成这个 Powershell 执行之后，可以看到如下 VAO 界面中的执行成功记录，除了记录成功失败，还将我设置中脚本中的信息同时传递到了 VAO 界面之中。

![30Iizd.png](https://s2.ax1x.com/2020/02/27/30Iizd.png)

## 更多参数传递

VAO 所使用的脚本还可以更复杂，比如说，可以通过 VAO 传递一些参数给脚本。我们来继续修改上面的脚本，如下：

```powershell
###########
#Lei Wei - 02/27/20
#
# 这个脚本是骚操作的代表，请仔细往后看
#
# v1.2

Param(
[Parameter(Mandatory=$true)]
[string]$planName,
[string]$text
)

try {
$S = Get-Date;
Add-Content c:\vao_log.txt "$S - Recording date. "
Write-Host "准确计时，骚操作成功"
Write-Host "准确计时，骚操作成功，$planName，$text !"
}
Catch {
Write-Error " 不知道哪里坏了，失败了！"
Write-Error $_.Exception.Message
}
```

这个脚本中，我们配置了两个参数，$planName 和$text，如果要在 VAO 中正确使用参数，并将相关参数传递给脚本，那么就需要我们为这个 Plan Step 加上额外的参数，这个可以通过 Plan Step 中右边的 Add 按钮来完成。

需要注意的是，我们 Add 的参数，它的名称必须和脚本中的参数名称保持一致，才能够被正确的传递，如下图，我们设置了 planName 和 text。

![307LtK.png](https://s2.ax1x.com/2020/02/28/307LtK.png)

这里 planName 的 default 值设置为$plan_name$，这个内容是 VAO 中系统自带的一些变量，在我们的传递参数中，可以直接使用。具体列表在点击 Edit 按钮时会直接弹出供我们选择。

而$text，我们直接输入 Default Value，而不是使用 VAO 内置的系统变量，输入的内容为：完成参数传递。

最后让我们来看看这个脚本骚操作在 Orchestration Plan 中执行结果吧，我们的 Step Details 和 Report 中会出现什么：

![307qk6.png](https://s2.ax1x.com/2020/02/28/307qk6.png)

感觉怎么样，是不是觉得 VAO 很棒？赶紧动手试一试吧。


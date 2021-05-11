---
layout: post
title: Veeam备份服务器升级指南
tags: VBR
---

## 前言

Veeam即将推出全新的v10版本，在这个版本中，Veeam支持从以前的VBR升级至v10版本，整个平滑升级过程不算复杂，和以往的VBR升级一样，当然也有一些细节需要注意。



### 升级前

请按照下面的流程图检查当前环境，在升级VBR之前确保其他组件已经正常升级。

<img src="https://s2.ax1x.com/2020/02/13/1L4P8H.png" alt="1L4P8H.png" style="zoom:33%;" />



由于v10开始，Veeam将使用全新的Veeam Universal License（VUL），所以请提前登陆My.veeam.com获取更新后的License，在升级过程中将会提示使用新的License激活产品。



### 升级方式

可以采用两种方式升级，没有太大区别。

1. 在原VBR服务器上原地升级；
2. 全新安装一台VBR服务器，然后将Configuration Backup File还原至这台全新安装的VBR中。

由于第二种方式和全新安装几乎没有任何区别，因此本文不详细展开讨论，而只讨论第一种原地升级方式。

### 升级准备

准备好Veeam升级介质，Veeam的产品非常简单，升级介质和全新安装使用同一个介质包，只需要把产品包挂载到VBR服务器上即可。在执行Upgrade之前，需要做一系列准备工作：

1. 仔细阅读Release Notes，检查自己环境，看看是否有不支持的系统。

 ```
  	- VMware vSphere 5.1以及之前的版本
  	- Windows 2003和XP
  	- Microsoft SQL Server 2005
 ```

2. 使用Veeam Configuration Backup功能，将VBR的配置做一个备份，这个备份请确保是用Encrypted模式，这样所有在VBR中使用的用户名和密码将会妥善的被保存在.bco文件中。
3. 检查VBR上面的所有备份作业，确保没有任何作业正在运行，这里要特别注意如下作业，需要手工点击Disable来停止：

```
    - Backup Copy Job
    - SQL、Oracle的日志备份作业
```

​		看看是否有Instant VM Recovery正在运行；

​		看看是否有Veeam Explorer正处于打开并在执行恢复；

​		看看是否有Surebackup/Virtual Lab正在运行。

最终，所有任务都停止后，会是如下图状态：

![1L7jrd.png](https://s2.ax1x.com/2020/02/13/1L7jrd.png)



### 升级过程

整个升级过程非常简单，只需要按照向导点击几下鼠标，然后静静的等待30分钟以后，软件就能升级完成，因此在这里我就不详细去一步一步说明这个过程了。

### 可能碰到的问题

1. 升级过程中，升级包会首先停止VBR的所有服务，有可能碰到停止服务超时或者失败，导致升级过程中断，建议碰到失败后首先检查下Services.msc中veeam开头的服务是否被正常停止。
2. 服务都正常停止后，原地升级如果还报错，建议可以把VBR服务器重启一下后，再尝试升级，这里特别注意一下，在VBR重启后，需要重新检查所有VBR的作业，确保没有作业在自动运行。
3. 如果尝试多次都无法进行正常升级，建议使用上面提到的方法二，全新安装一台VBR，然后将Configuration backup文件导入。
4. 如果以上方法全部失败，请及时联系Veeam Support团队，我们的攻城狮将会及时为您提供升级支持。



以上就是升级的一些小提示，感谢阅读！





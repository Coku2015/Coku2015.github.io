# VDP v12.1 安全功能深度分析系列（一）- 勒索攻击侦测


去年年底，Veeam 发布了 v12.1 的重要更新，其中包含了大量安全方面的新功能，从今天开始，我将会深入每一个具体功能，来为大家介绍它们的原理和使用方法。

本次第一篇，先来说说勒索攻击侦测部分，在这个版本中，加入的这个功能模块叫 Malware Detection，从功能分类上来说，由两大类组成。其中一个叫 Inline Entropy Scan，另外一个叫 Index Scan。


### Inline Entropy Scan

首先来看下 Inline Entropy Scan。默认情况下，Inline Entropy Scan 是处于被禁用状态，管理员需要手工打开该选项进行激活。而激活后，它是一个全局选项，所有支持的备份源都会在备份时进行 Inline Entropy Scan。 

Inline Scan 会根据 Veeam 多年的数据保护经验训练的数据分析大模型在备份过程中对备份数据进行实时扫描，当源数据中发现有以下几种状况时，系统就会发出警告，通知侦测到异常状况：

- 发现大量数据正在被加密，这个数据量有个 5 档敏感度设定，当灵敏度调高时，就算比较少的数据被加密，系统都会发出警告。

[![pkPXLT0.png](https://s21.ax1x.com/2024/04/27/pkPXLT0.png)](https://imgse.com/i/pkPXLT0)

- 当勒索攻击创建了相关文本内容后，系统会发出警告，这主要包括类似于 V3 版本的洋葱地址，勒索通知等。

[![pkPXXkV.md.png](https://s21.ax1x.com/2024/04/27/pkPXXkV.md.png)](https://imgse.com/i/pkPXXkV)

#### 工作原理

这个扫描会在备份作业运行的时候进行，VBR 会对每一个备份过程中接收到的数据块进行分析，VBR Server 上会加入一个全新的服务 Veeam Data Analyzer Service 来管理这个分析。

1. 这个数据分析会发生在 Backup Proxy 或者 Agent 端，在分析数据开始后，Proxy 上会存放一个临时的 RIDX 文件，这个文件会包含扫描到的磁盘源数据和勒索数据，比如加密的数据、文件类型、洋葱地址、勒索通知等。
2. 备份完成后，这个数据会被发送到 VBR 上的 VBRCatalog 文件夹中。
3. VBR 将收到的 RIDX 文件和存放在 VBRCatalog 文件夹中的历史存档将进行比较，确定是否有恶意攻击发生，如果侦测到异常，就会发出事件通知，将备份存档标记为 Suspicious。

#### 启用方法和排除方法

在 VBR 控制台的左上角，打开 VBR 的全局设置菜单，可以找到 v12.1 新增的 Malware Detection 选项，打开这个设置选项就可以看到如下图的配置复选框和滑块。默认情况下，复选框是没有被启用的，要打开扫描，可以勾上复选框。滑块是设置扫描灵敏度的，默认被置于 Normal 级别，可以根据实际情况调整灵敏度。

[![pkPXjYT.png](https://s21.ax1x.com/2024/04/27/pkPXjYT.png)](https://imgse.com/i/pkPXjYT)

如果有些特殊机器，不希望进行扫描，可以通过全局排除选项进行排除。和上面的启用方法一样，在 VBR 控制台的左上角，打开 VBR 的 Global Exclusion，可以找到 v12.1 全新的 Malware Exclusion 选项。

[![pkPX7Os.png](https://s21.ax1x.com/2024/04/27/pkPX7Os.png)](https://imgse.com/i/pkPX7Os)

在这里可以添加需要排除的虚拟机，也可以添加需要排除的 Veeam Agent。

[![pkPjFTx.md.png](https://s21.ax1x.com/2024/04/27/pkPjFTx.md.png)](https://imgse.com/i/pkPjFTx)



### Index Scan

除了上面的 Inline 方式进行扫描之外，VBR 还能够利用文件系统的 Index 记录功能来进行恶意文件分析。这个分析借助了 VBR 的 Guest Processing 中 Index guest files 的功能，默认情况下全局选项是打开的，但是它需要配合每一个备份作业中 Guest Processing 选项来一起工作，如果备份作业的 Guest Processing 步骤中的 Index guest files 复选框没有启用，那么 Index Scan 对于该备份作业也不会生效。

Index Scan 的扫描会针对以下几种异常状况：

- Index Scan 在工作时，会调用 VBR 中 SuspiciousFiles.xml 文件中已知的可疑文件扩展名进行匹配，发现已知的可疑文件后，系统会发出警告。
- 如果有超过 200 个文件被重命名，并且重命名后都带有同样的扩展名，系统会发出警告。
- 如果有包含特殊扩展名的 25 个文件以上或者 50% 的文件被删除，系统会发出警告。



#### 工作原理

这个扫描会在备份作业运行的时候进行，因为是 Guest Processing 服务，因此它会在每一台虚拟机或者物理机上抓取文件的索引信息，传输到 VBR 的 VBRCatalog 目录中，并由 VBR 的 Veeam Data Analyzer Service 来分析这个数据。

在工作时，SuspiciousFiles.xml 相当于是这个扫描的病毒库，VBR 在安装后，内置了出厂的库，备份管理员可以通过在线或者离线的方式来更新这个文件。

#### 启用方法和排除方法

全局的启用选项和前面的 Inline Scan 一样，在 VBR 控制台的左上角，打开 VBR 的全局设置菜单，找到 Malware detection 选项，第二部分就是这个 Index Scan 的功能。默认情况下，这个复选框是选上的。在这个复选框下面，还有一个复选框是在线更新 SuspiciousFiles.xml 文件的，如果 VBR 能连接互联网，那么这个文件可以定期被自动更新。如果需要手工更新这个文件，可以参考 https://www.veeam.com/kb4514。
[![pkPXvfU.png](https://s21.ax1x.com/2024/04/27/pkPXvfU.png)](https://imgse.com/i/pkPXvfU)

在全局启用后，每个备份任务中，需要额外启用 Index 功能，因此如果不想扫描，只需要在备份任务中不启用 Index 即可。

[![pkPjMnA.md.png](https://s21.ax1x.com/2024/04/27/pkPjMnA.md.png)](https://imgse.com/i/pkPjMnA)



### 恶意事件管理

以上两种扫描，如果触发了告警之后，在 Inventory 界面的 Malware Detection 中会出现黑体加粗的恶意攻击警告，对应的虚拟机或者物理机会在这里列出来。以上两种扫描的结果会被标记成 Suspicious 状态。

[![pkPXqwq.png](https://s21.ax1x.com/2024/04/27/pkPXqwq.png)](https://imgse.com/i/pkPXqwq)

在 History 中，也会有一大类新的事件，会列出每次备份中各种事件扫描到的内容。每个事件选择后，上方的工具栏或者右键菜单，都有事件详情的选项，可以打开详情查看具体发生了什么恶意事件。

[![pkPXbmn.png](https://s21.ax1x.com/2024/04/27/pkPXbmn.png)](https://imgse.com/i/pkPXbmn)

在详情中，会记录更加详细的事件记录的具体日志文件。



以上就是 VBR v12.1 中，在线勒索攻击的侦测方法，希望大家在启用功能后，永远别扫描到有数据被攻击。


# VDP v12.1 安全功能深度分析系列（二）- 恶意软件扫描


接着昨天的，来说说第二大重磅更新功能，YARA Scan 和 Antivirus Scan。 

VBR 除了能对备份数据流进行在线扫描之外，现在还支持对备份下来的备份数据进行二次扫描。v12.1 中具备两大扫描引擎，一个是使用 Mount Server 上的杀毒软件作为扫描引擎，另外一个是使用 YARA 作为扫描引擎。

### YARA 工具

YARA(全称：*Yet Another Recursive Acronym*)。官网链接：https://yara.readthedocs.io/en/latest/，Github 仓库链接：https://github.com/virustotal/yara。

YARA 通常是用来帮助安全专家和研究人员识别和分类恶意软件，它主要用于恶意软件的研究和检测。它能够扫描文本或者二进制模式的代码。

YARA 工具一般包含两部分，其中一部分是 YARA 扫描引擎本身，它可以安装在各种平台上。另外一部分是 YARA 规则，这个是使用者根据实际需求进行编写的匹配规则。在 YARA 使用时，简单逻辑是，YARA 引擎调用 YARA 规则扫描对应的需要扫描的内容，输出扫描结果。

在 VDP v12.1 中，加入了 YARA 工具，备份和安全管理员，可以直接在 VBR 控制台调用编写好的 YARA 规则，对备份存档进行扫描。完全不需要自己去手工搭建 YARA 运行环境。

#### YARA 规则

关于 YARA 规则，其实语法非常简单，可以参考官网的说明 https://yara.readthedocs.io/en/stable/writingrules.html，在 Github 上能找到相关的规则模版 https://github.com/Yara-Rules/rules。

在 VBR 上，内置了 3 段经典的 YARA 规则模版，可以作为编写的参考。

当然现在也不用那么麻烦，各种 GPT 可以帮我们轻松写一段 YARA 规则，比如：
[![pkiq6D1.png](https://s21.ax1x.com/2024/04/28/pkiq6D1.png)](https://imgse.com/i/pkiq6D1)


#### YARA 扫描工作原理

将以上 Chat GPT 帮我生成的内容存入到一个.yar 或者.yara 结尾的文件中，然后放到`C:\Program Files\Veeam\Backup and Replication\Backup\YaraRules` 目录下，VBR 就能自动识别到这些规则。
[![pkiqhCD.png](https://s21.ax1x.com/2024/04/28/pkiqhCD.png)](https://imgse.com/i/pkiqhCD)

启动扫描后，VBR 会将备份存档挂载到 Mount Server 上，然后利用 Mount Server 上的 YARA 引擎加载选择的 YARA 规则进行扫描。

当然，这个扫描因为是文本和二进制扫描，它不仅局限于恶意代码的扫描，实际上它能够扫描任何我们想查找的关键信息。


### 杀毒软件扫描

在 VBR v10 开始就在 Secure Restore 功能中内置了杀毒软件的扫描，VBR 会调用在 Mount Server 上的杀毒软件对备份存档进行扫描。v12.1 中，这个功能被集成到了 Scan Backup 中，并且内置支持的杀毒软件也更加丰富了。

#### 杀毒软件配置

在 v12.1 中内置了 Symantec Protection Engine、ESET、Windows Defender、Kaspersky Security、Bitdefender Endpoint Security Tools、Trellix (以前鼎鼎大名的 McAfee) 这 6 款杀毒引擎。

除了这 6 款软件之外，如果需要使用其他的杀毒软件，Veeam 也支持通过 AntivirusInfos.xml 配置其他的杀毒软件，只需要修改 Mount Server 上`%ProgramFiles%\Common Files\Veeam\Backup and Replication\Mount Service`这个目录下的 xml 文件，通过 CLI 命令行调用对应杀毒软件即可。更详细的 xml 配置方法，可以查看官网的详细 xml 语法属性说明 https://helpcenter.veeam.com/docs/backup/vsphere/av_scan_xml.html?ver=120。



### 配置方法

在 VBR 上，有多种方式启动扫描。

1. 选中受支持的备份存档，右键点击或者选择工具栏上的`Scan Backup`按钮，激活杀毒引擎扫描或者 YARA 扫描对话框。

[![pkiqW4O.png](https://s21.ax1x.com/2024/04/28/pkiqW4O.png)](https://imgse.com/i/pkiqW4O)
启动 Scan Backup 后，会打开扫描对话框，这时候，可以用这两个引擎按照 3 中不同的扫描方式对整条备份链进行安全扫描。

[![pkiqRUK.png](https://s21.ax1x.com/2024/04/28/pkiqRUK.png)](https://imgse.com/i/pkiqRUK)

2. 在各种整机或者磁盘恢复的 Secure Restore 步骤中，勾选杀毒引擎扫描或者 YARA 扫描选项。
[![pkiqcHx.png](https://s21.ax1x.com/2024/04/28/pkiqcHx.png)](https://imgse.com/i/pkiqcHx)


3. 在 Surebackup 作业中，勾选杀毒引擎扫描或者 YARA 扫描选项。
[![pkiq2E6.png](https://s21.ax1x.com/2024/04/28/pkiq2E6.png)](https://imgse.com/i/pkiq2E6)


#### 查看扫描结果

如果扫描结果匹配到了需要查找的内容，VBR 就会标记扫描到的备份存档为 Infected 状态，表示有恶意软件被发现。

完整的扫描存档会记录在 VBR 的这个目录下：`C:\ProgramData\Veeam\Backup\FLRSessions\Windows\FLR__<machinename>_\Antivirus`

和前面介绍的在线恶意攻击分析一样，在 VBR 的 History 中也会记录到详细的扫描状态，可以在 History 中查找扫描的结果。

[![pkiqyuR.png](https://s21.ax1x.com/2024/04/28/pkiqyuR.png)](https://imgse.com/i/pkiqyuR)



以上这些就是 VDP v12.1 中新增的一些备份存档扫描检查方法，能够帮助管理员在发生问题后避免二次感染，确保恢复出来的数据是干净的系统存档。


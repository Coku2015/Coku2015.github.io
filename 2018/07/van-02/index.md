# Veeam Availability for Nutanix AHV 配置和使用系列（二）


上一期介绍了 [《Veeam Availability for Nutanix AHV 的安装和配置》](http://mp.weixin.qq.com/s?__biz=MzU4NzA1MTk2Mg==&mid=2247483910&idx=1&sn=fc9effdd1355334ca52380e518a2ab73&chksm=fdf0a4d3ca872dc5d653cf1c7f78b8f7363a3df3c1f1409ce2f5a4c06eca4fac866eaff1b00c&scene=21#wechat_redirect)，本期来说说 VAN 的备份和恢复。

备份 AHV 的虚拟机

VAN 的所有备份操作依旧是以备份作业方式，但是和 VMware/Hyper-V 不同的是，Nutanix AHV 的 VM 备份作业都会在 VAN Console 中进行，而不是 VBR 上。

进入 VAN Console 中，上面的菜单非常简单，顶部从左向右分别是仪表盘、备份作业、已保护的虚拟机、事件这 4 个页面。

![1qgEOU.png](https://s2.ax1x.com/2020/02/13/1qgEOU.png)

备份作业可以进入 Backup Jobs 中设定，同时在这里也能查看到备份作业的运行状态。

![1jOwid.png](https://s2.ax1x.com/2020/02/14/1jOwid.png)

备份作业设定步骤

1. 在 Backup Jobs 页面中，点击 Add 按钮就可以新增备份作业。设置过程还是 Veeam 经典的向导模式，5 个步骤就能完成所有设定操作，非常简洁。

第一步，和 VBR 中的设定一样，是 Job Name 和 Job Description，根据实际情况输入信息即可。

![1qcxeg.png](https://s2.ax1x.com/2020/02/13/1qcxeg.png)

2. 选择备份哪些 VM，这里和 vSphere/Hyper-V 还是非常像，可以选择非 VM 的对象，比如一个 Host 或者一个 Cluster。

![1qczwQ.png](https://s2.ax1x.com/2020/02/13/1qczwQ.png)

点击 Add 即可打开 Nutanix AHV 的对象选择，和 vSphere/Hyper-V 不一样的是，这里会提示哪些 VM 处于 Unprotected 状态，这能很好的避免重复备份，也能快速定位哪些 VM 没有备份。

![1qgSoj.png](https://s2.ax1x.com/2020/02/13/1qgSoj.png)

3. 选择备份至什么位置，这里会列出 VBR 中已经设定了 Allow 权限的 Repository，可以选择普通的 Repository，也可以选择 Scale-out Repository。

![1qg9Fs.png](https://s2.ax1x.com/2020/02/13/1qg9Fs.png)

4. 设定计划任务，此处的界面会稍微有点不同，个人认为这一新的 Web 界面让 Schedule 选择变得更加美观，而计划任务的逻辑则和原来的 VBR 是完全一致。

![1qgCYn.png](https://s2.ax1x.com/2020/02/13/1qgCYn.png)

5. 最后一步 review 一下以上设定后，备份作业就设定完了。备份作业会在指定的时间自动开始运行。

![1qgklV.png](https://s2.ax1x.com/2020/02/13/1qgklV.png)

查看备份状态

而备份作业运行后，我们可以在 VAN Console 或者 VBR 中查看到备份状况，而 VBR 中并不能做任何的编辑，仅能查看状态。

![1qgZmF.png](https://s2.ax1x.com/2020/02/13/1qgZmF.png)

还原 AHV 的虚拟机

VAN 的还原可以在 VAN Console 中操作，也可以在 VBR Console 中进行。但是在这两个控制台中能做的操作会有些差别。

VAN Console 还原

在 VAN Console 中，Veeam 提供完整虚拟机还原和虚拟磁盘还原。

![1qgAyT.png](https://s2.ax1x.com/2020/02/13/1qgAyT.png)

**完整虚拟机还原**

1. 点击 Restore 按钮，会打开还原向导。

![1jOLo4.png](https://s2.ax1x.com/2020/02/14/1jOLo4.png)

2. 点击 Add 添加需要还原的虚拟机。

![1jOvWR.png](https://s2.ax1x.com/2020/02/14/1jOvWR.png) 点击 Point 按钮，可以选择适合的还原点进行恢复。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEoSdoztgwh9ZvGoSMY7yIPHHnyWSSLnjlUAH8g1JCNpWCxll5H2R91pw/640?wx_fmt=png)

4. 进入下一步后，可以选择还原位置。对于原始位置，没有太多选项，是对原有虚拟机的直接覆盖，而选择恢复到新位置时，可以输入更多配置，变成一台新的虚拟机。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEo6QS4nRBRDyolzfbsVntg1JCDgI3hSBQiafFPaLDUGeSuPYg6l88lahA/640?wx_fmt=png) 设定新的 VM name，和原始 VM 名称不同。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEopnDxJvLtCq5tLUSJoVU9FZibxhzTVeqKxEaelndRwy34mJuiaic9G15zA/640?wx_fmt=png)

6. 选择合适 VM Container，默认这里是原始的位置，可以根据实际情况选择新的节点和新的 Container。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEol4RQE5teawxEYRXNObpqlicS6k6YMIkNmH2SkU8aOLWlUJA5QibYcd4Q/640?wx_fmt=png)

7. 输入合适的还原理由后，可以开始 VM 的完整还原。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEoLOXDZQmichAWCda577qeZHgibOvOnIJUtrW6W8LWIFkIiccSicxVt80K5Q/640?wx_fmt=png)

部分 Disk 还原

1. 点击 Disk Restore，可以启动单个 virtual disk 的还原向导，选择需要还原的 VM

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEo04EYjZ7q8hen8X2Wak6QQCCERia7yDC357YPbjObFUCKBR6LOI2vmQQ/640?wx_fmt=png)

2. 选择合适的还原点。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEo7QZFicHfF64huyrOQaek0ZB8kiaLG1eicEIecuCZyFiccCViaBNzXBfKfDQ/640?wx_fmt=png) 设定 Disk 映射关系。

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEo08G1r7ouEMxwicjY85osKibzxuCUpLe8KcFxJjLJVfOkYFibICP45HYCA/640?wx_fmt=png)

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEoibyysicT8RhlmXlTdic9fwibHKJsVsrribHZJJvgInq2AU8s1yzIXH4f3BQ/640?wx_fmt=png)

4. 设定完 Restore Reason 后，点击 Finish 即可进入恢复过程。

VBR Console 还原

在 VBR Console 中，VAN 存档支持标准的 Veeam Agent 还原方式，即：Instant Recovery to Hyper-V、Export to Virtual Disk（VMDK/VHD/VHDX）、Guest File Restore、Application Item Restore 以及 Direct Restore to Microsoft Azure。

![1qgew4.png](https://s2.ax1x.com/2020/02/13/1qgew4.png)

此处操作就和 Agent 完全一致了，其中对于 Linux VM 的文件级恢复，依旧需要借助一台 Hyper-V 或者 vSphere 上的 Help Appliance 才可以完成。本文就不再详细展开介绍 VBR Console 中的恢复方式，具体可参看 VBR 中 Agent 的恢复。


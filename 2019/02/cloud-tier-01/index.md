# Veeam Cloud Tier – 云对象存储使用详解（一）


2019 年 1 月 23 日 Veeam 发布了其产品历史上功能最多的一次 Update 包 VBR 9.5U4，其中包含了一系列和云相关的功能模块，本文将会详细讨论其中最主要的一个特性：云对象存储。

在 VBR 9.5U4 中，可以使用 Amazon S3、Microsoft Azure Blob、IBM Cloud Object Storage 以及其他各种兼容 S3 协议的对象存储，因此，对于我们国内用户 AliCloud OSS 和 Tencent Cloud COS 也能够完美支持。

 

## 云对象存储的定位

在 VBR 中有三大类 Repository，分别是 Backup Repository、External Repository 和 Scale-Out Backup Repository（SOBR）。我相信对于绝大多数 Veeam 使用者，Backup Repository 是再熟悉不过了，那是 Veeam 存放备份数据的磁盘位置，也是以往被使用最多的数据存放方式。External Repository 是 VBR 9.5U4 新增的，这个并不是本文云对象存储涉及到的部分，本文暂且不讨论。而 SOBR，在以前的 VBR 版本中，可能鲜有提及，而在未来，这将可能成为 Veeam 最主要的数据存储方式。

在了解云对象存储之前，我觉得有必要来回顾一下 SOBR 的组成，每个 SOBR 都会由 1 个以上的 Extents 组成，每个 Extents 其实就是一个常规的 Backup Repository，也就是说，SOBR 就是一个 Backup Repository 的集合，这是以往 SOBR 的基本组成。

在这个全新的 SOBR 中，Veeam 把它分成两个层级，分别是 Performance Tier 和 Capacity Tier，所有本地磁盘组成的 Extend 都被归类为 Performance Tier，而云对象存储组成的 Extents 则被归类为 Capacity Tier。

 

## 工作原理

简单来说，含有云对象存储的 SOBR 必须由 1 个以上的 Extents 组成，然后必须包含 1 个云对象存储。

- 每隔 4 小时，Veeam 会根据 SOBR 中的保留策略设定自动运行 SOBR Offload 任务，将本地需要上传至云端的数据上传至云端的对象存储中。
- 相对的，SOBR Download 任务则对应可以将云对象存储中的数据取回本地 Extents 之中。

而在还原过程中，云对象存储可以说是近乎于透明状态的存在，它和以往任何的存储解决方案都会不一样，在 Veeam 中，云对象存储上的还原点，可以保留其原有的任何还原能力，以完全源生平滑的方式来进行数据还原。

我们来看一个实际的例子：当进行数据还原时，选择的还原点位于云对象存储上时，Veeam 首先会去读取本地的数据索引（Index），这个 Index 会告诉 Veeam，哪些数据同时存在于云上和本地，那么在读写数据时，Veeam 将会优先去使用本地的数据作为数据源，而只会从云中获取那些本地不存在的数据。这将大大减少云对象存储的使用费用，因为绝大多数的云对象存储的使用计费会更多的按照请求和回流来计算。

 

## 管理和操作

1. 添加云对象存储

上文提到过，云对象存储也是属于 SOBR 的一个 Extents，而 Extents 则是一个 Backup repository，因此添加云对象存储的入口就是 Add Repository。

![1qnKT1.png](https://s2.ax1x.com/2020/02/13/1qnKT1.png)

在 Add Backup Repository 中会新增一个向导 Object Storage，这就是添加云对象存储，其中包含了上文提到的 4 种不同的协议。

![1qnQFx.png](https://s2.ax1x.com/2020/02/13/1qnQFx.png)

添加过程非常简单，如同任何 Veeam 功能一样，以交互的方式填入合适的信息即可完成配置，本文就不做官方 User Guide 的复读机了，可以根据实际使用的云对象存储选择合适的存储类型进行添加。

https://helpcenter.veeam.com/docs/backup/vsphere/new_object_storage.html?ver=95u4

2. 配置 SOBR 和 Capacity Tier

在 Backup Infrastructure 中找到 Scale-Out Backup Repository，然后点击 Add 来新增，这时候需要首先配置 Performance Tier。关于 Performance Tier 的配置详细选项，本文就不展开进行详细讨论，有需要的可以查看官方 User Guide 中的相关章节。

https://helpcenter.veeam.com/docs/backup/vsphere/sorb_add_extents.html?ver=95u4

![1qnlY6.png](https://s2.ax1x.com/2020/02/13/1qnlY6.png)

选择默认的 Placement Policy 后，就可以进入 Capacity Tier 的配置，这时，在上一步中配置的云对象存储库就会出现在下图的 List 中，同时在这个页面上我们也可以配置如何去进行 SOBR Offload 任务，也就是我们前面提到的 SOBR 的保留策略。

![1qn1fK.png](https://s2.ax1x.com/2020/02/13/1qn1fK.png)

设置完本页内容之后，云对象存储的配置就完成了。

3. 使用操作

日常备份中，我们不需要过多的操作，系统后台会定时 4 小时去检查是否有数据需要 Offload，如果没有数据需要 Offload，或者说没有数据满足 Offload 条件，那么这个 SOBR Offload task 会迅速完成。

当然我们有手工进行数据传输的方式，可以按需进行数据的 Offload 和 Download。

举个例子，如图我们已经有一组备份存档，部分位于云对象存储中，部分位于本地磁盘上。

![1qnYOH.png](https://s2.ax1x.com/2020/02/13/1qnYOH.png)

这时候，对于云上的数据，我们可以做 Copy to Performance Tier 操作，这个操作就是 SOBR Download 任务。在 Download 过程中，Veeam 依旧是通过 Index 最优化取回数据，可以通过本地磁盘中重组的数据，就不会从线上取回。

![1qnGlD.png](https://s2.ax1x.com/2020/02/13/1qnGlD.png)

以上就是今天的内容，下一期我们会更深入的探讨 Veeam 云对象存储使用。


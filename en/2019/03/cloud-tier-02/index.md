# Veeam Cloud Tier – Understanding Cloud Object Storage Architecture (Part 2)


Last time, we covered the fundamentals of Veeam's Cloud Tier functionality. I noticed a few technical details in that post that needed clarification, so if you're looking for the updated version, just drop me a message with "Cloud" and I'll share the corrected version.

Today, we're diving deeper for those of you who want to understand the sophisticated architecture behind Veeam's cloud storage optimization.

One of the first things you'll notice when using Cloud Tier is that Veeam maintains full recovery capabilities regardless of where your backup archives live—whether in your local data center or in cloud object storage. This includes Veeam's groundbreaking Instant VM Recovery technology, which we pioneered back in 2010. If you want to explore that technology in detail, I covered it thoroughly in [this earlier post about vPower NFS](http://mp.weixin.qq.com/s?__biz=MzU4NzA1MTk2Mg==&mid=2247483838&idx=1&sn=d5ba99c0f7c8d649a5efe247159d4ebf&chksm=fdf0a76bca872e7d0161cbb7fcd9e1a5c4e6426d17fef21b24876d9222c8772aba3c710e6411&scene=21#wechat_redirect).

### The Economics of Cloud Storage

What makes cloud object storage special is its pricing model. Unlike traditional storage where you make a one-time capital investment, cloud providers charge across four dimensions: storage capacity, read/write requests, data transfer out, and subscription duration. This fundamental difference creates an interesting cost dynamic.

For long-term archival data that's rarely accessed, the costs for read operations and data retrieval become remarkably low. This is precisely why object storage excels as an off-site archival solution.

However, this economic model comes with a crucial caveat. If backup vendors treat cloud object storage like traditional local storage, the frequent read/write operations that are commonplace in traditional environments—things like data verification, integrity checks, recovery testing, and periodic deduplication—can generate unexpectedly high I/O and retrieval costs.

This is where Veeam's intelligent approach shines. We've completely restructured how data interacts with cloud object storage, implementing sophisticated access patterns that minimize I/O operations while ensuring data availability. The goal is simple: reduce your cloud storage costs without compromising on reliability.

### Metadata and Data Block Separation

Every Veeam backup archive (.vbk, .vib, .vrb files) consists of two fundamental components: **Metadata** and **Data Blocks**. In traditional local storage, these components are tightly coupled within the same file. But when data moves to cloud object storage, Veeam employs a clever separation strategy.

We split the metadata and data blocks, storing them in separate directories. Crucially, we keep the metadata locally on disk. This design choice enables fast recovery operations—Veeam can quickly locate and retrieve the required data blocks from either local or cloud storage based on availability and cost optimization.

### Intelligent Indexing System

The real magic happens with Veeam's indexing system, which gets generated when your SOBR Offload Job runs. This index contains hash values for every data block within your backup files. Veeam extracts these hashes from the backup archive metadata and stores them in the ArchiveIndex directory.

What makes this system so powerful is its deduplication efficiency. During subsequent data transfers, if Veeam encounters a data block with a hash that already exists in the index, it skips the upload entirely. This approach saves significant bandwidth and upload time by reusing existing data blocks.

However, there's an important limitation to understand: this indexing operates at the backup chain level. Two different backup jobs targeting the same VM won't share data blocks, even if the blocks have identical hashes. Each backup chain maintains its own index, which gets regenerated whenever the chain structure changes.

The index also tracks data block locations across both local and cloud storage. If a particular data block exists in three different full backups—two locally and one in the cloud—the index maintains awareness of all three locations. During new upload operations, Veeam leverages this intelligence to skip uploading blocks that already exist in the cloud, updating both local and cloud records accordingly.

This same indexing mechanism works brilliantly during recovery operations. Veeam prioritizes using locally stored data blocks whenever available, dramatically reducing the need to pull data from cloud object storage. This intelligent data sourcing is what makes Instant VM Recovery feasible even when working primarily with cloud-stored backups.

![1qnwkt.png](https://s2.ax1x.com/2020/02/13/1qnwkt.png)

### Understanding Backup Chain Architecture

A critical concept in Cloud Tier operations is the distinction between active and inactive backup chain segments. Only inactive portions of backup chains can be uploaded to cloud object storage. This holds true regardless of whether the upload is triggered manually or through automated schedules—restore points in the active chain segment will never be offloaded.

Veeam introduced this active/inactive segmentation concept specifically for cloud operations, and it's fundamental to understanding how Cloud Tier manages data placement.

Let's quickly review what constitutes a backup chain. In Veeam's architecture, backup data is stored as a chain of interdependent files. For a standard incremental backup, this typically looks like a full backup followed by a series of incremental backups. This entire collection of files represents a single backup chain.

The active/inactive boundary is defined by the most recent full backup. Everything preceding that full backup is considered the inactive portion. The full backup itself and all subsequent incrementals comprise the active portion.

![1qnU0A.png](https://s2.ax1x.com/2020/02/13/1qnU0A.png)

While this example uses standard incremental backups, the same principles apply to reverse incremental, forever forward incremental, and backup copy jobs—the specifics may vary slightly, but the active/inactive concept remains consistent.

As your backup jobs continue running over time, older restore points naturally transition from active to inactive status as new full backups are created. This gradual transition enables the automated offload process to move historical data to cloud storage without disrupting your recent recovery capabilities.

### Data Upload Decision Criteria

So, what determines which data gets uploaded to cloud object storage? Veeam evaluates three key conditions:

```
✓ Data must belong to the inactive portion of the backup chain
✓ Data must be older than the specified Capacity Tier retention period
✓ Data blocks must not have been previously uploaded for this backup job
```

Only when all three conditions are satisfied will the data be queued for cloud upload. This sophisticated decision-making ensures that Cloud Tier operations are both cost-effective and performance-optimized.

By understanding these architectural principles, you can better appreciate how Veeam has engineered Cloud Tier to deliver the best of both worlds: the economics of cloud storage combined with the performance characteristics of local infrastructure.


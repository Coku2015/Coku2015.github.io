# Veeam Cloud Tier – Detailed Usage of Cloud Object Storage (Part 1)


On January 23, 2019, Veeam released VBR 9.5U4, which was the most feature-rich update in the product's history. This update included a series of cloud-related feature modules, and this article will discuss in detail the most important one among them: cloud object storage.

In VBR 9.5U4, you can use Amazon S3, Microsoft Azure Blob, IBM Cloud Object Storage, and various other S3-compatible object storages, which means that for our domestic users, AliCloud OSS and Tencent Cloud COS are also perfectly supported.



## The Role of Cloud Object Storage

In VBR, there are three main types of repositories: Backup Repository, External Repository, and Scale-Out Backup Repository (SOBR). I believe for the vast majority of Veeam users, Backup Repository is the most familiar one. That's where Veeam stores backup data on disk and has been the most commonly used data storage method. External Repository was newly added in VBR 9.5U4, but this is not part of the cloud object storage discussed in this article, so we won't discuss it here for now. As for SOBR, it might have been rarely mentioned in previous VBR versions, but in the future, it could become Veeam's primary data storage method.

Before understanding cloud object storage, I think it's necessary to review the composition of SOBR. Each SOBR consists of one or more Extents, and each Extent is actually a regular Backup Repository. In other words, SOBR is a collection of Backup Repositories, which was the basic composition of SOBR in the past.

In this brand new SOBR, Veeam divides it into two tiers: Performance Tier and Capacity Tier. All local disk-based Extents are classified as Performance Tier, while cloud object storage-based Extents are classified as Capacity Tier.



## How It Works

Simply put, a SOBR containing cloud object storage must consist of one or more Extents, and must include one cloud object storage.

- Every 4 hours, Veeam automatically runs the SOBR Offload task according to the retention policy settings in the SOBR, uploading data that needs to be uploaded to the cloud from local storage.
- Conversely, the SOBR Download task can retrieve data from cloud object storage back to local Extents.

During the restore process, cloud object storage exists in an almost transparent state. It's different from any previous storage solution. In Veeam, restore points on cloud object storage can retain all their original restore capabilities, performing data restoration in a completely source-native smooth manner.

Let's look at a practical example: when performing data restoration, if the selected restore point is located on cloud object storage, Veeam will first read the local data index. This index tells Veeam which data exists both in the cloud and locally. When reading and writing data, Veeam will prioritize using local data as the data source and only fetch data that doesn't exist locally from the cloud. This will greatly reduce cloud object storage usage costs because the billing for most cloud object storage services is calculated based on requests and data transfer.



## Management and Operations

1. Adding Cloud Object Storage

As mentioned above, cloud object storage is also an Extent of SOBR, and Extents are Backup repositories. Therefore, the entry point for adding cloud object storage is Add Repository.

![1qnKT1.png](https://s2.ax1x.com/2020/02/13/1qnKT1.png)

In Add Backup Repository, a new Object Storage wizard will be added, which is for adding cloud object storage, including the 4 different protocols mentioned above.

![1qnQFx.png](https://s2.ax1x.com/2020/02/13/1qnQFx.png)

The addition process is very simple. Like any Veeam function, you can complete the configuration by interactively filling in appropriate information. This article won't repeat the official User Guide. You can select the appropriate storage type according to the cloud object storage you actually use.

https://helpcenter.veeam.com/docs/backup/vsphere/new_object_storage.html?ver=95u4

2. Configuring SOBR and Capacity Tier

Find Scale-Out Backup Repository in Backup Infrastructure, then click Add to create a new one. At this point, you need to configure the Performance Tier first. Regarding the detailed options of Performance Tier configuration, this article won't expand into detailed discussion. Those in need can check the relevant chapters in the official User Guide.

https://helpcenter.veeam.com/docs/backup/vsphere/sorb_add_extents.html?ver=95u4

![1qnlY6.png](https://s2.ax1x.com/2020/02/13/1qnlY6.png)

After selecting the default Placement Policy, you can enter the Capacity Tier configuration. At this time, the cloud object storage repository configured in the previous step will appear in the List below. On this page, we can also configure how to perform SOBR Offload tasks, which is the SOBR retention policy we mentioned earlier.

![1qn1fK.png](https://s2.ax1x.com/2020/02/13/1qn1fK.png)

After setting up the content on this page, the cloud object storage configuration is complete.

3. Usage Operations

In daily backups, we don't need too much operation. The system will automatically check every 4 hours to see if there is data that needs to be offloaded. If there is no data that needs to be offloaded, or if no data meets the offloading conditions, the SOBR Offload task will complete quickly.

Of course, we have ways to manually transfer data. We can perform data Offload and Download on demand.

For example, as shown in the figure, we already have a set of backup archives, some located in cloud object storage and some on local disks.

![1qnYOH.png](https://s2.ax1x.com/2020/02/13/1qnYOH.png)

At this time, for the data in the cloud, we can perform the Copy to Performance Tier operation, which is the SOBR Download task. During the Download process, Veeam still optimizes data retrieval through the Index. Data that can be reassembled from local disks will not be retrieved from the cloud.

![1qnGlD.png](https://s2.ax1x.com/2020/02/13/1qnGlD.png)

The above is today's content. In the next issue, we will discuss Veeam cloud object storage usage in more depth.

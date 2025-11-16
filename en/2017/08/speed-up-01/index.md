# Speed Up! Speed Up! Speed Up! (Part 1)


I don't often talk about speed and performance, because I've always considered it a fundamental requirement—like a good car's engine. You expect it to work well, and you don't really think about it until something goes wrong.

But here's the thing: in the world of backup and recovery, that engine is everything. It's where backup software truly proves its worth. Today, I want to dive deep into Veeam's acceleration technologies.

This is part one of a new series focused on performance, starting with the heart of Veeam's speed advantage: the Backup Acceleration Engine. This isn't just about faster backups—it's about how Veeam helps customers achieve true IT availability.

## Veeam's Backup Acceleration Engine

Most backup solutions use VMware's vStorage API for Data Protection (VADP) with the Virtual Disk Development Kit (VDDK). But Veeam goes further by adding something special: the Veeam Advanced Data Fetcher (ADF).

Think of ADF as a performance multiplier for enterprise storage arrays. It increases queue depth by more than 2x, which means dramatically faster data reads from vSphere environments. Compared to similar backup products, Veeam delivers double the efficiency at the source.

Even better, ADF reduces the number of I/O operations needed to read data, which means less impact on your production storage when backing up the same amount of data.

### Smart Control with Backup I/O Control

Speed is great, but not at the expense of production performance. That's why Veeam paired ADF with intelligent throttling: Backup I/O Control.

When production storage is already struggling with slow reads, backup software typically doesn't need to worry about causing performance issues. But when you can read data quickly, you must consider the production storage's capacity to handle additional load. This isn't something you can just guess at—it requires intelligent control.

![174YKf.png](https://s2.ax1x.com/2020/02/12/174YKf.png)

The magic happens when Veeam ADF and Backup I/O Control work together. They automatically sense production storage latency and dynamically adjust ADF's throughput to keep backups running within acceptable latency ranges.

### Transforming Backup Windows

Traditionally, backup administrators would schedule daily backups during off-peak hours—typically late at night when business activity is minimal. This results in a 24-hour Recovery Point Objective (RPO), not because administrators are overly cautious, but because they lacked intelligent control mechanisms. Backups had to step aside for production to ensure availability.

With Veeam's engine—specifically the collaboration between ADF and Backup I/O Control—backup administrators can now run backups anytime without impacting production. This dramatically improves backup RPO.

This is what sets Veeam apart. Many solutions can perform backups, but Veeam's technology helps you achieve availability goals at the same time. Critical business workloads can be backed up anytime, not just during maintenance windows.

True 24×7×365 availability starts with smarter backup practices.

---

**Coming Up Next:**

vSphere Communication Acceleration — Before backing up virtual machines, backup software spends significant time communicating with the virtualization platform. This communication overhead is often the second most time-consuming part of any backup job. Veeam's new Broker Service dramatically speeds up this process, saving valuable time in every backup operation.

# Veeam Black Technology: Direct NFS Access


I've been working with more VMware environments lately, and I'm noticing a clear trend: NFS datastores are becoming mainstream. It used to be that only NetApp enthusiasts would seriously consider NFS for VMware, but times have changed. With the rise of hyper-converged infrastructure, major platforms like Nutanix and Cisco HyperFlex are now delivering storage to VMware exclusively through NFS.

This shift has always been a bit problematic for backup performance. When you're using NFS datastores, your only option for virtual machine backups has been the network transport method (NBD), which caps you at just 40% of VMKernel's total network throughput. Even with plenty of bandwidth available, you'd hit that performance ceiling every time.

![17fbSx.png](https://s2.ax1x.com/2020/02/12/17fbSx.png)

But here's where things get interesting. Starting with Veeam Backup & Replication v9.0, there's a game-changing approach for NFS backups called Direct NFS Access. If you're familiar with Direct SAN Access for SAN environments, you'll recognize the pattern immediately. Instead of routing backup traffic through the ESXi host, Veeam can now read directly from NFS storage - bypassing the host entirely.

![17fL6K.png](https://s2.ax1x.com/2020/02/12/17fL6K.png)

## Getting Started with Direct NFS Access

True to Veeam's philosophy, this powerful feature is surprisingly simple to configure. Let me walk you through the setup process.

First, let's assume you have a virtual machine running on an NFS datastore:

![1T0mpd.png](https://s2.ax1x.com/2020/02/11/1T0mpd.png)

The critical step is configuring your NFS server permissions. You'll need to grant your Veeam Backup Proxy read/write access to the same NFS volume that your ESXi hosts use. In my FreeNAS setup, I configured access for both 10.10.1.130 (the ESXi host) and 10.10.1.171 (the Veeam Backup Proxy):

![17fjmD.jpg](https://s2.ax1x.com/2020/02/12/17fjmD.jpg)

Next, head over to the Veeam console and specify your preferred backup network - this should be the network segment that provides optimal connectivity to your NFS storage:

![17hptA.png](https://s2.ax1x.com/2020/02/12/17hptA.png)

If you've just added a new NFS datastore, run a VMware infrastructure rescan to make sure Veeam recognizes it properly:

![17hF6f.png](https://s2.ax1x.com/2020/02/12/17hF6f.png)

That's it for configuration. Now just run your backup job as usual. Veeam will automatically detect that Direct NFS Access is available and switch to this optimized transport method:

![17h9fI.png](https://s2.ax1x.com/2020/02/12/17h9fI.png)

Notice the [nfs] transport indicator in the backup session - that's your confirmation that Direct NFS Access is active. Compare that to the other transport methods you might see: [san] for Direct SAN Access, [hotadd] for HotAdd mode, and [nbd] for standard network backups.

You can also verify the transport method in the backup logs:

![17hi1P.jpg](https://s2.ax1x.com/2020/02/12/17hi1P.jpg)

## The Bottom Line

Direct NFS Access is one of those features that just makes sense - it delivers significant performance improvements with minimal configuration overhead. If you're running VMware on NFS datastores (and many more of us are these days), this is definitely worth enabling.

For deeper technical details, check out the official Veeam documentation. The performance gains you'll see are substantial, especially in environments where network backup throughput has been a bottleneck.


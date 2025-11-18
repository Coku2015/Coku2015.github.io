# 黑科技 | 激活隐藏在 VBR 中的快照猎手


It's been ages since I last shared something from my "Black Technology" series, but today I'm excited to introduce a feature I've been dying to write about.

This is quite possibly one of Veeam's most powerful yet underappreciated capabilities. I'd rank it in the top three for sheer utility, yet I'm willing to bet most Veeam users have no idea it even exists.

It's like having a silent guardian working behind the scenes in every single backup and replication job, quietly protecting your virtual machines without anyone noticing.

### Understanding VMware Snapshots

VMware snapshots are probably the most controversial technology in virtualization history. They're the feature that draws many people into virtualization in the first place, yet they're also responsible for driving others away from certain solutions altogether.

For any backup software worth its salt, mastering snapshots isn't optional—it's absolutely essential. You simply can't do proper virtualization backups without becoming a snapshot expert first.

Veeam relies heavily on VMware snapshot technology. When a backup job kicks off, Veeam sends snapshot commands through vSphere's API, and you'll see a temporary snapshot called "***VEEAM BACKUP TEMPORARY SNAPSHOT***" appear in the VM's snapshot manager. Once the job completes, Veeam sends another command to remove it.

![1qnrp8.png](https://s2.ax1x.com/2020/02/13/1qnrp8.png)

Here's where things get tricky. With multiple infrastructure components communicating, things don't always go smoothly. Sometimes that temporary snapshot never gets deleted properly. Even worse, you might experience what I call "false deletion"—the snapshot disappears from the manager but the underlying files remain on your datastore.

These leftover snapshot files (those 00001.vmdk delta files) become what VMware calls **orphaned snapshots**. They're trouble waiting to happen, potentially disrupting future snapshot operations and consuming valuable storage space. VMware does offer a "Consolidate" option to fix this, but getting there isn't always straightforward.

These situations are what we in the VMware community refer to as **snapshot issues**. They're notoriously difficult to spot early, and manual consolidation can fail spectacularly if you don't catch them in time.

For those dealing with these headaches, I've compiled some helpful VMware KB articles that might save you hours of troubleshooting:

> https://kb.vmware.com/s/article/1005049
>
> https://kb.vmware.com/s/article/1006847
>
> https://kb.vmware.com/s/article/1038963
>
> https://kb.vmware.com/s/article/2003638
>

### Enter the Snapshot Hunter

Now, what if you could avoid all that manual consolidation drama entirely?

That's where Veeam Backup & Replication (VBR) comes in with its secret weapon: the **Snapshot Hunter**. This feature is an absolute game-changer for anyone who's ever wrestled with snapshot problems.

The best part? It works completely automatically in the background, running silently in every backup and replication job. Most Veeam users have no idea it's even there, tirelessly protecting their virtual machines from snapshot chaos.

The Snapshot Hunter operates with a simple but brilliant two-step approach:

**Step 1: Cleanup leftover Veeam snapshots**
Before each backup job, it scans for any remaining "***VEEAM BACKUP TEMPORARY SNAPSHOT***" entries from previous jobs and removes them. This ensures your VMs start each backup with a clean slate.

**Step 2: Hunt down orphaned snapshots**
If it finds any orphaned snapshots, it attempts to consolidate them automatically. This catches everything else that might have slipped through the cracks.

But here's where it gets really clever. For that second step—handling orphaned snapshots—Veeam has developed a sophisticated consolidation algorithm that essentially combines the best practices from all four of those VMware KB articles I mentioned earlier.

**The Four-Stage Consolidation Strategy**

**1. The Standard Approach**
First, Veeam tries the same method you'd use manually in vCenter—it attempts standard snapshot consolidation. If this works (and often it does), the problem is solved instantly.

**2. Force Consolidation**
If the standard approach fails, Veeam escalates to a more aggressive strategy. It creates a new snapshot and then triggers VMware's "***Delete all snapshot***" command, essentially forcing the removal of all orphaned snapshots in one operation.

**3. Force Consolidation with Quiescence**
Still having issues? Veeam tries again, but this time it creates a quiesced snapshot (one that ensures application-consistent data) before attempting the deletion again.

**4. The Safety Net**
If all three methods fail, Veeam doesn't keep trying indefinitely. Instead, it sends you an alert recommending manual intervention. This prevents potential storage exhaustion while giving you the information you need to take action.

I'll be sharing a video demo soon that shows the Snapshot Hunter in action—you'll get to see firsthand just how powerful this hidden feature really is.

Until then, keep exploring those lesser-known features. Sometimes the best tools are the ones working quietly in the background, keeping everything running smoothly while we focus on the bigger picture.

Thanks for reading, and I'll catch you in the next one!


# 送 | 为裸奔中的电脑送一个备份保护


### Remembering Norton Ghost: The Tool That Defined an Era

How many of you remember Norton Ghost? For me, Ghost brings back memories from about 20 years ago when I first started building PCs. Back then, after assembling a new computer at the local tech market, the very first thing I'd do was create a system backup with Ghost.

![1jWmhF.jpg](https://s2.ax1x.com/2020/02/14/1jWmhF.jpg)

From that moment forward, Ghost became essential equipment for every computer I owned. Even as we moved through the Windows 7 era ten years ago and into today's Windows 10 world, many PCs still had that dual-boot setup. You know the one—second option: "Restore System with One-Click Ghost." At its peak, Ghost wasn't just popular; it was practically universal.

Ghost was incredibly reliable, but it belongs to another era. Symantec officially stopped updating and supporting Norton Ghost back in March 2013. The version still floating around out there? Stuck at v11. It's a real shame.

But here's the good news: Ghost may be gone, but we now have the perfect replacement—Veeam Agent for Microsoft Windows Free Edition!

I've been thinking about writing this post for a while, mainly because I worried about how people perceive "free" software these days. Let's be honest: most of us immediately think of stripped-down features, companies designing frustrating user experiences to push paid upgrades, and constant nagging about upgrading. When I encounter software like that, my first instinct is to uninstall it immediately.

What made Ghost so special was actually the simplicity of its time. The internet wasn't what it is today, and the software was refreshingly free of commercial considerations. No ads, no bundled crapware—just a tool that worked.

The free Veeam tool I'm excited to share with you today follows that exact same philosophy.

### Meet Veeam Agent for Microsoft Windows Free Edition

Just like Ghost, this is completely ad-free with no bundled software. Download it, install it, and you're ready to go with a full-featured backup solution. The only limitation? It's currently English-only. But that's not a dealbreaker—I'll walk you through everything step by step to get you up and running.

#### Getting Started: Download and Installation

The installation process is refreshingly simple. Head over to the Veeam website (https://www.veeam.com), create an account, and you'll find the free version in their downloads section. Grab the latest version (VeeamAgentWindows_3.0.1.1039.exe at the time of writing), double-click it, and you're on your way. The whole process takes just four steps.

**Step 1: Welcome Screen**
You'll see a brief introduction and license agreement. Feel free to read through if you're curious, or just check both "*I accept*" boxes to enable the Install button and move forward.

![1XlWvt.png](https://s2.ax1x.com/2020/02/14/1XlWvt.png)

**Step 2: Installation Location**
Here Veeam handles everything automatically. You can't customize the installation path—it goes straight into Windows' default program directory, which keeps things simple.

![1Xl4Df.png](https://s2.ax1x.com/2020/02/14/1Xl4Df.png)

**Step 3: Installation Progress**
A few minutes later, you're done! If you have any USB drives connected, Veeam will detect them and offer to set up a backup job. You can skip this for now—we'll configure everything manually.

![1Xl5b8.png](https://s2.ax1x.com/2020/02/14/1Xl5b8.png)

**Step 4: Recovery Media Creation**
Here's where Veeam shows its forward-thinking approach. After confirming successful installation, it prompts you to create Recovery Media. This is your emergency boot disk—essential for restoring your system when everything goes wrong.

![1XlTUg.png](https://s2.ax1x.com/2020/02/14/1XlTUg.png)

#### Essential Next Step: Creating Your Recovery Media

This is one step you don't want to skip. Veeam's wizard makes it painless, but it's absolutely critical for when disaster strikes.

**Step 1: Choose Your Recovery Media Type**
After clicking Finish from the main installation, you'll jump right into the Recovery Media creation wizard. First, decide between creating an ISO image or writing directly to a USB drive. If you have a spare USB drive ready, you can select it directly. For this guide, I'm using an ISO image—process is nearly identical for USB, and you can always convert the ISO to a bootable USB later if needed.

![1XjwS1.png](https://s2.ax1x.com/2020/02/14/1XjwS1.png)

**Step 2: Network Support Options**
Veeam thoughtfully includes two network-related options by default: network drivers and network configuration. This is brilliant for network-based recoveries, saving you headaches during restoration. Select your ISO file location (local drive or network UNC path), and if you're using a network share like CIFS, you'll need credentials to access it.

![1Xj0Qx.png](https://s2.ax1x.com/2020/02/14/1Xj0Qx.png)

**Step 3: Review Your Configuration**
A quick summary screen shows what you've configured so far. Simple, but it's good to double-check before moving forward.

![1XjBy6.png](https://s2.ax1x.com/2020/02/14/1XjBy6.png)

**Step 4: Create Your Recovery Media**
Click Create and let Veeam work its magic. A few minutes later, you'll have your bootable recovery media ready. When your system crashes and won't boot, this ISO or USB drive will be your lifeline. Just remember—the recovery media contains the tools, not your actual backup data.

![1XjDOK.png](https://s2.ax1x.com/2020/02/14/1XjDOK.png)

### Setting Up Your Backup Strategy

Now for the main event: configuring your actual backup job. Open up the Veeam Control Panel, and you'll get a one-time prompt asking whether to run in free mode or enter a commercial license. Just click "No" to continue with the free version—this is the only time you'll see this prompt.

![1Xl75Q.png](https://s2.ax1x.com/2020/02/14/1Xl75Q.png)

Click the three-line menu icon in the top-right corner, then select "Add New Job" to start creating your backup strategy.

![1qdtGF.png](https://s2.ax1x.com/2020/02/13/1qdtGF.png)

As you'll quickly notice, Veeam follows the same clean wizard approach throughout—everything is straightforward and logical.

**Step 1: Name and Describe Your Job**
Give your backup job a meaningful name and add a quick description. This helps when you're managing multiple jobs down the road.

![1Xlq8s.png](https://s2.ax1x.com/2020/02/14/1Xlq8s.png)

**Step 2: Choose What to Back Up**
The free edition gives you flexible options: backup the entire computer (including external USB drives), target specific disk volumes, or even back up individual files and folders. For comprehensive protection, I recommend backing up the entire computer—this captures everything needed for a complete system restore.

![1XlL2n.png](https://s2.ax1x.com/2020/02/14/1XlL2n.png)

**Step 3: Select Your Backup Destination**
Here's where you decide where your backups live. Veeam supports virtually any storage option: USB drives, FireWire, eSATA, network-attached storage (NAS), or even Veeam's own managed backup repositories. For personal use, you'll likely choose an external hard drive or a home NAS. In my setup, I'm backing up to a Synology NAS on my home network.

![1XjYo4.png](https://s2.ax1x.com/2020/02/14/1XjYo4.png)

**Step 4: Configure Storage Settings**
If you chose a network share, you'll need to provide the UNC path, username, and password. Veeam helpfully shows you the available space on your target volume. This is also where you configure important settings like retention policies (how many backup copies to keep), compression and deduplication options, and encryption. For sensitive data, encryption is definitely worth the minimal overhead.

![1XjGeU.png](https://s2.ax1x.com/2020/02/14/1XjGeU.png)

**Step 5: Schedule Your Backups**
This is where Veeam really shines in terms of convenience. Once configured, it runs completely automatically in the background—no manual intervention required. The scheduling options are incredibly flexible, with enough depth that I could write an entire article just on backup strategies. For now, let's keep it simple: set it to run automatically, and you'll never have to worry about forgetting to back up again.

![1XjJwF.png](https://s2.ax1x.com/2020/02/14/1XjJwF.png)

**Step 6: Finalize and Run**
Click Apply to create your backup job. You'll get a final summary of your configuration, and then you can click Finish to complete the setup. If you're eager to get started, check the "Run the job when I click finish" box to kick off your first backup immediately.

![1Xj3LT.png](https://s2.ax1x.com/2020/02/14/1Xj3LT.png)

### Watching Your Backups in Action

Once your job is configured, Veeam takes over completely. Backups run automatically according to your schedule—no intervention needed. Typically, the first backup is a full backup, followed by much faster incremental backups that only capture changes since the last run.

On my system, after completing the initial full backup, the subsequent incremental backup completed quickly. Here's what a successful backup job looks like in the console:

![1qdPKA.png](https://s2.ax1x.com/2020/02/13/1qdPKA.png)

You can browse your backup files directly in Windows File Explorer. You'll notice three types of files:
- **VBM files**: These are metadata files that track your backup chain information
- **VBK files**: Full backup archives (your complete system snapshots)
- **VIB files**: Incremental backup files that depend on their corresponding full backup

![1qdUxJ.png](https://s2.ax1x.com/2020/02/13/1qdUxJ.png)

### Your Turn to Get Protected

And that's it—you now have a comprehensive backup solution protecting your computer, completely free. No more running your system "bare" without protection.

If this sounds useful, I highly recommend downloading Veeam Agent from their official website and getting it set up. The peace of mind is worth the few minutes it takes to configure.

In my next post, I'll walk through the recovery process—how to actually restore your system from those backup archives when disaster strikes. We'll dive deeper into using Veeam Agent for Microsoft Windows Free Edition to its full potential.

For more tech insights and practical guides, follow my blog for regular updates.



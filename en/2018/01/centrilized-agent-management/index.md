# First Post of the New Year - Detailed Guide to Veeam 9.5U3 Centralized Agent Management


Kicking off the New Year with some exciting news! Veeam 9.5U3 brings us centralized agent management, a game-changing feature that transforms how we handle physical and cloud infrastructure backups. The interface has evolved significantly, but don't worry — Veeam maintains its familiar wizard-driven approach that we all know and love.

Let's dive into what's new and explore how this centralized management works.

![17owIe.png](https://s2.ax1x.com/2020/02/12/17owIe.png)

## The Big Picture: Interface Changes

First things first — you'll notice some familiar faces have moved:

* **Backup & Replication** is now called **Home**
* **Virtual Machine** has become **Inventory**
* **Agent management** lives under **Physical & Cloud Infrastructure** in the Inventory section

Veeam's approach to agent management follows its proven three-step methodology:

1. **Create Protection Groups** — Define and automatically discover what needs protecting
2. **Create Jobs or Policies** — Set up your backup configurations
3. **Execute Restores** — Recover data when needed using various methods

This consistency makes the transition smooth for anyone familiar with Veeam's virtualization backup workflows.

## Exploring the Physical & Cloud Infrastructure Interface

The Physical & Cloud Infrastructure node displays folder-like icons that represent different protection groups. After upgrading, you'll immediately see two system-created folders:

* **Manually Added** — For individually managed computers
* **Unmanaged** — For discovered but not yet protected systems

As you create protection groups, new folders will appear, each containing the servers or workstations you've designated for backup.

![17oaVO.png](https://s2.ax1x.com/2020/02/12/17oaVO.png)

## Creating Protection Groups

True to Veeam form, creating protection groups uses their classic wizard interface. Let's walk through the three different ways you can add computers to your protection groups.

![17odaD.png](https://s2.ax1x.com/2020/02/12/17odaD.png)

### Method 1: Individual Computers

Perfect for small environments or specific servers, this method lets you add computers manually one by one.

![17oNqK.png](https://s2.ax1x.com/2020/02/12/17oNqK.png)

Simply enter the host name or IP address and provide appropriate credentials. It's straightforward and ideal for targeted protection.

### Method 2: Microsoft Active Directory Objects

For larger environments, AD integration is a lifesaver. You can dynamically add entire organizational units, security groups, or individual computers based on AD queries.

![17otr6.png](https://s2.ax1x.com/2020/02/12/17otr6.png)
![17oBPH.png](https://s2.ax1x.com/2020/02/12/17oBPH.png)

Start by clicking the **Change** button to configure your AD connection — enter your domain details and provide domain administrator credentials. Once connected, you can browse your AD structure and select exactly what you want to protect.

![17oDGd.png](https://s2.ax1x.com/2020/02/12/17oDGd.png)

One smart feature: Veeam automatically excludes virtual machines from agent-based protection, since they should typically be protected through hypervisor-level backups.

### Method 3: Computers from CSV Files

Sometimes you need the flexibility of custom lists. The CSV import method lets you maintain your inventory in a simple text file.

![17orRA.png](https://s2.ax1x.com/2020/02/12/17orRA.png)

Just create a CSV file with your host names or IP addresses, then point Veeam to it. This method works great for mixed environments or when you're migrating from another backup solution.

![17osxI.png](https://s2.ax1x.com/2020/02/12/17osxI.png)

You can even specify different credentials for different hosts within the same CSV file, giving you granular control over authentication.

## Advanced Protection Group Settings

Regardless of which method you choose, you'll have access to some powerful automation settings:

![17o6Mt.png](https://s2.ax1x.com/2020/02/12/17o6Mt.png)

* **Automatic discovery intervals** — Set how often Veeam scans for new computers
* **Agent deployment** — Automatically install Veeam agents and CBT drivers on discovered machines
* **Restart policies** — Control automatic reboots when required after agent installation

![17ogqf.png](https://s2.ax1x.com/2020/02/12/17ogqf.png)

The wizard performs final status checks on target systems before creating your protection group, ensuring everything is ready for deployment.

## Managing Windows Agents

Once Veeam discovers machines in your protection groups, you'll see them listed in the Physical & Cloud Infrastructure view.

![17oRZ8.png](https://s2.ax1x.com/2020/02/12/17oRZ8.png)

The toolbar gives you complete control over agent lifecycle:

* **Install/Uninstall agents** — Push agents to new systems or remove them when needed
* **Restart computers** — Reboot machines remotely for maintenance
* **Create recovery media** — Build bootable recovery media directly from the console

What's particularly impressive is that all these operations, which previously required working directly on individual machines, are now centralized in the Veeam console.

### Creating Windows Backup Jobs

Setting up backups is as simple as selecting your computers and clicking **Add to Backup**. The familiar Veeam wizard guides you through the process:

![17oWdS.png](https://s2.ax1x.com/2020/02/12/17oWdS.png)

You'll notice three deployment options, each serving different scenarios:

* **Workstation** — Ideal for desktop/laptop environments
* **Managed by Agent** — Perfect for remote sites with local backup servers
* **Managed by Backup Server** — Our focus for centralized management

The **Managed by backup server** option gives you full control over backup scheduling, retention, and storage allocation.

#### Job Configuration Walkthrough

Let's walk through the key configuration steps:

![17ofIg.png](https://s2.ax1x.com/2020/02/12/17ofIg.png)

**Step 1: Name your job** — Give it a descriptive name that makes sense in your environment.

![17o4iQ.png](https://s2.ax1x.com/2020/02/12/17o4iQ.png)

**Step 2: Select servers** — Choose which computers to include and set their processing order if needed.

![1HPNUH.png](https://s2.ax1x.com/2020/02/12/1HPNUH.png)

**Step 3: Choose backup mode** — Options mirror what you're used to in Veeam's agent client.

![1HPdPA.png](https://s2.ax1x.com/2020/02/12/1HPdPA.png)

**Step 4: Configure storage** — Select your backup repository and set retention policies. Advanced options let you configure synthetic full and active full backup schedules.

![1HPw8I.png](https://s2.ax1x.com/2020/02/12/1HPw8I.png)

**Step 5: Application-aware processing** — Enable consistent backups for applications like SQL Server and Exchange.

![1HPtVe.png](https://s2.ax1x.com/2020/02/12/1HPtVe.png)

**Step 6: Schedule** — Set your backup frequency and timing using Veeam's familiar scheduling interface.

Once configured, your jobs run with the same reliability you expect from Veeam:

![1HPU5d.png](https://s2.ax1x.com/2020/02/12/1HPU5d.png)

During execution, Veeam collects necessary drivers and system information, ensuring reliable recovery when you need it.

### Recovery Operations

All your backup archives appear in the **Home** interface, where you can perform various recovery operations:

![1HP02t.png](https://s2.ax1x.com/2020/02/12/1HP02t.png)

The recovery options match what you're used to in virtualization backups — file-level recovery, volume recovery, and full bare-metal recovery. The consistency across platforms makes training and operations much simpler.

For bare-metal recovery, Veeam now generates recovery media directly from the backup server console:

![1HPBxP.png](https://s2.ax1x.com/2020/02/12/1HPBxP.png)

This centralization eliminates the need to manage recovery media creation on individual machines.

## Managing Linux Agents

Linux agent management follows a similar workflow but with some platform-specific differences:

![1HPrKf.png](https://s2.ax1x.com/2020/02/12/1HPrKf.png)

Linux environments have fewer management options — you won't find recovery media creation, CBT driver installation, or reboot capabilities directly in the console, reflecting the different requirements of Linux systems.

### Linux Backup Configuration

Creating Linux backup jobs uses the same wizard approach, though with some Linux-specific considerations:

![1HPsr8.png](https://s2.ax1x.com/2020/02/12/1HPsr8.png)

Notably, Linux doesn't support cluster-based protection in this release, though that may change in future versions.

The configuration screens will look familiar:

![1HPyqS.png](https://s2.ax1x.com/2020/02/12/1HPyqS.png)

**Name and describe your job** — Good documentation practices help in any environment.

![1HPcVg.png](https://s2.ax1x.com/2020/02/12/1HPcVg.png)

**Select servers** — Choose which Linux systems to protect.

![1HPWPs.png](https://s2.ax1x.com/2020/02/12/1HPWPs.png)

**Choose backup mode** — Select the appropriate backup strategy for your Linux workloads.

![1HPfGn.png](https://s2.ax1x.com/2020/02/12/1HPfGn.png)

**Configure storage** — Set your backup target and retention policies.

![1HPh2q.png](https://s2.ax1x.com/2020/02/12/1HPh2q.png)

**Application-aware processing** — Linux uses pre-freeze and post-thaw scripts for application consistency, with filesystem indexing handled during backup.

![1HPIMV.png](https://s2.ax1x.com/2020/02/12/1HPIMV.png)

**Schedule** — Set your backup timing using the familiar scheduling interface.

### Linux Recovery Options

Linux recovery operations in VBR are more limited compared to Windows:

![1HPorT.png](https://s2.ax1x.com/2020/02/12/1HPorT.png)
![1HPHZF.png](https://s2.ax1x.com/2020/02/12/1HPHZF.png)

From the Veeam console, you can perform:
* **File-level recovery** — Restore individual files and folders
* **Restore to Azure** — Migrate workloads to Azure
* **Export to virtual disk** — Create VMDK/VHD files for virtualization

For bare-metal recovery of Linux systems, you'll need to download the dedicated Linux recovery media from Veeam's website:

**Direct download link:** https://download2.veeam.com/veeam-recovery-media-2.0.0.400_x86_64.iso

## Looking Ahead

The 9.5U3 update marks a significant step forward in Veeam's physical and cloud infrastructure protection capabilities. By centralizing agent management alongside virtualization workloads, Veeam creates a unified protection platform that simplifies administration while maintaining the flexibility and power that administrators expect.

For the complete release notes and to download the update, check out the official Veeam documentation. This New Year's update sets the stage for even more exciting developments in the months to come.

Whether you're managing a handful of servers or thousands of distributed endpoints, centralized agent management in Veeam 9.5U3 provides the tools you need to protect your physical and cloud infrastructure effectively. The familiar interface, combined with powerful automation capabilities, makes this a welcome addition to any Veeam administrator's toolkit.


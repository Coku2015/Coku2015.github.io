# You Only Know if Backup Archives Can Be Restored When You've Actually Done It


There's one fundamental truth in backup and recovery that every IT professional eventually learns: you don't know if your backup archives can actually be restored until you've tried to restore them.

Veeam has a remarkable feature that automatically verifies backup archive availability online, ensuring your backed-up content can be properly restored when disaster strikes.

![1blqUA.png](https://s2.ax1x.com/2020/02/12/1blqUA.png)

The magic happens because SureBackup starts backup archives as normal virtual machines in an isolated environment, then runs comprehensive automated tests. It checks everything from VM heartbeats and network connectivity to application and service status within the VMs. After testing completes, it generates a detailed verification report about the archive's recoverability.

While SureBackup works with both VMware and Hyper-V, I'll focus on VMware environments to explain the technical principles and implementation methods.

### How It Works

SureBackup follows a methodical sequence to complete the verification process:

> 1. Veeam Backup & Replication publishes Application Groups and target VMs to an isolated sandbox environment called "DataLab." These VMs start directly from compressed, deduplicated backup files in the backup repository—no pre-restoration to VMware Datastores required. This relies on Veeam's Instant VM Recovery and vPower NFS Service.
> 2. Veeam performs automated verification tests on Application Groups and target VMs, typically including VM heartbeats, network pings, and custom application script tests.
> 3. After basic verification, you can optionally run file-level CRC checks on backup archives to ensure original files remain unmodified during testing.
> 4. When verification completes, Veeam unpublishes the VMs and generates a test report sent to designated administrators via email.

Throughout verification, Veeam maintains all backup archives in read-only mode. All runtime data gets stored in VM Redo Logs on VMware storage, which Veeam deletes after verification to reclaim temporary space.

### Key Components

Unlike standard backup infrastructure, SureBackup requires several specialized objects:

1. **Application Group**: Some VMs depend on others to start and function properly. Application Groups provide these dependencies—think AD and DNS servers for an Exchange server. When you need to verify an Exchange server, you add VMs providing AD and DNS services to the Application Group to support startup dependencies.

2. **Virtual Lab**: An isolated virtual sandbox where Application Group VMs and target VMs start up for testing.

3. **SureBackup Job**: The automated or manual task that executes backup archive verification on schedule or demand.

### Implementation Guide

SureBackup requires configuring all three components. Let's walk through each one.

#### Application Group

These are your production infrastructure's cornerstone services—everything else depends on them. Application Groups define essential VM sets that other verified VMs can't function without.

Crucially, Application Group VMs start from backup images, not production environment VMs. They must be pre-backed up and include their own verification tests. SureBackup validates Application Group VMs first—if they fail, verification stops entirely because other VMs can't start without their dependencies.

Keep Application Groups minimal. If target VMs don't need application or service dependencies, don't add VMs to the group.

**Configuration Method**

Creating Application Groups is straightforward. In Veeam Backup & Replication, navigate to Backup Infrastructure, select the SureBackup node, and click "Add Application Group."

![1HPjR1.png](https://s2.ax1x.com/2020/02/12/1HPjR1.png)

This launches Veeam's classic wizard interface.

First, set the Application Group name and description following your organization's naming conventions.

![1HPvxx.png](https://s2.ax1x.com/2020/02/12/1HPvxx.png)

Next, select VMs for this group. You can add VMs from backup archives, replica archives, or storage snapshot archives—each supporting different SureBackup functions (SureBackup/SureReplica/On-demand Sandbox for Storage Snapshots). We'll use "From Backup," the most common approach for regular backup verification.

Remember: Application Group VMs must be pre-backed up—you can't select production environment VMs directly.

![1HPqIJ.png](https://s2.ax1x.com/2020/02/12/1HPqIJ.png)

After selecting VMs, configure verification options. Application Group VMs must pass verification before other VMs get tested. Options include built-in server roles like DNS Server, Domain Controller, Global Catalog, Mail Server, SQL Server, and Web Server. When selected, Veeam automatically applies predefined verification scripts for each role.

![1HiPde.png](https://s2.ax1x.com/2020/02/12/1HiPde.png)

Additional verification options include startup settings, test scripts, and account credentials—detailed settings helpful for specialized applications. Consult Veeam's official documentation for specific configurations.

Review your settings on the Summary page to complete the Application Group setup.

![1HipqO.png](https://s2.ax1x.com/2020/02/12/1HipqO.png)

#### Virtual Lab

This isolated environment runs your verified VMs. Here, Veeam starts Application Group VMs first, then launches target VMs for verification.

Virtual Labs consume minimal resources and can deploy on any ESXi host. They request compute resources only when VMs start. Virtual Labs create network environments that completely mirror production networks—VMs maintain identical IP configurations, functioning exactly as they would in production.

Three critical concepts within Virtual Labs: Proxy Appliance, IP Masquerading, and Static IP Mapping.

**Proxy Appliance**

For production network communication, Veeam uses a Linux-based lightweight Proxy Appliance created in each Virtual Lab. Multiple network cards connect Virtual Lab VMs to the production environment.

**IP Masquerading**

Veeam establishes rules allowing production network access to isolated networks through specific IPs without modifying internal IP configurations.

![1HiAJA.png](https://s2.ax1x.com/2020/02/12/1HiAJA.png)

Each production IP gets a corresponding isolated network IP through IP Masquerading. For example, if production uses 172.16.10.10 with IP Masquerading rule 172.16.10.X/24 mapping to 172.18.10.X/24, the VM's masquerade IP becomes 172.18.10.10.

Veeam adds these as static routes to the VBR backup server and Virtual Lab Client desktops. When accessing 172.18.10.10, the Proxy Appliance acts as a NAT server, forwarding requests to the Virtual Lab VM. The VM's actual IP remains unchanged.

**Static IP Mapping**

Since static routes only get added to VBR servers and Virtual Lab Clients, accessing VMs from multiple clients becomes cumbersome.

![1HiERI.png](https://s2.ax1x.com/2020/02/12/1HiERI.png)

Veeam provides Static IP Mapping for broader access. Using an available production IP (like 172.16.10.99), you can map it to 172.18.10.10. All network clients then access the Virtual Lab VM via 172.16.10.99 without individual static route configurations.

**Virtual Lab Configuration**

Virtual Labs offer three configuration modes. I'll cover the most common: Advanced Single-Host Virtual Lab.

Navigate to Backup Infrastructure, select SureBackup, and click "Add Virtual Lab."

![1blyB4.png](https://s2.ax1x.com/2020/02/12/1blyB4.png)

Set the Virtual Lab name and description following your naming conventions.

![1bl6HJ.png](https://s2.ax1x.com/2020/02/12/1bl6HJ.png)

Select the ESXi host—each Virtual Lab runs on only one ESXi host.

![1blsuF.png](https://s2.ax1x.com/2020/02/12/1blsuF.png)

Choose the datastore for temporary data, Virtual Lab runtime files, and temporary VM Redo logs. Capacity requirements depend on data changes during testing—minimal for typical verification scenarios.

![1blDjU.png](https://s2.ax1x.com/2020/02/12/1blDjU.png)

Configure the Proxy Appliance—essential for fully automated verification and data labs. Without it, all verifications require manual console access. Configure the VM name, IP settings, and internet proxy settings if needed.

![1blh36.png](https://s2.ax1x.com/2020/02/12/1blh36.png)

Set up isolated networks. Configure one-to-one mappings between production networks (Application Groups and target VMs) and isolated networks. Four production port groups require four corresponding isolated port groups.

![1blBcT.png](https://s2.ax1x.com/2020/02/12/1blBcT.png)

Configure network settings. Assign IP addresses to Proxy Appliance vNICs connecting to each isolated network and set IP Masquerading rules. Typically, vNICs get production network gateway addresses, preventing conflicts and eliminating VM modifications.

![1blgE9.png](https://s2.ax1x.com/2020/02/12/1blgE9.png)

Configure Static IP Mapping as needed—optional for limited client access scenarios.

![1bl4gK.png](https://s2.ax1x.com/2020/02/12/1bl4gK.png)

Review your Virtual Lab configuration to complete setup.

![1blouD.png](https://s2.ax1x.com/2020/02/12/1blouD.png)

#### SureBackup Job

Finally, define which VMs to verify, where to verify them, and when to run verification—all configured in SureBackup Jobs.

Launch the SureBackup Job creation wizard.

![1Himsf.png](https://s2.ax1x.com/2020/02/12/1Himsf.png)

Set the job name and description.

![1blY7j.png](https://s2.ax1x.com/2020/02/12/1blY7j.png)

Select the Virtual Lab for running this SureBackup Job.

![1blUNn.png](https://s2.ax1x.com/2020/02/12/1blUNn.png)

Choose whether Application Groups are needed and which ones to use.

![1HiVzt.png](https://s2.ax1x.com/2020/02/12/1HiVzt.png)

Select which backup jobs need verification after completion.

![1blJBQ.png](https://s2.ax1x.com/2020/02/12/1blJBQ.png)

Configure detailed settings for individual VMs within backup jobs—similar to Application Group configurations.

![1blahq.png](https://s2.ax1x.com/2020/02/12/1blahq.png)

Set up administrator notifications for verification completion.

![1bl3jS.png](https://s2.ax1x.com/2020/02/12/1bl3jS.png)

Schedule the SureBackup Job. Typically, select "After this Job" to immediately verify backup results after backup completion.

![1blNAs.png](https://s2.ax1x.com/2020/02/12/1blNAs.png)

With proper configuration, SureBackup runs automatically, ensuring your backups remain valid and recoverable.

![1bl03V.png](https://s2.ax1x.com/2020/02/12/1bl03V.png)

You'll receive verification reports like this via email.

![1blw90.png](https://s2.ax1x.com/2020/02/12/1blw90.png)

**A Note on Licensing**

SureBackup is included in Veeam Backup & Replication Enterprise and Enterprise Plus editions. Standard edition users must rely on completely manual backup archive verification methods.

The wisdom in the Chinese title rings true: backup archive recoverability is something you only truly understand after you've actually done it. SureBackup transforms this practical wisdom into automated assurance.

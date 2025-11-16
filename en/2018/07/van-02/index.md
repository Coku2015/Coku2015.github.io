# Veeam Availability for Nutanix AHV Configuration and Usage Series (Part 2)


Now that we've covered the installation and configuration of Veeam Availability for Nutanix AHV (VAN) in our previous article, it's time to dive into the core operations that make this solution so valuable. Today, we'll explore how VAN handles backup and recovery operations for your AHV virtual machines.

What I find particularly interesting about VAN's approach is how it bridges the familiar Veeam workflow with the unique requirements of Nutanix environments. While the concepts remain consistent with traditional Veeam Backup & Replication (VBR), the implementation details reflect thoughtful adaptation to the AHV ecosystem.

## Managing AHV Virtual Machine Backups

Let's start with the backup workflow. If you're familiar with Veeam, you'll notice that VAN maintains the job-based approach we've come to expect. However, there's an important architectural difference: unlike VMware or Hyper-V environments where backup jobs run through VBR, all Nutanix AHV VM backup operations are managed directly through the VAN Console.

The VAN Console interface is refreshingly straightforward. You'll find four main sections across the top navigation: Dashboard, Backup Jobs, Protected Virtual Machines, and Events. This clean design makes it easy to navigate and find what you need quickly.

![1qgEOU.png](https://s2.ax1x.com/2020/02/13/1qgEOU.png)

The Backup Jobs section serves as your command center for both configuring new backup jobs and monitoring existing ones. This centralized view gives you immediate visibility into your backup infrastructure's health and status.

![1jOwid.png](https://s2.ax1x.com/2020/02/14/1jOwid.png)

## Creating Your First Backup Job

Setting up a backup job in VAN follows Veeam's signature wizard-based approach. I appreciate how the interface maintains this familiar pattern while adapting to the web-based format. The entire configuration process flows through just five logical steps, making it accessible even for those new to Veeam.

**Step 1: Basic Job Information**

The first step is straightforward – you'll define your job name and description. This follows the same pattern as VBR, so there's no learning curve here. Use descriptive names that will help you identify the job's purpose at a glance.

![1qcxeg.png](https://s2.ax1x.com/2020/02/13/1qcxeg.png)

**Step 2: Selecting VMs to Protect**

Here's where VAN shows its Nutanix-aware design. Similar to vSphere or Hyper-V, you can select individual VMs or broader containers like hosts and clusters. What's particularly helpful is how the interface identifies VMs that are currently in an "Unprotected" state, preventing duplicate configurations and helping you quickly spot coverage gaps.

![1qczwQ.png](https://s2.ax1x.com/2020/02/13/1qczwQ.png)

The VM selection interface provides clear visual indicators for protection status, making it easy to ensure comprehensive coverage without redundant jobs.

![1qgSoj.png](https://s2.ax1x.com/2020/02/13/1qgSoj.png)

**Step 3: Choosing Backup Storage**

Your backup destination options include any repositories that have been granted permission in VBR. This integration means you can leverage existing storage infrastructure, whether it's standard repositories or scale-out backup repositories (SOBRs). The flexibility here allows you to align with your organization's storage strategy.

![1qg9Fs.png](https://s2.ax1x.com/2020/02/13/1qg9Fs.png)

**Step 4: Scheduling Configuration**

The scheduling interface showcases the modern web-based design approach. While the underlying scheduling logic remains consistent with traditional VBR, the visual presentation is notably more intuitive. The same powerful scheduling capabilities are there – they're just presented in a more user-friendly package.

![1qgCYn.png](https://s2.ax1x.com/2020/02/13/1qgCYn.png)

**Step 5: Review and Launch**

The final step provides a comprehensive review of your configuration. Once you confirm the settings, your backup job is ready to execute according to the defined schedule. This last step ensures nothing gets missed before the job goes live.

![1qgklV.png](https://s2.ax1x.com/2020/02/13/1qgklV.png)

## Monitoring Backup Operations

After your jobs start running, you'll have visibility into their status from both the VAN Console and traditional VBR. However, there's an important distinction: VBR provides read-only access to these jobs – all management and configuration happens through the VAN Console. This design ensures clear separation of responsibilities while maintaining visibility across your infrastructure.

![1qgZmF.png](https://s2.ax1x.com/2020/02/13/1qgZmF.png)

## Recovery Operations: Restoring Your Virtual Machines

When it comes to recovery, VAN offers multiple pathways depending on your needs. You can perform restoration through either the VAN Console or VBR Console, though the available operations differ between these interfaces.

### VAN Console Recovery Options

The VAN Console provides the most comprehensive recovery capabilities for AHV environments, offering both full VM restoration and granular disk recovery options.

![1qgAyT.png](https://s2.ax1x.com/2020/02/13/1qgAyT.png)

#### Complete VM Recovery

For full virtual machine restoration, the process is intuitive and flexible:

1. **Initiate Recovery**: Click the Restore button to launch the recovery wizard.

![1jOLo4.png](https://s2.ax1x.com/2020/02/14/1jOLo4.png)

2. **Select Virtual Machines**: Add the VMs you need to restore from your available backups.

![1jOvWR.png](https://s2.ax1x.com/2020/02/14/1jOvWR.png)

3. **Choose Restore Point**: Select the appropriate recovery point based on your RPO requirements.

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEoSdoztgwh9ZvGoSMY7yIPHHnyWSSLnjlUAH8g1JCNpWCxll5H2R91pw/640?wx_fmt=png)

4. **Define Recovery Location**: You have two primary options:
   - **Original Location**: Direct overwrite of the existing VM
   - **New Location**: Create a new VM with custom configurations

When choosing a new location, you can specify different VM names and configuration parameters, which is particularly useful for testing or parallel recovery scenarios.

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEo6QS4nRBRDyolzfbsVntg1JCDgI3hSBQiafFPaLDUGeSuPYg6l88lahA/640?wx_fmt=png)

5. **Configure Target Settings**: Select appropriate VM containers and nodes. The defaults typically use the original location, but you can redistribute workloads based on current infrastructure capacity.

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEopnDxJvLtCq5tLUSJoVU9FZibxhzTVeqKxEaelndRwy34mJuiaic9G15zA/640?wx_fmt=png)

6. **Execute Recovery**: After providing a recovery reason for documentation purposes, initiate the restoration process.

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEol4RQE5teawxEYRXNObpqlicS6k6YMIkNmH2SkU8aOLWlUJA5QibYcd4Q/640?wx_fmt=png)

#### Selective Disk Recovery

Sometimes you don't need the entire VM – just specific disks. VAN's disk recovery feature provides this granular capability:

1. **Launch Disk Recovery**: Access the disk restoration wizard from the main recovery interface.

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEo04EYjZ7q8hen8X2Wak6QQCCERia7yDC357YPbjObFUCKBR6LOI2vmQQ/640?wx_fmt=png)

2. **Select Recovery Point**: Choose the appropriate backup timestamp for your disk recovery.

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEo7QZFicHfF64huyrOQaek0ZB8kiaLG1eicEIecuCZyFiccCViaBNzXBfKfDQ/640?wx_fmt=png)

3. **Configure Disk Mapping**: Define how the recovered disks will be mapped to target VMs or new configurations.

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEo08G1r7ouEMxwicjY85osKibzxuCUpLe8KcFxJjLJVfOkYFibICP45HYCA/640?wx_fmt=png)

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1FFJRAsVxib1Wc56RcicouEoibyysicT8RhlmXlTdic9fwibHKJsVsrribHZJJvgInq2AU8s1yzIXH4f3BQ/640?wx_fmt=png)

4. **Complete Recovery**: After documenting the recovery reason, execute the disk restoration process.

### VBR Console Recovery Integration

While the VAN Console provides AHV-specific recovery options, the VBR Console offers additional flexibility through standard Veeam Agent recovery methods. This integration includes:

- Instant Recovery to Hyper-V
- Export to Virtual Disk formats (VMDK/VHD/VHDX)
- Guest File Recovery
- Application Item Recovery
- Direct Restore to Microsoft Azure

![1qgew4.png](https://s2.ax1x.com/2020/02/13/1qgew4.png)

These options follow the same workflows as traditional Veeam Agent recoveries. For Linux VM file-level recovery, you'll still need to deploy a Help Appliance on either Hyper-V or vSphere infrastructure – a consistent requirement across Veeam's product family.

## What This Means for Your Environment

The beauty of VAN's dual-console approach is the flexibility it provides. The VAN Console gives you streamlined, AHV-optimized operations, while the VBR Console integration ensures you're not limited to a single recovery pathway. This hybrid approach allows you to choose the right tool for each recovery scenario based on urgency, infrastructure availability, and specific requirements.

In our next installment, we'll explore some advanced VAN features and performance optimization techniques that can help you get the most out of your Nutanix-Veeam integration.


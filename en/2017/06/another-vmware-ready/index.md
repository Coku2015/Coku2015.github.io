# Good news, Veeam passes another VMware Ready certification!


Great news from the Veeam team! Last week, we achieved another significant milestone by passing the newly available VMware Web Client Plug-in Ready certification for vSphere 6.5. This is genuinely exciting news for anyone managing VMware infrastructure with Veeam.

You can verify our certification status on VMware's official compatibility list: https://www.vmware.com/resources/compatibility/search.php?deviceCategory=wcp

![1T0COx.png](https://s2.ax1x.com/2020/02/11/1T0COx.png)

## Why VMware Ready Certification Matters

If you're not familiar with VMware Ready certification, here's why it's such a big deal. This certification ensures that plug-ins meet VMware's highest standards, providing several key advantages:

**1. Industry Best Practices Integration**
Certified plug-ins align with VMware's established best practices and are often featured in official documentation and whitepapers, giving you confidence in the implementation approach.

**2. Seamless User Experience**
The interface feels completely native, delivering an experience virtually identical to VMware's built-in tools. Your team won't need to learn new workflows or adapt to different interaction patterns.

**3. Performance and Stability Assurance**
VMware conducts rigorous testing on certified plug-ins, guaranteeing they won't impact vCenter performance or compromise system stability. You can deploy with confidence knowing your core infrastructure remains protected.

**4. Comprehensive Support Coverage**
If issues arise, VMware provides direct warranty support for certified plug-ins. This means you have a single point of contact for troubleshooting, eliminating finger-pointing between vendors.

## Exploring the Plugin's Powerful Features

Now let's dive into what makes this plugin so useful. Once deployed, you'll notice a new Veeam icon in your vSphere Web Client, appearing alongside other registered plugins. Simply click to access the integrated backup management interface.

![1T0961.png](https://s2.ax1x.com/2020/02/11/1T0961.png)

### Comprehensive Infrastructure Overview

The plugin provides an at-a-glance view of your entire backup infrastructure status, helping you quickly identify any issues or areas needing attention.

![1T0Sp9.png](https://s2.ax1x.com/2020/02/11/1T0Sp9.png)

### Backup Performance Monitoring

You can easily track VM backup success rates across different time periods - the last 24 hours, 7 days, and 14 days - giving you insights into backup trends and potential problems.

![1T0plR.png](https://s2.ax1x.com/2020/02/11/1T0plR.png)

### Job Management Dashboard

The plugin displays backup job execution status and upcoming schedules, allowing you to monitor backup operations without leaving the vSphere interface.

![1TwjkF.png](https://s2.ax1x.com/2020/02/11/1TwjkF.png)

### Processing Metrics

Track the volume of virtual machines processed over the past 7 days, 14 days, and month, helping you understand your backup workload patterns and capacity planning needs.

![1T0im6.png](https://s2.ax1x.com/2020/02/11/1T0im6.png)

### Storage Capacity Monitoring

Keep an eye on backup repository capacity to avoid running out of storage space during critical backup windows. The visual indicators make it easy to spot when repositories are approaching capacity limits.

![1T0F0K.png](https://s2.ax1x.com/2020/02/11/1T0F0K.png)

### Seamless Veeam ONE Integration

If you're also running Veeam ONE, each dashboard section includes direct links to detailed reports, allowing you to drill down into specific areas without switching between interfaces. This integration significantly streamlines your infrastructure management workflow.

## Quick Backup Capabilities

Beyond monitoring, the plugin also enhances your backup operations through quick backup options. Simply right-click on any VM to access the Backup menu:

![1T0kTO.png](https://s2.ax1x.com/2020/02/11/1T0kTO.png)

The plugin offers several quick backup options:

**VeeamZIP**: Performs an immediate full backup (Active Full type), perfect for creating quick, standalone backup files when you need them most.

**VeeamZIP to...**: Opens the VeeamZIP configuration interface directly within vSphere Web Client, eliminating the need to switch to the Veeam console for setup.

**Quick Backup**: Executes a fast incremental or reverse incremental backup for on-demand protection of critical VMs.

### VeeamZIP Configuration Interface

The VeeamZIP settings are conveniently accessible through the Manage tab on each VM's configuration page:

![1T0EkD.png](https://s2.ax1x.com/2020/02/11/1T0EkD.png)

Within this interface, you can configure essential backup parameters including:
- Backup server selection
- Target backup repository
- Encryption keys
- Retention settings for VeeamZIP files
- Compression levels
- Application-aware processing options

These settings mirror the full Veeam console experience, ensuring consistency across your backup operations. The interface also includes immediate task trigger buttons, allowing you to start backups without navigating to separate consoles.

### Progress Tracking

When you execute VeeamZIP or Quick Backup operations, the progress appears directly in vSphere Web Client's task panel, keeping you informed without disrupting your workflow:

![1T0ZfH.png](https://s2.ax1x.com/2020/02/11/1T0ZfH.png)

## The Bottom Line

The Veeam vSphere Web Client Plugin delivers a lightweight yet powerful integration that brings essential backup management capabilities directly into your VMware environment. It combines the simplicity you need with the enterprise-grade features you expect, all backed by VMware's certification support.

For administrators managing VMware infrastructure, this plugin represents a significant step forward in operational efficiency, allowing you to monitor and manage backup operations without context switching between different management interfaces. The result is a more streamlined, intuitive backup experience that saves time while maintaining the robust protection your virtual machines require.


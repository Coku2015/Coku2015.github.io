# VRO Basics (Part 1) – Overview


There's something exciting happening in the Veeam ecosystem. With the launch of Veeam Data Platform v12, we're seeing a significant evolution in disaster recovery orchestration. The platform's Platinum edition now includes **Veeam Recovery Orchestrator (VRO)** v6—the successor to Veeam Availability Orchestrator (VAO).

What makes this particularly noteworthy is the massive leap forward from the previous VAO v2. VRO v6 works seamlessly alongside VBR v12 and Veeam ONE v12, delivering comprehensive enhancements that transform how we approach disaster recovery. The improvements are so substantial that I've completely refreshed my foundational "VRO Basics" series to share everything that's new and powerful in this release.

## What Is VRO?

Think of VRO as Veeam's premier orchestration layer that dramatically enhances Veeam Backup & Replication's recovery capabilities. As the highest-tier component in the Veeam Data Platform, VRO v6 supports an impressive range of backup and disaster recovery data sources:

- **vSphere virtual machines** protected by VBR backups
- **Windows and Linux systems** protected by Veeam Agent backups
- **vSphere Replica archives** created through VBR replication
- **Veeam CDP replica archives** from continuous data protection
- **Storage volume replicas** from NetApp and HPE storage arrays (vSphere environments only)

In v6, these data sources power incredibly rich recovery scenarios and capabilities:

- **Policy-driven RPO/RTO enforcement** through software-defined automation that ensures your disaster recovery infrastructure meets required service level objectives
- **Fully automated failover processes** supporting backup archives, replica archives, and CDP archives with orchestrated workflows
- **Comprehensive disaster recovery validation** through DataLabs, where every DR scenario can be rehearsed in complete 1:1 isolation

And here's where VRO really expands the horizon: recovery destinations now extend beyond traditional vSphere environments to include **Microsoft Azure cloud**, enabling Direct-to-Azure recovery capabilities.

VRO essentially enhances and replaces VBR's built-in Recovery, Failover, and SureBackup operations. It takes these three critical functions and adds powerful customization layers—you can inject custom steps and scripts that align perfectly with your actual business scenarios. For administrators, thoughtfully designing these additional steps can dramatically reduce the complexity of disaster recovery workflows in IT operations.

## Where Can You Use VRO?

VRO adapts to your infrastructure complexity, from simple setups to sophisticated multi-site environments. Let me walk through two fundamental architecture scenarios to illustrate how VRO fits into different designs.

### Single Data Center

![Single site](https://s2.ax1x.com/2020/02/16/390jqx.png)

In a single data center deployment, adding VRO components introduces minimal changes to your existing backup architecture. All your VBR operations continue exactly as before—day-to-day backup and restore functions remain unchanged. What VRO brings is focused orchestration for your most critical workloads, ensuring their RPO and RTO requirements are consistently met.

When critical systems experience downtime, they typically recover in-place, so there's no need for dedicated recovery resources. The beauty of this approach is its simplicity—you're essentially elevating protection for the VMs that matter most without overhauling your entire infrastructure.

### Primary and DR Data Centers

![Primary/DR](https://s2.ax1x.com/2020/02/16/390OMR.png)

This is a more complex but very common scenario: geographically distributed primary and backup data centers. Your primary site handles production workloads, while your secondary site serves as your disaster recovery target. Typically, you'd already be copying backup archives to the DR site and potentially replicating critical VMs 1:1 to the recovery location.

This is where VRO truly shines. The data recovery workflows at your DR site can all be orchestrated through VRO's Replica Plans or Restore Plans, and these plans undergo complete recovery validation in corresponding DataLabs. The architecture remains fundamentally similar to the single data center approach, but now you can strategically allocate resources specifically for disaster recovery preparation and execution.

## The Five VRO Plan Types

It's important to understand that VRO doesn't provide backup or replication functionality itself—all source data processing happens in VBR. Instead, VRO v6 offers five distinct orchestration plans that bring everything together:

- **Replica Plan** – Recovery plans based on replicas created through VBR replication functionality
- **CDP Replica Plan** – Recovery plans leveraging replicas created through VBR's continuous data protection
- **Restore Plan** – Recovery plans for restoring VBR vSphere backups and Veeam Agent backups to vSphere environments
- **Storage Plan** – Recovery plans for restoring VMware Datastores from NetApp and HPE storage volume replications
- **Cloud Plan** – Recovery plans for restoring VBR vSphere backups and Veeam Agent backups directly to Microsoft Azure

Each plan type supports essential operations:
- Resource availability testing before execution
- Comprehensive automated reporting
- One-click fully automated recovery and failover

What's particularly exciting is how VRO enhances DataLabs functionality—this has always been one of Veeam's standout features. In VRO, DataLabs not only support testing for Replica Plans and Restore Plans, but also leverage VRO's powerful scripting and step addition capabilities to automatically generate complex testing environments. Through this enhancement, complex test cases and environment deployment workflows transform into simple one-button operations, dramatically improving DataLabs efficiency and utilization.

## What Can VRO Do For You?

To put it simply, I've summarized the key capabilities:

- **Fully automated recovery** to both Azure cloud and VMware virtualization environments
- **"Zero contamination" restores** through intelligent scanning engines that detect malware before restoration, ensuring recovered data remains uncompromised
- **Comprehensive automated disaster recovery and recovery testing** with minimal manual intervention
- **Instantly usable DataLabs** creation for isolated testing environments
- **Complete application availability validation** to ensure business continuity
- **One-click disaster recovery** execution for rapid response capabilities
- **Fully automated dynamic disaster recovery documentation** that updates in real-time

This marks the beginning of our updated VRO v6 journey. Stay tuned for this comprehensive series where I'll be sharing:

- [VRO Basics (Part 1) – Overview](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-01/) (this post)
- [VRO Basics (Part 2) – Installation & Deployment](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-02/)
- [VRO Basics (Part 3) – Core Components · Part 1](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-03/)
- [VRO Basics (Part 4) – Core Components · Part 2](https://blog.backupnext.cloud/2023/05/VRO-v6-Guide-04/)
- [VRO Basics (Part 5) – First Steps Toward a Successful DR Plan](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-05/)
- [VRO Basics (Part 6) – DataLabs](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-06/)
- [VRO Basics (Part 7) – Plan Steps · Part 1](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-07/)
- [VRO Basics (Part 8) – Plan Steps · Part 2](https://blog.backupnext.cloud/2023/06/VRO-v6-Guide-08/)
- [VRO Basics (Part 9) – Document Template Deep Dive](https://blog.backupnext.cloud/2023/10/VRO-v6-Guide-09/)
- [VRO Basics (Part 10) – Using VRO with K10 for Automated Container Disaster Recovery](https://blog.backupnext.cloud/2023/11/VRO-v6-Guide-10/)


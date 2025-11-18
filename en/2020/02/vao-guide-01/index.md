# VRO v6 基础入门（一） -  简介


There's exciting momentum building in the Veeam ecosystem. With Veeam Availability Suite v10 just around the corner, we're also anticipating the release of Veeam Availability Orchestrator v3.0. Right now, VAO is still at version 2.0, but I've been spending considerable time diving deep into this powerful yet often misunderstood product.

Many Veeam users I talk to find VAO intriguing but mysterious. It looks sophisticated and powerful, yet they're unsure how to leverage it in their environment. That's exactly why I'm starting this introductory series—to share what I've learned and help demystify VAO for the community.

## What is VAO?

Think of VAO as Veeam Availability Suite (VAS) on steroids. It's not a standalone product—VAO extends and enhances your existing VAS deployment, working seamlessly with Veeam Backup & Replication (VBR). There's one important caveat though: VAO is VMware-specific, so you'll need a vSphere environment to leverage its capabilities.

So what does VAO actually bring to the table? Three core capabilities that transform how you handle disaster recovery:

* **Guaranteed SLAs**: Software-driven automation ensures your disaster recovery infrastructure consistently meets your RPO and RTO requirements
* **Automated failover**: Streamlines the entire disaster recovery switching process, working with both backup archives and replicated VMs
* **Verified recovery**: Leverages DataLabs to validate your disaster recovery plans with 1:1 simulated testing—no more guessing if your recovery will work when it matters most

VAO essentially supercharges three critical VBR operations: Recovery, Failover, and SureBackup. It takes these essential functions and adds a layer of orchestration and customization. You can inject custom steps and scripts into these operations, tailoring them to your specific business requirements. For administrators, this means dramatically simplified disaster recovery workflows that align perfectly with real-world scenarios.

## Where can you use VAO?

VAO adapts to your infrastructure, whether you're running a simple setup or a complex multi-site environment. Let me walk through two common scenarios to illustrate how VAO fits into different architectures.

### Single Data Center

![390jqx.png](https://s2.ax1x.com/2020/02/16/390jqx.png)

In a single data center deployment, VAO integrates seamlessly with your existing VAS infrastructure. Your day-to-day backup and restore operations continue running on VBR exactly as before—nothing changes there. What VAO adds is a layer of intelligent orchestration for your most critical workloads.

Here's how it works in practice: you identify your mission-critical VMs and hand over their RPO/RTO management to VAO. When disaster strikes, these systems recover in-place, so you don't need dedicated recovery resources standing by. The beauty of this approach is its simplicity—you're essentially just elevating your protection strategy for the VMs that matter most, without overhauling your entire infrastructure.

### Primary and Backup Data Centers

![390OMR.png](https://s2.ax1x.com/2020/02/16/390OMR.png)

Now let's look at a more complex but very common scenario: geographically distributed primary and backup data centers. Your primary site handles production workloads, while your secondary site serves as your disaster recovery target.

This is where VAO really shines. In a typical VAS setup, you're already copying backup files to your DR site and replicating critical VMs. VAO takes this foundation and orchestrates the entire recovery process at your backup site. You can build comprehensive Recovery Plans and Failover Plans that leverage those replicated VMs and backup copies, then validate everything in isolated DataLabs.

The architecture remains fundamentally similar to the single data center approach, but now you have the flexibility to dedicate resources specifically for disaster recovery testing and execution.

## The Two Types of VAO Plans

It's important to understand that VAO doesn't replace your backup and replication functionality—it orchestrates it. All the heavy lifting of data protection still happens in VBR. What VAO adds are two types of orchestration plans that bring everything together.

### Restore Plans

Think of Restore Plans as VAO's way of orchestrating traditional backup and recovery operations. When you need to recover from backup files (.vbk, .vib, .vrb files, etc.), a Restore Plan handles the entire workflow, ensuring everything happens in the right order with proper validation.

### Failover Plans

Failover Plans are all about replicated environments. When you have VMs replicated to your disaster recovery site, Failover Plans orchestrate the entire switchover process—from powering down production VMs to bringing their replicas online and handling all the networking complexities in between.

Both plan types come with powerful built-in capabilities:

* **DataLabs validation**: Test your plans in isolated environments without impacting production
* **Resource availability checks**: Verify that your infrastructure is ready before executing critical operations
* **Automated reporting**: Get detailed documentation of every recovery operation
* **One-click automation**: Execute complex recovery procedures with a single command

## Enhanced DataLabs Capabilities

DataLabs have always been one of Veeam's standout features, and VAO takes them to the next level. While you can still use DataLabs to test your recovery and failover plans, VAO adds powerful scripting and workflow automation that transforms how you approach disaster recovery testing.

Here's what makes this special: you can build sophisticated test environments with custom scripts and predefined steps, then execute complex testing scenarios with the click of a button. What used to require hours of manual setup and configuration now happens automatically. This dramatically increases your testing frequency and coverage, ensuring your disaster recovery plans are always ready when you need them.

## Coming Up in This Series

This is just the beginning of our VAO journey. Over the next few posts, I'll dive deeper into practical implementation and advanced topics. Here's what's coming up:

- [VAO Basics (2) - Installation & Deployment](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO Basics (3) - Core Components · Part 1](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO Basics (4) - Core Components · Part 2](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO Basics (5) - Essential Configuration Tips](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO Basics (6) - Building Your First Successful Disaster Recovery Plan](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO Basics (7) - Plan Steps Deep Dive · Part 1](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO Basics (8) - Plan Steps Deep Dive · Part 2](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO Basics (9) - Document Templates Explained](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)


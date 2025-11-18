# VAO Basics (Part 7) – Plan Steps · Part 1


## Series Index

- [VAO Basics (1) – Introduction](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO Basics (2) – Installation & Deployment](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO Basics (3) – Core Components · Part 1](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO Basics (4) – Core Components · Part 2](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO Basics (5) – Essential Configuration Notes](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO Basics (6) – The First Step to a Successful DR Plan](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO Basics (7) – Plan Steps · Part 1](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO Basics (8) – Plan Steps · Part 2](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO Basics (9) – Document Template Deep Dive](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)

In Part 6 we walked through building Orchestration Plans. When designing DR, it’s best to start with a single application and scale gradually. By default, each plan includes the minimum steps required to restore or fail over a workload. VAO’s real power lies in the ability to add steps—pick what you need from the built-in library or layer on custom actions.

## Out-of-the-box Plan Steps

VAO ships with 22 predefined steps that fall into the following groups:

> **Recovery operations** – 2  
> **Datalab validation**  
> &nbsp;&nbsp;&nbsp;• Preparation – 1  
> &nbsp;&nbsp;&nbsp;• Basic VM checks – 2  
> &nbsp;&nbsp;&nbsp;• Application checks – 12  
> **Notifications** – 2  
> **VM power control** – 2  
> **Guest services** – 1

Everything is already baked into the product—just follow the prompts and supply any required inputs. I won’t document every parameter here; experiment and test the ones that match your use cases.

## Common Parameters

Every step exposes a *Common Parameter* block that controls how the step behaves:

```
- Failback & Undo Failover Action – run (or skip) the step during failback/undo.
- Test Action – decide whether the step runs during Datalab tests.
- Critical step – if enabled, the plan stops immediately when this step fails.
- Timeout – maximum execution time for the step.
- Retries – number of retry attempts on failure.
```

These settings can be adjusted per step in each plan.

## Taking It Further with Custom Scripts

Beyond the built-ins, VAO lets you run custom PowerShell scripts either on the VBR server or inside the recovered workloads. That opens the door to some creative workflows.

Consider a typical three-tier architecture:

![3a3EyF.png](https://s2.ax1x.com/2020/02/26/3a3EyF.png)

- Oracle runs on an AIX server.  
- Middleware and application tiers run on VMware vSphere.  
- Oracle GoldenGate keeps the database synchronized to the DR site.

VBR protects the virtualized tiers and delivers great DR rehearsals—the restored VMs boot inside an isolated network for full hands-on testing. But without a database, the application isn’t truly usable.

### Enter VAO

With VAO we can orchestrate the entire environment:

1. Kick off the application Failover/Restore Plan. Before recovering the VMs, add a PowerShell step that talks to the DR-site AIX systems.
2. That script instructs AIX to deploy a new LPAR.
3. Another script attaches a virtual NIC to the LPAR and connects it to the same isolated sandbox network used by VAO. The sandbox can’t route to production, so everything stays contained.
4. A third script spins up the latest Oracle copy on that LPAR.
5. Once the database is ready, power on the replicated middleware/app VMs inside the sandbox so they can reach the DR Oracle instance.
6. Leave the environment running for testing, development, or training.
7. When testing wraps up, the DR admin advances the plan to the next step.
8. VAO performs Undo Failover on the vSphere VMs, returning them to the pre-test state.
9. A final script notifies AIX to remove the temporary LPAR and database so nothing leaks back into production.

This approach isn’t limited to AIX—it works with HP-UX, Oracle Exadata, public-cloud resources, and anything else reachable via PowerShell or REST. With custom scripts plus scheduling, VAO becomes a Swiss Army knife for orchestrated DR.

In the next installment we’ll dive into building and managing those custom scripts. Stay tuned!


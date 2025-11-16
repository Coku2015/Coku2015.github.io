# VAO Basics (Part 6) – The First Step to a Successful DR Plan


## Series Index

- [VAO Basics (1) – Introduction](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO Basics (2) – Installation & Deployment](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO Basics (3) – Core Components · Part 1](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO Basics (4) – Core Components · Part 2](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO Basics (5) – Essential Configuration Notes](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO Basics (6) – The First Step to a Successful DR Plan](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO Basics (7) – Plan Step · Part 1](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO Basics (8) – Plan Step · Part 2](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO Basics (9) – Document Template Deep Dive](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)

With the earlier configuration work completed, VAO is ready for day-to-day use. Plan Authors can sign in, see only the scopes they’re allowed to touch, and work with the objects inside those scopes—Orchestration Plans, DataLabs, and Reports.

Meeting an enterprise’s RPO/RTO targets takes more than raw compute and software; administrators must also understand how the tool behaves. VAO is powerful, but the DR team needs to know every step and its expected outcome. The first step toward a successful DR plan is to understand how VAO executes one. For the walkthrough below I’m using the Plan Author account `user1@sedemolab.local`, which can access “Scope A” and “Scope B”.

## Orchestration Plan

VAO supports two plan types: **Restore Plans** (backup-based) and **Failover Plans** (replica-based). Both are the backbone of your disaster recovery processes; every automated action runs through them. My recommendation is to start small—stick with the built-in Plan Steps, keep the workflow short, and only introduce custom scripts after you’re comfortable with the mechanics.

1. Open **Orchestration Plans** on the left. In the toolbar, expand **Manage → New** to launch the plan wizard.  
   ![33lwpn.png](https://s2.ax1x.com/2020/02/23/33lwpn.png)
2. Choose the scope this plan belongs to. Each scope already bundles VM Groups, Recovery Locations, Plan Steps, etc., so the plan must live within a specific scope. Select Scope A and click **Next**.  
   ![331sgI.png](https://s2.ax1x.com/2020/02/23/331sgI.png)
3. Fill out **Plan Info**. These details flow into the generated reports.  
   ![3335dO.png](https://s2.ax1x.com/2020/02/23/3335dO.png)
4. Pick the **Plan Type** (Restore or Failover). Restore Plans include a Recovery Location step; choose one of the locations defined earlier in Plan Components.  
   ![33jxzt.png](https://s2.ax1x.com/2020/02/24/33jxzt.png)
5. Select the **VM Groups** to recover. Available groups come from the scope; move the required groups into **Plan Groups**. Use **View VMs** to inspect the members.  
   ![3Jh1at.png](https://s2.ax1x.com/2020/02/25/3Jh1at.png)
6. Configure **VM Recovery Options**:  
   - *If any VM recovery fails then*: decide whether the plan continues with the remaining VMs or stops immediately.  
   - *Recover the VMs in each group*: run simultaneously or in sequence.  
   - *Recover simultaneously max of VMs*: limit parallel recoveries (default 10). Test and tune this to match your resources.  
   - *Restore VM Tags*: typically leave unchecked when restoring to a new location to avoid tag conflicts.  
   ![3J57Ke.png](https://s2.ax1x.com/2020/02/25/3J57Ke.png)
7. On **VM Steps**, choose the steps to run for each VM. VAO selects “Restore VM” and “Check VM Heartbeat” by default. While learning the product, experiment by adding steps one at a time so you understand what each does before baking it into production plans.  
   ![3Y9bUP.png](https://s2.ax1x.com/2020/02/25/3Y9bUP.png)
8. **Protect VM Groups** lets VAO back up the restored VMs immediately. Tick the option and select a Template Job (defined earlier under Plan Components).  
   ![3YuNLV.png](https://s2.ax1x.com/2020/02/25/3YuNLV.png)
9. Define the plan’s **RTO** and **RPO** targets. VAO actively tracks these and raises warnings if they’re missed. Values can be configured down to the minute.  
   ![3YMMCQ.png](https://s2.ax1x.com/2020/02/25/3YMMCQ.png)
10. Choose the **Report Template** (PDF or Word). I’ll cover custom templates in Part 9.  
    ![3YMqIS.png](https://s2.ax1x.com/2020/02/25/3YMqIS.png)
11. Schedule automatic report generation. VAO currently supports daily schedules—pick the time of day that fits your workflow.  
    ![3YQYQA.png](https://s2.ax1x.com/2020/02/25/3YQYQA.png)
12. Optionally enable the immediate **Readiness Check** so VAO validates resource availability right after the plan is created.  
    ![3YQ7l9.png](https://s2.ax1x.com/2020/02/25/3YQ7l9.png)
13. Review the **Summary** and click **Finish**. The new plan appears in the list.  
    ![3YldXR.png](https://s2.ax1x.com/2020/02/25/3YldXR.png)

Once created, you can:

- **Launch**: Run now or schedule.  
- **Manage**: Enable/Disable, create a new plan, edit, reset, delete.  
- **Verify**: Run a Datalab test or a Readiness check.  
- **Report**: Generate or download documentation.

Fresh plans start disabled (grey icon). Use **Manage → Enable** to activate. After executing a plan, click **Manage → Reset** before reusing it.

## Datalab Testing

Under **Verify** you’ll find **Run Datalab test**. This wizard spins up a near-production rehearsal of the plan, including every custom script. Networking stays isolated inside the chosen DataLab, so you can measure the recovery process and timing safely.

### Restore Plan Test

1. Pick the DataLab to run in (all scope-assigned labs appear here).  
   ![3YJNLj.png](https://s2.ax1x.com/2020/02/25/3YJNLj.png)
2. Choose a **Quick Test** (Instant VM Recovery only) or a **Full Test** (includes migrations).  
   ![3YYyNt.png](https://s2.ax1x.com/2020/02/25/3YYyNt.png)
3. Select the **Recovery Location** for the test, even if the plan already specifies one. This selection is specific to the Datalab run.  
   ![3Yvdk8.png](https://s2.ax1x.com/2020/02/25/3Yvdk8.png)
4. Decide what happens after the automated checks finish—power off immediately or keep the lab running for additional testing, specifying the number of hours to keep it alive.  
   ![3YxiHP.png](https://s2.ax1x.com/2020/02/25/3YxiHP.png)
5. Select any required **Lab Groups** (similar to Application Groups in VBR). This step is optional.  
   ![3YzMxH.png](https://s2.ax1x.com/2020/02/25/3YzMxH.png)
6. Review the **Summary** and click **Finish** to start the test.

### Failover Plan Test

Failover Plans follow the same wizard but skip the test-type and Recovery Location steps—you jump straight to power options and Lab Group selection.

### Scheduling Datalab Tests

You can automate these exercises via the **Datalab Calendar** on the dashboard. Click **Create Schedule** to define a recurring plan: set the time window and choose which plans to test in the selected lab. Existing schedules are shown on the calendar so you always know what’s pending.

![3tSN01.png](https://s2.ax1x.com/2020/02/25/3tSN01.png)
![3tS59S.png](https://s2.ax1x.com/2020/02/25/3tS59S.png)
![3tSI1g.png](https://s2.ax1x.com/2020/02/25/3tSI1g.png)

These basics—creating Orchestration Plans and validating them with Datalab tests—lay the groundwork for successful disaster recovery. Stay tuned for the next installment! 


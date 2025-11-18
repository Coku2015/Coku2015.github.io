# VAO Basics (Part 2) – Installation & Deployment


## Series Index

- [VAO Basics (1) – Introduction](https://blog.backupnext.cloud/_posts/2020-02-17-VAO-Guide-01/)
- [VAO Basics (2) – Installation & Deployment](https://blog.backupnext.cloud/_posts/2020-02-18-VAO-Guide-02/)
- [VAO Basics (3) – Core Components · Part 1](https://blog.backupnext.cloud/_posts/2020-02-19-VAO-Guide-03/)
- [VAO Basics (4) – Core Components · Part 2](https://blog.backupnext.cloud/_posts/2020-02-20-VAO-Guide-04/)
- [VAO Basics (5) – Key Configuration Points](https://blog.backupnext.cloud/_posts/2020-02-21-VAO-Guide-05/)
- [VAO Basics (6) – The First Step of a Successful DR Plan](https://blog.backupnext.cloud/_posts/2020-02-25-VAO-Guide-06/)
- [VAO Basics (7) – Plan Step · Part 1](https://blog.backupnext.cloud/_posts/2020-02-27-VAO-Guide-07/)
- [VAO Basics (8) – Plan Step · Part 2](https://blog.backupnext.cloud/_posts/2020-02-28-VAO-Guide-08/)
- [VAO Basics (9) – Document Template Deep Dive](https://blog.backupnext.cloud/_posts/2020-03-02-VAO-Guide-09/)

## Getting the VAO Installer

You can download VAO directly from Veeam’s website – [here’s the shortcut](https://www.veeam.com/availability-orchestrator-download.html).

The ISO contains the entire VAO suite: the VAO server plus embedded instances of VBR and Veeam ONE. Although those embedded builds are just regular VBR/Veeam ONE installations, they cannot be extracted and installed separately; VAO deploys them because they are mandatory components. After VAO is up, you can reach the embedded VBR and Veeam ONE consoles like any other installation. The current ISO includes VBR 9.5 U4 and Veeam ONE 9.5 U4—once VAO is installed, remember to patch both to 9.5 U4a/U4b using the standard upgrade process.

## Installation Prerequisites

Two important reminders:

> - **Do not** run the VAO installer on a server that already hosts VBR or Veeam ONE.
> - **Do not** install VAO on a domain controller.

In practice, regardless of whether you already have VBR in production, plan to deploy VAO onto a brand-new Windows Server. After the installation, you can either add your existing VBR into VAO for centralized orchestration, or simply use the embedded VBR instance for day-to-day backup/replication tasks.

For more detailed prerequisites, see the [official requirements](https://helpcenter.veeam.com/docs/vao/deployment/system_requirements.html?ver=20).

## Installation Process

The download is an ISO file. Mount it and autorun the splash screen—you’ll find the VAO setup button:

![3PrjeA.png](https://s2.ax1x.com/2020/02/17/3PrjeA.png)

The wizard is identical to other Veeam products: keep clicking **Next** to finish the base deployment. When the installation completes, **immediately** install the VBR 9.5 U4a and Veeam ONE 9.5 U4a patches—U4a fixes many VAO-related bugs.

Need help upgrading VBR to 9.5 U4a? Refer to [my earlier post](https://blog.backupnext.cloud/_posts/2020-02-13-How-to-upgrade-VBR/).

During installation you must provide a username and password. These credentials are used by VAO, VBR, Veeam ONE, and their databases. The account therefore needs at least local Windows administrator rights on the VAO server (membership in the local **Administrators** group is sufficient). Although this account is unrelated to the disaster recovery administrator who will manage VAO later, the very first time you log into the UI you must use this same account.

![3PgvP1.png](https://s2.ax1x.com/2020/02/17/3PgvP1.png)

## Initial Configuration

1. After installation, **do not** open the embedded VBR or Veeam ONE consoles yet. Start the initialization wizard immediately by navigating to `https://<VAO IP>:9898/`.
   ![3PWOaQ.png](https://s2.ax1x.com/2020/02/17/3PWOaQ.png)

   Your browser prompts for credentials—enter the same username/password you specified during setup. This account is used only once during initialization; after the wizard finishes you’ll sign in with the DR admin defined in step 4 below.

2. Once authenticated, the Welcome page briefly introduces what the wizard will configure. Read through it if you like and click **Next**.
   ![3PfDoQ.png](https://s2.ax1x.com/2020/02/17/3PfDoQ.png)

3. Provide the VAO server’s basic management details. These fields are later referenced in document templates. Don’t worry if you make a mistake—you can edit the values later under **Configuration**.
   ![3Pf2Q0.png](https://s2.ax1x.com/2020/02/17/3Pf2Q0.png)

4. Next, specify the VAO DR administrator. This must be an Active Directory account because VAO requires AD. If your environment lacks AD, create a dedicated domain just for VAO. This account will be used to access VAO after the wizard completes. When initialization finishes, the local administrator you used during setup can no longer log in—so be sure to note the DR admin credentials here.
   ![3Pfczq.png](https://s2.ax1x.com/2020/02/17/3Pfczq.png)

5. The next page covers VBR integration. If you already have a VBR or Enterprise Manager instance you want VRO to orchestrate, enter its address now. Otherwise, click **Skip** to use the embedded VBR instance.
   ![3Pf6Wn.png](https://s2.ax1x.com/2020/02/17/3Pf6Wn.png)

   For brand-new environments, it’s perfectly acceptable to skip this step and rely on the embedded VBR for backup/replication.

   `This series focuses on the “Skip” scenario (using the built-in VBR).`

6. After skipping VBR, you’re prompted to add vCenter. Provide the production site’s vCenter account—ideally create a dedicated account for VAO and place it in the vCenter Administrators group. Although this step is optional in the wizard, vCenter is mandatory for actual operations. Even if you skip it now, you must register every vCenter later under **Configuration**. VAO does not support direct ESXi connections, so you can’t run VAO without vCenter.
   ![3Pf0eS.png](https://s2.ax1x.com/2020/02/17/3Pf0eS.png)

After you complete the steps above, click **Finish**. The page refreshes back to the VAO login screen. Sign in with the DR admin account defined in step 4 and you’re ready to go.

![3Pqq4f.png](https://s2.ax1x.com/2020/02/17/3Pqq4f.png)

Welcome to VAO! From here you can begin using the product. In the next article we’ll walk through the individual components.


# Kasten K10 Getting Started Series 03 - K10 Backup and Restore


## Kasten K10 Getting Started Series Table of Contents

[Kasten K10 Getting Started Series 01 - Quickly Build K8S Single-Node Test Environment](https://blog.backupnext.cloud/2020/12/Setting-up-quick-demo-for-K10-01/)

[Kasten K10 Getting Started Series 02 - K10 Installation](https://blog.backupnext.cloud/2021/05/K10-setup/)

## Main Content

Previously I introduced the installation of K10. The entire installation process is actually just one `helm install` command. After installation is complete, subsequent operations can be performed by opening K10's dashboard in a browser to configure the K10 backup system, manage K10 backup policies, and perform data recovery.

Like all backup systems, before starting backup operations, you need to configure a data storage location for K10 to store backup data. Currently, K10 supports storing data in object storage and has not yet added VBR Repository support. In K10's Settings, you can find the Locations setting, which is K10's backup repository. In this Locations section, you can use the New Profiles button as shown in the figure.

[![ghQEBq.png](https://z3.ax1x.com/2021/05/18/ghQEBq.png)](https://imgtu.com/i/ghQEBq)

When creating a new one, you need to provide the S3 access address, access key, and secret key to complete the Locations Profile configuration. After configuration is complete, subsequent backup policy settings can direct backup data to be Exported to this backup repository.

In K10, you don't need to add backup objects. K10 can automatically discover all Applications in the Kubernetes Cluster where the current K10 instance is running. This is very different from previous backup software.

In addition to setting up Locations for initial configuration, you also need to enable K10 Disaster Recovery. Only after enabling this operation can K10 recover our previously backed up data when any failure occurs in the current Kubernetes Cluster. This Disaster Recovery stores K10's backup catalog database in the current cluster to object storage. When any problems occur with the cluster, you can recover the backed up catalog in a new cluster and extract data for recovery.

[![ghQAun.png](https://z3.ax1x.com/2021/05/18/ghQAun.png)](https://imgtu.com/i/ghQAun)

When configuring K10 DR, administrators need to record the Cluster ID displayed on the screen after enabling K10 DR and keep it safe for subsequent K10 catalog recovery. Additionally, when enabling K10 DR, the system will prompt you to enter a "passphrase" which is used to create dr-secret during recovery. Therefore, this passphrase also needs to be kept safe along with the Cluster ID.

![dr_policy_form](https://docs.kasten.io/latest/_images/dr_policy_form1.png)

## Backup

All K10 backups are initiated through Policy. In the center of the dashboard is Policy-related content, including displaying the current total number of Policies and creating new Policies.

[![ghQicj.png](https://z3.ax1x.com/2021/05/18/ghQicj.png)](https://imgtu.com/i/ghQicj)

To protect an Application, administrators need to open the Policy configuration page through new policy. As shown in the figure below, you need to fill in some relevant information on this configuration page to complete the creation of the backup policy.

[![ghQVH0.jpg](https://z3.ax1x.com/2021/05/18/ghQVH0.jpg)](https://imgtu.com/i/ghQVH0)

After creation is complete, you can view this Policy in Policies, and you can use run once to initiate and run a single backup job. Under normal circumstances, Policy will automatically run at the set time according to the scheduled task settings.

[![ghQP3Q.png](https://z3.ax1x.com/2021/05/18/ghQP3Q.png)](https://imgtu.com/i/ghQP3Q)

## Restore

After data backup is complete, you can see that the application status has become Compliant in Applications

[![ghQSN8.png](https://z3.ax1x.com/2021/05/18/ghQSN8.png)](https://imgtu.com/i/ghQSN8)

And you can see different restore points in Restore Points.

[![ghQp4S.png](https://z3.ax1x.com/2021/05/18/ghQp4S.png)](https://imgtu.com/i/ghQp4S)

After selecting a restore point, you can restore the entire application or delete the restore point.

[![ghQC9g.png](https://z3.ax1x.com/2021/05/18/ghQC9g.png)](https://imgtu.com/i/ghQC9g)

The above is the basic backup and restore content of K10 in this section. It has a completely graphical interface and is very simple to use. For more content, please follow the subsequent updates of this series.


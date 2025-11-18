# Veeam Backup Server Upgrade Guide


## Introduction

Veeam is about to launch the new v10 version. In this version, Veeam supports upgrading from previous VBR to v10. The smooth upgrade process is not complicated and is similar to previous VBR upgrades, though there are some details to pay attention to.

### Before Upgrade

Please check your current environment according to the flowchart below. Ensure other components are properly upgraded before upgrading VBR.

![1L4P8H.png](https://s2.ax1x.com/2020/02/13/1L4P8H.png)

Starting from v10, Veeam will use the new Veeam Universal License (VUL). Please log in to My.veeam.com in advance to get the updated License. During the upgrade process, you will be prompted to use the new License to activate the product.

### Upgrade Methods

There are two methods to upgrade, with no significant difference.

1. In-place upgrade on the original VBR server;
2. Install a new VBR server, then restore the Configuration Backup File to this newly installed VBR.

Since the second method is almost identical to a fresh installation, this article will not discuss it in detail and will only cover the first in-place upgrade method.

### Upgrade Preparation

Prepare the Veeam upgrade media. Veeam products are very simple - the upgrade media uses the same package as fresh installation. Just mount the product package to the VBR server. Before executing the Upgrade, you need to do a series of preparation work:

1. Carefully read the Release Notes, check your environment, and see if there are any unsupported systems.

```
  	- VMware vSphere 5.1 and earlier versions
  	- Windows 2003 and XP
  	- Microsoft SQL Server 2005
```

2. Use Veeam Configuration Backup to create a backup of your VBR configuration. Please ensure this backup is in Encrypted mode, so all usernames and passwords used in VBR will be properly saved in the .bco file.
3. Check all backup jobs on the VBR server to ensure no jobs are running. Pay special attention to the following jobs, which need to be manually clicked Disable to stop:

```
    - Backup Copy Job
    - SQL, Oracle log backup jobs
```

Check if any Instant VM Recovery is running;

Check if any Veeam Explorer is open and performing recovery;

Check if any SureBackup/Virtual Lab is running.

When all tasks are stopped, the status will be as shown below:

![1L7jrd.png](https://s2.ax1x.com/2020/02/13/1L7jrd.png)

### Upgrade Process

The entire upgrade process is very simple. Just follow the wizard and click through a few screens, then quietly wait for about 30 minutes for the software to complete the upgrade. Therefore, I won't go into step-by-step details of this process here.

### Possible Issues

1. During the upgrade process, the upgrade package will first stop all VBR services. You may encounter service stop timeouts or failures, causing the upgrade process to interrupt. If you encounter failures, it's recommended to first check if services starting with "veeam" in Services.msc have been properly stopped.
2. After all services are properly stopped, if the in-place upgrade still reports errors, you can try restarting the VBR server and then attempting the upgrade again. Here, pay special attention that after the VBR restart, you need to recheck all VBR jobs to ensure no jobs are running automatically.
3. If you try multiple times and cannot perform a normal upgrade, it's recommended to use method 2 mentioned above - install a new VBR server and then import the Configuration backup file.
4. If all the above methods fail, please contact the Veeam Support team in time. Our engineers will promptly provide you with upgrade support.

These are some upgrade tips. Thank you for reading!

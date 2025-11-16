# VAO Basics (Part 8) – Plan Steps · Part 2


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

Previously we looked at the Plan Step library. Today we’ll zoom in on custom scripts—how to create them, where to run them, and how to pass parameters. I’ll walk through a working example so you can follow along.

## Creating & Configuring Custom Steps

You need an account in the **Administrators** role to manage Plan Steps. In **Administration → Configuration → Plan Steps** you’ll find the full list, including both built-in steps and any custom ones you add.

![3wzhTJ.png](https://s2.ax1x.com/2020/02/27/3wzhTJ.png)

Click **Add** to launch the wizard. Give the step a memorable name—say “Remote test script”—and upload your PowerShell file via **Browse**.

![30MFTs.png](https://s2.ax1x.com/2020/02/27/30MFTs.png)

Choose whether the step is visible to all Plan Authors or hidden (for sensitive scripts).  
![308ao4.png](https://s2.ax1x.com/2020/02/27/308ao4.png)

Finish the wizard to save the step. One critical reminder: custom steps can run either on the **VBR server** or inside the **guest OS** of the recovered VM. After creating the step, click its name and adjust the **Execution Target** on the right. The default is “On VBR server”. For today’s test we’ll switch it to **In-Guest OS**.

![30smI1.png](https://s2.ax1x.com/2020/02/27/30smI1.png)

This setting is global—if multiple scopes use the same step, they all inherit the same execution target. Create separate steps if you need different behavior.

## Hello, Script

Let’s start simple:

```powershell
###########
# Lei Wei - 02/28/20
# A quick demo script
# v1.0

$S = Get-Date
Add-Content c:\vao_log.txt "$S - Recording date"
```

If everything goes well you’ll see the step appear in VAO like this:

![30RZZD.jpg](https://s2.ax1x.com/2020/02/27/30RZZD.jpg)

## Handling Errors

Real scripts fail occasionally, so let’s add error handling:

```powershell
###########
# Lei Wei - 02/27/20
# Demo script with error handling
# v1.1

try {
    $S = Get-Date
    Add-Content c:\vao_log.txt "$S - Recording date."
    Write-Host "Operation succeeded"
}
catch {
    Write-Error "Something broke!"
    Write-Error $_.Exception.Message
}
```

When this script runs, VAO captures both success and failure output and surfaces it directly in the UI:

![30Iizd.png](https://s2.ax1x.com/2020/02/27/30Iizd.png)

## Passing Parameters

Scripts can also receive parameters from VAO. Update the script to accept two values:

```powershell
###########
# Lei Wei - 02/27/20
# Demo script with parameters
# v1.2

Param(
    [Parameter(Mandatory=$true)]
    [string]$planName,
    [string]$text
)

try {
    $S = Get-Date
    Add-Content c:\vao_log.txt "$S - Recording date."
    Write-Host "Operation succeeded"
    Write-Host "Plan $planName says: $text"
}
catch {
    Write-Error "Something broke!"
    Write-Error $_.Exception.Message
}
```

To feed those parameters from VAO, open the step and click **Add** under the parameters pane. The parameter names must match the script exactly (`planName` and `text` in this example).

![307LtK.png](https://s2.ax1x.com/2020/02/28/307LtK.png)

For `planName`, set the default value to `$plan_name$`—one of VAO’s built-in variables. Click **Edit** to see the list of available variables. For `text`, type a literal string such as “parameter transfer completed”.

Now run the plan that uses this step. The Step Details and final report will display the output with your parameters injected:

![307qk6.png](https://s2.ax1x.com/2020/02/28/307qk6.png)

Feels pretty powerful, right? Give it a try and start building your own automation!


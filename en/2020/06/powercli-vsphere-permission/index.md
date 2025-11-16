# Create a Minimal vSphere Role for Veeam via PowerCLI


Hardening a Veeam deployment starts with a least-privilege vSphere account. As VBR adds features, the list of required rights keeps growing—check the full [fine-grained permission matrix](https://helpcenter.veeam.com/docs/backup/permissions/cumulativepermissions.html?ver=100). Manually clicking through every checkbox is tedious, so here’s a slick PowerCLI script I recently found that builds the role automatically.

Prerequisite: install VMware PowerCLI. VMware’s [official blog post](https://blogs.vmware.com/PowerCLI/2018/03/installing-powercli-10-0-0-macos.html) explains the process in detail; below is the short version.

1. Install [PowerShell Core 7](https://github.com/PowerShell/PowerShell). It’s required for PowerCLI and works on Windows, macOS, and Linux. On Windows, just run the MSI installer.
2. Launch the PowerShell 7 shortcut and install PowerCLI:

   ```powershell
   Install-Module -Name VMware.PowerCLI -Scope CurrentUser
   ```

   Verify the modules with:

   ```powershell
   Get-Module -Name VMware.* -ListAvailable
   ```

   ![tr87i6.png](https://s1.ax1x.com/2020/06/05/tr87i6.png)

3. Run the [PowerCLI script](https://www.virtualhome.blog/2020/04/22/creating-a-vcenter-role-for-veeam-with-powercli/) (also mirrored on GitHub). It prompts for the vCenter address, credentials, and desired role name; supply values that fit your environment.  
   ![trJG38.png](https://s1.ax1x.com/2020/06/05/trJG38.png)

4. Back in the vSphere Client, open **Administration → Access Control → Roles** and you’ll see the newly created *VBR Backup Admin* role.  
   ![trYFbj.png](https://s1.ax1x.com/2020/06/05/trYFbj.png)

5. Under **Single Sign On → Users and Groups**, switch to the appropriate domain and create a dedicated user.
6. Assign that user to the vCenter with the *VBR Backup Admin* role:  
   ![trtWfx.png](https://s1.ax1x.com/2020/06/05/trtWfx.png)

That’s it—fast, repeatable, and aligned with least-privilege best practices. Script link for reference: <https://github.com/falkobanaszak/vCenter-role-for-Veeam/blob/master/New_vCenterRole_Veeam.ps1>.


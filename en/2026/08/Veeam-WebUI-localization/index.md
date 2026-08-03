# Veeam Backup & Replication v13.1 Web UI Simplified Chinese Package Released: Making the New-Gen VBR WebUI Truly Usable



About 7 years ago, I built a Chrome extension that localized Veeam Enterprise Manager's web interface into Chinese.

Back then, getting a Chinese interface as a Chinese user was genuinely hard. I shipped the extension and didn't think much of it, and to my surprise, Veeam R&D later picked it up and officially folded it into the Chinese release of EM.

Fast forward 7 years, Veeam's next-gen Web UI arrived, and Chinese is missing again.

This time the situation is a bit different. The v13.1 Web UI isn't the old "check status, click a button" Enterprise Manager page. It's becoming the operational entry point for the next-generation Veeam backup server, and day-to-day operations will depend on it. Yet Simplified Chinese still isn't among the built-in languages.

The reason isn't complicated. Veeam's market strategy, both overseas and in China, means official Simplified Chinese support most likely isn't coming back. But for AI today, this isn't a problem at all. So I decided to spend a weekend building a Simplified Chinese localization package for the Veeam Backup & Replication Web UI.

Project repository:

[https://github.com/Coku2015/Veeam-Chinese-UI-Packages](https://github.com/Coku2015/Veeam-Chinese-UI-Packages)

Currently supported version:

```text
Veeam Backup & Replication Web UI 13.1.0.411
```

## Let's Be Clear: Why the v13.1 Web UI Deserves Special Attention

If you've been relying on Veeam's Windows Console as your primary tool, after v13.1 the Web UI's role is genuinely different.

It's no longer the experimental first-gen product. Cross-platform recovery, multi-hypervisor management, Agent management, unstructured data protection, the malware detection control plane, RBAC—these heavy-lifting tasks are being moved into the browser one by one. Let me highlight a few key ones.

### 1. Instant Recovery Is Now in the Web UI, and It's Cross-Platform

In v13.1, the Web UI supports initiating Instant Recovery directly from image-level backups, covering far more target platforms than before.

Don't underestimate this change. Admins can handle cross-platform recovery within a single browser interface, without bouncing between the Console, plug-ins, and various recovery entry points.

Today, many enterprises haven't been single-hypervisor shops for a long time. VMware, Hyper-V, Nutanix AHV, and Proxmox VE often coexist. If recovery capability stays locked to a single management tool, the operations experience will inevitably be fragmented. The Web UI is moving toward becoming that "unified recovery entry point."

### 2. AHV and Proxmox VE Coverage in the Web UI Has Been Greatly Rounded Out

v13.1 is quite aggressive in its multi-hypervisor support. Beyond the traditional VMware vSphere and Hyper-V, Veeam continues to expand Nutanix AHV and Proxmox VE, and has introduced platform capabilities for Sangfor aSV, Citrix XenServer, XCP-ng, Platform9, and VergeOS. Of course, these latter platforms haven't yet entered the Web UI's unified management.

More importantly, backup jobs, restore operations, and infrastructure management for AHV and Proxmox VE have gained much more complete coverage in the Web UI.

This matters a lot for teams in the middle of hypervisor migration, replacement, or hybrid deployment: the Web UI is becoming a unified operational plane across hypervisors.

### 3. Agent Management and Remote Bare Metal Recovery Entered the Web UI

v13.1 continues to expand Web UI capabilities for Agent scenarios, including protection groups, Windows/Linux Agent backup job management, and common recovery operations.

Remote Bare Metal Recovery for Veeam Agent for Windows can now be initiated and managed through the Web UI. End users just need to boot the machine into a pre-configured recovery environment, and the admin can run the rest of the recovery workflow from the Web UI.

This is especially useful for branch offices, remote work, and unattended sites. These operations used to need someone on-site watching things; now remote recovery lets admins get the work done in a more centralized way.

### 4. Unstructured Data Protection Fully Entered the Web UI

Unstructured data sources like file shares and object storage, along with their related backup jobs, monitoring, and recovery operations, also received complete Web UI coverage in v13.1.

Unstructured data is typically large in volume, changes frequently, and involves a messy mix of object types. Putting this management capability in the Web UI lets admins see data sources, job status, and recovery operations in one interface, with no more jumping between multiple entry points.

### 5. The Malware Detection Control Plane Entered the Web UI

v13.1 further strengthens malware detection capabilities, and the full control plane has entered the Web UI, including incident management, fine-grained exclusion rules, and end-to-end investigation workflows.

Now the Web UI isn't just a "backup job management interface." It's also running security operations. Detection results, policy adjustments, investigation, and response can all happen in one interface.

Ransomware is already a reality that backup systems have to face head-on. On this point, the value is direct.

### 6. The Web UI Itself Is Becoming More Like a Modern Management Entry Point

Beyond the "heavy lifting" above, the v13.1 Web UI also brings quite a few changes that directly affect the daily experience:

- Refreshed default theme
- User-level personalization settings
- Expanded language support
- Veeam ONE alarm panel integration
- Mail server and notification settings can be configured directly in the Web UI
- Enhanced Backup Copy Job detail view
- Application-item-level recovery for Microsoft Active Directory and Microsoft SQL Server entered the Web UI
- Full advanced RBAC, including custom roles, scope visibility, and centralized role management
- Support for creating empty jobs: build the job template first, then add protection objects later

The trend is clear. The VBR Web UI is becoming a lighter, more unified entry point, better suited for daily operations and cross-platform recovery.

## Simplified Chinese Package: Filling in This Missing Piece

The Veeam v13.1 Web UI ships with English, German, French, and Japanese. No Simplified Chinese.

For Chinese admins, this is rough. A genuinely poor experience. The capabilities are already this complete; if you could work in a familiar Chinese interface, learning, demos, delivery, training, and daily operations would all go much more smoothly.

So I built this unofficial Simplified Chinese localization package.

The goals are clear:

- Add "Simplified Chinese" on top of the existing languages
- Don't overwrite the original multilingual UI; keep English, German, French, and Japanese
- Use professional Chinese terminology from the Veeam backup field
- Support both platforms: Windows Backup Server and Linux Appliance
- Support one-click installation, with automatic backup of the official original language files before install; also support one-click uninstall and restore, to make future upgrades easy without affecting official support

## Usage

### Linux Appliance Installation

First, enter the Veeam Appliance Console and select:

```text
Enable SSH server
```

![Xnip2026-08-02_19-21-44](https://files.seeusercontent.com/2026/08/02/7quO/Xnip2026-08-02_19-21-44.jpg)



Then, on your local machine, use `scp` to transfer the installation package to the Appliance:

```bash
scp VeeamWebUiZhCN-13.1.0.411-linux.tar.gz veeamadmin@vbrvsaip:/tmp/
```

Replace `vbrvsaip` with the hostname or IP of your Veeam Backup Server / Linux Appliance.

Back in the Veeam Appliance Console, select:

```text
Enter shell
```

After entering the shell, run:

```bash
cd /tmp
tar xvf VeeamWebUiZhCN-13.1.0.411-linux.tar.gz
bash VeeamWebUiZhCN-13.1.0.411/linux/install-veeam-webui-zh-cn.sh
```

![Xnip2026-08-02_19-24-46](https://files.seeusercontent.com/2026/08/02/Ypm9/Xnip2026-08-02_19-24-46.jpg)



Once done, no VBR services need to be restarted. Just go back to the Web UI in your browser and refresh to see the Chinese interface.

Uninstall and restore:

```bash
cd /tmp
bash VeeamWebUiZhCN-13.1.0.411/linux/uninstall-veeam-webui-zh-cn.sh
```

### Windows Installation

On the Veeam Backup Server, open PowerShell as Administrator:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd C:\Users\Administrator\Downloads\VeeamWebUiZhCN-13.1.0.411\windows
.\Install-VeeamWebUiZhCN.ps1
```

Uninstall and restore:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd C:\Users\Administrator\Downloads\VeeamWebUiZhCN-13.1.0.411\windows
.\Uninstall-VeeamWebUiZhCN.ps1
```

After installation, force-refresh your browser, then select "Simplified Chinese" from the language menu.

## Chinese UI Preview

### Web UI Simplified Chinese Interface

![Xnip2026-08-02_17-27-51](https://files.seeusercontent.com/2026/08/02/Bjy8/Xnip2026-08-02_17-27-51.jpg)



![Xnip2026-08-02_17-28-09](https://files.seeusercontent.com/2026/08/02/Tx2d/Xnip2026-08-02_17-28-09.jpg)

## Notes

This localization package is an unofficial project, not a Veeam official hotfix.

Before installing, confirm that the Web UI build matches the Chinese package version. I recommend uninstalling the Chinese package before upgrading Veeam, then installing the version matching the new build after the upgrade is complete.

If the installation script reports a hash mismatch, it means the target file may have been upgraded or modified. Don't force-install a mismatched version.

## Wrap-up

That Chinese localization extension from 7 years ago eventually became the official EM Chinese release.

The new-gen Web UI launched, and Chinese was missing again. We can't control market strategy, but building it ourselves beats just waiting.

v13.1 is a major release aimed at multi-hypervisor, multi-workload, and modern operational experiences. The Web UI takes on more core capabilities in this version, and is better suited to be the unified entry point for daily operations, recovery, and monitoring.

I hope this Simplified Chinese package helps more Chinese users get hands-on with the new v13.1 Web UI more smoothly. Downloads, tests, and feedback are all welcome. Let's keep filling in the Chinese UI for more Veeam products together.

Project repository:

[https://github.com/Coku2015/Veeam-Chinese-UI-Packages](https://github.com/Coku2015/Veeam-Chinese-UI-Packages)


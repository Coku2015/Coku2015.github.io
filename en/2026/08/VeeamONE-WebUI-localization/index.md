# Veeam ONE v13.1 Web UI Simplified Chinese Package Released: Bringing Chinese to Monitoring and Analytics


Last week we released the Simplified Chinese package for the VBR Web UI.

This time, it's Veeam ONE's turn.

In the Veeam ecosystem, VBR does the heavy lifting — backup, replication, recovery. Veeam ONE does the watching — monitoring, analytics, alerting, security posture. Together, the two close the loop on day-to-day operations.

And just like VBR, the Veeam ONE Web UI shipped without Simplified Chinese.

So this week, we filled that gap too.

The project repository is still the same one:

[https://github.com/Coku2015/Veeam-Chinese-UI-Packages](https://github.com/Coku2015/Veeam-Chinese-UI-Packages)

Currently supported version:

```text
Veeam ONE Web UI 13.1.0.7034
```

## Veeam ONE: The "Watcher" of the Backup Stack

Many people's impression of Veeam stops at VBR. But within the Veeam ecosystem there's a product dedicated to monitoring and analytics, and that's Veeam ONE.

It does a different job than VBR. VBR is about backing data up and restoring it. Veeam ONE stands to the side, keeping an eye on the entire backup infrastructure and virtualization platform — telling you where the risks are, what to optimize, how much capacity is left, and whether there's any suspicious activity.

Specifically, Veeam ONE looks after these areas:

- **Monitoring**: Watches Veeam backup servers, repositories, proxies, and other components, as well as resources on virtualization platforms like VMware and Hyper-V.
- **Alerting**: Ships with a large set of built-in alert rules — backup failures, repositories nearing capacity, job timeouts — all flagged in real time.
- **Analytics**: v13 introduces the all-new Veeam Analytics Service, with a more scalable and reliable monitoring backend that delivers consistent anomaly detection across hybrid platforms.
- **Reporting**: Long-term, tangible outputs like capacity planning and compliance audits.
- **Security posture**: Threat Center rolls up the zero-trust posture and security compliance of the backup system into a score and investigation workflow.

VBR is the hand; Veeam ONE is the eye.

## This Generation's Web UI Is Becoming the Main Entry Point

Just like VBR, Veeam ONE is heading down the Web UI path.

In the v13 generation, the Veeam ONE Web UI has clearly risen in status — it's no longer an auxiliary page you glance at after installation. Monitoring, alerting, dashboards, Threat Center and other everyday capabilities are increasingly consolidated in the Web UI. The REST API has kept pace too, making integration with external systems straightforward.

On the VBR v13.1 side, the Veeam ONE alert panel has been specifically integrated into the VBR Web UI — which also shows that the two products' Web UIs are already wired together rather than each minding its own business.

Since it's an entry point you stare at every day, a Chinese interface genuinely pays off: alerts are understood at a glance, analytics don't require guesswork, and demos for the boss or onboarding for new hires get noticeably easier.

## The Simplified Chinese Package: Making This Monitoring and Analytics Plane Speak Chinese

The Veeam ONE Web UI ships with English, Japanese, Deutsch, Français and other languages — but, again, no Simplified Chinese.

So we built this unofficial Chinese package. The goals are identical to last week's VBR package:

- Add "Simplified Chinese" on top of the existing languages
- Don't overwrite the original multilingual support — English, Japanese, Deutsch, Français all stay
- Use professional Chinese terminology from the Veeam monitoring and analytics domain
- One-click install, with an automatic backup of the official original language files before installation
- One-click uninstall and restore, with no impact on official vendor support

Once installed, the login page and main interface will both show the `zh-CN (Simplified Chinese)` option — just select it.

## An "Along for the Ride" Bonus

There's one more thing worth mentioning about this package.

Veeam ONE exposes a set of remote plugin resources specifically for Analytics and Threat Center. After VBR connects to Veeam ONE, the "Analytics" page inside the VBR Web UI loads exactly those Veeam ONE resources.

So once this Chinese package is installed, the analytics page on the VBR side turns Chinese too — provided VBR is actually connected to Veeam ONE.

If it isn't connected, VBR won't load those remote resources and the original page stays unchanged; the two sides don't interfere with each other.

This is also why last week's VBR package couldn't handle that analytics page on its own: that piece simply isn't VBR's to manage. The two packages together are what make the coverage complete.

## How to Use It

On the Veeam ONE Server, open PowerShell as administrator:

```powershell
Invoke-WebRequest -Uri "https://github.com/Coku2015/Veeam-Chinese-UI-Packages/raw/main/VeeamONE%20WebUI%20Chinese%20Package/VeeamONE-13.1.0.7034/VeeamOneWebUiZhCN-13.1.0.7034-windows.zip" -OutFile "$env:USERPROFILE\Downloads\VeeamOneWebUiZhCN-13.1.0.7034-windows.zip"
Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\VeeamOneWebUiZhCN-13.1.0.7034-windows.zip" -DestinationPath "$env:USERPROFILE\Downloads" -Force
Set-ExecutionPolicy -Scope Process Bypass
cd "$env:USERPROFILE\Downloads\VeeamOneWebUiZhCN-13.1.0.7034\windows"
.\Install-VeeamOneWebUiZhCN.ps1
```

To uninstall and restore:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd "$env:USERPROFILE\Downloads\VeeamOneWebUiZhCN-13.1.0.7034\windows"
.\Uninstall-VeeamOneWebUiZhCN.ps1
```

After installation, do a `Ctrl+F5` hard refresh on both the login page and the Web UI, then pick `zh-CN (Simplified Chinese)` from the language menu.

## Chinese UI in Action

Home main interface

![Xnip2026-08-09_20-38-13](https://files.seeusercontent.com/2026/08/09/gr4F/Xnip2026-08-09_20-38-13.jpg)

### Login Page Language Selection

![Xnip2026-08-09_20-37-33](https://files.seeusercontent.com/2026/08/09/so0Y/Xnip2026-08-09_20-37-33.jpg)

### Veeam ONE Alert Preview

Veeam ONE alert preview

![Xnip2026-08-09_20-39-34](https://files.seeusercontent.com/2026/08/09/r0Ns/Xnip2026-08-09_20-39-34.jpg)

### Configuration Page

![Xnip2026-08-09_20-40-12](https://files.seeusercontent.com/2026/08/09/xN6o/Xnip2026-08-09_20-40-12.jpg)

### With VBR Connected to Veeam ONE, the Analytics Page Turns Chinese

VBR analytics page in Chinese

![Xnip2026-08-09_20-51-45](https://files.seeusercontent.com/2026/08/09/mq6F/Xnip2026-08-09_20-51-45.jpg)



## Notes

This localization package is an unofficial project; it is not a Veeam official hotfix.

Before installing, please confirm that your Veeam ONE Web UI build matches the Chinese package version (13.1.0.7034). We recommend uninstalling the Chinese package before upgrading Veeam ONE, then installing the version that matches the new build once the upgrade is complete.

The install script backs up the Web UI static files it modifies, and the uninstall script verifies and restores them.

If the install script reports a hash mismatch, it means the Veeam ONE files may have already been upgraded or modified — please do not force the install of a mismatched version.

## Closing

Last week we took care of VBR; this week we've taken care of Veeam ONE.

Across this Veeam backup stack, both sides — the "doing" and the "watching" — deserve a Chinese interface that feels natural. VBR does the work, Veeam ONE does the watching, and together the two Web UI Chinese packages cover the two entry points most people stare at day in and day out.

And because the two products' Web UIs are already wired together, the Veeam ONE package has the bonus effect of bringing Chinese to VBR's analytics page as well.

We hope this package helps more Chinese-speaking administrators who keep an eye on the monitoring dashboard.

Feel free to download, test, and share feedback. Project repository:

[https://github.com/Coku2015/Veeam-Chinese-UI-Packages](https://github.com/Coku2015/Veeam-Chinese-UI-Packages)


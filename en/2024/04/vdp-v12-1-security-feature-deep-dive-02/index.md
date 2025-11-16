# VDP v12.1 Security Feature Deep Dive Series (Part 2) - Malware Scanning


Following up on yesterday's post, let's dive into the second major update: YARA Scan and Antivirus Scan.

Beyond its ability to perform online scanning of backup data streams, Veeam Backup & Replication (VBR) now supports secondary scanning of already backed-up data. Version 12.1 introduces two powerful scanning engines: one that leverages antivirus software installed on the Mount Server, and another that utilizes YARA as the scanning engine.

### Understanding YARA

YARA (which stands for *Yet Another Recursive Acronym*) is a tool primarily used by security experts and researchers to identify and classify malware. You can find the official documentation at https://yara.readthedocs.io/en/latest/ and the GitHub repository at https://github.com/virustotal/yara.

YARA excels at malware research and detection by scanning text or binary patterns within files. The tool typically consists of two main components: the YARA scanning engine itself, which can be installed across various platforms, and YARA rules—custom matching patterns written by users to meet specific requirements. The workflow is straightforward: the YARA engine loads your custom rules and scans target content, then outputs the results.

With VDP v12.1, YARA integration means backup and security administrators can now directly invoke YARA rules from the VBR console to scan backup archives—no need to manually set up and maintain a separate YARA environment.

#### Working with YARA Rules

YARA rule syntax is actually quite simple. You can reference the official documentation at https://yara.readthedocs.io/en/stable/writingrules.html and find plenty of rule templates on GitHub at https://github.com/Yara-Rules/rules.

VBR comes pre-loaded with three classic YARA rule templates that serve as excellent starting points for your own rules.

Of course, these days you don't even have to write rules from scratch—various GPT models can help you generate YARA rules effortlessly. For instance:
[![pkiq6D1.png](https://s21.ax1x.com/2024/04/28/pkiq6D1.png)](https://imgse.com/i/pkiq6D1)

#### How YARA Scanning Works

Simply save the GPT-generated content into a file with a `.yar` or `.yara` extension and place it in the `C:\Program Files\Veeam\Backup and Replication\Backup\YaraRules` directory. VBR will automatically detect and load these rules.
[![pkiqhCD.png](https://s21.ax1x.com/2024/04/28/pkiqhCD.png)](https://imgse.com/i/pkiqhCD)

When you initiate a scan, VBR mounts the backup archive to the Mount Server and uses the YARA engine on that server to load and apply your selected YARA rules.

Since this scanning operates at the text and binary level, it's not limited to just malicious code detection—you can actually scan for any critical information you're looking for.

### Antivirus Scanning

Antivirus scanning was first introduced in VBR v10 as part of the Secure Restore feature, where VBR would call upon antivirus software installed on the Mount Server to scan backup archives. In v12.1, this capability has been integrated into the Scan Backup functionality, with expanded support for more antivirus solutions.

#### Antivirus Configuration

Version 12.1 includes built-in support for six major antivirus engines: Symantec Protection Engine, ESET, Windows Defender, Kaspersky Security, Bitdefender Endpoint Security Tools, and Trellix (formerly the well-known McAfee).

Beyond these six solutions, Veeam also supports additional antivirus software through the `AntivirusInfos.xml` configuration file. You can modify the XML file located in the `%ProgramFiles%\Common Files\Veeam\Backup and Replication\Mount Service` directory on your Mount Server to configure other antivirus solutions via CLI command-line calls. For detailed XML configuration syntax, check out the official documentation at https://helpcenter.veeam.com/docs/backup/vsphere/av_scan_xml.html?ver=120.

### Configuration Methods

In VBR, there are multiple ways to initiate scanning:

1. **Direct Backup Archive Scanning**: Select a supported backup archive, right-click, or choose the `Scan Backup` button from the toolbar to launch either the antivirus scanning or YARA scanning dialog.

[![pkiqW4O.png](https://s21.ax1x.com/2024/04/28/pkiqW4O.png)](https://imgse.com/i/pkiqW4O)

After launching Scan Backup, the scanning dialog opens where you can use either engine to perform security scans on the entire backup chain using three different scanning methods.

[![pkiqRUK.png](https://s21.ax1x.com/2024/04/28/pkiqRUK.png)](https://imgse.com/i/pkiqRUK)

2. **Secure Restore Integration**: During full VM or disk restore operations, enable antivirus scanning or YARA scanning in the Secure Restore steps.
[![pkiqcHx.png](https://s21.ax1x.com/2024/04/28/pkiqcHx.png)](https://imgse.com/i/pkiqcHx)

3. **SureBackup Integration**: Enable antivirus scanning or YARA scanning options within your SureBackup jobs.
[![pkiq2E6.png](https://s21.ax1x.com/2024/04/28/pkiq2E6.png)](https://imgse.com/i/pkiq2E6)

#### Viewing Scan Results

If scan results detect matching content, VBR will mark the scanned backup archive with an "Infected" status, indicating that malware has been discovered.

Complete scan logs are recorded in the VBR directory: `C:\ProgramData\Veeam\Backup\FLRSessions\Windows\FLR__<machinename>_\Antivirus`

Similar to the online malware attack analysis we discussed earlier, detailed scan status is also recorded in VBR's History, where you can search and review scan results.

[![pkiqyuR.png](https://s21.ax1x.com/2024/04/28/pkiqyuR.png)](https://imgse.com/i/pkiqyuR)

These are the new backup archive scanning methods introduced in VDP v12.1, designed to help administrators avoid secondary infections after incidents occur and ensure that recovered data consists of clean system archives.

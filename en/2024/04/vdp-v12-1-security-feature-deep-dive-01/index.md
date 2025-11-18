# VDP v12.1 Security Feature Deep Dive Series (Part 1) - Ransomware Detection


I'm genuinely excited to share this deep dive into Veeam Data Platform v12.1's security enhancements. When Veeam released this major update late last year, they packed it with significant security features that deserve proper attention. Starting today, I'll be exploring each of these capabilities in detail, breaking down how they work and how to make the most of them.

For this first installment, let's dive into ransomware detection. In v12.1, Veeam introduced a comprehensive malware detection module that consists of two core components: Inline Entropy Scan and Index Scan. Both work together to provide multiple layers of protection against sophisticated attacks.

### Inline Entropy Scan: Real-time Protection During Backup

Let's start with Inline Entropy Scan, which is disabled by default and requires manual activation. Once enabled, it becomes a global setting that applies to all supported backup sources during the backup process.

What makes this particularly interesting is that Inline Scan leverages a sophisticated data analysis model trained on Veeam's extensive experience in data protection. The system performs real-time analysis during backup operations and generates alerts when it detects specific anomaly patterns:

- **Mass encryption detection**: The system identifies when large volumes of data are being encrypted, with five adjustable sensitivity levels. Higher sensitivity settings can trigger alerts even for smaller-scale encryption activities.

![Mass encryption detection](https://s21.ax1x.com/2024/04/27/pkPXLT0.png)

- **Ransomware artifact detection**: The system flags when ransomware creates telltale text content, including Tor addresses (similar to V3 onion addresses), ransom notes, and other characteristic indicators.

![Ransomware artifact detection](https://s21.ax1x.com/2024/04/27/pkPXXkV.md.png)

#### How It Works

The scanning process runs during backup job execution. The VBR server analyzes each data block received during the backup process, utilizing a new service called Veeam Data Analyzer Service to manage this analysis.

Here's the workflow:

1. **Initial analysis**: The data analysis occurs at the Backup Proxy or Agent level. When analysis begins, the Proxy stores a temporary RIDX file containing scanned disk source data and potential ransomware indicators, such as encrypted data patterns, file types, onion addresses, and ransom notes.

2. **Data transfer**: After backup completion, this data is transmitted to the VBRCatalog folder on the VBR server.

3. **Comparative analysis**: VBR compares the received RIDX file against historical archives in the VBRCatalog folder to determine if a malicious attack has occurred. If anomalies are detected, the system generates event notifications and marks the backup archive as Suspicious.

#### Configuration and Exclusion Methods

To enable Inline Entropy Scan, navigate to the VBR console's global settings menu in the upper-left corner. There you'll find the new Malware Detection option added in v12.1. The configuration interface includes a checkbox to enable scanning and a slider to adjust sensitivity levels. By default, the checkbox is unchecked, and sensitivity is set to Normal.

![Inline Entropy Scan configuration](https://s21.ax1x.com/2024/04/27/pkPXjYT.png)

For systems that require exclusion, you can use global exclusion options. Access these through the same global settings menu, where you'll find the new Malware Exclusion option in v12.1.

![Malware exclusion settings](https://s21.ax1x.com/2024/04/27/pkPX7Os.png)

Here you can add specific virtual machines or Veeam Agents to exclude from scanning.

![Exclusion configuration](https://s21.ax1x.com/2024/04/27/pkPjFTx.md.png)

### Index Scan: File-level Analysis

Beyond the real-time Inline scanning, VBR also leverages file system indexing capabilities for malicious file analysis. This functionality builds upon VBR's Guest Processing feature, specifically the "Index guest files" capability. While globally enabled by default, it requires the Index guest files option to be checked in each backup job's Guest Processing settings to take effect.

Index Scan focuses on detecting several specific anomaly patterns:

- **Known suspicious file detection**: The scan matches against known suspicious file extensions defined in the SuspiciousFiles.xml file, generating alerts when matches are found.

- **Mass file renaming**: Triggers alerts when more than 200 files are renamed with the same extension, a common tactic in ransomware attacks.

- **Mass file deletion**: Flags suspicious activity when more than 25 files with special extensions are deleted or when 50% of files are removed.

#### How It Works

This scanning runs during backup job execution through the Guest Processing service, which captures file indexing information from each virtual or physical machine and transmits it to the VBR server's VBRCatalog directory. The Veeam Data Analyzer Service then analyzes this data.

The SuspiciousFiles.xml file serves as the scan's signature database. VBR includes a factory-default database, and backup administrators can update this file through online or offline methods.

#### Configuration and Exclusion Methods

Global configuration mirrors the Inline Scan setup. Access the Malware Detection option in VBR's global settings menu, where you'll find the Index Scan section in the second part. By default, this checkbox is selected. Below it, there's an option for automatic online updates of the SuspiciousFiles.xml file. If your VBR server has internet access, this file can be updated automatically. For manual updates, refer to Veeam KB4514.

![Index Scan configuration](https://s21.ax1x.com/2024/04/27/pkPXvfU.png)

After global enablement, each backup job must have the Index function specifically enabled. To exclude particular jobs from scanning, simply disable the Index option in those backup jobs.

![Backup job Index configuration](https://s21.ax1x.com/2024/04/27/pkPjMnA.md.png)

### Malware Event Management

When either scan type triggers an alert, the Malware Detection section in the Inventory interface displays bolded malware attack warnings, listing the affected virtual or physical machines. Results from both scan types are marked with a Suspicious status.

![Malware Detection Inventory](https://s21.ax1x.com/2024/04/27/pkPXqwq.png)

The History section includes a new category of events that details content detected during each backup scan. Selecting any event reveals options in the toolbar or right-click menu to view detailed event information, showing exactly what malicious activity was detected.

![Malware event history](https://s21.ax1x.com/2024/04/27/pkPXbmn.png)

The details section provides comprehensive event logs with specific information about each detected incident.

### Conclusion

That covers the online ransomware detection methods in VBR v12.1. These multi-layered detection capabilities provide robust protection against modern ransomware threats. While I hope you never need to rely on these detection features, having them properly configured and understood can make all the difference when facing sophisticated attacks.

In the next installment of this series, we'll explore additional security features introduced in v12.1. Stay tuned for more deep dives into Veeam's security enhancements.

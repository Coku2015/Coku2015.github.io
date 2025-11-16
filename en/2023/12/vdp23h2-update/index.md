# Veeam's Major H2 2023 Product Line Update


Just yesterday, Veeam officially GA'd the important updates for their entire data protection platform product line in the second half of this year. Almost every product has been updated with a new version. If you're a Veeam power user, when you visit your Veeam homepage at https://my.veeam.com, you'll see a full screen where all products show "New" status - these are all newly available versions released this week for download.

![image-20231207110403710](https://s2.loli.net/2024/04/30/fUvhwKGsALM4TJX.png)

The most important part of this product update is certainly the v12.1 update of the flagship VDP platform. Less than a year after the last major version v12 update, the Veeam R&D team has delivered v12.1, which adds new features second only to a major version update. The most dazzling aspect is this year's super-hot AI large model technology, which has been integrated into backup, recovery, disaster recovery, and even daily operations to enhance the backup system's capabilities. You could say this update makes your data protection platform smarter.

## Major Feature Updates

### Network Security Detection and Discovery

- **Inline Streaming Malware Detection** - During the backup data transmission process, content analysis is performed on the data stream, and it can be compared and analyzed with known historical data stream states to determine the state change of data blocks from unencrypted to encrypted. Using the Veeam-trained AI model built into the product, it distinguishes malicious encryption behaviors and detects malicious attack signals.
- **Suspicious File System Behavior Detection** - Unlike streaming analysis, after data backup is completed, for the backed-up file system, through Index indexing technology, it quickly scans and analyzes known malware extensions, ransomware notices, and malware indicators. This analysis technology can also perform historical backup data comparisons, further analyzing through data activities at different times to achieve suspicious behavior judgment. This technology built by Veeam includes virus definition databases similar to antivirus software vendors and supports online and offline virus database updates.
- **Early Threat Detection** - A completely new Incident API has been opened for integration with third-party EDR tools, including current mainstream NDR, MDR, XDR, etc. Once attack signals are discovered in other systems, these third-party systems can sound the alarm and notify the backup system to "close the door and beat the dog."

### Enhanced Ransomware Incident Recovery Response Capabilities

- **YARA Engine Scanning** - In addition to using antivirus software to scan backup archives, this update also adds the industry-popular YARA engine, which makes scanning malware more convenient and efficient. At the same time, this engine's scanning is smarter, providing 3 different scanning modes.
- **Avoid Secondary Infection** - Based on tracking different events' ransomware behaviors, Veeam has built-in important crawler markers for malicious infections. In the graphical interface, you can clearly see which archives have infection risks and which are safe. During recovery, you can quickly select clean restore points to avoid secondary infection.
- **Event Forwarding Capability** - Integrated standard Syslog service capabilities, which can forward most events to Syslog systems for further response and analysis.

### Ensuring Security and Compliance

- **Four-Eyes Authorization** - Two-person four-eyes, also called A-B role dual authorization, this is a traditional security process in IT. In backup systems, Veeam has also introduced such security management methods. For important operations, A-B roles need to jointly authorize to complete them.
- **KMS Key Management System Integration** - Eliminate the insecurity of manual password management and use key management systems for data encryption and decryption. Veeam supports industry mainstream KMS key management systems for backup data encryption through the standard KMIP 1.4 protocol, avoiding backup data leakage risks.
- **Backup System Security Compliance Monitoring** - Added more than 20 security self-checks. This part is an enhancement of v12 capabilities. The backup system will self-check security and regularly send security reports to customers to ensure the entire security architecture meets requirements and has not been compromised.
- **Veeam Threat Center** - A brand-new center panel display that directly and intuitively displays the 3-2-1-1-0 best practices on the console. Take a look every morning when you come to work, and you'll know whether your data is secure now.

### Other Major Updates

- **Object Storage Backup** - New member of unstructured data backup, especially cloud-native applications, image hosting, intelligent video monitoring systems, static website hosting, and various other object storage usage scenarios. Now the Veeam platform can backup and restore this data.
- **CDP Capability Enhancement** - Both performance and functionality have been greatly improved. Laboratory data shows that a single VBR supports second-level real-time replication of about 7000 VMs, achieving continuous data protection without pressure. And v12.1's CDP also supports Veeam's widely acclaimed regular features such as file-level recovery, application object recovery, and fully automated data lab recovery verification. More importantly, the streaming malware detection system added in v12.1 can also work here. After discovering IO exceptions, it can restore to historical time points with second-level precision, greatly reducing data loss.
- **Veeam AI Assistant** - Built-in large model GPT, this large model is trained based on Veeam's official website operation manuals, specializing in various incomprehensions. If you get the software and don't know how to use it, the first thing is to open the assistant and ask questions.

## Other Updates

Let me talk about some of my favorite small updates.

- **Instant Disk Publishing** - Actually, this is the previous data integration API, which has now become an instant disk recovery that can be directly operated in the graphical interface. This way, any Veeam disk image archive can be directly mounted to any Windows and Linux machines. After mounting, data recovery, data mining, data analysis, and other operations can be performed.
- **Data Lab Lite Version** - A lightweight data lab specifically designed for security scanning and YARA scanning, which can be used even without a virtualization environment.
- **Instant PostgreSQL Database Recovery** - The second version of Veeam Explorer for PostgreSQL, which completes Veeam's signature capability.
- **Linux Agent Deployer** - Deployment gadget that can centrally manage Linux Agents without entering passwords on VBR.
- **Veeam Plugin Adds DB2 Support** - Supports DB2 on both Linux and AIX, and can support complex architectures such as single-node, HADR architecture, IBM PowerHA, TSA, and Pacemaker.
- **Veeam Explorer Adds SAP HANA Support** - Full graphical operation for SAP HANA is here. Backup and recovery can now be easily performed in the VBR console.
- **Enterprise Manager Chinese Version Support** - The console for daily use, Enterprise Manager, is now completely in Chinese version. It can manage, backup, recover, and even provide self-service. Everything that can and cannot be done is here.

## Supported Platform Updates

- Full feature support for VMware vSphere 8.0 U2
- Full feature support for VMware Cloud Director 10.5
- Full feature support for Microsoft Windows 11 23H2 version
- Linux part, full support for Debian 12.1, 12.2, Fedora 39, RHEL 8.9, 9.2 and 9.3, Ubuntu 23.10
- macOS 14 Sonoma support

There are many other updates that I won't list all here. Interested friends can go to the official website to see the detailed [What's New](https://www.veeam.com/veeam_backup_12_1_whats_new_wn.pdf) manual, or you can directly download the trial version to try it out.

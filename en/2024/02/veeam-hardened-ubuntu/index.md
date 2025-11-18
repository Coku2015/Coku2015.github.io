# Further Security Hardening for Ubuntu Systems Used as Veeam Hardened Repositories


After the release of Veeam v12, the official documentation provides [methods for further system security hardening](https://helpcenter.veeam.com/docs/backup/vsphere/hardened_repository_ubuntu_configuring_stig.html?ver=120) after building a Veeam hardened repository based on Ubuntu 20.04, and offers a fully automated configuration script. Therefore, after using my [Configurator](https://github.com/Coku2015/Veeam_Repo_Configurator) to build the Ubuntu repository, you can use this automated configuration script for more secure hardening.

**Since the official script includes some US military compliance configurations that are not suitable for Chinese users, I have modified Veeam's official script and republished it to make it suitable for Chinese users.**

Script download location:

https://github.com/Coku2015/veeam-hardened-repository

**System Requirements:**

- Must be run as root user
- Must be run on a clean installation of Ubuntu 20.04
- Only supports Veeam Backup & Replication v12 and above

**Usage Instructions:**

1. Connect to the Ubuntu 20.04 server via SSH
2. Copy the script content to the server
3. Run the script using the following command:
```bash
sudo bash veeam.harden.sh > output.txt 2>&1
```

Note: If you need more detailed output, simply run the following command:
```bash
sudo bash veeam.harden.sh
```

## Script Hardening Content Overview

UBTU-20-010005 - The Ubuntu operating system must allow users to directly initiate session locking for all connection types.

UBTU-20-010007 - The Ubuntu operating system must enforce a 24-hour/1-day minimum password lifetime. New users' passwords must have a 24-hour/1-day minimum password validity period restriction.

UBTU-20-010008 - The Ubuntu operating system must enforce a 60-day maximum password lifetime restriction. New users' passwords must have a 60-day maximum password validity period restriction.

UBTU-20-010013 - After an inactivity timeout, the Ubuntu operating system must automatically terminate user sessions.

UBTU-20-010014 - The Ubuntu operating system must require users to re-authenticate when elevating privileges or changing roles.

UBTU-20-010016 - The Ubuntu operating system default filesystem permissions must be defined so that all authenticated users can only read and modify their own files.

UBTU-20-010035 - The Ubuntu operating system must use strong authenticators to establish non-local maintenance and diagnostic sessions.

UBTU-20-010036 - The Ubuntu operating system must immediately terminate all network connections associated with SSH traffic after a period of inactivity.

UBTU-20-010037 - The Ubuntu operating system must immediately terminate all network connections associated with SSH traffic at session end or after 10 minutes of inactivity.

UBTU-20-010038 - Before granting any local or remote system connection, the Ubuntu operating system must display the standard mandatory DoD notice and consent banner.

UBTU-20-010043 - The Ubuntu operating system must configure the SSH daemon to use Message Authentication Codes (MAC) that employ FIPS 140-2 approved cryptographic hashes to prevent unauthorized information disclosure and/or detect changes to information during transmission.

UBTU-20-010047 - The Ubuntu operating system must not allow unattended or automatic login via SSH.

UBTU-20-010048 - The Ubuntu operating system must be configured to disable remote X connections unless required to meet documented and validated mission requirements.

UBTU-20-010049 - The Ubuntu operating system SSH daemon must prevent remote hosts from connecting to the proxy display.

UBTU-20-010050 - The Ubuntu operating system must enforce password complexity by requiring at least one uppercase character.

UBTU-20-010051 - The Ubuntu operating system must enforce password complexity by requiring at least one lowercase character.

UBTU-20-010052 - The Ubuntu operating system must enforce password complexity by requiring at least one numeric character.

UBTU-20-010053 - The Ubuntu operating system must require a change of at least 8 characters when changing passwords.

UBTU-20-010054 - The Ubuntu operating system must enforce a minimum password length of at least 15 characters.

UBTU-20-010055 - The Ubuntu operating system must enforce password complexity by requiring at least one special character.

UBTU-20-010056 - The Ubuntu operating system must prohibit the use of dictionary words as passwords.

UBTU-20-010057 - The Ubuntu operating system must be configured so that pwquality is used when changing passwords or establishing new passwords.

UBTU-20-010070 - The Ubuntu operating system must prohibit password reuse for at least five generations.

UBTU-20-010072 - The Ubuntu operating system must automatically lock accounts until an administrator releases the lock after 3 failed login attempts.

UBTU-20-010074 - The Ubuntu operating system must be configured so that scripts that check file integrity run at least every 30 days or less are the default scripts.

UBTU-20-010075 - The Ubuntu operating system must enforce a delay of at least 4 seconds between login prompts following a failed login attempt.

UBTU-20-010100 - The Ubuntu operating system must generate audit records for all account creation, modification, disabling, and termination events affecting /etc/passwd.

UBTU-20-010101 - The Ubuntu operating system must generate audit records for all account creation, modification, disabling, and termination events affecting /etc/group.

UBTU-20-010102 - The Ubuntu operating system must generate audit records for all account creation, modification, disabling, and termination events affecting /etc/shadow.

UBTU-20-010103 - The Ubuntu operating system must generate audit records for all account creation, modification, disabling, and termination events affecting /etc/gshadow.

UBTU-20-010104 - The Ubuntu operating system must generate audit records for all account creation, modification, disabling, and termination events affecting /etc/opasswd.

UBTU-20-010118 - The Ubuntu operating system must shut down by default upon audit failure (unless availability is an overriding concern).

UBTU-20-010122 - The Ubuntu operating system must be configured so that unauthorized users cannot read or write to audit log files.

UBTU-20-010123 - The Ubuntu operating system must be configured to permit only authorized users ownership of audit log files.

UBTU-20-010124 - The Ubuntu operating system must permit only authorized groups ownership of audit log files.

UBTU-20-010128 - The Ubuntu operating system must be configured so that unauthorized users do not have write access to audit log directories.

UBTU-20-010133 - The Ubuntu operating system must be configured so that unauthorized users cannot write to audit configuration files.

UBTU-20-010134 - The Ubuntu operating system must permit only authorized accounts ownership of audit configuration files.

UBTU-20-010135 - The Ubuntu operating system must permit only authorized groups ownership of audit configuration files.

UBTU-20-010136 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the su command.

UBTU-20-010137 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the chfn command.

UBTU-20-010138 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the mount command.

UBTU-20-010139 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the umount command.

UBTU-20-010140 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the ssh-agent command.

UBTU-20-010141 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the ssh-keysign command.

UBTU-20-010142 - The Ubuntu operating system must generate audit records for any use of the setxattr, fsetxattr, lsetxattr, removexattr, fremovexattr, and lremovexattr system calls.

UBTU-20-010148 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the chown, fchown, fchownat, and lchown system calls.

UBTU-20-010152 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the chmod, fchmod, and fchmodat system calls.

UBTU-20-010155 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the creat, open, openat, open_by_handle_at, truncate, and ftruncate system calls.

UBTU-20-010161 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the sudo command.

UBTU-20-010162 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the sudoedit command.

UBTU-20-010163 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the chsh command.

UBTU-20-010164 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the newgrp command.

UBTU-20-010165 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the chcon command.

UBTU-20-010166 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the apparmor_parser command.

UBTU-20-010167 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the setfacl command.

UBTU-20-010168 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the chacl command.

UBTU-20-010169 - The Ubuntu operating system must generate audit records for the use and modification of the tallylog file.

UBTU-20-010170 - The Ubuntu operating system must generate audit records for the use and modification of the faillog file.

UBTU-20-010171 - The Ubuntu operating system must generate audit records for the use and modification of the lastlog file.

UBTU-20-010172 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the passwd command.

UBTU-20-010173 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the unix_update command.

UBTU-20-010174 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the gpasswd command.

UBTU-20-010175 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the chage command.

UBTU-20-010176 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the usermod command.

UBTU-20-010177 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the crontab command.

UBTU-20-010178 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the pam_timestamp_check command.

UBTU-20-010179 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the init_module and finit_module system calls.

UBTU-20-010181 - The Ubuntu operating system must generate audit records for successful/unsuccessful use of the delete_module system call.

UBTU-20-010182 - The Ubuntu operating system must generate audit records and reports that contain information about the time, location, type, source, and results for all auditable events and actions.

UBTU-20-010198 - The Ubuntu operating system must start session auditing at system startup.

UBTU-20-010199 - The Ubuntu operating system must configure the audit tools to be mode 0755 or less permissive.

UBTU-20-010200 - The Ubuntu operating system must configure the audit tools to be owned by root.

UBTU-20-010201 - The Ubuntu operating system must configure the audit tools to be group-owned by root.

UBTU-20-010205 - The Ubuntu operating system must use cryptographic mechanisms to protect the integrity of audit tools.

UBTU-20-010211 - The Ubuntu operating system must prevent all software from executing at higher privilege levels than users executing the software and must configure the audit system to audit the execution of privileged functions.

UBTU-20-010230 - The Ubuntu operating system must record time stamps for audit records that can be mapped to Coordinated Universal Time (UTC) or Greenwich Mean Time (GMT).

UBTU-20-010244 - The Ubuntu operating system must generate audit records for privileged activities, non-local maintenance, diagnostic sessions, and other system-level access.

UBTU-20-010267 - The Ubuntu operating system must generate audit records for any successful/unsuccessful use of the unlink, unlinkat, rename, renameat, and rmdir system calls.

UBTU-20-010277 - The Ubuntu operating system must generate audit records for the /var/log/wtmp file.

UBTU-20-010278 - The Ubuntu operating system must generate audit records for the /var/run/utmp file.

UBTU-20-010279 - The Ubuntu operating system must generate audit records for the /var/log/btmp file.

UBTU-20-010296 - The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to use the modprobe command are made.

UBTU-20-010297 - The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to use the kmod command are made.

UBTU-20-010298 - The Ubuntu operating system must generate audit records when successful/unsuccessful attempts to use the fdisk command are made.

UBTU-20-010400 - The Ubuntu operating system must limit the number of concurrent sessions for all accounts and/or account types to 10.

UBTU-20-010403 - The Ubuntu operating system must monitor remote access methods.

UBTU-20-010404 - The Ubuntu operating system must use FIPS 140-2 approved cryptographic hashing algorithms for encrypting all stored passwords.

UBTU-20-010405 - The Ubuntu operating system must not have the telnet package installed.

UBTU-20-010406 - The Ubuntu operating system must not have the rsh-server package installed.

UBTU-20-010407 - The Ubuntu operating system must be configured to prohibit or restrict the use of functions, ports, protocols, and/or services that are defined as being prohibited or restricted by PPSM CAL and vulnerability assessments.

UBTU-20-010408 - The Ubuntu operating system must prevent direct login to the root account.

UBTU-20-010411 - The Ubuntu operating system must set the sticky bit on all public directories to prevent unauthorized and accidental information transfer through shared system resources.

UBTU-20-010412 - The Ubuntu operating system must be configured to use TCP syncookies.

UBTU-20-010413 - The Ubuntu operating system must disable kernel core dumps to prevent a system from entering a safe state during system initialization failure, shutdown failure, or abort failure.

UBTU-20-010416 - The Ubuntu operating system must generate error messages that provide the information necessary for corrective actions without revealing information that could be exploited by adversaries.

UBTU-20-010417 - The Ubuntu operating system must configure the /var/log directory to be group-owned by syslog.

UBTU-20-010418 - The Ubuntu operating system must configure the /var/log directory to be owned by root.

UBTU-20-010419 - The Ubuntu operating system must configure the /var/log directory to have mode "0755" or less permissive.

UBTU-20-010420 - The Ubuntu operating system must configure the /var/log/syslog file to be group-owned by adm.

UBTU-20-010421 - The Ubuntu operating system must configure the /var/log/syslog file to be owned by syslog.

UBTU-20-010422 - The Ubuntu operating system must configure the /var/log/syslog file using permission mode 0640 or less permissive.

UBTU-20-010423 - The Ubuntu operating system must have directories that contain system commands set to mode 0755 or less permissive.

UBTU-20-010424 - The Ubuntu operating system must have directories that contain system commands owned by root.

UBTU-20-010425 - The Ubuntu operating system must have directories that contain system commands group-owned by root.

UBTU-20-010426 - The Ubuntu operating system library files must have permission mode 0755 or less permissive.

UBTU-20-010427 - The Ubuntu operating system library directories must have permission mode 0755 or less permissive.

UBTU-20-010428 - The Ubuntu operating system library files must be owned by root.

UBTU-20-010429 - The Ubuntu operating system library directories must be owned by root.

UBTU-20-010430 - The Ubuntu operating system library files must be group-owned by root or a system account.

UBTU-20-010431 - The Ubuntu operating system library directories must be group-owned by root.

UBTU-20-010432 - The Ubuntu operating system must be configured to preserve log records from fault events.

UBTU-20-010433 - The Ubuntu operating system must have an application firewall installed to control remote access methods.

UBTU-20-010434 - The Ubuntu operating system must enable and run the Simple Firewall (ufw).

UBTU-20-010438 - The Ubuntu operating system's Advance Package Tool (APT) must be configured to prevent installation of patches, service packs, device drivers, or Ubuntu operating system components without verification that they have been digitally signed using a certificate that is recognized and approved by the organization.

UBTU-20-010439 - The Ubuntu operating system must be configured to use AppArmor.

UBTU-20-010448 - The Ubuntu operating system must implement address space layout randomization to protect its memory from unauthorized code execution.

UBTU-20-010449 - The Ubuntu operating system must be configured so that Advance Package Tool (APT) removes all software components after updated versions have been installed.

UBTU-20-010450 - The Ubuntu operating system must use file integrity tools to verify the correct operation of all security functions.

UBTU-20-010451 - If the baseline configuration is changed in an unauthorized manner, the Ubuntu operating system must notify designated personnel. The file integrity tool must notify system administrators when baseline configuration changes are discovered or when any security function operates abnormally.

UBTU-20-010453 - The Ubuntu operating system must display the date and time of the last successful account login upon login.

UBTU-20-010454 - The Ubuntu operating system must enable the application firewall.

UBTU-20-010456 - The Ubuntu operating system must set system commands to mode 0755 or less permissive.

UBTU-20-010457 - The Ubuntu operating system must have system commands owned by root or a system account.

UBTU-20-010458 - The Ubuntu operating system must have system commands group-owned by root or a system account.

UBTU-20-010460 - The Ubuntu operating system must disable the x86 [Ctrl+Alt+Delete] key combination.

UBTU-20-010462 - The Ubuntu operating system must not have accounts configured with blank or empty passwords.

UBTU-20-010463 - The Ubuntu operating system must not allow accounts configured with blank or empty passwords.

UBTU-20-010461 - The Ubuntu operating system must disable automounting of the Universal Serial Bus (USB) mass storage driver.

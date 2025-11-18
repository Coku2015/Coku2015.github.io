# Hidden Shortcuts in Veeam Backup & Replication v12


There's something special about discovering hidden features in software—the kind that aren't in the release notes but make your daily work so much better. Veeam Backup & Replication v10 introduced some fantastic hidden features, and with the recent v12 release, there are even more gems waiting to be found.

Let me share the hidden shortcuts and features I've uncovered in v12 that could save you hours of frustration.

## Ctrl + Right-Click: Your New Best Friend

### Repair Corrupted VACM Files

Here's a scenario that keeps backup administrators up at night. With v12, almost all your data can be safely stored in Veeam Hardened Repositories (VHR), protected by WORM functionality. But there's a catch: Enterprise Plugins like Oracle RMAN, SAP HANA, and the new SQL Plugins store their backup job metadata (VACM files) outside the hardened repository.

If a malicious actor deletes these VACM files, your backups become inaccessible—a disaster scenario indeed.

The solution? Navigate to your Enterprise Plugin backup archive, hold **Ctrl**, and right-click. You'll see two new menu options appear, including a **Repair** button that rebuilds the missing metadata files for your backup jobs.

![Repair VACM files](https://imgse.com/i/pp6CfN8)

### Remove from Configuration: Now Safely Hidden

Veeam Hardened Repositories provide excellent security—even if attackers compromise your VBR server, they can't use the "Delete from disk" button to wipe your backup archives. However, in v11, there was another button: "Remove from configuration."

This button doesn't delete the actual backup data from your VHR, but it does remove the backup records from VBR's database. While useful for backup operations, it also gave attackers a way to hide your backups from the console.

In v12, Veeam wisely hid this option to prevent accidental misuse. When you genuinely need it, simply hold **Ctrl** and right-click to access it.

![Remove from configuration menu](https://imgse.com/i/pp6CgBt)

### Rebalance Your SOBR Storage

If you've been using Scale-Out Backup Repositories (SOBR) for a while, especially with mixed-capacity extents storing many VMs, you've likely encountered capacity imbalances between your extents. Some drives fill up while others sit mostly empty, creating inefficient storage utilization.

v12 introduces a **Rebalance** feature that evenly distributes backup archives across all your SOBR extents. Like the other hidden features, access it by holding **Ctrl** and right-clicking on your SOBR.

![SOBR Rebalance option](https://imgse.com/i/pp6CWAf)

## New Right-Click Options for Individual VMs

Thanks to the revolutionary per-VM backup chain architecture, v12 brings granular control to your backup operations. In the backup job history, each machine now has its own right-click context menu with two powerful options:

- **Active Full**: Create a full backup for just this VM
- **Retry**: Retry the backup for this specific machine only

Previously, these functions operated on the entire backup job. If you had a job protecting 4 VMs and needed to perform an Active Full, all 4 machines would get full backups simultaneously. Now, you can perform these operations on individual machines, giving you unprecedented control over your backup resources.

![Per-VM context menu](https://imgse.com/i/pp6C2HP)

## Hidden Timestamps for Troubleshooting

This next feature isn't actually new to v12, but it's so useful that it's worth highlighting. In your backup job history, right-click near the Action column to reveal a hidden column showing the start time of every backup step.

This feature is invaluable for troubleshooting, especially when analyzing performance issues. Being able to see exactly when each step began helps you identify bottlenecks and optimize your backup jobs.

![Hidden timestamps in job history](https://imgse.com/i/pp6CcnI)

## Explore and Discover

That's our tour of v12's hidden features. These shortcuts demonstrate Veeam's commitment to both security and usability—hiding potentially dangerous operations while making advanced features accessible when needed.

Download v12 and start exploring these new capabilities. If you discover other hidden gems, drop a comment below and share your findings with the community. Happy backup administrating!


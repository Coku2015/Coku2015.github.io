# 不知勒索病毒的攻击原理，怎知如何防御？


Ransomware seems to be one of those topics that just keeps getting hotter. Remember those service outage images from a year ago when the attacks first exploded? Most of us who weren't hit watched them with that curious "glad it's not me" feeling. I couldn't resist sharing a few in my posts back then—capitalizing on the buzz helped boost my follower count.

At first, I thought this ransomware craze would die down quickly. With security patches rolling out and protection getting stronger, surely these attacks wouldn't last long. But that's not what happened. Instead, ransomware keeps evolving, and this back-and-forth battle between attackers and defenders keeps getting more interesting.

## Ransomware 101

By now, I'm sure we all know what ransomware is. The attack playbook is pretty straightforward:

1. Encrypt everything on the infected system
2. Contact the victim through various channels demanding payment

Typically, my conversations with ransomware victims go something like this:

**Unlucky Admin:** Crap, I got hit! All my files are locked and they want 10 bitcoins. What do I do?

**Stone Brother:** Do you have backups?

**Unlucky Admin:** No!

**Stone Brother:** Well, pay them and hope for the best.

Without backups, what happens next is anyone's guess. Reports from the past couple of years show that less than 25% of people who actually pay the ransom get their data back.

## How Ransomware Has Evolved

Lately, I've been seeing discussions about how modern ransomware has gotten much smarter. These malware programs can now replicate themselves and spread through user environments. They'll also disable mainstream antivirus software, backup tools, firewalls, and databases to make sure they can successfully extort their victims.

Some particularly nasty variants even include destruction capabilities. They'll analyze known backup software catalog systems and wipe out both production data and backup data to maximize their leverage.

In these scenarios, the conversation sounds a bit different:

**Unlucky Admin:** Crap, I got hit! All my files are locked and they want 20 bitcoins. What do I do?

**Stone Brother:** Do you have backups?

**Unlucky Admin:** Yes, but they were too clever. They infected my backup server, disabled all backup jobs after the infection date, and deleted my backup catalog file.

**Stone Brother:** Can you recover any data?

**Unlucky Admin:** The data's sitting on an EMC DataDomain with the latest file locking protocols, so it's pretty secure. But without the catalog, even the safest backup archives are useless for recovery.

**Stone Brother:** Well, guess you'll have to pay up.

Even though they had backup software in place, their protection strategy wasn't sophisticated enough. They didn't consider that ransomware could target the backup infrastructure itself, making their backups essentially worthless.

The images below come from a ransomware sample analysis, showing the various services this malware can disable. Notice how it systematically eliminates anything that might interfere with its destructive operations. You can see all the major antivirus and backup software services on its target list.

![img](https://mmbiz.qlogo.cn/mmbiz_png/FEtXyGtyIU1xTMA9iaLzVXoKicibdVr8APPLLIBuvZibribHvc0q2YicRQKuJ5ic4bBIOAaZPCibJhHk3d2Fw1Mric4UgmA/640?wx_fmt=png)

![img](https://mmbiz.qlogo.cn/mmbiz_jpg/FEtXyGtyIU1xTMA9iaLzVXoKicibdVr8APPUTg5rN3ibc5VtdHHfjEiaV2zHBOBIiaCicK1FicHW0iaRYtj6mHScFjXdxpw/640?wx_fmt=jpeg)

![img](https://mmbiz.qlogo.cn/mmbiz_jpg/FEtXyGtyIU1xTMA9iaLzVXoKicibdVr8APP3AgdslJMkfou3uppJPn1ND7uGYGPLzibmOUJw1ttHwBrTuIK4LllLWA/640?wx_fmt=jpeg)

![img](https://mmbiz.qlogo.cn/mmbiz_jpg/FEtXyGtyIU1xTMA9iaLzVXoKicibdVr8APPAicQO809YgV5FvrdY9UePzHOqruMraUuHbjUeYdDDXO3akafNvs2ojg/640?wx_fmt=jpeg)

## Backup and Disaster Recovery Strategies

Having backups doesn't guarantee peace of mind. When designing backup and disaster recovery architectures, you need to consider several crucial factors:

### 1. Independent and Portable Backup Archives

More and more customers are realizing just how important this is. If your backup archives can't self-recover and completely depend on a catalog created by your backup software, then destroying that catalog is equivalent to destroying everything.

In contrast, environments using Veeam Backup without a centralized catalog have it much easier. Each backup archive is a self-contained entity, meaning ransomware would have to target each file individually to succeed. I'm sure you'd store your most critical data in the safest location to avoid infection.

Let's say the worst happens: your backup server gets infected, and a particularly aggressive ransomware corrupts the disk's MBR records, preventing system boot. Here's what you'd do:

- Clean and restore your environment to ensure the ransomware is completely eliminated
- Install a fresh VBR (Veeam Backup & Replication) server
- Retrieve your previously backed up VBK files from your most secure tapes
- Import them into the new VBR. Veeam can recognize each backup archive's content without needing a centralized catalog database or deduplication database
- Use various recovery methods—exactly like normal Veeam recovery— including Instant VM Recovery and Instant File Recovery

### 2. Secure Isolation of Multiple Backup Copies

When storing data, never rely on synchronization features. This applies to both enterprise and personal data. Take personal cloud storage like Google Drive or OneDrive as an example. The lazy approach is enabling automatic background sync. As soon as data writes to your disk, these tools automatically sync it to the cloud in near real-time.

But what if that data write was initiated by ransomware? Your cloud data would get infected too, rendering all your backup defenses useless.

The same principle applies to enterprise data centers. Storage-level synchronization, even vendors' so-called "byte-level sync" methods, are exactly what ransomware wants—automatic propagation that spreads the attack for them.

That's why I strongly recommend switching from automatic to semi-automatic mode. There's nothing wrong with having the technology, but when necessary, use periodic data replication instead to significantly reduce infection risk.

Storing multiple data copies across different media types is another excellent defense strategy. Since ransomware is automated software that operates with minimal human intervention, breaking the usual data storage patterns can be an effective countermeasure. Of course, this requires backup software flexible enough to support various storage devices.

### 3. Regular Backup Verification and Automated Recovery Testing

Here's another interesting topic: recoverability verification. In backup and disaster recovery environments, this verification typically has to be done manually, consuming significant time and resources. Before ransomware became widespread, this was mostly a formality to satisfy management and regulators—a written report would usually suffice.

But in today's ransomware-dominated landscape, we need to think more seriously. If ransomware destroys my environment, which of my backup archives are clean and can restore a malware-free system?

Fully automated backup verification can save administrators significant time and resources in these scenarios. Veeam Availability Orchestrator 2.0, with its enhanced automated validation logic, excels at this.

## Outsmarting Ransomware

No software is completely free of vulnerabilities, and no software can be fully immune to attacks. I believe the only way to win this prolonged battle against ransomware is to store data more intelligently and continuously verify its integrity.

The cat-and-mouse game continues, but with the right strategies, we can stay one step ahead.


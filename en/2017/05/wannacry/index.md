# A Few Words About the 'WannaCry' Virus


It's been a hectic 72 hours.

From Friday evening through today, my phone hasn't stopped ringing. Friends calling in panic, canceling weekend plans, activating emergency protocols, desperately trying to recover their data. This WannaCry ransomware earned its name—it's left countless unprepared organizations literally wanting to cry.

Whether you paid the ransom or managed to recover your data another way, now that the dust is settling a bit, it's time to step back and think strategically. How do we prevent this from happening again? How do we build truly comprehensive protection that leaves no gaps?

**Let's rewind to before the outbreak.**

Backups! Backups! Backups!

I can't say this enough. When a massive ransomware attack hits, having clean backup data from before the infection makes the difference between a minor inconvenience and a catastrophe. With proper backups, this ransomware becomes relatively trivial to defeat.

But what does "proper backup" actually mean?

First rule: never store backups with production data. This is the cardinal sin of backup strategy. Keeping them together is like putting all your money in one wallet—lose it, and you lose everything. It's the most overlooked basic principle, yet it's the mistake I see most often. And I don't just mean on the same server or storage array. True backup isolation means your backup data should have no direct connection to your production environment whatsoever.

Second: redundancy matters. Multiple backup copies are never a mistake. When you have three or more independent copies of your data, you can face these situations with confidence instead of panic.

Third: test your recovery procedures. If you regularly run drills and verify that every recovery point actually works, when disaster strikes, you'll operate with confidence instead of chaos.

**Now, let's talk about when the outbreak happens.**

Speed is everything. The faster you recover, the better. This is where instant virtual machine recovery becomes your best friend. We're talking about rolling back to a previous save point in under two minutes and getting operations back online. No embarrassing notices on your front door, no frantic customer service calls.

Of course, the reality is more nuanced. Some system-level issues can be resolved with antivirus updates and patches. But for actual file decryption? There's no magic solution—backup software is your only real option. And since not all files are equally critical, you need flexible recovery options.

Instant VM recovery is your blunt instrument—fast and effective. But instant file-level recovery is your surgical tool. This lets you selectively restore the most important files first, getting critical business functions running while you continue recovering less essential data in the background.

**After the crisis: system maintenance.**

Once you've stabilized the immediate emergency, it's time to look at the systems that survived unscathed. Prevention is better than cure, and patches are available. But here's where things get tricky again.

Have you ever applied a Microsoft patch only to see the dreaded blue screen? With thousands of Windows machines requiring patches and reboots, even a 5% failure rate becomes a nightmare. Suddenly you realize the systems that survived WannaCry are being taken down by Microsoft's own fixes.

![1T6qgg.jpg](https://s2.ax1x.com/2020/02/11/1T6qgg.jpg)

Before patching anything, always follow this protocol:

First, create a fresh backup. Ensure you can roll back if things go wrong. This isn't optional—it's mandatory.

Second, test patches in a sandbox environment. Verify they install correctly and don't break system functionality. While you're at it, test whether the patched systems are still vulnerable to the attack vector.

These are the hard-won lessons from the WannaCry outbreak. Learn them now, before the next crisis hits.

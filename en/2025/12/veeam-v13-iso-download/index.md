# Which Veeam V13 ISO Should You Download? 90% Get It Wrong from Step One



Last week, a friend in the group chat shouted out: Downloaded the Veeam V13 ISO, but the upgrade failed.

I asked him: Which one did you download?

He said: The Veeam Data Platform Premium ISO, the 20 GB one.

I sighed.

You fell into the trap.

---

## ⚠️ Core Change: VDP Premium ISO No Longer Works

The changes in V13 caught many people off guard.

Before, when upgrading Veeam, you could use any ISO to upgrade the VBR server.

In V12, a single Veeam Data Platform ISO worked for everything.

**That's no longer the case.**

Starting with V13, **the Veeam Data Platform Premium ISO cannot be used to upgrade VBR.**

Honestly, this change came quite suddenly.

But if you don't know about it, like my friend, and download the 20 GB ISO only to discover it won't work when you're ready to upgrade—that's wasted time.

### V12 vs V13 Comparison

| Version | Usage |
|------|------|
| V12 and earlier | VDP Premium ISO can upgrade VBR ✅ |
| V13 onwards | VDP Premium ISO cannot upgrade VBR ❌ |

---

## Three Types of ISOs, Don't Get Confused

V13 now has three main ISO types, each with completely different purposes.

### 1. VBR ISO (Use This for Upgrades)

**Filename**: `VeeamBackup&Replication_13.0.x.xxxx_[date].iso`

**Size**: 16.9 GB

**Purpose**:
- Upgrade from V12 Windows to V13 Windows VBR
- Fresh installation of Windows version VBR

**Remember**: Want to upgrade VBR? Download this one.

---

### 2. VSA ISO (For New Linux Deployments)

**Filename**: `VeeamSoftwareAppliance_13.0.x.xxxx_[date].iso`

**Size**: 11.8 GB

**Purpose**:
- Deploy Linux-based pre-hardened virtual appliance
- **Only supports fresh deployments, does not support migrating configuration from V12**

**Remember**: Want to use the Linux version of Veeam? You can try it for new environments.

---

### 3. VDP Premium ISO (Complete Platinum Edition)

**Filename**: `VeeamDataPlatform_13.0.x.xxxx_[date].iso`

**Size**: Contains VBR + Veeam ONE + VRO (full suite approximately 20 GB)

**Purpose**:
- Fresh installation of complete Veeam Data Platform environment
- Contains VBR + Veeam ONE + VRO

**The bottom line**: Use for fresh installation of the full suite, don't choose it for upgrading VBR.

---

## Three Common Mistakes

### Mistake 1: Using VDPP ISO to Upgrade VBR ❌

This is the most common one.

The reason is simple: In V12, that's how you did it—download a VDP ISO and upgrade.

When V13 came along, old habits die hard.

The result? Download 19 GB, wait forever, only to find there's no upgrade option in the installer.

**Solution**: Redownload the VBR-specific ISO, the 16.9 GB one.

---

### Mistake 2: Wanting to Use VSA with Socket Licenses ❌

VSA (Linux version) only supports VUL licenses.

If you still have the old Socket licenses and want to use VSA?

Not possible.

**Solution**: Either continue using the Windows version of VBR (supports Socket licenses), or convert to VUL licenses when renewing.

---

### Mistake 3: Ignoring Network Port Changes ❌

V13's network communication protocol has changed.

Previously used Microsoft RPC and Microsoft WMI, now switched to gRPC.

NTLM authentication is also deprecated, switched to Kerberos.

**If you don't check firewall rules**, you might find backup jobs can't connect after the upgrade.

**Solution**: Check the official documentation before upgrading to confirm which ports need to be opened.

---

## Before Downloading, Check These 5 Items

```
□ Current VBR version (V12.x.x recommended to upgrade to latest V12.3.2 first)
□ Operating platform (Windows or Linux)
□ License type (Socket or VUL)
□ Backup configuration database
□ Confirm ISO type (use VBR ISO for VBR upgrades)
```

**Time reminder**: For the 16.9 GB ISO, at 10MB/s network speed, it takes approximately 30 minutes to download.

---

## My Recommendations

Let me share my perspective.

### Don't Rush into VSA

VSA (Linux version) is the highlight of V13—pre-hardened, automatic updates, high security factor.

But there are a few things to note:

1. V13 doesn't support configuration migration, only fresh deployments
2. Some advanced features aren't supported in the web console yet
3. Is your team more familiar with Windows or Linux?

**If your existing VBR is running well**, I recommend:

- Windows users continue with Windows version V13
- Consider VSA for new environments
- Give VSA some time to mature

### Three Specific Recommendations

1. **Test in a Test Environment First**

Don't upgrade directly in production.

Run through the process in a test environment, hit all the potential pitfalls beforehand.

2. **Read Filenames Carefully Before Downloading**

`VeeamBackup&Replication_...` This is the VBR upgrade ISO

`VeeamDataPlatform_...` This is the complete edition ISO

Don't get them mixed up again.

3. **Keep Old ISOs for at Least 1 Year**

Veeam's website typically only provides the latest version for download.

If the upgrade has issues and you need to roll back, or want to deploy a new environment using an older version?

Don't delete the old ones after downloading the new version.

---

## Final Thoughts

V13 is a great version.

Native Linux architecture, web console, security enhancements—all tangible improvements.

But before upgrading, **make sure you download the right ISO**.

This is the first step, and the easiest one to get wrong.

---

**What version of Veeam are you currently running? When do you plan to upgrade to V13?**

Let's chat in the comments.


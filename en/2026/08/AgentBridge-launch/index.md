# Manual Kit Installs Again? I Built AgentBridge


Before v13 came along, installing the Veeam Agent on Windows machines that weren't domain-joined was never a hard problem.

You'd fill a protection group with machine names and an administrator account, and VBR would push the Agent out in bulk. Domain-joined or not, everything could be pushed. For non-domain-joined machines, the worst of it was typing one extra local administrator's username and password.

Then v13's flagship VSA arrived, and that trick suddenly stopped working for non-domain-joined Windows machines.

You'd enter the credentials, hit install, and what came back wasn't a progress bar, it was an error. Dig through the documentation, wander the forums, and everything points to the same answer: first, install a small tool called the Deployment Kit on each machine. Only once it's installed can VBR connect to that machine, and only then can the Agent be pushed.

The Kit itself isn't complicated, and installing it isn't slow. The problem is getting it onto dozens or hundreds of machines. The officially offered paths boil down to running scripts by hand, or already having enterprise distribution tools such as SCCM or Intune.

In an environment without SCCM, you're down to one road: remote desktop in and click through, one machine at a time. With a dozen machines you grit your teeth and get through it. With dozens or hundreds, the experience takes you straight back to the dark ages of manual clicking.

Why did it suddenly stop working? The official word is a security upgrade: the way VSA trusts non-domain-joined machines has changed, and it's moving to certificates. No need to dig into the details, just remember the outcome. The old credential-based push road is closed, and it's not coming back. On the Windows version of v13 that old road still works for now, but VSA is the flagship form of v13, and new environments won't be able to avoid it.

At the end of the day, installing the Kit is repetitive labor, exactly the kind of work that should be handed to a tool. So I wrote the tool. It's called AgentBridge, and today I'm releasing the first version, v0.1.0.

Project URL: [https://github.com/Coku2015/AgentBridge](https://github.com/Coku2015/AgentBridge)



### What Is AgentBridge?

In one sentence: a deployment tool that handles nothing but the Agent's first installation. Making that first connection between a machine and VBR reliable is its only job.

The actual work is three steps: install the Deployment Kit on the target machines, create a certificate-based protection group, and hand things over to VBR. From there, Agent push, upgrades, backup, and recovery all run on VBR's normal tracks.

It comes as a single executable that runs on Windows, Linux, and macOS. No installation, no service to start. Type it once in a terminal, the console opens in your browser, and everything after that happens in the web UI. Close it when you're done and it leaves nothing behind.



### How Does It Bring Push Installation Back?

That Deployment Kit I mentioned earlier is really the new key v13 hands to non-domain-joined machines.

Once the Kit is installed, it establishes a certificate-based trust with VBR: VBR claims the machine through a certificate-based Individual Computers protection group, and everything after that, deploying and managing the Agent, is VBR's own business. This is the road v13 officially designed, not some back-alley trick.

Nothing wrong with the design direction. It's cleaner than the old credential approach. What's been blocking people was never the principle; it was the step of getting the Kit installed at scale.

That step is exactly what AgentBridge does. On Windows it works over SMB 3 and Scheduled Task RPC: it first pre-checks that TCP/445 is reachable, that the ADMIN$ administrative share exists, and that remote Scheduled Tasks work. Then it uploads the Kit to a random temporary directory and remotely executes the official installation script. Installing alone doesn't count as done: it confirms the VeeamDeploySvc service is running and TCP/6160 is reachable before it calls the machine a success, and finally it cleans up the temporary files.

Through the whole process, you enter an administrator username and password exactly once, in the browser.

By the way: it doesn't bypass permissions. Whatever administrator rights are required on the target machine are still required. It just runs the errands for you; it doesn't bend the rules for you.



### Why AgentBridge?

**Get back the feel of "enter an account, hit push."** That's the reason it exists. Add non-domain-joined Windows machines one by one, fill in an administrator account, and AgentBridge installs and verifies the Kit remotely while you sit at your own computer the entire time. What was effortless in the v12 era should stay effortless in v13.

**Passwords are used once and never stored.** Under the old way, push required storing a batch of local administrator credentials in VBR, and every security audit came around asking about them. With AgentBridge, the username and password exist in memory only for the moment of installation; they're cleared when the task ends, never written to disk, never written to logs. What's left in VBR is a single certificate-based protection group. When the audit comes asking again, you're standing on solid ground.

**No need to scrape together an SCCM just for this.** The Kit and the Linux Agent installation packages are exported directly from your own VBR, so the version always matches the server. No extra distribution server, no enterprise-grade tooling. A single executable gets the whole job done.

**For machines that resist the push, send a command over instead.** Some environments run a tight network: administrative shares disabled, Remote UAC in the way, remote paths unreachable. In those cases AgentBridge starts a temporary download service locally and generates a PowerShell command. Send it to whoever is sitting at the machine; copy, paste, press Enter, and the script elevates itself, downloads, verifies, and installs. The download token is single-use and expires in 30 minutes. You never have to remote desktop in yourself.

**Linux gets taken care of in the same pass.** In the same interface, Linux machines go over SSH: AgentBridge recognizes the distribution and architecture automatically, picks the matching package from VBR, and supports all the usual authentication styles, whether root password, passwordless sudo, or sudo password. In the end Windows and Linux land in the same certificate-based protection group, and VBR treats them alike.

**Systems the vendor no longer favors: force-install them.** Veeam dropped official support for systems like CentOS years ago, but in the real world those machines are still running in whole fleets. When AgentBridge meets a distribution the vendor doesn't recognize, it infers the best-matching package from the package format, architecture, and OS version, and lets you force the install. Before it does, it clearly warns that this is an unofficial path and requires you to confirm it yourself; the recommended package also carries an "inferred compatible" label, kept separate from the officially supported paths, so nothing gets mixed up.

**"Installed" and "recognized" are shown separately.** "The Kit is installed on this machine" and "VBR sees it" are two different things, with a protection group and a Rescan in between. AgentBridge lays these two layers of status out separately, so you can see at a glance exactly where things are stuck. Otherwise everything shows green during the install, and only later do you discover VBR never claimed the machines at all, and you're left with nowhere to start troubleshooting. It's an unremarkable detail, and a lifesaver when things actually go wrong.



### The Full Walkthrough: From Bare Machines to VBR Taking Over

Take the most typical scenario: a v13 VSA environment and a batch of non-domain-joined Windows machines.

**Step 1, download and run.** Grab the package for your system from the Releases page; unzip it and there's just one file:

```bash
agentbridge
```

![Snapzy_clipboard_C6B18D4B-C633-4143-BC3F-174D5522804E](https://files.seeusercontent.com/2026/08/17/zC4m/Snapzy_clipboard_C6B18D4B-C633-4.png)

Once it starts, the browser opens the console automatically, and everything else is done with clicks in the web page.

**Step 2, connect to VBR.** You need VBR v13.1. Fill in the address and credentials, click Connect. Then generate the Deployment Kit, with the components exported from your VBR on the spot.

![connect-en](https://files.seeusercontent.com/2026/08/17/u7gV/connect-en.png)

**Step 3, add hosts.** Add the machines one by one, choosing either the Windows or the Linux platform. Enter one-time administrator credentials for each machine, and AgentBridge first runs its pre-checks: TCP/445, ADMIN$, Scheduled Task RPC, each item checked in turn. If Remote UAC blocks the way, it tells you exactly where things got stuck instead of throwing a vague error at you.

![hosts-en](https://files.seeusercontent.com/2026/08/17/mA6m/hosts-en.png)

**Step 4, deploy.** Machines that accept a push get installed remotely; the ones that don't switch to manual mode, and you send that PowerShell command to whoever is sitting at the machine. After installation it automatically verifies the VeeamDeploySvc service and TCP/6160. If the check doesn't pass, it doesn't count as success.

**Step 5, create the protection group.** Select the hosts that are ready, create a certificate-based protection group, and a Rescan fires automatically.

![protection-group-en](https://files.seeusercontent.com/2026/08/17/4Ggv/protection-group-en.png)

**Step 6, wait for VBR to claim them.** Once the Rescan finishes, VBR deploys the Agents to this batch of machines following the protection group's settings. From that moment on, upgrades, backup, and recovery all run on VBR's normal tracks. Its work done, AgentBridge steps out of the way, and you only come back to it when the next new machines arrive.

---



### Project Info

Project URL: **[https://github.com/Coku2015/AgentBridge](https://github.com/Coku2015/AgentBridge)**

If you find it useful, you're welcome to:

- ⭐ Star the project
- Open an Issue to report problems you hit while using it
- Tell me how it behaved in your own environment, especially the various non-domain-joined combinations out there
- Submit a Pull Request

If you run into trouble you can also email me directly: [coku2015@gmail.com](mailto:coku2015@gmail.com). Remember to sanitize error output before sending; leave out passwords, private keys, and Kit contents. It's normal for a first release not to cover every environment. Send it over and I'll get to it as soon as I can.

What's next: more real-world test records from additional environments, better documentation, and adjustments to the deployment flow based on feedback.

---

*v13 closed off an old road. What AgentBridge wants to do is build a smoother new one in its place.*


# Holo VTL Is Now Live


I've been in the backup industry for years, and I keep running into the same problem: you want to test tape backup functionality, but you don't have a real tape library on hand.

Real tape libraries aren't cheap — even an entry-level unit starts at tens of thousands of dollars, and getting one configured is a headache. In lab and test environments, they're practically nonexistent. Most people end up skipping tape-related validation altogether, or worse, running tests against a production tape library — which carries real risk.

Today, I'm officially releasing **Holo VTL** — an open-source virtual tape library that came out of a vibe coding session.

Project repository: [https://github.com/Holo-VTL/Holo](https://github.com/Holo-VTL/Holo)

---

### What Is Holo VTL?

Simply put, Holo VTL is a virtual tape library that runs on an ordinary Linux server.

Once installed, it emulates a complete tape library device on your server — including tape drives, slots, and tape media — and exposes it over the standard iSCSI protocol. When your backup software connects, it sees a real tape library. Discovery, inventory, and data writes all work exactly as expected.

The name Holo comes from "hologram" — the idea that even a fragment can reflect the whole picture.

The first official release is now available: **Holo@v1.0.0**, open-sourced under the MIT License.

---

### What Does It Look Like?

After installation, you can open the web console in your browser:

```
http://<server-ip>/ui/
```

**System Overview**

The home screen is a dashboard showing the current system state — configured virtual tape libraries, number of drives, tape count, storage utilization, and other basic information.

![Xnip2026-05-09_12-58-01](https://files.seeusercontent.com/2026/05/09/uX4c/Xnip2026-05-09_12-58-01.png)

**Storage Management**

The storage management page lets you view and manage virtual tape storage status, including per-tape capacity, compression ratio, and usage.

![Xnip2026-05-09_13-49-28](https://files.seeusercontent.com/2026/05/09/9Qtj/Xnip2026-05-09_13-49-28.png)

**VTL Rack View**

This is personally my favorite page — it displays the current state of the virtual tape library in a visual rack layout, so you can see at a glance which slots have tapes loaded and which drives are active. From this view, you can also simulate exporting tapes to an offline vault.

![Xnip2026-05-09_14-51-55](https://files.seeusercontent.com/2026/05/09/Hwu7/Xnip2026-05-09_14-51-55.png)

The UI is intentionally straightforward. The goal is to let administrators quickly assess system state and handle day-to-day management without living in the command line.

---

### One Command to Install

Holo VTL currently supports major Linux distributions, including RHEL 8/9/10, Rocky Linux, Alma Linux, Ubuntu 20.04/24.04/25.04, Debian 12/13, and openSUSE Leap 15.6.

Online installation (root privileges required):

```bash
curl -fsSL https://raw.githubusercontent.com/Holo-VTL/Holo/main/scripts/install.sh | bash
```

For air-gapped environments, download the installer from the Releases page and run:

```bash
bash install.sh --offline
```

The installation script handles all dependencies automatically — iSCSI target components, TCMU drivers, and systemd service configuration. Once it's done, just open a browser and you're ready to go.

---

### End-to-End Workflow with Veeam

Here's a complete walkthrough using Veeam Backup & Replication as the example.

#### Step 1: Create a Virtual Tape Library in Holo VTL

Open the web console and create a new virtual tape library. You can select the tape library model — Holo VTL ships with 48 built-in tape drive configurations, including IBM LTO series (LTO-3 through LTO-9), HP Ultrium, Quantum, Dell PowerVault, and other major brands, along with 50+ tape library configurations.

If your Tape Server runs Windows, I'd recommend choosing IBM or HP series virtual libraries, since Windows includes native drivers for both brands. Linux-based Tape Servers have no such driver restrictions.

![Xnip2026-05-09_14-52-42](https://files.seeusercontent.com/2026/05/09/gW0z/Xnip2026-05-09_14-52-42.png)

> **Note:** To successfully publish the iSCSI Target, you must complete all virtual tape library configurations first — including the libraries, drives, and tape initialization. Otherwise, the backup server won't be able to properly recognize the virtual devices.

Configuration options include: number of drives, number of slots, initial tape count, and number of I/E ports.

![Xnip2026-05-09_14-54-13](https://files.seeusercontent.com/2026/05/09/s2xN/Xnip2026-05-09_14-54-13.png)

Once created, Holo VTL exposes the virtual device over iSCSI, ready for your backup server to connect. The current published targets are visible directly in the web interface.

![Xnip2026-05-09_14-54-48](https://files.seeusercontent.com/2026/05/09/Hu5j/Xnip2026-05-09_14-54-48.png)

#### Step 2: Connect the iSCSI Target on the Veeam Server

On the Veeam Tape Server, open iSCSI Initiator, add the Holo VTL server's IP address, and connect to the corresponding iSCSI target.

![Xnip2026-05-09_14-04-08](https://files.seeusercontent.com/2026/05/09/9lbH/Xnip2026-05-09_14-04-08.png)

Once connected, you should see the newly added tape devices in Windows Device Manager: a Tape Drive and a Medium Changer.

![Xnip2026-05-09_14-07-55](https://files.seeusercontent.com/2026/05/09/g7Pe/Xnip2026-05-09_14-07-55.png)

#### Step 3: Add Tape Infrastructure in Veeam

Open the Veeam console, navigate to the **Tape Infrastructure** view, and scan the server you added.

If everything is configured correctly, Veeam will detect the virtual tape library provided by Holo VTL.

![Xnip2026-05-09_14-10-51](https://files.seeusercontent.com/2026/05/09/fHm3/Xnip2026-05-09_14-10-51.png)

#### Step 4: Run Inventory

In Veeam's Tape view, run an Inventory operation against the tape library. Veeam will scan all slots and identify the barcode and status of each virtual tape.

![Xnip2026-05-09_14-13-56](https://files.seeusercontent.com/2026/05/09/nz8X/Xnip2026-05-09_14-13-56.png)

#### Step 5: Create a Tape Backup Job

Once Inventory completes, you can create a Tape Backup Job in Veeam to write existing backup data to virtual tape. The workflow is identical to working with a real tape library.

![Xnip2026-05-09_14-15-09](https://files.seeusercontent.com/2026/05/09/Enq3/Xnip2026-05-09_14-15-09.png)

#### Step 6: Review the Results

After the job completes, check the task status in Veeam. You can also return to the Holo VTL web console to see actual tape utilization — capacity changes and data write volumes are both visible there.

![Xnip2026-05-09_14-55-46](https://files.seeusercontent.com/2026/05/09/Iyb8/Xnip2026-05-09_14-55-46.png)

Walking through this entire flow, Veeam is performing a complete backup operation against a virtual tape library — device discovery, inventory, data write, job completion — with no meaningful difference from real hardware.

---

### Use Cases

**Backup software testing.** Want to validate tape functionality in your backup software but don't have physical hardware? That's exactly what Holo VTL is for.

**Learning and lab environments.** If you want to actually understand VTL, iSCSI, tape libraries, Media Pools, and Tape Jobs, a hands-on environment beats reading documentation every time.

**Backup workflow validation.** Test tape rotation strategies, media retention policies, and archival workflows in a virtual environment before rolling them out in production.

**Development and compatibility testing.** If you're building systems that interact with backup, archival, or storage infrastructure, Holo VTL lets you simulate a tape library device for integration testing.

---

### What It Isn't

This is just as important to say clearly.

Holo VTL is not a full backup platform, and it's not a file sync tool. It's a "virtual tape library device" — think of it as the virtual hardware layer in a backup architecture. It provides backup software with a standard tape library device interface. Managing backup policies, scheduling jobs, and handling the business logic of data storage — that's all still your backup software's job.

---

### Troubleshooting Errors

For a first release, running into issues is expected — especially around compatibility between different backup software products and their varying SCSI command sequences. That's hard to cover completely in one go.

If you hit an error in your backup software, here's the recommended process for gathering information before reaching out:

**Step 1: Enable CDB trace.** In the Holo VTL web console, go to the **About** page, find the log setting, and switch to Enable CDB trace mode.

![Xnip2026-05-09_15-04-20](https://files.seeusercontent.com/2026/05/09/r9Cb/Xnip2026-05-09_15-04-20.png)

**Step 2: Reproduce the issue.** With logging enabled, go back to your backup software and re-run the operation that failed — backup or restore — so the error occurs again.

**Step 3: Download the log bundle.** Still on the About page, click the "Download Log Bundle" button. This generates a compressed archive containing complete diagnostic information.

**Step 4: Send it to me.** Email the log bundle to **coku2015@gmail.com** with a brief description: which backup software you're using, what operation you performed, and what error you got. I'll take a look as soon as I can.

---

### Open Source

Holo VTL is open-sourced under the MIT License. Project repository:

**[https://github.com/Holo-VTL/Holo](https://github.com/Holo-VTL/Holo)**

If this project interests you, you're welcome to:

- ⭐ Star the repository
- Submit Issues to report problems
- Test compatibility with your backup software and share the results
- Submit Pull Requests

Going forward, I'll continue refining the web UI experience, adding more detailed configuration documentation, and testing compatibility with additional backup software. Whether you're using Veeam or any other backup solution — if you run into issues, feel free to open a GitHub Issue or leave a comment on the blog.

---

*This is a small project I built with Codex and Claude Code. Holo VTL's first public release — and a starting point. I hope it helps anyone who needs to test and learn tape backup.*


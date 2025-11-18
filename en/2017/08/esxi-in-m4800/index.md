# Transforming HOME LAB: Installing ESXi on M6400


Sometimes the best discoveries happen completely by accident. Last week at VeeamON Shanghai, I stumbled upon something that completely changed my perspective on home lab setups. One of my colleagues casually mentioned he was running ESXi on his laptop, and I was blown away.

Now, I've always assumed installing ESXi on a laptop would be a nightmare of driver hunting and compatibility issues. But here's the game-changing insight: use Dell's customized ESXi ISO. Everything just works out of the box—no driver hunting, no compatibility headaches. The installation process is literally one-click, and you're up and running.

I couldn't wait to try this myself.

But as I started planning my weekend project, I hit a small snag. I still needed Hyper-V for some work, and formatting the internal drives of my Dell M4800 workstation into VMFS seemed like a waste. That's when inspiration struck: I had an old USB 3.0 external drive sitting around. What if I could create a dual-boot setup, keeping Hyper-V on the internal drives while running ESXi from external storage?

A quick Google search confirmed it was totally possible, and I was ready to dive in.

## The Setup

Here's what I was working with:

**Dell M4800 Specs:**
- **CPU:** Intel Core i7-4710MQ @ 2.5GHz
- **Memory:** 32GB DDR3
- **Internal Storage:** Samsung 500GB SSD + Seagate 500GB SATA
- **Network:** Intel i217-LM Gigabit Ethernet

**External Hardware:**
- **Boot Media:** 8GB USB flash drive
- **Storage:** WD 2TB SATA drive connected via USB 3.0 (for VM datastore)
- **Software:** Dell Customized ESXi ISO (available from Dell's support site)

## Installation: Surprisingly Simple

Time to get my hands dirty! I was honestly expecting some complications, but the installation process was incredibly straightforward.

The Dell customized ESXi ISO lived up to its reputation. The installer booted perfectly, detected all my hardware (including that tricky Intel NIC), and completed the entire installation in just five minutes. Seriously—five minutes from USB stick to fully functional ESXi host.

After the basic setup, I configured the network settings, set a hostname, and joined it to my existing vCenter cluster. Everything just worked, exactly as promised.

![17ITHO.png](https://s2.ax1x.com/2020/02/12/17ITHO.png)

## The Real Challenge: USB Datastore Setup

Now for the interesting part—getting that external USB drive working as a datastore. VMware officially doesn't support USB storage for production environments, which makes total sense from a reliability perspective. But for a home lab? This is exactly the kind of flexible setup that makes experimenting so much fun.

**Quick note:** These steps are specifically for ESXi 6.0. Your mileage may vary with other versions.

Here's how I got it working:

### Step 1: Enable SSH and Connect

First things first, I needed SSH access to the ESXi host. Once that was enabled, I could connect and start exploring the storage devices.

### Step 2: Identify the USB Drive

```bash
[root@esxim4800:~] ls /dev/disks
```

In the output, I looked for my USB drive and found these entries:
```
mpx.vmhba38:C0:T0:L0
mpx.vmhba38:C0:T0:L0:1
mpx.vmhba38:C0:T0:L0:2
```

### Step 3: Create the Partition Table

```bash
[root@esxim4800:~] partedUtil mklabel /dev/disks/mpx.vmhba38:C0:T0:L0 gpt
```

### Step 4: Calculate Partition Layout

This was the trickiest part—I needed to calculate the end sector for the VMFS volume:

```bash
[root@esxim4800:~] eval expr $(partedUtil getptbl /dev/disks/mpx.vmhba38:C0:T0:L0 | tail -1 | awk '{print $1 "* " $2 " * " $3}') – 13907024064
```

### Step 5: Create the Partition

```bash
[root@esxim4800:~] partedUtil setptbl /dev/disks/mpx.vmhba38:C0:T0:L0 gpt "12048 3907024064 AA31E02A400F11DB9590000C2911D1B8"
```

### Step 6: Format as VMFS5

```bash
[root@esxim4800:~] vmkfstools -C vmfs5 -S USB-LOCAL /dev/disks/mpx.vmhba38:C0:T0:L0:1
```

And there it was! Back in the vSphere Client, I could see my new "USB-LOCAL" datastore ready to use.

![17IbUe.png](https://s2.ax1x.com/2020/02/12/17IbUe.png)

## The Result: Perfect Dual-Boot Setup

Mission accomplished! My Dell M4800 now has the best of both worlds. When I need to work with Hyper-V, I simply boot from the internal drives into Windows Server 2016. For my VMware home lab adventures, I boot from the USB drive and have a full ESXi environment with 2TB of external storage.

This setup gives me incredible flexibility without sacrificing anything. I can experiment with VMware, run test VMs, and explore virtualization techniques while keeping my work environment completely separate. The external USB storage provides plenty of room for VMs, and because it's all on removable media, I can even take my lab environment with me if needed.

**Would I recommend this approach?** Absolutely—for home lab enthusiasts. It's not something I'd deploy in production, but for learning, testing, and experimentation? It's perfect.

The key takeaway here is that sometimes the most creative solutions come from working within constraints. Don't let conventional thinking limit your home lab possibilities!


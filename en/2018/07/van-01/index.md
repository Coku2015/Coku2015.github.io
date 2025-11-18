# Veeam Availability for Nutanix AHV Configuration and Usage Series (Part 1)


I'm thrilled to share that Veeam Availability for Nutanix AHV (VAN) has finally been released! As someone who works extensively with both Nutanix and Veeam technologies, I've been eagerly anticipating this integration. Today, I want to walk you through everything you need to know to get started with this powerful new tool.

VAN comes as a Proxy Appliance that you can download directly from the Veeam website. Once you extract the ZIP file, you'll find a disk image in VMDK format. Just like other Veeam products, you can grab a 30-day trial license to test everything out before committing.

## Understanding VAN Architecture

Here's where things get interesting. VAN isn't a standalone solution - it's actually an extension of Veeam Backup & Replication (VBR) that brings enterprise-grade data protection to Nutanix AHV environments. Let me break down how everything fits together:

![1jWetU.png](https://s2.ax1x.com/2020/02/14/1jWetU.png)

This means that even if you're running a pure AHV environment, you'll still need a VBR server deployed first. VAN acts as the bridge between your AHV infrastructure and Veeam's proven backup technology. You'll also need a Zero-Socket VBR ENT+ license to unlock all of VAN's capabilities. I won't dive deep into VBR deployment here - the official documentation covers that well - but it's worth mentioning this architectural dependency upfront.

## Getting Started with VAN Deployment

Let's get hands-on with the deployment process. I'll walk you through each step to ensure everything goes smoothly.

### Step 1: Upload the VAN Image to Nutanix

First things first, we need to get the VAN image into your Nutanix environment. Head over to Prism and select "Configure Image."

![1qdra6.png](https://s2.ax1x.com/2020/02/13/1qdra6.png)

### Step 2: Upload the Disk Image

In the configuration dialog, choose "Upload Image" to get started with the import process.

![1qd2xH.png](https://s2.ax1x.com/2020/02/13/1qd2xH.png)

### Step 3: Configure the Image Details

Now it's time to set up your image properly. Give it a descriptive name, add some notes if you'd like, select "Disk" as the image type, choose an appropriate Storage Container, and point to the VMDK file you extracted earlier. Hit Save and let the upload begin.

![1qdWMd.png](https://s2.ax1x.com/2020/02/13/1qdWMd.png)

### Step 4: Verify Image Activation

Patience is key here. The AHV system needs time to upload and initialize the image. Once all background tasks complete, check back in the "Configure Image" dialog - you should see your VeeamProxy image showing as "Active."

![1qdgRe.png](https://s2.ax1x.com/2020/02/13/1qdgRe.png)

### Step 5: Create the VAN Proxy VM

This is where the magic happens! We're going to create the VM that will serve as your data extraction engine in Nutanix. Think of it as the equivalent of a Veeam Proxy in VMware environments, except this one comes pre-packaged as a Linux appliance by Veeam.

The VM creation process is straightforward. I recommend following the official guidelines: 2 vCPU, 2 cores, 4GB RAM, and add a new disk using the image we just uploaded. Don't forget to assign it to the right network for initial access.

![1qd7i8.png](https://s2.ax1x.com/2020/02/13/1qd7i8.png)

![1qccJ1.png](https://s2.ax1x.com/2020/02/13/1qccJ1.png)![1qcso9.png](https://s2.ax1x.com/2020/02/13/1qcso9.png)

### Step 6: Initialize the VAN Proxy

Once your VeeamProxy VM is created, power it on in AHV. After a quick initialization, you'll see the command line prompt with instructions to access the web interface via HTTPS. At this point, your work in Nutanix is essentially done - the rest happens through VAN's web console.

![1qcWQK.png](https://s2.ax1x.com/2020/02/13/1qcWQK.png)

### Step 7: Access the Web Console

Fire up your browser and navigate to the Proxy Appliance address. You'll be greeted with Veeam's signature sleek black interface and green logo. Use the default "Admin" credentials to launch the initial configuration wizard.

![1qcfsO.png](https://s2.ax1x.com/2020/02/13/1qcfsO.png)

### Step 8: Choose Installation Type

On first access, you'll have two options: fresh installation or restore from configuration. Since we're starting from scratch, go with "Fresh Install."

![1qchLD.png](https://s2.ax1x.com/2020/02/13/1qchLD.png)

### Step 9: Accept the License Agreement

Like any enterprise software, you'll need to accept the End User License Agreement. Check the box and continue to the next step.

![1qc5ee.png](https://s2.ax1x.com/2020/02/13/1qc5ee.png)

### Step 10: Set Admin Password

Change the default Admin password to something secure, then move on to network configuration.

![1qcood.png](https://s2.ax1x.com/2020/02/13/1qcood.png)

### Step 11: Configure Network Settings

Set the hostname and IP address for your Proxy appliance. Make sure it's on a network that can communicate with both your VBR server and Nutanix cluster.

![1qc7FA.png](https://s2.ax1x.com/2020/02/13/1qc7FA.png)

### Step 12: Complete Initial Setup

Review your configuration settings and click Finish. The system will reboot once more to apply all the changes.

![1qcHJI.png](https://s2.ax1x.com/2020/02/13/1qcHJI.png)

### Step 13: License the Appliance

When you log back into the web console, you'll be prompted to enter your license. All Nutanix-related licensing is managed directly on the Proxy Appliance, which simplifies things considerably.

![1qcbWt.png](https://s2.ax1x.com/2020/02/13/1qcbWt.png)

### Step 14: Complete Core Configuration

Click the gear icon in the upper right corner to access the main configuration interface. Here you'll need to complete three essential tasks: activate your license, connect to your VBR server, and add your Nutanix cluster.

The interface is clean and intuitive - basic information is all you need to get everything configured.

For licensing, simply import your .lic file just like with other Veeam products.

![1qcOQf.png](https://s2.ax1x.com/2020/02/13/1qcOQf.png)

### Step 15: Connect to VBR Server

Configuring the VBR connection is straightforward - just provide the IP address, default port (9419), and your VBR server credentials.

![1qcXy8.png](https://s2.ax1x.com/2020/02/13/1qcXy8.png)

### Step 16: Add Nutanix Cluster

Finally, add your Nutanix cluster by providing the CVM address along with admin credentials.

![1qcjOS.png](https://s2.ax1x.com/2020/02/13/1qcjOS.png)

## Ready for Action

And that's it! With these configurations complete, your VAN deployment is ready to start protecting VMs in your AHV environment. The setup process might seem involved, but it's quite logical when you break it down step by step.

In the next installment of this series, I'll dive deep into AHV backup and recovery operations, showing you how to leverage VAN's full capabilities for your data protection strategy.

Stay tuned!


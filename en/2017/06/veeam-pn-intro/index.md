# VeeamON 2017 Series: Alternative VPN -- Veeam PN


Sometimes the most exciting announcements at conferences are the ones you never saw coming.

At last month's VeeamON conference, Veeam unveiled something completely unexpected—a product that has nothing to do with backup. They called it Veeam PN (short for Veeam Powered Network), and it's a lightweight SDN solution that quickly connects multiple sites for both site-to-site and endpoint-to-site communication.

Rather than attempting a comprehensive review (you can dive deeper in Veeam KB2271 and the official help manual), I want to share how I'm using it in my home lab.

## The Remote Access Challenge

My need is pretty straightforward: when I'm away from home, I want to connect to my home lab from anywhere and get work done.

Sure, most VPN solutions can handle this, but they often require complex setups with varying methods depending on your environment. What caught my attention about Veeam PN is how simple it makes the whole process—we're talking a few minutes and a few clicks to get everything running.

## Understanding the Architecture

Veeam PN runs on three core components that work together:

**1. Veeam Hub**
This serves as the central access point and single entry point for managing all endpoints. You can deploy it anywhere with internet access—on-premises or in the cloud—as long as it can communicate with other sites over the WAN and has a public IP address.

**2. Veeam Site Gateway**
Each site gets its own gateway that connects back to the Hub. Think of each subnet as requiring its own Site Gateway. These just need internet access—no public IP required.

**3. VPN Client**
End users connect using any OpenVPN-compatible client, giving you plenty of options across all platforms.

![1TMJfS.png](https://s2.ax1x.com/2020/02/11/1TMJfS.png)

For my home lab setup, I'm running a single network segment (10.100.1.0/24), so I just need one Hub and one Site Gateway. The best part? Both components come from the same OVA file—you just choose different deployment modes for each.

## Getting Started: Deployment

The deployment process is refreshingly simple. In your vSphere Client, deploy the OVA just like any other virtual appliance. Once imported, you'll configure the IP address and hostname within the Ubuntu system.

![1TQsHI.png](https://s2.ax1x.com/2020/02/11/1TQsHI.png)

Since I'm running both Hub and Site Gateway at home, I deployed two VMs from the same OVA—one for each role:

![1TQ6Et.png](https://s2.ax1x.com/2020/02/11/1TQ6Et.png)

## Configuring the Hub

Access the Hub's web interface (mine is at https://10.100.1.40/) using the default credentials:

Username: root
Password: VeeamPN

![1TQwge.png](https://s2.ax1x.com/2020/02/11/1TQwge.png)

You'll be prompted to change the password and select the Hub role during initialization:

![1TQg4f.png](https://s2.ax1x.com/2020/02/11/1TQg4f.png)

The setup wizard walks you through basic configuration. Fill in your details, keep the default 2048-bit encryption, and configure your public IP or DNS:

![1TQrDA.png](https://s2.ax1x.com/2020/02/11/1TQrDA.png)

![1TQRC8.png](https://s2.ax1x.com/2020/02/11/1TQRC8.png)

I used my external DDNS domain name for the public address. Click Finish, and your Hub is ready.

## Adding Sites and Clients

Now for the fun part—adding your infrastructure. Click "Clients" and then "Add" to launch the wizard:

![1TMQeI.png](https://s2.ax1x.com/2020/02/11/1TMQeI.png)

You have two options: "Entire Site" (for a Site Gateway) or "Standalone Computer" (for individual remote access):

![1TMuyd.png](https://s2.ax1x.com/2020/02/11/1TMuyd.png)

Let's add our site first. Choose "Entire Site" and proceed:

![1TM8Ff.png](https://s2.ax1x.com/2020/02/11/1TM8Ff.png)

Give it a descriptive name and specify your subnet (mine is 10.100.1.0/24):

![1TMnQH.png](https://s2.ax1x.com/2020/02/11/1TMnQH.png)

After clicking Finish, the Hub automatically downloads an XML file—hold onto this, as you'll need it for the Site Gateway configuration.

Next, repeat the process to add a client access point:

![1TMlwt.png](https://s2.ax1x.com/2020/02/11/1TMlwt.png)

This just needs a name for identification. After completing the wizard, your browser downloads an .ovpn file that you can use with any OpenVPN client.

## Configuring the Site Gateway

Access your Site Gateway's web interface and go through the same password change and initialization process—this time, select "Site Gateway" instead of "Network Hub":

![1TQg4f.png](https://s2.ax1x.com/2020/02/11/1TQg4f.png)

Import the XML file you downloaded from the Hub, click Finish, and your Site Gateway will automatically connect to the Hub:

![1TQcUP.png](https://s2.ax1x.com/2020/02/11/1TQcUP.png)

## Final Step: Client Setup

For client access, you can use any OpenVPN-compatible client across all operating systems and mobile devices. I'm using Windows with the standard OpenVPN client (**openvpn-install-2.4.2-I601.exe**).

The installation is straightforward—run through the installer, then import the .ovpn file you downloaded earlier. The connection process works exactly like standard OpenVPN, requiring no additional credentials.

## The Result

That's it. From anywhere in the world, I can now securely connect to my home lab and access all my resources as if I were sitting at my desk.

What impresses me most about Veeam PN is its simplicity. While traditional VPN solutions often require complex networking knowledge and lengthy configuration processes, Veeam PN abstracts away the complexity while maintaining enterprise-grade security and functionality.

If you're looking for a straightforward way to connect distributed environments—whether for home labs, branch offices, or cloud connectivity—Veeam PN deserves a serious look. Sometimes the best solutions are the ones that just work, right out of the box.

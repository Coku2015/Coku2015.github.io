# Secure Restore | Making Malware Detection Truly Comprehensive


Here's a fundamental truth about IT infrastructure: security and backup are your two essential pillars. Whether you're running a home setup or enterprise systems, you need both. But here's where things get interesting—antivirus software faces an impossible battle. It's constantly chasing new malware variants, dealing with sophisticated evasion techniques, and sometimes even fighting back against viruses designed to disable the antivirus itself.

The traditional approach of installing antivirus on every individual OS has serious limitations. It's resource-intensive, easily compromised, and frankly, not enough in today's threat landscape. Virtualization helped by moving antivirus engines into the hypervisor layer, avoiding many of the problems with agent-based installations.

But we still face a critical challenge: no single antivirus catches everything. Even the best solutions need constant signature updates, and there are always some threats that slip through the cracks. According to AV-Test, there are dozens of antivirus solutions on the market, each with different strengths and varying detection rates across versions.

![3SXn00.jpg](https://s2.ax1x.com/2020/02/16/3SXn00.jpg)

The other day, while designing a distributed backup architecture, I had an insight about Veeam's Mount Server functionality. What if we could leverage different Mount Servers, each running a different antivirus engine? This would create a multi-layered defense system where we could choose specific scanning engines during Secure Restore operations.

It's a simple but powerful idea: use Veeam's infrastructure to orchestrate comprehensive malware detection across multiple antivirus platforms.

## Making It Work

### Setting Up Your Mount Servers

In Veeam Backup & Replication, Mount Servers are straightforward components. Basically, you need a Windows Server that's managed as a Veeam server. The real requirement is network connectivity—your Mount Server needs to talk to both the VBR server and your backup repositories. For the specific port requirements, check the official documentation.

https://helpcenter.veeam.com/docs/backup/vsphere/used_ports.html?ver=95u4#mount

Once you're in the VBR console, navigate to Backup Infrastructure → Managed Servers and add your Windows Server.

![3SXOEV.png](https://s2.ax1x.com/2020/02/16/3SXOEV.png)

The process follows Veeam's familiar wizard pattern:

1. **Server Details**: Enter the FQDN or IP address of your Mount Server. Pro tip: use the description field to note which antivirus engine this server runs—it'll make identification much easier later.
   ![3SXj4U.png](https://s2.ax1x.com/2020/02/16/3SXj4U.png)
2. **Credentials**: Provide administrator credentials for Veeam to push and install the Mount Server components.
   ![3SjSgJ.png](https://s2.ax1x.com/2020/02/16/3SjSgJ.png)
3. **Installation Preview**: Review the components to be installed and complete the setup.

   ![3SXxCF.png](https://s2.ax1x.com/2020/02/16/3SXxCF.png)

### Assigning Mount Servers to Repositories

Each backup repository can be assigned a specific Mount Server. This is where the magic happens—when you need a particular antivirus engine, simply edit your repository settings and select the corresponding Mount Server.

![3SXz34.png](https://s2.ax1x.com/2020/02/16/3SXz34.png)

From there, it's business as usual. Run any recovery operation that supports Secure Restore, and Veeam will automatically use the antivirus engine associated with your chosen Mount Server.

That's the complete solution. Not overly complex, but incredibly effective for administrators dealing with malware challenges. By leveraging Veeam's infrastructure this way, you gain the flexibility to apply multiple antivirus engines where they matter most—during the recovery process.



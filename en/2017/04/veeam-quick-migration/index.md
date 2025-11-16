# Veeam's Quick Migration Technology


While vSphere and Hyper-V each offer their own migration technologies, Veeam brings a different perspective to the table. As a data protection platform, Veeam offers IT administrators another approach to VM migration through what's commonly known as Quick Migration.

If you've worked with Veeam before, you might recognize Quick Migration as an option during Instant VM Recovery. It's an optional step in the recovery process that becomes particularly useful when you need to move data from backup storage to production storage.

Think about those scenarios where you don't have VMware Enterprise Plus licensing for Storage vMotion, or perhaps vCenter is unavailable during recovery and you're working with just a single ESXi host. In these situations, Quick Migration shines as an excellent alternative. Yes, it comes with a bit more downtime than Storage vMotion, but you gain much broader compatibility – making it a fantastic complementary tool to have in your arsenal.

But that's just scratching the surface. Quick Migration offers far more capabilities than you might initially expect.

### Cross-vCenter and Cross-Datacenter Migration

Anyone who's tackled VM migration across different vCenters or datacenters knows it typically involves complex manual procedures or expensive enterprise solutions. Veeam changes this equation entirely.

With Quick Migration, what was once a daunting task becomes remarkably straightforward. As long as you have a suitable proxy server available, Veeam can handle these cross-boundary migrations seamlessly. The best part? This isn't a backup-dependent operation. Veeam can migrate VMs directly without requiring prior backup or replication jobs as prerequisites.

The process is refreshingly simple – just navigate to the Veeam console, click the Quick Migration button, and follow the wizard. During migration, Veeam handles the essentials like Thin/Thick provisioning conversions and disk redirection automatically.

![1TwZMq.jpg](https://s2.ax1x.com/2020/02/11/1TwZMq.jpg)

### LAN-free Migration

Yes, you read that right – LAN-free VM migration is possible with Veeam. Quick Migration can be configured to work completely outside your regular network infrastructure when you set up your proxy servers strategically.

By leveraging Direct SAN Access technology, Quick Migration can use either Fiber Channel or Direct NFS connections. This approach completely bypasses potential VMKernel bandwidth bottlenecks, giving you precise control over data flow. For large VM migrations where network bandwidth becomes a critical concern, this capability can be a real game-changer.

Of course, you could potentially achieve similar results with other tools and methods, but Veeam's Quick Migration gives us another powerful option in our virtualization toolkit. Having multiple approaches to tackle the daily challenges of virtualized data management means we can always choose the right tool for the job.

Sometimes the best solutions aren't the most expensive or complex ones – they're the ones that work reliably in your specific environment. Quick Migration exemplifies this philosophy perfectly.


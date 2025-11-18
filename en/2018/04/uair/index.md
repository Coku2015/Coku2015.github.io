# Recovering MySQL Database with Veeam U-Air


One question I get asked frequently is whether Veeam supports application-level recovery for specific databases. The interesting thing about this question is that the answer has nothing to do with which database you're using — it's always yes.

That's because Veeam includes a powerful feature called U-AIR (Universal Application-Item Recovery) that makes application-level recovery possible for virtually any system.

Today, I want to walk you through a practical MySQL recovery scenario to show you how this works in practice.

## Setting Up Our Scenario

For this example, I'm working with a MySQL 5.1.7 installation running on CentOS. The database is backed up using Veeam Backup & Replication with pre-freeze and post-freeze scripts to ensure data consistency.

If you need details on setting up those consistency scripts, Veeam has excellent documentation:

https://www.veeam.com/wp-consistent-protection-mysql-mariadb.html

Here's what our test data looks like in the source database:

![1blj8P.png](https://s2.ax1x.com/2020/02/12/1blj8P.png)

Now, let's create our recovery scenario. After taking a backup of this MySQL server, something goes wrong and the `veeamlab` database becomes corrupted. Our goal is to recover this specific database while leaving the rest of the server running normally.

I'll create a new empty database called `veeamlab_recovered` to serve as our recovery target, while the original MySQL server continues operating normally:

![1blvgf.png](https://s2.ax1x.com/2020/02/12/1blvgf.png)

## Starting the Recovery Process

The recovery begins with the Universal Lab Request Wizard. This is where we request access to a backup copy for recovery purposes. The process is straightforward:

![1blxv8.png](https://s2.ax1x.com/2020/02/12/1blxv8.png)

First, specify the VM name. Veeam supports pattern matching, so you don't need the exact name:

![1b1PEj.png](https://s2.ax1x.com/2020/02/12/1b1PEj.png)

Select the most recent restore point:

![1b1iUs.png](https://s2.ax1x.com/2020/02/12/1b1iUs.png)

Submit the request:

![1b1ACq.png](https://s2.ax1x.com/2020/02/12/1b1ACq.png)

Now the U-AIR request is in the system, awaiting approval from the backup administrator.

## The Administrator Approval Process

Switching over to the backup administrator view in Veeam Enterprise Manager, we can see the pending recovery request:

![1b1mKU.png](https://s2.ax1x.com/2020/02/12/1b1mKU.png)

The approval process leverages Veeam's SureBackup and Virtual Lab capabilities. If you're not familiar with these technologies, I covered them in a previous post about verifying backup recoverability.

During approval, Veeam automatically locates the appropriate backup:

![1b1V2V.png](https://s2.ax1x.com/2020/02/12/1b1V2V.png)

![1b1ZvT.png](https://s2.ax1x.com/2020/02/12/1b1ZvT.png)

Then it selects the right Virtual Lab and SureBackup Job to create a temporary recovery environment:

![1qniF0.png](https://s2.ax1x.com/2020/02/13/1qniF0.png)

![1qn9wn.png](https://s2.ax1x.com/2020/02/13/1qn9wn.png)

Once approved, the database administrator receives connection details for the temporary recovery environment after a brief wait:

![1qnFYV.png](https://s2.ax1x.com/2020/02/13/1qnFYV.png)

## Extracting and Recovering the Data

Now for the interesting part. I can SSH into the recovery environment at 172.20.1.139, while my production MySQL server at 10.10.1.139 continues running normally.

Let's verify the database state in our temporary environment:

![1qnVlF.png](https://s2.ax1x.com/2020/02/13/1qnVlF.png)

![1qnZy4.png](https://s2.ax1x.com/2020/02/13/1qnZy4.png)

Perfect — the data looks intact. Now I need to extract the corrupted database and transfer it back to our production server. I'll use mysqldump for the extraction:

![1qneOJ.png](https://s2.ax1x.com/2020/02/13/1qneOJ.png)

The extracted data is saved to `/tmp/mysql/veeamlab.sql`.

Back on our production server (10.10.1.139), I've configured Virtual Lab's Static IP Mapping to make the recovery environment accessible at 10.10.1.138. This allows me to pull the dump file directly:

![1qnnm9.png](https://s2.ax1x.com/2020/02/13/1qnnm9.png)

The restore command itself is beautifully simple:

![1qnuwR.png](https://s2.ax1x.com/2020/02/13/1qnuwR.png)

## Wrapping Up

And that's it — our MySQL database recovery is complete. All the data from our corrupted `veeamlab` database is now safely restored in `veeamlab_recovered`.

The temporary U-AIR environment can be terminated manually by the database administrator or will automatically clean up when its time limit expires.

## Why This Matters

What makes this approach powerful is its flexibility. The only prerequisite is using Veeam Backup & Replication — beyond that, U-AIR gives you the ability to recover **any** application data with the same level of control and precision I've demonstrated here.

Whether you're dealing with databases, email servers, or custom applications, the U-AIR workflow provides a safe, isolated environment for recovery without impacting your production systems.

That's the beauty of Veeam's approach to application recovery — it's comprehensive, it's reliable, and it works with virtually any application you can throw at it.

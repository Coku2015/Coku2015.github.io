# How to Calculate Backup Size and Bandwidth in Data Centers


One of the most common questions I get asked is: "How effective is your backup software's deduplication, and how much storage space will my backups actually use?"

The truth is, effectiveness varies dramatically depending on your data types and storage methods. Different environments and hardware configurations can produce vastly different results, making it impossible to give a one-size-fits-all answer. But regardless of these variables, backup data needs storage space, and capacity planning becomes a critical component of any backup infrastructure design.

Getting your storage capacity and bandwidth calculations right directly impacts project success, affecting storage costs, efficiency, and overall backup reliability. Let me walk you through the calculation process using a typical virtualized environment as our example.

## Our Example Environment

- **ESXi Hosts**: 25 servers
- **Virtual Machines**: 500 VMs
- **Average VM disk capacity**: 200GB
- **Total datastore usage**: 100TB

## Calculating Bandwidth Requirements

Backup operations typically follow a pattern: an initial full backup followed by regular incremental backups. The first backup transfers all your virtual environment data to the backup storage, essentially moving your entire datastore usage. Subsequent backups only transfer what has changed since the last backup—typically daily changes in most environments.

The daily change rate in your environment can be accurately obtained from Veeam ONE's change assessment report. For our example, let's assume a conservative 7% daily change rate.

Here's what we're working with:

- **Initial full backup**: 100TB
- **Daily incremental backup**: 7TB

Now, let's factor in Veeam's built-in compression and deduplication. Assuming typical deduplication efficiency reduces our data by 50%, we get:

- **Actual initial transfer**: 50TB
- **Actual daily transfer**: 3.5TB

### The Bandwidth Math

For our bandwidth calculations, let's make some practical assumptions about backup windows:

- Initial full backup: Can run continuously for 24 hours (we'll schedule this for Saturday)
- Daily incremental backups: Run during off-peak hours (8 PM to 6 AM)
- Only 80% of the backup window is actual data transfer (the rest is job setup and overhead)

This gives us:
- **Full backup window**: 24 hours × 80% = 19.2 hours of actual transfer time
- **Incremental backup window**: 10 hours × 80% = 8 hours of actual transfer time

Now for the calculations:

**Full backup bandwidth requirement:**
```
50TB × 1024GB/TB × 8bits/byte ÷ (24hrs × 3600sec/hr × 0.8) = 5.93 Gbps
```

**Incremental backup bandwidth requirement:**
```
3.5TB × 1024GB/TB × 8bits/byte ÷ (10hrs × 3600sec/hr × 0.8) = 1.0 Gbps
```

With these numbers, you can now plan your network and storage throughput accordingly, configuring the right number of network cards or HBAs to achieve these transfer rates.

## Planning Storage Capacity

Storage capacity planning becomes straightforward when you understand your backup retention strategy. Let's work with a common scenario: keeping at least 14 backup points, with weekly full backups and daily incrementals.

Here's what our two-week retention cycle looks like:

| Day | Backup Type | Size |
|-----|-------------|------|
| 1   | Full Backup | 50 TB |
| 2   | Incremental | 3.5 TB |
| 3   | Incremental | 3.5 TB |
| 4   | Incremental | 3.5 TB |
| 5   | Incremental | 3.5 TB |
| 6   | Incremental | 3.5 TB |
| 7   | Incremental | 3.5 TB |
| 8   | Full Backup | 50 TB |
| 9   | Incremental | 3.5 TB |
| 10  | Incremental | 3.5 TB |
| 11  | Incremental | 3.5 TB |
| 12  | Incremental | 3.5 TB |
| 13  | Incremental | 3.5 TB |
| 14  | Incremental | 3.5 TB |

**Capacity calculations:**
- **Raw backup data**: 209.5 TB
- **15% buffer space**: 31.4 TB
- **Total recommended capacity**: 240.9 TB

## A Better Way to Plan

While these manual calculations give you a solid foundation, I highly recommend checking out the Veeam Backup Repository Capacity Planning Tool created by my international colleagues. This web-based tool offers more comprehensive calculations with additional variables you can customize for your specific environment.

You can access it at: http://vee.am/rps

The tool provides a more detailed analysis and can help you fine-tune your capacity planning based on your unique requirements and constraints.

---

*Capacity planning might seem complex, but getting it right from the start saves countless headaches down the road. Whether you're planning a new deployment or optimizing an existing one, taking the time to do the math properly ensures your backup infrastructure will be ready when you need it most.*

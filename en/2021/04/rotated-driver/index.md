# “Wildcard” Strategy – Rotating External Drives for Ransomware Defense


You’ve seen all the v11 ransomware-hardening tips—but attackers keep innovating, so we can’t stop. Here’s an unconventional approach: rotate offline external drives. It’s basically a DIY air gap. Not bulletproof, but a handy “wildcard” for environments that can’t invest in tape or immutable storage yet.

## Requirements & Scenario

- A hot-swap external enclosure (USB 3.0/USB-C or eSATA) for quick drive swaps.  
- Multiple high-capacity SATA disks (7200 RPM).  
- A rotation schedule: write backups to one drive, then eject and store it offline while another drive comes online.

## Expected Outcome

- As long as the data isn’t encrypted before ejection, it’s safe once offline.  
- Each drive’s backup chain is self-contained; no dependency on other drives.  
- VBR writes its own metadata alongside the backups, so restores are easy when you plug the drive back in.  
- Compared to tape, recovery is straightforward—just mount the drive and start restoring.

## How to Use It

Watch the demo video below for the workflow.

> *(Insert video link/description as in the original post.)*

This trick works with Veeam Backup & Replication, Veeam Agent for Windows, and Veeam Agent for Linux. Download Community Edition, set up a rotation, and give your backup plan one more layer of resilience.


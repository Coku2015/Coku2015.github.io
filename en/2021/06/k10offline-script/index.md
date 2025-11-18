# Kasten K10 Starter Series 04 – Offline Image Download Script


## Series Index

- [Part 1 – Single-Node Lab](https://blog.backupnext.cloud/2020/12/Setting-up-quick-demo-for-K10-01/)  
- [Part 2 – Install K10](https://blog.backupnext.cloud/2021/05/K10-setup/)  
- [Part 3 – Backup & Restore](https://blog.backupnext.cloud/2021/05/K10-configuration/)

## Why This Script Exists

Downloading K10 can be painful—especially if you’re used to Veeam’s tidy installers. Kasten’s docs describe deployment, but there’s no simple download link. Everything lives under `gcr.io`, which is unreachable from many regions. Kasten suggests the JFrog Artifactory mirror for online installs, but it doesn’t integrate with the official offline script.

To solve this, I wrote a helper script that pulls from a non-`gcr.io` mirror and pushes to your private registry.

Official “air-gap” instructions for reference: <https://docs.kasten.io/latest/install/offline.html#preparing-k10-container-images-for-air-gapped-use>

## Prerequisites

Run the script on Linux with:

- Network access to the **source** mirror (defaults to JFrog; customize inside the script if needed).  
- Network access to your **target** private registry.  
- `jq` installed (<https://stedolan.github.io/jq/>)  
- `docker` installed (<https://docs.docker.com/get-started/>)

## Usage

Download the script:

```bash
curl -O https://blog.backupnext.cloud/k10offline.sh
```

Review the contents to ensure they’re safe, then make it executable:

```bash
chmod +x k10offline.sh
```

Run it with:

```bash
./k10offline.sh <k10-version> <target-registry>
```

Example (K10 v4.0.3, pushing to `private.target.repo/kasten`):

```bash
./k10offline.sh 4.0.3 private.target.repo/kasten
```

The script pulls all required images and uploads them to your registry. When installing K10, point Helm to that repo:

```bash
helm install k10 k10-4.0.3.tgz \
  --namespace kasten-io \
  --set global.airgapped.repository=private.target.repo/kasten
```

Enjoy smoother offline installs!***


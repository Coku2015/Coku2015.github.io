# Kasten K10 Starter Series 05 - K10 Installation Package Download (2)


## Kasten K10 Starter Series Table of Contents

[Kasten K10 Starter Series 01 - Quick Setup of K8S Single-Node Test Environment](https://blog.backupnext.cloud/2020/12/Setting-up-quick-demo-for-K10-01/)

[Kasten K10 Starter Series 02 - K10 Installation](https://blog.backupnext.cloud/2021/05/K10-setup/)

[Kasten K10 Starter Series 03 - K10 Backup and Recovery](https://blog.backupnext.cloud/2021/05/K10-configuration/)

[Kasten K10 Starter Series 04 - K10 Installation Package Download](https://blog.backupnext.cloud/2021/06/K10offline-script/)

## Main Content

In the previous article, we introduced downloading and pushing K10 installation images to a private image repository through scripts. Today, I want to share some offline image packages, which may be the most convenient method in completely offline environments without external network access.

First, here's the download link:

https://cloud.189.cn/web/share?code=zIVZ3uaIzUr2 (Access code: 8fbw)

## Content Description

In this download link, K10 installation packages are placed in folders named by version number. Inside each version folder, two files are included:

- kasten_k10_offline_images_<version>.tar.gz : Image package
- k10_<version>.json : Configuration file for pushing to private image repository

This image package contains all K10 installation images (version 4.0.8, other versions may vary slightly):

| Original Repository       | Image Name   |
| -------------------- | -------- |
| ghcr.io/kanisterio | kanister-tools |
| quay.io/datawire | ambassador |
| quay.io/prometheus | prometheus |
| jimmidyson | configmap-reload |
| quay.io/dexidp | dex |
| gcr.io/kasten-images | frontend |
| gcr.io/kasten-images | kanister |
| gcr.io/kasten-images | aggregatedapis |
| gcr.io/kasten-images | config |
| gcr.io/kasten-images | auth |
| gcr.io/kasten-images | bloblifecyclemanager |
| gcr.io/kasten-images | catalog |
| gcr.io/kasten-images | crypto |
| gcr.io/kasten-images | dashboardbff |
| gcr.io/kasten-images | executor |
| gcr.io/kasten-images | jobs |
| gcr.io/kasten-images | logging |
| gcr.io/kasten-images | metering |
| gcr.io/kasten-images | state |
| gcr.io/kasten-images | upgrade |
| gcr.io/kasten-images | cephtool |
| gcr.io/kasten-images | datamover |
| gcr.io/kasten-images | k10tools |
| gcr.io/kasten-images | restorectl |
| gcr.io/kasten-images | k10offline |

## Prerequisites

Similar to using the script in the previous article, you need to prepare a Linux server with the following requirements:

- Ability to access the `<target>` image repository normally
- jq software installed, can use jq command, learn more through this link: [jq](https://stedolan.github.io/jq/)
- docker installed, learn more through this link: [docker](https://docs.docker.com/get-started/)

## Usage Method

Transfer the downloaded corresponding version files to the Linux server offline, then use the following command to load the image package into the local docker cache:

```shell
docker load < kasten_k10_offline_images_4.0.8.tar.gz
```

After loading, you can check and confirm the image status with the following command:

```shell
docker images
```

Download the push script:

```shell
curl -O https://blog.backupnext.cloud/kasten_private_repo.sh
```

Please note that after downloading the script, be sure to review the content to ensure it's correct before use.

Modify script execution permissions:

```bash
chmod +x kasten_private_repo.sh
```

Script commands and parameters:

```bash
./kasten_private_repo.sh <k10-ver> <target repo>
```

Where k10-ver is the K10 version, for example, the latest version is `4.0.8`.

target repo is the target private image repository, for example `private.target.repo/kasten`

For example, with the above configuration, this command becomes:

```bash
./kasten_private_repo.sh 4.0.8 private.target.repo/kasten
```

Running this command will automatically upload the K10 images to private.target.repo/kasten, and when installing K10, you can use this private image repository:

```shell
helm install k10 k10-4.0.8.tgz --namespace kasten-io \
    --set global.airgapped.repository=private.target.repo/kasten
    --set metering.mode=airgap
```

The above is the second offline installation method for today.


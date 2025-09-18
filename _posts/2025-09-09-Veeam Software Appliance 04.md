---
layout: post
title: 让 Veeam 更新既安全又快速：本地更新镜像服务器搭建全攻略
tags: VBR
---


在前几篇文章里，我们把 Veeam Software Appliance 装了起来、跑了起来，也体验了它“安全默认”的管理方式。这次我们要解决很多人真正关心的问题：**在没有互联网的环境里，如何让 Veeam Software Appliance 也能像在线环境一样自动获取更新**。官方手册提到可以指定本地镜像仓库，但具体怎么搭建、怎么同步、怎么配证书，却没有细说。这篇就基于我自己实验室的操作，完整复刻一遍，大家可以直接照着做。


## 一、为什么要自己搭建更新仓库

Veeam Software Appliance 自带的 Veeam Updater 服务每天会自动连到 `https://repository.veeam.com` 拉取补丁和元数据，这对有外网的环境很方便。但在隔离区、测试区或者合规要求不能访问公网的场景，就会面临补丁滞后、手工更新麻烦的问题。

本地更新仓库的作用就是：在内网搭一个“翻版”的 Veeam 官方仓库，用 HTTPS 提供服务，并且让 Appliance 信任它，这样即使断网也能自动检查和安装更新。你只需要周期性地把官方仓库镜像下来，内网的 Appliance 就能像连公网一样更新了。


## 二、在 Ubuntu 上部署 nginx + 自签名证书 + 镜像同步

本教程演示如何在 Ubuntu 虚拟机 上搭建一套完整的 Veeam 官方仓库镜像服务：

- 使用 nginx 提供 HTTPS 访问；
- 通过 自签名证书（或替换为 Let’s Encrypt 证书）提供传输安全，满足 Veeam 官方要求；
- 利用 wget 镜像模式定时同步官方仓库内容；

我这里的实验室环境是 Proxmox 上的 虚拟机，CPU 和内存配置按需即可，磁盘空间需预留足够（例如 rocky 仓库约 17 GB，完整仓库可能超 100 GB）。

接下来就可以按以下步骤操作。

```bash
# 安装 nginx
apt install nginx -y

# 创建存放镜像和证书的目录
mkdir -p /var/www/veeam-repo
mkdir -p /etc/nginx/ssl
cd /etc/nginx/ssl

# 生成自签名证书
openssl genrsa -out veeamrepo.key 2048
openssl req -new -key veeamrepo.key -out veeamrepo.csr \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Lab/OU=IT/CN=veeamupdater.backupnext.home"
openssl x509 -req -days 3650 -in veeamrepo.csr -signkey veeamrepo.key -out veeamrepo.crt
```

其中这里 veeamupdater.backupnext.home 这里是我家里的域名解析，如果大家自己搭建镜像服务器，可以根据自己的情况设置域名。在后面的步骤中，会需要用到这个域名。



配置 nginx 虚拟主机（`/etc/nginx/sites-available/veeamrepo.conf`）：

```nginx
server {
    listen 443 ssl;
    server_name veeamupdater.backupnext.home;

    ssl_certificate     /etc/nginx/ssl/veeamrepo.crt;
    ssl_certificate_key /etc/nginx/ssl/veeamrepo.key;

    root /var/www/veeam-repo;
    index index.html index.htm;

    autoindex on;             
    autoindex_exact_size off;
    autoindex_localtime on;

    location / {
        allow all;
    }
}

server {
    listen 80;
    server_name veeamupdater.backupnext.home;
    return 301 https://$host$request_uri;
}
```

启用并检查配置：

```bash
ln -s /etc/nginx/sites-available/veeamrepo.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

接下来编写镜像同步脚本（只同步需要的路径，这里以 `rocky` 为例）：

```bash
#!/bin/sh
MIRROR_DIR="/var/www/veeam-repo"
LOG_FILE="/root/sync_vbr_only.log"
URL="https://repository.veeam.com/rocky/"

cd "$MIRROR_DIR" || exit 1

wget -m -c -np -nH --cut-dirs=0 \
     -e robots=off \
     -t 3 -T 30 \
     -R "index.html*" \
     -l inf \
     "$URL" >> "$LOG_FILE" 2>&1

echo "Sync completed at $(date)" >> "$LOG_FILE"
```

给脚本执行权限，并通过 crontab 定时执行：

```bash
chmod +x /root/sync_veeam_vbr.sh
crontab -e
# 每天早上 9 点同步一次
0 9 * * * /root/sync_veeam_vbr.sh
```

第一次可以手动运行脚本立即下载，约 17 GB，取决于网速。下载后无需重启 nginx，目录内容更新后 Web 服务即可直接提供新文件。

---

## 三、在 Veeam Software Appliance 中配置本地仓库

镜像服务器准备就绪后，接下来就是在 Veeam Software Appliance 中启用它。操作思路很简单：把自签名证书导入控制台 → 指定镜像地址 → 测试更新。

具体步骤如下：

1. 将刚才在 nginx 服务器上生成的 `veeamrepo.crt` 自签名证书拷贝到 Veeam Backup Console 所在的服务器；
2. 打开 Veeam Backup Console，进入 **Update Settings** 界面。

![Xnip2025-09-09_13-37-10](https://s2.loli.net/2025/09/09/pXIACFlKvNPoOqD.png)

3. 点击下方的 Software repository 设置，，在“Mirror repository”里填写你的地址（例如 `https://veeamupdater.backupnext.home/rocky`）；

![Xnip2025-09-09_13-38-01](https://s2.loli.net/2025/09/09/hlHxmOBCsk7T4Z5.png)

4. 上传 `.crt` 证书并保存设置；


5. 在 Console 左上角，继续点击“检查更新”，跳转到 updater 的网页。点击`Check update`如果提示成功并能正常下载更新，说明内网镜像仓库已配置完成。

![Xnip2025-09-09_13-39-40](https://s2.loli.net/2025/09/09/57GOvJ9KkzDBAmT.png)



6. 这个过程也可以在 web Console 中设置。

![Xnip2025-09-09_13-40-10](https://s2.loli.net/2025/09/09/KO1kZY2o3WbPfmJ.png)

以上，即便在完全隔离的内网环境中，**Veeam Software Appliance** 也能像在公网下一样自动获取补丁与更新，无需再手工下载导入。同时，这个内网更新服务不仅适用于单台 Appliance，还可以为整个 **Veeam Infrastructure Appliance** 环境提供统一的更新源——所有设备的更新请求都会自动重定向到你的内网镜像仓库，真正实现集中、快速又安全的升级体验。


在下一篇文章中，我将继续深入，带大家了解 **Veeam Infrastructure Appliance** 的使用与管理。

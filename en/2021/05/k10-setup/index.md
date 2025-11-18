# Kasten K10 Starter Series 02 – Installing K10


## Kasten K10 Starter Series Index

[Kasten K10 Starter Series 01 - Quick Setup for K8s Single-Node Test Environment](https://blog.backupnext.cloud/2020/12/Setting-up-quick-demo-for-K10-01/)

## Main Content

Kasten K10 installation uses the Kubernetes package management tool Helm. If you're not familiar with Kubernetes, you might not know what Helm is. Simply put, Helm on Kubernetes is like yum on CentOS - when you need to install software on CentOS, you just run `yum install`, and on Kubernetes, it's `helm install`.

Helm commands, like other Linux commands, come with a lot of parameters that can be overwhelming to look at. But don't worry, we don't need to understand all the complex stuff. Just remember these key commands and you'll be able to handle K10 just fine:

```bash
# Add a chart repository
$ helm repo add <repo name> <url>
# Install software
$ helm install <chart> <repo/chart> --namespace <namespace name>
# Uninstall software
$ helm uninstall <chart> --namespace <namespace name>
```

For K10 installation, the key elements are:

- Repo name (repository name): kasten
- Chart (software name): k10
- URL (repository address): https://charts.kasten.io/
- Namespace name: kasten-io (default value)

## K10 Pre-Flight Check

Of course, before installation, because each user's environment can be complex and may have various conditions that don't meet requirements, Kasten provides a pre-flight check script ([pre-flight checks](https://docs.kasten.io/latest/install/requirements.html#pre-flight-checks)) to help us determine if the basic installation conditions are met. Simply put, when this script finishes running and you see all green "Ok" statuses, then installing K10 will be completely fine.

Due to some incomprehensible network issues, `gcr.io` cannot be accessed normally, so the pre-flight check script from the official documentation cannot run properly. Here I provide a modified script that can work normally with domestic networks:

```bash
$ curl https://blog.backupnext.cloud/k10_primer.sh | bash
```

This K10 pre-flight check script also has a dedicated parameter for storage class checks. When needed, you can perform a series of health checks on a created storage class:

```bash
$ curl -s https://blog.backupnext.cloud/k10_primer.sh  | bash /dev/stdin -s ${STORAGE_CLASS}
```

## K10 Installation

K10 can basically work with all Kubernetes distributions. In the official documentation, for special distributions like AWS, Azure, Red Hat Openshift, Google Cloud, DigitalOcean, and VMware vSphere, there are some specific installation guides, mostly related to service accounts. For Kubernetes distributions beyond these, you can follow the general installation method.

Again, because gcr.io cannot be accessed, for our domestic networks, we need to look for the [Air-Gapped Install](https://docs.kasten.io/latest/install/offline.html) section in the documentation. The installation steps are as follows:

1. Download the installation script locally. After running the command, you'll see a file called `k10-4.0.2.tgz` in your local folder, where 4.0.2 is the current latest K10 version.

```bash
# Update helm repository and grab the K10 chart locally
$ helm repo update && \
    helm fetch kasten/k10
# In the command above, kasten is the repo name, and k10 is the chart name
```

2. Create the kasten-io namespace in the Kubernetes cluster.

```bash
# Create a namespace named "kasten-io"
$ kubectl create namespace kasten-io
```

3. Install K10 version 4.0.2 using the domestic mirror `ccr.ccs.tencentyun.com/kasten/`.

```bash
# Install kasten k10 using helm
$ helm install k10 k10-4.0.2.tgz --namespace kasten-io \
    --set global.airgapped.repository=ccr.ccs.tencentyun.com/kasten
# In the command above, k10 is the chart name, and the repo is not specified,
# directly using the content from the downloaded tgz compressed package,
# so there's no need to search for the relevant chart in the repo anymore.
```

4. Since the entire installation process will automatically fetch container images from the specified container image repository - for example, in this case, it will fetch K10 images from the Tencent domestic mirror `ccr.ccs.tencentyun.com/kasten/` - it will take some time to wait. During this waiting period, you can use the following command to check the status of all K10 pods.

```bash
# Check K10 status
$ watch -n 2 "kubectl get pod -n kasten-io"
```

5. When all pod statuses show as "running", you can press Ctrl+C to terminate this command.

6. The installation process ends here. Next, you can use K10 through the graphical interface. To access the Dashboard, you need to expose the K10 service from Kubernetes. There are many methods to do this. Here's the simplest one that I commonly use during my own testing.

```bash
# Run the command in the background, publishing K10's dashboard web service through kubectl.
$ kubectl -n kasten-io port-forward --address 0.0.0.0 svc/gateway 8080:8000 > /dev/null 2>&1 &
```

7. You can access K10 by visiting `http://cluster ip:8080/k10/#/` through your web browser and enjoy playing with it.

That's all for today's second lesson in the Kasten K10 series. Thanks for reading, and feel free to try installing and playing around with it yourself.


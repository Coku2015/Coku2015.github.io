---
layout: post
title: 使用 Azure EntraID 为 Kasten 控制台提供多因子验证
tags: Kubernetes
---

Kasten 在安全方面提供全面的管理能力，其中很重要的一部分是用户的账号访问管理，使用 Kasten 的用户可以灵活的借助 OIDC 的协议完成身份认证。本文以 Azure EntraID 为例，通过为 Kasten 配置 Azure EntraID 的集成，实现 Kasten 控制台的多因子验证。

本配置方法由两部分组成，一部分在 Azure 中完成，另外一部分在 Kasten K10 中完成。
## Azure 配置
### 第一步 Kasten 用户组创建
首先在 Azure EntraID 中，需要配置一个安全组，我们会将需要访问 Kasten 网页的用户添加到这个安全组中。

在 Azure EntraID 控制台中，我们首先找到 Group，然后 New Group 新建一个。Group type 选择`安全组`，Group Name 随意起，我这里设置成 Kasten Users，其他选项保持不变如下图：

![image-20250525141056077](https://s2.loli.net/2025/05/25/8vQZrBwt3XAnDOb.png)

点击 Create 创建后，回到 All groups 列表中可以看到创建好的组。

然后我们点击进入这个组，找到 Members，在这里通过 Add members 按钮，把需要访问的用户加进来，比如我这里已经把 Lei Wei 添加进来了。

![image-20250525141032819](https://s2.loli.net/2025/05/25/LCmM9QoaKXw6fEd.png)

### 第二步 应用注册

在 Azure EntraID 中需要创建一个 App，用来做 Kasten 身份认证的接口，在 Azure EntraID 中找到 App registrations，点击 New registration 就可以进行创建，如下图：

![image-20250525141000594](https://s2.loli.net/2025/05/25/bN8xUeMK4iJCXAY.png)

在 New registration 向导中，我们需要起个名字，比如叫 kasten-service，其他选项保持默认，注册即可。

![image-20250525140937124](https://s2.loli.net/2025/05/25/QRx5IjBbvoA7GTO.png)

注册完后，立刻进入了这个新创建的 kasten-service 应用属性页面，接着我们需要简单配置下这个应用，让这个应用能够给 kasten 使用。
找到 Manage 下面的 Authentication，在这里要配置下 Platform，我们点击 Add a platform，然后选择 Web Applications 中的 Web，如下图：

![image-20250525140903111](https://s2.loli.net/2025/05/25/r9Lsb8qhDgYXT7t.png)

这时候，在接下去的 Configure Web 步骤中，设置下 Redirect URIs，这个需要将 kasten 的网页填上来，比如我的 kasten 的 webui 地址是
https://k10-lab-1-node01-71.suzhou.backupnext.cloud/k10，这时候，我需要在这个地址后加上`/auth-svc/v0/oidc/redirect`组成一个完整的 Redirect URI，如下：
https://k10-lab-1-node01-71.suzhou.backupnext.cloud/k10/auth-svc/v0/oidc/redirect
另外，在这个步骤中，还需要勾选 ID tokens 复选框，如图：

![image-20250525140818645](https://s2.loli.net/2025/05/25/OapRHZh2igYvQ9u.png)

点击 save 之后这步就完成了。

接下去，我们还需要一个这个 Application 的 secret，找到 Manage 下面的 Certificates & secrets，创建一个并记录下来备用。这里需要注意下过期时间，如果过期了，到时候是需要重新创建和更新的。

![image-20250525140742618](https://s2.loli.net/2025/05/25/eR3Z4QpHLtCi7Mh.png)

创建完成后，有复制按钮，复制出来备用。

![image-20250525140703688](https://s2.loli.net/2025/05/25/87CwqaDkJnGcPhx.png)

下一步，我们还要在 Token configuration 中添加一个 group claim，使它能够访问安全组。同样是在 Manage 下，找到 Token configuration，点击 Add group claim，选中 Security groups 后点 add 添加。

![image-20250525140636856](https://s2.loli.net/2025/05/25/WcR4CbwxKBkuL8y.png)



### 第三步 收集配置信息用于 Kasten
好，大功告成，那么我们来收集一些信息，去用作 Kasten 的 helm value.yaml 配置。

首先我们来看下 yaml 模版：
```yaml
auth:
  oidcAuth:
    clientID: 3cae7658-5192-4122-b31a-1efcb9355a6f
    clientSecret: xxxxxxxxxxxxxxxxxxxxxxx
    enabled: true
    groupClaim: groups
    groupPrefix: kasten_azure_
    prompt: select_account
    providerURL: https://login.microsoftonline.com/6d2374b4-aceb-42ac-966a-716a93f07db0/v2.0
    redirectURL: https://k10-lab-1-node01-71.suzhou.backupnext.cloud
    scopes: openid email
    usernameClaim: sub
    usernamePrefix: kasten_azure_ 
```

上面这个模版中，我们需要 3 个重要信息，分别是 clientID、clientSecret 和 providerURL。

这可以第二步设置的 App 首页中找到，打开 Overview，然后点击上面的 Endpoint，如下图显示的信息：

![image-20250525140555007](https://s2.loli.net/2025/05/25/tuQafIBGpw8kTgH.png)

这里需要注意的是，providerURL 除了复制这个 URL 之外，还需要额外加上`/v2.0`这个路径。另外，clientSecret 就是第二步中我们记下的那个 Secret。

我们还需要找一下安全组的 ID，这个 ID 会在配置权限时用到。找到 Group 后，看到 Kasten User 的 Overview，找到上面的 Object ID，复制备用。

![image-20250525140516814](https://s2.loli.net/2025/05/25/GtWE1Ndp4oLO7sI.png)



## Kasten 配置

回到 Kasten 中，我们先导出一份已经在使用的 Kasten 的 helm yaml
```bash
helm get values k10 -n kasten-io > k10_values.yaml 
```
编辑这个 k10_values.yaml，将 auth 下面的内容用我们修改好的信息替换后保存：
```yaml
auth:
  oidcAuth:
    clientID: 3cae7658-5192-4122-b31a-1efcb9355a6f
    clientSecret: xxxxxxxxxxxxxxxxxxxxxxx
    enabled: true
    groupClaim: groups
    groupPrefix: kasten_azure_
    prompt: select_account
    providerURL: https://login.microsoftonline.com/6d2374b4-aceb-42ac-966a-716a93f07db0/v2.0
    redirectURL: https://k10-lab-1-node01-71.suzhou.backupnext.cloud
    scopes: openid email
    usernameClaim: sub
    usernamePrefix: kasten_azure_ 
```

然后更新下 kasten 的配置：
```bash
helm upgrade k10 kasten/k10 -n kasten-io -f k10_values.yaml 
```
更新后，等待几分钟，kasten 的 pod 会全部重启下。
重启完成后，再次登入 kasten 网页的时候，会发现网页直接跳转到 Azure EntraID 的认证了。输入 Azure EntraID 的账号并认证后，就能进入 kasten webui 了，但是此时会发现，进入之后没有任何的访问权限。这是因为我们还没为账号绑定 kasten 相关的权限。我们来创建下 kasten 的权限：

下面的命令中，会用到前面提到的安全组的 Object ID，在命令中的 group 信息，由上面 yaml 中的 groupPrefix 的内容和安全组的 ID 组合而成。我这里例子中，groupPrefix 是`kasten_azure_`而安全组的 id 记下来的是`d228b7e7-c10c-488b-9b13-8714682dbb0c`，因此我的命令如下：
```bash
#创建clusterrolebinding
kubectl create clusterrolebinding k10-admin \
  --clusterrole=k10-admin \
  --group=kasten_azure_d228b7e7-c10c-488b-9b13-8714682dbb0c
#创建rolebinding
kubectl create rolebinding k10-admin \
  --role=k10-ns-admin \
  --group=kasten_azure_d228b7e7-c10c-488b-9b13-8714682dbb0c \
  --namespace=kasten-io
```

创建完成后，再刷新网页，会发现访问就正常了。到此所有配置完成。



## 使用 Azure EntraID 认证

重新打开 Kasten 网页，会立刻重定向到 Azure EntraID 的认证界面。

![image-20250525144441652](https://s2.loli.net/2025/05/25/uURfhF61Vpc9tKB.png)

输入账号密码后，会提示通过 Authenticator 进行多因子验证，需要手机同意授权。

![image-20250525144619335](https://s2.loli.net/2025/05/25/9ae25GC7K6DXTS1.png)

完成之后即可进入控制台，在控制台右上角，可以看到当前用户信息，对应的是前缀 kasten_azure_，而后缀则是 Azure 中对应用户的 User ID。

![image-20250525144725581](https://s2.loli.net/2025/05/25/ZclKfx7g5sTIJiF.png)



## 总结

通过和 Azure EntraID 的集成，Kasten 能够快速获得安全可靠的多因子身份验证能力，进一步守护数据的安全。
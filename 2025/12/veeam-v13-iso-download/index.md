# Veeam V13 下载哪个 ISO？90% 的人第一步就错了



上周，一位朋友在群里喊：下载了 Veeam V13 的 ISO，结果升级失败。

我问他下的哪个？

他说：Veeam Data Platform Premium ISO 啊，20 GB 那个。

我叹了口气。

你踩坑了。

---

## ⚠️ 核心变化：VDP Premium ISO 不能用了

这次 V13 的变化，很多人第一反应是懵的。

以前升级 Veeam，不管你下载哪个 ISO，都能拿来升级 VBR 服务器。

V12 的时候，一个 Veeam Data Platform ISO 走天下。

**现在不行了。**

从 V13 开始，**Veeam Data Platform Premium ISO 不能用来升级 VBR。**

说实话，这个变化挺突然的。

但如果你不知道，像我那位朋友一样，下载了 20 GB 的 ISO，准备升级的时候才发现不能用——那就浪费时间了。

### V12 vs V13 对比

| 版本 | 用法 |
|------|------|
| V12 及之前 | VDP Premium ISO 可以升级 VBR ✅ |
| V13 开始 | VDP Premium ISO 不能升级 VBR ❌ |

---

## 三种 ISO，别再搞混了

V13 现在主要有三种 ISO，用途完全不同。

### 1. VBR ISO（升级用这个）

**文件名**：`VeeamBackup&Replication_13.0.x.xxxx_[date].iso`

**大小**：16.9 GB

**用途**：
- 从 V12 Windows 升级到 V13 Windows VBR
- 全新安装 Windows 版 VBR

**记住**：要升级 VBR？就下这个。

---

### 2. VSA ISO（Linux 新部署）

**文件名**：`VeeamSoftwareAppliance_13.0.x.xxxx_[date].iso`

**大小**：11.8 GB

**用途**：
- 部署基于 Linux 的预加固虚拟设备
- **仅支持全新部署，不支持从 V12 迁移配置**

**记住**：想用 Linux 版 Veeam？新环境可以试试。

---

### 3. VDP Premium ISO（完整白金版）

**文件名**：`VeeamDataPlatform_13.0.x.xxxx_[date].iso`

**大小**：包含 VBR+Veeam ONE+VRO（完整套件约 20 GB）

**用途**：
- 全新安装完整的 Veeam Data Platform 环境
- 包含 VBR + Veeam ONE + VRO

**核心就是**：完整套件新装用，升级 VBR 别选它。

---

## 三大常见错误

### 错误 1：用 VDPP ISO 升级 VBR ❌

这是最多的。

原因很简单：以前 V12 就是这么干的，下载个 VDP ISO 就能升级。

到了 V13，这个习惯改不掉。

结果呢？下载了 19 GB，等了半天，发现安装程序里根本没有升级选项。

**解决办法**：重新下载 VBR 专用 ISO，16.9 GB 那个。

---

### 错误 2：Socket 许可证想用 VSA ❌

VSA（Linux 版）只支持 VUL 许可证。

如果你手里还是老的 Socket 许可证，想用 VSA？

不行。

**解决办法**：要么继续用 Windows 版 VBR（支持 Socket 许可证），要么在续费时转换成 VUL 许可证。

---

### 错误 3：忽略网络端口变化 ❌

V13 的网络通信协议变了。

以前用的 Microsoft RPC、Microsoft WMI，现在改用 gRPC。

NTLM 认证也弃用了，改用 Kerberos。

**如果你不检查防火墙规则**，升级完成后可能发现备份任务连不上。

**解决办法**：升级前查官方文档，确认需要开放的端口。

---

## 下载前，先检查这 5 项

```
□ 当前VBR版本（V12.x.x建议先升到最新V12.3.2）
□ 运行平台（Windows还是Linux）
□ 许可证类型（Socket还是VUL）
□ 备份配置数据库
□ 确认ISO类型（VBR升级用VBR ISO）
```

**时间提醒**：16.9 GB 的 ISO，按 10MB/s 网速算，大概需要 30 分钟下载。

---

## 我的建议

我来说说看法。

### 别急着上 VSA

VSA（Linux 版）是 V13 的重头戏，预加固、自动更新、安全系数高。

但有几点要注意：

1. V13 不支持配置迁移，只能新部署
2. 部分高级功能 Web 控制台还不支持
3. 你的团队熟悉 Windows 还是 Linux？

**如果你现有的 VBR 跑得好好的**，我建议：

- Windows 用户继续用 Windows 版 V13
- 新环境可以考虑 VSA
- 给 VSA 一点时间成熟

### 三个具体建议

1. **先在测试环境试一遍**

别直接在生产环境上升级。

测试环境走一遍流程，该踩的坑提前踩完。

2. **下载前看清楚文件名**

`VeeamBackup&Replication_...` 这是 VBR 升级 ISO

`VeeamDataPlatform_...` 这是完整版 ISO

别再搞错了。

3. **保留旧 ISO 至少 1 年**

Veeam 官网通常只提供最新版本下载。

万一升级出问题需要回退，或者要部署新环境想用旧版本呢？

别下载完新版本就把旧的删了。

---

## 最后说一句

V13 是个好版本。

Linux 原生架构、Web 控制台、安全增强，都是实打实的进步。

但升级之前，**先把 ISO 下对**。

这是第一步，也是最容易出错的一步。

---

**你现在的 Veeam 是哪个版本？计划什么时候升级 V13？**

评论区聊聊。


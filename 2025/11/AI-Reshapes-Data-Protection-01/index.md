# AI 重塑数据保护：Claude Code + GLM-4.6 实战，从零搭建 AI CLI 工具


# AI 重塑数据保护：Claude Code + GLM-4.6 实战，从零搭建 AI CLI 工具


Vibe coding 非常火爆，Claude Code 和 Codex 打的异常激烈，感谢有这么好的 AI 工具，给我们数据保护和数据安全行业也带来了全新的能力和全新的想法。本期开始，我想给大家分享下，使用这些 AI 工具，能给我们的数据保护带来一些什么样的不一样的能力，近距离带大家看看 AI 给我们的行业带来的变化。

## 什么是 Claude Code？

鼎鼎大名 Claude Code，不用多说啦，https://code.claude.com/docs/en/overview 有兴趣可以看一下，网络上各大平台的介绍也很多，不仅有关于 AI 编程的，更有一些奇奇怪怪的用法的，像生活助理、博客写作、旅游助手等等。能做的事情就怕你想不到。

本文从零开始带大家看看，如何使用 Claude Code。我的目标并不是教大家如何 Vibe Coding 进行 AI 编程，而是想借着 Claude Code 这个工具给大家一些新的启示。

## 基础环境准备

首先来看看环境准备，Claude Code 它是纯 CLI 形态的工具，和我们通常网页版的 AI 工具，比如 ChatGPT、Copilot 或者豆包等不太一样。因此在使用时，最好为它配上合适的编辑器，这样一边使用一边能观察它创建和修改的相关文件。在基础环境准备的时候，首先我会安装上一款比较好用的 AI 编辑器，我推荐使用 Cursor 编辑器，当然你可以选择任何你顺手的编辑器来使用。

### 安装 Cursor 编辑器

我选 Cursor 开始，原因很简单：AI 集成做得好，界面跟 VS Code 几乎一样，不用重新学习。

这个编辑器同时支持 Windows、Linux 和 macOS，下载安装非常简单。
1. 访问 [Cursor.com](https://cursor.com/cn/download) 下载对应平台的版本
2. 运行安装程序，一路 Next 完成安装
3. 首次启动需要登录，可以注册个新账号登陆即可。

### 环境依赖：Git 和 Node.js

安装 Claude Code 之前，要配置 Git 和 Node.js 环境，因此特别对于 Windows，需要手工去[git网站](https://git-scm.com/)下载 git 工具，然后去去[Node.js 网站](https://nodejs.org/en/download)下载 Node.js 工具。对于 Linux 和 macOS，相对友好一些，安装 git 和 node.js 也都不太费劲，这里不在赘述。等待两个前置工具都安装成功之后，可以通过以下命令确认：

```
$ git -v
$ node -v
$ npm -v
```

确认都安装完成后，有时候需要重启下 Terminal。

## 安装和配置 Claude Code

### 安装 Claude Code 软件
环境准备好后，安装 Claude Code 就很简单了。打开任意一个 Terminal：

```bash
npm install -g @anthropic-ai/claude-code
```

安装完成后验证：
```bash
claude --version
```

首次运行需要登录：打开会提示登录 Anthropic 账号，这时候如果在国内使用，可能会碰到一些麻烦，不过不要紧，我今天的教程带大家更换一下 Claude Code 的大模型，我们就只使用 Claude Code 提供的 CLI 软件，它后台的大模型，我们切换成性价比更高，国内一流的 Coding 模型，智谱 AI 的 GLM-4.6 模型。

### 注册 GLM-4.6

智谱 AI 国庆期间，发布了它的全新旗舰 Coding 模型 - GLM-4.6。根据各大媒体和国内外用户评测，它的 Coding 能力已经和 Claude Code 官网的非常接近了，但是其价格却是只要 Claude Code 的 1/7，并且新用户注册，还赠送免费的 Token 体验包，大家扫码注册就能直接领取赠送的 2000 万 Token 体验包了。

![BigmodelPoster (1)](https://s2.loli.net/2025/11/11/JZk8NxyMWaeVARI.png)

另外，通过我上面这个扫码激活 Coding Plan，还能再折 10%，这个简直白菜价了，每月低至 18 元。Token 的使用量来说，我自己体验下来，是基本上没碰到过 5 小时的 Limit。这里我推荐先上手试用 GLM Coding Lite 20 元的第一个月订阅，当第一个月结束之后，如果还想继续，可以接着取消续订后，选择 3 个月 60 元档的继续优惠订阅，最后一个是一年 240 元的优惠订阅，基本上这样一年多下来，都是在每月 18 元这一档使用，单价远比 Claude Code 原版的$20/月的大模型便宜，但是分量更足。

![Xnip2025-11-11_17-19-35](https://s2.loli.net/2025/11/11/1fr8XzCL2jBdosF.png)

注册完成后，可以在网页上找到主页右上角的 API Key，从里面可以找到自己的 API Key，一会儿我们需要用这个来 Claude Code 中进行配置，为 Claude Code 更换“🧠大脑”。

### 为 Claude Code 配置 GLM 4.6

这个配置页非常简单，GLM 4.6 官网手册清清楚楚的写具体配置方法。具体可以查看以下网站：

https://docs.bigmodel.cn/cn/coding-plan/tool/claude

在这个网站说明里，甚至给出了自动化配置的脚本，不想自己修改的同学可以直接运行脚本解决。

### 创建并配置项目文件夹

接着我们开始使用 Claude Code，我们通常会在某个工作目录下进行 Claude Code 的 coding 操作，因此我们需要打开 Cursor，并指定工作目录。在 Cursor 中，打开一个项目文件夹，同时激活下 Cursor 中的 Terminal，在 Terminal 中输入 Claude，即可进入 Claude Code 的主界面，如下图：

![Xnip2025-11-11_12-14-33](https://s2.loli.net/2025/11/11/wF3o6TMUXYAmLEv.png)



## 下一步

除了 GLM - 4.6 之外，国内还有不少优秀模型，比如 Kimi K2 等，但是性价比就和 GLM - 4.6 差远了。大家有兴趣可以自行探索以下。

基础环境到这里就搭建完了，这样我们就可以在 CLI 界面和 AI 进行直接对话了，因为具备了操作文件和运行本地程序的权限，Claude Code 几乎能干任何电脑上的事情，查询任何我们想要让他查询的信息，因此它能做的事情是非常多的，在下一期开始，我将以一个 VBR 项目为例带大家看看如果使用 Claude Code 帮我执行各种命令。


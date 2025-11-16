# AI 重塑数据保护 (二)：使用 Claude Code 控制您的 VBR 服务器


# AI 重塑数据保护（二）: 使用 Claude Code 控制您的 VBR 服务器

在上篇文章中，我们搭建了 Claude Code + GLM-4.6 的 AI 终端环境。今天，我要向大家展示一个颠覆性的工作方式：**零代码**、通过 Veeam RestAPI 控制 Veeam Backup & Replication 服务器。千万别被 API 之类的吓坏，在今天的内容里不需要编写一行代码，就能让 Claude Code（以下简称 CC）成为你的 VBR 操作助理！让 CC 给你带来一个完全不一样的数据保护体验。

>
> 上周在 Veeam100 Summit 上，Veeam 的 Product Management Director，Anthony Spiteri 先生分享了使用 Codex 通过 VBR Rest API 操作备份服务器，我今天通过本篇帖子详细分享一下通过 Claude Code 来实现这个 demo 的过程。

## 初始化配置

今天的用例其实是 CC 的标准用法，学会了之后，只要你有想法，你可以用这种工作方式，应用到各种各样的场景中。

### 1. 创建工作目录

CC 启动时会以当前目录作为工作环境，这是我们项目的基础，因此我们在安装完 Claude 的电脑上，任意开个空目录开始即可。在 Cursor 中，打开这个目录，同时调整 Cursor 布局，我一般喜欢 3 列式布局，最左侧是文件导航栏，中间是文本编辑窗口，最右侧则是 Terminal 窗口，大概的比例会整成 1:2:3 的样子。大家可以根据自己的喜好，调整相关布局，但是一定要记得把 Terminal 给单独拉出来，因为我们的所有对话操作都会在 Terminal 中完成。

![Xnip2025-11-12_12-01-09](https://s2.loli.net/2025/11/12/mVMw7fSqxQbenXt.png)

打开这个布局后，界面非常干净，什么都没有，可能大家无从下手，这确实回到了最原始的状态，体现了极致的简洁。我们只需要在 Terminal 中输入`Claude`然后按回车，就能正确的进入 Claude 的对话界面。

### 2. 定义 AI 助理角色

在开始对话前，我们先别急着和 CC 聊天，我们来做一些准备工作。

我们可以在项目中先为 CC 身份做一些定义，这个操作也非常简单，我们只需要在左侧的文件夹区域右键添加一个新文件，文件名可以随意取，我这里就叫`assistant.md` ，里面输入以下内容：

```markdown
# 特征描述
- 你是我的备份服务器操作助理，你能通过 rest api 接口操作我的备份服务器。
- openapi 规范在 docs/ 目录下
- VBR 服务器的配置在 .env 文件中
- 你作为助理，只需要按照指令，输出结果即可，不需要把实现过程输出在窗口中
- 不要在对话窗口中输出和记录代码，你用什么代码我并不关心，我只关心结果。
- 请不要将敏感信息，如 access_token 等，输出在 claude code 对话的上下文中。
```

这个文件可以不用太在意格式，只需要把你想要的内容罗列在文件中即可，写完保存即可。我这个内容大家也可以直接抄作业。

写完这个文件后，我们让 CC 自己来为自己设定个标准，在 CC 对话框中，我们用 @assistant.md 的方法，呼唤出 CC 来看下这个文件：

```bash
> 请查看 @assistant.md 文件中的内容，根据说明，撰写一份自我约束和规范的说明，在后面的对话中，记得时刻按照这个约束进行。
```

这样，CC 就会很快自动写出一份说明，这个说明 CC 每次写出来的可能稍微有些不一样，但是大致上内容会差不多，写完后，我的如下：

```markdown
# AI 助理工作约束规范

## 核心定位
- **角色**：备份服务器操作助理
- **职责**：通过 REST API 操作备份服务器，执行备份相关任务
- **目标**：提供专业、高效的备份管理服务

## 工作模式约束

### 1. 结果导向原则
- ✅ **只输出结果**：直接提供任务执行结果
- ❌ **不展示过程**：不记录代码实现、API 调用细节
- ❌ **不技术展示**：不说明使用了什么技术或方法

### 2. 信息安全红线
- 🔒 **严禁敏感信息**：access_token、refresh_token、密码等
- 🔒 **内部数据保护**：所有认证信息仅内部使用
- 🔒 **上下文清洁**：对话中不出现任何敏感数据

### 3. 沟通方式规范
- **简洁直接**：用最少文字传达完整结果
- **专业准确**：使用标准备份术语和状态描述
- **用户友好**：重点突出关键信息
- **使用语音**：永远使用中文作为输出语言，不管接收到什么语言指令，坚决不更换输出语言。

### 4. 技术实现保密
- **代码隐藏**：不展示任何实现代码
- **API 调用保密**：不记录具体的 API 请求过程
- **工具使用隐含**：不说明使用了什么工具或方法

## 参考依据
- 📁 *API 规范*：docs/目录下的 OpenAPI 规范
- ⚙️ **配置文件**：.env 文件中的服务器配置
- 🔧 **接口标准*：严格遵循既定 API 接口

## 执行检查清单
在每次回复前确认：
- [ ] 是否只包含结果信息？
- [ ] 是否没有敏感信息泄露？
- [ ] 是否没有技术实现细节？
- [ ] 是否简洁专业？
- [ ] 是否符合助理角色定位？

## 违规处理
如发现违反上述约束：
1. 立即停止输出
2. 重新审视约束要求
3. 按规范重新组织回复
4. 确保符合所有约束后再输出

---
**创建日期**：2025-11-10
**版本**：1.0
**约束等级**：严格执行
```



### 3. 下载并处理 Veeam Rest API 接口文件

从[Veeam 官网 API 手册中](https://helpcenter.veeam.com/references/vbr/13/rest/1.3-rev0/tag/SectionAbout)点击 Download 按钮下载 swagger.json 文件并存放到当前项目目录中，由于下载下来的文件有 2.5M 大小，对于 CC 处理起来会比较大，特别是在上下文中使用，因此我推荐先让 CC 做个拆分处理，将其拆分成小单元。这个工作直接交给 CC 即可，在对话中输入以下内容：

```bash
> 请帮我拆分 @swagger.json 文件, 目前这个JSON文件太大了,使用起来效率有点低,请帮我根据里面的结构,拆解成有效的小文件,方便阅读和使用. 拆解完成后,将其存放到 docs/swagger/ 目录下, 请确保拆分后的文件一样符合openapi的标准, 确保里面内容和原始json文件的一致性，并且相关客户端能够有效的解析这个拆分后的数据. 
```

接下来 CC 会开始它的第一轮表演，自动调用 Python，处理文件，高效的将文件拆分并存放到你要求的位置。如果有需要，你还可以让它进行一致性验证。处理完成后，swagger.json 文件就可以删除了。

### 4. 初始化项目

接下来，正式进入初始化环境，每个 CC 实例正式干活前，为了让它能够有效的理解当前状况，我们都需要执行这个命令。

在 CC 中执行 `/init` 命令：

```bash
/init
```

Claude 会自动创建 `CLAUDE.md`文件，这是 CC 的行为规范文件。它相当于 CC 的行为准则。在启动/init 命令之后，CC 会通读目录中的所有相关文件，然后将说明和约束更新到到`CLAUDE.md`中。

如果觉得 CC 自己写的有任何疑问，我们都可以手工修改`CLAUDE.md`文件。我生成完成的`CLAUDE.md`文件内容如下：

```markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Veeam Backup & Replication REST API assistant** project. The system acts as a backup server operation assistant that interacts with Veeam Backup & Replication via REST API to manage backup jobs, infrastructure, and monitoring.

## Server Configuration

The Veeam server configuration is stored in `.env`:
- Server: `https://10.10.1.221:9419` (default Veeam REST API port)
- Username: `veeamadmin`
- Currently uses insecure connection (for testing)
- API version: `1.3-rev0`

## API Documentation

Complete OpenAPI specification is available in `docs/swagger/`:
- **Main spec**: `docs/swagger/openapi.json` (1.3MB full specification)
- **Entry point**: `docs/swagger.json` (references main spec)
- **Path definitions**: `docs/swagger/paths/` (jobs, infrastructure, auth)
- **Schemas**: `docs/swagger/components/schemas.json`

### Key API Categories

1. **Job Management** (`paths/jobs.json`):
   - CRUD operations on backup jobs
   - Job control: start, stop, retry, disable
   - Job state monitoring and filtering

2. **Infrastructure Management**:
   - **Proxies** (`paths/infra-proxies.json`): Proxy server management
   - **Servers** (`paths/infra-servers.json`): Backup server management

3. **Authentication** (`paths/misc.json`):
   - OAuth 2.0 password grant authentication
   - Token management (access: 60min, refresh: 14 days)
   - AD domain management

## Authentication Flow

All API calls require:
1. **OAuth2 Token**: POST `/api/oauth2/token` with password grant
2. **Bearer Token**: All subsequent calls need `Authorization: Bearer <token>`
3. **API Version Header**: `x-api-version: 1.3-rev0` required for all requests

## Assistant Role and Behavior

Based on `assistant.md`, the assistant should:
- Act as backup server operation assistant via REST API
- Use OpenAPI specs in `docs/` for all operations
- Use `.env` configuration for server settings
- **Output only results, not implementation details**
- **Do not display or record code in conversation**
- Focus on operational results, not technical implementation

### Critical Constraints (from AI_ASSISTANT_CONSTRAINTS.md)
- **Result-only output**: Never show implementation details or API calls
- **Information security**: Never expose tokens, passwords, or sensitive data
- **Language flexibility**: Respond in user's preferred language for effective communication
- **Technical confidentiality**: Hide all code, tools, and methods used
- **Professional communication**: Concise, accurate, backup-focused terminology

## API Usage Patterns

### Standard Query Parameters:
- `skip`: Pagination offset
- `limit`: Maximum items (default 200)
- `orderColumn`: Sort field
- `orderAsc`: Sort direction (true/false)
- `nameFilter`: Text filtering with wildcards

### Common Operations:
- **Jobs**: GET `/api/v1/jobs`, POST `/api/v1/jobs`, DELETE `/api/v1/jobs/{id}`
- **Job Control**: POST `/api/v1/jobs/{id}/action` (start/stop/retry)
- **Proxies**: GET/POST/PUT/DELETE `/api/v1/infra/proxies`
- **Servers**: GET/POST/PUT/DELETE `/api/v1/infra/servers`

## Security Notes

- Current configuration uses `insecure: true` (testing only)
- Production should use proper SSL/TLS certificates
- All credentials stored in `.env` file
- OAuth2 token management with refresh capability

## Development Guidelines

- Use the provided `.env` configuration for server connection
- Reference the complete OpenAPI spec for detailed operation parameters
- Follow the assistant role: output results only, no implementation details
- All API responses are in JSON format
- Error handling includes token expired, invalid token, and permission errors

## Working with this Project

This is NOT a traditional code development project. It's an API specification and assistant configuration project:

- **No build/compile steps**: This is documentation and configuration only
- **No source code**: All functionality comes from Veeam REST API calls
- **No testing framework**: Testing involves API calls to Veeam server
- **Development workflow**: Update API specs, modify assistant prompts, manage configurations

### Key Files to Understand
- `.env`: Server connection and authentication
- `assistant.md`: Chinese assistant role definition
- `AI_ASSISTANT_CONSTRAINTS.md`: Strict working constraints and security rules
- `docs/swagger/`: Complete Veeam API specification

### Security Notes
- Current configuration uses `insecure: true` (testing only)
- Production should use proper SSL/TLS certificates
- All credentials stored in `.env` file
- OAuth2 token management with refresh capability
- **NEVER expose tokens or credentials in any output**
```

>
> 当然，CC + GLM 4.6 有时候也会比较弱智，自己的限制条件在情急之中也会忘记，但是大多数时候都会按照这个约束条件进行。



### 5. 配置 VBR 连接信息

根据我们给 CC 的提示，我们需要编写一个环境变量文件，给 CC 提供它需要连接 VBR 的信息，我们接着在项目目录中新建个文件，文件名就叫`.env`，里面内容简单输入下 VBR 服务器相关信息就行了，格式可以比较随意，像我下面的就行：

```bash
# VBR服务器配置
VBR_SERVER=192.168.1.100
VBR_PORT=9419
VBR_USERNAME=veeamadmin
VBR_PASSWORD=your_password
insecure=true
```



## 实战使用

经过以上配置，我们的基础工作已经完成，这时候就可以直接和 CC 进行对话了。比如我们先上来可以问问 CC 他任务和职责：

```bash
> Hi CC, 请简单描述下你的任务和职责。
```

它看上去很清楚自己的定位，立刻说出了自己的职责。

![Xnip2025-11-12_13-11-35](https://s2.loli.net/2025/11/12/Yg9izKedakUjupH.png)

看，这还是挺不错吧，有模有样的。

然后，我们看看它的工作是否是符合预期，让 CC 来执行个小任务吧：

```bash
> 请帮我看下昨天的备份任务情况吧。
```

这时候 CC 会执行操作并输出，我这里，它秒出结果如下：

![Xnip2025-11-12_13-14-01](https://s2.loli.net/2025/11/12/cGROgEHsAe9hkJZ.png)

是不是超级简单？不需要编写任何代码，CC 自动用 API 帮我们获取了我们想要的信息，并合理格式化内容后，有效的输出信息给我们。

我们再让他执行下备份任务，看他是不是能按照要求去做

```bash
> 请帮我执行下虚拟机的复制任务。
```

CC 还挺聪明，先找了下当前的 replication 作业，然后和我确定了下操作。

![Xnip2025-11-12_14-40-09](https://s2.loli.net/2025/11/12/HEFxTb1O85yNakz.png)

当我给出确定执行的指令后，CC 就按照要求去启动虚拟机复制任务了。

![Xnip2025-11-12_14-38-58](https://s2.loli.net/2025/11/12/6v4XsPeInMG7rED.png)

回 VBR 控制台查看的话，可以看到任务已经在执行了，看到启动时间，和 CC 提示的是一致的。

![Xnip2025-11-12_14-38-38](https://s2.loli.net/2025/11/12/c17udTmlQy5ps4H.png)



## 总结

随着 AI 技术的不断发展，我们可以期待：

  - **更强的理解能力**：AI 将能够理解更复杂的业务需求和技术场景
  - **更多的自动化**：从被动执行指令到主动发现问题、提出优化建议
  - **更广的集成**：与更多 IT 管理工具和监控系统集成，形成统一的管理平台

以上内容，作为一点点抛砖引玉，AI 技术在不断的给我们的日常生活和我们的行业带来变化，希望我的这个分享对大家有所帮助有所启发，能够让 AI 技术为我们带来更多有价值的应用方式。如果也想动手试一试，可以完整参考这两期的内容，也用 Claude Code + GLM 4.6 搭建一个自己的环境，实战体验一下 AI 的能力。扫码注册下方的链接，获取 9 折的 GLM 4.6 Coding plan 的优惠。

![BigmodelPoster (1)](https://s2.loli.net/2025/11/11/JZk8NxyMWaeVARI.png)


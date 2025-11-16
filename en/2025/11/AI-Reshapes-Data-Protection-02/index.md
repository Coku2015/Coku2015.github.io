# AI Reshaping Data Protection (Part 2): Using Claude Code to Control Your VBR Server


# AI Reshaping Data Protection (Part 2): Using Claude Code to Control Your VBR Server

In our previous article, we set up an AI terminal environment with Claude Code + GLM-4.6. Today, I want to show you a revolutionary way of working: **zero-code** control of your Veeam Backup & Replication server through Veeam RestAPI. Don't be intimidated by terms like API - in today's content, you won't need to write a single line of code to make Claude Code (hereafter CC) your VBR operations assistant! Let CC bring you a completely different data protection experience.

>
> Last week at Veeam100 Summit, Anthony Spiteri, Veeam's Product Management Director, shared about using Codex to operate backup servers through VBR Rest API. Today, I'm sharing the detailed process of implementing this demo through Claude Code.

## Initial Configuration

Today's use case is actually standard CC usage. Once you learn it, as long as you have ideas, you can apply this workflow to various scenarios.

### 1. Create Working Directory

When CC starts, it uses the current directory as the working environment. This is the foundation of our project, so after installing Claude on your computer, you can simply create an empty directory to begin. In Cursor, open this directory and adjust the layout. I generally prefer a 3-column layout: file navigation on the far left, text editing window in the middle, and Terminal window on the far right, with proportions roughly 1:2:3. You can adjust the layout according to your preferences, but remember to pull out the Terminal separately because all our conversation operations will be completed in the Terminal.

![Xnip2025-11-12_12-01-09](https://s2.loli.net/2025/11/12/mVMw7fSqxQbenXt.png)

After opening this layout, the interface is very clean with nothing there, which might make you wonder where to start. This truly returns us to the most primitive state, reflecting ultimate simplicity. We just need to type `Claude` in the Terminal and press Enter to properly enter Claude's conversation interface.

### 2. Define AI Assistant Role

Before starting the conversation, let's not rush to chat with CC. Let's do some preparation first.

We can predefine CC's identity in the project. This operation is also very simple - we just need to right-click in the file area on the left to add a new file. The filename can be arbitrary; I'll call it `assistant.md`. Enter the following content:

```markdown
# Character Description
- You are my backup server operations assistant, capable of operating my backup server through REST API interfaces.
- OpenAPI specifications are in the docs/ directory
- VBR server configuration is in the .env file
- As an assistant, you only need to output results according to instructions, without outputting the implementation process in the window
- Do not output or record code in the conversation window - I don't care what code you use, only the results.
- Please do not output sensitive information such as access_token in the Claude Code conversation context.
```

You don't need to pay too much attention to the format of this file - just list the content you want in the file and save it. You can directly copy my content.

After writing this file, we let CC set a standard for itself. In the CC dialog box, we use the @assistant.md method to call CC to review this file:

```bash
> Please review the content in @assistant.md file, and based on the instructions, write a self-constraint and specification document. Remember to follow these constraints in subsequent conversations.
```

CC will then quickly automatically write a specification document. The content CC writes each time might be slightly different, but generally similar. Here's what mine looked like:

```markdown
# AI Assistant Work Constraints Specification

## Core Positioning
- **Role**: Backup Server Operations Assistant
- **Responsibility**: Operate backup server through REST API, execute backup-related tasks
- **Goal**: Provide professional, efficient backup management services

## Work Mode Constraints

### 1. Results-Oriented Principle
- ✅ **Output only results**: Directly provide task execution results
- ❌ **Don't show process**: Don't record code implementation, API call details
- ❌ **No technical demonstration**: Don't explain what technology or methods were used

### 2. Information Security Red Line
- 🔒 **Strictly prohibit sensitive information**: access_token, refresh_token, passwords, etc.
- 🔒 **Internal data protection**: All authentication information used internally only
- 🔒 **Clean context**: No sensitive data appears in conversations

### 3. Communication Style Standards
- **Concise and direct**: Use minimal text to convey complete results
- **Professional and accurate**: Use standard backup terminology and status descriptions
- **User-friendly**: Highlight key information
- **Language use**: Always use Chinese as output language, regardless of received language instructions

### 4. Technical Implementation Confidentiality
- **Code hiding**: Don't show any implementation code
- **API call confidentiality**: Don't record specific API request processes
- **Tool usage implication**: Don't explain what tools or methods were used

## Reference Basis
- 📁 *API specifications*: OpenAPI specifications in docs/ directory
- ⚙️ **Configuration file**: Server configuration in .env file
- 🔧 **Interface standards*: Strictly follow established API interfaces

## Execution Checklist
Confirm before each response:
- [ ] Does it contain only result information?
- [ ] Is there no sensitive information leakage?
- [ ] Are there no technical implementation details?
- [ ] Is it concise and professional?
- [ ] Does it match the assistant role positioning?

## Violation Handling
If violations of the above constraints are found:
1. Stop output immediately
2. Re-examine constraint requirements
3. Reorganize response according to specifications
4. Ensure all constraints are met before outputting

---
**Creation date**: 2025-11-10
**Version**: 1.0
**Constraint level**: Strict execution
```

### 3. Download and Process Veeam Rest API Interface Files

From the [Veeam official API manual](https://helpcenter.veeam.com/references/vbr/13/rest/1.3-rev0/tag/SectionAbout), click the Download button to download the swagger.json file and save it to the current project directory. Since the downloaded file is 2.5MB in size, it would be quite large for CC to process, especially when using it in context. Therefore, I recommend letting CC do a split processing first, breaking it into small units. You can directly assign this work to CC by entering the following in the conversation:

```bash
> Please help me split the @swagger.json file. Currently, this JSON file is too large and somewhat inefficient to use. Please help me break it down into effective small files based on its structure for easier reading and use. After splitting, save them to the docs/swagger/ directory. Please ensure the split files still conform to OpenAPI standards, maintain consistency with the original JSON file content, and that relevant clients can effectively parse this split data.
```

Next, CC will begin its first performance, automatically calling Python, processing the file, and efficiently splitting and storing it in your requested location. If needed, you can also ask it to perform consistency verification. After processing is complete, the swagger.json file can be deleted.

### 4. Initialize Project

Next, we formally enter the initialization environment. Before each CC instance officially starts working, we need to execute this command to enable it to effectively understand the current situation.

Execute the `/init` command in CC:

```bash
/init
```

Claude will automatically create a `CLAUDE.md` file, which is CC's behavior specification file. It's equivalent to CC's code of conduct. After starting the /init command, CC will read through all relevant files in the directory and then update the instructions and constraints to `CLAUDE.md`.

If you have any questions about what CC wrote, you can manually modify the `CLAUDE.md` file. Here's the content of my generated `CLAUDE.md` file:

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
> Of course, CC + GLM 4.6 can sometimes be a bit clueless and forget its own constraints in urgent situations, but most of the time it will follow these constraint conditions.

### 5. Configure VBR Connection Information

According to the hints we gave CC, we need to write an environment variable file to provide CC with the information it needs to connect to VBR. Let's continue by creating a new file in the project directory named `.env`, and simply enter the VBR server information. The format can be quite flexible, like mine below:

```bash
# VBR Server Configuration
VBR_SERVER=192.168.1.100
VBR_PORT=9419
VBR_USERNAME=veeamadmin
VBR_PASSWORD=your_password
insecure=true
```

## Practical Usage

After the above configuration, our foundational work is complete, and we can now directly converse with CC. For example, we can first ask CC about its tasks and responsibilities:

```bash
> Hi CC, please briefly describe your tasks and responsibilities.
```

It seems very clear about its positioning and immediately stated its responsibilities.

![Xnip2025-11-12_13-11-35](https://s2.loli.net/2025/11/12/Yg9izKedakUjupH.png)

See, that's quite good, isn't it? Very professional.

Then, let's see if its work meets expectations. Let CC execute a small task:

```bash
> Please help me check yesterday's backup job status.
```

At this point, CC will execute the operation and output. Here, it instantly produced the following results:

![Xnip2025-11-12_13-14-01](https://s2.loli.net/2025/11/12/cGROgEHsAe9hkJZ.png)

Isn't that super simple? No need to write any code - CC automatically uses the API to help us get the information we want and effectively outputs the information to us after reasonably formatting the content.

Let's ask it to execute a backup task to see if it can follow instructions:

```bash
> Please help me execute the VM replication task.
```

CC is quite smart - it first found the current replication jobs and then confirmed the operation with me.

![Xnip2025-11-12_14-40-09](https://s2.loli.net/2025/11/12/HEFxTb1O85yNakz.png)

When I gave the confirmation to execute, CC went ahead and started the VM replication task as requested.

![Xnip2025-11-12_14-38-58](https://s2.loli.net/2025/11/12/6v4XsPeInMG7rED.png)

Checking back in the VBR console, you can see the task is already running. Looking at the start time, it matches what CC indicated.

![Xnip2025-11-12_14-38-38](https://s2.loli.net/2025/11/12/c17udTmlQy5ps4H.png)

## Conclusion

With the continuous development of AI technology, we can expect:

- **Stronger comprehension capabilities**: AI will be able to understand more complex business requirements and technical scenarios
- **More automation**: From passively executing instructions to proactively identifying problems and suggesting optimizations
- **Broader integration**: Integration with more IT management tools and monitoring systems to form a unified management platform

The above content is just a small attempt to spark ideas. AI technology is continuously bringing changes to our daily lives and our industry. I hope my sharing is helpful and inspiring to everyone, enabling AI technology to bring us more valuable application methods. If you also want to try it yourself, you can refer to these two articles completely, use Claude Code + GLM 4.6 to build your own environment, and experience AI's capabilities firsthand. Scan the code to register through the link below to get a 10% discount on GLM 4.6 Coding plan.

![BigmodelPoster (1)](https://s2.loli.net/2025/11/11/JZk8NxyMWaeVARI.png)


# Veeam YARA 扫描的免费规则库 - Ransomware.live 实战指南


我们在之前的文章中介绍了 Veeam v13 版本继续加强了 YARA 恶意软件扫描功能，但官方规则库有限的问题很现实。互联网上免费的 YARA 规则源本来就不多，质量好的更是稀缺。今天给大家推荐一个宝藏网站：Ransomware.live - 一个专业的开源勒索软件威胁情报平台，它提供 62 个主流勒索软件团伙的免费 YARA 规则，正好可以作为 Veeam YARA 扫描功能的绝佳补充。

## 认识 Ransomware.live：专业的勒索软件威胁情报平台

Ransomware.live 是由安全专家 Julien Mousqueton 维护的开源威胁情报平台，专注于勒索软件攻击的实时监控和分析。平台跟踪 297 个攻击团伙，记录超过 23,126 个受害者案例，最核心的价值是提供了 62 个主流勒索软件团伙的专业 YARA 规则库。

![Xnip2025-11-10_21-36-18](https://s2.loli.net/2025/11/10/JmvzxfRylTEIN1X.png)

**平台核心功能：**

- **实时攻击监控**- 跟踪全球勒索软件攻击活动，显示 297 个攻击团伙、23,126+ 个受害者案例例
- **攻击统计** - 按时间、地域、行业维度分析勒索软件趋势
- **团伙档案** - 详细记录各个勒索软件团伙的攻击特征和历史活动
- **受害者数据库** - 可搜索的受害者信息，便于威胁关联分析
- **YARA规则库** - 按勒索软件团伙分类的检测规则，支持直接下载

这些规则由安全专家基于真实攻击样本编写，质量远超通用检测规则。Ransomware.live 的 YARA 页面能够查看并手工获取相关的 YARA 规则。有需要的用户可以按需查找相关规则。

![Xnip2025-11-10_21-41-54](https://s2.loli.net/2025/11/10/oHRtXxlOLDmZcbT.png)

除了手工获取之外，平台还提供 Pro API 服务，对于需要自动化批量下载的 Veeam 用户来说，Pro 版本的结构化 API 接口服务特别实用，我们只需要通过 Get your free API Key 服务获取相关下载 API key 即可。

![Xnip2025-11-10_21-43-37](https://s2.loli.net/2025/11/10/QBj3stTaEOglyvN.png)



## Pro API：自动化 YARA 规则获取

对于有规则需要离线使用的用户，我为大家提供了一个一键下载所有规则的脚本，专门为 Veeam 用户设计，能够自动下载所有 62 个团伙的 YARA 规则文件。脚本使用 jq 解析 JSON 响应，自动处理文件命名和验证，还包含详细的下载日志。

### 完整自动化下载脚本

```bash
#!/bin/bash
# Ransomware.live YARA规则全自动下载脚本
set -e
set -o pipefail

# 用户配置
TARGET_DIR="./yara_rules"
API_KEY="your-api-key-here"
API_BASE="https://api-pro.ransomware.live"

# 创建目录
mkdir -p "$TARGET_DIR"
LOG_FILE="${TARGET_DIR}/download_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查工具
if ! command -v jq >/dev/null 2>&1; then
    echo "需要安装jq: sudo apt-get install jq 或 brew install jq"
    exit 1
fi

log "开始下载Ransomware.live YARA规则..."

# 获取所有团伙YARA规则
API_RESPONSE=$(curl -s -H "X-API-KEY: $API_KEY" "$API_BASE/yara")

if ! echo "$API_RESPONSE" | jq -e '.groups' >/dev/null 2>&1; then
    log "API响应异常，请检查API密钥"
    exit 1
fi

# 批量下载规则
echo "$API_RESPONSE" | jq -r '.groups[].group' | while read -r group; do
    if [ -n "$group" ]; then
        log "下载: $group"

        YARA_RESPONSE=$(curl -s -H "X-API-KEY: $API_KEY" "$API_BASE/yara/$group")

        if echo "$YARA_RESPONSE" | jq -e '.rules[0]' >/dev/null 2>&1; then
            YARA_CONTENT=$(echo "$YARA_RESPONSE" | jq -r '.rules[0].content')
            FILENAME=$(echo "$YARA_RESPONSE" | jq -r '.rules[0].filename')

            if [ -n "$YARA_CONTENT" ] && [ "$YARA_CONTENT" != "null" ]; then
                OUTPUT_FILE="${TARGET_DIR}/${FILENAME:-${group}.yar}"
                echo "$YARA_CONTENT" > "$OUTPUT_FILE"

                if [ -s "$OUTPUT_FILE" ] && grep -q "^rule " "$OUTPUT_FILE"; then
                    RULE_COUNT=$(grep -c "^rule " "$OUTPUT_FILE")
                    log "✓ $(basename "$OUTPUT_FILE") (${RULE_COUNT}条规则)"
                else
                    log "✗ 文件无效: $group"
                    rm -f "$OUTPUT_FILE"
                fi
            fi
        fi

        sleep 0.5
    fi
done

log "下载完成！规则文件保存在: $TARGET_DIR"
```

### 脚本使用方法

1. **环境准备**
   ```bash
   # 安装必要工具
   sudo apt-get install curl jq  # Ubuntu/Debian
   # 或
   brew install curl jq            # macOS
   ```

2. **配置脚本**
   ```bash
   # 修改 TARGET_DIR 为你的目标目录
   # 修改 API_KEY 为你的实际 API 密钥
   chmod +x download_yara_rules.sh
   ```

3. **运行脚本**
   ```bash
   ./download_yara_rules.sh
   ```

**脚本特性：**
- 一键下载所有 62 个勒索软件团伙的 YARA 规则，如果后续有新的规则更新，本脚本也能同样一键获取相关更新规则。
- 自动处理文件命名和格式验证
- 详细的下载日志和错误处理
- 支持自定义下载目录

## Veeam 集成部署方法

规则下载完成后，可以通过 VBR console 上传和导入。

1. 来到 VBR console 中，打开下方的三个点，激活 Files 窗口

![Xnip2025-11-10_21-06-36](https://s2.loli.net/2025/11/10/V4SgK6FYNOTo3uq.png)

2. 在 Files 窗口中，能看到当前 Console 所在的 Windows 的文件夹和 VBR Server 的文件夹。

![Xnip2025-11-10_21-08-47](https://s2.loli.net/2025/11/10/jYiExvhsGX65PMW.png)

3. 从当前电脑的 YARA 规则存放路径中，选中所有需要拷贝的规则，右键点击 Copy 按钮。

![Xnip2025-11-10_21-09-13](https://s2.loli.net/2025/11/10/DOJ7jhWtuH12egS.png)

4. 来到 VBR Server 的 yara_rules 目录，右键菜单选择 Paste 按钮

![Xnip2025-11-10_21-09-39](https://s2.loli.net/2025/11/10/TfDBsL62ptvMOHZ.png)

5. 稍等片刻后，yara 规则文件就会被传输到 vbr 服务器上。

![Xnip2025-11-10_21-09-52](https://s2.loli.net/2025/11/10/L1lrcHyehWNQGdm.png)

6. 找任意一个备份存档，选中 Scan backup 操作，能够在 YARA 下来菜单中实时看到规则名称，选取作为扫描规则即可。

![Xnip2025-11-10_21-11-03](https://s2.loli.net/2025/11/10/qTkXvl5RDZHfsQ9.png)



## 总结

Ransomware.live 作为免费开源的威胁情报平台，为 Veeam 用户提供了零成本的 YARA 规则增强方案。目前已包含 62 个专业级勒索软件检测规则、持续更新的威胁情报、再加上自动化下载工具，这套组合让 Veeam v13 的恶意软件检测能力有了质的提升。配合免费的 Pro 版本的 RestAPI 和我的自动下载脚本，能够实现全自动的规则更新。

**实际应用建议：**

1. **定期更新**：建议每周执行一次，保持威胁情报最新
2. **测试验证**：先在测试环境验证新规则的检测效果
4. **监控日志**：关注下载成功率和文件有效性，如果有可能，可以进行人工核对

面对日益复杂的勒索软件威胁，这种免费但专业的威胁情报源值得每个 Veeam 用户关注和使用。通过合理配置 Ransomware.live 的 YARA 规则，可以显著提升 Veeam 环境对勒索软件的检测和防护能力。

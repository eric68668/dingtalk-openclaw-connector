# 钉钉 OpenClaw 连接器 - v0.8.0 升级指南

> **版本信息**：v0.8.0-beta | [查看变更日志](CHANGELOG.md)

## 🎉 主要更新

本次升级将钉钉连接器从旧版 Clawdbot SDK 迁移到 OpenClaw SDK，带来以下重大改进：

### ✨ 新增功能

- **多账号支持** - 支持同时配置多个钉钉机器人账号
- **安全策略配置** - 支持单聊/群聊策略（open/pairing/allowlist）
- **SecretInput 模式** - 支持从环境变量、文件、命令执行获取敏感信息
- **完整 ChannelPlugin 接口** - 实现所有 OpenClaw 标准接口
- **模块化架构** - 代码从单文件（3938 行）拆分为 19 个模块

### 🔧 配置变更

#### 基础配置（向下兼容）

```json5
{
  "channels": {
    "dingtalk-connector": {
      "enabled": true,
      "clientId": "ding_xxx",
      "clientSecret": "xxx",
      "enableMediaUpload": true,
      "separateSessionByConversation": true,
      "groupSessionScope": "group"
    }
  }
}
```

> ✅ **向下兼容**：旧配置无需修改即可使用

#### 新增配置项

```json5
{
  "channels": {
    "dingtalk-connector": {
      // 安全策略
      "dmPolicy": "open",              // open | pairing | allowlist
      "allowFrom": [],                 // 单聊白名单
      "groupPolicy": "open",           // open | allowlist | disabled
      "groupAllowFrom": [],            // 群聊白名单
      "requireMention": true,          // 群聊是否需要 @ 机器人
      
      // 多账号配置
      "defaultAccount": "main",
      "accounts": {
        "main": {
          "enabled": true,
          "name": "主账号",
          "clientId": "ding_xxx",
          "clientSecret": { 
            "source": "env", 
            "provider": "system", 
            "id": "DINGTALK_CLIENT_SECRET" 
          }
        }
      }
    }
  }
}
```

### 📦 安装升级

#### 方式一：从本地开发模式安装（内测）

```bash
# 切换到升级分支
git checkout feat/migrate-to-openclaw-sdk

# 安装依赖
npm install

# 安装插件（本地开发模式）
openclaw plugins install -l .

# 重启 Gateway
openclaw gateway restart
```

#### 方式二：从 Git 安装

```bash
# 安装升级分支
openclaw plugins install https://github.com/DingTalk-Real-AI/dingtalk-openclaw-connector.git#feat/migrate-to-openclaw-sdk

# 重启 Gateway
openclaw gateway restart
```

### 🔒 SecretInput 配置示例

#### 环境变量方式

```json5
{
  "clientSecret": { 
    "source": "env", 
    "provider": "system", 
    "id": "DINGTALK_CLIENT_SECRET" 
  }
}
```

然后在环境变量中设置：
```bash
export DINGTALK_CLIENT_SECRET="your_secret_here"
```

#### 文件方式

```json5
{
  "clientSecret": { 
    "source": "file", 
    "provider": "system", 
    "id": "/path/to/secret.txt" 
  }
}
```

### 🚀 多账号配置示例

```json5
{
  "channels": {
    "dingtalk-connector": {
      "enabled": true,
      "defaultAccount": "main",
      "accounts": {
        "main": {
          "enabled": true,
          "name": "主账号",
          "clientId": "ding_xxx",
          "clientSecret": "xxx",
          "dmPolicy": "open",
          "groupPolicy": "allowlist",
          "groupAllowFrom": ["oc_xxx"]
        },
        "bot2": {
          "enabled": true,
          "name": "机器人 2",
          "clientId": "ding_yyy",
          "clientSecret": "yyy",
          "dmPolicy": "pairing"
        }
      }
    }
  },
  "bindings": [
    {
      "agentId": "ding-bot1",
      "match": { 
        "channel": "dingtalk-connector", 
        "accountId": "main" 
      }
    },
    {
      "agentId": "ding-bot2",
      "match": { 
        "channel": "dingtalk-connector", 
        "accountId": "bot2" 
      }
    }
  ]
}
```

### ⚠️ 注意事项

1. **向下兼容**：旧配置无需修改即可使用
2. **配置验证**：新增了配置 Schema 验证，配置错误会提示具体原因
3. **多账号**：使用多账号时，需要在 `bindings` 中指定 `accountId`
4. **安全策略**：`dmPolicy="allowlist"` 时必须配置 `allowFrom`

### 🐛 问题反馈

如遇到问题，请提交 Issue：
https://github.com/DingTalk-Real-AI/dingtalk-openclaw-connector/issues

### 📚 相关文档

- [完整配置参考](#配置参考)
- [多账号支持](#多账号支持新增)
- [SecretInput 模式](#secretinput-模式新增)

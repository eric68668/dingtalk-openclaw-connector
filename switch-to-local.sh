#!/bin/bash
set -e

echo "🔄 切换到本地开发版本..."

# 检查本地开发目录是否存在
LOCAL_DEV_PATH="/Users/xiaocao/IdeaProjects/dingtalk-openclaw-connector"
if [ ! -d "$LOCAL_DEV_PATH" ]; then
    echo "❌ 错误：本地开发目录不存在: $LOCAL_DEV_PATH"
    exit 1
fi

CONFIG_FILE="$HOME/.openclaw/openclaw.json"

# 备份配置文件
echo "📦 备份配置文件..."
cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"

# 检查是否安装了 jq
if ! command -v jq &> /dev/null; then
    echo "❌ 错误：需要安装 jq 工具"
    echo "💡 安装命令：brew install jq"
    exit 1
fi

# 修改配置文件，添加本地开发路径
echo "🔧 修改配置文件..."
jq --arg path "$LOCAL_DEV_PATH" '
  .plugins.load.paths = [$path] |
  .plugins.entries."dingtalk-connector".enabled = true
' "$CONFIG_FILE" > /tmp/openclaw_config_temp.json

mv /tmp/openclaw_config_temp.json "$CONFIG_FILE"

# 重启 Gateway
echo "🔄 重启 Gateway..."
openclaw gateway restart

echo ""
echo "✅ 已切换到本地开发版本！"
echo "📍 路径：$LOCAL_DEV_PATH"
echo ""
echo "验证安装："
openclaw plugins list | grep "dingtalk-connector"

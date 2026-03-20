#!/bin/bash
set -e

echo "🔄 切换到 Beta 版本..."

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

# 移除本地开发路径
echo "🔧 修改配置文件..."
jq 'del(.plugins.load.paths)' "$CONFIG_FILE" > /tmp/openclaw_config_temp.json
mv /tmp/openclaw_config_temp.json "$CONFIG_FILE"

# 卸载其他版本
echo "🗑️  卸载其他版本..."
openclaw plugins uninstall dingtalk-connector 2>/dev/null || true

# 安装 beta 版本
echo "📥 安装 Beta 版本..."
openclaw plugins install @dingtalk-real-ai/dingtalk-connector@beta

# 重启 Gateway
echo "🔄 重启 Gateway..."
openclaw gateway restart

echo ""
echo "✅ 已切换到 Beta 版本！"
echo ""
echo "验证安装："
openclaw plugins list | grep "dingtalk-connector"

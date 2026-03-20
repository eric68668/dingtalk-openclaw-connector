#!/bin/bash
set -e

# 显示菜单
show_menu() {
    echo ""
    echo "============================================"
    echo "   DingTalk Connector 版本切换工具"
    echo "============================================"
    echo ""
    echo "请选择要切换的版本："
    echo ""
    echo "  1) 本地开发版本 (~/IdeaProjects/dingtalk-openclaw-connector)"
    echo "  2) Beta 测试版本 (@beta)"
    echo "  3) 线上稳定版本 (@latest)"
    echo "  4) 指定版本号"
    echo "  5) 查看当前版本"
    echo "  0) 退出"
    echo ""
    echo "============================================"
    echo -n "请输入选项 [0-5]: "
}

# 查看当前版本
show_current_version() {
    echo ""
    echo "📋 当前安装的版本："
    echo ""
    openclaw plugins list | grep "dingtalk-connector" || echo "未找到 dingtalk-connector 插件"
    echo ""
}

# 切换到本地开发版本
switch_to_local() {
    echo ""
    echo "🔄 切换到本地开发版本..."
    bash "$(dirname "$0")/switch-to-local.sh"
}

# 切换到 Beta 版本
switch_to_beta() {
    echo ""
    echo "🔄 切换到 Beta 版本..."
    bash "$(dirname "$0")/switch-to-beta.sh"
}

# 切换到稳定版本
switch_to_stable() {
    echo ""
    echo "🔄 切换到线上稳定版本..."
    bash "$(dirname "$0")/switch-to-stable.sh"
}

# 切换到指定版本
switch_to_custom() {
    echo ""
    echo -n "请输入版本号 (例如: 0.8.0-beta.2): "
    read version
    
    if [ -z "$version" ]; then
        echo "❌ 错误：版本号不能为空"
        return 1
    fi
    
    echo ""
    echo "🔄 切换到版本 $version..."
    
    CONFIG_FILE="$HOME/.openclaw/openclaw.json"
    
    # 备份配置文件
    echo "📦 备份配置文件..."
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    
    # 移除本地开发路径
    echo "🔧 修改配置文件..."
    jq 'del(.plugins.load.paths)' "$CONFIG_FILE" > /tmp/openclaw_config_temp.json
    mv /tmp/openclaw_config_temp.json "$CONFIG_FILE"
    
    # 卸载其他版本
    echo "🗑️  卸载其他版本..."
    openclaw plugins uninstall dingtalk-connector 2>/dev/null || true
    
    # 安装指定版本
    echo "📥 安装版本 $version..."
    openclaw plugins install "@dingtalk-real-ai/dingtalk-connector@$version"
    
    # 重启 Gateway
    echo "🔄 重启 Gateway..."
    openclaw gateway restart
    
    echo ""
    echo "✅ 已切换到版本 $version！"
    echo ""
    echo "验证安装："
    openclaw plugins list | grep "dingtalk-connector"
}

# 主循环
while true; do
    show_menu
    read choice
    
    case $choice in
        1)
            switch_to_local
            ;;
        2)
            switch_to_beta
            ;;
        3)
            switch_to_stable
            ;;
        4)
            switch_to_custom
            ;;
        5)
            show_current_version
            ;;
        0)
            echo ""
            echo "👋 再见！"
            exit 0
            ;;
        *)
            echo ""
            echo "❌ 无效的选项，请重新选择"
            ;;
    esac
    
    echo ""
    echo -n "按 Enter 键继续..."
    read
done

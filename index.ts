/**
 * DingTalk Connector Plugin for OpenClaw
 *
 * 钉钉企业内部机器人插件，使用 Stream 模式连接，支持 AI Card 流式响应。
 * 已迁移到 OpenClaw SDK，支持多账号、安全策略等完整功能。
 * 
 * Last updated: 2026-03-18 17:00:00
 */

// 🔧 在所有模块导入之前，先配置 axios 禁用代理
// 问题：环境变量中的 http_proxy/https_proxy 可能使用 HTTP 协议（如 http://127.0.0.1:15236）
// 导致：axios 通过 HTTP 代理访问 HTTPS 网站时，服务器返回 "HTTP request sent to HTTPS port"
// 解决：在项目入口处统一禁用代理，确保所有 axios 实例都不使用代理
import axios from "axios";
axios.defaults.proxy = false;

import type { OpenClawPluginApi } from "openclaw/plugin-sdk";
import { dingtalkPlugin } from "./src/channel.ts";
import { setDingtalkRuntime } from "./src/runtime.ts";
import { registerGatewayMethods } from "./src/gateway-methods.ts";

export default function register(api: OpenClawPluginApi) {
  setDingtalkRuntime(api.runtime);
  api.registerChannel({ plugin: dingtalkPlugin });
  
  // 注册 Gateway Methods
  registerGatewayMethods(api);
}

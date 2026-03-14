# WebSocket 心跳日志优化说明

## 问题描述

用户遇到了来自 `dingtalk-stream` SDK 的心跳超时日志：

```
2026-03-14T10:54:04.240+08:00 TERMINATE SOCKET: Ping Pong does not transfer heartbeat within heartbeat intervall
```

这条日志存在以下问题：
1. **拼写错误**：`intervall` 应该是 `interval`
2. **信息不足**：缺少账号ID、连接时长、重连次数等关键诊断信息
3. **日志级别不明确**：作为正常的重连机制，日志级别需要优化

## 解决方案

由于该日志来自 `dingtalk-stream` SDK 内部，我们无法直接修改 SDK 源码。因此采用以下方案在项目层面改善日志体验：

### 1. 关闭 SDK Debug 日志

在初始化 `DWClient` 时显式设置 `debug: false`，减少 SDK 内部的噪音日志：

```typescript
const client = new DWClient({
  clientId: account.clientId,
  clientSecret: account.clientSecret,
  debug: false, // 关闭 SDK 的 debug 日志，减少噪音
});
```

### 2. 添加连接状态监控

在项目层面添加详细的连接状态追踪和日志：

```typescript
// 连接状态追踪
let connectionStartTime = Date.now();
let reconnectCount = 0;

// Handle disconnection
client.on('close', () => {
  const connectionDuration = Date.now() - connectionStartTime;
  log(`[DingTalk][${accountId}] Connection closed after ${Math.round(connectionDuration / 1000)}s`);
  resolve();
});

// 监听重连事件
client.on('reconnect', () => {
  reconnectCount++;
  connectionStartTime = Date.now();
  log(`[DingTalk][${accountId}] Reconnecting... (attempt ${reconnectCount})`);
});

client.on('reconnected', () => {
  log(`[DingTalk][${accountId}] Reconnected successfully after ${reconnectCount} attempts`);
});
```

## 优化效果

### 优化前
```
TERMINATE SOCKET: Ping Pong does not transfer heartbeat within heartbeat intervall
```

### 优化后
```
[DingTalk][account-123] Connection closed after 3600s
[DingTalk][account-123] Reconnecting... (attempt 1)
[DingTalk][account-123] Reconnected successfully after 1 attempts
```

## 影响范围

- ✅ `src/monitor.core.ts` - 核心监控模块
- ✅ `src/monitor-single.ts` - 单账号监控模块

## 相关文件

- `src/monitor.core.ts` - 添加了 debug: false 和连接状态监控
- `src/monitor-single.ts` - 添加了连接状态监控（已有 debug: false）

## 后续建议

1. **监控告警**：如果 `reconnectCount` 频繁增加，可能需要检查网络稳定性
2. **性能优化**：考虑根据重连次数调整重连间隔（指数退避）
3. **SDK 升级**：关注 `dingtalk-stream` SDK 更新，看是否修复了拼写错误

## 参考

- Issue: WebSocket 心跳超时日志优化
- Date: 2026-03-14
- Author: Aone Copilot

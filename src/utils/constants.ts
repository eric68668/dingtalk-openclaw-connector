/**
 * 常量定义模块
 */

/** 默认账号 ID，用于标记单账号模式（无 accounts 配置）时的内部标识 */
export const DEFAULT_ACCOUNT_ID = '__default__';

/** 新会话触发命令 */
export const NEW_SESSION_COMMANDS = ['/new', '/reset', '/clear', '新会话', '重新开始', '清空对话'];

/**
 * 媒体类消息类型集合。
 *
 * 这些消息类型需要通过钉钉原生消息 API 发送，不支持 AI Card 形式，
 * 在 sendProactiveInternal 中会强制跳过 AI Card 路径。
 */
export const MEDIA_MSG_TYPES = new Set(['image', 'voice', 'file', 'video'] as const);

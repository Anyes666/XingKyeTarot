/**
 * 星澜聊天会话管理器（XinglanSessionManager）
 *
 * 管理单次聊天会话的上下文状态：
 *   - 消息历史
 *   - 已用文案 ID 队列（去重窗口：最近 N 条）
 *   - 同主题连续深度计数
 *   - 上一轮情绪/主题记忆
 *
 * MVP 不持久化，页面退出即清空。
 */

import {
  XinglanChatMessage,
  XinglanChatRole,
  XinglanSessionState,
  XinglanEmotionTag,
  XinglanTopicTag,
  XinglanReplyPlan
} from '../types/XinglanTypes';
import { XINGLAN_DEDUP_WINDOW } from '../data/XinglanTemplates';

/**
 * 创建空的会话状态
 */
export function createSessionState(): XinglanSessionState {
  return {
    messages: [],
    usedLineIds: [],
    lastEmotion: XinglanEmotionTag.UNKNOWN,
    sameTopicDepth: 0,
    lastTopic: XinglanTopicTag.UNKNOWN
  };
}

/**
 * 生成消息唯一 ID
 */
function generateMessageId(): string {
  return `msg_${Date.now()}_${Math.floor(Math.random() * 10000)}`;
}

/**
 * 添加用户消息到会话
 */
export function addUserMessage(
  state: XinglanSessionState,
  text: string
): XinglanSessionState {
  const msg: XinglanChatMessage = {
    id: generateMessageId(),
    role: XinglanChatRole.USER,
    text: text,
    time: Date.now()
  };
  state.messages = [...state.messages, msg];
  return state;
}

/**
 * 添加星澜消息到会话，同时记录已用文案 ID
 */
export function addXinglanMessage(
  state: XinglanSessionState,
  text: string,
  lineIds: string[]
): XinglanSessionState {
  const msg: XinglanChatMessage = {
    id: generateMessageId(),
    role: XinglanChatRole.XINGLAN,
    text: text,
    time: Date.now()
  };
  state.messages = [...state.messages, msg];

  // 更新已用文案 ID 队列（只保留最近 N 条）
  const updatedIds: string[] = [...state.usedLineIds, ...lineIds];
  if (updatedIds.length > XINGLAN_DEDUP_WINDOW) {
    state.usedLineIds = updatedIds.slice(updatedIds.length - XINGLAN_DEDUP_WINDOW);
  } else {
    state.usedLineIds = updatedIds;
  }

  return state;
}

/**
 * 更新会话上下文（在生成回复后调用）
 */
export function updateContext(
  state: XinglanSessionState,
  plan: XinglanReplyPlan
): XinglanSessionState {
  // 更新同主题深度
  if (plan.topic === state.lastTopic && plan.topic !== XinglanTopicTag.UNKNOWN) {
    state.sameTopicDepth = state.sameTopicDepth + 1;
  } else {
    state.sameTopicDepth = 1;
  }

  state.lastEmotion = plan.emotion;
  state.lastTopic = plan.topic;

  return state;
}

/**
 * 检查某个文案 ID 是否在去重黑名单中
 */
export function isLineUsed(state: XinglanSessionState, lineId: string): boolean {
  return state.usedLineIds.includes(lineId);
}

/**
 * 获取会话消息数量
 */
export function getMessageCount(state: XinglanSessionState): number {
  return state.messages.length;
}

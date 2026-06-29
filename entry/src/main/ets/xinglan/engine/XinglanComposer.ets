/**
 * 星澜聊天回复拼装器（XinglanComposer）
 *
 * 输入：XinglanReplyPlan + XinglanSessionState
 * 输出：拼接好的星澜回复文本 + 使用的文案 ID
 *
 * 拼装流程：
 *   1. 按策略序列依次从语料池抽取文案
 *   2. 排除 session 内已用的文案 ID（去重）
 *   3. 优先匹配 emotion 子类，fallback 到 ANY
 *   4. 每句之间用空行分隔
 *   5. 末尾追加开放式问题（安全场景不追加）
 *   6. 调用 SafetyGuard 校验输出
 *   7. 校验长度限制
 */

import {
  XinglanReplyPlan,
  XinglanReplyStrategy,
  XinglanEmotionTag,
  XinglanSessionState,
  XinglanComposeResult,
  XinglanChatLine,
  XinglanBoundaryTag,
  XinglanSubTopicTag,
  XinglanSpecialIntent
} from '../types/XinglanTypes';
import {
  getLinesByStrategy,
  CORPUS_SPECIAL_GREETING,
  CORPUS_SPECIAL_THANKS,
  CORPUS_SPECIAL_DENIAL,
  CORPUS_SPECIAL_SILENCE,
  CORPUS_SPECIAL_TOO_SHORT
} from '../data/XinglanCorpus';
import {
  getShortEmotionLines,
  getLoveDesireLines
} from '../data/XinglanShortCorpus';
import {
  checkRelevance
} from './XinglanReplyRelevanceGuard';
import {
  XINGLAN_REPLY_MAX_CHARS,
  XINGLAN_CRISIS_MAX_CHARS
} from '../data/XinglanTemplates';
import { validateOutput } from './XinglanSafetyGuard';

/**
 * 从指定策略池中随机抽取一条未使用的文案
 */
function pickOneLine(
  strategy: XinglanReplyStrategy,
  emotion: XinglanEmotionTag,
  usedIds: string[]
): XinglanChatLine | null {
  // 获取该策略的全部文案
  const allLines: XinglanChatLine[] = getLinesByStrategy(strategy);
  if (allLines.length === 0) {
    return null;
  }

  // 按 emotion 过滤（优先精确匹配，fallback 到 ANY）
  let emotionFiltered: XinglanChatLine[] = allLines.filter(
    (l: XinglanChatLine) => l.emotion === emotion
  );
  if (emotionFiltered.length === 0) {
    emotionFiltered = allLines.filter(
      (l: XinglanChatLine) => l.emotion === XinglanEmotionTag.ANY
    );
  }
  if (emotionFiltered.length === 0) {
    emotionFiltered = allLines;
  }

  // 排除已用的
  const available: XinglanChatLine[] = emotionFiltered.filter(
    (l: XinglanChatLine) => !usedIds.includes(l.id)
  );

  // 如果全部被排除，重置去重窗口（只保留最后 3 条）
  if (available.length === 0) {
    const recentIds: string[] = usedIds.slice(-3);
    const retry: XinglanChatLine[] = emotionFiltered.filter(
      (l: XinglanChatLine) => !recentIds.includes(l.id)
    );
    if (retry.length === 0) {
      // 真的全用过了，从整个池随机取
      return emotionFiltered[Math.floor(Math.random() * emotionFiltered.length)];
    }
    return retry[Math.floor(Math.random() * retry.length)];
  }

  return available[Math.floor(Math.random() * available.length)];
}

/**
 * 获取特殊意图的简短回复
 */
function composeSpecialReply(
  intent: XinglanSpecialIntent
): string {
  const poolMap: Record<string, XinglanChatLine[]> = {
    'GREETING': CORPUS_SPECIAL_GREETING,
    'THANKS': CORPUS_SPECIAL_THANKS,
    'DENIAL': CORPUS_SPECIAL_DENIAL,
    'SILENCE': CORPUS_SPECIAL_SILENCE,
    'TOO_SHORT': CORPUS_SPECIAL_TOO_SHORT
  };

  const pool: XinglanChatLine[] = poolMap[intent] || CORPUS_SPECIAL_SILENCE;
  if (pool.length === 0) {
    return '你可以慢慢说。星澜在这里。';
  }
  const pick: XinglanChatLine = pool[Math.floor(Math.random() * pool.length)];
  return pick.text;
}

/**
 * 拼装星澜回复
 */
export function composeReply(
  plan: XinglanReplyPlan,
  state: XinglanSessionState
): XinglanComposeResult {
  const usedLineIds: string[] = [];

  // 按策略序列逐条抽取
  const parts: string[] = [];
  for (let i = 0; i < plan.strategies.length; i++) {
    const strategy: XinglanReplyStrategy = plan.strategies[i];
    const picked: XinglanChatLine | null = pickOneLine(
      strategy,
      plan.emotion,
      state.usedLineIds
    );
    if (picked) {
      parts.push(picked.text);
      usedLineIds.push(picked.id);
      // 实时更新已用列表，避免本轮内重复
      state.usedLineIds = [...state.usedLineIds, picked.id];
    }
  }

  // 拼接（段落间空行）
  let replyText: string = parts.join('\n\n');

  // 长度限制
  const maxChars: number = plan.boundary === XinglanBoundaryTag.CRISIS
    ? XINGLAN_CRISIS_MAX_CHARS
    : XINGLAN_REPLY_MAX_CHARS;

  if (replyText.length > maxChars) {
    // 截断到最大长度，找到最后一个完整句号
    const truncated: string = replyText.substring(0, maxChars);
    const lastPeriod: number = truncated.lastIndexOf('。');
    if (lastPeriod > maxChars * 0.6) {
      replyText = truncated.substring(0, lastPeriod + 1);
    } else {
      replyText = truncated + '。';
    }
  }

  // 输出安全校验
  const safetyCheck = validateOutput(replyText);
  if (!safetyCheck.passed) {
    replyText = safetyCheck.fallbackText;
  }

  // Phase 4: 相关性检查（短情绪词/想谈恋爱/角色互动）
  replyText = checkRelevance(replyText, plan.subTopic || XinglanSubTopicTag.ANY, plan.boundary, plan.topic, plan.emotion);

  // 确保至少有一点内容
  if (replyText.trim().length === 0) {
    replyText = '星澜在这里。你可以慢慢说。';
  }

  return {
    replyText: replyText,
    usedLineIds: usedLineIds
  };
}

/**
 * 对外入口：处理特殊意图的简短回复
 */
export function getSpecialReply(intent: XinglanSpecialIntent): string {
  return composeSpecialReply(intent);
}

/**
 * 判断回复计划是否为安全边界场景（不做追问）
 */
export function isSafetyBoundaryPlan(plan: XinglanReplyPlan): boolean {
  return plan.boundary === XinglanBoundaryTag.PROFESSIONAL ||
    plan.boundary === XinglanBoundaryTag.CRISIS;
}

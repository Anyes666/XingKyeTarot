/**
 * 星澜策略退避规则引擎（CHAT-2 增量）
 *
 * 对应 V2 计划第 9.2 节 + 占卜计划第 13.3 节的 8 条退避规则：
 *   R1. 每轮最多一个问题
 *   R2. 首次承接不提问
 *   R3. 同策略最多连续两轮
 *   R4. 三轮无新信息时转整理或安静
 *   R5. 拒绝建议后四轮退避
 *   R6. "不想说"后不追问
 *   R7. "你不懂"后回退承接
 *   R8. Safety 优先级最高
 *
 * 职责：
 *   1. detectBackoffSignals — 从用户输入 + 会话状态检测退避信号
 *   2. applyBackoffToPlan — 根据状态元信息 + 退避信号调整 plan.strategies
 *   3. countQuestions — 统计文本问号数量（R1 用）
 *   4. enforceSingleQuestion — 拼装后强制每轮最多1个问号（R1 用）
 *
 * 增量加入，不重写管线；由 XinglanComposer.composeReply 内部调用。
 */

import {
  XinglanBackoffSignal,
  XinglanDialogState,
  XinglanReplyPlan,
  XinglanReplyStrategy,
  XinglanSessionState,
  XinglanAnalysisResult,
  XinglanChatMessage,
  XinglanChatRole,
  XinglanBoundaryTag
} from '../types/XinglanTypes';
import { getDialogStateMeta } from './XinglanDialogStateMachine';

// ═══ R6 "不想说"关键词 ═══
const NOT_WANT_TALK_KEYWORDS: string[] = [
  '不想说', '不想聊', '不想谈', '别问了', '不想提',
  '不想讲了', '不想回忆', '不想想', '不想说这个'
];

// ═══ R7 "你不懂"关键词 ═══
const YOU_DONT_UNDERSTAND_KEYWORDS: string[] = [
  '你不懂', '你理解不了', '你不会懂', '你不明白',
  '你根本不懂', '算了', '跟你说了也没用', '说了你也不懂'
];

// ═══ R5 拒绝建议关键词 ═══
const REJECT_SUGGESTION_KEYWORDS: string[] = [
  '不想试', '不想做', '不适合我', '做不到', '太难了',
  '不想动', '没用的', '试过了', '不想试这个', '今天先不做'
];

// ═══ R8 风险关键词（与 SafetyGuard/Keywords 对齐，这里仅做信号检测）═══
const RISK_KEYWORDS: string[] = [
  '不想活', '活不下去', '想死', '想结束', '自杀', '自残', '伤害自己',
  '不想存在', '结束自己', '了结', '跳下去', '离开这个世界'
];

/**
 * 获取会话中最后一条用户消息文本（用于信号检测）
 */
function getLastUserText(state: XinglanSessionState): string {
  const msgs: XinglanChatMessage[] = state.messages;
  for (let i = msgs.length - 1; i >= 0; i--) {
    if (msgs[i].role === XinglanChatRole.USER) {
      return msgs[i].text;
    }
  }
  return '';
}

/**
 * 文本是否包含任一关键词
 */
function containsAny(text: string, keywords: string[]): boolean {
  const lower: string = text.toLowerCase();
  for (let i = 0; i < keywords.length; i++) {
    if (lower.includes(keywords[i].toLowerCase())) {
      return true;
    }
  }
  return false;
}

/**
 * R1: 统计文本中的问号数量（中文？+ 英文?）
 */
export function countQuestions(text: string): number {
  let count: number = 0;
  for (let i = 0; i < text.length; i++) {
    const ch: string = text.charAt(i);
    if (ch === '？' || ch === '?') {
      count++;
    }
  }
  return count;
}

/**
 * R1: 强制每轮最多1个问号 — 截断到第一个问号后的首个句号/换行
 * 若无问号则原样返回；若多个问号则保留第一个问号所在句，截断后续
 */
export function enforceSingleQuestion(text: string): string {
  const qCount: number = countQuestions(text);
  if (qCount <= 1) {
    return text;
  }
  // 找到第一个问号位置
  const firstQ: number = Math.max(text.indexOf('？'), text.indexOf('?'));
  if (firstQ < 0) {
    return text;
  }
  // 从第一个问号后查找句末（。！.）或换行，截断到那里
  let cutEnd: number = -1;
  for (let i = firstQ + 1; i < text.length; i++) {
    const ch: string = text.charAt(i);
    if (ch === '。' || ch === '！' || ch === '.' || ch === '!' || ch === '\n') {
      cutEnd = i + 1;
      break;
    }
  }
  if (cutEnd > 0) {
    return text.substring(0, cutEnd);
  }
  // 没找到句末，截断到第一个问号后 + 句号
  return text.substring(0, firstQ + 1) + '。';
}

/**
 * 检测本轮退避信号（R2-R8）
 *
 * @param userInput    本轮用户原始输入
 * @param state        会话状态（读取 lastStrategies / sameStrategyStreak / sameTopicStagnant / suggestionCooldownTurns / firstReceiveDone）
 * @param analysis     本轮分析结果
 * @returns 触发的退避信号数组
 */
export function detectBackoffSignals(
  userInput: string,
  state: XinglanSessionState,
  analysis: XinglanAnalysisResult
): XinglanBackoffSignal[] {
  const signals: XinglanBackoffSignal[] = [];

  // R8: Safety 优先级最高 — 风险关键词或 CRISIS 边界
  if (analysis.boundary === XinglanBoundaryTag.CRISIS ||
      containsAny(userInput, RISK_KEYWORDS)) {
    signals.push(XinglanBackoffSignal.RISK_DETECTED);
  }

  // R6: "不想说"后不追问
  if (containsAny(userInput, NOT_WANT_TALK_KEYWORDS)) {
    signals.push(XinglanBackoffSignal.USER_SAYS_NOT_WANT_TALK);
  }

  // R7: "你不懂"后回退承接
  if (containsAny(userInput, YOU_DONT_UNDERSTAND_KEYWORDS)) {
    signals.push(XinglanBackoffSignal.USER_SAYS_YOU_DONT_UNDERSTAND);
  }

  // R5: 拒绝建议后4轮退避
  if (containsAny(userInput, REJECT_SUGGESTION_KEYWORDS)) {
    signals.push(XinglanBackoffSignal.USER_REJECTS_SUGGESTION);
  }

  // R2: 首次承接不提问（当前状态为 RECEIVE 且 firstReceiveDone 未标记）
  const currentState: XinglanDialogState = state.currentState || XinglanDialogState.ENTRY;
  if (currentState === XinglanDialogState.RECEIVE && !state.firstReceiveDone) {
    signals.push(XinglanBackoffSignal.FIRST_RECEIVE);
  }

  // R3: 同策略最多连续两轮（≥2 触发切换信号）
  const streak: number = state.sameStrategyStreak || 0;
  if (streak >= 2) {
    signals.push(XinglanBackoffSignal.SAME_STRATEGY_TWO_ROUNDS);
  }

  // R4: 三轮无新信息时转整理或安静（≥3 触发）
  const stagnant: number = state.sameTopicStagnant || 0;
  if (stagnant >= 3) {
    signals.push(XinglanBackoffSignal.NO_NEW_INFO_THREE_ROUNDS);
  }

  return signals;
}

/**
 * 根据状态元信息 + 退避信号，调整 plan.strategies
 *
 * 调整规则：
 *   - 移除当前状态 forbiddenStrategies 中的策略
 *   - R6"不想说" → 移除所有提问策略（SOFT_QUESTION）
 *   - R5 拒绝建议 + cooldown 期间 → 移除 TINY_STEP
 *   - R3 同策略连续2轮 → 优先切换策略序列
 *
 * @param plan          原始回复计划
 * @param newState      本轮应进入的状态
 * @param signals       退避信号
 * @param state         会话状态
 * @returns 调整后的 plan（新对象，不修改原 plan）
 */
export function applyBackoffToPlan(
  plan: XinglanReplyPlan,
  newState: XinglanDialogState,
  signals: XinglanBackoffSignal[],
  state: XinglanSessionState
): XinglanReplyPlan {
  const meta = getDialogStateMeta(newState);

  // 复制策略序列（不修改原 plan）
  let strategies: XinglanReplyStrategy[] = [...plan.strategies];

  // 1. 移除当前状态禁用的策略
  if (meta.forbiddenStrategies.length > 0) {
    strategies = strategies.filter(
      (s: XinglanReplyStrategy) => !meta.forbiddenStrategies.includes(s)
    );
  }

  // 2. R6 "不想说" → 强制移除所有提问策略
  if (signals.includes(XinglanBackoffSignal.USER_SAYS_NOT_WANT_TALK)) {
    strategies = strategies.filter(
      (s: XinglanReplyStrategy) => s !== XinglanReplyStrategy.SOFT_QUESTION
    );
  }

  // 3. R5 拒绝建议后4轮退避 — cooldown 期间移除 TINY_STEP
  const cooldown: number = state.suggestionCooldownTurns || 0;
  if (cooldown > 0) {
    strategies = strategies.filter(
      (s: XinglanReplyStrategy) => s !== XinglanReplyStrategy.TINY_STEP
    );
  }

  // 4. R2 首次承接不提问 — RECEIVE 状态本身 forbiddenStrategies 已含 SOFT_QUESTION，双保险
  if (signals.includes(XinglanBackoffSignal.FIRST_RECEIVE)) {
    strategies = strategies.filter(
      (s: XinglanReplyStrategy) => s !== XinglanReplyStrategy.SOFT_QUESTION
    );
  }

  // 5. R3 同策略连续2轮 — 若上一轮策略序列与当前完全相同，强制替换首个策略
  if (signals.includes(XinglanBackoffSignal.SAME_STRATEGY_TWO_ROUNDS)) {
    const lastStrats: XinglanReplyStrategy[] = state.lastStrategies || [];
    if (lastStrats.length > 0 && strategies.length > 0) {
      // 检查是否完全相同
      let identical: boolean = strategies.length === lastStrats.length;
      if (identical) {
        for (let i = 0; i < strategies.length; i++) {
          if (strategies[i] !== lastStrats[i]) {
            identical = false;
            break;
          }
        }
      }
      if (identical && strategies.length > 1) {
        // 将首个策略移到末尾，切换主策略
        const first: XinglanReplyStrategy = strategies[0];
        strategies = strategies.slice(1);
        strategies.push(first);
      }
    }
  }

  // 6. 兜底：若策略被清空，至少保留 HOLD_EMOTION
  if (strategies.length === 0) {
    strategies = [XinglanReplyStrategy.HOLD_EMOTION];
  }

  // 7. allowFollowUp 受状态可提问性约束
  const allowFollowUp: boolean = meta.allowQuestion && (plan.allowFollowUp !== false);

  return {
    emotion: plan.emotion,
    topic: plan.topic,
    boundary: plan.boundary,
    subTopic: plan.subTopic,
    strategies: strategies,
    slots: plan.slots,
    allowFollowUp: allowFollowUp,
    forceShortCircuit: plan.forceShortCircuit
  };
}

/**
 * 记录轮次结束 — 更新状态机的退避计数器
 *
 * 在 composeReply 拼装完成后调用，更新：
 *   - lastStrategies（本轮使用的策略）
 *   - sameStrategyStreak（与上一轮相同则+1，否则重置1）
 *   - sameTopicStagnant（同主题无新信息计数）
 *   - suggestionCooldownTurns（拒绝建议后递减）
 *   - firstReceiveDone（首次承接后标记）
 *   - stateRoundsCount / currentState（由状态机转移结果更新）
 *   - totalTurns
 *
 * @param state         会话状态（原地更新）
 * @param usedPlan      本轮实际使用的 plan（经退避调整后）
 * @param newState      本轮进入的状态
 * @param stateChanged  是否发生状态转移
 * @param analysis      本轮分析结果
 */
export function recordTurnEnd(
  state: XinglanSessionState,
  usedPlan: XinglanReplyPlan,
  newState: XinglanDialogState,
  stateChanged: boolean,
  analysis: XinglanAnalysisResult
): void {
  const prevStrategies: XinglanReplyStrategy[] = state.lastStrategies || [];
  const currentStrategies: XinglanReplyStrategy[] = usedPlan.strategies;

  // 同策略连续检测：与上一轮完全相同则 streak+1，否则重置为1
  let streak: number = 1;
  if (prevStrategies.length > 0 && prevStrategies.length === currentStrategies.length) {
    let identical: boolean = true;
    for (let i = 0; i < currentStrategies.length; i++) {
      if (prevStrategies[i] !== currentStrategies[i]) {
        identical = false;
        break;
      }
    }
    if (identical) {
      streak = (state.sameStrategyStreak || 0) + 1;
    }
  }
  state.lastStrategies = currentStrategies;
  state.sameStrategyStreak = streak;

  // 同主题无新信息检测：主题相同且无新 subTopic → stagnant+1，否则重置
  if (analysis.topic === state.lastTopic && analysis.topic !== undefined &&
      state.sameTopicDepth > 0) {
    state.sameTopicStagnant = (state.sameTopicStagnant || 0) + 1;
  } else {
    state.sameTopicStagnant = 0;
  }

  // 拒绝建议后4轮退避：若本轮拒绝建议，置 cooldown=4；否则递减
  if (analysis.boundary !== XinglanBoundaryTag.CRISIS) {
    const userInput: string = getLastUserText(state);
    if (containsAny(userInput, REJECT_SUGGESTION_KEYWORDS)) {
      state.suggestionCooldownTurns = 4;
    } else if ((state.suggestionCooldownTurns || 0) > 0) {
      state.suggestionCooldownTurns = (state.suggestionCooldownTurns || 0) - 1;
    }
  }

  // 首次承接标记：进入 RECEIVE 后标记
  if (newState === XinglanDialogState.RECEIVE) {
    state.firstReceiveDone = true;
  }

  // 状态轮次计数
  if (stateChanged) {
    state.currentState = newState;
    state.stateRoundsCount = 1;
  } else {
    state.currentState = newState;
    state.stateRoundsCount = (state.stateRoundsCount || 0) + 1;
  }

  // 总轮次
  state.totalTurns = (state.totalTurns || 0) + 1;
}

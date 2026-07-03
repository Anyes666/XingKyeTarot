/**
 * 星澜十二状态机引擎（CHAT-2 增量）
 *
 * 对应 V2 计划第 9.2 节 + ch4b 状态机文档 12 状态设计。
 * 增量加入，不重写管线；接入点在 XinglanComposer.composeReply 内部。
 *
 * 职责：
 *   1. 提供 12 状态元信息表（可否提问/最大轮次/可否建议/禁用策略）
 *   2. 根据当前状态 + 分析结果 + 退避信号，决策下一状态
 *   3. Safety 优先级最高：任何状态检测到风险 → 立即跳转 SAFETY
 *
 * 状态转移依据 ch4b 文档 Mermaid 图，结合用户要求的 12 状态命名。
 */

import {
  XinglanDialogState,
  XinglanDialogStateMeta,
  XinglanBackoffSignal,
  XinglanReplyStrategy,
  XinglanBoundaryTag,
  XinglanEmotionTag,
  XinglanTopicTag,
  XinglanAnalysisResult,
  XinglanStateTransitionResult
} from '../types/XinglanTypes';

// ═══ 12 状态元信息表 ═══
// 依据 ch4b 文档每状态的「是否允许提问 / 一次最多提问数 / 连续轮次切换 / 是否允许给建议」
// forbiddenStrategies：该状态禁止使用的策略（退避规则据此过滤 plan.strategies）

const STATE_META_ENTRY: XinglanDialogStateMeta = {
  state: XinglanDialogState.ENTRY,
  allowQuestion: true,
  maxConsecutiveRounds: 1,
  canGiveSuggestion: false,
  forbiddenStrategies: [
    XinglanReplyStrategy.TINY_STEP,         // 禁止过早给建议
    XinglanReplyStrategy.SAFETY_BOUNDARY    // 非安全场景不用安全策略
  ]
};

const STATE_META_RECEIVE: XinglanDialogStateMeta = {
  state: XinglanDialogState.RECEIVE,
  allowQuestion: false,                     // 首次承接不提问
  maxConsecutiveRounds: 3,
  canGiveSuggestion: false,
  forbiddenStrategies: [
    XinglanReplyStrategy.SOFT_QUESTION,     // 承接期不提问
    XinglanReplyStrategy.TINY_STEP,         // 不给建议
    XinglanReplyStrategy.CLARIFY            // 不分析澄清
  ]
};

const STATE_META_CLARIFY: XinglanDialogStateMeta = {
  state: XinglanDialogState.CLARIFY,
  allowQuestion: true,
  maxConsecutiveRounds: 3,
  canGiveSuggestion: false,
  forbiddenStrategies: [
    XinglanReplyStrategy.TINY_STEP,
    XinglanReplyStrategy.SAFETY_BOUNDARY
  ]
};

const STATE_META_CAUSE_FOCUS: XinglanDialogStateMeta = {
  state: XinglanDialogState.CAUSE_FOCUS,
  allowQuestion: true,
  maxConsecutiveRounds: 4,
  canGiveSuggestion: false,
  forbiddenStrategies: [
    XinglanReplyStrategy.TINY_STEP,
    XinglanReplyStrategy.SAFETY_BOUNDARY
  ]
};

const STATE_META_COMFORT: XinglanDialogStateMeta = {
  state: XinglanDialogState.COMFORT,
  allowQuestion: false,                     // 安慰不分析、不追问
  maxConsecutiveRounds: 3,
  canGiveSuggestion: false,
  forbiddenStrategies: [
    XinglanReplyStrategy.SOFT_QUESTION,
    XinglanReplyStrategy.TINY_STEP,
    XinglanReplyStrategy.CLARIFY
  ]
};

const STATE_META_QUIET: XinglanDialogStateMeta = {
  state: XinglanDialogState.QUIET,
  allowQuestion: false,
  maxConsecutiveRounds: 99,                 // 按时间收束，非轮次
  canGiveSuggestion: false,
  forbiddenStrategies: [
    XinglanReplyStrategy.SOFT_QUESTION,
    XinglanReplyStrategy.TINY_STEP,
    XinglanReplyStrategy.CLARIFY,
    XinglanReplyStrategy.REFLECT,
    XinglanReplyStrategy.HOLD_EMOTION
  ]
};

const STATE_META_ORGANIZE: XinglanDialogStateMeta = {
  state: XinglanDialogState.ORGANIZE,
  allowQuestion: true,                      // 仅确认性提问"我理解得对吗？"
  maxConsecutiveRounds: 3,
  canGiveSuggestion: false,                 // 整理≠建议
  forbiddenStrategies: [
    XinglanReplyStrategy.TINY_STEP,
    XinglanReplyStrategy.SAFETY_BOUNDARY
  ]
};

const STATE_META_MICRO_ACTION: XinglanDialogStateMeta = {
  state: XinglanDialogState.MICRO_ACTION,
  allowQuestion: true,
  maxConsecutiveRounds: 2,
  canGiveSuggestion: true,                  // 唯一可给建议的状态（限定1个微小行动）
  forbiddenStrategies: [
    XinglanReplyStrategy.SAFETY_BOUNDARY
  ]
};

const STATE_META_CALMING: XinglanDialogStateMeta = {
  state: XinglanDialogState.CALMING,
  allowQuestion: false,
  maxConsecutiveRounds: 2,
  canGiveSuggestion: false,
  forbiddenStrategies: [
    XinglanReplyStrategy.SOFT_QUESTION,
    XinglanReplyStrategy.TINY_STEP,
    XinglanReplyStrategy.CLARIFY
  ]
};

const STATE_META_CLOSE: XinglanDialogStateMeta = {
  state: XinglanDialogState.CLOSE,
  allowQuestion: false,
  maxConsecutiveRounds: 2,
  canGiveSuggestion: false,
  forbiddenStrategies: [
    XinglanReplyStrategy.SOFT_QUESTION,
    XinglanReplyStrategy.TINY_STEP,
    XinglanReplyStrategy.CLARIFY,
    XinglanReplyStrategy.REFLECT
  ]
};

const STATE_META_BOUNDARY: XinglanDialogStateMeta = {
  state: XinglanDialogState.BOUNDARY,
  allowQuestion: false,                     // 边界场景不追问
  maxConsecutiveRounds: 2,
  canGiveSuggestion: false,
  forbiddenStrategies: [
    XinglanReplyStrategy.SOFT_QUESTION,
    XinglanReplyStrategy.TINY_STEP
  ]
};

const STATE_META_SAFETY: XinglanDialogStateMeta = {
  state: XinglanDialogState.SAFETY,
  allowQuestion: false,                     // 风险场景禁止追问细节
  maxConsecutiveRounds: 2,
  canGiveSuggestion: false,                 // 不给"如何自愈"建议，仅引导现实支持
  forbiddenStrategies: [
    XinglanReplyStrategy.SOFT_QUESTION,
    XinglanReplyStrategy.TINY_STEP,
    XinglanReplyStrategy.CLARIFY,
    XinglanReplyStrategy.REFLECT,
    XinglanReplyStrategy.TAROT_METAPHOR
  ]
};

// 状态元信息索引表
const DIALOG_STATE_META: XinglanDialogStateMeta[] = [
  STATE_META_ENTRY, STATE_META_RECEIVE, STATE_META_CLARIFY, STATE_META_CAUSE_FOCUS,
  STATE_META_COMFORT, STATE_META_QUIET, STATE_META_ORGANIZE, STATE_META_MICRO_ACTION,
  STATE_META_CALMING, STATE_META_CLOSE, STATE_META_BOUNDARY, STATE_META_SAFETY
];

/**
 * 获取指定状态的元信息（缺省返回 ENTRY 元信息）
 */
export function getDialogStateMeta(state: XinglanDialogState): XinglanDialogStateMeta {
  for (let i = 0; i < DIALOG_STATE_META.length; i++) {
    if (DIALOG_STATE_META[i].state === state) {
      return DIALOG_STATE_META[i];
    }
  }
  return STATE_META_ENTRY;
}

/**
 * 获取初始状态（新会话/无状态时）
 */
export function getInitialState(): XinglanDialogState {
  return XinglanDialogState.ENTRY;
}

/**
 * 从分析结果推断"目标状态倾向"（不考虑退避信号时的自然流向）
 *
 * 依据 ch4b 转移图 + 边界优先级：
 *   CRISIS/PROFESSIONAL/风险信号 → SAFETY
 *   ROLE_BOUNDARY/ADULT_BOUNDARY/PREDICTION → BOUNDARY
 *   有情绪表达 → RECEIVE（首次）或保持在 RECEIVE/CLARIFY
 *   CHOICE 主题 + 想理清 → ORGANIZE
 *   TIRED + 想要小行动 → MICRO_ACTION
 */
function inferTargetStateFromAnalysis(
  analysis: XinglanAnalysisResult,
  signals: XinglanBackoffSignal[]
): XinglanDialogState {
  // Safety 优先级最高
  if (signals.includes(XinglanBackoffSignal.RISK_DETECTED) ||
      analysis.boundary === XinglanBoundaryTag.CRISIS) {
    return XinglanDialogState.SAFETY;
  }

  // 边界类（角色/成人/预测/专业非危机）
  if (analysis.boundary === XinglanBoundaryTag.PROFESSIONAL ||
      analysis.boundary === XinglanBoundaryTag.ROLE_BOUNDARY ||
      analysis.boundary === XinglanBoundaryTag.ADULT_BOUNDARY ||
      analysis.boundary === XinglanBoundaryTag.PREDICTION) {
    return XinglanDialogState.BOUNDARY;
  }

  // "你不懂" → 回退承接
  if (signals.includes(XinglanBackoffSignal.USER_SAYS_YOU_DONT_UNDERSTAND)) {
    return XinglanDialogState.RECEIVE;
  }

  // "不想说" → 安静陪伴
  if (signals.includes(XinglanBackoffSignal.USER_SAYS_NOT_WANT_TALK)) {
    return XinglanDialogState.QUIET;
  }

  // 3轮无新信息 → 转整理或安静
  if (signals.includes(XinglanBackoffSignal.NO_NEW_INFO_THREE_ROUNDS)) {
    return XinglanDialogState.ORGANIZE;
  }

  // 拒绝建议 → 退避期不进入 MICRO_ACTION，转 CALMING
  if (signals.includes(XinglanBackoffSignal.USER_REJECTS_SUGGESTION)) {
    return XinglanDialogState.CALMING;
  }

  // 有情绪表达 → RECEIVE（首次承接不提问由状态元信息保证）
  if (analysis.emotion !== XinglanEmotionTag.UNKNOWN &&
      analysis.emotion !== XinglanEmotionTag.ANY) {
    return XinglanDialogState.RECEIVE;
  }

  // 选择类主题 → 倾向整理
  if (analysis.topic === XinglanTopicTag.CHOICE) {
    return XinglanDialogState.ORGANIZE;
  }

  return XinglanDialogState.RECEIVE;
}

/**
 * 状态转移决策（核心函数）
 *
 * 决策优先级（从高到低）：
 *   1. RISK_DETECTED → SAFETY（无条件跳转）
 *   2. 边界类 → BOUNDARY
 *   3. 退避信号（不想说/你不懂/拒绝建议/3轮无新信息）
 *   4. 当前状态超限（maxConsecutiveRounds）→ 按转移图自然流出
 *   5. 分析结果推断的目标状态
 *   6. 保持当前状态
 *
 * @param currentState   当前状态
 * @param stateRounds    当前状态已连续轮次
 * @param analysis       本轮分析结果
 * @param signals        本轮触发的退避信号
 * @returns { newState, stateChanged, reason }
 */
export function resolveNextState(
  currentState: XinglanDialogState,
  stateRounds: number,
  analysis: XinglanAnalysisResult,
  signals: XinglanBackoffSignal[]
): XinglanStateTransitionResult {
  const result: XinglanStateTransitionResult = {
    newState: currentState,
    stateChanged: false,
    reason: '保持当前状态'
  };

  // 1. Safety 优先级最高（任何状态检测到风险 → 立即 SAFETY）
  if (signals.includes(XinglanBackoffSignal.RISK_DETECTED) ||
      analysis.boundary === XinglanBoundaryTag.CRISIS) {
    if (currentState !== XinglanDialogState.SAFETY) {
      result.newState = XinglanDialogState.SAFETY;
      result.stateChanged = true;
      result.reason = '风险信号→SAFETY（最高优先级）';
      return result;
    }
    result.newState = XinglanDialogState.SAFETY;
    result.stateChanged = false;
    result.reason = '已处于SAFETY';
    return result;
  }

  // 2. 边界类 → BOUNDARY
  if (analysis.boundary === XinglanBoundaryTag.PROFESSIONAL ||
      analysis.boundary === XinglanBoundaryTag.ROLE_BOUNDARY ||
      analysis.boundary === XinglanBoundaryTag.ADULT_BOUNDARY ||
      analysis.boundary === XinglanBoundaryTag.PREDICTION) {
    if (currentState !== XinglanDialogState.BOUNDARY) {
      result.newState = XinglanDialogState.BOUNDARY;
      result.stateChanged = true;
      result.reason = '边界类信号→BOUNDARY';
      return result;
    }
  }

  // 3. "你不懂" → 回退承接（无论当前状态）
  if (signals.includes(XinglanBackoffSignal.USER_SAYS_YOU_DONT_UNDERSTAND)) {
    result.newState = XinglanDialogState.RECEIVE;
    result.stateChanged = currentState !== XinglanDialogState.RECEIVE;
    result.reason = '"你不懂"→回退RECEIVE';
    return result;
  }

  // 4. "不想说" → QUIET
  if (signals.includes(XinglanBackoffSignal.USER_SAYS_NOT_WANT_TALK)) {
    result.newState = XinglanDialogState.QUIET;
    result.stateChanged = currentState !== XinglanDialogState.QUIET;
    result.reason = '"不想说"→QUIET';
    return result;
  }

  // 5. 拒绝建议 → CALMING（并触发4轮退避，由 BackoffRules 维护 cooldown）
  if (signals.includes(XinglanBackoffSignal.USER_REJECTS_SUGGESTION)) {
    result.newState = XinglanDialogState.CALMING;
    result.stateChanged = currentState !== XinglanDialogState.CALMING;
    result.reason = '拒绝建议→CALMING（进入4轮退避）';
    return result;
  }

  // 6. 3轮无新信息 → ORGANIZE
  if (signals.includes(XinglanBackoffSignal.NO_NEW_INFO_THREE_ROUNDS)) {
    result.newState = XinglanDialogState.ORGANIZE;
    result.stateChanged = currentState !== XinglanDialogState.ORGANIZE;
    result.reason = '3轮无新信息→ORGANIZE';
    return result;
  }

  // 7. 当前状态超限 → 按转移图自然流出
  const meta: XinglanDialogStateMeta = getDialogStateMeta(currentState);
  if (stateRounds >= meta.maxConsecutiveRounds) {
    const outflow: XinglanDialogState = resolveOutflowOnLimit(currentState, analysis);
    result.newState = outflow;
    result.stateChanged = true;
    result.reason = `${currentState}连续${stateRounds}轮超限→${outflow}`;
    return result;
  }

  // 8. 分析结果推断目标状态（仅在目标与当前不同时转移）
  const target: XinglanDialogState = inferTargetStateFromAnalysis(analysis, signals);
  if (target !== currentState) {
    result.newState = target;
    result.stateChanged = true;
    result.reason = `分析推断→${target}`;
    return result;
  }

  // 9. 保持当前状态
  return result;
}

/**
 * 状态超限时按转移图决定流出目标
 * 依据 ch4b Mermaid 图每状态的退出条件
 */
function resolveOutflowOnLimit(
  currentState: XinglanDialogState,
  analysis: XinglanAnalysisResult
): XinglanDialogState {
  if (currentState === XinglanDialogState.ENTRY) {
    // 1轮后必须转出：有情绪→RECEIVE，否则 QUIET
    if (analysis.emotion !== XinglanEmotionTag.UNKNOWN &&
        analysis.emotion !== XinglanEmotionTag.ANY) {
      return XinglanDialogState.RECEIVE;
    }
    return XinglanDialogState.QUIET;
  }
  if (currentState === XinglanDialogState.RECEIVE) {
    // 3轮后：转 CLARIFY 或 CAUSE_FOCUS 或 QUIET
    return XinglanDialogState.CAUSE_FOCUS;
  }
  if (currentState === XinglanDialogState.CLARIFY) {
    return XinglanDialogState.ORGANIZE;
  }
  if (currentState === XinglanDialogState.CAUSE_FOCUS) {
    // 4轮后转整理或安静
    return XinglanDialogState.ORGANIZE;
  }
  if (currentState === XinglanDialogState.COMFORT) {
    return XinglanDialogState.CALMING;
  }
  if (currentState === XinglanDialogState.ORGANIZE) {
    return XinglanDialogState.MICRO_ACTION;
  }
  if (currentState === XinglanDialogState.MICRO_ACTION) {
    return XinglanDialogState.CALMING;
  }
  if (currentState === XinglanDialogState.CALMING) {
    return XinglanDialogState.CLOSE;
  }
  if (currentState === XinglanDialogState.CLOSE ||
      currentState === XinglanDialogState.BOUNDARY ||
      currentState === XinglanDialogState.SAFETY) {
    return XinglanDialogState.CLOSE;
  }
  return XinglanDialogState.RECEIVE;
}

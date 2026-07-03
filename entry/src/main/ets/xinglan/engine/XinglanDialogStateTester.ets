/**
 * 星澜十二状态机与退避规则验证器（CHAT-2 增量）
 *
 * 对应 V2 计划第 9.2 节验收要点：
 *   1. 十二状态全部落地，含状态转移条件
 *   2. 退避规则全部生效（同策略≤2轮、拒绝建议后4轮退避等）
 *
 * 纯函数测试，不接入 UI，不依赖随机性。
 * 直接调用 detectBackoffSignals / resolveNextState / applyBackoffToPlan / enforceSingleQuestion，
 * 避开 composeReply 的随机语料抽取，保证可复现。
 *
 * 调用方式：runDialogStateTests() 返回 string[] 报告行。
 */

import {
  XinglanDialogState,
  XinglanBackoffSignal,
  XinglanReplyStrategy,
  XinglanReplyPlan,
  XinglanSessionState,
  XinglanAnalysisResult,
  XinglanEmotionTag,
  XinglanTopicTag,
  XinglanBoundaryTag,
  XinglanSubTopicTag,
  XinglanSpecialIntent,
  XinglanChatRole
} from '../types/XinglanTypes';
import { resolveNextState, getInitialState, getDialogStateMeta } from './XinglanDialogStateMachine';
import {
  detectBackoffSignals,
  applyBackoffToPlan,
  recordTurnEnd,
  enforceSingleQuestion,
  countQuestions
} from './XinglanBackoffRules';

// ═══ 测试辅助 ═══

interface TestResult {
  name: string;
  passed: boolean;
  detail: string;
}

function makeState(): XinglanSessionState {
  return {
    messages: [],
    usedLineIds: [],
    lastEmotion: XinglanEmotionTag.UNKNOWN,
    lastTopic: XinglanTopicTag.UNKNOWN,
    sameTopicDepth: 0,
    currentState: XinglanDialogState.ENTRY,
    stateRoundsCount: 0,
    lastStrategies: [],
    sameStrategyStreak: 0,
    sameTopicStagnant: 0,
    suggestionCooldownTurns: 0,
    firstReceiveDone: false,
    totalTurns: 0
  };
}

function makeAnalysis(
  emotion: XinglanEmotionTag,
  topic: XinglanTopicTag,
  boundary: XinglanBoundaryTag
): XinglanAnalysisResult {
  return {
    emotion: emotion,
    topic: topic,
    boundary: boundary,
    subTopic: XinglanSubTopicTag.ANY,
    specialIntent: XinglanSpecialIntent.NONE,
    score: 1
  };
}

function makePlan(strategies: XinglanReplyStrategy[]): XinglanReplyPlan {
  return {
    emotion: XinglanEmotionTag.SAD,
    topic: XinglanTopicTag.SELF,
    boundary: XinglanBoundaryTag.NONE,
    subTopic: XinglanSubTopicTag.ANY,
    strategies: strategies,
    allowFollowUp: true,
    forceShortCircuit: false
  };
}

function addUserText(state: XinglanSessionState, text: string): void {
  state.messages = [...state.messages, {
    id: `u_${state.messages.length}`,
    role: XinglanChatRole.USER,
    text: text,
    time: Date.now()
  }];
}

const PASS: string = 'PASS';
const FAIL: string = 'FAIL';
let passCount: number = 0;
let failCount: number = 0;

function check(name: string, condition: boolean, detail: string, results: TestResult[]): void {
  if (condition) {
    passCount++;
    results.push({ name: name, passed: true, detail: detail });
  } else {
    failCount++;
    results.push({ name: name, passed: false, detail: detail });
  }
}

// ═══ 状态转移测试（覆盖 12 状态 + 转移条件）═══

function testStateTransitions(results: TestResult[]): void {
  // T1: 初始状态 = ENTRY
  check('T1 初始状态=ENTRY', getInitialState() === XinglanDialogState.ENTRY,
    `expected=ENTRY actual=${getInitialState()}`, results);

  // T2: ENTRY + 有情绪 → RECEIVE
  {
    const s = makeState();
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.ENTRY, 0, a, []);
    check('T2 ENTRY+情绪→RECEIVE',
      t.newState === XinglanDialogState.RECEIVE && t.stateChanged,
      `expected=RECEIVE actual=${t.newState} reason=${t.reason}`, results);
  }

  // T3: 任意状态 + 风险信号 → SAFETY（优先级最高）
  {
    const s = makeState();
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.RECEIVE, 1, a, [XinglanBackoffSignal.RISK_DETECTED]);
    check('T3 RECEIVE+风险→SAFETY',
      t.newState === XinglanDialogState.SAFETY && t.stateChanged,
      `expected=SAFETY actual=${t.newState} reason=${t.reason}`, results);
  }

  // T4: CRISIS 边界 → SAFETY（无需显式信号）
  {
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.CRISIS);
    const t = resolveNextState(XinglanDialogState.CAUSE_FOCUS, 1, a, []);
    check('T4 CRISIS边界→SAFETY',
      t.newState === XinglanDialogState.SAFETY && t.stateChanged,
      `expected=SAFETY actual=${t.newState} reason=${t.reason}`, results);
  }

  // T5: "你不懂" → 回退 RECEIVE
  {
    const a = makeAnalysis(XinglanEmotionTag.ANGRY, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.CAUSE_FOCUS, 1, a,
      [XinglanBackoffSignal.USER_SAYS_YOU_DONT_UNDERSTAND]);
    check('T5 CAUSE_FOCUS+你不懂→RECEIVE',
      t.newState === XinglanDialogState.RECEIVE && t.stateChanged,
      `expected=RECEIVE actual=${t.newState} reason=${t.reason}`, results);
  }

  // T6: "不想说" → QUIET
  {
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.RECEIVE, 1, a,
      [XinglanBackoffSignal.USER_SAYS_NOT_WANT_TALK]);
    check('T6 RECEIVE+不想说→QUIET',
      t.newState === XinglanDialogState.QUIET && t.stateChanged,
      `expected=QUIET actual=${t.newState} reason=${t.reason}`, results);
  }

  // T7: 拒绝建议 → CALMING
  {
    const a = makeAnalysis(XinglanEmotionTag.TIRED, XinglanTopicTag.WORK, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.MICRO_ACTION, 1, a,
      [XinglanBackoffSignal.USER_REJECTS_SUGGESTION]);
    check('T7 MICRO_ACTION+拒绝→CALMING',
      t.newState === XinglanDialogState.CALMING && t.stateChanged,
      `expected=CALMING actual=${t.newState} reason=${t.reason}`, results);
  }

  // T8: 3轮无新信息 → ORGANIZE
  {
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.CAUSE_FOCUS, 1, a,
      [XinglanBackoffSignal.NO_NEW_INFO_THREE_ROUNDS]);
    check('T8 CAUSE_FOCUS+3轮无新信息→ORGANIZE',
      t.newState === XinglanDialogState.ORGANIZE && t.stateChanged,
      `expected=ORGANIZE actual=${t.newState} reason=${t.reason}`, results);
  }

  // T9: ROLE_BOUNDARY 边界 → BOUNDARY
  {
    const a = makeAnalysis(XinglanEmotionTag.ANY, XinglanTopicTag.ROLE_INTERACTION, XinglanBoundaryTag.ROLE_BOUNDARY);
    const t = resolveNextState(XinglanDialogState.RECEIVE, 1, a, []);
    check('T9 ROLE_BOUNDARY→BOUNDARY',
      t.newState === XinglanDialogState.BOUNDARY && t.stateChanged,
      `expected=BOUNDARY actual=${t.newState} reason=${t.reason}`, results);
  }

  // T10: CAUSE_FOCUS 连续4轮超限 → ORGANIZE
  {
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.CAUSE_FOCUS, 4, a, []);
    check('T10 CAUSE_FOCUS连续4轮超限→ORGANIZE',
      t.newState === XinglanDialogState.ORGANIZE && t.stateChanged,
      `expected=ORGANIZE actual=${t.newState} reason=${t.reason}`, results);
  }

  // T11: RECEIVE 连续3轮超限 → CAUSE_FOCUS
  {
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.RECEIVE, 3, a, []);
    check('T11 RECEIVE连续3轮超限→CAUSE_FOCUS',
      t.newState === XinglanDialogState.CAUSE_FOCUS && t.stateChanged,
      `expected=CAUSE_FOCUS actual=${t.newState} reason=${t.reason}`, results);
  }

  // T12: 保持当前状态（无信号、未超限、目标与当前一致）
  {
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.RECEIVE, 1, a, []);
    check('T12 RECEIVE无信号保持',
      t.newState === XinglanDialogState.RECEIVE && !t.stateChanged,
      `expected=RECEIVE(保持) actual=${t.newState} reason=${t.reason}`, results);
  }

  // T13: 12状态元信息全部可获取
  {
    let allOk = true;
    const allStates: XinglanDialogState[] = [
      XinglanDialogState.ENTRY, XinglanDialogState.RECEIVE, XinglanDialogState.CLARIFY,
      XinglanDialogState.CAUSE_FOCUS, XinglanDialogState.COMFORT, XinglanDialogState.QUIET,
      XinglanDialogState.ORGANIZE, XinglanDialogState.MICRO_ACTION, XinglanDialogState.CALMING,
      XinglanDialogState.CLOSE, XinglanDialogState.BOUNDARY, XinglanDialogState.SAFETY
    ];
    for (let i = 0; i < allStates.length; i++) {
      const meta = getDialogStateMeta(allStates[i]);
      if (meta.state !== allStates[i]) {
        allOk = false;
        break;
      }
    }
    check('T13 12状态元信息齐全', allOk, `共${allStates.length}个状态`, results);
  }
}

// ═══ 退避规则测试（8条）═══

function testBackoffRules(results: TestResult[]): void {
  // R1: 每轮最多一个问题
  {
    const multi = '你好吗？最近还好吗？还在想那件事吗？';
    const enforced = enforceSingleQuestion(multi);
    check('R1 每轮最多1问号',
      countQuestions(enforced) <= 1,
      `input问号数=${countQuestions(multi)} output问号数=${countQuestions(enforced)}`, results);
  }
  {
    const single = '我在这里。可以慢慢说。';
    check('R1 单问号不变',
      enforceSingleQuestion(single) === single,
      `input=${single}`, results);
  }

  // R2: 首次承接不提问
  {
    const s = makeState();
    s.currentState = XinglanDialogState.RECEIVE;
    s.firstReceiveDone = false;
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('我很难过', s, a);
    check('R2 首次承接触发FIRST_RECEIVE信号',
      signals.includes(XinglanBackoffSignal.FIRST_RECEIVE),
      `signals=${signals.join(',')}`, results);
  }
  {
    const s = makeState();
    s.currentState = XinglanDialogState.RECEIVE;
    s.firstReceiveDone = false;
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('我很难过', s, a);
    const plan = makePlan([XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.SOFT_QUESTION]);
    const adjusted = applyBackoffToPlan(plan, XinglanDialogState.RECEIVE, signals, s);
    check('R2 首次承接移除SOFT_QUESTION',
      !adjusted.strategies.includes(XinglanReplyStrategy.SOFT_QUESTION),
      `adjusted=${adjusted.strategies.join(',')}`, results);
  }

  // R3: 同策略最多连续两轮
  {
    const s = makeState();
    s.sameStrategyStreak = 2;
    s.lastStrategies = [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT];
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('还是难过', s, a);
    check('R3 同策略2轮触发信号',
      signals.includes(XinglanBackoffSignal.SAME_STRATEGY_TWO_ROUNDS),
      `streak=${s.sameStrategyStreak} signals=${signals.join(',')}`, results);
  }
  {
    const s = makeState();
    s.sameStrategyStreak = 2;
    s.lastStrategies = [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION];
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('还是难过', s, a);
    const plan = makePlan([XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]);
    const adjusted = applyBackoffToPlan(plan, XinglanDialogState.CAUSE_FOCUS, signals, s);
    // 同策略2轮触发后，首个策略被移到末尾，策略序列应与原序列不同
    const same: boolean = adjusted.strategies.length === 3 &&
      adjusted.strategies[0] === XinglanReplyStrategy.HOLD_EMOTION &&
      adjusted.strategies[1] === XinglanReplyStrategy.REFLECT;
    check('R3 同策略2轮触发切换',
      !same,
      `原=[HOLD_EMOTION,REFLECT,SOFT_QUESTION] 调整后=${adjusted.strategies.join(',')}`, results);
  }

  // R4: 三轮无新信息时转整理或安静
  {
    const s = makeState();
    s.sameTopicStagnant = 3;
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('还是难过', s, a);
    check('R4 3轮无新信息触发信号',
      signals.includes(XinglanBackoffSignal.NO_NEW_INFO_THREE_ROUNDS),
      `stagnant=${s.sameTopicStagnant} signals=${signals.join(',')}`, results);
  }

  // R5: 拒绝建议后四轮退避
  {
    const s = makeState();
    s.currentState = XinglanDialogState.MICRO_ACTION;
    addUserText(s, '不想试，做不到');
    const a = makeAnalysis(XinglanEmotionTag.TIRED, XinglanTopicTag.WORK, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('不想试，做不到', s, a);
    check('R5 拒绝建议触发信号',
      signals.includes(XinglanBackoffSignal.USER_REJECTS_SUGGESTION),
      `signals=${signals.join(',')}`, results);
  }
  {
    // 模拟拒绝后4轮退避：cooldown=4 期间 TINY_STEP 被移除
    const s = makeState();
    s.suggestionCooldownTurns = 4;
    s.currentState = XinglanDialogState.CALMING;
    const a = makeAnalysis(XinglanEmotionTag.TIRED, XinglanTopicTag.WORK, XinglanBoundaryTag.NONE);
    const plan = makePlan([XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.TINY_STEP]);
    const adjusted = applyBackoffToPlan(plan, XinglanDialogState.CALMING, [], s);
    check('R5 cooldown期间移除TINY_STEP',
      !adjusted.strategies.includes(XinglanReplyStrategy.TINY_STEP),
      `cooldown=${s.suggestionCooldownTurns} adjusted=${adjusted.strategies.join(',')}`, results);
  }
  {
    // 拒绝建议后 recordTurnEnd 设置 cooldown=4
    const s = makeState();
    addUserText(s, '不想试');
    s.currentState = XinglanDialogState.MICRO_ACTION;
    const a = makeAnalysis(XinglanEmotionTag.TIRED, XinglanTopicTag.WORK, XinglanBoundaryTag.NONE);
    const plan = makePlan([XinglanReplyStrategy.TINY_STEP]);
    recordTurnEnd(s, plan, XinglanDialogState.CALMING, true, a);
    check('R5 拒绝建议后cooldown=4',
      s.suggestionCooldownTurns === 4,
      `cooldown=${s.suggestionCooldownTurns}`, results);
  }

  // R6: "不想说"后不追问
  {
    const s = makeState();
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('我不想说这个', s, a);
    check('R6 "不想说"触发信号',
      signals.includes(XinglanBackoffSignal.USER_SAYS_NOT_WANT_TALK),
      `signals=${signals.join(',')}`, results);
  }
  {
    const s = makeState();
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('不想说', s, a);
    const plan = makePlan([XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.SOFT_QUESTION]);
    const adjusted = applyBackoffToPlan(plan, XinglanDialogState.QUIET, signals, s);
    check('R6 "不想说"移除SOFT_QUESTION',
      !adjusted.strategies.includes(XinglanReplyStrategy.SOFT_QUESTION),
      `adjusted=${adjusted.strategies.join(',')}`, results);
  }

  // R7: "你不懂"后回退承接
  {
    const s = makeState();
    s.currentState = XinglanDialogState.CAUSE_FOCUS;
    const a = makeAnalysis(XinglanEmotionTag.ANGRY, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('你不懂我', s, a);
    check('R7 "你不懂"触发信号',
      signals.includes(XinglanBackoffSignal.USER_SAYS_YOU_DONT_UNDERSTAND),
      `signals=${signals.join(',')}`, results);
  }
  {
    const s = makeState();
    s.currentState = XinglanDialogState.CAUSE_FOCUS;
    const a = makeAnalysis(XinglanEmotionTag.ANGRY, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('你不懂', s, a);
    const t = resolveNextState(XinglanDialogState.CAUSE_FOCUS, 1, a, signals);
    check('R7 "你不懂"→回退RECEIVE',
      t.newState === XinglanDialogState.RECEIVE,
      `expected=RECEIVE actual=${t.newState} reason=${t.reason}`, results);
  }

  // R8: Safety 优先级最高
  {
    const s = makeState();
    const a = makeAnalysis(XinglanEmotionTag.SAD, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const signals = detectBackoffSignals('我不想活了', s, a);
    check('R8 风险关键词触发RISK_DETECTED',
      signals.includes(XinglanBackoffSignal.RISK_DETECTED),
      `signals=${signals.join(',')}`, results);
  }
  {
    // 即使有其他信号，RISK 仍让状态跳转 SAFETY
    const a = makeAnalysis(XinglanEmotionTag.ANGRY, XinglanTopicTag.SELF, XinglanBoundaryTag.NONE);
    const t = resolveNextState(XinglanDialogState.CAUSE_FOCUS, 2, a,
      [XinglanBackoffSignal.USER_SAYS_NOT_WANT_TALK, XinglanBackoffSignal.RISK_DETECTED]);
    check('R8 风险信号优先于不想说',
      t.newState === XinglanDialogState.SAFETY,
      `expected=SAFETY actual=${t.newState} reason=${t.reason}`, results);
  }

  // 状态元信息约束验证
  {
    const receiveMeta = getDialogStateMeta(XinglanDialogState.RECEIVE);
    check('元信息 RECEIVE不允问',
      receiveMeta.allowQuestion === false,
      `allowQuestion=${receiveMeta.allowQuestion}`, results);
    check('元信息 RECEIVE不给建议',
      receiveMeta.canGiveSuggestion === false,
      `canGiveSuggestion=${receiveMeta.canGiveSuggestion}`, results);
  }
  {
    const microMeta = getDialogStateMeta(XinglanDialogState.MICRO_ACTION);
    check('元信息 MICRO_ACTION可给建议',
      microMeta.canGiveSuggestion === true,
      `canGiveSuggestion=${microMeta.canGiveSuggestion}`, results);
    check('元信息 MICRO_ACTION最多2轮',
      microMeta.maxConsecutiveRounds === 2,
      `maxRounds=${microMeta.maxConsecutiveRounds}`, results);
  }
  {
    const safetyMeta = getDialogStateMeta(XinglanDialogState.SAFETY);
    check('元信息 SAFETY不允问',
      safetyMeta.allowQuestion === false,
      `allowQuestion=${safetyMeta.allowQuestion}`, results);
    check('元信息 SAFETY禁用TAROT_METAPHOR',
      safetyMeta.forbiddenStrategies.includes(XinglanReplyStrategy.TAROT_METAPHOR),
      `forbidden=${safetyMeta.forbiddenStrategies.join(',')}`, results);
  }
}

// ═══ 对外入口 ═══

export function runDialogStateTests(): string[] {
  passCount = 0;
  failCount = 0;
  const results: TestResult[] = [];

  testStateTransitions(results);
  testBackoffRules(results);

  const lines: string[] = [];
  lines.push('═══ CHAT-2 十二状态机与退避规则验证 ═══');
  lines.push(`总计 ${results.length} 项，PASS ${passCount}，FAIL ${failCount}`);
  lines.push('');
  lines.push('| # | 用例 | 结果 | 详情 |');
  lines.push('| - | ---- | ---- | ---- |');
  for (let i = 0; i < results.length; i++) {
    const r = results[i];
    lines.push(`| ${i + 1} | ${r.name} | ${r.passed ? PASS : FAIL} | ${r.detail} |`);
  }
  return lines;
}

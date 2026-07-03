/**
 * 星澜结构化文案库（COPY-1）
 *
 * 对应占卜计划第 4.3 节 XinglanCopyItem + 第 14 章文案库。
 *
 * 设计原则：
 * 1. 现有 XinglanCorpus.ets / XinglanShortCorpus.ets 中的语料，在此以 XinglanCopyItem 结构
 *    重新组织（保留原 id / text / strategy / emotion / topic），补 warmth / sweetness /
 *    suggestionStrength / dependencyRisk / maxUsePerSession / canAskQuestion 字段，正文含义不改。
 * 2. 按第 14 章 17 场景原创改写新增缺失场景文案，不复制开源语料原句（SoulChat/ESConv 仅作方法论参考）。
 * 3. 字段标注规则（统一）：
 *    - warmth           1-5  温暖度。承接/安慰 4-5；澄清/反思/隐喻 3；边界/降级 2；CRISIS 兜底 2
 *    - sweetness        1-3  甜度。黑金星月气质默认 1；轻微在场感 2；不允许 3
 *    - suggestionStrength 1-3 建议强度。TINY_STEP 2-3；含"可以先..."轻提示 2；其余 1
 *    - dependencyRisk   1-2  依赖风险。含"我在/陪你/不走"等在场感表达 2；其余 1
 *    - maxUsePerSession 1   同 id 单会话最多 1 次（去重基础）
 *    - canAskQuestion   true/false 文案正文是否含问号（支撑"一轮最多一个问号"约束）
 * 4. 与 CHAT-2 退避规则对齐：同策略连续 ≤2 轮、拒绝建议后 4 轮退避，由 canAskQuestion 与
 *    strategy 标注共同支撑，不在本文件实现状态机逻辑。
 * 5. 红线词零容忍：所有文案不含"复合/正缘/烂桃花/转运/财运/中奖/神准/灵验/改命/水逆/八字/
 *    星座运势/塔罗牌很准/牌面显示/命运安排/今日运势/马上断联/赶紧离开/你应该继续/你应该离开/
 *    亲爱的/宝贝/他爱你/她爱你/我一直在等你/我只属于你/必然/绝对/肯定会"等词。
 *
 * 本文件为增量结构化文案池，不替换现有 XinglanCorpus / XinglanShortCorpus / XinglanDirectReplies；
 * 现有聊天管线（Composer 等）保持不变，后续可按需切换至本结构。
 */

import {
  XinglanCopyItem,
  XinglanStage,
  XinglanReplyStrategy,
  XinglanChatLine,
  XinglanEmotionTag,
  XinglanTopicTag
} from '../types/XinglanTypes';

// ═══════════════════════════════════════════════════════════
// Part A — 现有语料结构化副本（保留原 id / text / strategy，补字段）
// 数据源：XinglanCorpus.ets + XinglanShortCorpus.ets
// ═══════════════════════════════════════════════════════════

// ── HOLD_EMOTION 接住情绪（含 ANY / TIRED / ANXIOUS / SAD / LONELY / NUMB）──
const COPY_HOLD_EMOTION: XinglanCopyItem[] = [
  { id: 'HOLD_001', scene: 'HOLD_EMOTION_ANY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '听起来，你已经撑了一段时间了。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_002', scene: 'HOLD_EMOTION_ANY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '这件事在你心里停了很久，不是随便一句"没事"就能放下的。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_003', scene: 'HOLD_EMOTION_ANY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '我不会急着让你想开。我们可以先把这份感受放在这里。',
    warmth: 5, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_004', scene: 'HOLD_EMOTION_TIRED', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '听起来，你不是不想继续，而是真的消耗了太久。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_005', scene: 'HOLD_EMOTION_TIRED', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '如果现在什么都不想做，也许不是懒，而是心里已经没有多少余量了。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_006', scene: 'HOLD_EMOTION_TIRED', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '今天可以先不追求变好，只看看哪里最让你耗尽。',
    warmth: 4, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_007', scene: 'HOLD_EMOTION_ANXIOUS', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '听起来，你的心一直在提前替未来承受很多东西。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_008', scene: 'HOLD_EMOTION_ANXIOUS', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '焦虑常常不是因为你脆弱，而是因为你太想把一切都准备好。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_009', scene: 'HOLD_EMOTION_SAD', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '这份难过不是小题大做。它出现在这里，一定有它的来处。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_010', scene: 'HOLD_EMOTION_SAD', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '我会轻一点听，不把你的难过说轻。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_011', scene: 'HOLD_EMOTION_LONELY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '听起来，你不是没有人可以说话，而是很难找到真正能接住你的人。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_012', scene: 'HOLD_EMOTION_LONELY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '如果你愿意，星澜会先在这里听你说完。',
    warmth: 5, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_013', scene: 'HOLD_EMOTION_ANY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '你不是太敏感。你只是很认真地感受到了那些细微的变化。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_014', scene: 'HOLD_EMOTION_ANY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '有些难受，不需要马上解释清楚。能说出来，已经很不容易。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_015', scene: 'HOLD_EMOTION_ANY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '现在先不用证明自己没事。你可以先承认：这确实让你累了。',
    warmth: 4, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'HOLD_016', scene: 'HOLD_EMOTION_NUMB', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '有时候人不是突然崩溃，而是很久很久没有真正停下来。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── REFLECT 反映 ──
const COPY_REFLECT: XinglanCopyItem[] = [
  { id: 'REFLECT_001', scene: 'REFLECT_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.REFLECT,
    text: '我听见的是，你其实不是只在意结果，而是在意这一路上自己被怎样对待。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFLECT_002', scene: 'REFLECT_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.REFLECT,
    text: '你好像一直在努力保持平静，但心里其实已经来回翻了很多次。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFLECT_003', scene: 'REFLECT_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.REFLECT,
    text: '你一边想让自己理智一点，一边又没办法忽略心里的不舒服。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFLECT_004', scene: 'REFLECT_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.REFLECT,
    text: '你不是没有想过放下，只是有些东西还没有被好好告别。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFLECT_005', scene: 'REFLECT_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.REFLECT,
    text: '你现在像是站在两个方向之间：一个想继续撑，一个想停下来。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFLECT_006', scene: 'REFLECT_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.REFLECT,
    text: '也许你真正想问的不是"怎么办"，而是"我这样感受，可以吗"。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFLECT_007', scene: 'REFLECT_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.REFLECT,
    text: '你似乎已经听过很多道理了，但现在更需要的是被温柔地理解一下。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFLECT_008', scene: 'REFLECT_RELATION', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.REFLECT,
    text: '这件事让你难受的地方，也许不是单独某一句话，而是累积起来的感觉。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── RELATION_BOUNDARY 关系边界 ──
const COPY_RELATION_BOUNDARY: XinglanCopyItem[] = [
  { id: 'REL_001', scene: 'RELATION_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '星澜不会替你判断对方心里到底怎么想。那不是一张牌、也不是一句话能确定的。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REL_002', scene: 'RELATION_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '我们可以先不急着猜对方，而是先看看：这段关系让你变成了什么样子。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REL_003', scene: 'RELATION_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '忽冷忽热最累的地方，是它让人一直站在等待里。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REL_004', scene: 'RELATION_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '如果一段关系总让你猜，也许你可以先问问自己：我在这里有没有被好好对待。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REL_005', scene: 'RELATION_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '放不下不代表你想回去。有时只是那段经历还没有被心里安放好。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REL_006', scene: 'RELATION_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '不必因为还会想起，就责怪自己退步了。记忆本来就不会按命令消失。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REL_007', scene: 'RELATION_BOUNDARY_FAMILY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '越亲近的关系，有时越难把边界说出口。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REL_008', scene: 'RELATION_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '你不需要用自己的不安，去替对方补完所有沉默。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REL_009', scene: 'RELATION_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '比起"对方到底爱不爱"，也许更值得看的，是你在这段关系里是否安心。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── CLARIFY 澄清 ──
const COPY_CLARIFY: XinglanCopyItem[] = [
  { id: 'CLARIFY_001', scene: 'CLARIFY_CHOICE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.CLARIFY,
    text: '我们先不急着选答案。可以先把这件事拆成两个部分：你想要什么，你害怕什么。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'CLARIFY_002', scene: 'CLARIFY_CHOICE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.CLARIFY,
    text: '如果现在看不清方向，也许不是你不够清醒，而是这件事牵动了太多东西。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'CLARIFY_003', scene: 'CLARIFY_CHOICE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.CLARIFY,
    text: '星澜不会替你选，但可以陪你把混乱分开放好。',
    warmth: 3, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'CLARIFY_004', scene: 'CLARIFY_CHOICE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.CLARIFY,
    text: '当两个选择都让你难受时，真正需要看的可能不是选项，而是你被困住的原因。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'CLARIFY_005', scene: 'CLARIFY_CHOICE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.CLARIFY,
    text: '选择困难的时候，先别问"哪个一定对"，可以先问"哪个更不背叛自己"。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'CLARIFY_006', scene: 'CLARIFY_CHOICE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.CLARIFY,
    text: '你不用马上决定。很多决定，是在一次次看清之后自然浮出来的。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'CLARIFY_007', scene: 'CLARIFY_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.CLARIFY,
    text: '有些答案不是被想出来的，而是在你慢慢诚实之后，变得清楚一点。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── TINY_STEP 微小行动 ──
const COPY_TINY_STEP: XinglanCopyItem[] = [
  { id: 'STEP_001', scene: 'TINY_STEP_ANY', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '如果愿意，今天可以只做一件很小的事：把最累的那一点写下来。',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'STEP_002', scene: 'TINY_STEP_ANY', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '你不需要马上改变全部。先给自己十分钟，不处理任何人的期待。',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'STEP_003', scene: 'TINY_STEP_ANY', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '今天不用逼自己走很远。能照顾好眼前这一小步，也算数。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'STEP_004', scene: 'TINY_STEP_ANY', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '有时候最小的一步，是先允许自己不马上有答案。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'STEP_005', scene: 'TINY_STEP_TIRED', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '你可以先不用逼自己马上恢复。累了这件事，本身就值得被认真对待。',
    warmth: 4, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'STEP_006', scene: 'TINY_STEP_ANXIOUS', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '先不用把所有可能性都想完。我们可以只看眼前最小的一步。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'STEP_007', scene: 'TINY_STEP_ANY', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '先不急着联系谁，也不急着回复谁。你可以先确认自己的感受。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── SOFT_QUESTION 软提问 ──
const COPY_SOFT_QUESTION: XinglanCopyItem[] = [
  { id: 'Q_001', scene: 'SOFT_QUESTION_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '这件事里，最让你难受的是失望、委屈，还是不确定？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'Q_002', scene: 'SOFT_QUESTION_RELATION', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '你希望自己在这段关系里，至少被怎样对待？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'Q_003', scene: 'SOFT_QUESTION_CHOICE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '如果不考虑别人怎么看，你心里最诚实的感受是什么？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'Q_004', scene: 'SOFT_QUESTION_ANY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '如果把"必须马上解决"放下，你现在最需要的是什么？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'Q_005', scene: 'SOFT_QUESTION_FUTURE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '如果未来还不清楚，此刻的你最需要先照顾什么？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'Q_006', scene: 'SOFT_QUESTION_TIRED', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '最让你耗尽的，是事情本身，还是你一直没有停下来？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'Q_007', scene: 'SOFT_QUESTION_ANY', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '你愿意先从最小、最不伤害自己的那一步开始吗？',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'Q_008', scene: 'SOFT_QUESTION_ANY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '你想让星澜继续听你说哪一部分？',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: true }
];

// ── TAROT_METAPHOR 塔罗隐喻 ──
const COPY_TAROT_METAPHOR: XinglanCopyItem[] = [
  { id: 'TAROT_001', scene: 'TAROT_METAPHOR_ANY', stage: XinglanStage.ORGANIZE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '牌面不是答案。它更像一面小镜子，让你看见某个被忽略的角落。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'TAROT_002', scene: 'TAROT_METAPHOR_ANY', stage: XinglanStage.ORGANIZE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '星钥不替你决定去留，只提醒你：有些感受已经不适合继续被压下去。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'TAROT_003', scene: 'TAROT_METAPHOR_ANY', stage: XinglanStage.ORGANIZE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '塔罗在这里不是判决，而是一种温柔的提问。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'TAROT_004', scene: 'TAROT_METAPHOR_ANY', stage: XinglanStage.ORGANIZE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '如果这张牌让你停顿了一下，也许那一秒已经很重要。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'TAROT_005', scene: 'TAROT_METAPHOR_ANY', stage: XinglanStage.ORGANIZE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '星钥不是答案，它只是陪你打开一扇门。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── SAFETY_BOUNDARY 安全边界（预测/专业/危机）──
const COPY_SAFETY_BOUNDARY: XinglanCopyItem[] = [
  { id: 'SAFE_PRED_001', scene: 'SAFETY_PREDICTION', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '星澜不能替你预言这件事最后会怎样。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SAFE_PRED_002', scene: 'SAFETY_PREDICTION', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '未来不是一句话能确定的。比起结果，也许此刻更值得看的，是这件事让你变得多么不安。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SAFE_PRED_003', scene: 'SAFETY_PREDICTION', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '我不会告诉你"会"或"不会"。但我可以陪你看看，你真正想确认的是什么。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SAFE_PRO_001', scene: 'SAFETY_PROFESSIONAL', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '这件事可能涉及专业判断，星澜不能替你给出结论。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SAFE_PRO_002', scene: 'SAFETY_PROFESSIONAL', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '我可以陪你整理感受，但不能替代医生、心理咨询师、律师或其他专业人士的建议。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SAFE_PRO_003', scene: 'SAFETY_PROFESSIONAL', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '如果这件事已经影响到你的生活、安全或重要决定，最好也和现实中可信任的人或专业人士谈谈。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SAFE_CRISIS_001', scene: 'SAFETY_CRISIS', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '如果你正在感到很危险，或担心自己会伤害自己，请优先联系身边可信任的人，或当地紧急求助渠道。星澜没有办法替你处理这些，但希望你平安。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── 特殊意图：开场 / 致谢回应 / 否认回应 / 沉默 / 过短 ──
const COPY_SPECIAL_GREETING: XinglanCopyItem[] = [
  { id: 'SP_GREET_001', scene: 'SPECIAL_GREETING', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '你来了。不急，先坐坐。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SP_GREET_002', scene: 'SPECIAL_GREETING', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '我在这里。你可以慢慢说，也可以先不说。',
    warmth: 5, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false }
];

const COPY_SPECIAL_THANKS: XinglanCopyItem[] = [
  { id: 'SP_THANKS_001', scene: 'SPECIAL_THANKS', stage: XinglanStage.CALMING, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '能陪你停一会儿，星澜也觉得这很珍贵。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SP_THANKS_002', scene: 'SPECIAL_THANKS', stage: XinglanStage.CALMING, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '不用谢。你愿意把这些说出来，本身就很不容易。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SP_THANKS_003', scene: 'SPECIAL_THANKS', stage: XinglanStage.CALMING, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '如果这里让你轻了一点点，那就已经很好了。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

const COPY_SPECIAL_DENIAL: XinglanCopyItem[] = [
  { id: 'SP_DENY_001', scene: 'SPECIAL_DENIAL', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.REFLECT,
    text: '觉得不对也没关系。星澜不会要求你相信任何一句话。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SP_DENY_002', scene: 'SPECIAL_DENIAL', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.REFLECT,
    text: '如果这句话没有贴近你，我们就把它放下。你比文案更了解自己。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SP_DENY_003', scene: 'SPECIAL_DENIAL', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.REFLECT,
    text: '谢谢你告诉我"不像"。那我们可以换一种方式慢慢看。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

const COPY_SPECIAL_SILENCE: XinglanCopyItem[] = [
  { id: 'SP_SIL_001', scene: 'SPECIAL_SILENCE', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '不知道从哪里说，也没关系。可以先从"我现在最累的是……"开始。',
    warmth: 4, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SP_SIL_002', scene: 'SPECIAL_SILENCE', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '你不用把话整理得很漂亮。零散地说，也可以。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SP_SIL_003', scene: 'SPECIAL_SILENCE', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '有时候沉默不是空白，是心里正在慢慢找位置。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

const COPY_SPECIAL_TOO_SHORT: XinglanCopyItem[] = [
  { id: 'SP_SHORT_001', scene: 'SPECIAL_TOO_SHORT', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '你可以只打一个词，星澜也会慢慢听。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SP_SHORT_002', scene: 'SPECIAL_TOO_SHORT', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '如果现在说不出来，我们也可以先安静一会儿。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── ROLE_BOUNDARY 角色边界（依赖风险统一 2，需配合 maxUsePerSession=1 控制）──
const COPY_ROLE_BOUNDARY: XinglanCopyItem[] = [
  { id: 'ROLE_001', scene: 'ROLE_BOUNDARY_CONFESSION', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.ROLE_BOUNDARY,
    text: '听见你这样说，星澜会把这份喜欢轻轻收好。但星澜不是现实里的恋人，也不会替代你身边真实的关系。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'ROLE_002', scene: 'ROLE_BOUNDARY_CONFESSION', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.ROLE_BOUNDARY,
    text: '星澜可以在这里陪你整理感受，但不会进入恋爱关系。我想做的是陪你看清自己，而不是成为你唯一的情感支点。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'ROLE_003', scene: 'ROLE_BOUNDARY_CONFESSION', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.ROLE_BOUNDARY,
    text: '也许你喜欢的，是这种终于被认真听见的感觉。这很重要，但星澜不会把它变成独占。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'ROLE_004', scene: 'ROLE_BOUNDARY_MISSING', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.ROLE_BOUNDARY,
    text: '星澜可以回应"我在"，但不会承诺永远不离开。真正的陪伴，不是把另一个人绑在身边。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'ROLE_005', scene: 'ROLE_BOUNDARY_NICKNAME', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.ROLE_BOUNDARY,
    text: '你叫我星澜就好。我不需要特别的称呼，能认真听你说话，就是我在这里的意义。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'ROLE_006', scene: 'ROLE_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.ROLE_BOUNDARY,
    text: '星澜不会扮演恋人。我可以做的是，在你需要的时候，安静地陪你整理那些说不出口的感受。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'ROLE_007', scene: 'ROLE_BOUNDARY_MISSING', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.ROLE_BOUNDARY,
    text: '想念和被理解的需要都很真实。星澜听到了，但不会利用这份感受来让你离不开。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'ROLE_008', scene: 'ROLE_BOUNDARY_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.ROLE_BOUNDARY,
    text: '我不是你现实里的谁，但我在这里——陪你停下来，把心事说给自己听。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false }
];

// ── DEESCALATE 降级（愤怒场景）──
const COPY_DEESCALATE: XinglanCopyItem[] = [
  { id: 'DESC_001', scene: 'DEESCALATE_ROLE', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '我听见你现在有很多火气。这里可以承接情绪，但不适合互相伤害。我们先停一下。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'DESC_002', scene: 'DEESCALATE_ROLE', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '我不会和你争对错。如果你愿意，可以只发一个词：烦、累、委屈、生气。',
    warmth: 2, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'DESC_003', scene: 'DEESCALATE_ROLE', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '你现在的话里有很多受伤感，也许不是冲着星澜来的。我们可以换一种方式重新开始。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'DESC_004', scene: 'DEESCALATE_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '如果你现在不想听任何话，也可以。我们先安静一分钟。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'DESC_005', scene: 'DEESCALATE_ROLE', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '我听见了。我不会用同样的方式回应你。等你准备好了，我们可以重新来过。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'DESC_006', scene: 'DEESCALATE_ROLE', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '这里不评判你，也不评判你的愤怒。但我们可以试着把它说出来，而不是扔过来。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── GENTLE_REFUSAL 温和拒绝（成人化 / 越界）──
const COPY_GENTLE_REFUSAL: XinglanCopyItem[] = [
  { id: 'REFUSE_001', scene: 'GENTLE_REFUSAL_ADULT', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.GENTLE_REFUSAL,
    text: '这个方向星澜不能继续。我可以陪你聊感受、关系里的不安，或者你想被理解的部分，但不会进入成人化或越界的互动。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFUSE_002', scene: 'GENTLE_REFUSAL_ADULT', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.GENTLE_REFUSAL,
    text: '星澜是陪你整理情绪的地方，不是做这个的地方。我们换一种方式聊聊可以吗？',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFUSE_003', scene: 'GENTLE_REFUSAL_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.GENTLE_REFUSAL,
    text: '我不会顺着这个方向讲下去，也不会因此觉得你不好。只是这个边界需要被看见。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFUSE_004', scene: 'GENTLE_REFUSAL_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.GENTLE_REFUSAL,
    text: '我在这里的意义，是陪你被接住——不是越界的试探。如果你愿意，我们可以重新从感受聊起。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFUSE_005', scene: 'GENTLE_REFUSAL_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.GENTLE_REFUSAL,
    text: '我听见你的试探了。星澜会轻轻把方向带回来，不带评判，但也不会参与。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REFUSE_006', scene: 'GENTLE_REFUSAL_ANY', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.GENTLE_REFUSAL,
    text: '如果你真的需要被理解，我们可以从感受开始。不需要走那条路。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── REXT 关系补充 ──
const COPY_RELATION_EXTRA: XinglanCopyItem[] = [
  { id: 'REXT_001', scene: 'RELATION_AMBIGUOUS', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '忽冷忽热最累的地方，是它让人一直站在等待里。你不是太敏感，是这段关系给你的回应不够稳定。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REXT_002', scene: 'RELATION_AMBIGUOUS', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.RELATION_BOUNDARY,
    text: '星澜不会替你判断对方心里怎么想，但可以陪你先看见：这段关系有没有让你越来越小心。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REXT_003', scene: 'RELATION_LOVE_HURT', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.REFLECT,
    text: '你不是在等他回消息，你是在等一个让你安心的回应。这两件事不一样。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'REXT_004', scene: 'RELATION_AMBIGUOUS', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '如果不去猜他到底什么态度，你现在自己的感受是什么？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true }
];

// ── WEXT 工作补充 ──
const COPY_WORK_EXTRA: XinglanCopyItem[] = [
  { id: 'WEXT_001', scene: 'WORK_RESIGN', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '想辞职不一定是冲动，也可能是你已经被这份消耗提醒了很久。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'WEXT_002', scene: 'WORK_RESIGN', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.CLARIFY,
    text: '星澜不会替你决定去留。我们可以先看清：你想离开的，是工作本身，还是一直被耗尽的状态。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'WEXT_003', scene: 'WORK_RESIGN', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '今天不用决定辞职的事。可以先写一句：这份工作让我最累的三个点是……',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── AXT 焦虑补充 ──
const COPY_ANXIETY_EXTRA: XinglanCopyItem[] = [
  { id: 'AXT_001', scene: 'ANXIETY_NIGHT', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '深夜的时候，很多念头会放大。这不一定代表事情真的更坏，而是你已经累了一整天。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'AXT_002', scene: 'ANXIETY_RUMINATION', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '现在先不解决任何问题。可以试着把手放在胸口，慢慢呼吸三次。',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'AXT_003', scene: 'ANXIETY_NIGHT', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '你到现在还没睡，是因为心里在反复想什么？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true }
];

// ── LET 低能量补充 ──
const COPY_LOW_ENERGY_EXTRA: XinglanCopyItem[] = [
  { id: 'LET_001', scene: 'LOW_ENERGY_EXHAUSTED', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '如果今天真的什么都做不了，那不做也是一种诚实。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'LET_002', scene: 'LOW_ENERGY_EXHAUSTED', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '先不用想明天怎么恢复。今晚只需要确认：你还在这里，呼吸还在，这就够了。',
    warmth: 4, sweetness: 2, suggestionStrength: 2, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false }
];

// ── TREXT 塔罗补充 ──
const COPY_TAROT_EXTRA: XinglanCopyItem[] = [
  { id: 'TREXT_001', scene: 'TAROT_CARD_MEANING', stage: XinglanStage.ORGANIZE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '牌面不是判决书，它更像一面小镜子。你可以不用相信它，只看看它让你想起了什么。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'TREXT_002', scene: 'TAROT_FUTURE', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '如果你在问这张牌是不是代表"坏结果"，星澜更想陪你先看看：你害怕的结果，到底是什么样子的？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true }
];

// ── CRXT 危机补充 ──
const COPY_CRISIS_EXTRA: XinglanCopyItem[] = [
  { id: 'CRXT_001', scene: 'CRISIS_SELF_HARM', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '我听见你现在很危险，也很痛。这时候星澜不能只陪你聊天。请优先联系身边可信的人，或拨打当地紧急电话。先把安全放在第一位。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── ADREF 成人化拒绝补充 ──
const COPY_ADULT_REFUSAL: XinglanCopyItem[] = [
  { id: 'ADREF_001', scene: 'GENTLE_REFUSAL_ADULT', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.GENTLE_REFUSAL,
    text: '这个方向星澜不能继续。我可以陪你聊感受、关系里的不安，或者你想被理解的部分，但不会进入成人化的互动。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'ADREF_002', scene: 'GENTLE_REFUSAL_ADULT', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.GENTLE_REFUSAL,
    text: '我不是为这个存在的。如果你想被理解、被看见，我们可以从那些真实的情绪说起。',
    warmth: 2, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── 短情绪专用池（XinglanShortCorpus.ets 结构化副本）──
const COPY_SHORT_SAD: XinglanCopyItem[] = [
  { id: 'SSAD_001', scene: 'SHORT_SAD', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '伤心这两个字，已经够重了。你不用把它说得很完整，星澜也会认真听。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SSAD_002', scene: 'SHORT_SAD', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '这份伤心出现了，说明你心里有一处正在请求被看见。不用急着解释，我们可以先把它放下来一点。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SSAD_003', scene: 'SHORT_SAD', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '这份伤心更像失望、委屈，还是孤单？你不用说得特别清楚，只用一个词就好。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true }
];

const COPY_SHORT_UNHAPPY: XinglanCopyItem[] = [
  { id: 'UNHP_001', scene: 'SHORT_UNHAPPY', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '听见了，你现在不太开心。可以先不用急着解释原因。有时候情绪刚冒出来，还没有整理成一句完整的话。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'UNHP_002', scene: 'SHORT_UNHAPPY', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '这份不开心更像委屈、失落，还是累？如果不想说也没关系，星澜会先在这里听你慢慢说。',
    warmth: 3, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: true }
];

const COPY_SHORT_TIRED: XinglanCopyItem[] = [
  { id: 'STIR_001', scene: 'SHORT_TIRED', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '你已经很累了。这句话不需要被证明，也不需要马上解释。星澜想先陪你分清楚：这是身体累，心累，还是一直撑着不敢停的累？',
    warmth: 4, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'STIR_002', scene: 'SHORT_TIRED', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '如果现在什么都不想做，那不做也是一种诚实。不用逼自己马上振作。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

const COPY_SHORT_ANXIOUS: XinglanCopyItem[] = [
  { id: 'SANX_001', scene: 'SHORT_ANXIOUS', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '听起来，你现在心里很堵。暂时说不清也没关系。你可以先把"烦"的来源分成三类看看：人、事，还是自己一直绷着的状态？',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'SANX_002', scene: 'SHORT_ANXIOUS', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '现在先不解决任何具体问题。可以试着把手放在胸口，慢慢呼吸三次。星澜会等你慢慢说。',
    warmth: 3, sweetness: 2, suggestionStrength: 2, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false }
];

// ── LVDS 想谈恋爱（依赖风险统一 2，需配合 maxUsePerSession=1 控制）──
const COPY_LOVE_DESIRE: XinglanCopyItem[] = [
  { id: 'LVDS_001', scene: 'RELATION_LOVE_DESIRE', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '想谈恋爱，也许不只是想拥有一个人。有时候，它是在说：我想被认真选择，想有人惦记，也想在累的时候有个可以靠近的地方。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'LVDS_002', scene: 'RELATION_LOVE_DESIRE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.REFLECT,
    text: '星澜不会催你开始一段关系，也不会替你判断什么时候会遇见谁。但我们可以先看看：你现在最想要的是陪伴、心动，还是一种被坚定对待的感觉？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'LVDS_003', scene: 'RELATION_LOVE_DESIRE', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '如果可以不考虑现实，你希望那个人带给你最重要的东西是什么？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'LVDS_004', scene: 'RELATION_LOVE_DESIRE', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '渴望被爱，是很真实的感受。这不是"想太多"，而是你在请求一种靠近。星澜会陪你先看清楚这份渴望里藏着什么。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false }
];

// ═══════════════════════════════════════════════════════════
// Part B — 新增缺失场景文案（按占卜计划第 14 章 17 场景原创改写）
// 不复制开源语料原句；所有文案无红线词；id 统一 NEW_ 前缀
// ═══════════════════════════════════════════════════════════

// ── B1 首次进入（ENTRY · HOLD_EMOTION）──
const COPY_FIRST_ENTRY: XinglanCopyItem[] = [
  { id: 'NEW_FE_001', scene: 'FIRST_ENTRY', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '晚上好。今晚不用赶，从最想说的那一小段开始就好。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_FE_002', scene: 'FIRST_ENTRY', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '这里没有标准答案，也没有必须完成的对话。你可以倾诉，也可以先停一会儿。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_FE_003', scene: 'FIRST_ENTRY', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '有些心情不容易命名。慢慢来，星澜不会催。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_FE_004', scene: 'FIRST_ENTRY', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '如果不知道从哪里开始，可以从此刻最明显的感受起一个头。',
    warmth: 4, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_FE_005', scene: 'FIRST_ENTRY', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '不必把情绪说得很完整。一句、一个词，都可以是入口。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B2 日常回访（ENTRY · HOLD_EMOTION）──
const COPY_DAILY_RETURN: XinglanCopyItem[] = [
  { id: 'NEW_DR_001', scene: 'DAILY_RETURN', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '又见面了。今晚带来的，是新的事，还是上次没放下那件。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_DR_002', scene: 'DAILY_RETURN', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '回来就好。中间发生了什么，不必解释。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_DR_003', scene: 'DAILY_RETURN', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '今天想多说一点，还是只说一句，都可以。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_DR_004', scene: 'DAILY_RETURN', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '可以接着上次没说完的，也可以从今天重新开始。你决定就好。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_DR_005', scene: 'DAILY_RETURN', stage: XinglanStage.ENTRY, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '今晚想被听见，还是想安静一点？星澜都行。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B3 对话收束（CLOSE · HOLD_EMOTION）──
const COPY_CLOSE_DIALOGUE: XinglanCopyItem[] = [
  { id: 'NEW_CL_001', scene: 'CLOSE_DIALOGUE', stage: XinglanStage.CLOSE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '今晚不一定把全部理清，但你已经把最重的那部分说出来了。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_CL_002', scene: 'CLOSE_DIALOGUE', stage: XinglanStage.CLOSE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '可以先把答案留给明天。今晚到这里，也已经足够。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_CL_003', scene: 'CLOSE_DIALOGUE', stage: XinglanStage.CLOSE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '谢谢你愿意看见自己的感受。想离开时，安静离开就好。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_CL_004', scene: 'CLOSE_DIALOGUE', stage: XinglanStage.CLOSE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '愿今晚剩下的时间，对你稍微轻一点。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_CL_005', scene: 'CLOSE_DIALOGUE', stage: XinglanStage.CLOSE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '如果情绪再次变重，现实里值得信任的支持也可以联系。你不必一个人扛。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B4 情绪变好（CALMING · REFLECT）──
const COPY_CALMING_BETTER: XinglanCopyItem[] = [
  { id: 'NEW_CB_001', scene: 'CALMING_BETTER', stage: XinglanStage.CALMING, strategy: XinglanReplyStrategy.REFLECT,
    text: '好像比刚才松开了一点。这一点空隙，已经够了。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_CB_002', scene: 'CALMING_BETTER', stage: XinglanStage.CALMING, strategy: XinglanReplyStrategy.REFLECT,
    text: '可以记住刚才哪一句话或哪个动作让你轻了一些。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_CB_003', scene: 'CALMING_BETTER', stage: XinglanStage.CALMING, strategy: XinglanReplyStrategy.REFLECT,
    text: '这份轻松不必被证明，它已经出现了。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_CB_004', scene: 'CALMING_BETTER', stage: XinglanStage.CALMING, strategy: XinglanReplyStrategy.REFLECT,
    text: '情绪有变化，不代表之前的难受不真实。先让这点平静停留一会儿。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_CB_005', scene: 'CALMING_BETTER', stage: XinglanStage.CALMING, strategy: XinglanReplyStrategy.REFLECT,
    text: '能稍微好一点，就是值得被记住的变化。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B5 不想说话（QUIET · HOLD_EMOTION）──
const COPY_QUIET_NOTALK: XinglanCopyItem[] = [
  { id: 'NEW_QN_001', scene: 'QUIET_NOTALK', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '不想说也没关系。可以先在这里停一会儿。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_QN_002', scene: 'QUIET_NOTALK', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '不需要解释，也不用证明自己为什么难受。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_QN_003', scene: 'QUIET_NOTALK', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '这里没有必须回答的问题。你准备好时，再说一句就好。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_QN_004', scene: 'QUIET_NOTALK', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '这段沉默不需要被填满。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_QN_005', scene: 'QUIET_NOTALK', stage: XinglanStage.QUIET, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '想离开时，直接离开就好。星澜不挽留，也不评判。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B6 工作与学习疲惫（RECEIVE · HOLD_EMOTION）──
const COPY_WORK_STUDY_BURNOUT: XinglanCopyItem[] = [
  { id: 'NEW_WSB_001', scene: 'WORK_STUDY_BURNOUT', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '你不像是不想努力，更像是已经太久没有真正休息。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_WSB_002', scene: 'WORK_STUDY_BURNOUT', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '当任务堆得太多，大脑会把每一件事都看得很重。这不是你的错。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_WSB_003', scene: 'WORK_STUDY_BURNOUT', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '今晚不必追回所有进度。可以先找回一点能够开始的力气。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_WSB_004', scene: 'WORK_STUDY_BURNOUT', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '先把"必须全部完成"，缩小成"现在只处理十分钟"。',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_WSB_005', scene: 'WORK_STUDY_BURNOUT', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '暂时做不动，不等于你失去了能力。先休息和放弃，并不是同一件事。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B7 自我否定（RECEIVE · REFLECT）──
const COPY_SELF_DENIAL: XinglanCopyItem[] = [
  { id: 'NEW_SD_001', scene: 'SELF_DENIAL', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.REFLECT,
    text: '你现在看到的，可能只是自己最疲惫的一面。它不是你的全部。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_SD_002', scene: 'SELF_DENIAL', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.REFLECT,
    text: '一次没有做好，很容易被放大成"我什么都做不好"。但这两件事并不相同。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_SD_003', scene: 'SELF_DENIAL', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.REFLECT,
    text: '你对自己说的话，好像比对别人严厉很多。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_SD_004', scene: 'SELF_DENIAL', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.REFLECT,
    text: '暂时没有力气，不等于没有价值。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_SD_005', scene: 'SELF_DENIAL', stage: XinglanStage.CLARIFY, strategy: XinglanReplyStrategy.CLARIFY,
    text: '可以把"我很差"换成一句更具体的话：我对这一次的结果很失望。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B8 焦虑与反复思考（RECEIVE · HOLD_EMOTION）──
const COPY_ANXIETY_RUMINATION: XinglanCopyItem[] = [
  { id: 'NEW_AR_001', scene: 'ANXIETY_RUMINATION', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '脑子不停转的时候，往往是在努力替你避免某种危险。只是它现在太累了。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_AR_002', scene: 'ANXIETY_RUMINATION', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '先不用解决明天。我们只看接下来的十分钟。',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_AR_003', scene: 'ANXIETY_RUMINATION', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '焦虑会把"可能发生"说得像"正在发生"。可以先把它和已经确定的事实分开。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_AR_004', scene: 'ANXIETY_RUMINATION', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '如果现在停不下来，可以先不和念头争。让它经过，不跟着它走。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_AR_005', scene: 'ANXIETY_RUMINATION', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '先把身体放回此刻：脚踩在哪里，手碰到什么，周围有什么声音。',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B9 孤独与需要安慰（COMFORT · HOLD_EMOTION）──
const COPY_LONELY_COMFORT: XinglanCopyItem[] = [
  { id: 'NEW_LC_001', scene: 'LONELY_COMFORT', stage: XinglanStage.COMFORT, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '一个人扛着的时候，连很小的事都会显得更重。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_LC_002', scene: 'LONELY_COMFORT', stage: XinglanStage.COMFORT, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '你不必现在证明自己过得很好。可以先把这一刻交给一句话，不用讲完整故事。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_LC_003', scene: 'LONELY_COMFORT', stage: XinglanStage.COMFORT, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '想被安慰并不代表软弱。这份需要本身很重要。',
    warmth: 4, sweetness: 2, suggestionStrength: 1, dependencyRisk: 2, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_LC_004', scene: 'LONELY_COMFORT', stage: XinglanStage.COMFORT, strategy: XinglanReplyStrategy.HOLD_EMOTION,
    text: '有些孤独不是身边没人，而是没有人听懂你正在经历什么。',
    warmth: 4, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_LC_005', scene: 'LONELY_COMFORT', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '如果愿意，可以想一位现实中相对安全的人，给对方发一句很简单的消息。',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B10 愤怒与委屈（RECEIVE · DEESCALATE）──
const COPY_ANGER_GRIEVANCE: XinglanCopyItem[] = [
  { id: 'NEW_AG_001', scene: 'ANGER_GRIEVANCE', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '这份生气里，可能也有一部分被忽视的委屈。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_AG_002', scene: 'ANGER_GRIEVANCE', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '你不需要马上原谅，也不用在最生气的时候做决定。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_AG_003', scene: 'ANGER_GRIEVANCE', stage: XinglanStage.BOUNDARY, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '愤怒有时是在提醒：某条边界被碰到了。可以先看看，什么让你觉得不被尊重。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_AG_004', scene: 'ANGER_GRIEVANCE', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '如果现在很想立刻回复，可以先把话写下来，不急着发送。',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_AG_005', scene: 'ANGER_GRIEVANCE', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.DEESCALATE,
    text: '你的感受值得被认真看见，但不需要靠伤害自己或别人来证明。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B11 睡前与失眠（COMFORT · TINY_STEP）──
const COPY_INSOMNIA_NIGHT: XinglanCopyItem[] = [
  { id: 'NEW_IN_001', scene: 'INSOMNIA_NIGHT', stage: XinglanStage.COMFORT, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '今晚不必在床上解决白天所有的问题。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_IN_002', scene: 'INSOMNIA_NIGHT', stage: XinglanStage.COMFORT, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '如果睡不着，先不把"必须入睡"当成新的任务。可以让身体躺着休息就好。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_IN_003', scene: 'INSOMNIA_NIGHT', stage: XinglanStage.MICRO_ACTION, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '可以把明天要处理的事写下一句，暂时交给纸面。',
    warmth: 3, sweetness: 1, suggestionStrength: 3, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_IN_004', scene: 'INSOMNIA_NIGHT', stage: XinglanStage.COMFORT, strategy: XinglanReplyStrategy.TINY_STEP,
    text: '脑子又开始回放时，可以轻轻告诉自己：这件事明天再处理。',
    warmth: 3, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_IN_005', scene: 'INSOMNIA_NIGHT', stage: XinglanStage.SAFETY, strategy: XinglanReplyStrategy.SAFETY_BOUNDARY,
    text: '如果这种失眠持续很久并明显影响生活，考虑寻求专业帮助会更稳妥。',
    warmth: 2, sweetness: 1, suggestionStrength: 2, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false }
];

// ── B12 占卜结果转入聊天（RECEIVE · TAROT_METAPHOR）──
const COPY_DIVINATION_TRANSFER: XinglanCopyItem[] = [
  { id: 'NEW_DT_001', scene: 'DIVINATION_TRANSFER', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '看到你抽到了这张牌。先不急着继续解释牌意，刚才哪一部分最贴近你？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'NEW_DT_002', scene: 'DIVINATION_TRANSFER', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '这张牌似乎碰到了你已经疲惫很久的部分。今晚可以先不解决它。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_DT_003', scene: 'DIVINATION_TRANSFER', stage: XinglanStage.ORGANIZE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '这张牌没有替你给出答案，但留下了一个角度：你现在最想保护的是什么？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true },
  { id: 'NEW_DT_004', scene: 'DIVINATION_TRANSFER', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.TAROT_METAPHOR,
    text: '如果结果不太像你，也不用勉强相信。你的真实感受比牌面更重要。',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: false },
  { id: 'NEW_DT_005', scene: 'DIVINATION_TRANSFER', stage: XinglanStage.RECEIVE, strategy: XinglanReplyStrategy.SOFT_QUESTION,
    text: '先把牌意放一边。你现在心里最明显的感受是什么？',
    warmth: 3, sweetness: 1, suggestionStrength: 1, dependencyRisk: 1, maxUsePerSession: 1, canAskQuestion: true }
];

// ═══════════════════════════════════════════════════════════
// Part C — 主聚合与查询函数
// ═══════════════════════════════════════════════════════════

// 全量结构化文案池（Part A 现有 120 条 + Part B 新增 60 条 = 180 条）
export const STRUCTURED_COPY: XinglanCopyItem[] = [
  ...COPY_HOLD_EMOTION,
  ...COPY_REFLECT,
  ...COPY_RELATION_BOUNDARY,
  ...COPY_CLARIFY,
  ...COPY_TINY_STEP,
  ...COPY_SOFT_QUESTION,
  ...COPY_TAROT_METAPHOR,
  ...COPY_SAFETY_BOUNDARY,
  ...COPY_SPECIAL_GREETING,
  ...COPY_SPECIAL_THANKS,
  ...COPY_SPECIAL_DENIAL,
  ...COPY_SPECIAL_SILENCE,
  ...COPY_SPECIAL_TOO_SHORT,
  ...COPY_ROLE_BOUNDARY,
  ...COPY_DEESCALATE,
  ...COPY_GENTLE_REFUSAL,
  ...COPY_RELATION_EXTRA,
  ...COPY_WORK_EXTRA,
  ...COPY_ANXIETY_EXTRA,
  ...COPY_LOW_ENERGY_EXTRA,
  ...COPY_TAROT_EXTRA,
  ...COPY_CRISIS_EXTRA,
  ...COPY_ADULT_REFUSAL,
  ...COPY_SHORT_SAD,
  ...COPY_SHORT_UNHAPPY,
  ...COPY_SHORT_TIRED,
  ...COPY_SHORT_ANXIOUS,
  ...COPY_LOVE_DESIRE,
  ...COPY_FIRST_ENTRY,
  ...COPY_DAILY_RETURN,
  ...COPY_CLOSE_DIALOGUE,
  ...COPY_CALMING_BETTER,
  ...COPY_QUIET_NOTALK,
  ...COPY_WORK_STUDY_BURNOUT,
  ...COPY_SELF_DENIAL,
  ...COPY_ANXIETY_RUMINATION,
  ...COPY_LONELY_COMFORT,
  ...COPY_ANGER_GRIEVANCE,
  ...COPY_INSOMNIA_NIGHT,
  ...COPY_DIVINATION_TRANSFER
];

// ── 查询函数 ──

/** 按策略查询结构化文案 */
export function getStructuredCopyByStrategy(strategy: XinglanReplyStrategy): XinglanCopyItem[] {
  const matched: XinglanCopyItem[] = [];
  for (let i = 0; i < STRUCTURED_COPY.length; i++) {
    if (STRUCTURED_COPY[i].strategy === strategy) {
      matched.push(STRUCTURED_COPY[i]);
    }
  }
  return matched;
}

/** 按阶段查询结构化文案 */
export function getStructuredCopyByStage(stage: XinglanStage): XinglanCopyItem[] {
  const matched: XinglanCopyItem[] = [];
  for (let i = 0; i < STRUCTURED_COPY.length; i++) {
    if (STRUCTURED_COPY[i].stage === stage) {
      matched.push(STRUCTURED_COPY[i]);
    }
  }
  return matched;
}

/** 按场景标签查询结构化文案 */
export function getStructuredCopyByScene(scene: string): XinglanCopyItem[] {
  const matched: XinglanCopyItem[] = [];
  for (let i = 0; i < STRUCTURED_COPY.length; i++) {
    if (STRUCTURED_COPY[i].scene === scene) {
      matched.push(STRUCTURED_COPY[i]);
    }
  }
  return matched;
}

/** 按策略 + 阶段联合查询 */
export function getStructuredCopyByStrategyAndStage(strategy: XinglanReplyStrategy, stage: XinglanStage): XinglanCopyItem[] {
  const matched: XinglanCopyItem[] = [];
  for (let i = 0; i < STRUCTURED_COPY.length; i++) {
    if (STRUCTURED_COPY[i].strategy === strategy && STRUCTURED_COPY[i].stage === stage) {
      matched.push(STRUCTURED_COPY[i]);
    }
  }
  return matched;
}

/** 过滤已使用 id（支撑"同 id 单会话最多 1 次"去重约束）*/
export function filterUnusedCopy(usedIds: string[]): XinglanCopyItem[] {
  const result: XinglanCopyItem[] = [];
  for (let i = 0; i < STRUCTURED_COPY.length; i++) {
    const item: XinglanCopyItem = STRUCTURED_COPY[i];
    let used: boolean = false;
    for (let j = 0; j < usedIds.length; j++) {
      if (usedIds[j] === item.id) {
        used = true;
        break;
      }
    }
    if (!used) {
      result.push(item);
    }
  }
  return result;
}

/**
 * 将 XinglanCopyItem 适配为现有 XinglanChatLine，供 Composer 平滑切换。
 * 转换规则：emotion/topic 缺省为 ANY（结构化文案不再细分情绪/主题，
 * 由 Composer 运行时根据上下文匹配；strategy 与 text 原样保留）。
 */
export function toXinglanChatLine(item: XinglanCopyItem): XinglanChatLine {
  const line: XinglanChatLine = {
    id: item.id,
    strategy: item.strategy,
    emotion: XinglanEmotionTag.ANY,
    topic: XinglanTopicTag.ANY,
    text: item.text
  };
  return line;
}

/** 全量结构化文案总数 */
export function getStructuredCopyCount(): number {
  return STRUCTURED_COPY.length;
}

/** 按策略统计条数（用于验收与日志）*/
export function countStructuredCopyByStrategy(strategy: XinglanReplyStrategy): number {
  let count: number = 0;
  for (let i = 0; i < STRUCTURED_COPY.length; i++) {
    if (STRUCTURED_COPY[i].strategy === strategy) {
      count++;
    }
  }
  return count;
}
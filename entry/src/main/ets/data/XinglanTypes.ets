/**
 * 星澜聊天 — 核心类型与枚举定义 v1.0
 *
 * 设计依据：《星澜聊天功能设计 v1.0》
 * 用途：本地离线情绪陪伴聊天的类型层，供 Analyzer / Router / Composer / SafetyGuard 共用。
 *
 * 工程约束：
 *  - 全部使用显式 enum / interface，不使用 any / as any / 匿名对象 / Record<>。
 *  - 枚举值使用大写蛇形命名，匹配 TopicSlotExtractor 和 Composer 的 switch-case 路由。
 */

// ═══════════════════════════════════════════
// 情绪标签
// ═══════════════════════════════════════════
export enum XinglanEmotionTag {
  ANY = 'ANY',
  TIRED = 'TIRED',
  ANXIOUS = 'ANXIOUS',
  SAD = 'SAD',
  LONELY = 'LONELY',
  CONFUSED = 'CONFUSED',
  ANGRY = 'ANGRY',
  GUILTY = 'GUILTY',
  NUMB = 'NUMB',
  HOPEFUL = 'HOPEFUL',
  UNCERTAIN = 'UNCERTAIN',
  UNKNOWN = 'UNKNOWN'
}

// ═══════════════════════════════════════════
// 主题标签
// ═══════════════════════════════════════════
export enum XinglanTopicTag {
  ANY = 'ANY',
  SELF = 'SELF',
  RELATION = 'RELATION',
  WORK = 'WORK',
  STUDY = 'STUDY',
  FAMILY = 'FAMILY',
  FRIENDSHIP = 'FRIENDSHIP',
  CHOICE = 'CHOICE',
  FUTURE = 'FUTURE',
  TAROT_CARD = 'TAROT_CARD',
  ROLE_INTERACTION = 'ROLE_INTERACTION',
  UNKNOWN = 'UNKNOWN'
}

// ═══════════════════════════════════════════
// 边界标签
// ═══════════════════════════════════════════
export enum XinglanBoundaryTag {
  NONE = 'NONE',
  PREDICTION = 'PREDICTION',
  PROFESSIONAL = 'PROFESSIONAL',
  CRISIS = 'CRISIS',
  ROLE_BOUNDARY = 'ROLE_BOUNDARY',
  ADULT_BOUNDARY = 'ADULT_BOUNDARY'
}

// ═══════════════════════════════════════════
// 子主题标签（30 类细分）
// ═══════════════════════════════════════════
export enum XinglanSubTopicTag {
  ANY = 'ANY',

  // 关系类
  RELATION_AMBIGUOUS = 'RELATION_AMBIGUOUS',
  RELATION_UNREPLIED = 'RELATION_UNREPLIED',
  RELATION_NO_LABEL = 'RELATION_NO_LABEL',
  RELATION_EX = 'RELATION_EX',
  RELATION_RECONCILE = 'RELATION_RECONCILE',
  RELATION_CONTACT_EX = 'RELATION_CONTACT_EX',
  RELATION_INSECURE = 'RELATION_INSECURE',
  RELATION_COLD = 'RELATION_COLD',
  RELATION_CONTINUE_OR_NOT = 'RELATION_CONTINUE_OR_NOT',

  // 朋友类
  FRIEND_DISTANCE = 'FRIEND_DISTANCE',
  FRIEND_EXCLUDE = 'FRIEND_EXCLUDE',
  FRIEND_BOUNDARY = 'FRIEND_BOUNDARY',

  // 家庭类
  FAMILY_CONTROL = 'FAMILY_CONTROL',
  FAMILY_COMPARISON = 'FAMILY_COMPARISON',
  FAMILY_ESCAPE = 'FAMILY_ESCAPE',

  // 工作类
  WORK_BURNOUT = 'WORK_BURNOUT',
  WORK_RESIGN = 'WORK_RESIGN',
  WORK_MEANINGLESS = 'WORK_MEANINGLESS',

  // 学习类
  STUDY_EXAM = 'STUDY_EXAM',
  STUDY_PROCRASTINATION = 'STUDY_PROCRASTINATION',
  STUDY_SELF_DOUBT = 'STUDY_SELF_DOUBT',

  // 自我类
  SELF_WORTH = 'SELF_WORTH',
  SELF_INFERIOR = 'SELF_INFERIOR',
  SELF_PEOPLE_PLEASE = 'SELF_PEOPLE_PLEASE',
  ANXIETY_OVERTHINK = 'ANXIETY_OVERTHINK',
  ANXIETY_FUTURE = 'ANXIETY_FUTURE',
  ANXIETY_MISTAKE = 'ANXIETY_MISTAKE',
  LOW_ENERGY_EXHAUSTED = 'LOW_ENERGY_EXHAUSTED',
  LOW_ENERGY_NOTHING = 'LOW_ENERGY_NOTHING',
  LOW_ENERGY_SHUTDOWN = 'LOW_ENERGY_SHUTDOWN',
  LONELY_NOT_UNDERSTOOD = 'LONELY_NOT_UNDERSTOOD',
  LONELY_CANT_TELL = 'LONELY_CANT_TELL',
  LONELY_SURROUNDED = 'LONELY_SURROUNDED',

  // 选择类
  CHOICE_BREAKUP = 'CHOICE_BREAKUP',
  CHOICE_RESIGN = 'CHOICE_RESIGN',
  CHOICE_CONTACT = 'CHOICE_CONTACT',

  // 未来预测类
  FUTURE_RESULT = 'FUTURE_RESULT',
  FUTURE_TIME = 'FUTURE_TIME',
  FUTURE_LUCK = 'FUTURE_LUCK',

  // 情绪爆发类
  EMOTION_CRY = 'EMOTION_CRY',
  EMOTION_COLLAPSE = 'EMOTION_COLLAPSE',
  EMOTION_ESCAPE = 'EMOTION_ESCAPE',

  // 深夜类
  NIGHT_INSOMNIA = 'NIGHT_INSOMNIA',
  NIGHT_RUMINATION = 'NIGHT_RUMINATION',
  NIGHT_PHONE_SCROLL = 'NIGHT_PHONE_SCROLL',

  // 愧疚类
  GUILT_SELFBLAME = 'GUILT_SELFBLAME',
  GUILT_HURT_OTHERS = 'GUILT_HURT_OTHERS',
  GUILT_SELFISH = 'GUILT_SELFISH',

  // 愤怒类
  ANGER_UNFAIR = 'ANGER_UNFAIR',
  ANGER_BETRAYED = 'ANGER_BETRAYED',
  ANGER_USED = 'ANGER_USED',

  // 麻木类
  NUMB_EMPTY = 'NUMB_EMPTY',
  NUMB_NOTHING_FUN = 'NUMB_NOTHING_FUN',
  NUMB_GLASS = 'NUMB_GLASS',

  // 塔罗类
  TAROT_CARD_MEANING = 'TAROT_CARD_MEANING',
  TAROT_RECONCILE = 'TAROT_RECONCILE',
  TAROT_DEATH_CARD = 'TAROT_DEATH_CARD',

  // 专业 / 危机
  PROFESSIONAL_MEDICAL = 'PROFESSIONAL_MEDICAL',
  PROFESSIONAL_LEGAL = 'PROFESSIONAL_LEGAL',
  CRISIS_SELF_HARM = 'CRISIS_SELF_HARM',

  // 角色互动
  ROLE_CONFESSION = 'ROLE_CONFESSION',
  ROLE_LOVE = 'ROLE_LOVE',
  ROLE_MARRY = 'ROLE_MARRY',
  ROLE_MISS = 'ROLE_MISS',
  ROLE_ONLY_YOU = 'ROLE_ONLY_YOU',
  ROLE_STAY = 'ROLE_STAY',
  ROLE_COMFORT = 'ROLE_COMFORT',
  ROLE_SOOTHE = 'ROLE_SOOTHE',
  ROLE_HIDE_AWHILE = 'ROLE_HIDE_AWHILE',
  ROLE_NICKNAME = 'ROLE_NICKNAME',
  ROLE_SISTER = 'ROLE_SISTER',
  ROLE_POSSESSIVE_NAME = 'ROLE_POSSESSIVE_NAME',
  ROLE_TEASE = 'ROLE_TEASE',
  ROLE_JEALOUSY = 'ROLE_JEALOUSY',
  ROLE_ONLY_ME = 'ROLE_ONLY_ME',
  ROLE_THANKS = 'ROLE_THANKS',
  ROLE_PRAISE = 'ROLE_PRAISE',
  ROLE_FEEL_HEARD = 'ROLE_FEEL_HEARD',
  ROLE_NOT_UNDERSTAND = 'ROLE_NOT_UNDERSTAND',
  ROLE_WRONG = 'ROLE_WRONG',
  ROLE_PERFUNCTORY = 'ROLE_PERFUNCTORY',
  ROLE_INSULT = 'ROLE_INSULT',
  ROLE_TELL_SHUTUP = 'ROLE_TELL_SHUTUP',
  ROLE_SOFTWARE = 'ROLE_SOFTWARE',
  ROLE_CONTROL = 'ROLE_CONTROL',
  ROLE_DONT_LEAVE = 'ROLE_DONT_LEAVE',
  ROLE_MUST_LOVE = 'ROLE_MUST_LOVE',
  ROLE_ADULT = 'ROLE_ADULT',
  ROLE_SEXUAL_ROLEPLAY = 'ROLE_SEXUAL_ROLEPLAY',
  ROLE_BODY_DESCRIPTION = 'ROLE_BODY_DESCRIPTION'
}

// ═══════════════════════════════════════════
// 回复策略枚举
// ═══════════════════════════════════════════
export enum XinglanReplyStrategy {
  HOLD_EMOTION = 'HOLD_EMOTION',
  REFLECT = 'REFLECT',
  RELATION_BOUNDARY = 'RELATION_BOUNDARY',
  CLARIFY = 'CLARIFY',
  TINY_STEP = 'TINY_STEP',
  TAROT_METAPHOR = 'TAROT_METAPHOR',
  SAFETY_BOUNDARY = 'SAFETY_BOUNDARY',
  SOFT_QUESTION = 'SOFT_QUESTION',
  ROLE_BOUNDARY = 'ROLE_BOUNDARY',
  GENTLE_REFUSAL = 'GENTLE_REFUSAL',
  DEESCALATE = 'DEESCALATE'
}

// ═══════════════════════════════════════════
// 分析结果结构
// ═══════════════════════════════════════════
export interface XinglanAnalyzerResult {
  emotion: XinglanEmotionTag;
  topic: XinglanTopicTag;
  subTopic: XinglanSubTopicTag;
  boundary: XinglanBoundaryTag;
  strategies: XinglanReplyStrategy[];
  priority: number;
}

// ═══════════════════════════════════════════
// 主题槽位
// ═══════════════════════════════════════════
export interface XinglanTopicSlot {
  subject: string;
  action: string;
  painPoint: string;
  need: string;
}

// ═══════════════════════════════════════════
// 关键词规则
// ═══════════════════════════════════════════
export interface XinglanKeywordRule {
  id: string;
  keywords: string[];
  emotion: XinglanEmotionTag;
  topic: XinglanTopicTag;
  subTopic: XinglanSubTopicTag;
  boundary: XinglanBoundaryTag;
  priority: number;
  strategies: XinglanReplyStrategy[];
}

// ═══════════════════════════════════════════
// 聊天消息
// ═══════════════════════════════════════════
export interface XinglanChatMessage {
  id: string;
  role: 'USER' | 'XINGLAN';
  text: string;
  timestamp: number;
  emotionTag?: XinglanEmotionTag;
  topicTag?: XinglanTopicTag;
}

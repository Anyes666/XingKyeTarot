export enum ArcanaType {
  MAJOR = 'major',
  MINOR = 'minor'
}

export enum TarotSuit {
  NONE = 'none',
  WANDS = 'wands',
  CUPS = 'cups',
  SWORDS = 'swords',
  PENTACLES = 'pentacles'
}

export interface TarotCard {
  id: string;
  index: number;
  nameZh: string;
  nameEn: string;
  arcana: ArcanaType;
  suit: TarotSuit;
  image: string;
  keywords: string[];
}

export interface CardInterpretation {
  cardId: string;
  upright: string;
  reversed: string;
  uprightKeywords: string[];
  reversedKeywords: string[];
}

// ═══════════════════════════════════════════════════════════
// MVP P0 新增类型（追加，不动旧 interface）
// ═══════════════════════════════════════════════════════════

/** 6 种情绪标签 */
export type EmotionTag = '关系内耗' | '关系评估' | '职场疲惫' | '选择纠结' | '能量低落' | '寻求安慰';

/** 场景化解读内容（每个情绪标签对应一套内容） */
export interface ScenarioContent {
  /** 一句扎心金句（P0 必填） */
  goldenSentence: string;
  /** 情绪关键词（最多 3 个，P0 必填） */
  emotionKeywords: string[];
  /** 今日行动建议（一句，P0 必填） */
  todayAction: string;
  /** 情绪安抚（P1 预留，P0 可为空） */
  soothingMessage?: string;
  /** 星澜提醒（P1 预留，P0 可为空） */
  moonReminder?: string;
}

/** 追问选项 */
export interface FollowUpOption {
  emoji: string;
  label: string;
  response: string;
}

/** 追问问题 */
export interface FollowUpQuestion {
  id: string;
  question: string;
  options: FollowUpOption[];
}

/** 深度解读 */
export interface DeepInterpretation {
  cardId: string;
  personalityType: string;
  deepInterpretation: string;
  cardMeaningBrief: string;
}

/** 结构化解读（一张牌的全部 P0 数据） */
export interface StructuredInterpretation {
  cardId: string;
  scenarioMap: Record<EmotionTag, ScenarioContent>;
  followUpQuestions: FollowUpQuestion[];
  personalityType: string;
  deepInterpretation: string;
  cardMeaningBrief: string;
}

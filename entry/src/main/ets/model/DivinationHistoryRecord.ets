/**
 * P0.2 占卜历史记录模型
 *
 * 新建独立于旧 MvpDivinationRecord / DivinationRecord 的历史记录结构，
 * 支持 SINGLE / TRIANGLE / RELATION 三种牌阵。
 */

/** 牌阵类型 */
export enum SpreadType {
  SINGLE = 'SINGLE',
  TRIANGLE = 'TRIANGLE',
  RELATION = 'RELATION',
  CARD_WHEEL = 'CARD_WHEEL',
}

/** 入口模式 */
export enum EntryMode {
  FIRST_EXPERIENCE = 'FIRST_EXPERIENCE',
  NORMAL_SINGLE = 'NORMAL_SINGLE',
  CARD_WHEEL = 'CARD_WHEEL',
}

/** 单张已抽牌记录 */
export interface DrawnCardRecord {
  positionKey: string;    // 'guidance' | 'past' | 'present' | 'future' | 'self' | 'other' | 'trend'
  positionTitle: string;  // '指引' | '过去' | '现在' | '未来' | '我' | '对方' | '走向'
  cardId: string;
  cardName: string;
  isReversed: boolean;
  keyword: string;
  goldenSentence: string;
  brief: string;
  action: string;
}

/** 占卜历史记录 */
export interface DivinationHistoryRecord {
  id: string;
  timestamp: number;
  spreadType: SpreadType;
  modeTitle: string;
  questionText: string;
  scenarioTag: string;
  cards: DrawnCardRecord[];
  summaryTitle: string;
  summaryText: string;
  adviceText: string;
  shareText: string;
}

/**
 * 生成历史记录唯一 ID
 * 格式：rec_timestamp_randomHex
 */
export function generateHistoryRecordId(): string {
  const ts: number = Date.now();
  const randomHex: string = Math.random().toString(36).substring(2, 8);
  return `rec_${ts}_${randomHex}`;
}

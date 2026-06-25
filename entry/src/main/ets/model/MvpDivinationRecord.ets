/**
 * P0 MVP 抽牌记录接口
 *
 * 冲突决议 #1：不修改旧 model/DivinationRecord.ets，新建本文件。
 * P0 使用本接口；v1.x 继续使用旧 DivinationRecord。
 */
export interface MvpDivinationRecord {
  /** UUID 格式的唯一记录 ID */
  id: string;
  /** 抽牌时间戳（毫秒） */
  timestamp: number;
  /** 抽到的牌 ID，例如 'major_18_moon' */
  cardId: string;
  /** P0 固定为 false（不做逆位） */
  isReversed: false;
  /** 问心选项索引（0-5） */
  heartOptionIndex: number;
  /** 情绪标签 */
  heartEmotionTag: string;
  /** 命中的金句 */
  goldenSentence: string;
}

/**
 * 生成临时 UUID（简化版，用于 P0 本地记录）
 * 格式：timestamp-randomHex
 */
export function generateRecordId(): string {
  const ts: number = Date.now();
  const randomHex: string = Math.floor(Math.random() * 0xFFFFFFFFFFFF).toString(16).padStart(12, '0');
  return `${ts}-${randomHex}`;
}

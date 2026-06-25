import { EmotionTag } from '../model/TarotCard';
import { MVP8_CARD_IDS } from './MVP8CardsData';

/**
 * 抽牌权重条目
 */
export interface CardWeightItem {
  cardId: string;
  weight: number;
}

/**
 * 加权随机抽牌结果
 */
export interface DrawCardResult {
  cardId: string;
  isReversed: boolean;
}

/**
 * 情绪权重分组
 */
export interface EmotionWeightGroup {
  emotionTag: EmotionTag;
  weights: CardWeightItem[];
}

/**
 * 问心选项接口
 */
export interface HeartOption {
  index: number;             // 0-5
  emoji: string;             // 💔 💕 😮‍💨 🔀 🫥 🫂
  label: string;             // 显示文案
  emotionTag: EmotionTag;    // 情绪标签
}

/**
 * 6 个问心选项数据
 * 来源：规格书附录 A
 */
export const HEART_OPTIONS: HeartOption[] = [
  { index: 0, emoji: '💔', label: '他/她忽冷忽热，我很内耗', emotionTag: '关系内耗' },
  { index: 1, emoji: '💕', label: '我想知道这段关系值不值得', emotionTag: '关系评估' },
  { index: 2, emoji: '😮‍💨', label: '我最近工作很累，想逃离', emotionTag: '职场疲惫' },
  { index: 3, emoji: '🔀', label: '我正在纠结一个选择', emotionTag: '选择纠结' },
  { index: 4, emoji: '🫥', label: '我感觉自己能量很低', emotionTag: '能量低落' },
  { index: 5, emoji: '🫂', label: '我只是想被安慰一下', emotionTag: '寻求安慰' },
];

/**
 * cardWeights 权重矩阵
 * Key = emotionTag, Value = { cardId: weight }
 * 来源：规格书附录 B（每行和为 100%）
 * 只引用 MVP 8 张牌
 */
export const CARD_WEIGHTS: Record<EmotionTag, Record<string, number>> = {
  '关系内耗': {
    'major_00_fool': 5,
    'major_02_high_priestess': 10,
    'major_06_lovers': 15,
    'major_07_chariot': 8,
    'major_09_hermit': 12,
    'major_10_wheel_of_fortune': 5,
    'major_13_death': 10,
    'major_18_moon': 35,
  },
  '关系评估': {
    'major_00_fool': 8,
    'major_02_high_priestess': 20,
    'major_06_lovers': 25,
    'major_07_chariot': 12,
    'major_09_hermit': 5,
    'major_10_wheel_of_fortune': 10,
    'major_13_death': 15,
    'major_18_moon': 5,
  },
  '职场疲惫': {
    'major_00_fool': 18,
    'major_02_high_priestess': 10,
    'major_06_lovers': 5,
    'major_07_chariot': 20,
    'major_09_hermit': 12,
    'major_10_wheel_of_fortune': 18,
    'major_13_death': 12,
    'major_18_moon': 5,
  },
  '选择纠结': {
    'major_00_fool': 22,
    'major_02_high_priestess': 10,
    'major_06_lovers': 22,
    'major_07_chariot': 15,
    'major_09_hermit': 10,
    'major_10_wheel_of_fortune': 10,
    'major_13_death': 8,
    'major_18_moon': 3,
  },
  '能量低落': {
    'major_00_fool': 15,
    'major_02_high_priestess': 10,
    'major_06_lovers': 5,
    'major_07_chariot': 8,
    'major_09_hermit': 25,
    'major_10_wheel_of_fortune': 5,
    'major_13_death': 15,
    'major_18_moon': 17,
  },
  '寻求安慰': {
    'major_00_fool': 12,
    'major_02_high_priestess': 15,
    'major_06_lovers': 10,
    'major_07_chariot': 5,
    'major_09_hermit': 18,
    'major_10_wheel_of_fortune': 10,
    'major_13_death': 5,
    'major_18_moon': 25,
  },
};

/**
 * 加权随机抽牌
 *
 * 根据指定的 emotionTag 按 cardWeights 权重随机抽取一张牌。
 * 只允许 MVP8 张牌；若权重中包含非 MVP cardId，fallback 到 major_18_moon。
 *
 * @param emotionTag - 用户选择的情绪标签
 * @param seed - 可选随机种子（用于测试）
 * @returns { cardId: string, isReversed: false } — P0 固定正位
 */
export function drawCardByWeight(
  emotionTag: EmotionTag,
  seed?: number
): DrawCardResult {
  const weights: Record<string, number> | undefined = CARD_WEIGHTS[emotionTag];
  if (!weights) {
    // 无匹配权重时 fallback
    const fallbackResult: DrawCardResult = {
      cardId: 'major_18_moon',
      isReversed: false
    };
    return fallbackResult;
  }

  // 收集加权条目，过滤非 MVP8 cardId
  const entries: CardWeightItem[] = [];
  let totalWeight: number = 0;

  for (const cardId of MVP8_CARD_IDS) {
    const w: number = weights[cardId] ?? 0;
    if (w > 0) {
      entries.push({ cardId, weight: w });
      totalWeight += w;
    }
  }

  // 如果所有权重为 0，fallback
  if (entries.length === 0 || totalWeight <= 0) {
    const zeroWeightResult: DrawCardResult = {
      cardId: 'major_18_moon',
      isReversed: false
    };
    return zeroWeightResult;
  }

  // 加权随机
  const random: number = seed ?? Math.random();
  let randomValue: number = random * totalWeight;
  let selectedCardId: string = 'major_18_moon'; // 默认 fallback

  for (const entry of entries) {
    randomValue -= entry.weight;
    if (randomValue <= 0) {
      selectedCardId = entry.cardId;
      break;
    }
  }

  // 最终安全校验：非 MVP8 fallback
  if (!MVP8_CARD_IDS.includes(selectedCardId)) {
    selectedCardId = 'major_18_moon';
  }

  const result: DrawCardResult = {
    cardId: selectedCardId,
    isReversed: false
  };
  return result;
}

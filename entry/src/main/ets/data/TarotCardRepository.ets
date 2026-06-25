import {
  MVP8_CARD_IDS,
  MVP8_CARD_NAMES,
  MVP8_CARD_IMAGES,
  getMVP8CardData,
  getScenarioContent,
} from './MVP8CardsData';
import { drawCardByWeight } from './HeartOptionsData';
import { TAROT_CARDS } from './TarotCardData';
import { TarotCard, EmotionTag } from '../model/TarotCard';

/**
 * 抽牌结果
 */
export interface DrawCardResult {
  cardId: string;
  isReversed: boolean;
}

/**
 * 牌库统一访问仓库
 * 当前优先使用 MVP 8 张牌，预留 78 张扩展能力。
 */
export class TarotCardRepository {
  /**
   * 抽取单张牌
   * @param emotionTag - 可选情绪标签，有则加权抽取，无则均匀随机
   */
  static drawSingleCard(emotionTag?: EmotionTag): DrawCardResult {
    if (emotionTag) {
      return drawCardByWeight(emotionTag);
    }
    // 无情绪标签：均匀随机从 MVP8
    const randomIndex: number = Math.floor(Math.random() * MVP8_CARD_IDS.length);
    const cardId: string = MVP8_CARD_IDS[randomIndex];
    const result: DrawCardResult = {
      cardId: cardId,
      isReversed: false,
    };
    return result;
  }

  /**
   * 抽取 count 张不重复的牌（Fisher-Yates 洗牌）
   * @param count - 抽取数量，最大不超过 MVP8_CARD_IDS 长度
   */
  static drawUniqueCards(count: number): DrawCardResult[] {
    const pool: string[] = [...MVP8_CARD_IDS];
    const len: number = pool.length;

    // Fisher-Yates 洗牌
    for (let i: number = len - 1; i > 0; i--) {
      const j: number = Math.floor(Math.random() * (i + 1));
      const temp: string = pool[i];
      pool[i] = pool[j];
      pool[j] = temp;
    }

    const selectedCount: number = Math.min(count, len);
    const results: DrawCardResult[] = [];
    for (let k: number = 0; k < selectedCount; k++) {
      const drawResult: DrawCardResult = {
        cardId: pool[k],
        isReversed: false,
      };
      results.push(drawResult);
    }
    return results;
  }

  /**
   * 根据 cardId 获取 TarotCard 数据（全量 78 张）
   */
  static getCardById(cardId: string): TarotCard | undefined {
    return TAROT_CARDS.find((card: TarotCard) => card.id === cardId);
  }

  /**
   * 根据 cardId 获取中文牌名
   */
  static getCardName(cardId: string): string {
    const fromMvp8: string | undefined = MVP8_CARD_NAMES[cardId];
    if (fromMvp8) {
      return fromMvp8;
    }
    const tarotCard: TarotCard | undefined = TarotCardRepository.getCardById(cardId);
    return tarotCard?.nameZh ?? '';
  }

  /**
   * 根据 cardId 获取情绪关键词（取第一个）
   * 从场景化解读中提取 emotionKeywords，场景不存在时 fallback 到 TarotCard.keywords
   */
  static getCardKeyword(cardId: string): string {
    // 尝试通过场景化解读获取情绪关键词
    try {
      const scenario = getScenarioContent(cardId, '寻求安慰' as EmotionTag);
      if (scenario && scenario.emotionKeywords && scenario.emotionKeywords.length > 0) {
        return scenario.emotionKeywords[0];
      }
    } catch (_err) {
      // scenario not found, fall through
    }
    // 兼容不存在场景数据的牌：从 TarotCard.keywords fallback
    const tc: TarotCard | undefined = TarotCardRepository.getCardById(cardId);
    if (tc && tc.keywords && tc.keywords.length > 0) {
      return tc.keywords[0];
    }
    return '';
  }

  /**
   * 获取牌的简要说明
   */
  static getCardBrief(cardId: string, emotionTag?: EmotionTag): string {
    if (emotionTag) {
      const scenario = getScenarioContent(cardId, emotionTag);
      if (scenario && scenario.emotionKeywords && scenario.emotionKeywords.length > 0) {
        return scenario.goldenSentence;
      }
    }
    const mvp8Data = getMVP8CardData(cardId);
    if (mvp8Data && mvp8Data.cardMeaningBrief) {
      return mvp8Data.cardMeaningBrief;
    }
    return '';
  }

  /**
   * 获取今日行动建议
   */
  static getCardAction(cardId: string, emotionTag?: EmotionTag): string {
    if (emotionTag) {
      const scenario = getScenarioContent(cardId, emotionTag);
      if (scenario && scenario.todayAction) {
        return scenario.todayAction;
      }
    }
    return '';
  }

  /**
   * 获取牌面图片资源
   */
  static getCardImage(cardId: string): Resource {
    const img: Resource | undefined = MVP8_CARD_IMAGES[cardId];
    if (img) {
      return img;
    }
    return $r('app.media.tarot_major_18_moon');
  }
}

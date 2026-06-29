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
   * 获取牌面图片资源（完整 78 张映射）
   */
  static getCardImage(cardId: string): Resource {
    // 优先查 MVP8_CARD_IMAGES
    const img: Resource | undefined = MVP8_CARD_IMAGES[cardId];
    if (img) {
      return img;
    }
    // 完整 78 张映射（大阿卡纳 + 小阿卡纳）
    switch (cardId) {
      case 'major_01_magician': return $r('app.media.tarot_major_01_magician');
      case 'major_03_empress': return $r('app.media.tarot_major_03_empress');
      case 'major_04_emperor': return $r('app.media.tarot_major_04_emperor');
      case 'major_05_hierophant': return $r('app.media.tarot_major_05_hierophant');
      case 'major_08_strength': return $r('app.media.tarot_major_08_strength');
      case 'major_11_justice': return $r('app.media.tarot_major_11_justice');
      case 'major_12_hanged_man': return $r('app.media.tarot_major_12_hanged_man');
      case 'major_14_temperance': return $r('app.media.tarot_major_14_temperance');
      case 'major_15_devil': return $r('app.media.tarot_major_15_devil');
      case 'major_16_tower': return $r('app.media.tarot_major_16_tower');
      case 'major_17_star': return $r('app.media.tarot_major_17_star');
      case 'major_19_sun': return $r('app.media.tarot_major_19_sun');
      case 'major_20_judgement': return $r('app.media.tarot_major_20_judgement');
      case 'major_21_world': return $r('app.media.tarot_major_21_world');
      // 权杖组
      case 'minor_wands_01_ace': return $r('app.media.minor_wands_01_ace');
      case 'minor_wands_02_two': return $r('app.media.minor_wands_02_two');
      case 'minor_wands_03_three': return $r('app.media.minor_wands_03_three');
      case 'minor_wands_04_four': return $r('app.media.minor_wands_04_four');
      case 'minor_wands_05_five': return $r('app.media.minor_wands_05_five');
      case 'minor_wands_06_six': return $r('app.media.minor_wands_06_six');
      case 'minor_wands_07_seven': return $r('app.media.minor_wands_07_seven');
      case 'minor_wands_08_eight': return $r('app.media.minor_wands_08_eight');
      case 'minor_wands_09_nine': return $r('app.media.minor_wands_09_nine');
      case 'minor_wands_10_ten': return $r('app.media.minor_wands_10_ten');
      case 'minor_wands_page': return $r('app.media.minor_wands_page');
      case 'minor_wands_knight': return $r('app.media.minor_wands_knight');
      case 'minor_wands_queen': return $r('app.media.minor_wands_queen');
      case 'minor_wands_king': return $r('app.media.minor_wands_king');
      // 圣杯组
      case 'minor_cups_01_ace': return $r('app.media.minor_cups_01_ace');
      case 'minor_cups_02_two': return $r('app.media.minor_cups_02_two');
      case 'minor_cups_03_three': return $r('app.media.minor_cups_03_three');
      case 'minor_cups_04_four': return $r('app.media.minor_cups_04_four');
      case 'minor_cups_05_five': return $r('app.media.minor_cups_05_five');
      case 'minor_cups_06_six': return $r('app.media.minor_cups_06_six');
      case 'minor_cups_07_seven': return $r('app.media.minor_cups_07_seven');
      case 'minor_cups_08_eight': return $r('app.media.minor_cups_08_eight');
      case 'minor_cups_09_nine': return $r('app.media.minor_cups_09_nine');
      case 'minor_cups_10_ten': return $r('app.media.minor_cups_10_ten');
      case 'minor_cups_page': return $r('app.media.minor_cups_page');
      case 'minor_cups_knight': return $r('app.media.minor_cups_knight');
      case 'minor_cups_queen': return $r('app.media.minor_cups_queen');
      case 'minor_cups_king': return $r('app.media.minor_cups_king');
      // 宝剑组
      case 'minor_swords_01_ace': return $r('app.media.minor_swords_01_ace');
      case 'minor_swords_02_two': return $r('app.media.minor_swords_02_two');
      case 'minor_swords_03_three': return $r('app.media.minor_swords_03_three');
      case 'minor_swords_04_four': return $r('app.media.minor_swords_04_four');
      case 'minor_swords_05_five': return $r('app.media.minor_swords_05_five');
      case 'minor_swords_06_six': return $r('app.media.minor_swords_06_six');
      case 'minor_swords_07_seven': return $r('app.media.minor_swords_07_seven');
      case 'minor_swords_08_eight': return $r('app.media.minor_swords_08_eight');
      case 'minor_swords_09_nine': return $r('app.media.minor_swords_09_nine');
      case 'minor_swords_10_ten': return $r('app.media.minor_swords_10_ten');
      case 'minor_swords_page': return $r('app.media.minor_swords_page');
      case 'minor_swords_knight': return $r('app.media.minor_swords_knight');
      case 'minor_swords_queen': return $r('app.media.minor_swords_queen');
      case 'minor_swords_king': return $r('app.media.minor_swords_king');
      // 星币组
      case 'minor_pentacles_01_ace': return $r('app.media.minor_pentacles_01_ace');
      case 'minor_pentacles_02_two': return $r('app.media.minor_pentacles_02_two');
      case 'minor_pentacles_03_three': return $r('app.media.minor_pentacles_03_three');
      case 'minor_pentacles_04_four': return $r('app.media.minor_pentacles_04_four');
      case 'minor_pentacles_05_five': return $r('app.media.minor_pentacles_05_five');
      case 'minor_pentacles_06_six': return $r('app.media.minor_pentacles_06_six');
      case 'minor_pentacles_07_seven': return $r('app.media.minor_pentacles_07_seven');
      case 'minor_pentacles_08_eight': return $r('app.media.minor_pentacles_08_eight');
      case 'minor_pentacles_09_nine': return $r('app.media.minor_pentacles_09_nine');
      case 'minor_pentacles_10_ten': return $r('app.media.minor_pentacles_10_ten');
      case 'minor_pentacles_page': return $r('app.media.minor_pentacles_page');
      case 'minor_pentacles_knight': return $r('app.media.minor_pentacles_knight');
      case 'minor_pentacles_queen': return $r('app.media.minor_pentacles_queen');
      case 'minor_pentacles_king': return $r('app.media.minor_pentacles_king');
      // 临时占位：未知 cardId fallback 到月亮牌
      // TODO: 补齐所有牌面图片资源后移除此 fallback
      default: return $r('app.media.tarot_major_18_moon');
    }
  }
}

import { DailyFortune } from '../model/DailyFortune';
import { TarotCard } from '../model/TarotCard';
import { RandomUtil } from '../utils/RandomUtil';
import { DateUtil } from '../utils/DateUtil';
import { TarotDataService } from './TarotDataService';
import { PreferenceStore } from '../data/PreferenceStore';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'DailyFortuneService';

export class DailyFortuneService {
  /**
   * Returns today's fortune. Cached in Preferences per date key.
   * Same user + same date = same result. Different users = different results.
   *
   * @param userId - Persistent random user identifier (generated on first launch)
   * @param context - Application context for Preferences access
   * @returns DailyFortune for today
   */
  static async getTodayFortune(userId: string, context: Context): Promise<DailyFortune> {
    const dateKey: string = DateUtil.toDateKey();
    const cacheKey: string = `daily_fortune_${dateKey}`;
    const cached: string = await PreferenceStore.getString(cacheKey, '', context);

    if (cached.length > 0) {
      try {
        const parsed: DailyFortune = JSON.parse(cached) as DailyFortune;
        // 基本结构校验，防止缓存数据不完整
        if (parsed && parsed.card && parsed.dateKey) {
          return parsed;
        }
        hilog.warn(0x0000, TAG, 'Cached fortune missing required fields, regenerating');
      } catch (err) {
        hilog.warn(0x0000, TAG, 'Corrupted daily fortune cache, regenerating: %{public}s', JSON.stringify(err));
      }
      // 缓存损坏或数据不完整，清除后重新生成
      await PreferenceStore.putString(cacheKey, '', context);
    }

    const data: TarotDataService = TarotDataService.getInstance();
    const cards: TarotCard[] = data.getAllCards();

    if (cards.length === 0) {
      throw new Error('Cannot generate daily fortune: no cards loaded');
    }

    const seed: string = DateUtil.dailySeed(userId);
    const index: number = RandomUtil.drawUniqueIndexes(cards.length, 1, seed)[0];
    const card: TarotCard = cards[index];
    const isReversed: boolean = RandomUtil.booleanFromSeed(seed, card.id);
    const keywords: string[] = data.getKeywords(card.id, isReversed);

    const fortune: DailyFortune = {
      dateKey: dateKey,
      card: card,
      isReversed: isReversed,
      keyword: keywords.length > 0 ? keywords[0] : '',
      summary: data.getInterpretation(card.id, isReversed),
      createdAt: Date.now()
    };

    await PreferenceStore.putString(cacheKey, JSON.stringify(fortune), context);
    return fortune;
  }

  /**
   * Clears the daily fortune cache for the current date.
   * Useful for testing or forcing a refresh.
   */
  static async clearTodayCache(context: Context): Promise<void> {
    const dateKey: string = DateUtil.toDateKey();
    const cacheKey: string = `daily_fortune_${dateKey}`;
    await PreferenceStore.putString(cacheKey, '', context);
  }
}

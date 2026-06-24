import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../common/Constants';
import { PreferenceStore } from '../data/PreferenceStore';
import { DivinationRecord } from '../model/DivinationRecord';

const TAG: string = 'DivinationHistoryService';

export class DivinationHistoryService {
  static async saveRecord(record: DivinationRecord, context: Context): Promise<void> {
    const history: DivinationRecord[] = await DivinationHistoryService.getRecentRecords(context);
    const deduped: DivinationRecord[] = history.filter((item: DivinationRecord) => item.id !== record.id);
    const nextHistory: DivinationRecord[] = [record, ...deduped]
      .sort((a: DivinationRecord, b: DivinationRecord) => b.createdAt - a.createdAt)
      .slice(0, Constants.DIVINATION_HISTORY_LIMIT);
    await PreferenceStore.putString(
      Constants.PREF_KEY_DIVINATION_HISTORY,
      JSON.stringify(nextHistory),
      context
    );
  }

  static async getRecentRecords(context: Context): Promise<DivinationRecord[]> {
    const cached: string = await PreferenceStore.getString(Constants.PREF_KEY_DIVINATION_HISTORY, '', context);
    if (cached.length === 0) {
      return [];
    }

    try {
      const parsed: DivinationRecord[] = JSON.parse(cached) as DivinationRecord[];
      if (!Array.isArray(parsed)) {
        hilog.warn(0x0000, TAG, 'Divination history is not an array, resetting');
        await PreferenceStore.putString(Constants.PREF_KEY_DIVINATION_HISTORY, '', context);
        return [];
      }
      return parsed
        .filter((item: DivinationRecord) => item && item.id && item.spread && Array.isArray(item.cards))
        .sort((a: DivinationRecord, b: DivinationRecord) => b.createdAt - a.createdAt)
        .slice(0, Constants.DIVINATION_HISTORY_LIMIT);
    } catch (err) {
      hilog.warn(0x0000, TAG, 'Corrupted divination history, resetting: %{public}s', JSON.stringify(err));
      await PreferenceStore.putString(Constants.PREF_KEY_DIVINATION_HISTORY, '', context);
      return [];
    }
  }

  static async clearHistory(context: Context): Promise<void> {
    await PreferenceStore.putString(Constants.PREF_KEY_DIVINATION_HISTORY, '', context);
  }

  static async clearHistoryForTest(context: Context): Promise<void> {
    await DivinationHistoryService.clearHistory(context);
  }
}

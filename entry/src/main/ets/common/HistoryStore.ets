import { PreferenceStore } from '../data/PreferenceStore';
import { Constants } from './Constants';
import { DivinationHistoryRecord, generateHistoryRecordId } from '../model/DivinationHistoryRecord';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'HistoryStore';

/**
 * 历史记录存储服务
 * FIFO 淘汰：最多保存 Constants.HISTORY_MAX_RECORDS 条。
 * 所有方法 try/catch，异常返回安全默认值。
 */
export class HistoryStore {
  /**
   * 添加一条占卜历史记录，自动去重 + FIFO 淘汰
   */
  static async addRecord(context: Context, record: DivinationHistoryRecord): Promise<void> {
    try {
      const records: DivinationHistoryRecord[] = await HistoryStore.getRecords(context);

      // 去重：按 id 移除旧记录
      const deduped: DivinationHistoryRecord[] = records.filter(
        (r: DivinationHistoryRecord) => r.id !== record.id
      );

      // unshift 新记录到最前
      deduped.unshift(record);

      // FIFO 淘汰
      const capped: DivinationHistoryRecord[] = deduped.slice(0, Constants.HISTORY_MAX_RECORDS);

      await PreferenceStore.putString(
        Constants.PREF_KEY_DIVINATION_HISTORY_V2,
        JSON.stringify(capped),
        context
      );
    } catch (err) {
      hilog.warn(0x0000, TAG, 'addRecord error: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 获取全部历史记录（按时间倒序）
   */
  static async getRecords(context: Context): Promise<DivinationHistoryRecord[]> {
    try {
      const raw: string = await PreferenceStore.getString(
        Constants.PREF_KEY_DIVINATION_HISTORY_V2,
        '[]',
        context
      );
      const parsed: DivinationHistoryRecord[] = JSON.parse(raw) as DivinationHistoryRecord[];
      if (!Array.isArray(parsed)) {
        return [];
      }
      // 安全校验：每项必须有 id
      return parsed.filter((r: DivinationHistoryRecord) => typeof r.id === 'string' && r.id.length > 0);
    } catch (err) {
      hilog.warn(0x0000, TAG, 'getRecords error: %{public}s', JSON.stringify(err));
      // 数据损坏时重置为空数组
      try {
        await PreferenceStore.putString(Constants.PREF_KEY_DIVINATION_HISTORY_V2, '[]', context);
      } catch (_resetErr) {
        // 忽略重置失败
      }
      return [];
    }
  }

  /**
   * 按 ID 获取单条记录，不存在返回 null
   */
  static async getRecordById(context: Context, id: string): Promise<DivinationHistoryRecord | null> {
    try {
      const records: DivinationHistoryRecord[] = await HistoryStore.getRecords(context);
      const found: DivinationHistoryRecord | undefined = records.find(
        (r: DivinationHistoryRecord) => r.id === id
      );
      return found ?? null;
    } catch (err) {
      hilog.warn(0x0000, TAG, 'getRecordById error: %{public}s', JSON.stringify(err));
      return null;
    }
  }

  /**
   * 获取今天最新的一条记录（按时间戳降序），无则返回 null
   */
  static async getTodayLatestRecord(context: Context): Promise<DivinationHistoryRecord | null> {
    try {
      const records: DivinationHistoryRecord[] = await HistoryStore.getRecords(context);
      const todayStart: number = HistoryStore.getTodayStartMs();

      const todayRecords: DivinationHistoryRecord[] = records.filter(
        (r: DivinationHistoryRecord) => r.timestamp >= todayStart
      );

      if (todayRecords.length === 0) {
        return null;
      }

      // 按时间戳降序排序，取第一条
      todayRecords.sort((a: DivinationHistoryRecord, b: DivinationHistoryRecord) => b.timestamp - a.timestamp);
      return todayRecords[0];
    } catch (err) {
      hilog.warn(0x0000, TAG, 'getTodayLatestRecord error: %{public}s', JSON.stringify(err));
      return null;
    }
  }

  /**
   * 获取历史记录总条数
   */
  static async getCount(context: Context): Promise<number> {
    try {
      const records: DivinationHistoryRecord[] = await HistoryStore.getRecords(context);
      return records.length;
    } catch (err) {
      hilog.warn(0x0000, TAG, 'getCount error: %{public}s', JSON.stringify(err));
      return 0;
    }
  }

  /**
   * 清空所有记录（调试用）
   * @deprecated 使用 clearAllRecords 替代
   */
  static async clearAllForDebug(context: Context): Promise<void> {
    try {
      await PreferenceStore.putString(Constants.PREF_KEY_DIVINATION_HISTORY_V2, '[]', context);
    } catch (err) {
      hilog.warn(0x0000, TAG, 'clearAllForDebug error: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 按 ID 删除单条记录（P0.3 整改）
   * @returns true 表示删除成功，false 表示未找到或操作失败
   */
  static async deleteRecordById(context: Context, id: string): Promise<boolean> {
    try {
      const records: DivinationHistoryRecord[] = await HistoryStore.getRecords(context);
      const index: number = records.findIndex((r: DivinationHistoryRecord): boolean => r.id === id);
      if (index < 0) {
        return false;
      }
      records.splice(index, 1);
      await PreferenceStore.putString(
        Constants.PREF_KEY_DIVINATION_HISTORY_V2,
        JSON.stringify(records),
        context
      );
      return true;
    } catch (err) {
      hilog.error(0x0000, TAG, 'deleteRecordById error: %{public}s', JSON.stringify(err));
      return false;
    }
  }

  /**
   * 清空全部历史记录（P0.3 整改）
   * @returns true 表示清空成功
   */
  static async clearAllRecords(context: Context): Promise<boolean> {
    try {
      await PreferenceStore.putString(Constants.PREF_KEY_DIVINATION_HISTORY_V2, '[]', context);
      return true;
    } catch (err) {
      hilog.error(0x0000, TAG, 'clearAllRecords error: %{public}s', JSON.stringify(err));
      return false;
    }
  }

  /**
   * 获取当天 00:00:00 的时间戳（毫秒）
   */
  private static getTodayStartMs(): number {
    const now: Date = new Date();
    const todayStart: Date = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    return todayStart.getTime();
  }
}

import { PreferenceStore } from '../../data/PreferenceStore';
import { DateUtil } from '../../utils/DateUtil';
import { DailyDirection } from '../model/DailyDirection';
import { DailyLightContent } from '../model/DailyLightContent';
import { DailyReflection, ReflectionChoice } from '../model/DailyReflection';
import { DailyRitualState } from '../model/DailyRitualState';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'DailyRitualStore';

/**
 * 今日星页状态持久化
 *
 * 职责：
 * - 读取当天状态；
 * - 次日读取时返回新的未完成状态；
 * - 保存方向、内容 ID、完成状态、是否已换一次、晚间回望、是否已保存到星历；
 * - 不直接修改情绪星底层规则；
 * - 不保存完整聊天、不做心理推断、不连续签到。
 */
export class DailyRitualStore {
  private static readonly KEY_STATE: string = 'daily_ritual_v1_state';

  /**
   * 读取今天状态。若存储的 dateKey 不是今天，返回新的未完成状态。
   */
  static async getTodayState(context: Context): Promise<DailyRitualState> {
    const today: string = DateUtil.toDateKey();
    const stored: DailyRitualState | null = await DailyRitualStore.readStoredState(context);

    if (stored === null) {
      return DailyRitualStore.createFreshState(today);
    }

    if (stored.dateKey !== today) {
      return DailyRitualStore.createFreshState(today);
    }

    return stored;
  }

  /**
   * 保存完整状态。dateKey 必须与今天一致，否则会被忽略。
   */
  static async saveState(state: DailyRitualState, context: Context): Promise<void> {
    const today: string = DateUtil.toDateKey();
    if (state.dateKey !== today) {
      hilog.warn(0x0000, TAG, 'saveState ignored: dateKey mismatch');
      return;
    }
    await DailyRitualStore.writeState(state, context);
  }

  /**
   * 标记今日星页已完成。
   */
  static async markCompleted(state: DailyRitualState, context: Context): Promise<DailyRitualState> {
    const today: string = DateUtil.toDateKey();
    if (state.dateKey !== today) {
      hilog.warn(0x0000, TAG, 'markCompleted ignored: dateKey mismatch');
      return state;
    }
    const next: DailyRitualState = DailyRitualStore.cloneState(state);
    next.completed = true;
    await DailyRitualStore.writeState(next, context);
    return next;
  }

  /**
   * 标记今天已经换过一次内容。每天最多一次，由 UI / Provider 调用前判断。
   */
  static async markReplaced(state: DailyRitualState, context: Context): Promise<DailyRitualState> {
    const today: string = DateUtil.toDateKey();
    if (state.dateKey !== today) {
      hilog.warn(0x0000, TAG, 'markReplaced ignored: dateKey mismatch');
      return state;
    }
    const next: DailyRitualState = DailyRitualStore.cloneState(state);
    next.replacedOnce = true;
    await DailyRitualStore.writeState(next, context);
    return next;
  }

  /**
   * 保存当天选中的内容与方向，并更新最近七天内容 ID 窗口。
   */
  static async saveSelectedContent(
    state: DailyRitualState,
    content: DailyLightContent,
    context: Context
  ): Promise<DailyRitualState> {
    const today: string = DateUtil.toDateKey();
    if (state.dateKey !== today) {
      hilog.warn(0x0000, TAG, 'saveSelectedContent ignored: dateKey mismatch');
      return state;
    }

    const recentContentIds: string[] = DailyRitualStore.buildRecentWindow(state.recentContentIds, content.id);
    const next: DailyRitualState = DailyRitualStore.cloneState(state);
    next.direction = content.direction;
    next.contentId = content.id;
    next.recentContentIds = recentContentIds;
    await DailyRitualStore.writeState(next, context);
    return next;
  }

  private static buildRecentWindow(currentIds: string[], selectedId: string): string[] {
    const filtered: string[] = [];
    for (const id of currentIds) {
      if (id !== selectedId) {
        filtered.push(id);
      }
    }
    filtered.push(selectedId);
    if (filtered.length > 7) {
      return filtered.slice(filtered.length - 7);
    }
    return filtered;
  }

  /**
   * 显式克隆状态对象（ArkTS 不支持对象 spread，需逐字段构造）。
   * 返回的新对象与原对象无引用共享，调用方可安全修改字段。
   */
  private static cloneState(state: DailyRitualState): DailyRitualState {
    return {
      dateKey: state.dateKey,
      direction: state.direction,
      contentId: state.contentId,
      completed: state.completed,
      replacedOnce: state.replacedOnce,
      eveningReflection: state.eveningReflection,
      savedToCalendar: state.savedToCalendar,
      recentContentIds: state.recentContentIds
    };
  }
  static async saveEveningReflection(
    state: DailyRitualState,
    reflection: DailyReflection,
    context: Context
  ): Promise<DailyRitualState> {
    const today: string = DateUtil.toDateKey();
    if (state.dateKey !== today) {
      hilog.warn(0x0000, TAG, 'saveEveningReflection ignored: dateKey mismatch');
      return state;
    }
    const next: DailyRitualState = DailyRitualStore.cloneState(state);
    next.eveningReflection = reflection;
    await DailyRitualStore.writeState(next, context);
    return next;
  }

  /**
   * 标记已保存到星历。
   */
  static async markSavedToCalendar(state: DailyRitualState, context: Context): Promise<DailyRitualState> {
    const today: string = DateUtil.toDateKey();
    if (state.dateKey !== today) {
      hilog.warn(0x0000, TAG, 'markSavedToCalendar ignored: dateKey mismatch');
      return state;
    }
    const next: DailyRitualState = DailyRitualStore.cloneState(state);
    next.savedToCalendar = true;
    await DailyRitualStore.writeState(next, context);
    return next;
  }

  /**
   * 测试重置能力：清空今日星页状态。不暴露到用户界面。
   */
  static async resetForTest(context: Context): Promise<void> {
    try {
      await PreferenceStore.putString(DailyRitualStore.KEY_STATE, '', context);
    } catch (_err) {
      hilog.error(0x0000, TAG, 'resetForTest failed');
    }
  }

  private static createFreshState(dateKey: string): DailyRitualState {
    return {
      dateKey: dateKey,
      completed: false,
      replacedOnce: false,
      savedToCalendar: false,
      recentContentIds: []
    };
  }

  private static async readStoredState(context: Context): Promise<DailyRitualState | null> {
    try {
      const json: string = await PreferenceStore.getString(DailyRitualStore.KEY_STATE, '', context);
      if (json.length === 0) {
        return null;
      }
      return DailyRitualStore.parseState(json);
    } catch (_err) {
      hilog.error(0x0000, TAG, 'readStoredState failed');
      return null;
    }
  }

  private static async writeState(state: DailyRitualState, context: Context): Promise<void> {
    try {
      await PreferenceStore.putString(DailyRitualStore.KEY_STATE, JSON.stringify(state), context);
    } catch (_err) {
      hilog.error(0x0000, TAG, 'writeState failed');
    }
  }

  private static parseState(json: string): DailyRitualState | null {
    try {
      const raw: Object = JSON.parse(json);
      if (raw === null || typeof raw !== 'object') {
        return null;
      }
      const obj: Record<string, Object> = raw as Record<string, Object>;
      const dateKey: Object = obj['dateKey'];
      const completed: Object = obj['completed'];
      const replacedOnce: Object = obj['replacedOnce'];
      const savedToCalendar: Object = obj['savedToCalendar'];

      if (typeof dateKey !== 'string' ||
        typeof completed !== 'boolean' ||
        typeof replacedOnce !== 'boolean' ||
        typeof savedToCalendar !== 'boolean') {
        return null;
      }

      const state: DailyRitualState = {
        dateKey: dateKey,
        completed: completed,
        replacedOnce: replacedOnce,
        savedToCalendar: savedToCalendar,
        recentContentIds: []
      };

      const recentContentIdsRaw: Object = obj['recentContentIds'];
      if (recentContentIdsRaw !== undefined && recentContentIdsRaw !== null && Array.isArray(recentContentIdsRaw)) {
        const recentIdsArr: Object[] = recentContentIdsRaw as Object[];
        const validIds: string[] = [];
        for (const id of recentIdsArr) {
          if (typeof id === 'string') {
            validIds.push(id);
          }
        }
        state.recentContentIds = validIds;
      }

      const direction: Object = obj['direction'];
      if (typeof direction === 'string' && DailyRitualStore.isValidDirection(direction)) {
        state.direction = direction as DailyDirection;
      }

      const contentId: Object = obj['contentId'];
      if (typeof contentId === 'string') {
        state.contentId = contentId;
      }

      const eveningReflection: Object = obj['eveningReflection'];
      if (eveningReflection !== undefined &&
        eveningReflection !== null &&
        typeof eveningReflection === 'object') {
        const reflectionObj: Record<string, Object> = eveningReflection as Record<string, Object>;
        const choice: Object = reflectionObj['choice'];
        const createdAt: Object = reflectionObj['createdAt'];
        const note: Object = reflectionObj['note'];
        if (typeof choice === 'string' &&
          DailyRitualStore.isValidReflectionChoice(choice) &&
          typeof createdAt === 'number') {
          const reflection: DailyReflection = {
            choice: choice as ReflectionChoice,
            createdAt: createdAt
          };
          if (typeof note === 'string') {
            reflection.note = note;
          }
          state.eveningReflection = reflection;
        }
      }

      return state;
    } catch (_err) {
      return null;
    }
  }

  private static isValidDirection(value: string): boolean {
    for (const v of Object.values(DailyDirection)) {
      if (v === value) {
        return true;
      }
    }
    return false;
  }

  private static isValidReflectionChoice(value: string): boolean {
    for (const v of Object.values(ReflectionChoice)) {
      if (v === value) {
        return true;
      }
    }
    return false;
  }
}

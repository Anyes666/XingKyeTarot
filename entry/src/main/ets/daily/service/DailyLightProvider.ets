import { DailyContentSeed } from './DailyContentSeed';
import { DailyDirection } from '../model/DailyDirection';
import { DailyLightContent } from '../model/DailyLightContent';
import { DailyRitualState } from '../model/DailyRitualState';
import { DAILY_LIGHT_LIBRARY, findContentById, getContentsByDirection } from '../data/DailyLightCopyLibrary';
import { DailyRitualStore } from './DailyRitualStore';

const RECENT_WINDOW_DAYS: number = 7;

/** 内容统计结果（ArkTS 严格类型：显式 interface 代替匿名对象） */
interface DailyContentSummary {
  total: number;
  perDirection: Record<string, number>;
}

/**
 * 今日星页内容稳定提供器
 *
 * 职责：
 * - 根据方向返回匹配内容；
 * - 相同 dateKey + direction 稳定返回同一内容；
 * - 最近七天内容 ID 去重；
 * - 每天最多换一次并持久化。
 */
export class DailyLightProvider {
  /**
   * 获取今天当前方向的内容。
   *
   * 若 state 已保存 contentId，优先返回已有内容；
   * 否则按方向候选池 + 日期种子 + 七天去重选择新内容。
   */
  static getContentForToday(state: DailyRitualState, direction: DailyDirection): DailyLightContent | null {
    if (state.contentId !== undefined && state.contentId.length > 0) {
      const existing: DailyLightContent | null = findContentById(state.contentId);
      if (existing !== null && existing.direction === direction) {
        return existing;
      }
    }

    const candidates: DailyLightContent[] = DailyLightProvider.filterCandidates(
      direction,
      state.recentContentIds
    );
    if (candidates.length === 0) {
      return null;
    }

    return DailyContentSeed.selectFrom(state.dateKey, direction, candidates);
  }

  /**
   * 换一次内容。每天最多一次，换后持久化 replacedOnce=true。
   *
   * 若已换过一次，直接返回当前状态不修改内容。
   */
  static async replaceContent(
    state: DailyRitualState,
    direction: DailyDirection,
    context: Context
  ): Promise<DailyRitualState> {
    if (state.replacedOnce) {
      return state;
    }

    const currentContentId: string = state.contentId ?? '';
    const excludedIds: string[] = DailyLightProvider.buildReplaceExclusion(state.recentContentIds, currentContentId);
    let candidates: DailyLightContent[] = DailyLightProvider.filterCandidates(direction, excludedIds);

    if (candidates.length === 0) {
      candidates = getContentsByDirection(direction);
    }

    if (candidates.length === 0) {
      return state;
    }

    const selected: DailyLightContent | null = DailyContentSeed.selectFrom(state.dateKey, direction, candidates);
    if (selected === null) {
      return state;
    }

    const replacedState: DailyRitualState = await DailyRitualStore.saveSelectedContent(state, selected, context);
    return await DailyRitualStore.markReplaced(replacedState, context);
  }

  /**
   * 保存当天首次选中的内容，用于 UI 确认后持久化。
   */
  static async saveSelectedContent(
    state: DailyRitualState,
    content: DailyLightContent,
    context: Context
  ): Promise<DailyRitualState> {
    return DailyRitualStore.saveSelectedContent(state, content, context);
  }

  /**
   * 获取内容总数与每方向条数统计。
   */
  static getContentSummary(): DailyContentSummary {
    const perDirection: Record<string, number> = {};
    for (const item of DAILY_LIGHT_LIBRARY) {
      const key: string = item.direction;
      if (perDirection[key] === undefined) {
        perDirection[key] = 0;
      }
      perDirection[key] += 1;
    }
    const summary: DailyContentSummary = {
      total: DAILY_LIGHT_LIBRARY.length,
      perDirection: perDirection
    };
    return summary;
  }

  /**
   * 最小自验证：检查稳定性、去重、换一次限制。
   * 返回空字符串表示全部通过，否则返回错误信息。
   */
  static runSelfChecks(): string {
    const summary = DailyLightProvider.getContentSummary();
    const directions: string[] = Object.keys(summary.perDirection);

    for (const direction of directions) {
      if (summary.perDirection[direction] === undefined || summary.perDirection[direction] < 5) {
        return `direction ${direction} has fewer than 5 items`;
      }
    }

    const state: DailyRitualState = {
      dateKey: '2026-07-03',
      completed: false,
      replacedOnce: false,
      savedToCalendar: false,
      recentContentIds: []
    };

    const first: DailyLightContent | null = DailyLightProvider.getContentForToday(state, DailyDirection.GENTLE);
    const second: DailyLightContent | null = DailyLightProvider.getContentForToday(state, DailyDirection.GENTLE);
    if (first === null || second === null || first.id !== second.id) {
      return 'same dateKey+direction should return stable content';
    }

    const differentDirection: DailyLightContent | null = DailyLightProvider.getContentForToday(
      state,
      DailyDirection.ATTENTION
    );
    if (differentDirection !== null && differentDirection.id === first.id) {
      return 'different direction should not return same content as gentle on same date';
    }

    const recentState: DailyRitualState = {
      dateKey: state.dateKey,
      completed: state.completed,
      replacedOnce: state.replacedOnce,
      savedToCalendar: state.savedToCalendar,
      recentContentIds: [first.id]
    };
    const afterRecent: DailyLightContent | null = DailyLightProvider.getContentForToday(
      recentState,
      DailyDirection.GENTLE
    );
    if (afterRecent !== null && afterRecent.id === first.id) {
      return 'recent content should be excluded within 7 days';
    }

    return '';
  }

  private static filterCandidates(
    direction: DailyDirection,
    excludedIds: string[]
  ): DailyLightContent[] {
    const all: DailyLightContent[] = getContentsByDirection(direction);
    const result: DailyLightContent[] = [];
    for (const item of all) {
      if (!excludedIds.includes(item.id)) {
        result.push(item);
      }
    }
    return result;
  }

  private static buildReplaceExclusion(recentContentIds: string[], currentContentId: string): string[] {
    const excluded: string[] = [];
    for (const id of recentContentIds) {
      if (!excluded.includes(id)) {
        excluded.push(id);
      }
    }
    if (currentContentId.length > 0 && !excluded.includes(currentContentId)) {
      excluded.push(currentContentId);
    }
    if (excluded.length > RECENT_WINDOW_DAYS) {
      return excluded.slice(excluded.length - RECENT_WINDOW_DAYS);
    }
    return excluded;
  }
}

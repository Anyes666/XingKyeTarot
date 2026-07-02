import { DailyDirection } from './DailyDirection';
import { DailyReflection } from './DailyReflection';

/**
 * 今日星页状态
 *
 * 只记录当天可跨重启恢复的最小状态，不保存完整聊天、不做心理推断、不连续签到。
 */
export interface DailyRitualState {
  dateKey: string;
  direction?: DailyDirection;
  contentId?: string;
  completed: boolean;
  replacedOnce: boolean;
  eveningReflection?: DailyReflection;
  savedToCalendar: boolean;
  recentContentIds: string[];
}

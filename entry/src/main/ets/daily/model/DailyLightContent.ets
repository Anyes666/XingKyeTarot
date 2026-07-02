import { DailyDirection } from './DailyDirection';

/**
 * 今日星页三层内容
 *
 * 所有文案均来自本地审核后的文案库，不联网、不调用模型、不做运势判断。
 */
export interface DailyLightContent {
  id: string;
  direction: DailyDirection;
  mainLine: string;
  observation: string;
  microAction: string;
  pocketLight: string;
  warmth: 1 | 2 | 3 | 4 | 5;
  suggestionStrength: 1 | 2 | 3;
  sensitive: boolean;
}

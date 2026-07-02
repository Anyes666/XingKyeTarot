import { DailyDirection } from '../model/DailyDirection';
import { RandomUtil } from '../../utils/RandomUtil';

/**
 * 今日星页内容稳定选择器
 *
 * 相同 dateKey + direction 总是产生相同的伪随机索引，
 * 不依赖联网、不调用模型、不使用随机奖池。
 */
export class DailyContentSeed {
  /**
   * 基于日期与方向生成稳定种子字符串。
   */
  static buildSeed(dateKey: string, direction: DailyDirection): string {
    return `daily-${dateKey}-${direction}`;
  }

  /**
   * 从 [0, total) 中返回一个由种子决定的稳定索引。
   */
  static selectIndex(seed: string, total: number): number {
    if (total <= 0) {
      return 0;
    }
    const values: number[] = RandomUtil.seededNumbers(seed, 1);
    const index: number = Math.floor(values[0] * total);
    return index < total ? index : total - 1;
  }

  /**
   * 从候选列表中按日期+方向稳定选择一条内容。
   * 如果候选为空，返回 null。
   */
  static selectFrom<T>(dateKey: string, direction: DailyDirection, candidates: T[]): T | null {
    if (candidates.length === 0) {
      return null;
    }
    const seed: string = DailyContentSeed.buildSeed(dateKey, direction);
    const index: number = DailyContentSeed.selectIndex(seed, candidates.length);
    return candidates[index];
  }
}

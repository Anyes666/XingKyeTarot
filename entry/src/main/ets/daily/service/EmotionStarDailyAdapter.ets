import { EmotionStarStorage, EmotionStarRecord } from '../../common/EmotionStarStorage';
import { DailyDirection } from '../model/DailyDirection';
import { DailyLightContent } from '../model/DailyLightContent';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'EmotionStarDailyAdapter';

/**
 * 今日星页确认后的点亮结果
 *
 * - LIT          本次成功点亮（今天之前未点亮）
 * - ALREADY_LIT  今天已经点亮过，不重复累计（保持 EmotionStarStorage 既定规则）
 * - FAILED       点亮失败（存储异常等），调用方可展示可重试文案
 */
export enum DailyLightResult {
  LIT = 'lit',
  ALREADY_LIT = 'already_lit',
  FAILED = 'failed'
}

/**
 * 方向 → 星历里展示的短星名（2–4 字，便于星历格子与详情展示）。
 *
 * 不映射为长句，避免星历历史列表里被截断；
 * 也不复用 directionLabel 那种长文案，保持与既有 EmotionStarRecord.starName
 * （如「关系内耗」「职场疲惫」）同等的简短颗粒度。
 */
export function directionStarName(direction: DailyDirection): string {
  switch (direction) {
    case DailyDirection.GENTLE:
      return '温柔';
    case DailyDirection.ATTENTION:
      return '收回注意';
    case DailyDirection.LESS_RESULT:
      return '少追结果';
    case DailyDirection.BLANK:
      return '留白';
    case DailyDirection.SLOW:
      return '慢慢来';
    case DailyDirection.HEAR_SELF:
      return '听见自己';
    case DailyDirection.BOUNDARY:
      return '守住边界';
    case DailyDirection.ALLOW_IMPERFECT:
      return '允许不完美';
    default:
      return '今日星页';
  }
}

/**
 * 今日星页 ↔ 情绪星适配层（DAILY-5）
 *
 * 职责：
 *  1. 查询今天情绪星是否已点亮（复用 EmotionStarStorage.hasLightedToday）；
 *  2. 未点亮时构造记录并调用 EmotionStarStorage.lightToday；
 *  3. 已点亮时返回 ALREADY_LIT，由调用方决定是否展示归档动画（不重复累计）。
 *
 * 规则保护（本适配层绝不绕过或改写）：
 *  - 不修改 EmotionStarStorage.ets 的任何方法、阈值、字段；
 *  - 不改变「每天一次」——lightToday 内部仍会判定今天是否已存在；
 *  - 不改变「未来日期不可点亮」——本适配层只写今天，date 由 lightToday 强制；
 *  - 不改变「重复点亮不累计」——已点亮直接返回 ALREADY_LIT，不再写入；
 *  - 不改变等级阈值（初见 / 星火初亮 / 七日星轨 / 月下自省者 /
 *    星钥守望者 / 星河同行者 / 半年听心者 / 长夜星澜）；
 *  - 不修改历史记录结构——EmotionStarRecord 字段与 sourceType='daily_card'
 *    保持与既有占卜点亮入口一致。
 *
 * 本适配层不引入联网、账号、统计、第三方 SDK。
 */
export class EmotionStarDailyAdapter {
  /**
   * 查询今天情绪星是否已点亮。
   * 查询异常时返回 false，交由后续 lightTodayFromDaily 兜底，不在适配层假成功。
   */
  static async isTodayLit(context: Context): Promise<boolean> {
    try {
      return await EmotionStarStorage.hasLightedToday(context);
    } catch (_err) {
      hilog.warn(0x0000, TAG, 'isTodayLit query failed, treat as not lit');
      return false;
    }
  }

  /**
   * 尝试点亮今天的情绪星。
   *
   * 流程：
   *  1. 先 hasLightedToday 查询；已点亮 → ALREADY_LIT（不重复累计）；
   *  2. 未点亮 → 构造 EmotionStarRecord，调用 lightToday；
   *     - lightToday 返回 true → LIT；
   *     - lightToday 返回 false → 今天已被并发写入，按 ALREADY_LIT 处理；
   *  3. 任意步骤抛错 → FAILED，调用方可重试。
   *
   * 不修改 EmotionStarStorage 规则：内部仍由 lightToday 做最终的「今天是否已存在」判定。
   */
  static async lightTodayFromDaily(
    context: Context,
    direction: DailyDirection,
    content: DailyLightContent
  ): Promise<DailyLightResult> {
    try {
      const alreadyLit: boolean = await EmotionStarStorage.hasLightedToday(context);
      if (alreadyLit) {
        return DailyLightResult.ALREADY_LIT;
      }

      const record: EmotionStarRecord = {
        date: EmotionStarStorage.todayString(),
        starName: directionStarName(direction),
        sourceType: 'daily_card',
        cardName: '今日星页',
        createdAt: Date.now()
      };

      const success: boolean = await EmotionStarStorage.lightToday(context, record);
      if (success) {
        return DailyLightResult.LIT;
      }
      // lightToday 返回 false 表示今天已存在（并发或重复），按已点亮处理
      return DailyLightResult.ALREADY_LIT;
    } catch (_err) {
      hilog.error(0x0000, TAG, 'lightTodayFromDaily failed');
      return DailyLightResult.FAILED;
    }
  }
}

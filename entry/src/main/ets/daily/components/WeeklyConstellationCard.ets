import { Theme } from '../../common/Theme';

/**
 * 星图槽位（绝对定位坐标，固定 300x180 画布）
 * 形状参考北斗七星：一段起伏的星轨，避免横排呆板。
 */
interface ConstellationStarSlot {
  x: number;       // 中心 x（vp）
  y: number;       // 中心 y（vp）
  index: number;   // 第几颗（1-7）
}

/**
 * 星图连线（相邻两颗星之间的一段细线）
 * length 与 angle 为预计算值，避免运行时三角函数。
 */
interface ConstellationStarLink {
  x: number;       // 起点 x（vp）
  y: number;       // 起点 y（vp）
  length: number;  // 线段长度（vp）
  angle: number;   // 旋转角度（度，顺时针正）
}

// 北斗状小星图坐标（300x180 画布，左上角原点）
const STAR_SLOTS: ConstellationStarSlot[] = [
  { x: 30,  y: 130, index: 1 },
  { x: 75,  y: 95,  index: 2 },
  { x: 120, y: 115, index: 3 },
  { x: 165, y: 60,  index: 4 },
  { x: 210, y: 80,  index: 5 },
  { x: 245, y: 45,  index: 6 },
  { x: 270, y: 100, index: 7 }
];

// 相邻星之间的连线（共 6 段，从 slot[i] 到 slot[i+1]）
// length / angle 由两点坐标预计算得出，build 时直接取用。
const STAR_LINKS: ConstellationStarLink[] = [
  { x: 30,  y: 130, length: 56, angle: -39 },
  { x: 75,  y: 95,  length: 54, angle: 22 },
  { x: 120, y: 115, length: 68, angle: -54 },
  { x: 165, y: 60,  length: 50, angle: 24 },
  { x: 210, y: 80,  length: 37, angle: -72 },
  { x: 245, y: 45,  length: 65, angle: 66 }
];

/**
 * 每周星图卡（DAILY-8）
 *
 * 累计 7 次点亮形成一幅小星图，不要求连续，纯视觉奖励。
 *
 * 规则保护（V2 计划 10.2 / 10.3 / AGENTS.md）：
 *   - 不修改 EmotionStarStorage 规则，不修改等级阈值；
 *   - 不引入货币 / 抽奖 / 稀有度 / 补签卡 / 付费保连续；
 *   - 漏一天不清零、不惩罚，仅展示安慰文案；
 *   - 奖励仅限视觉：星图纹样 + 完成文案 + 档案标记。
 *
 * 视觉：A「星图档案」
 *   - 档案脊线 + 周期编号 + 等宽字体时间戳；
 *   - 北斗状小星图（300x180 画布，绝对定位 + 预计算连线）；
 *   - 四档进度：1 颗星 / 3 颗星线 / 5 颗局部图案 / 7 颗完整星图；
 *   - 完成态：卡片金色细边 + 完成文案 + 已完成周期数档案标记。
 *
 * 数据：父组件传入 totalLightDays（从 EmotionStarStorage.getTotalLightDays 获取）
 *       与 missedYesterday（昨天未点亮且今天未点亮）。
 * 本组件不直接读写存储。
 */
@Component
export struct WeeklyConstellationCard {
  /** 累计点亮天数（非连续，来自 EmotionStarStorage.getTotalLightDays） */
  @Prop totalLightDays: number = 0;
  /** 昨天是否未点亮（用于显示 V2 计划 10.2 漏一天文案） */
  @Prop missedYesterday: boolean = false;

  /**
   * 当前周期已点亮的星数（1-7）。
   * - totalLightDays = 0 → 0 颗（尚未开始）
   * - totalLightDays = 1..7 → 1..7 颗
   * - totalLightDays = 8..14 → 1..7 颗（下一周期重新计数）
   * 每完成 7 颗进入下一周期，不要求连续。
   */
  private currentCycleStars(): number {
    if (this.totalLightDays <= 0) {
      return 0;
    }
    return ((this.totalLightDays - 1) % 7) + 1;
  }

  /** 已完成的星图周期数（每满 7 颗 +1） */
  private completedCycles(): number {
    if (this.totalLightDays <= 0) {
      return 0;
    }
    return Math.floor((this.totalLightDays - 1) / 7);
  }

  /** 当前周期是否已完成（7 颗全亮） */
  private isCompleted(): boolean {
    return this.currentCycleStars() >= 7;
  }

  /**
   * 进度档位文案（V2 计划 10.3 完成文案为第 7 档原文）
   * 文案只描述"已形成的图案"，不预测未来、不承诺、不施压。
   */
  private progressCaption(): string {
    const stars: number = this.currentCycleStars();
    if (stars === 0) {
      return '今天的第一颗星，会从这里开始。';
    }
    if (stars === 1) {
      return '第一颗星已经亮起。';
    }
    if (stars === 2) {
      return '两颗星之间，已有一段距离被你走过。';
    }
    if (stars === 3) {
      return '三颗星连成了一小段星线。';
    }
    if (stars === 4) {
      return '四颗星，星线在延伸。';
    }
    if (stars === 5) {
      return '五颗星形成了局部图案。';
    }
    if (stars === 6) {
      return '六颗星，图案已接近完成。';
    }
    // V2 计划 10.3 完成文案（原文）
    return '七颗星已经连成了一小段轨迹。不是因为你从未停下，而是你总会回来看看自己。';
  }

  /** 第 idx 颗星（0-6）是否已点亮 */
  private starIsLit(idx: number): boolean {
    return idx < this.currentCycleStars();
  }

  /**
   * 第 idx 条连线（0-5）的透明度（按进度档位显示）
   * - 第 3 颗星亮起 → 0-1 号连线显形（短星线）
   * - 第 5 颗星亮起 → 0-3 号连线显形（局部图案）
   * - 第 7 颗星亮起 → 0-5 号连线全显形（完整星图）
   */
  private linkOpacity(idx: number): number {
    const stars: number = this.currentCycleStars();
    if (stars >= 7) {
      return 1.0;
    }
    if (stars >= 5 && idx <= 3) {
      return 0.8;
    }
    if (stars >= 3 && idx <= 1) {
      return 0.6;
    }
    return 0.0;
  }

  /** 当前周期编号标签（等宽档案标记） */
  private cycleLabel(): string {
    const n: number = this.completedCycles() + 1;
    return n < 10 ? 'CYCLE 0' + n.toString() : 'CYCLE ' + n.toString();
  }

  build() {
    Column() {
      // ══ A 档案脊线（顶部细金线）══
      Row()
        .width(48)
        .height(1)
        .backgroundColor('rgba(201,164,75,0.45)')
        .margin({ bottom: Theme.V2_SPACE_SM })

      // ══ 档案标题 ══
      Text('每周星图')
        .fontSize(Theme.V2A_FONT_SUBTITLE)
        .fontColor(Theme.V2A_TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .letterSpacing(1)
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ bottom: Theme.V2_SPACE_2XS })

      // 周期编号（等宽字体 · 档案标记）
      Text(this.cycleLabel())
        .fontSize(Theme.V2A_FONT_TIMESTAMP)
        .fontColor(Theme.V2_TEXT_TERTIARY)
        .fontFamily('HarmonyOS Sans Mono')
        .letterSpacing(2)
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ bottom: Theme.V2_SPACE_MD })

      // ══ 星图画布（300x180，居中）══
      Stack() {
        // 底层：极淡星轨装饰线（贯穿画布中段）
        Row()
          .width(260)
          .height(1)
          .backgroundColor('rgba(201,164,75,0.08)')
          .position({ x: 20, y: 90 })

        // 中层：连线（已点亮的星之间显示）
        ForEach(STAR_LINKS, (link: ConstellationStarLink, idx: number) => {
          Row()
            .width(link.length)
            .height(1)
            .backgroundColor('rgba(201,164,75,0.45)')
            .position({ x: link.x, y: link.y })
            .rotate({ angle: link.angle, centerX: 0, centerY: 0 })
            .opacity(this.linkOpacity(idx))
        }, (link: ConstellationStarLink, idx: number) => idx.toString())

        // 上层：7 颗星
        ForEach(STAR_SLOTS, (slot: ConstellationStarSlot, idx: number) => {
          Stack() {
            if (this.starIsLit(idx)) {
              // 已点亮：金色实心星
              Text('★')
                .fontSize(20)
                .fontColor(Theme.V2_STATE_STAR_LIT)
            } else {
              // 未点亮：灰色空心圈
              Text('○')
                .fontSize(14)
                .fontColor(Theme.V2_STATE_STAR_UNLIT)
            }
          }
          .width(28)
          .height(28)
          .alignContent(Alignment.Center)
          .position({ x: slot.x, y: slot.y })
        }, (slot: ConstellationStarSlot) => slot.index.toString())
      }
      .width(300)
      .height(180)
      .alignContent(Alignment.TopStart)

      // ══ 进度档位文案 ══
      Text(this.progressCaption())
        .fontSize(Theme.V2A_FONT_LEAD)
        .fontColor(this.isCompleted() ? Theme.V2A_GOLD_GLOW : Theme.V2A_TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
        .lineHeight(22)
        .letterSpacing(0.3)
        .width('92%')
        .margin({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_SM })

      // ══ 进度数字（等宽字体 · 档案感）══
      Row() {
        Text(this.currentCycleStars().toString())
          .fontSize(Theme.V2A_FONT_BODY)
          .fontColor(Theme.V2A_GOLD_ACCENT)
          .fontFamily('HarmonyOS Sans Mono')

        Text(' / 7')
          .fontSize(Theme.V2A_FONT_CAPTION)
          .fontColor(Theme.V2_TEXT_TERTIARY)
          .fontFamily('HarmonyOS Sans Mono')
      }
      .alignItems(VerticalAlign.Bottom)
      .margin({ bottom: Theme.V2_SPACE_SM })

      // ══ 已完成周期档案标记（仅 completedCycles > 0 时显示）══
      if (this.completedCycles() > 0) {
        Text('已完成 ' + this.completedCycles().toString() + ' 幅小星图')
          .fontSize(Theme.V2A_FONT_CAPTION)
          .fontColor(Theme.V2_TEXT_TERTIARY)
          .fontFamily('HarmonyOS Sans Mono')
          .letterSpacing(0.5)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.V2_SPACE_SM })
      }

      // ══ 漏一天文案（V2 计划 10.2 原文）══
      // 仅当 missedYesterday=true 时显示，不施压、不惩罚。
      if (this.missedYesterday) {
        Column() {
          Row()
            .width(24)
            .height(1)
            .backgroundColor('rgba(138,132,152,0.3)')
            .margin({ bottom: Theme.V2_SPACE_XS })

          Text('昨天没有留下记录，也没关系。星轨不会因为一次停顿而消失。今天可以从这里继续。')
            .fontSize(Theme.V2A_FONT_CAPTION)
            .fontColor(Theme.V2_TEXT_TERTIARY)
            .textAlign(TextAlign.Center)
            .lineHeight(18)
            .letterSpacing(0.3)
            .width('92%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: Theme.V2_SPACE_XS })
      }
    }
    .width('100%')
    .padding(Theme.V2_SPACE_LG)
    .backgroundColor(Theme.V2A_BG_CARD)
    .borderRadius(Theme.V2A_RADIUS_CARD)
    .border({
      width: 1,
      // 完成态：金色细边奖励；进行中：A 方案星轨线边框
      color: this.isCompleted() ? 'rgba(201,164,75,0.35)' : Theme.V2A_ORBIT_LINE
    })
    .shadow(Theme.V2A_SHADOW_CARD)
    .alignItems(HorizontalAlign.Center)
  }
}

import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { EmotionStarStorage, EmotionStarRecord, StarKeyLevel, NextLevelInfo } from '../common/EmotionStarStorage';

/**
 * 最近7日星图条目
 */
interface WeekStarItem {
  dateLabel: string;     // 日期标签（如 "周一" / "M/D"）
  dateStr: string;       // yyyy-MM-dd
  isLit: boolean;        // 是否点亮
  starName: string;      // 星名（情绪标签）
  isToday: boolean;      // 是否今天
}

/**
 * 星历跳转参数
 */
interface StarCalendarRouteParams {
  tab: number;
}

/**
 * 星澜星历页 — A 方案星图档案
 *
 * 功能：7日情绪星图展示 + 当前星钥等级
 * 设计系统：A 方案「星图档案」（V2A Token + 等宽字体时间戳）
 * 参考：deliverables/prototypes/05-star-calendar.html
 */
@Entry
@Component
struct StarCalendarPage {
  @State private weekStars: WeekStarItem[] = [];
  @State private totalLightDays: number = 0;
  @State private currentLevelTitle: string = '初见';
  @State private currentLevelDays: number = 0;
  @State private nextLevelTitle: string = '星火初亮';
  @State private daysToNextLevel: number = 1;
  @State private isMaxLevel: boolean = false;

  aboutToAppear(): void {
    this.loadStarData();
  }

  /**
   * 加载情绪星数据
   */
  private async loadStarData(): Promise<void> {
    try {
      const context: Context = getContext(this);
      const records: EmotionStarRecord[] = await EmotionStarStorage.getRecords(context);
      this.totalLightDays = EmotionStarStorage.getTotalLightDays(records);

      // 计算当前等级
      const currentLevel: StarKeyLevel = EmotionStarStorage.getLevelByTotalDays(this.totalLightDays);
      this.currentLevelTitle = currentLevel.title;
      this.currentLevelDays = currentLevel.threshold;

      // 计算下一等级
      const nextInfo: NextLevelInfo = EmotionStarStorage.getNextLevelInfo(this.totalLightDays);
      this.nextLevelTitle = nextInfo.title;
      this.daysToNextLevel = nextInfo.daysLeft;
      this.isMaxLevel = nextInfo.isMaxLevel;

      // 构建最近7日星图
      this.weekStars = this.buildWeekStars(records);
    } catch (_err) {
      // 加载失败时保持初始空状态
      this.weekStars = this.buildEmptyWeek();
    }
  }

  /**
   * 构建最近7日星图数据
   */
  private buildWeekStars(records: EmotionStarRecord[]): WeekStarItem[] {
    const result: WeekStarItem[] = [];
    const today: Date = new Date();
    const oneDay: number = 24 * 60 * 60 * 1000;
    const weekdayNames: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    for (let i: number = 6; i >= 0; i--) {
      const date: Date = new Date(today.getTime() - i * oneDay);
      const dateStr: string = EmotionStarStorage.formatDateString(
        date.getFullYear(), date.getMonth() + 1, date.getDate()
      );
      const record: EmotionStarRecord | null = EmotionStarStorage.getRecordByDate(records, dateStr);
      const isToday: boolean = EmotionStarStorage.isToday(date.getFullYear(), date.getMonth() + 1, date.getDate());

      result.push({
        dateLabel: weekdayNames[date.getDay()],
        dateStr: dateStr,
        isLit: record !== null,
        starName: record !== null ? record.starName : '',
        isToday: isToday
      });
    }
    return result;
  }

  /**
   * 构建空7日星图（加载失败兜底）
   */
  private buildEmptyWeek(): WeekStarItem[] {
    const result: WeekStarItem[] = [];
    const today: Date = new Date();
    const oneDay: number = 24 * 60 * 60 * 1000;
    const weekdayNames: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    for (let i: number = 6; i >= 0; i--) {
      const date: Date = new Date(today.getTime() - i * oneDay);
      const dateStr: string = EmotionStarStorage.formatDateString(
        date.getFullYear(), date.getMonth() + 1, date.getDate()
      );
      result.push({
        dateLabel: weekdayNames[date.getDay()],
        dateStr: dateStr,
        isLit: false,
        starName: '',
        isToday: EmotionStarStorage.isToday(date.getFullYear(), date.getMonth() + 1, date.getDate())
      });
    }
    return result;
  }

  build() {
    Stack() {
      // ── A 方案星图档案底色 ──
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2A_BG_BASE)

      // ── 主内容 ──
      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.MAIN_FRAME })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        .alignItems(VerticalAlign.Center)

        Scroll() {
          Column() {
            // ══ 页面标题 ══
            Text('星澜星历')
              .fontSize(Theme.V2A_FONT_DISPLAY)
              .fontColor(Theme.V2A_TEXT_PRIMARY)
              .fontWeight(FontWeight.Lighter)
              .letterSpacing(2)
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_2XS })

            // 时间戳副标题（A 方案等宽字体）
            Text(EmotionStarStorage.todayString())
              .fontSize(Theme.V2A_FONT_TIMESTAMP)
              .fontColor(Theme.V2A_TEXT_SECONDARY)
              .fontFamily('HarmonyOS Sans Mono')
              .letterSpacing(1)
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ bottom: Theme.V2_SPACE_XL })

            // ══ 当前星钥等级卡片 ══
            Column() {
              // 等级称号（A 方案标记感）
              Text(this.currentLevelTitle)
                .fontSize(Theme.V2A_FONT_RANK_TITLE)
                .fontColor(Theme.V2A_GOLD_GLOW)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ bottom: Theme.V2_SPACE_2XS })

              // 累计天数（等宽大字）
              Row() {
                Text(this.totalLightDays.toString())
                  .fontSize(Theme.V2A_FONT_RANK_DAYS)
                  .fontColor(Theme.V2A_GOLD_ACCENT)
                  .fontWeight(FontWeight.Bold)
                  .fontFamily('HarmonyOS Sans Mono')

                Text(' 天')
                  .fontSize(Theme.V2A_FONT_BODY)
                  .fontColor(Theme.V2A_TEXT_SECONDARY)
                  .margin({ left: Theme.V2_SPACE_2XS })
              }
              .alignItems(VerticalAlign.Bottom)
              .margin({ bottom: Theme.V2_SPACE_SM })

              // 下一等级进度
              if (!this.isMaxLevel) {
                Text('下一称号：' + this.nextLevelTitle + ' · 还差 ' + this.daysToNextLevel.toString() + ' 天')
                  .fontSize(Theme.V2A_FONT_CAPTION)
                  .fontColor(Theme.V2A_TEXT_SECONDARY)
                  .textAlign(TextAlign.Center)
                  .lineHeight(18)
              } else {
                Text('你已到达最高星钥等级')
                  .fontSize(Theme.V2A_FONT_CAPTION)
                  .fontColor(Theme.V2A_GOLD_ACCENT)
                  .textAlign(TextAlign.Center)
              }
            }
            .width('92%')
            .padding(Theme.V2_SPACE_LG)
            .backgroundColor(Theme.V2A_BG_CARD)
            .borderRadius(Theme.V2A_RADIUS_CARD)
            .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
            .shadow(Theme.V2A_SHADOW_CARD)
            .margin({ bottom: Theme.V2_SPACE_XL })

            // ══ 最近7日情绪星图 ══
            Column() {
              // 区域标题
              Row() {
                Text('最近七日')
                  .fontSize(Theme.V2A_FONT_SUBTITLE)
                  .fontColor(Theme.V2A_TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .margin({ bottom: Theme.V2_SPACE_MD })

              // 7日星点行
              Row() {
                ForEach(this.weekStars, (item: WeekStarItem, index: number) => {
                  Column() {
                    // 星点
                    Stack() {
                      if (item.isLit) {
                        // 已点亮：金色实心星
                        Text('★')
                          .fontSize(24)
                          .fontColor(Theme.V2_STATE_STAR_LIT)
                          .shadow({
                            radius: 8,
                            color: 'rgba(201,164,75,0.3)',
                            offsetX: 0,
                            offsetY: 0
                          })
                      } else {
                        // 未点亮：灰色空心圈
                        Text('○')
                          .fontSize(20)
                          .fontColor(Theme.V2_STATE_STAR_UNLIT)
                      }
                    }
                    .width(36)
                    .height(36)

                    // 日期标签（等宽字体）
                    Text(item.dateLabel)
                      .fontSize(Theme.V2A_FONT_TIMESTAMP)
                      .fontColor(item.isToday ? Theme.V2A_GOLD_ACCENT : Theme.V2A_TEXT_SECONDARY)
                      .fontFamily('HarmonyOS Sans Mono')
                      .margin({ top: Theme.V2_SPACE_2XS })

                    // 星名（如已点亮）
                    if (item.isLit && item.starName.length > 0) {
                      Text(item.starName)
                        .fontSize(10)
                        .fontColor(Theme.V2A_GOLD_GLOW)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width(48)
                        .textAlign(TextAlign.Center)
                        .margin({ top: 2 })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Center)
                }, (item: WeekStarItem) => item.dateStr)
              }
              .width('100%')

              // 今天标记
              Text('● 今天')
                .fontSize(Theme.V2A_FONT_CAPTION)
                .fontColor(Theme.V2A_GOLD_ACCENT)
                .fontFamily('HarmonyOS Sans Mono')
                .margin({ top: Theme.V2_SPACE_SM })
            }
            .width('92%')
            .padding(Theme.V2_SPACE_LG)
            .backgroundColor(Theme.V2A_BG_CARD)
            .borderRadius(Theme.V2A_RADIUS_CARD)
            .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
            .shadow(Theme.V2A_SHADOW_CARD)
            .margin({ bottom: Theme.V2_SPACE_XL })

            // ══ 温柔提示 ══
            Text('每一颗星，都是你认真面对自己的证明。')
              .fontSize(Theme.V2A_FONT_LEAD)
              .fontColor(Theme.V2A_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .lineHeight(24)
              .width('82%')
              .margin({ bottom: Theme.V2_SPACE_2XL })

            Column().height(80)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}

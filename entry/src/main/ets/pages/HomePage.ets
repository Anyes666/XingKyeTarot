import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { HistoryStore } from '../common/HistoryStore';
import { DivinationHistoryRecord } from '../model/DivinationHistoryRecord';

/**
 * AskHeart 页面路由参数
 */
interface AskHeartRouteParams {
  entryMode: string;
}

/**
 * 首页
 *
 * 组件树：
 * - 顶部标题 + 副标题
 * - 今日一占卡片（有记录 / 无记录引导）
 * - 4 个功能卡片（2×2）
 * - 历史查询入口
 * - 合规页脚
 */
@Entry
@Component
struct HomePage {
  @State todayRecord: DivinationHistoryRecord | null = null;
  @State historyCount: number = 0;
  @State isDataLoaded: boolean = false;

  async aboutToAppear(): Promise<void> {
    try {
      this.todayRecord = await HistoryStore.getTodayLatestRecord(getContext(this));
      this.historyCount = await HistoryStore.getCount(getContext(this));
    } catch (_err) {
      this.todayRecord = null;
      this.historyCount = 0;
    } finally {
      this.isDataLoaded = true;
    }
  }

  /**
   * 跳转到单牌快占
   */
  private goToSingleDivination(): void {
    try {
      const params: AskHeartRouteParams = {
        entryMode: 'NORMAL_SINGLE',
      };
      router.pushUrl({
        url: Routes.ASK_HEART,
        params: params,
      });
    } catch (_err) {
      // ignore
    }
  }

  /**
   * 跳转到历史详情
   */
  private goToHistoryDetail(recordId: string): void {
    try {
      const detailParams: HistoryDetailRouteParams = {
        recordId: recordId,
      };
      router.pushUrl({
        url: Routes.HISTORY_DETAIL,
        params: detailParams,
      });
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.SPACE_MD }) {
        // ═══════════ 顶部标题 ═══════════
        Column() {
          Text(Constants.APP_NAME)
            .fontSize(Theme.FONT_HEADLINE)
            .fontColor(Theme.GOLD_LIGHT)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .margin({ top: 60 })

          Text('探索内心，点亮星光')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.MOON_MUTED)
            .textAlign(TextAlign.Center)
            .margin({ top: Theme.SPACE_SM })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: Theme.SPACE_LG })

        // ═══════════ 今日一占卡片 ═══════════
        this.buildTodayCard()

        // ═══════════ 2×2 功能卡片 ═══════════
        this.buildFeatureGrid()

        // ═══════════ 历史查询入口 ═══════════
        this.buildHistoryEntry()

        // ═══════════ 合规页脚 ═══════════
        ComplianceFooter({
          fontSize: Theme.FONT_CAPTION,
          textColor: Theme.MOON_MUTED,
          showDivider: true,
        })

        Blank().height(40)
      }
      .width('100%')
      .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
    .scrollBar(BarState.Off)
  }

  /**
   * 今日一占卡片
   */
  @Builder
  buildTodayCard(): void {
    Column() {
      Text('🌙 今日一占')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.GOLD_AMBER)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.SPACE_MD })

      if (this.todayRecord && this.todayRecord.cards && this.todayRecord.cards.length > 0) {
        // 有记录：显示第一条牌的牌名 + 关键词
        Row() {
          Column() {
            Text(this.todayRecord.cards[0].cardName)
              .fontSize(Theme.FONT_SUBTITLE)
              .fontColor(Theme.TEXT_PRIMARY_LIGHT)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: Theme.SPACE_XS })

            Text(this.todayRecord.cards[0].keyword || this.todayRecord.modeTitle)
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.MOON_MUTED)

            Text(this.formatTimestamp(this.todayRecord.timestamp))
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.MOON_MUTED)
              .margin({ top: Theme.SPACE_XS })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text('查看详情 →')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.GOLD_AMBER)
            .onClick(() => {
              this.goToHistoryDetail(this.todayRecord!.id);
            })
        }
        .width('100%')
      } else {
        // 无记录：引导文案
        Column() {
          Text('今天还没有抽牌')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.MOON_MUTED)
            .margin({ bottom: Theme.SPACE_MD })

          Button('开始抽牌')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .width('60%')
            .height(44)
            .backgroundColor(Theme.GOLD_AMBER)
            .borderRadius(Theme.RADIUS_FULL)
            .onClick(() => {
              this.goToSingleDivination();
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.15)' })
  }

  /**
   * 2×2 功能卡片网格
   */
  @Builder
  buildFeatureGrid(): void {
    Column({ space: Theme.SPACE_MD }) {
      // 第一行
      Row({ space: Theme.SPACE_MD }) {
        this.buildFeatureCard(
          '🃏',
          '单牌快占',
          '快速获得此刻指引',
          true,
          () => { this.goToSingleDivination(); }
        )

        this.buildFeatureCard(
          '🔺',
          '圣三角',
          '过去·现在·未来',
          true,
          () => {
            try {
              router.pushUrl({ url: Routes.TRIANGLE_INTRO });
            } catch (_err) {
              // ignore
            }
          }
        )
      }
      .width('100%')

      // 第二行
      Row({ space: Theme.SPACE_MD }) {
        this.buildFeatureCard(
          '💞',
          '关系探索',
          '我·对方·走向',
          true,
          () => {
            try {
              router.pushUrl({ url: Routes.RELATION_INTRO });
            } catch (_err) {
              // ignore
            }
          }
        )

        this.buildFeatureCard(
          '🔮',
          '决策牌阵',
          '即将上线',
          false,
          undefined
        )
      }
      .width('100%')
    }
    .width('100%')
  }

  /**
   * 单个功能卡片
   */
  @Builder
  buildFeatureCard(
    emoji: string,
    title: string,
    subtitle: string,
    enabled: boolean,
    onTap?: () => void
  ): void {
    Column() {
      Text(emoji)
        .fontSize(28)
        .margin({ bottom: Theme.SPACE_SM })

      Text(title)
        .fontSize(Theme.FONT_BODY)
        .fontColor(enabled ? Theme.TEXT_PRIMARY_LIGHT : Theme.MOON_MUTED)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: Theme.SPACE_XS })

      Text(subtitle)
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(enabled ? Theme.MOON_MUTED : Theme.TEXT_MUTED)
        .textAlign(TextAlign.Center)
    }
    .width('48%')
    .height(120)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(enabled ? Theme.BG_CARD_DARK : Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: enabled ? 'rgba(202, 138, 4, 0.15)' : 'rgba(42, 42, 74, 0.5)' })
    .opacity(enabled ? 1.0 : 0.5)
    .onClick(() => {
      if (enabled && onTap) {
        onTap();
      }
    })
  }

  /**
   * 历史查询入口
   */
  @Builder
  buildHistoryEntry(): void {
    Row() {
      Text('📋 查看最近' + this.historyCount + '/50 条占卜记录')
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.GOLD_AMBER)
        .textAlign(TextAlign.Start)

      Blank()

      Text('→')
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.MOON_MUTED)
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.1)' })
    .onClick(() => {
      try {
        router.pushUrl({ url: Routes.HISTORY });
      } catch (_err) {
        // ignore
      }
    })
  }

  /**
   * 格式化时间戳为 HH:mm
   */
  private formatTimestamp(ts: number): string {
    const d: Date = new Date(ts);
    const h: string = String(d.getHours()).padStart(2, '0');
    const m: string = String(d.getMinutes()).padStart(2, '0');
    return h + ':' + m;
  }
}

// ── 跨文件接口 ──

interface HistoryDetailRouteParams {
  recordId: string;
}

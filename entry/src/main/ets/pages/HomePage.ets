import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { Routes } from '../common/Routes';
import { HistoryStore } from '../common/HistoryStore';
import { DivinationHistoryRecord } from '../model/DivinationHistoryRecord';
import { CompanionBottomNav } from '../components/CompanionBottomNav';

/**
 * AskHeart 页面路由参数
 */
interface AskHeartRouteParams {
  entryMode: string;
}

/**
 * 星澜陪伴文案池（25 条）
 */
const XINGLAN_QUOTES: string[] = [
  '今天，也给自己留一张星钥吧。\n不问未来，只看看此刻的你。',
  '我听见了，慢慢说也没关系。',
  '你不是想太多，只是很认真地在感受。',
  '不用马上找到答案，我们先把心放稳一点。',
  '今天能回来看看自己，就已经很好。',
  '有些心事，不需要立刻解决。\n先被看见，也很重要。',
  '如果这件事让你很累，\n我们可以只看最轻的一步。',
  '你并不孤单。\n星澜会陪你一起走一小段。',
  '不用证明自己很坚强。\n你可以先休息一下。',
  '这一次，我们不预测未来。\n只看看现在的你。',
  '先别催自己。\n月光也不是一瞬间照亮整片夜空。',
  '你可以慢慢来。\n星澜会在这里等你。',
  '今天不需要很勇敢。\n先照顾好这一刻的自己。',
  '如果心里有点乱，\n就从一张牌开始。',
  '不是所有问题都要马上回答。\n有些答案会慢慢靠近。',
  '你已经撑了很久。\n这一次，先让自己缓一缓。',
  '把问题放轻一点。\n你会更容易听见自己。',
  '星钥不是答案。\n它只是陪你打开一扇门。',
  '不用急着向前走。\n先确认你还站在自己这边。',
  '回来就好。\n星澜一直在这里。',
  '你可以先不用解释。\n感受被看见，也是一种开始。',
  '有些难过不是脆弱。\n是你真的在认真经过它。',
  '慢一点没关系。\n星光也会一点点亮起来。',
  '今天先不追问结果。\n只确认你此刻需要什么。',
  '如果答案还远，\n就先把心放近一点。'
];

/**
 * 星澜沉浸式陪伴首页 — 响应式比例布局（14 / 59 / 16 / 11）
 *
 * Stack 根容器：
 * ├─ Layer 1: 星澜背景图（Cover 满铺，opacity 0.82）
 * ├─ Layer 2: 渐变遮罩（顶暗→中透→底强暗）
 * └─ Layer 3: 主内容 Column（按 layoutWeight 比例分配）
 *     ├─ Header 品牌区      layoutWeight(14)  minHeight 108 / maxHeight 138
 *     ├─ DialogueArea 对话流  layoutWeight(59)  minHeight 360
 *     ├─ ActionArea 底部操作  layoutWeight(16)  minHeight 132 / maxHeight 172
 *     └─ BottomNav 底部导航   layoutWeight(11)  minHeight 78  / maxHeight 96
 *
 * 点击星澜背景/中间星澜按钮 → addNextXinglanQuote() 追加文案到 quoteList 末尾
 */
@Entry
@Component
struct HomePage {
  @State todayRecord: DivinationHistoryRecord | null = null;
  @State historyCount: number = 0;
  @State isDataLoaded: boolean = false;
  @State quoteIndex: number = 0;
  @State quoteList: string[] = [XINGLAN_QUOTES[0]];
  private scroller: Scroller = new Scroller();

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
   * 追加下一条星澜文案到语句流末尾（循环）
   */
  private addNextXinglanQuote(): void {
    this.quoteIndex = (this.quoteIndex + 1) % XINGLAN_QUOTES.length;
    const newList: string[] = [...this.quoteList, XINGLAN_QUOTES[this.quoteIndex]];
    this.quoteList = newList;
    try {
      this.scroller.scrollEdge(Edge.Bottom);
    } catch (_err) {
      // 滚动失败忽略
    }
  }

  private navigateToAskHeart(): void {
    try {
      const params: AskHeartRouteParams = { entryMode: 'NORMAL_SINGLE' };
      const options: router.RouterOptions = { url: Routes.ASK_HEART, params: params };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }

  private navigateToHistory(): void {
    try {
      const options: router.RouterOptions = { url: Routes.HISTORY };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }

  private formatTimestamp(ts: number): string {
    const d: Date = new Date(ts);
    const h: string = String(d.getHours()).padStart(2, '0');
    const m: string = String(d.getMinutes()).padStart(2, '0');
    return h + ':' + m;
  }

  build() {
    Stack() {
      // ═══════════════════════════════════════════
      // Layer 1: 星澜背景图
      // ═══════════════════════════════════════════
      Image($r('app.media.xinglan_home'))
        .objectFit(ImageFit.Cover)
        .width('100%')
        .height('100%')
        .opacity(0.82)
        .hitTestBehavior(HitTestMode.Transparent)

      // ═══════════════════════════════════════════
      // Layer 2: 渐变遮罩
      // ═══════════════════════════════════════════
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['rgba(15, 15, 35, 0.85)', 0.0],
            ['rgba(15, 15, 35, 0.25)', 0.15],
            ['rgba(15, 15, 35, 0)', 0.40],
            ['rgba(15, 15, 35, 0)', 0.60],
            ['rgba(15, 15, 35, 0.78)', 0.82],
            [Theme.BG_DEEP_INDIGO, 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // ═══════════════════════════════════════════
      // Layer 3: 主内容 Column（比例布局 14/59/16/11）
      // 点击星澜背景追加文案
      // ═══════════════════════════════════════════
      Column() {
        // ── Header 品牌区 (14%, minHeight 108 / maxHeight 138) ──
        Column() {
          Text(Constants.APP_NAME)
            .fontSize(Theme.FONT_HEADLINE)
            .fontColor(Theme.GOLD_LIGHT)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)

          Text('探索内心，点亮星光')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.MOON_MUTED)
            .textAlign(TextAlign.Center)
            .margin({ top: Theme.SPACE_SM })
        }
        .width('100%')
        .layoutWeight(14)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 36 })
        .constraintSize({ minHeight: 108, maxHeight: 138 })

        // ── DialogueArea 对话流区 (59%, minHeight 360) ──
        Stack() {
          Scroll(this.scroller) {
            Column({ space: 10 }) {
              ForEach(this.quoteList, (quote: string, index: number) => {
                Text(quote)
                  .fontSize(16)
                  .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                  .lineHeight(24)
                  .backgroundColor('rgba(27, 27, 48, 0.68)')
                  .borderRadius(16)
                  .padding({ left: 14, right: 14, top: 12, bottom: 12 })
                  .constraintSize({ maxWidth: '80%' })
                  .alignSelf(ItemAlign.Start)
              }, (quote: string, index: number) => index.toString() + '_' + quote.substring(0, 6))
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ top: 36, bottom: 12 })
          }
          .width('100%')
          .height('100%')
          .scrollable(ScrollDirection.Vertical)
          .align(Alignment.Bottom)
          .scrollBar(BarState.Off)
          .hitTestBehavior(HitTestMode.Transparent)

          // 顶部渐隐遮罩
          Column()
            .width('100%')
            .height(36)
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [
                [Theme.BG_DEEP_INDIGO, 0.0],
                ['rgba(15, 15, 35, 0)', 1.0]
              ]
            })
            .hitTestBehavior(HitTestMode.Transparent)
            .position({ x: 0, y: 0 })
        }
        .width('100%')
        .layoutWeight(59)
        .constraintSize({ minHeight: 360 })
        .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD })

        // ── ActionArea 底部操作区 (16%, minHeight 132 / maxHeight 172) ──
        Column() {
          Text('星澜会先接住你的情绪。')
            .fontSize(12)
            .fontColor(Theme.MOON_MUTED)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: 8 })

          Button('开始今日一占')
            .fontSize(18)
            .fontColor(Theme.BTN_DARK_TEXT)
            .fontWeight(FontWeight.Bold)
            .width('88%')
            .height(54)
            .backgroundColor(Theme.GOLD_MAIN)
            .borderRadius(28)
            .margin({ bottom: 10 })
            .onClick(() => { this.navigateToAskHeart(); })

          Text('查看最近记录')
            .fontSize(15)
            .fontColor(Theme.MOON_MUTED)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: 12 })
            .onClick(() => { this.navigateToHistory(); })

          Text(Constants.COMPLIANCE_FOOTER)
            .fontSize(11)
            .fontColor(Theme.MOON_MUTED)
            .textAlign(TextAlign.Center)
            .lineHeight(16)
            .width('100%')
            .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD })
        }
        .width('100%')
        .layoutWeight(16)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.End)
        .constraintSize({ minHeight: 132, maxHeight: 172 })
        .padding({ bottom: 4 })
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['rgba(15, 15, 35, 0)', 0.0],
            ['rgba(15, 15, 35, 0.65)', 0.35],
            [Theme.BG_DEEP_INDIGO, 1.0]
          ]
        })

        // ── BottomNav 底部导航区 (11%, minHeight 78 / maxHeight 96) ──
        Column() {
          CompanionBottomNav({ onXinglanClick: () => { this.addNextXinglanQuote(); } })
        }
        .width('100%')
        .layoutWeight(11)
        .constraintSize({ minHeight: 78, maxHeight: 96 })
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .onClick(() => {
        this.addNextXinglanQuote();
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
    .alignContent(Alignment.TopStart)
  }
}

// ── 跨文件接口 ──

interface HistoryDetailRouteParams {
  recordId: string;
}

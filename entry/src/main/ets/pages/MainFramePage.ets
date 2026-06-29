import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { CompanionBottomNav } from '../components/CompanionBottomNav';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';
import { PreferenceStore } from '../data/PreferenceStore';
import { TAROT_CARDS } from '../data/TarotCardData';
import { TarotCard, ArcanaType, TarotSuit } from '../model/TarotCard';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Phase 6.8：主框架页面 — 底部导航容器
 *
 * 使用条件渲染（if/else）承载 5 个一级入口：
 *   0. 占卜 (DivinationCenterPage)
 *   1. 星澜聊天 (XinglanChatPage)
 *   2. 星澜语录 (HomePage)
 *   3. 卡牌总览 (TarotCardsPage)
 *   4. 设置 (SettingsPage)
 *
 * 只渲染当前 tab 内容，避免一次性构建所有页面导致卡顿。
 * 底部导航 CompanionBottomNav 通过 onTabChange 回调驱动 currentTab 切换。
 *
 * 路由参数（可选）：
 *   { tab: number } — 指定初始选中的 tab 索引（0-4）
 */
@Entry
@Component
struct MainFramePage {
  @State currentTab: number = 2;

  aboutToAppear(): void {
    // 尝试从路由参数读取初始 tab
    try {
      const rawParams: Object | undefined = router.getParams();
      if (rawParams !== undefined && rawParams !== null) {
        const params: Record<string, Object> = rawParams as Record<string, Object>;
        const tabValue: Object | undefined = params['tab'];
        if (tabValue !== undefined && tabValue !== null) {
          const tabNum: number = typeof tabValue === 'number' ? tabValue : parseInt(String(tabValue));
          if (!isNaN(tabNum) && tabNum >= 0 && tabNum <= 4) {
            this.currentTab = tabNum;
          }
        }
      }
    } catch (_err) {
      // ignore, keep default tab 2
    }
  }

  private handleTabChange(index: number): void {
    if (index < 0 || index > 4) {
      return;
    }
    // Tab 1（星澜聊天）：直接 push 独立聊天页，不切换 MainFrame 内容
    if (index === 1) {
      try {
        const options: router.RouterOptions = { url: Routes.XINGLAN_CHAT };
        router.pushUrl(options);
      } catch (_err) {
        // ignore
      }
      return;
    }
    if (this.currentTab === index) {
      return;
    }
    this.currentTab = index;
  }

  // ── 条件渲染当前 Tab 内容 ──
  @Builder
  buildCurrentTabContent(): void {
    if (this.currentTab === 0) {
      DivinationCenterTabContent()
    } else if (this.currentTab === 1) {
      XinglanChatTabContent()
    } else if (this.currentTab === 2) {
      XinglanQuotesTabContent()
    } else if (this.currentTab === 3) {
      TarotCardsTabContent()
    } else {
      SettingsTabContent()
    }
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      Column() {
        // 页面内容区 — 只渲染当前 Tab（条件渲染）
        Column() {
          this.buildCurrentTabContent()
        }
        .width('100%')
        .layoutWeight(1)

        // 底部导航
        Column() {
          CompanionBottomNav({
            currentTab: this.currentTab,
            onTabChange: (index: number) => {
              this.handleTabChange(index);
            }
          })
        }
        .width('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }
}

// ═══════════════════════════════════════════════════════════
// 各 Tab 内联内容组件
// ═══════════════════════════════════════════════════════════

/**
 * AskHeart 页面路由参数
 */
interface AskHeartRouteParams {
  entryMode: string;
}

/**
 * 卡牌详情路由参数
 */
interface TarotCardDetailRouteParams {
  cardId: string;
}

/**
 * 占卜中心入口卡片配置
 */
interface DivinationEntry {
  icon: string;
  title: string;
  subtitle: string;
  routeAction: () => void;
}

/**
 * 筛选项配置
 */
interface FilterOption {
  label: string;
  value: string;
}

/**
 * 卡牌解读内容接口
 */
interface CardReading {
  uprightMeaning: string;
  reversedMeaning: string;
  companionReading: string;
  relationHint: string;
  workHint: string;
  selfExploration: string;
}

/**
 * 关于页入口配置
 */
interface AboutEntry {
  title: string;
  subtitle: string;
  routeUrl: string;
}

/**
 * 授权条目接口
 */
interface LicenseEntry {
  title: string;
  content: string;
}

// ═══════════════════════════════════════════════════════════
// Tab 0: 占卜中心
// ═══════════════════════════════════════════════════════════

@Component
struct DivinationCenterTabContent {
  private buildEntries(): DivinationEntry[] {
    const entries: DivinationEntry[] = [
      {
        icon: '◇',
        title: '单牌快占',
        subtitle: '一句心事，一张星钥。',
        routeAction: (): void => {
          try {
            const params: AskHeartRouteParams = { entryMode: 'NORMAL_SINGLE' };
            const options: router.RouterOptions = { url: Routes.ASK_HEART, params: params };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      },
      {
        icon: '△',
        title: '圣三角牌阵',
        subtitle: '过去、现在、可能的方向。',
        routeAction: (): void => {
          try {
            const options: router.RouterOptions = { url: Routes.TRIANGLE_INTRO };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      },
      {
        icon: '◎',
        title: '关系探索',
        subtitle: '不替你判断谁对谁错，只陪你看清感受。',
        routeAction: (): void => {
          try {
            const options: router.RouterOptions = { url: Routes.RELATION_INTRO };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      },
      {
        icon: '✦',
        title: '旋转牌轮',
        subtitle: '亲手转动牌轮，选择此刻靠近你的牌。',
        routeAction: (): void => {
          try {
            const options: router.RouterOptions = { url: Routes.CARD_WHEEL_MODE };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      },
      {
        icon: '☰',
        title: '历史查看',
        subtitle: '回看曾经抽到的星钥和那时的自己。',
        routeAction: (): void => {
          try {
            const options: router.RouterOptions = { url: Routes.HISTORY };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      }
    ];
    return entries;
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      Column() {
        // 顶部安全区
        Column()
          .width('100%')
          .height(Theme.SAFE_TOP + 16)
          .backgroundColor(Theme.BG_DEEP_INDIGO)

        // 标题
        Text('占卜')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        Text('用一张牌、一组牌阵，轻轻照见此刻的心事。')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })

        Scroll() {
          Column() {
            ForEach(this.buildEntries(), (entry: DivinationEntry, index: number) => {
              Row() {
                Text(entry.icon)
                  .fontSize(28)
                  .fontColor('#E8B83D')
                  .width(56)
                  .textAlign(TextAlign.Center)

                Column() {
                  Text(entry.title)
                    .fontSize(Theme.FONT_SUBTITLE)
                    .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                    .fontWeight(FontWeight.Medium)

                  Text(entry.subtitle)
                    .fontSize(Theme.FONT_CAPTION)
                    .fontColor(Theme.MOON_MUTED)
                    .margin({ top: 4 })
                    .lineHeight(18)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: Theme.SPACE_SM })

                Text('›')
                  .fontSize(24)
                  .fontColor(Theme.GOLD_DIM)
              }
              .width('92%')
              .padding(Theme.SPACE_MD)
              .margin({ bottom: Theme.SPACE_SM })
              .backgroundColor('rgba(27, 27, 48, 0.68)')
              .borderRadius(Theme.RADIUS_MD)
              .border({ width: 1, color: 'rgba(216, 180, 90, 0.12)' })
              .onClick(() => {
                entry.routeAction();
              })
            }, (_entry: DivinationEntry, index: number) => 'div_entry_' + index.toString())
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(11)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .lineHeight(16)
          .width('100%')
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 12 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}

// ═══════════════════════════════════════════════════════════
// Tab 1: 星澜聊天
// ═══════════════════════════════════════════════════════════

@Component
struct XinglanChatTabContent {
  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      Column() {
        // 顶部安全区
        Column()
          .width('100%')
          .height(Theme.SAFE_TOP + 16)
          .backgroundColor(Theme.BG_DEEP_INDIGO)

        // 标题
        Text('星澜聊天')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        Text('和星澜说说话，不用想太多。')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })

        // 进入聊天按钮
        Column() {
          Text('◉')
            .fontSize(48)
            .fontColor('#E8B83D')
            .margin({ bottom: Theme.SPACE_MD })

          Text('进入星澜聊天')
            .fontSize(Theme.FONT_SUBTITLE)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: Theme.SPACE_SM })

          Text('星澜会倾听你的心事，陪你慢慢聊。')
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.MOON_MUTED)
            .textAlign(TextAlign.Center)
            .lineHeight(20)
        }
        .width('92%')
        .backgroundColor('rgba(27, 27, 48, 0.68)')
        .borderRadius(Theme.RADIUS_MD)
        .border({ width: 1, color: 'rgba(216, 180, 90, 0.18)' })
        .padding({ top: 36, bottom: 36, left: Theme.SPACE_MD, right: Theme.SPACE_MD })
        .alignItems(HorizontalAlign.Center)
        .margin({ top: Theme.SPACE_LG })
        .onClick(() => {
          try {
            const options: router.RouterOptions = { url: Routes.XINGLAN_CHAT };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        })

        Blank()

        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(11)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .lineHeight(16)
          .width('100%')
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 12 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}

// ═══════════════════════════════════════════════════════════
// Tab 2: 星澜语录 (HomePage 功能内联)
// ═══════════════════════════════════════════════════════════

const XINGLAN_QUOTES_TAB: string[] = [
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
];

const XINGLAN_LISTENING_HINT_TAB: string = '星澜安静地听着。';

@Component
struct XinglanQuotesTabContent {
  @State quoteList: string[] = [XINGLAN_QUOTES_TAB[0]];
  @State quoteIndex: number = 0;
  @State isXinglanResponding: boolean = false;
  private scroller: Scroller = new Scroller();

  private async addNextXinglanQuote(): Promise<void> {
    if (this.isXinglanResponding) {
      return;
    }
    this.isXinglanResponding = true;
    try {
      const listWithHint: string[] = [...this.quoteList, XINGLAN_LISTENING_HINT_TAB];
      this.quoteList = listWithHint;
      this.scrollToBottom();

      const delay: number = 800 + Math.floor(Math.random() * 700);
      await this.sleep(delay);

      const baseList: string[] = this.removeListeningHintFromTail();
      this.quoteIndex = (this.quoteIndex + 1) % XINGLAN_QUOTES_TAB.length;
      const finalList: string[] = [...baseList, XINGLAN_QUOTES_TAB[this.quoteIndex]];
      this.quoteList = finalList;
      this.scrollToBottom();
    } catch (err) {
      hilog.error(0x0000, 'XinglanQuotesTab', 'addNextXinglanQuote error: %{public}s', JSON.stringify(err));
    } finally {
      this.isXinglanResponding = false;
    }
  }

  private removeListeningHintFromTail(): string[] {
    if (this.quoteList.length === 0) {
      return [];
    }
    if (this.quoteList[this.quoteList.length - 1] === XINGLAN_LISTENING_HINT_TAB) {
      return this.quoteList.slice(0, this.quoteList.length - 1);
    }
    return this.quoteList;
  }

  private sleep(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(() => { resolve(); }, ms);
    });
  }

  private scrollToBottom(): void {
    try {
      this.scroller.scrollEdge(Edge.Bottom);
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Stack() {
      // ═══════════════════════════════════════════
      // Layer 1: 星澜背景图
      // ═══════════════════════════════════════════
      Image($r('app.media.xinglan_home_main'))
        .objectFit(ImageFit.Cover)
        .width('100%')
        .height('100%')
        .translate({ x: 0, y: -80 })
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
            ['#030716', 0.0],
            ['#030716', 0.08],
            ['rgba(4, 8, 23, 0.88)', 0.12],
            ['rgba(6, 10, 28, 0.50)', 0.22],
            ['rgba(6, 10, 28, 0.15)', 0.40],
            ['rgba(6, 10, 28, 0)', 0.58],
            ['rgba(15, 15, 35, 0)', 0.65],
            ['rgba(15, 15, 35, 0.78)', 0.87],
            ['#030716', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // ═══════════════════════════════════════════
      // Layer 3: 主内容
      // ═══════════════════════════════════════════
      Column() {
        // 顶部安全区
        Column()
          .width('100%')
          .height(Theme.SAFE_TOP + 16)

        // 标题
        Text('星澜语录')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        Text('星澜想对你说的话，都在这里。')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })

        // 语录滚动区
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
            }, (quote: string, index: number) => 'ql_' + index.toString() + '_' + quote.substring(0, 4))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ top: 36, bottom: 12, left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .onClick(() => {
          this.addNextXinglanQuote();
        })

        // 提示
        Text('轻触上方区域，星澜会回应你。')
          .fontSize(12)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding({ bottom: 12 })

        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(11)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .lineHeight(16)
          .width('100%')
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 12 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}

// ═══════════════════════════════════════════════════════════
// Tab 3: 卡牌总览
// ═══════════════════════════════════════════════════════════

@Component
struct TarotCardsTabContent {
  @State selectedFilter: string = 'all';
  @State displayedCards: TarotCard[] = TAROT_CARDS;

  private filters: FilterOption[] = [
    { label: '全部', value: 'all' },
    { label: '大阿尔卡那', value: 'major' },
    { label: '权杖', value: 'wands' },
    { label: '圣杯', value: 'cups' },
    { label: '宝剑', value: 'swords' },
    { label: '星币', value: 'pentacles' }
  ];

  private applyFilter(value: string): void {
    this.selectedFilter = value;
    if (value === 'all') {
      this.displayedCards = TAROT_CARDS;
    } else if (value === 'major') {
      this.displayedCards = TAROT_CARDS.filter((card: TarotCard) => card.arcana === ArcanaType.MAJOR);
    } else {
      this.displayedCards = TAROT_CARDS.filter((card: TarotCard) => {
        if (card.suit === TarotSuit.NONE) {
          return false;
        }
        return card.suit === value;
      });
    }
  }

  private navigateToDetail(card: TarotCard): void {
    try {
      const params: TarotCardDetailRouteParams = { cardId: card.id };
      const options: router.RouterOptions = { url: Routes.TAROT_CARD_DETAIL, params: params };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }

  private getSuitLabel(card: TarotCard): string {
    if (card.arcana === ArcanaType.MAJOR) {
      return '大阿尔卡那';
    }
    switch (card.suit) {
      case TarotSuit.WANDS:
        return '权杖';
      case TarotSuit.CUPS:
        return '圣杯';
      case TarotSuit.SWORDS:
        return '宝剑';
      case TarotSuit.PENTACLES:
        return '星币';
      default:
        return '';
    }
  }

  private getSuitColor(card: TarotCard): string {
    if (card.arcana === ArcanaType.MAJOR) {
      return '#E8B83D';
    }
    switch (card.suit) {
      case TarotSuit.WANDS:
        return '#E8A838';
      case TarotSuit.CUPS:
        return '#5EA8D7';
      case TarotSuit.SWORDS:
        return '#8B7EC8';
      case TarotSuit.PENTACLES:
        return '#6EB87A';
      default:
        return '#94A3B8';
    }
  }

  private formatIndex(index: number): string {
    if (index < 10) {
      return '0' + index.toString();
    }
    return index.toString();
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      Column() {
        Column()
          .width('100%')
          .height(Theme.SAFE_TOP + 16)
          .backgroundColor(Theme.BG_DEEP_INDIGO)

        Text('卡牌总览')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        Text('78 张塔罗牌，不是答案，而是看见自己的不同方式。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_MD })

        // 筛选区
        Scroll() {
          Row() {
            ForEach(this.filters, (filter: FilterOption, index: number) => {
              Text(filter.label)
                .fontSize(13)
                .fontColor(this.selectedFilter === filter.value ? Theme.BG_DEEP_INDIGO : Theme.MOON_MUTED)
                .fontWeight(this.selectedFilter === filter.value ? FontWeight.Bold : FontWeight.Normal)
                .backgroundColor(this.selectedFilter === filter.value ? '#E8B83D' : 'rgba(27, 27, 48, 0.68)')
                .borderRadius(16)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin({ right: 8 })
                .onClick(() => {
                  this.applyFilter(filter.value);
                })
            }, (_filter: FilterOption, index: number) => 'tab_filter_' + index.toString())
          }
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(44)
        .margin({ bottom: Theme.SPACE_SM })

        Divider()
          .strokeWidth(0.5)
          .color(Theme.DEEP_STARRY)
          .margin({ bottom: Theme.SPACE_SM })

        // 卡牌列表
        Scroll() {
          List() {
            ForEach(this.displayedCards, (card: TarotCard, index: number) => {
              ListItem() {
                Row() {
                  Text(this.formatIndex(card.index))
                    .fontSize(12)
                    .fontColor(Theme.GOLD_DIM)
                    .width(36)
                    .textAlign(TextAlign.Center)

                  Column() {
                    Text(card.nameZh)
                      .fontSize(Theme.FONT_BODY)
                      .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                      .fontWeight(FontWeight.Medium)

                    Text(card.nameEn)
                      .fontSize(11)
                      .fontColor(Theme.MOON_MUTED)
                      .margin({ top: 2 })

                    Row() {
                      ForEach(card.keywords, (keyword: string, ki: number) => {
                        Text(keyword)
                          .fontSize(10)
                          .fontColor(this.getSuitColor(card))
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .margin({ right: 4, top: 4 })
                      }, (_kw: string, ki: number) => 'tab_kw_' + card.id + '_' + ki.toString())
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({ left: Theme.SPACE_SM })

                  Text(this.getSuitLabel(card))
                    .fontSize(10)
                    .fontColor(this.getSuitColor(card))
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .border({ width: 0.5, color: this.getSuitColor(card), style: BorderStyle.Solid })
                    .borderRadius(8)
                    .margin({ right: 4 })

                  Text('›')
                    .fontSize(20)
                    .fontColor(Theme.GOLD_DIM)
                }
                .width('100%')
                .padding(Theme.SPACE_MD)
                .alignItems(VerticalAlign.Center)
                .backgroundColor('rgba(27, 27, 48, 0.52)')
                .borderRadius(Theme.RADIUS_SM)
                .margin({ bottom: 6, left: Theme.SPACE_MD, right: Theme.SPACE_MD })
                .onClick(() => {
                  this.navigateToDetail(card);
                })
              }
            }, (card: TarotCard) => card.id)
          }
          .width('100%')
          .padding({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })
          .listDirection(Axis.Vertical)
          .divider({ strokeWidth: 0 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}

// ═══════════════════════════════════════════════════════════
// Tab 4: 设置
// ═══════════════════════════════════════════════════════════

@Component
struct SettingsTabContent {
  @State isResetting: boolean = false;

  private async resetAllGuides(): Promise<void> {
    if (this.isResetting) {
      return;
    }
    this.isResetting = true;
    try {
      const keys: string[] = [
        'hasSeenHomeGuide',
        'hasSeenSingleGuide',
        'hasSeenTriangleGuide',
        'hasSeenRelationGuide',
        'hasSeenResultGuide',
        'hasSeenRecordGuide',
        'hasSeenDisclaimerHint'
      ];
      for (let i = 0; i < keys.length; i++) {
        await PreferenceStore.putBoolean(keys[i], false, getContext(this));
      }
      this.showResetSuccessDialog();
    } catch (err) {
      hilog.error(0x0000, 'SettingsTab', 'resetAllGuides error: %{public}s', JSON.stringify(err));
    } finally {
      this.isResetting = false;
    }
  }

  private showResetSuccessDialog(): void {
    try {
      this.getUIContext().showAlertDialog({
        title: '星澜准备好了',
        message: '星澜的介绍已经准备好了。下次进入语录页时，她会重新陪你走一遍。',
        confirm: {
          value: '知道了',
          action: () => {}
        }
      });
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      Column() {
        Column()
          .width('100%')
          .height(Theme.SAFE_TOP + 16)
          .backgroundColor(Theme.BG_DEEP_INDIGO)

        Text('设置')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_LG })

        // 设置项：重新听听星澜的介绍
        Column() {
          Text('重新听听星澜的介绍')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .width('100%')
            .padding({ top: 16, bottom: 16, left: 20, right: 20 })

          Text('星澜会重新陪你走一遍语录页的第一次介绍。')
            .fontSize(13)
            .fontColor(Theme.MOON_MUTED)
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 16 })
        }
        .width('92%')
        .backgroundColor('rgba(27, 27, 48, 0.68)')
        .borderRadius(Theme.RADIUS_MD)
        .margin({ bottom: Theme.SPACE_MD })
        .onClick(() => { this.resetAllGuides(); })

        // 设置项：关于星钥塔罗
        Column() {
          Text('关于星钥塔罗')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .width('100%')
            .padding({ top: 16, bottom: 16, left: 20, right: 20 })

          Text('版本信息、隐私政策、用户协议、素材与授权')
            .fontSize(13)
            .fontColor(Theme.MOON_MUTED)
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 16 })
        }
        .width('92%')
        .backgroundColor('rgba(27, 27, 48, 0.68)')
        .borderRadius(Theme.RADIUS_MD)
        .margin({ bottom: Theme.SPACE_MD })
        .onClick(() => {
          try {
            const options: router.RouterOptions = { url: Routes.ABOUT };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        })

        Blank()

        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(11)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .lineHeight(16)
          .width('100%')
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 12 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}

import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { CompanionBottomNav } from '../components/CompanionBottomNav';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';
import { PreferenceStore } from '../data/PreferenceStore';
import { TAROT_CARDS } from '../data/TarotCardData';
import { TarotCard, ArcanaType, TarotSuit } from '../model/TarotCard';
import { TarotCardImage } from '../components/TarotCardImage';
import { DivinationEntryCard } from '../components/DivinationEntryCard';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { GlobalBgmManager } from '../common/GlobalBgmManager';
import { UserProfileStore } from '../common/UserProfileStore';
import { EmotionStarStorage, EmotionStarRecord, StarKeyLevel, NextLevelInfo } from '../common/EmotionStarStorage';
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { XinglanChatEntranceContent } from './XinglanChatEntrancePage';
import { DailyLightHeroCard } from '../daily/components/DailyLightHeroCard';

/**
 * Phase 6.8：主框架页面 — 底部导航容器
 *
 * 使用条件渲染（if/else）承载 5 个一级入口：
 *   0. 占卜 (DivinationCenterPage)
 *   1. 星澜聊天 (XinglanChatPage)
 *   2. 星澜语录 (HomePage)
 *   3. 卡牌总览 (TarotCardsPage)
 *   4. 我的 (SettingsPage)
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

    // 初始化并开始播放全局背景音乐（单例，幂等）
    this.initAndPlayBgm();
  }

  /**
   * 初始化全局背景音乐管理器并开始播放
   * 使用 getContext 获取 UIAbilityContext，传递 rawfile 文件描述符
   * 尊重 bgm_enabled 持久化偏好
   */
  private initAndPlayBgm(): void {
    try {
      const bgmManager: GlobalBgmManager = GlobalBgmManager.getInstance();
      const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

      // 先读取持久化的 bgm 开关状态
      PreferenceStore.getBoolean('bgm_enabled', true, ctx).then((enabled: boolean) => {
        bgmManager.setMusicEnabled(enabled);

        // 初始化（仅首次创建 AVPlayer）
        bgmManager.init(ctx).then(() => {
          // 初始化完成后播放（内部会检查 isMusicEnabled）
          bgmManager.play().catch((_err: Error) => {
            hilog.warn(0x0000, 'MainFramePage', 'BGM play failed');
          });
        }).catch((_err: Error) => {
          hilog.warn(0x0000, 'MainFramePage', 'BGM init failed');
        });
      }).catch((_err: Error) => {
        // 读取失败，默认开启
        hilog.warn(0x0000, 'MainFramePage', 'BGM pref read failed, using default');
        bgmManager.init(ctx).then(() => {
          bgmManager.play().catch((_err2: Error) => {
            hilog.warn(0x0000, 'MainFramePage', 'BGM play failed');
          });
        }).catch((_err2: Error) => {
          hilog.warn(0x0000, 'MainFramePage', 'BGM init failed');
        });
      });
    } catch (_err) {
      hilog.warn(0x0000, 'MainFramePage', 'BGM setup failed');
    }
  }

  private handleTabChange(index: number): void {
    if (index < 0 || index > 4) {
      return;
    }
    // Tab 1（星澜聊天）：切换到入口内容（XinglanChatEntranceContent），不直接进入聊天页
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
      XinglanChatEntranceContent()
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
        .backgroundColor(Theme.V2_BG_BASE)

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
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['rgba(8, 11, 26, 0)', 0.0],
            ['rgba(8, 11, 26, 0.72)', 0.32],
            [Theme.V2_BG_BASE, 1.0]
          ]
        })
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
        title: '每日一占',
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
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [Theme.V2C_BG_BASE, 0.0],
            ['#090D1C', 0.56],
            [Theme.V2C_BG_BASE, 1.0]
          ]
        })

      Column()
        .width('100%')
        .height('100%')
        .radialGradient({
          center: ['50%', '10%'],
          radius: '70%',
          colors: [
            ['rgba(197,160,80,0.035)', 0.0],
            ['rgba(197,160,80,0.012)', 0.42],
            ['rgba(10,13,26,0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.Transparent)

      Row()
        .width(1)
        .height('82%')
        .backgroundColor('rgba(197,160,80,0.10)')
        .position({ x: '50%', y: '8%' })
        .hitTestBehavior(HitTestMode.Transparent)

      Column() {
        // 顶部安全区
        Column()
          .width('100%')
          .height(Theme.SAFE_TOP + 16)

        // 标题
        Text('占卜')
          .fontSize(Theme.V2C_FONT_TITLE)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        Text('翻开星钥之书，轻轻选择此刻想被照见的心事。')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })

        Scroll() {
          Column() {
            // 今日星页 Hero（DAILY-3）：未完成 / 已完成两态，不遮挡下方占卜入口
            DailyLightHeroCard({
              // DAILY-4：跳转今日星页展开流程
              onExpand: (): void => {
                try {
                  const options: router.RouterOptions = { url: Routes.DAILY_LIGHT };
                  router.pushUrl(options);
                } catch (_err) {
                  // ignore router error
                }
              },
              // DAILY-4：跳转今日星页回看模式（已完成态）
              onReview: (): void => {
                try {
                  const options: router.RouterOptions = { url: Routes.DAILY_LIGHT };
                  router.pushUrl(options);
                } catch (_err) {
                  // ignore router error
                }
              },
              onChatWithXinglan: (): void => {
                try {
                  const options: router.RouterOptions = { url: Routes.XINGLAN_CHAT_ENTRANCE };
                  router.pushUrl(options);
                } catch (_err) {
                  // ignore
                }
              }
            })

            ForEach(this.buildEntries(), (entry: DivinationEntry, index: number) => {
              DivinationEntryCard({
                icon: entry.icon,
                title: entry.title,
                subtitle: entry.subtitle,
                action: entry.routeAction
              })
                .margin({ bottom: Theme.V2_SPACE_SM })
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
          .fontColor(Theme.V2C_TEXT_SECONDARY)
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
  @State private buttonPressed: boolean = false;

  // v2 Token（B 方案·月湖映心）— 逐步迁移，旧常量保留兼容
  private static readonly GOLD_CAPSULE_BG: string = Theme.V2B_GOLD_CORE;
  private static readonly GOLD_CAPSULE_PRESSED: string = '#B8943D';
  private static readonly ENTRY_CARD_BG: string = 'rgba(15, 24, 53, 0.72)';
  private static readonly ENTRY_CARD_BORDER: string = 'rgba(212, 172, 77, 0.14)';

  build() {
    Stack() {
      // ═══════════════════════════════════════════
      // Layer 1: 深空渐变背景
      // ═══════════════════════════════════════════
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [Theme.V2B_BG_BASE, 0.0],
            [Theme.V2B_BG_BASE, 0.45],
            ['#0A0D20', 1.0]
          ]
        })

      // ═══════════════════════════════════════════
      // Layer 2: 星点装饰（用背景图片呈现星空感）
      // ═══════════════════════════════════════════
      Image($r('app.media.xinglan_home_main'))
        .objectFit(ImageFit.Cover)
        .width('100%')
        .height('60%')
        .position({ x: 0, y: '26%' })
        .opacity(0.35)
        .hitTestBehavior(HitTestMode.Transparent)

      // ═══════════════════════════════════════════
      // Layer 3: 渐变遮罩（上下消隐）— v2 月湖底色
      // ═══════════════════════════════════════════
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['rgba(6, 11, 26, 0.92)', 0.0],
            ['rgba(6, 11, 26, 0.55)', 0.12],
            ['rgba(6, 11, 26, 0.08)', 0.30],
            ['rgba(6, 11, 26, 0.04)', 0.50],
            ['rgba(6, 11, 26, 0.35)', 0.72],
            ['#0A0D20', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // ═══════════════════════════════════════════
      // Layer 4: 主内容区
      // ═══════════════════════════════════════════
      Scroll() {
        Column() {
          // 顶部安全间距
          Column()
            .width('100%')
            .height(Theme.SAFE_TOP + 20)

          // 标题
          Text('星澜聊天')
            .fontSize(Theme.V2B_FONT_TITLE)
            .fontColor(Theme.V2B_TEXT_PRIMARY)
            .fontWeight(FontWeight.Normal)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: Theme.SPACE_LG })

          // 副标题
          Text('慢慢说，星澜会先听你说完。')
            .fontSize(Theme.V2B_FONT_BODY)
            .fontColor(Theme.V2B_TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_XXL })

          // ═══ 星澜形象区 ═══
          Column() {
            // 星澜圆形头像
            Image($r('app.media.app_icon5'))
              .width(88)
              .height(88)
              .borderRadius(44)
              .objectFit(ImageFit.Cover)
              .clip(true)
              .border({ width: 2, color: 'rgba(212, 172, 77, 0.55)' })
              .shadow(Theme.V2_HALO_AVATAR_ACTIVE)
              .margin({ bottom: 20 })

            // 星澜名字
            Text('星澜在这里')
              .fontSize(20)
              .fontColor(Theme.V2B_TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 16 })

            // 引导文案
            Text('你可以慢慢说。\n星澜不会替你判断，也不会催你变好。\n这里，只陪你把心里的话放下来一点。')
              .fontSize(Theme.V2B_FONT_BODY)
              .fontColor(Theme.V2B_GOLD_RIPPLE)
              .lineHeight(28)
              .textAlign(TextAlign.Center)
              .maxLines(5)
              .width('86%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: Theme.SPACE_XXL })

          // ═══ 进入聊天按钮 ═══
          Column() {
            Text('进入星澜聊天')
              .fontSize(Theme.V2B_FONT_BODY)
              .fontColor(Theme.V2B_GOLD_CORE)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .height(52)
              .textAlign(TextAlign.Center)
              .backgroundColor(Theme.V2B_BG_CARD)
              .borderRadius(Theme.V2B_RADIUS_BTN)
              .shadow(this.buttonPressed ?
                { radius: 8, color: 'rgba(212,172,77,0.08)', offsetX: 0, offsetY: 0 } :
                Theme.V2B_SHADOW_BTN_GLOW)
              .scale({ x: this.buttonPressed ? 0.98 : 1, y: this.buttonPressed ? 0.98 : 1 })
              .animation({ duration: 140, curve: Curve.EaseOut })
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.buttonPressed = true;
                } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                  this.buttonPressed = false;
                  if (event.type === TouchType.Up) {
                    try {
                      const options: router.RouterOptions = { url: Routes.XINGLAN_CHAT };
                      router.pushUrl(options);
                    } catch (_err) {
                      // ignore
                    }
                  }
                }
              })
          }
          .width('82%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 14 })

          // 按钮副文案
          Text('开始一段安静的对话')
            .fontSize(Theme.V2B_FONT_CAPTION)
            .fontColor(Theme.V2B_TEXT_SECONDARY)
            .opacity(0.65)
            .textAlign(TextAlign.Center)
            .margin({ bottom: Theme.SPACE_XXL })

          Blank()

          // ═══ 免责声明 ═══
          Text('星澜的回应仅供陪伴与自我探索参考，不构成任何专业建议。')
            .fontSize(Theme.V2B_FONT_DISCLAIMER)
            .fontColor(Theme.V2B_TEXT_SECONDARY)
            .opacity(0.55)
            .textAlign(TextAlign.Center)
            .lineHeight(17)
            .width('100%')
            .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 16 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
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
      // Layer 1: 月湖底色（月湖映心 B 方案）
      // ═══════════════════════════════════════════
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2B_BG_BASE)

      Image($r('app.media.xinglan_home_main'))
        .objectFit(ImageFit.Cover)
        .width('100%')
        .height('82%')
        .translate({ x: 0, y: -44 })
        .opacity(0.46)
        .hitTestBehavior(HitTestMode.Transparent)

      // ═══════════════════════════════════════════
      // Layer 2: 月光与湖面遮罩（低刺激，不做粒子爆发）
      // ═══════════════════════════════════════════
      Column()
        .width('100%')
        .height(260)
        .radialGradient({
          center: ['50%', '18%'],
          radius: '64%',
          colors: [
            ['rgba(236, 216, 157, 0.07)', 0.0],
            ['rgba(212, 172, 77, 0.025)', 0.52],
            ['rgba(6, 11, 26, 0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.Transparent)

      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [Theme.V2B_BG_BASE, 0.0],
            ['rgba(6, 11, 26, 0.72)', 0.14],
            ['rgba(6, 11, 26, 0.28)', 0.38],
            ['rgba(6, 11, 26, 0.18)', 0.56],
            ['rgba(6, 11, 26, 0.70)', 0.84],
            [Theme.V2B_BG_BASE, 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.Transparent)

      Column()
        .width('70%')
        .height(1)
        .backgroundColor('rgba(236, 216, 157, 0.10)')
        .position({ x: '15%', y: '60%' })
        .hitTestBehavior(HitTestMode.Transparent)

      // ═══════════════════════════════════════════
      // Layer 3: 主内容（B 月湖映心 Token）
      // ═══════════════════════════════════════════
      Column() {
        // 顶部安全区
        Column()
          .width('100%')
          .height(Theme.SAFE_TOP + 16)

        // 标题 — B 方案暖金标题
        Text('星澜语录')
          .fontSize(Theme.V2B_FONT_TITLE)
          .fontColor(Theme.V2B_GOLD_RIPPLE)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_MD })

        Text('不问未来，只陪你看见此刻的自己。')
          .fontSize(Theme.V2B_FONT_BODY)
          .fontColor(Theme.V2B_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_MD_B })

        // 语录滚动区 — B 方案中央语录气泡
        Scroll(this.scroller) {
          Column({ space: 16 }) {
            ForEach(this.quoteList, (quote: string, index: number) => {
              // 中央语录气泡 — 吸收 Stitch 的金线角标与柔和遮罩
              Stack() {
                Column()
                  .width('100%')
                  .height('100%')
                  .radialGradient({
                    center: ['50%', '0%'],
                    radius: '78%',
                    colors: [
                      ['rgba(236, 216, 157, 0.045)', 0.0],
                      ['rgba(15, 24, 53, 0)', 1.0]
                    ]
                  })

                Text('✦')
                  .fontSize(11)
                  .fontColor(Theme.V2B_GOLD_RIPPLE)
                  .opacity(index === this.quoteList.length - 1 ? 0.46 : 0.24)
                  .position({ x: '50%', y: 12 })
                  .translate({ x: '-50%', y: 0 })

                Text(quote)
                  .fontSize(index === this.quoteList.length - 1 ? Theme.V2B_FONT_LEAD : Theme.V2B_FONT_BODY)
                  .fontColor(Theme.V2B_TEXT_PRIMARY)
                  .fontWeight(FontWeight.Normal)
                  .lineHeight(index === this.quoteList.length - 1 ? 29 : 24)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .padding({ left: 22, right: 22, top: 28, bottom: 20 })

                Column()
                  .width(6)
                  .height(6)
                  .border({ width: { top: 0.5, left: 0.5 }, color: 'rgba(236, 216, 157, 0.09)' })
                  .position({ x: 14, y: 14 })

                Column()
                  .width(6)
                  .height(6)
                  .border({ width: { top: 0.5, right: 0.5 }, color: 'rgba(236, 216, 157, 0.09)' })
                  .position({ x: '100%', y: 14 })
                  .translate({ x: -20, y: 0 })

                Column()
                  .width(6)
                  .height(6)
                  .border({ width: { bottom: 0.5, left: 0.5 }, color: 'rgba(236, 216, 157, 0.06)' })
                  .position({ x: 14, y: '100%' })
                  .translate({ x: 0, y: -20 })

                Column()
                  .width(6)
                  .height(6)
                  .border({ width: { bottom: 0.5, right: 0.5 }, color: 'rgba(236, 216, 157, 0.06)' })
                  .position({ x: '100%', y: '100%' })
                  .translate({ x: -20, y: -20 })
              }
              .width(index === this.quoteList.length - 1 ? '78%' : '68%')
              .constraintSize({ minHeight: index === this.quoteList.length - 1 ? 106 : 86 })
              .backgroundColor(index === this.quoteList.length - 1 ? 'rgba(15, 24, 53, 0.66)' : 'rgba(15, 24, 53, 0.46)')
              .border({ width: 1, color: index === this.quoteList.length - 1 ? 'rgba(236, 216, 157, 0.16)' : Theme.V2B_BORDER })
              .borderRadius(Theme.V2B_RADIUS_CARD)
              .shadow(index === this.quoteList.length - 1 ? Theme.V2B_SHADOW_CARD : { radius: 12, color: 'rgba(0,0,0,0.22)', offsetX: 0, offsetY: 2 })
              .opacity(index === this.quoteList.length - 1 ? 1.0 : 0.72)
            }, (quote: string, index: number) => 'ql_' + index.toString() + '_' + quote.substring(0, 4))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .padding({ top: 24, bottom: 16, left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .onClick(() => {
          this.addNextXinglanQuote();
        })

        // 提示 — B 方案水雾灰
        Text('轻触上方区域，星澜会回应你。')
          .fontSize(12)
          .fontColor(Theme.V2B_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding({ bottom: 10 })

        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(Theme.V2B_FONT_CAPTION)
          .fontColor(Theme.V2B_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(16)
          .width('100%')
          .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD, bottom: 16 })
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
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [Theme.V2C_BG_BASE, 0.0],
            ['#0C1024', 0.48],
            [Theme.V2C_BG_BASE, 1.0]
          ]
        })

      Column()
        .width('100%')
        .height('42%')
        .radialGradient({
          center: ['50%', '8%'],
          radius: '78%',
          colors: [
            ['rgba(197,160,80,0.045)', 0.0],
            ['rgba(197,160,80,0.014)', 0.44],
            ['rgba(10,13,26,0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.Transparent)

      Column() {
        Column()
          .width('100%')
          .height(Theme.SAFE_TOP + 12)

        Text('星钥之书')
          .fontSize(Theme.V2C_FONT_TITLE)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_SM })

        Text('翻阅七十八张牌，\n看看每一种意象如何照见不同的处境。')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(20)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_XS, bottom: Theme.V2_SPACE_MD })

        // 筛选区
        Scroll() {
          Row() {
            ForEach(this.filters, (filter: FilterOption, index: number) => {
              Text(filter.label)
                .fontSize(13)
                .fontColor(this.selectedFilter === filter.value ? Theme.V2C_GOLD_GILT_SOFT : Theme.V2C_TEXT_SECONDARY)
                .fontWeight(this.selectedFilter === filter.value ? FontWeight.Medium : FontWeight.Normal)
                .height(32)
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.selectedFilter === filter.value ? 'rgba(197,160,80,0.10)' : 'rgba(18,24,54,0.58)')
                .borderRadius(Theme.V2C_RADIUS_CHIP)
                .border({
                  width: 1,
                  color: this.selectedFilter === filter.value ? 'rgba(197,160,80,0.38)' : 'rgba(139,134,155,0.14)'
                })
                .margin({ right: Theme.V2_SPACE_XS })
                .onClick(() => {
                  this.applyFilter(filter.value);
                })
            }, (_filter: FilterOption, index: number) => 'tab_filter_' + index.toString())
          }
          .height(32)
          .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(40)
        .margin({ bottom: Theme.V2_SPACE_XS })

        Divider()
          .strokeWidth(0.5)
          .color('rgba(197,160,80,0.12)')
          .width('88%')
          .margin({ bottom: Theme.V2_SPACE_XS })

        // 卡牌网格（3 列真实牌面）
        Scroll() {
          Grid() {
            ForEach(this.displayedCards, (card: TarotCard, index: number) => {
              GridItem() {
                Column() {
                  Column() {
                    TarotCardImage({ cardId: card.id, cardWidth: 82, cardHeight: 132 })
                  }
                  .padding(4)
                  .backgroundColor('rgba(10,13,26,0.68)')
                  .borderRadius(Theme.V2C_RADIUS_CARD)
                  .border({ width: 1, color: 'rgba(197,160,80,0.20)' })
                  .margin({ bottom: Theme.V2_SPACE_XS })

                  Text(card.nameZh)
                    .fontSize(12)
                    .fontColor(Theme.V2C_TEXT_PRIMARY)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(2)
                    .textAlign(TextAlign.Center)
                    .lineHeight(17)
                    .width('100%')
                    .height(36)
                }
                .width('100%')
                .padding({ top: Theme.V2_SPACE_XS, left: Theme.V2_SPACE_2XS, right: Theme.V2_SPACE_2XS, bottom: Theme.V2_SPACE_XS })
                .backgroundColor('rgba(18,24,54,0.72)')
                .borderRadius(Theme.V2C_RADIUS_CARD)
                .border({ width: 1, color: 'rgba(197,160,80,0.12)' })
                .shadow({
                  radius: 10,
                  color: 'rgba(0,0,0,0.28)',
                  offsetX: 0,
                  offsetY: 2
                })
                .onClick(() => {
                  this.navigateToDetail(card);
                })
              }
            }, (card: TarotCard) => card.id)
          }
          .columnsTemplate('1fr 1fr 1fr')
          .columnsGap(Theme.V2_SPACE_MD)
          .rowsGap(Theme.V2_SPACE_MD)
          .width('100%')
          .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD, top: Theme.V2_SPACE_SM, bottom: 112 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
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
// Tab 4: 我的（原设置页升级为个人中心）
// ═══════════════════════════════════════════════════════════

@Component
struct SettingsTabContent {
  @State isResetting: boolean = false;
  @State bgmEnabled: boolean = true;
  @State avatarUri: string = '';
  @State nickname: string = '未命名旅者';
  @State showNicknameDialog: boolean = false;
  private nicknameEditText: string = '';
  @State level: string = '初见';
  /** 头像操作面板可见 */
  @State showAvatarSheet: boolean = false;
  /** 是否正在选择图片 */
  @State isPickingPhoto: boolean = false;
  /** 用于抑制 loadBgmEnabled 中程序化 @State 更新触发的 Toggle.onChange */
  private isLoadingBgmState: boolean = false;
  private isProfileLoaded: boolean = false;

  // ── 星澜星历状态 ──
  @State starRecords: EmotionStarRecord[] = [];
  @State cumulativeLightDays: number = 0;
  @State streakDays: number = 0;
  @State nextLevelTitle: string = '星火初亮';
  @State daysToNextLevel: number = 1;
  @State isMaxLevel: boolean = false;
  @State isTodayLit: boolean = false;

  // ── 可翻页日历状态 ──
  @State visibleYear: number = 0;        // 当前显示的年份，0 表示未初始化
  @State visibleMonth: number = 0;       // 当前显示的月份，0 表示未初始化
  @State currentYear: number = 0;        // 真实今天的年份
  @State currentMonth: number = 0;       // 真实今天的月份
  @State calendarDays: number[] = [];
  @State calendarOffset: number = 0;
  @State visibleMonthRecords: EmotionStarRecord[] = [];
  @State visibleMonthLightDays: number = 0;

  // ── 日期详情弹窗 ──
  @State selectedDateKey: string = '';
  @State selectedRecord: EmotionStarRecord | null = null;
  @State showDateDetail: boolean = false;

  aboutToAppear(): void {
    this.loadBgmEnabled();
    this.loadProfile();
    this.loadStarCalendar();
  }

  /**
   * 加载星澜星历数据（每次页面出现都刷新）
   * visibleYear/visibleMonth 只在首次初始化时设为当前月份，翻页后刷新保持不变
   */
  private async loadStarCalendar(): Promise<void> {
    try {
      const records: EmotionStarRecord[] = await EmotionStarStorage.getRecords(getContext(this));
      this.starRecords = records;

      // 今天日期（全局参考）
      const today: Date = new Date();
      this.currentYear = today.getFullYear();
      this.currentMonth = today.getMonth() + 1;

      // 首次加载时 visible 初始化为当前月
      if (this.visibleMonth === 0) {
        this.visibleYear = this.currentYear;
        this.visibleMonth = this.currentMonth;
      }

      // 全局统计（不受翻页影响）
      this.isTodayLit = await EmotionStarStorage.hasLightedToday(getContext(this));
      this.cumulativeLightDays = EmotionStarStorage.getTotalLightDays(records);
      this.streakDays = EmotionStarStorage.getCurrentStreakDays(records);

      // 等级
      const level: StarKeyLevel = EmotionStarStorage.getLevelByTotalDays(this.cumulativeLightDays);
      this.level = level.title;

      // 下一等级
      const nextInfo: NextLevelInfo = EmotionStarStorage.getNextLevelInfo(this.cumulativeLightDays);
      this.nextLevelTitle = nextInfo.title;
      this.daysToNextLevel = nextInfo.daysLeft;
      this.isMaxLevel = nextInfo.isMaxLevel;

      // 刷新可见月份数据
      this.refreshVisibleMonth();
    } catch (_err) {
      // keep defaults
    }
  }

  /**
   * 根据 visibleYear/visibleMonth 刷新日历格子和本月统计
   */
  private refreshVisibleMonth(): void {
    if (this.visibleMonth === 0) {
      return;
    }
    this.visibleMonthRecords = EmotionStarStorage.getMonthRecords(
      this.starRecords, this.visibleYear, this.visibleMonth
    );
    // 按日期倒序（最新的在前，用于历史列表）
    this.visibleMonthRecords = [...this.visibleMonthRecords].sort(
      (a: EmotionStarRecord, b: EmotionStarRecord) => {
        if (a.date > b.date) {
          return -1;
        }
        if (a.date < b.date) {
          return 1;
        }
        return 0;
      }
    );
    this.visibleMonthLightDays = this.visibleMonthRecords.length;
    this.generateCalendar();
  }

  /**
   * 生成可见月份日历数据
   */
  private generateCalendar(): void {
    const daysInMonth: number = EmotionStarStorage.getDaysInMonth(this.visibleYear, this.visibleMonth);
    const firstDayOfWeek: number = EmotionStarStorage.getFirstDayOfWeek(this.visibleYear, this.visibleMonth);

    this.calendarOffset = firstDayOfWeek;
    this.calendarDays = [];
    for (let i = 1; i <= daysInMonth; i++) {
      this.calendarDays.push(i);
    }
  }

  /**
   * 判断可见月份中日历某个日期是否已点亮
   */
  private isDayLit(day: number): boolean {
    const dateStr: string = EmotionStarStorage.formatDateString(this.visibleYear, this.visibleMonth, day);
    for (let i = 0; i < this.starRecords.length; i++) {
      if (this.starRecords[i].date === dateStr) {
        return true;
      }
    }
    return false;
  }

  // ── 月份翻页 ──

  private goToPreviousMonth(): void {
    if (this.visibleMonth <= 1) {
      this.visibleMonth = 12;
      this.visibleYear -= 1;
    } else {
      this.visibleMonth -= 1;
    }
    this.reloadVisibleMonth();
  }

  private goToNextMonth(): void {
    let nextMonth: number = this.visibleMonth + 1;
    let nextYear: number = this.visibleYear;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear += 1;
    }
    this.visibleMonth = nextMonth;
    this.visibleYear = nextYear;
    this.reloadVisibleMonth();
  }

  /**
   * 当前是否在查看未来月份
   */
  private isViewingFutureMonth(): boolean {
    return EmotionStarStorage.compareYearMonth(
      this.visibleYear, this.visibleMonth, this.currentYear, this.currentMonth
    ) > 0;
  }

  private goToCurrentMonth(): void {
    if (this.visibleYear === this.currentYear && this.visibleMonth === this.currentMonth) {
      return;
    }
    this.visibleYear = this.currentYear;
    this.visibleMonth = this.currentMonth;
    this.reloadVisibleMonth();
  }

  private isViewingCurrentMonth(): boolean {
    return this.visibleYear === this.currentYear && this.visibleMonth === this.currentMonth;
  }

  private async reloadVisibleMonth(): Promise<void> {
    try {
      const records: EmotionStarRecord[] = await EmotionStarStorage.getRecords(getContext(this));
      this.starRecords = records;
      this.refreshVisibleMonth();
    } catch (_err) {
      // ignore
    }
  }

  // ── 日期详情弹窗 ──

  /**
   * 检查可见月份中某个日期是否属于未来
   */
  private dayIsFuture(day: number): boolean {
    const dateKey: string = EmotionStarStorage.formatDateString(this.visibleYear, this.visibleMonth, day);
    return EmotionStarStorage.isFutureDate(dateKey);
  }

  /**
   * 当前选中的日期详情是否指向今天
   */
  private isSelectedDateToday(): boolean {
    return this.selectedDateKey === EmotionStarStorage.todayString();
  }

  private isSelectedDateFuture(): boolean {
    return EmotionStarStorage.isFutureDate(this.selectedDateKey);
  }

  private handleDateClick(day: number): void {
    const dateKey: string = EmotionStarStorage.formatDateString(this.visibleYear, this.visibleMonth, day);
    this.selectedDateKey = dateKey;
    this.selectedRecord = EmotionStarStorage.getRecordByDate(this.starRecords, dateKey);
    this.showDateDetail = true;
  }

  private handleHistoryItemClick(record: EmotionStarRecord): void {
    this.selectedDateKey = record.date;
    this.selectedRecord = record;
    this.showDateDetail = true;
  }

  private closeDateDetail(): void {
    this.showDateDetail = false;
    this.selectedDateKey = '';
    this.selectedRecord = null;
  }

  private async loadProfile(): Promise<void> {
    if (this.isProfileLoaded) {
      // 昵称和等级只加载一次，但头像总是刷新
      try {
        this.avatarUri = await UserProfileStore.getAvatarUri(getContext(this));
      } catch (_err) {
        // keep current
      }
      return;
    }
    this.isProfileLoaded = true;
    try {
      this.avatarUri = await UserProfileStore.getAvatarUri(getContext(this));
      this.nickname = await UserProfileStore.getNickname(getContext(this));
      this.level = await UserProfileStore.getLevel(getContext(this));
    } catch (_err) {
      // keep defaults
    }
  }

  private async loadBgmEnabled(): Promise<void> {
    try {
      const enabled: boolean = await PreferenceStore.getBoolean('bgm_enabled', true, getContext(this));
      this.isLoadingBgmState = true;
      this.bgmEnabled = enabled;
      this.isLoadingBgmState = false;
    } catch (_err) {
      this.bgmEnabled = GlobalBgmManager.getInstance().getMusicEnabled();
    }
  }

  private async toggleBgm(isOn: boolean): Promise<void> {
    if (this.isLoadingBgmState) {
      return;
    }
    if (this.bgmEnabled === isOn) {
      return;
    }
    this.bgmEnabled = isOn;
    const bgmManager: GlobalBgmManager = GlobalBgmManager.getInstance();
    bgmManager.setMusicEnabled(isOn);
    try {
      await PreferenceStore.putBoolean('bgm_enabled', isOn, getContext(this));
    } catch (_err) {
      // ignore
    }
  }

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

  /**
   * 当从 AvatarCropPage 返回时，刷新头像 URI
   * 在 onPageShow / 生命周期中调用
   */
  private async refreshAvatar(): Promise<void> {
    try {
      this.avatarUri = await UserProfileStore.getAvatarUri(getContext(this));
    } catch (_err) {
      // keep current
    }
  }

  /**
   * 校验并保存昵称
   */
  private async handleSaveNickname(): Promise<void> {
    const trimmed: string = this.nicknameEditText.trim();

    // 空字符串视为恢复默认
    if (trimmed.length === 0) {
      await this.handleResetNickname();
      return;
    }

    // 长度校验：按字符数（支持 emoji）
    const nicknameLength: number = Array.from(trimmed).length;
    if (nicknameLength > 12) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '昵称短一点，星澜会更好记住。',
          duration: 2000
        });
      } catch (_err) {
        // ignore
      }
      return;
    }

    // 不允许换行
    if (trimmed.includes('\n') || trimmed.includes('\r')) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '昵称不能包含换行。',
          duration: 2000
        });
      } catch (_err) {
        // ignore
      }
      return;
    }

    // 不允许明显控制字符
    const controlRegex: RegExp = /[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/;
    if (controlRegex.test(trimmed)) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '昵称包含不支持的字符。',
          duration: 2000
        });
      } catch (_err) {
        // ignore
      }
      return;
    }

    try {
      await UserProfileStore.setNickname(trimmed, getContext(this));
      this.nickname = trimmed;
      this.showNicknameDialog = false;
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '星澜记住这个称呼了。',
          duration: 2000
        });
      } catch (_err) {
        // ignore
      }
    } catch (_err) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '保存失败，请稍后再试。',
          duration: 2000
        });
      } catch (_err2) {
        // ignore
      }
    }
  }

  /**
   * 恢复默认昵称
   */
  private async handleResetNickname(): Promise<void> {
    try {
      await UserProfileStore.clearNickname(getContext(this));
      this.nickname = '未命名旅者';
      this.nicknameEditText = '';
      this.showNicknameDialog = false;
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '已恢复默认昵称。',
          duration: 2000
        });
      } catch (_err) {
        // ignore
      }
    } catch (_err) {
      // keep current
    }
  }

  /**
   * 打开系统图片选择器，选择头像图片
   */
  private async openPhotoPicker(): Promise<void> {
    this.showAvatarSheet = false;
    if (this.isPickingPhoto) {
      return;
    }
    this.isPickingPhoto = true;
    try {
      const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      const helper: photoAccessHelper.PhotoAccessHelper =
        photoAccessHelper.getPhotoAccessHelper(ctx);
      const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();

      const result: photoAccessHelper.PhotoSelectResult = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });

      if (result.photoUris && result.photoUris.length > 0) {
        const selectedUri: string = result.photoUris[0];
        // 跳转到 AvatarCropPage 进行裁剪
        try {
          const options: router.RouterOptions = {
            url: Routes.AVATAR_CROP,
            params: { imageUri: selectedUri }
          };
          router.pushUrl(options);
        } catch (_err2) {
          // ignore
        }
      }
    } catch (err) {
      const errStr: string = JSON.stringify(err);
      // 用户取消选择不会触发错误，这里处理真正的异常
      if (!errStr.includes('cancel') && !errStr.includes('Cancel')) {
        hilog.warn(0x0000, 'SettingsTab', 'PhotoPicker error: %{public}s', errStr);
      }
    } finally {
      this.isPickingPhoto = false;
    }
  }

  /**
   * 恢复默认头像
   */
  private async resetAvatar(): Promise<void> {
    this.showAvatarSheet = false;
    try {
      await UserProfileStore.clearAvatarUri(getContext(this));
      this.avatarUri = '';
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Stack() {
      // 沉浸式深空背景（A 星图档案）
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [Theme.BG_DEEP_SPACE, 0.0],
            [Theme.V2A_BG_BASE, 0.55],
            [Theme.V2A_BG_BASE, 1.0]
          ]
        })

      Scroll() {
        Column() {
          Column()
            .width('100%')
            .height(Theme.SAFE_TOP + 16)
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [
                [Theme.BG_DEEP_SPACE, 0.0],
                ['rgba(8, 11, 24, 0)', 1.0]
              ]
            })

          // 档案主标题：月光白克制，配星轨细线（不抢）
          Row() {
            Column()
              .width(28)
              .height(1)
              .backgroundColor(Theme.V2A_ORBIT_LINE)

            Text('我的')
              .fontSize(Theme.V2A_FONT_TITLE)
              .fontColor(Theme.V2A_TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .letterSpacing(2)
              .margin({ left: 12, right: 12 })

            Column()
              .width(28)
              .height(1)
              .backgroundColor(Theme.V2A_ORBIT_LINE)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_SM })

        // ═══ 头像档案圆章 ═══
        Column() {
          // 圆形头像
          Stack() {
            if (this.avatarUri.length > 0) {
              Image(this.avatarUri)
                .width(88)
                .height(88)
                .borderRadius(44)
                .objectFit(ImageFit.Cover)
                .clip(true)
            } else {
              Image($r('app.media.app_icon3'))
                .width(88)
                .height(88)
                .borderRadius(44)
                .objectFit(ImageFit.Cover)
                .clip(true)
                .opacity(0.85)
            }
          }
          .width(92)
          .height(92)
          .borderRadius(46)
          .border({ width: 1, color: Theme.V2A_GOLD_ACCENT })
          .shadow(Theme.V2A_SHADOW_CARD)
          .alignContent(Alignment.Center)
          .margin({ bottom: 14 })
          .onClick(() => { this.showAvatarSheet = true; })

          // 昵称 + 编辑按钮
          Row() {
            Text(this.nickname)
              .fontSize(Theme.V2A_FONT_SUBTITLE)
              .fontColor(Theme.V2A_TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text('✎')
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_TEXT_SECONDARY)
              .margin({ left: 8 })
              .onClick(() => {
                this.nicknameEditText = this.nickname;
                this.showNicknameDialog = true;
              })
          }
          .margin({ bottom: 8 })

          // 等级标签：柔和金细线徽章
          Text('星钥等级：' + this.level)
            .fontSize(Theme.V2A_FONT_CAPTION)
            .fontColor(Theme.V2A_GOLD_GLOW)
            .letterSpacing(1)
            .padding({ left: 16, right: 16, top: 4, bottom: 4 })
            .backgroundColor('rgba(201, 164, 75, 0.06)')
            .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
            .borderRadius(Theme.V2A_RADIUS_CHIP)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 16, bottom: 16 })
        .margin({ bottom: Theme.SPACE_MD })

        // ═══ 今日点亮状态提示（档案时间戳） ═══
        Column() {
          Row() {
            Text(this.isTodayLit ? '⭐' : '☆')
              .fontSize(Theme.V2A_FONT_DATE_NUM)
              .fontColor(this.isTodayLit ? Theme.V2A_GOLD_ACCENT : Theme.V2_TEXT_TERTIARY)
              .margin({ right: 8 })

            Text(this.isTodayLit ? '今日已点亮' : '今日未点亮')
              .fontSize(Theme.V2A_FONT_BODY)
              .fontColor(this.isTodayLit ? Theme.V2A_GOLD_GLOW : Theme.V2A_TEXT_SECONDARY)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8, bottom: 8 })
        }
        .width('88%')
        .margin({ bottom: Theme.SPACE_MD })

        // ═══ 星澜星历日历卡片 ═══
        Column() {
          // 档案编号 + 卡片标题
          Row() {
            Text('档案 · 星历')
              .fontSize(Theme.V2A_FONT_TIMESTAMP)
              .fontColor(Theme.V2_TEXT_TERTIARY)
              .letterSpacing(1)
              .width('100%')
          }
          .width('100%')
          .margin({ bottom: 6 })

          Text('星澜星历')
            .fontSize(Theme.V2A_FONT_SUBTITLE)
            .fontColor(Theme.V2A_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ bottom: 4 })

          Text('不是打卡，只是把认真感受过的日子轻轻留下。')
            .fontSize(Theme.V2A_FONT_CAPTION)
            .fontColor(Theme.V2A_TEXT_SECONDARY)
            .width('100%')
            .margin({ bottom: Theme.V2_SPACE_MD })

          // ═══ 月份翻页控件 ═══
          Row() {
            // 左箭头
            Text('‹')
              .fontSize(Theme.V2A_FONT_TITLE)
              .fontColor(Theme.V2A_GOLD_ACCENT)
              .fontWeight(FontWeight.Lighter)
              .width(36)
              .height(36)
              .textAlign(TextAlign.Center)
              .onClick(() => { this.goToPreviousMonth(); })

            // 月份标题（等宽时间戳风格）
            Text(this.visibleYear.toString() + ' 年 ' + this.visibleMonth.toString() + ' 月')
              .fontSize(Theme.V2A_FONT_DATE_NUM)
              .fontColor(Theme.V2A_GOLD_GLOW)
              .fontWeight(FontWeight.Medium)
              .letterSpacing(1)
              .textAlign(TextAlign.Center)
              .layoutWeight(1)

            // 右箭头（始终可翻页）
            Text('›')
              .fontSize(Theme.V2A_FONT_TITLE)
              .fontColor(Theme.V2A_GOLD_ACCENT)
              .fontWeight(FontWeight.Lighter)
              .width(36)
              .height(36)
              .textAlign(TextAlign.Center)
              .onClick(() => { this.goToNextMonth(); })
          }
          .width('100%')
          .margin({ bottom: 6 })

          // 回到本月按钮（历史月份时显示）
          if (!this.isViewingCurrentMonth()) {
            Text('回到本月')
              .fontSize(Theme.V2A_FONT_DISCLAIMER)
              .fontColor(Theme.V2A_GOLD_ACCENT)
              .padding({ left: 14, right: 14, top: 4, bottom: 4 })
              .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
              .borderRadius(Theme.V2A_RADIUS_CHIP)
              .onClick(() => { this.goToCurrentMonth(); })
              .margin({ bottom: 14 })
          } else {
            Blank()
              .height(6)
          }

          // 星期头
          Row() {
            ForEach(['一', '二', '三', '四', '五', '六', '日'], (label: string) => {
              Text(label)
                .fontSize(Theme.V2A_FONT_DISCLAIMER)
                .fontColor(Theme.V2_TEXT_TERTIARY)
                .width('14.28%')
                .textAlign(TextAlign.Center)
                .height(28)
            }, (label: string) => 'wkd_' + label)
          }
          .width('100%')

          // 日期格（7 列布局，可点击）
          Flex({ wrap: FlexWrap.Wrap }) {
            // 前面的空白格
            ForEach(new Array(this.calendarOffset).fill(0), (_empty: number, idx: number) => {
              Column()
                .width('14.28%')
                .height(42)
            }, (_empty: number, idx: number) => 'offset_' + idx.toString())

            // 日期格
            ForEach(this.calendarDays, (day: number) => {
              Column() {
                if (this.isDayLit(day)) {
                  // 已点亮：金色星星
                  Text('⭐')
                    .fontSize(Theme.V2A_FONT_DATE_NUM)
                    .fontColor(Theme.V2A_GOLD_ACCENT)
                } else {
                  // 未点亮：灰蓝日期数字 或 未来日期置灰
                  Text(day.toString())
                    .fontSize(Theme.V2A_FONT_CAPTION)
                    .fontColor(this.dayIsFuture(day) ? Theme.V2_STATE_FUTURE_TEXT : Theme.V2_TEXT_TERTIARY)
                }
              }
              .width('14.28%')
              .height(42)
              .justifyContent(FlexAlign.Center)
              .borderRadius(Theme.V2_RADIUS_SM)
              .border({
                width: EmotionStarStorage.isToday(this.visibleYear, this.visibleMonth, day) ? 1 : 0,
                color: EmotionStarStorage.isToday(this.visibleYear, this.visibleMonth, day) ?
                  Theme.V2A_GOLD_ACCENT : 'transparent'
              })
              .backgroundColor(
                EmotionStarStorage.isToday(this.visibleYear, this.visibleMonth, day) &&
                  !this.isDayLit(day) ? 'rgba(201, 164, 75, 0.06)' : 'transparent'
              )
              .onClick(() => { this.handleDateClick(day); })
            }, (day: number) => 'cal_day_' + day.toString())
          }
          .width('100%')
          .margin({ bottom: Theme.V2_SPACE_MD })

          // 星轨贯穿线
          Divider()
            .strokeWidth(0.5)
            .color(Theme.V2A_ORBIT_LINE)
            .width('100%')
            .margin({ bottom: Theme.V2_SPACE_SM })

          // 统计行（档案数据）
          Row() {
            Column() {
              Text(this.visibleMonthLightDays.toString())
                .fontSize(Theme.V2A_FONT_RANK_DAYS)
                .fontColor(Theme.V2A_GOLD_ACCENT)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .width('100%')

              Text('本月点亮')
                .fontSize(Theme.V2A_FONT_DISCLAIMER)
                .fontColor(Theme.V2A_TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 2 })
            }
            .layoutWeight(1)

            Column() {
              Text(this.cumulativeLightDays.toString())
                .fontSize(Theme.V2A_FONT_RANK_DAYS)
                .fontColor(Theme.V2A_GOLD_GLOW)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .width('100%')

              Text('累计点亮')
                .fontSize(Theme.V2A_FONT_DISCLAIMER)
                .fontColor(Theme.V2A_TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 2 })
            }
            .layoutWeight(1)

            Column() {
              Text(this.streakDays.toString())
                .fontSize(Theme.V2A_FONT_RANK_DAYS)
                .fontColor(Theme.V2A_GOLD_ACCENT)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .width('100%')

              Text('连续点亮')
                .fontSize(Theme.V2A_FONT_DISCLAIMER)
                .fontColor(Theme.V2A_TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: Theme.V2_SPACE_SM })

          // 下一称号信息
          if (!this.isMaxLevel) {
            Text('下一称号：' + this.nextLevelTitle)
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_TEXT_SECONDARY)
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 4 })

            Text('距离「' + this.nextLevelTitle + '」还差 ' + this.daysToNextLevel.toString() + ' 天')
              .fontSize(Theme.V2A_FONT_DISCLAIMER)
              .fontColor(Theme.V2_TEXT_TERTIARY)
              .width('100%')
              .textAlign(TextAlign.Center)
          } else {
            Text('你已到达最高星钥等级')
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_GOLD_ACCENT)
              .width('100%')
              .textAlign(TextAlign.Center)
          }

          // ═══ 查看完整星历入口 ═══
          Row() {
            Text('查看完整星历')
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_GOLD_ACCENT)
              .fontWeight(FontWeight.Medium)

            Text('›')
              .fontSize(Theme.V2A_FONT_BODY)
              .fontColor(Theme.V2A_GOLD_ACCENT)
              .fontWeight(FontWeight.Lighter)
              .margin({ left: 4 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: Theme.V2_SPACE_MD, bottom: 4 })
          .onClick(() => {
            try {
              const options: router.RouterOptions = { url: Routes.STAR_CALENDAR };
              router.pushUrl(options);
            } catch (_err) {
              // 跳转失败静默
            }
          })

          // ═══ 本月星光记录 ═══
          if (this.visibleMonthRecords.length > 0) {
            Divider()
              .strokeWidth(0.5)
              .color(Theme.V2A_ORBIT_LINE)
              .width('100%')
              .margin({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_SM })

            Text('本月星光记录')
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_GOLD_GLOW)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ bottom: 10 })

            ForEach(this.visibleMonthRecords, (record: EmotionStarRecord, idx: number) => {
              Row() {
                Text(EmotionStarStorage.formatMonthDay(record.date))
                  .fontSize(Theme.V2A_FONT_CAPTION)
                  .fontColor(Theme.V2A_TEXT_SECONDARY)
                  .width(72)

                Text(record.starName)
                  .fontSize(Theme.V2A_FONT_CAPTION)
                  .fontColor(Theme.V2A_GOLD_GLOW)
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text('›')
                  .fontSize(Theme.V2A_FONT_BODY)
                  .fontColor(Theme.V2A_ORBIT_LINE)
                  .width(20)
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .border({
                width: idx < this.visibleMonthRecords.length - 1 ? 0.5 : 0,
                color: Theme.V2A_ORBIT_LINE
              })
              .onClick(() => { this.handleHistoryItemClick(record); })
            }, (record: EmotionStarRecord) => 'star_month_item_' + record.date)
          } else {
            Divider()
              .strokeWidth(0.5)
              .color(Theme.V2A_ORBIT_LINE)
              .width('100%')
              .margin({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_SM })

            if (this.isViewingCurrentMonth()) {
              Text('这个月还没有留下星光。\n完成一次每日一占，就能点亮今天。')
                .fontSize(Theme.V2A_FONT_DISCLAIMER)
                .fontColor(Theme.V2_TEXT_TERTIARY)
                .textAlign(TextAlign.Center)
                .lineHeight(20)
                .width('100%')
            } else if (this.isViewingFutureMonth()) {
              Text('这些日子还在星光前方。')
                .fontSize(Theme.V2A_FONT_DISCLAIMER)
                .fontColor(Theme.V2_TEXT_TERTIARY)
                .textAlign(TextAlign.Center)
                .width('100%')
            } else {
              Text('这个月没有点亮记录。')
                .fontSize(Theme.V2A_FONT_DISCLAIMER)
                .fontColor(Theme.V2_TEXT_TERTIARY)
                .textAlign(TextAlign.Center)
                .width('100%')
            }
          }
        }
        .width('92%')
        .padding(Theme.V2_SPACE_MD_B)
        .backgroundColor(Theme.V2A_BG_CARD)
        .borderRadius(Theme.V2A_RADIUS_CARD)
        .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
        .shadow(Theme.V2A_SHADOW_CARD)
        .margin({ bottom: Theme.SPACE_MD })

        // ═══ 偏好设置卡片 ═══
        // 背景音乐开关
        Column() {
          Row() {
            Column() {
              Text('背景音乐')
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .width('100%')

              Text('开启后，星钥塔罗会播放一首低音量的全局主旋律。')
                .fontSize(Theme.V2A_FONT_CAPTION)
                .fontColor(Theme.V2A_TEXT_SECONDARY)
                .width('100%')
                .margin({ top: 4 })
            }
            .layoutWeight(1)

            Toggle({ type: ToggleType.Switch, isOn: this.bgmEnabled })
              .selectedColor(Theme.V2A_GOLD_ACCENT)
              .onChange((isOn: boolean) => {
                this.toggleBgm(isOn);
              })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .padding({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_MD, left: Theme.V2_SPACE_MD_B, right: Theme.V2_SPACE_MD_B })
        }
        .width('92%')
        .backgroundColor(Theme.V2A_BG_CARD)
        .borderRadius(Theme.V2A_RADIUS_CARD)
        .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
        .shadow(Theme.V2A_SHADOW_CARD)
        .margin({ bottom: Theme.SPACE_MD })

        // 重新听听星澜的介绍
        Column() {
          Row() {
            Column() {
              Text('重新听听星澜的介绍')
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .width('100%')
            }
            .layoutWeight(1)

            Text('›')
              .fontSize(Theme.V2A_FONT_SUBTITLE)
              .fontColor(Theme.V2A_ORBIT_LINE)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .padding({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_MD, left: Theme.V2_SPACE_MD_B, right: Theme.V2_SPACE_MD_B })

          Text('星澜会重新陪你走一遍语录页的第一次介绍。')
            .fontSize(Theme.V2A_FONT_CAPTION)
            .fontColor(Theme.V2A_TEXT_SECONDARY)
            .width('100%')
            .padding({ left: Theme.V2_SPACE_MD_B, right: Theme.V2_SPACE_MD_B, bottom: Theme.V2_SPACE_MD })
        }
        .width('92%')
        .backgroundColor(Theme.V2A_BG_CARD)
        .borderRadius(Theme.V2A_RADIUS_CARD)
        .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
        .shadow(Theme.V2A_SHADOW_CARD)
        .margin({ bottom: Theme.SPACE_MD })
        .onClick(() => { this.resetAllGuides(); })

        // ═══ 帮助卡片 ═══
        // 使用说明
        Column() {
          Row() {
            Column() {
              Text('使用说明')
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .width('100%')
            }
            .layoutWeight(1)

            Text('›')
              .fontSize(Theme.V2A_FONT_SUBTITLE)
              .fontColor(Theme.V2A_ORBIT_LINE)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .padding({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_MD, left: Theme.V2_SPACE_MD_B, right: Theme.V2_SPACE_MD_B })

          Text('了解星钥塔罗每个板块的用法和设计初衷。')
            .fontSize(Theme.V2A_FONT_CAPTION)
            .fontColor(Theme.V2A_TEXT_SECONDARY)
            .width('100%')
            .padding({ left: Theme.V2_SPACE_MD_B, right: Theme.V2_SPACE_MD_B, bottom: Theme.V2_SPACE_MD })
        }
        .width('92%')
        .backgroundColor(Theme.V2A_BG_CARD)
        .borderRadius(Theme.V2A_RADIUS_CARD)
        .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
        .shadow(Theme.V2A_SHADOW_CARD)
        .margin({ bottom: Theme.SPACE_MD })
        .onClick(() => {
          try {
            const options: router.RouterOptions = { url: Routes.USAGE_GUIDE };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        })

        // ═══ 关于卡片 ═══
        // 关于星钥塔罗
        Column() {
          Row() {
            Column() {
              Text('关于星钥塔罗')
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .width('100%')
            }
            .layoutWeight(1)

            Text('›')
              .fontSize(Theme.V2A_FONT_SUBTITLE)
              .fontColor(Theme.V2A_ORBIT_LINE)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .padding({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_MD, left: Theme.V2_SPACE_MD_B, right: Theme.V2_SPACE_MD_B })

          Text('版本信息、隐私政策、用户协议、素材与授权。')
            .fontSize(Theme.V2A_FONT_CAPTION)
            .fontColor(Theme.V2A_TEXT_SECONDARY)
            .width('100%')
            .padding({ left: Theme.V2_SPACE_MD_B, right: Theme.V2_SPACE_MD_B, bottom: Theme.V2_SPACE_MD })
        }
        .width('92%')
        .backgroundColor(Theme.V2A_BG_CARD)
        .borderRadius(Theme.V2A_RADIUS_CARD)
        .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
        .shadow(Theme.V2A_SHADOW_CARD)
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
          .fontSize(Theme.V2A_FONT_DISCLAIMER)
          .fontColor(Theme.V2_TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .lineHeight(16)
          .width('100%')
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 12 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')

      // ═══ 头像操作面板（底部弹出）═══
      if (this.showAvatarSheet) {
        // 半透明遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.V2_OVERLAY_SCRIM)
          .onClick(() => { this.showAvatarSheet = false; })

        // 底部面板
        Column() {
          // 标题
          Text('更换头像')
            .fontSize(Theme.V2A_FONT_SUBTITLE)
            .fontColor(Theme.V2A_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: Theme.V2_SPACE_MD_B, bottom: Theme.V2_SPACE_MD })

          // 分割线
          Divider()
            .strokeWidth(0.5)
            .color(Theme.V2A_ORBIT_LINE)
            .width('88%')

          // 从相册选择
          Row() {
            Text('从相册选择')
              .fontSize(Theme.V2A_FONT_BODY)
              .fontColor(Theme.V2A_TEXT_PRIMARY)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 18, bottom: 18 })
          }
          .width('100%')
          .onClick(() => { this.openPhotoPicker(); })

          Divider()
            .strokeWidth(0.5)
            .color(Theme.V2A_ORBIT_LINE)
            .width('88%')

          // 恢复默认头像
          Row() {
            Text('恢复默认头像')
              .fontSize(Theme.V2A_FONT_BODY)
              .fontColor(Theme.V2A_TEXT_PRIMARY)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 18, bottom: 18 })
          }
          .width('100%')
          .onClick(() => { this.resetAvatar(); })

          Divider()
            .strokeWidth(0.5)
            .color(Theme.V2A_ORBIT_LINE)
            .width('88%')

          // 取消
          Row() {
            Text('取消')
              .fontSize(Theme.V2A_FONT_BODY)
              .fontColor(Theme.V2A_TEXT_SECONDARY)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 18, bottom: 18 })
          }
          .width('100%')
          .onClick(() => { this.showAvatarSheet = false; })

          // 底部安全区
          Row()
            .width('100%')
            .height(Theme.SAFE_BOTTOM)
        }
        .width('100%')
        .backgroundColor(Theme.V2A_BG_FLOATING)
        .borderRadius({ topLeft: Theme.V2A_RADIUS_POPUP, topRight: Theme.V2A_RADIUS_POPUP })
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: '-100%' })
        .zIndex(100)
      }

      // ═══ 日期详情弹窗（居中卡片）═══
      if (this.showDateDetail) {
        // 半透明遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.V2_OVERLAY_SCRIM)
          .onClick(() => { this.closeDateDetail(); })
          .zIndex(150)

        // 居中详情卡片
        Column() {
          // 日期标题（等宽时间戳风格）
          Text(EmotionStarStorage.formatMonthDay(this.selectedDateKey))
            .fontSize(Theme.V2A_FONT_RANK_TITLE)
            .fontColor(Theme.V2A_GOLD_GLOW)
            .fontWeight(FontWeight.Medium)
            .letterSpacing(1)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: Theme.V2_SPACE_MD })

          if (this.selectedRecord !== null) {
            // ======== 已点亮：展示详情 ========
            Text('这一天，你留下了一颗情绪星。')
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_TEXT_SECONDARY)
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 18 })

            // 星名
            Row() {
              Text('今日星名')
                .fontSize(Theme.V2A_FONT_CAPTION)
                .fontColor(Theme.V2_TEXT_TERTIARY)
                .width(72)

              Text(this.selectedRecord.starName)
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_GOLD_GLOW)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 10 })

            // 牌名
            Row() {
              Text('今日牌名')
                .fontSize(Theme.V2A_FONT_CAPTION)
                .fontColor(Theme.V2_TEXT_TERTIARY)
                .width(72)

              Text(this.selectedRecord.cardName)
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_GOLD_GLOW)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 10 })

            // 点亮时间
            Row() {
              Text('点亮时间')
                .fontSize(Theme.V2A_FONT_CAPTION)
                .fontColor(Theme.V2_TEXT_TERTIARY)
                .width(72)

              Text(EmotionStarStorage.formatTimeFromTimestamp(this.selectedRecord.createdAt))
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_GOLD_GLOW)
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 18 })

            Divider()
              .strokeWidth(0.5)
              .color(Theme.V2A_ORBIT_LINE)
              .width('100%')
              .margin({ bottom: Theme.V2_SPACE_MD })

            Text('星澜记得：')
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_GOLD_ACCENT)
              .width('100%')
              .margin({ bottom: 8 })

            Text('那天的你，也认真面对过自己的感受。')
              .fontSize(Theme.V2A_FONT_BODY)
              .fontColor(Theme.V2A_TEXT_PRIMARY)
              .lineHeight(22)
              .width('100%')
              .margin({ bottom: Theme.V2_SPACE_MD_B })
          } else {
            // ======== 未点亮 ========
            if (this.isSelectedDateToday()) {
              Text('今天还没有点亮情绪星。')
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 12 })

              Text('完成一次每日一占，就能为今天留下一点星光。')
                .fontSize(Theme.V2A_FONT_CAPTION)
                .fontColor(Theme.V2A_TEXT_SECONDARY)
                .lineHeight(20)
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: Theme.V2_SPACE_MD_B })
            } else if (this.isSelectedDateFuture()) {
              // ======== 未来日期 ========
              Text('这一天还在星光前方。')
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 12 })

              Text('未来的每一天，都值得期待。')
                .fontSize(Theme.V2A_FONT_CAPTION)
                .fontColor(Theme.V2A_TEXT_SECONDARY)
                .lineHeight(20)
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: Theme.V2_SPACE_MD_B })
            } else {
              Text('这一天还没有留下星光。')
                .fontSize(Theme.V2A_FONT_BODY)
                .fontColor(Theme.V2A_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 12 })

              Text('没关系，不是每天都需要记录。\n你愿意回来看看自己，就已经很好了。')
                .fontSize(Theme.V2A_FONT_CAPTION)
                .fontColor(Theme.V2A_TEXT_SECONDARY)
                .lineHeight(20)
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: Theme.V2_SPACE_MD_B })
            }
          }

          // 关闭按钮
          Text('知道了')
            .fontSize(Theme.V2A_FONT_BODY)
            .fontColor(Theme.V2A_GOLD_ACCENT)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor('rgba(201, 164, 75, 0.06)')
            .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
            .borderRadius(Theme.V2A_RADIUS_CHIP)
            .onClick(() => { this.closeDateDetail(); })
        }
        .width('82%')
        .padding(Theme.V2_SPACE_MD_B)
        .backgroundColor(Theme.V2A_BG_FLOATING)
        .borderRadius(Theme.V2A_RADIUS_POPUP)
        .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
        .shadow(Theme.V2A_SHADOW_CARD)
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-50%', y: '-50%' })
        .zIndex(200)
      }

      // ═══ 昵称编辑弹窗 ═══
      if (this.showNicknameDialog) {
        // 半透明遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.V2_OVERLAY_SCRIM)
          .onClick(() => { this.showNicknameDialog = false; })
          .zIndex(150)
          .hitTestBehavior(HitTestMode.Block)

        // 居中编辑卡片
        Column() {
          Text('给自己取一个星钥昵称')
            .fontSize(Theme.V2A_FONT_SUBTITLE)
            .fontColor(Theme.V2A_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 12 })

          Text('这个昵称只保存在你的设备上，用来让星澜更自然地称呼你。')
            .fontSize(Theme.V2A_FONT_CAPTION)
            .fontColor(Theme.V2A_TEXT_SECONDARY)
            .lineHeight(20)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: Theme.V2_SPACE_MD_B })

          TextInput({ placeholder: '比如：小月、阿澜、旅人、今晚的我', text: this.nicknameEditText })
            .width('100%')
            .height(48)
            .fontSize(Theme.V2A_FONT_BODY)
            .fontColor(Theme.V2A_TEXT_PRIMARY)
            .placeholderColor(Theme.V2_TEXT_TERTIARY)
            .backgroundColor('rgba(255, 255, 255, 0.04)')
            .borderRadius(Theme.V2_RADIUS_SM)
            .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
            .padding({ left: 14, right: 14 })
            .maxLength(12)
            .type(InputType.Normal)
            .onChange((value: string) => {
              this.nicknameEditText = value;
            })
            .margin({ bottom: Theme.V2_SPACE_MD_B })

          Row() {
            Button('恢复默认')
              .type(ButtonType.Normal)
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_TEXT_SECONDARY)
              .backgroundColor('rgba(255, 255, 255, 0.04)')
              .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
              .borderRadius(Theme.V2A_RADIUS_CHIP)
              .height(42)
              .layoutWeight(1)
              .onClick(() => { this.handleResetNickname(); })

            Blank().width(12)

            Button('取消')
              .type(ButtonType.Normal)
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_TEXT_SECONDARY)
              .backgroundColor('rgba(255, 255, 255, 0.04)')
              .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
              .borderRadius(Theme.V2A_RADIUS_CHIP)
              .height(42)
              .layoutWeight(1)
              .onClick(() => { this.showNicknameDialog = false; })

            Blank().width(12)

            Button('保存')
              .type(ButtonType.Normal)
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(Theme.V2A_BG_BASE)
              .backgroundColor(Theme.V2A_GOLD_ACCENT)
              .borderRadius(Theme.V2A_RADIUS_CHIP)
              .height(42)
              .layoutWeight(1)
              .onClick(() => { this.handleSaveNickname(); })
          }
          .width('100%')
        }
        .width('80%')
        .padding(Theme.V2_SPACE_MD_B)
        .backgroundColor(Theme.V2A_BG_FLOATING)
        .borderRadius(Theme.V2A_RADIUS_POPUP)
        .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
        .shadow(Theme.V2A_SHADOW_CARD)
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-50%', y: '-50%' })
        .zIndex(200)
      }
    }
    .width('100%')
    .height('100%')
  }
}

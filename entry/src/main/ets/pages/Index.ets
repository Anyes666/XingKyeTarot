import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';
import { LegalDocuments } from '../common/LegalDocuments';
import { DailyFortuneService } from '../service/DailyFortuneService';
import { DivinationHistoryService } from '../service/DivinationHistoryService';
import { UserStateService } from '../service/UserStateService';
import { DailyFortune } from '../model/DailyFortune';
import { DivinationRecord } from '../model/DivinationRecord';
import { StarBackground } from '../components/StarBackground';
import { PrimaryButton } from '../components/PrimaryButton';
import { ComplianceFooter } from '../components/ComplianceFooter';

interface FeatureEntry {
  id: string;
  title: string;
  subtitle: string;
  spreadId: string;
  enabled: boolean;
}

const FEATURE_ENTRIES: FeatureEntry[] = [
  { id: 'single', title: '单牌快占', subtitle: '快速获得此刻指引', spreadId: 'single_card', enabled: true },
  { id: 'triangle', title: '圣三角', subtitle: '过去 · 现在 · 未来', spreadId: 'sacred_triangle', enabled: true },
  { id: 'relationship', title: '关系探索', subtitle: '我 · 对方 · 走向', spreadId: 'relationship', enabled: true },
  { id: 'decision', title: '决策牌阵', subtitle: '即将上线', spreadId: 'decision', enabled: false }
];

@Entry
@Component
struct Index {
  @State showDisclaimer: boolean = false;
  @State dailyFortune: DailyFortune | null = null;
  @State isLoading: boolean = true;
  @State fortuneSummary: string = '';
  @State fortuneKeyword: string = '';
  @State fortuneCardName: string = '';
  @State fortuneIsReversed: boolean = false;
  @State divinationHistoryCount: number = 0;
  @State showLegalDetail: boolean = false;
  @State legalDetailTitle: string = '';
  @State legalDetailContent: string = '';

  async aboutToAppear(): Promise<void> {
    // ── P0 MVP 已通过 EntryAbility 直接加载 AskHeartPage，此处不再 redirect ──
    // （保留原始 v1.x 首页逻辑，供后续从其他入口访问）

    const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

    // 初始化响应式窗口宽度（vp），供所有组件 breakpoint 自适应
    this.initWindowMetrics();

    const complianceAccepted: boolean = await UserStateService.isComplianceAccepted(ctx);
    if (!complianceAccepted) {
      this.showDisclaimer = true;
      return;
    }

    const onboardingDone: boolean = await UserStateService.isOnboardingDone(ctx);
    if (!onboardingDone) {
      try {
        await this.getUIContext().getRouter().replaceUrl({ url: Routes.ONBOARDING });
      } catch (err) {
        hilog.error(0x0000, 'Index', 'Router replace error: %{public}s', JSON.stringify(err));
      }
      return;
    }

    await this.loadFortune(ctx);
    await this.loadHistoryPreview(ctx);
  }

  async onPageShow(): Promise<void> {
    const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    await this.loadHistoryPreview(ctx);
  }

  async loadFortune(ctx: Context): Promise<void> {
    try {
      // TarotDataService 已在 EntryAbility.onWindowStageCreate 中初始化
      const userId: string = await UserStateService.getUserId(ctx);
      const fortune: DailyFortune = await DailyFortuneService.getTodayFortune(userId, ctx);
      this.dailyFortune = fortune;
      this.fortuneCardName = fortune.card.nameZh;
      this.fortuneKeyword = fortune.keyword;
      this.fortuneSummary = fortune.summary;
      this.fortuneIsReversed = fortune.isReversed;
    } catch (err) {
      this.fortuneCardName = '—';
      this.fortuneKeyword = '加载中…';
      this.fortuneSummary = '';
    } finally {
      this.isLoading = false;
    }
  }

  async loadHistoryPreview(ctx: Context): Promise<void> {
    try {
      const history: DivinationRecord[] = await DivinationHistoryService.getRecentRecords(ctx);
      this.divinationHistoryCount = history.length;
    } catch (err) {
      this.divinationHistoryCount = 0;
    }
  }

  async acceptDisclaimer(): Promise<void> {
    const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    await UserStateService.acceptCompliance(ctx);
    this.showDisclaimer = false;

    const onboardingDone: boolean = await UserStateService.isOnboardingDone(ctx);
    if (!onboardingDone) {
      try {
        await this.getUIContext().getRouter().replaceUrl({ url: Routes.ONBOARDING });
      } catch (err) {
        hilog.error(0x0000, 'Index', 'Router replace error: %{public}s', JSON.stringify(err));
      }
    } else {
      await this.loadFortune(ctx);
      await this.loadHistoryPreview(ctx);
    }
  }

  build() {
    Stack() {
      StarBackground()

      Column() {
        Column() {
          Text(Constants.APP_NAME)
            .fontSize(Theme.FONT_HEADLINE)
            .fontColor(Theme.GOLD)
            .fontWeight(FontWeight.Bold)
            .letterSpacing(4)

          Text('探索内心，点亮星光')
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.TEXT_MUTED)
            .margin({ top: Theme.SPACE_XS })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 60, bottom: Theme.SPACE_XL })

        Column() {
          Row() {
            Text('今日一占')
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.GOLD)
              .fontWeight(FontWeight.Bold)
              .padding({ left: Theme.SPACE_SM, right: Theme.SPACE_SM, top: 2, bottom: 2 })
              .borderRadius(Theme.RADIUS_SM)
              .border({ width: 1, color: Theme.GOLD })
          }
          .width('100%')
          .margin({ bottom: Theme.SPACE_MD })

          if (this.isLoading) {
            LoadingProgress()
              .width(36)
              .height(36)
              .color(Theme.GOLD)
          } else {
            Row() {
              Column() {
                Text(this.fortuneCardName)
                  .fontSize(Theme.FONT_TITLE)
                  .fontColor(Theme.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)

                if (this.fortuneIsReversed) {
                  Text('逆位')
                    .fontSize(Theme.FONT_CAPTION)
                    .fontColor(Theme.DANGER_SOFT)
                    .margin({ top: 4 })
                }

                Text(this.fortuneKeyword)
                  .fontSize(Theme.FONT_BODY)
                  .fontColor(Theme.AURORA)
                  .margin({ top: Theme.SPACE_SM })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('查看详情 >')
                .fontSize(Theme.FONT_CAPTION)
                .fontColor(Theme.GOLD_SOFT)
            }
            .width('100%')
            .onClick(() => {
              try {
                this.getUIContext().getRouter().pushUrl({ url: Routes.DAILY_FORTUNE });
              } catch (err) {
                hilog.error(0x0000, 'Index', 'Router push error: %{public}s', JSON.stringify(err));
              }
            })
          }
        }
        .width('85%')
        .padding(Theme.SPACE_LG)
        .backgroundColor(Theme.BG_CARD)
        .borderRadius(Theme.RADIUS_LG)
        .border({ width: 1, color: 'rgba(216, 180, 90, 0.2)' })
        .shadow({
          radius: 16,
          color: 'rgba(216, 180, 90, 0.08)',
          offsetY: 4
        })

        this.FeatureGrid()
        this.HistoryEntry()
        this.TarotLibraryEntry()

        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.TEXT_MUTED)
          .opacity(0.6)
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_MD })

        Blank()
      }
      .width('100%')
      .height('100%')

      if (this.showDisclaimer) {
        this.LegalAgreementDialog()
      }

      if (this.showLegalDetail) {
        this.LegalDetailCover()
      }
    }
  }

  @Builder
  FeatureGrid(): void {
    Column() {
      Text('选择一种占卜方式')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .width('85%')
        .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_MD })

      Grid() {
        ForEach(FEATURE_ENTRIES, (entry: FeatureEntry) => {
          GridItem() {
            this.FeatureCard(entry)
          }
        }, (entry: FeatureEntry) => entry.id)
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(Theme.SPACE_MD)
      .columnsGap(Theme.SPACE_MD)
      .width('85%')
      .height(188)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  HistoryEntry(): void {
    Row() {
      Column() {
        Text('历史查询 >')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)

        Text(`查看最近 ${this.divinationHistoryCount} / 50 条占卜记录`)
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.TEXT_MUTED)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.divinationHistoryCount > 0 ? '继续回看' : '暂未生成')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.GOLD_SOFT)
    }
    .width('85%')
    .padding(Theme.SPACE_MD)
    .margin({ top: Theme.SPACE_MD })
    .backgroundColor('rgba(23, 29, 58, 0.72)')
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(216, 180, 90, 0.16)' })
    .onClick(() => {
      try {
        this.getUIContext().getRouter().pushUrl({ url: Routes.DIVINATION_HISTORY });
      } catch (err) {
        hilog.error(0x0000, 'Index', 'Router push error: %{public}s', JSON.stringify(err));
      }
    })
  }

  @Builder
  TarotLibraryEntry(): void {
    Row() {
      Column() {
        Text('塔罗库')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontColor(Theme.TEXT_MUTED)
          .fontWeight(FontWeight.Medium)

        Text('78 张牌全览 · 即将上线')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.TEXT_MUTED)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('敬请期待')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.GOLD_SOFT)
        .opacity(0.55)
    }
    .width('85%')
    .padding(Theme.SPACE_MD)
    .margin({ top: Theme.SPACE_SM })
    .backgroundColor('rgba(23, 29, 58, 0.46)')
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(255, 255, 255, 0.08)' })
    .onClick(() => {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '塔罗库即将上线，敬请期待',
          duration: 1800
        });
      } catch (err) {
        hilog.error(0x0000, 'Index', 'Toast error: %{public}s', JSON.stringify(err));
      }
    })
  }

  @Builder
  FeatureCard(entry: FeatureEntry): void {
    Column() {
      Text(entry.title)
        .fontSize(Theme.FONT_BODY)
        .fontColor(entry.enabled ? Theme.TEXT_PRIMARY : Theme.TEXT_MUTED)
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(entry.subtitle)
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(entry.enabled ? Theme.AURORA : Theme.TEXT_MUTED)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: Theme.SPACE_SM })
    }
    .width('100%')
    .height(86)
    .padding(Theme.SPACE_MD)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(entry.enabled ? Theme.BG_CARD : 'rgba(23, 29, 58, 0.46)')
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: entry.enabled ? 'rgba(216, 180, 90, 0.18)' : 'rgba(255, 255, 255, 0.08)' })
    .onClick(() => {
      this.openFeature(entry);
    })
  }

  @Builder
  LegalAgreementDialog(): void {
    Column() {
      Column() {
        Text('用户协议与隐私政策')
          .fontSize(Theme.FONT_TITLE)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: Theme.SPACE_MD })

        Text('欢迎使用星钥塔罗。请您在继续使用前仔细阅读并同意以下协议与政策。')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_SECONDARY)
          .lineHeight(24)
          .margin({ bottom: Theme.SPACE_MD })

        Text() {
          Span('我已阅读并同意 ')
            .fontColor(Theme.TEXT_SECONDARY)
          Span('《用户协议》')
            .fontColor(Theme.GOLD)
            .decoration({ type: TextDecorationType.Underline, color: Theme.GOLD })
            .onClick(() => {
              this.openLegalDetail(LegalDocuments.USER_AGREEMENT_TITLE, LegalDocuments.USER_AGREEMENT);
            })
          Span(' 和 ')
            .fontColor(Theme.TEXT_SECONDARY)
          Span('《隐私政策》')
            .fontColor(Theme.GOLD)
            .decoration({ type: TextDecorationType.Underline, color: Theme.GOLD })
            .onClick(() => {
              this.openLegalDetail(LegalDocuments.PRIVACY_POLICY_TITLE, LegalDocuments.PRIVACY_POLICY);
            })
          Span('。本应用内容仅供娱乐和自我探索参考，不构成任何专业建议。')
            .fontColor(Theme.TEXT_SECONDARY)
        }
        .fontSize(Theme.FONT_BODY)
        .lineHeight(24)
        .margin({ bottom: Theme.SPACE_LG })

        Row() {
          Button('不同意')
            .layoutWeight(1)
            .height(44)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_SECONDARY)
            .backgroundColor('rgba(255, 255, 255, 0.06)')
            .borderRadius(Theme.RADIUS_FULL)
            .onClick(() => {
              this.getUIContext().getPromptAction().showToast({
                message: '需要同意用户协议与隐私政策后才能继续使用',
                duration: 2500
              });
            })

          Button('同意并继续')
            .layoutWeight(1)
            .height(44)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.BG_DEEP)
            .fontWeight(FontWeight.Bold)
            .backgroundColor(Theme.GOLD)
            .borderRadius(Theme.RADIUS_FULL)
            .margin({ left: Theme.SPACE_MD })
            .onClick(() => {
              this.acceptDisclaimer();
            })
        }
        .width('100%')
      }
      .width('84%')
      .padding(Theme.SPACE_LG)
      .backgroundColor(Theme.BG_PRIMARY)
      .borderRadius(Theme.RADIUS_LG)
      .border({ width: 1.5, color: Theme.GOLD })
      .shadow({
        radius: 24,
        color: 'rgba(0, 0, 0, 0.5)',
        offsetY: 8
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(8, 11, 24, 0.92)')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  LegalDetailCover(): void {
    Column() {
      Row() {
        Text(this.legalDetailTitle)
          .fontSize(Theme.FONT_TITLE)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('关闭')
          .height(36)
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.BG_DEEP)
          .backgroundColor(Theme.GOLD)
          .borderRadius(Theme.RADIUS_FULL)
          .onClick(() => {
            this.closeLegalDetail();
          })
      }
      .width('100%')
      .padding({ left: Theme.SPACE_LG, right: Theme.SPACE_LG, top: Theme.SPACE_XL, bottom: Theme.SPACE_MD })

      Scroll() {
        Text(this.legalDetailContent)
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_SECONDARY)
          .lineHeight(24)
          .padding({ left: Theme.SPACE_LG, right: Theme.SPACE_LG, bottom: Theme.SPACE_XXL })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP)
  }

  private initWindowMetrics(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync();
      // px2vp 来自 @kit.ArkUI，将物理像素转为 vp
      const screenVp: number = px2vp(displayInfo.width);
      AppStorage.setOrCreate('windowWidth', screenVp);
    } catch (e) {
      // 降级：使用默认手机宽度
      AppStorage.setOrCreate('windowWidth', 360);
    }
  }

  private openLegalDetail(title: string, content: string): void {
    this.legalDetailTitle = title;
    this.legalDetailContent = content;
    this.showLegalDetail = true;
  }

  private closeLegalDetail(): void {
    this.showLegalDetail = false;
    this.legalDetailTitle = '';
    this.legalDetailContent = '';
  }

  private openFeature(entry: FeatureEntry): void {
    if (!entry.enabled) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '该牌阵即将上线',
          duration: 1800
        });
      } catch (err) {
        hilog.error(0x0000, 'Index', 'Toast error: %{public}s', JSON.stringify(err));
      }
      return;
    }

    AppStorage.setOrCreate('selectedSpreadId', entry.spreadId);
    try {
      this.getUIContext().getRouter().pushUrl({ url: Routes.DIVINATION });
    } catch (err) {
      hilog.error(0x0000, 'Index', 'Router push error: %{public}s', JSON.stringify(err));
    }
  }
}

import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';
import { DailyFortuneService } from '../service/DailyFortuneService';
import { UserStateService } from '../service/UserStateService';
import { DailyFortune } from '../model/DailyFortune';
import { StarBackground } from '../components/StarBackground';
import { PrimaryButton } from '../components/PrimaryButton';
import { ComplianceFooter } from '../components/ComplianceFooter';

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

  async aboutToAppear(): Promise<void> {
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

    const complianceAccepted: boolean = await UserStateService.isComplianceAccepted(ctx);
    if (!complianceAccepted) {
      this.showDisclaimer = true;
      return;
    }

    const onboardingDone: boolean = await UserStateService.isOnboardingDone(ctx);
    if (!onboardingDone) {
      try {
        router.replaceUrl({ url: Routes.ONBOARDING });
      } catch (err) {
        hilog.error(0x0000, 'Index', 'Router replace error: %{public}s', JSON.stringify(err));
      }
      return;
    }

    await this.loadFortune(ctx);
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

  async acceptDisclaimer(): Promise<void> {
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    await UserStateService.acceptCompliance(ctx);
    this.showDisclaimer = false;

    const onboardingDone: boolean = await UserStateService.isOnboardingDone(ctx);
    if (!onboardingDone) {
      try {
        router.replaceUrl({ url: Routes.ONBOARDING });
      } catch (err) {
        hilog.error(0x0000, 'Index', 'Router replace error: %{public}s', JSON.stringify(err));
      }
    } else {
      await this.loadFortune(ctx);
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
                router.pushUrl({ url: Routes.DAILY_FORTUNE });
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

        Blank()

        PrimaryButton({
          buttonLabel: '开始占卜',
          onTap: () => {
            try {
              router.pushUrl({ url: Routes.DIVINATION });
            } catch (err) {
              hilog.error(0x0000, 'Index', 'Router push error: %{public}s', JSON.stringify(err));
            }
          }
        })

        Text('结果仅供娱乐，请理性参考')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.TEXT_MUTED)
          .opacity(0.6)
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_MD })

        Blank()
      }
      .width('100%')
      .height('100%')

      if (this.showDisclaimer) {
        Column() {
          Column() {
            Text(Constants.COMPLIANCE_TITLE)
              .fontSize(Theme.FONT_TITLE)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: Theme.SPACE_MD })

            Text(Constants.COMPLIANCE_CONTENT)
              .fontSize(Theme.FONT_BODY)
              .fontColor(Theme.TEXT_SECONDARY)
              .lineHeight(24)
              .margin({ bottom: Theme.SPACE_LG })

            Button('我已了解')
              .width('100%')
              .height(44)
              .fontSize(Theme.FONT_BODY)
              .fontColor(Theme.BG_DEEP)
              .fontWeight(FontWeight.Bold)
              .backgroundColor(Theme.GOLD)
              .borderRadius(Theme.RADIUS_FULL)
              .onClick(() => {
                this.acceptDisclaimer();
              })
          }
          .width('80%')
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
    }
  }
}

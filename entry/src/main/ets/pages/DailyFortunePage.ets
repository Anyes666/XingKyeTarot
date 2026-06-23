import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';
import { UserStateService } from '../service/UserStateService';
import { DailyFortuneService } from '../service/DailyFortuneService';
import { DailyFortune } from '../model/DailyFortune';
import { StarBackground } from '../components/StarBackground';
import { TarotCardView, CardDisplayState } from '../components/TarotCardView';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { PrimaryButton } from '../components/PrimaryButton';

@Entry
@Component
struct DailyFortunePage {
  @State fortune: DailyFortune | null = null;
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  async aboutToAppear(): Promise<void> {
    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    try {
      // TarotDataService 已在 EntryAbility.onWindowStageCreate 中初始化
      const userId: string = await UserStateService.getUserId(ctx);
      const fortune: DailyFortune = await DailyFortuneService.getTodayFortune(userId, ctx);
      this.fortune = fortune;
      this.isLoading = false;
    } catch (err) {
      this.errorMessage = '运势加载失败，请返回重试';
      this.isLoading = false;
    }
  }

  build() {
    Stack() {
      StarBackground()

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Theme.GOLD)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage.length > 0) {
        Column() {
          Text(this.errorMessage)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.DANGER_SOFT)
          Button('返回')
            .margin({ top: Theme.SPACE_MD })
            .onClick(() => {
              try {
                router.back();
              } catch (err) {
                hilog.error(0x0000, 'DailyFortunePage', 'Router back error: %{public}s', JSON.stringify(err));
              }
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.fortune) {
        Scroll() {
          Column() {
            Text('今日一占')
              .fontSize(Theme.FONT_TITLE)
              .fontColor(Theme.GOLD)
              .fontWeight(FontWeight.Bold)
              .letterSpacing(2)
              .margin({ top: 48, bottom: Theme.SPACE_XS })

            Text(this.fortune.dateKey)
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.TEXT_MUTED)
              .margin({ bottom: Theme.SPACE_LG })

            TarotCardView({
              cardName: this.fortune.card.nameZh,
              cardImage: this.fortune.card.image,
              isReversed: this.fortune.isReversed,
              displayState: CardDisplayState.REVEALED,
              cardWidth: 120,
              cardHeight: 192
            })
              .margin({ bottom: Theme.SPACE_LG })

            Text(this.fortune.card.nameZh)
              .fontSize(Theme.FONT_SUBTITLE)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)

            if (this.fortune.isReversed) {
              Text('逆位')
                .fontSize(Theme.FONT_CAPTION)
                .fontColor(Theme.DANGER_SOFT)
                .margin({ top: 4 })
            }

            Text(this.fortune.keyword)
              .fontSize(Theme.FONT_BODY)
              .fontColor(Theme.AURORA)
              .fontWeight(FontWeight.Medium)
              .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, top: 6, bottom: 6 })
              .borderRadius(Theme.RADIUS_SM)
              .backgroundColor('rgba(94, 215, 210, 0.1)')
              .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_LG })

            Text(this.fortune.summary)
              .fontSize(Theme.FONT_BODY)
              .fontColor(Theme.TEXT_SECONDARY)
              .lineHeight(26)
              .textAlign(TextAlign.Center)
              .padding({ left: Theme.SPACE_LG, right: Theme.SPACE_LG })
              .margin({ bottom: Theme.SPACE_XXL })

            PrimaryButton({
              buttonLabel: '返回首页',
              onTap: () => {
                try {
                  router.replaceUrl({ url: Routes.HOME });
                } catch (err) {
                  hilog.error(0x0000, 'DailyFortunePage', 'Router replace error: %{public}s', JSON.stringify(err));
                }
              }
            })
              .margin({ bottom: Theme.SPACE_MD })

            ComplianceFooter()

            Blank()
              .height(Theme.SPACE_LG)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      }
    }
  }
}

import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';
import { UserStateService } from '../service/UserStateService';
import { PrimaryButton } from '../components/PrimaryButton';
import { StarBackground } from '../components/StarBackground';
import { AppBackButton } from '../components/AppBackButton';

interface OnboardingPageData {
  title: string;
  description: string;
}

/**
 * 新手引导页 — 3 页滑动引导
 */
@Entry
@Component
struct OnboardingPage {
  @State currentPage: number = 0;
  private swiperController: SwiperController = new SwiperController();

  private readonly pages: OnboardingPageData[] = [
    {
      title: '抽一张牌\n不是预测命运',
      description: '星钥塔罗是你自我探索的伙伴。\n每一张牌都是一面镜子，\n帮助你看见内心的不同面向。'
    } as OnboardingPageData,
    {
      title: '圣三角牌阵',
      description: '过去 · 现在 · 未来\n\n三张牌对应三个时间维度，\n帮你理清当下的状态与可能的方向。\n请保持开放心态，享受这个过程。'
    } as OnboardingPageData,
    {
      title: '每日一占',
      description: '每天一张牌，一个关键词。\n适合作为一天的灵感提醒，\n也可以记录心情变化。\n\n结果仅供娱乐，请理性参考。'
    } as OnboardingPageData
  ];

  build() {
    Stack() {
      StarBackground()
      AppBackButton()

      Column() {
        Row() {
          Blank()
          Text('跳过')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_MUTED)
            .onClick(() => {
              this.finishOnboarding();
            })
        }
        .width('100%')
        .padding({ right: Theme.SPACE_LG, top: Theme.SPACE_XL })
        .margin({ top: 32 })

        Swiper(this.swiperController) {
          ForEach(this.pages, (page: OnboardingPageData, index: number) => {
            Column() {
              Stack() {
                Circle({ width: 120, height: 120 })
                  .fill('transparent')
                  .stroke(Theme.GOLD)
                  .strokeWidth(1)
                  .opacity(0.3)

                Circle({ width: 90, height: 90 })
                  .fill('transparent')
                  .stroke(Theme.AURORA)
                  .strokeWidth(0.5)
                  .opacity(0.25)
              }
              .margin({ bottom: Theme.SPACE_XL })

              Text(page.title)
                .fontSize(Theme.FONT_HEADLINE)
                .fontColor(Theme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .lineHeight(42)
                .margin({ bottom: Theme.SPACE_LG })

              Text(page.description)
                .fontSize(Theme.FONT_BODY)
                .fontColor(Theme.TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .lineHeight(26)
                .padding({ left: Theme.SPACE_XL, right: Theme.SPACE_XL })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }, (page: OnboardingPageData, index: number) => `onboarding_page_${index}`)
        }
        .width('100%')
        .layoutWeight(1)
        .indicator(
          Indicator.dot()
            .selectedColor(Theme.GOLD)
            .color(Theme.TEXT_MUTED)
            .itemWidth(8)
            .itemHeight(8)
            .selectedItemWidth(8)
            .selectedItemHeight(8)
        )
        .loop(false)
        .onChange((index: number) => {
          this.currentPage = index;
        })

        Column() {
          if (this.currentPage < this.pages.length - 1) {
            PrimaryButton({
              buttonLabel: '下一步',
              onTap: () => {
                this.swiperController.showNext();
              }
            })
          } else {
            PrimaryButton({
              buttonLabel: '开始体验',
              onTap: () => {
                this.finishOnboarding();
              }
            })
          }
        }
        .width('100%')
        .padding({ bottom: Theme.SPACE_XXL })
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 16 })
      }
      .width('100%')
      .height('100%')
    }
  }

  private async finishOnboarding(): Promise<void> {
    try {
      const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await UserStateService.completeOnboarding(ctx);
    } catch (e) {
      // Preference write may fail in some test contexts — still navigate
    }
    try {
      await this.getUIContext().getRouter().replaceUrl({ url: Routes.HOME });
    } catch (err) {
      hilog.error(0x0000, 'OnboardingPage', 'Router replace error: %{public}s', JSON.stringify(err));
    }
  }
}

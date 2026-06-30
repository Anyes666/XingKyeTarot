import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';
import { AppStateStore } from '../common/AppStateStore';

/**
 * 新手引导页 — 3 页引导
 * 完成 Onboarding 后进入 AskHeartPage(FIRST_EXPERIENCE)
 */
@Entry
@Component
struct OnboardingPage {
  @State currentIndex: number = 0;

  build() {
    Column() {
      // ── 图片区（if 分支）──
      if (this.currentIndex === 0) {
        Image($r('app.media.onboarding_self_seeing'))
          .width('100%')
          .height(280)
          .objectFit(ImageFit.Contain)
          .borderRadius(24)
          .border({ width: 1, color: 'rgba(202,138,4,0.25)' })
          .margin({ bottom: 24 })
      } else if (this.currentIndex === 1) {
        Image($r('app.media.onboarding_daily_star_key'))
          .width('100%')
          .height(280)
          .objectFit(ImageFit.Contain)
          .borderRadius(24)
          .border({ width: 1, color: 'rgba(202,138,4,0.25)' })
          .margin({ bottom: 24 })
      } else {
        Image($r('app.media.onboarding_feature'))
          .width('100%')
          .height(280)
          .objectFit(ImageFit.Contain)
          .borderRadius(24)
          .border({ width: 1, color: 'rgba(202,138,4,0.25)' })
          .margin({ bottom: 24 })
      }

      // ── 标题 ──
      if (this.currentIndex === 0) {
        Text('不是算命，是一次温柔的自我看见')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_LIGHT)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })
      } else if (this.currentIndex === 1) {
        Text('每天一张牌，点亮一颗情绪星')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_LIGHT)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })
      } else {
        Text('当心事变复杂，星澜会陪你慢慢看')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_LIGHT)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })
      }

      // ── 副标题 ──
      if (this.currentIndex === 0) {
        Text('星钥塔罗用塔罗牌作为心理隐喻，帮你整理那些说不出口的心事。')
          .fontSize(16)
          .fontColor(Theme.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .width('100%')
          .margin({ bottom: 16 })
      } else if (this.currentIndex === 1) {
        Text('选择一句最像此刻的心事，星澜会为你抽一张今日星钥。')
          .fontSize(16)
          .fontColor(Theme.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .width('100%')
          .margin({ bottom: 16 })
      } else {
        Text('每日一占、圣三角、关系探索，会从不同角度帮你整理情绪和选择。')
          .fontSize(16)
          .fontColor(Theme.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .width('100%')
          .margin({ bottom: 16 })
      }

      // ── 额外文案 ──
      if (this.currentIndex === 0) {
        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(12)
          .fontColor('#8B7A5C')
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ bottom: 24 })
      } else if (this.currentIndex === 1) {
        Text('不是为了坚持打卡，\n是为了慢慢看见自己。')
          .fontSize(15)
          .fontColor('#C8B88A')
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .width('100%')
          .margin({ bottom: 24 })
      } else {
        Column() {
          Text('每日一占：30 秒，看见此刻心事')
            .fontSize(14)
            .fontColor(Theme.TEXT_SECONDARY)
            .margin({ bottom: 6 })
          Text('圣三角：看清一件事的过去、现在、未来')
            .fontSize(14)
            .fontColor(Theme.TEXT_SECONDARY)
            .margin({ bottom: 6 })
          Text('关系探索：整理我、对方与这段关系的走向')
            .fontSize(14)
            .fontColor(Theme.TEXT_SECONDARY)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 24 })
      }

      // ── 分页点 ──
      Row({ space: 8 }) {
        Column()
          .width(this.currentIndex === 0 ? 18 : 6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.currentIndex === 0 ? Theme.GOLD_AMBER : '#3A3A5A')
        Column()
          .width(this.currentIndex === 1 ? 18 : 6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.currentIndex === 1 ? Theme.GOLD_AMBER : '#3A3A5A')
        Column()
          .width(this.currentIndex === 2 ? 18 : 6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.currentIndex === 2 ? Theme.GOLD_AMBER : '#3A3A5A')
      }
      .margin({ bottom: 20 })

      // ── 主按钮 ──
      Button(this.currentIndex < 2 ? '下一页' : '开始我的第一次星钥')
        .type(ButtonType.Normal)
        .width('100%')
        .height(52)
        .borderRadius(26)
        .backgroundColor(Theme.GOLD_MAIN)
        .fontColor(Theme.BTN_DARK_TEXT)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.handlePrimaryButtonClick();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
    .padding({ left: 24, right: 24, top: 48, bottom: 36 })
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 主按钮点击：翻页或完成引导
   */
  private handlePrimaryButtonClick(): void {
    if (this.currentIndex < 2) {
      this.currentIndex += 1;
    } else {
      this.completeAndEnterFirstExperience();
    }
  }

  /**
   * 完成引导并进入首次体验
   */
  private async completeAndEnterFirstExperience(): Promise<void> {
    try {
      const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await AppStateStore.completeOnboarding(ctx);
    } catch (err) {
      hilog.error(0x0000, 'OnboardingPage', 'completeOnboarding error: %{public}s', JSON.stringify(err));
    }
    try {
      const params: AskHeartRouteParams = { entryMode: 'FIRST_EXPERIENCE' };
      const routeOptions: router.RouterOptions = { url: Routes.ASK_HEART, params: params };
      router.replaceUrl(routeOptions).catch((_e: Error) => {
        hilog.error(0x0000, 'OnboardingPage', 'replaceUrl AskHeart failed');
      });
    } catch (err) {
      hilog.error(0x0000, 'OnboardingPage', 'replaceUrl error: %{public}s', JSON.stringify(err));
    }
  }
}

// ═══════════════════════════════════════════════════════════
// 路由参数接口（文件级作用域，与 LaunchPage 同名不冲突）
// ═══════════════════════════════════════════════════════════

interface AskHeartRouteParams {
  entryMode: string;
}

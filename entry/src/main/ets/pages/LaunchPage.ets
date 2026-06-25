import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { Routes } from '../common/Routes';
import { AppStateStore } from '../common/AppStateStore';

/**
 * LaunchPage 路由参数（无额外参数）
 */
interface LaunchRouteParams {
}

/**
 * 启动隐私门禁页面
 *
 * 流程：
 * 1. 渲染基础 UI（加载中）
 * 2. aboutToAppear 异步检查隐私同意状态
 * 3. 未同意 → 显示隐私门禁弹窗
 * 4. 同意后 → 检查首次体验 → 分流到 AskHeartPage(FIRST_EXPERIENCE) 或 HomePage
 */
@Entry
@Component
struct LaunchPage {
  @State isPrivacyChecked: boolean = false;
  @State showPrivacyGate: boolean = false;
  @State isAccepting: boolean = false;

  async aboutToAppear(): Promise<void> {
    try {
      const accepted: boolean = await AppStateStore.isPrivacyAccepted(getContext(this));
      if (!accepted) {
        this.showPrivacyGate = true;
      } else {
        await this.routeAfterPrivacy();
      }
    } catch (_err) {
      // 异常时显示隐私门禁
      this.showPrivacyGate = true;
    } finally {
      this.isPrivacyChecked = true;
    }
  }

  /**
   * 隐私同意后的路由分流
   */
  private async routeAfterPrivacy(): Promise<void> {
    try {
      // 1. 先判断 Onboarding 是否完成（必须在 firstExperience 之前）
      const onboardingDone: boolean = await AppStateStore.hasCompletedOnboarding(getContext(this));
      if (!onboardingDone) {
        // 未完成引导 → OnboardingPage
        const routeOptions: router.RouterOptions = {
          url: Routes.ONBOARDING,
        };
        router.replaceUrl(routeOptions).catch((_err: Error) => {
          // fallback
        });
        return;
      }
      // 2. 再判断首次体验是否完成
      const isFirstDone: boolean = await AppStateStore.isFirstExperienceCompleted(getContext(this));
      if (!isFirstDone) {
        // 首次体验 → AskHeartPage(FIRST_EXPERIENCE)
        const askParams: AskHeartRouteParams = {
          entryMode: 'FIRST_EXPERIENCE',
        };
        const routeOptions: router.RouterOptions = {
          url: Routes.ASK_HEART,
          params: askParams,
        };
        router.replaceUrl(routeOptions).catch((_err: Error) => {
          // fallback
        });
      } else {
        // 已完成首次体验 → HomePage
        const routeOptions: router.RouterOptions = {
          url: Routes.NEW_HOME,
        };
        router.replaceUrl(routeOptions).catch((_err: Error) => {
          // fallback
        });
      }
    } catch (_err) {
      // 异常默认进入首页
      const routeOptions: router.RouterOptions = {
        url: Routes.NEW_HOME,
      };
      router.replaceUrl(routeOptions).catch((_err2: Error) => {
        // fallback
      });
    }
  }

  /**
   * 用户点击「同意并继续」
   */
  private async onAccept(): Promise<void> {
    if (this.isAccepting) {
      return;
    }
    this.isAccepting = true;
    try {
      await AppStateStore.acceptPrivacy(getContext(this), Constants.PRIVACY_CURRENT_VERSION);
      this.showPrivacyGate = false;
      await this.routeAfterPrivacy();
    } catch (_err) {
      // 即使保存失败也继续
      this.showPrivacyGate = false;
      await this.routeAfterPrivacy();
    } finally {
      this.isAccepting = false;
    }
  }

  /**
   * 用户点击「不同意」→ router.back()
   */
  private onDecline(): void {
    try {
      router.back();
    } catch (_err) {
      // back 失败则不做额外处理
    }
  }

  /**
   * 打开《用户协议》
   */
  private openUserAgreement(): void {
    try {
      router.pushUrl({ url: Routes.USER_AGREEMENT });
    } catch (_err) {
      // ignore
    }
  }

  /**
   * 打开《隐私政策》
   */
  private openPrivacyPolicy(): void {
    try {
      router.pushUrl({ url: Routes.PRIVACY_POLICY });
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Stack() {
      // ── 深色全屏背景 ──
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      // ── 加载中 / 品牌展示 ──
      if (!this.showPrivacyGate) {
        Column() {
          Text(Constants.APP_NAME)
            .fontSize(Theme.FONT_HEADLINE)
            .fontColor(Theme.GOLD_LIGHT)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: Theme.SPACE_MD })

          Text('抽一张牌，看见你没说出口的心事')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.MOON_MUTED)
            .margin({ bottom: Theme.SPACE_XL })

          LoadingProgress()
            .width(36)
            .height(36)
            .color(Theme.GOLD_AMBER)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }

      // ── 隐私门禁弹窗（内联条件渲染，非 CustomDialog）──
      if (this.showPrivacyGate) {
        Column() {
          // 半透明遮罩
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.7)')

          // 弹窗卡片
          Column() {
            Text(Constants.PRIVACY_GATE_TITLE)
              .fontSize(Theme.FONT_TITLE)
              .fontColor(Theme.GOLD_LIGHT)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ bottom: Theme.SPACE_LG })

            // 正文（含可点击链接）
            Column() {
              Text('在你开始使用前，请先阅读并同意')
                .fontSize(Theme.FONT_BODY)
                .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                .textAlign(TextAlign.Start)

              Row() {
                Text('《用户协议》')
                  .fontSize(Theme.FONT_BODY)
                  .fontColor(Theme.GOLD_AMBER)
                  .fontWeight(FontWeight.Medium)
                  .onClick(() => {
                    this.openUserAgreement();
                  })

                Text('和')
                  .fontSize(Theme.FONT_BODY)
                  .fontColor(Theme.TEXT_PRIMARY_LIGHT)

                Text('《隐私政策》')
                  .fontSize(Theme.FONT_BODY)
                  .fontColor(Theme.GOLD_AMBER)
                  .fontWeight(FontWeight.Medium)
                  .onClick(() => {
                    this.openPrivacyPolicy();
                  })
              }
              .width('100%')
              .margin({ top: Theme.SPACE_XS, bottom: Theme.SPACE_MD })

              Text('。星钥塔罗是一款塔罗式情绪陪伴产品，内容仅供娱乐、情绪记录与自我探索参考，不构成医疗、心理咨询、法律、投资等专业建议。')
                .fontSize(Theme.FONT_BODY)
                .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .margin({ bottom: Theme.SPACE_XL })

            // 按钮区
            Column({ space: Theme.SPACE_MD }) {
              Button('同意并继续')
                .fontSize(Theme.FONT_BODY)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .height(48)
                .backgroundColor(Theme.GOLD_AMBER)
                .borderRadius(Theme.RADIUS_FULL)
                .enabled(!this.isAccepting)
                .onClick(() => {
                  this.onAccept();
                })

              Button('不同意')
                .fontSize(Theme.FONT_BODY)
                .fontColor(Theme.MOON_MUTED)
                .fontWeight(FontWeight.Normal)
                .width('100%')
                .height(44)
                .backgroundColor(Color.Transparent)
                .borderRadius(Theme.RADIUS_FULL)
                .onClick(() => {
                  this.onDecline();
                })
            }
            .width('100%')
          }
          .width('88%')
          .padding(Theme.SPACE_XL)
          .backgroundColor(Theme.BG_CARD_DARK)
          .borderRadius(Theme.RADIUS_LG)
          .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
          .position({ x: '6%', y: '25%' })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}

// ═══════════════════════════════════════════════════════════
// 路由参数接口（跨文件共用声明）
// ═══════════════════════════════════════════════════════════

interface AskHeartRouteParams {
  entryMode: string;
}

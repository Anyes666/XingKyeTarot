import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { HEART_OPTIONS, HeartOption } from '../data/HeartOptionsData';
import { AppStateStore } from '../common/AppStateStore';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PreferenceStore } from '../data/PreferenceStore';

/**
 * 问心页路由参数接口
 */
interface AskHeartRouteParams {
  entryMode: string;
}

/**
 * 抽牌页路由参数接口
 */
interface CardDrawRouteParams {
  entryMode: string;
  spreadType: string;
  heartOptionIndex: number;
  emotionTag: string;
  questionText: string;
}

/**
 * 阶段3A：单牌入口页首次引导文案
 */
const SINGLE_FIRST_GUIDE: string = '一张牌，一个此刻的映照。想着你现在最贴近的感受就好。';

/**
 * 问心入口页面
 * 用户在此选择当前最贴合的情绪状态，然后进入抽牌流程。
 * P0.2：支持 FIRST_EXPERIENCE / NORMAL_SINGLE 两套文案。
 */
@Entry
@Component
struct AskHeartPage {
  @State selectedIndex: number = -1;
  @State private isTransitioning: boolean = false;
  @State private entryMode: string = 'NORMAL_SINGLE';
  @State private showFirstGuide: boolean = false;

  aboutToAppear(): void {
    this.prepareFirstGuide();
  }

  /**
   * 阶段3A：首次进入单牌入口页引导
   * - 保留原 entryMode 解析逻辑
   * - 读 hasSeenSingleGuide，若 false 则显示引导并标记 true
   */
  private async prepareFirstGuide(): Promise<void> {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params: AskHeartRouteParams = rawParams as AskHeartRouteParams;
      this.entryMode = params.entryMode ?? 'NORMAL_SINGLE';
    }
    try {
      const hasSeen: boolean = await PreferenceStore.getBoolean('hasSeenSingleGuide', false, getContext(this));
      this.showFirstGuide = !hasSeen;
      if (!hasSeen) {
        await PreferenceStore.putBoolean('hasSeenSingleGuide', true, getContext(this));
      }
    } catch (err) {
      hilog.error(0x0000, 'AskHeartPage', 'prepareFirstGuide error: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 当前模式标题
   */
  private getTitle(): string {
    if (this.entryMode === 'FIRST_EXPERIENCE') {
      return '此刻，你的心是什么颜色？';
    }
    return '你现在，最想被哪件事接住？';
  }

  /**
   * 当前模式副标题
   */
  private getSubtitle(): string {
    if (this.entryMode === 'FIRST_EXPERIENCE') {
      return '第一次见面，星澜想先为你抽一张牌。';
    }
    return '不用想太久，选最像你此刻的那一句。';
  }

  /**
   * 当前模式按钮文案
   */
  private getButtonText(): string {
    if (this.entryMode === 'FIRST_EXPERIENCE') {
      return '让星澜为我抽第一张牌';
    }
    return '让星澜为我抽一张';
  }

  build() {
    Stack() {
      Column() {
      // ── P0.3 整改：左上角统一返回按钮（安全区修复）──
      Row() {
        AppBackButton({ fallbackUrl: Routes.HOME })
      }
      .width('100%')
      .padding({ top: Theme.SAFE_TOP, left: 14 })

      // ── 标题区 ──
      Column() {
        Text(this.getTitle())
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')

        Text(this.getSubtitle())
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM })
      }
      .width('100%')
      .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_MD })

      // ── 阶段3A：首次进入单牌入口页引导（仅首次显示）──
      if (this.showFirstGuide) {
        Text(SINGLE_FIRST_GUIDE)
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: Theme.SPACE_SM })
      }

      // ── 6 个问心选项 ──
      Scroll() {
        Column({ space: Theme.SPACE_MD }) {
          ForEach(HEART_OPTIONS, (option: HeartOption, index: number) => {
            this.buildHeartOption(option, index)
          }, (option: HeartOption) => option.index.toString())
        }
        .width('100%')
        .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: Theme.SPACE_MD })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // ── 确认按钮 ──
      Button(this.getButtonText())
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .width('85%')
        .height(52)
        .backgroundColor(this.selectedIndex >= 0 ? Theme.GOLD_AMBER : Theme.DEEP_STARRY)
        .borderRadius(Theme.RADIUS_FULL)
        .enabled(this.selectedIndex >= 0 && !this.isTransitioning)
        .opacity(this.selectedIndex >= 0 ? 1.0 : 0.4)
        .margin({ bottom: Theme.SPACE_SM })
        .onClick(() => {
          this.onConfirm();
        })

      // ── 首次体验跳过入口（仅 FIRST_EXPERIENCE 模式显示）──
      if (this.entryMode === 'FIRST_EXPERIENCE') {
        Button('暂时跳过，先逛首页')
          .type(ButtonType.Normal)
          .fontSize(14)
          .fontColor('#94A3B8')
          .backgroundColor(Color.Transparent)
          .width('auto')
          .height(40)
          .margin({ top: 4, bottom: Theme.SPACE_SM })
          .onClick(() => {
            this.skipFirstExperience();
          })
      }

      // ── 合规页脚 ──
      ComplianceFooter({ fontSize: Theme.FONT_CAPTION, textColor: Theme.MOON_MUTED, showDivider: false })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
    .padding({ top: 0, bottom: Theme.SAFE_BOTTOM })

      // 顶部渐变遮罩（消除状态栏硬边）
      Column()
        .width('100%')
        .height(Theme.SAFE_TOP + 64)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#0A0E1C', 0], ['rgba(15,15,35,0)', 1]]
        })
        .hitTestBehavior(HitTestMode.Transparent)
        .position({ x: 0, y: 0 })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建单个问心选项卡片
   */
  @Builder
  buildHeartOption(option: HeartOption, index: number) {
    Row() {
      Text(option.emoji)
        .fontSize(22)
        .margin({ right: Theme.SPACE_MD })

      Text(option.label)
        .fontSize(Theme.FONT_BODY)
        .fontColor(this.selectedIndex === index ? Theme.TEXT_PRIMARY_LIGHT : Theme.MOON_MUTED)
        .fontWeight(this.selectedIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .height(64)
    .padding({ left: Theme.SPACE_LG, right: Theme.SPACE_LG })
    .backgroundColor(this.selectedIndex === index ? Theme.BG_CARD_LIGHTER : Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({
      width: this.selectedIndex === index ? 2 : 0,
      color: this.selectedIndex === index ? Theme.GOLD_AMBER : Color.Transparent,
      style: BorderStyle.Solid,
    })
    .onClick(() => {
      this.selectedIndex = index;
    })
    .animation({
      duration: 200,
      curve: Curve.EaseOut,
    })
  }

  /**
   * 确认选择，跳转到抽牌页面
   */
  private onConfirm(): void {
    if (this.selectedIndex < 0 || this.isTransitioning) {
      return;
    }
    this.isTransitioning = true;

    const option: HeartOption = HEART_OPTIONS[this.selectedIndex];
    const routeParams: CardDrawRouteParams = {
      entryMode: this.entryMode,
      spreadType: 'SINGLE',
      heartOptionIndex: option.index,
      emotionTag: option.emotionTag,
      questionText: option.label,
    };

    const routeOptions: router.RouterOptions = {
      url: Routes.CARD_DRAW,
      params: routeParams,
    };

    try {
      router.pushUrl(routeOptions).catch((_err: Error) => {
        this.getUIContext().getPromptAction().showToast({ message: '页面跳转失败，请重试' });
      });
    } catch (_err) {
      this.getUIContext().getPromptAction().showToast({ message: '页面跳转失败，请重试' });
    } finally {
      this.isTransitioning = false;
    }
  }

  /**
   * 首次体验跳过：标记完成并进入首页
   */
  private async skipFirstExperience(): Promise<void> {
    try {
      await AppStateStore.completeFirstExperience(getContext(this));
    } catch (err) {
      // 写入失败不假成功，但仍允许用户继续抽牌（不阻断当前页面）
      // 用 toast 提示，不跳转
      try {
        this.getUIContext().getPromptAction().showToast({ message: '暂时无法跳过，请稍后再试' });
      } catch (_toastErr) {
        // ignore
      }
      return;
    }
    // 写入成功后 replaceUrl 到 HomePage
    try {
      const routeOptions: router.RouterOptions = {
        url: Routes.MAIN_FRAME,
      };
      router.replaceUrl(routeOptions).catch((_err: Error) => {
        try {
          this.getUIContext().getPromptAction().showToast({ message: '页面跳转失败，请重试' });
        } catch (_toastErr2) {
          // ignore
        }
      });
    } catch (err) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: '页面跳转失败，请重试' });
      } catch (_toastErr3) {
        // ignore
      }
    }
  }
}

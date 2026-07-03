import { router } from '@kit.ArkUI';
import { Theme } from '../../common/Theme';
import { Routes } from '../../common/Routes';
import { AppBackButton } from '../../components/AppBackButton';
import { ComplianceFooter } from '../../components/ComplianceFooter';
import { DailyRitualState } from '../model/DailyRitualState';
import { DailyRitualStore } from '../service/DailyRitualStore';
import { DailyReflection, ReflectionChoice } from '../model/DailyReflection';
import { EveningReflectionCard } from '../components/EveningReflectionCard';
import { SafeUiActions } from '../../common/SafeUiActions';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'DailyReflectionPage';

/**
 * 月湖回望页（DAILY-7）
 *
 * 承载 EveningReflectionCard，处理：
 *   - 读取今日 DailyRitualState（判断是否已有回望，回看模式预选）；
 *   - 主动确认保存 → DailyRitualStore.saveEveningReflection；
 *   - 和星澜说一句 → 跳转 XinglanChatPage；
 *   - 今天到这里 → 不保存，直接返回。
 *
 * 视觉：B「月湖映心」（湖底深色 + 顶部月光光晕 + 圆润圆角）。
 *
 * 规则保护（V2 计划 5.4 / AGENTS.md）：
 *   - 不强制晚上才能进入（页面不做任何时间判断，白天进入同样可用）；
 *   - 不自动通知；
 *   - 不要求填写长文本；
 *   - 用户可直接「今天到这里」结束，不保存；
 *   - 只有主动点「保存这次回望」才写入 eveningReflection；
 *   - 不保存完整聊天、不做心理推断；
 *   - 「今天有点难」不标记为失败。
 *
 * 不修改：DailyRitualStore 规则、EmotionStarStorage、抽牌算法、BGM、星历规则。
 * 不使用 any / as any / @ts-ignore。
 */
@Entry
@Component
struct DailyReflectionPage {
  @State private loading: boolean = true;
  @State private reduceMotion: boolean = false;
  @State private state: DailyRitualState | null = null;
  /** 是否已有保存过的回望（回看模式） */
  @State private hasExisting: boolean = false;
  /** 已保存的回望选项 */
  @State private existingChoice: ReflectionChoice = ReflectionChoice.SMALL_THING;

  async aboutToAppear(): Promise<void> {
    // 读取减少动态效果设置（与 DailyLightPage 同一来源）
    const stored: boolean | undefined = AppStorage.get<boolean>('reduceMotion');
    this.reduceMotion = stored === true;

    try {
      const ctx: Context = getContext(this);
      const state: DailyRitualState = await DailyRitualStore.getTodayState(ctx);
      this.state = state;
      if (state.eveningReflection !== undefined) {
        this.hasExisting = true;
        this.existingChoice = state.eveningReflection.choice;
      }
    } catch (_err) {
      hilog.warn(0x0000, TAG, 'load today state failed');
    }
    this.loading = false;
  }

  /**
   * 主动确认保存回望。
   * 仅在用户点「保存这次回望」时调用，写入 eveningReflection。
   * 不保存完整聊天、不做心理推断。
   * 保存成功后温和返回（短暂 toast 后 router.back）。
   */
  private async handleSave(choice: ReflectionChoice): Promise<void> {
    if (this.state === null) {
      return;
    }
    const ctx: Context = getContext(this);
    const reflection: DailyReflection = {
      choice: choice,
      createdAt: Date.now()
    };
    try {
      const newState: DailyRitualState = await DailyRitualStore.saveEveningReflection(
        this.state,
        reflection,
        ctx
      );
      this.state = newState;
      this.hasExisting = true;
      this.existingChoice = choice;
      SafeUiActions.safeToast('已保存今天的回望');
      // 保存后温和返回，让用户看到 toast
      setTimeout(() => {
        this.safeBack();
      }, 700);
    } catch (_err) {
      hilog.warn(0x0000, TAG, 'save evening reflection failed');
      SafeUiActions.safeToast('暂时没能保存，可以稍后再试');
    }
  }

  /**
   * 和星澜说一句：跳转星澜聊天页。
   * 路由跳转遵循 ArkTS 规则：先声明 RouterOptions，try/catch 包裹。
   * 不携带微光上下文（本轮不修改 XinglanChatPage 参数解析）。
   */
  private handleChatWithXinglan(): void {
    try {
      const options: router.RouterOptions = {
        url: Routes.XINGLAN_CHAT
      };
      router.pushUrl(options);
    } catch (_err) {
      hilog.warn(0x0000, TAG, 'navigate to xinglan chat failed');
      SafeUiActions.safeToast('暂时没能打开星澜聊天，请稍后再试');
    }
  }

  /**
   * 今天到这里：不保存，直接结束返回。
   */
  private handleDone(): void {
    this.safeBack();
  }

  /**
   * 安全返回：优先 router.back()，失败走 MAIN_FRAME 兜底。
   */
  private safeBack(): void {
    try {
      router.back();
    } catch (_err) {
      try {
        const options: router.RouterOptions = {
          url: Routes.MAIN_FRAME
        };
        router.replaceUrl(options);
      } catch (_e) {
        hilog.warn(0x0000, TAG, 'safe back failed');
      }
    }
  }

  build() {
    Stack() {
      // ── B 月湖映心底色（最深湖底）──
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2B_BG_BASE)

      // ── 顶部月光光晕（B 方案极淡金色渐变）──
      Column()
        .width('100%')
        .height(280)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['rgba(212,172,77,0.05)', 0.0],
            ['rgba(6,11,26,0)', 0.7]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      // ── 内容滚动区 ──
      Scroll() {
        Column({ space: Theme.V2_SPACE_LG }) {
          // 顶部安全区 + 返回按钮
          Row() {
            AppBackButton({ fallbackUrl: Routes.MAIN_FRAME })
          }
          .width('100%')
          .padding({ top: Theme.SAFE_TOP })

          if (this.loading) {
            Text('正在准备回望…')
              .fontSize(Theme.V2B_FONT_BODY)
              .fontColor(Theme.V2B_TEXT_SECONDARY)
              .padding({ top: Theme.V2_SPACE_2XL })
          } else {
            // 月湖回望卡
            EveningReflectionCard({
              reduceMotion: this.reduceMotion,
              hasExisting: this.hasExisting,
              existingChoice: this.existingChoice,
              onSave: (choice: ReflectionChoice) => {
                this.handleSave(choice);
              },
              onChatWithXinglan: () => {
                this.handleChatWithXinglan();
              },
              onDone: () => {
                this.handleDone();
              }
            })

            // 温柔提示：不强制晚上、不保存完整对话
            Text('白天也可以回望。不保存完整对话，只记录你选的这一刻。')
              .fontSize(Theme.V2B_FONT_DISCLAIMER)
              .fontColor(Theme.V2B_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .lineHeight(18)
              .opacity(0.7)
              .width('82%')
              .margin({ top: Theme.V2_SPACE_SM })

            ComplianceFooter({
              fontSize: Theme.V2B_FONT_DISCLAIMER,
              textColor: Theme.V2B_TEXT_SECONDARY,
              showDivider: true
            })
          }
        }
        .width('100%')
        .padding({
          left: Theme.SPACE_SCREEN_PAD,
          right: Theme.SPACE_SCREEN_PAD,
          bottom: Theme.SAFE_BOTTOM + 40
        })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}

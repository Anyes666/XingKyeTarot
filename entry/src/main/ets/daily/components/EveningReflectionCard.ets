import { Theme } from '../../common/Theme';
import { ReflectionChoice } from '../model/DailyReflection';

/**
 * 月湖回望快捷选项配置
 *
 * 文案来自 V2 详细开发计划第 5.4 节，不预测未来、不承诺复合、不替用户决定。
 * isHard=true 对应「今天有点难」，展示安慰文案而非积极变化文案，
 * 不将「今天很难」标记为失败。
 */
interface ReflectionOption {
  choice: ReflectionChoice;
  label: string;
  isHard: boolean;
}

const REFLECTION_OPTIONS: ReflectionOption[] = [
  { choice: ReflectionChoice.SMALL_THING, label: '我完成了一件小事', isHard: false },
  { choice: ReflectionChoice.BOUNDARY, label: '我保护了一次自己的边界', isHard: false },
  { choice: ReflectionChoice.REST, label: '我让自己休息了一会儿', isHard: false },
  { choice: ReflectionChoice.HARD_TO_SAY, label: '今天有点难，暂时说不出来', isHard: true }
];

/**
 * 月湖回望卡（DAILY-7）
 *
 * 用途：为已完成今日星页的用户提供一次可选、可跳过的日末复盘。
 *       用户选一个快捷选项 → 看到对应反馈 → 主动确认才保存到 DailyRitualStore.eveningReflection。
 *
 * 视觉：B「月湖映心」
 *   - 湖中石板底色（V2B_BG_CARD）+ 顶部极淡月光光晕；
 *   - 烫金细线仅在小标题与按钮文字点缀，不铺大面积金；
 *   - 圆角倾向圆润（V2B_RADIUS_CARD / V2B_RADIUS_BTN / V2B_RADIUS_CHIP）；
 *   - 主字用月光白（V2B_TEXT_PRIMARY），副字用水雾灰（V2B_TEXT_SECONDARY），
 *     强调用湖面月光（V2B_GOLD_RIPPLE）。
 *
 * 规则保护（V2 计划 5.4 / AGENTS.md）：
 *   - 不强制晚上才能进入（入口由父页面控制，本卡不做时间判断）；
 *   - 不自动通知；
 *   - 不要求填写长文本（只有四个快捷选项，无输入框）；
 *   - 用户可直接「今天到这里」结束，不保存；
 *   - 只有主动点「保存这次回望」才写入 eveningReflection；
 *   - 不保存完整聊天、不做心理推断；
 *   - 「今天有点难」展示安慰文案，不标记为失败。
 *
 * 数据：通过 onSave 回调把选中的 ReflectionChoice 交给页面，
 *       页面调用 DailyRitualStore.saveEveningReflection。
 *       本组件不直接读写存储。
 *
 * 不修改：DailyRitualStore 规则、EmotionStarStorage、抽牌算法、BGM。
 * 不使用 any / as any / @ts-ignore。
 */
@Component
export struct EveningReflectionCard {
  /** 减少动态效果（淡入降级） */
  @Prop reduceMotion: boolean = false;
  /** 是否已有保存过的回望（回看模式：预选并允许更新） */
  @Prop hasExisting: boolean = false;
  /** 已保存的回望选项（hasExisting=true 时生效） */
  @Prop existingChoice: ReflectionChoice = ReflectionChoice.SMALL_THING;
  /** 「保存这次回望」回调，传回用户选中的选项 */
  onSave: (choice: ReflectionChoice) => void = () => {};
  /** 「和星澜说一句」回调（跳转星澜聊天页） */
  onChatWithXinglan: () => void = () => {};
  /** 「今天到这里」回调（不保存，直接结束） */
  onDone: () => void = () => {};

  /** 当前选中的选项（hasSelected=false 时无意义） */
  @State private selectedChoice: ReflectionChoice = ReflectionChoice.SMALL_THING;
  /** 是否已选中任一选项（控制反馈区与操作区的显隐） */
  @State private hasSelected: boolean = false;
  /** 卡片渐入 opacity */
  @State private cardOpacity: number = 0;
  /** 反馈区渐入 opacity */
  @State private feedbackOpacity: number = 0;

  // 按压态（每个按钮独立，避免共用一个状态互相影响）
  @State private savePressed: boolean = false;
  @State private chatPressed: boolean = false;
  @State private donePressed: boolean = false;

  aboutToAppear(): void {
    // 回看模式：预选已保存的回望，直接展示反馈与操作区
    if (this.hasExisting) {
      this.selectedChoice = this.existingChoice;
      this.hasSelected = true;
      this.feedbackOpacity = 1.0;
    }
    if (this.reduceMotion) {
      this.cardOpacity = 1.0;
    } else {
      // 极短淡入（150ms），保持月光感，不弹跳
      setTimeout(() => {
        this.cardOpacity = 1.0;
      }, 40);
    }
  }

  build() {
    Column() {
      // ── 顶部月光光晕（B 方案极淡金色径向渐变）──
      Column()
        .width('100%')
        .height(120)
        .radialGradient({
          center: ['50%', '18%'],
          radius: '70%',
          colors: [
            ['rgba(212,172,77,0.06)', 0.0],
            ['rgba(212,172,77,0.018)', 0.58],
            ['rgba(6,11,26,0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      // 「月湖回望」小标题
      Text('月湖回望')
        .fontSize(Theme.V2B_FONT_CAPTION)
        .fontColor(Theme.V2B_GOLD_CORE)
        .letterSpacing(2)
        .margin({ top: Theme.V2_SPACE_LG })

      // 烫金细线分隔
      Row()
        .width(36)
        .height(1)
        .backgroundColor('rgba(212,172,77,0.32)')
        .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_MD })

      // 引导标题（V2 计划 5.4 原文案）
      Text('今晚，要回看一下今天吗？')
        .fontSize(Theme.V2B_FONT_SUBTITLE)
        .fontColor(Theme.V2B_TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .lineHeight(28)
        .margin({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD })

      // 主问题（V2 计划 5.4 原文案）
      Text('今天哪一刻，你有一点站回自己这边？')
        .fontSize(Theme.V2B_FONT_LEAD)
        .fontColor(Theme.V2B_GOLD_RIPPLE)
        .textAlign(TextAlign.Center)
        .lineHeight(26)
        .margin({
          top: Theme.V2_SPACE_LG,
          left: Theme.V2_SPACE_LG,
          right: Theme.V2_SPACE_LG
        })

      // ── 四个快捷选项（内联 Chip，纵向列表）──
      Column({ space: Theme.V2_SPACE_SM }) {
        ForEach(REFLECTION_OPTIONS, (opt: ReflectionOption) => {
          Text(opt.label)
            .fontSize(Theme.V2B_FONT_BODY)
            .fontColor(this.isSelected(opt.choice) ? Theme.V2B_GOLD_RIPPLE : Theme.V2B_TEXT_PRIMARY)
            .fontWeight(this.isSelected(opt.choice) ? FontWeight.Medium : FontWeight.Normal)
            .textAlign(TextAlign.Center)
            .width('100%')
            .height(46)
            .borderRadius(Theme.V2B_RADIUS_CHIP)
            .backgroundColor(
              this.isSelected(opt.choice) ? 'rgba(212,172,77,0.12)' : 'rgba(22,32,72,0.45)'
            )
            .border({
              width: 1,
              color: this.isSelected(opt.choice) ? 'rgba(212,172,77,0.42)' : 'rgba(255,255,255,0.06)'
            })
            .accessibilityGroup(true)
            .accessibilityText(`回望选项：${opt.label}`)
            .accessibilityLevel('yes')
            .onClick(() => {
              this.selectedChoice = opt.choice;
              this.hasSelected = true;
              // 反馈区淡入
              if (this.reduceMotion) {
                this.feedbackOpacity = 1.0;
              } else {
                this.feedbackOpacity = 0.0;
                setTimeout(() => {
                  this.feedbackOpacity = 1.0;
                }, 30);
              }
            })
        }, (opt: ReflectionOption) => opt.choice)
      }
      .width('100%')
      .margin({
        top: Theme.V2_SPACE_LG,
        left: Theme.V2_SPACE_LG,
        right: Theme.V2_SPACE_LG
      })

      // ── 反馈文案（选中后展示）──
      if (this.hasSelected) {
        this.BuildReflectionFeedback()
      }

      // ── 三个操作按钮（选中后展示）──
      if (this.hasSelected) {
        this.BuildActions()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Theme.V2B_BG_CARD)
    .borderRadius(Theme.V2B_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(212,172,77,0.18)' })
    .shadow(Theme.V2B_SHADOW_CARD)
    .clip(true)
    .opacity(this.cardOpacity)
    .animation({ duration: this.reduceMotion ? 0 : 180, curve: Theme.V2_EASE_OUT })
  }

  /**
   * 判断某选项是否为当前选中态。
   */
  private isSelected(choice: ReflectionChoice): boolean {
    return this.hasSelected && this.selectedChoice === choice;
  }

  /**
   * 判断某选项是否属于「今天有点难」。
   * isHard=true 时展示安慰文案，不标记为失败。
   */
  private isHardChoice(choice: ReflectionChoice): boolean {
    return choice === ReflectionChoice.HARD_TO_SAY;
  }

  /**
   * 反馈文案区：根据选中选项展示「积极变化」或「今天仍然很难」文案。
   * 文案来自 V2 计划 5.4 节，不预测未来、不替用户决定。
   */
  @Builder
  BuildReflectionFeedback(): void {
    Column() {
      // 分隔细线
      Row()
        .width(28)
        .height(1)
        .backgroundColor('rgba(212,172,77,0.22)')
        .margin({ top: Theme.V2_SPACE_LG, bottom: Theme.V2_SPACE_SM })

      if (this.isHardChoice(this.selectedChoice)) {
        // 今天仍然很难（V2 计划 5.4 原文案）
        Text('今天没有轻松下来，也没有关系。')
          .fontSize(Theme.V2B_FONT_BODY)
          .fontColor(Theme.V2B_TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .lineHeight(24)

        Text('一颗星不只记录好心情，')
          .fontSize(Theme.V2B_FONT_CAPTION)
          .fontColor(Theme.V2B_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(22)
          .margin({ top: Theme.V2_SPACE_2XS })

        Text('也记录你认真走过的这一天。')
          .fontSize(Theme.V2B_FONT_CAPTION)
          .fontColor(Theme.V2B_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(22)
      } else {
        // 积极变化（V2 计划 5.4 原文案）
        Text('这一点变化值得被记住。')
          .fontSize(Theme.V2B_FONT_BODY)
          .fontColor(Theme.V2B_TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .lineHeight(24)

        Text('不是因为今天变得完美，')
          .fontSize(Theme.V2B_FONT_CAPTION)
          .fontColor(Theme.V2B_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(22)
          .margin({ top: Theme.V2_SPACE_2XS })

        Text('而是你在某一刻照顾了自己。')
          .fontSize(Theme.V2B_FONT_CAPTION)
          .fontColor(Theme.V2B_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(22)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG })
    .opacity(this.feedbackOpacity)
    .animation({ duration: this.reduceMotion ? 0 : 220, curve: Theme.V2_EASE_OUT })
  }

  /**
   * 三个操作按钮（V2 计划 5.4 操作区原文案）：
   *   1. 保存这次回望（主按钮，主动确认才保存）；
   *   2. 和星澜说一句（次按钮，跳转星澜聊天页）；
   *   3. 今天到这里（文字入口，不保存直接结束）。
   */
  @Builder
  BuildActions(): void {
    Column({ space: Theme.V2_SPACE_SM }) {
      // 主按钮：保存这次回望
      Text(this.hasExisting ? '更新这次回望' : '保存这次回望')
        .fontSize(Theme.V2B_FONT_BODY)
        .fontColor(Theme.V2B_GOLD_RIPPLE)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(46)
        .borderRadius(Theme.V2B_RADIUS_BTN)
        .backgroundColor('rgba(212,172,77,0.10)')
        .border({ width: 1, color: 'rgba(212,172,77,0.32)' })
        .scale({
          x: this.savePressed ? Theme.PRESS_SCALE : 1.0,
          y: this.savePressed ? Theme.PRESS_SCALE : 1.0
        })
        .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
        .margin({ top: Theme.V2_SPACE_LG })
        .accessibilityGroup(true)
        .accessibilityText(this.hasExisting ? '更新今天的回望' : '保存今天的回望')
        .accessibilityLevel('yes')
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.savePressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.savePressed = false;
          }
        })
        .onClick(() => {
          this.onSave(this.selectedChoice);
        })

      // 次按钮：和星澜说一句
      Text('和星澜说一句')
        .fontSize(Theme.V2B_FONT_CAPTION)
        .fontColor(Theme.V2B_TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(42)
        .borderRadius(Theme.V2B_RADIUS_BTN)
        .backgroundColor('rgba(10,13,26,0.0)')
        .border({ width: 1, color: 'rgba(224,205,149,0.18)' })
        .scale({
          x: this.chatPressed ? Theme.PRESS_SCALE : 1.0,
          y: this.chatPressed ? Theme.PRESS_SCALE : 1.0
        })
        .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
        .accessibilityGroup(true)
        .accessibilityText('和星澜说一句，跳转星澜聊天页')
        .accessibilityLevel('yes')
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.chatPressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.chatPressed = false;
          }
        })
        .onClick(() => {
          this.onChatWithXinglan();
        })

      // 文字入口：今天到这里（不保存，直接结束）
      Text('今天到这里')
        .fontSize(Theme.V2B_FONT_CAPTION)
        .fontColor(Theme.V2B_TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(38)
        .borderRadius(Theme.V2B_RADIUS_BTN)
        .backgroundColor('rgba(10,13,26,0.0)')
        .scale({
          x: this.donePressed ? Theme.PRESS_SCALE : 1.0,
          y: this.donePressed ? Theme.PRESS_SCALE : 1.0
        })
        .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
        .margin({ top: Theme.V2_SPACE_2XS })
        .accessibilityGroup(true)
        .accessibilityText('今天到这里，结束回望，不保存')
        .accessibilityLevel('yes')
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.donePressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.donePressed = false;
          }
        })
        .onClick(() => {
          this.onDone();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({
      left: Theme.V2_SPACE_LG,
      right: Theme.V2_SPACE_LG,
      bottom: Theme.V2_SPACE_LG
    })
    .opacity(this.feedbackOpacity)
    .animation({ duration: this.reduceMotion ? 0 : 220, curve: Theme.V2_EASE_OUT })
  }
}

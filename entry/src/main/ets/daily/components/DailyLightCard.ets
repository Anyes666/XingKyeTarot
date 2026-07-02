import { Theme } from '../../common/Theme';

/**
 * 今日星页三层内容卡（DAILY-4）
 *
 * 视觉：C「星钥之书」
 *   - 书页底色 + 烫金细线分隔；
 *   - 三层标题用烫金小字，正文用书页白；
 *   - 金色仅作标题、细线、按钮文字点缀。
 *
 * 渐显动效：
 *   - 今日一句 / 今日观察 / 今日微小行动 逐层渐显；
 *   - 每层间隔 200ms（在 180-260ms 范围内）；
 *   - 总动效 ≈ 400ms + 单层淡入 300ms ≈ 700ms（不超 1.2 秒）；
 *   - reduceMotion=true 时三层同时直接显示，无动效。
 *
 * 交互按钮：
 *   - 「这句话不太适合今天」：换一次，每天最多一次；
 *   - 「把这一页带进今天」：确认完成；
 *   - 回看模式（reviewMode=true）隐藏两个操作按钮，只展示内容；
 *   - 所有按钮圆角统一 V2C_RADIUS_BTN，不变形。
 *
 * 无障碍：
 *   - 三层内容分别 accessibilityGroup；
 *   - 按钮朗读文案 + 状态。
 *
 * 不修改业务逻辑、路由、数据结构、BGM。
 */
@Component
export struct DailyLightCard {
  /** 今日一句 */
  @Prop mainLine: string = '';
  /** 今日观察 */
  @Prop observation: string = '';
  /** 今日微小行动 */
  @Prop microAction: string = '';
  /** 减少动态效果降级 */
  @Prop reduceMotion: boolean = false;
  /** 换一次按钮是否已禁用（已换过一次） */
  @Prop replaceButtonDisabled: boolean = false;
  /** 回看模式：隐藏操作按钮 */
  @Prop reviewMode: boolean = false;
  /** 换一次回调 */
  onReplace: () => void = () => {};
  /** 确认完成回调 */
  onConfirm: () => void = () => {};

  @State private layer1Visible: boolean = false;
  @State private layer2Visible: boolean = false;
  @State private layer3Visible: boolean = false;
  @State private replacePressed: boolean = false;
  @State private confirmPressed: boolean = false;

  aboutToAppear(): void {
    this.startLayerReveal();
  }

  private startLayerReveal(): void {
    if (this.reduceMotion) {
      this.layer1Visible = true;
      this.layer2Visible = true;
      this.layer3Visible = true;
      return;
    }
    this.layer1Visible = true;
    setTimeout(() => {
      this.layer2Visible = true;
    }, 200);
    setTimeout(() => {
      this.layer3Visible = true;
    }, 400);
  }

  build() {
    Column({ space: Theme.V2_SPACE_LG }) {
      // ── 三层内容 ──
      this.BuildLayer('今日一句', this.mainLine, this.layer1Visible)
      this.BuildDivider()
      this.BuildLayer('今日观察', this.observation, this.layer2Visible)
      this.BuildDivider()
      this.BuildLayer('今日微小行动', this.microAction, this.layer3Visible)

      // ── 操作按钮（回看模式隐藏）──
      if (!this.reviewMode) {
        this.BuildReplaceButton()
        this.BuildConfirmButton()
      }
    }
    .width('100%')
    .padding({
      top: Theme.V2_SPACE_LG,
      bottom: Theme.V2_SPACE_LG,
      left: Theme.V2_SPACE_MD_B,
      right: Theme.V2_SPACE_MD_B
    })
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .backgroundColor('rgba(18,24,54,0.55)')
    .border({ width: 1, color: 'rgba(197,160,80,0.18)' })
  }

  @Builder
  BuildLayer(label: string, body: string, visible: boolean): void {
    Column() {
      Text(label)
        .fontSize(Theme.V2C_FONT_CAPTION)
        .fontColor(Theme.V2C_GOLD_GILT)
        .letterSpacing(1)
        .opacity(visible ? 1.0 : 0.0)

      Text(body)
        .fontSize(Theme.V2C_FONT_LEAD)
        .fontColor(Theme.V2C_TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .lineHeight(28)
        .textAlign(TextAlign.Center)
        .margin({ top: Theme.V2_SPACE_XS })
        .opacity(visible ? 1.0 : 0.0)
        .translate({ y: visible ? 0 : 8 })
        .animation({
          duration: this.reduceMotion ? 0 : 300,
          curve: Theme.V2_EASE_OUT
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_SM })
    .accessibilityGroup(true)
    .accessibilityText(`${label}：${body}`)
    .accessibilityLevel('yes')
  }

  @Builder
  BuildDivider(): void {
    Row()
      .width(36)
      .height(1)
      .backgroundColor('rgba(197,160,80,0.20)')
  }

  @Builder
  BuildReplaceButton(): void {
    Text(this.replaceButtonDisabled ? '今天已换过一次' : '这句话不太适合今天')
      .fontSize(Theme.V2C_FONT_CAPTION)
      .fontColor(this.replaceButtonDisabled ? Theme.V2_STATE_DISABLED_TEXT : Theme.V2C_TEXT_SECONDARY)
      .textAlign(TextAlign.Center)
      .width('100%')
      .height(42)
      .borderRadius(Theme.V2C_RADIUS_BTN)
      .backgroundColor('rgba(10,13,26,0.0)')
      .border({
        width: 1,
        color: this.replaceButtonDisabled ? 'rgba(138,132,152,0.18)' : 'rgba(224,205,149,0.20)'
      })
      .scale({
        x: this.replacePressed && !this.replaceButtonDisabled ? Theme.PRESS_SCALE : 1.0,
        y: this.replacePressed && !this.replaceButtonDisabled ? Theme.PRESS_SCALE : 1.0
      })
      .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
      .margin({ top: Theme.V2_SPACE_SM })
      .accessibilityGroup(true)
      .accessibilityText(
        this.replaceButtonDisabled ? '今天已换过一次，按钮已禁用' : '这句话不太适合今天，换一个角度'
      )
      .accessibilityLevel(this.replaceButtonDisabled ? 'no' : 'yes')
      .onTouch((event: TouchEvent) => {
        if (this.replaceButtonDisabled) {
          return;
        }
        if (event.type === TouchType.Down) {
          this.replacePressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.replacePressed = false;
        }
      })
      .onClick(() => {
        if (this.replaceButtonDisabled) {
          return;
        }
        this.onReplace();
      })
  }

  @Builder
  BuildConfirmButton(): void {
    Text('把这一页带进今天')
      .fontSize(Theme.V2C_FONT_BODY)
      .fontColor(Theme.V2C_GOLD_GILT_SOFT)
      .fontWeight(FontWeight.Medium)
      .textAlign(TextAlign.Center)
      .width('100%')
      .height(48)
      .borderRadius(Theme.V2C_RADIUS_BTN)
      .backgroundColor('rgba(197,160,80,0.10)')
      .border({ width: 1, color: 'rgba(197,160,80,0.34)' })
      .scale({
        x: this.confirmPressed ? Theme.PRESS_SCALE : 1.0,
        y: this.confirmPressed ? Theme.PRESS_SCALE : 1.0
      })
      .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
      .margin({ top: Theme.V2_SPACE_SM })
      .accessibilityGroup(true)
      .accessibilityText('把这一页带进今天，确认完成今日星页')
      .accessibilityLevel('yes')
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.confirmPressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.confirmPressed = false;
        }
      })
      .onClick(() => {
        this.onConfirm();
      })
  }
}

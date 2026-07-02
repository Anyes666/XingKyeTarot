import { Theme } from '../../common/Theme';

/**
 * 星钥开页组件（DAILY-4）
 *
 * 视觉：C「星钥之书」+ B「月湖映心」融入
 *   - 星钥符号 ✦，未展开时柔金半透，展开后烫金亮；
 *   - 顶部一道极淡月光渐变（B 融入）；
 *   - 金色仅作符号与文字点缀，不铺大面积。
 *
 * 交互：
 *   - 长按 500ms 触发 onRevealed（主交互）；
 *   - 普通点击同样触发 onRevealed（无障碍替代，TalkBack 双击即可）；
 *   - 已展开后忽略再次触发；
 *   - reduceMotion=true 时无展开动效，直接呈现展开态。
 *
 * 无障碍：
 *   - accessibilityGroup 合并；
 *   - accessibilityText 朗读「星钥，双击翻开今日星页」/「今日星页已展开」；
 *   - accessibilityLevel yes。
 *
 * 不修改业务逻辑、路由、数据结构、BGM。
 */
@Component
export struct StarKeyReveal {
  /** 是否已展开（由父组件控制） */
  @Prop revealed: boolean = false;
  /** 减少动态效果降级 */
  @Prop reduceMotion: boolean = false;
  /** 展开回调（长按或点击均触发，父组件需保证幂等） */
  onRevealed: () => void = () => {};

  @State private pressed: boolean = false;

  build() {
    Column() {
      // 星钥符号
      Text('✦')
        .fontSize(this.revealed ? 58 : 50)
        .fontColor(this.revealed ? Theme.V2C_GOLD_GILT : 'rgba(197,160,80,0.55)')
        .scale({
          x: this.revealed ? 1.0 : 0.92,
          y: this.revealed ? 1.0 : 0.92
        })
        .opacity(this.revealed ? 1.0 : 0.72)
        .animation({
          duration: this.reduceMotion ? 0 : 480,
          curve: Theme.V2_EASE_OUT
        })

      // 状态文案
      if (!this.revealed) {
        Text('长按星钥，翻开今日')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .margin({ top: Theme.V2_SPACE_MD })

        Text('或轻点此处（无障碍）')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ top: Theme.V2_SPACE_XS })
      } else {
        Text('今日星页已展开')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .margin({ top: Theme.V2_SPACE_MD })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({
      top: Theme.V2_SPACE_XL,
      bottom: Theme.V2_SPACE_XL,
      left: Theme.V2_SPACE_LG,
      right: Theme.V2_SPACE_LG
    })
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .backgroundColor('rgba(18,24,54,0.50)')
    .border({ width: 1, color: 'rgba(197,160,80,0.18)' })
    .scale({
      x: this.pressed ? Theme.PRESS_SCALE : 1.0,
      y: this.pressed ? Theme.PRESS_SCALE : 1.0
    })
    .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
    .accessibilityGroup(true)
    .accessibilityText(this.revealed ? '今日星页已展开' : '星钥，双击翻开今日星页')
    .accessibilityLevel('yes')
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => {
          if (this.revealed) {
            return;
          }
          this.onRevealed();
        })
    )
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressed = false;
      }
    })
    .onClick(() => {
      if (this.revealed) {
        return;
      }
      this.onRevealed();
    })
  }
}

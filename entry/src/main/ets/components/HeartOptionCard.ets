import { Theme } from '../common/Theme';

/**
 * HeartOptionCard — 问心选项卡（C 方案 #11 问心用）
 *
 * 功能：图标 + label + description + 选中态（金色边框 + 金色底色）
 * 交互：按压态 scale(0.97) + onTouch
 *
 * 使用示例：
 *   HeartOptionCard({
 *     icon: '🌧',
 *     label: '今天有点难过',
 *     description: '心里沉甸甸的，说不上来为什么',
 *     selected: this.selectedIndex === index,
 *     onPress: () => { this.selectedIndex = index; }
 *   })
 */
@Component
export struct HeartOptionCard {
  /** 图标符号 */
  @Prop icon: string = '';
  /** 选项标签 */
  @Prop label: string = '';
  /** 选项描述 */
  @Prop description: string = '';
  /** 是否选中 */
  @Prop selected: boolean = false;
  /** 按压回调 */
  onPress: () => void = () => {};
  /** 按压态 */
  @State private pressed: boolean = false;

  build() {
    Stack() {
      Row()
        .width(1)
        .height('62%')
        .backgroundColor(this.selected ? 'rgba(197,160,80,0.20)' : 'rgba(139,134,155,0.10)')
        .position({ x: 8, y: '19%' })

      Row() {
        // 图标
        if (this.icon.length > 0) {
          Stack() {
            Text(this.icon)
              .fontSize(16)
              .fontColor(this.selected ? Theme.V2C_GOLD_GILT_SOFT : Theme.V2C_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .opacity(this.selected ? 0.78 : 0.54)
          }
          .width(34)
          .height(34)
          .borderRadius(Theme.V2C_RADIUS_CARD)
          .backgroundColor(this.selected ? 'rgba(197,160,80,0.075)' : 'rgba(10,13,26,0.26)')
          .border({ width: 1, color: this.selected ? 'rgba(197,160,80,0.22)' : 'rgba(139,134,155,0.08)' })
        }

        // 文字区
        Column() {
          Text(this.label)
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(this.selected ? Theme.V2C_GOLD_GILT_SOFT : Theme.V2C_TEXT_PRIMARY)
            .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Normal)
            .lineHeight(21)

          if (this.description.length > 0) {
            Text(this.description)
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .margin({ top: 3 })
              .lineHeight(18)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: this.icon.length > 0 ? Theme.V2_SPACE_SM : 0 })
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
      .padding({
        left: Theme.V2_SPACE_LG,
        right: Theme.V2_SPACE_LG,
        top: 13,
        bottom: 13
      })
    }
    .width('100%')
    .height(this.description.length > 0 ? 82 : 66)
    .clip(true)
    .backgroundColor(this.selected ? 'rgba(24,31,64,0.82)' : 'rgba(18,24,54,0.74)')
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({
      width: 1,
      color: this.selected ? 'rgba(197,160,80,0.30)' : 'rgba(29,35,66,0.92)',
      style: BorderStyle.Solid
    })
    .scale({
      x: this.pressed ? Theme.PRESS_SCALE : 1.0,
      y: this.pressed ? Theme.PRESS_SCALE : 1.0
    })
    .animation({
      duration: Theme.ANIM_PRESS_DURATION,
      curve: Theme.V2_EASE_OUT
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressed = false;
      }
    })
    .onClick(() => {
      this.onPress();
    })
  }
}

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
    Row() {
      // 图标
      if (this.icon.length > 0) {
        Text(this.icon)
          .fontSize(24)
          .fontColor(this.selected ? Theme.V2C_GOLD_GILT : Theme.V2C_TEXT_SECONDARY)
          .width(40)
          .textAlign(TextAlign.Center)
      }

      // 文字区
      Column() {
        Text(this.label)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(this.selected ? Theme.V2C_GOLD_GILT_SOFT : Theme.V2C_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)

        if (this.description.length > 0) {
          Text(this.description)
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .margin({ top: 2 })
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
    .padding({
      left: Theme.V2_SPACE_LG,
      right: Theme.V2_SPACE_LG,
      top: 14,
      bottom: 14
    })
    .backgroundColor(this.selected ? Theme.V2C_BG_FLOATING : Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({
      width: this.selected ? 2 : 1,
      color: this.selected ? Theme.V2C_GOLD_GILT : Theme.V2C_SPINE_LINE,
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

import { Theme } from '../common/Theme';

/**
 * DivinationEntryCard — 占卜入口卡（C 方案 #10 占卜中心用）
 *
 * 功能：图标 + 标题 + 副标题 + 箭头，点击进入对应占卜流程
 * 交互：按压态 scale(0.97) + onTouch
 *
 * 使用示例：
 *   DivinationEntryCard({
 *     icon: '◇',
 *     title: '每日一占',
 *     subtitle: '一句心事，一张星钥。',
 *     onClick: () => { this.navigateToAskHeart(); }
 *   })
 */
@Component
export struct DivinationEntryCard {
  /** 图标符号（几何符号文字） */
  @Prop icon: string = '◇';
  /** 标题 */
  @Prop title: string = '';
  /** 副标题 */
  @Prop subtitle: string = '';
  /** 点击回调 */
  onClick: () => void = () => {};
  /** 按压态索引（内部状态） */
  @State private pressed: boolean = false;

  build() {
    Row() {
      // 图标
      Text(this.icon)
        .fontSize(28)
        .fontColor(Theme.V2C_GOLD_GILT)
        .width(56)
        .textAlign(TextAlign.Center)

      // 文字区
      Column() {
        Text(this.title)
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)

        Text(this.subtitle)
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ top: 4 })
          .lineHeight(18)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: Theme.V2_SPACE_SM })

      // 箭头
      Text('›')
        .fontSize(24)
        .fontColor(Theme.V2C_GOLD_GILT)
    }
    .width('92%')
    .padding({
      left: Theme.STARKEY_CARD_PADDING_H,
      right: Theme.STARKEY_CARD_PADDING_H,
      top: Theme.STARKEY_CARD_PADDING_V,
      bottom: Theme.STARKEY_CARD_PADDING_V
    })
    .backgroundColor(Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: Theme.V2C_SPINE_LINE })
    .shadow(Theme.V2C_SHADOW_CARD)
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
      this.onClick();
    })
  }
}

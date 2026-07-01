import { Theme } from '../common/Theme';

/**
 * BoundaryReminder — 关系探索边界提醒浮层（C 方案 #14 关系探索用）
 *
 * 功能：烫金竖线 + 温柔文案，提醒用户"关系探索不判断对方心意"
 * 适用方案：C 方案（星钥之书）
 *
 * 使用示例：
 *   BoundaryReminder({ text: '关系探索不判断对方心意，只陪你看清自己的感受、期待与边界' })
 */
@Component
export struct BoundaryReminder {
  /** 提醒文案 */
  @Prop text: string = '关系探索不判断对方心意，只陪你看清自己的感受、期待与边界';
  /** 是否显示左侧烫金竖线 */
  @Prop showAccentLine: boolean = true;

  build() {
    Row() {
      // 烫金竖线（2px）
      if (this.showAccentLine) {
        Column()
          .width(2)
          .height('100%')
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .borderRadius(1)
          .margin({ right: Theme.V2_SPACE_SM })
      }

      // 文案
      Text(this.text)
        .fontSize(Theme.V2C_FONT_CAPTION)
        .fontColor(Theme.V2C_TEXT_SECONDARY)
        .lineHeight(20)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: Theme.V2_SPACE_MD,
      right: Theme.V2_SPACE_MD,
      top: Theme.V2_SPACE_SM,
      bottom: Theme.V2_SPACE_SM
    })
    .backgroundColor(Theme.V2C_BG_FLOATING)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .alignItems(VerticalAlign.Top)
  }
}

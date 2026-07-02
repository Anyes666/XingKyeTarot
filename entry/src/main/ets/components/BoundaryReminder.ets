import { Theme } from '../common/Theme';

/**
 * BoundaryReminder — 关系探索边界提醒卡（C 方案 #14 关系探索用）
 *
 * 功能：低亮书页底 + 温柔文案，提醒用户"关系探索不判断对方心意"
 * 适用方案：C 方案（星钥之书）
 *
 * 使用示例：
 *   BoundaryReminder({ text: '关系探索不判断对方心意，只陪你看清自己的感受、期待与边界' })
 */
@Component
export struct BoundaryReminder {
  /** 提醒标题 */
  @Prop title: string = '边界提醒';
  /** 提醒文案 */
  @Prop text: string = '关系探索不判断对方心意，只陪你看清自己的感受、期待与边界';
  /** 是否显示短烫金细线 */
  @Prop showAccentLine: boolean = true;

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Medium)

        Blank()

        Text('不替你决定')
          .fontSize(Theme.V2C_FONT_DISCLAIMER)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
      }
      .width('100%')
      .margin({ bottom: Theme.V2_SPACE_SM })

      if (this.showAccentLine) {
        Row()
          .width(42)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.24)
          .margin({ bottom: Theme.V2_SPACE_SM })
      }

      Text(this.text)
        .fontSize(Theme.V2C_FONT_CAPTION)
        .fontColor(Theme.V2C_TEXT_SECONDARY)
        .lineHeight(21)
        .width('100%')
    }
    .width('100%')
    .padding({
      left: Theme.V2_SPACE_LG,
      right: Theme.V2_SPACE_LG,
      top: Theme.V2_SPACE_MD,
      bottom: Theme.V2_SPACE_MD
    })
    .backgroundColor('rgba(18, 24, 54, 0.72)')
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: Theme.V2C_SPINE_LINE })
  }
}

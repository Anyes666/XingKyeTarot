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
 *     action: () => { this.navigateToAskHeart(); }
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
  action: () => void = () => {};
  /** 按压态索引（内部状态） */
  @State private pressed: boolean = false;

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [
            ['rgba(197,160,80,0.035)', 0.0],
            ['rgba(18,24,54,0.72)', 0.36],
            ['rgba(10,13,26,0.18)', 1.0]
          ]
        })

      Row()
        .width(1)
        .height('68%')
        .backgroundColor('rgba(197,160,80,0.18)')
        .position({ x: 9, y: '16%' })

      Row() {
        // 图标
        Stack() {
          Text(this.icon)
            .fontSize(23)
            .fontColor(this.selectedIconColor())
            .textAlign(TextAlign.Center)
        }
        .width(44)
        .height(44)
        .borderRadius(Theme.V2C_RADIUS_CHIP)
        .backgroundColor('rgba(10,13,26,0.42)')
        .border({ width: 1, color: 'rgba(197,160,80,0.10)' })

        // 文字区
        Column() {
          Text(this.title)
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)

          Text(this.subtitle)
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .margin({ top: 5 })
            .lineHeight(18)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: Theme.V2_SPACE_MD })

        // 箭头
        Text('›')
          .fontSize(22)
          .fontColor('rgba(224,205,149,0.42)')
          .margin({ left: Theme.V2_SPACE_XS })
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
      .padding({
        left: Theme.V2_SPACE_LG,
        right: Theme.V2_SPACE_MD,
        top: Theme.V2_SPACE_MD,
        bottom: Theme.V2_SPACE_MD
      })
    }
    .width('92%')
    .height(86)
    .clip(true)
    .backgroundColor('rgba(18,24,54,0.78)')
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197,160,80,0.14)' })
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
      this.action();
    })
  }

  private selectedIconColor(): ResourceColor {
    return this.pressed ? Theme.V2C_GOLD_GILT_SOFT : Theme.V2C_GOLD_GILT;
  }
}

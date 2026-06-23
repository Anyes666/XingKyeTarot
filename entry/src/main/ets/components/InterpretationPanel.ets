import { Theme } from '../common/Theme';

/**
 * 解读面板组件
 * 展示牌位名称、牌名、关键词列表、解读正文
 */
@Component
export struct InterpretationPanel {
  @Prop positionName: string = '';
  @Prop cardName: string = '';
  @Prop isReversed: boolean = false;
  @Prop keywords: string[] = [];
  @Prop interpretation: string = '';

  build() {
    Column() {
      // 牌位标签
      Row() {
        Text(this.positionName)
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD)
          .fontWeight(FontWeight.Bold)
          .padding({ left: Theme.SPACE_SM, right: Theme.SPACE_SM, top: 2, bottom: 2 })
          .borderRadius(Theme.RADIUS_SM)
          .border({ width: 1, color: Theme.GOLD })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: Theme.SPACE_SM })

      // 牌名 + 正逆位
      Row() {
        Text(this.cardName)
          .fontSize(Theme.FONT_SUBTITLE)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)

        if (this.isReversed) {
          Text('（逆位）')
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.DANGER_SOFT)
            .margin({ left: Theme.SPACE_SM })
        }
      }
      .width('100%')
      .margin({ bottom: Theme.SPACE_SM })

      // 关键词
      if (this.keywords.length > 0) {
        Row() {
          ForEach(this.keywords, (keyword: string, index: number) => {
            Text(keyword)
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.AURORA)
              .padding({ left: Theme.SPACE_SM, right: Theme.SPACE_SM, top: 2, bottom: 2 })
              .margin({ right: Theme.SPACE_SM })
              .borderRadius(Theme.RADIUS_SM)
              .backgroundColor('rgba(94, 215, 210, 0.1)')
          }, (keyword: string, index: number) => `${keyword}_${index}`)
        }
        .width('100%')
        .margin({ bottom: Theme.SPACE_SM })
      }

      // 解读正文
      Text(this.interpretation)
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_SECONDARY)
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.SPACE_MD)
    .backgroundColor(Theme.BG_CARD)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(216, 180, 90, 0.15)' })
  }
}

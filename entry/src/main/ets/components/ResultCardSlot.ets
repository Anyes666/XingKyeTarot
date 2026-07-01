import { Theme } from '../common/Theme';
import { TarotCardImage } from './TarotCardImage';

/**
 * ResultCardSlot — 结果页牌位卡（C 方案 #4 单牌 / #13 圣三角 / #14 关系探索用）
 *
 * 功能：位置标题 + 牌面 + 牌名 + 关键词 + 金句，垂直堆叠
 * 适用方案：C 方案（星钥之书）
 *
 * 使用示例：
 *   ResultCardSlot({
 *     positionTitle: '过去',
 *     cardId: 'major_17_star',
 *     cardName: '星星 · The Star',
 *     keywords: '希望 · 灵感 · 宁静',
 *     goldenLine: '在你以为一切都已经干涸的地方，其实还有水在流。'
 *   })
 */
@Component
export struct ResultCardSlot {
  /** 位置标题（如"过去"/"现在"/"可能的方向"） */
  @Prop positionTitle: string = '';
  /** 牌面 ID */
  @Prop cardId: string = '';
  /** 牌名 */
  @Prop cardName: string = '';
  /** 关键词 */
  @Prop keywords: string = '';
  /** 金句 */
  @Prop goldenLine: string = '';
  /** 牌面宽度（默认三牌尺寸 90x144） */
  @Prop cardWidth: number = Theme.CARD_SIZE_TRIO.width;
  /** 牌面高度 */
  @Prop cardHeight: number = Theme.CARD_SIZE_TRIO.height;
  /** 是否显示正逆位标签 */
  @Prop showPositionTag: boolean = false;
  /** 正逆位标签文字 */
  @Prop positionTagText: string = '正位';

  build() {
    Column() {
      // 位置标题
      if (this.positionTitle.length > 0) {
        Row() {
          Text(this.positionTitle)
            .fontSize(Theme.V2C_FONT_SUBTITLE)
            .fontColor(Theme.V2C_GOLD_GILT)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .margin({ bottom: Theme.V2_SPACE_MD })
      }

      // 牌面 + 右侧文字
      Row() {
        // 牌面图
        TarotCardImage({
          cardId: this.cardId,
          cardWidth: this.cardWidth,
          cardHeight: this.cardHeight
        })

        // 右侧信息
        Column() {
          // 牌名
          Text(this.cardName)
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: Theme.V2_SPACE_XS })

          // 正逆位标签
          if (this.showPositionTag) {
            Text(this.positionTagText)
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_GOLD_GILT)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(Theme.V2C_RADIUS_CHIP)
              .border({ width: 1, color: Theme.V2C_GOLD_GILT })
              .margin({ bottom: Theme.V2_SPACE_XS })
          }

          // 关键词
          if (this.keywords.length > 0) {
            Text(this.keywords)
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_GOLD_GILT)
              .margin({ bottom: Theme.V2_SPACE_SM })
          }

          // 金句
          if (this.goldenLine.length > 0) {
            Text(this.goldenLine)
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(22)
          }
        }
        .layoutWeight(1)
        .margin({ left: Theme.V2_SPACE_MD })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.V2_SPACE_LG)
    .backgroundColor(Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: Theme.V2C_SPINE_LINE })
  }
}

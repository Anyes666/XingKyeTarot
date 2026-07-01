import { Theme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { TarotCardView, CardDisplayState } from './TarotCardView';
import { DrawnCard, DivinationRecord } from '../model/DivinationRecord';

/**
 * 分享图预览组件（隐藏渲染用）
 * 尺寸 1080×1920，包含完整牌阵和解读文案，用于 componentSnapshot 截图。
 */
@Component
export struct SharePreview {
  @Prop record: DivinationRecord | null = null;

  build() {
    Column() {
      // ═══ 顶部标题 ═══
      Column() {
        Text('⭐')
          .fontSize(56)
          .fontColor(Theme.GOLD)

        Text(Constants.APP_NAME)
          .fontSize(56)
          .fontColor(Theme.GOLD)
          .fontWeight(FontWeight.Bold)
          .letterSpacing(6)
          .margin({ top: Theme.SPACE_SM })

        Text('圣三角 · 占卜结果')
          .fontSize(30)
          .fontColor(Theme.TEXT_MUTED)
          .opacity(0.7)
          .margin({ top: Theme.SPACE_SM })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ top: 60, bottom: 30 })

      Divider()
        .strokeWidth(0.5)
        .color(Theme.V2C_SPINE_LINE)
        .opacity(0.3)
        .width('80%')
        .margin({ bottom: 30 })

      // ═══ 三张牌（紧凑排列） ═══
      if (this.record) {
        Row() {
          ForEach(this.record.cards, (card: DrawnCard, index: number) => {
            Column() {
              TarotCardView({
                cardName: card.card.nameZh,
                cardImage: card.card.image,
                isReversed: card.isReversed,
                displayState: CardDisplayState.REVEALED,
                cardWidth: 140,
                cardHeight: 224
              })

              Text(card.positionName)
                .fontSize(22)
                .fontColor(Theme.GOLD)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 12 })

              Text(card.card.nameZh + (card.isReversed ? '（逆）' : ''))
                .fontSize(18)
                .fontColor(Theme.TEXT_PRIMARY)
                .margin({ top: 6 })

              Text(card.keywords.slice(0, 3).join(' · '))
                .fontSize(16)
                .fontColor(Theme.V2C_GOLD_GILT_SOFT)
                .maxLines(1)
                .margin({ top: 6 })
            }
            .width(300)
            .alignItems(HorizontalAlign.Center)
            .margin({ left: 30, right: 30 })
          }, (card: DrawnCard, index: number) => `share_card_${index}`)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Divider()
          .strokeWidth(0.5)
          .color(Theme.V2C_SPINE_LINE)
          .opacity(0.3)
          .width('80%')
          .margin({ top: 30, bottom: 24 })

        // ═══ 三张牌完整解读 ═══
        Column() {
          ForEach(this.record.cards, (card: DrawnCard, index: number) => {
            Column() {
              // 牌位标签
              Row() {
                Text(card.positionName)
                  .fontSize(20)
                  .fontColor(Theme.GOLD)
                  .fontWeight(FontWeight.Bold)
                  .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                  .borderRadius(6)
                  .border({ width: 1, color: Theme.GOLD })
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({ bottom: 10 })

              // 牌名 + 正逆位
              Row() {
                Text(card.card.nameZh)
                  .fontSize(28)
                  .fontColor(Theme.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)

                if (card.isReversed) {
                  Text('（逆位）')
                    .fontSize(20)
                    .fontColor(Theme.V2C_GOLD_GILT_SOFT)
                    .margin({ left: 8 })
                }
              }
              .width('100%')
              .margin({ bottom: 8 })

              // 关键词标签
              Row() {
                ForEach(card.keywords.slice(0, 3), (kw: string) => {
                  Text(kw)
                    .fontSize(16)
                    .fontColor(Theme.V2C_GOLD_GILT_SOFT)
                    .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                    .margin({ right: 8 })
                    .borderRadius(6)
                    .backgroundColor('rgba(94, 215, 210, 0.12)')
                }, (kw: string) => `kw_${index}_${kw}`)
              }
              .width('100%')
              .margin({ bottom: 10 })

              // 完整解读
              Text(card.interpretation)
                .fontSize(22)
                .fontColor(Theme.TEXT_SECONDARY)
                .lineHeight(34)
                .width('100%')
            }
            .width('88%')
            .padding(20)
            .backgroundColor(Theme.V2C_BG_FLOATING)
            .borderRadius(12)
            .border({ width: 1, color: Theme.V2C_SPINE_LINE })
            .margin({ bottom: 16 })
          }, (card: DrawnCard, index: number) => `interp_${index}`)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }

      Blank()

      // ═══ 底部合规声明 ═══
      Column() {
        Divider()
          .strokeWidth(0.5)
          .color(Theme.V2C_SPINE_LINE)
          .opacity(0.3)
          .width('80%')
          .margin({ bottom: 16 })

        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(22)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .opacity(0.7)
          .textAlign(TextAlign.Center)

        Text('— 星钥塔罗 —')
          .fontSize(18)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .opacity(0.5)
          .margin({ top: 8 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ bottom: 40 })
    }
    .width(1080)
    .height(1920)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [
        [Theme.V2C_BG_BASE, 0.0],
        [Theme.V2C_BG_CARD, 0.4],
        [Theme.V2C_BG_BASE, 1.0]
      ]
    })
    .border({ width: 1, color: Theme.V2C_SPINE_LINE })
  }
}

import { Theme } from '../common/Theme';

/**
 * 塔罗牌组件
 * 支持正逆位显示：逆位通过 rotation 旋转 180deg 实现，使用同一张牌图。
 *
 * 状态：
 * - idle: 显示牌背
 * - revealed: 显示牌面（正/逆）
 */
export enum CardDisplayState {
  IDLE = 'idle',
  REVEALED = 'revealed'
}

@Component
export struct TarotCardView {
  @Prop cardName: string = '';
  @Prop cardImage: string = '';
  @Prop isReversed: boolean = false;
  @Prop displayState: CardDisplayState = CardDisplayState.IDLE;
  @Prop cardWidth: number = Theme.TAROT_CARD_WIDTH;
  @Prop cardHeight: number = Theme.TAROT_CARD_HEIGHT;
  onTap?: () => void;

  build() {
    Column() {
      if (this.displayState === CardDisplayState.IDLE) {
        // 牌背
        Column() {
          Image($r('app.media.card_back'))
            .width(this.cardWidth)
            .height(this.cardHeight)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.TAROT_CARD_RADIUS)
        }
        .width(this.cardWidth)
        .height(this.cardHeight)
        .borderRadius(Theme.TAROT_CARD_RADIUS)
        .border({ width: 1, color: Theme.GOLD_DIM })
        .shadow({
          radius: 12,
          color: 'rgba(216, 180, 90, 0.15)',
          offsetY: 4
        })
      } else {
        // 牌面（带正逆位旋转）
        Column() {
          // 牌图
          Image($r('app.media.placeholder_card'))
            .width(this.cardWidth)
            .height(this.cardHeight * 0.65)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.TAROT_CARD_RADIUS, topRight: Theme.TAROT_CARD_RADIUS })

          // 牌名区域
          Column() {
            Text(this.cardName)
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            if (this.isReversed) {
              Text('逆位')
                .fontSize(10)
                .fontColor(Theme.DANGER_SOFT)
                .margin({ top: 2 })
            }
          }
          .width('100%')
          .height(this.cardHeight * 0.35)
          .justifyContent(FlexAlign.Center)
          .padding({ left: 4, right: 4 })
          .backgroundColor(Theme.BG_CARD)
          .borderRadius({ bottomLeft: Theme.TAROT_CARD_RADIUS, bottomRight: Theme.TAROT_CARD_RADIUS })
        }
        .width(this.cardWidth)
        .height(this.cardHeight)
        .borderRadius(Theme.TAROT_CARD_RADIUS)
        .border({ width: 1.5, color: Theme.GOLD })
        .shadow({
          radius: 16,
          color: 'rgba(216, 180, 90, 0.25)',
          offsetY: 4
        })
        .rotate({
          angle: this.isReversed ? 180 : 0,
          centerY: '50%',
          centerX: '50%'
        })
        .animation({
          duration: 400,
          curve: Curve.EaseOut
        })
      }
    }
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
  }
}

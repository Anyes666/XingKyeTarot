import { Theme } from '../common/Theme';

/**
 * 塔罗牌组件
 * 支持正逆位显示：逆位通过 rotation 旋转 180deg 实现。
 *
 * 状态：
 * - idle: 显示牌背
 * - revealed: 显示牌面（正/逆），含平滑加载和错误兜底
 *
 * 响应式：通过 breakpoint 自动调整卡片尺寸。
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
  @StorageProp('windowWidth') windowWidth: number = 360;
  @State isImageLoading: boolean = true;
  @State hasImageError: boolean = false;
  @State showImage: boolean = false;
  onTap?: () => void;

  aboutToAppear(): void {
    this.isImageLoading = true;
    this.hasImageError = false;
    this.showImage = false;
  }

  /**
   * 根据窗口宽度自动计算响应式卡片宽度。
   * 手机端用传入尺寸，平板端放大 1.4 倍。
   */
  private getResponsiveWidth(): number {
    if (this.windowWidth >= Theme.BREAKPOINT_LG) {
      return this.cardWidth * 1.4;
    }
    if (this.windowWidth >= Theme.BREAKPOINT_MD) {
      return this.cardWidth * 1.2;
    }
    return this.cardWidth;
  }

  private getResponsiveHeight(): number {
    return this.getResponsiveWidth() * Theme.TAROT_CARD_ASPECT_RATIO;
  }

  build() {
    Column() {
      if (this.displayState === CardDisplayState.IDLE) {
        this.cardBackView()
      } else {
        this.cardFaceView()
      }
    }
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
  }

  @Builder
  cardBackView(): void {
    Column() {
      Image($r('app.media.card_back'))
        .width(this.getResponsiveWidth())
        .height(this.getResponsiveHeight())
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.TAROT_CARD_RADIUS)
    }
    .width(this.getResponsiveWidth())
    .height(this.getResponsiveHeight())
    .borderRadius(Theme.TAROT_CARD_RADIUS)
    .border({ width: 1, color: Theme.GOLD_DIM })
    .shadow({
      radius: 12,
      color: 'rgba(216, 180, 90, 0.15)',
      offsetY: 4
    })
  }

  @Builder
  cardFaceView(): void {
    Column() {
      // 牌图区域 — 带加载骨架 + 错误兜底
      Stack() {
        // 加载中骨架
        if (this.isImageLoading && !this.hasImageError) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(23, 29, 58, 0.6)')
            .borderRadius({ topLeft: Theme.TAROT_CARD_RADIUS, topRight: Theme.TAROT_CARD_RADIUS })

          LoadingProgress()
            .width(28)
            .height(28)
            .color(Theme.GOLD_SOFT)
        }

        // 加载失败兜底
        if (this.hasImageError) {
          Column() {
            Text('?')
              .fontSize(36)
              .fontColor(Theme.TEXT_MUTED)
              .fontWeight(FontWeight.Bold)
            Text('加载失败')
              .fontSize(10)
              .fontColor(Theme.TEXT_MUTED)
              .margin({ top: 4 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(23, 29, 58, 0.6)')
          .borderRadius({ topLeft: Theme.TAROT_CARD_RADIUS, topRight: Theme.TAROT_CARD_RADIUS })
        }

        // 牌图
        Image(this.getCardImageResource())
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Theme.TAROT_CARD_RADIUS, topRight: Theme.TAROT_CARD_RADIUS })
          .opacity(this.showImage ? 1 : 0)
          .animation({ duration: 300, curve: Curve.EaseOut })
          .onComplete(() => {
            this.isImageLoading = false;
            this.hasImageError = false;
            this.showImage = true;
          })
          .onError(() => {
            this.isImageLoading = false;
            this.hasImageError = true;
          })
      }
      .width('100%')
      .height(this.getResponsiveHeight() * 0.65)

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
      .height(this.getResponsiveHeight() * 0.35)
      .justifyContent(FlexAlign.Center)
      .padding({ left: 4, right: 4 })
      .backgroundColor(Theme.BG_CARD)
      .borderRadius({ bottomLeft: Theme.TAROT_CARD_RADIUS, bottomRight: Theme.TAROT_CARD_RADIUS })
    }
    .width(this.getResponsiveWidth())
    .height(this.getResponsiveHeight())
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

  private getCardImageResource(): Resource {
    switch (this.cardImage) {
      case 'tarot_major_00_fool.png':
        return $r('app.media.tarot_major_00_fool');
      case 'tarot_major_01_magician.png':
        return $r('app.media.tarot_major_01_magician');
      case 'tarot_major_02_high_priestess.png':
        return $r('app.media.tarot_major_02_high_priestess');
      case 'tarot_major_03_empress.png':
        return $r('app.media.tarot_major_03_empress');
      case 'tarot_major_04_emperor.png':
        return $r('app.media.tarot_major_04_emperor');
      case 'tarot_major_05_hierophant.png':
        return $r('app.media.tarot_major_05_hierophant');
      case 'tarot_major_06_lovers.png':
        return $r('app.media.tarot_major_06_lovers');
      case 'tarot_major_07_chariot.png':
        return $r('app.media.tarot_major_07_chariot');
      case 'tarot_major_08_strength.png':
        return $r('app.media.tarot_major_08_strength');
      case 'tarot_major_09_hermit.png':
        return $r('app.media.tarot_major_09_hermit');
      case 'tarot_major_10_wheel_of_fortune.png':
        return $r('app.media.tarot_major_10_wheel_of_fortune');
      case 'tarot_major_11_justice.png':
        return $r('app.media.tarot_major_11_justice');
      case 'tarot_major_12_hanged_man.png':
        return $r('app.media.tarot_major_12_hanged_man');
      case 'tarot_major_13_death.png':
        return $r('app.media.tarot_major_13_death');
      case 'tarot_major_14_temperance.png':
        return $r('app.media.tarot_major_14_temperance');
      case 'tarot_major_15_devil.png':
        return $r('app.media.tarot_major_15_devil');
      case 'tarot_major_16_tower.png':
        return $r('app.media.tarot_major_16_tower');
      case 'tarot_major_17_star.png':
        return $r('app.media.tarot_major_17_star');
      case 'tarot_major_18_moon.png':
        return $r('app.media.tarot_major_18_moon');
      case 'tarot_major_19_sun.png':
        return $r('app.media.tarot_major_19_sun');
      case 'tarot_major_20_judgement.png':
        return $r('app.media.tarot_major_20_judgement');
      case 'tarot_major_21_world.png':
        return $r('app.media.tarot_major_21_world');
      case 'minor_cups_01_ace.png':
        return $r('app.media.minor_cups_01_ace');
      case 'minor_cups_02_two.png':
        return $r('app.media.minor_cups_02_two');
      case 'minor_cups_03_three.png':
        return $r('app.media.minor_cups_03_three');
      case 'minor_cups_04_four.png':
        return $r('app.media.minor_cups_04_four');
      case 'minor_cups_05_five.png':
        return $r('app.media.minor_cups_05_five');
      case 'minor_cups_06_six.png':
        return $r('app.media.minor_cups_06_six');
      case 'minor_cups_07_seven.png':
        return $r('app.media.minor_cups_07_seven');
      case 'minor_cups_08_eight.png':
        return $r('app.media.minor_cups_08_eight');
      case 'minor_cups_09_nine.png':
        return $r('app.media.minor_cups_09_nine');
      case 'minor_cups_10_ten.png':
        return $r('app.media.minor_cups_10_ten');
      case 'minor_cups_king.png':
        return $r('app.media.minor_cups_king');
      case 'minor_cups_knight.png':
        return $r('app.media.minor_cups_knight');
      case 'minor_cups_page.png':
        return $r('app.media.minor_cups_page');
      case 'minor_cups_queen.png':
        return $r('app.media.minor_cups_queen');
      case 'minor_pentacles_01_ace.png':
        return $r('app.media.minor_pentacles_01_ace');
      case 'minor_pentacles_02_two.png':
        return $r('app.media.minor_pentacles_02_two');
      case 'minor_pentacles_03_three.png':
        return $r('app.media.minor_pentacles_03_three');
      case 'minor_pentacles_04_four.png':
        return $r('app.media.minor_pentacles_04_four');
      case 'minor_pentacles_05_five.png':
        return $r('app.media.minor_pentacles_05_five');
      case 'minor_pentacles_06_six.png':
        return $r('app.media.minor_pentacles_06_six');
      case 'minor_pentacles_07_seven.png':
        return $r('app.media.minor_pentacles_07_seven');
      case 'minor_pentacles_08_eight.png':
        return $r('app.media.minor_pentacles_08_eight');
      case 'minor_pentacles_09_nine.png':
        return $r('app.media.minor_pentacles_09_nine');
      case 'minor_pentacles_10_ten.png':
        return $r('app.media.minor_pentacles_10_ten');
      case 'minor_pentacles_king.png':
        return $r('app.media.minor_pentacles_king');
      case 'minor_pentacles_knight.png':
        return $r('app.media.minor_pentacles_knight');
      case 'minor_pentacles_page.png':
        return $r('app.media.minor_pentacles_page');
      case 'minor_pentacles_queen.png':
        return $r('app.media.minor_pentacles_queen');
      case 'minor_swords_01_ace.png':
        return $r('app.media.minor_swords_01_ace');
      case 'minor_swords_02_two.png':
        return $r('app.media.minor_swords_02_two');
      case 'minor_swords_03_three.png':
        return $r('app.media.minor_swords_03_three');
      case 'minor_swords_04_four.png':
        return $r('app.media.minor_swords_04_four');
      case 'minor_swords_05_five.png':
        return $r('app.media.minor_swords_05_five');
      case 'minor_swords_06_six.png':
        return $r('app.media.minor_swords_06_six');
      case 'minor_swords_07_seven.png':
        return $r('app.media.minor_swords_07_seven');
      case 'minor_swords_08_eight.png':
        return $r('app.media.minor_swords_08_eight');
      case 'minor_swords_09_nine.png':
        return $r('app.media.minor_swords_09_nine');
      case 'minor_swords_10_ten.png':
        return $r('app.media.minor_swords_10_ten');
      case 'minor_swords_king.png':
        return $r('app.media.minor_swords_king');
      case 'minor_swords_knight.png':
        return $r('app.media.minor_swords_knight');
      case 'minor_swords_page.png':
        return $r('app.media.minor_swords_page');
      case 'minor_swords_queen.png':
        return $r('app.media.minor_swords_queen');
      case 'minor_wands_01_ace.png':
        return $r('app.media.minor_wands_01_ace');
      case 'minor_wands_02_two.png':
        return $r('app.media.minor_wands_02_two');
      case 'minor_wands_03_three.png':
        return $r('app.media.minor_wands_03_three');
      case 'minor_wands_04_four.png':
        return $r('app.media.minor_wands_04_four');
      case 'minor_wands_05_five.png':
        return $r('app.media.minor_wands_05_five');
      case 'minor_wands_06_six.png':
        return $r('app.media.minor_wands_06_six');
      case 'minor_wands_07_seven.png':
        return $r('app.media.minor_wands_07_seven');
      case 'minor_wands_08_eight.png':
        return $r('app.media.minor_wands_08_eight');
      case 'minor_wands_09_nine.png':
        return $r('app.media.minor_wands_09_nine');
      case 'minor_wands_10_ten.png':
        return $r('app.media.minor_wands_10_ten');
      case 'minor_wands_king.png':
        return $r('app.media.minor_wands_king');
      case 'minor_wands_knight.png':
        return $r('app.media.minor_wands_knight');
      case 'minor_wands_page.png':
        return $r('app.media.minor_wands_page');
      case 'minor_wands_queen.png':
        return $r('app.media.minor_wands_queen');
      default:
        return $r('app.media.placeholder_card');
    }
  }
}

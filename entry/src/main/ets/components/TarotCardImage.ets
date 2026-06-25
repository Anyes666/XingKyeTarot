import { MVP8_CARD_IMAGES } from '../data/MVP8CardsData';

/**
 * 统一塔罗牌图组件（P0.3 整改）
 *
 * 解决黑边问题：
 * - 使用 ImageFit.Cover（不是 Contain）确保图片填满容器
 * - 容器 clip(true) 裁切溢出
 * - 统一圆角 8vp
 * - 暗色背景防透视
 * - 比例 5:8
 *
 * 使用示例：
 *   TarotCardImage({ cardId: 'major_18_moon', cardWidth: 100, cardHeight: 160 })
 */
@Component
export struct TarotCardImage {
  @Prop cardId: string = '';
  @Prop cardWidth: number = 100;
  @Prop cardHeight: number = 160;

  build() {
    Stack() {
      Image(this.getCardImageResource(this.cardId))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
    }
    .width(this.cardWidth)
    .height(this.cardHeight)
    .clip(true)
    .borderRadius(8)
    .backgroundColor('#1a1a2e')
  }

  /**
   * cardId → Resource 映射
   * 优先查 MVP8_CARD_IMAGES，未知 cardId fallback 到 card_back
   */
  private getCardImageResource(cardId: string): Resource {
    if (cardId && MVP8_CARD_IMAGES[cardId]) {
      return MVP8_CARD_IMAGES[cardId];
    }
    // 补充所有卡牌映射（包含非 MVP8 的 22 张大阿卡纳 + 56 张小阿卡纳）
    switch (cardId) {
      case 'major_01_magician': return $r('app.media.tarot_major_01_magician');
      case 'major_03_empress': return $r('app.media.tarot_major_03_empress');
      case 'major_04_emperor': return $r('app.media.tarot_major_04_emperor');
      case 'major_05_hierophant': return $r('app.media.tarot_major_05_hierophant');
      case 'major_08_strength': return $r('app.media.tarot_major_08_strength');
      case 'major_11_justice': return $r('app.media.tarot_major_11_justice');
      case 'major_12_hanged_man': return $r('app.media.tarot_major_12_hanged_man');
      case 'major_14_temperance': return $r('app.media.tarot_major_14_temperance');
      case 'major_15_devil': return $r('app.media.tarot_major_15_devil');
      case 'major_16_tower': return $r('app.media.tarot_major_16_tower');
      case 'major_17_star': return $r('app.media.tarot_major_17_star');
      case 'major_19_sun': return $r('app.media.tarot_major_19_sun');
      case 'major_20_judgement': return $r('app.media.tarot_major_20_judgement');
      case 'major_21_world': return $r('app.media.tarot_major_21_world');
      default: return $r('app.media.card_back');
    }
  }
}

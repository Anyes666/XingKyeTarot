import { MVP8_CARD_IMAGES } from '../data/MVP8CardsData';
import { Theme } from '../common/Theme';

/**
 * 统一塔罗牌图组件（P0.3 整改 v2）
 *
 * 消除黑边/多余边框：
 * - ImageFit.Cover 确保图片填满容器
 * - 使用 Theme.TAROT_CARD_RADIUS 统一圆角
 * - clip(true) 裁切溢出
 * - 移除 backgroundColor 消除暗色盒子透视
 * - 移除所有 border/shadow
 * - 比例 5:8（width:height = 1:1.6）
 *
 * 使用示例：
 *   TarotCardImage({ cardId: 'major_18_moon', cardWidth: 90, cardHeight: 144 })
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
        .borderRadius(Theme.TAROT_CARD_RADIUS)
    }
    .width(this.cardWidth)
    .height(this.cardHeight)
    .clip(true)
    .borderRadius(Theme.TAROT_CARD_RADIUS)
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
      // ── 权杖组 (Wands) 14张 ──
      case 'minor_wands_01_ace': return $r('app.media.minor_wands_01_ace');
      case 'minor_wands_02_two': return $r('app.media.minor_wands_02_two');
      case 'minor_wands_03_three': return $r('app.media.minor_wands_03_three');
      case 'minor_wands_04_four': return $r('app.media.minor_wands_04_four');
      case 'minor_wands_05_five': return $r('app.media.minor_wands_05_five');
      case 'minor_wands_06_six': return $r('app.media.minor_wands_06_six');
      case 'minor_wands_07_seven': return $r('app.media.minor_wands_07_seven');
      case 'minor_wands_08_eight': return $r('app.media.minor_wands_08_eight');
      case 'minor_wands_09_nine': return $r('app.media.minor_wands_09_nine');
      case 'minor_wands_10_ten': return $r('app.media.minor_wands_10_ten');
      case 'minor_wands_page': return $r('app.media.minor_wands_page');
      case 'minor_wands_knight': return $r('app.media.minor_wands_knight');
      case 'minor_wands_queen': return $r('app.media.minor_wands_queen');
      case 'minor_wands_king': return $r('app.media.minor_wands_king');
      // ── 圣杯组 (Cups) 14张 ──
      case 'minor_cups_01_ace': return $r('app.media.minor_cups_01_ace');
      case 'minor_cups_02_two': return $r('app.media.minor_cups_02_two');
      case 'minor_cups_03_three': return $r('app.media.minor_cups_03_three');
      case 'minor_cups_04_four': return $r('app.media.minor_cups_04_four');
      case 'minor_cups_05_five': return $r('app.media.minor_cups_05_five');
      case 'minor_cups_06_six': return $r('app.media.minor_cups_06_six');
      case 'minor_cups_07_seven': return $r('app.media.minor_cups_07_seven');
      case 'minor_cups_08_eight': return $r('app.media.minor_cups_08_eight');
      case 'minor_cups_09_nine': return $r('app.media.minor_cups_09_nine');
      case 'minor_cups_10_ten': return $r('app.media.minor_cups_10_ten');
      case 'minor_cups_page': return $r('app.media.minor_cups_page');
      case 'minor_cups_knight': return $r('app.media.minor_cups_knight');
      case 'minor_cups_queen': return $r('app.media.minor_cups_queen');
      case 'minor_cups_king': return $r('app.media.minor_cups_king');
      // ── 宝剑组 (Swords) 14张 ──
      case 'minor_swords_01_ace': return $r('app.media.minor_swords_01_ace');
      case 'minor_swords_02_two': return $r('app.media.minor_swords_02_two');
      case 'minor_swords_03_three': return $r('app.media.minor_swords_03_three');
      case 'minor_swords_04_four': return $r('app.media.minor_swords_04_four');
      case 'minor_swords_05_five': return $r('app.media.minor_swords_05_five');
      case 'minor_swords_06_six': return $r('app.media.minor_swords_06_six');
      case 'minor_swords_07_seven': return $r('app.media.minor_swords_07_seven');
      case 'minor_swords_08_eight': return $r('app.media.minor_swords_08_eight');
      case 'minor_swords_09_nine': return $r('app.media.minor_swords_09_nine');
      case 'minor_swords_10_ten': return $r('app.media.minor_swords_10_ten');
      case 'minor_swords_page': return $r('app.media.minor_swords_page');
      case 'minor_swords_knight': return $r('app.media.minor_swords_knight');
      case 'minor_swords_queen': return $r('app.media.minor_swords_queen');
      case 'minor_swords_king': return $r('app.media.minor_swords_king');
      // ── 星币组 (Pentacles) 14张 ──
      case 'minor_pentacles_01_ace': return $r('app.media.minor_pentacles_01_ace');
      case 'minor_pentacles_02_two': return $r('app.media.minor_pentacles_02_two');
      case 'minor_pentacles_03_three': return $r('app.media.minor_pentacles_03_three');
      case 'minor_pentacles_04_four': return $r('app.media.minor_pentacles_04_four');
      case 'minor_pentacles_05_five': return $r('app.media.minor_pentacles_05_five');
      case 'minor_pentacles_06_six': return $r('app.media.minor_pentacles_06_six');
      case 'minor_pentacles_07_seven': return $r('app.media.minor_pentacles_07_seven');
      case 'minor_pentacles_08_eight': return $r('app.media.minor_pentacles_08_eight');
      case 'minor_pentacles_09_nine': return $r('app.media.minor_pentacles_09_nine');
      case 'minor_pentacles_10_ten': return $r('app.media.minor_pentacles_10_ten');
      case 'minor_pentacles_page': return $r('app.media.minor_pentacles_page');
      case 'minor_pentacles_knight': return $r('app.media.minor_pentacles_knight');
      case 'minor_pentacles_queen': return $r('app.media.minor_pentacles_queen');
      case 'minor_pentacles_king': return $r('app.media.minor_pentacles_king');
      // 临时占位：未知 cardId fallback 到 card_back
      // TODO: 补齐所有牌面图片资源后移除此 fallback
      default: return $r('app.media.card_back');
    }
  }
}

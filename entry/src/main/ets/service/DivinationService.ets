import { SACRED_TRIANGLE_SPREAD } from '../model/Spread';
import { DivinationRecord, DrawnCard } from '../model/DivinationRecord';
import { TarotCard } from '../model/TarotCard';
import { RandomUtil } from '../utils/RandomUtil';
import { TarotDataService } from './TarotDataService';

export class DivinationService {
  /**
   * Performs a Sacred Triangle (圣三角) draw.
   */
  static async drawSacredTriangle(
    questionType: string = 'general',
    seed: string = `${Date.now()}`
  ): Promise<DivinationRecord> {
    const data: TarotDataService = TarotDataService.getInstance();
    const cards: TarotCard[] = data.getAllCards();

    if (cards.length < 3) {
      throw new Error(`Not enough cards for a 3-card draw: only ${cards.length} available`);
    }

    const indexes: number[] = RandomUtil.drawUniqueIndexes(cards.length, 3, seed);

    const drawn: DrawnCard[] = indexes.map((cardIndex: number, positionIndex: number) => {
      const card: TarotCard = cards[cardIndex];
      const isReversed: boolean = RandomUtil.booleanFromSeed(seed, `${card.id}-pos${positionIndex}`);
      const result: DrawnCard = {
        card: card,
        positionIndex: positionIndex,
        positionName: SACRED_TRIANGLE_SPREAD.positions[positionIndex].name,
        isReversed: isReversed,
        interpretation: data.getInterpretation(card.id, isReversed),
        keywords: data.getKeywords(card.id, isReversed)
      };
      return result;
    });

    const record: DivinationRecord = {
      id: `record_${Date.now()}`,
      questionType: questionType,
      spread: SACRED_TRIANGLE_SPREAD,
      cards: drawn,
      createdAt: Date.now()
    };
    return record;
  }
}

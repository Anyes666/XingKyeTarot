import { SACRED_TRIANGLE_SPREAD, SpreadTemplate, getSpreadById } from '../model/Spread';
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
    return DivinationService.drawSpread(SACRED_TRIANGLE_SPREAD, questionType, seed);
  }

  static async drawBySpreadId(
    spreadId: string,
    questionType: string = 'general',
    seed: string = `${Date.now()}`
  ): Promise<DivinationRecord> {
    return DivinationService.drawSpread(getSpreadById(spreadId), questionType, seed);
  }

  private static async drawSpread(
    spread: SpreadTemplate,
    questionType: string,
    seed: string
  ): Promise<DivinationRecord> {
    const data: TarotDataService = TarotDataService.getInstance();
    const cards: TarotCard[] = data.getAllCards();
    const drawCount: number = spread.positions.length;

    if (cards.length < drawCount) {
      throw new Error(`Not enough cards for a ${drawCount}-card draw: only ${cards.length} available`);
    }

    const indexes: number[] = RandomUtil.drawUniqueIndexes(cards.length, drawCount, seed);

    const drawn: DrawnCard[] = indexes.map((cardIndex: number, positionIndex: number) => {
      const card: TarotCard = cards[cardIndex];
      const isReversed: boolean = RandomUtil.booleanFromSeed(seed, `${card.id}-pos${positionIndex}`);
      const result: DrawnCard = {
        card: card,
        positionIndex: positionIndex,
        positionName: spread.positions[positionIndex].name,
        isReversed: isReversed,
        interpretation: data.getInterpretation(card.id, isReversed),
        keywords: data.getKeywords(card.id, isReversed)
      };
      return result;
    });

    const record: DivinationRecord = {
      id: `record_${Date.now()}`,
      questionType: questionType,
      spread: spread,
      cards: drawn,
      createdAt: Date.now()
    };
    return record;
  }
}

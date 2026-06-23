import { TarotCard, CardInterpretation } from '../model/TarotCard';
import { TAROT_CARDS } from './TarotCardData';
import { CARD_INTERPRETATIONS } from './InterpretationData';

export class TarotDataLoader {
  /**
   * Load cards from compiled-in data (no runtime resource dependency).
   */
  static loadCards(): TarotCard[] {
    return TAROT_CARDS;
  }

  /**
   * Load interpretations from compiled-in data.
   */
  static loadInterpretations(): CardInterpretation[] {
    return CARD_INTERPRETATIONS;
  }
}

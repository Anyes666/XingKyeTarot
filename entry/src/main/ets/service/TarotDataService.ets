import { TarotCard, CardInterpretation } from '../model/TarotCard';
import { TarotDataLoader } from '../data/TarotDataLoader';

export class TarotDataService {
  private static instance: TarotDataService = new TarotDataService();
  private cards: TarotCard[] = [];
  private interpretationMap: Map<string, CardInterpretation> = new Map();
  private initialized: boolean = false;

  static getInstance(): TarotDataService {
    return TarotDataService.instance;
  }

  /**
   * Initialize: load cards and interpretations from compiled-in data.
   * Safe to call multiple times — only loads once.
   * Returns Promise<void> for proper async call semantics.
   */
  async init(): Promise<void> {
    if (this.initialized) {
      return;
    }
    this.cards = TarotDataLoader.loadCards();
    const list: CardInterpretation[] = TarotDataLoader.loadInterpretations();
    this.interpretationMap.clear();
    list.forEach((item: CardInterpretation) => this.interpretationMap.set(item.cardId, item));
    this.validate();
    this.initialized = true;
  }

  /**
   * Returns all loaded cards. Call after init().
   */
  getAllCards(): TarotCard[] {
    return this.cards;
  }

  /**
   * Returns a single card by ID, or throws if not found.
   */
  getCardById(cardId: string): TarotCard {
    const card: TarotCard | undefined = this.cards.find((c: TarotCard) => c.id === cardId);
    if (!card) {
      throw new Error(`Card not found: ${cardId}`);
    }
    return card;
  }

  /**
   * Returns the interpretation text for a card, respecting upright/reversed.
   */
  getInterpretation(cardId: string, isReversed: boolean): string {
    const item: CardInterpretation | undefined = this.interpretationMap.get(cardId);
    if (!item) {
      throw new Error(`Missing interpretation for card: ${cardId}`);
    }
    return isReversed ? item.reversed : item.upright;
  }

  /**
   * Returns keywords for a card, respecting upright/reversed.
   */
  getKeywords(cardId: string, isReversed: boolean): string[] {
    const item: CardInterpretation | undefined = this.interpretationMap.get(cardId);
    if (!item) {
      throw new Error(`Missing keywords for card: ${cardId}`);
    }
    return isReversed ? item.reversedKeywords : item.uprightKeywords;
  }

  /**
   * Number of loaded cards.
   */
  getCardCount(): number {
    return this.cards.length;
  }

  /**
   * Whether the service has been initialized.
   */
  isInitialized(): boolean {
    return this.initialized;
  }

  /**
   * Data integrity check: every card must have a matching interpretation.
   */
  private validate(): void {
    if (this.cards.length === 0) {
      throw new Error('No tarot cards loaded — data may be missing');
    }
    this.cards.forEach((card: TarotCard) => {
      if (!this.interpretationMap.has(card.id)) {
        throw new Error(`Card "${card.nameZh}" (${card.id}) has no matching interpretation`);
      }
    });
  }

  /**
   * Reset singleton state for test isolation.
   */
  static reset(): void {
    TarotDataService.instance = new TarotDataService();
  }
}

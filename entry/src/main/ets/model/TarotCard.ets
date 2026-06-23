export enum ArcanaType {
  MAJOR = 'major',
  MINOR = 'minor'
}

export enum TarotSuit {
  NONE = 'none',
  WANDS = 'wands',
  CUPS = 'cups',
  SWORDS = 'swords',
  PENTACLES = 'pentacles'
}

export interface TarotCard {
  id: string;
  index: number;
  nameZh: string;
  nameEn: string;
  arcana: ArcanaType;
  suit: TarotSuit;
  image: string;
  keywords: string[];
}

export interface CardInterpretation {
  cardId: string;
  upright: string;
  reversed: string;
  uprightKeywords: string[];
  reversedKeywords: string[];
}

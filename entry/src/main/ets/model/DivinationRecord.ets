import { TarotCard } from './TarotCard';
import { SpreadTemplate } from './Spread';

export interface DrawnCard {
  card: TarotCard;
  positionIndex: number;
  positionName: string;
  isReversed: boolean;
  interpretation: string;
  keywords: string[];
}

export interface DivinationRecord {
  id: string;
  questionType: string;
  spread: SpreadTemplate;
  cards: DrawnCard[];
  createdAt: number;
}

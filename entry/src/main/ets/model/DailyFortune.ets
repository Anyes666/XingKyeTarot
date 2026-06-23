import { TarotCard } from './TarotCard';

export interface DailyFortune {
  dateKey: string;
  card: TarotCard;
  isReversed: boolean;
  keyword: string;
  summary: string;
  createdAt: number;
}

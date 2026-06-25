export { ArcanaType, TarotSuit } from '../model/TarotCard';
export type {
  TarotCard,
  CardInterpretation,
  EmotionTag,
  ScenarioContent,
  FollowUpOption,
  FollowUpQuestion,
  DeepInterpretation,
  StructuredInterpretation
} from '../model/TarotCard';
export type { SpreadPosition, SpreadTemplate } from '../model/Spread';
export { SACRED_TRIANGLE_SPREAD } from '../model/Spread';
export type { DrawnCard, DivinationRecord } from '../model/DivinationRecord';
export type { DailyFortune } from '../model/DailyFortune';

// ── MVP P0 新增导出 ──
export type { MvpDivinationRecord } from '../model/MvpDivinationRecord';
export { generateRecordId } from '../model/MvpDivinationRecord';
export type { HeartOption } from '../data/HeartOptionsData';
export { HEART_OPTIONS, CARD_WEIGHTS, drawCardByWeight } from '../data/HeartOptionsData';
export {
  MVP8_CARD_IDS,
  MVP8_CARD_NAMES,
  MVP8_CARD_IMAGES,
  getMVP8CardData,
  getScenarioContent,
  getGoldenSentence,
} from '../data/MVP8CardsData';

// ── P0.2 新增导出 ──
export { SpreadType, EntryMode, generateHistoryRecordId } from '../model/DivinationHistoryRecord';
export type { DrawnCardRecord, DivinationHistoryRecord } from '../model/DivinationHistoryRecord';


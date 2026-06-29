/**
 * 星澜短情绪与渴望恋爱专用语料（Phase 4 新增）
 *
 * 解决：短情绪词随机抽到关系/告别/等待文案的问题。
 * 解决："想谈恋爱了"没有专属回复的问题。
 */

import {
  XinglanChatLine,
  XinglanEmotionTag,
  XinglanTopicTag,
  XinglanReplyStrategy,
  XinglanSubTopicTag
} from '../types/XinglanTypes';

// ═══════════════════════════════════════════════════════════
// 短情绪专用池 — SHORT_EMOTION
// ═══════════════════════════════════════════════════════════
export const CORPUS_SHORT_SAD: XinglanChatLine[] = [
  {
    id: 'SSAD_001',
    strategy: XinglanReplyStrategy.HOLD_EMOTION,
    emotion: XinglanEmotionTag.SAD,
    topic: XinglanTopicTag.SELF,
    text: '伤心这两个字，已经够重了。你不用把它说得很完整，星澜也会认真听。'
  },
  {
    id: 'SSAD_002',
    strategy: XinglanReplyStrategy.HOLD_EMOTION,
    emotion: XinglanEmotionTag.SAD,
    topic: XinglanTopicTag.SELF,
    text: '这份伤心出现了，说明你心里有一处正在请求被看见。不用急着解释，我们可以先把它放下来一点。'
  },
  {
    id: 'SSAD_003',
    strategy: XinglanReplyStrategy.SOFT_QUESTION,
    emotion: XinglanEmotionTag.SAD,
    topic: XinglanTopicTag.SELF,
    text: '这份伤心更像失望、委屈，还是孤单？你不用说得特别清楚，只用一个词就好。'
  }
];

export const CORPUS_SHORT_UNHAPPY: XinglanChatLine[] = [
  {
    id: 'UNHP_001',
    strategy: XinglanReplyStrategy.HOLD_EMOTION,
    emotion: XinglanEmotionTag.SAD,
    topic: XinglanTopicTag.SELF,
    text: '听见了，你现在不太开心。可以先不用急着解释原因。有时候情绪刚冒出来，还没有整理成一句完整的话。'
  },
  {
    id: 'UNHP_002',
    strategy: XinglanReplyStrategy.SOFT_QUESTION,
    emotion: XinglanEmotionTag.SAD,
    topic: XinglanTopicTag.SELF,
    text: '这份不开心更像委屈、失落，还是累？如果不想说也没关系，星澜会先在这里听你慢慢说。'
  }
];

export const CORPUS_SHORT_TIRED: XinglanChatLine[] = [
  {
    id: 'STIR_001',
    strategy: XinglanReplyStrategy.HOLD_EMOTION,
    emotion: XinglanEmotionTag.TIRED,
    topic: XinglanTopicTag.SELF,
    text: '你已经很累了。这句话不需要被证明，也不需要马上解释。星澜想先陪你分清楚：这是身体累，心累，还是一直撑着不敢停的累？'
  },
  {
    id: 'STIR_002',
    strategy: XinglanReplyStrategy.HOLD_EMOTION,
    emotion: XinglanEmotionTag.TIRED,
    topic: XinglanTopicTag.SELF,
    text: '如果现在什么都不想做，那不做也是一种诚实。不用逼自己马上振作。'
  }
];

export const CORPUS_SHORT_ANXIOUS: XinglanChatLine[] = [
  {
    id: 'SANX_001',
    strategy: XinglanReplyStrategy.HOLD_EMOTION,
    emotion: XinglanEmotionTag.ANXIOUS,
    topic: XinglanTopicTag.SELF,
    text: '听起来，你现在心里很堵。暂时说不清也没关系。你可以先把"烦"的来源分成三类看看：人、事，还是自己一直绷着的状态？'
  },
  {
    id: 'SANX_002',
    strategy: XinglanReplyStrategy.SOFT_QUESTION,
    emotion: XinglanEmotionTag.ANXIOUS,
    topic: XinglanTopicTag.SELF,
    text: '现在先不解决任何具体问题。可以试着把手放在胸口，慢慢呼吸三次。星澜会等你慢慢说。'
  }
];

// ═══════════════════════════════════════════════════════════
// 想谈恋爱 — RELATION_LOVE_DESIRE
// ═══════════════════════════════════════════════════════════
export const CORPUS_LOVE_DESIRE: XinglanChatLine[] = [
  {
    id: 'LVDS_001',
    strategy: XinglanReplyStrategy.HOLD_EMOTION,
    emotion: XinglanEmotionTag.LONELY,
    topic: XinglanTopicTag.RELATION,
    text: '想谈恋爱，也许不只是想拥有一个人。有时候，它是在说：我想被认真选择，想有人惦记，也想在累的时候有个可以靠近的地方。'
  },
  {
    id: 'LVDS_002',
    strategy: XinglanReplyStrategy.REFLECT,
    emotion: XinglanEmotionTag.LONELY,
    topic: XinglanTopicTag.RELATION,
    text: '星澜不会催你开始一段关系，也不会替你判断什么时候会遇见谁。但我们可以先看看：你现在最想要的是陪伴、心动，还是一种被坚定对待的感觉？'
  },
  {
    id: 'LVDS_003',
    strategy: XinglanReplyStrategy.SOFT_QUESTION,
    emotion: XinglanEmotionTag.HOPEFUL,
    topic: XinglanTopicTag.RELATION,
    text: '如果可以不考虑现实，你希望那个人带给你最重要的东西是什么？'
  },
  {
    id: 'LVDS_004',
    strategy: XinglanReplyStrategy.SOFT_QUESTION,
    emotion: XinglanEmotionTag.LONELY,
    topic: XinglanTopicTag.RELATION,
    text: '渴望被爱，是很真实的感受。这不是"想太多"，而是你在请求一种靠近。星澜会陪你先看清楚这份渴望里藏着什么。'
  }
];

/** 获取短情绪专用语料 */
export function getShortEmotionLines(emotion: XinglanEmotionTag): XinglanChatLine[] {
  if (emotion === XinglanEmotionTag.SAD) { return [...CORPUS_SHORT_SAD, ...CORPUS_SHORT_UNHAPPY]; }
  if (emotion === XinglanEmotionTag.TIRED) { return [...CORPUS_SHORT_TIRED]; }
  if (emotion === XinglanEmotionTag.ANXIOUS) { return [...CORPUS_SHORT_ANXIOUS]; }
  return [];
}

/** 获取 RELATION_LOVE_DESIRE 语料 */
export function getLoveDesireLines(): XinglanChatLine[] {
  return CORPUS_LOVE_DESIRE;
}

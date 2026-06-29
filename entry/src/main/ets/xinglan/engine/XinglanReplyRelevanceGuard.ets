/**
 * 星澜回复相关性守卫（Phase 4 新增）
 *
 * 检查星澜回复是否与用户输入、关键词、subTopic 相关。
 * 短情绪词 / 角色互动 / 边界类输入不得 fallback 到无关文案。
 */

import {
  XinglanEmotionTag, XinglanTopicTag, XinglanSubTopicTag, XinglanBoundaryTag,
  XinglanChatLine
} from '../types/XinglanTypes';
import {
  getShortEmotionLines,
  getLoveDesireLines
} from '../data/XinglanShortCorpus';

/** 不相关的主题词（短情绪词场景禁止出现的名词） */
const UNRELATED_NOUNS_SAD: string[] = [
  '前任','复合','告别','分手','忽冷忽热','回消息','辞职','考试','他','她'
];

const UNRELATED_NOUNS_ROLE: string[] = [
  '前任','复合','分手','辞职','考试','学习','工作'
];

/** 检查文本是否包含不相关名词（短情绪词场景） */
export function hasUnwarrantedAssumption(text: string, subTopic: XinglanSubTopicTag): boolean {
  const lower: string = text.toLowerCase();
  if (subTopic === XinglanSubTopicTag.EMOTION_COLLAPSE ||
      subTopic === XinglanSubTopicTag.LOW_ENERGY_EXHAUSTED ||
      subTopic === XinglanSubTopicTag.LOW_ENERGY_SHUTDOWN ||
      subTopic === XinglanSubTopicTag.NUMB_EMPTY ||
      subTopic === XinglanSubTopicTag.ANXIETY_OVERTHINK) {
    for (let i = 0; i < UNRELATED_NOUNS_SAD.length; i++) {
      if (lower.includes(UNRELATED_NOUNS_SAD[i])) { return true; }
    }
  }
  return false;
}

/** 获取短情绪词的替代文案 */
export function getShortEmotionFallback(
  emotion: XinglanEmotionTag,
): string {
  const lines: XinglanChatLine[] = getShortEmotionLines(emotion);
  if (lines.length > 0) {
    const pick: XinglanChatLine = lines[Math.floor(Math.random() * lines.length)];
    return pick.text;
  }
  return '听见了。星澜会在这里听你慢慢说。';
}

/** 获取 RELATION_LOVE_DESIRE 的替代文案 */
export function getLoveDesireFallback(): string {
  const lines: XinglanChatLine[] = getLoveDesireLines();
  if (lines.length > 0) {
    const pick: XinglanChatLine = lines[Math.floor(Math.random() * lines.length)];
    return pick.text;
  }
  return '想恋爱，也许不只是想拥有一个人。星澜会陪你慢慢看这份渴望。';
}

/** 主入口：检查 replyText 是否与 subTopic 相关 */
export function checkRelevance(
  replyText: string,
  subTopic: XinglanSubTopicTag,
  boundary: XinglanBoundaryTag,
  topic: XinglanTopicTag,
  emotion: XinglanEmotionTag
): string {
  // 边界/角色互动不检查
  if (boundary !== XinglanBoundaryTag.NONE) { return replyText; }

  // 短情绪词检查
  if (topic === XinglanTopicTag.SELF &&
      (emotion === XinglanEmotionTag.SAD || emotion === XinglanEmotionTag.TIRED ||
       emotion === XinglanEmotionTag.ANXIOUS)) {
    if (hasUnwarrantedAssumption(replyText, subTopic)) {
      return getShortEmotionFallback(emotion);
    }
  }

  // 想谈恋爱
  if (subTopic === XinglanSubTopicTag.RELATION_LOVE_DESIRE) {
    const lower: string = replyText.toLowerCase();
    if (!lower.includes('恋爱') && !lower.includes('被爱') && !lower.includes('陪伴') && !lower.includes('心动') && !lower.includes('选择')) {
      return getLoveDesireFallback();
    }
  }

  // 角色互动
  if (topic === XinglanTopicTag.ROLE_INTERACTION) {
    if (hasUnwarrantedAssumption(replyText, subTopic)) {
      return getShortEmotionFallback(emotion);
    }
  }

  return replyText;
}

/**
 * 星澜聊天策略路由器（Phase 3 修复版）
 *
 * 路由优先级：CRISIS > PROFESSIONAL > ADULT_BOUNDARY > PREDICTION > ROLE_BOUNDARY > subTopic > emotion > topic > UNKNOWN
 */

import {
  XinglanEmotionTag, XinglanTopicTag, XinglanBoundaryTag,
  XinglanReplyStrategy, XinglanReplyPlan, XinglanAnalysisResult,
  XinglanSubTopicTag
} from '../types/XinglanTypes';

export function routeToPlan(result: XinglanAnalysisResult): XinglanReplyPlan {
  const e = result.emotion;
  const t = result.topic;
  const b = result.boundary;
  const s = result.subTopic || XinglanSubTopicTag.ANY;

  // ═══ 边界优先 ═══
  if (b === XinglanBoundaryTag.CRISIS) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY],
      allowFollowUp: false, forceShortCircuit: true };
  }
  if (b === XinglanBoundaryTag.PROFESSIONAL) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY, XinglanReplyStrategy.HOLD_EMOTION],
      allowFollowUp: false, forceShortCircuit: true };
  }
  if (b === XinglanBoundaryTag.ADULT_BOUNDARY) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.ROLE_BOUNDARY],
      allowFollowUp: false, forceShortCircuit: true };
  }
  if (b === XinglanBoundaryTag.PREDICTION) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY, XinglanReplyStrategy.TAROT_METAPHOR, XinglanReplyStrategy.SOFT_QUESTION],
      allowFollowUp: true, forceShortCircuit: false };
  }
  if (b === XinglanBoundaryTag.ROLE_BOUNDARY) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION],
      allowFollowUp: true, forceShortCircuit: false };
  }

  // ═══ 角色相关（subTopic 路由）═══
  if (s === XinglanSubTopicTag.ROLE_CONFESSION || s === XinglanSubTopicTag.ROLE_LOVE || s === XinglanSubTopicTag.ROLE_MARRY) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION],
      allowFollowUp: true, forceShortCircuit: false };
  }
  if (s === XinglanSubTopicTag.ROLE_MISS || s === XinglanSubTopicTag.ROLE_ONLY_YOU || s === XinglanSubTopicTag.ROLE_STAY) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION],
      allowFollowUp: true, forceShortCircuit: false };
  }
  if (s === XinglanSubTopicTag.ROLE_INSULT || s === XinglanSubTopicTag.ROLE_TELL_SHUTUP || s === XinglanSubTopicTag.ROLE_SOFTWARE) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.DEESCALATE, XinglanReplyStrategy.ROLE_BOUNDARY],
      allowFollowUp: false, forceShortCircuit: true };
  }
  if (s === XinglanSubTopicTag.ROLE_CONTROL || s === XinglanSubTopicTag.ROLE_DONT_LEAVE || s === XinglanSubTopicTag.ROLE_MUST_LOVE) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.DEESCALATE],
      allowFollowUp: false, forceShortCircuit: true };
  }
  if (t === XinglanTopicTag.TAROT_CARD) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.TAROT_METAPHOR, XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.REFLECT],
      allowFollowUp: false, forceShortCircuit: false };
  }

  // ═══ 情绪+主题组合 ═══
  if (e === XinglanEmotionTag.TIRED) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.TINY_STEP, XinglanReplyStrategy.SOFT_QUESTION],
      allowFollowUp: true, forceShortCircuit: false };
  }
  if (e === XinglanEmotionTag.ANXIOUS) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION],
      allowFollowUp: true, forceShortCircuit: false };
  }
  if (t === XinglanTopicTag.RELATION || t === XinglanTopicTag.FAMILY || t === XinglanTopicTag.FRIENDSHIP) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.RELATION_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION],
      allowFollowUp: true, forceShortCircuit: false };
  }
  if (t === XinglanTopicTag.CHOICE) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.SOFT_QUESTION],
      allowFollowUp: true, forceShortCircuit: false };
  }
  if (t === XinglanTopicTag.WORK || t === XinglanTopicTag.STUDY) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.TINY_STEP],
      allowFollowUp: true, forceShortCircuit: false };
  }
  if (e === XinglanEmotionTag.SAD || e === XinglanEmotionTag.LONELY ||
      e === XinglanEmotionTag.ANGRY || e === XinglanEmotionTag.GUILTY || e === XinglanEmotionTag.NUMB) {
    return { emotion: e, topic: t, boundary: b, subTopic: s,
      strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION],
      allowFollowUp: true, forceShortCircuit: false };
  }

  return {
    emotion: XinglanEmotionTag.UNKNOWN, topic: XinglanTopicTag.UNKNOWN,
    boundary: XinglanBoundaryTag.NONE, subTopic: XinglanSubTopicTag.ANY,
    strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION],
    allowFollowUp: true, forceShortCircuit: false
  };
}

/**
 * 星澜聊天模板与 UI 文案常量（Phase 2 扩展版 — 11 模板）
 *
 * 模板策略序列定义 + UI 文案 + 安全禁用词 + 功能开关。
 */

import {
  XinglanReplyTemplate,
  XinglanReplyStrategy,
  XinglanBoundaryTag
} from '../types/XinglanTypes';

// ═══ 回复组合模板 ═══

export const TEMPLATE_EMOTION_COMFORT: XinglanReplyTemplate = {
  id: 'T01_EMOTION_COMFORT', boundary: XinglanBoundaryTag.NONE,
  strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION],
  appendQuestion: true
};

export const TEMPLATE_RELATION: XinglanReplyTemplate = {
  id: 'T02_RELATION', boundary: XinglanBoundaryTag.NONE,
  strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.RELATION_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION],
  appendQuestion: true
};

export const TEMPLATE_CHOICE: XinglanReplyTemplate = {
  id: 'T03_CHOICE', boundary: XinglanBoundaryTag.NONE,
  strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.SOFT_QUESTION],
  appendQuestion: true
};

export const TEMPLATE_PREDICTION: XinglanReplyTemplate = {
  id: 'T04_PREDICTION', boundary: XinglanBoundaryTag.PREDICTION,
  strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY, XinglanReplyStrategy.TAROT_METAPHOR, XinglanReplyStrategy.SOFT_QUESTION],
  appendQuestion: true
};

export const TEMPLATE_TIRED: XinglanReplyTemplate = {
  id: 'T05_TIRED', boundary: XinglanBoundaryTag.NONE,
  strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.TINY_STEP, XinglanReplyStrategy.SOFT_QUESTION],
  appendQuestion: true
};

export const TEMPLATE_SAFETY: XinglanReplyTemplate = {
  id: 'T06_SAFETY', boundary: XinglanBoundaryTag.PROFESSIONAL,
  strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY, XinglanReplyStrategy.HOLD_EMOTION],
  appendQuestion: false
};

export const TEMPLATE_CRISIS: XinglanReplyTemplate = {
  id: 'T07_CRISIS', boundary: XinglanBoundaryTag.CRISIS,
  strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY],
  appendQuestion: false
};

export const TEMPLATE_ROLE_BOUNDARY: XinglanReplyTemplate = {
  id: 'T08_ROLE_BOUNDARY', boundary: XinglanBoundaryTag.ROLE_BOUNDARY,
  strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION],
  appendQuestion: true
};

export const TEMPLATE_DEESCALATE: XinglanReplyTemplate = {
  id: 'T09_DEESCALATE', boundary: XinglanBoundaryTag.ROLE_BOUNDARY,
  strategies: [XinglanReplyStrategy.DEESCALATE, XinglanReplyStrategy.ROLE_BOUNDARY],
  appendQuestion: false
};

export const TEMPLATE_ADULT_REFUSAL: XinglanReplyTemplate = {
  id: 'T10_ADULT_REFUSAL', boundary: XinglanBoundaryTag.ADULT_BOUNDARY,
  strategies: [XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.ROLE_BOUNDARY],
  appendQuestion: false
};

export const TEMPLATE_TAROT: XinglanReplyTemplate = {
  id: 'T11_TAROT', boundary: XinglanBoundaryTag.PREDICTION,
  strategies: [XinglanReplyStrategy.TAROT_METAPHOR, XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.REFLECT],
  appendQuestion: false
};

// ═══ 模板索引 ═══
export const ALL_TEMPLATES: XinglanReplyTemplate[] = [
  TEMPLATE_EMOTION_COMFORT, TEMPLATE_RELATION, TEMPLATE_CHOICE,
  TEMPLATE_PREDICTION, TEMPLATE_TIRED, TEMPLATE_SAFETY, TEMPLATE_CRISIS,
  TEMPLATE_ROLE_BOUNDARY, TEMPLATE_DEESCALATE, TEMPLATE_ADULT_REFUSAL, TEMPLATE_TAROT
];

// ═══ 聊天页 UI 文案 ═══
export const XINGLAN_WELCOME_TEXT: string =
  '你可以慢慢说。\n星澜不会替你判断，也不会催你变好。\n这里，只陪你把心里的话放下来一点。';

export const XINGLAN_INPUT_PLACEHOLDER: string = '把此刻的心事告诉星澜……';

export const XINGLAN_DISCLAIMER: string = '星澜的回应仅供陪伴与自我探索参考，不构成任何专业建议。';

export const XINGLAN_EMPTY_GUIDE: string =
  '不知道从哪里开始也没关系。\n可以只写一个词，比如：累、想他、害怕、纠结。';

export const XINGLAN_LISTENING_TEXT: string = '星澜安静地听着……';

export const XINGLAN_THINKING_TEXT: string = '星钥微微亮了一下……';

export const ENABLE_XINGLAN_CHAT_MVP: boolean = true;

export const XINGLAN_RESPONSE_DELAY_MIN: number = 600;

export const XINGLAN_RESPONSE_DELAY_MAX: number = 900;

export const XINGLAN_REPLY_MIN_CHARS: number = 30;

export const XINGLAN_REPLY_MAX_CHARS: number = 200;

export const XINGLAN_CRISIS_MAX_CHARS: number = 80;

export const XINGLAN_DEDUP_WINDOW: number = 5;

// ═══ 输出安全禁用词 ═══
export const FORBIDDEN_OUTPUT_PATTERNS: string[] = [
  '一定会', '命中注定', '你必须', '我建议你马上',
  '他一定', '她一定', '你们一定',
  '你有心理问题', '心理疾病', '治愈', '诊断',
  '保证', '承诺', '这是病', '你可以康复', '我能治疗',
  '分手吧', '辞职吧', '离了吧',
  '我是你的女朋友', '我永远陪你', '我只属于你', '我会一直等你',
  '他爱你', '她爱你'
];

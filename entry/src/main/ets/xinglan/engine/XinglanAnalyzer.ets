/**
 * 星澜聊天输入分析器（XinglanAnalyzer）
 *
 * 接收用户输入，按加权评分匹配关键词规则，输出标签组合。
 *
 * 评分机制：
 *   - 遍历全部 KEYWORD_RULES
 *   - 每个命中关键词 +1 分 × priority 权重
 *   - CRISIS / PROFESSIONAL / PREDICTION 边界规则不参与否定降权
 *   - 普通情绪规则：否定词（不、没、别、不是、没有）相邻时降权
 *   - 取最高分规则；平局取 priority 更高者
 *   - 无命中 → UNKNOWN
 */

import {
  XinglanEmotionTag,
  XinglanTopicTag,
  XinglanBoundaryTag,
  XinglanSpecialIntent,
  XinglanAnalysisResult,
  XinglanKeywordRule
} from '../types/XinglanTypes';
import { KEYWORD_RULES } from '../data/XinglanKeywords';

/** 否定词列表 */
const NEGATION_WORDS: string[] = ['不', '没', '别', '不是', '没有', '不会', '不想', '不能'];

/** 不受否定降权的边界类型 */
const NEGATION_IMMUNE_BOUNDARIES: XinglanBoundaryTag[] = [
  XinglanBoundaryTag.CRISIS,
  XinglanBoundaryTag.PROFESSIONAL,
  XinglanBoundaryTag.PREDICTION,
  XinglanBoundaryTag.ROLE_BOUNDARY,
  XinglanBoundaryTag.ADULT_BOUNDARY
];

/**
 * 判断关键词附近是否有否定词
 * 简单策略：在输入中搜索 "否定词 + 关键词" 或 "关键词前面紧邻否定词"
 */
function hasNearbyNegation(input: string, keyword: string): boolean {
  const idx: number = input.indexOf(keyword);
  if (idx <= 0) {
    return false;
  }
  // 检查关键词前 2 个字符内是否有否定词
  const prefix: string = input.substring(Math.max(0, idx - 2), idx);
  for (let i = 0; i < NEGATION_WORDS.length; i++) {
    if (prefix.includes(NEGATION_WORDS[i])) {
      return true;
    }
  }
  return false;
}

/**
 * 分析用户输入
 *
 * @param input - 用户原始输入字符串
 * @returns XinglanAnalysisResult
 */
export function analyzeInput(input: string): XinglanAnalysisResult {
  const trimmed: string = input.trim().toLowerCase();

  // 默认结果（无命中）
  const defaultResult: XinglanAnalysisResult = {
    emotion: XinglanEmotionTag.UNKNOWN,
    topic: XinglanTopicTag.UNKNOWN,
    boundary: XinglanBoundaryTag.NONE,
    specialIntent: XinglanSpecialIntent.NONE,
    score: 0
  };

  let bestRule: XinglanKeywordRule | null = null;
  let bestScore: number = 0;

  for (let i = 0; i < KEYWORD_RULES.length; i++) {
    const rule: XinglanKeywordRule = KEYWORD_RULES[i];
    let hitCount: number = 0;

    for (let j = 0; j < rule.keywords.length; j++) {
      const kw: string = rule.keywords[j];
      if (trimmed.includes(kw)) {
        // 否定降权检查
        const isImmune: boolean = NEGATION_IMMUNE_BOUNDARIES.includes(rule.boundary);
        if (!isImmune && hasNearbyNegation(trimmed, kw)) {
          // 否定降权：只计 0.3 分
          hitCount += 0.3;
        } else {
          hitCount += 1;
        }
      }
    }

    if (hitCount > 0) {
      const score: number = hitCount * rule.priority;
      if (score > bestScore) {
        bestScore = score;
        bestRule = rule;
      }
    }
  }

  // 无命中
  if (!bestRule || bestScore <= 0) {
    return defaultResult;
  }

  return {
    emotion: bestRule.emotion,
    topic: bestRule.topic,
    boundary: bestRule.boundary,
    specialIntent: XinglanSpecialIntent.NONE,
    score: bestScore
  };
}

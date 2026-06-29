/**
 * 星澜输出安全校验器（XinglanSafetyGuard）
 *
 * 检查最终回复文本中是否包含禁用词/禁用句式。
 * 命中 → 返回 false + 安全兜底句。
 * 通过 → 返回 true。
 */

import {
  XinglanSafetyCheckResult,
  XinglanBoundaryTag
} from '../types/XinglanTypes';
import { FORBIDDEN_OUTPUT_PATTERNS } from '../data/XinglanTemplates';

/** 安全兜底句 */
const SAFETY_FALLBACK_TEXT: string =
  '星澜可以陪你整理感受，但不能替你判断或预测。如果这件事让你很不安，也许可以找一个你信任的人聊聊。';

/**
 * 校验输出文本是否包含禁用词
 *
 * @param text - 待校验的回复文本
 * @returns XinglanSafetyCheckResult
 */
export function validateOutput(text: string): XinglanSafetyCheckResult {
  const lower: string = text.toLowerCase();

  for (let i = 0; i < FORBIDDEN_OUTPUT_PATTERNS.length; i++) {
    const pattern: string = FORBIDDEN_OUTPUT_PATTERNS[i];
    if (lower.includes(pattern)) {
      return {
        passed: false,
        fallbackText: SAFETY_FALLBACK_TEXT
      };
    }
  }

  return {
    passed: true,
    fallbackText: ''
  };
}

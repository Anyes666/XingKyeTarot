/**
 * 星澜直接回复引擎（Phase 5.3）
 */

import { findDirectReply } from '../data/XinglanDirectReplies';

export interface DirectReplyResult {
  hit: boolean;
  key: string;
  segments: string[];
  isUrgent: boolean;
}

export function tryDirectReply(input: string): DirectReplyResult {
  const match = findDirectReply(input);
  if (match) {
    return { hit: true, key: match.key, segments: match.segments, isUrgent: match.isUrgent };
  }
  return { hit: false, key: '', segments: [], isUrgent: false };
}

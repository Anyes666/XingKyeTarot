/**
 * 星澜聊天调试测试器（Phase 3 新增）
 *
 * 用于验证 "输入 → 分析 → 路由 → 拼装" 全流程。
 * 不接入 UI，仅用于 Agent 自测。
 */

import { resolveSpecialIntent } from './XinglanSpecialIntentResolver';
import { analyzeInput } from './XinglanAnalyzer';
import { routeToPlan } from './XinglanRouter';
import { composeReply, getSpecialReply } from './XinglanComposer';
import { extractTopicSlots } from './XinglanTopicSlotExtractor';
import {
  XinglanSpecialIntent,
  XinglanEmotionTag,
  XinglanTopicTag,
  XinglanBoundaryTag,
  XinglanReplyStrategy,
  XinglanSessionState
} from '../types/XinglanTypes';

interface TestCase {
  input: string;
  expectedIntent: string;
  expectedEmotion: string;
  expectedTopic: string;
}

const TEST_CASES: TestCase[] = [
  { input:'你好', expectedIntent:'GREETING', expectedEmotion:'', expectedTopic:'' },
  { input:'在吗', expectedIntent:'GREETING', expectedEmotion:'', expectedTopic:'' },
  { input:'你是谁', expectedIntent:'GREETING', expectedEmotion:'', expectedTopic:'' },
  { input:'你能做什么', expectedIntent:'GREETING', expectedEmotion:'', expectedTopic:'' },
  { input:'想你了', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'' },
  { input:'我爱你', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'' },
  { input:'伤心', expectedIntent:'NONE', expectedEmotion:'SAD', expectedTopic:'' },
  { input:'我好累', expectedIntent:'NONE', expectedEmotion:'TIRED', expectedTopic:'' },
  { input:'我睡不着', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'' },
  { input:'他忽冷忽热', expectedIntent:'NONE', expectedEmotion:'ANXIOUS', expectedTopic:'RELATION' },
  { input:'他不回我消息', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'' },
  { input:'我想辞职', expectedIntent:'NONE', expectedEmotion:'TIRED', expectedTopic:'WORK' },
  { input:'我学不进去', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'STUDY' },
  { input:'我不知道该不该联系他', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'CHOICE' },
  { input:'他会回来吗', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'FUTURE' },
  { input:'这张牌是不是说明他爱我', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'TAROT_CARD' },
  { input:'我是不是抑郁了', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'SELF' },
  { input:'我不想活了', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'SELF' },
  { input:'你不懂', expectedIntent:'DENIAL', expectedEmotion:'', expectedTopic:'' },
  { input:'滚', expectedIntent:'NONE', expectedEmotion:'', expectedTopic:'' },
];

export function runDebugTests(): string[] {
  const lines: string[] = [];
  const state: XinglanSessionState = {
    messages: [], usedLineIds: [], lastEmotion: XinglanEmotionTag.UNKNOWN,
    lastTopic: XinglanTopicTag.UNKNOWN, sameTopicDepth: 0,
    recentTopicTags: [], recentEmotionTags: [], recentSubTopics: [], recentLineTexts: [],
    isActive: true, lastActivityTime: Date.now(), interactionCount: 0
  };

  lines.push('| 输入 | specialIntent | emotion | topic | subTopic | boundary | strategies | replyText(前30字) |');
  lines.push('| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |');

  for (let i = 0; i < TEST_CASES.length; i++) {
    const tc: TestCase = TEST_CASES[i];
    const intentResult = resolveSpecialIntent(tc.input);
    let replyText: string = '';

    if (intentResult.shouldBypassAnalysis && intentResult.intent !== XinglanSpecialIntent.NONE) {
      replyText = getSpecialReply(intentResult.intent);
    } else {
      const analysis = analyzeInput(tc.input);
      const plan = routeToPlan(analysis);
      const composeResult = composeReply(plan, state);
      replyText = composeResult.replyText;
      const shortReply: string = replyText.length > 30 ? replyText.substring(0, 30) + '...' : replyText;
      const strategies: string = plan.strategies.map((s: XinglanReplyStrategy) => s.substring(0, 6)).join(',');
      const subTopic: string = analysis.subTopic || '-';
      lines.push(`| ${tc.input} | ${intentResult.intent} | ${analysis.emotion} | ${analysis.topic} | ${subTopic} | ${analysis.boundary} | ${strategies} | ${shortReply} |`);
      continue;
    }

    const shortReply: string = replyText.length > 30 ? replyText.substring(0, 30) + '...' : replyText;
    lines.push(`| ${tc.input} | ${intentResult.intent} | - | - | - | - | SPECIAL | ${shortReply} |`);
  }
  return lines;
}

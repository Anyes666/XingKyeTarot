/**
 * 星澜小互动引擎（Phase 5 新增）
 *
 * 匹配 triggerText，返回分段回复。
 * 命中后不走 Analyzer / Router / Corpus。
 */

import { XinglanMiniInteractionKey } from '../types/XinglanTypes';
import { XINGLAN_MINI_INTERACTIONS, XinglanMiniInteractionDef } from '../data/XinglanMiniInteractions';
import { getRandomPaperNote } from '../data/XinglanPaperNotes';

export function matchMiniInteraction(input: string): string[] {
  const trimmed: string = input.trim();

  for (let i = 0; i < XINGLAN_MINI_INTERACTIONS.length; i++) {
    const interaction: XinglanMiniInteractionDef = XINGLAN_MINI_INTERACTIONS[i];

    // 完全匹配 triggerText
    if (trimmed === interaction.triggerText) {
      return resolveSegments(interaction);
    }

    // 包含匹配
    if (trimmed.includes(interaction.triggerText)) {
      return resolveSegments(interaction);
    }

    // 别名匹配
    if (matchAlias(trimmed, interaction.key)) {
      return resolveSegments(interaction);
    }
  }

  return [];
}

function resolveSegments(interaction: XinglanMiniInteractionDef): string[] {
  // 小纸条特殊处理：随机填充
  if (interaction.key === XinglanMiniInteractionKey.GIVE_ME_A_NOTE) {
    const note: string = getRandomPaperNote();
    return [
      '星澜递给你一张很小的纸条：',
      '"' + note + '"',
      '如果你愿意，也可以告诉我：这句话戳中你了吗？'
    ];
  }
  return interaction.replySegments;
}

function matchAlias(input: string, key: XinglanMiniInteractionKey): boolean {
  const aliases: Record<string, string[]> = {
    'ASK_ME_A_QUESTION': ['问我一个问题','问我','问一个问题','问我个问题'],
    'RELIEVE_BOREDOM': ['陪我解闷','解闷','无聊陪我','帮我解闷'],
    'GIVE_ME_A_NOTE': ['给我小纸条','小纸条','纸条','给我一句小纸条','给我一个纸条'],
    'I_WANT_TO_TALK': ['说点心事','想说心事','说说心事','说心事'],
    'PICK_A_MOOD_WORD': ['心情词','选个心情','今天什么心情','心情','选一个词'],
    'GENTLE_CHOICE': ['二选一','选一个','轻轻二选一'],
    'PAT_XINGLAN': ['拍一下星澜','拍拍星澜','拍一拍','轻轻拍'],
    'NIGHT_LETTER': ['夜信','写一封信','写封信','写一封','星澜夜信']
  };
  const words: string[] = aliases[key] || [];
  for (let i = 0; i < words.length; i++) {
    if (input.includes(words[i])) { return true; }
  }
  return false;
}

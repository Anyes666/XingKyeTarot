/**
 * 星澜小互动定义（8 个）
 */

import { XinglanMiniInteractionKey } from '../types/XinglanTypes';

export interface XinglanMiniInteractionDef {
  key: XinglanMiniInteractionKey;
  title: string;
  triggerText: string;
  replySegments: string[];
}

export const XINGLAN_MINI_INTERACTIONS: XinglanMiniInteractionDef[] = [
  {
    key: XinglanMiniInteractionKey.ASK_ME_A_QUESTION,
    title: '星澜问我一个问题',
    triggerText: '星澜问我一个问题',
    replySegments: [
      '那我问一个很轻的问题。',
      '如果今天的心情是一种天气，它更像阴天、小雨，还是有风的夜晚？',
      '不用解释太多，选一个最像的就好。'
    ]
  },
  {
    key: XinglanMiniInteractionKey.RELIEVE_BOREDOM,
    title: '陪我解闷',
    triggerText: '陪我解闷',
    replySegments: [
      '好，我们先不聊沉重的。',
      '我给你一个二选一。',
      '现在的你更想被逗笑一下，还是被安静陪着？'
    ]
  },
  {
    key: XinglanMiniInteractionKey.GIVE_ME_A_NOTE,
    title: '给我一句小纸条',
    triggerText: '给我一句小纸条',
    replySegments: []  // 运行时从 PaperNotes 随机填充
  },
  {
    key: XinglanMiniInteractionKey.I_WANT_TO_TALK,
    title: '我想说点心事',
    triggerText: '我想说点心事',
    replySegments: [
      '好。',
      '你可以慢慢说，也可以先只说一个词。',
      '星澜会先听，不急着给答案。'
    ]
  },
  {
    key: XinglanMiniInteractionKey.PICK_A_MOOD_WORD,
    title: '选一个心情词',
    triggerText: '选一个心情词',
    replySegments: [
      '给现在的心情选一个词吧。',
      '是"有点累""想躲起来""还在撑""需要抱抱"，还是"说不清"？',
      '选哪个都可以，不需要很准确。'
    ]
  },
  {
    key: XinglanMiniInteractionKey.GENTLE_CHOICE,
    title: '来个轻轻二选一',
    triggerText: '来个轻轻二选一',
    replySegments: [
      '那我们玩一个很轻的二选一。',
      '现在的你更想：A. 被安慰一下，还是 B. 被逗一下？',
      '你只要回 A 或 B 就好。'
    ]
  },
  {
    key: XinglanMiniInteractionKey.PAT_XINGLAN,
    title: '轻轻拍一下星澜',
    triggerText: '轻轻拍一下星澜',
    replySegments: [
      '你轻轻碰了碰星钥。',
      '星澜抬头看了你一眼。',
      '"我在，慢慢说。"'
    ]
  },
  {
    key: XinglanMiniInteractionKey.NIGHT_LETTER,
    title: '写一封星澜夜信',
    triggerText: '写一封星澜夜信',
    replySegments: [
      '这可以是一封慢一点的心事。',
      '你不用写得漂亮，也不用一次说清。',
      '星澜会把它当成一封夜里的信，认真收下。'
    ]
  }
];

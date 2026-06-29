/**
 * 星澜陪伴模式引擎（Phase 5 新增）
 *
 * 识别解闷、闲聊、安静陪伴请求，返回分段回复。
 * 命中后不走 Analyzer / Router / Corpus。
 */

import {
  XinglanCompanionMode,
  XinglanCompanionModeResult
} from '../types/XinglanTypes';

interface CompanionPattern {
  keywords: string[];
  mode: XinglanCompanionMode;
  segments: string[];
}

const COMPANION_PATTERNS: CompanionPattern[] = [
  {
    keywords: ['好无聊','无聊','不知道干嘛','不知道做什么','好闲','没事做','没事干'],
    mode: XinglanCompanionMode.BOREDOM_RELIEF,
    segments: [
      '那星澜先陪你把这一小段无聊打发掉。',
      '我们可以不聊大道理，也不用马上变得积极。',
      '你想玩一个很轻的小选择，还是让我问你一个奇怪但温柔的问题？'
    ]
  },
  {
    keywords: ['陪我聊聊','陪我说说话','想找人说话','陪我说话','和我聊聊','随便聊聊','聊聊天'],
    mode: XinglanCompanionMode.LIGHT_CHAT,
    segments: [
      '好。',
      '今天我们不急着解决什么。',
      '你可以随便说一句，我会接住。要不先从一个很小的问题开始：你现在更想被逗笑，还是被安静陪着？'
    ]
  },
  {
    keywords: ['不知道说什么','不知道说啥','不知道聊什么','不知道怎么说'],
    mode: XinglanCompanionMode.QUIET_COMPANY,
    segments: [
      '不知道说什么，也可以。',
      '有时候心里不是空白，只是还没有找到开口的地方。',
      '你可以先发一个词：累、烦、想哭、想恋爱，或者"随便陪我聊聊"。'
    ]
  },
  {
    keywords: ['别讲大道理','不讲大道理','不要讲道理','不要大道理'],
    mode: XinglanCompanionMode.QUIET_COMPANY,
    segments: [
      '好，那星澜先不讲大道理。',
      '我们只把这一刻过轻一点。',
      '你可以说一句很短的话，我只负责接住，不急着分析。'
    ]
  },
  {
    keywords: ['不想一个人','不想一个人待着','想有人陪着','陪我一会儿','安静陪我'],
    mode: XinglanCompanionMode.QUIET_COMPANY,
    segments: [
      '好。',
      '星澜不会走。',
      '你不必说很多，只要你知道这里有人在听，就已经够了。'
    ]
  },
  {
    keywords: ['逗我一下','逗我','讲个笑话','让我笑一下'],
    mode: XinglanCompanionMode.BOREDOM_RELIEF,
    segments: [
      '星澜不擅长讲笑话。',
      '但如果你愿意，我可以问你一个很奇怪但温柔的问题。',
      '比如：如果你现在可以变成一种天气，你想变成什么——蒙蒙细雨，还是傍晚的风？'
    ]
  }
];

export function resolveCompanionMode(input: string): XinglanCompanionModeResult {
  const trimmed: string = input.trim();
  for (let i = 0; i < COMPANION_PATTERNS.length; i++) {
    const pattern = COMPANION_PATTERNS[i];
    for (let j = 0; j < pattern.keywords.length; j++) {
      if (trimmed.includes(pattern.keywords[j])) {
        return {
          mode: pattern.mode,
          shouldBypassNormalReply: true,
          replySegments: pattern.segments
        };
      }
    }
  }
  return {
    mode: XinglanCompanionMode.NONE,
    shouldBypassNormalReply: false,
    replySegments: []
  };
}

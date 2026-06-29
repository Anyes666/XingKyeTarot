/**
 * 星澜问题绑定选项数据（Phase 5.7.1）
 *
 * 每个星澜提问都绑定一组专属选项，替换默认 chips。
 */

import {
  XinglanQuestionId, XinglanQuestionOption, XinglanPendingQuestion,
  XinglanInteractionFlowId, XinglanEmotionTag, XinglanTopicTag
} from '../types/XinglanTypes';

// ═══ 辅助工厂函数 ═══

function makeOption(
  id: string, label: string, userText: string, replyLines: string[],
  nextOptions: XinglanQuestionOption[],
  nextFlowId: XinglanInteractionFlowId,
  clearAfterSelect: boolean,
  emotionTag: XinglanEmotionTag,
  topicTag: XinglanTopicTag
): XinglanQuestionOption {
  return {
    id: id, label: label, userText: userText, replyLines: replyLines,
    nextOptions: nextOptions, nextFlowId: nextFlowId, clearAfterSelect: clearAfterSelect,
    emotionTag: emotionTag, topicTag: topicTag
  };
}

function emptyOptions(): XinglanQuestionOption[] {
  return [];
}

function noFlow(): XinglanInteractionFlowId {
  return XinglanInteractionFlowId.NONE;
}

// ═══ 天气问题 — 二级选项模板 ═══

const MOOD_CLOUDY_NEXT: XinglanQuestionOption[] = [
  makeOption('MC_TALK', '想说说为什么', '想说说为什么',
    ['好，你说，我认真听。', '不需要说得很清楚，有一点影子就好。'],
    emptyOptions(), noFlow(), true,
    XinglanEmotionTag.SAD, XinglanTopicTag.ANY),
  makeOption('MC_NOTE', '给我一句小纸条', '给我一句小纸条',
    ['好，星澜给你一张小纸条。'],
    emptyOptions(), XinglanInteractionFlowId.PAPER_NOTE_FLOW, true,
    XinglanEmotionTag.SAD, XinglanTopicTag.ANY),
  makeOption('MC_QUIET', '陪我安静一下', '陪我安静一下',
    ['好。星澜在这里，不说话。', '你可以闭上眼睛，也可以只是看着这里。', '星澜不走。'],
    emptyOptions(), noFlow(), true,
    XinglanEmotionTag.SAD, XinglanTopicTag.ANY)
];

const MOOD_RAIN_NEXT: XinglanQuestionOption[] = [
  makeOption('MR_CRY', '我有点想哭', '我有点想哭',
    ['那就让眼泪流出来吧。', '星澜不会说"别哭了"。', '哭一会儿也没关系。'],
    emptyOptions(), noFlow(), true,
    XinglanEmotionTag.SAD, XinglanTopicTag.SELF),
  makeOption('MR_STUFFY', '我只是有点闷', '我只是有点闷',
    ['闷着的时候，比大哭还难熬。', '你不需要把它变成什么大事。', '就让它在那里，星澜陪你。'],
    emptyOptions(), noFlow(), true,
    XinglanEmotionTag.NUMB, XinglanTopicTag.SELF),
  makeOption('MR_LIGHT', '给我一句轻一点的话', '给我一句轻一点的话',
    ['好。'],
    emptyOptions(), XinglanInteractionFlowId.PAPER_NOTE_FLOW, true,
    XinglanEmotionTag.SAD, XinglanTopicTag.ANY)
];

const MOOD_WINDY_NEXT: XinglanQuestionOption[] = [
  makeOption('MW_CHAOS', '我心里很乱', '我心里很乱',
    ['当很多声音在心里一起响的时候，', '最累的不是哪一个声音，而是停不下来。', '你不用现在就理清楚。先让星澜陪着你。'],
    emptyOptions(), noFlow(), true,
    XinglanEmotionTag.ANXIOUS, XinglanTopicTag.SELF),
  makeOption('MW_SORT', '我想理一理', '我想理一理',
    ['好。你不用一次说清，可以只说一根线头。', '你想先说关系、工作，还是自己？'],
    emptyOptions(), noFlow(), true,
    XinglanEmotionTag.CONFUSED, XinglanTopicTag.CHOICE),
  makeOption('MW_QUIET', '我想先安静', '我想先安静',
    ['嗯。有些声音不是需要被理清，而是需要被听到。', '星澜在这里，安静地听。'],
    emptyOptions(), noFlow(), true,
    XinglanEmotionTag.ANXIOUS, XinglanTopicTag.SELF)
];

const MOOD_NONE_LIKE_NEXT: XinglanQuestionOption[] = [
  makeOption('MN_SWITCH', '换一种问法', '换一种问法',
    ['好。那不用天气。', '如果现在的心情是一首音乐，它更像哪种？'],
    emptyOptions(), noFlow(), true,
    XinglanEmotionTag.UNKNOWN, XinglanTopicTag.ANY),
  makeOption('MN_SELF', '我自己说说', '我自己说说',
    ['好，你说。', '不用整理，星澜帮你接着。'],
    emptyOptions(), noFlow(), true,
    XinglanEmotionTag.UNKNOWN, XinglanTopicTag.SELF),
  makeOption('MN_NOTE', '给我小纸条', '给我一句小纸条',
    ['好。'],
    emptyOptions(), XinglanInteractionFlowId.PAPER_NOTE_FLOW, true,
    XinglanEmotionTag.UNKNOWN, XinglanTopicTag.ANY)
];

// ═══ 天气问题 — 一级选项 ═══

const MOOD_WEATHER_OPTIONS: XinglanQuestionOption[] = [
  makeOption('MW_CLOUDY', '阴天', '阴天',
    ['那今天的心也许有点低低的、沉沉的。', '不一定是坏天气，只是它需要一点慢下来的空间。'],
    MOOD_CLOUDY_NEXT, noFlow(), false,
    XinglanEmotionTag.SAD, XinglanTopicTag.SELF),
  makeOption('MW_RAIN', '小雨', '小雨',
    ['小雨像是那些没有大声哭出来的难过。', '它不吵，但会一点点把心打湿。'],
    MOOD_RAIN_NEXT, noFlow(), false,
    XinglanEmotionTag.SAD, XinglanTopicTag.SELF),
  makeOption('MW_WINDY', '有风的夜晚', '有风的夜晚',
    ['有风的夜晚，像心里有很多声音在来回走。', '也许你不是没有答案，只是还没有安静下来。'],
    MOOD_WINDY_NEXT, noFlow(), false,
    XinglanEmotionTag.ANXIOUS, XinglanTopicTag.SELF),
  makeOption('MW_NONE', '都不像', '都不像',
    ['那也没关系。', '有些心情本来就不容易被一个词装下。'],
    MOOD_NONE_LIKE_NEXT, noFlow(), false,
    XinglanEmotionTag.UNKNOWN, XinglanTopicTag.SELF)
];

// ═══ 待回答问题构建器 ═══

export function createMoodWeatherQuestion(): XinglanPendingQuestion {
  return {
    questionId: XinglanQuestionId.MOOD_WEATHER,
    questionText: '如果今天的心情是一种天气，它更像阴天、小雨，还是有风的夜晚？',
    options: MOOD_WEATHER_OPTIONS,
    allowFreeText: true,
    sourceFlowId: XinglanInteractionFlowId.NONE,
    createdAt: Date.now()
  };
}

// ═══ 按问题 ID 查找 ═══

export function findQuestionOptions(questionId: XinglanQuestionId): XinglanPendingQuestion {
  if (questionId === XinglanQuestionId.MOOD_WEATHER) {
    return createMoodWeatherQuestion();
  }
  return {
    questionId: XinglanQuestionId.NONE,
    questionText: '',
    options: [],
    allowFreeText: true,
    sourceFlowId: XinglanInteractionFlowId.NONE,
    createdAt: 0
  };
}

// ═══ 按选项 ID 查找 ═══

export function findOptionById(options: XinglanQuestionOption[], optionId: string): XinglanQuestionOption | null {
  for (let i = 0; i < options.length; i++) {
    if (options[i].id === optionId) {
      return options[i];
    }
  }
  return null;
}

// ═══ 自由文本模糊匹配选项 ═══

export function fuzzyMatchOption(input: string, options: XinglanQuestionOption[]): XinglanQuestionOption | null {
  const trimmed: string = input.trim();
  if (trimmed.length === 0) {
    return null;
  }

  // 精确匹配 label 或 userText
  for (let i = 0; i < options.length; i++) {
    if (trimmed === options[i].label || trimmed === options[i].userText) {
      return options[i];
    }
  }

  // 包含匹配
  for (let i = 0; i < options.length; i++) {
    if (trimmed.includes(options[i].label) || trimmed.includes(options[i].userText)) {
      return options[i];
    }
  }

  // 短输入同义词匹配
  const shortText: string = trimmed.toLowerCase();
  const synonyms: Record<string, string> = {
    '阴天吧': 'MW_CLOUDY', '阴': 'MW_CLOUDY', '阴的': 'MW_CLOUDY',
    '小雨吧': 'MW_RAIN', '雨': 'MW_RAIN', '下雨': 'MW_RAIN',
    '有风': 'MW_WINDY', '风': 'MW_WINDY', '大风': 'MW_WINDY',
    '都不': 'MW_NONE', '都不是': 'MW_NONE', '不是': 'MW_NONE'
  };

  const synId: string = synonyms[shortText] || '';
  if (synId.length > 0) {
    return findOptionById(options, synId);
  }

  return null;
}

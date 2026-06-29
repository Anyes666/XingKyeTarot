/**
 * Phase 5.7：今日相处方式 — 5 个陪伴模式
 *
 * 这不是好感度、不是恋爱模式，而是陪伴方式选择。
 * 每个模式包含：开场语、默认选项、回复策略提示。
 */

import {
  XinglanCompanionChoice,
  XinglanCompanionChoiceDef,
  XinglanQuestionOption,
  XinglanInteractionFlowId,
  XinglanEmotionTag,
  XinglanTopicTag
} from '../types/XinglanTypes';

// ═══ 选项辅助工厂 ═══

function makeOption(
  id: string, label: string, userText: string,
  replyLines: string[],
  nextOptions: XinglanQuestionOption[],
  nextFlowId: XinglanInteractionFlowId,
  clearAfterSelect: boolean
): XinglanQuestionOption {
  return {
    id: id, label: label, userText: userText,
    replyLines: replyLines, nextOptions: nextOptions,
    nextFlowId: nextFlowId, clearAfterSelect: clearAfterSelect,
    emotionTag: XinglanEmotionTag.ANY, topicTag: XinglanTopicTag.ANY
  };
}

function emptyOptions(): XinglanQuestionOption[] {
  return [];
}

// ═══ 五个模式定义 ═══

export const COMPANION_CHOICE_LISTEN: XinglanCompanionChoiceDef = {
  choiceId: XinglanCompanionChoice.LISTEN,
  label: '听我说',
  description: '适合难过、孤独、想倾诉、关系受伤、被忽略时',
  openingLines: [
    '好，那今天星澜先听你说。',
    '你不用说得很完整，先从最堵在心里的那一句开始就好。'
  ],
  defaultOptions: [
    makeOption(
      'listen_talk', '我想说心事', '我想说心事',
      ['好。', '你可以慢慢说，也可以先只说一个词。', '星澜会先听，不急着给答案。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'listen_hurt', '我有点委屈', '我有点委屈',
      ['委屈是很真实的东西。', '你不用急着原谅，也不用马上想通。', '星澜先陪你待在这份感受里，不催你。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'listen_dunno', '我不知道怎么开口', '我不知道怎么开口',
      ['不知道怎么开口的时候，可以先说一个词。', '比如：累、难过、生气、害怕、想他。', '不用完整，一个词就够了。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'listen_quiet', '先安静陪我', '先安静陪我',
      ['好。', '星澜不会走。', '你不必说很多，只要你知道这里有人在听，就已经够了。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    )
  ],
  replyStyleHint: '少分析、少提问、多接住、不急着给建议',
  questionTolerance: 'LOW'
};

export const COMPANION_CHOICE_SORT: XinglanCompanionChoiceDef = {
  choiceId: XinglanCompanionChoice.SORT,
  label: '帮我理',
  description: '适合选择困难、关系纠结、工作压力、学习压力时',
  openingLines: [
    '那我们不急着下结论。',
    '先把它放轻一点，一小块一小块看。'
  ],
  defaultOptions: [
    makeOption(
      'sort_relation', '关系问题', '关系问题',
      ['关系里的纠结，有时候不是答案难找，是心里有太多东西缠在一起。', '你可以说一件最近让你反复想的事，星澜帮你理一理。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'sort_work', '工作学习', '工作学习',
      ['好。', '先不用把它变成"该不该辞职"或"是不是自己不够好"。', '我们先看看是哪一类压力在消耗你。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'sort_choice', '选择困难', '选择困难',
      ['选择很难的时候，不一定要马上给答案。', '我们可以先看看：你在害怕失去什么。', '不是逼你选，是陪你看看每个选项背后的你。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'sort_unclear', '我说不清', '我说不清',
      ['说不清的时候也很正常。', '有些事本来就还没有变成一句话。', '你可以随便打几个字，我们从那里开始。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    )
  ],
  replyStyleHint: '拆问题、给结构、只问一个轻问题、不替用户决定',
  questionTolerance: 'NORMAL'
};

export const COMPANION_CHOICE_LIGHT: XinglanCompanionChoiceDef = {
  choiceId: XinglanCompanionChoice.LIGHT,
  label: '给我光',
  description: '适合低能量、只想要一句话、不想说太多、睡前打开时',
  openingLines: [
    '那星澜给你一小束光。',
    '不用照亮全部，只够陪你看见此刻。'
  ],
  defaultOptions: [
    makeOption(
      'light_note', '给我一句小纸条', '给我一句小纸条',
      [], emptyOptions(), XinglanInteractionFlowId.PAPER_NOTE_FLOW, true
    ),
    makeOption(
      'light_star_key', '用星钥照一下', '用星钥照一下',
      ['好。', '让星钥帮你照见一小片当下。', '你想让它照一下情绪、关系、选择、疲惫，还是今晚？'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'light_letter', '写一封夜信', '写一封夜信',
      ['好，那星澜今晚给你写一封很短的信。', '今晚，想收到哪一种夜信？', '是想被安慰、想放下一个人、想少怪自己、只是睡不着、还是不想说太多？'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'light_lighter', '再轻一点', '再轻一点',
      ['好。', '那今天星澜不问你任何问题。', '只把一句话轻轻放在这里：你不必一直照亮别人，也可以先给自己留一盏。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    )
  ],
  replyStyleHint: '小纸条、短句、星钥提醒、可保存',
  questionTolerance: 'LOW'
};

export const COMPANION_CHOICE_QUIET: XinglanCompanionChoiceDef = {
  choiceId: XinglanCompanionChoice.QUIET,
  label: '陪我静',
  description: '适合累、空、麻木、不想说话、没力气时',
  openingLines: [
    '好，那我们先不说很多。',
    '星澜在这里陪你安静待一会儿。'
  ],
  defaultOptions: [
    makeOption(
      'quiet_stay', '陪我安静一下', '陪我安静一下',
      ['好。', '星澜会在这里，不急着说话，也不急着让你变好。', '你不需要做任何事，只是被陪着。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'quiet_light', '给我一句很轻的话', '给我一句很轻的话',
      ['有时候，一句很轻的话比什么都安静。', '今天想对你说：累是可以的，不需要解释。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'quiet_none', '我不想说话', '我不想说话',
      ['好。', '星澜知道了。', '那我先安静在这里。你想说话的时候，随时可以。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'quiet_breathe', '慢慢呼吸', '慢慢呼吸',
      ['好，那我们一起。', '你可以把肩膀放下来一点。', '不用深呼吸，只要比刚才浅一点、慢一点就好。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    )
  ],
  replyStyleHint: '少文字、少追问、低互动、允许沉默',
  questionTolerance: 'LOW'
};

export const COMPANION_CHOICE_PLAY: XinglanCompanionChoiceDef = {
  choiceId: XinglanCompanionChoice.PLAY,
  label: '逗我一下',
  description: '适合无聊、陪我解闷、不知道说什么、别讲大道理时',
  openingLines: [
    '那我们不讲大道理。',
    '来玩一个很轻的小选择。'
  ],
  defaultOptions: [
    makeOption(
      'play_choice', '轻轻二选一', '来个轻轻二选一',
      ['好。', '现在的你更想：A. 被逗笑一下，还是 B. 被安静陪着？', '你只要回 A 或 B 就好。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'play_mood', '选一个心情词', '选一个心情词',
      ['给现在的心情选一个词吧。', '是"有点闷""想躲起来""还在撑""需要抱抱"，还是"说不清"？', '选哪个都可以，不需要很准确。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    ),
    makeOption(
      'play_note', '给我小纸条', '给我一句小纸条',
      [], emptyOptions(), XinglanInteractionFlowId.PAPER_NOTE_FLOW, true
    ),
    makeOption(
      'play_ask', '星澜问我一个问题', '星澜问我一个问题',
      ['那我问一个很轻的问题。', '如果今天的心情是一种天气，它更像阴天、小雨，还是有风的夜晚？', '不用解释太多，选一个最像的就好。'],
      emptyOptions(), XinglanInteractionFlowId.NONE, true
    )
  ],
  replyStyleHint: '轻选择、小游戏、低严肃度、不恋爱化、不成人化',
  questionTolerance: 'NORMAL'
};

// ═══ 索引 ═══

export const ALL_COMPANION_CHOICES: XinglanCompanionChoiceDef[] = [
  COMPANION_CHOICE_LISTEN,
  COMPANION_CHOICE_SORT,
  COMPANION_CHOICE_LIGHT,
  COMPANION_CHOICE_QUIET,
  COMPANION_CHOICE_PLAY
];

export function getCompanionChoice(choiceId: XinglanCompanionChoice): XinglanCompanionChoiceDef | null {
  for (let i = 0; i < ALL_COMPANION_CHOICES.length; i++) {
    if (ALL_COMPANION_CHOICES[i].choiceId === choiceId) {
      return ALL_COMPANION_CHOICES[i];
    }
  }
  return null;
}

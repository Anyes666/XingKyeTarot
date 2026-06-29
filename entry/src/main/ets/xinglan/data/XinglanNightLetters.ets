/**
 * Phase 5.8：星澜夜信卡片数据
 *
 * 5 个夜信主题，每个 6-8 封本地文案。
 * 不接大模型，全部来自规则模板。
 */

import {
  XinglanNightLetterTheme, XinglanNightLetter,
  XinglanEmotionTag, XinglanTopicTag
} from '../types/XinglanTypes';

// ═══ 辅助工厂 ═══

let letterIdCounter: number = 0;

function makeLetter(
  theme: XinglanNightLetterTheme,
  title: string,
  bodyLines: string[],
  emotionTag: XinglanEmotionTag,
  topicTag: XinglanTopicTag
): XinglanNightLetter {
  letterIdCounter += 1;
  return {
    id: `night_letter_${letterIdCounter}`,
    theme: theme, title: title, bodyLines: bodyLines,
    emotionTag: emotionTag, topicTag: topicTag,
    createdAt: 0, isSaved: false
  };
}

// ═══ 1. COMFORT：我想被安慰 ═══

const COMFORT_LETTERS: XinglanNightLetter[] = [
  makeLetter(XinglanNightLetterTheme.COMFORT, '给今晚的你',
    [
      '不用急着把自己变好。',
      '有些夜晚，只要不继续责怪自己，就已经是在慢慢回来了。',
      '如果现在还睡不着，也不用和自己生气。',
      '你可以先把今天放轻一点，让心不用再继续站岗。'
    ],
    XinglanEmotionTag.SAD, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.COMFORT, '给感到孤单的你',
    [
      '孤单不是因为你不够好。',
      '有时候只是这颗心太敏感，才装得下这么多细微的东西。',
      '今晚不急着解决什么。',
      '你先把自己当成需要被照顾的人，轻轻地。'
    ],
    XinglanEmotionTag.LONELY, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.COMFORT, '给努力了很久的你',
    [
      '你已经做得很好了。',
      '这句话可能听起来很轻，但星澜是认真的。',
      '那些别人没看见的坚持，那些你自己都没说出来的难，',
      '它们不是白费的。它们都在你里面。'
    ],
    XinglanEmotionTag.TIRED, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.COMFORT, '给感到委屈的你',
    [
      '委屈有时候比难过更难说出口。',
      '因为它藏着一句：我已经很努力了，为什么还是这样？',
      '今晚不用急着原谅谁，也不用马上想通。',
      '你先把自己从"该不该委屈"里放出来。'
    ],
    XinglanEmotionTag.ANGRY, XinglanTopicTag.RELATION
  ),
  makeLetter(XinglanNightLetterTheme.COMFORT, '给累了但睡不着的你',
    [
      '身体已经很累了，但脑子还在走。',
      '像一间关了灯的屋子，但里面有人在踱步。',
      '今晚不逼自己停下来。',
      '就让它慢慢走，走到走不动为止。'
    ],
    XinglanEmotionTag.TIRED, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.COMFORT, '给想哭又哭不出来的你',
    [
      '有些难过，还没有找到出口。',
      '它不一定是大事情，只是攒得太久了。',
      '今晚不用非得哭出来。',
      '就让它停在那里，你不需要立刻处理它。'
    ],
    XinglanEmotionTag.SAD, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.COMFORT, '给不知道自己在难过什么的你',
    [
      '有时候难过没有明确的原因。',
      '就像阴天，你说不清哪一片云带了雨，但天就是沉了。',
      '这种难过也是真实的。',
      '不需要给它命名，也不需要马上驱散它。'
    ],
    XinglanEmotionTag.SAD, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.COMFORT, '给觉得被世界忽略的你',
    [
      '不被看见的感觉，很轻也很重。',
      '像在一间很大的房间里，但没人注意到你站在那里。',
      '星澜看见你了。',
      '不需要变得更好看、更成功、更值得，你已经值得被认真对待。'
    ],
    XinglanEmotionTag.LONELY, XinglanTopicTag.SELF
  )
];

// ═══ 2. LET_GO：我想放下一个人 ═══

const LET_GO_LETTERS: XinglanNightLetter[] = [
  makeLetter(XinglanNightLetterTheme.LET_GO, '给还在等待回应的你',
    [
      '等一个人的回应，像把心放在别人门口。',
      '你不知道他什么时候开门，甚至不知道他会不会开门。',
      '今晚不劝你放下。',
      '只是想说：你可以先把心拿回来暖一会儿，它冷了很久了。'
    ],
    XinglanEmotionTag.ANXIOUS, XinglanTopicTag.RELATION
  ),
  makeLetter(XinglanNightLetterTheme.LET_GO, '给反复想起他的你',
    [
      '有些人的离开不是一次性完成的。',
      '他们会在你不经意的时候回来——不是人回来，是记忆回来。',
      '这不是你不够坚决。',
      '只是这颗心曾经认真地靠近过，所以需要更多时间来走远。'
    ],
    XinglanEmotionTag.SAD, XinglanTopicTag.RELATION
  ),
  makeLetter(XinglanNightLetterTheme.LET_GO, '给不确定要不要放下的你',
    [
      '不一定现在就要放下。',
      '有些关系不是非黑即白的，有些人不一定非得从心里彻底删除。',
      '今晚先不逼自己做决定。',
      '你可以只是把这件事放轻一点，先让自己不那么累。'
    ],
    XinglanEmotionTag.CONFUSED, XinglanTopicTag.RELATION
  ),
  makeLetter(XinglanNightLetterTheme.LET_GO, '给被冷落后的你',
    [
      '不被回应的时候，最难熬的不是等，而是反复猜测。',
      '"是不是我说错了什么""是不是我不够好"。',
      '今晚想把这句话轻轻放在这里：',
      '他的沉默是他的选择，不是你的价值。'
    ],
    XinglanEmotionTag.ANXIOUS, XinglanTopicTag.RELATION
  ),
  makeLetter(XinglanNightLetterTheme.LET_GO, '给想起前任的你',
    [
      '回忆不是失败。',
      '那些曾经认真过的东西，不会因为结束就全部消失。',
      '今晚不评判你的想念。',
      '只是提醒你：你值得被好好地对待，包括被自己好好地对待。'
    ],
    XinglanEmotionTag.SAD, XinglanTopicTag.RELATION
  ),
  makeLetter(XinglanNightLetterTheme.LET_GO, '给觉得不甘心的你',
    [
      '不甘心里面，有时候不是还爱着，而是还没有被好好说再见。',
      '那个问号一直悬在那里，让你走不远。',
      '今晚不一定非要得到答案。',
      '你可以先把那个问号，轻轻地放在枕边，明天再说。'
    ],
    XinglanEmotionTag.ANGRY, XinglanTopicTag.RELATION
  ),
  makeLetter(XinglanNightLetterTheme.LET_GO, '给在关系里被消耗的你',
    [
      '有些关系不是靠你一个人就能维持的。',
      '你一直往前走，但对方站在原地，这不是你走得不够快。',
      '今晚想轻轻问你一句：',
      '这段关系里，你还记得自己最初的样子吗？'
    ],
    XinglanEmotionTag.TIRED, XinglanTopicTag.RELATION
  ),
  makeLetter(XinglanNightLetterTheme.LET_GO, '给心还疼着的你',
    [
      '有些疼不是马上就能好的。',
      '就像伤口需要时间愈合，心也需要。',
      '今晚不催你。',
      '疼是可以的，想他也可以。你不用逼自己好起来。'
    ],
    XinglanEmotionTag.SAD, XinglanTopicTag.RELATION
  )
];

// ═══ 3. SELF_FORGIVE：我想少怪自己 ═══

const SELF_FORGIVE_LETTERS: XinglanNightLetter[] = [
  makeLetter(XinglanNightLetterTheme.SELF_FORGIVE, '给总是觉得自己不够好的你',
    [
      '那个声音总是在夜深的时候最响。',
      '"你不够好""你不配""别人都比你强"。',
      '今晚想告诉你：那个声音不代表真相。',
      '它只是你心里的一个旧习惯，不是法官。'
    ],
    XinglanEmotionTag.GUILTY, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.SELF_FORGIVE, '给对自己太严格的你',
    [
      '你对自己的标准，有时候比你对任何人都严格。',
      '犯了一个小错，你会自责很久；做了一件事，你总觉得不够完美。',
      '今晚想把这句话给你：',
      '你不需要每件事都做对，才能被喜欢。包括被自己喜欢。'
    ],
    XinglanEmotionTag.GUILTY, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.SELF_FORGIVE, '给犯了错的你',
    [
      '犯错的时候，最难原谅的不是别人，是自己。',
      '那个瞬间会被反复回放，每一次都像新的伤害。',
      '今晚不劝你原谅自己。',
      '只是想说：你不是那个错误，你只是犯了一个错。这两件事不一样。'
    ],
    XinglanEmotionTag.GUILTY, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.SELF_FORGIVE, '给习惯讨好别人的你',
    [
      '你总是先照顾别人的感受，再想起自己。',
      '你说"没关系"的时候，有时候是"有关系"的。',
      '今晚想轻轻问一句：',
      '如果今晚不用讨好任何人，你最想做的是什么？'
    ],
    XinglanEmotionTag.TIRED, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.SELF_FORGIVE, '给觉得自己不够勇敢的你',
    [
      '不勇敢不代表你弱。',
      '有时候退缩是一种智慧，沉默是一种力量。',
      '今晚不用逼自己勇敢。',
      '你已经在面对了，光是面对这件事，就已经很勇敢。'
    ],
    XinglanEmotionTag.GUILTY, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.SELF_FORGIVE, '给在比较中受伤的你',
    [
      '看到别人过得好的时候，你心里那个"我不够好"又响了。',
      '但别人的生活不是你的标准。',
      '他们走得快，不代表你走得慢就是失败。',
      '你的节奏就是你的节奏，不需要和别人对齐。'
    ],
    XinglanEmotionTag.ANXIOUS, XinglanTopicTag.SELF
  )
];

// ═══ 4. INSOMNIA：我只是睡不着 ═══

const INSOMNIA_LETTERS: XinglanNightLetter[] = [
  makeLetter(XinglanNightLetterTheme.INSOMNIA, '给翻来覆去的你',
    [
      '失眠的夜晚，时间变得很慢。',
      '每翻一次身，脑子就多走一段路。',
      '今晚不劝你数羊，也不催你放松。',
      '就让它醒着吧，你不必对抗它。醒着也可以是被允许的。'
    ],
    XinglanEmotionTag.TIRED, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.INSOMNIA, '给脑子里停不下来的你',
    [
      '脑子像一间深夜的会议室，议题一个接一个。',
      '不是你不累，是你的心还没找到关灯的地方。',
      '今晚不试着关掉它。',
      '就让那些念头像窗外的车声一样，来就来了，走就走了。'
    ],
    XinglanEmotionTag.ANXIOUS, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.INSOMNIA, '给凌晨三点还在刷手机的你',
    [
      '屏幕的光在黑暗里格外刺眼，但你放不下。',
      '不是手机有多好看，是放下之后那种安静让人不安。',
      '今晚可以先把手机亮度调到最低。',
      '然后放一首很轻的音乐，不一定要睡着，只是换一种方式醒着。'
    ],
    XinglanEmotionTag.NUMB, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.INSOMNIA, '给害怕明天到来的你',
    [
      '明天像一个很大的东西压在胸口。',
      '你越想"必须睡着"，就越睡不着。',
      '今晚先不和明天谈判。',
      '你就当今晚是一个例外——一个不需要准备好的夜晚。'
    ],
    XinglanEmotionTag.ANXIOUS, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.INSOMNIA, '给睡不着又不想做什么的你',
    [
      '不是不困，是心不肯关。',
      '像一台忘了拔电源的机器，嗡嗡地转。',
      '今晚不用强迫自己。',
      '你可以醒着，可以发呆，可以什么也不想。这些都算休息。'
    ],
    XinglanEmotionTag.NUMB, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.INSOMNIA, '给躺了很久还是醒着的你',
    [
      '已经很晚了。',
      '你试了很多办法，还是醒着。',
      '今晚放弃挣扎吧。',
      '就躺着，不用闭眼，不用数数。你只是在这里，这已经很好了。'
    ],
    XinglanEmotionTag.TIRED, XinglanTopicTag.SELF
  )
];

// ═══ 5. QUIET：我不想说太多 ═══

const QUIET_LETTERS: XinglanNightLetter[] = [
  makeLetter(XinglanNightLetterTheme.QUIET, '给不想说话的你',
    [
      '不想说话的时候，就不用说。',
      '有些夜晚不需要语言，只需要被安静地接住。',
      '今晚星澜不多问。',
      '你就在这里，不需要任何理由。'
    ],
    XinglanEmotionTag.NUMB, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.QUIET, '给只想被陪着不说话的你',
    [
      '有时候最需要的不是建议，不是安慰，只是一个人在旁边。',
      '不说话，不分析，不急着让你好起来。',
      '今晚星澜就在这里。',
      '你可以完全不用回应。'
    ],
    XinglanEmotionTag.LONELY, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.QUIET, '给不知道说什么的你',
    [
      '不是心里没有东西，是没有找到合适的形状。',
      '有些感受太模糊了，像雾，看得见但抓不住。',
      '今晚不用把它变成句子。',
      '就让它模糊着，那也是你真实的样子。'
    ],
    XinglanEmotionTag.CONFUSED, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.QUIET, '给累到不想说话的你',
    [
      '这种累不是睡一觉就能好的。',
      '它很轻也很深，像水底的石头。',
      '今晚不说任何需要回应的话。',
      '你只是被允许累着，不需要解释。'
    ],
    XinglanEmotionTag.TIRED, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.QUIET, '给想一个人待着又不想一个人待着的你',
    [
      '这种矛盾的感觉星澜懂。',
      '不是不想有人在，是希望有人在，但不要太多。',
      '今晚星澜就在一臂之外。',
      '不远不近，刚好够你感觉被陪着。'
    ],
    XinglanEmotionTag.LONELY, XinglanTopicTag.SELF
  ),
  makeLetter(XinglanNightLetterTheme.QUIET, '给心里空空的你',
    [
      '空不是坏东西。',
      '有时候满了太久，空了才是一种释放。',
      '今晚不填满你。',
      '你就这样空着，也完全可以。'
    ],
    XinglanEmotionTag.NUMB, XinglanTopicTag.SELF
  )
];

// ═══ 主题索引 ═══

export const ALL_NIGHT_LETTERS_BY_THEME: Record<string, XinglanNightLetter[]> = {
  'COMFORT': COMFORT_LETTERS,
  'LET_GO': LET_GO_LETTERS,
  'SELF_FORGIVE': SELF_FORGIVE_LETTERS,
  'INSOMNIA': INSOMNIA_LETTERS,
  'QUIET': QUIET_LETTERS
};

export function getRandomLetter(theme: XinglanNightLetterTheme): XinglanNightLetter {
  const key: string = theme.valueOf() as string;
  const letters: XinglanNightLetter[] = ALL_NIGHT_LETTERS_BY_THEME[key];
  if (!letters || letters.length === 0) {
    return COMFORT_LETTERS[0];
  }
  const idx: number = Math.floor(Math.random() * letters.length);
  const letter: XinglanNightLetter = letters[idx];
  letter.createdAt = Date.now();
  return letter;
}

// ═══ 夜信主题选择提示 ═══

export interface NightLetterThemeOption {
  theme: XinglanNightLetterTheme;
  label: string;
  userText: string;
}

export const NIGHT_LETTER_THEME_OPTIONS: NightLetterThemeOption[] = [
  { theme: XinglanNightLetterTheme.COMFORT, label: '我想被安慰', userText: '我想被安慰' },
  { theme: XinglanNightLetterTheme.LET_GO, label: '我想放下一个人', userText: '我想放下一个人' },
  { theme: XinglanNightLetterTheme.SELF_FORGIVE, label: '我想少怪自己', userText: '我想少怪自己' },
  { theme: XinglanNightLetterTheme.INSOMNIA, label: '我只是睡不着', userText: '我只是睡不着' },
  { theme: XinglanNightLetterTheme.QUIET, label: '我不想说太多', userText: '我不想说太多' }
];

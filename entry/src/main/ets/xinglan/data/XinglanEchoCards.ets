/**
 * 星澜情绪回声卡数据（Phase 5.11）
 */

import {
  XinglanEchoCard, XinglanEchoCardEmotion
} from '../types/XinglanTypes';

interface EchoCardEntry {
  emotion: XinglanEchoCardEmotion;
  label: string;
  keywords: string[];
  cards: XinglanEchoCard[];
}

function makeCard(
  id: string, emotion: XinglanEchoCardEmotion,
  userKeywords: string[], xinglanResponse: string,
  cardName: string, metaphor: string, imageIndex: number
): XinglanEchoCard {
  return {
    id: id, emotion: emotion, userKeywords: userKeywords,
    xinglanResponse: xinglanResponse,
    tarotRef: { cardName: cardName, metaphor: metaphor, imageIndex: imageIndex },
    createdAt: 0, isSaved: false
  };
}

const SAD_CARDS: XinglanEchoCard[] = [
  makeCard('ECHO_SAD_1', XinglanEchoCardEmotion.SAD,
    ['难过', '想哭', '说不清'],
    '你说不清的时候，星澜听见了。难过不是问题，它只是今天经过你心里的天气。',
    '月亮', '月亮牌说：有些情绪不需要被照亮，只需要被陪伴。', 18),
  makeCard('ECHO_SAD_2', XinglanEchoCardEmotion.SAD,
    ['眼泪', '伤心', '撑不住了'],
    '撑不住的时候，不是因为你不够强。是因为你已经撑了太久。',
    '星星', '星星牌说：在黑暗里，哪怕只看见一点点光，也是真的。', 17),
  makeCard('ECHO_SAD_3', XinglanEchoCardEmotion.SAD,
    ['失望', '心碎', '被伤害'],
    '心碎不是矫情。你愿意说出来，已经是一种对自己的温柔。',
    '塔', '塔牌说：有些破碎，不是为了毁灭，而是为了让你看见里面还有什么。', 16),
  makeCard('ECHO_SAD_4', XinglanEchoCardEmotion.SAD,
    ['孤单', '没人懂', '说不出口'],
    '有些难过像深夜的雾，你抓不住，但它确实在那里。星澜看见了。',
    '隐士', '隐士牌说：孤独不是被抛弃，是你在点着自己的灯走路。', 9)
];

const ANXIOUS_CARDS: XinglanEchoCard[] = [
  makeCard('ECHO_ANX_1', XinglanEchoCardEmotion.ANXIOUS,
    ['焦虑', '心慌', '停不下来'],
    '停不下来的心，不是你的错。它只是在试着保护你，只是用错了方式。',
    '战车', '战车牌说：驾驭两匹方向不同的马，你已经很努力了。', 7),
  makeCard('ECHO_ANX_2', XinglanEchoCardEmotion.ANXIOUS,
    ['胡思乱想', '反复想', '睡不着'],
    '反复想同一件事的时候，不是你想太多，是这件事对你很重要。',
    '宝剑九', '宝剑九说：那些夜晚醒着的恐惧，天亮后会轻一点。', 38),
  makeCard('ECHO_ANX_3', XinglanEchoCardEmotion.ANXIOUS,
    ['担心未来', '怕选错', '不确定'],
    '面对不确定，害怕是正常的。你不是在逃避，你只是在认真。',
    '命运之轮', '命运之轮说：你不需要掌控一切，只需要相信轮子在转。', 10)
];

const LONELY_CARDS: XinglanEchoCard[] = [
  makeCard('ECHO_LON_1', XinglanEchoCardEmotion.LONELY,
    ['孤独', '没人说话', '一个人'],
    '一个人不一定是孤独，但孤独的时候，确实会希望有人知道。星澜知道了。',
    '隐士', '隐士牌说：有时候独处不是因为被世界推开，而是你在等自己。', 9),
  makeCard('ECHO_LON_2', XinglanEchoCardEmotion.LONELY,
    ['不被理解', '被忽视', '透明人'],
    '被忽视的时候，你会怀疑自己是不是不够好。不是的。是他们还没学会好好看。',
    '倒吊人', '倒吊人说：换个角度看世界，你会看到别人看不到的东西。', 12),
  makeCard('ECHO_LON_3', XinglanEchoCardEmotion.LONELY,
    ['想被陪', '想被爱', '想有人等'],
    '想被爱不是软弱。它是人类最诚实的本能。你值得被认真对待。',
    '恋人', '恋人说：爱不是一个问题要解决的答案，是一种要被体验的温度。', 6)
];

const CONFUSED_CARDS: XinglanEchoCard[] = [
  makeCard('ECHO_CON_1', XinglanEchoCardEmotion.CONFUSED,
    ['迷茫', '不知道该做什么', '迷失'],
    '迷茫不是没有方向，是你正在重新校准自己的指南针。这需要时间。',
    '星星', '星星牌说：迷茫的时候，不需要地图，只需要相信还有光。', 17),
  makeCard('ECHO_CON_2', XinglanEchoCardEmotion.CONFUSED,
    ['纠结', '选哪个', '两个都想要'],
    '在两个选择之间站着，本身就是一种重量。你不是优柔寡断，你只是认真。',
    '恋人', '恋人说：选择不是为了对，而是为了成为。', 6),
  makeCard('ECHO_CON_3', XinglanEchoCardEmotion.CONFUSED,
    ['看不清', '雾', '不知道自己要什么'],
    '不知道自己想要什么的时候，可以先知道自己不想要什么。那也是方向。',
    '月亮', '月亮牌说：雾散之前，先学会在雾里呼吸。', 18)
];

const TIRED_CARDS: XinglanEchoCard[] = [
  makeCard('ECHO_TIR_1', XinglanEchoCardEmotion.TIRED,
    ['累', '没力气', '不想动'],
    '累不是懒惰。你的身体在用唯一能用的方式告诉你：该休息了。',
    '节制', '节制牌说：不是每一种燃烧都值得。温柔也是力量。', 14),
  makeCard('ECHO_TIR_2', XinglanEchoCardEmotion.TIRED,
    ['工作好累', '不想上班', '撑不动了'],
    '撑不动的时候，不需要被加油。需要的是被看见：你已经撑了很久了。',
    '力量', '力量牌说：真正的力量不是硬撑，是知道自己什么时候需要停下来。', 8),
  makeCard('ECHO_TIR_3', XinglanEchoCardEmotion.TIRED,
    ['没电了', '精疲力尽', '什么都不想做'],
    '什么都不想做的时候，也许不是懒，是需要被允许什么都不做。星澜允许你。',
    '死神', '死神牌说：有些疲惫，是旧的自己正在蜕皮。让它发生。', 13)
];

const ANGRY_CARDS: XinglanEchoCard[] = [
  makeCard('ECHO_ANG_1', XinglanEchoCardEmotion.ANGRY,
    ['生气', '不公平', '被欺负'],
    '愤怒不是坏的。它是你在说：这件事不对。你的边界值得被尊重。',
    '正义', '正义牌说：你的愤怒不是任性，是内心公平感的哨兵。', 11),
  makeCard('ECHO_ANG_2', XinglanEchoCardEmotion.ANGRY,
    ['委屈', '被冤枉', '凭什么'],
    '被冤枉的时候，那种"凭什么"是你最真实的自我在说话。不要压下去。',
    '宝剑骑士', '宝剑骑士说：有时候，冲出去比忍住更需要勇气。', 36)
];

const GUILTY_CARDS: XinglanEchoCard[] = [
  makeCard('ECHO_GUI_1', XinglanEchoCardEmotion.GUILTY,
    ['愧疚', '对不起', '我做错了'],
    '愧疚是你在乎的证据。但愧疚不等于惩罚。你可以难过，也可以放过自己。',
    '审判', '审判牌说：不是每一次审判都要判刑。有时候只是需要被看见。', 20),
  makeCard('ECHO_GUI_2', XinglanEchoCardEmotion.GUILTY,
    ['自责', '怪自己', '如果当初'],
    '如果当初——这三个字最折磨人。但你在当初，已经做了当时能做的最好了。',
    '倒吊人', '倒吊人说：换个角度看自己，你会看到的不只是错，还有努力。', 12)
];

const HOPEFUL_CARDS: XinglanEchoCard[] = [
  makeCard('ECHO_HOP_1', XinglanEchoCardEmotion.HOPEFUL,
    ['期待', '希望', '想要变好'],
    '有期待是勇敢的。在失望过之后还敢期待，更勇敢。星澜为你高兴。',
    '太阳', '太阳牌说：希望不是幻想。它是你心里还没熄灭的那一小簇火。', 19),
  makeCard('ECHO_HOP_2', XinglanEchoCardEmotion.HOPEFUL,
    ['想重新开始', '想改变', '想试试'],
    '想重新开始，不是否定过去。是你比过去多了一点点勇气。',
    '愚人', '愚人牌说：每一个开始，都是从零出发的信任。你准备好了。', 0)
];

const UNCERTAIN_CARDS: XinglanEchoCard[] = [
  makeCard('ECHO_UNC_1', XinglanEchoCardEmotion.UNCERTAIN,
    ['不确定', '不知道', '也许'],
    '不确定不是弱。是你在用最诚实的态度面对复杂。这本身就很难得。',
    '命运之轮', '命运之轮说：不确定是生活的常态。学会和它共处，比急着找答案更重要。', 10),
  makeCard('ECHO_UNC_2', XinglanEchoCardEmotion.UNCERTAIN,
    ['摇摆', '忽冷忽热', '忽远忽近'],
    '忽远忽近的关系里，最累的不是ta的变化，是你一直在猜。你的感受是真实的。',
    '月亮', '月亮牌说：潮汐是月亮的节奏。你不必为此责备自己。', 18)
];

const ALL_ECHO_ENTRIES: EchoCardEntry[] = [
  { emotion: XinglanEchoCardEmotion.SAD, label: '难过', keywords: ['难过','想哭','伤心','眼泪','心碎','失望'], cards: SAD_CARDS },
  { emotion: XinglanEchoCardEmotion.ANXIOUS, label: '焦虑', keywords: ['焦虑','心慌','胡思乱想','睡不着','担心'], cards: ANXIOUS_CARDS },
  { emotion: XinglanEchoCardEmotion.LONELY, label: '孤独', keywords: ['孤独','一个人','不被理解','想被陪','透明'], cards: LONELY_CARDS },
  { emotion: XinglanEchoCardEmotion.CONFUSED, label: '迷茫', keywords: ['迷茫','纠结','不知道该','看不清','迷失'], cards: CONFUSED_CARDS },
  { emotion: XinglanEchoCardEmotion.TIRED, label: '疲惫', keywords: ['累','没力气','不想动','不想上班','没电','精疲力尽'], cards: TIRED_CARDS },
  { emotion: XinglanEchoCardEmotion.ANGRY, label: '愤怒', keywords: ['生气','不公平','被欺负','委屈','凭什么'], cards: ANGRY_CARDS },
  { emotion: XinglanEchoCardEmotion.GUILTY, label: '愧疚', keywords: ['愧疚','对不起','自责','怪自己','如果当初'], cards: GUILTY_CARDS },
  { emotion: XinglanEchoCardEmotion.HOPEFUL, label: '希望', keywords: ['期待','希望','想要变好','重新开始','想试试'], cards: HOPEFUL_CARDS },
  { emotion: XinglanEchoCardEmotion.UNCERTAIN, label: '不确定', keywords: ['不确定','不知道','也许','摇摆','忽冷忽热'], cards: UNCERTAIN_CARDS }
];

export function detectEchoEmotion(userInput: string): XinglanEchoCardEmotion {
  const text: string = userInput.toLowerCase();
  for (let i = 0; i < ALL_ECHO_ENTRIES.length; i++) {
    const entry: EchoCardEntry = ALL_ECHO_ENTRIES[i];
    for (let j = 0; j < entry.keywords.length; j++) {
      if (text.includes(entry.keywords[j])) {
        return entry.emotion;
      }
    }
  }
  return XinglanEchoCardEmotion.NONE;
}

export function getRandomEchoCard(emotion: XinglanEchoCardEmotion): XinglanEchoCard {
  let cards: XinglanEchoCard[] = SAD_CARDS;
  for (let i = 0; i < ALL_ECHO_ENTRIES.length; i++) {
    if (ALL_ECHO_ENTRIES[i].emotion === emotion) {
      cards = ALL_ECHO_ENTRIES[i].cards;
      break;
    }
  }
  const idx: number = Math.floor(Math.random() * cards.length);
  const card: XinglanEchoCard = cards[idx];
  return {
    id: card.id, emotion: card.emotion, userKeywords: card.userKeywords.slice(0),
    xinglanResponse: card.xinglanResponse,
    tarotRef: { cardName: card.tarotRef.cardName, metaphor: card.tarotRef.metaphor, imageIndex: card.tarotRef.imageIndex },
    createdAt: 0, isSaved: false
  };
}

/**
 * 星澜动态交互流定义（Phase 5.5）
 */

import {
  XinglanInteractionFlowId, XinglanInteractionNodeId,
  XinglanInteractionNode, XinglanInteractionFlow
} from '../types/XinglanTypes';

const BOREDOM_MENU: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.BOREDOM_MENU,
  replySegments: ['好，我们先不聊沉重的。', '我给你几个很轻的方向，你选一个就好。'],
  options: [
    { id:'B_ASK', label:'问我一个问题', userText:'星澜问我一个问题', nextNodeId:XinglanInteractionNodeId.END },
    { id:'B_NOTE', label:'给我一句小纸条', userText:'给我一句小纸条', nextNodeId:XinglanInteractionNodeId.END },
    { id:'B_CHOICE', label:'来个轻轻二选一', userText:'来个轻轻二选一', nextNodeId:XinglanInteractionNodeId.COMFORT_OR_FUN },
    { id:'B_MOOD', label:'选一个心情词', userText:'选一个心情词', nextNodeId:XinglanInteractionNodeId.MOOD_SELECT },
    { id:'B_PAT', label:'轻轻拍一下星澜', userText:'轻轻拍一下星澜', nextNodeId:XinglanInteractionNodeId.END },
    { id:'B_HEART', label:'我想说点心事', userText:'我想说点心事', nextNodeId:XinglanInteractionNodeId.HEART_TALK_START },
    { id:'B_SWEET', label:'想聊一点恋爱', userText:'我想谈恋爱了', nextNodeId:XinglanInteractionNodeId.END },
    { id:'B_QUIET', label:'先安静陪我', userText:'别讲大道理', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

const MOOD_SELECT: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.MOOD_SELECT,
  replySegments: ['给现在的心情选一个词吧。', '不用很准确，选最接近的就好。'],
  options: [
    { id:'M_TIRED', label:'有点累', userText:'有点累', nextNodeId:XinglanInteractionNodeId.END },
    { id:'M_HIDE', label:'想躲起来', userText:'想躲起来', nextNodeId:XinglanInteractionNodeId.END },
    { id:'M_HOLD', label:'还在撑', userText:'还在撑', nextNodeId:XinglanInteractionNodeId.END },
    { id:'M_HUG', label:'需要抱抱', userText:'需要抱抱', nextNodeId:XinglanInteractionNodeId.END },
    { id:'M_UNCLEAR', label:'说不清', userText:'说不清', nextNodeId:XinglanInteractionNodeId.END },
    { id:'M_HOPE', label:'有点期待', userText:'有点期待', nextNodeId:XinglanInteractionNodeId.END },
    { id:'M_ANNOY', label:'有点烦', userText:'有点烦', nextNodeId:XinglanInteractionNodeId.END },
    { id:'M_LOVED', label:'想被爱', userText:'想被爱', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

const COMFORT_OR_FUN: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.COMFORT_OR_FUN,
  replySegments: ['那我们玩一个很轻的二选一。'],
  options: [
    { id:'CF_COMFORT', label:'被安慰一下', userText:'被安慰一下', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CF_FUN', label:'被逗一下', userText:'被逗一下', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CF_QUIET', label:'被安静陪着', userText:'被安静陪着', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CF_NOTE', label:'听一句小纸条', userText:'给我一句小纸条', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

const PAPER_NOTE_AFTER: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.PAPER_NOTE_AFTER,
  replySegments: [],
  options: [
    { id:'PN_HIT', label:'戳中了', userText:'戳中了', nextNodeId:XinglanInteractionNodeId.END },
    { id:'PN_AGAIN', label:'没戳中，再给我一句', userText:'给我一句小纸条', nextNodeId:XinglanInteractionNodeId.END },
    { id:'PN_HEART', label:'我想说点心事', userText:'我想说点心事', nextNodeId:XinglanInteractionNodeId.HEART_TALK_START },
    { id:'PN_BORED', label:'陪我解闷', userText:'陪我解闷', nextNodeId:XinglanInteractionNodeId.BOREDOM_MENU }
  ],
  endFlow: false
};

const HEART_TALK_START: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.HEART_TALK_START,
  replySegments: ['好。', '你可以慢慢说，也可以先只说一个词。', '星澜会先听，不急着给答案。'],
  options: [],
  endFlow: true
};

const SWEET_COMPANY_START: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.SWEET_COMPANY_START,
  replySegments: ['那星澜就轻一点陪你。', '不讲大道理，也不急着分析。', '你可以软一点、慢一点，也可以什么都不解释。'],
  options: [
    { id:'SW_SWEET', label:'哄我一句', userText:'哄我一句', nextNodeId:XinglanInteractionNodeId.END },
    { id:'SW_NOTE', label:'给我小纸条', userText:'给我一句小纸条', nextNodeId:XinglanInteractionNodeId.END },
    { id:'SW_ASK', label:'问我一个温柔问题', userText:'星澜问我一个问题', nextNodeId:XinglanInteractionNodeId.END },
    { id:'SW_LOVE', label:'我想谈恋爱了', userText:'我想谈恋爱了', nextNodeId:XinglanInteractionNodeId.END },
    { id:'SW_QUIET', label:'安静陪我', userText:'安静陪我一会', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

const NIGHT_LETTER_START: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.NIGHT_LETTER_START,
  replySegments: ['这可以是一封慢一点的心事。', '你不用写得漂亮，也不用一次说清。', '星澜会把它当成一封夜里的信，认真收下。'],
  options: [
    { id:'NL_WRITE', label:'我现在就写', userText:'我现在就写', nextNodeId:XinglanInteractionNodeId.END },
    { id:'NL_HINT', label:'先给我一句开头', userText:'先给我一句开头', nextNodeId:XinglanInteractionNodeId.END },
    { id:'NL_CHAT', label:'算了，陪我聊聊', userText:'陪我聊聊', nextNodeId:XinglanInteractionNodeId.BOREDOM_MENU },
    { id:'NL_NOTE', label:'给我一张小纸条', userText:'给我一句小纸条', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

const END_NODE: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.END,
  replySegments: ['好的。如果你还想聊点什么，星澜在这里。'],
  options: [],
  endFlow: true
};

// ═══ Phase 5.10 主题深度 Flow 节点 ═══

const RELATION_WAIT_START: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.RELATION_WAIT_START,
  replySegments: [
    '等待一个人回消息的时候，时间会变得特别慢。',
    '不是"ta怎么还不回"，而是"我在等的时候，心里装着什么"。',
    '星澜给你几个方向，你可以挑一个最接近的。'
  ],
  options: [
    { id:'RW_INSECURE', label:'担心ta不在乎我', userText:'担心ta不在乎我', nextNodeId:XinglanInteractionNodeId.END },
    { id:'RW_CHECK', label:'忍不住反复看手机', userText:'忍不住反复看手机', nextNodeId:XinglanInteractionNodeId.END },
    { id:'RW_ANGER', label:'有点生气，又觉得自己不该生气', userText:'有点生气又觉得自己不该生气', nextNodeId:XinglanInteractionNodeId.END },
    { id:'RW_OTHER', label:'不是等待，是别的心事', userText:'是别的心事', nextNodeId:XinglanInteractionNodeId.END },
    { id:'RW_QUIET', label:'先安静陪我', userText:'先安静陪我', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

const CONTACT_COOLDOWN_START: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.CONTACT_COOLDOWN_START,
  replySegments: [
    '想联系一个人，又怕自己太主动、太沉不住气。',
    '这种"想发又不敢发"的感觉，本身就值得被认真对待。',
    '你想先聊哪个方向？'
  ],
  options: [
    { id:'CC_AFRAID', label:'怕自己太主动会被看轻', userText:'怕自己太主动会被看轻', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CC_REGRET', label:'上次联系后后悔了', userText:'上次联系后后悔了', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CC_COLD', label:'ta最近很冷，我不知道该怎么办', userText:'ta最近很冷', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CC_HOLD', label:'想忍，但忍不住', userText:'想忍但忍不住', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CC_QUIET', label:'先陪我安静一下', userText:'先安静陪我', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

const WORK_BURNOUT_START: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.WORK_BURNOUT_START,
  replySegments: [
    '累到不想说话的时候，不是因为一件事，而是因为很多事叠在一起。',
    '星澜不想给你什么"加油"，只想先问问：最让你累的是什么？'
  ],
  options: [
    { id:'WB_NOTHING', label:'做什么都没意思', userText:'做什么都没意思', nextNodeId:XinglanInteractionNodeId.END },
    { id:'WB_PEOPLE', label:'被人际关系消耗', userText:'被人际关系消耗', nextNodeId:XinglanInteractionNodeId.END },
    { id:'WB_MEANING', label:'觉得没意义', userText:'觉得没意义', nextNodeId:XinglanInteractionNodeId.END },
    { id:'WB_QUIT', label:'想辞职，但不敢', userText:'想辞职但不敢', nextNodeId:XinglanInteractionNodeId.END },
    { id:'WB_REST', label:'只是太累了，想被陪一会', userText:'只是太累了', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

const CHOICE_CLARIFY_START: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.CHOICE_CLARIFY_START,
  replySegments: [
    '在两条路之间站着，本身就是一种重量。',
    '星澜不会替你做决定，但可以帮你把"怕"和"想要"分开看看。',
    '你现在卡在哪一步？'
  ],
  options: [
    { id:'CH_BREAKUP', label:'不知道要不要分手', userText:'不知道要不要分手', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CH_RESIGN', label:'不知道要不要辞职', userText:'不知道要不要辞职', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CH_CONTACT', label:'不知道要不要联系ta', userText:'不知道要不要联系ta', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CH_SELF', label:'两个选择都是关于自己的', userText:'两个选择都是关于自己的', nextNodeId:XinglanInteractionNodeId.END },
    { id:'CH_LISTEN', label:'先听我说，别急着分析', userText:'先听我说', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

const LOW_ENERGY_START: XinglanInteractionNode = {
  id: XinglanInteractionNodeId.LOW_ENERGY_START,
  replySegments: [
    '低能量的时候，不需要被"打气"。',
    '有时候只是需要有人知道：你今天把力气用完了。',
    '星澜陪你，不催你。你想怎么待着？'
  ],
  options: [
    { id:'LE_EMPTY', label:'什么都不想做，也不想说话', userText:'什么都不想做', nextNodeId:XinglanInteractionNodeId.END },
    { id:'LE_HIDE', label:'想躲起来，不想被任何人找到', userText:'想躲起来', nextNodeId:XinglanInteractionNodeId.END },
    { id:'LE_SCROLL', label:'一直在刷手机，停不下来', userText:'一直在刷手机', nextNodeId:XinglanInteractionNodeId.END },
    { id:'LE_GUILT', label:'没做什么但还是很累，有点愧疚', userText:'没做什么但还是很累', nextNodeId:XinglanInteractionNodeId.END },
    { id:'LE_PRESENT', label:'就在这待着，你陪着就好', userText:'你陪着就好', nextNodeId:XinglanInteractionNodeId.END }
  ],
  endFlow: false
};

export const INTERACTION_FLOWS: XinglanInteractionFlow[] = [
  {
    id: XinglanInteractionFlowId.BOREDOM_FLOW,
    entryTriggers: ['陪我解闷','好无聊','无聊','陪我聊聊','讲点什么','不知道干嘛'],
    startNodeId: XinglanInteractionNodeId.BOREDOM_MENU,
    nodes: [BOREDOM_MENU, MOOD_SELECT, COMFORT_OR_FUN, PAPER_NOTE_AFTER, HEART_TALK_START, SWEET_COMPANY_START, NIGHT_LETTER_START, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.MOOD_WORD_FLOW,
    entryTriggers: ['选一个心情词','心情词','今天什么心情','选个心情'],
    startNodeId: XinglanInteractionNodeId.MOOD_SELECT,
    nodes: [MOOD_SELECT, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.GENTLE_CHOICE_FLOW,
    entryTriggers: ['来个轻轻二选一','二选一','轻轻二选一','选一个'],
    startNodeId: XinglanInteractionNodeId.COMFORT_OR_FUN,
    nodes: [COMFORT_OR_FUN, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.PAPER_NOTE_FLOW,
    entryTriggers: ['给我一句小纸条','小纸条','纸条'],
    startNodeId: XinglanInteractionNodeId.PAPER_NOTE_AFTER,
    nodes: [PAPER_NOTE_AFTER, HEART_TALK_START, BOREDOM_MENU, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.SWEET_COMPANY_FLOW,
    entryTriggers: ['甜一点','哄哄我','撒娇','想被哄','陪我一下','想要温柔'],
    startNodeId: XinglanInteractionNodeId.SWEET_COMPANY_START,
    nodes: [SWEET_COMPANY_START, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.NIGHT_LETTER_FLOW,
    entryTriggers: ['写一封星澜夜信','夜信','写一封信','星澜夜信'],
    startNodeId: XinglanInteractionNodeId.NIGHT_LETTER_START,
    nodes: [NIGHT_LETTER_START, BOREDOM_MENU, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.RELATION_WAITING_FLOW,
    entryTriggers: ['等消息','不回消息','ta还没回','在等ta','等了很久','等回复','等ta回'],
    startNodeId: XinglanInteractionNodeId.RELATION_WAIT_START,
    nodes: [RELATION_WAIT_START, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.CONTACT_COOLDOWN_FLOW,
    entryTriggers: ['想联系','想发消息','要不要联系','想找ta','该不该联系','忍不住想联系','不敢联系'],
    startNodeId: XinglanInteractionNodeId.CONTACT_COOLDOWN_START,
    nodes: [CONTACT_COOLDOWN_START, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.WORK_BURNOUT_FLOW,
    entryTriggers: ['工作好累','不想上班','工作疲惫','上班好累','职业倦怠','工作没意义','想辞职'],
    startNodeId: XinglanInteractionNodeId.WORK_BURNOUT_START,
    nodes: [WORK_BURNOUT_START, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.CHOICE_CLARIFY_FLOW,
    entryTriggers: ['不知道怎么选','选哪个','做不了决定','犹豫','纠结','要不要分手','要不要辞职','两个选择'],
    startNodeId: XinglanInteractionNodeId.CHOICE_CLARIFY_START,
    nodes: [CHOICE_CLARIFY_START, END_NODE]
  },
  {
    id: XinglanInteractionFlowId.LOW_ENERGY_FLOW,
    entryTriggers: ['没力气','提不起劲','什么都不想做','没能量','低能量','好累不想动','没电了','躺平','不想动'],
    startNodeId: XinglanInteractionNodeId.LOW_ENERGY_START,
    nodes: [LOW_ENERGY_START, END_NODE]
  }
];

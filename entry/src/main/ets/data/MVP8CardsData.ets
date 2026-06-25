import {
  StructuredInterpretation,
  ScenarioContent,
  FollowUpQuestion,
  FollowUpOption,
  EmotionTag
} from '../model/TarotCard';

/**
 * MVP 8 张牌完整结构化解读数据
 *
 * 数据来源：星钥塔罗_P0_开发执行规格书_最终可交付版.md 第 5 章
 * 每张牌包含 6 种情绪场景的解读 + 3 组追问（每组 3 个选项各含 3 个定向回应）
 */

export const MVP8_CARD_IDS: string[] = [
  'major_00_fool',
  'major_02_high_priestess',
  'major_06_lovers',
  'major_07_chariot',
  'major_09_hermit',
  'major_10_wheel_of_fortune',
  'major_13_death',
  'major_18_moon',
];

// ── 牌名映射 ──
export const MVP8_CARD_NAMES: Record<string, string> = {
  'major_00_fool': '愚人',
  'major_02_high_priestess': '女祭司',
  'major_06_lovers': '恋人',
  'major_07_chariot': '战车',
  'major_09_hermit': '隐士',
  'major_10_wheel_of_fortune': '命运之轮',
  'major_13_death': '死神',
  'major_18_moon': '月亮',
};

// ── 图片资源映射 ──
export const MVP8_CARD_IMAGES: Record<string, Resource> = {
  'major_00_fool': $r('app.media.tarot_major_00_fool'),
  'major_02_high_priestess': $r('app.media.tarot_major_02_high_priestess'),
  'major_06_lovers': $r('app.media.tarot_major_06_lovers'),
  'major_07_chariot': $r('app.media.tarot_major_07_chariot'),
  'major_09_hermit': $r('app.media.tarot_major_09_hermit'),
  'major_10_wheel_of_fortune': $r('app.media.tarot_major_10_wheel_of_fortune'),
  'major_13_death': $r('app.media.tarot_major_13_death'),
  'major_18_moon': $r('app.media.tarot_major_18_moon'),
};

// ═══════════════════════════════════════════════════════════
// 5.1 愚人（The Fool · major_00_fool）
// ═══════════════════════════════════════════════════════════
const FOOL_SCENARIO: Record<EmotionTag, ScenarioContent> = {
  '关系内耗': {
    goldenSentence: '你反复琢磨的那些细节，可能只是因为你太想抓住什么。',
    emotionKeywords: ['过度投入', '害怕错过', '反复确认'],
    todayAction: '今天先别逼自己判断"对错"，让事情自然流动',
  },
  '关系评估': {
    goldenSentence: '有些路不用知道终点再出发，先走一步，答案在路上。',
    emotionKeywords: ['勇敢尝试', '不确定感', '新开始'],
    todayAction: '给关系一个"试试看"的机会，不预设结果',
  },
  '职场疲惫': {
    goldenSentence: '你不是想逃避，你只是太久没有为自己做选择了。',
    emotionKeywords: ['倦怠感', '渴望自由', '重新选择'],
    todayAction: '写下你真正想做的三件事，挑一件本周开始',
  },
  '选择纠结': {
    goldenSentence: '想不清楚的时候，不如先跳一步。答案不在脑子里，在行动里。',
    emotionKeywords: ['犹豫', '勇气', '突破'],
    todayAction: '抛硬币——不是为了看结果，是为了在硬币飞起时，发现自己在期待哪一面',
  },
  '能量低落': {
    goldenSentence: '一个全新的开始，不需要你准备好——只需要你愿意。',
    emotionKeywords: ['空白', '可能', '信任'],
    todayAction: '今天只做一件小事：走出房间，呼吸新鲜空气',
  },
  '寻求安慰': {
    goldenSentence: '你啊，心里那个小孩想出去玩。不是要你勇敢，是要你轻装上阵。',
    emotionKeywords: ['轻盈', '直觉', '童心'],
    todayAction: '对自己说一句：今天可以什么都不做好',
  },
};

const FOOL_FOLLOWUP: FollowUpQuestion[] = [
  {
    id: 'fuq_fool_01',
    question: '你在怕的是"走错"，还是怕"没人陪你走"？',
    options: [
      { emoji: '😰', label: '怕走错', response: '走错的路也是路。愚人从来不回头看悬崖，他只看见前方的天空。' },
      { emoji: '🫂', label: '怕没人陪', response: '你不是一个人。愚人身边那条小狗，就是生活给你的提醒——总有人默默跟着你。' },
      { emoji: '🤷', label: '都有', response: '怕就对了。怕说明你在乎。但不要因为怕，就停在原地。愚人迈出那一步的时候，也没人给他保证。' },
    ],
  },
  {
    id: 'fuq_fool_02',
    question: '如果没有任何限制，你内心最想做的那件事是什么？',
    options: [
      { emoji: '💡', label: '有明确想法', response: '可以从今天的一小步开始。但大决定不急着马上交出去，先给自己一个试用期。愚人牌在告诉你：先迈出很小的一步试试。' },
      { emoji: '🤔', label: '暂时没想到', response: '没关系。不知道去哪儿也是一种自由。允许自己暂时没有方向，反而会有新的东西进来。' },
      { emoji: '😞', label: '想到了但觉得不现实', response: '所有的"不现实"都是经验在说话。但经验是过去的事。愚人不在乎过去——他只在乎脚下这一步。' },
    ],
  },
  {
    id: 'fuq_fool_03',
    question: '你通常怎么面对"未知"？',
    options: [
      { emoji: '🔍', label: '拼命搜集信息', response: '你有一个很聪明的头脑。但愚人提醒你：有些信息不会在你准备好之后才出现，先跳进水里才能学会游泳。' },
      { emoji: '🛑', label: '先停下来观望', response: '谨慎是你的优点。但观望太久，机会就不是你的了。今天能不能小试一下？' },
      { emoji: '🏃', label: '闭眼冲', response: '你的勇气值得鼓掌。愚人喜欢你的行动力——留三分给直觉就够了，不用十成十。' },
    ],
  },
];

// ═══════════════════════════════════════════════════════════
// 5.2 女祭司（The High Priestess · major_02_high_priestess）
// ═══════════════════════════════════════════════════════════
const PRIESTESS_SCENARIO: Record<EmotionTag, ScenarioContent> = {
  '关系内耗': {
    goldenSentence: '你翻来覆去想的那些事，不是因为你想太多，是你的直觉在拉警报。',
    emotionKeywords: ['信息不透明', '反复猜测', '安全感不足'],
    todayAction: '今天不要再翻聊天记录，把手机放下，去喝杯水',
  },
  '关系评估': {
    goldenSentence: '有些真相不需要对方说出来——你的身体已经在告诉你了。',
    emotionKeywords: ['直觉', '沉默', '等待'],
    todayAction: '写下你在这段关系中"感觉到但没说出来"的三件事',
  },
  '职场疲惫': {
    goldenSentence: '你不是在偷懒，你是在积蓄。女祭司的能量是静水深流，不是表面热闹。',
    emotionKeywords: ['沉淀期', '内在力量', '耐心'],
    todayAction: '今天允许自己慢下来——不是偷懒，是战略性地休整',
  },
  '选择纠结': {
    goldenSentence: '安静下来。答案不在外面的噪音里，在你心里那个最安静的地方。',
    emotionKeywords: ['内观', '等待', '智慧'],
    todayAction: '找一个安静的地方坐五分钟，不问任何人意见，只听自己',
  },
  '能量低落': {
    goldenSentence: '不是所有的力量都要外放。有些时候，最大的力量是你选择了不解释。',
    emotionKeywords: ['独处', '恢复', '边界感'],
    todayAction: '今天拒绝一件你不想做的事——这是一种力量',
  },
  '寻求安慰': {
    goldenSentence: '有些事情不需要答案，只需要一个安静的空间和你自己。',
    emotionKeywords: ['自我对话', '内在安宁', '觉察'],
    todayAction: '给今天的自己泡一杯茶，就当是星澜陪你坐了一会儿',
  },
};

const PRIESTESS_FOLLOWUP: FollowUpQuestion[] = [
  {
    id: 'fuq_priestess_01',
    question: '你更难受的是"不确定"，还是"明明知道却舍不得"？',
    options: [
      { emoji: '😔', label: '不确定，心里没底', response: '女祭司说：你不需要现在就知道。有些答案会在你不找它们的时候，自己浮现。' },
      { emoji: '💔', label: '明明知道，但舍不得', response: '你的直觉一直在说话，只是你的心还在犹豫。给自己一点时间，不急着做决定。' },
      { emoji: '🤷', label: '两个都有', response: '没关系。女祭司也不是一出生就知道一切的——她选择了安静，然后她更容易看清自己的真实感受。' },
    ],
  },
  {
    id: 'fuq_priestess_02',
    question: '有没有一件事，你一直"感觉到不对劲"，但没说出口？',
    options: [
      { emoji: '🤐', label: '有，但不敢说', response: '你的直觉在保护你。不是说你一定要说出口，但至少要对自己承认：是的，我感受到了。' },
      { emoji: '🤔', label: '不确定是不是自己多想', response: '女祭司的智慧就是：相信你感觉到的东西，哪怕别人说你想多了。你不是想多，你是想得比别人深。' },
      { emoji: '💬', label: '已经说过了', response: '说了就是一种力量。女祭司不需要反复证明自己——你也不需要。' },
    ],
  },
  {
    id: 'fuq_priestess_03',
    question: '你上一次"相信直觉"是什么时候？结果呢？',
    options: [
      { emoji: '✅', label: '结果对了', response: '记住这种感觉。你的直觉比你想象中更可靠。下次它说话的时候，多听一会儿。' },
      { emoji: '❌', label: '结果错了', response: '直觉不是预言。它的作用是提醒你"这里有东西值得注意"，不是替你做决定。' },
      { emoji: '🤷', label: '不记得了', response: '那今天就是一个好的开始——留意一下今天第一个让你"咯噔"的感觉，把它记下来。' },
    ],
  },
];

// ═══════════════════════════════════════════════════════════
// 5.3 恋人（The Lovers · major_06_lovers）
// ═══════════════════════════════════════════════════════════
const LOVERS_SCENARIO: Record<EmotionTag, ScenarioContent> = {
  '关系内耗': {
    goldenSentence: '这段关系里最累的不是"他不回应"，是你在替他找理由。',
    emotionKeywords: ['单向投入', '期待落空', '自我怀疑'],
    todayAction: '今天暂停一次：停止猜测他在想什么，先问问自己想要什么',
  },
  '关系评估': {
    goldenSentence: '一段健康的关系不需要你反复确认"值不值得"。',
    emotionKeywords: ['价值观匹配', '选择', '双向奔赴'],
    todayAction: '列出你在这段关系中的三个底线，看看哪一个正在被触碰',
  },
  '职场疲惫': {
    goldenSentence: '你不是在纠结工作本身，你是在纠结"这是不是我想要的生活"。',
    emotionKeywords: ['人生选择', '方向感', '价值观'],
    todayAction: '拿出一张纸，左边写「现在的工作」，右边写「理想的状态」，看看差距在哪',
  },
  '选择纠结': {
    goldenSentence: '有些选择不是选 A 或选 B，是选择"你想成为什么样的人"。',
    emotionKeywords: ['身份认同', '取舍', '真实自我'],
    todayAction: '问问自己：这个选择会让一年后的我谢自己，还是怪自己？',
  },
  '能量低落': {
    goldenSentence: '你不需要别人给你能量——你需要的是和自己达成和解。',
    emotionKeywords: ['自我接纳', '内心矛盾', '放下'],
    todayAction: '对镜子里的自己说一句：你已经做得很好了',
  },
  '寻求安慰': {
    goldenSentence: '你不是一个人在纠结。每个人面对重要选择时，手心都会出汗。',
    emotionKeywords: ['陪伴', '共情', '释怀'],
    todayAction: '给一个信任的人发条消息，就说一句"我今天有点需要被鼓励"',
  },
};

const LOVERS_FOLLOWUP: FollowUpQuestion[] = [
  {
    id: 'fuq_lovers_01',
    question: '你最怕在这个选择里失去什么？',
    options: [
      { emoji: '💔', label: '怕失去一个人', response: '真正的失去，不是对方离开，是你为了留他而弄丢了自己。恋人牌问的从来不是"你要选谁"，是"你选自己还是选恐惧"。' },
      { emoji: '🛡️', label: '怕失去安全感', response: '安全感很重要。但恋人牌提醒你：真正的安全感不是来自于"不变"，而是来自于"我变了也能应付"。' },
      { emoji: '🎯', label: '怕失去机会', response: '如果一个机会让你害怕失去，那它不叫机会，叫赌注。恋人的智慧是：对的选择让你心里踏实，不是让你心跳加速。' },
    ],
  },
  {
    id: 'fuq_lovers_02',
    question: '你的心更偏向哪一边？你的脑子呢？',
    options: [
      { emoji: '❤️', label: '心选了A，脑子选了B', response: '有趣。心和脑打架的时候，身体最诚实——你想起哪个选择时胃会舒服一点？选那个。' },
      { emoji: '🧠', label: '心和脑一致', response: '那你还等什么？犹豫不是因为没想清楚，是因为还没准备好接受结果。恋人牌说：你准备好了。' },
      { emoji: '🤷', label: '两边都不确定', response: '那就停下来。恋人牌的核心不是"选哪个"，而是"你是否愿意为自己的选择负责"。先学会对自己负责，选择会变简单。' },
    ],
  },
  {
    id: 'fuq_lovers_03',
    question: '如果这件事只有一个正确答案——你觉得你的"自己"会选什么？排除别人的期待。',
    options: [
      { emoji: '🌈', label: '有清晰答案', response: '看到了吧——你一直都知道。你只是需要一个人告诉你：选自己，没错。' },
      { emoji: '🥺', label: '没想到"排除别人"', response: '这就是恋人牌要教你的：在很多选择里，最常被忘记的选项是"自己"。今天把它加回来。' },
      { emoji: '🔒', label: '害怕别人失望', response: '别人会失望。但你会解脱。恋人牌不要求你让所有人满意——它只要求你对自己诚实。' },
    ],
  },
];

// ═══════════════════════════════════════════════════════════
// 5.4 战车（The Chariot · major_07_chariot）
// ═══════════════════════════════════════════════════════════
const CHARIOT_SCENARIO: Record<EmotionTag, ScenarioContent> = {
  '关系内耗': {
    goldenSentence: '你一直扛着——扛着期待、扛着猜测、扛着所有没说出口的话。今天能不能放下一会儿？',
    emotionKeywords: ['硬扛', '疲惫', '掌控欲'],
    todayAction: '对自己承认一句：我也有不想扛的时候',
  },
  '关系评估': {
    goldenSentence: '战车提醒你：不是每段关系都要你冲锋在前。有些人坐车就好，不用帮你拉。',
    emotionKeywords: ['主动', '边界', '决心'],
    todayAction: '列出你在关系中"一直在做但对方不一定注意到"的三件事',
  },
  '职场疲惫': {
    goldenSentence: '你不是累在活多，是累在"没人看到我在扛"。',
    emotionKeywords: ['高压', '孤军奋战', '渴望认可'],
    todayAction: '今天跟上级说一句：最近我手上有 A/B/C 三件事，想确认一下优先级',
  },
  '选择纠结': {
    goldenSentence: '想好了就出发。犹豫不决的时候，你在消耗的不是时间，是自己的气势。',
    emotionKeywords: ['行动力', '决心', '掌控'],
    todayAction: '今天做一个已经拖了一周的决定——不求完美，求"结束犹豫"',
  },
  '能量低落': {
    goldenSentence: '你不是没能量，你是在"憋着"。战车的能量是往外冲的，不是往里收的。',
    emotionKeywords: ['压抑', '爆发', '释放'],
    todayAction: '去找一个可以大喊大叫的地方，或者去健身房打拳、跑步',
  },
  '寻求安慰': {
    goldenSentence: '你不需要被人"心疼"，你需要被人"看见"。你一直在开车，副驾驶上有人吗？',
    emotionKeywords: ['坚强', '渴望支持', '不需要可怜'],
    todayAction: '跟那个人说一句：我最近有点累，不用帮我解决，听我说说就好',
  },
};

const CHARIOT_FOLLOWUP: FollowUpQuestion[] = [
  {
    id: 'fuq_chariot_01',
    question: '你在扛着的那件事——如果不管了，会发生什么？',
    options: [
      { emoji: '💥', label: '感觉会崩', response: '你觉得会崩，是因为你一直以为只有你在撑着。但战车的缰绳有两根——一根控制理性，一根控制本能。你可以让一只手休息。' },
      { emoji: '🤷', label: '不确定', response: '不确定就是答案。你不敢放手不是因为世界会塌，是因为你不确定"没有你"是什么样。试试看——让事情自然发生一次。' },
      { emoji: '😌', label: '其实也不会怎样', response: '那你扛着干嘛？战车是拿来冲的，不是拿来原地拉磨的。' },
    ],
  },
  {
    id: 'fuq_chariot_02',
    question: '谁是那个可以帮你分担的人？',
    options: [
      { emoji: '👤', label: '有，但不想麻烦对方', response: '战车不是用来逞强的。你叫一个人坐副驾驶不是示弱——是让对方知道"我需要你"。那句话比你想象的更有力量。' },
      { emoji: '😶', label: '没有', response: '没有也没关系。战车的另一层意思是：你可以做自己的副驾驶。对自己说："我来。"但也要对自己说："我歇一下。"' },
      { emoji: '🤝', label: '已经在帮我了', response: '那很好。战车不需要一个人拉到底——缰绳可以分一根出去。记得说声谢谢，不只是对别人，也是对自己。' },
    ],
  },
  {
    id: 'fuq_chariot_03',
    question: '你觉得自己在"硬撑"还是在"前进"？',
    options: [
      { emoji: '🪨', label: '硬撑', response: '硬撑和前进的区别是：硬撑的时候你在看脚下，前进的时候你在看前面。抬头看一下——前面有什么让你想跑过去的东西？' },
      { emoji: '🚀', label: '前进', response: '很好。战车在动，方向明确。留意一下速度——太快会错过风景，太慢会消耗气势。找到你的节奏。' },
      { emoji: '🔄', label: '分不清', response: '那就停下来看一眼。战车的两头灵兽一黑一白——黑的是你的恐惧，白的是你的渴望。它们往同一个方向拉，才能前进。今天先搞清楚：恐惧和渴望各指哪边？' },
    ],
  },
];

// ═══════════════════════════════════════════════════════════
// 5.5 隐士（The Hermit · major_09_hermit）
// ═══════════════════════════════════════════════════════════
const HERMIT_SCENARIO: Record<EmotionTag, ScenarioContent> = {
  '关系内耗': {
    goldenSentence: '你一直在分析他的一举一动。隐士说：把手电筒从别人身上拿回来，照照自己。',
    emotionKeywords: ['过度分析', '自我忽视', '内省缺失'],
    todayAction: '今天问自己一个问题：我这么在意他的反应，是因为在乎他，还是因为在乎自己被怎么对待？',
  },
  '关系评估': {
    goldenSentence: '不需要别人告诉你答案。你的心比你想象的更清楚——只是安静不下来听。',
    emotionKeywords: ['独立思考', '内心声音', '暂停'],
    todayAction: '给自己一个完整的下午，不看手机，不去想"要不要继续"，就待着',
  },
  '职场疲惫': {
    goldenSentence: '你不是职业倦怠，你是太久没有问自己"我想要什么"了。',
    emotionKeywords: ['方向迷失', '意义感弱', '需要独处'],
    todayAction: '请一天假，一个人去一个从来没去过的地方',
  },
  '选择纠结': {
    goldenSentence: '想不明白的时候，不是信息不够——是噪音太多。躲开所有人的意见，你已经有答案了。',
    emotionKeywords: ['信息过载', '直觉被淹没', '减法'],
    todayAction: '今天不跟任何人讨论这个选择，自己写下来，写完就撕掉',
  },
  '能量低落': {
    goldenSentence: '你不是没能量，你是把能量花在了"让别人理解你"这件事上。省省电。',
    emotionKeywords: ['社交消耗', '解释疲劳', '精神独处'],
    todayAction: '今天拒绝一场社交，用那段时间给自己做顿饭',
  },
  '寻求安慰': {
    goldenSentence: '有些路确实要一个人走。不是孤独——是沉淀。你手里那盏灯，就是给自己的温暖。',
    emotionKeywords: ['自我陪伴', '内在力量', '温暖自给'],
    todayAction: '给自己写一封信，开头是：亲爱的自己，最近辛苦你了',
  },
};

const HERMIT_FOLLOWUP: FollowUpQuestion[] = [
  {
    id: 'fuq_hermit_01',
    question: '你上一次真正一个人待着、不想任何人的事——是什么时候？',
    options: [
      { emoji: '📅', label: '很久以前了', response: '隐士点着灯一个人在雪山顶上，不是为了躲开谁——是为了找到自己。你也需要那座山。' },
      { emoji: '🤔', label: '想不起来', response: '那今天就是第一天。不是逃避，是回家——回到自己这里。' },
      { emoji: '🏠', label: '经常这样', response: '你是隐士牌选中的人。但记得：独处是充电，不是逃避。充好了就下山，把灯照给需要的人。' },
    ],
  },
  {
    id: 'fuq_hermit_02',
    question: '你觉得自己在"寻找答案"还是在"等待答案"？',
    options: [
      { emoji: '🔍', label: '寻找', response: '方向对了。隐士的灯不是照远方的——是照脚下的。答案就在你走出的每一步里。' },
      { emoji: '⏳', label: '等待', response: '等待也是一种力量。但不是被动地等——是像隐士一样，在雪山之巅安静地等，等雪停了，路自然就出来了。' },
      { emoji: '🔄', label: '都有', response: '那很好。寻找和等待是同一件事的两面。隐士手中的灯，既是寻找的工具，也是等待的信号。' },
    ],
  },
  {
    id: 'fuq_hermit_03',
    question: '如果给你三天完全独处的时间——第一天你会做什么？',
    options: [
      { emoji: '😴', label: '睡觉', response: '身体在说话了。你欠自己一个彻底的休息。隐士的雪山夜晚很长，睡吧。' },
      { emoji: '📖', label: '看书/思考', response: '隐士的书房里有一整面墙的书。不是每本都要读——找一本你翻了三年还没读完的，今天就翻一章。' },
      { emoji: '🌿', label: '去大自然', response: '去。隐士在雪山上不是偶然的——自然是最好的静音室。记得带杯热茶。' },
    ],
  },
];

// ═══════════════════════════════════════════════════════════
// 5.6 命运之轮（Wheel of Fortune · major_10_wheel_of_fortune）
// ═══════════════════════════════════════════════════════════
const WHEEL_SCENARIO: Record<EmotionTag, ScenarioContent> = {
  '关系内耗': {
    goldenSentence: '你在漩涡里打转的时候，最容易忘记一件事：轮子是会转的。你不在底部——你在一个正在转动的位置。',
    emotionKeywords: ['周期低谷', '转机将至', '不要绝望'],
    todayAction: '写下过去 3 个月发生的 3 件好事——你可能忘了它们发生过',
  },
  '关系评估': {
    goldenSentence: '关系有春夏秋冬。现在是冬天，不代表春天不会来。但你要想清楚：你想等春天，还是想去有春天的地方？',
    emotionKeywords: ['周期规律', '等待or离开', '时机'],
    todayAction: '回忆一下：这段关系最好的时候是什么样？那个版本还会回来吗？',
  },
  '职场疲惫': {
    goldenSentence: '运气不是天上掉馅饼。运气是你能不能在"对的时间"站在"对的地方"。轮子在转了——你站对了吗？',
    emotionKeywords: ['时机', '顺势', '机会窗口'],
    todayAction: '问问自己：现在的工作里，哪个方向正在"上升"？',
  },
  '选择纠结': {
    goldenSentence: '轮子在转的时候，最重要的是"上轮子"，不是"选左边还是右边"。',
    emotionKeywords: ['顺势而为', '行动优先', '不纠结'],
    todayAction: '不管三七二十一，先朝一个方向走一步——行动会带来新的反馈',
  },
  '能量低落': {
    goldenSentence: '运势有起有落。在谷底的时候，最重要的事不是"爬上去"，是"别散架"。',
    emotionKeywords: ['耐心', '周期', '保持完整'],
    todayAction: '对自己说：现在是缓冲期，我在充电，不是在退步',
  },
  '寻求安慰': {
    goldenSentence: '一切都在变化——好消息是：坏的情况会变；坏消息是：好的情况也会变。所以要珍惜当下。',
    emotionKeywords: ['无常', '豁达', '此刻即是全部'],
    todayAction: '今晚抬头看一分钟的夜空——世界在转，你也在转，一切都会流动',
  },
};

const WHEEL_FOLLOWUP: FollowUpQuestion[] = [
  {
    id: 'fuq_wheel_01',
    question: '你觉得现在是在"上升期"还是在"低谷"？',
    options: [
      { emoji: '📈', label: '上升期', response: '抓住这股势头。命运之轮的提醒是：顺的时候别飘——转盘会继续转。把基础打牢，为下坡准备缓冲。' },
      { emoji: '📉', label: '低谷', response: '低谷是轮子的一部分，不是你的错。轮子上的四种生物在读书——它们不是在看你怎么摔，它们在学习规律：每一段下坠都在为下一次上升蓄力。' },
      { emoji: '🤷', label: '分不清', response: '分不清的时候，说明你在两个阶段的交界处。深呼吸——轮子正在过界，很快就知道往哪边转了。' },
    ],
  },
  {
    id: 'fuq_wheel_02',
    question: '你觉得"时机"是外部给你的，还是你自己创造的？',
    options: [
      { emoji: '🌍', label: '外部给的', response: '没错，轮子有它自己的节奏。但你可以选择在轮子转到你面前时伸手——很多人错过了，因为他们在低头看手机。' },
      { emoji: '🛠️', label: '自己创造的', response: '你的行动力是轮子的燃料。命运之轮不是纯随机——它奖励那些在正确时间做了正确准备的人。' },
      { emoji: '⚖️', label: '一半一半', response: '最好的答案。轮子顶端的持剑者——它既代表外部的节奏，也代表你可以把握的瞬间。' },
    ],
  },
  {
    id: 'fuq_wheel_03',
    question: '如果三个月后你回头看，你觉得现在这个时刻会是什么？',
    options: [
      { emoji: '🔄', label: '转折点', response: '记住这句话。命运之轮正在过界。三个月后的你会感谢今天没有放弃。' },
      { emoji: '🧱', label: '积累期', response: '隐士的雪山之后就是命运之轮。你在积蓄的东西，很快就会有出口。别急着看到结果。' },
      { emoji: '🎯', label: '起点', response: '这是一个新的四分之一圆。轮子上的四个符号代表自然的四季循环——你正在进入一个新的季节。' },
    ],
  },
];

// ═══════════════════════════════════════════════════════════
// 5.7 死神（Death · major_13_death）
// ═══════════════════════════════════════════════════════════
const DEATH_SCENARIO: Record<EmotionTag, ScenarioContent> = {
  '关系内耗': {
    goldenSentence: '有些关系的结束不是因为谁错了——是因为这段关系已经完成了它的使命。',
    emotionKeywords: ['放手', '完成', '感谢'],
    todayAction: '给那段关系写一句"谢谢你，再见"——不用发出去',
  },
  '关系评估': {
    goldenSentence: '死神不是判决书——它是一张请假条。准许你放下那些已经不滋养你的东西。',
    emotionKeywords: ['止损', '蜕变', '勇气'],
    todayAction: '问自己：如果这段关系是一部电影，你是想让结局停在现在，还是继续演下去？',
  },
  '职场疲惫': {
    goldenSentence: '你不是在放弃——你是在腾出双手，去接住更值得的东西。',
    emotionKeywords: ['转型', '结束即开始', '空间'],
    todayAction: '列出你在这份工作中学到的东西——带着它们走，比带着怨气走好',
  },
  '选择纠结': {
    goldenSentence: '有些选择不是"做决定"——是"让旧的自己退场，新的自己慢慢长出来"。',
    emotionKeywords: ['蜕变', '告别旧我', '重生'],
    todayAction: '你纠结的那些选项里，有没有一个是"旧的"但安全，一个是"新的"但不确定？',
  },
  '能量低落': {
    goldenSentence: '像结束了一段旧状态是正常的。但不是真的死——是蜕皮。旧壳裂开，新皮肤很嫩，但会变硬。',
    emotionKeywords: ['脆弱期', '蜕皮', '耐心'],
    todayAction: '今天允许自己脆弱——不是软弱，是在长新的铠甲',
  },
  '寻求安慰': {
    goldenSentence: '死神牌的真正含义不是结束，是"结束是为你让路"。那个空出来的位置，很快会被新的东西填满。',
    emotionKeywords: ['希望', '空白', '新生'],
    todayAction: '写下你最想"画上句号"的一件事——写完折起来，收进抽屉',
  },
};

const DEATH_FOLLOWUP: FollowUpQuestion[] = [
  {
    id: 'fuq_death_01',
    question: '你直觉上知道该放下什么——但你最怕放下后会发生什么？',
    options: [
      { emoji: '🕳️', label: '怕空虚', response: '空虚不是坏事。死神牌的黑色铠甲代表保护，留出的空白代表新的空间。空虚不是坏事，它可能是在为新的东西腾地方。' },
      { emoji: '💔', label: '怕后悔', response: '后悔的前提是"还有可能"。但死神牌告诉你：那扇门已经关上了。不是你在后悔——是过去的你在敲门，而现在的你不需要再开门了。' },
      { emoji: '😨', label: '怕再也找不到', response: '死神牌上太阳正在升起。不是终点，是起点。你会更有空间接住新的可能——因为你值得更好的滋养。' },
    ],
  },
  {
    id: 'fuq_death_02',
    question: '你能说出"我需要放手"——但你说出这句话的时候，身体哪个地方最不舒服？',
    options: [
      { emoji: '🫁', label: '胸口闷', response: '那里是心的位置。它在说不舍。不舍是对的——说明那段时间是真的。但死神牌说：记住它，放下它，往前走。' },
      { emoji: '🤯', label: '头胀', response: '脑子里有太多"万一"。死神牌上的白马不是乱跑的——它有方向。你的理性知道方向在哪，只是情绪还在拽缰绳。' },
      { emoji: '🫄', label: '胃痛', response: '胃是你的直觉。它在说：吃不下就别硬吃了。死神牌的刀不是来伤害你的——是来帮你切开那些消化不了的东西。' },
    ],
  },
  {
    id: 'fuq_death_03',
    question: '如果让"一年后的你"来替你做这个决定——他会怎么做？',
    options: [
      { emoji: '🔪', label: '果断放手', response: '一年后的你已经在新的地方了。他知道这段路只是过渡。你不需要一年——你只需要今天。' },
      { emoji: '🤷', label: '不确定', response: '那就问"三年后的你"。三年的跨度，足够让死神牌的太阳完全升起——回头看，现在的纠结会变得像别人的故事。' },
      { emoji: '🎭', label: '会矛盾', response: '矛盾是正常的。死神牌本身就充满了矛盾：白色玫瑰（纯真）+ 黑色铠甲（保护）。你不需要现在就完全坚定——只需要迈一步。' },
    ],
  },
];

// ═══════════════════════════════════════════════════════════
// 5.8 月亮（The Moon · major_18_moon）
// ═══════════════════════════════════════════════════════════
const MOON_SCENARIO: Record<EmotionTag, ScenarioContent> = {
  '关系内耗': {
    goldenSentence: '你不是想太多，你只是太久没有安全感。',
    emotionKeywords: ['信息不透明', '反复猜测', '安全感不足'],
    todayAction: '今天不要追问任何答案——不翻记录、不发消息、不逼自己判断',
  },
  '关系评估': {
    goldenSentence: '月亮照出来的不是真相——是你的恐惧投下的影子。先分清哪是影子，哪是路。',
    emotionKeywords: ['错觉', '恐惧投射', '幻觉'],
    todayAction: '问一个你信任的朋友：你觉得我在这段关系里，在害怕什么？',
  },
  '职场疲惫': {
    goldenSentence: '你每天花很多精力猜领导在想什么、同事怎么看你——月亮说：你猜的90%都不准。',
    emotionKeywords: ['社交焦虑', '过度解读', '精神消耗'],
    todayAction: '直接问一个人你想知道的事——月亮退散，太阳出来',
  },
  '选择纠结': {
    goldenSentence: '你在迷雾里找路，星澜给你一盏灯——不是照亮远方，是照亮下一步。',
    emotionKeywords: ['迷茫', '看不清未来', '需要指引'],
    todayAction: '告诉自己：我不需要看到终点，我只需要看到下一步',
  },
  '能量低落': {
    goldenSentence: '你不需要在黑夜中找到出口——你需要的是在黑夜中先坐下，等月亮升到最高。',
    emotionKeywords: ['黑暗期', '耐心', '自我关照'],
    todayAction: '关灯点一支蜡烛，在烛光里坐十分钟——就坐着，什么都不想',
  },
  '寻求安慰': {
    goldenSentence: '怕黑是正常的。但别忘了一件事——月亮再暗，它也是太阳照亮的。光一直在，只是拐了个弯。',
    emotionKeywords: ['孤独感', '渴望温暖', '隐藏的光'],
    todayAction: '给自己做一碗热汤面——身体的温暖会慢慢传到心里',
  },
};

const MOON_FOLLOWUP: FollowUpQuestion[] = [
  {
    id: 'fuq_moon_01',
    question: '你更难受的是"不确定"，还是"明明知道却舍不得"？',
    options: [
      { emoji: '😔', label: '不确定', response: '月亮的迷雾里有一条小路，通往两座塔之间。你不确定是因为还没走到塔那里——先走，走几步迷雾会散。' },
      { emoji: '💔', label: '舍不得', response: '月亮下面的那只小龙虾，从水里爬到陆地上——它不是离开，是在进化。你的舍不得不是因为失去，是因为变化。' },
      { emoji: '🤷', label: '两个都有', response: '那就慢慢来。月亮不需要你马上做决定——它只是提醒你：迷雾里藏着答案，你看不清，但它在。' },
    ],
  },
  {
    id: 'fuq_moon_02',
    question: '你一天中有多少时间在"猜测别人怎么想"？',
    options: [
      { emoji: '⏰', label: '很多', response: '月亮牌的猎物就在两座塔之间嚎叫——那个嚎叫不是威胁，是在喊：我被困在自己的想象里了。你不是被困——你只是看得太认真了。' },
      { emoji: '🕐', label: '有一些', response: '减少一半。今天的另一半精力用来猜测"自己怎么想"。你会惊讶——你其实比自己以为的更清楚。' },
      { emoji: '🕒', label: '不多', response: '那你已经走出了月亮牌的迷雾。保持这份清醒——月亮是循环的，但你可以选择不迷路。' },
    ],
  },
  {
    id: 'fuq_moon_03',
    question: '你上一次"完全不想别人"是什么时候？',
    options: [
      { emoji: '😌', label: '最近有过', response: '记住那个时刻。那是月亮最亮的时候——不是没有黑暗，是黑暗被照亮了。经常回那个时刻充电。' },
      { emoji: '🤔', label: '很久了', response: '月亮牌说：是时候从别人的故事里抽身了。你不是别人故事里的配角——你是自己故事里的主角。' },
      { emoji: '😞', label: '想不起来', response: '那就今天。关掉所有外界输入一小时。月亮在窗外陪你——它知道的，黑暗不可怕，可怕的是你忘了看月亮。' },
    ],
  },
];

// ═══════════════════════════════════════════════════════════
// 汇总导出：MVP 8 张牌结构化解读 Map
// ═══════════════════════════════════════════════════════════

/**
 * 获取指定卡牌的结构化解读数据。
 * @param cardId - 牌 ID，例如 'major_18_moon'
 * @returns StructuredInterpretation 或 undefined
 */
export function getMVP8CardData(cardId: string): StructuredInterpretation | undefined {
  return MVP8_STRUCTURED_DATA.get(cardId);
}

/**
 * 根据 cardId 和 emotionTag 获取场景化解读内容。
 * @returns ScenarioContent 或 undefined
 */
export function getScenarioContent(cardId: string, emotionTag: EmotionTag): ScenarioContent | undefined {
  const card = MVP8_STRUCTURED_DATA.get(cardId);
  if (!card) {
    return undefined;
  }
  return card.scenarioMap[emotionTag];
}

/**
 * 根据 cardId 获取金句（指定情绪场景）。
 * @returns goldenSentence 字符串或空字符串
 */
export function getGoldenSentence(cardId: string, emotionTag: EmotionTag): string {
  const scenario = getScenarioContent(cardId, emotionTag);
  return scenario ? scenario.goldenSentence : '';
}

// ── 内部结构化数据 Map ──
const MVP8_STRUCTURED_DATA: Map<string, StructuredInterpretation> = new Map();

MVP8_STRUCTURED_DATA.set('major_00_fool', {
  cardId: 'major_00_fool',
  scenarioMap: FOOL_SCENARIO,
  followUpQuestions: FOOL_FOLLOWUP,
  personalityType: '慢热重启型',
  deepInterpretation: '愚人牌是大阿卡纳的起点，编号 0，蕴含一切可能。它不是一个"什么都不懂"的人，而是一个"知道风险但却选择相信生活"的人。你抽到愚人，说明你心里有一个声音在说：够了，我想换个活法。但你害怕——害怕失败，害怕别人的眼光，害怕走错一步就回不去了。愚人告诉你的是：回不去本身不可怕，可怕的是你从来没有出发过。回头看看那个悬崖边，愚人正仰头看天空，他的脚边有一只小狗在叫——那只小狗是你的直觉，是你的朋友，是你心里那个一直在喊"试一下也不会让一切失控"的声音。听到了吗？',
  cardMeaningBrief: '愚人是塔罗的第一张牌，代表"全新的开始"。选到它意味着你的潜意识正在渴望一次重启——不要等到一切就绪才行动，第一步本身就是答案。',
});

MVP8_STRUCTURED_DATA.set('major_02_high_priestess', {
  cardId: 'major_02_high_priestess',
  scenarioMap: PRIESTESS_SCENARIO,
  followUpQuestions: PRIESTESS_FOLLOWUP,
  personalityType: '高敏感知型',
  deepInterpretation: '女祭司是大阿卡纳的 2 号，编号 2 在塔罗中代表二元、平衡与选择。她坐在两根柱子之间——左边是黑柱（阴性力量），右边是白柱（阳性力量）。她手里拿着一卷书，书有一半被遮住了——这不是说知识不可得，而是说有些答案不在书里，在你的直觉里。你抽到女祭司，说明你正在一段"不知道该怎么办"的时期。这种感觉很折磨，但女祭司告诉你：不知道怎么办本身就是一种答案——它在说"现在不是做决定的时候"。安静，观察，等待。月亮背后有太阳，帷幕之后有真相。你可以先试着坐一会儿，什么都不做，你会更容易看清自己的真实感受。',
  cardMeaningBrief: '女祭司是塔罗中最沉默也最有力量的一张牌。她坐在帷幕之门前，代表直觉、潜意识和未说出口的真相。抽到它说明你心里有很多话——只是还没找到对的方式说出口。不是别人不懂你，是你自己还没把这些感受说出来。',
});

MVP8_STRUCTURED_DATA.set('major_06_lovers', {
  cardId: 'major_06_lovers',
  scenarioMap: LOVERS_SCENARIO,
  followUpQuestions: LOVERS_FOLLOWUP,
  personalityType: '温柔内耗型',
  deepInterpretation: '恋人牌是大阿卡纳的 6 号，传统描绘了两个人站在选择面前、上方有守护意象的场景。但它的核心不是"爱情"，而是"选择"。你在关系中、职场中、人生方向上反复纠结，其实都在问一个问题：我该选让我舒服的，还是选让别人满意的？恋人牌的回答很直接：选你内心认同的那个。不是选容易的，不是选安全的，不是选"别人不会说什么的"——是选那个一年后你不会后悔的。选错也没关系，选错的代价永远小于"从来没为自己选过"。',
  cardMeaningBrief: '恋人不只是爱情牌——它是塔罗中关于"选择"和"价值观"最重要的牌。抽到它意味着你正站在一个十字路口。这不是生活在考验你，而是这个选择正在提醒你重新确认价值观——选择那个和你内心价值观一致的方向，而不是别人希望你走的路。',
});

MVP8_STRUCTURED_DATA.set('major_07_chariot', {
  cardId: 'major_07_chariot',
  scenarioMap: CHARIOT_SCENARIO,
  followUpQuestions: CHARIOT_FOLLOWUP,
  personalityType: '清醒忍耐型',
  deepInterpretation: '战车是大阿卡纳的 7 号。数字 7 代表突破与超越——在 6（恋人/选择）之后，你做出了选择，战车就是执行选择的那个力量。牌面上，战车战士站在战车上，前面是两头灵兽（一黑一白），没有缰绳——他是用意志力在驾驭它们。你抽到战车，说明你正在硬撑。撑一件事、一段关系、一个局面。你觉得自己必须扛，因为"我不扛就没人扛了"。但战车的真正智慧是：你不是在拉车——你是在驾车。驾驶员不用亲自推车，驾驶员只需要把握方向。找到你的方向，然后让力量自然流动，而不是被"硬撑"消耗殆尽。',
  cardMeaningBrief: '战车是塔罗中的"行动力之王"。抽到它说明你有足够的能量去突破现状——只是这股能量一直被"扛着"消耗了。战车告诉你：你不是不够强，你是把力量用错了方向。也许可以先把方向看清，再让力量自然流动。',
});

MVP8_STRUCTURED_DATA.set('major_09_hermit', {
  cardId: 'major_09_hermit',
  scenarioMap: HERMIT_SCENARIO,
  followUpQuestions: HERMIT_FOLLOWUP,
  personalityType: '高敏感知型',
  deepInterpretation: '隐士是大阿卡纳的 9 号。9 是最后一个个位数，代表完成前的最后一步——你已经走了很远，但在进入下一个阶段（10 命运之轮）之前，你需要停下来，反问自己：我走了这么多路，到底是为了什么？隐士手中的灯不是照路的——是照心的。他站在雪山之巅，不是因为那里没有别人，而是因为在那个高度，世界安静到足以让你听见自己呼吸的节奏。你感到疲惫、纠结、能量低落——不是因为你不够好，是因为你太久没有和自己对话了。你不缺答案，你缺安静。',
  cardMeaningBrief: '隐士是大阿卡纳 9 号，手握灯盏独自立于山巅。他不逃避世界——他在积蓄智慧。抽到它意味着你需要一段安静的独处时间，不是为了躲开问题，而是为了在寂静中听见自己。',
});

MVP8_STRUCTURED_DATA.set('major_10_wheel_of_fortune', {
  cardId: 'major_10_wheel_of_fortune',
  scenarioMap: WHEEL_SCENARIO,
  followUpQuestions: WHEEL_FOLLOWUP,
  personalityType: '清醒忍耐型',
  deepInterpretation: '命运之轮是大阿卡纳的第 10 号。10 是第一个"双位数"——1 代表新的开始，0 代表返回原点。这意味着你正在完成一个完整的循环。牌面上，轮子四周有四种象征：风（理性）、水（情感）、土（稳定）、火（动力）——它们各自在观察循环的规律。轮子顶端持剑者代表清醒与平衡。轮子上的符号都在说同一件事：一切都在循环。你感到低谷、纠结、不确定——但命运之轮告诉你：你不在底部——你在一个正在转动的位置。轮子往哪里转，部分取决于你愿不愿意跟着动。唯一的问题是：你愿意相信吗？',
  cardMeaningBrief: '命运之轮是大阿卡纳的 10 号，代表自然的循环法则。10 也是一个循环的完成和新的开始——1 和 0 的组合。抽到它说明你的生活正处在变化之中。不要抗拒变化——顺着变化的方向，让它带你到该去的地方。',
});

MVP8_STRUCTURED_DATA.set('major_13_death', {
  cardId: 'major_13_death',
  scenarioMap: DEATH_SCENARIO,
  followUpQuestions: DEATH_FOLLOWUP,
  personalityType: '慢热重启型',
  deepInterpretation: '死神是大阿卡纳的第 13 号。13 在塔罗结构中常被理解为旧状态退场与新阶段打开的节点。12 是倒吊人（接受生活的悬置），13 是死神——悬置之后，也许你可以先试着放手。牌面上，死神骑着白马，脚下踏过倒下的旧有结构。但请注意：远处有太阳，河上有船，有人保持沉静与接纳，小孩献花——死神不是杀戮者，是清理者。黑旗上的白色玫瑰代表纯粹的新生，黑色铠甲代表必要的保护。这张牌的重点不是夺取，而是整理。它提醒你把已经不再滋养你的东西送出生活，然后让新的空间慢慢出现。你怕放手，怕失去，怕「没了就没了」——但很多时候，正是旧状态退场，新的可能才有位置生长。',
  cardMeaningBrief: '死神是塔罗中最被误解的牌——它不预言真正的死亡，它代表"必须结束的东西"。抽到它说明你心里有一样东西该放手了。不是坏事——死神背后的太阳正在升起，那是新生的光。',
});

MVP8_STRUCTURED_DATA.set('major_18_moon', {
  cardId: 'major_18_moon',
  scenarioMap: MOON_SCENARIO,
  followUpQuestions: MOON_FOLLOWUP,
  personalityType: '温柔内耗型',
  deepInterpretation: '月亮是大阿卡纳的第 18 号。18 可以拆成 1+8=9（隐士），也可以看成 1 和 8——新的开始（1）和力量/无限（8）。这意味着月亮牌既是迷失也是入口。牌面上，月亮巨大而低垂，滴落的水珠滋养着大地；一条小路蜿蜒穿过两座塔之间的山谷；一只狗和一头狼对着月亮嚎叫；水中有只小龙虾正在爬上岸。狗是你被驯化的恐惧（"别人会怎么看我"），狼是你原始的恐惧（"我不够好"）。它们都在叫——但月亮不说话，它只是照亮。照亮不是驱散黑暗——是让你看到：黑暗里有一条路，有两座塔（你的本能和你的理性），有一只小龙虾（你的潜意识）正在上岸。你不是想太多——你只是太久没有在黑暗中安静地坐了。',
  cardMeaningBrief: '月亮是塔罗中关于"内耗"最精准的一张牌。它代表潜意识、不安和迷雾。抽到它说明你正在被反复念头困扰——不是你想太多，是你的安全感正在向你求救。月亮的两座塔之间有一条小路——你只需要走一步，迷雾就会开始散。',
});

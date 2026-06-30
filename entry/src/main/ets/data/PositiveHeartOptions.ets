/**
 * 单牌快占 · 积极方向选项与场景化文案
 *
 * 新增 6 个积极方向，供单牌快占使用。
 * 不用于三牌和关系探索。
 *
 * 产品边界：
 * - 不预言未来、不承诺好运、不说一定成功
 * - 不制造宿命感、不说命运安排、不替用户做决定
 * - 积极感 = 温柔、有光、克制、具体、不夸张、不鸡血
 */
import { ScenarioContent } from '../model/TarotCard';
import { MVP8_CARD_IDS } from './MVP8CardsData';
import { CardWeightItem, DrawCardResult } from './HeartOptionsData';

/**
 * 积极方向标签类型（6 个）
 */
export type PositiveEmotionTag =
  | '给我鼓励'
  | '今日微光'
  | '找回力量'
  | '一点勇气'
  | '积极一面'
  | '一句提醒';

/**
 * 积极方向选项接口
 */
export interface PositiveHeartOption {
  index: number;             // 0-5
  emoji: string;
  label: string;             // 选项标题
  description: string;       // 简短说明文案
  emotionTag: PositiveEmotionTag;  // 积极情绪标签
}

/**
 * 6 个积极方向选项
 */
export const POSITIVE_HEART_OPTIONS: PositiveHeartOption[] = [
  {
    index: 0,
    emoji: '🌟',
    label: '给我一点鼓励',
    description: '当你有点低落时，让一张牌陪你看见还在的力量。',
    emotionTag: '给我鼓励',
  },
  {
    index: 1,
    emoji: '✨',
    label: '看看今天的微光',
    description: '不追问答案，只看看今天有什么温柔的小提醒。',
    emotionTag: '今日微光',
  },
  {
    index: 2,
    emoji: '🔥',
    label: '我想找回力量',
    description: '把注意力从消耗中收回来，看看自己还能握住什么。',
    emotionTag: '找回力量',
  },
  {
    index: 3,
    emoji: '🕊️',
    label: '给自己一点勇气',
    description: '不是催你立刻向前，而是陪你迈出很小的一步。',
    emotionTag: '一点勇气',
  },
  {
    index: 4,
    emoji: '🌤️',
    label: '帮我看见积极的一面',
    description: '不是否认困难，而是在困难旁边找一点光。',
    emotionTag: '积极一面',
  },
  {
    index: 5,
    emoji: '💫',
    label: '给现在的我一句提醒',
    description: '让一张牌成为今天的一句温柔提醒。',
    emotionTag: '一句提醒',
  },
];

/**
 * 积极方向抽牌权重（与原有 6 个情绪标签独立）
 * 使用 MVP 8 张牌，权重偏均衡，稍侧重温和牌（隐士、命运之轮）
 */
export const POSITIVE_CARD_WEIGHTS: Record<PositiveEmotionTag, Record<string, number>> = {
  '给我鼓励': {
    'major_00_fool': 15,
    'major_02_high_priestess': 12,
    'major_06_lovers': 12,
    'major_07_chariot': 18,
    'major_09_hermit': 13,
    'major_10_wheel_of_fortune': 15,
    'major_13_death': 5,
    'major_18_moon': 10,
  },
  '今日微光': {
    'major_00_fool': 18,
    'major_02_high_priestess': 15,
    'major_06_lovers': 10,
    'major_07_chariot': 10,
    'major_09_hermit': 15,
    'major_10_wheel_of_fortune': 12,
    'major_13_death': 5,
    'major_18_moon': 15,
  },
  '找回力量': {
    'major_00_fool': 10,
    'major_02_high_priestess': 10,
    'major_06_lovers': 10,
    'major_07_chariot': 25,
    'major_09_hermit': 15,
    'major_10_wheel_of_fortune': 15,
    'major_13_death': 10,
    'major_18_moon': 5,
  },
  '一点勇气': {
    'major_00_fool': 22,
    'major_02_high_priestess': 10,
    'major_06_lovers': 10,
    'major_07_chariot': 18,
    'major_09_hermit': 10,
    'major_10_wheel_of_fortune': 10,
    'major_13_death': 12,
    'major_18_moon': 8,
  },
  '积极一面': {
    'major_00_fool': 15,
    'major_02_high_priestess': 12,
    'major_06_lovers': 12,
    'major_07_chariot': 15,
    'major_09_hermit': 10,
    'major_10_wheel_of_fortune': 18,
    'major_13_death': 8,
    'major_18_moon': 10,
  },
  '一句提醒': {
    'major_00_fool': 12,
    'major_02_high_priestess': 18,
    'major_06_lovers': 12,
    'major_07_chariot': 10,
    'major_09_hermit': 20,
    'major_10_wheel_of_fortune': 12,
    'major_13_death': 6,
    'major_18_moon': 10,
  },
};

// ═══════════════════════════════════════════════════════════
// 愚人（The Fool · major_00_fool）积极方向场景化文案
// ═══════════════════════════════════════════════════════════
const FOOL_POSITIVE: Record<PositiveEmotionTag, ScenarioContent> = {
  '给我鼓励': {
    goldenSentence: '你不是必须一下子变得很强。能愿意继续照顾自己，本身已经是一种力量。',
    emotionKeywords: ['重新开始', '轻盈', '相信自己'],
    todayAction: '今天可以只做一件很小的事：把自己从混乱里轻轻带回来。',
  },
  '今日微光': {
    goldenSentence: '这张牌不是在告诉你今天一定会发生好事，而是在提醒你：有些微小的明亮，可能需要你慢一点才看得见。',
    emotionKeywords: ['慢下来', '微小美好', '觉察'],
    todayAction: '今天试着记录一个让你没那么沉重的瞬间。',
  },
  '找回力量': {
    goldenSentence: '一个全新的开始，不需要你准备好——只需要你愿意。',
    emotionKeywords: ['空白', '可能', '信任'],
    todayAction: '今天只做一件小事：走出房间，呼吸新鲜空气。',
  },
  '一点勇气': {
    goldenSentence: '想不清楚的时候，不如先跳一步。答案不在脑子里，在行动里。',
    emotionKeywords: ['犹豫', '勇气', '突破'],
    todayAction: '今天只迈出一步就好，不需要证明全部。',
  },
  '积极一面': {
    goldenSentence: '愚人从来不回头看悬崖，他只看见前方的天空。也许你也有一个还没被看见的远方。',
    emotionKeywords: ['开放', '可能', '轻盈'],
    todayAction: '写下你真正想做的一件事——不需要很大，只写下来就好。',
  },
  '一句提醒': {
    goldenSentence: '你啊，心里那个小孩想出去玩。不是要你勇敢，是要你轻装上阵。',
    emotionKeywords: ['轻盈', '直觉', '童心'],
    todayAction: '对自己说一句：今天可以什么都不做好。',
  },
};

// ═══════════════════════════════════════════════════════════
// 女祭司（The High Priestess · major_02_high_priestess）积极方向场景化文案
// ═══════════════════════════════════════════════════════════
const PRIESTESS_POSITIVE: Record<PositiveEmotionTag, ScenarioContent> = {
  '给我鼓励': {
    goldenSentence: '有些事情不需要答案，只需要一个安静的空间和你自己。你比自己以为的更有内在的沉稳。',
    emotionKeywords: ['自我对话', '内在安宁', '觉察'],
    todayAction: '给今天的自己泡一杯茶，就当是星澜陪你坐了一会儿。',
  },
  '今日微光': {
    goldenSentence: '安静下来。有些明亮不在外面，在你心里那个最安静的地方。',
    emotionKeywords: ['内观', '安静', '智慧'],
    todayAction: '找一个安静的地方坐五分钟，不问任何人意见，只听自己。',
  },
  '找回力量': {
    goldenSentence: '不是所有的力量都要外放。有些时候，最大的力量是你选择了不解释。',
    emotionKeywords: ['独处', '恢复', '边界感'],
    todayAction: '今天拒绝一件你不想做的事——这是一种力量。',
  },
  '一点勇气': {
    goldenSentence: '有些真相不需要别人说出来——你的身体已经在告诉你了。相信那个安静的声音。',
    emotionKeywords: ['直觉', '沉默', '等待'],
    todayAction: '写下你在心里"感觉到但没说出口"的一件事。',
  },
  '积极一面': {
    goldenSentence: '你不是想太多。女祭司的智慧就是：相信你感觉到的东西，哪怕别人说你想多了。',
    emotionKeywords: ['直觉', '觉察', '自信'],
    todayAction: '今天留意一下第一个让你"心里一动"的感觉，把它记下来。',
  },
  '一句提醒': {
    goldenSentence: '女祭司坐在帷幕之前，不是因为她不知道答案，而是因为她知道有些事不需要急着揭开。',
    emotionKeywords: ['沉淀', '耐心', '信任过程'],
    todayAction: '今天不要追问任何答案——让它自己浮现。',
  },
};

// ═══════════════════════════════════════════════════════════
// 恋人（The Lovers · major_06_lovers）积极方向场景化文案
// ═══════════════════════════════════════════════════════════
const LOVERS_POSITIVE: Record<PositiveEmotionTag, ScenarioContent> = {
  '给我鼓励': {
    goldenSentence: '你不是一个人在纠结。每个人面对重要选择时，手心都会出汗。能认真对待选择的人，值得被肯定。',
    emotionKeywords: ['陪伴', '共情', '释怀'],
    todayAction: '给一个信任的人发条消息，就说一句"我今天有点需要被鼓励"。',
  },
  '今日微光': {
    goldenSentence: '有些选择不是选 A 或选 B，是选择"你想成为什么样的人"。这个问题本身就很有光。',
    emotionKeywords: ['身份认同', '真实自我', '方向'],
    todayAction: '问问自己：这个选择会让一年后的我谢自己，还是怪自己？',
  },
  '找回力量': {
    goldenSentence: '你不需要别人给你能量——你需要的是和自己达成和解。和解本身，就是一种力量。',
    emotionKeywords: ['自我接纳', '内心矛盾', '放下'],
    todayAction: '对镜子里的自己说一句：你已经做得很好了。',
  },
  '一点勇气': {
    goldenSentence: '恋人牌的核心不是"选哪个"，而是"你是否愿意为自己的选择负责"。愿意承担，就是勇气。',
    emotionKeywords: ['选择', '担当', '成长'],
    todayAction: '今天做一个已经拖了很久的小决定——不求完美，求"结束犹豫"。',
  },
  '积极一面': {
    goldenSentence: '一段健康的选择，不需要反复确认"值不值得"。你的心比你想象的更清楚答案。',
    emotionKeywords: ['价值观', '清晰', '内心认同'],
    todayAction: '列出你在这个选择中最看重的三个东西——答案可能已经在里面了。',
  },
  '一句提醒': {
    goldenSentence: '恋人牌问的从来不是"你要选谁"，是"你选自己还是选恐惧"。记得把自己加回选项里。',
    emotionKeywords: ['自我优先', '真实', '勇气'],
    todayAction: '今天给自己一个完整的下午，不考虑任何人的意见，只问自己想要什么。',
  },
};

// ═══════════════════════════════════════════════════════════
// 战车（The Chariot · major_07_chariot）积极方向场景化文案
// ═══════════════════════════════════════════════════════════
const CHARIOT_POSITIVE: Record<PositiveEmotionTag, ScenarioContent> = {
  '给我鼓励': {
    goldenSentence: '这张牌像是在提醒你：你不是必须一下子变得很强。能愿意继续照顾自己，本身已经是一种力量。',
    emotionKeywords: ['硬扛', '温柔对自己', '坚持'],
    todayAction: '对自己承认一句：我也有不想扛的时候，这没关系。',
  },
  '今日微光': {
    goldenSentence: '战车的两头灵兽一黑一白——黑的是你的恐惧，白的是你的渴望。它们往同一个方向拉，才能前进。今天先看看渴望在指哪边。',
    emotionKeywords: ['方向', '渴望', '看见'],
    todayAction: '抬头看一下——前面有什么让你想跑过去的东西？',
  },
  '找回力量': {
    goldenSentence: '这张牌像一面镜子，照见你身上还没有完全熄灭的部分。也许你比自己以为的更能撑住一点。',
    emotionKeywords: ['内在力量', '掌控', '韧性'],
    todayAction: '把注意力放回一件你可以掌控的小事上。',
  },
  '一点勇气': {
    goldenSentence: '想好了就出发。犹豫不决的时候，你在消耗的不是时间，是自己的气势。',
    emotionKeywords: ['行动力', '决心', '掌控'],
    todayAction: '今天做一个已经拖了一周的决定——不求完美，求"结束犹豫"。',
  },
  '积极一面': {
    goldenSentence: '你不是累在活多，是累在"没人看到我在扛"。但你自己看到了——这就是起点。',
    emotionKeywords: ['被看见', '认可自己', '释放'],
    todayAction: '今天跟一个人说一句：我最近有点累，不用帮我解决，听我说说就好。',
  },
  '一句提醒': {
    goldenSentence: '战车不是用来逞强的。你叫一个人坐副驾驶不是示弱——是让对方知道"我需要你"。',
    emotionKeywords: ['求助', '分享', '连接'],
    todayAction: '问自己：谁是那个可以帮你分担的人？',
  },
};

// ═══════════════════════════════════════════════════════════
// 隐士（The Hermit · major_09_hermit）积极方向场景化文案
// ═══════════════════════════════════════════════════════════
const HERMIT_POSITIVE: Record<PositiveEmotionTag, ScenarioContent> = {
  '给我鼓励': {
    goldenSentence: '有些路确实要一个人走。不是孤独——是沉淀。你手里那盏灯，就是给自己的温暖。',
    emotionKeywords: ['自我陪伴', '内在力量', '温暖自给'],
    todayAction: '给自己写一封信，开头是：亲爱的自己，最近辛苦你了。',
  },
  '今日微光': {
    goldenSentence: '隐士手中的灯不是照路的——是照心的。今天不需要找答案，只需要照一照自己。',
    emotionKeywords: ['内省', '温柔', '安静'],
    todayAction: '关掉手机一小时，做一件纯粹为自己做的事。',
  },
  '找回力量': {
    goldenSentence: '你不是没能量，你是把能量花在了"让别人理解你"这件事上。省省电，把注意力收回来。',
    emotionKeywords: ['社交消耗', '精神独处', '回收能量'],
    todayAction: '今天拒绝一场社交，用那段时间给自己做顿饭。',
  },
  '一点勇气': {
    goldenSentence: '想不明白的时候，不是信息不够——是噪音太多。躲开所有人的意见，你已经有答案了。',
    emotionKeywords: ['减法', '直觉', '果断'],
    todayAction: '今天不跟任何人讨论你的纠结，自己写下来，写完就放下。',
  },
  '积极一面': {
    goldenSentence: '隐士站在雪山之巅，不是因为那里没有别人，而是因为在那个高度，世界安静到足以让你听见自己呼吸的节奏。',
    emotionKeywords: ['独处', '清晰', '高度'],
    todayAction: '给自己一个完整的下午，不看手机，就待着。',
  },
  '一句提醒': {
    goldenSentence: '你不是职业倦怠，你是太久没有问自己"我想要什么"了。今天把这个问题的音量调大一点。',
    emotionKeywords: ['方向', '自我对话', '意义感'],
    todayAction: '请一天假，一个人去一个从来没去过的地方。',
  },
};

// ═══════════════════════════════════════════════════════════
// 命运之轮（Wheel of Fortune · major_10_wheel_of_fortune）积极方向场景化文案
// ═══════════════════════════════════════════════════════════
const WHEEL_POSITIVE: Record<PositiveEmotionTag, ScenarioContent> = {
  '给我鼓励': {
    goldenSentence: '你在漩涡里打转的时候，最容易忘记一件事：轮子是会转的。你不在底部——你在一个正在转动的位置。',
    emotionKeywords: ['周期', '转机', '希望'],
    todayAction: '写下过去 3 个月发生的 3 件好事——你可能忘了它们发生过。',
  },
  '今日微光': {
    goldenSentence: '一切都在变化。今天的你，和昨天的你，已经不是同一个位置了。抬头看看轮子在往哪边转。',
    emotionKeywords: ['流动', '变化', '当下'],
    todayAction: '今晚抬头看一分钟的夜空——世界在转，你也在转，一切都会流动。',
  },
  '找回力量': {
    goldenSentence: '运气不是天上掉馅饼。运气是你能不能在"对的时间"站在"对的地方"。轮子在转了——你已经在路上了。',
    emotionKeywords: ['时机', '顺势', '行动'],
    todayAction: '问问自己：现在的生活里，哪个方向正在"上升"？',
  },
  '一点勇气': {
    goldenSentence: '轮子在转的时候，最重要的是"上轮子"，不是"选左边还是右边"。先迈一步，行动会带来新的反馈。',
    emotionKeywords: ['顺势而为', '行动优先', '不纠结'],
    todayAction: '不管三七二十一，先朝一个方向走一步——行动会带来新的反馈。',
  },
  '积极一面': {
    goldenSentence: '命运之轮上的四种生物在读书——它们不是在看你怎么摔，它们在学习规律：每一段下坠都在为下一次上升蓄力。',
    emotionKeywords: ['规律', '耐心', '成长'],
    todayAction: '对自己说：现在是缓冲期，我在充电，不是在退步。',
  },
  '一句提醒': {
    goldenSentence: '命运之轮顶端的持剑者——它既代表外部的节奏，也代表你可以把握的瞬间。你手里也有那把剑。',
    emotionKeywords: ['清醒', '平衡', '把握'],
    todayAction: '今天做一件你完全掌控的小事——它会提醒你：你不是被动的。',
  },
};

// ═══════════════════════════════════════════════════════════
// 死神（Death · major_13_death）积极方向场景化文案
// ═══════════════════════════════════════════════════════════
const DEATH_POSITIVE: Record<PositiveEmotionTag, ScenarioContent> = {
  '给我鼓励': {
    goldenSentence: '死神牌的真正含义不是结束，是"结束是为你让路"。那个空出来的位置，很快会被新的东西填满。',
    emotionKeywords: ['希望', '空白', '新生'],
    todayAction: '写下你最想"画上句号"的一件事——写完折起来，收进抽屉。',
  },
  '今日微光': {
    goldenSentence: '死神牌上太阳正在升起。不是终点，是起点。今天可以看到一丝新的光亮了。',
    emotionKeywords: ['黎明', '新开始', '温暖'],
    todayAction: '今天做一件你很久没做但很喜欢的小事——作为新开始的仪式。',
  },
  '找回力量': {
    goldenSentence: '你不是在放弃——你是在腾出双手，去接住更值得的东西。放手本身就是一种力量。',
    emotionKeywords: ['转型', '释放', '空间'],
    todayAction: '列出你从过去一段经历中学到的东西——带着它们走，比带着怨气走好。',
  },
  '一点勇气': {
    goldenSentence: '死神不是判决书——它是一张请假条。准许你放下那些已经不滋养你的东西。',
    emotionKeywords: ['止损', '蜕变', '勇气'],
    todayAction: '如果有一件事你已经想了很久要放手，今天对自己说一句：准许了。',
  },
  '积极一面': {
    goldenSentence: '像结束了一段旧状态是正常的。但不是真的死——是蜕皮。旧壳裂开，新皮肤很嫩，但会变硬。',
    emotionKeywords: ['脆弱期', '蜕变', '成长'],
    todayAction: '今天允许自己脆弱——不是软弱，是在长新的铠甲。',
  },
  '一句提醒': {
    goldenSentence: '死神牌上的白马不是乱跑的——它有方向。你的理性知道方向在哪，只是情绪还在拽缰绳。轻轻松一松。',
    emotionKeywords: ['方向', '释放', '信任'],
    todayAction: '问自己：如果让"一年后的你"来替你做这个决定——他会怎么做？',
  },
};

// ═══════════════════════════════════════════════════════════
// 月亮（The Moon · major_18_moon）积极方向场景化文案
// ═══════════════════════════════════════════════════════════
const MOON_POSITIVE: Record<PositiveEmotionTag, ScenarioContent> = {
  '给我鼓励': {
    goldenSentence: '怕黑是正常的。但别忘了一件事——月亮再暗，它也是太阳照亮的。光一直在，只是拐了个弯。',
    emotionKeywords: ['孤独感', '渴望温暖', '隐藏的光'],
    todayAction: '给自己做一碗热汤面——身体的温暖会慢慢传到心里。',
  },
  '今日微光': {
    goldenSentence: '你在迷雾里找路，星澜给你一盏灯——不是照亮远方，是照亮下一步。先走一步就好。',
    emotionKeywords: ['迷茫', '指引', '下一步'],
    todayAction: '告诉自己：我不需要看到终点，我只需要看到下一步。',
  },
  '找回力量': {
    goldenSentence: '你不需要在黑夜中找到出口——你需要的是在黑夜中先坐下，等月亮升到最高。',
    emotionKeywords: ['黑暗期', '耐心', '自我关照'],
    todayAction: '关灯点一支蜡烛，在烛光里坐十分钟——就坐着，什么都不想。',
  },
  '一点勇气': {
    goldenSentence: '月亮下面的那只小龙虾，从水里爬到陆地上——它不是离开，是在进化。你的不安不是退步，是变化。',
    emotionKeywords: ['进化', '变化', '适应'],
    todayAction: '今天走出舒适区一小步——不用很大，只需要和昨天有一点点不同。',
  },
  '积极一面': {
    goldenSentence: '月亮的两座塔之间有一条小路——你只需要走一步，迷雾就会开始散。那条路一直在那里。',
    emotionKeywords: ['出路', '希望', '行动'],
    todayAction: '今天直接做一件你一直在"想"但没"做"的事——哪怕只做五分钟。',
  },
  '一句提醒': {
    goldenSentence: '你不是想太多，你只是太久没有安全感。但月亮也在告诉你：你不需要看穿黑暗——你只需要在黑暗中安静地呼吸。',
    emotionKeywords: ['安全感', '自我关照', '呼吸'],
    todayAction: '今天不要追问任何答案——不翻记录、不发消息、不逼自己判断。',
  },
};

// ═══════════════════════════════════════════════════════════
// 汇总 Map
// ═══════════════════════════════════════════════════════════

const POSITIVE_SCENARIO_MAP: Map<string, Record<PositiveEmotionTag, ScenarioContent>> = new Map();

POSITIVE_SCENARIO_MAP.set('major_00_fool', FOOL_POSITIVE);
POSITIVE_SCENARIO_MAP.set('major_02_high_priestess', PRIESTESS_POSITIVE);
POSITIVE_SCENARIO_MAP.set('major_06_lovers', LOVERS_POSITIVE);
POSITIVE_SCENARIO_MAP.set('major_07_chariot', CHARIOT_POSITIVE);
POSITIVE_SCENARIO_MAP.set('major_09_hermit', HERMIT_POSITIVE);
POSITIVE_SCENARIO_MAP.set('major_10_wheel_of_fortune', WHEEL_POSITIVE);
POSITIVE_SCENARIO_MAP.set('major_13_death', DEATH_POSITIVE);
POSITIVE_SCENARIO_MAP.set('major_18_moon', MOON_POSITIVE);

/**
 * 获取积极方向的场景化解读内容
 */
export function getPositiveScenarioContent(
  cardId: string,
  positiveTag: PositiveEmotionTag
): ScenarioContent | undefined {
  const map: Record<PositiveEmotionTag, ScenarioContent> | undefined = POSITIVE_SCENARIO_MAP.get(cardId);
  if (!map) {
    return undefined;
  }
  return map[positiveTag];
}

/**
 * 获取积极方向的金句
 */
export function getPositiveGoldenSentence(cardId: string, positiveTag: PositiveEmotionTag): string {
  const scenario: ScenarioContent | undefined = getPositiveScenarioContent(cardId, positiveTag);
  return scenario ? scenario.goldenSentence : '';
}

/**
 * 积极方向加权随机抽牌
 * 复用 drawCardByWeight 的逻辑
 */
export function drawCardByPositiveWeight(positiveTag: PositiveEmotionTag, seed?: number): DrawCardResult {
  const weights: Record<string, number> | undefined = POSITIVE_CARD_WEIGHTS[positiveTag];
  if (!weights) {
    return { cardId: 'major_18_moon', isReversed: false };
  }

  const entries: CardWeightItem[] = [];
  let totalWeight: number = 0;

  for (const cardId of MVP8_CARD_IDS) {
    const w: number = weights[cardId] ?? 0;
    if (w > 0) {
      entries.push({ cardId, weight: w });
      totalWeight += w;
    }
  }

  if (entries.length === 0 || totalWeight <= 0) {
    return { cardId: 'major_18_moon', isReversed: false };
  }

  const random: number = seed ?? Math.random();
  let randomValue: number = random * totalWeight;
  let selectedCardId: string = 'major_18_moon';

  for (const entry of entries) {
    randomValue -= entry.weight;
    if (randomValue <= 0) {
      selectedCardId = entry.cardId;
      break;
    }
  }

  if (!MVP8_CARD_IDS.includes(selectedCardId)) {
    selectedCardId = 'major_18_moon';
  }

  return { cardId: selectedCardId, isReversed: false };
}

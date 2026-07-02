export interface TarotCard {
  id: number;
  name: string;
  englishName: string;
  upright: string;
  reversed: string;
  description: string;
  themeColor: string;
  element: "风" | "水" | "火" | "土";
}

export const MAJOR_ARCANA: TarotCard[] = [
  {
    id: 0,
    name: "愚人",
    englishName: "The Fool",
    upright: "新的开始、自由、冒险、纯真、自发性",
    reversed: "鲁莽、不负责任、迟疑不决、盲目、受阻",
    description: "一个年轻旅人站在悬崖边，眺望未知的世界。他身旁有一只忠诚的小狗，手里握着一朵白玫瑰，代表纯洁的渴望与对新旅程的无限信任。",
    themeColor: "from-amber-200 to-yellow-500",
    element: "风"
  },
  {
    id: 1,
    name: "魔术师",
    englishName: "The Magician",
    upright: "创造力、行动、意志力、专注力、掌控、才华",
    reversed: "意志消沉、幻灭、欺骗、能力未被利用、方向错误",
    description: "魔术师站在圣坛前，头顶无限大符号（∞）。圣坛上摆放着圣杯、宝剑、权杖与星币四种圣物，代表他拥有将意志转化为现实的一切元素与力量。",
    themeColor: "from-red-400 to-rose-600",
    element: "风"
  },
  {
    id: 2,
    name: "女祭司",
    englishName: "The High Priestess",
    upright: "直觉、潜意识、神秘、内心智慧、静止、冥想",
    reversed: "内心冲突、忽视直觉、流于表面、秘密被揭穿",
    description: "女祭司静坐在黑白两根石柱（B与J）之间，手持妥拉卷轴，身后悬挂着石榴石围幔。她代表着潜意识的智慧与不为人知的内心奥秘。",
    themeColor: "from-blue-400 to-indigo-600",
    element: "水"
  },
  {
    id: 3,
    name: "女皇",
    englishName: "The Empress",
    upright: "丰盛、自然、丰收、母性、创造、感官享受",
    reversed: "创造力受阻、过度保护、缺乏安全感、依赖他人",
    description: "女皇坐在华丽的王座上，身处郁郁葱葱的森林与金色麦田中。她头戴十二颗星星的王冠，手持金色权杖，散发着无尽的滋养与创造力。",
    themeColor: "from-emerald-400 to-teal-600",
    element: "土"
  },
  {
    id: 4,
    name: "皇帝",
    englishName: "The Emperor",
    upright: "权威、秩序、结构、稳固、保护、父亲形象",
    reversed: "暴政、掌控欲过强、缺乏自律、权威受损、僵化",
    description: "皇帝坐在饰有公羊头的坚硬石座上，身穿红色战袍与铠甲，手握代表支配权的宝球与权杖。他代表着世俗的最高秩序与理性的保护者。",
    themeColor: "from-amber-700 to-orange-800",
    element: "火"
  },
  {
    id: 5,
    name: "教皇",
    englishName: "The Hierophant",
    upright: "传统、精神向导、体制、仪式、契约、学习",
    reversed: "墨守陈规、叛逆、寻找个人道路、体制限制",
    description: "教皇端坐在圣殿中，身穿神圣的三层法袍，右手做出祝福的手势。他代表着传统的道德秩序、社会规范以及寻求心灵导师的庇护。",
    themeColor: "from-purple-500 to-indigo-700",
    element: "土"
  },
  {
    id: 6,
    name: "恋人",
    englishName: "The Lovers",
    upright: "爱、和谐、关系、价值观契合、选择、双向奔赴",
    reversed: "失和、内心挣扎、选择失误、沟通障碍、自私自利",
    description: "在一片温暖纯净的乐土中，一对男女在天使的祝福下深情对视。天空铺满金色的暖阳，红尘与灵性交织在一起。一段健康的契约不需要你反复确认。",
    themeColor: "from-pink-400 to-purple-500",
    element: "风"
  },
  {
    id: 7,
    name: "战车",
    englishName: "The Chariot",
    upright: "意志力、胜利、决心、自控力、克服障碍、行动",
    reversed: "失控、方向不明、动力流失、侵略性、阻碍",
    description: "英勇的战士驾驭着一黑一白两只狮身人面兽，冲向前方。战车没有缰绳，完全依靠他的精神力与钢铁意志来掌控平衡与方向。",
    themeColor: "from-cyan-500 to-blue-600",
    element: "水"
  },
  {
    id: 8,
    name: "力量",
    englishName: "Strength",
    upright: "内在力量、勇气、温柔、耐心、宽恕、同情心",
    reversed: "软弱、自我怀疑、恐惧、滥用权力、情绪失控",
    description: "一名白衣女子神态安详，用纯粹的温柔与抚摸驯服了一头威猛的狮子。她的头顶有着无限符号（∞），代表着温柔可以战胜粗暴的本能。",
    themeColor: "from-yellow-400 to-amber-600",
    element: "火"
  },
  {
    id: 9,
    name: "隐士",
    englishName: "The Hermit",
    upright: "内省、独自探索、内心引导、寻求真理、冷静",
    reversed: "孤立、孤独感、固执、过度挑剔、逃避现实",
    description: "一位年迈的老人身披灰色长袍，站在冰封的山巅。他左手拄着手杖，右手高举着一盏亮着六角星光芒的灯笼，照亮漆黑的心灵旅程。",
    themeColor: "from-slate-500 to-zinc-700",
    element: "土"
  },
  {
    id: 10,
    name: "命运之轮",
    englishName: "Wheel of Fortune",
    upright: "转机、好运、命运、不可控的变化、业力、新循环",
    reversed: "厄运、阻碍变化、打破旧循环、坏运气、逆境",
    description: "巨大的命运之轮悬浮在白云深处，轮盘上刻着古老神秘的符号。四周有代表四大元素的飞兽，默默注视着世间万物的交替与轮回。",
    themeColor: "from-blue-500 to-indigo-800",
    element: "火"
  },
  {
    id: 11,
    name: "正义",
    englishName: "Justice",
    upright: "公正、因果、诚实、真理、决断、责任归宿",
    reversed: "不公、逃避责任、偏见、不公正的评判、不平衡",
    description: "正义女神双目澄澈，端坐神圣法座。她右手高举代表决断的宝剑，左手提着衡量是非的天平，代表着真理、公平与客观的审视。",
    themeColor: "from-emerald-600 to-teal-800",
    element: "风"
  },
  {
    id: 12,
    name: "倒吊人",
    englishName: "The Hanged Man",
    upright: "换位思考、暂停、牺牲、奉献、释放、新视角",
    reversed: "毫无意义的拖延、无用功、抗拒改变、自我感动",
    description: "一个青年单腿倒吊在生命之树上，双手置于身后。他神情平静详和，脑后散发着金色的神圣智慧光芒。通过静止，他获得了全新的世界观。",
    themeColor: "from-violet-400 to-purple-600",
    element: "水"
  },
  {
    id: 13,
    name: "死神",
    englishName: "Death",
    upright: "结束、彻底蜕变、新陈代谢、旧事物的消除、重生",
    reversed: "抗拒改变、勉强维持、沉溺于过去、缓慢痛苦的调整",
    description: "身穿黑色铠甲的死神骑着白马缓缓走来，带走一切腐朽的过往。背景的地平线处，初升的旭日预示着一个充满希望的崭新开始。",
    themeColor: "from-neutral-800 to-neutral-950",
    element: "水"
  },
  {
    id: 14,
    name: "节制",
    englishName: "Temperance",
    upright: "平衡、融合、和谐、净化、节制、内心平静、炼金术",
    reversed: "失衡、冲突、缺乏协调、过度放纵、难以调和",
    description: "大天使一只脚踏在代表意识的水中，另一只脚踩在代表物质的坚石上。他神情宁静，正将金樽中的神圣泉水倒入另一个银杯中，创造完美的平衡。",
    themeColor: "from-sky-400 to-blue-500",
    element: "火"
  },
  {
    id: 15,
    name: "恶魔",
    englishName: "The Devil",
    upright: "执念、物质束缚、欲望、沉迷、影子自我、无形禁锢",
    reversed: "觉醒、解除束缚、直面阴暗面、重获自由、理智回归",
    description: "带翼的恶魔端坐在高石上，底座铁链系着一对男女。铁链其实十分宽松，随时可以脱掉。它揭示了我们内心的沉迷、自设的牢笼和盲目的欲望。",
    themeColor: "from-stone-800 to-red-950",
    element: "土"
  },
  {
    id: 16,
    name: "高塔",
    englishName: "The Tower",
    upright: "剧变、幻觉破灭、突发灾难、启示、重组、重获自由",
    reversed: "逃过一劫、抗拒必要的重建、慢性摩擦、延缓灾祸",
    description: "高耸的金顶石塔被一道猛烈的闪电击毁，王冠坠落，人们坠入深渊。虽然痛苦，但这摧毁了我们建立在沙滩之上的虚伪城堡与幻觉。",
    themeColor: "from-amber-900 to-stone-900",
    element: "火"
  },
  {
    id: 17,
    name: "星星",
    englishName: "The Star",
    upright: "希望、信念、宁静、治愈、启发、宇宙的指引、灵感",
    reversed: "失去希望、缺乏信念、灵感枯竭、消极、迷失方向",
    description: "夜空群星闪耀，一颗巨大的八角恒星洒落银辉。一位纯洁的少女倾倒两个水瓶，将泉水倾注入大地与湖泊，代表生命之源与希望的永恒治愈力。",
    themeColor: "from-cyan-400 to-blue-600",
    element: "风"
  },
  {
    id: 18,
    name: "月亮",
    englishName: "The Moon",
    upright: "直觉、幻想、恐惧、不安、潜意识、未知的真相、波动",
    reversed: "误会澄清、直面恐惧、真相大白、迷雾散去、好转",
    description: "一轮满月悬挂半空，月容流露悲悯之情。地上一只狼与一只家犬对着月光嚎叫，一只龙虾从无意识的深海爬出。它代表着内心的焦虑、直觉与梦境。",
    themeColor: "from-indigo-700 to-slate-900",
    element: "水"
  },
  {
    id: 19,
    name: "太阳",
    englishName: "The Sun",
    upright: "成功、喜悦、活力、光明、真理、自信、温暖、慷慨",
    reversed: "短暂的灰暗、缺乏活力、盲目自负、未被充分认可",
    description: "一轮巨大的太阳普照大地，金色向日葵在墙角傲然绽放。一个纯真的孩童骑着白马，手举红色旗帜，洋溢着无尽的生机、真理与喜悦活力。",
    themeColor: "from-amber-400 to-red-500",
    element: "火"
  },
  {
    id: 20,
    name: "审判",
    englishName: "Judgement",
    upright: "觉醒、重获新生、感召、释怀、关键抉择、业力了结",
    reversed: "自我怀疑、拒绝召唤、拖延不决、重蹈覆辙、执迷不悟",
    description: "天使高举红十字旗炽，吹响神圣的小号。逝去的亡者从棺木中坐起，张开双臂迎接神圣的净化与呼唤。它代表着心灵的觉醒与灵魂的重生。",
    themeColor: "from-purple-600 to-fuchsia-800",
    element: "火"
  },
  {
    id: 21,
    name: "世界",
    englishName: "The World",
    upright: "圆满、达成、旅程终点、和谐、世界大同、自由、整合",
    reversed: "功败垂成、缺乏圆满、未完成的旅程、窒息感、停滞不前",
    description: "一位女子在绿叶花环中翩翩起舞，花环四周环绕着鹰、狮、牛、人四大神兽。她代表着一段重大生命旅程的完美闭环与身心灵的终极和谐。",
    themeColor: "from-teal-500 to-emerald-700",
    element: "土"
  }
];

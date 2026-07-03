/**
 * 占卜结果进入聊天时的最小必要上下文
 *
 * 对应开发计划 3.2 节 DivinationConversationContext：
 * 占卜结果页"和星澜继续聊聊"携带本上下文进入星澜聊天，
 * 星澜不重新抽牌、不改正逆位、不推断新牌阵事实。
 *
 * 限制：
 * - 不携带无关隐私
 * - 不让 LLM / 规则引擎重新决定牌面
 * - 不允许 LLM / 规则引擎改写正逆位
 * - userAcceptedInterpretation=false 时，进入聊天后不得继续强行引用同一解释
 * - 星澜进入聊天后不重复整篇结果，只从用户最有感的一部分继续
 */
export interface DivinationConversationContext {
  /** 牌阵模式 */
  mode: 'single' | 'triangle' | 'relation' | 'wheel';
  /** 牌名列表（按位置顺序） */
  cardNames: string[];
  /** 正逆位列表（与 cardNames 等长，'upright'=正位 / 'reversed'=逆位） */
  orientations: ('upright' | 'reversed')[];
  /** 位置名列表（与 cardNames 等长） */
  positionNames: string[];
  /** 问心模式：'held'=今天我想被接住 / 'light'=今天我想看见光；缺失表示未经过问心页 */
  heartMode?: 'held' | 'light';
  /** 问心选项 ID（若经过问心页） */
  heartOptionId?: string;
  /** 结果页核心摘要（一句话总览，不重复整篇结果） */
  coreSummary: string;
  /** 用户是否接受结果页解释；false 表示用户点了"有一部分不太像我" */
  userAcceptedInterpretation?: boolean;
}

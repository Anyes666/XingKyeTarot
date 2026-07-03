/**
 * 星澜聊天页 — Phase 5.1：分段气泡 + chips + 优先级闭环
 */

import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { MoonlightLayer } from '../components/MoonlightLayer';
import { StarBackground } from '../components/StarBackground';
import { UserProfileStore } from '../common/UserProfileStore';
import {
  XinglanChatRole, XinglanChatMessage, XinglanSpecialIntent,
  XinglanMiniInteractionKey, XinglanCompanionChoice, XinglanCompanionChoiceDef,
  XinglanNightLetter, XinglanNightLetterTheme,
  XinglanStarKeyMirror, XinglanMirrorTopic,
  XinglanEchoCard, XinglanEchoCardEmotion,
  XinglanLightMemory, XinglanMemoryPreference,
  XinglanNeed,
  XinglanEmotionTag
} from '../xinglan/types/XinglanTypes';
import {
  XINGLAN_WELCOME_TEXT, XINGLAN_INPUT_PLACEHOLDER, XINGLAN_DISCLAIMER,
  XINGLAN_EMPTY_GUIDE, XINGLAN_LISTENING_TEXT,
  XINGLAN_RESPONSE_DELAY_MIN, XINGLAN_RESPONSE_DELAY_MAX
} from '../xinglan/data/XinglanTemplates';
import { selectChatGreeting } from '../data/XinglanNicknameGreetings';
import { XINGLAN_MINI_INTERACTIONS, XinglanMiniInteractionDef } from '../xinglan/data/XinglanMiniInteractions';
import { getRandomPaperNote } from '../xinglan/data/XinglanPaperNotes';
import { getShortEmotionLines } from '../xinglan/data/XinglanShortCorpus';
import { resolveSpecialIntent } from '../xinglan/engine/XinglanSpecialIntentResolver';
import { analyzeInput } from '../xinglan/engine/XinglanAnalyzer';
import { routeToPlan } from '../xinglan/engine/XinglanRouter';
import { composeReply, getSpecialReply } from '../xinglan/engine/XinglanComposer';
import { resolveCompanionMode } from '../xinglan/engine/XinglanCompanionModeEngine';
import { matchMiniInteraction } from '../xinglan/engine/XinglanMiniInteractionEngine';
import { tryDirectReply } from '../xinglan/engine/XinglanDirectReplyEngine';
import { resolveFlowEntry, resolveFlowNext } from '../xinglan/engine/XinglanInteractionFlowEngine';
import { detectInterrupt } from '../xinglan/engine/XinglanInterruptDetector';
import {
  createSessionState, addUserMessage, addXinglanMessage, updateContext
} from '../xinglan/engine/XinglanSessionManager';
import {
  XinglanInteractionOption, XinglanActiveInteractionState,
  XinglanInteractionFlowId, XinglanInteractionNodeId,
  XinglanPendingQuestion, XinglanQuestionOption, XinglanQuestionId
} from '../xinglan/types/XinglanTypes';
import {
  createMoodWeatherQuestion, fuzzyMatchOption
} from '../xinglan/data/XinglanQuestionOptions';
import { ALL_COMPANION_CHOICES, getCompanionChoice } from '../xinglan/data/XinglanCompanionChoices';
import { getRandomLetter, NIGHT_LETTER_THEME_OPTIONS, NightLetterThemeOption } from '../xinglan/data/XinglanNightLetters';
import { getRandomMirror, MIRROR_TOPIC_OPTIONS, MirrorTopicOption } from '../xinglan/data/XinglanStarKeyMirror';
import { detectEchoEmotion, getRandomEchoCard } from '../xinglan/data/XinglanEchoCards';
import { detectMemoryPreference, getMemoryPreferenceDef, getSavedMemorySummary, formatMemoryForDisplay } from '../xinglan/data/XinglanLightMemory';
import { DivinationConversationContext } from '../model/DivinationConversationContext';

interface ChipItem { title: string; triggerText: string; }

/**
 * FLOW-1：XinglanChatPage 路由入参
 *
 * 仅"和星澜继续聊聊"入口携带 divinationContext；
 * CHAT-1：聊天入口页五卡片携带 need；底部"也可以直接说一句"携带 need=LISTEN。
 * 其它入口（聊天 Tab）不传 params，need 缺省为 UNKNOWN 走默认开场。
 */
interface XinglanChatRouteParams {
  divinationContext?: DivinationConversationContext;
  need?: XinglanNeed;
}

const QUICK_CHIPS: ChipItem[] = [
  { title: '今天怎么陪我', triggerText: '__companion_picker__' },
  { title: '陪我解闷', triggerText: '陪我解闷' },
  { title: '给我一句小纸条', triggerText: '给我一句小纸条' },
  { title: '我想说点心事', triggerText: '我想说点心事' }
];

const CHAT_CHIPS: ChipItem[] = [
  { title: '陪我解闷', triggerText: '陪我解闷' },
  { title: '给我一句小纸条', triggerText: '给我一句小纸条' },
  { title: '选一个心情词', triggerText: '选一个心情词' }
];

@Entry
@Component
struct XinglanChatPage {
  private session = createSessionState();
  @State messages: XinglanChatMessage[] = [];
  @State inputText: string = '';
  @State isListening: boolean = false;
  @State showWelcome: boolean = true;
  @State showEmptyGuide: boolean = true;
  @State isSending: boolean = false;
  private scroller: Scroller = new Scroller();
  private segmentTimers: number[] = [];
  private activeInteractionState: XinglanActiveInteractionState = {
    flowId: XinglanInteractionFlowId.NONE, nodeId: XinglanInteractionNodeId.NONE,
    awaitingUserChoice: false, turnCount: 0
  };
  @State currentFlowOptions: XinglanInteractionOption[] = [];
  @State pendingQuestion: XinglanPendingQuestion | null = null;
  @State currentCompanionChoice: XinglanCompanionChoice = XinglanCompanionChoice.NONE;
  @State showCompanionPicker: boolean = false;
  @State currentNightLetter: XinglanNightLetter | null = null;
  @State showNightLetterPicker: boolean = false;
  @State savedNightLetters: XinglanNightLetter[] = [];
  @State currentMirror: XinglanStarKeyMirror | null = null;
  @State showMirrorPicker: boolean = false;
  @State currentEchoCard: XinglanEchoCard | null = null;
  @State showEchoCardPrompt: boolean = false;
  @State savedEchoCards: XinglanEchoCard[] = [];
  @State currentMemoryPrompt: XinglanMemoryPreference = XinglanMemoryPreference.NONE;
  @State showMemoryConfirm: boolean = false;
  @State savedMemories: XinglanLightMemory[] = [];
  @State memoryInputText: string = '';
  @State userAvatarUri: string = '';
  @State welcomeText: string = XINGLAN_WELCOME_TEXT;
  @State chatNickname: string = '未命名旅者';
  // CHAT-1：当前陪伴需求方向 + 顶部状态文案（按 Need 显示，参考 V2 计划 11.2 节）
  @State currentNeed: XinglanNeed = XinglanNeed.UNKNOWN;
  @State needStatusLabel: string = '';
  @State private typingBreathOpacity: number = 0.35;
  private echoTurnCounter: number = 0;
  private lastUserEmotionText: string = '';

  // ═══ CHAT-3：安静陪伴模式 ═══
  @State isQuietMode: boolean = false;
  @State quietTextIndex: number = 0;
  @State quietOpacity: number = 1.0;
  private quietTextTimer: number = -1;
  private quietFadeTimer: number = -1;
  private readonly QUIET_TEXTS: string[] = [
    '不用说什么，也可以。',
    '这里没有需要立刻回答的问题。',
    '先让这一刻慢一点。',
    '不急着整理，停一会儿也好。'
  ];
  private readonly QUIET_ROTATE_INTERVAL_MS: number = 8000;
  private readonly QUIET_FADE_DELAY_MS: number = 180000;

  // ═══ CHAT-4：情绪降噪模式 ═══
  @State isNoiseReductionMode: boolean = false;
  @State showNoiseReductionPrompt: boolean = false;
  private consecutiveShortMessages: number = 0;
  private lastMessageTimestamp: number = 0;
  private readonly NOISE_REDUCTION_GENERIC_REPLIES: string[] = [
    '不用急着把话说完。星澜会在这里，等你想好下一句。',
    '如果文字让你觉得多，我们就一次只看一句话。',
    '先停下来也没关系。你可以把这里当作一个安静的角落。',
    '你不需要一次把所有感受都整理清楚。慢慢来，星澜在。',
    '这一刻，只需要知道自己被听见。不用解释，不用证明。'
  ];
  private readonly NOISE_REDUCTION_CHIPS: ChipItem[] = [
    { title: '再说一句', triggerText: '再说一句' },
    { title: '我先安静', triggerText: '我先安静' }
  ];
  private readonly NOISE_REDUCTION_EXPLICIT_TRIGGERS: string[] = [
    '太多了', '别说太长', '少说一点', '太长了', '字太多', '字好小',
    '看不见', '看不完', '头晕', '眼花', '眼睛累', '看不过来'
  ];
  private readonly NOISE_REDUCTION_ANXIETY_WORDS: string[] = [
    '焦虑', '不安', '紧张', '害怕', '心慌', '很乱', '很烦', '抓狂', '崩溃',
    '睡不着', '想太多', '停不下来', '喘不上气', '浑身发抖'
  ];

  aboutToAppear(): void {
    this.showWelcome = true;
    setTimeout(() => { this.showWelcome = false; }, 2500);
    this.loadUserAvatar();
    this.loadNicknameAndWelcome();
    // CHAT-1：解析 need 参数（聊天入口页五卡片携带），先于占卜上下文解析
    // divinationContext 优先：若同时携带占卜上下文，need 不覆盖开场
    this.parseNeedParam();
    // FLOW-1：解析占卜结果转入聊天上下文（"和星澜继续聊聊"入口携带）
    this.parseDivinationContext();
    // B 方案低刺激 typing 呼吸（2s 循环，opacity 0.35→0.8）
    animateTo({
      duration: 2000,
      iterations: -1,
      curve: Curve.EaseInOut
    }, () => {
      this.typingBreathOpacity = 0.8;
    });
  }

  private async loadUserAvatar(): Promise<void> {
    try {
      this.userAvatarUri = await UserProfileStore.getAvatarUri(getContext(this));
    } catch (_err) {
      // keep default (empty = default avatar)
    }
  }

  private async loadNicknameAndWelcome(): Promise<void> {
    try {
      const context: Context = getContext(this);
      const name: string = await UserProfileStore.getNickname(context);
      this.chatNickname = name;
      const greeting = await selectChatGreeting(name, context);
      this.welcomeText = greeting.text;
    } catch (_err) {
      // 降级：使用 XINGLAN_WELCOME_TEXT 默认文案
    }
  }

  /**
   * CHAT-1：解析 need 路由参数
   *
   * 聊天入口页五卡片携带 need，影响顶部状态文案与开场。
   * 安全解析：非法值降级为 UNKNOWN（走默认开场）。
   * 若已携带 divinationContext（占卜转入），need 不覆盖开场，仅记录状态文案。
   */
  private parseNeedParam(): void {
    const rawParams: Object | undefined = router.getParams();
    if (!rawParams) {
      // Tab 直入 / 无参数：保持 UNKNOWN，无状态文案
      this.needStatusLabel = '';
      return;
    }

    const params: XinglanChatRouteParams = rawParams as XinglanChatRouteParams;
    const need: XinglanNeed | undefined = params.need;
    if (need === undefined || need === null) {
      this.needStatusLabel = '';
      return;
    }

    // 校验是否合法枚举值
    const validNeeds: XinglanNeed[] = [
      XinglanNeed.LISTEN, XinglanNeed.COMFORT, XinglanNeed.ORGANIZE,
      XinglanNeed.ADVICE, XinglanNeed.QUIET, XinglanNeed.UNKNOWN
    ];
    let isValid: boolean = false;
    for (let i = 0; i < validNeeds.length; i++) {
      if (validNeeds[i] === need) { isValid = true; break; }
    }
    if (!isValid) {
      this.needStatusLabel = '';
      return;
    }

    this.currentNeed = need;
    this.needStatusLabel = this.resolveNeedStatusLabel(need);

    // 占卜转入优先：若后续 parseDivinationContext 挂载了上下文，则不重复插入 need 开场
    // 此处仅当未携带 divinationContext 时插入 need 开场
    const hasDivinationContext: boolean = params.divinationContext !== undefined && params.divinationContext !== null;
    if (hasDivinationContext) {
      return;
    }

    // QUIET：纯视觉安静模式，不自动发送开场文本（参考 V2 计划 9.3 节）
    if (need === XinglanNeed.QUIET) {
      this.enterQuietMode();
      return;
    }

    const segments: string[] = this.buildNeedOpeningSegments(need);
    if (segments.length === 0) {
      return;
    }
    for (let i = 0; i < segments.length; i++) {
      addXinglanMessage(this.session, segments[i], []);
    }
    this.messages = [...this.session.messages];
    this.welcomeText = segments[0];
    this.showEmptyGuide = false;
  }

  /**
   * CHAT-1：按 Need 映射顶部状态文案（参考 V2 计划 11.2 节）
   */
  private resolveNeedStatusLabel(need: XinglanNeed): string {
    switch (need) {
      case XinglanNeed.LISTEN: return '先听你说';
      case XinglanNeed.COMFORT: return '今晚先不急着分析';
      case XinglanNeed.ORGANIZE: return '一起把思绪放慢';
      case XinglanNeed.ADVICE: return '只找一个很小的下一步';
      case XinglanNeed.QUIET: return '这里没有必须回答的问题';
      default: return '';
    }
  }

  /**
   * CHAT-1：按 Need 构建开场文案
   *
   * 各 Need 对应默认策略（V2 计划 9.1 节）：
   * - LISTEN   承接 + 一次轻追问
   * - COMFORT  安慰，不分析
   * - ORGANIZE 拆分 2-3 个矛盾点
   * - ADVICE   一个可拒绝的小行动
   * - QUIET    纯视觉安静（不在此发送文本，由 parseNeedParam 跳过）
   * 文案遵守红线：不预测、不承诺、不替用户决定，无"亲爱的/宝贝"等。
   */
  private buildNeedOpeningSegments(need: XinglanNeed): string[] {
    switch (need) {
      case XinglanNeed.LISTEN:
        return [
          '我在这里，可以慢慢说。',
          '发生了什么，按你愿意说的部分开始就好。',
          '说到哪里，星澜就听到哪里。'
        ];
      case XinglanNeed.COMFORT:
        return [
          '今晚先不急着分析。',
          '先让感受被接住，不用把它说清楚。',
          '想哭或者想停一下，都可以。'
        ];
      case XinglanNeed.ORGANIZE:
        return [
          '我们一起把思绪放慢一点。',
          '不用一次想明白，可以先说说现在心里最乱的是哪几件事。',
          '星澜帮你把它们一件件分开看。'
        ];
      case XinglanNeed.ADVICE:
        return [
          '只找一个很小的下一步。',
          '不用是答案，只是一个你现在愿意试一下的小动作。',
          '如果觉得不合适，随时可以拒绝。'
        ];
      case XinglanNeed.QUIET:
        return [];
      default:
        return [];
    }
  }

  /**
   * FLOW-1：解析占卜结果转入聊天上下文
   *
   * 仅"和星澜继续聊聊"入口携带 divinationContext。
   * 安全解析：字段校验失败则降级为普通聊天，不强挂上下文。
   * 星澜不重新抽牌、不改正逆位、不推断新牌阵事实。
   */
  private parseDivinationContext(): void {
    const rawParams: Object | undefined = router.getParams();
    if (!rawParams) {
      return;
    }

    const params: XinglanChatRouteParams = rawParams as XinglanChatRouteParams;
    if (!params.divinationContext) {
      return;
    }

    const ctx: DivinationConversationContext = params.divinationContext;
    // 字段校验：mode 与 cardNames 必填，缺失则降级
    if (!ctx.mode || !ctx.cardNames || ctx.cardNames.length === 0) {
      return;
    }
    // orientations / positionNames 长度与 cardNames 一致性校验
    if (ctx.orientations && ctx.orientations.length !== ctx.cardNames.length) {
      return;
    }
    if (ctx.positionNames && ctx.positionNames.length !== ctx.cardNames.length) {
      return;
    }

    // 挂载到 session（仅数据挂载，不改核心管线逻辑）
    this.session.divinationContext = ctx;

    // 构建开场白（参考开发计划 14.17 节 8 条，不重复整篇结果）
    const segments: string[] = this.buildDivinationOpeningSegments(ctx);
    if (segments.length === 0) {
      return;
    }

    // 作为星澜开场消息插入（不走 Composer/Router 核心管线）
    for (let i = 0; i < segments.length; i++) {
      addXinglanMessage(this.session, segments[i], []);
    }
    this.messages = [...this.session.messages];
    // 顶部欢迎卡同步显示开场白首段
    this.welcomeText = segments[0];
    this.showEmptyGuide = false;
  }

  /**
   * FLOW-1：构建占卜转入聊天开场白
   *
   * 参考开发计划 14.17 节"占卜结果转入聊天"8 条文案。
   * 规则：
   * - 不重复整篇结果，只从用户最有感的一部分继续
   * - userAcceptedInterpretation=false 时不强引用同一解释（选第 4 条）
   * - 多张牌选第 5 条（哪一个位置最触动）
   * - 单牌按 heartMode 调整语感：held 更承接 / light 带方向 / 默认通用
   */
  private buildDivinationOpeningSegments(ctx: DivinationConversationContext): string[] {
    const firstCardName: string = ctx.cardNames.length > 0 ? ctx.cardNames[0] : '这张牌';
    const isMultiCard: boolean = ctx.cardNames.length > 1;

    // userAcceptedInterpretation=false：不强引用同一解释，选第 4 条
    if (ctx.userAcceptedInterpretation === false) {
      return [
        '如果结果不太像你，也不用勉强相信。',
        '你的真实感受比牌面更重要。',
        '我们可以先不谈牌，从你现在心里最明显的感受开始。'
      ];
    }

    // 多张牌（triangle / relation）：选第 5 条
    if (isMultiCard) {
      const heldSoft: string = (ctx.heartMode === 'held')
        ? '先不急着找答案，让感受被好好听见。'
        : '';
      const seg1: string = heldSoft.length > 0
        ? '刚才三张牌里，哪一个位置让你停得最久？\n\n' + heldSoft
        : '刚才三张牌里，哪一个位置让你停得最久？';
      return [
        seg1,
        '不用急着解释牌意，从那一个最触动你的位置开始说就好。'
      ];
    }

    // 单牌：按 heartMode 调整语感
    if (ctx.heartMode === 'held') {
      return [
        `我看到你抽到了「${firstCardName}」。`,
        '先不急着继续解释牌，今晚可以先不解决它。',
        '刚才哪一部分最贴近你？'
      ];
    }
    if (ctx.heartMode === 'light') {
      return [
        `我看到你抽到了「${firstCardName}」。`,
        '这张牌没有替你给出答案，但留下了一个角度：你现在最想保护的是什么？'
      ];
    }
    // 默认（未经过问心页）：选第 1 条
    return [
      `我看到你抽到了「${firstCardName}」。`,
      '先不急着继续解释牌，刚才哪一部分最贴近你？'
    ];
  }

  aboutToDisappear(): void {
    for (let i = 0; i < this.segmentTimers.length; i++) {
      clearTimeout(this.segmentTimers[i]);
    }
    this.segmentTimers = [];
    this.clearQuietTimers();
  }

  private clearQuietTimers(): void {
    if (this.quietTextTimer !== -1) {
      clearInterval(this.quietTextTimer);
      this.quietTextTimer = -1;
    }
    if (this.quietFadeTimer !== -1) {
      clearTimeout(this.quietFadeTimer);
      this.quietFadeTimer = -1;
    }
  }

  private scrollToBottom(): void {
    try { this.scroller.scrollEdge(Edge.Bottom); } catch (_err) { /* ignore */ }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => { setTimeout(resolve, ms); });
  }

  private normalizeReplySegments(text: string): string[] {
    if (!text || text.trim().length === 0) {
      return ['我在这里。', '你可以慢慢说，也可以先不说。'];
    }
    const parts: string[] = text.split('\n\n');
    const result: string[] = [];
    for (let i = 0; i < parts.length && result.length < 4; i++) {
      const trimmed: string = parts[i].trim();
      if (trimmed.length > 0) { result.push(trimmed); }
    }
    if (result.length === 0) { result.push(text.trim()); }
    return result;
  }

  private addXinglanSegment(text: string): void {
    addXinglanMessage(this.session, text, []);
    this.messages = [...this.session.messages];
    this.scrollToBottom();
  }

  private async appendXinglanSegments(segments: string[], isUrgent: boolean): Promise<void> {
    if (isUrgent) {
      // 危机：立即全部显示
      const fullText: string = segments.join('\n\n');
      this.isListening = false;
      addXinglanMessage(this.session, fullText, []);
      this.messages = [...this.session.messages];
      this.scrollToBottom();
      this.isSending = false;
      return;
    }

    // 普通：逐段显示
    let displaySegments: string[] = segments;
    if (this.isNoiseReductionMode && !isUrgent) {
      // CHAT-4：降噪模式只显示一段，且限制在 20-50 字
      if (segments.length > 0) {
        displaySegments = [this.clampNoiseReductionText(segments[0])];
      } else {
        displaySegments = [];
      }
    }
    const delays: number[] = [300, 700, 850, 850];
    for (let i = 0; i < displaySegments.length; i++) {
      const delay: number = delays[Math.min(i, delays.length - 1)];
      await this.sleep(delay);
      if (!this.isSending && i > 0) { break; }
      this.isListening = i < displaySegments.length - 1;
      this.addXinglanSegment(displaySegments[i]);
    }
    this.isListening = false;
    this.isSending = false;
  }

  private async sendMessage(): Promise<void> {
    const text: string = this.inputText.trim();
    if (text.length === 0 || this.isSending) { return; }

    this.inputText = '';
    this.isSending = true;
    addUserMessage(this.session, text);
    this.messages = [...this.session.messages];
    this.showEmptyGuide = false;
    this.scrollToBottom();
    this.isListening = true;
    this.scrollToBottom();

    // CHAT-4：记录连续短消息，用于触发降噪模式
    this.updateShortMessageStats(text);

    const delay: number = XINGLAN_RESPONSE_DELAY_MIN +
      Math.floor(Math.random() * (XINGLAN_RESPONSE_DELAY_MAX - XINGLAN_RESPONSE_DELAY_MIN));
    await this.sleep(delay);

    // CHAT-3：用户表达"不想说"后进入安静陪伴模式，不继续走聊天管线
    if (this.detectQuietTrigger(text)) {
      this.enterQuietMode();
      this.isListening = false;
      this.isSending = false;
      return;
    }

    // CHAT-4：用户主动要求退出降噪模式
    if (this.isNoiseReductionMode && (text.includes('恢复正常') || text.includes('正常显示'))) {
      this.exitNoiseReductionMode();
      await this.appendXinglanSegments(['好，回到正常显示。'], false);
      this.isListening = false;
      this.isSending = false;
      return;
    }

    // CHAT-4：检测降噪模式触发条件，显示入口提示
    if (!this.isNoiseReductionMode && this.detectNoiseReductionTrigger(text)) {
      this.showNoiseReductionPrompt = true;
    }

    // CHAT-4：降噪模式下直接返回短文案，不走完整管线
    if (this.isNoiseReductionMode) {
      this.clearPendingQuestion();
      this.activeInteractionState = {
        flowId: XinglanInteractionFlowId.NONE,
        nodeId: XinglanInteractionNodeId.NONE,
        awaitingUserChoice: false,
        turnCount: 0
      };
      this.currentFlowOptions = [];
      const emotion: XinglanEmotionTag = this.detectEmotionForShortCorpus(text);
      const reply: string = this.selectNoiseReductionReply(emotion);
      await this.appendXinglanSegments([reply], false);
      this.isListening = false;
      this.isSending = false;
      return;
    }

    // ═══ 管线优先级 ═══
    // 0.1. 夜信触发 — 显示夜信主题选择
    if (text.includes('写一封夜信') || text.includes('写一封星澜夜信') ||
        text.includes('星澜夜信') || text.includes('写一封信') ||
        text === '夜信' || text === '写夜信' || text === '今晚收一封夜信') {
      this.clearPendingQuestion();
      this.activeInteractionState = { flowId: XinglanInteractionFlowId.NONE, nodeId: XinglanInteractionNodeId.NONE, awaitingUserChoice: false, turnCount: 0 };
      this.currentFlowOptions = [];
      this.showNightLetterPicker = true;
      this.currentNightLetter = null;
      this.isListening = false;
      this.isSending = false;
      this.scrollToBottom();
      return;
    }

    // 0.15. 星钥小镜子触发
    if (text.includes('用星钥照一下') || text.includes('星钥照一下') ||
        text === '照一下' || text === '星钥小镜子') {
      this.clearPendingQuestion();
      this.activeInteractionState = { flowId: XinglanInteractionFlowId.NONE, nodeId: XinglanInteractionNodeId.NONE, awaitingUserChoice: false, turnCount: 0 };
      this.currentFlowOptions = [];
      this.showMirrorPicker = true;
      this.currentMirror = null;
      this.isListening = false;
      this.isSending = false;
      this.scrollToBottom();
      return;
    }

    // 0. DirectReply（最高优先级）
    const directResult = tryDirectReply(text);
    if (directResult.hit) {
      this.clearPendingQuestion();
      this.activeInteractionState = { flowId: XinglanInteractionFlowId.NONE, nodeId: XinglanInteractionNodeId.NONE, awaitingUserChoice: false, turnCount: 0 };
      this.currentFlowOptions = [];
      await this.appendXinglanSegments(directResult.segments, directResult.isUrgent);
      return;
    }

    // 0.3. pendingQuestion 存在时 — 先尝试自由文本模糊匹配选项
    if (this.pendingQuestion !== null && this.pendingQuestion.options.length > 0) {
      // 尝试模糊匹配
      const matched: XinglanQuestionOption | null = fuzzyMatchOption(text, this.pendingQuestion.options);
      if (matched !== null) {
        // 匹配成功，按选项点击处理
        await this.handleQuestionOption(matched);
        return;
      }
      // 短输入未匹配 → 提示用户选择，保留 pendingQuestion
      if (text.length < 8) {
        const hintSegs: string[] = ['你可以选一个上面的选项，也可以直接跟我说说你的心事。'];
        await this.appendXinglanSegments(hintSegs, false);
        return;
      }
      // 长输入 → 退出 pendingQuestion，走正常 pipeline
      this.clearPendingQuestion();
      const fallbackAnalysis = analyzeInput(text);
      const fallbackPlan = routeToPlan(fallbackAnalysis);
      const fallbackCompose = composeReply(fallbackPlan, this.session);
      updateContext(this.session, fallbackPlan);
      const fallbackSegs: string[] = this.normalizeReplySegments(fallbackCompose.replyText);
      await this.appendXinglanSegments(fallbackSegs, fallbackPlan.forceShortCircuit || false);
      return;
    }

    // 0.5. 当前交互流中 → 判断打断/继续
    if (this.activeInteractionState.flowId !== XinglanInteractionFlowId.NONE) {
      const interrupt = detectInterrupt(text, this.activeInteractionState);
      if (interrupt.action === 'SAFETY' || interrupt.action === 'DIRECT' || interrupt.action === 'NEW_TOPIC') {
        // 打断当前流
        this.clearPendingQuestion();
        this.activeInteractionState = { flowId: XinglanInteractionFlowId.NONE, nodeId: XinglanInteractionNodeId.NONE, awaitingUserChoice: false, turnCount: 0 };
        this.currentFlowOptions = [];
        // 重新走完整管线
        const retryDirect = tryDirectReply(text);
        if (retryDirect.hit) {
          await this.appendXinglanSegments(retryDirect.segments, retryDirect.isUrgent);
          return;
        }
        // 走普通管线
        const analysis = analyzeInput(text);
        const plan = routeToPlan(analysis);
        const composeResult2 = composeReply(plan, this.session);
        updateContext(this.session, plan);
        const segs2: string[] = this.normalizeReplySegments(composeResult2.replyText);
        await this.appendXinglanSegments(segs2, plan.forceShortCircuit || false);
        return;
      }
      // 继续当前流
      const flowNext = resolveFlowNext(text, this.activeInteractionState);
      if (flowNext.matched) {
        if (flowNext.nextOptions.length === 0) {
          // 流已结束，清空状态
          this.activeInteractionState = { flowId: XinglanInteractionFlowId.NONE, nodeId: XinglanInteractionNodeId.NONE, awaitingUserChoice: false, turnCount: 0 };
          this.currentFlowOptions = [];
        } else {
          this.activeInteractionState = flowNext.activeState;
          this.currentFlowOptions = flowNext.nextOptions;
        }
        await this.appendXinglanSegments(flowNext.replySegments, false);
        return;
      }
    }

    // 1. 交互流入口
    const flowEntry = resolveFlowEntry(text);
    if (flowEntry.matched) {
      this.activeInteractionState = flowEntry.activeState;
      this.currentFlowOptions = flowEntry.nextOptions;
      await this.appendXinglanSegments(flowEntry.replySegments, false);
      return;
    }

    // 2. MiniInteraction
    const miniSegments: string[] = matchMiniInteraction(text);
    if (miniSegments.length > 0) {
      // 命中"星澜问我一个问题" → 设置 pendingQuestion
      if (text.includes('星澜问我一个问题') || text.includes('问我一个问题') || text.includes('问我')) {
        this.pendingQuestion = createMoodWeatherQuestion();
      }
      await this.appendXinglanSegments(miniSegments, false);
      return;
    }

    // 3. CompanionMode
    const companionResult = resolveCompanionMode(text);
    if (companionResult.shouldBypassNormalReply) {
      await this.appendXinglanSegments(companionResult.replySegments, false);
      return;
    }

    // 4. 特殊意图
    const intentResult = resolveSpecialIntent(text);
    if (intentResult.shouldBypassAnalysis && intentResult.intent !== XinglanSpecialIntent.NONE) {
      const replyText: string = getSpecialReply(intentResult.intent);
      const segments: string[] = this.normalizeReplySegments(replyText);
      await this.appendXinglanSegments(segments, false);
      return;
    }

    // 5. 普通管线
    const analysisResult = analyzeInput(text);
    const replyPlan = routeToPlan(analysisResult);
    const composeResult = composeReply(replyPlan, this.session);
    updateContext(this.session, replyPlan);
    const isUrgent: boolean = replyPlan.forceShortCircuit || false;
    const segments: string[] = this.normalizeReplySegments(composeResult.replyText);
    await this.appendXinglanSegments(segments, isUrgent);

    // ═══ Phase 5.11 回声卡检测 ═══
    // 每 3 轮对话 + 用户输入包含情绪词 → 弹出回声卡提示
    this.echoTurnCounter = this.echoTurnCounter + 1;
    this.lastUserEmotionText = text;
    if (this.echoTurnCounter >= 3 && this.currentEchoCard === null && !this.showEchoCardPrompt) {
      const emotion: XinglanEchoCardEmotion = detectEchoEmotion(text);
      if (emotion !== XinglanEchoCardEmotion.NONE) {
        this.showEchoCardPrompt = true;
      }
    }

    // ═══ Phase 5.12 轻记得检测 ═══
    if (!this.showMemoryConfirm) {
      const memoryPref: XinglanMemoryPreference = detectMemoryPreference(text);
      if (memoryPref !== XinglanMemoryPreference.NONE) {
        this.currentMemoryPrompt = memoryPref;
        this.showMemoryConfirm = true;
      }
    }
  }

  private async onChipClick(chip: ChipItem): Promise<void> {
    this.inputText = '';
    const text: string = chip.triggerText;

    // Phase 5.7: "今天怎么陪我" → 展开相处方式选择面板
    if (text === '__companion_picker__') {
      this.showCompanionPicker = true;
      return;
    }

    if (text.length === 0 || this.isSending) { return; }

    this.isSending = true;
    addUserMessage(this.session, text);
    this.messages = [...this.session.messages];
    this.showEmptyGuide = false;
    this.scrollToBottom();
    this.isListening = true;
    this.scrollToBottom();

    const delay: number = XINGLAN_RESPONSE_DELAY_MIN +
      Math.floor(Math.random() * (XINGLAN_RESPONSE_DELAY_MAX - XINGLAN_RESPONSE_DELAY_MIN));
    await this.sleep(delay);

    // CHAT-4：降噪模式 chips 直接返回短文案，不走管线
    if (this.isNoiseReductionMode) {
      this.clearPendingQuestion();
      this.activeInteractionState = {
        flowId: XinglanInteractionFlowId.NONE,
        nodeId: XinglanInteractionNodeId.NONE,
        awaitingUserChoice: false,
        turnCount: 0
      };
      this.currentFlowOptions = [];
      if (text === '我先安静') {
        this.enterQuietMode();
        this.isListening = false;
        this.isSending = false;
        return;
      }
      const emotion: XinglanEmotionTag = this.detectEmotionForShortCorpus(text);
      const reply: string = this.selectNoiseReductionReply(emotion);
      await this.appendXinglanSegments([reply], false);
      this.isListening = false;
      this.isSending = false;
      return;
    }

    // chips 直接走 MiniInteraction
    const miniSegments: string[] = matchMiniInteraction(text);
    if (miniSegments.length > 0) {
      // 命中"星澜问我一个问题" → 设置 pendingQuestion
      if (text.includes('星澜问我一个问题') || text.includes('问我一个问题') || text.includes('问我')) {
        this.pendingQuestion = createMoodWeatherQuestion();
      }
      await this.appendXinglanSegments(miniSegments, false);
      return;
    }

    // 走普通管线
    const analysisResult = analyzeInput(text);
    const replyPlan = routeToPlan(analysisResult);
    const composeResult = composeReply(replyPlan, this.session);
    updateContext(this.session, replyPlan);
    const isUrgent: boolean = replyPlan.forceShortCircuit || false;
    const segments: string[] = this.normalizeReplySegments(composeResult.replyText);
    await this.appendXinglanSegments(segments, isUrgent);
  }

  // ═══ Phase 5.7.1: 问题绑定选项 ═══

  private clearPendingQuestion(): void {
    this.pendingQuestion = null;
  }

  private async handleQuestionOption(option: XinglanQuestionOption): Promise<void> {
    // 显示 typing
    this.isListening = true;
    this.scrollToBottom();

    const shortDelay: number = 400 + Math.floor(Math.random() * 400);
    await this.sleep(shortDelay);

    // 输出星澜回复
    await this.appendXinglanSegments(option.replyLines, false);

    // 处理后续
    if (option.nextFlowId !== XinglanInteractionFlowId.NONE) {
      // 进入指定 Flow — 通过小纸条 trigger 触发
      this.clearPendingQuestion();
      if (option.nextFlowId === XinglanInteractionFlowId.PAPER_NOTE_FLOW) {
        const flowEntry = resolveFlowEntry('给我一句小纸条');
        if (flowEntry.matched) {
          this.activeInteractionState = flowEntry.activeState;
          this.currentFlowOptions = flowEntry.nextOptions;
          // 追加小纸条内容
          const miniSegs: string[] = matchMiniInteraction('给我一句小纸条');
          if (miniSegs.length > 0) {
            await this.appendXinglanSegments(miniSegs, false);
          }
        }
      }
      return;
    }

    if (option.nextOptions.length > 0) {
      // 更新为下一组选项
      this.pendingQuestion = {
        questionId: this.pendingQuestion !== null ? this.pendingQuestion.questionId : XinglanQuestionId.NONE,
        questionText: this.pendingQuestion !== null ? this.pendingQuestion.questionText : '',
        options: option.nextOptions,
        allowFreeText: true,
        sourceFlowId: XinglanInteractionFlowId.NONE,
        createdAt: Date.now()
      };
    } else if (option.clearAfterSelect) {
      // 清空 pendingQuestion，恢复默认 chips
      this.clearPendingQuestion();
    }
  }

  private async onQuestionOptionClick(option: XinglanQuestionOption): Promise<void> {
    if (this.isSending) { return; }
    this.isSending = true;

    // 将选项文本作为用户消息插入
    addUserMessage(this.session, option.userText);
    this.messages = [...this.session.messages];
    this.scrollToBottom();

    // CHAT-3：用户点击"我不想说话"选项后直接进入安静陪伴模式
    if (option.id === 'quiet_none' || this.detectQuietTrigger(option.userText)) {
      this.enterQuietMode();
      this.isSending = false;
      return;
    }

    await this.handleQuestionOption(option);
    this.isSending = false;
  }

  // ═══ Phase 5.7: 今日相处方式 ═══

  private async onCompanionChoiceSelect(choice: XinglanCompanionChoiceDef): Promise<void> {
    if (this.isSending) { return; }
    this.isSending = true;

    this.currentCompanionChoice = choice.choiceId;
    this.showCompanionPicker = false;

    // 将选择标签作为用户消息
    addUserMessage(this.session, choice.label);
    this.messages = [...this.session.messages];
    this.showEmptyGuide = false;
    this.scrollToBottom();

    const delay: number = XINGLAN_RESPONSE_DELAY_MIN +
      Math.floor(Math.random() * (XINGLAN_RESPONSE_DELAY_MAX - XINGLAN_RESPONSE_DELAY_MIN));
    await this.sleep(delay);

    // 显示开场语
    this.isListening = true;
    this.scrollToBottom();

    await this.appendXinglanSegments(choice.openingLines, false);

    // 设置默认选项为 pendingQuestion
    this.pendingQuestion = {
      questionId: XinglanQuestionId.NONE,
      questionText: '',
      options: choice.defaultOptions,
      allowFreeText: true,
      sourceFlowId: XinglanInteractionFlowId.NONE,
      createdAt: Date.now()
    };

    this.isSending = false;
  }

  // ═══ Phase 5.8: 星澜夜信 ═══

  private async onNightLetterThemeSelect(themeOption: NightLetterThemeOption): Promise<void> {
    if (this.isSending) { return; }
    this.isSending = true;

    addUserMessage(this.session, themeOption.userText);
    this.messages = [...this.session.messages];
    this.scrollToBottom();

    const delay: number = XINGLAN_RESPONSE_DELAY_MIN +
      Math.floor(Math.random() * (XINGLAN_RESPONSE_DELAY_MAX - XINGLAN_RESPONSE_DELAY_MIN));
    await this.sleep(delay);

    const letter: XinglanNightLetter = getRandomLetter(themeOption.theme);
    letter.createdAt = Date.now();
    this.currentNightLetter = letter;
    this.showNightLetterPicker = false;

    this.isListening = true;
    this.scrollToBottom();
    const openingSegs: string[] = ['好，星澜给你写了一封夜信。'];
    await this.appendXinglanSegments(openingSegs, false);

    this.isSending = false;
  }

  private onSaveNightLetter(): void {
    if (this.currentNightLetter !== null) {
      this.currentNightLetter.isSaved = true;
      const saved: XinglanNightLetter[] = [...this.savedNightLetters];
      saved.push(this.currentNightLetter);
      this.savedNightLetters = saved;
    }
  }

  private onCloseNightLetter(): void {
    this.currentNightLetter = null;
    addXinglanMessage(this.session, '夜信收好了。想再写一封，还是回到聊天？', []);
    this.messages = [...this.session.messages];
    this.scrollToBottom();
  }

  // ═══ Phase 5.9: 星钥小镜子 ═══

  private async onMirrorTopicSelect(opt: MirrorTopicOption): Promise<void> {
    if (this.isSending) { return; }
    this.isSending = true;

    addUserMessage(this.session, opt.userText);
    this.messages = [...this.session.messages];
    this.scrollToBottom();

    const delay: number = XINGLAN_RESPONSE_DELAY_MIN +
      Math.floor(Math.random() * (XINGLAN_RESPONSE_DELAY_MAX - XINGLAN_RESPONSE_DELAY_MIN));
    await this.sleep(delay);

    const mirror: XinglanStarKeyMirror = getRandomMirror(opt.topic);
    this.currentMirror = mirror;
    this.showMirrorPicker = false;

    this.isListening = true;
    this.scrollToBottom();
    const openingSegs: string[] = ['好，星钥微微亮了一下。', '让星澜陪你照见这一小片当下。'];
    await this.appendXinglanSegments(openingSegs, false);

    this.isSending = false;
  }

  private async onMirrorFollowUp(opt: XinglanQuestionOption): Promise<void> {
    if (this.isSending) { return; }
    this.isSending = true;

    addUserMessage(this.session, opt.userText);
    this.messages = [...this.session.messages];
    this.scrollToBottom();

    const delay: number = XINGLAN_RESPONSE_DELAY_MIN +
      Math.floor(Math.random() * (XINGLAN_RESPONSE_DELAY_MAX - XINGLAN_RESPONSE_DELAY_MIN));
    await this.sleep(delay);

    if (opt.id === 'm_again') {
      // 重新选择镜子主题
      this.currentMirror = null;
      this.showMirrorPicker = true;
      this.isListening = false;
      this.isSending = false;
      this.scrollToBottom();
      return;
    }

    // 收进回声 / 回到聊天
    this.isListening = true;
    this.scrollToBottom();
    await this.appendXinglanSegments(opt.replyLines, false);
    this.currentMirror = null;
    this.isSending = false;
  }

  private onCloseMirror(): void {
    this.currentMirror = null;
    addXinglanMessage(this.session, '星钥的光慢慢暗下来了。你想说什么，星澜都在。', []);
    this.messages = [...this.session.messages];
    this.scrollToBottom();
  }

  // ═══ Phase 5.11: 情绪回声卡 ═══

  private async onGenerateEchoCard(): Promise<void> {
    if (this.isSending) { return; }
    this.isSending = true;
    this.showEchoCardPrompt = false;

    const emotion: XinglanEchoCardEmotion = detectEchoEmotion(this.lastUserEmotionText);
    const card: XinglanEchoCard = getRandomEchoCard(emotion);
    card.createdAt = Date.now();

    // 用最后一条用户消息的关键词
    const words: string[] = this.lastUserEmotionText.split(/[，,。！!？?\s]+/);
    const filtered: string[] = [];
    for (let i = 0; i < words.length && filtered.length < 3; i++) {
      if (words[i].length > 0 && words[i].length < 8) {
        filtered.push(words[i]);
      }
    }
    if (filtered.length > 0) {
      card.userKeywords = filtered;
    }

    this.currentEchoCard = card;
    this.echoTurnCounter = 0;

    this.isListening = true;
    this.scrollToBottom();
    const introSegs: string[] = [
      '星澜把刚才那段心情，变成了一张小小的回声卡。',
      '它不是分析，也不是结论。只是帮你把情绪装进一个温柔的形状里。'
    ];
    await this.appendXinglanSegments(introSegs, false);
    this.isSending = false;
  }

  private onSkipEchoCard(): void {
    this.showEchoCardPrompt = false;
    this.echoTurnCounter = 0;
    addXinglanMessage(this.session, '好的，那就让刚才的情绪轻轻过去。你想聊什么，星澜都在。', []);
    this.messages = [...this.session.messages];
    this.scrollToBottom();
  }

  private onSaveEchoCard(): void {
    if (this.currentEchoCard !== null) {
      this.currentEchoCard.isSaved = true;
      const saved: XinglanEchoCard[] = [...this.savedEchoCards];
      saved.push(this.currentEchoCard);
      this.savedEchoCards = saved;
    }
  }

  private onCloseEchoCard(): void {
    this.currentEchoCard = null;
    addXinglanMessage(this.session, '回声卡收好了。它只是一片情绪的影子，不会定义你。', []);
    this.messages = [...this.session.messages];
    this.scrollToBottom();
  }

  // ═══ Phase 5.12: 星澜轻记得 ═══

  private async onMemoryConfirm(value: string): Promise<void> {
    if (this.isSending || value.trim().length === 0) { return; }
    this.isSending = true;
    this.showMemoryConfirm = false;

    const pref: XinglanMemoryPreference = this.currentMemoryPrompt;
    const memory: XinglanLightMemory = {
      id: `mem_${Date.now()}`,
      preference: pref,
      key: pref.valueOf() as string,
      value: value.trim(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    // 检查是否已存在同类型记忆，替换或追加
    const existing: XinglanLightMemory[] = [...this.savedMemories];
    let found: boolean = false;
    for (let i = 0; i < existing.length; i++) {
      if (existing[i].preference === pref) {
        existing[i] = memory;
        found = true;
        break;
      }
    }
    if (!found) {
      existing.push(memory);
    }
    this.savedMemories = existing;

    const def = getMemoryPreferenceDef(pref);
    const label: string = def !== null ? def.label : '';
    this.isListening = true;
    this.scrollToBottom();
    const confirmSegs: string[] = [
      '好的，星澜记住了。',
      label + '：' + value.trim() + '。',
      '这不是一个承诺，只是一个记号。你随时可以改，也可以让星澜忘记。'
    ];
    await this.appendXinglanSegments(confirmSegs, false);
    this.currentMemoryPrompt = XinglanMemoryPreference.NONE;
    this.isSending = false;
  }

  private onSkipMemory(): void {
    this.showMemoryConfirm = false;
    this.currentMemoryPrompt = XinglanMemoryPreference.NONE;
    addXinglanMessage(this.session, '好的，星澜不记。你想说什么，我都在。', []);
    this.messages = [...this.session.messages];
    this.scrollToBottom();
  }

  private onClearAllMemories(): void {
    this.savedMemories = [];
    addXinglanMessage(this.session, '星澜已经把记下的都放下了。', []);
    this.messages = [...this.session.messages];
    this.scrollToBottom();
  }

  private onInputChange(value: string): void {
    this.inputText = value;
  }

  // ═══ CHAT-3：安静陪伴模式控制 ═══

  private detectQuietTrigger(text: string): boolean {
    const t: string = text.trim();
    const triggers: string[] = [
      '不想说', '我不想说话', '我不想说', '别问了', '先别问', '让我安静', '我想安静',
      '别说话', '不用说什么', '什么都别说', '安静待一会儿', '陪我安静', '我想静一静'
    ];
    for (let i = 0; i < triggers.length; i++) {
      if (t.includes(triggers[i])) {
        return true;
      }
    }
    return false;
  }

  // ═══ CHAT-4：情绪降噪模式控制 ═══

  private detectNoiseReductionTrigger(text: string): boolean {
    const t: string = text.trim();
    for (let i = 0; i < this.NOISE_REDUCTION_EXPLICIT_TRIGGERS.length; i++) {
      if (t.includes(this.NOISE_REDUCTION_EXPLICIT_TRIGGERS[i])) {
        return true;
      }
    }
    if (this.detectHighAnxiety(text)) {
      return true;
    }
    if (this.consecutiveShortMessages >= 3) {
      return true;
    }
    return false;
  }

  private detectHighAnxiety(text: string): boolean {
    const t: string = text.trim();
    let count: number = 0;
    for (let i = 0; i < this.NOISE_REDUCTION_ANXIETY_WORDS.length; i++) {
      if (t.includes(this.NOISE_REDUCTION_ANXIETY_WORDS[i])) {
        count++;
      }
    }
    return count >= 2;
  }

  private updateShortMessageStats(text: string): void {
    const now: number = Date.now();
    const isShort: boolean = text.trim().length < 10;
    if (isShort) {
      if (now - this.lastMessageTimestamp < 30000) {
        this.consecutiveShortMessages++;
      } else {
        this.consecutiveShortMessages = 1;
      }
    } else {
      this.consecutiveShortMessages = 0;
    }
    this.lastMessageTimestamp = now;
  }

  private detectEmotionForShortCorpus(text: string): XinglanEmotionTag {
    const t: string = text.trim();
    if (t.includes('累') || t.includes('疲惫') || t.includes('不想动') || t.includes('没力气') || t.includes('耗尽')) {
      return XinglanEmotionTag.TIRED;
    }
    if (t.includes('焦虑') || t.includes('紧张') || t.includes('不安') || t.includes('害怕') || t.includes('慌') || t.includes('想太多')) {
      return XinglanEmotionTag.ANXIOUS;
    }
    if (t.includes('难过') || t.includes('伤心') || t.includes('想哭') || t.includes('难受') || t.includes('委屈') || t.includes('失落')) {
      return XinglanEmotionTag.SAD;
    }
    return XinglanEmotionTag.ANY;
  }

  private selectNoiseReductionReply(emotion: XinglanEmotionTag): string {
    const minChars: number = 20;
    const maxChars: number = 50;
    const candidates: string[] = [];
    const shortLines = getShortEmotionLines(emotion);
    for (let i = 0; i < shortLines.length; i++) {
      const text: string = shortLines[i].text;
      if (text.length >= minChars && text.length <= maxChars) {
        candidates.push(text);
      } else if (text.length > maxChars) {
        candidates.push(this.clampNoiseReductionText(text));
      }
    }
    for (let i = 0; i < this.NOISE_REDUCTION_GENERIC_REPLIES.length; i++) {
      candidates.push(this.NOISE_REDUCTION_GENERIC_REPLIES[i]);
    }
    if (candidates.length === 0) {
      return '慢慢来，星澜在。';
    }
    const idx: number = Math.floor(Math.random() * candidates.length);
    return candidates[idx];
  }

  private clampNoiseReductionText(text: string): string {
    const maxChars: number = 50;
    const minChars: number = 20;
    if (text.length <= maxChars) {
      return text;
    }
    let cut: string = text.substring(0, maxChars);
    const lastPunct: number = Math.max(
      cut.lastIndexOf('。'),
      cut.lastIndexOf('？'),
      cut.lastIndexOf('！'),
      cut.lastIndexOf('，')
    );
    if (lastPunct >= minChars) {
      cut = cut.substring(0, lastPunct + 1);
    }
    return cut;
  }

  private enterNoiseReductionMode(): void {
    this.isNoiseReductionMode = true;
    this.showNoiseReductionPrompt = false;
  }

  private exitNoiseReductionMode(): void {
    this.isNoiseReductionMode = false;
    this.showNoiseReductionPrompt = false;
    this.consecutiveShortMessages = 0;
    this.lastMessageTimestamp = 0;
  }

  private enterQuietMode(): void {
    this.isQuietMode = true;
    this.showEmptyGuide = false;
    this.showWelcome = false;
    this.needStatusLabel = '这里没有必须回答的问题';
    this.quietOpacity = 1.0;
    this.quietTextIndex = 0;
    this.clearQuietTimers();
    this.quietTextTimer = setInterval(() => {
      this.rotateQuietText();
    }, this.QUIET_ROTATE_INTERVAL_MS);
    this.startQuietFadeTimer();
  }

  private rotateQuietText(): void {
    if (!this.isQuietMode) {
      return;
    }
    this.quietTextIndex = (this.quietTextIndex + 1) % this.QUIET_TEXTS.length;
  }

  private startQuietFadeTimer(): void {
    if (this.quietFadeTimer !== -1) {
      clearTimeout(this.quietFadeTimer);
    }
    this.quietFadeTimer = setTimeout(() => {
      animateTo({
        duration: 1200,
        curve: Theme.V2_EASE_IN_OUT
      }, () => {
        this.quietOpacity = 0.25;
      });
    }, this.QUIET_FADE_DELAY_MS);
  }

  private resetQuietFadeOnInteraction(): void {
    if (!this.isQuietMode) {
      return;
    }
    if (this.quietOpacity < 1.0) {
      animateTo({
        duration: 400,
        curve: Theme.V2_EASE_OUT
      }, () => {
        this.quietOpacity = 1.0;
      });
    }
    this.startQuietFadeTimer();
  }

  private onQuietSpeak(): void {
    this.resetQuietFadeOnInteraction();
    this.exitQuietMode();
  }

  private onQuietContinue(): void {
    this.resetQuietFadeOnInteraction();
    this.rotateQuietText();
  }

  private onQuietEnd(): void {
    this.clearQuietTimers();
    this.isQuietMode = false;
    this.quietOpacity = 1.0;
    this.needStatusLabel = '';
    try {
      router.back();
    } catch (_err) {
      // 降级：回到主框架
      try {
        const params: router.RouterOptions = { url: Routes.MAIN_FRAME };
        router.replaceUrl(params);
      } catch (_err2) {
        // ignore
      }
    }
  }

  private exitQuietMode(): void {
    this.clearQuietTimers();
    this.isQuietMode = false;
    this.quietOpacity = 1.0;
    this.needStatusLabel = '';
  }

  build() {
    Stack() {
      // v2: B方案月湖映心 — 最深湖底背景
      Column().width('100%').height('100%').backgroundColor(Theme.V2B_BG_BASE)

      // B方案月光呼吸层（引入公共组件，6s 无限循环呼吸动画）
      MoonlightLayer({ strong: false, reducedMotion: this.isNoiseReductionMode })

      // CHAT-3：星点装饰层，安静模式下提供水面星点；CHAT-4：降噪模式下进一步减少动效
      StarBackground({ bgOpacity: this.isQuietMode ? 0.35 : (this.isNoiseReductionMode ? 0.06 : 0.12) })

      Column() {
        // 顶部安全区
        Column()
          .width('100%')
          .height(Theme.SAFE_TOP + 8)

        // ═══ 顶部栏（返回按钮 + 星澜名称 + 头像）═══
        Row() {
          AppBackButton({ fallbackUrl: Routes.MAIN_FRAME })

          // 星澜名称 — 陪伴空间标题
          Text('星澜')
            .fontSize(Theme.V2B_FONT_SUBTITLE)
            .fontColor(Theme.V2B_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .letterSpacing(1)
            .margin({ left: 16 })

          Blank()

          // 星澜头像圆章 — v2 月光环（active 级柔光）
          Image($r('app.media.app_icon5'))
            .width(42)
            .height(42)
            .borderRadius(21)
            .border({ width: 1.5, color: 'rgba(212, 172, 77, 0.5)' })
            .objectFit(ImageFit.Cover)
            .clip(true)
            .shadow(Theme.V2_HALO_AVATAR_ACTIVE)
        }
        .width('100%')
        .height(50)
        .padding({ left: 24, right: 28 })
        .alignItems(VerticalAlign.Center)

        // ═══ CHAT-1：顶部状态文案（按 Need 显示，参考 V2 计划 11.2 节）═══
        // 仅当从入口页携带合法 Need 时显示；Tab 直入 / UNKNOWN 不显示
        if (this.needStatusLabel.length > 0) {
          Row() {
            Text(this.needStatusLabel)
              .fontSize(Theme.V2B_FONT_CAPTION)
              .fontColor(Theme.V2B_GOLD_RIPPLE)
              .letterSpacing(0.5)
          }
          .width('100%')
          .padding({ left: 28, right: 28, bottom: 8, top: 2 })
          .alignItems(VerticalAlign.Center)
        }

        // ═══ 消息列表 / 安静陪伴模式 ═══
        if (this.isQuietMode) {
          this.buildQuietMode()
        } else {
          Stack() {
            Scroll(this.scroller) {
              Column() {
                if (this.showWelcome) { this.buildWelcomeCard() }
                if (this.showEmptyGuide && this.messages.length === 0 && !this.showWelcome) { this.buildEmptyGuide() }

                // 空状态 — Phase 5.7：相处方式选择
                if (this.messages.length === 0 && !this.showWelcome) {
                  if (this.showCompanionPicker) {
                    this.buildCompanionPicker()
                  } else {
                    this.buildChipsRow(QUICK_CHIPS)
                  }
                }

                Column({ space: 14 }) {
                  ForEach(this.messages, (msg: XinglanChatMessage) => {
                    if (msg.role === XinglanChatRole.USER) { this.buildUserBubble(msg) }
                    else { this.buildXinglanBubble(msg) }
                  }, (msg: XinglanChatMessage) => msg.id)
                }
                .width('100%')
                .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, top: Theme.SPACE_SM })

                // Chips — 优先级：pendingQuestion > currentFlowOptions > 默认 chips
                // CHAT-4：降噪模式下只显示两个降噪 chips + 恢复入口
                if (this.messages.length > 0 && !this.isSending) {
                  if (this.isNoiseReductionMode) {
                    this.buildNoiseReductionChips()
                    this.buildNoiseReductionRestoreButton()
                  } else if (this.pendingQuestion !== null && this.pendingQuestion.options.length > 0) {
                    this.buildQuestionOptions(this.pendingQuestion.options)
                  } else if (this.currentFlowOptions.length > 0) {
                    this.buildDynamicChips(this.currentFlowOptions)
                  } else {
                    this.buildChipsRow(CHAT_CHIPS)
                  }
                }

                // CHAT-4：降噪模式入口提示
                if (this.showNoiseReductionPrompt && !this.isNoiseReductionMode) {
                  this.buildNoiseReductionPrompt()
                }

                if (this.isListening) { this.buildListeningHint() }

                // Phase 5.8: 夜信主题选择面板
                if (this.showNightLetterPicker) {
                  this.buildNightLetterThemePicker()
                }

                // Phase 5.8: 夜信卡片
                if (this.currentNightLetter !== null) {
                  this.buildNightLetterCard(this.currentNightLetter)
                }

                // Phase 5.9: 星钥小镜子主题选择
                if (this.showMirrorPicker) {
                  this.buildMirrorTopicPicker()
                }

                // Phase 5.9: 星钥小镜子卡片
                if (this.currentMirror !== null) {
                  this.buildMirrorCard(this.currentMirror)
                }

                // Phase 5.11: 回声卡提示
                if (this.showEchoCardPrompt) {
                  this.buildEchoCardPrompt()
                }

                // Phase 5.11: 回声卡卡片
                if (this.currentEchoCard !== null) {
                  this.buildEchoCardCard(this.currentEchoCard)
                }

                // Phase 5.12: 轻记得确认
                if (this.showMemoryConfirm) {
                  this.buildMemoryConfirm()
                }

                // Phase 5.12: 已保存记忆展示
                if (this.savedMemories.length > 0 && !this.showMemoryConfirm && !this.showEchoCardPrompt && !this.currentEchoCard) {
                  this.buildSavedMemories()
                }

                Column().height(80)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .height('100%')
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)

            // 顶部淡化层
            Column()
              .width('100%')
              .height(36)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [[Theme.V2B_BG_BASE, 0], ['rgba(15,15,35,0)', 1]]
              })
              .hitTestBehavior(HitTestMode.Transparent)
              .position({ x: 0, y: 0 })

            // 底部淡化层
            Column()
              .width('100%')
              .height(44)
              .linearGradient({
                direction: GradientDirection.Top,
                colors: [['rgba(6,11,26,0)', 0], [Theme.V2B_BG_BASE, 1]]
              })
              .hitTestBehavior(HitTestMode.Transparent)
              .position({ x: 0, y: '100%' })
              .translate({ y: -44 })
          }
          .layoutWeight(1)

          // ═══ 免责声明 ═══
          Text(XINGLAN_DISCLAIMER)
            .fontSize(Theme.V2B_FONT_DISCLAIMER).fontColor(Theme.V2_TEXT_TERTIARY).textAlign(TextAlign.Center)
            .lineHeight(17).width('100%')
            .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 6 })

          // ═══ 输入区 ═══
          this.buildInputArea()
        }
      }
      .width('100%').height('100%')
    }
    .width('100%').height('100%')
  }

  @Builder buildChipsRow(chips: ChipItem[]): void {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(chips, (chip: ChipItem) => {
          Text(chip.title)
            .fontSize(Theme.V2B_FONT_CAPTION)
            .fontColor(Theme.V2B_GOLD_CORE)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor('rgba(212, 172, 77, 0.06)')
            .borderRadius(Theme.V2B_RADIUS_CHIP)
            .border({ width: 1, color: 'rgba(212, 172, 77, 0.15)' })
            .flexShrink(0)
            .onClick(() => { this.onChipClick(chip); })
        }, (chip: ChipItem) => chip.title)
      }
      .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .padding({ top: 12, bottom: 8 })
  }

  // ═══ CHAT-4：情绪降噪入口提示 ═══
  @Builder buildNoiseReductionPrompt(): void {
    Column() {
      Text('文字太多了吗？可以切换到更安静的回复。')
        .fontSize(14)
        .fontColor(Theme.V2B_TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 12 })

      Text('少说一点')
        .fontSize(13)
        .fontColor(Theme.V2B_GOLD_CORE)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('rgba(212, 172, 77, 0.08)')
        .borderRadius(Theme.V2B_RADIUS_CHIP)
        .border({ width: 1, color: 'rgba(212, 172, 77, 0.2)' })
        .onClick(() => { this.enterNoiseReductionMode(); })
    }
    .width('88%')
    .padding(20)
    .backgroundColor(Theme.V2B_BG_CARD)
    .borderRadius(Theme.V2B_RADIUS_CARD)
    .border({ width: 1, color: Theme.V2B_BORDER })
    .margin({ top: 12, bottom: 12 })
  }

  // ═══ CHAT-4：降噪模式专用 chips（最多两个）═══
  @Builder buildNoiseReductionChips(): void {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.NOISE_REDUCTION_CHIPS, (chip: ChipItem) => {
          Text(chip.title)
            .fontSize(Theme.V2B_FONT_CAPTION)
            .fontColor(Theme.V2B_GOLD_CORE)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor('rgba(212, 172, 77, 0.06)')
            .borderRadius(Theme.V2B_RADIUS_CHIP)
            .border({ width: 1, color: 'rgba(212, 172, 77, 0.15)' })
            .flexShrink(0)
            .onClick(() => { this.onChipClick(chip); })
        }, (chip: ChipItem) => chip.title)
      }
      .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .padding({ top: 12, bottom: 8 })
  }

  // ═══ CHAT-4：恢复正常显示入口 ═══
  @Builder buildNoiseReductionRestoreButton(): void {
    Row() {
      Text('恢复正常显示')
        .fontSize(13)
        .fontColor(Theme.V2B_TEXT_SECONDARY)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('rgba(255, 255, 255, 0.04)')
        .borderRadius(Theme.V2B_RADIUS_CHIP)
        .border({ width: 1, color: 'rgba(255, 255, 255, 0.08)' })
        .onClick(() => { this.exitNoiseReductionMode(); })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 12 })
  }

  // Phase 5.7: 今日相处方式选择面板
  @Builder buildCompanionPicker(): void {
    Column({ space: 12 }) {
      Text('今天想让星澜怎么陪你？')
        .fontSize(15)
        .fontColor(Theme.GOLD_PALE)
        .margin({ bottom: 8 })

      ForEach(ALL_COMPANION_CHOICES, (choice: XinglanCompanionChoiceDef) => {
        Column() {
          Text(choice.label)
            .fontSize(16)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .fontWeight(600)
            .margin({ bottom: 4 })

          Text(choice.description)
            .fontSize(12)
            .fontColor(Theme.MOON_MUTED)
            .lineHeight(18)
            .maxLines(2)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.BG_CARD_DARK)
        .borderRadius(Theme.RADIUS_MD)
        .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
        .onClick(() => { this.onCompanionChoiceSelect(choice); })
      }, (choice: XinglanCompanionChoiceDef) => choice.choiceId)
    }
    .width('88%')
    .padding({ top: 12, bottom: 8 })
  }

  // Phase 5.8: 夜信主题选择面板
  @Builder buildNightLetterThemePicker(): void {
    Column({ space: 12 }) {
      Text('今晚，想收到哪一种夜信？')
        .fontSize(15)
        .fontColor(Theme.GOLD_PALE)
        .margin({ bottom: 4 })

      ForEach(NIGHT_LETTER_THEME_OPTIONS, (opt: NightLetterThemeOption) => {
        Row() {
          Text(opt.label)
            .fontSize(15)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .padding({ left: 4 })
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.BG_CARD_DARK)
        .borderRadius(Theme.RADIUS_MD)
        .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
        .onClick(() => { this.onNightLetterThemeSelect(opt); })
      }, (opt: NightLetterThemeOption) => opt.theme.valueOf() as string)
    }
    .width('88%')
    .padding({ top: 12, bottom: 8 })
  }

  // Phase 5.8: 夜信卡片
  @Builder buildNightLetterCard(letter: XinglanNightLetter): void {
    Column() {
      // 顶部星钥小图标
      Image($r('app.media.app_icon3'))
        .width(32)
        .height(32)
        .borderRadius(16)
        .border({ width: 1, color: 'rgba(232, 184, 61, 0.5)' })
        .objectFit(ImageFit.Cover)
        .clip(true)
        .margin({ bottom: 12 })

      // 标题
      Text(letter.title)
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.GOLD_PALE)
        .fontWeight(500)
        .margin({ bottom: 16 })

      // 正文分段
      Column({ space: 12 }) {
        ForEach(letter.bodyLines, (line: string, idx: number) => {
          Text(line)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .lineHeight(26)
            .textAlign(TextAlign.Start)
            .width('100%')
        }, (line: string, idx: number) => `${letter.id}_body_${idx}`)
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 签名
      Text('— 星澜')
        .fontSize(14)
        .fontColor(Theme.GOLD_AMBER)
        .fontStyle(FontStyle.Italic)
        .margin({ bottom: 20 })

      // 按钮行
      Row({ space: 12 }) {
        Text('保存夜信')
          .fontSize(13)
          .fontColor(letter.isSaved ? Theme.MOON_MUTED : Theme.GOLD_AMBER)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(letter.isSaved ? 'rgba(148, 163, 184, 0.08)' : 'rgba(202, 138, 4, 0.12)')
          .borderRadius(18)
          .border({ width: 1, color: letter.isSaved ? 'rgba(148, 163, 184, 0.2)' : 'rgba(202, 138, 4, 0.25)' })
          .onClick(() => { this.onSaveNightLetter(); })

        Text('回到聊天')
          .fontSize(13)
          .fontColor(Theme.MOON_MUTED)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('rgba(148, 163, 184, 0.06)')
          .borderRadius(18)
          .border({ width: 1, color: 'rgba(148, 163, 184, 0.15)' })
          .onClick(() => { this.onCloseNightLetter(); })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('88%')
    .padding(24)
    .backgroundColor('rgba(15, 15, 35, 0.85)')
    .borderRadius(Theme.RADIUS_LG)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
    .margin({ top: 16, bottom: 16 })
  }

  // Phase 5.9: 星钥小镜子主题选择
  @Builder buildMirrorTopicPicker(): void {
    Column({ space: 12 }) {
      Text('想让星钥照见哪一处？')
        .fontSize(15)
        .fontColor(Theme.GOLD_PALE)
        .margin({ bottom: 4 })

      ForEach(MIRROR_TOPIC_OPTIONS, (opt: MirrorTopicOption) => {
        Row() {
          Text(opt.label)
            .fontSize(15)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.BG_CARD_DARK)
        .borderRadius(Theme.RADIUS_MD)
        .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
        .onClick(() => { this.onMirrorTopicSelect(opt); })
      }, (opt: MirrorTopicOption) => opt.topic.valueOf() as string)
    }
    .width('88%')
    .padding({ top: 12, bottom: 8 })
  }

  // Phase 5.9: 星钥小镜子卡片
  @Builder buildMirrorCard(mirror: XinglanStarKeyMirror): void {
    Column() {
      // 标题
      Text('今日星钥小镜子')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.GOLD_PALE)
        .fontWeight(500)
        .margin({ bottom: 16 })

      // 1. 星钥意象
      Column({ space: 4 }) {
        ForEach(mirror.symbolLines, (line: string, idx: number) => {
          Text(line)
            .fontSize(14)
            .fontColor(Theme.GOLD_AMBER)
            .fontStyle(FontStyle.Italic)
            .lineHeight(22)
            .width('100%')
        }, (line: string, idx: number) => `${mirror.id}_sym_${idx}`)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 2. 它照见了什么
      Column({ space: 8 }) {
        ForEach(mirror.reflectionLines, (line: string, idx: number) => {
          Text(line)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .lineHeight(26)
            .width('100%')
        }, (line: string, idx: number) => `${mirror.id}_ref_${idx}`)
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 3. 星澜的轻问题
      Column() {
        Text(mirror.softQuestion)
          .fontSize(14)
          .fontColor(Theme.GOLD_PALE)
          .lineHeight(22)
          .fontStyle(FontStyle.Italic)
          .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('rgba(202, 138, 4, 0.06)')
      .borderRadius(10)
      .margin({ bottom: 16 })

      // 4. 小行动
      Column() {
        Text('今晚的小行动')
          .fontSize(12)
          .fontColor(Theme.MOON_MUTED)
          .margin({ bottom: 4 })
        Text(mirror.tinyAction)
          .fontSize(13)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .lineHeight(20)
          .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('rgba(94, 215, 210, 0.06)')
      .borderRadius(10)
      .margin({ bottom: 20 })

      // 底部按钮
      Row({ space: 12 }) {
        ForEach(mirror.followUpOptions, (opt: XinglanQuestionOption) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(Theme.GOLD_AMBER)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('rgba(202, 138, 4, 0.08)')
            .borderRadius(18)
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
            .onClick(() => { this.onMirrorFollowUp(opt); })
        }, (opt: XinglanQuestionOption) => opt.id)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('88%')
    .padding(24)
    .backgroundColor('rgba(15, 15, 35, 0.85)')
    .borderRadius(Theme.RADIUS_LG)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
    .margin({ top: 16, bottom: 16 })
  }

  @Builder buildDynamicChips(options: XinglanInteractionOption[]): void {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(options.slice(0, 5), (opt: XinglanInteractionOption) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(Theme.GOLD_AMBER)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('rgba(202, 138, 4, 0.08)')
            .borderRadius(18)
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
            .flexShrink(0)
            .onClick(() => {
              const chip: ChipItem = { title: opt.label, triggerText: opt.userText };
              this.onChipClick(chip);
            })
        }, (opt: XinglanInteractionOption) => opt.id)
      }
      .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .padding({ top: 12, bottom: 8 })
  }

  // Phase 5.7.1: question option chips
  @Builder buildQuestionOptions(options: XinglanQuestionOption[]): void {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(options.slice(0, 4), (opt: XinglanQuestionOption) => {
          Text(opt.label)
            .fontSize(13)
            .fontColor(Theme.GOLD_AMBER)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('rgba(202, 138, 4, 0.08)')
            .borderRadius(18)
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
            .flexShrink(0)
            .onClick(() => {
              if (this.isSending) { return; }
              this.onQuestionOptionClick(opt);
            })
        }, (opt: XinglanQuestionOption) => opt.id)
      }
      .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .padding({ top: 12, bottom: 8 })
  }

  // ═══ CHAT-3：安静陪伴模式 UI ═══
  @Builder buildQuietMode(): void {
    Column() {
      // 中间文案区：月光下缓慢轮换的安静许可
      Column() {
        Blank().height('12%')

        Text(this.QUIET_TEXTS[this.quietTextIndex])
          .fontSize(Theme.V2B_FONT_LEAD)
          .fontColor(Theme.V2B_TEXT_PRIMARY)
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Center)
          .lineHeight(30)
          .padding({ left: Theme.SPACE_LG, right: Theme.SPACE_LG })

        Blank().height('18%')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .onClick(() => { this.resetQuietFadeOnInteraction(); })

      // 底部三按钮：低刺激、可预测
      Column({ space: 12 }) {
        // 主按钮：我想说一句
        Row() {
          Text('我想说一句')
            .fontSize(Theme.V2B_FONT_BODY)
            .fontColor(Theme.V2B_BG_BASE)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height(Theme.BTN_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.V2B_GOLD_CORE)
        .borderRadius(Theme.V2B_RADIUS_BTN)
        .shadow(Theme.V2B_SHADOW_BTN_GLOW)
        .onClick(() => { this.onQuietSpeak(); })

        // 次要按钮：继续安静
        Row() {
          Text('继续安静')
            .fontSize(Theme.V2B_FONT_BODY)
            .fontColor(Theme.V2B_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height(Theme.BTN_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.V2B_BG_FLOATING)
        .borderRadius(Theme.V2B_RADIUS_BTN)
        .border({ width: 1, color: Theme.V2B_BORDER })
        .onClick(() => { this.onQuietContinue(); })

        // 退出按钮：结束这次陪伴
        Row() {
          Text('结束这次陪伴')
            .fontSize(Theme.V2B_FONT_BODY)
            .fontColor(Theme.V2B_TEXT_SECONDARY)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height(Theme.BTN_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(255,255,255,0.03)')
        .borderRadius(Theme.V2B_RADIUS_BTN)
        .border({ width: 1, color: 'rgba(255,255,255,0.06)' })
        .onClick(() => { this.onQuietEnd(); })
      }
      .width('100%')
      .padding({ left: Theme.SPACE_LG, right: Theme.SPACE_LG, bottom: Theme.SAFE_BOTTOM, top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .opacity(this.quietOpacity)
  }

  @Builder buildWelcomeCard(): void {
    Column() {
      Text('🌙').fontSize(36).margin({ bottom: 14 })
      Text(this.welcomeText)
        .fontSize(Theme.V2B_FONT_BODY).fontColor(Theme.V2B_TEXT_PRIMARY)
        .lineHeight(26).textAlign(TextAlign.Center).maxLines(6)
    }
    .width('88%').padding(28).backgroundColor(Theme.V2B_BG_CARD)
    .borderRadius(Theme.V2B_RADIUS_CARD)
    .border({ width: 1, color: Theme.V2B_BORDER })
    .margin({ top: 20, bottom: 12 })
  }

  @Builder buildEmptyGuide(): void {
    Column() {
      Text(XINGLAN_EMPTY_GUIDE)
        .fontSize(Theme.V2B_FONT_CAPTION).fontColor(Theme.V2B_TEXT_SECONDARY).lineHeight(22)
        .textAlign(TextAlign.Center).maxLines(4)
    }
    .width('85%').padding(20).margin({ top: 16, bottom: 8 })
  }

  @Builder buildUserBubble(msg: XinglanChatMessage): void {
    Row() {
      Blank()
      // 用户气泡 — v2: 暖月光微底 + 右上小圆角 + 细边框
      Column() {
        Text(msg.text)
          .fontSize(this.isNoiseReductionMode ? Theme.V2B_FONT_BODY + 1 : Theme.V2B_FONT_BODY)
          .fontColor(Theme.V2B_TEXT_PRIMARY)
          .lineHeight(this.isNoiseReductionMode ? 32 : 27)
          .padding({ left: 18, right: 18, top: 13, bottom: 13 })
          .backgroundColor('rgba(212, 172, 77, 0.06)')
          .borderRadius({ topLeft: Theme.V2B_RADIUS_BUBBLE_LARGE, topRight: Theme.V2B_RADIUS_BUBBLE_SMALL, bottomLeft: Theme.V2B_RADIUS_BUBBLE_LARGE, bottomRight: Theme.V2B_RADIUS_BUBBLE_LARGE })
          .border({ width: 1, color: 'rgba(212, 172, 77, 0.12)' })
          .constraintSize({ maxWidth: '64%' })
      }
      .alignItems(HorizontalAlign.End)

      // 用户头像（圆形，右侧）— v2 月光环
      if (this.userAvatarUri.length > 0) {
        Image(this.userAvatarUri)
          .width(Theme.AVATAR_CHAT_DIAMETER)
          .height(Theme.AVATAR_CHAT_DIAMETER)
          .borderRadius(Theme.AVATAR_CHAT_DIAMETER / 2)
          .border({ width: Theme.AVATAR_BORDER_WIDTH, color: 'rgba(212, 172, 77, 0.5)' })
          .shadow(Theme.V2_HALO_AVATAR_STANDARD)
          .objectFit(ImageFit.Cover)
          .clip(true)
          .margin({ left: 10 })
      } else {
        Image($r('app.media.app_icon3'))
          .width(Theme.AVATAR_CHAT_DIAMETER)
          .height(Theme.AVATAR_CHAT_DIAMETER)
          .borderRadius(Theme.AVATAR_CHAT_DIAMETER / 2)
          .border({ width: Theme.AVATAR_BORDER_WIDTH, color: 'rgba(212, 172, 77, 0.5)' })
          .shadow(Theme.V2_HALO_AVATAR_STANDARD)
          .objectFit(ImageFit.Cover)
          .clip(true)
          .opacity(0.8)
          .margin({ left: 10 })
      }
    }
    .width('100%')
  }

  @Builder buildXinglanBubble(msg: XinglanChatMessage): void {
    Row() {
      // 星澜头像（圆形，左侧）— v2 月光环
      Image($r('app.media.app_icon5'))
        .width(Theme.AVATAR_CHAT_DIAMETER)
        .height(Theme.AVATAR_CHAT_DIAMETER)
        .borderRadius(Theme.AVATAR_CHAT_DIAMETER / 2)
        .border({ width: Theme.AVATAR_BORDER_WIDTH, color: 'rgba(212, 172, 77, 0.5)' })
        .shadow(Theme.V2_HALO_AVATAR_STANDARD)
        .objectFit(ImageFit.Cover)
        .margin({ right: 10 })

      Column() {
        // 星澜气泡 — v2: 浮上水面底色 + 月光白文字 + 左上小圆角 + 细边框
        Text(msg.text)
          .fontSize(this.isNoiseReductionMode ? Theme.V2B_FONT_BODY + 1 : Theme.V2B_FONT_BODY)
          .fontColor(Theme.V2B_TEXT_PRIMARY)
          .lineHeight(this.isNoiseReductionMode ? 32 : 27)
          .padding({ left: 18, right: 18, top: 13, bottom: 13 })
          .backgroundColor(Theme.V2B_BG_FLOATING)
          .borderRadius({ topLeft: Theme.V2B_RADIUS_BUBBLE_SMALL, topRight: Theme.V2B_RADIUS_BUBBLE_LARGE, bottomLeft: Theme.V2B_RADIUS_BUBBLE_LARGE, bottomRight: Theme.V2B_RADIUS_BUBBLE_LARGE })
          .border({ width: 1, color: Theme.V2B_BORDER })
          .constraintSize({ maxWidth: '64%' })
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
    }
    .width('100%')
  }

  @Builder buildListeningHint(): void {
    Row() {
      // 星澜头像 — typing 状态也显示头像 — v2 月光环
      Image($r('app.media.app_icon5'))
        .width(Theme.AVATAR_CHAT_DIAMETER)
        .height(Theme.AVATAR_CHAT_DIAMETER)
        .borderRadius(Theme.AVATAR_CHAT_DIAMETER / 2)
        .border({ width: Theme.AVATAR_BORDER_WIDTH, color: 'rgba(212, 172, 77, 0.5)' })
        .shadow(Theme.V2_HALO_AVATAR_STANDARD)
        .objectFit(ImageFit.Cover)
        .margin({ right: 10 })

      // typing 呼吸气泡 — 3 个月光小点，低刺激 opacity 呼吸
      Row({ space: 7 }) {
        Circle({ width: 5, height: 5 })
          .fill(Theme.V2B_GOLD_RIPPLE)
          .opacity(this.typingBreathOpacity)
        Circle({ width: 5, height: 5 })
          .fill(Theme.V2B_GOLD_RIPPLE)
          .opacity(this.typingBreathOpacity * 0.65)
        Circle({ width: 5, height: 5 })
          .fill(Theme.V2B_GOLD_RIPPLE)
          .opacity(this.typingBreathOpacity * 0.35)
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor(Theme.V2B_BG_FLOATING)
      .borderRadius({ topLeft: Theme.V2B_RADIUS_BUBBLE_SMALL, topRight: Theme.V2B_RADIUS_BUBBLE_LARGE, bottomLeft: Theme.V2B_RADIUS_BUBBLE_LARGE, bottomRight: Theme.V2B_RADIUS_BUBBLE_LARGE })
      .border({ width: 1, color: Theme.V2B_BORDER })

      Blank()
    }
    .width('100%').padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, top: 8 })
  }

  // ═══ Phase 5.11: 回声卡提示 Builder ═══

  @Builder buildEchoCardPrompt(): void {
    Column() {
      Text('刚才那段心情，要不要变成一张回声卡？')
        .fontSize(14)
        .fontColor(Theme.GOLD_PALE)
        .margin({ bottom: 12 })
        .textAlign(TextAlign.Center)

      Text('它会装下你的关键词和星澜的回应，像一片情绪的小标本。')
        .fontSize(12)
        .fontColor(Theme.MOON_MUTED)
        .lineHeight(18)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 16 })

      Row({ space: 12 }) {
        Text('不用了')
          .fontSize(13)
          .fontColor(Theme.MOON_MUTED)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('rgba(148, 163, 184, 0.06)')
          .borderRadius(18)
          .border({ width: 1, color: 'rgba(148, 163, 184, 0.15)' })
          .onClick(() => { this.onSkipEchoCard(); })

        Text('生成回声卡')
          .fontSize(13)
          .fontColor(Theme.GOLD_AMBER)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('rgba(202, 138, 4, 0.12)')
          .borderRadius(18)
          .border({ width: 1, color: 'rgba(202, 138, 4, 0.25)' })
          .onClick(() => { this.onGenerateEchoCard(); })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('88%')
    .padding(20)
    .backgroundColor('rgba(15, 15, 35, 0.85)')
    .borderRadius(Theme.RADIUS_LG)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.15)' })
    .margin({ top: 16, bottom: 8 })
  }

  // ═══ Phase 5.11: 回声卡卡片 Builder ═══

  @Builder buildEchoCardCard(card: XinglanEchoCard): void {
    Column() {
      // 星钥图标
      Image($r('app.media.app_icon3'))
        .width(28)
        .height(28)
        .borderRadius(14)
        .border({ width: 1, color: 'rgba(232, 184, 61, 0.5)' })
        .objectFit(ImageFit.Cover)
        .clip(true)
        .margin({ bottom: 12 })

      Text('情绪回声卡')
        .fontSize(16)
        .fontColor(Theme.GOLD_PALE)
        .fontWeight(500)
        .margin({ bottom: 16 })

      // 情绪关键词
      Column() {
        Text('你留下的词')
          .fontSize(11)
          .fontColor(Theme.MOON_MUTED)
          .margin({ bottom: 6 })
        Row({ space: 8 }) {
          ForEach(card.userKeywords, (kw: string) => {
            Text(kw)
              .fontSize(12)
              .fontColor(Theme.GOLD_AMBER)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('rgba(202, 138, 4, 0.1)')
              .borderRadius(12)
          }, (kw: string) => kw)
        }
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 星澜回应
      Column() {
        Text('星澜听见了')
          .fontSize(11)
          .fontColor(Theme.MOON_MUTED)
          .margin({ bottom: 6 })
        Text(card.xinglanResponse)
          .fontSize(14)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .lineHeight(24)
          .width('100%')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 塔罗牌隐喻
      Column() {
        Text(card.tarotRef.cardName)
          .fontSize(15)
          .fontColor(Theme.GOLD_PALE)
          .fontWeight(500)
          .margin({ bottom: 6 })
        Text(card.tarotRef.metaphor)
          .fontSize(13)
          .fontColor(Theme.MOON_MUTED)
          .fontStyle(FontStyle.Italic)
          .lineHeight(20)
          .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('rgba(94, 215, 210, 0.05)')
      .borderRadius(10)
      .margin({ bottom: 20 })

      // 底部按钮
      Row({ space: 12 }) {
        Text('保存回声卡')
          .fontSize(13)
          .fontColor(card.isSaved ? Theme.MOON_MUTED : Theme.GOLD_AMBER)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(card.isSaved ? 'rgba(148, 163, 184, 0.08)' : 'rgba(202, 138, 4, 0.12)')
          .borderRadius(18)
          .border({ width: 1, color: card.isSaved ? 'rgba(148, 163, 184, 0.2)' : 'rgba(202, 138, 4, 0.25)' })
          .onClick(() => { this.onSaveEchoCard(); })

        Text('回到聊天')
          .fontSize(13)
          .fontColor(Theme.MOON_MUTED)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('rgba(148, 163, 184, 0.06)')
          .borderRadius(18)
          .border({ width: 1, color: 'rgba(148, 163, 184, 0.15)' })
          .onClick(() => { this.onCloseEchoCard(); })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('88%')
    .padding(24)
    .backgroundColor('rgba(15, 15, 35, 0.85)')
    .borderRadius(Theme.RADIUS_LG)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
    .margin({ top: 16, bottom: 16 })
  }

  // ═══ Phase 5.12: 轻记得确认 Builder ═══

  @Builder buildMemoryConfirm(): void {
    Column() {
      Text(this.getMemoryQuestionText())
        .fontSize(14)
        .fontColor(Theme.GOLD_PALE)
        .margin({ bottom: 12 })
        .textAlign(TextAlign.Center)

      TextInput({ placeholder: '在这里告诉星澜...', text: this.memoryInputText })
        .placeholderColor(Theme.MOON_MUTED)
        .fontSize(14)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .backgroundColor(Theme.BG_CARD_DARK)
        .borderRadius(Theme.RADIUS_MD)
        .height(44)
        .width('100%')
        .padding({ left: 14, right: 14 })
        .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
        .margin({ bottom: 16 })
        .onChange((value: string) => { this.memoryInputText = value; })

      Row({ space: 12 }) {
        Text('不用记')
          .fontSize(13)
          .fontColor(Theme.MOON_MUTED)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('rgba(148, 163, 184, 0.06)')
          .borderRadius(18)
          .border({ width: 1, color: 'rgba(148, 163, 184, 0.15)' })
          .onClick(() => { this.onSkipMemory(); })

        Text('记下')
          .fontSize(13)
          .fontColor(Theme.GOLD_AMBER)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('rgba(202, 138, 4, 0.12)')
          .borderRadius(18)
          .border({ width: 1, color: 'rgba(202, 138, 4, 0.25)' })
          .onClick(() => { this.onMemoryConfirm(this.memoryInputText); })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('88%')
    .padding(20)
    .backgroundColor('rgba(15, 15, 35, 0.85)')
    .borderRadius(Theme.RADIUS_LG)
    .border({ width: 1, color: 'rgba(94, 215, 210, 0.15)' })
    .margin({ top: 16, bottom: 8 })
  }

  private getMemoryQuestionText(): string {
    const def = getMemoryPreferenceDef(this.currentMemoryPrompt);
    if (def !== null) {
      return def.promptQuestion;
    }
    return '你想让星澜记住什么？';
  }

  // ═══ Phase 5.12: 已保存记忆展示 Builder ═══

  @Builder buildSavedMemories(): void {
    Column() {
      Row() {
        Text('星澜轻记得')
          .fontSize(12)
          .fontColor(Theme.MOON_MUTED)

        Blank()

        Text('清除全部')
          .fontSize(11)
          .fontColor('rgba(239, 68, 68, 0.6)')
          .onClick(() => { this.onClearAllMemories(); })
      }
      .width('100%')
      .margin({ bottom: 8 })

      Column({ space: 4 }) {
        ForEach(this.savedMemories, (mem: XinglanLightMemory) => {
          Text(formatMemoryForDisplay(mem))
            .fontSize(12)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .lineHeight(20)
            .width('100%')
        }, (mem: XinglanLightMemory) => mem.id)
      }
      .width('100%')
    }
    .width('88%')
    .padding(12)
    .backgroundColor('rgba(94, 215, 210, 0.04)')
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(94, 215, 210, 0.1)' })
    .margin({ top: 8, bottom: 4 })
  }

  @Builder buildInputArea(): void {
    Row() {
      TextInput({ placeholder: XINGLAN_INPUT_PLACEHOLDER, text: this.inputText })
        .placeholderColor('rgba(149, 144, 168, 0.45)')
        .fontSize(Theme.V2B_FONT_BODY).fontColor(Theme.V2B_TEXT_PRIMARY)
        .backgroundColor(Theme.V2B_BG_CARD).borderRadius(Theme.V2B_RADIUS_BTN)
        .height(48).layoutWeight(1).padding({ left: 18, right: 18 })
        .border({ width: 1, color: Theme.V2B_BORDER })
        .onChange((value: string) => { this.onInputChange(value); })
        .onSubmit(() => { this.sendMessage(); })

      // 发送按钮 — v2 月光金圆章 + 柔光阴影
      Text('↑')
        .fontSize(20).fontColor(Theme.V2B_GOLD_CORE).width(48).height(48)
        .borderRadius(Theme.V2B_RADIUS_BTN).backgroundColor(Theme.V2B_BG_FLOATING).textAlign(TextAlign.Center)
        .border({ width: 1, color: 'rgba(212, 172, 77, 0.15)' })
        .shadow(Theme.V2B_SHADOW_BTN_GLOW)
        .margin({ left: 12 })
        .onClick(() => { this.sendMessage(); })
    }
    .width('100%')
    .padding({ left: Theme.SPACE_LG, right: Theme.SPACE_LG, top: 10, bottom: Theme.SAFE_BOTTOM })
    .backgroundColor(Theme.V2B_BG_BASE)
  }
}

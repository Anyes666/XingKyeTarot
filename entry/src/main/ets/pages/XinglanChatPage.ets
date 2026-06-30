/**
 * 星澜聊天页 — Phase 5.1：分段气泡 + chips + 优先级闭环
 */

import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { UserProfileStore } from '../common/UserProfileStore';
import {
  XinglanChatRole, XinglanChatMessage, XinglanSpecialIntent,
  XinglanMiniInteractionKey, XinglanCompanionChoice, XinglanCompanionChoiceDef,
  XinglanNightLetter, XinglanNightLetterTheme,
  XinglanStarKeyMirror, XinglanMirrorTopic,
  XinglanEchoCard, XinglanEchoCardEmotion,
  XinglanLightMemory, XinglanMemoryPreference
} from '../xinglan/types/XinglanTypes';
import {
  XINGLAN_WELCOME_TEXT, XINGLAN_INPUT_PLACEHOLDER, XINGLAN_DISCLAIMER,
  XINGLAN_EMPTY_GUIDE, XINGLAN_LISTENING_TEXT,
  XINGLAN_RESPONSE_DELAY_MIN, XINGLAN_RESPONSE_DELAY_MAX
} from '../xinglan/data/XinglanTemplates';
import { XINGLAN_MINI_INTERACTIONS, XinglanMiniInteractionDef } from '../xinglan/data/XinglanMiniInteractions';
import { getRandomPaperNote } from '../xinglan/data/XinglanPaperNotes';
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

interface ChipItem { title: string; triggerText: string; }

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
  private echoTurnCounter: number = 0;
  private lastUserEmotionText: string = '';

  aboutToAppear(): void {
    this.showWelcome = true;
    setTimeout(() => { this.showWelcome = false; }, 2500);
    this.loadUserAvatar();
  }

  private async loadUserAvatar(): Promise<void> {
    try {
      this.userAvatarUri = await UserProfileStore.getAvatarUri(getContext(this));
    } catch (_err) {
      // keep default (empty = default avatar)
    }
  }

  aboutToDisappear(): void {
    for (let i = 0; i < this.segmentTimers.length; i++) {
      clearTimeout(this.segmentTimers[i]);
    }
    this.segmentTimers = [];
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
    const delays: number[] = [300, 700, 850, 850];
    for (let i = 0; i < segments.length; i++) {
      const delay: number = delays[Math.min(i, delays.length - 1)];
      await this.sleep(delay);
      if (!this.isSending && i > 0) { break; }
      this.isListening = i < segments.length - 1;
      this.addXinglanSegment(segments[i]);
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

    const delay: number = XINGLAN_RESPONSE_DELAY_MIN +
      Math.floor(Math.random() * (XINGLAN_RESPONSE_DELAY_MAX - XINGLAN_RESPONSE_DELAY_MIN));
    await this.sleep(delay);

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

  build() {
    Stack() {
      Column().width('100%').height('100%').backgroundColor(Theme.BG_DEEP_INDIGO)

      Column() {
        // ═══ 顶部栏 ═══
        Row() {
          AppBackButton({ fallbackUrl: Routes.MAIN_FRAME })
          Blank()
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: 24, right: 24 })
        .alignItems(VerticalAlign.Center)

        // 星钥圆形图标 — 独立于顶部栏，置于 Stack 最顶层，避免状态栏遮挡
        Image($r('app.media.app_icon3'))
          .width(42)
          .height(42)
          .borderRadius(21)
          .border({ width: 1.5, color: 'rgba(232, 184, 61, 0.45)' })
          .objectFit(ImageFit.Cover)
          .clip(true)
          .position({ x: '100%', y: Theme.SAFE_TOP + 18 })
          .translate({ x: -66, y: 0 })
          .zIndex(10)

        // ═══ 消息列表 ═══
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
              if (this.messages.length > 0 && !this.isSending) {
                if (this.pendingQuestion !== null && this.pendingQuestion.options.length > 0) {
                  this.buildQuestionOptions(this.pendingQuestion.options)
                } else if (this.currentFlowOptions.length > 0) {
                  this.buildDynamicChips(this.currentFlowOptions)
                } else {
                  this.buildChipsRow(CHAT_CHIPS)
                }
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
              colors: [['#0A0E1C', 0], ['rgba(15,15,35,0)', 1]]
            })
            .hitTestBehavior(HitTestMode.Transparent)
            .position({ x: 0, y: 0 })

          // 底部淡化层
          Column()
            .width('100%')
            .height(44)
            .linearGradient({
              direction: GradientDirection.Top,
              colors: [['rgba(15,15,35,0)', 0], ['#0A0E1C', 1]]
            })
            .hitTestBehavior(HitTestMode.Transparent)
            .position({ x: 0, y: '100%' })
            .translate({ y: -44 })
        }
        .layoutWeight(1)

        // ═══ 免责声明 ═══
        Text(XINGLAN_DISCLAIMER)
          .fontSize(11).fontColor(Theme.MOON_MUTED).textAlign(TextAlign.Center)
          .lineHeight(16).width('100%')
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 4 })

        // ═══ 输入区 ═══
        this.buildInputArea()
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
            .fontSize(13)
            .fontColor(Theme.GOLD_AMBER)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('rgba(202, 138, 4, 0.08)')
            .borderRadius(18)
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
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

  @Builder buildWelcomeCard(): void {
    Column() {
      Text('🌙').fontSize(36).margin({ bottom: 12 })
      Text(XINGLAN_WELCOME_TEXT)
        .fontSize(Theme.FONT_BODY).fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .lineHeight(24).textAlign(TextAlign.Center).maxLines(6)
    }
    .width('88%').padding(24).backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_LG).margin({ top: 20, bottom: 12 })
  }

  @Builder buildEmptyGuide(): void {
    Column() {
      Text(XINGLAN_EMPTY_GUIDE)
        .fontSize(14).fontColor(Theme.MOON_MUTED).lineHeight(22)
        .textAlign(TextAlign.Center).maxLines(4)
    }
    .width('85%').padding(20).margin({ top: 16, bottom: 8 })
  }

  @Builder buildUserBubble(msg: XinglanChatMessage): void {
    Row() {
      Blank()
      // 用户气泡
      Column() {
        Text(msg.text)
          .fontSize(Theme.FONT_BODY).fontColor(Theme.TEXT_PRIMARY_LIGHT).lineHeight(24)
          .padding(14).backgroundColor(Theme.BG_CARD_DARK)
          .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
          .borderRadius({ topLeft: Theme.RADIUS_MD, topRight: Theme.RADIUS_MD, bottomLeft: Theme.RADIUS_MD, bottomRight: 4 })
          .constraintSize({ maxWidth: '64%' })
      }
      .alignItems(HorizontalAlign.End)

      // 用户头像（圆形，右侧）
      if (this.userAvatarUri.length > 0) {
        Image(this.userAvatarUri)
          .width(Theme.AVATAR_CHAT_DIAMETER)
          .height(Theme.AVATAR_CHAT_DIAMETER)
          .borderRadius(Theme.AVATAR_CHAT_DIAMETER / 2)
          .border({ width: Theme.AVATAR_BORDER_WIDTH, color: Theme.AVATAR_BORDER })
          .shadow(Theme.SHADOW_AVATAR_GLOW)
          .objectFit(ImageFit.Cover)
          .clip(true)
          .margin({ left: 10 })
      } else {
        Image($r('app.media.app_icon3'))
          .width(Theme.AVATAR_CHAT_DIAMETER)
          .height(Theme.AVATAR_CHAT_DIAMETER)
          .borderRadius(Theme.AVATAR_CHAT_DIAMETER / 2)
          .border({ width: Theme.AVATAR_BORDER_WIDTH, color: Theme.AVATAR_BORDER })
          .shadow(Theme.SHADOW_AVATAR_GLOW)
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
      // 星澜头像（圆形，左侧，38vp）
      Image($r('app.media.app_icon5'))
        .width(Theme.AVATAR_CHAT_DIAMETER)
        .height(Theme.AVATAR_CHAT_DIAMETER)
        .borderRadius(Theme.AVATAR_CHAT_DIAMETER / 2)
        .border({ width: Theme.AVATAR_BORDER_WIDTH, color: Theme.AVATAR_BORDER })
        .shadow(Theme.SHADOW_AVATAR_GLOW)
        .objectFit(ImageFit.Cover)
        .margin({ right: 10 })

      Column() {
        Text(msg.text)
          .fontSize(Theme.FONT_BODY).fontColor('#F6E6B8').lineHeight(24)
          .padding(14).backgroundColor('#17172F')
          .border({ width: 1, color: 'rgba(202, 138, 4, 0.15)' })
          .borderRadius({ topLeft: 4, topRight: Theme.RADIUS_MD, bottomLeft: Theme.RADIUS_MD, bottomRight: Theme.RADIUS_MD })
          .constraintSize({ maxWidth: '64%' })
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
    }
    .width('100%')
  }

  @Builder buildListeningHint(): void {
    Row() {
      // 星澜头像 — typing 状态也显示头像
      Image($r('app.media.app_icon5'))
        .width(Theme.AVATAR_CHAT_DIAMETER)
        .height(Theme.AVATAR_CHAT_DIAMETER)
        .borderRadius(Theme.AVATAR_CHAT_DIAMETER / 2)
        .border({ width: Theme.AVATAR_BORDER_WIDTH, color: Theme.AVATAR_BORDER })
        .shadow(Theme.SHADOW_AVATAR_GLOW)
        .objectFit(ImageFit.Cover)
        .margin({ right: 10 })
      Column() {
        Text(XINGLAN_LISTENING_TEXT)
          .fontSize(14).fontColor(Theme.MOON_MUTED).fontStyle(FontStyle.Italic)
          .padding(12).backgroundColor('rgba(23, 23, 47, 0.6)')
          .borderRadius({ topLeft: 4, topRight: Theme.RADIUS_MD, bottomLeft: Theme.RADIUS_MD, bottomRight: Theme.RADIUS_MD })
      }
      .alignItems(HorizontalAlign.Start)
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
        .placeholderColor(Theme.MOON_MUTED).fontSize(Theme.FONT_BODY).fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .backgroundColor(Theme.BG_CARD_DARK).borderRadius(Theme.RADIUS_FULL)
        .height(46).layoutWeight(1).padding({ left: 18, right: 18 })
        .border({ width: 1, color: 'rgba(202, 138, 4, 0.2)' })
        .onChange((value: string) => { this.onInputChange(value); })
        .onSubmit(() => { this.sendMessage(); })

      Text('↑')
        .fontSize(20).fontColor('#111426').width(46).height(46)
        .borderRadius(23).backgroundColor(Theme.GOLD_AMBER).textAlign(TextAlign.Center)
        .shadow({ radius: 10, color: 'rgba(202, 138, 4, 0.4)', offsetX: 0, offsetY: 2 })
        .margin({ left: 10 })
        .onClick(() => { this.sendMessage(); })
    }
    .width('100%')
    .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, top: 10, bottom: Theme.SAFE_BOTTOM })
    .backgroundColor(Theme.BG_DEEP_INDIGO)
  }
}

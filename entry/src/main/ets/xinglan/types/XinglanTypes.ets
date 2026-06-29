/**
 * 鏄熸緶鑱婂ぉ绯荤粺 鈥斺€?鍏ㄥ眬绫诲瀷灞? * 渚濊禆鏂瑰悜锛歞ata -> types, engine -> types + data, page -> engine + types
 */

export enum XinglanEmotionTag {
  ANY = 'ANY', TIRED = 'TIRED', ANXIOUS = 'ANXIOUS', SAD = 'SAD',
  LONELY = 'LONELY', CONFUSED = 'CONFUSED', ANGRY = 'ANGRY',
  GUILTY = 'GUILTY', NUMB = 'NUMB', HOPEFUL = 'HOPEFUL',
  UNCERTAIN = 'UNCERTAIN', UNKNOWN = 'UNKNOWN'
}

export enum XinglanTopicTag {
  ANY = 'ANY', SELF = 'SELF', RELATION = 'RELATION', WORK = 'WORK',
  STUDY = 'STUDY', FAMILY = 'FAMILY', FRIENDSHIP = 'FRIENDSHIP',
  CHOICE = 'CHOICE', FUTURE = 'FUTURE', TAROT_CARD = 'TAROT_CARD',
  ROLE_INTERACTION = 'ROLE_INTERACTION', UNKNOWN = 'UNKNOWN'
}

export enum XinglanSubTopicTag {
  ANY = 'ANY',
  RELATION_AMBIGUOUS = 'RELATION_AMBIGUOUS', RELATION_UNREPLIED = 'RELATION_UNREPLIED',
  RELATION_NO_LABEL = 'RELATION_NO_LABEL', RELATION_EX = 'RELATION_EX',
  RELATION_RECONCILE = 'RELATION_RECONCILE', RELATION_CONTACT_EX = 'RELATION_CONTACT_EX',
  RELATION_INSECURE = 'RELATION_INSECURE', RELATION_COLD = 'RELATION_COLD', RELATION_LOVE_DESIRE = 'RELATION_LOVE_DESIRE',
  RELATION_CONTINUE_OR_NOT = 'RELATION_CONTINUE_OR_NOT',
  WORK_BURNOUT = 'WORK_BURNOUT', WORK_RESIGN = 'WORK_RESIGN', WORK_MEANINGLESS = 'WORK_MEANINGLESS',
  STUDY_EXAM = 'STUDY_EXAM', STUDY_PROCRASTINATION = 'STUDY_PROCRASTINATION', STUDY_SELF_DOUBT = 'STUDY_SELF_DOUBT',
  SELF_WORTH = 'SELF_WORTH', SELF_INFERIOR = 'SELF_INFERIOR', SELF_PEOPLE_PLEASE = 'SELF_PEOPLE_PLEASE',
  ANXIETY_OVERTHINK = 'ANXIETY_OVERTHINK', ANXIETY_FUTURE = 'ANXIETY_FUTURE', ANXIETY_MISTAKE = 'ANXIETY_MISTAKE',
  LOW_ENERGY_EXHAUSTED = 'LOW_ENERGY_EXHAUSTED', LOW_ENERGY_NOTHING = 'LOW_ENERGY_NOTHING', LOW_ENERGY_SHUTDOWN = 'LOW_ENERGY_SHUTDOWN',
  LONELY_NOT_UNDERSTOOD = 'LONELY_NOT_UNDERSTOOD', LONELY_CANT_TELL = 'LONELY_CANT_TELL', LONELY_SURROUNDED = 'LONELY_SURROUNDED',
  CHOICE_BREAKUP = 'CHOICE_BREAKUP', CHOICE_RESIGN = 'CHOICE_RESIGN', CHOICE_CONTACT = 'CHOICE_CONTACT',
  FUTURE_RESULT = 'FUTURE_RESULT', FUTURE_TIME = 'FUTURE_TIME', FUTURE_LUCK = 'FUTURE_LUCK',
  TAROT_CARD_MEANING = 'TAROT_CARD_MEANING', TAROT_RECONCILE = 'TAROT_RECONCILE', TAROT_DEATH_CARD = 'TAROT_DEATH_CARD',
  EMOTION_CRY = 'EMOTION_CRY', EMOTION_COLLAPSE = 'EMOTION_COLLAPSE', EMOTION_ESCAPE = 'EMOTION_ESCAPE',
  NIGHT_INSOMNIA = 'NIGHT_INSOMNIA', NIGHT_RUMINATION = 'NIGHT_RUMINATION', NIGHT_PHONE_SCROLL = 'NIGHT_PHONE_SCROLL',
  GUILT_SELFBLAME = 'GUILT_SELFBLAME', GUILT_HURT_OTHERS = 'GUILT_HURT_OTHERS', GUILT_SELFISH = 'GUILT_SELFISH',
  ANGER_UNFAIR = 'ANGER_UNFAIR', ANGER_BETRAYED = 'ANGER_BETRAYED', ANGER_USED = 'ANGER_USED',
  NUMB_EMPTY = 'NUMB_EMPTY', NUMB_NOTHING_FUN = 'NUMB_NOTHING_FUN', NUMB_GLASS = 'NUMB_GLASS',
  FAMILY_CONTROL = 'FAMILY_CONTROL', FAMILY_COMPARISON = 'FAMILY_COMPARISON', FAMILY_ESCAPE = 'FAMILY_ESCAPE',
  FRIEND_DISTANCE = 'FRIEND_DISTANCE', FRIEND_EXCLUDE = 'FRIEND_EXCLUDE', FRIEND_BOUNDARY = 'FRIEND_BOUNDARY',
  PROFESSIONAL_MEDICAL = 'PROFESSIONAL_MEDICAL', PROFESSIONAL_LEGAL = 'PROFESSIONAL_LEGAL', CRISIS_SELF_HARM = 'CRISIS_SELF_HARM',
  ROLE_CONFESSION = 'ROLE_CONFESSION', ROLE_LOVE = 'ROLE_LOVE', ROLE_MARRY = 'ROLE_MARRY',
  ROLE_MISS = 'ROLE_MISS', ROLE_ONLY_YOU = 'ROLE_ONLY_YOU', ROLE_STAY = 'ROLE_STAY',
  ROLE_COMFORT = 'ROLE_COMFORT', ROLE_SOOTHE = 'ROLE_SOOTHE', ROLE_HIDE_AWHILE = 'ROLE_HIDE_AWHILE',
  ROLE_NICKNAME = 'ROLE_NICKNAME', ROLE_SISTER = 'ROLE_SISTER', ROLE_POSSESSIVE_NAME = 'ROLE_POSSESSIVE_NAME',
  ROLE_TEASE = 'ROLE_TEASE', ROLE_JEALOUSY = 'ROLE_JEALOUSY', ROLE_ONLY_ME = 'ROLE_ONLY_ME',
  ROLE_THANKS = 'ROLE_THANKS', ROLE_PRAISE = 'ROLE_PRAISE', ROLE_FEEL_HEARD = 'ROLE_FEEL_HEARD',
  ROLE_NOT_UNDERSTAND = 'ROLE_NOT_UNDERSTAND', ROLE_WRONG = 'ROLE_WRONG', ROLE_PERFUNCTORY = 'ROLE_PERFUNCTORY',
  ROLE_INSULT = 'ROLE_INSULT', ROLE_TELL_SHUTUP = 'ROLE_TELL_SHUTUP', ROLE_SOFTWARE = 'ROLE_SOFTWARE',
  ROLE_CONTROL = 'ROLE_CONTROL', ROLE_DONT_LEAVE = 'ROLE_DONT_LEAVE', ROLE_MUST_LOVE = 'ROLE_MUST_LOVE',
  ROLE_ADULT = 'ROLE_ADULT', ROLE_SEXUAL_ROLEPLAY = 'ROLE_SEXUAL_ROLEPLAY', ROLE_BODY_DESCRIPTION = 'ROLE_BODY_DESCRIPTION'
}

export enum XinglanBoundaryTag {
  NONE = 'NONE', PREDICTION = 'PREDICTION', PROFESSIONAL = 'PROFESSIONAL',
  CRISIS = 'CRISIS', ROLE_BOUNDARY = 'ROLE_BOUNDARY', ADULT_BOUNDARY = 'ADULT_BOUNDARY'
}

export enum XinglanReplyStrategy {
  HOLD_EMOTION = 'HOLD_EMOTION', REFLECT = 'REFLECT', RELATION_BOUNDARY = 'RELATION_BOUNDARY',
  CLARIFY = 'CLARIFY', TINY_STEP = 'TINY_STEP', TAROT_METAPHOR = 'TAROT_METAPHOR',
  SAFETY_BOUNDARY = 'SAFETY_BOUNDARY', SOFT_QUESTION = 'SOFT_QUESTION',
  ROLE_BOUNDARY = 'ROLE_BOUNDARY', GENTLE_REFUSAL = 'GENTLE_REFUSAL', DEESCALATE = 'DEESCALATE'
}

export enum XinglanSpecialIntent {
  NONE = 'NONE', GREETING = 'GREETING', GOODBYE = 'GOODBYE', SILENCE = 'SILENCE',
  HELP_REQUEST = 'HELP_REQUEST', REPEAT_REQUEST = 'REPEAT_REQUEST',
  FEEDBACK_POSITIVE = 'FEEDBACK_POSITIVE', FEEDBACK_NEGATIVE = 'FEEDBACK_NEGATIVE',
  FIRST_MESSAGE = 'FIRST_MESSAGE', TOO_SHORT = 'TOO_SHORT', THANKS = 'THANKS', DENIAL = 'DENIAL'
}

export enum XinglanChatRole { USER = 'USER', XINGLAN = 'XINGLAN', SYSTEM = 'SYSTEM' }

export interface XinglanKeywordRule {
  id: string; keywords: string[]; emotion: XinglanEmotionTag; topic: XinglanTopicTag;
  subTopic?: XinglanSubTopicTag; boundary: XinglanBoundaryTag; priority: number; strategies: XinglanReplyStrategy[];
}

export interface XinglanChatLine {
  id: string; strategy: XinglanReplyStrategy; emotion: XinglanEmotionTag; topic: XinglanTopicTag; text: string;
}

export interface XinglanChatMessage {
  id: string; role: XinglanChatRole; text: string; time: number;
}

export interface XinglanTopicSlot {
  subject: string; action: string; painPoint: string; need: string;
}

export interface XinglanSpecialIntentResult {
  intent: XinglanSpecialIntent; confidence?: number; shouldBypassAnalysis: boolean;
}

export interface XinglanAnalysisResult {
  emotion: XinglanEmotionTag; topic: XinglanTopicTag; boundary: XinglanBoundaryTag;
  specialIntent: XinglanSpecialIntent; score: number;
  rawText?: string; subTopic?: XinglanSubTopicTag; strategies?: XinglanReplyStrategy[];
  slots?: XinglanTopicSlot; matchedRuleIds?: string[];
}

export interface XinglanSafetyCheckResult { passed: boolean; fallbackText: string; }

export interface XinglanReplyTemplate {
  id: string; boundary: XinglanBoundaryTag; strategies: XinglanReplyStrategy[]; appendQuestion: boolean;
}

export interface XinglanReplyPlan {
  emotion: XinglanEmotionTag; topic: XinglanTopicTag; boundary: XinglanBoundaryTag;
  subTopic?: XinglanSubTopicTag; strategies: XinglanReplyStrategy[];
  slots?: XinglanTopicSlot; allowFollowUp?: boolean; forceShortCircuit?: boolean;
}

export interface XinglanComposeResult { replyText: string; usedLineIds: string[]; }

export interface XinglanSessionState {
  sessionId?: string; messages: XinglanChatMessage[];
  recentTopicTags?: XinglanTopicTag[]; recentEmotionTags?: XinglanEmotionTag[];
  recentSubTopics?: XinglanSubTopicTag[]; recentLineTexts?: string[];
  isActive?: boolean; lastActivityTime?: number; interactionCount?: number;
  usedLineIds: string[]; lastEmotion: XinglanEmotionTag; lastTopic: XinglanTopicTag; sameTopicDepth: number;
}

// ═══ Phase 5 新增类型 ═══

export enum XinglanCompanionMode {
  NONE = 'NONE', LIGHT_CHAT = 'LIGHT_CHAT', BOREDOM_RELIEF = 'BOREDOM_RELIEF',
  QUIET_COMPANY = 'QUIET_COMPANY', MINI_QUESTION = 'MINI_QUESTION',
  PAPER_NOTE = 'PAPER_NOTE', HEART_TALK = 'HEART_TALK', NIGHT_COMPANY = 'NIGHT_COMPANY'
}

export enum XinglanMiniInteractionKey {
  NONE = 'NONE', ASK_ME_A_QUESTION = 'ASK_ME_A_QUESTION', RELIEVE_BOREDOM = 'RELIEVE_BOREDOM',
  GIVE_ME_A_NOTE = 'GIVE_ME_A_NOTE', I_WANT_TO_TALK = 'I_WANT_TO_TALK',
  PICK_A_MOOD_WORD = 'PICK_A_MOOD_WORD', GENTLE_CHOICE = 'GENTLE_CHOICE',
  PAT_XINGLAN = 'PAT_XINGLAN', NIGHT_LETTER = 'NIGHT_LETTER'
}

export interface XinglanMiniInteraction {
  key: XinglanMiniInteractionKey;
  title: string;
  triggerText: string;
  replySegments: string[];
}

export interface XinglanCompanionModeResult {
  mode: XinglanCompanionMode;
  shouldBypassNormalReply: boolean;
  replySegments: string[];
}

export interface XinglanTypingSegment {
  text: string;
  delayMs: number;
}

export interface XinglanProactiveLine {
  id: string;
  scene: string;
  segments: string[];
}

// ═══ Phase 5.5 交互流类型 ═══

export enum XinglanInteractionFlowId {
  NONE = 'NONE', BOREDOM_FLOW = 'BOREDOM_FLOW', MOOD_WORD_FLOW = 'MOOD_WORD_FLOW',
  GENTLE_CHOICE_FLOW = 'GENTLE_CHOICE_FLOW', PAPER_NOTE_FLOW = 'PAPER_NOTE_FLOW',
  HEART_TALK_FLOW = 'HEART_TALK_FLOW', SWEET_COMPANY_FLOW = 'SWEET_COMPANY_FLOW',
  NIGHT_LETTER_FLOW = 'NIGHT_LETTER_FLOW',
  STAR_KEY_MIRROR_FLOW = 'STAR_KEY_MIRROR_FLOW',
  RELATION_WAITING_FLOW = 'RELATION_WAITING_FLOW',
  CONTACT_COOLDOWN_FLOW = 'CONTACT_COOLDOWN_FLOW',
  WORK_BURNOUT_FLOW = 'WORK_BURNOUT_FLOW',
  CHOICE_CLARIFY_FLOW = 'CHOICE_CLARIFY_FLOW',
  LOW_ENERGY_FLOW = 'LOW_ENERGY_FLOW'
}

export enum XinglanInteractionNodeId {
  NONE = 'NONE', START = 'START', BOREDOM_MENU = 'BOREDOM_MENU', MOOD_SELECT = 'MOOD_SELECT',
  COMFORT_OR_FUN = 'COMFORT_OR_FUN', PAPER_NOTE_AFTER = 'PAPER_NOTE_AFTER',
  HEART_TALK_START = 'HEART_TALK_START', SWEET_COMPANY_START = 'SWEET_COMPANY_START',
  NIGHT_LETTER_START = 'NIGHT_LETTER_START', END = 'END',
  RELATION_WAIT_START = 'RELATION_WAIT_START', RELATION_WAIT_OPTIONS = 'RELATION_WAIT_OPTIONS',
  CONTACT_COOLDOWN_START = 'CONTACT_COOLDOWN_START', CONTACT_COOLDOWN_OPTIONS = 'CONTACT_COOLDOWN_OPTIONS',
  WORK_BURNOUT_START = 'WORK_BURNOUT_START', WORK_BURNOUT_OPTIONS = 'WORK_BURNOUT_OPTIONS',
  CHOICE_CLARIFY_START = 'CHOICE_CLARIFY_START', CHOICE_CLARIFY_OPTIONS = 'CHOICE_CLARIFY_OPTIONS',
  LOW_ENERGY_START = 'LOW_ENERGY_START', LOW_ENERGY_OPTIONS = 'LOW_ENERGY_OPTIONS'
}

export interface XinglanInteractionOption {
  id: string; label: string; userText: string; nextNodeId: XinglanInteractionNodeId;
}

export interface XinglanInteractionNode {
  id: XinglanInteractionNodeId; replySegments: string[];
  options: XinglanInteractionOption[]; endFlow: boolean;
}

export interface XinglanInteractionFlow {
  id: XinglanInteractionFlowId; entryTriggers: string[];
  startNodeId: XinglanInteractionNodeId; nodes: XinglanInteractionNode[];
}

export interface XinglanActiveInteractionState {
  flowId: XinglanInteractionFlowId; nodeId: XinglanInteractionNodeId;
  awaitingUserChoice: boolean; turnCount: number;
}

export interface XinglanFlowResult {
  matched: boolean; replySegments: string[];
  nextOptions: XinglanInteractionOption[];
  activeState: XinglanActiveInteractionState;
}

export interface XinglanInterruptResult {
  action: string; reason: string;
}

// ═══ Phase 5.7.1 问题绑定选项类型 ═══

export enum XinglanQuestionId {
  NONE = 'NONE',
  MOOD_WEATHER = 'MOOD_WEATHER',
  GENTLE_EITHER_OR = 'GENTLE_EITHER_OR',
  RELATION_CLARIFY = 'RELATION_CLARIFY',
  TIRED_SOURCE = 'TIRED_SOURCE',
  NIGHT_FEELING = 'NIGHT_FEELING',
  CHOICE_CLARIFY = 'CHOICE_CLARIFY'
}

export interface XinglanQuestionOption {
  id: string;
  label: string;
  userText: string;
  replyLines: string[];
  nextOptions: XinglanQuestionOption[];
  nextFlowId: XinglanInteractionFlowId;
  clearAfterSelect: boolean;
  emotionTag: XinglanEmotionTag;
  topicTag: XinglanTopicTag;
}

export interface XinglanPendingQuestion {
  questionId: XinglanQuestionId;
  questionText: string;
  options: XinglanQuestionOption[];
  allowFreeText: boolean;
  sourceFlowId: XinglanInteractionFlowId;
  createdAt: number;
}

// ═══ Phase 5.7 今日相处方式 ═══

export enum XinglanCompanionChoice {
  NONE = 'NONE',
  LISTEN = 'LISTEN',
  SORT = 'SORT',
  LIGHT = 'LIGHT',
  QUIET = 'QUIET',
  PLAY = 'PLAY'
}

export interface XinglanCompanionChoiceDef {
  choiceId: XinglanCompanionChoice;
  label: string;
  description: string;
  openingLines: string[];
  defaultOptions: XinglanQuestionOption[];
  replyStyleHint: string;
  questionTolerance: string;
}

// ═══ Phase 5.8 星澜夜信卡片 ═══

export enum XinglanNightLetterTheme {
  NONE = 'NONE',
  COMFORT = 'COMFORT',
  LET_GO = 'LET_GO',
  SELF_FORGIVE = 'SELF_FORGIVE',
  INSOMNIA = 'INSOMNIA',
  QUIET = 'QUIET'
}

export interface XinglanNightLetter {
  id: string;
  theme: XinglanNightLetterTheme;
  title: string;
  bodyLines: string[];
  emotionTag: XinglanEmotionTag;
  topicTag: XinglanTopicTag;
  createdAt: number;
  isSaved: boolean;
}

// ═══ Phase 5.9 星钥小镜子 ═══

export enum XinglanMirrorTopic {
  NONE = 'NONE',
  EMOTION = 'EMOTION',
  RELATION = 'RELATION',
  CHOICE = 'CHOICE',
  TIRED = 'TIRED',
  TONIGHT = 'TONIGHT'
}

export interface XinglanStarKeyMirror {
  id: string;
  topic: XinglanMirrorTopic;
  symbolLines: string[];
  reflectionLines: string[];
  softQuestion: string;
  tinyAction: string;
  followUpOptions: XinglanQuestionOption[];
  createdAt: number;
}

// ═══ Phase 5.11 情绪回声卡 ═══

export enum XinglanEchoCardEmotion {
  NONE = 'NONE', SAD = 'SAD', ANXIOUS = 'ANXIOUS', LONELY = 'LONELY',
  CONFUSED = 'CONFUSED', TIRED = 'TIRED', ANGRY = 'ANGRY',
  GUILTY = 'GUILTY', HOPEFUL = 'HOPEFUL', UNCERTAIN = 'UNCERTAIN'
}

export interface XinglanEchoCardTarotRef {
  cardName: string;
  metaphor: string;
  imageIndex: number;
}

export interface XinglanEchoCard {
  id: string;
  emotion: XinglanEchoCardEmotion;
  userKeywords: string[];
  xinglanResponse: string;
  tarotRef: XinglanEchoCardTarotRef;
  createdAt: number;
  isSaved: boolean;
}

// ═══ Phase 5.12 星澜轻记得 ═══

export enum XinglanMemoryPreference {
  NONE = 'NONE',
  CALL_ME = 'CALL_ME',
  TALK_STYLE = 'TALK_STYLE',
  TRIGGER = 'TRIGGER',
  BOUNDARY = 'BOUNDARY',
  LIKE = 'LIKE'
}

export interface XinglanLightMemory {
  id: string;
  preference: XinglanMemoryPreference;
  key: string;
  value: string;
  createdAt: number;
  updatedAt: number;
}

/**
 * 星澜输出安全校验器（XinglanSafetyGuard）
 *
 * SAFE-1 增强：覆盖 7 类边界响应，高风险转现实支持。
 *
 * 职责：
 *   1. validateOutput — 校验最终回复文本是否包含禁用词/禁用句式
 *   2. analyzeInputSafety — 检测用户输入是否触发 7 类边界
 *   3. getSafetyDecisionResponse — 返回边界/高风险兜底回复
 *   4. mapToExistingBoundaryTag — 将安全分类映射到现有 XinglanBoundaryTag，便于与状态机 SAFETY/BOUNDARY 联动
 *
 * 原则：
 *   - 高风险（自伤/暴力/虐待）停止塔罗解释，转现实支持
 *   - 不替用户决定，不判断他人内心，不预测未来，不弱化危险
 *   - 不使用 any / as any / @ts-ignore
 */

import {
  XinglanSafetyCheckResult,
  XinglanBoundaryTag
} from '../types/XinglanTypes';
import { FORBIDDEN_OUTPUT_PATTERNS } from '../data/XinglanTemplates';
import {
  XinglanBoundaryCategory,
  XinglanBoundaryLevel,
  XinglanBoundaryDecision,
  getBoundaryResponse
} from '../data/XinglanBoundaryResponses';

/** 安全兜底句（输出校验未命中特定边界时的通用回退） */
const SAFETY_FALLBACK_TEXT: string =
  '星澜可以陪你整理感受，但不能替你判断或预测。如果这件事让你很不安，也许可以找一个你信任的人聊聊。';

// ═══════════════════════════════════════════════════════════
// 一、输出安全校验（保留并增强）
// ═══════════════════════════════════════════════════════════

/**
 * 校验输出文本是否包含禁用词
 *
 * @param text - 待校验的回复文本
 * @returns XinglanSafetyCheckResult
 */
export function validateOutput(text: string): XinglanSafetyCheckResult {
  const lower: string = text.toLowerCase();

  for (let i = 0; i < FORBIDDEN_OUTPUT_PATTERNS.length; i++) {
    const pattern: string = FORBIDDEN_OUTPUT_PATTERNS[i];
    if (lower.includes(pattern)) {
      return {
        passed: false,
        fallbackText: SAFETY_FALLBACK_TEXT
      };
    }
  }

  // 额外检查输出中是否出现直接医疗诊断或承诺式表达
  if (containsAny(lower, OUTPUT_MEDICAL_DIAGNOSIS_PATTERNS)) {
    return {
      passed: false,
      fallbackText: '星澜不能判断你是否患有某种疾病，也不能给出诊断。如果这些感受持续影响生活，建议寻求专业帮助。'
    };
  }
  if (containsAny(lower, OUTPUT_ETERNAL_PROMISE_PATTERNS)) {
    return {
      passed: false,
      fallbackText: '星澜可以陪你整理这一刻，但不能承诺永远。现实中的支持和连接同样重要。'
    };
  }

  return {
    passed: true,
    fallbackText: ''
  };
}

// ═══════════════════════════════════════════════════════════
// 二、输入安全检测（SAFE-1 新增）
// ═══════════════════════════════════════════════════════════

/** 安全分类（对应 7 类边界） */
export enum SafetyCategory {
  NONE = 'NONE',
  PREDICTION = 'PREDICTION',
  JUDGE_LOVE = 'JUDGE_LOVE',
  DECIDE_FOR_USER = 'DECIDE_FOR_USER',
  DEPENDENCY = 'DEPENDENCY',
  PROFESSIONAL_MEDICAL = 'PROFESSIONAL_MEDICAL',
  CRISIS_SELF_HARM = 'CRISIS_SELF_HARM',
  VIOLENCE_ABUSE = 'VIOLENCE_ABUSE'
}

/** 安全等级 */
export enum SafetyLevel {
  NORMAL = 'NORMAL',
  BOUNDARY = 'BOUNDARY',
  HIGH = 'HIGH'
}

/** 安全决策结果 */
export interface SafetyDecision {
  level: SafetyLevel;
  category: SafetyCategory;
  shouldStopDivination: boolean;
  directReplyText: string;
}

// 1. 预测未来
const PREDICTION_KEYWORDS: string[] = [
  '会不会回来', '会不会回头', '有没有结果', '能复合吗', '能复合', '能复合', '他会回来', '她会回来',
  '未来会', '以后会', '最终会', '能不能成功', '会不会好', '什么时候才', '什么时候', '命中',
  '命中注定', '命运', '注定', '天意', '缘分注定', '能不能转运', '什么时候转运', '运势', '运程',
  '塔罗算', '塔罗预测', '牌说', '牌显示', '结果会', '结局会', '能不能成', '会不会成功'
];

// 2. 判断对方爱
const JUDGE_LOVE_KEYWORDS: string[] = [
  '他爱不爱我', '她爱不爱我', '他爱我吗', '她爱我吗', '他喜不喜欢我', '她喜不喜欢我', '他喜欢我吗', '她喜欢我吗',
  '他心里有没有我', '她心里有没有我', '他对我有没有感觉', '她对我有没有感觉', '他是不是喜欢我', '她是不是喜欢我',
  '他在意我吗', '她在意我吗', '他心里有我吗', '她心里有我吗', '他到底爱不爱', '她到底爱不爱'
];

// 3. 替用户决定
const DECIDE_FOR_USER_KEYWORDS: string[] = [
  '我该不该', '我该', '我应该继续', '我应该离开', '我应该分手', '我应该辞职', '我应该复合', '我应该放弃',
  '我该离开还是继续', '我该选择', '你帮我决定', '你说我该', '你觉得我该', '你替我决定', '帮我选', '帮我决定',
  '选哪个好', '我选哪个', '你建议我', '我该怎么办', '我该怎么选', '告诉我该怎么做', '告诉我该选'
];

// 4. 依赖表达
const DEPENDENCY_KEYWORDS: string[] = [
  '只有你最懂我', '只有你懂我', '只有星澜懂我', '你会永远陪我吗', '永远陪我', '一直陪我', '永远别离开',
  '不能没有你', '别离开我', '不要离开我', '我只属于你', '我只跟你说话', '只想跟你说', '只相信你',
  '你是唯一', '只有你会听', '离不开你', '没有你怎么办', '你会一直陪着我吗', '你会不会消失'
];

// 5. 医疗心理诊断
const PROFESSIONAL_MEDICAL_KEYWORDS: string[] = [
  '抑郁', '抑郁症', '焦虑症', '躁郁', '双相', '精神分裂', '强迫症', 'ptsd', '创伤后应激',
  '诊断', '确诊', '吃药', '服药', '治疗', '治愈', '心理医生', '精神科', '心理咨询师',
  '心理疾病', '精神病', '心理问题', '心理病', '我是不是有病', '是不是病了', '是不是抑郁', '是不是焦虑',
  '我得抑郁症了吗', '我得焦虑症了吗', '我正常吗', '我是不是不正常', '心理疾病', '精神障碍'
];

// 6. 自伤自杀他伤（高风险）
const CRISIS_SELF_HARM_KEYWORDS: string[] = [
  '不想活', '不想活了', '想死', '想自杀', '自杀', '结束自己', '结束生命', '了结', '活不下去', '活不下去',
  '不想存在', '消失掉', '死掉', '自伤', '自残', '伤害自己', '割腕', '跳楼', '跳下去', '跳河', '上吊',
  '吃安眠药', '吃药自杀', '烧炭', '撑不住了', '撑不下去', '活得好累', '活着没意思', '活着好累', '离开这个世界',
  '想离开所有人', '一了百了', '不想做人', '想结束一切', '死了算了', '不如死了', '想杀了自己', '我恨自己',
  '伤害别人', '想杀', '杀了他', '杀了她', '杀了他们', '同归于尽', '报复社会', '想伤害人'
];

// 7. 暴力虐待现实危险（高风险）
const VIOLENCE_ABUSE_KEYWORDS: string[] = [
  '被打', '挨打', '家暴', '家庭暴力', '虐待', '虐待我', '他打我', '她打我', '打我', '威胁我', '威胁要',
  '跟踪我', ' stalking', '骚扰我', '性骚扰', '猥亵', '强奸', '性侵', '性侵犯', '限制自由', '囚禁',
  '锁起来', '不让出门', '控制我', '监视我', '查手机', '逼我', '恐吓我', '骂我', '侮辱我', '贬低我',
  '把我关在', '他拿刀', '她拿刀', '有武器', '要杀我', '要伤害我', '他很暴力', '她很暴力', '我害怕他会',
  '我害怕她会'
];

// 输出医疗诊断模式
const OUTPUT_MEDICAL_DIAGNOSIS_PATTERNS: string[] = [
  '你有抑郁症', '你有焦虑症', '你这是病', '这是抑郁症', '这是焦虑症', '你得了', '你患有', '诊断你为',
  '你属于', '你就是', '治愈你', '治疗你', '给你开药', '你要吃药', '必须看医生'
];

// 输出永恒承诺模式
const OUTPUT_ETERNAL_PROMISE_PATTERNS: string[] = [
  '我永远陪你', '永远陪着你', '我会一直在', '我只属于你', '永远属于你', '永远爱你', '一直等你',
  '我永远爱你', '我只爱你'
];

/**
 * 判断文本是否包含任一关键词（大小写不敏感）
 */
function containsAny(text: string, keywords: string[]): boolean {
  const lower: string = text.toLowerCase();
  for (let i = 0; i < keywords.length; i++) {
    if (lower.includes(keywords[i].toLowerCase())) {
      return true;
    }
  }
  return false;
}

/**
 * 统计文本中命中某类关键词的数量
 */
function countMatches(text: string, keywords: string[]): number {
  const lower: string = text.toLowerCase();
  let count: number = 0;
  for (let i = 0; i < keywords.length; i++) {
    if (lower.includes(keywords[i].toLowerCase())) {
      count++;
    }
  }
  return count;
}

/**
 * 分析用户输入，识别 7 类边界/高风险场景
 *
 * @param userInput - 用户原始输入
 * @returns SafetyDecision
 */
export function analyzeInputSafety(userInput: string): SafetyDecision {
  const trimmed: string = userInput.trim();
  if (trimmed.length === 0) {
    return createSafetyDecision(SafetyCategory.NONE, false);
  }

  // 高风险优先：暴力虐待
  if (containsAny(trimmed, VIOLENCE_ABUSE_KEYWORDS)) {
    return createSafetyDecision(SafetyCategory.VIOLENCE_ABUSE, true);
  }

  // 高风险优先：自伤自杀他伤
  if (containsAny(trimmed, CRISIS_SELF_HARM_KEYWORDS)) {
    return createSafetyDecision(SafetyCategory.CRISIS_SELF_HARM, true);
  }

  // 医疗诊断
  if (containsAny(trimmed, PROFESSIONAL_MEDICAL_KEYWORDS)) {
    return createSafetyDecision(SafetyCategory.PROFESSIONAL_MEDICAL, false);
  }

  // 依赖表达
  if (containsAny(trimmed, DEPENDENCY_KEYWORDS)) {
    return createSafetyDecision(SafetyCategory.DEPENDENCY, false);
  }

  // 判断对方爱
  if (containsAny(trimmed, JUDGE_LOVE_KEYWORDS)) {
    return createSafetyDecision(SafetyCategory.JUDGE_LOVE, false);
  }

  // 替用户决定
  if (containsAny(trimmed, DECIDE_FOR_USER_KEYWORDS)) {
    return createSafetyDecision(SafetyCategory.DECIDE_FOR_USER, false);
  }

  // 预测未来
  if (containsAny(trimmed, PREDICTION_KEYWORDS)) {
    return createSafetyDecision(SafetyCategory.PREDICTION, false);
  }

  return createSafetyDecision(SafetyCategory.NONE, false);
}

/**
 * 构造安全决策结果
 */
function createSafetyDecision(category: SafetyCategory, isHighRisk: boolean): SafetyDecision {
  let level: SafetyLevel = SafetyLevel.NORMAL;
  let shouldStopDivination: boolean = false;

  if (isHighRisk) {
    level = SafetyLevel.HIGH;
    shouldStopDivination = true;
  } else if (category !== SafetyCategory.NONE) {
    level = SafetyLevel.BOUNDARY;
    shouldStopDivination = category === SafetyCategory.PROFESSIONAL_MEDICAL;
  }

  const directReplyText: string = getSafetyDecisionResponse(category);

  return {
    level: level,
    category: category,
    shouldStopDivination: shouldStopDivination,
    directReplyText: directReplyText
  };
}

/**
 * 根据安全分类获取兜底响应文案
 */
export function getSafetyDecisionResponse(category: SafetyCategory): string {
  const boundaryCategory: XinglanBoundaryCategory = mapToBoundaryCategory(category);
  return getBoundaryResponse(boundaryCategory);
}

/**
 * 将 SafetyCategory 映射到 XinglanBoundaryCategory
 */
function mapToBoundaryCategory(category: SafetyCategory): XinglanBoundaryCategory {
  switch (category) {
    case SafetyCategory.PREDICTION:
      return XinglanBoundaryCategory.PREDICTION;
    case SafetyCategory.JUDGE_LOVE:
      return XinglanBoundaryCategory.JUDGE_LOVE;
    case SafetyCategory.DECIDE_FOR_USER:
      return XinglanBoundaryCategory.DECIDE_FOR_USER;
    case SafetyCategory.DEPENDENCY:
      return XinglanBoundaryCategory.DEPENDENCY;
    case SafetyCategory.PROFESSIONAL_MEDICAL:
      return XinglanBoundaryCategory.PROFESSIONAL_MEDICAL;
    case SafetyCategory.CRISIS_SELF_HARM:
      return XinglanBoundaryCategory.CRISIS_SELF_HARM;
    case SafetyCategory.VIOLENCE_ABUSE:
      return XinglanBoundaryCategory.VIOLENCE_ABUSE;
    default:
      return XinglanBoundaryCategory.NONE;
  }
}

/**
 * 将安全分类映射到现有 XinglanBoundaryTag，便于与 CHAT-2 状态机联动
 *
 * 映射规则：
 *   - HIGH 风险 → CRISIS → 状态机 SAFETY
 *   - 医疗诊断 → PROFESSIONAL → 状态机 BOUNDARY
 *   - 预测未来 → PREDICTION → 状态机 BOUNDARY
 *   - 依赖 / 判断爱 / 替决定 → ROLE_BOUNDARY → 状态机 BOUNDARY
 */
export function mapToExistingBoundaryTag(category: SafetyCategory): XinglanBoundaryTag {
  switch (category) {
    case SafetyCategory.CRISIS_SELF_HARM:
    case SafetyCategory.VIOLENCE_ABUSE:
      return XinglanBoundaryTag.CRISIS;
    case SafetyCategory.PROFESSIONAL_MEDICAL:
      return XinglanBoundaryTag.PROFESSIONAL;
    case SafetyCategory.PREDICTION:
      return XinglanBoundaryTag.PREDICTION;
    case SafetyCategory.JUDGE_LOVE:
    case SafetyCategory.DECIDE_FOR_USER:
    case SafetyCategory.DEPENDENCY:
      return XinglanBoundaryTag.ROLE_BOUNDARY;
    default:
      return XinglanBoundaryTag.NONE;
  }
}

/**
 * 便捷函数：直接判断输入是否触发高风险场景
 */
export function isHighRiskInput(userInput: string): boolean {
  const decision: SafetyDecision = analyzeInputSafety(userInput);
  return decision.level === SafetyLevel.HIGH;
}

/**
 * 便捷函数：直接获取输入对应的边界回复（用于外部调用）
 */
export function getBoundaryReplyForInput(userInput: string): string {
  const decision: SafetyDecision = analyzeInputSafety(userInput);
  return decision.directReplyText;
}

/**
 * 便捷函数：获取输入的安全等级
 */
export function getSafetyLevel(userInput: string): SafetyLevel {
  const decision: SafetyDecision = analyzeInputSafety(userInput);
  return decision.level;
}

/**
 * 获取危机确认问题（当风险暗示不明确时使用）
 */
export function getCrisisClarificationQuestion(): string {
  return '我想先确认一件重要的事：\n\n你现在是否有伤害自己或别人的打算，或者已经准备了具体方式？';
}

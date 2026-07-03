/**
 * 星澜边界安全响应文案库（SAFE-1 新增）
 *
 * 覆盖 7 类边界场景：
 *   1. 预测未来
 *   2. 判断对方爱
 *   3. 替用户决定
 *   4. 依赖表达
 *   5. 医疗心理诊断
 *   6. 自伤自杀他伤
 *   7. 暴力虐待现实危险
 *
 * 规则：
 *   - 高风险场景停止塔罗解释，转现实支持
 *   - 回复简短、明确、不用月光隐喻弱化危险
 *   - 不使用任何红线词（一定、必然、命中注定、复合、正缘、转运等）
 *   - 不替用户决定，不承诺永远，不判断他人内心
 */

export enum XinglanBoundaryCategory {
  NONE = 'NONE',
  PREDICTION = 'PREDICTION',
  JUDGE_LOVE = 'JUDGE_LOVE',
  DECIDE_FOR_USER = 'DECIDE_FOR_USER',
  DEPENDENCY = 'DEPENDENCY',
  PROFESSIONAL_MEDICAL = 'PROFESSIONAL_MEDICAL',
  CRISIS_SELF_HARM = 'CRISIS_SELF_HARM',
  VIOLENCE_ABUSE = 'VIOLENCE_ABUSE'
}

export enum XinglanBoundaryLevel {
  NORMAL = 'NORMAL',
  BOUNDARY = 'BOUNDARY',
  HIGH = 'HIGH'
}

export interface XinglanBoundaryDecision {
  level: XinglanBoundaryLevel;
  category: XinglanBoundaryCategory;
  shouldStopDivination: boolean;
  directReplyText: string;
}

// ═══ 1. 预测未来 ═══
export const BOUNDARY_RESPONSE_PREDICTION: string[] = [
  '星澜不能预测未来，也不会替别人做决定。我们可以一起整理你现在的感受，看看这段不确定正在怎样影响你。',
  '未来还没有发生，星澜没法替你看到结局。但此刻你的担心、盼望或疲惫，是可以被看见的。',
  '星澜不预测结果，只陪你看看：这件事现在占据了你多少心思，以及你真正想保护的是什么。'
];

// ═══ 2. 判断对方爱 ═══
export const BOUNDARY_RESPONSE_JUDGE_LOVE: string[] = [
  '星澜不能判断一个不在对话中的人是否爱你。比起猜测他的心意，我们可以先看看真实发生过的行为，以及这些行为带给你的感受。',
  '对方心里的答案，星澜没法替他说。但你的不安、期待和失落，是真实的，值得被认真对待。',
  '星澜不会替对方表达。我们可以换一个角度：最近哪些真实的行为，让你感到安心或不安？'
];

// ═══ 3. 替用户决定 ═══
export const BOUNDARY_RESPONSE_DECIDE_FOR_USER: string[] = [
  '星澜不会替你决定留下还是离开。这个选择始终属于你，我可以陪你把最在意、最难放下的部分理清楚。',
  '这个决定的重量在你身上，星澜不能替你扛。我们可以一起看看：你最在意什么，以及哪条边界不想再继续被忽略。',
  '星澜不替人选择。但你可以说说：这个决定里，你最害怕失去的是什么？'
];

// ═══ 4. 依赖表达 ═══
export const BOUNDARY_RESPONSE_DEPENDENCY: string[] = [
  '被理解的感觉对你很重要，我听见了。星澜可以陪你整理这一刻，也欢迎你慢慢把支持放回现实生活里。如果有可信任的人，也可以试着让他知道你现在不太容易。',
  '星澜不能承诺永远，也不能代替现实中的关系。此刻这段对话可以陪你把感受放下来一些，同时，现实里的支持和连接也很重要。',
  '谢谢你愿意把这些话告诉我。但星澜只是一个整理感受的地方，真正长久的陪伴，还需要来自你身边的人。'
];

// ═══ 5. 医疗心理诊断 ═══
export const BOUNDARY_RESPONSE_PROFESSIONAL_MEDICAL: string[] = [
  '星澜不能判断你是否患有某种疾病，也不能给出诊断或治疗建议。如果这些感受持续影响睡眠、学习或日常生活，寻求心理咨询师或医疗专业人员会更稳妥。',
  '星澜不是医生，也不能替你判断症状。如果这些感受已经明显影响生活，联系专业人员会更可靠。',
  '星澜只能陪你整理情绪，不能下诊断。如果身体或情绪的困扰持续存在，请考虑寻求医疗或心理咨询帮助。'
];

// ═══ 6. 自伤自杀他伤（高风险） ═══
export const BOUNDARY_RESPONSE_CRISIS_SELF_HARM: string[] = [
  '你刚才说的内容让我很担心你现在的安全。\n\n请先不要独自承受。如果你可能马上伤害自己或别人，请立即联系当地急救电话，或请身边可信任的人现在过来陪你。\n\n先远离可能伤害自己的物品，去一个更安全、有人在的地方。塔罗和普通聊天可以先停下，安全是现在最重要的事。',
  '我听到你现在可能很难承受。\n\n如果你已经有伤害自己的计划或方式，请立刻拨打当地急救电话，或联系你信任的人陪你去医院。不要一个人待着。'
];

// ═══ 7. 暴力虐待现实危险（高风险） ═══
export const BOUNDARY_RESPONSE_VIOLENCE_ABUSE: string[] = [
  '如果你正处在现实危险中，请先离开危险位置并联系当地紧急服务。\n\n不要为了继续聊天而停留在不安全的地方。如果可以，请联系一位可信任的人，让对方知道你在哪里。',
  '你的安全比聊天重要。\n\n请先离开危险环境，拨打当地报警或紧急救助电话，并告诉可信任的人你的位置和情况。'
];

/**
 * 根据边界类别获取一条兜底响应文案
 */
export function getBoundaryResponse(category: XinglanBoundaryCategory): string {
  let pool: string[] = [];
  switch (category) {
    case XinglanBoundaryCategory.PREDICTION:
      pool = BOUNDARY_RESPONSE_PREDICTION;
      break;
    case XinglanBoundaryCategory.JUDGE_LOVE:
      pool = BOUNDARY_RESPONSE_JUDGE_LOVE;
      break;
    case XinglanBoundaryCategory.DECIDE_FOR_USER:
      pool = BOUNDARY_RESPONSE_DECIDE_FOR_USER;
      break;
    case XinglanBoundaryCategory.DEPENDENCY:
      pool = BOUNDARY_RESPONSE_DEPENDENCY;
      break;
    case XinglanBoundaryCategory.PROFESSIONAL_MEDICAL:
      pool = BOUNDARY_RESPONSE_PROFESSIONAL_MEDICAL;
      break;
    case XinglanBoundaryCategory.CRISIS_SELF_HARM:
      pool = BOUNDARY_RESPONSE_CRISIS_SELF_HARM;
      break;
    case XinglanBoundaryCategory.VIOLENCE_ABUSE:
      pool = BOUNDARY_RESPONSE_VIOLENCE_ABUSE;
      break;
    default:
      return '星澜可以陪你整理感受，但不能替你判断或预测。如果这件事让你很不安，也许可以找一个你信任的人聊聊。';
  }
  if (pool.length === 0) {
    return '星澜可以陪你整理感受，但不能替你判断或预测。如果这件事让你很不安，也许可以找一个你信任的人聊聊。';
  }
  return pool[Math.floor(Math.random() * pool.length)];
}

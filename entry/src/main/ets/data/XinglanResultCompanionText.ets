/**
 * 星澜结果页陪伴文案数据
 *
 * Phase 8-C: 在牌义解读下方追加"星澜陪你看见"区，4 段结构。
 *
 * 结构：
 *   title     — 区域标题
 *   receive   — 星澜先接住你
 *   reflect   — 这张牌照见什么
 *   question  — 给自己的一个问题
 *   action    — 今天可以做的一件小事
 *
 * 第一版使用通用模板，后续可扩展为每张牌专属文案。
 */

/** 陪伴文案结构 */
export interface ResultCompanionText {
  title: string;
  receive: string;
  reflect: string;
  question: string;
  action: string;
}

/**
 * 获取单牌结果页陪伴文案
 * @param cardName 牌中文名
 * @param isReversed 是否逆位
 * @returns 陪伴文案结构
 */
export function getSingleCardCompanionText(
  cardName: string,
  isReversed: boolean
): ResultCompanionText {
  const orientationHint: string = isReversed ? '以逆位出现时，' : '停在你面前时，';

  return {
    title: '星澜陪你看见',
    receive: `也许${cardName}不是在告诉你答案，而是在轻轻提醒：你已经把这件事放在心里很久了。`,
    reflect: `它照见的，可能是你此刻最需要被听见的那部分感受——${orientationHint}它邀请你先不用急着判断对错，只先看看自己正在经历什么。`,
    question: '可以问问自己：如果今天只允许我照顾自己一点点，我最想先照顾哪一部分？',
    action: '今天可以做的小事：把最重的那句话写下来，不急着解释，也不急着解决。先让它从心里出来，落在纸上。'
  };
}

/**
 * 获取圣三角结果页陪伴文案
 * @returns 陪伴文案结构
 */
export function getTriangleCompanionText(): ResultCompanionText {
  return {
    title: '星澜陪你整理这三张牌',
    receive: '这三张牌不是在替你决定接下来会发生什么。它们更像把一件心事分成了三个角度，让你可以慢慢看清：哪些是已经走过的，哪些是正在发生的，哪些只是还没有确定的可能。',
    reflect: '也许这三张牌像是在帮你整理：过去并没有白白经过，现在的状态值得被认真看见，而未来，并不需要你今天就给出答案。',
    question: '可以问问自己：如果不急着得出结论，我现在最想先理解这三段线索里的哪一部分？',
    action: '今天可以做的小事：把这件事拆成"我已经知道的"和"我还不确定的"两栏写下来。先不用解决，只要看清。'
  };
}

/**
 * 获取关系探索结果页陪伴文案
 * 聚焦用户感受与边界，不判断对方，不预测关系走向
 * @returns 陪伴文案结构
 */
export function getRelationCompanionText(): ResultCompanionText {
  return {
    title: '星澜陪你把关系放轻一点',
    receive: '这组牌不是在替你判断谁对谁错。它更像把这段关系里那些说不清的感受，轻轻放到月光下。',
    reflect: '也许你真正想确认的，不只是对方怎么想，还有：在这段关系里，我有没有被好好看见？我有没有正在消耗自己？',
    question: '可以问问自己：如果先不急着靠近或离开，我最需要守住的一条边界是什么？',
    action: '今天可以做的小事：写下这段关系里让你安心的一件事，和让你消耗的一件事。先不用做决定，只把它们看清楚。'
  };
}

// ═══════════════════════════════════════════════════════════
// RESULT-2：问心模式（held / light）专属陪伴文案
//
// 设计依据：开发计划 6.2 节（抽牌前语感）+ 10.4 节（星澜轻放的话）
//   - held（今天我想被接住）：先承接，不主动建议，不强行积极，
//     结尾以允许暂停为主。
//   - light（今天我想看见光）：仍先承接，提供一个可选角度，
//     最多一个微小行动，不变成积极鸡汤。
//
// 红线遵守：不含「一定/必然/复合/命中注定/转运/你应该」等词；
//   不预测未来、不替用户决定、不制造依赖。
// ═══════════════════════════════════════════════════════════

/**
 * 被接住模式（held）陪伴文案
 *
 * 语感：先接住感受，不催促找答案，结尾允许暂停。
 * @param cardName 牌中文名
 * @param isReversed 是否逆位
 * @returns 陪伴文案结构
 */
export function getHeldCompanionText(
  cardName: string,
  isReversed: boolean
): ResultCompanionText {
  const orientationHint: string = isReversed ? '以逆位出现时' : '停在你面前时';

  const result: ResultCompanionText = {
    title: '星澜陪你停下来',
    receive: `也许${cardName}不是在催你找到答案。它${orientationHint}，更像是陪你看看，此刻有什么感受还没有被好好听见。`,
    reflect: '你不用现在就把它解释清楚。有些沉重只需要先被承认——它在那里，它有它的理由，并不需要你立刻把它变成什么。',
    question: '可以问问自己：如果今天允许我什么都不先解决，我最想先放下的，是哪一份紧绷？',
    action: '今天可以暂时什么都不做。想暂停一下也没关系——星澜不会替你决定，也不会催你往前。'
  };
  return result;
}

/**
 * 看见光模式（light）陪伴文案
 *
 * 语感：仍先承接，再留一个可选角度，最多一个微小行动。
 * 不变成积极鸡汤，不承诺好转。
 * @param cardName 牌中文名
 * @param isReversed 是否逆位
 * @returns 陪伴文案结构
 */
export function getLightCompanionText(
  cardName: string,
  isReversed: boolean
): ResultCompanionText {
  const orientationHint: string = isReversed ? '以逆位出现时' : '停在你面前时';

  const result: ResultCompanionText = {
    title: '星澜陪你看见一点光',
    receive: `也许${cardName}${orientationHint}，不是要替你决定方向。它更像先接住你此刻的感受，再留下一点线索。`,
    reflect: '在被理解之后，也许可以慢慢看看一个角度：现在这件事里，你最想保护的是什么？不一定马上有答案，能看见这个问题本身，就已经是光。',
    question: '可以问问自己：如果只留一个你最不愿意丢掉的东西，它会是什么？',
    action: '今天可以做的一件小事：把那个「最想保护的」写下来，只一行就好。不用为了它做什么，先认得它。'
  };
  return result;
}

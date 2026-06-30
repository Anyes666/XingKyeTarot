export interface SpreadPosition {
  index: number;
  name: string;
  meaning: string;
}

export interface SpreadTemplate {
  id: string;
  name: string;
  positions: SpreadPosition[];
}

export const SACRED_TRIANGLE_SPREAD: SpreadTemplate = {
  id: 'sacred_triangle',
  name: '圣三角',
  positions: [
    { index: 0, name: '过去', meaning: '问题的背景与已经发生的影响' },
    { index: 1, name: '现在', meaning: '当下最需要被看见的状态' },
    { index: 2, name: '未来', meaning: '接下来可能展开的趋势' }
  ]
};

export const SINGLE_CARD_SPREAD: SpreadTemplate = {
  id: 'single_card',
  name: '每日一占',
  positions: [
    { index: 0, name: '指引', meaning: '此刻最值得关注的一张牌' }
  ]
};

export const RELATIONSHIP_SPREAD: SpreadTemplate = {
  id: 'relationship',
  name: '关系探索',
  positions: [
    { index: 0, name: '我的状态', meaning: '我在这段关系中的真实状态' },
    { index: 1, name: '对方状态', meaning: '对方当前呈现出的关系状态' },
    { index: 2, name: '关系走向', meaning: '这段关系接下来可能展开的方向' }
  ]
};

export function getSpreadById(spreadId: string): SpreadTemplate {
  if (spreadId === SINGLE_CARD_SPREAD.id) {
    return SINGLE_CARD_SPREAD;
  }
  if (spreadId === RELATIONSHIP_SPREAD.id) {
    return RELATIONSHIP_SPREAD;
  }
  return SACRED_TRIANGLE_SPREAD;
}

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

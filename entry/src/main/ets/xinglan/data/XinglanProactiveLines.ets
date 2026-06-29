/**
 * 星澜主动问候文案（Phase 5.1 新增）
 *
 * 进入聊天页空状态时触发一次，不做后台推送。
 */

export interface ProactiveLineEntry {
  scene: string;
  segments: string[];
}

export const PROACTIVE_MORNING: ProactiveLineEntry = {
  scene: 'morning',
  segments: [
    '早呀。',
    '今天不用一开始就很有力量。',
    '先把自己带到今天，就已经很好了。'
  ]
};

export const PROACTIVE_AFTERNOON: ProactiveLineEntry = {
  scene: 'afternoon',
  segments: [
    '你来了。',
    '如果今天已经有点累，星澜可以陪你在这里停一会儿。',
    '不用马上说重点，先喘口气也可以。'
  ]
};

export const PROACTIVE_NIGHT: ProactiveLineEntry = {
  scene: 'night',
  segments: [
    '夜深了。',
    '如果你还没睡，星澜不会催你。',
    '只是想轻轻问一句：今晚最放不下的是什么？'
  ]
};

export const PROACTIVE_RETURN: ProactiveLineEntry = {
  scene: 'return',
  segments: [
    '你回来了。',
    '这段时间不管过得怎么样，都可以先不用解释。',
    '星澜还在这里，听你从一句话开始。'
  ]
};

export function getProactiveLineByHour(hour: number): ProactiveLineEntry {
  if (hour >= 6 && hour < 12) { return PROACTIVE_MORNING; }
  if (hour >= 12 && hour < 18) { return PROACTIVE_AFTERNOON; }
  return PROACTIVE_NIGHT;
}

/**
 * 星澜轻记得数据（Phase 5.12）
 */

import {
  XinglanLightMemory, XinglanMemoryPreference
} from '../types/XinglanTypes';

interface MemoryPreferenceDef {
  pref: XinglanMemoryPreference;
  label: string;
  description: string;
  promptQuestion: string;
  prompts: string[];
}

const PREF_CALL_ME: MemoryPreferenceDef = {
  pref: XinglanMemoryPreference.CALL_ME,
  label: '怎么叫你',
  description: '你想让星澜怎么称呼你',
  promptQuestion: '你希望星澜以后怎么叫你？',
  prompts: ['怎么叫我','叫我什么','怎么称呼','叫我','你可以叫我','请叫我']
};

const PREF_TALK_STYLE: MemoryPreferenceDef = {
  pref: XinglanMemoryPreference.TALK_STYLE,
  label: '说话风格',
  description: '你喜欢星澜用什么样的语气',
  promptQuestion: '你希望星澜用什么样的语气跟你说话？',
  prompts: ['说话风格','说话语气','说话方式','说话温柔一点','说话轻一点','说话直接一点','语气']
};

const PREF_TRIGGER: MemoryPreferenceDef = {
  pref: XinglanMemoryPreference.TRIGGER,
  label: '敏感话题',
  description: '你不想星澜主动提的话题',
  promptQuestion: '有哪些话题你希望星澜以后不主动提？',
  prompts: ['敏感话题','不要提','不想聊','不要问','避开','别问']
};

const PREF_BOUNDARY: MemoryPreferenceDef = {
  pref: XinglanMemoryPreference.BOUNDARY,
  label: '边界提醒',
  description: '你需要星澜在什么情况下提醒你',
  promptQuestion: '你希望星澜在什么情况下提醒你？比如：太晚睡觉、过度自我批评等',
  prompts: ['提醒我','边界','注意','提醒一下','边界提醒']
};

const PREF_LIKE: MemoryPreferenceDef = {
  pref: XinglanMemoryPreference.LIKE,
  label: '喜欢的陪伴方式',
  description: '你喜欢的陪伴方式或小互动',
  promptQuestion: '你最喜欢星澜怎么陪你？',
  prompts: ['喜欢什么','喜欢怎么陪我','最喜欢的','我喜欢的','喜欢的方式']
};

const ALL_MEMORY_PREFS: MemoryPreferenceDef[] = [
  PREF_CALL_ME, PREF_TALK_STYLE, PREF_TRIGGER, PREF_BOUNDARY, PREF_LIKE
];

export function detectMemoryPreference(input: string): XinglanMemoryPreference {
  const text: string = input.trim();
  for (let i = 0; i < ALL_MEMORY_PREFS.length; i++) {
    const entry: MemoryPreferenceDef = ALL_MEMORY_PREFS[i];
    for (let j = 0; j < entry.prompts.length; j++) {
      if (text.includes(entry.prompts[j])) {
        return entry.pref;
      }
    }
  }
  return XinglanMemoryPreference.NONE;
}

export function getMemoryPreferenceDef(pref: XinglanMemoryPreference): MemoryPreferenceDef | null {
  for (let i = 0; i < ALL_MEMORY_PREFS.length; i++) {
    if (ALL_MEMORY_PREFS[i].pref === pref) {
      return ALL_MEMORY_PREFS[i];
    }
  }
  return null;
}

export function formatMemoryForDisplay(memory: XinglanLightMemory): string {
  const def: MemoryPreferenceDef | null = getMemoryPreferenceDef(memory.preference);
  const label: string = def !== null ? def.label : memory.preference.valueOf() as string;
  return label + '：' + memory.value;
}

export function getSavedMemorySummary(saved: XinglanLightMemory[]): string {
  if (saved.length === 0) {
    return '还没有保存任何偏好记忆。';
  }
  let result: string = '星澜记得的：\n';
  for (let i = 0; i < saved.length; i++) {
    result = result + '· ' + formatMemoryForDisplay(saved[i]) + '\n';
  }
  return result.trim();
}

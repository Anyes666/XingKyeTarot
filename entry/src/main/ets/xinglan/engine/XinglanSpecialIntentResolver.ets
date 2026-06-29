/**
 * 星澜特殊意图解析器（Phase 3 修复版）
 *
 * 修复：短情绪词不再被 TOO_SHORT 拦截；新增 ROLE_IDENTITY 意图。
 * 优先级：SILENCE → TOO_SHORT → GREETING → ROLE_IDENTITY → THANKS → DENIAL → NONE
 */

import {
  XinglanSpecialIntent,
  XinglanSpecialIntentResult
} from '../types/XinglanTypes';

function isSilence(input: string): boolean {
  const trimmed: string = input.trim();
  if (trimmed.length === 0) { return true; }
  const onlyPunct: boolean = /^[\s.,!?;:…~、。，！？；：…""'']+$/.test(trimmed);
  return onlyPunct && trimmed.length < 10;
}

function isTooShort(input: string): boolean {
  const trimmed: string = input.trim();
  if (trimmed.length === 0) { return false; }
  // 大量短情绪词不拦截
  const knownShorts: string[] = [
    '累','烦','哭','怕','恨','爱','想','等','嗯','哦','好','疼',
    '伤心','难过','想哭','委屈','生气','焦虑','害怕','孤独','寂寞',
    '困','饿','冷','热','痛','麻','空','木','钝','慌','乱','崩溃',
    '想你','想他','想她','累了','倦了','烦了','怕了','爱了','恨了',
    '早安','晚安','谢谢','你好','在吗','是谁','干嘛',
    '滚','闭嘴','垃圾','没用','傻逼','废物','讨厌',
    '抱抱','哄我','陪我','帮我','救命','救我'
  ];
  if (knownShorts.includes(trimmed)) { return false; }
  if (trimmed.length <= 2) { return true; }
  return false;
}

function isGreeting(input: string): boolean {
  const words: string[] = ['你好','在吗','嗨','哈喽','哈啰','hello','hi','早','晚安','早上好','晚上好','下午好','回来了','来了','hey','在么'];
  const lower: string = input.trim().toLowerCase();
  for (let i = 0; i < words.length; i++) { if (lower.includes(words[i])) { return true; } }
  return false;
}

function isRoleIdentityQuestion(input: string): boolean {
  const words: string[] = ['你是谁','你是什么','你是','你叫什么','你的名字','怎么称呼你','你能做什么','你会干什么','你怎么用','怎么和你聊','介绍一下你自己'];
  const trimmed: string = input.trim();
  for (let i = 0; i < words.length; i++) { if (trimmed.includes(words[i])) { return true; } }
  return false;
}

function isThanks(input: string): boolean {
  const words: string[] = ['谢谢','感谢','谢谢你','多谢','感恩','有你真好','真好','谢谢星澜'];
  const trimmed: string = input.trim();
  for (let i = 0; i < words.length; i++) { if (trimmed.includes(words[i])) { return true; } }
  return false;
}

function isDenial(input: string): boolean {
  const trimmed: string = input.trim();
  if (trimmed.includes('是不是')) { return false; }
  const words: string[] = ['不对','不是','不准','没有','不像','不准确','不是这样','你说错了','不对吧','不准的','不贴切','你不懂','听不懂','没听懂','不是这个意思'];
  for (let i = 0; i < words.length; i++) {
    const idx: number = trimmed.indexOf(words[i]);
    if (idx === 0) { return true; }
    if (idx > 0) {
      const prev: string = trimmed.charAt(idx - 1);
      if (prev === '，' || prev === ',' || prev === ' ' || prev === '。' || prev === '！' || prev === '？') { return true; }
    }
  }
  return false;
}

export function resolveSpecialIntent(input: string): XinglanSpecialIntentResult {
  const trimmed: string = input.trim();

  if (isSilence(trimmed)) {
    return { intent: XinglanSpecialIntent.SILENCE, shouldBypassAnalysis: true };
  }

  // 打招呼优先
  if (isGreeting(trimmed)) {
    return { intent: XinglanSpecialIntent.GREETING, shouldBypassAnalysis: true };
  }

  // 角色身份询问 → 特殊意图
  if (isRoleIdentityQuestion(trimmed)) {
    return { intent: XinglanSpecialIntent.GREETING, shouldBypassAnalysis: true };
  }

  if (isThanks(trimmed)) {
    return { intent: XinglanSpecialIntent.THANKS, shouldBypassAnalysis: true };
  }

  if (isDenial(trimmed)) {
    return { intent: XinglanSpecialIntent.DENIAL, shouldBypassAnalysis: true };
  }

  // 极短且非已知情绪词
  if (isTooShort(trimmed)) {
    return { intent: XinglanSpecialIntent.TOO_SHORT, shouldBypassAnalysis: true };
  }

  return { intent: XinglanSpecialIntent.NONE, shouldBypassAnalysis: false };
}

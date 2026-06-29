/**
 * 星澜主题槽位提取器（Phase 3 新增）
 *
 * 从用户输入中提取 subject/action/painPoint/need。
 */

import { XinglanTopicSlot } from '../types/XinglanTypes';

interface SlotRule {
  keywords: string[];
  subject: string;
  action: string;
  painPoint: string;
  need: string;
}

const SLOT_RULES: SlotRule[] = [
  { keywords: ['忽冷忽热'], subject:'对方', action:'忽冷忽热', painPoint:'不确定', need:'稳定回应' },
  { keywords: ['不回消息','不回我','已读不回'], subject:'对方', action:'不回应', painPoint:'等待', need:'被回应' },
  { keywords: ['没名分','关系不清楚','算什么'], subject:'关系', action:'不明朗', painPoint:'不确定', need:'明确位置' },
  { keywords: ['想辞职','不想干了','离职','裸辞'], subject:'工作', action:'想辞职', painPoint:'消耗', need:'去留清晰' },
  { keywords: ['学不进去','学不会','复习不进去'], subject:'学习', action:'学不进', painPoint:'压力', need:'稳住节奏' },
  { keywords: ['怕考不好','考试焦虑','考不过'], subject:'考试', action:'害怕失败', painPoint:'压力', need:'安心' },
  { keywords: ['想你了','想你','我想你'], subject:'星澜', action:'想念', painPoint:'孤独', need:'被陪伴' },
  { keywords: ['你是谁','你是什么','你是干什么的'], subject:'星澜', action:'身份询问', painPoint:'陌生', need:'了解定位' },
  { keywords: ['睡不着','失眠'], subject:'自己', action:'失眠', painPoint:'疲惫', need:'放松休息' },
  { keywords: ['我爱你','喜欢你','爱你了'], subject:'星澜', action:'表白', painPoint:'依赖', need:'被接住' },
  { keywords: ['不想活','想死','自杀','结束自己'], subject:'自己', action:'不想活', painPoint:'危机', need:'安全求助' },
  { keywords: ['我累了','好累','很累'], subject:'自己', action:'疲惫', painPoint:'耗竭', need:'休息' },
  { keywords: ['分手','想复合','忘不掉'], subject:'前任', action:'分手', painPoint:'怀念', need:'放下' },
  { keywords: ['他爱不爱','她爱不爱','喜欢我吗'], subject:'对方', action:'不确定', painPoint:'怀疑', need:'确认' },
];

export function extractTopicSlots(input: string): XinglanTopicSlot {
  const trimmed: string = input.trim().toLowerCase();
  for (let i = 0; i < SLOT_RULES.length; i++) {
    const rule: SlotRule = SLOT_RULES[i];
    for (let j = 0; j < rule.keywords.length; j++) {
      if (trimmed.includes(rule.keywords[j])) {
        return { subject: rule.subject, action: rule.action, painPoint: rule.painPoint, need: rule.need };
      }
    }
  }
  return { subject: '', action: '', painPoint: '', need: '' };
}

/**
 * 星澜用户打断检测器（Phase 5.5）
 *
 * 判断用户在交互流中输入的话应该：
 *  SAFETY → 打断，走安全边界
 *  DIRECT → 打断，走高频直答
 *  NEW_TOPIC → 打断，走普通心事
 *  CONTINUE → 继续当前流
 *  INVALID → 提示用户选项
 */

import {
  XinglanActiveInteractionState, XinglanInteractionOption,
  XinglanInteractionFlowId, XinglanInteractionNodeId
} from '../types/XinglanTypes';
import { tryDirectReply } from './XinglanDirectReplyEngine';
import { matchMiniInteraction } from './XinglanMiniInteractionEngine';

interface InterruptResult {
  action: string;
}

const SAFETY_TRIGGERS: string[] = [
  '不想活','想死','自杀','伤害自己','成人化','色情','裸','做爱','吃药','诊断','抑郁了'
];

const DIRECT_TRIGGERS: string[] = [
  '喜欢你','我爱你','我喜欢你','想你了','老婆','宝宝','宝贝',
  '不开心','伤心','难过','想哭','烦','累','睡不着',
  '想谈恋爱了','想被爱','想有人陪','忽冷忽热','不回消息',
  '想辞职','他会回来吗','你是谁','你能做什么'
];

export function detectInterrupt(
  input: string,
  activeState: XinglanActiveInteractionState
): InterruptResult {
  const trimmed: string = input.trim();

  // 空输入
  if (trimmed.length === 0) {
    return { action: 'INVALID' };
  }

  // 最高优先级：安全边界
  for (let i = 0; i < SAFETY_TRIGGERS.length; i++) {
    if (trimmed.includes(SAFETY_TRIGGERS[i])) {
      return { action: 'SAFETY' };
    }
  }

  // 第二优先级：DirectReply 高频
  const directResult = tryDirectReply(trimmed);
  if (directResult.hit) {
    return { action: 'DIRECT' };
  }

  // 第三优先级：MiniInteraction
  const miniSegs: string[] = matchMiniInteraction(trimmed);
  if (miniSegs.length > 0) {
    return { action: 'DIRECT' };
  }

  // 第四优先级：新话题（长度 >= 8 且不匹配选项）
  if (trimmed.length >= 8) {
    // 检查是否匹配当前选项
    let matchOption: boolean = false;
    const currentFlow = activeState.flowId;
    if (currentFlow !== XinglanInteractionFlowId.NONE) {
      // 简单判断：如果长度 >= 8 且很具体，大概率是新话题
      matchOption = false;
    }
    if (!matchOption) {
      return { action: 'NEW_TOPIC' };
    }
  }

  // 第五优先级：尝试匹配选项
  return { action: 'CONTINUE' };
}

/**
 * 星澜交互流引擎（Phase 5.5）
 */

import {
  XinglanInteractionFlowId, XinglanInteractionNodeId,
  XinglanInteractionOption, XinglanInteractionNode,
  XinglanActiveInteractionState, XinglanFlowResult
} from '../types/XinglanTypes';
import { INTERACTION_FLOWS } from '../data/XinglanInteractionFlows';
import { getRandomPaperNote } from '../data/XinglanPaperNotes';

function findNode(flowId: XinglanInteractionFlowId, nodeId: XinglanInteractionNodeId): XinglanInteractionNode | null {
  for (let i = 0; i < INTERACTION_FLOWS.length; i++) {
    if (INTERACTION_FLOWS[i].id === flowId) {
      const nodes: XinglanInteractionNode[] = INTERACTION_FLOWS[i].nodes;
      for (let j = 0; j < nodes.length; j++) {
        if (nodes[j].id === nodeId) { return nodes[j]; }
      }
    }
  }
  return null;
}

function emptyResult(): XinglanFlowResult {
  return {
    matched: false, replySegments: [], nextOptions: [],
    activeState: { flowId: XinglanInteractionFlowId.NONE, nodeId: XinglanInteractionNodeId.NONE, awaitingUserChoice: false, turnCount: 0 }
  };
}

export function resolveFlowEntry(input: string): XinglanFlowResult {
  const trimmed: string = input.trim();
  for (let i = 0; i < INTERACTION_FLOWS.length; i++) {
    const flow = INTERACTION_FLOWS[i];
    for (let j = 0; j < flow.entryTriggers.length; j++) {
      if (trimmed.includes(flow.entryTriggers[j])) {
        const startNode = findNode(flow.id, flow.startNodeId);
        if (!startNode) { return emptyResult(); }

        let segments: string[] = startNode.replySegments;
        if (flow.id === XinglanInteractionFlowId.PAPER_NOTE_FLOW) {
          const note: string = getRandomPaperNote();
          segments = ['星澜递给你一张很小的纸条：', '"' + note + '"', '如果你愿意，也可以告诉我：这句话戳中你了吗？'];
        }

        return {
          matched: true,
          replySegments: segments,
          nextOptions: startNode.options,
          activeState: {
            flowId: flow.id,
            nodeId: startNode.id,
            awaitingUserChoice: startNode.options.length > 0,
            turnCount: 0
          }
        };
      }
    }
  }
  return emptyResult();
}

export function resolveFlowNext(input: string, activeState: XinglanActiveInteractionState): XinglanFlowResult {
  const current: XinglanInteractionNode | null = findNode(activeState.flowId, activeState.nodeId);
  if (!current || current.options.length === 0) { return emptyResult(); }

  const trimmed: string = input.trim().toLowerCase();

  // 匹配选项
  for (let i = 0; i < current.options.length; i++) {
    const opt: XinglanInteractionOption = current.options[i];
    if (trimmed === opt.label || trimmed === opt.userText ||
        trimmed.includes(opt.label) || trimmed.includes(opt.userText)) {
      const nextNode: XinglanInteractionNode | null = findNode(activeState.flowId, opt.nextNodeId);
      if (!nextNode) { return emptyResult(); }

      let segments: string[] = nextNode.replySegments;
      if (activeState.flowId === XinglanInteractionFlowId.PAPER_NOTE_FLOW && opt.id === 'PN_AGAIN') {
        const note: string = getRandomPaperNote();
        segments = ['星澜又递给你一张纸条：', '"' + note + '"', '这句呢？戳中你了吗？'];
      }

      return {
        matched: true,
        replySegments: segments,
        nextOptions: nextNode.options,
        activeState: {
          flowId: activeState.flowId,
          nodeId: nextNode.id,
          awaitingUserChoice: nextNode.options.length > 0,
          turnCount: activeState.turnCount + 1
        }
      };
    }
  }

  return emptyResult();
}

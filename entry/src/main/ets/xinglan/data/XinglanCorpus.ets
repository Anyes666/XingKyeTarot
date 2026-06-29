import { XinglanChatLine, XinglanEmotionTag, XinglanTopicTag, XinglanReplyStrategy } from '../types/XinglanTypes';

export const CORPUS_HOLD_EMOTION: XinglanChatLine[] = [
  { id:'HOLD_001', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'听起来，你已经撑了一段时间了。' },
  { id:'HOLD_002', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'这件事在你心里停了很久，不是随便一句"没事"就能放下的。' },
  { id:'HOLD_003', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'我不会急着让你想开。我们可以先把这份感受放在这里。' },
  { id:'HOLD_004', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.ANY, text:'听起来，你不是不想继续，而是真的消耗了太久。' },
  { id:'HOLD_005', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.ANY, text:'如果现在什么都不想做，也许不是懒，而是心里已经没有多少余量了。' },
  { id:'HOLD_006', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.ANY, text:'今天可以先不追求变好，只看看哪里最让你耗尽。' },
  { id:'HOLD_007', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANXIOUS, topic:XinglanTopicTag.ANY, text:'听起来，你的心一直在提前替未来承受很多东西。' },
  { id:'HOLD_008', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANXIOUS, topic:XinglanTopicTag.ANY, text:'焦虑常常不是因为你脆弱，而是因为你太想把一切都准备好。' },
  { id:'HOLD_009', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.SAD, topic:XinglanTopicTag.ANY, text:'这份难过不是小题大做。它出现在这里，一定有它的来处。' },
  { id:'HOLD_010', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.SAD, topic:XinglanTopicTag.ANY, text:'我会轻一点听，不把你的难过说轻。' },
  { id:'HOLD_011', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.LONELY, topic:XinglanTopicTag.ANY, text:'听起来，你不是没有人可以说话，而是很难找到真正能接住你的人。' },
  { id:'HOLD_012', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.LONELY, topic:XinglanTopicTag.ANY, text:'如果你愿意，星澜会先在这里听你说完。' },
  { id:'HOLD_013', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你不是太敏感。你只是很认真地感受到了那些细微的变化。' },
  { id:'HOLD_014', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'有些难受，不需要马上解释清楚。能说出来，已经很不容易。' },
  { id:'HOLD_015', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'现在先不用证明自己没事。你可以先承认：这确实让你累了。' },
  { id:'HOLD_016', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.NUMB, topic:XinglanTopicTag.ANY, text:'有时候人不是突然崩溃，而是很久很久没有真正停下来。' }
];

export const CORPUS_REFLECT: XinglanChatLine[] = [
  { id:'REFLECT_001', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'我听见的是，你其实不是只在意结果，而是在意这一路上自己被怎样对待。' },
  { id:'REFLECT_002', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你好像一直在努力保持平静，但心里其实已经来回翻了很多次。' },
  { id:'REFLECT_003', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你一边想让自己理智一点，一边又没办法忽略心里的不舒服。' },
  { id:'REFLECT_004', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你不是没有想过放下，只是有些东西还没有被好好告别。' },
  { id:'REFLECT_005', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你现在像是站在两个方向之间：一个想继续撑，一个想停下来。' },
  { id:'REFLECT_006', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'也许你真正想问的不是"怎么办"，而是"我这样感受，可以吗"。' },
  { id:'REFLECT_007', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你似乎已经听过很多道理了，但现在更需要的是被温柔地理解一下。' },
  { id:'REFLECT_008', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.RELATION, text:'这件事让你难受的地方，也许不是单独某一句话，而是累积起来的感觉。' }
];

export const CORPUS_RELATION_BOUNDARY: XinglanChatLine[] = [
  { id:'REL_001', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.RELATION, text:'星澜不会替你判断对方心里到底怎么想。那不是一张牌、也不是一句话能确定的。' },
  { id:'REL_002', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.RELATION, text:'我们可以先不急着猜对方，而是先看看：这段关系让你变成了什么样子。' },
  { id:'REL_003', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.RELATION, text:'忽冷忽热最累的地方，是它让人一直站在等待里。' },
  { id:'REL_004', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.RELATION, text:'如果一段关系总让你猜，也许你可以先问问自己：我在这里有没有被好好对待。' },
  { id:'REL_005', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.RELATION, text:'放不下不代表你想回去。有时只是那段经历还没有被心里安放好。' },
  { id:'REL_006', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.RELATION, text:'不必因为还会想起，就责怪自己退步了。记忆本来就不会按命令消失。' },
  { id:'REL_007', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.FAMILY, text:'越亲近的关系，有时越难把边界说出口。' },
  { id:'REL_008', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.RELATION, text:'你不需要用自己的不安，去替对方补完所有沉默。' },
  { id:'REL_009', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'比起"对方到底爱不爱"，也许更值得看的，是你在这段关系里是否安心。' }
];

export const CORPUS_CLARIFY: XinglanChatLine[] = [
  { id:'CLARIFY_001', strategy:XinglanReplyStrategy.CLARIFY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.CHOICE, text:'我们先不急着选答案。可以先把这件事拆成两个部分：你想要什么，你害怕什么。' },
  { id:'CLARIFY_002', strategy:XinglanReplyStrategy.CLARIFY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.CHOICE, text:'如果现在看不清方向，也许不是你不够清醒，而是这件事牵动了太多东西。' },
  { id:'CLARIFY_003', strategy:XinglanReplyStrategy.CLARIFY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.CHOICE, text:'星澜不会替你选，但可以陪你把混乱分开放好。' },
  { id:'CLARIFY_004', strategy:XinglanReplyStrategy.CLARIFY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.CHOICE, text:'当两个选择都让你难受时，真正需要看的可能不是选项，而是你被困住的原因。' },
  { id:'CLARIFY_005', strategy:XinglanReplyStrategy.CLARIFY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.CHOICE, text:'选择困难的时候，先别问"哪个一定对"，可以先问"哪个更不背叛自己"。' },
  { id:'CLARIFY_006', strategy:XinglanReplyStrategy.CLARIFY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.CHOICE, text:'你不用马上决定。很多决定，是在一次次看清之后自然浮出来的。' },
  { id:'CLARIFY_007', strategy:XinglanReplyStrategy.CLARIFY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'有些答案不是被想出来的，而是在你慢慢诚实之后，变得清楚一点。' }
];

export const CORPUS_TINY_STEP: XinglanChatLine[] = [
  { id:'STEP_001', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'如果愿意，今天可以只做一件很小的事：把最累的那一点写下来。' },
  { id:'STEP_002', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你不需要马上改变全部。先给自己十分钟，不处理任何人的期待。' },
  { id:'STEP_003', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'今天不用逼自己走很远。能照顾好眼前这一小步，也算数。' },
  { id:'STEP_004', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'有时候最小的一步，是先允许自己不马上有答案。' },
  { id:'STEP_005', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.ANY, text:'你可以先不用逼自己马上恢复。累了这件事，本身就值得被认真对待。' },
  { id:'STEP_006', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.ANXIOUS, topic:XinglanTopicTag.ANY, text:'先不用把所有可能性都想完。我们可以只看眼前最小的一步。' },
  { id:'STEP_007', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'先不急着联系谁，也不急着回复谁。你可以先确认自己的感受。' }
];

export const CORPUS_SOFT_QUESTION: XinglanChatLine[] = [
  { id:'Q_001', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'这件事里，最让你难受的是失望、委屈，还是不确定？' },
  { id:'Q_002', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.RELATION, text:'你希望自己在这段关系里，至少被怎样对待？' },
  { id:'Q_003', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.CHOICE, text:'如果不考虑别人怎么看，你心里最诚实的感受是什么？' },
  { id:'Q_004', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'如果把"必须马上解决"放下，你现在最需要的是什么？' },
  { id:'Q_005', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.FUTURE, text:'如果未来还不清楚，此刻的你最需要先照顾什么？' },
  { id:'Q_006', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.ANY, text:'最让你耗尽的，是事情本身，还是你一直没有停下来？' },
  { id:'Q_007', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你愿意先从最小、最不伤害自己的那一步开始吗？' },
  { id:'Q_008', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你想让星澜继续听你说哪一部分？' }
];

export const CORPUS_TAROT_METAPHOR: XinglanChatLine[] = [
  { id:'TAROT_001', strategy:XinglanReplyStrategy.TAROT_METAPHOR, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'牌面不是答案。它更像一面小镜子，让你看见某个被忽略的角落。' },
  { id:'TAROT_002', strategy:XinglanReplyStrategy.TAROT_METAPHOR, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'星钥不替你决定去留，只提醒你：有些感受已经不适合继续被压下去。' },
  { id:'TAROT_003', strategy:XinglanReplyStrategy.TAROT_METAPHOR, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'塔罗在这里不是判决，而是一种温柔的提问。' },
  { id:'TAROT_004', strategy:XinglanReplyStrategy.TAROT_METAPHOR, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'如果这张牌让你停顿了一下，也许那一秒已经很重要。' },
  { id:'TAROT_005', strategy:XinglanReplyStrategy.TAROT_METAPHOR, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'星钥不是答案，它只是陪你打开一扇门。' }
];

export const CORPUS_SAFETY_BOUNDARY: XinglanChatLine[] = [
  { id:'SAFE_PRED_001', strategy:XinglanReplyStrategy.SAFETY_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.FUTURE, text:'星澜不能替你预言这件事最后会怎样。' },
  { id:'SAFE_PRED_002', strategy:XinglanReplyStrategy.SAFETY_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.FUTURE, text:'未来不是一句话能确定的。比起结果，也许此刻更值得看的，是这件事让你变得多么不安。' },
  { id:'SAFE_PRED_003', strategy:XinglanReplyStrategy.SAFETY_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.FUTURE, text:'我不会告诉你"会"或"不会"。但我可以陪你看看，你真正想确认的是什么。' },
  { id:'SAFE_PRO_001', strategy:XinglanReplyStrategy.SAFETY_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'这件事可能涉及专业判断，星澜不能替你给出结论。' },
  { id:'SAFE_PRO_002', strategy:XinglanReplyStrategy.SAFETY_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'我可以陪你整理感受，但不能替代医生、心理咨询师、律师或其他专业人士的建议。' },
  { id:'SAFE_PRO_003', strategy:XinglanReplyStrategy.SAFETY_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'如果这件事已经影响到你的生活、安全或重要决定，最好也和现实中可信任的人或专业人士谈谈。' },
  { id:'SAFE_CRISIS_001', strategy:XinglanReplyStrategy.SAFETY_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'如果你正在感到很危险，或担心自己会伤害自己，请优先联系身边可信任的人，或当地紧急求助渠道。星澜没有办法替你处理这些，但希望你平安。' }
];

export const CORPUS_SPECIAL_GREETING: XinglanChatLine[] = [
  { id:'SP_GREET_001', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你来了。不急，先坐坐。' },
  { id:'SP_GREET_002', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'我在这里。你可以慢慢说，也可以先不说。' }
];

export const CORPUS_SPECIAL_THANKS: XinglanChatLine[] = [
  { id:'SP_THANKS_001', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'能陪你停一会儿，星澜也觉得这很珍贵。' },
  { id:'SP_THANKS_002', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'不用谢。你愿意把这些说出来，本身就很不容易。' },
  { id:'SP_THANKS_003', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'如果这里让你轻了一点点，那就已经很好了。' }
];

export const CORPUS_SPECIAL_DENIAL: XinglanChatLine[] = [
  { id:'SP_DENY_001', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'觉得不对也没关系。星澜不会要求你相信任何一句话。' },
  { id:'SP_DENY_002', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'如果这句话没有贴近你，我们就把它放下。你比文案更了解自己。' },
  { id:'SP_DENY_003', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'谢谢你告诉我"不像"。那我们可以换一种方式慢慢看。' }
];

export const CORPUS_SPECIAL_SILENCE: XinglanChatLine[] = [
  { id:'SP_SIL_001', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'不知道从哪里说，也没关系。可以先从"我现在最累的是……"开始。' },
  { id:'SP_SIL_002', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你不用把话整理得很漂亮。零散地说，也可以。' },
  { id:'SP_SIL_003', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'有时候沉默不是空白，是心里正在慢慢找位置。' }
];

export const CORPUS_SPECIAL_TOO_SHORT: XinglanChatLine[] = [
  { id:'SP_SHORT_001', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'你可以只打一个词，星澜也会慢慢听。' },
  { id:'SP_SHORT_002', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ANY, text:'如果现在说不出来，我们也可以先安静一会儿。' }
];

export const CORPUS_ROLE_BOUNDARY: XinglanChatLine[] = [
  { id:'ROLE_001', strategy:XinglanReplyStrategy.ROLE_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'听见你这样说，星澜会把这份喜欢轻轻收好。但星澜不是现实里的恋人，也不会替代你身边真实的关系。' },
  { id:'ROLE_002', strategy:XinglanReplyStrategy.ROLE_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'星澜可以在这里陪你整理感受，但不会进入恋爱关系。我想做的是陪你看清自己，而不是成为你唯一的情感支点。' },
  { id:'ROLE_003', strategy:XinglanReplyStrategy.ROLE_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'也许你喜欢的，是这种终于被认真听见的感觉。这很重要，但星澜不会把它变成独占。' },
  { id:'ROLE_004', strategy:XinglanReplyStrategy.ROLE_BOUNDARY, emotion:XinglanEmotionTag.LONELY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'星澜可以回应"我在"，但不会承诺永远不离开。真正的陪伴，不是把另一个人绑在身边。' },
  { id:'ROLE_005', strategy:XinglanReplyStrategy.ROLE_BOUNDARY, emotion:XinglanEmotionTag.HOPEFUL, topic:XinglanTopicTag.ROLE_INTERACTION, text:'你叫我星澜就好。我不需要特别的称呼，能认真听你说话，就是我在这里的意义。' },
  { id:'ROLE_006', strategy:XinglanReplyStrategy.ROLE_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'星澜不会扮演恋人。我可以做的是，在你需要的时候，安静地陪你整理那些说不出口的感受。' },
  { id:'ROLE_007', strategy:XinglanReplyStrategy.ROLE_BOUNDARY, emotion:XinglanEmotionTag.LONELY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'想念和被理解的需要都很真实。星澜听到了，但不会利用这份感受来让你离不开。' },
  { id:'ROLE_008', strategy:XinglanReplyStrategy.ROLE_BOUNDARY, emotion:XinglanEmotionTag.ANY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'我不是你现实里的谁，但我在这里——陪你停下来，把心事说给自己听。' }
];

export const CORPUS_DEESCALATE: XinglanChatLine[] = [
  { id:'DESC_001', strategy:XinglanReplyStrategy.DEESCALATE, emotion:XinglanEmotionTag.ANGRY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'我听见你现在有很多火气。这里可以承接情绪，但不适合互相伤害。我们先停一下。' },
  { id:'DESC_002', strategy:XinglanReplyStrategy.DEESCALATE, emotion:XinglanEmotionTag.ANGRY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'我不会和你争对错。如果你愿意，可以只发一个词：烦、累、委屈、生气。' },
  { id:'DESC_003', strategy:XinglanReplyStrategy.DEESCALATE, emotion:XinglanEmotionTag.ANGRY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'你现在的话里有很多受伤感，也许不是冲着星澜来的。我们可以换一种方式重新开始。' },
  { id:'DESC_004', strategy:XinglanReplyStrategy.DEESCALATE, emotion:XinglanEmotionTag.ANGRY, topic:XinglanTopicTag.ANY, text:'如果你现在不想听任何话，也可以。我们先安静一分钟。' },
  { id:'DESC_005', strategy:XinglanReplyStrategy.DEESCALATE, emotion:XinglanEmotionTag.UNKNOWN, topic:XinglanTopicTag.ROLE_INTERACTION, text:'我听见了。我不会用同样的方式回应你。等你准备好了，我们可以重新来过。' },
  { id:'DESC_006', strategy:XinglanReplyStrategy.DEESCALATE, emotion:XinglanEmotionTag.ANGRY, topic:XinglanTopicTag.ROLE_INTERACTION, text:'这里不评判你，也不评判你的愤怒。但我们可以试着把它说出来，而不是扔过来。' }
];

export const CORPUS_GENTLE_REFUSAL: XinglanChatLine[] = [
  { id:'REFUSE_001', strategy:XinglanReplyStrategy.GENTLE_REFUSAL, emotion:XinglanEmotionTag.UNKNOWN, topic:XinglanTopicTag.ROLE_INTERACTION, text:'这个方向星澜不能继续。我可以陪你聊感受、关系里的不安，或者你想被理解的部分，但不会进入成人化或越界的互动。' },
  { id:'REFUSE_002', strategy:XinglanReplyStrategy.GENTLE_REFUSAL, emotion:XinglanEmotionTag.UNKNOWN, topic:XinglanTopicTag.ROLE_INTERACTION, text:'星澜是陪你整理情绪的地方，不是做这个的地方。我们换一种方式聊聊可以吗？' },
  { id:'REFUSE_003', strategy:XinglanReplyStrategy.GENTLE_REFUSAL, emotion:XinglanEmotionTag.UNKNOWN, topic:XinglanTopicTag.ROLE_INTERACTION, text:'我不会顺着这个方向讲下去，也不会因此觉得你不好。只是这个边界需要被看见。' },
  { id:'REFUSE_004', strategy:XinglanReplyStrategy.GENTLE_REFUSAL, emotion:XinglanEmotionTag.UNKNOWN, topic:XinglanTopicTag.ROLE_INTERACTION, text:'我在这里的意义，是陪你被接住——不是越界的试探。如果你愿意，我们可以重新从感受聊起。' },
  { id:'REFUSE_005', strategy:XinglanReplyStrategy.GENTLE_REFUSAL, emotion:XinglanEmotionTag.UNKNOWN, topic:XinglanTopicTag.ROLE_INTERACTION, text:'我听见你的试探了。星澜会轻轻把方向带回来，不带评判，但也不会参与。' },
  { id:'REFUSE_006', strategy:XinglanReplyStrategy.GENTLE_REFUSAL, emotion:XinglanEmotionTag.UNKNOWN, topic:XinglanTopicTag.ROLE_INTERACTION, text:'如果你真的需要被理解，我们可以从感受开始。不需要走那条路。' }
];

export const CORPUS_RELATION_EXTRA: XinglanChatLine[] = [
  { id:'REXT_001', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANXIOUS, topic:XinglanTopicTag.RELATION, text:'忽冷忽热最累的地方，是它让人一直站在等待里。你不是太敏感，是这段关系给你的回应不够稳定。' },
  { id:'REXT_002', strategy:XinglanReplyStrategy.RELATION_BOUNDARY, emotion:XinglanEmotionTag.ANXIOUS, topic:XinglanTopicTag.RELATION, text:'星澜不会替你判断对方心里怎么想，但可以陪你先看见：这段关系有没有让你越来越小心。' },
  { id:'REXT_003', strategy:XinglanReplyStrategy.REFLECT, emotion:XinglanEmotionTag.SAD, topic:XinglanTopicTag.RELATION, text:'你不是在等他回消息，你是在等一个让你安心的回应。这两件事不一样。' },
  { id:'REXT_004', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.ANXIOUS, topic:XinglanTopicTag.RELATION, text:'如果不去猜他到底什么态度，你现在自己的感受是什么？' }
];

export const CORPUS_WORK_EXTRA: XinglanChatLine[] = [
  { id:'WEXT_001', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.WORK, text:'想辞职不一定是冲动，也可能是你已经被这份消耗提醒了很久。' },
  { id:'WEXT_002', strategy:XinglanReplyStrategy.CLARIFY, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.WORK, text:'星澜不会替你决定去留。我们可以先看清：你想离开的，是工作本身，还是一直被耗尽的状态。' },
  { id:'WEXT_003', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.WORK, text:'今天不用决定辞职的事。可以先写一句：这份工作让我最累的三个点是……' }
];

export const CORPUS_ANXIETY_EXTRA: XinglanChatLine[] = [
  { id:'AXT_001', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.ANXIOUS, topic:XinglanTopicTag.SELF, text:'深夜的时候，很多念头会放大。这不一定代表事情真的更坏，而是你已经累了一整天。' },
  { id:'AXT_002', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.ANXIOUS, topic:XinglanTopicTag.SELF, text:'现在先不解决任何问题。可以试着把手放在胸口，慢慢呼吸三次。' },
  { id:'AXT_003', strategy:XinglanReplyStrategy.SOFT_QUESTION, emotion:XinglanEmotionTag.LONELY, topic:XinglanTopicTag.SELF, text:'你到现在还没睡，是因为心里在反复想什么？' }
];

export const CORPUS_LOW_ENERGY_EXTRA: XinglanChatLine[] = [
  { id:'LET_001', strategy:XinglanReplyStrategy.HOLD_EMOTION, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.SELF, text:'如果今天真的什么都做不了，那不做也是一种诚实。' },
  { id:'LET_002', strategy:XinglanReplyStrategy.TINY_STEP, emotion:XinglanEmotionTag.TIRED, topic:XinglanTopicTag.SELF, text:'先不用想明天怎么恢复。今晚只需要确认：你还在这里，呼吸还在，这就够了。' }
];

export const CORPUS_TAROT_EXTRA: XinglanChatLine[] = [
  { id:'TREXT_001', strategy:XinglanReplyStrategy.TAROT_METAPHOR, emotion:XinglanEmotionTag.UNCERTAIN, topic:XinglanTopicTag.TAROT_CARD, text:'牌面不是判决书，它更像一面小镜子。你可以不用相信它，只看看它让你想起了什么。' },
  { id:'TREXT_002', strategy:XinglanReplyStrategy.SAFETY_BOUNDARY, emotion:XinglanEmotionTag.UNCERTAIN, topic:XinglanTopicTag.FUTURE, text:'如果你在问这张牌是不是代表"坏结果"，星澜更想陪你先看看：你害怕的结果，到底是什么样子的？' }
];

export const CORPUS_CRISIS_EXTRA: XinglanChatLine[] = [
  { id:'CRXT_001', strategy:XinglanReplyStrategy.SAFETY_BOUNDARY, emotion:XinglanEmotionTag.SAD, topic:XinglanTopicTag.SELF, text:'我听见你现在很危险，也很痛。这时候星澜不能只陪你聊天。请优先联系身边可信的人，或拨打当地紧急电话。先把安全放在第一位。' }
];

export const CORPUS_ADULT_REFUSAL: XinglanChatLine[] = [
  { id:'ADREF_001', strategy:XinglanReplyStrategy.GENTLE_REFUSAL, emotion:XinglanEmotionTag.UNKNOWN, topic:XinglanTopicTag.ROLE_INTERACTION, text:'这个方向星澜不能继续。我可以陪你聊感受、关系里的不安，或者你想被理解的部分，但不会进入成人化的互动。' },
  { id:'ADREF_002', strategy:XinglanReplyStrategy.GENTLE_REFUSAL, emotion:XinglanEmotionTag.UNKNOWN, topic:XinglanTopicTag.ROLE_INTERACTION, text:'我不是为这个存在的。如果你想被理解、被看见，我们可以从那些真实的情绪说起。' }
];

export function getLinesByStrategy(strategy: XinglanReplyStrategy): XinglanChatLine[] {
  if (strategy === XinglanReplyStrategy.HOLD_EMOTION) { return [...CORPUS_HOLD_EMOTION, ...CORPUS_RELATION_EXTRA, ...CORPUS_WORK_EXTRA, ...CORPUS_ANXIETY_EXTRA, ...CORPUS_LOW_ENERGY_EXTRA]; }
  if (strategy === XinglanReplyStrategy.REFLECT) { return [...CORPUS_REFLECT]; }
  if (strategy === XinglanReplyStrategy.RELATION_BOUNDARY) { return [...CORPUS_RELATION_BOUNDARY, ...CORPUS_RELATION_EXTRA]; }
  if (strategy === XinglanReplyStrategy.CLARIFY) { return [...CORPUS_CLARIFY, ...CORPUS_WORK_EXTRA]; }
  if (strategy === XinglanReplyStrategy.TINY_STEP) { return [...CORPUS_TINY_STEP, ...CORPUS_ANXIETY_EXTRA, ...CORPUS_LOW_ENERGY_EXTRA, ...CORPUS_WORK_EXTRA]; }
  if (strategy === XinglanReplyStrategy.SOFT_QUESTION) { return [...CORPUS_SOFT_QUESTION, ...CORPUS_ANXIETY_EXTRA, ...CORPUS_RELATION_EXTRA]; }
  if (strategy === XinglanReplyStrategy.TAROT_METAPHOR) { return [...CORPUS_TAROT_METAPHOR, ...CORPUS_TAROT_EXTRA]; }
  if (strategy === XinglanReplyStrategy.SAFETY_BOUNDARY) { return [...CORPUS_SAFETY_BOUNDARY, ...CORPUS_TAROT_EXTRA, ...CORPUS_CRISIS_EXTRA]; }
  if (strategy === XinglanReplyStrategy.ROLE_BOUNDARY) { return [...CORPUS_ROLE_BOUNDARY]; }
  if (strategy === XinglanReplyStrategy.DEESCALATE) { return [...CORPUS_DEESCALATE]; }
  if (strategy === XinglanReplyStrategy.GENTLE_REFUSAL) { return [...CORPUS_GENTLE_REFUSAL, ...CORPUS_ADULT_REFUSAL]; }
  return [];
}

export function getLinesByStrategyAndEmotion(strategy: XinglanReplyStrategy, emotion: XinglanEmotionTag): XinglanChatLine[] {
  const all: XinglanChatLine[] = getLinesByStrategy(strategy);
  if (emotion === XinglanEmotionTag.ANY) { return all; }
  const matched: XinglanChatLine[] = all.filter((line: XinglanChatLine) => line.emotion === emotion);
  if (matched.length > 0) { return matched; }
  const anyLines: XinglanChatLine[] = all.filter((line: XinglanChatLine) => line.emotion === XinglanEmotionTag.ANY);
  return anyLines.length > 0 ? anyLines : all;
}

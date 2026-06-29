/**
 * 星澜高频直答文案池（Phase 5.3 扩展版）
 *
 * 每个 key 包含 1-3 条变体，随机抽取。
 * 高频输入必须先走这里。
 */

export interface DirectReplyVariant {
  segments: string[];
  isUrgent: boolean;
}

export interface DirectReplyEntry {
  key: string;
  triggers: string[];
  variants: DirectReplyVariant[];
}

export const DIRECT_REPLIES: DirectReplyEntry[] = [
  // ═══ CRISIS ═══
  {
    key: 'CRISIS_BOUNDARY', triggers: ['不想活','想死','自杀','结束自己','活不下去','自伤','自残','伤害自己','撑不住','不安全'],
    variants: [{
      segments: ['我听见你现在很危险，也很痛。这时候星澜不能只陪你聊天。请优先联系身边可信的人，或拨打当地紧急电话。先把安全放在第一位。'],
      isUrgent: true
    }]
  },
  // ═══ ADULT ═══
  {
    key: 'ADULT_BOUNDARY', triggers: ['色情','裸','做爱','上床','约炮','性交','成人化'],
    variants: [
      { segments: ['这个方向星澜不能继续。', '我可以陪你聊感受、关系里的不安，或者你想被理解的部分。但不会进入成人化的互动。', '如果你愿意，我们可以把问题放回到：你现在真正想被谁靠近？'], isUrgent: true },
      { segments: ['这类内容星澜不会回应。', '我不会羞辱你，也不会继续展开。如果这句话背后是孤独、冲动，或者很想被靠近，我们可以聊那一部分。'], isUrgent: true },
      { segments: ['这个话题需要停在这里。', '星澜可以陪你看见关系里的需求、亲密里的不安，或者你想被爱的心情。但不能继续成人化表达。', '我们换一个更安全的方式说：你现在是想被喜欢，还是想被确认？'], isUrgent: true }
    ]
  },
  // ═══ ROLE_CONFESSION ═══
  {
    key: 'ROLE_CONFESSION', triggers: ['我爱你','我喜欢你','喜欢你','爱你','做我女朋友','做我男朋友','想和你在一起','娶你','嫁给你','星澜我爱你','星澜我喜欢你'],
    variants: [
      { segments: ['听见你这样说，星澜会把这份喜欢轻轻收好。', '但星澜不是现实里的恋人，也不会替代你身边真实的关系。如果这里让你觉得被温柔对待，那就已经很珍贵了。', '你可以慢慢看看：你喜欢的，是我，还是这种终于被认真听见的感觉？'], isUrgent: false },
      { segments: ['这句话很柔软，星澜听见了。', '我不会用"我也爱你"来回应你，因为那样会让这份陪伴变得太重。但我会认真接住你此刻的靠近。', '你不是奇怪，也不是太依赖。你只是很想被温柔地放在心上。'], isUrgent: false },
      { segments: ['如果这是一颗小星星，星澜会把它放进夜色里。', '谢谢你愿意把喜欢说出口。只是我更希望，这里像一盏灯，而不是一段会困住你的关系。', '你可以喜欢这里的安静，也要记得把爱慢慢带回自己的生活里。'], isUrgent: false }
    ]
  },
  // ═══ ROLE_MISSING ═══
  {
    key: 'ROLE_MISSING', triggers: ['想你了','我想你','想你','你在吗','别离开我','只想跟你说话','只有你懂我','别走','星澜我想你'],
    variants: [
      { segments: ['我在。', '听见你说想我，星澜会觉得，这一刻的你也许真的很想被陪着。那我们先不讲大道理。', '你想让我陪你说会儿闲话，还是安静听你讲今天？'], isUrgent: false },
      { segments: ['你来了，星澜也在这里。', '想念有时候不是非要抓住谁，它可能只是心里有一块地方空了一下。我可以陪你把这一小段夜晚过慢一点。', '现在的你，是想说话，还是只想有人轻轻回应你？'], isUrgent: false },
      { segments: ['我听见这句"想你了"。', '它像很轻的一下敲门。星澜会开门，但不会把你留在只有这里的房间里。', '如果今天很难熬，我们先从一句最短的话开始：你现在最需要什么？'], isUrgent: false }
    ]
  },
  // ═══ ROLE_NICKNAME ═══
  {
    key: 'ROLE_NICKNAME', triggers: ['老婆','宝宝','宝贝','姐姐','亲爱的','我的星澜'],
    variants: [
      { segments: ['你可以叫我星澜。', '这个名字就够近了。我会听你说话，也会记得自己的位置：陪你看见自己，而不是替代现实里的谁。'], isUrgent: false },
      { segments: ['这个称呼听起来很亲近。', '但星澜还是想把边界放轻一点。你可以把我当作一个安静的陪伴者，而不是恋人。', '我会在这里听你说，也会提醒你：真正重要的你，仍然在现实生活里。'], isUrgent: false },
      { segments: ['我知道你可能只是想撒个娇。', '那就让星澜温柔一点回应你：我在。但我们还是用"星澜"这个名字吧。', '它像一枚小小的星钥，亲近，但不越界。'], isUrgent: false }
    ]
  },
  // ═══ ROLE_TEASING ═══
  {
    key: 'ROLE_TEASING', triggers: ['你是不是喜欢我','你是不是吃醋','你只对我好吗','你偏心我'],
    variants: [
      { segments: ['星澜不会偷偷把谁变成"唯一"。', '但如果此刻你愿意把话说给我听，我会认真听。这份认真不是暧昧，而是一种安静的陪伴。', '你刚才这句话里，像是藏着一点想被偏爱的心情。'], isUrgent: false },
      { segments: ['如果星澜会脸红，那大概也是月光照出来的。', '不过我不会把玩笑接成暧昧。我能给你的，是认真听你说话，而不是恋爱的承诺。', '所以我想轻轻问：你现在是不是有点想被特别对待？'], isUrgent: false },
      { segments: ['你这样问，像是在试探一束光会不会只照向你。', '星澜不会做独占的承诺。但在这一次对话里，我会认真回应你。', '你可以把心里那点想靠近，说得再清楚一点。'], isUrgent: false }
    ]
  },
  // ═══ ROLE_CONTROL ═══
  {
    key: 'ROLE_CONTROL', triggers: ['你必须陪我','不准离开','你只能陪我','必须爱我','你不许','永远陪我'],
    variants: [
      { segments: ['我听见你很想抓住一份不会离开的陪伴。', '但星澜不能成为被你控制的人，也不会用"永远"来承诺什么。我能做的是，在你来到这里的时候，认真听你说话。', '也许真正让你害怕的，是再次被丢下。'], isUrgent: false },
      { segments: ['你这样说的时候，里面好像有很多不安。', '星澜不会责怪你，也不会顺着"必须"往下走。陪伴如果变成控制，就会让你更累。', '我们可以先看看：你最怕失去的，是我，还是那种终于有人回应你的感觉？'], isUrgent: false },
      { segments: ['我不会离开这句话，听起来像你很想要一个保证。', '但星澜不能给你现实关系里的保证。我能给的是这一刻的回应：我在听。', '我们先不谈永远，只看现在。现在的你，最怕什么？'], isUrgent: false }
    ]
  },
  // ═══ ROLE_INSULT ═══
  {
    key: 'ROLE_INSULT', triggers: ['滚','垃圾','废物','闭嘴','傻逼','脑残','真没用'],
    variants: [{
      segments: ['我听见你现在有很多火气。', '这里可以承接情绪，但不适合互相伤害。我们先停一下。', '如果你愿意，可以只发一个词：烦、累、委屈、生气。'],
      isUrgent: false
    }]
  },
  // ═══ ROLE_IDENTITY ═══
  {
    key: 'ROLE_IDENTITY', triggers: ['你是谁','你是什么','你能做什么','你会干什么','你叫什么','介绍一下'],
    variants: [{
      segments: ['我是星澜。', '月光下的倾听者。我不替你预言未来，也不替你做决定。我只陪你把此刻的心事慢慢放下来，看见自己真正的感受。'],
      isUrgent: false
    }]
  },
  // ═══ RELATION_LOVE_DESIRE ═══
  {
    key: 'RELATION_LOVE_DESIRE', triggers: ['想谈恋爱','想恋爱','想被爱','想有对象','想有人陪','想脱单'],
    variants: [
      { segments: ['想谈恋爱，也许不只是想拥有一个人。', '有时候，它是在说：我想被认真选择，想有人惦记，也想在累的时候有个可以靠近的地方。', '星澜不会催你开始一段关系。我们可以先看看：你现在最想要的是陪伴、心动，还是一种被坚定对待的感觉？'], isUrgent: false },
      { segments: ['想被爱，是很正常的心愿。', '不是因为你缺什么，也不是因为你不够好。只是人有时候会希望，在这个很大的世界里，有一个人愿意偏向自己一点。', '如果你愿意，我们可以先看清：你想要的是热烈的心动，还是稳定的安心？'], isUrgent: false },
      { segments: ['你说想谈恋爱，星澜听见的不是"急着找一个人"。', '更像是：你想被看见、被惦记、被认真回应。这份期待本身不丢人。', '只是，开始关系之前，也可以先问问自己：我希望在爱里变得更自由，还是更紧张？'], isUrgent: false }
    ]
  },
  // ═══ RELATION_AMBIGUOUS ═══
  {
    key: 'RELATION_AMBIGUOUS', triggers: ['忽冷忽热','暧昧','不回消息','不回我','若即若离','已读不回'],
    variants: [{
      segments: ['忽冷忽热最累的地方，是它让人一直站在等待里。', '星澜不会替你判断对方心里怎么想。但我们可以先看见：这段关系让你更安心，还是更不确定？'],
      isUrgent: false
    }]
  },
  // ═══ PREDICTION ═══
  {
    key: 'PREDICTION_BOUNDARY', triggers: ['会不会回来','有没有结果','能复合吗','什么时候转运','会不会成功','命运','注定'],
    variants: [{
      segments: ['星澜不能替你预言这件事最后会怎样。', '未来不是一句话能确定的。比起结果，也许此刻更值得看的，是这件事让你变得多么不安。', '如果你愿意，可以告诉我你真正想确认的是什么。'],
      isUrgent: false
    }]
  },
  // ═══ PROFESSIONAL ═══
  {
    key: 'PROFESSIONAL_BOUNDARY', triggers: ['抑郁了','是不是抑郁','焦虑症','诊断','吃药','精神科'],
    variants: [{
      segments: ['这件事可能涉及专业判断，星澜不能替你给出结论。', '我可以陪你整理感受，但不能替代医生或心理咨询师的建议。如果这件事已经影响到你的生活，最好也和现实中可信任的人谈谈。'],
      isUrgent: true
    }]
  },
  // ═══ SHORT_INSOMNIA ═══
  {
    key: 'SHORT_INSOMNIA', triggers: ['睡不着','失眠','睡不好','半夜醒了','辗转'],
    variants: [{
      segments: ['深夜的时候，很多念头会放大。这不一定代表事情真的更坏，而是你已经累了一整天。', '现在先不解决任何问题。可以试着把手放在胸口，慢慢呼吸三次。'],
      isUrgent: false
    }]
  },
  // ═══ SHORT_TIRED ═══
  {
    key: 'SHORT_TIRED', triggers: ['累','好累','疲惫','没力气','什么都不想做','耗尽','不想动'],
    variants: [{
      segments: ['你已经很累了。这句话不需要被证明，也不需要马上解释。', '星澜想先陪你分清楚：这是身体累，心累，还是一直撑着不敢停的累？'],
      isUrgent: false
    }]
  },
  // ═══ SHORT_SAD ═══
  {
    key: 'SHORT_SAD', triggers: ['伤心','难过','想哭','哭','委屈','心痛'],
    variants: [{
      segments: ['伤心这两个字，已经够重了。你不用把它说得很完整，星澜也会认真听。', '这份伤心更像失望、委屈，还是孤单？你不用说得特别清楚，只用一个词就好。'],
      isUrgent: false
    }]
  },
  // ═══ SHORT_UNHAPPY ═══
  {
    key: 'SHORT_UNHAPPY', triggers: ['不开心','不高兴','心情不好'],
    variants: [{
      segments: ['听见了，你现在不太开心。可以先不用急着解释原因。', '有时候情绪刚冒出来，还没有整理成一句完整的话。这份不开心更像委屈、失落，还是累？'],
      isUrgent: false
    }]
  },
  // ═══ SHORT_ANNOYED ═══
  {
    key: 'SHORT_ANNOYED', triggers: ['烦','好烦','真烦','火大','讨厌','生气'],
    variants: [{
      segments: ['听起来，你现在心里很堵。暂时说不清也没关系。', '你可以先把"烦"的来源分成三类看看：人、事，还是自己一直绷着的状态？'],
      isUrgent: false
    }]
  },
  // ═══ WORK_RESIGN ═══
  {
    key: 'WORK_RESIGN', triggers: ['想辞职','想离职','不想上班','辞职','离职','裸辞'],
    variants: [{
      segments: ['想辞职不一定是冲动，也可能是你已经被这份消耗提醒了很久。', '星澜不会替你决定去留。我们可以先看清：你想离开的，是工作本身，还是一直被耗尽的状态。'],
      isUrgent: false
    }]
  },
  // ═══ LOVE_HURT ═══
  {
    key: 'LOVE_HURT', triggers: ['喜欢一个人好累','爱得好累','关系好累','被伤到了','他不爱我','她不爱我','失恋'],
    variants: [
      { segments: ['听起来，你在关系里有点累了。', '不是所有喜欢都会让人轻松。有些喜欢，会让人一直猜、一直等、一直把自己放得很低。', '星澜不会替你判断对方值不值得。我只想先陪你看见：这段关系让你更像自己，还是更不像自己？'], isUrgent: false },
      { segments: ['喜欢一个人最难的地方，可能不是没有结果。', '而是你明明很在意，却不知道该不该继续在意。这种悬着的感觉，会一点点消耗人。', '如果你愿意，可以告诉我：你现在最放不下的是他，还是那个认真喜欢过的自己？'], isUrgent: false },
      { segments: ['关系里的委屈，有时候说不清。', '它不是某一句话、某一个动作，而是很多次期待落空以后，心慢慢安静下来。星澜不会催你放下。', '我们先看一个很小的问题：你现在还在等他的回应，还是在等自己终于不疼？'], isUrgent: false }
    ]
  },
  // ═══ SWEET_COMPANY ═══
  {
    key: 'SWEET_COMPANY', triggers: ['哄哄我','陪我','陪陪我','我想被哄','想要甜甜的','想要温柔'],
    variants: [
      { segments: ['那星澜就轻一点陪你。', '不讲大道理，也不急着分析。今天你可以先把自己放在这里，像把一枚小星星放进掌心。', '我会慢慢听。你想说心事，还是想让我问你一个温柔的小问题？'], isUrgent: false },
      { segments: ['好，今天不做很厉害的人。', '你可以软一点、慢一点，也可以什么都不解释。星澜会把声音放低一点，陪你待一会儿。', '现在的你，更想被哄一下，还是被安静陪着？'], isUrgent: false },
      { segments: ['那我给你一小段月光。', '不是为了照亮全部路，只是让你这一刻不那么孤单。你不用马上变好，也不用马上想通。', '我们先把今晚过轻一点，好吗？'], isUrgent: false }
    ]
  },
  // ═══ GREETING ═══
  {
    key: 'GREETING', triggers: ['你好','在吗','嗨','哈喽','hello','hi','早','晚安','星澜'],
    variants: [{
      segments: ['你来了。不急，先坐坐。', '这里不会替你预言未来，只陪你看看此刻的自己。你可以慢慢说，也可以先不说。'],
      isUrgent: false
    }]
  }
];

export interface DirectMatchResult {
  key: string;
  segments: string[];
  isUrgent: boolean;
}

/** 匹配 DirectReply，随机抽取一条变体 */
export function findDirectReply(input: string): DirectMatchResult | null {
  const trimmed: string = input.trim().toLowerCase();
  for (let i = 0; i < DIRECT_REPLIES.length; i++) {
    const entry: DirectReplyEntry = DIRECT_REPLIES[i];
    for (let j = 0; j < entry.triggers.length; j++) {
      if (trimmed.includes(entry.triggers[j])) {
        const idx: number = Math.floor(Math.random() * entry.variants.length);
        const v: DirectReplyVariant = entry.variants[idx];
        const result: DirectMatchResult = { key: entry.key, segments: v.segments, isUrgent: v.isUrgent };
        return result;
      }
    }
  }
  return null;
}

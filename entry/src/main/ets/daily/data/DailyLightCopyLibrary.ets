import { DailyDirection } from '../model/DailyDirection';
import { DailyLightContent } from '../model/DailyLightContent';

/**
 * 今日星页本地审核文案库
 *
 * 所有文案均为本地离线内容，不联网、不调用模型、不做运势判断。
 * 首发 8 个方向，每个方向 8 条完整内容，共 64 条。
 * 每方向 warmth 覆盖 1/3/5，suggestionStrength 覆盖 1/2/3。
 */
export const DAILY_LIGHT_LIBRARY: DailyLightContent[] = [
  // ==================== 今天想对自己温柔一点 ====================
  {
    id: 'gentle_01',
    direction: DailyDirection.GENTLE,
    mainLine: '今天不必一直表现得很好。',
    observation: '当你又一次对自己说"应该更好"时，先停一下，看看这句话来自哪里。',
    microAction: '用对待朋友的语气，对自己说一句话。',
    pocketLight: '今天不必证明自己，也可以好好存在。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'gentle_02',
    direction: DailyDirection.GENTLE,
    mainLine: '先把对自己的要求放轻一点。',
    observation: '留意今天有没有哪一刻，你对自己的批评比对别人的更严厉。',
    microAction: '做一件小事，只为让自己舒服一点，而不是为了完成。',
    pocketLight: '放轻一点，不是放弃，是给肩膀松一松。',
    warmth: 5,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'gentle_03',
    direction: DailyDirection.GENTLE,
    mainLine: '疲惫的时候，慢一点也算前进。',
    observation: '当你觉得"效率太低"时，也许今天的你本来就需要一段缓冲。',
    microAction: '允许自己先休息五分钟，再决定下一步。',
    pocketLight: '慢一点不是落后，是你正在照顾自己。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'gentle_04',
    direction: DailyDirection.GENTLE,
    mainLine: '今天可以少批评自己一次。',
    observation: '注意今天第一个冒出来的自我否定的声音，然后选择不跟它走。',
    microAction: '写下一句你最近对自己太苛刻的话，把它改成温和的版本。',
    pocketLight: '你对自己少一点苛责，世界并不会因此塌下来。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'gentle_05',
    direction: DailyDirection.GENTLE,
    mainLine: '不够完美，也仍然值得被认真对待。',
    observation: '当你想等到"准备好了"再开始时，也许已经够了。',
    microAction: '做一件你一直在等"完美时机"的事，只开个头就好。',
    pocketLight: '不用等到完美，现在的你就可以被温柔接住。',
    warmth: 5,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'gentle_06',
    direction: DailyDirection.GENTLE,
    mainLine: '今天可以少扛一点。',
    observation: '当你觉得"必须撑住"时，也许正是什么都已经太重了。',
    microAction: '把今天的一件事挪到明天，不需要理由。',
    pocketLight: '少扛一点，不是逃避，是承认自己有极限。',
    warmth: 1,
    suggestionStrength: 3,
    sensitive: false
  },
  {
    id: 'gentle_07',
    direction: DailyDirection.GENTLE,
    mainLine: '对自己温柔，不是放松要求，是换个语气。',
    observation: '留意今天对自己说话的语气，是否比对任何人都严厉。',
    microAction: '把一句自我批评，改写成对朋友会说的话。',
    pocketLight: '温柔不是降低标准，是给自己一个能站稳的位置。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'gentle_08',
    direction: DailyDirection.GENTLE,
    mainLine: '今天不必回答任何关于自己的问题。',
    observation: '当内心一直在追问"我到底怎么了"时，也许可以先停下来。',
    microAction: '今天不分析自己，只做一件让身体舒服的事。',
    pocketLight: '不追问，也是一种温柔。',
    warmth: 1,
    suggestionStrength: 1,
    sensitive: false
  },

  // ==================== 把注意力收回来 ====================
  {
    id: 'attention_01',
    direction: DailyDirection.ATTENTION,
    mainLine: '先别急着猜别人怎么想。',
    observation: '当你开始猜测别人时，先看看已经发生的真实行为。',
    microAction: '把一件你正在猜测的事，分成"已知"和"想象"两列。',
    pocketLight: '把注意力放回自己能确认的部分，心里会安静一些。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'attention_02',
    direction: DailyDirection.ATTENTION,
    mainLine: '把注意力放回你能确认的事实。',
    observation: '今天有没有哪一刻，你因为过度注意别人而忽略了自己的反应？',
    microAction: '选一件小事，只做你能控制的那部分，其余先放一放。',
    pocketLight: '外面的事情再乱，你也能先把注意力收回自己身上。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'attention_03',
    direction: DailyDirection.ATTENTION,
    mainLine: '今天先照顾你能控制的那一部分。',
    observation: '当你感到失控时，往往是因为注意力落在了不可控的事情上。',
    microAction: '列出三件你能控制的小事，先做其中一件。',
    pocketLight: '控制不了全局，也可以先稳住自己能握住的一小步。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'attention_04',
    direction: DailyDirection.ATTENTION,
    mainLine: '别人的反应，不需要占满你的一整天。',
    observation: '留意今天你是否把别人的情绪，放在了自己的情绪前面。',
    microAction: '设置一个"只关注自己"的小时段，哪怕只有十分钟。',
    pocketLight: '别人的反应是别人的，你的心可以留一些给自己。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'attention_05',
    direction: DailyDirection.ATTENTION,
    mainLine: '先听听自己的感受，再看外面的声音。',
    observation: '当你被很多建议包围时，自己内心的声音可能变得很小。',
    microAction: '在做决定前，先问自己：我真正在意的是什么？',
    pocketLight: '外界的声音可以参考，但你的感受也值得先听见。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'attention_06',
    direction: DailyDirection.ATTENTION,
    mainLine: '今天可以先不看别人。',
    observation: '当你反复查看别人的反应时，注意力已经不在自己身上了。',
    microAction: '关闭一个常用来观察别人的入口，只一个小时。',
    pocketLight: '不看别人，不是冷漠，是把眼睛还给自己。',
    warmth: 1,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'attention_07',
    direction: DailyDirection.ATTENTION,
    mainLine: '你此刻的感受，值得被放在最前面。',
    observation: '今天有没有哪一刻，你把自己的感受排在了所有人的后面？',
    microAction: '在下次开口前，先问自己一句：我愿意吗？',
    pocketLight: '把自己放在前面，不是自私，是不再把自己弄丢。',
    warmth: 5,
    suggestionStrength: 3,
    sensitive: false
  },
  {
    id: 'attention_08',
    direction: DailyDirection.ATTENTION,
    mainLine: '外面的事可以晚一点再处理。',
    observation: '当你急着回应所有事时，也许只是害怕被落下。',
    microAction: '选一条未读消息，今天不回，明天再说。',
    pocketLight: '晚一点回应，世界并不会因此忘记你。',
    warmth: 1,
    suggestionStrength: 3,
    sensitive: false
  },

  // ==================== 少追问一点结果 ====================
  {
    id: 'less_result_01',
    direction: DailyDirection.LESS_RESULT,
    mainLine: '今天不必把所有事情都想清楚。',
    observation: '当你再次催促自己时，留意一下：这件事真的需要现在完成吗？',
    microAction: '把今天最重要的一件事，缩小成一个十分钟内可以开始的动作。',
    pocketLight: '不必想清楚全部，先走好眼前能走的那一步。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'less_result_02',
    direction: DailyDirection.LESS_RESULT,
    mainLine: '答案没有出现时，也可以先过好眼前这一段。',
    observation: '不确定是否让你一直停在"必须解决"的状态里？',
    microAction: '给自己一段不找答案的时间，只做一件小事。',
    pocketLight: '答案会来，但不是此刻必须完成的任务。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'less_result_03',
    direction: DailyDirection.LESS_RESULT,
    mainLine: '不确定不等于坏结果。',
    observation: '当你把"不确定"自动翻译成"会不好"时，试着把它换成"还在展开"。',
    microAction: '写下三件你目前不确定的事，不为找答案，只为看见它们。',
    pocketLight: '不确定本身不可怕，它只是在提醒你事情还在发生。',
    warmth: 3,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'less_result_04',
    direction: DailyDirection.LESS_RESULT,
    mainLine: '可以先停在还不知道的位置。',
    observation: '你是否有把"不知道"当作"失败"的习惯？',
    microAction: '对一件还不知道的事说一句："我现在还不知道，这没关系。"',
    pocketLight: '停在不知道的位置，也是在尊重事情本来的节奏。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'less_result_05',
    direction: DailyDirection.LESS_RESULT,
    mainLine: '有些事情适合观察，不适合催促。',
    observation: '当你想加速某件事时，留意它是否正在自己慢慢变化。',
    microAction: '选一件正在进展中的事，今天只做观察者，不施加推力。',
    pocketLight: '不是所有事情都需要加速，有些答案会在你不再催促时出现。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'less_result_06',
    direction: DailyDirection.LESS_RESULT,
    mainLine: '今天可以不知道。',
    observation: '当你拼命想搞清楚时，也许"不知道"本身就是当下的答案。',
    microAction: '对一件还无解的事说一句：我现在不知道，先放着。',
    pocketLight: '不知道不是失败，是事情还在展开。',
    warmth: 1,
    suggestionStrength: 3,
    sensitive: false
  },
  {
    id: 'less_result_07',
    direction: DailyDirection.LESS_RESULT,
    mainLine: '有些事慢慢会清楚，不必今天就逼出答案。',
    observation: '你是否把"还没想清楚"当成了一种拖延，并为此自责？',
    microAction: '把一件悬而未决的事写下来，旁边写：暂时不需要答案。',
    pocketLight: '允许事情慢慢清楚，也是对自己的一种耐心。',
    warmth: 5,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'less_result_08',
    direction: DailyDirection.LESS_RESULT,
    mainLine: '今天不必检查自己有没有进展。',
    observation: '反复确认进度，往往不会让事情更快，只会让人更累。',
    microAction: '今天不打开任何进度追踪，只做眼前的一步。',
    pocketLight: '不检查进展，不代表没有在走。',
    warmth: 1,
    suggestionStrength: 1,
    sensitive: false
  },

  // ==================== 给自己留一点空白 ====================
  {
    id: 'blank_01',
    direction: DailyDirection.BLANK,
    mainLine: '今天不需要把每一分钟都填满。',
    observation: '空下来的时间里，你常常感到焦虑还是轻松？',
    microAction: '故意留一段没有计划的时间，允许它什么都不发生。',
    pocketLight: '空白不是浪费，是给你留一点呼吸的缝隙。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'blank_02',
    direction: DailyDirection.BLANK,
    mainLine: '空下来，不等于浪费时间。',
    observation: '当你休息时会否产生内疚感？这往往来自"必须有用"的声音。',
    microAction: '做一次没有目的的休息，比如发呆或看一会儿天。',
    pocketLight: '真正的休息不需要被批准，它本身就是一种需要。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'blank_03',
    direction: DailyDirection.BLANK,
    mainLine: '先留一点位置给呼吸和停顿。',
    observation: '今天有没有哪一刻，你因为赶时间而忘记了呼吸的深浅？',
    microAction: '在三个时间点停下来，做三次深呼吸。',
    pocketLight: '呼吸和停顿，是今天最容易被忽略的小事。',
    warmth: 3,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'blank_04',
    direction: DailyDirection.BLANK,
    mainLine: '不处理事情的时候，你也仍然有价值。',
    observation: '你的价值是否常常被"完成度"来衡量？',
    microAction: '今天不做任何"有用"的事，只是存在一会儿。',
    pocketLight: '你不必一直产出，你的存在本身就足够。',
    warmth: 5,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'blank_05',
    direction: DailyDirection.BLANK,
    mainLine: '让今天有一小段不需要完成什么的时间。',
    observation: '当你没有目标时，会不会感到不安？',
    microAction: '安排十分钟，不带任何任务地坐着或走动。',
    pocketLight: '不需要完成什么的时间，也是生活的一部分。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'blank_06',
    direction: DailyDirection.BLANK,
    mainLine: '今天可以什么都不做。',
    observation: '当你觉得"必须做点什么"时，也许正是最需要停下的信号。',
    microAction: '留一段完全空白的时间，不做任何事，不解释。',
    pocketLight: '什么都不做，也是今天的一种完成。',
    warmth: 1,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'blank_07',
    direction: DailyDirection.BLANK,
    mainLine: '空白里藏着今天没有说出口的疲惫。',
    observation: '当你终于停下来时，疲惫才敢浮上来——这不是脆弱，是身体在说话。',
    microAction: '留五分钟，只是感受疲惫，不急着赶走它。',
    pocketLight: '疲惫被看见，比被赶走更重要。',
    warmth: 3,
    suggestionStrength: 3,
    sensitive: false
  },
  {
    id: 'blank_08',
    direction: DailyDirection.BLANK,
    mainLine: '留一点空白，给今天还没发生的可能。',
    observation: '当你把时间填满时，也许同时关上了某些自然会出现的东西。',
    microAction: '今天留一段不安排的时间，看看会发生什么。',
    pocketLight: '空白不是空，是给可能留位置。',
    warmth: 2,
    suggestionStrength: 2,
    sensitive: false
  },

  // ==================== 把一件事慢慢做好 ====================
  {
    id: 'slow_01',
    direction: DailyDirection.SLOW,
    mainLine: '慢下来，不等于做得差。',
    observation: '当你追求速度时，有没有忽略事情本身的质感？',
    microAction: '选一件今天要做的事，比平时慢一倍完成。',
    pocketLight: '慢是一种节奏，不是一种错误。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'slow_02',
    direction: DailyDirection.SLOW,
    mainLine: '把一件事做完，比同时做十件事更值得。',
    observation: '多任务是否让你常常觉得自己做了很多，却什么都不够完整？',
    microAction: '今天只选一件事做到底，其他事情先排队。',
    pocketLight: '一次只做一件事，是给自己减少摩擦力。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'slow_03',
    direction: DailyDirection.SLOW,
    mainLine: '真正完成一件事，比开始很多事更踏实。',
    observation: '你是否习惯不断开新任务，因为完成旧任务让人感到压力？',
    microAction: '找出一件已经开了头但没完成的事，把它推进一小步。',
    pocketLight: '完成一件事，比开始十件事更能让心安定。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'slow_04',
    direction: DailyDirection.SLOW,
    mainLine: '细节里也藏着值得认真对待的部分。',
    observation: '当你想快速跳过时，有没有忽略那些需要耐心的小环节？',
    microAction: '做一件小事时，比平时多留意一个细节。',
    pocketLight: '认真对待一个小细节，也是在认真对待自己。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'slow_05',
    direction: DailyDirection.SLOW,
    mainLine: '今天选一件事，不赶时间地做完。',
    observation: '赶时间是否已经成为你的默认状态？',
    microAction: '选一件日常小事，比如吃饭或走路，有意识地放慢速度。',
    pocketLight: '不赶时间地做一件事，是给今天的自己一点礼物。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'slow_06',
    direction: DailyDirection.SLOW,
    mainLine: '今天可以只做一件事。',
    observation: '当你觉得什么都要做时，也许什么都没真正开始。',
    microAction: '从所有待办里挑一件，今天只做这一件。',
    pocketLight: '只做一件事，不是偷懒，是把力气集中。',
    warmth: 1,
    suggestionStrength: 3,
    sensitive: false
  },
  {
    id: 'slow_07',
    direction: DailyDirection.SLOW,
    mainLine: '慢下来的时候，你会看见平时错过的小事。',
    observation: '当你慢下来时，有没有发现一些一直被忽略的细节？',
    microAction: '用比平时慢一半的速度做完一件日常事，留意一个细节。',
    pocketLight: '慢一点，世界会多给你看一点。',
    warmth: 5,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'slow_08',
    direction: DailyDirection.SLOW,
    mainLine: '不必同时处理所有事。',
    observation: '多线程是否已经成为你的习惯，而不是真正必要？',
    microAction: '今天把一件事做完再做下一件，不交叉。',
    pocketLight: '一次只做一件事，心会安静很多。',
    warmth: 1,
    suggestionStrength: 2,
    sensitive: false
  },

  // ==================== 更认真地听见自己 ====================
  {
    id: 'hear_self_01',
    direction: DailyDirection.HEAR_SELF,
    mainLine: '你心里的声音，今天值得被认真听一次。',
    observation: '当你说"我没事"时，身体有没有给你不同的信号？',
    microAction: '花三分钟安静坐着，只问自己：我现在真正感受是什么？',
    pocketLight: '认真听自己一次，不是自私，是自我照顾。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'hear_self_02',
    direction: DailyDirection.HEAR_SELF,
    mainLine: '先听见自己的感受，再回应外面的期待。',
    observation: '今天有没有哪一刻，你为了符合期待而忽略了自己的不舒服？',
    microAction: '在下次答应别人前，先停顿一秒感受自己的身体反应。',
    pocketLight: '你的感受不需要排在别人的期待后面。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'hear_self_03',
    direction: DailyDirection.HEAR_SELF,
    mainLine: '身体比脑子更先知道答案。',
    observation: '当你感到紧绷、疲惫或不安时，身体在告诉你什么？',
    microAction: '从头到脚扫描一次身体，只做观察，不评判。',
    pocketLight: '身体的信号值得被听见，即使它暂时说不清楚。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'hear_self_04',
    direction: DailyDirection.HEAR_SELF,
    mainLine: '今天不急着把感受变成结论。',
    observation: '当你产生某种情绪时，是否常常立刻要求自己"想开点"？',
    microAction: '写下一个今天的感受，不解释、不解决，只是描述。',
    pocketLight: '感受不需要立刻变成结论，它可以先被承认。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'hear_self_05',
    direction: DailyDirection.HEAR_SELF,
    mainLine: '你的真实感受，不需要被修饰成别人能接受的版本。',
    observation: '当你表达感受时，是否会不自觉地加上"但是"让它显得合理？',
    microAction: '用一句简单的话，直接说出今天的一种感受。',
    pocketLight: '真实的感受，即使不完美，也值得被说出来。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'hear_self_06',
    direction: DailyDirection.HEAR_SELF,
    mainLine: '今天可以不解释自己的感受。',
    observation: '当你反复解释"我为什么这样想"时，也许感受本身已经被压到了后面。',
    microAction: '今天只说出感受，不解释原因，不辩护。',
    pocketLight: '感受不需要理由，它存在就值得被承认。',
    warmth: 1,
    suggestionStrength: 3,
    sensitive: false
  },
  {
    id: 'hear_self_07',
    direction: DailyDirection.HEAR_SELF,
    mainLine: '你心里的声音，比头脑的分析更靠近真实。',
    observation: '当你想太多时，身体和直觉往往已经先给出了答案。',
    microAction: '对一个正在纠结的决定，先不看理由，只感受心里的倾向。',
    pocketLight: '心里的声音，值得被认真听一次。',
    warmth: 5,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'hear_self_08',
    direction: DailyDirection.HEAR_SELF,
    mainLine: '今天可以只观察，不结论。',
    observation: '你是否习惯立刻给感受贴标签——"这是焦虑""这是矫情"？',
    microAction: '今天只描述感受，不给它命名或分类。',
    pocketLight: '只观察不结论，感受才能完整地被看见。',
    warmth: 1,
    suggestionStrength: 2,
    sensitive: false
  },

  // ==================== 保护好自己的边界 ====================
  {
    id: 'boundary_01',
    direction: DailyDirection.BOUNDARY,
    mainLine: '今天只承担属于你的那部分责任。',
    observation: '当你感到疲惫时，有没有可能是承担了太多不属于自己的情绪？',
    microAction: '区分一件让你累的事中，哪些是你的责任，哪些不是。',
    pocketLight: '边界不是冷漠，是让自己有力气继续温柔。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'boundary_02',
    direction: DailyDirection.BOUNDARY,
    mainLine: '拒绝一件你不想承担的小事，也是一种自我照顾。',
    observation: '当你说"好"时，是否常常是因为不好意思说"不"？',
    microAction: '今天只拒绝一件你并不想做的事，用一句温和的话。',
    pocketLight: '温和的拒绝，也是一种保护自己的力量。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'boundary_03',
    direction: DailyDirection.BOUNDARY,
    mainLine: '别人的情绪，不总是要你来接住。',
    observation: '当身边有人低落时，你是否会立刻觉得自己必须负责？',
    microAction: '今天允许自己只做陪伴者，而不是解决者。',
    pocketLight: '你可以关心别人，同时不必承担别人的情绪。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'boundary_04',
    direction: DailyDirection.BOUNDARY,
    mainLine: '保护自己的时间和能量，不是自私。',
    observation: '今天有没有哪一刻，你因为害怕被评价而压缩了自己的需要？',
    microAction: '为自己预留一段不被打扰的时间，不解释原因。',
    pocketLight: '守住自己的空间，你才能更有力气地回应世界。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'boundary_05',
    direction: DailyDirection.BOUNDARY,
    mainLine: '你的"可以"和"不可以"都值得被表达。',
    observation: '当你想设边界时，是否会担心破坏关系？',
    microAction: '对一件小事，明确说出你的"可以"或"不可以"。',
    pocketLight: '表达边界，不是拒绝别人，是告诉别人你怎样能被更好地对待。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'boundary_06',
    direction: DailyDirection.BOUNDARY,
    mainLine: '今天可以不接住所有人的情绪。',
    observation: '当你感到被拖累时，也许是因为承担了太多不属于自己的感受。',
    microAction: '今天对一件别人的情绪，只做旁观者，不接手。',
    pocketLight: '不接住，不是冷漠，是承认那不是你的。',
    warmth: 1,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'boundary_07',
    direction: DailyDirection.BOUNDARY,
    mainLine: '你的"不"，也值得被温柔地说出口。',
    observation: '当你想拒绝却开不了口时，是不是害怕让对方失望？',
    microAction: '今天对一个不想做的事，说一句温和但明确的"不"。',
    pocketLight: '温和的不，也是一种对自己的忠诚。',
    warmth: 5,
    suggestionStrength: 3,
    sensitive: false
  },
  {
    id: 'boundary_08',
    direction: DailyDirection.BOUNDARY,
    mainLine: '今天可以不回应所有人的期待。',
    observation: '当你觉得"必须让所有人满意"时，也许自己的需要已经被挤没了。',
    microAction: '选一个期待，今天不回应，只照顾自己。',
    pocketLight: '不回应，也是一种回答。',
    warmth: 1,
    suggestionStrength: 3,
    sensitive: false
  },

  // ==================== 允许自己不那么完美 ====================
  {
    id: 'allow_imperfect_01',
    direction: DailyDirection.ALLOW_IMPERFECT,
    mainLine: '今天允许自己有一处不那么完美。',
    observation: '你是否常常用"完美"作为保护自己的方式？',
    microAction: '故意让一件小事不完美，然后观察会发生什么。',
    pocketLight: '不完美不会让世界结束，但会让你轻松一些。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'allow_imperfect_02',
    direction: DailyDirection.ALLOW_IMPERFECT,
    mainLine: '出一点小错，不代表你整个人不够好。',
    observation: '当你犯错时，内心会立刻放大成"我又搞砸了"吗？',
    microAction: '如果今天发生小失误，练习对自己说："这只是其中一件事。"',
    pocketLight: '一次小错，不会定义你，就像一次做对也不会。',
    warmth: 4,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'allow_imperfect_03',
    direction: DailyDirection.ALLOW_IMPERFECT,
    mainLine: '不必把所有事情都做到一百分。',
    observation: '你是否把"足够好"等同于"完美"？',
    microAction: '选一件事，主动只做八十分的版本。',
    pocketLight: '八十分的生活，也可以很完整。',
    warmth: 4,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'allow_imperfect_04',
    direction: DailyDirection.ALLOW_IMPERFECT,
    mainLine: '有些日子就是用来松松垮垮地过的。',
    observation: '当你状态不好时，是否会额外责怪自己"不该这样"？',
    microAction: '今天降低一个对自己的要求，让状态来决定节奏。',
    pocketLight: '松松垮垮地过一天，不是浪费，是恢复。',
    warmth: 5,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'allow_imperfect_05',
    direction: DailyDirection.ALLOW_IMPERFECT,
    mainLine: '你不必今天就把自己修好。',
    observation: '当你把"变好"作为日常任务时，会不会反而给自己增加压力？',
    microAction: '今天不做任何"自我提升"的事，只做让自己舒服的事。',
    pocketLight: '不需要每天都进步，有些日子只需要不被苛责。',
    warmth: 5,
    suggestionStrength: 1,
    sensitive: false
  },
  {
    id: 'allow_imperfect_06',
    direction: DailyDirection.ALLOW_IMPERFECT,
    mainLine: '今天可以搞砸一点。',
    observation: '当你害怕犯错时，也许"不犯错"本身已经成了最大的压力。',
    microAction: '故意在一件小事上不追求完美，看看会发生什么。',
    pocketLight: '搞砸一点，天不会塌下来。',
    warmth: 1,
    suggestionStrength: 3,
    sensitive: false
  },
  {
    id: 'allow_imperfect_07',
    direction: DailyDirection.ALLOW_IMPERFECT,
    mainLine: '八十分的你，也已经足够被认真对待。',
    observation: '你是否一直在追赶那个"满分版本"的自己，却忘了现在的自己？',
    microAction: '今天做一件事，只做到"差不多就行"，然后停。',
    pocketLight: '八十分也值得，不是非要满分才被允许。',
    warmth: 3,
    suggestionStrength: 2,
    sensitive: false
  },
  {
    id: 'allow_imperfect_08',
    direction: DailyDirection.ALLOW_IMPERFECT,
    mainLine: '今天不必把自己修好。',
    observation: '当你把"变好"当成每天的任务时，会不会连休息都带着内疚？',
    microAction: '今天不做任何"自我提升"的事，只允许自己存在。',
    pocketLight: '不修好，也可以好好过完今天。',
    warmth: 1,
    suggestionStrength: 1,
    sensitive: false
  }
];

/**
 * 按方向获取内容列表
 */
export function getContentsByDirection(direction: DailyDirection): DailyLightContent[] {
  const result: DailyLightContent[] = [];
  for (const item of DAILY_LIGHT_LIBRARY) {
    if (item.direction === direction) {
      result.push(item);
    }
  }
  return result;
}

/**
 * 根据 ID 查找内容
 */
export function findContentById(id: string): DailyLightContent | null {
  for (const item of DAILY_LIGHT_LIBRARY) {
    if (item.id === id) {
      return item;
    }
  }
  return null;
}

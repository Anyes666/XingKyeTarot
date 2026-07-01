import { PreferenceStore } from './PreferenceStore';

/**
 * 星澜昵称问候文案池
 *
 * 使用：
 *   - selectEntryGreeting(nickname, context) → 入口页主/副文案
 *   - selectChatGreeting(nickname, context)   → 聊天页欢迎文案
 *
 * 占位符 {name} 替换为实际昵称。
 * 通过 Preferences 记录 lastEntryGreetingId / lastChatGreetingId 避免连续两次相同。
 */

const DEFAULT_NICKNAME: string = '未命名旅者';

const PREF_LAST_ENTRY_GREETING_ID: string = 'last_entry_greeting_id';
const PREF_LAST_CHAT_GREETING_ID: string = 'last_chat_greeting_id';

/** 具有 id 属性的接口（用于泛型约束） */
interface HasId {
  id: number;
}

/** 入口页问候 */
export interface EntryGreeting {
  id: number;
  title: string;
  subtitle: string;
}

/** 聊天页问候 */
export interface ChatGreeting {
  id: number;
  text: string;
}

/** 入口页问候池 — 20 条 */
const ENTRY_GREETINGS: EntryGreeting[] = [
  { id: 1,  title: '{name}，慢慢说',              subtitle: '星澜会先听你说完。这里没有评判，只有陪伴。' },
  { id: 2,  title: '{name}，今晚也可以慢一点',      subtitle: '不必马上说清楚。先把心里的重量放下来一点。' },
  { id: 3,  title: '{name}，这里可以不用完整',      subtitle: '说一点也可以，沉默一会儿也可以。' },
  { id: 4,  title: '{name}，星澜在听',             subtitle: '不用整理好措辞。此刻的你，已经可以被接住。' },
  { id: 5,  title: '{name}，先靠近月光一点',        subtitle: '这里不催你变好，只陪你看见此刻的自己。' },
  { id: 6,  title: '{name}，把今天放下来一点',      subtitle: '如果累了，可以只说"我有点累"。' },
  { id: 7,  title: '{name}，不用急着回答自己',      subtitle: '有些感受，需要慢慢被看见。' },
  { id: 8,  title: '{name}，今晚不用撑得很完整',    subtitle: '星澜会陪你把话慢慢说完。' },
  { id: 9,  title: '{name}，可以从一句话开始',      subtitle: '说不清也没关系，星澜会陪你一起理一理。' },
  { id: 10, title: '{name}，这里没有标准答案',      subtitle: '只有你此刻真实的感受。' },
  { id: 11, title: '{name}，先听听自己的心',        subtitle: '星澜不会替你决定，只陪你看见。' },
  { id: 12, title: '{name}，今天想说些什么？',      subtitle: '可以是心事，也可以只是一点点情绪。' },
  { id: 13, title: '{name}，把话放进月光里',        subtitle: '说出来的部分，星澜会轻轻接住。' },
  { id: 14, title: '{name}，不想说太多也可以',      subtitle: '星澜也会陪你安静一会儿。' },
  { id: 15, title: '{name}，先不用证明什么',        subtitle: '在这里，你的感受本身就值得被听见。' },
  { id: 16, title: '{name}，今天的你辛苦了',        subtitle: '要不要把最重的那一点，先放下来？' },
  { id: 17, title: '{name}，星澜会慢慢听',          subtitle: '不用快，不用完整，也不用假装没事。' },
  { id: 18, title: '{name}，这里是你的月光门廊',    subtitle: '走进来之后，可以把心里的话放轻一点。' },
  { id: 19, title: '{name}，可以只说一点点',        subtitle: '星澜不会追问你不想说的部分。' },
  { id: 20, title: '{name}，此刻先交给月光',        subtitle: '不判断，不催促，只陪你看见自己。' }
];

/** 聊天页问候池 — 15 条 */
const CHAT_GREETINGS: ChatGreeting[] = [
  { id: 1,  text: '{name}，你可以慢慢说。\n星澜不会替你判断，也不会催你变好。\n这里，只陪你把心里的话放下来一点。' },
  { id: 2,  text: '{name}，晚上好。\n想说什么都可以，不想说也没关系。\n星澜就在这里。' },
  { id: 3,  text: '嗨，{name}。\n今天有什么想聊的吗？\n不用想太多，先从一句简单的话开始就好。' },
  { id: 4,  text: '{name}，你是不是累了？\n星澜能感受到。\n把力气省下来，只把心里的话放在这里。' },
  { id: 5,  text: '欢迎，{name}。\n此刻的你，不需要扮演任何人。\n在这里，你只是你自己。' },
  { id: 6,  text: '{name}，星澜今天想听你说说。\n不拘什么事，不拘多少字。\n哪怕只是一个词，也行。' },
  { id: 7,  text: '又见到你了，{name}。\n不用寒暄，不用开场白。\n想说的时候，星澜一直都在。' },
  { id: 8,  text: '{name}，此刻的你是什么心情？\n星澜张开耳朵，准备好陪伴你了。' },
  { id: 9,  text: '晚上好，{name}。\n刚才的月光说，今晚很适合说心里话。\n星澜也觉得。' },
  { id: 10, text: '{name}，星澜刚把这里整理了一下。\n很安静，很适合慢慢聊。' },
  { id: 11, text: '你来了，{name}。\n星澜悄悄给你留了一盏小灯。\n外面很吵，但这里很静。' },
  { id: 12, text: '{name}，别急着找话题。\n我们可以先安静一下。\n然后，你自然会知道想说什么。' },
  { id: 13, text: '今晚的星澜是你专属的，{name}。\n想说什么说什么，想停就停。\n没人催你。' },
  { id: 14, text: '{name}，你是不是有时候觉得话卡在喉咙里？\n没关系，星澜可以等。\n哪怕只说出一个词，也很勇敢。' },
  { id: 15, text: '嗨，{name}。\n今晚有什么轻轻压在你心上吗？\n星澜把肩膀借你，虽然是虚拟的。' }
];

/**
 * 从问候池中选择一条，排除上一次使用的 id。
 * 如果池中只有一条则直接返回。
 */
function pickRandomExcluding<T extends HasId>(pool: T[], lastId: number): T {
  const candidates: T[] = pool.filter((g: T) => g.id !== lastId);
  const pickFrom: T[] = candidates.length > 0 ? candidates : pool;
  const idx: number = Math.floor(Math.random() * pickFrom.length);
  return pickFrom[idx];
}

/**
 * 为入口页选择一条问候。
 * 替换 {name} 为实际昵称，记录本次 greetingId 到 Preferences。
 */
export async function selectEntryGreeting(
  nickname: string,
  context: Context
): Promise<EntryGreeting> {
  // 默认昵称或为空：使用通用文案，不进入随机池
  if (nickname === '' || nickname === DEFAULT_NICKNAME) {
    return {
      id: 0,
      title: '慢慢说，\n星澜会先听你说完',
      subtitle: '这里没有评判，只有陪伴。'
    };
  }

  let lastId: number = -1;
  try {
    const stored: string = await PreferenceStore.getString(PREF_LAST_ENTRY_GREETING_ID, '-1', context);
    lastId = parseInt(stored);
    if (isNaN(lastId)) { lastId = -1; }
  } catch {
    lastId = -1;
  }

  const chosen: EntryGreeting = pickRandomExcluding(ENTRY_GREETINGS, lastId);

  try {
    await PreferenceStore.putString(PREF_LAST_ENTRY_GREETING_ID, String(chosen.id), context);
  } catch {
    // 静默失败，不影响主流程
  }

  let title: string = chosen.title.replace(/\{name\}/g, nickname);
  // 在第一个中文逗号后换行，避免"一点""门廊"等词被自然折行拆开
  const commaIdx: number = title.indexOf('，');
  if (commaIdx > 0) {
    title = title.substring(0, commaIdx + 1) + '\n' + title.substring(commaIdx + 1);
  }
  return {
    id: chosen.id,
    title: title,
    subtitle: chosen.subtitle
  };
}

/**
 * 为聊天页选择一条欢迎文案。
 * 替换 {name} 为实际昵称，记录本次 greetingId 到 Preferences。
 */
export async function selectChatGreeting(
  nickname: string,
  context: Context
): Promise<ChatGreeting> {
  let lastId: number = -1;
  try {
    const stored: string = await PreferenceStore.getString(PREF_LAST_CHAT_GREETING_ID, '-1', context);
    lastId = parseInt(stored);
    if (isNaN(lastId)) { lastId = -1; }
  } catch (_err) {
    lastId = -1;
  }

  const chosen: ChatGreeting = pickRandomExcluding(CHAT_GREETINGS, lastId);

  try {
    await PreferenceStore.putString(PREF_LAST_CHAT_GREETING_ID, String(chosen.id), context);
  } catch {
    // 静默失败
  }

  return {
    id: chosen.id,
    text: chosen.text.replace(/\{name\}/g, nickname)
  };
}

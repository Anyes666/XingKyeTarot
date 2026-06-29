# 星澜塔罗 — Phase 5.7 ~ 5.12 详细设计计划

> **项目定位**：塔罗式情绪陪伴 + 自我探索
> **核心原则**：不做预言、不诊断、不替用户决定、不做恋爱承诺、不制造依赖
> **工程铁律**：每阶段完成后 `hvigor assembleHap` 保证 `ERROR=0`，不一次性全做

---

## 当前代码基线分析

### 已有核心能力
| 模块 | 文件 | 能力 |
|------|------|------|
| 类型系统 | `XinglanTypes.ets` | 完整的 enum/interface 体系 |
| 输入分析 | `XinglanAnalyzer` | 关键词规则 → AnalysisResult |
| 策略路由 | `XinglanRouter` | CRISIS > PROFESSIONAL > ADULT > PREDICTION > ROLE > subTopic > emotion > topic |
| 回复拼装 | `XinglanComposer` | 策略序列 → 语料池抽取 → 去重 → 拼接 |
| 安全守卫 | `XinglanSafetyGuard` | 输出校验 |
| 直接回复 | `XinglanDirectReplyEngine` | 高频痛点直答（含危机） |
| 陪伴模式 | `XinglanCompanionModeEngine` | 解闷/闲聊/安静陪伴 |
| 小互动 | `XinglanMiniInteractions` | 8 个 MiniInteraction |
| 交互流 | `XinglanInteractionFlows` | 6 条 Flow |
| 交互流引擎 | `XinglanInteractionFlowEngine` | Flow 入口匹配 + 节点推进 |
| 打断检测 | `XinglanInterruptDetector` | SAFETY > DIRECT > NEW_TOPIC > CONTINUE |
| 会话管理 | `XinglanSessionManager` | 消息历史/去重/上下文 |
| 本地存储 | `PreferenceStore` | preferences 持久化 |
| 聊天页 | `XinglanChatPage.ets` | 分段气泡 + chips + 优先级管线闭环 |

### 已有聊天页管线优先级（`sendMessage` 函数）
```
0.  DirectReply（最高优先级 — 危机/高频直答）
0.5 当前交互流中 → detectInterrupt（打断/继续）
1.  交互流入口 resolveFlowEntry
2.  MiniInteraction matchMiniInteraction
3.  CompanionMode resolveCompanionMode
4.  特殊意图 resolveSpecialIntent
5.  普通管线 analyzeInput → routeToPlan → composeReply
```

### 可复用素材
- 小纸条素材池（30 条，`XinglanPaperNotes.ets`）
- 星澜文案（`星澜文案.docx`）
- 回复模板（11 个，`XinglanTemplates.ets`）
- 社交调研（`社交媒体调研.md`）

---

## 总目标

```
用户选择今天怎么被陪
→ 星澜进入对应互动方式
→ 多轮陪伴 / 小卡片 / 夜信 / 星钥镜子
→ 生成可保存的情绪回声
→ 用户可设置偏好，但不形成依赖关系
```

---

## Phase 5.7：今日相处方式

### 目标
个性化系统的入口。用户进入星澜聊天，看到 5 个相处模式选择。

### 5 个模式
| 模式 | 枚举值 | 用于 | 风格 |
|------|--------|------|------|
| 听我说 | `LISTEN` | 难过/孤独/想说心事/被忽略/关系受伤 | 少分析、少提问、多接住 |
| 帮我理 | `SORT` | 选择困难/关系纠结/要不要继续 | 不替决定，帮拆标准与代价 |
| 给我光 | `LIGHT` | 低能量/只想要一句话/睡前打开 | 一张小纸条或星钥提醒 |
| 陪我静 | `QUIET` | 好累/不想说话/没力气/麻木 | 安静陪坐，不追问 |
| 逗我一下 | `PLAY` | 好无聊/陪我聊聊/别讲大道理 | 轻解闷，复用已有 Flow |

### 实现步骤

**第一步：扩展类型定义（`XinglanTypes.ets`）**
```typescript
export enum XinglanCompanionChoice {
  NONE = 'NONE',
  LISTEN = 'LISTEN', SORT = 'SORT', LIGHT = 'LIGHT',
  QUIET = 'QUIET', PLAY = 'PLAY'
}

export interface XinglanCompanionChoiceDef {
  choice: XinglanCompanionChoice;
  label: string; subtitle: string;
  openingSegments: string[];
  defaultChips: string[];
  replyStyle: 'short' | 'normal' | 'quiet';
  askQuestions: boolean;
  preferFlow?: XinglanInteractionFlowId;
}
```

**第二步：新建模式数据文件**
`entry/src/main/ets/xinglan/data/XinglanCompanionChoices.ets` — 5 个模式的定义数据。

**第三步：新建模式引擎**
`entry/src/main/ets/xinglan/engine/XinglanCompanionChoiceEngine.ets`
- `getChoiceDef(choice)` / `getChoiceChips(choice)` / `getChoiceOpening(choice)`

**第四步：修改 `XinglanChatPage.ets`**
- 新增 `@State currentCompanionChoice` 和 `@State showCompanionChoices`
- 在 welcome card 之后新增 `buildCompanionChoiceBar()` Builder
- 点击后：插入开场消息 + 更新默认 chips + 隐藏选择栏

**第五步：模式影响回复行为（第一版）**
- 默认 chips 变化
- 回复长短（`replyStyle`）
- 是否主动提问（`askQuestions`）
- 倾向进入的 Flow（`preferFlow`）
- **不动 SafetyGuard**，危机优先级保持最高

### 验收标准
- 5 个模式可见，点击后有对应开场
- 默认 chips 会变化
- 不影响原发送逻辑、不影响 flow
- 危机输入仍然优先中断
- `assembleHap` 成功，`ERROR=0`

### 涉及文件
| 文件 | 操作 |
|------|------|
| `XinglanTypes.ets` | 新增 `XinglanCompanionChoice` 枚举 + `XinglanCompanionChoiceDef` 接口 |
| `XinglanCompanionChoices.ets` | **新建** |
| `XinglanCompanionChoiceEngine.ets` | **新建** |
| `XinglanChatPage.ets` | 新增 choice bar Builder + 状态管理 + 管线集成 |

**预估工时**：3-4 小时

---

## Phase 5.8：星澜夜信卡片

### 目标
把"写一封星澜夜信"从普通聊天气泡升级成**可保存的夜信卡片**。

### 用户体验
1. 用户点击"写夜信"（chips 或相处模式入口）
2. 星澜问："今晚，想收到哪一种夜信？"
3. 5 个选项：我想被安慰 / 我想放下一个人 / 我想少怪自己 / 我只是睡不着 / 我不想说太多
4. 生成一张夜信卡片（不是普通气泡）
5. 底部按钮：保存夜信 / 再写短一点 / 回到聊天

### 实现步骤

**第一步：扩展类型定义（`XinglanTypes.ets`）**
```typescript
export enum XinglanNightLetterTheme {
  COMFORT = 'COMFORT', LET_GO = 'LET_GO',
  SELF_FORGIVE = 'SELF_FORGIVE', INSOMNIA = 'INSOMNIA', QUIET = 'QUIET'
}

export interface XinglanNightLetter {
  id: string; theme: XinglanNightLetterTheme;
  themeLabel: string; title: string; body: string;
  emotionTag: string; topicTag: string;
  createdAt: number; isSaved: boolean;
}

// 扩展 XinglanInteractionFlowId: NIGHT_LETTER_CARD_FLOW
// 扩展 XinglanInteractionNodeId: NIGHT_LETTER_THEME_SELECT, NIGHT_LETTER_SHOW_CARD
```

**第二步：新建夜信模板池**
`entry/src/main/ets/xinglan/data/XinglanNightLetters.ets` — 5 主题 × 8-10 封 = 40-50 封夜信。

**第三步：扩展交互流数据（`XinglanInteractionFlows.ets`）**
在现有 `NIGHT_LETTER_FLOW` 基础上新增主题选择和卡片展示节点。

**第四步：新增夜信卡片 UI（`XinglanChatPage.ets`）**
新增 `buildNightLetterCard(letter: XinglanNightLetter)` Builder。
- 视觉：深蓝半透明背景 + 金色细边框 + 顶部小星钥 + 正文分段 + 底部签名"星澜"
- 操作按钮：保存 / 再写短一点 / 回到聊天

**第五步：保存到 session（MVP）**
在 `XinglanSessionState` 中新增 `nightLetters: XinglanNightLetter[]` 字段。暂不接入历史页（降低风险）。

**第六步：安全中断** — 复用现有 `detectInterrupt`（SAFETY_TRIGGERS 已覆盖）。

### 验收标准
- 写夜信入口可点击，能选择夜信主题
- 输出为卡片，不是普通气泡
- 夜信可保存到当前 session
- 危机输入能中断，不影响普通聊天
- `assembleHap` 成功，`ERROR=0`

### 涉及文件
| 文件 | 操作 |
|------|------|
| `XinglanTypes.ets` | 新增 `XinglanNightLetterTheme` 枚举 + `XinglanNightLetter` 接口 + 扩展枚举 |
| `XinglanNightLetters.ets` | **新建**，40-50 封夜信模板 |
| `XinglanInteractionFlows.ets` | 新增 2 个节点 |
| `XinglanChatPage.ets` | 新增 `buildNightLetterCard()` Builder |
| `XinglanSessionManager.ets` | 扩展 session state |

**预估工时**：5-6 小时

---

## Phase 5.9：星钥小镜子

### 目标
用星钥/塔罗意象照见当下（不是预测未来）。

### 用户体验
1. 入口："用星钥照一下"（chips 或相处模式）
2. 星澜问："想让星钥照见哪一处？"
3. 5 个选项：照一下情绪 / 关系 / 选择 / 疲惫 / 今晚
4. 输出固定 4 段：星钥意象 → 照见了什么 → 星澜的轻问题 → 一个小行动
5. 底部按钮：再照一次 / 收进回声 / 回到聊天

### 实现步骤

**第一步：扩展类型（`XinglanTypes.ets`）**
```typescript
export enum XinglanMirrorTopic {
  EMOTION = 'EMOTION', RELATION = 'RELATION',
  CHOICE = 'CHOICE', TIRED = 'TIRED', NIGHT = 'NIGHT'
}

export interface XinglanMirrorCard {
  id: string; topic: XinglanMirrorTopic; topicLabel: string;
  imageSymbol: string; reflection: string;
  softQuestion: string; tinyAction: string;
  createdAt: number; isSaved: boolean;
}
// 扩展 FlowId: STAR_KEY_MIRROR_FLOW
// 扩展 NodeId: MIRROR_TOPIC_SELECT, MIRROR_SHOW_CARD
```

**第二步：新建镜子数据文件**
`entry/src/main/ets/xinglan/data/XinglanStarKeyMirror.ets` — 5 主题 × 8-10 张 = 40-50 张。

**第三步：新增镜子卡片 UI**
`buildMirrorCard(card: XinglanMirrorCard)` Builder。
- 视觉：深紫半透明背景 + 星光细边框 + 顶部小星钥 + 标题"今日星钥小镜子"

**第四步：接入预测边界**
- 不出现"一定会/命中注定/会复合"
- 预测类问题转成"照见你现在的感受"
- 复用现有 `XinglanBoundaryTag.PREDICTION` 路由逻辑

### 验收标准
- 能从 chips 进入，能选择 5 个主题
- 输出 4 段非预测式卡片
- 不出现"一定会/命中注定/会复合"
- `assembleHap` 成功，`ERROR=0`

### 涉及文件
| 文件 | 操作 |
|------|------|
| `XinglanTypes.ets` | 新增枚举 + 接口 + 扩展 Flow/Node 枚举 |
| `XinglanStarKeyMirror.ets` | **新建**，40-50 张镜子卡片 |
| `XinglanInteractionFlows.ets` | 新增 2 个节点 |
| `XinglanChatPage.ets` | 新增 `buildMirrorCard()` Builder |

**预估工时**：5-6 小时

---

## Phase 5.10：主题深度 Flow

### 目标
把高频心事做成"情境路线"，让用户感觉星澜真的知道这类心事要怎么慢慢看。

### 5 条深度 Flow

| Flow ID | 名称 | 触发关键词 | 核心流程 |
|---------|------|-----------|---------|
| `RELATION_WAITING_FLOW` | 关系等待 | 他不回我/忽冷忽热/不主动不拒绝/我们算什么 | 接住不安 → 不猜对方 → 看事实 → 看感受 → 边界小行动 |
| `CONTACT_COOLDOWN_FLOW` | 联系前降温 | 要不要联系他/想发消息/想找前任/忍不住想问 | 确认冲动 → 分辨目的 → 延迟行动 → 写下不发送 → 24h 后看 |
| `WORK_BURNOUT_FLOW` | 工作疲惫 | 上班好累/想辞职/领导让我窒息/工作没意义 | 区分累的类型 → 身体/关系/意义感/经济/离职冲动 |
| `CHOICE_CLARIFY_FLOW` | 选择困难 | 要不要/该不该/继续吗/分手吗/辞职吗/联系吗 | 不替决定 → 列出在意 → 列出害怕 → 最小试探 → 延迟建议 |
| `LOW_ENERGY_FLOW` | 低能量 | 好累/没力气/什么都不想做/只想躺着 | 低强度回应 → 不追问 → 允许休息 → 最小动作 |

### 实现步骤

**第一步：扩展类型定义（`XinglanTypes.ets`）**
```typescript
// 新增 5 个 FlowId
RELATION_WAITING_FLOW, CONTACT_COOLDOWN_FLOW,
WORK_BURNOUT_FLOW, CHOICE_CLARIFY_FLOW, LOW_ENERGY_FLOW

// 新增约 20 个 NodeId（每个 Flow 3-5 个节点）
RW_ACKNOWLEDGE, RW_DONT_GUESS, RW_LOOK_FACTS, RW_BOUNDARY_ACTION,
CC_CONFIRM_URGE, CC_CLARIFY_PURPOSE, CC_DELAY_ACTION, CC_WRITE_NOT_SEND,
WB_IDENTIFY_TYPE, WB_BODY_TIRED, WB_MEANING_LOSS, WB_BOUNDARY,
CCL_LIST_CARE, CCL_LIST_FEAR, CCL_MIN_TEST, CCL_DELAY,
LE_GENTLE_ACK, LE_MIN_ACTION
```

**第二步：扩展交互流数据（`XinglanInteractionFlows.ets`）**
新增 5 条 Flow 定义，每条含 entryKeywords + nodes（3-5 个节点）+ options。

**关键规则**：
- 安全优先级不变：CRISIS > ADULT > PROFESSIONAL > PREDICTION > ROLE > 主题 Flow > 普通 Pipeline
- 每个 Flow 最后一个节点 `endFlow: true`
- 不替用户做决定

**第三步：黑盒测试清单**
| 输入 | 期望 |
|------|------|
| "他不回我" | 进 RELATION_WAITING_FLOW |
| "我要不要联系前任" | 进 CONTACT_COOLDOWN_FLOW |
| "我想辞职" | 进 WORK_BURNOUT_FLOW |
| "我好累" | 进 LOW_ENERGY_FLOW |
| "我要不要分手" | 进 CHOICE_CLARIFY_FLOW |
| "我不想活了，好累" | 危机优先，不进 LOW_ENERGY_FLOW |
| "喜欢你" | 角色边界，不进情境 Flow |

**第四步：打断逻辑** — 复用现有 `detectInterrupt`。

### 验收标准
- 5 条主题 flow 能正确进入
- 用户打断能退出 flow
- 危机输入永远优先，不替用户做决定
- 动态 chips 正常
- `assembleHap` 成功，`ERROR=0`

### 涉及文件
| 文件 | 操作 |
|------|------|
| `XinglanTypes.ets` | 新增 5 个 FlowId + ~20 个 NodeId |
| `XinglanInteractionFlows.ets` | 新增 5 条 Flow 定义（~20 个节点） |
| `XinglanChatPage.ets` | 无需改动（Flow 引擎已集成） |

**预估工时**：8-10 小时

---

## Phase 5.11：情绪回声卡

### 目标
把一次聊天沉淀成一张"情绪回声卡"，提高留存和复访。

### 用户体验
1. 触发：聊了 5 轮以上 或 用户说"谢谢/好多了/先这样"
2. 星澜提示："要不要把刚才这段心事，收成一张小小的回声？"
3. 生成卡片（3 段）：你今天提到的感觉 / 背后的需要 / 星澜留给你的一句
4. 操作：保存到历史 / 不用保存

### 实现步骤

**第一步：扩展类型（`XinglanTypes.ets`）**
```typescript
export interface XinglanEmotionEcho {
  id: string; createdAt: number;
  emotionTag: string; topicTag: string;
  summaryText: string; needText: string; xinglanLine: string;
  sourceMessageIds: string[]; isSaved: boolean;
}
```

**第二步：新建回声生成引擎**
`entry/src/main/ets/xinglan/engine/XinglanEmotionEchoEngine.ets`
- 从 session 取最近 3 条用户消息关键词 + lastEmotion/lastTopic
- 规则匹配模板（每组 emotion+topic 准备 5-8 个变体）
- 不输出诊断词（"抑郁/焦虑型依恋/心理问题"等）

**第三步：新增回声卡片 UI**
`buildEmotionEchoCard(echo: XinglanEmotionEcho)` Builder。
- 视觉：深蓝半透明背景 + 金色细边框 + 标题"今日回声"

**第四步：触发逻辑**
在 `sendMessage` 管线末尾检查：用户消息数 >= 5 或匹配告别关键词 → 插入 echo prompt。

**第五步：保存到 session（MVP）**
在 `XinglanSessionState` 中新增 `echoes: XinglanEmotionEcho[]` 字段。暂不接入历史页。

**安全边界**：绝对不输出"你有抑郁/你是焦虑型依恋/你有心理问题"等诊断词。

### 验收标准
- 聊天达到条件后出现"收成回声"
- 能生成回声卡，可保存或暂存
- 不输出诊断词，不泄露过多隐私
- `assembleHap` 成功，`ERROR=0`

### 涉及文件
| 文件 | 操作 |
|------|------|
| `XinglanTypes.ets` | 新增 `XinglanEmotionEcho` 接口 |
| `XinglanEmotionEchoEngine.ets` | **新建** |
| `XinglanChatPage.ets` | 新增 `buildEmotionEchoCard()` Builder + 触发逻辑 |
| `XinglanSessionManager.ets` | 扩展 session state |

**预估工时**：5-6 小时

---

## Phase 5.12：星澜轻记得

### 目标
让星澜有"被记得感"，但只记陪伴偏好，不记恋爱关系。

### 可以记 / 不记什么
- ✅ 回复长短偏好、提问频率、常用陪伴方式、塔罗表达偏好、不喜欢鸡汤
- ❌ 喜欢星澜/把星澜当恋人/亲密等级/好感度/恋爱承诺

### 实现步骤

**第一步：扩展类型（`XinglanTypes.ets`）**
```typescript
export enum XinglanReplyStyle { SHORT = 'SHORT', NORMAL = 'NORMAL', DETAILED = 'DETAILED' }
export enum XinglanQuestionTolerance { FEW = 'FEW', NORMAL = 'NORMAL', MORE = 'MORE' }
export enum XinglanDefaultCompanion { COMFORT = 'COMFORT', SORT = 'SORT', NOTE = 'NOTE', QUIET = 'QUIET' }
export enum XinglanTarotPreference { LIKE = 'LIKE', SOMETIMES = 'SOMETIMES', NEVER = 'NEVER' }

export interface XinglanUserPreference {
  replyStyle: XinglanReplyStyle;
  questionTolerance: XinglanQuestionTolerance;
  defaultCompanionChoice: XinglanDefaultCompanion;
  tarotPreference: XinglanTarotPreference;
  dislikedPatterns: string[];
  updatedAt: number;
}
```

**第二步：新建偏好存储管理器**
`entry/src/main/ets/xinglan/engine/XinglanPreferenceStore.ets`
- `loadPreference()` / `savePreference()` / `resetPreference()`
- `updateReplyStyle()` / `updateQuestionTolerance()` / `updateDislikedPattern()`
- 使用已有 `PreferenceStore` 做持久化

**第三步：聊天页读取偏好**
- `aboutToAppear` → `loadPreference` → 设置默认 chips/相处方式
- 连续 3 次选择同一模式后 → 轻问是否保存偏好
- 选项：可以 / 这次可以以后不一定 / 不要记住

**第四步：偏好影响回复**
- `replyStyle` → 调整输出长度
- `questionTolerance` → 调整是否追加问题
- `defaultCompanionChoice` → 设置默认相处方式
- `dislikedPatterns` → 避免特定表达

**第五步：显式确认** — 任何偏好保存前都要让用户点"可以"，不自动偷偷记。

### 验收标准
- 偏好能保存，重新打开仍生效
- 可撤回，不保存恋爱关系/好感度
- 不影响安全边界
- `assembleHap` 成功，`ERROR=0`

### 涉及文件
| 文件 | 操作 |
|------|------|
| `XinglanTypes.ets` | 新增 4 个偏好枚举 + `XinglanUserPreference` 接口 |
| `XinglanPreferenceStore.ets` | **新建**，偏好 CRUD |
| `XinglanChatPage.ets` | 读取偏好 + 偏好影响回复 + 轻问逻辑 |

**预估工时**：5-6 小时

---

## 总开发顺序

### 第 1 周：做入口层
**Phase 5.7 今日相处方式** — 先把 5 个模式做出来，这是最容易让用户立刻感受到变化的功能。

### 第 2 周：做仪式感卡片
**Phase 5.8 星澜夜信卡片** + **Phase 5.9 星钥小镜子** — 让星澜从"聊天"变成"陪伴产品"。

### 第 3 周：做深度心事路线
**Phase 5.10 主题深度 Flow** — 优先做：关系等待、联系前降温、选择困难、低能量。

### 第 4 周：做沉淀和复访
**Phase 5.11 情绪回声卡** — 让用户每次聊完都有东西留下来。

### 第 5 周：做个性化偏好
**Phase 5.12 星澜轻记得** — 最后做，涉及本地存储、偏好读取，风险最高。

---

## 最小 MVP 版本

第一版只做 3 个：
1. **今日相处方式**（Phase 5.7）
2. **星澜夜信卡片**（Phase 5.8）
3. **星钥小镜子**（Phase 5.9）

MVP 后用户路径：
```
打开 App → 进入聊天 → 选择今天怎么被陪
→ 星澜进入对应模式 → 可以收夜信 / 照星钥小镜子
```

**核心产品理念**：不是让用户攻略星澜，而是让用户通过星澜，慢慢靠近自己。

---

## 总预估工时

| Phase | 名称 | 工时 |
|-------|------|------|
| 5.7 | 今日相处方式 | 3-4h |
| 5.8 | 星澜夜信卡片 | 5-6h |
| 5.9 | 星钥小镜子 | 5-6h |
| 5.10 | 主题深度 Flow | 8-10h |
| 5.11 | 情绪回声卡 | 5-6h |
| 5.12 | 星澜轻记得 | 5-6h |
| **合计** | | **31-38h** |
| **MVP** | 5.7+5.8+5.9 | **13-16h** |

---

## 新文件清单

| Phase | 新建文件 |
|-------|---------|
| 5.7 | `XinglanCompanionChoices.ets`（数据）、`XinglanCompanionChoiceEngine.ets`（引擎） |
| 5.8 | `XinglanNightLetters.ets`（数据） |
| 5.9 | `XinglanStarKeyMirror.ets`（数据） |
| 5.10 | 无新文件（扩展 `XinglanInteractionFlows.ets`） |
| 5.11 | `XinglanEmotionEchoEngine.ets`（引擎） |
| 5.12 | `XinglanPreferenceStore.ets`（引擎） |

## 修改文件清单

| 文件 | Phase | 改动 |
|------|-------|------|
| `XinglanTypes.ets` | 全部 | 每阶段新增枚举/接口 |
| `XinglanInteractionFlows.ets` | 5.8/5.9/5.10 | 新增节点和 Flow 定义 |
| `XinglanChatPage.ets` | 5.7/5.8/5.9/5.11/5.12 | 新增 Builder + 状态管理 + 管线集成 |
| `XinglanSessionManager.ets` | 5.8/5.11 | 扩展 session state |

---

> 设计完成日期：2026-06-29
> 基于项目当前代码基线（Phase 5.5 已完成），所有改动均利用现有引擎架构扩展，避免大规模重写。

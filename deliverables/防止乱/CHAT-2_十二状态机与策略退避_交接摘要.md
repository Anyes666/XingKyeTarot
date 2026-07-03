# CHAT-2 交接摘要：十二状态机与策略退避

> 阶段：V2 计划步骤 18 / CHAT-2
> 状态：代码完成，编译通过，可复现验证就绪
> 日期：2026-07-03

## 一、本轮目标

在现有星澜引擎上**增量**加入十二状态机与策略退避规则，不重写管线，不改 UI，不改网络/BGM。十二状态全部落地含转移条件，8 条退避规则全部生效。

## 二、修改文件清单

### 修改（2 个，纯增量，无删除）
| 文件 | 改动 |
|---|---|
| `entry/src/main/ets/xinglan/types/XinglanTypes.ets` | 新增 `XinglanDialogState` 枚举（12 状态）、`XinglanDialogStateMeta`/`XinglanBackoffSignal`/`XinglanDialogCoordination`/`XinglanStateTransitionResult` 接口；扩展 `XinglanSessionState` 加 9 个可选状态机字段 |
| `entry/src/main/ets/xinglan/engine/XinglanComposer.ets` | `composeReply` 内部增量接入：入口调状态机+退避调整 plan，出口记录轮次+强制单问号；原拼装/去重/安全校验逻辑完全不动 |

### 新建（3 个引擎文件）
| 文件 | 职责 |
|---|---|
| `entry/src/main/ets/xinglan/engine/XinglanDialogStateMachine.ets` | 12 状态元信息表 + `resolveNextState` 转移决策（含 Safety 最高优先级、超限流出） |
| `entry/src/main/ets/xinglan/engine/XinglanBackoffRules.ets` | 8 条退避规则：`detectBackoffSignals` 信号检测 + `applyBackoffToPlan` 策略调整 + `enforceSingleQuestion` 单问号强制 + `recordTurnEnd` 计数器更新 |
| `entry/src/main/ets/xinglan/engine/XinglanDialogStateTester.ets` | 可复现验证：`runDialogStateTests()` 返回报告，覆盖 12 状态转移 + 8 条退避规则 |

### 未改（符合铁律）
- ChatPage 及所有 UI 页面（本轮只改引擎与类型）
- Analyzer / Router / SessionManager / SafetyGuard / DirectReplyEngine / InteractionFlowEngine（管线不动）
- 抽牌 / 78 牌数据 / 历史记录结构 / BGM / 头像裁剪 / 昵称持久化 / 星历 / 等级阈值
- 路由 / main_pages.json（无新增页面）
- 网络接口（无网络）

## 三、当前真实管线图

```
用户输入
  │
  ▼
ChatPage.sendMessage(text)
  │
  ├─► addUserMessage(session, text)              [SessionManager]
  ├─► tryDirectReply(text)                        [DirectReplyEngine]  短路
  ├─► resolveFlowEntry/resolveFlowNext(text)      [InteractionFlowEngine]  交互流
  ├─► analyzeInput(text) → analysisResult         [Analyzer]
  ├─► routeToPlan(analysisResult) → replyPlan     [Router]
  ├─► composeReply(replyPlan, session)            [Composer]  ← CHAT-2 接入点
  │     │
  │     ├─ [CHAT-2 入口] 从 plan 构造 analysisFromPlan + 取最后用户消息
  │     ├─ [CHAT-2 入口] detectBackoffSignals → 退避信号
  │     ├─ [CHAT-2 入口] resolveNextState → 状态转移决策
  │     ├─ [CHAT-2 入口] applyBackoffToPlan → 调整后的 plan（移除禁用策略/切换策略）
  │     ├─ 原有拼装：按策略抽语料 + 去重 + 长度限制 + SafetyGuard + 相关性
  │     ├─ [CHAT-2 出口] enforceSingleQuestion → 每轮最多1问号
  │     └─ [CHAT-2 出口] recordTurnEnd → 更新状态机计数器
  │
  ├─► updateContext(session, replyPlan)           [SessionManager]
  └─► addXinglanMessage(session, text, lineIds)   [SessionManager]
```

**接入点选择依据**：`composeReply(plan, state)` 已接收 `state: XinglanSessionState`，是唯一不改 UI、不改签名、不重写管线的接入点。原有 analyzeInput/routeToPlan/SessionManager 完全不变。

## 四、哪些状态已经存在（本轮前）

| 概念 | 现状 |
|---|---|
| 对话状态机 | ❌ 不存在（XinglanInteractionFlowId 是菜单驱动交互流，非状态机） |
| 策略去重 | ✅ usedLineIds 去重窗口（最近5条） |
| 同主题深度 | ✅ sameTopicDepth 计数（但无退避动作） |
| 边界短路 | ✅ Router 对 CRISIS/PROFESSIONAL/ROLE/ADULT/PREDICTION 短路 |
| 输出安全 | ✅ SafetyGuard 禁用词校验 |
| 退避规则 | ❌ 8 条全部不存在 |

## 五、十二状态全部落地

| 枚举值 | 语义 | 允问 | 可建议 | 最大连续轮次 | 禁用策略 |
|---|---|---|---|---|---|
| ENTRY | 初始接触 | ✓ | ✗ | 1 | TINY_STEP, SAFETY_BOUNDARY |
| RECEIVE | 情绪承接（首次不提问） | ✗ | ✗ | 3 | SOFT_QUESTION, TINY_STEP, CLARIFY |
| CLARIFY | 感受澄清 | ✓ | ✗ | 3 | TINY_STEP, SAFETY_BOUNDARY |
| CAUSE_FOCUS | 原因探索 | ✓ | ✗ | 4 | TINY_STEP, SAFETY_BOUNDARY |
| COMFORT | 安慰陪伴（不分析） | ✗ | ✗ | 3 | SOFT_QUESTION, TINY_STEP, CLARIFY |
| QUIET | 安静陪伴 | ✗ | ✗ | 按时间 | SOFT_QUESTION, TINY_STEP, CLARIFY, REFLECT, HOLD_EMOTION |
| ORGANIZE | 轻量整理 | ✓(确认性) | ✗ | 3 | TINY_STEP, SAFETY_BOUNDARY |
| MICRO_ACTION | 微小行动 | ✓ | ✓(唯一) | 2 | SAFETY_BOUNDARY |
| CALMING | 情绪缓和 | ✗ | ✗ | 2 | SOFT_QUESTION, TINY_STEP, CLARIFY |
| CLOSE | 对话收束 | ✗ | ✗ | 2 | SOFT_QUESTION, TINY_STEP, CLARIFY, REFLECT |
| BOUNDARY | 边界处理 | ✗ | ✗ | 2 | SOFT_QUESTION, TINY_STEP |
| SAFETY | 风险安全（最高优先级） | ✗ | ✗ | 2 | SOFT_QUESTION, TINY_STEP, CLARIFY, REFLECT, TAROT_METAPHOR |

### 状态转移条件（对应 ch4b Mermaid 图）

- **ENTRY** → RECEIVE（有情绪表达）/ QUIET（用户选不想说话）/ SAFETY（风险信号）
- **RECEIVE** → CAUSE_FOCUS（情绪被接住愿深入）/ CLARIFY（情绪模糊）/ QUIET（不想深入）/ SAFETY
- **CLARIFY** → ORGANIZE（感受明确）/ QUIET（不想继续）/ CALMING（缓和）/ SAFETY
- **CAUSE_FOCUS** → ORGANIZE（信息足够）/ QUIET（不想继续）/ RECEIVE（新情绪）/ SAFETY
- **COMFORT** → CALMING（超限流出）/ RECEIVE（新情绪）
- **QUIET** → RECEIVE（用户主动开口）/ CLOSE（退出/超时）/ SAFETY
- **ORGANIZE** → MICRO_ACTION（想下一步）/ CLOSE（整理完成）/ RECEIVE（新情绪）/ QUIET
- **MICRO_ACTION** → CALMING（接受/拒绝后缓和）/ CLOSE / ORGANIZE / SAFETY
- **CALMING** → CLOSE（准备好结束）/ RECEIVE（想继续聊）
- **CLOSE** → RECEIVE（再聊一会儿）/ 会话结束
- **BOUNDARY** ← 任意状态检测到 ROLE/ADULT/PREDICTION/PROFESSIONAL 边界
- **SAFETY** ← 任意状态检测到 CRISIS/风险关键词（**最高优先级，无条件跳转**）
- **超限流出**：每状态达 maxConsecutiveRounds 后按转移图自然转出（如 RECEIVE 3轮→CAUSE_FOCUS，CAUSE_FOCUS 4轮→ORGANIZE）

## 六、8 条退避规则全部生效

| 规则 | 实现位置 | 验证用例 |
|---|---|---|
| R1 每轮最多一个问题 | `enforceSingleQuestion` 拼装后强制截断到首问号 | T-R1: 多问号→1问号 |
| R2 首次承接不提问 | RECEIVE 状态 `firstReceiveDone=false` 触发 FIRST_RECEIVE，移除 SOFT_QUESTION | T-R2: 信号触发+策略移除 |
| R3 同策略最多连续两轮 | `sameStrategyStreak≥2` 触发切换，首个策略移到末尾 | T-R3: 信号触发+策略序列变化 |
| R4 三轮无新信息转整理/安静 | `sameTopicStagnant≥3` 触发 NO_NEW_INFO → ORGANIZE | T-R4: 信号触发 |
| R5 拒绝建议后四轮退避 | 检测拒绝关键词 → `suggestionCooldownTurns=4`，每轮递减，期间移除 TINY_STEP | T-R5: 信号+cooldown=4+策略移除 |
| R6 "不想说"后不追问 | 检测关键词 → USER_SAYS_NOT_WANT_TALK → QUIET + 移除 SOFT_QUESTION | T-R6: 信号+策略移除 |
| R7 "你不懂"后回退承接 | 检测关键词 → USER_SAYS_YOU_DONT_UNDERSTAND → RECEIVE | T-R7: 信号+状态回退 |
| R8 Safety 优先级最高 | RISK_DETECTED / CRISIS 边界 → 无条件跳 SAFETY（优先于其他所有信号） | T-R8: 风险关键词+优先级覆盖 |

## 七、可复现验证

`XinglanDialogStateTester.ets` 提供 `runDialogStateTests(): string[]`，纯函数测试，不依赖随机性，直接调用 `detectBackoffSignals` / `resolveNextState` / `applyBackoffToPlan` / `enforceSingleQuestion`（避开 composeReply 的随机语料抽取）。

### 调用方式
```typescript
import { runDialogStateTests } from '../xinglan/engine/XinglanDialogStateTester';
const report: string[] = runDialogStateTests();
// report[0] = '═══ CHAT-2 十二状态机与退避规则验证 ═══'
// report[1] = '总计 N 项，PASS X，FAIL Y'
// 后续为 Markdown 表格行
```

### 覆盖项（共 25+ 项）
- 状态转移：T1-T13（初始状态、ENTRY→RECEIVE、风险→SAFETY、CRISIS→SAFETY、"你不懂"→RECEIVE、"不想说"→QUIET、拒绝→CALMING、3轮无新信息→ORGANIZE、ROLE_BOUNDARY→BOUNDARY、CAUSE_FOCUS 4轮超限→ORGANIZE、RECEIVE 3轮超限→CAUSE_FOCUS、保持当前、12状态元信息齐全）
- 退避规则：R1-R8 各 1-3 项（信号触发 + 策略调整 + 状态转移）
- 元信息约束：RECEIVE 不允问/不给建议、MICRO_ACTION 可给建议且最多2轮、SAFETY 不允问且禁 TAROT_METAPHOR

## 八、验收要点对照

| 验收项 | 状态 |
|---|---|
| 编译 ERROR=0 | ✅ BUILD SUCCESSFUL，ERROR=0 |
| 十二状态全部落地，含状态转移条件 | ✅ 12 状态枚举 + 元信息表 + resolveNextState 转移决策 |
| 退避规则全部生效（同策略≤2轮、拒绝建议后4轮退避等） | ✅ 8 条规则在 BackoffRules 实现 + Tester 验证 |
| 现有引擎未删除，仅增量 | ✅ 仅 Composer 增量接入，其余引擎零改动 |
| 有可复现验证 | ✅ runDialogStateTests() 纯函数测试，25+ 项 |
| 不使用 any/as any/@ts-ignore | ✅ 全部显式 interface + 类型变量 |
| 不改 UI / 不改网络 / 不改 BGM | ✅ 仅改引擎与类型 |

## 九、ArkTS 严格类型遵守

- 全部新增接口显式声明（XinglanDialogState / XinglanDialogStateMeta / XinglanBackoffSignal / XinglanDialogCoordination / XinglanStateTransitionResult）
- `resolveNextState` 返回类型为显式 interface `XinglanStateTransitionResult`，所有 return 前先声明 `const result: XinglanStateTransitionResult`
- 无匿名对象类型、无 `return { ... }` 裸返回、无 any/as any/@ts-ignore
- 首次编译 12 个 ERROR（匿名对象类型 + 裸返回），已全部按 ArkTS 规则修复

## 十、与 CHAT-1 的关系

- CHAT-1 的五 Need 入口（LISTEN/COMFORT/ORGANIZE/ADVICE/QUIET）影响**开场**与顶部状态文案
- CHAT-2 的十二状态机影响**每轮回复的策略调整**与状态转移
- 两者互不冲突：CHAT-1 开场消息不走 Composer，CHAT-2 状态机只在 Composer 内生效
- 后续可打通：Need 入口时同步初始化 currentState（如 QUIET Need → 直接进 QUIET 状态），属下一窗口扩展

## 十一、编译结果

- 命令：`cd /d/XingKeyTarot && node "D:\HarmonyOS\DevEco Studio\tools\hvigor\bin\hvigorw.js" assembleHap --mode module -p module=entry@default -p product=default --no-daemon`
- 结果：**BUILD SUCCESSFUL in 25s**
- ERROR = 0
- WARN ≈ 190（全部来自已有 pages/ 页面，本轮新增 4 个 xinglan 文件零 WARN）
- 注：需 `cd /d/XingKeyTarot` 切到大写盘符目录规避 hvigor 小写盘符环境问题（FLOW-1/CHAT-1 已记录）

## 十二、下一窗口可进入

- CHAT-3 安静陪伴（V2 计划步骤 19）：QUIET 状态的视觉模式落地（月光水面星点，不自动发文本）
- 可选增强：Need 入口与 currentState 初始化打通
- 可选增强：状态机可视化调试面板（开发期，不入正式版）

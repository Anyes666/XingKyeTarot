# AUDIT-V2-0：V2 产品交互差异审计报告

> 项目：星钥塔罗（XingKey Tarot）
> 路径：D:\XingKeyTarot
> 审计类型：只读，不修改任何 App 代码
> 审计时间：2026-07-02
> 输出：deliverables/v2_product_interaction_gap_report.md

---

## 1. 审计结论摘要

| 项目 | 结论 |
|---|---|
| 报告是否已生成 | 是 |
| 是否修改代码 | 否 |
| 是否发现 P0 差异 | 否（差异存在，但均为计划内未开发项，不构成当前阻塞） |
| 是否发现 P1 差异 | 是（功能缺失） |
| 是否发现 P2 差异 | 是（部分实现/待增强） |
| UI 焕新是否达标 | 是（UI-15 已确认） |
| 推荐第一个 V2 Task | **DAILY-1：今日星页数据模型与本地存储** |

**总体判断**：当前代码库已完成 UI 焕新（A/B/C 三套视觉系统）和基础星澜聊天管线（Phase 5.x）。V2 计划中的核心功能大部分尚未实现，但基础能力（情绪星存储、五种陪伴方向的数据层、安静陪伴的原始形态）已存在，可直接复用。推荐从 DAILY-1 开始，因为今日星页是 V2 阶段 1 的 P0 入口，且其数据层是后续 DAILY-2~8 的前置依赖。

---

## 2. 15 项重点检查逐项审计

### 2.1 今日星页是否存在

- **状态**：**尚未开发**
- **证据**：
  - `entry/src/main/ets/daily/` 目录不存在（Glob 搜索无结果）。
  - `main_pages.json` 中没有 `DailyLightPage` 注册记录。
  - `Routes.ets` 中没有 `DAILY_LIGHT` 路由常量。
  - `MainFramePage.ets` 的 `DivinationCenterTabContent` 中仅有「每日一占」「圣三角牌阵」「关系探索」「旋转牌轮」「历史查看」五个入口，没有「今日星页」Hero 或入口。
- **说明**：V2 计划中的「今日星页」是独立新页面，当前完全没有实现。

### 2.2 每日一次状态是否存在

- **状态**：**已完成**
- **证据**：
  - `EmotionStarStorage.ets` 提供 `hasLightedToday(context): Promise<boolean>` 方法。
  - `lightToday()` 方法内部会检查今天是否已有记录，若已存在则返回 `false`。
- **说明**：现有「情绪星每天只能点亮一次」的规则已满足 V2 对「每日一次状态」的需求，可直接复用。

### 2.3 七天去重文案选择是否存在

- **状态**：**尚未开发**
- **证据**：
  - 项目中不存在 `DailyLightCopyLibrary`、`DailyContentSeed`、`DailyLightProvider` 等文件。
  - 没有 `recentContentIds` 或七天去重窗口的持久化字段。
- **说明**：七天去重是今日星页文案系统的核心规则，需随 DAILY-2 一起实现。

### 2.4 月湖回望是否存在

- **状态**：**尚未开发**
- **证据**：
  - 没有 `EveningReflectionCard` 或 `DailyReflectionPage` 文件。
  - `DailyRitualStore` 不存在，`eveningReflection` 字段无持久化载体。
- **说明**：月湖回望是今日星页完成后的可选日末复盘，需 DAILY-7 实现。

### 2.5 口袋微光是否存在

- **状态**：**尚未开发**
- **证据**：
  - 没有 `PocketLightCard` 组件。
  - 没有 `pocketLight` 字段的文案结构。
- **说明**：口袋微光需依赖今日星页内容完成后的展示，属于 DAILY-6。

### 2.6 每周星图是否存在

- **状态**：**部分完成**
- **证据**：
  - `StarCalendarPage.ets` 已实现「最近 7 日情绪星图」展示（最近七天的点亮/未点亮状态）。
  - 但 V2 计划中的「每周星图」特指「累计 7 次点亮（不要求连续）形成一幅小星图」的纯视觉奖励机制，该机制未实现：
    - 没有 `WeeklyConstellationCard` 组件。
    - 没有 7 次累计进度的四档视觉（1 星 / 3 星短星线 / 5 星局部图案 / 7 星小星图）。
    - 没有完成星图的文案与奖励表现。
- **说明**：现有 7 日星图展示可作为视觉基础，但「累计 7 次」的进度奖励形态需 DAILY-8 补充。

### 2.7 五种陪伴方向是否存在

- **状态**：**部分完成**
- **证据**：
  - 数据层已存在：`XinglanTypes.ets` 定义 `XinglanCompanionChoice`（LISTEN / SORT / LIGHT / QUIET / PLAY）。
  - 文案/选项层已存在：`XinglanCompanionChoices.ets` 完整定义了五个模式的 Def（听我说 / 帮我理 / 给我光 / 陪我静 / 逗我一下）。
  - 但入口层**未在入口页落地**：
    - `XinglanChatEntrancePage.ets` 只有一个「进入聊天」主按钮，没有五个方向卡片。
    - 五种方向目前只能在聊天页内通过「今天怎么陪我」chip 触发 `CompanionPicker` 进入。
- **说明**：V2 计划 CHAT-1 要求入口页直接展示五种方向。当前数据完整，入口页改造是主要工作量。

### 2.8 十二状态是否存在

- **状态**：**尚未开发**
- **证据**：
  - 不存在 `XinglanState` 或 `XinglanConversationState` 十二状态枚举。
  - 没有 ENTRY / RECEIVE / CLARIFY / CAUSE_FOCUS / COMFORT / QUIET / ORGANIZE / MICRO_ACTION / CALMING / CLOSE / BOUNDARY / SAFETY 这些状态定义。
  - 现有 `XinglanReplyStrategy` 仅包含策略枚举，不是状态机。
  - `XinglanSessionManager.ets` 管理消息会话，但没有状态字段。
- **说明**：十二状态机是 V2 CHAT-2 的核心任务，需要增量加入现有引擎而不重写管线。

### 2.9 建议退避是否存在

- **状态**：**尚未开发**
- **证据**：
  - 没有同策略连续轮次计数器（sameStrategyTurnCount）。
  - 没有拒绝建议后的退避计数器。
  - `XinglanRouter` / `XinglanComposer` 中没有实现「同策略最多连续两轮」「拒绝建议后四轮退避」等逻辑。
- **说明**：建议退避依赖十二状态机，需在 CHAT-2 中实现。

### 2.10 安静陪伴是否存在

- **状态**：**部分完成**
- **证据**：
  - 已存在：
    - `XinglanCompanionMode.QUIET_COMPANY`（在 `XinglanCompanionModeEngine` 中触发）。
    - `XinglanCompanionChoice.QUIET`（「陪我静」方向）。
    - 多个交互流中提供「先安静陪我」选项。
  - 未实现 V2 要求的「安静陪伴模式」：
    - 没有专门的安静模式 UI 态（隐藏普通 chips、只保留三按钮）。
    - 没有「我想说一句 / 继续安静 / 结束这次陪伴」三按钮。
    - 没有文案轮换（如「不用说什么，也可以」等）。
    - 没有三分钟无操作淡出逻辑。
- **说明**：安静陪伴的语义已存在，但独立的安静模式 UI 与交互需 CHAT-3 实现。

### 2.11 情绪降噪是否存在

- **状态**：**尚未开发**
- **证据**：
  - 没有 `reduceNoise` / `quietMode` / `noiseReduction` 状态或字段。
  - 没有「文字太多了吗？可以切换到更安静的回复」入口。
  - 没有短文案（20-50 字）/ 最多两个 chips / 字号增大 / 行距增加 / 减少背景动效的降级表现。
  - `XinglanShortCorpus.ets` 存在，但只是短文案库，没有被「降噪模式」调用。
- **说明**：情绪降噪是会话态 UI 功能，需 CHAT-4 实现。

### 2.12 结果纠偏 Chips 是否存在

- **状态**：**尚未开发**
- **证据**：
  - 没有 `ResultFeedbackChips` 组件。
  - `ResultGoldenPage.ets` / `TriangleResultPage.ets` / `RelationResultPage.ets` 的操作按钮区只有：
    - 进入首页（FIRST_EXPERIENCE）
    - 追问星澜 / 和星澜继续聊聊（不同页面文案略有不同）
    - 生成分享卡
    - 回到首页
    - 再听星澜说一句
  - 没有「这句话有点像我 / 有一部分不太像 / 帮我继续理一理 / 我只想安静一会儿 / 给我一个很小的建议」五个 Chips。
  - 没有 `userAcceptedInterpretation` 状态字段。
- **说明**：结果纠偏 Chips 是 V2 RESULT-1 的核心任务。

### 2.13 占卜结果是否能带上下文进入聊天

- **状态**：**尚未开发**
- **证据**：
  - 没有 `DivinationConversationContext` interface 或模型文件。
  - `XinglanSessionState` 中没有 `divinationContext` 可选字段。
  - `ResultGoldenPage.ets` 的「追问星澜」按钮使用 `FollowUpRouteParams` 跳转到 `Routes.FOLLOW_UP`，不是进入 `XinglanChatPage`。
  - `TriangleResultPage.ets` / `RelationResultPage.ets` 没有「和星澜继续聊聊」按钮（只有分享卡和回首页）。
  - `XinglanChatPage.ets` 的 `getParams` 没有解析占卜上下文。
- **说明**：占卜结果带入聊天是 V2 FLOW-1 的核心任务，需要新增上下文模型并改造三个结果页与聊天页。

### 2.14 依赖与预测边界是否存在

- **状态**：**部分完成**
- **证据**：
  - `XinglanBoundaryTag` 已定义：PREDICTION / PROFESSIONAL / CRISIS / ROLE_BOUNDARY / ADULT_BOUNDARY。
  - `XinglanSafetyGuard.ets` 已处理预测未来、专业建议、角色越界等边界。
  - `CORPUS_RELATION_BOUNDARY` 已包含「不判断对方心里到底怎么想」等文案。
  - 但 V2 SAFE-1 要求覆盖的 **7 类边界** 的完整增强响应尚未明确落地：
    - 预测未来、判断对方爱、替用户决定、依赖、医疗心理诊断、自伤自杀他伤、暴力虐待现实危险。
  - 现有边界处理更多集中在关键词识别和通用兜底，缺少按类别组织的增强响应文案（如 `XinglanBoundaryResponses.ets`）。
- **说明**：边界基础存在，但 SAFE-1 要求按 7 类边界增强响应与高风险转现实支持，需要补充。

### 2.15 哪些功能可直接复用现有实现

| 可复用能力 | 当前实现 | 后续复用点 |
|---|---|---|
| 每日一次状态 | `EmotionStarStorage.hasLightedToday` / `lightToday` | DAILY-5 点亮适配、每日星页完成后的情绪星点亮 |
| 情绪星记录与等级 | `EmotionStarStorage` 的 records、levels、连续/累计天数 | DAILY-8 每周星图、DAILY-5 星光归档 |
| 五种陪伴方向数据 | `XinglanCompanionChoice` + `XinglanCompanionChoices` | CHAT-1 入口页落地 |
| 安静陪伴语义 | `XinglanCompanionMode.QUIET_COMPANY` + `COMPANION_CHOICE_QUIET` | CHAT-3 安静模式 UI |
| 短文案库 | `XinglanShortCorpus.ets` | CHAT-4 情绪降噪 |
| 分享卡核心 | `ShareCardPage` / `ShareImageService` | DAILY-6 口袋微光生成分享卡 |
| 路由与参数模式 | 现有 `RouterOptions` + 显式 interface 已规范化 | FLOW-1 占卜结果带入聊天 |
| 安全边界基础 | `XinglanSafetyGuard` / `XinglanBoundaryTag` | SAFE-1 增强 |

---

## 3. 差异清单（P0 / P1 / P2）

### P0 — 阻塞 V2 主线或需优先补齐

> 当前无阻塞当前版本上架的 P0 差异（UI 焕新已完成且编译通过）。以下 P0 指 V2 主线的阻塞级缺失。

| # | 差异项 | 影响 | 对应 Task |
|---|---|---|---|
| P0-1 | 今日星页数据层未建立 | 没有持久化载体，DAILY-2~8 全部无法落地 | DAILY-1 |
| P0-2 | 今日星页入口未在占卜 Tab 添加 | 用户无法进入 V2 核心新功能 | DAILY-3 |
| P0-3 | 结果纠偏 Chips 未实现 | 用户无法反馈「不太像我」，影响体验 | RESULT-1 |
| P0-4 | 占卜结果上下文未带入聊天 | 星澜无法基于占卜结果继续对话 | FLOW-1 |

### P1 — 功能缺失，影响 V2 完整性

| # | 差异项 | 影响 | 对应 Task |
|---|---|---|---|
| P1-1 | 七天去重文案选择未实现 | 今日星页内容可能重复 | DAILY-2 |
| P1-2 | 月湖回望未实现 | 缺少日末复盘 | DAILY-7 |
| P1-3 | 口袋微光未实现 | 缺少完成后的微光保存/分享/聊天入口 | DAILY-6 |
| P1-4 | 每周星图（累计 7 次）未实现 | 缺少纯视觉奖励 | DAILY-8 |
| P1-5 | 十二状态机未实现 | 聊天策略无法按状态路由 | CHAT-2 |
| P1-6 | 建议退避未实现 | 聊天可能重复策略或过度建议 | CHAT-2 |
| P1-7 | 情绪降噪未实现 | 高焦虑场景缺少短文案模式 | CHAT-4 |
| P1-8 | 五种陪伴方向入口页未落地 | 入口页仍是单一入口 | CHAT-1 |
| P1-9 | 安静陪伴模式 UI 未实现 | 缺少独立安静模式 | CHAT-3 |
| P1-10 | 7 类边界增强响应未完整落地 | 高风险边界转现实支持不足 | SAFE-1 |

### P2 — 增强或优化项

| # | 差异项 | 影响 | 对应 Task |
|---|---|---|---|
| P2-1 | 文案结构化（XinglanCopyItem）未实现 | 策略路由与去重能力弱 | COPY-1 |
| P2-2 | 被接住/看见光文案路由未实现 | 问心模式对结果页文案无影响 | RESULT-2 |
| P2-3 | 评测体系与 42 条回归测试未建立 | 缺少系统验证 | EVAL-1 |
| P2-4 | 入口页五种陪伴方向卡片动效可更精致 | 视觉体验 | CHAT-1 |

---

## 4. 推荐第一个 V2 开发 Task

**推荐：DAILY-1 — 今日星页数据模型与本地存储**

理由：
1. **前置依赖**：今日星页是 V2 阶段 1（DAILY-1~8）的起点，没有数据层，DAILY-2 文案库、DAILY-3 Hero、DAILY-4 页面、DAILY-5 点亮适配、DAILY-6 口袋微光、DAILY-7 月湖回望、DAILY-8 每周星图都无法真正落地。
2. **风险可控**：纯数据层，不碰 UI、不碰路由、不碰现有核心逻辑（抽牌/聊天/BGM/历史/头像昵称/星历）。
3. **可复用现有经验**：参考 `EmotionStarStorage.ets` 和 `UserProfileStore.ets` 的 Preferences 封装模式。
4. **符合 V2 计划**：V2 分步计划明确 DAILY-1 为阶段 1 第一步。
5. **编译验证简单**：新增 5 个文件，不涉及页面注册，只需确保 ArkTS 严格类型通过。

预期产出：
- `entry/src/main/ets/daily/model/DailyDirection.ets`
- `entry/src/main/ets/daily/model/DailyRitualState.ets`
- `entry/src/main/ets/daily/model/DailyLightContent.ets`
- `entry/src/main/ets/daily/model/DailyReflection.ets`
- `entry/src/main/ets/daily/service/DailyRitualStore.ets`

---

## 5. 禁止修改范围确认（本轮严格遵守）

本轮只读审计，未修改任何 App 代码。以下核心逻辑确认未改动：

- `GlobalBgmManager.ets`
- `UserProfileStore.ets`
- `EmotionStarStorage.ets`
- `HistoryStore.ets`
- `xinglan/engine/` 全部核心引擎
- `xinglan/data/` 语料与数据
- 抽牌算法 / 78 张卡牌数据
- 历史记录结构
- 分享卡核心逻辑
- 星钥等级阈值
- 包名 / 签名 / 应用图标配置

---

## 6. 后续建议

1. **按 V2 分步计划顺序执行**：DAILY-1 → DAILY-2 → DAILY-3 → DAILY-4 → DAILY-5 → DAILY-6 → DAILY-7 → DAILY-8，然后进入阶段 2（RESULT / FLOW / CHAT / SAFE）。
2. **每个 Task 只改指定文件**：严格遵循 AGENTS.md 的「不扩散、不重构、不顺手修无关问题」原则。
3. **优先复用现有实现**：
   - 情绪星点亮规则直接复用 `EmotionStarStorage`。
   - 五种陪伴方向数据直接复用 `XinglanCompanionChoices`。
   - 分享卡直接复用 `ShareCardPage`。
   - 安静陪伴语义直接复用 `XinglanCompanionMode.QUIET_COMPANY`。
4. **注意红线文案**：新增文案必须避免「一定会」「复合」「正缘」「转运」「财运」等禁用表达。
5. **ArkTS 严格类型**：新增类型必须显式声明 interface，不使用 any / as any / @ts-ignore。
6. **每步编译**：每个 Task 完成后必须执行 `assembleHap`，确保 ERROR=0。

---

*报告结束。*

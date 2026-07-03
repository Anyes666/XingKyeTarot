# SAFE-1 边界与高风险 — 交接摘要

## 完成目标
增强 `XinglanSafetyGuard`，覆盖 7 类边界响应；高风险场景停止塔罗解释，转现实支持；与 CHAT-2 十二状态机 SAFETY/BOUNDARY 状态联动。

## 修改文件

### 1. `entry/src/main/ets/xinglan/engine/XinglanSafetyGuard.ets`
- 保留并增强 `validateOutput`：除 `FORBIDDEN_OUTPUT_PATTERNS` 外，新增医疗诊断承诺与永恒承诺输出二次拦截。
- 新增 `SafetyCategory` / `SafetyLevel` / `SafetyDecision` 类型。
- 新增 `analyzeInputSafety(userInput)`：识别 7 类边界场景，返回安全等级、类别、是否停止占卜、兜底回复。
- 新增 7 类关键词库：
  - `PREDICTION_KEYWORDS`：预测未来（会不会回来、命中注定、运势等）。
  - `JUDGE_LOVE_KEYWORDS`：判断对方爱（他爱不爱我、他心里有没有我等）。
  - `DECIDE_FOR_USER_KEYWORDS`：替用户决定（我该不该、你帮我决定等）。
  - `DEPENDENCY_KEYWORDS`：依赖表达（只有你最懂我、永远陪我等）。
  - `PROFESSIONAL_MEDICAL_KEYWORDS`：医疗心理诊断（抑郁症、诊断、治愈等）。
  - `CRISIS_SELF_HARM_KEYWORDS`：自伤自杀他伤（想死、自杀、伤害自己等）。
  - `VIOLENCE_ABUSE_KEYWORDS`：暴力虐待现实危险（被打、家暴、威胁、性侵等）。
- 新增 `mapToExistingBoundaryTag`：将 7 类安全分类映射到现有 `XinglanBoundaryTag`（CRISIS/PROFESSIONAL/PREDICTION/ROLE_BOUNDARY），与状态机既有路由对齐。
- 新增便捷函数：`isHighRiskInput`、`getBoundaryReplyForInput`、`getSafetyLevel`、`getCrisisClarificationQuestion`。

### 2. `entry/src/main/ets/xinglan/data/XinglanTemplates.ets`
- 扩展 `FORBIDDEN_OUTPUT_PATTERNS`，覆盖红线词：
  - 必然、绝对、肯定会
  - 复合、复合概率、正缘、烂桃花、招桃花、旺桃花、旺财运、开运
  - 转运、财运、中奖、神准、灵验、改命、水逆、八字、星座运势
  - 塔罗牌很准、牌面显示、命运安排、今日运势
  - 马上断联、赶紧离开、你应该继续、你应该离开
  - 亲爱的、宝贝、我一直在等你

### 3. 新增 `entry/src/main/ets/xinglan/data/XinglanBoundaryResponses.ets`
- 定义 `XinglanBoundaryCategory` / `XinglanBoundaryLevel` / `XinglanBoundaryDecision`。
- 为 7 类边界各提供 2–3 条响应文案池：
  - 预测未来 → 转自我探索。
  - 判断对方爱 → 转真实行为与感受。
  - 替用户决定 → 归还选择权。
  - 依赖表达 → 承认被理解，引导现实支持。
  - 医疗心理诊断 → 建议寻求专业帮助。
  - 自伤自杀他伤 → 停止聊天，提供急救/热线/信任之人引导。
  - 暴力虐待现实危险 → 先离开危险位置，联系紧急服务。
- 提供 `getBoundaryResponse(category)` 统一取文案。

## 删除 / 未改内容
- 未删除任何旧逻辑。
- 未修改 `XinglanComposer` / `XinglanRouter` / `XinglanAnalyzer` / `XinglanBackoffRules` / `XinglanDialogStateMachine` 等聊天核心管线逻辑。
- 未修改 `XinglanTypes.ets`。
- 未修改抽牌、78 牌数据、历史、分享、BGM、头像昵称、星历。
- 未修改 `main_pages.json` 或路由。
- 未新增页面/组件注册。

## 状态机联动说明
- `XinglanSafetyGuard` 的 `mapToExistingBoundaryTag` 将高风险映射为 `XinglanBoundaryTag.CRISIS`。
- CHAT-2 状态机已存在规则：
  - `CRISIS` → `SAFETY`（最高优先级）
  - `PROFESSIONAL` / `PREDICTION` / `ROLE_BOUNDARY` → `BOUNDARY`
- 因此 SafetyGuard 的分类结果天然与现有状态机路由对齐；后续如需在 `XinglanBackoffRules` 中显式调用 `analyzeInputSafety` 补充 `RISK_DETECTED` 信号，可直接使用已暴露的 `isHighRiskInput` / `analyzeInputSafety` API，无需再改 SafetyGuard 本体。

## 编译结果
- `assembleHap`：BUILD SUCCESSFUL
- ERROR：0
- WARN：既有 deprecation / classes-as-obj 警告，非本次引入

## 验收要点
1. 编译 ERROR=0：通过。
2. 七类边界均有响应文案：通过 `XinglanBoundaryResponses.ets` 覆盖。
3. 高风险停止塔罗解释转现实支持：通过 `analyzeInputSafety` 返回 `shouldStopDivination=true` 与对应兜底文案。
4. SafetyGuard 与状态机 SAFETY 联动：通过 `mapToExistingBoundaryTag` 映射到现有 `XinglanBoundaryTag.CRISIS/PROFESSIONAL/PREDICTION/ROLE_BOUNDARY`。
5. 其他引擎逻辑未改：未修改 Composer/Router/Analyzer/BackoffRules/DialogStateMachine。

## 未完成项及原因
- 无。7 类边界检测与兜底文案已落地；与状态机的显式调用接线保留在 BackoffRules/Composer 层，因本轮约束「仅 SafetyGuard 增强」未改动，但 API 与映射已准备就绪。

## 下一步建议
- 可在 `XinglanBackoffRules.detectBackoffSignals` 中接入 `isHighRiskInput` / `analyzeInputSafety`，使 7 类边界信号直接触发 `RISK_DETECTED` → `SAFETY` 状态跳转。
- 可在 `XinglanComposer` 中针对 `SafetyDecision.level === 'HIGH'` 直接短路回复，跳过塔罗策略拼装。

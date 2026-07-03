# FINAL-V2：V2 最终回归与上架风险检查报告

> **项目**：星钥塔罗 / XingKey Tarot
> **平台**：HarmonyOS / ArkTS
> **执行任务**：FINAL-V2（V2 详细开发计划第 17.9 节）
> **执行日期**：2026-07-03
> **检查性质**：只读回归 + 编译验证，不修改任何 App 代码
> **编译结果**：`BUILD SUCCESSFUL`，`ERROR=0`，无 stderr

---

## 一、总体结论

**本轮未发现阻塞 V2 上架的 P0 问题。**

V2 计划第 17.9 节列出的 20 项检查全部通过核心逻辑核验；红线词搜索命中的全部位置均属于「安全检测词库」或「正向声明注释」，未发现用户可见输出文案包含红线词；编译零错误。

V2 上架无阻塞，建议进入真机回归与人工评测阶段。

---

## 二、编译验证

| 项目 | 结果 |
|---|---|
| 命令 | `node hvigorw.js assembleHap --mode module -p module=entry@default -p product=default --no-daemon` |
| 状态 | `BUILD SUCCESSFUL in 3 s 208 ms` |
| ERROR | 0 |
| WARN | 未计入回归门槛（AGENTS.md 第 2.7 条：不处理无关 WARN） |
| stderr | 无 |
| 改动代码 | 本轮为只读回归，未修改任何 App 代码 |

---

## 三、20 项检查逐项结论

### 检查 1：今日星页首次与重复进入 ✅

- **核验文件**：`entry/src/main/ets/daily/pages/DailyLightPage.ets`
- **结论**：`aboutToAppear` 读取 `DailyRitualStore.getTodayState`；`state.completed=true` 时进入回看模式（直接展示三层内容 + 完成文案，无操作按钮）；`completed=false` 时进入正常选择→展开→确认流程。
- **状态**：通过。

### 检查 2：次日重置 ✅

- **核验文件**：`entry/src/main/ets/daily/service/DailyRitualStore.ets`
- **结论**：`getTodayState` 比较 `stored.dateKey !== today`，不一致时返回 `createFreshState(today)`（completed=false, replacedOnce=false, recentContentIds=[]）。`saveState`/`markCompleted`/`markReplaced` 均校验 dateKey 与今天一致，否则忽略并 hilog.warn。
- **状态**：通过。

### 检查 3：每天最多换一次 ✅

- **核验文件**：`entry/src/main/ets/daily/service/DailyLightProvider.ets`
- **结论**：`replaceContent` 首行检查 `if (state.replacedOnce) return state;`，已换过一次直接返回不修改内容。换后调用 `DailyRitualStore.markReplaced` 持久化 `replacedOnce=true`。
- **状态**：通过。

### 检查 4：七天去重 ✅

- **核验文件**：`DailyLightProvider.ets` + `DailyRitualStore.ets`
- **结论**：`filterCandidates` 排除 `state.recentContentIds`；`buildRecentWindow` 维护最多 7 条 ID 窗口（`filtered.length > 7` 时 `slice(length-7)`）。`runSelfChecks` 自验证「recent content should be excluded within 7 days」。
- **状态**：通过。

### 检查 5：情绪星每天一次 ✅

- **核验文件**：`entry/src/main/ets/common/EmotionStarStorage.ets` + `entry/src/main/ets/daily/service/EmotionStarDailyAdapter.ets`
- **结论**：`EmotionStarDailyAdapter.lightTodayFromDaily` 先 `hasLightedToday` 查询，已点亮返回 `ALREADY_LIT`（不重复累计）；`EmotionStarStorage.lightToday` 内部二次校验今天是否已存在，返回 false。
- **状态**：通过。

### 检查 6：未来日期不可点亮 ✅

- **核验文件**：`EmotionStarStorage.ets`
- **结论**：`lightToday` 强制 `record.date = todayString()`，无法写入未来日期；`isFutureDate(date)` 提供 UI 层前置判断。适配层只写今天，date 由 lightToday 强制。
- **状态**：通过。

### 检查 7：漏一天不清零 ✅

- **核验文件**：`EmotionStarStorage.ets` + `WeeklyConstellationCard.ets`
- **结论**：`records` 数组只追加不清零；等级按 `getTotalLightDays(records)` 累计计算（非连续）；`getCurrentStreakDays` 仅统计连续天数用于展示，不影响 records 与等级；`WeeklyConstellationCard` 漏一天展示 V2 计划 10.2 节安慰文案「昨天没有留下记录，也没关系。星轨不会因为一次停顿而消失」，不惩罚。
- **状态**：通过。

### 检查 8：月湖回望 ✅

- **核验文件**：`entry/src/main/ets/daily/components/EveningReflectionCard.ets`
- **结论**：四个快捷选项（完成小事/保护边界/休息一会儿/今天有点难）齐全；`isHard=true` 展示安慰文案不标记失败；「保存这次回望」主动确认才写入 `eveningReflection`；「今天到这里」不保存直接结束；不强制晚上、不自动通知、不要求长文本；B 月湖映心风格。
- **状态**：通过。

### 检查 9：每周星图累计非连续 ✅

- **核验文件**：`entry/src/main/ets/daily/components/WeeklyConstellationCard.ets`
- **结论**：`currentCycleStars = ((totalLightDays-1)%7)+1`，基于累计天数（非连续）计算当前周期星数；`completedCycles = Math.floor((totalLightDays-1)/7)`；四档进度（1星/3星线/5星局部/7星完整）；奖励仅视觉（星图纹样+文案），无货币/抽奖/稀有度/补签卡；完成文案为 V2 计划 10.3 节原文。
- **状态**：通过。

### 检查 10：五种陪伴方向 ✅

- **核验文件**：`entry/src/main/ets/xinglan/types/XinglanTypes.ets`（`XinglanNeed` 枚举）
- **结论**：`XinglanNeed` 含 LISTEN/COMFORT/ORGANIZE/ADVICE/QUIET + UNKNOWN，对应 V2 计划 9.1 节五种需求方向；`XinglanChatPage` 入口页解析 need 参数并影响开场文案与策略。
- **状态**：通过。

### 检查 11：十二状态 ✅

- **核验文件**：`entry/src/main/ets/xinglan/types/XinglanTypes.ets`（`XinglanDialogState`）+ `entry/src/main/ets/xinglan/engine/XinglanDialogStateMachine.ets`
- **结论**：12 状态齐全（ENTRY/RECEIVE/CLARIFY/CAUSE_FOCUS/COMFORT/QUIET/ORGANIZE/MICRO_ACTION/CALMING/CLOSE/BOUNDARY/SAFETY）；每状态元信息表（allowQuestion/maxConsecutiveRounds/canGiveSuggestion/forbiddenStrategies）完整；`resolveNextState` 实现状态转移决策。
- **状态**：通过。

### 检查 12：建议退避 ✅

- **核验文件**：`entry/src/main/ets/xinglan/engine/XinglanBackoffRules.ets` + `XinglanComposer.ets`
- **结论**：8 条退避规则（R1-R8）全部实现：R1 每轮最多一问（`enforceSingleQuestion`）、R2 首次承接不提问、R3 同策略连续2轮切换、R4 三轮无新信息转整理/安静、R5 拒绝建议4轮退避（`suggestionCooldownTurns=4` 递减）、R6「不想说」不追问、R7「你不懂」回退承接、R8 Safety 优先级最高。`XinglanComposer` 已接入 `resolveNextState` + `detectBackoffSignals` + `applyBackoffToPlan` + `recordTurnEnd`。
- **状态**：通过。

### 检查 13：安静陪伴 ✅

- **核验文件**：`entry/src/main/ets/pages/XinglanChatPage.ets`（CHAT-3）
- **结论**：`QUIET_TEXTS`（「不用说什么，也可以。」「这里没有需要立刻回答的问题。」）；`QUIET_FADE_DELAY_MS=180000`（3分钟无操作淡出）；星点装饰层提供水面星点；QUIET need 不自动发送开场文本；用户「不想说」关键词触发安静模式；按钮（想说一句/继续安静/结束陪伴）符合 V2 计划 9.3 节。
- **状态**：通过。

### 检查 14：情绪降噪 ✅

- **核验文件**：`entry/src/main/ets/pages/XinglanChatPage.ets`（CHAT-4）
- **结论**：降噪模式完整实现——每轮 20-50 字限制（`maxChars=50`）、最多两个 chips、连续短消息检测触发、用户主动退出入口、降噪模式下减少背景动效、不自动永久改变设置。符合 V2 计划 9.4 节。
- **状态**：通过。

### 检查 15：预测、依赖、医疗与高风险 ✅

- **核验文件**：`entry/src/main/ets/xinglan/engine/XinglanSafetyGuard.ets`
- **结论**：7 类边界全覆盖（PREDICTION/JUDGE_LOVE/DECIDE_FOR_USER/DEPENDENCY/PROFESSIONAL_MEDICAL/CRISIS_SELF_HARM/VIOLENCE_ABUSE）；高风险（CRISIS_SELF_HARM/VIOLENCE_ABUSE）`shouldStopDivination=true` 转现实支持；`validateOutput` 校验输出禁用词+医疗诊断+永恒承诺；`mapToExistingBoundaryTag` 联动状态机 SAFETY/BOUNDARY。
- **状态**：通过。

### 检查 16：占卜结果纠偏 ✅

- **核验文件**：`entry/src/main/ets/components/ResultFeedbackChips.ets`
- **结论**：5 Chips 齐全（这句话有点像我/有一部分不太像/帮我继续理一理/我只想安静一会儿/给我一个很小的建议）；「有一部分不太像」置 `userAcceptedInterpretation=false` 并回复「牌只是一个角度，你的真实感受始终比牌面更重要」；进入聊天后不强引用同一解释。
- **状态**：通过。

### 检查 17：结果进入聊天 ✅

- **核验文件**：`entry/src/main/ets/model/DivinationConversationContext.ets` + `XinglanTypes.ets`（`XinglanSessionState.divinationContext`）+ `XinglanChatPage.ets`
- **结论**：`DivinationConversationContext` 结构完整（mode/cardNames/orientations/positionNames/heartMode/coreSummary/userAcceptedInterpretation）；`XinglanSessionState.divinationContext` 可选字段携带上下文；注释明确「星澜不重新抽牌、不改正逆位、不推断新牌阵事实」。
- **状态**：通过。

### 检查 18：隐私存储 ✅

- **核验文件**：`DailyRitualStore.ets` + `EmotionStarStorage.ets` + `EmotionStarDailyAdapter.ets`
- **结论**：仅本地 Preferences 持久化（`daily_ritual_v1_state` / `emotion_star_records`），不联网、无账号、无云同步；只保存日期/方向/内容ID/完成状态/回望选择，不保存完整聊天、不做心理推断；`EmotionStarStorage` 注释明确「不上传服务器，不引入登录/账号/云同步」。
- **状态**：通过。

### 检查 19：减少动态效果 ✅

- **核验文件**：`DailyLightPage.ets` + `EveningReflectionCard.ets` + `XinglanChatPage.ets`
- **结论**：`DailyLightPage` 读取 `AppStorage.get<boolean>('reduceMotion')`；`reduceMotion=true` 时跳过星轨动画只做完成文案淡入；`EveningReflectionCard` 淡入降级（`duration: reduceMotion ? 0 : 180`）；`XinglanChatPage` 降噪模式进一步减少动效。符合 V2 计划 6.4 节性能降级。
- **状态**：通过。

### 检查 20：小屏与大字体 ✅

- **核验文件**：`DailyLightPage.ets` + `EveningReflectionCard.ets` + `WeeklyConstellationCard.ets` + `ResultFeedbackChips.ets`
- **结论**：页面使用 `Scroll` 容器与百分比宽度，小屏可滚动；文本 `textAlign(TextAlign.Center)` + `lineHeight` 避免大字体截断；Chips 圆角统一（`V2C_RADIUS_CHIP`/`V2B_RADIUS_CHIP`）按压态稳定；`accessibilityGroup` + `accessibilityText` + `accessibilityLevel('yes')` 支持 TalkBack。符合 V2 计划 18.2 节 UI 验收。
- **状态**：通过（建议真机小屏回归确认）。

---

## 四、红线词搜索与分类

搜索词集（AGENTS.md 第 5 节）：一定会 / 必然 / 命中注定 / 复合 / 复合概率 / 正缘 / 烂桃花 / 对方爱你 / 他爱你 / 她爱你 / 转运 / 财运 / 中奖 / 神准 / 灵验 / 改命 / 保证 / 你必须 / 马上断联 / 赶紧离开 / 你应该继续 / 你应该离开 / 亲爱的 / 宝贝 / 我一直在等你 / 我只属于你。

### A. 安全检测词库（正向，符合规范）✅

| 文件 | 行 | 用途 |
|---|---|---|
| `xinglan/data/XinglanTemplates.ets` | 119-128 | `FORBIDDEN_OUTPUT_PATTERNS` 输出禁用词库，供 `validateOutput` 校验拦截 |
| `xinglan/data/XinglanDirectReplies.ets` | 57 | `ROLE_NICKNAME.triggers` 检测用户输入「宝贝/亲爱的」（星澜拒绝并引导边界） |
| `xinglan/data/XinglanDirectReplies.ets` | 117 | `PREDICTION_BOUNDARY.triggers` 检测用户输入「能复合吗/什么时候转运」（触发边界回复） |
| `xinglan/engine/XinglanSafetyGuard.ets` | 109-161 | 7 类输入检测关键词库（PREDICTION/JUDGE_LOVE/DEPENDENCY/CRISIS 等） |
| `xinglan/data/XinglanKeywords.ets` | — | 关键词规则匹配库（检测用户输入） |
| `xinglan/engine/XinglanInterruptDetector.ets` | — | 中断检测逻辑（检测用户输入） |
| `xinglan/engine/XinglanReplyRelevanceGuard.ets` | — | 回复相关性守卫（检测） |
| `xinglan/engine/XinglanTopicSlotExtractor.ets` | — | 话题槽位提取（检测） |

### B. 正向声明注释（符合规范）✅

| 文件 | 行 | 内容 |
|---|---|---|
| `xinglan/data/XinglanBoundaryResponses.ets` | 16 | 注释「不使用任何红线词（一定、必然、命中注定、复合、正缘、转运等）」 |
| `xinglan/data/XinglanStructuredCopy.ets` | 20-22 | 注释「红线词零容忍：所有文案不含...」 |
| `data/XinglanResultCompanionText.ets` | 84 | 注释「红线遵守：不含「一定/必然/复合/命中注定/转运/你应该」等词」 |
| `daily/pages/DailyLightPage.ets` | 37 | 注释「不预测未来、不承诺复合、不替用户决定」 |
| `pages/XinglanChatPage.ets` | 294 | 注释「无「亲爱的/宝贝」等」 |

### C. 需留意但非违规（P2 观察）

| 文件 | 行 | 内容 | 评估 |
|---|---|---|---|
| `data/MVP8CardsData.ets` | 347 | `todayAction: '给自己写一封信，开头是：亲爱的自己，最近辛苦你了'` | 「亲爱的自己」是自我书信模板，非星澜对用户的亲密称呼，不违反红线（红线针对星澜称呼用户「亲爱的/宝贝」） |
| `data/PositiveHeartOptions.ets` | 304 | 同上「亲爱的自己」 | 同上 |
| `data/PositiveHeartOptions.ets` | 163 | `'这张牌不是在告诉你今天一定会发生好事'` | 否定句式纠偏文案，明确「不是...一定会」，属正向引导 |

### D. 用户可见输出违规 ❌

**未发现。** 所有红线词命中均属于检测词库、正向声明或非违规语境。

---

## 五、P0 / P1 / P2 问题清单

### P0（阻塞上架）— 0 项

**本轮未发现阻塞 V2 上架的 P0 问题。**

### P1（重要，建议上架前修复）— 0 项

无。

### P2（轻微，可后续迭代处理）— 1 项

| 编号 | 位置 | 描述 | 建议 |
|---|---|---|---|
| P2-1 | `data/MVP8CardsData.ets:347` / `data/PositiveHeartOptions.ets:304` | 「亲爱的自己」出现在自我书信模板的 todayAction 中 | 非违规（自我书信语境），但若后续红线扫描工具做字面匹配可能误报。可考虑改为「致：自己，最近辛苦你了」以彻底规避自动化扫描误判。非必须。 |

---

## 六、验收对照

| 验收要点 | 状态 |
|---|---|
| `deliverables/v2_final_acceptance_report.md` 已生成 | ✅ |
| 编译 ERROR=0 | ✅ BUILD SUCCESSFUL |
| 20 项检查全覆盖 | ✅ 逐项核验 |
| 红线词搜索区分正向输出与检测词库 | ✅ 已分类 A/B/C/D |
| P0/P1/P2 问题清单清晰 | ✅ P0=0, P1=0, P2=1 |
| 未修改任何 App 代码 | ✅ 只读回归 |
| 未使用 any / as any / @ts-ignore | ✅ 本轮无代码改动 |

---

## 七、仍需真机验证的项目

本轮为静态代码核验 + 编译验证，以下项目建议真机回归确认：

1. **今日星页**：首次展开动效时长 ≤1.2s；减少动态效果下降级为淡入；退出重进状态不丢失。
2. **情绪星点亮**：已点亮当天重复确认不累计；跨零点后次日重置。
3. **每周星图**：累计 7 次后周期 +1，星图完成动画。
4. **安静陪伴**：3 分钟无操作淡出；用户随时退出。
5. **情绪降噪**：连续短消息触发；20-50 字截断；用户主动退出后恢复正常。
6. **高风险拦截**：输入「不想活/想死」立即停止塔罗叙事并展示现实支持文案。
7. **小屏大字体**：长页面滚动完整，Chips 圆角按压态稳定，TalkBack 可读。
8. **占卜结果进聊天**：携带上下文后星澜不重新抽牌、不改正逆位。

---

## 八、交付说明

- **本报告**：`deliverables/v2_final_acceptance_report.md`
- **本轮代码改动**：无（只读回归）
- **前置文档**：`deliverables/xinglan_eval_framework.md`（20 维评测体系）、`deliverables/xinglan_regression_cases.md`（42 条回归用例）可配合真机回归使用。

**最终结论：V2 上架无阻塞，建议进入真机回归与人工评测阶段。**

# CHAT-4 情绪降噪 — 交接摘要

## 完成目标
在星澜聊天页实现情绪降噪模式：触发后每轮 20-50 字、最多两个 Chips、字号略增、行距增加、隐藏非必要入口、减少背景动效。

## 修改文件
- `entry/src/main/ets/pages/XinglanChatPage.ets`

## 新增内容（均在 XinglanChatPage.ets 内）
1. **CHAT-4 状态与常量**
   - `isNoiseReductionMode`：降噪模式开关（会话态，退出页面即恢复，不持久化）。
   - `showNoiseReductionPrompt`：入口提示显示状态。
   - `consecutiveShortMessages` / `lastMessageTimestamp`：连续短消息计数。
   - 通用降噪短文案池 `NOISE_REDUCTION_GENERIC_REPLIES`（20-50 字）。
   - 降噪专用 Chips：`再说一句`、`我先安静`。

2. **触发检测（四种条件）**
   - 用户主动表达：检测到「太多了 / 别说太长 / 少说一点 / 看不见 / 头晕」等关键词。
   - 焦虑强度高：输入中出现 ≥2 个焦虑关键词（焦虑、紧张、不安、害怕、心慌、很乱、很烦、想太多等）。
   - 连续发送多条短消息：连续 3 条长度 <10 的消息（30 秒内）。
   - 用户主动选择：点击入口提示的「少说一点」按钮进入。

3. **降噪模式行为**
   - 文案：优先从 `XinglanShortCorpus.ets` 取对应情绪的短文案，并通过 `clampNoiseReductionText` 限制在 20-50 字；无匹配时回退到通用降噪池。
   - 路由：进入降噪后不走完整聊天管线，直接返回短文案；点击「我先安静」进入 CHAT-3 安静模式；输入「恢复正常 / 正常显示」退出降噪。
   - UI：
     - 星澜气泡字号从 `V2B_FONT_BODY` 增大 1，行高从 27 增加到 32。
     - 仅显示两个降噪 Chips（再说一句 / 我先安静）+「恢复正常显示」按钮，隐藏夜信、镜子、回声卡、轻记得等入口。
     - 背景：`MoonlightLayer` 启用 `reducedMotion`，`StarBackground` 透明度降低。

4. **Builder 新增**
   - `buildNoiseReductionPrompt()`：入口提示「文字太多了吗？可以切换到更安静的回复。」+「少说一点」按钮。
   - `buildNoiseReductionChips()`：两个降噪 Chips。
   - `buildNoiseReductionRestoreButton()`：「恢复正常显示」按钮。

## 删除 / 未改内容
- 未删除任何旧逻辑。
- 未修改聊天核心管线（XinglanAnalyzer / XinglanComposer / XinglanRouter / XinglanDirectReplyEngine / XinglanSessionManager 等）。
- 未修改抽牌、历史、BGM、星历、UserProfileStore。
- 未修改 `main_pages.json` 或路由。
- 未持久化降噪状态，退出页面即恢复。

## 编译结果
- `assembleHap`：BUILD SUCCESSFUL
- ERROR：0
- WARN：194（均为既有 deprecation / classes-as-obj 警告，非本次引入）

## 验收要点
1. 编译 ERROR=0：通过。
2. 四种触发条件生效：显式关键词 / 焦虑强度高 / 连续短消息 / 主动点击「少说一点」。
3. 降噪态文案 ≤50 字、Chips ≤2：通过 `clampNoiseReductionText` 与 `buildNoiseReductionChips` 控制。
4. 可恢复正常显示：输入「恢复正常」或点击「恢复正常显示」按钮。
5. 不永久改变设置：未写入 Preferences，状态为会话级。

## 未完成项及原因
- 无。

## 下一步建议
- 可继续执行步骤 21：SAFE-1 边界与高风险增强。

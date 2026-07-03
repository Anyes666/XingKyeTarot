# CHAT-3 交接概览：安静陪伴模式

## 完成内容

在星澜聊天页 `XinglanChatPage.ets` 内实现安静陪伴模式 UI 态与入口/退出控制，不改动聊天核心管线、不自动发送新文本。

## 修改文件

- `entry/src/main/ets/pages/XinglanChatPage.ets`（唯一修改文件）
  - 新增 `isQuietMode` / `quietTextIndex` / `quietOpacity` 等状态
  - 新增 `QUIET_TEXTS` 文案轮换数组（4 条）
  - 新增安静模式控制方法：`enterQuietMode` / `exitQuietMode` / `onQuietSpeak` / `onQuietContinue` / `onQuietEnd`
  - 新增 3 分钟无操作淡出计时：`startQuietFadeTimer` / `resetQuietFadeOnInteraction`
  - 新增触发检测：`detectQuietTrigger`（覆盖"不想说/我不想说话/别问了/让我安静/安静待一会儿"等）
  - `parseNeedParam` 中 `need === QUIET` 直接进入安静模式
  - `sendMessage` 开头检测到"不想说"类文本直接进安静模式，不继续走聊天管线
  - `onQuestionOptionClick` 中点击 `quiet_none`（"我不想说话"）选项直接进入安静模式
  - `build()` 中条件渲染安静模式 UI，普通模式下保持原逻辑不变
  - 新增 `buildQuietMode()` Builder：月光下轮换文案 + 三按钮
  - 引入 `StarBackground` 作为星点装饰层，安静模式下透明度提高

## 允许修改范围

仅 `XinglanChatPage.ets` 的 UI 态与按钮逻辑。

## 严格未改动范围

- `XinglanSafetyGuard` / `XinglanComposer` / `XinglanRouter` / `XinglanAnalyzer` / `XinglanSessionManager` 等核心管线零改动
- 抽牌 / 历史 / BGM / 星历 / 星钥等级 未改动
- 未模拟心跳、眨眼或生命体征
- 未自动发送新文本
- 未使用 `any` / `as any` / `@ts-ignore`

## 安静模式行为

1. 入口：
   - 从聊天入口页选择「先安静陪我」（`need=QUIET`）直接进入
   - 对话中发送「不想说/别问了/我想安静」等触发词进入
   - 点击「陪我静」相处方式下的「我不想说话」选项进入
2. UI：
   - 只保留月光、水面、星点；隐藏普通 Chips、输入框、免责声明、消息列表活动元素
   - 顶部状态文案固定为「这里没有必须回答的问题」
   - 不显示「在线」状态
   - 月光缓慢呼吸（复用 `MoonlightLayer` 6s 循环）
3. 文案轮换：
   - 「不用说什么，也可以。」
   - 「这里没有需要立刻回答的问题。」
   - 「先让这一刻慢一点。」
   - 「不急着整理，停一会儿也好。」
4. 三按钮：
   - 「我想说一句」：退出安静模式，回到普通聊天输入
   - 「继续安静」：切换下一条文案并刷新淡出计时
   - 「结束这次陪伴」：退出安静模式并返回上一页
5. 无操作：
   - 3 分钟无操作后整体 UI 淡至 25% 透明度
   - 点击屏幕或任何按钮恢复不透明并重新计时
   - 不自动保存会话

## 编译结果

- 命令：`cd "D:\XingKeyTarot" && node "D:\HarmonyOS\DevEco Studio\tools\hvigor\bin\hvigorw.js" assembleHap --mode module -p module=entry@default -p product=default --no-daemon`
- 结果：**BUILD SUCCESSFUL**，ERROR=0
- WARN≈190，全部来自已有 pages/ 页面；`XinglanChatPage.ets` 仅新增 4 条 ArkTS deprecated API WARN（`animateTo` / `back` / `replaceUrl` 为 SDK 已废弃 API，与本次改动无关）

## 验收要点

- [x] 编译 ERROR=0
- [x] QUIET 入口可进入安静模式
- [x] 仅三按钮，无普通 Chips
- [x] 不自动发送新文本
- [x] 聊天核心管线逻辑未改

## 下一窗口

按 V2 计划继续后续 CHAT 步骤或进入 UI/UX 验收调整。

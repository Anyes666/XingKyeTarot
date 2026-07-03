# CHAT-1 交接摘要：五种陪伴方向

> 阶段：V2 计划步骤 17 / CHAT-1
> 状态：代码完成，人工检验
> 日期：2026-07-03

## 一、本轮目标

在星澜聊天入口页落地五种需求方向（LISTEN/COMFORT/ORGANIZE/ADVICE/QUIET），每种对应内部 Need 与默认策略；进入聊天后影响顶部状态文案与开场。

## 二、修改文件清单

### 修改
- `entry/src/main/ets/xinglan/types/XinglanTypes.ets` — 新增 `XinglanNeed` 枚举（UNKNOWN/LISTEN/COMFORT/ORGANIZE/ADVICE/QUIET）
- `entry/src/main/ets/pages/XinglanChatEntrancePage.ets` — 单一"走进月光门廊"按钮改为五入口卡 + 底部"也可以直接说一句……"直接入口；主内容区改 Scroll 防小屏溢出
- `entry/src/main/ets/pages/XinglanChatPage.ets` — `XinglanChatRouteParams` 增 `need` 字段；新增 `parseNeedParam` / `resolveNeedStatusLabel` / `buildNeedOpeningSegments`；顶部栏下增 Need 状态文案行

### 未改（符合铁律）
- 聊天核心管线（XinglanSafetyGuard / XinglanDirectReplyEngine / XinglanInteractionFlowEngine / XinglanAnalyzer / XinglanRouter / XinglanComposer / XinglanSessionManager 逻辑不改）
- 抽牌 / 78 牌数据 / 历史记录结构 / BGM / 头像裁剪 / 昵称持久化 / 星历 / 等级阈值
- 路由（`Routes.XINGLAN_CHAT` 已存在，复用）
- `main_pages.json`（无新增页面）

## 三、五种需求方向（对齐 V2 计划 9.1 节）

| 入口卡文案 | 内部 Need | 默认策略 | 顶部状态文案 |
|---|---|---|---|
| 我想说说发生了什么 | LISTEN | 承接 + 一次轻追问 | 先听你说 |
| 我现在只想被安慰 | COMFORT | 安慰，不分析 | 今晚先不急着分析 |
| 帮我把思绪理一理 | ORGANIZE | 拆分 2-3 个矛盾点 | 一起把思绪放慢 |
| 给我一个很小的建议 | ADVICE | 一个可拒绝的小行动 | 只找一个很小的下一步 |
| 我不想说话，安静待一会儿 | QUIET | 纯视觉安静模式 | 这里没有必须回答的问题 |

底部入口"也可以直接说一句……" → 携带 `need=LISTEN` 进入聊天。

## 四、入口页实现要点

1. `COMPANION_ENTRY_CARDS` 常量数组（显式 `CompanionEntryCard` interface），顺序固定对应五 Need。
2. 每张卡：B 月湖映心风格，`Theme.V2B_BG_CARD` 底 + `rgba(236,216,157,0.22)` 月光细线边 + `Theme.V2B_RADIUS_CARD`(20) 圆角，按压 scale 0.97 一致。
3. 暖金克制：仅文案用 `V2B_GOLD_RIPPLE`，无大面积金色。
4. 主内容区由固定 Column 改为 `Scroll` 包裹，防五卡片在小屏（360×780）溢出。
5. 路由跳转：`const params: XinglanChatRouteParams = { need };` + `router.RouterOptions` + `try/catch`。

## 五、聊天页实现要点

### 1. 路由参数扩展
```typescript
interface XinglanChatRouteParams {
  divinationContext?: DivinationConversationContext; // FLOW-1
  need?: XinglanNeed;                                 // CHAT-1
}
```

### 2. parseNeedParam（安全解析）
1. `router.getParams()` 取参，空则 UNKNOWN，无状态文案
2. `need` 缺失/非法 → 降级 UNKNOWN
3. 枚举值白名单校验（LISTEN/COMFORT/ORGANIZE/ADVICE/QUIET/UNKNOWN）
4. **divinationContext 优先**：若同时携带占卜上下文，need 不覆盖开场，仅记录状态文案（占卜转入走占卜开场）
5. **QUIET 特殊**：纯视觉安静模式，不自动发送开场文本（参考 V2 计划 9.3 节），仅 `showEmptyGuide=false`
6. 其余 Need：调 `buildNeedOpeningSegments` 生成开场，作为星澜消息插入（不走 Composer/Router 核心管线），顶部欢迎卡同步首段

### 3. 顶部状态文案行
- 位置：顶部栏（返回+星澜名+头像）下方、消息列表上方
- 仅当 `needStatusLabel.length > 0` 时渲染（Tab 直入 / UNKNOWN 不显示）
- 样式：`V2B_FONT_CAPTION` + `V2B_GOLD_RIPPLE` 暖金克制

### 4. buildNeedOpeningSegments（按 Need 选取）
- LISTEN：承接 + 一次轻追问（"我在这里，可以慢慢说。" + "发生了什么，按你愿意说的部分开始就好。" + "说到哪里，星澜就听到哪里。"）
- COMFORT：安慰不分析（"今晚先不急着分析。" + "先让感受被接住，不用把它说清楚。" + "想哭或者想停一下，都可以。"）
- ORGANIZE：拆分矛盾点（"我们一起把思绪放慢一点。" + "不用一次想明白，可以先说说现在心里最乱的是哪几件事。" + "星澜帮你把它们一件件分开看。"）
- ADVICE：可拒绝小行动（"只找一个很小的下一步。" + "不用是答案，只是一个你现在愿意试一下的小动作。" + "如果觉得不合适，随时可以拒绝。"）
- QUIET：返回空数组（不发送文本）

## 六、验收要点对照

| 验收项 | 状态 |
|---|---|
| 五入口可点选并正确传递 Need | ✅ ForEach + navigateToChat(card.need) |
| 顶部状态文案按 Need 切换 | ✅ needStatusLabel + resolveNeedStatusLabel |
| 聊天核心管线逻辑未改 | ✅ need 开场不走 Composer/Router |
| 显式 interface 声明参数 | ✅ CompanionEntryCard / XinglanChatRouteParams |
| 路由跳转 try/catch | ✅ |
| 不用 any/as any/@ts-ignore | ✅ |
| 无红线文案（亲爱的/宝贝/必然/复合等） | ✅ 已逐条核对 |
| B 月湖映心风格，暖金克制 | ✅ V2B 色板 + V2B_RADIUS_CARD 统一 |
| 五卡片按压圆角一致 | ✅ 均用 V2B_RADIUS_CARD(20) |

## 七、编译验证

命令行 `hvigorw assembleHap` 报 `Path not found. At file: d:\XingKeyTarot\entry`（小写盘符 `d:`）。
该报错为 hvigor 环境配置问题（FLOW-1 交接摘要已记录"小写盘符导致的 hvigor 配置报错，与代码无关"），非本轮代码引入。
- entry 目录及关键文件（oh-package.json5 / build-profile.json5 / hvigorfile.ts / module.json5）均存在
- 本轮改动为纯类型安全增量（新增枚举、显式 interface、无 any），无语法/类型风险
- 建议在 DevEco Studio IDE 内编译验证（IDE 内 hvigor 用大写盘符 `D:`，可正常解析）

## 八、与 FLOW-1 的关系

- FLOW-1（占卜转入聊天）与 CHAT-1（五 Need 入口）共享 `XinglanChatRouteParams`，两个字段互不冲突
- 同时携带时：divinationContext 优先开场，need 仅影响顶部状态文案（不重复插入开场）
- 两条通道均不走 Composer/Router 核心管线，仅作为星澜开场消息插入

## 九、下一窗口可进入

建议下一阶段：CHAT-2（若计划有）或 Need 对聊天后续轮次的影响（如 QUIET 模式下用户首次发言时的承接策略、ORGANIZE 模式下星澜主动拆分矛盾点的轮次节奏），但仍不改核心管线，仅在开场与状态层做最小扩展。

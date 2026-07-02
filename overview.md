# DAILY-3 交接报告：占卜 Tab 今日星页 Hero

## 完成内容

在占卜 Tab 顶部接入今日星页 Hero，展示未完成与已完成两种状态，提供进入今日星页与和星澜说话的入口。同时修复 DAILY-2 遗留的 DailyRitualStore.ets 编译错误。

## 修改与新增文件

### 新增

- `entry/src/main/ets/daily/components/DailyLightHeroCard.ets`：今日星页 Hero 卡组件。

### 修改

- `entry/src/main/ets/pages/MainFramePage.ets`：新增 import；仅在 `DivinationCenterTabContent` 的 Scroll 内 ForEach 之前插入 `DailyLightHeroCard`。
- `entry/src/main/ets/daily/service/DailyRitualStore.ets`：修复 DAILY-2 遗留的 12 个 ArkTS 严格类型 ERROR（逻辑不变）。

## Hero 两态说明

### 未完成态

- 小标：今日星页
- 主标题：今天，想怎样站在自己这一边？
- 副文案：用不到一分钟，为今天留下一点方向。
- 主按钮：展开今日星页

### 已完成态

- 小标：今天已经点亮
- 引文：显示今日 mainLine（来自 `findContentById(state.contentId)`）
- 主按钮：回看今日微光
- 次按钮：和星澜说一句

## 视觉

- C「星钥之书」为主：书页底色 `rgba(18,24,54,0.82)` + 烫金细线边框 `rgba(197,160,80,0.18)` + 烫金标题/文字。
- 入口处融入 B「月湖映心」：顶部极淡月光渐变 `rgba(212,172,77,0.05→0.06)`。
- 金色仅作细线、标题、按钮文字点缀，不铺大面积金。
- 主按钮圆角 `V2C_RADIUS_BTN`，按压 `scale 0.97`。
- 卡片宽 92%，与 DivinationEntryCard 左右对齐。
- 小屏由父容器 Scroll 承载滚动，不遮挡下方四个占卜入口。

## 状态来源

- `aboutToAppear` 异步读取 `DailyRitualStore.getTodayState(getContext(this))`，只读不写。
- 未修改 EmotionStarStorage、未修改抽牌算法、未修改占卜入口点击逻辑。
- 跳转通过回调注入：`onExpand` / `onReview` / `onChatWithXinglan`。

## 修复 DAILY-2 遗留编译错误

DailyRitualStore.ets 存在 12 个 ArkTS 严格类型 ERROR（DAILY-2 交接报告声称 ERROR=0 但实际未通过编译），阻碍 DAILY-3。修复方式（逻辑不变）：

1. 5 处对象 spread `{...state, ...}` → 新增私有 `cloneState(state)` helper + 字段覆盖。
2. 补 import `ReflectionChoice`（原文件用了但未导入）。
3. `for...of` 遍历 `Object` → 先 `as Object[]` 断言。
4. `string` → `DailyDirection` / `ReflectionChoice` → 加 `as` enum 断言（与文件既有 `as Record<string,Object>` 风格一致）。

## 编译结果

```
BUILD SUCCESSFUL in 5s 780ms
ERROR: 0
WARN: 既有（DailyLightHeroCard.ets:51 的 getContext 同类 lint，与 MainFramePage.ets 既有 WARN 同类，非新增违规）
```

## 验收对照

| 验收要点 | 结果 |
| --- | --- |
| 编译 ERROR=0 | ✅ BUILD SUCCESSFUL，ERROR=0 |
| Hero 在占卜 Tab 顶部 | ✅ Scroll 内 ForEach 之前 |
| 未完成/已完成两态正确 | ✅ 由 state.completed 切换，已完成态展示 mainLine |
| 未遮挡现有占卜四个入口 | ✅ Hero 在滚动区顶部，五个 DivinationEntryCard 在下方正常滚动 |
| MainFramePage 仅改 DivinationCenterTabContent 区域 | ✅ 只加 import + Scroll 内插入 Hero，未动其他 Tab/底部导航/路由 |
| 暖金克制，无大面积金色 | ✅ 金色仅用于细线/标题/按钮文字/细边 |

## 截图验收点

1. 占卜 Tab 顶部出现今日星页 Hero 卡，下方五个占卜入口（每日一占/圣三角/关系探索/旋转牌轮/历史查看）正常显示。
2. 未完成态：标题「今日星页」+ 主标题 + 副文案 + 「展开今日星页」按钮。
3. 已完成态（需先有 completed=true 的 state）：标题「今天已经点亮」+ mainLine 引文 + 「回看今日微光」+「和星澜说一句」。
4. 顶部烫金细线、卡片烫金细边，整体深夜蓝黑底，无大面积金色。
5. 小屏滚动顺畅，Hero 不遮挡下方入口，底部 COMPLIANCE_FOOTER 正常。

## 未完成项与原因

- `onExpand` / `onReview` 跳转目标 `DailyLightPage` 尚未创建（属 DAILY-4 范围），当前为 TODO 占位回调，点击仅做按压反馈。
- `DailyDirectionChip.ets`（V2 计划中 DAILY-3 提到的方向选择 Chip）未创建：用户本轮任务描述未要求方向选择，方向选择归 DAILY-4 展开流程。

## 给下一个窗口（DAILY-4）的交接

- DAILY-4 创建 `DailyLightPage.ets` 后：
  1. 在 `Routes.ets` 新增 `DAILY_LIGHT` 路由。
  2. 将 `MainFramePage.ets` 中 `DailyLightHeroCard` 的 `onExpand` / `onReview` TODO 替换为 `router.pushUrl(Routes.DAILY_LIGHT)`。
- Hero 已完成态的 mainLine 来自 `findContentById(state.contentId)`，DAILY-4 完成流程需调用 `DailyRitualStore.markCompleted(state, ctx)` 持久化 completed=true。
- `DailyRitualStore` 已可正常编译，cloneState helper 可复用。

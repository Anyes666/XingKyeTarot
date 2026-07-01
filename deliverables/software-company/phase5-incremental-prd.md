# 星钥塔罗 Phase 5 增量 PRD

> **文档版本**：v1.0
> **日期**：2026-07
> **编写人**：产品经理 Alice
> **项目**：星钥塔罗（XingKey Tarot）— HarmonyOS 本地离线塔罗式情绪陪伴 App
> **范围**：将 14 个高保真 HTML 原型落地为 ArkTS 页面

---

## 1. 增量范围

### 1.1 14 个原型按改动类型分类

| 改动类型 | 数量 | 原型编号 | 说明 |
|---------|------|---------|------|
| **视觉迁移** | 11 | #02, #03, #04, #06, #07, #09, #10, #11, #12, #13, #14 | ArkTS 页面已存在且功能完整，仅按原型更新视觉样式（Token 从旧版迁移到 V2 系列，布局/间距/圆角/字体对齐原型） |
| **新建页面** | 2 | #01, #05 | 无对应 ArkTS 页面，需创建 `.ets` 文件并注册路由 |
| **新建组件** | 1 | #08 | 弹窗组件，嵌入其他页面，不需注册路由 |

### 1.2 三批次划分（P0 / P1 / P2）

| 批次 | 优先级 | 原型编号 | 页面数 | 划分理由 |
|------|--------|---------|--------|---------|
| **第一批** | P0 | #04, #06, #07, #10, #11, #12, #13, #14 | 8 | 页面已存在、功能完整，仅视觉迁移，风险最低；且覆盖占卜全流程链路（问心→抽牌→结果），可快速验证 V2 Token 体系可用性 |
| **第二批** | P1 | #02, #03, #09 | 3 | 页面已存在但改造量较大：聊天页气泡样式重构、情绪星 B+A 混合动画、我的页布局重构 |
| **第三批** | P2 | #01, #05, #08 | 3 | 需新建页面/组件，需注册路由，依赖 P0/P1 完成后组件库更完善时再做 |

**批次依赖关系**：P1 依赖 P0 建立的 C 方案实现模式（#04 令牌基准页）；P2 依赖 P1 完成的 MoonlightLayer 等公共组件。

---

## 2. 待确认问题默认处理方案

> 以下为针对交接说明第 10.3 节 8 个待确认问题的**默认假设**，标注「默认假设，可被用户覆盖」。开发团队可据此直接开工，无需等待确认。

| # | 问题 | 默认处理方案 | 依据 |
|---|------|------------|------|
| Q1 | 原型 01（聊天入口）是否作为独立路由页？ | **独立路由页**。新建 `XinglanChatEntrancePage.ets`，注册路由 `Routes.XINGLAN_CHAT_ENTRANCE` | 交接说明 3.1 表已注明"需新建" |
| Q2 | 原型 05（星历）新建独立页还是嵌入 SettingsPage？ | **新建独立页**。新建 `StarCalendarPage.ets`，注册路由 `Routes.STAR_CALENDAR` | 交接说明 3.1 表已注明"需新建" |
| Q3 | 等级弹窗（#08）触发时机？ | **点亮情绪星后立即弹出**。在 `EmotionStarPage` 中，用户点亮情绪星后触发 `LevelUpPopup`，提供仪式感 | 仪式感优先，避免下次进入 App 时用户已遗忘上下文 |
| Q4 | SettingsPage 是否重命名为 MyPage？ | **不重命名，保持 `SettingsPage.ets` 原名** | 项目铁律禁止改 App 名等关键标识；重命名会扩散影响路由注册、import 引用等 |
| Q5 | 78 张牌面图资源是否齐全？ | **交付前架构师阶段核查**。开发阶段先用 `TarotCardImage` 组件统一调用，若缺图则显示占位框 | 交接说明 8.4 已说明牌面图在 `resources/media/` 下已有 |
| Q6 | 文案池未建，先接占位还是等文案池？ | **先接占位文案**。原型 HTML 中的文案直接硬编码，后续替换为 `CopywritingService.getCopy(categoryKey)` | 交接说明 6.3 已明确允许"文案池未建之前先用占位文案" |
| Q7 | 关系探索"边界提醒"文案是否需产品确认措辞？ | **按交接说明 4.2.6 温柔措辞**。"关系探索不判断对方心意，只陪你看清自己的感受" | 交接说明 4.2.6 已给出标准文案，内容铁律已覆盖 |
| Q8 | 星钥等级阈值数据不一致 | **以交接说明 5.4 表格为准**：0/1/7/21/30/90/180/365 天（8 级）。10.3 节问题 8 中写的 0/1/7/14/30/60/90/180 与 5.4 不一致，以 5.4 为权威 | 5.4 为固定称号数据表，10.3 为待确认问题清单（本身存疑） |

**等级阈值对照表（以 5.4 为准）**：

| 序号 | 天数阈值 | 称号 |
|------|---------|------|
| 1 | 0 天 | 初见 |
| 2 | 1 天 | 星火初亮 |
| 3 | 7 天 | 七日星轨 |
| 4 | 21 天 | 月下自省者 |
| 5 | 30 天 | 星钥守望者 |
| 6 | 90 天 | 星河同行者 |
| 7 | 180 天 | 半年听心者 |
| 8 | 365 天 | 长夜星澜 |

---

## 3. 用户故事

### 3.1 P0 批次：占卜流程链路

| # | 用户故事 |
|---|---------|
| P0-US1 | 作为一个想要自我探索的用户，我想在占卜中心看到所有占卜入口（单牌/圣三角/关系探索），这样我可以根据当前心境选择合适的占卜方式 |
| P0-US2 | 作为一个有具体心事的用户，我想在问心页选择情绪标签，这样星澜能理解我的处境并给出有针对性的解读 |
| P0-US3 | 作为一个等待结果的用户，我想看到流畅的抽牌动画（牌背淡入→翻牌→正面展示），这样我能感受到仪式感而非机械操作 |
| P0-US4 | 作为一个抽到牌的用户，我想在结果页看到牌面、关键词、金句和深度解读，这样我能获得有深度的自我觉察而非空洞预言 |
| P0-US5 | 作为一个探索关系的用户，我想在关系探索结果页看到多张牌的交叉解读和边界提醒，这样我能看清自己的感受而非被判断对方心意 |
| P0-US6 | 作为一个对塔罗牌好奇的用户，我想在卡牌总览页浏览 78 张牌，并点击进入详情页查看每张牌的含义 |

### 3.2 P1 批次：陪伴感强化

| # | 用户故事 |
|---|---------|
| P1-US1 | 作为一个深夜焦虑的用户，我想在星澜聊天页看到温柔的月光氛围和星澜的回应气泡，这样我感到被陪伴而非被评判 |
| P1-US2 | 作为一个每天使用 App 的用户，我想在点亮情绪星时看到星光动画和星澜的反馈，这样我的坚持被看见和认可 |
| P1-US3 | 作为一个老用户，我想在"我的"页面看到清晰的等级称号、使用统计和设置入口，这样我能管理自己的探索旅程 |

### 3.3 P2 批次：入口与仪式感

| # | 用户故事 |
|---|---------|
| P2-US1 | 作为一个新用户，我想在聊天入口页看到星澜的月光门廊和引导文案，这样我能自然地进入对话而非面对空白 |
| P2-US2 | 作为一个长期用户，我想在星历页看到我的占卜记录以日历形式呈现，这样我能回顾自己的情绪轨迹 |
| P2-US3 | 作为一个达到新等级的用户，我想在升级时看到烫金弹窗和寄语，这样里程碑被仪式化地庆祝 |

---

## 4. 需求池（P0 / P1 / P2）

### 4.1 P0 批次需求项（8 个视觉迁移页面）

| 需求ID | 原型# | 目标文件 | 改动要点 | 验收标准 |
|--------|------|---------|---------|---------|
| P0-01 | #04 | `ResultGoldenPage.ets` | 令牌基准页：C 方案完整色彩体系 + B 月光光晕 + 烫金线装饰 + 标准卡片结构（牌面+牌名+关键词+金句+深度解读+免责声明）；旧 Token 全部替换为 V2C/V2B 系列 | V2C Token 使用率 100%；`ComplianceFooter` 组件已引入；月光光晕动画正常；assembleHap ERROR=0 |
| P0-02 | #06 | `TarotCardsPage.ets` | C 方案卡牌总览：78 张牌网格布局 + LazyForEach 异步加载 + 烫金书脊线分隔 + 点击跳转详情页 | V2C Token 使用率 100%；LazyForEach 已用；78 张牌可滚动浏览无卡顿；assembleHap ERROR=0 |
| P0-03 | #07 | `TarotCardDetailPage.ets` | C 方案卡牌详情：衬线标题 + 大牌面图 + 牌义解读 + 正逆位切换 + 免责声明 | V2C Token 使用率 100%；`TarotCardImage` 组件已用；正逆位可切换；`ComplianceFooter` 已引入；assembleHap ERROR=0 |
| P0-04 | #10 | `DivinationCenterPage.ets` | C+B 混合占卜中心：月光光晕 + 占卜入口卡列表（单牌/圣三角/关系探索）+ 点击跳转对应流程 | V2C+V2B Token 使用率 100%；月光动画正常；3 个入口卡可点击跳转；assembleHap ERROR=0 |
| P0-05 | #11 | `AskHeartPage.ets` | C 方案问心页：6 选项卡（被接住/看见光双模式）+ 选中态金色边框 + 按压 scale(0.97) + 防重复跳转 `isTransitioning` | V2C Token 使用率 100%；双模式可切换；按压态动画正常；选中后跳转 CardDrawPage；assembleHap ERROR=0 |
| P0-06 | #12 | `CardDrawPage.ets` | C+B 混合抽牌动画：月光光晕 + 状态机（loading→fadeIn→flipping→revealed→particles→done）+ `.rotate({ y: flipAngle })` 翻牌 + 防重复跳转 | V2C+V2B Token 使用率 100%；6 阶段动画时序正确；`animPhase==='done'` 时 return 防重复；assembleHap ERROR=0 |
| P0-07 | #13 | `TriangleResultPage.ets` | C 方案圣三角结果：3 牌位垂直/水平堆叠 + 位置标题 + `ResultCardSlot` 组件 + 综合解读展开态 + "再听星澜说一句" + 自动保存历史 | V2C Token 使用率 100%；`CompanionResultLines` 已接入；`hasHeardCompanionResult` 限 1 次；`ComplianceFooter` 已引入；assembleHap ERROR=0 |
| P0-08 | #14 | `RelationResultPage.ets` | C 方案关系探索结果：多牌交叉解读 + `BoundaryReminder` 边界提醒组件（温柔措辞）+ "再听星澜说一句" + 自动保存历史 | V2C Token 使用率 100%；边界提醒文案符合铁律（不判断对方心意）；`ComplianceFooter` 已引入；assembleHap ERROR=0 |

### 4.2 P1 批次需求项（3 个已有页改造）

| 需求ID | 原型# | 目标文件 | 改动要点 | 验收标准 |
|--------|------|---------|---------|---------|
| P1-01 | #02 | `XinglanChatPage.ets` | B 方案聊天页：月光呼吸层 + 星澜气泡样式（圆润 20px 圆角）+ 用户气泡 + 打字动画 + 气泡淡入 180ms | V2B Token 使用率 100%；月光动画 6s 循环正常；气泡淡入动画正常；`aboutToDisappear` 停止动画；assembleHap ERROR=0 |
| P1-02 | #03 | `EmotionStarPage.ets` | B+A 混合情绪星点亮：B 月湖氛围 + A 星图标记感星点 + 点亮动画 650ms + 星澜反馈文案 + 点亮后触发 `LevelUpPopup` | V2B+V2A Token 使用率 100%；星点点亮动画正常；`LevelUpPopup` 触发逻辑正确；assembleHap ERROR=0 |
| P1-03 | #09 | `SettingsPage.ets` | A+B 混合我的页面（不重命名）：A 星图档案布局 + B 月光底色 + 等级称号展示 + 使用统计 + 设置入口列表 | V2A+V2B Token 使用率 100%；文件名保持 `SettingsPage.ets`；等级称号显示正确；assembleHap ERROR=0 |

### 4.3 P2 批次需求项（新建页面 + 组件）

| 需求ID | 原型# | 目标文件 | 改动要点 | 验收标准 |
|--------|------|---------|---------|---------|
| P2-01 | #01 | `XinglanChatEntrancePage.ets`（新建） | B 方案聊天入口：月光门廊（强光态 0.08）+ 星澜引导文案 + 进入聊天按钮 + 路由注册 | 新文件已创建；`Routes.XINGLAN_CHAT_ENTRANCE` 已添加；`main_pages.json` 已注册；V2B Token 使用率 100%；路由可跳转；assembleHap ERROR=0 |
| P2-02 | #05 | `StarCalendarPage.ets`（新建） | A 方案星历：日历网格 + 占卜记录标记（已查看/未查看圆点）+ 等级进度 + 路由注册 | 新文件已创建；`Routes.STAR_CALENDAR` 已添加；`main_pages.json` 已注册；V2A Token 使用率 100%；路由可跳转；assembleHap ERROR=0 |
| P2-03 | #08 | `LevelUpPopup.ets`（新建组件） | A+C 混合等级弹窗：底部滑入 220ms + 烫金横线 + 衬线称号大字 + 勋章 + 寄语 + "继续旅程"按钮 | 新组件已创建；不需注册路由；底部滑入动画正常；称号数据按 5.4 表格（8 级）；由父页面 `@State showLevelUp` 控制；assembleHap ERROR=0 |

### 4.4 路由新增项

| 路由常量 | 值 | 注册位置 |
|---------|-----|---------|
| `Routes.XINGLAN_CHAT_ENTRANCE` | `'pages/XinglanChatEntrancePage'` | `Routes.ets` + `main_pages.json` |
| `Routes.STAR_CALENDAR` | `'pages/StarCalendarPage'` | `Routes.ets` + `main_pages.json` |

### 4.5 建议新增公共组件（P2 阶段）

| 组件文件 | 组件名 | 使用页面 | 说明 |
|---------|--------|---------|------|
| `MoonlightLayer.ets` | MoonlightLayer | #01, #02, #03, #04, #09, #10, #12 | 月光呼吸层，参数 `strong: boolean`，降级为静态光斑 |
| `CardFrame.ets` | CardFrame | #04, #06, #07, #12, #13, #14 | 标准牌面框（烫金细线 + 装饰星 + 圆角），支持多种尺寸 |
| `BoundaryReminder.ets` | BoundaryReminder | #14 | 边界提醒卡（浮层底色 + 烫金竖线 + 温柔文案） |
| `LevelUpPopup.ets` | LevelUpPopup | #03（嵌入） | 等级升级弹窗 |

> **注意**：`MoonlightLayer` 和 `CardFrame` 为建议抽取的公共组件，P0 阶段可先在页面内直接实现，P2 阶段统一抽取。`BoundaryReminder` 和 `LevelUpPopup` 为必须新建组件。

---

## 5. UI 设计稿引用

14 个高保真原型 HTML 路径索引（开发时对着原型抄，不重复原型内容）：

| # | 原型文件路径 | 页面中文名 | 设计方案 |
|---|------------|-----------|---------|
| 01 | `D:/XingKeyTarot/deliverables/prototypes/01-chat-entrance.html` | 星澜聊天入口页（月光门廊） | B 月湖映心 |
| 02 | `D:/XingKeyTarot/deliverables/prototypes/02-chat-page.html` | 星澜聊天页 | B 月湖映心 |
| 03 | `D:/XingKeyTarot/deliverables/prototypes/03-star-lit-success.html` | 点亮情绪星成功页 | B + A 标记感 |
| 04 | `D:/XingKeyTarot/deliverables/prototypes/04-card-result.html` | 卡牌结果页（每日一占）★令牌基准页 | C 星钥之书 + B 月光 |
| 05 | `D:/XingKeyTarot/deliverables/prototypes/05-star-calendar.html` | 星澜星历 | A 星图档案 |
| 06 | `D:/XingKeyTarot/deliverables/prototypes/06-cards-overview.html` | 卡牌总览（星钥之书） | C 星钥之书 |
| 07 | `D:/XingKeyTarot/deliverables/prototypes/07-card-detail.html` | 卡牌详情 | C 星钥之书 |
| 08 | `D:/XingKeyTarot/deliverables/prototypes/08-level-up-popup.html` | 星钥等级升级弹窗 | A 星图档案 + C 烫金标题 |
| 09 | `D:/XingKeyTarot/deliverables/prototypes/09-my-page.html` | 我的页面 | A + B 月光底色 |
| 10 | `D:/XingKeyTarot/deliverables/prototypes/10-divination-center.html` | 占卜中心 | C 星钥之书 + B 月光 |
| 11 | `D:/XingKeyTarot/deliverables/prototypes/11-ask-heart.html` | 问心/输入心事 | C 星钥之书（纯卡牌） |
| 12 | `D:/XingKeyTarot/deliverables/prototypes/12-card-draw.html` | 抽牌动画 | C 星钥之书 + B 月光 |
| 13 | `D:/XingKeyTarot/deliverables/prototypes/13-triangle-result.html` | 圣三角结果 | C 星钥之书（纯卡牌） |
| 14 | `D:/XingKeyTarot/deliverables/prototypes/14-relation-result.html` | 关系探索结果 | C 星钥之书（纯卡牌） |

**设计系统参考文档**：
- `D:/XingKeyTarot/deliverables/design-system-tokens.md` — 完整 Token 体系
- `D:/XingKeyTarot/deliverables/design-system-proposals-v2.md` — A/B/C 三套方案完整定义
- `D:/XingKeyTarot/deliverables/星钥塔罗_设计稿开发交接说明.md` — 开发交接主索引

**令牌基准页**：原型 #04（`04-card-result.html`）为 C 方案实现基准，其他 C 方案页面的 Token 用法参考 #04。

---

## 6. 内容底线（铁律）

> 以下为星澜内容铁律，设计稿已执行，开发落地时继续遵守。违反将导致内容合规问题。

### 6.1 禁止出现的内容

- ❌ 算命承诺 / 必然发生 / 改命转运 / 招桃花 / 强复合
- ❌ 疾病、生死、法律、投资结论
- ❌ 复合概率 / 对方心意判断 / 财运预测 / 运势排名
- ❌ 开运转运 / 改命 / 付费抽命运
- ❌ 恋爱好感度 / 强签到 / 断签惩罚

### 6.2 必须保留的内容

- ✅ 所有结果页保留免责声明：「结果仅供娱乐与自我探索参考，不构成任何专业建议」
- ✅ 关系探索页不判断对方心意，只陪用户看清自己的感受、期待与边界
- ✅ 边界提醒文案（#14 关系探索）：「关系探索不判断对方心意，只陪你看清自己的感受」

### 6.3 合规组件

| 组件 | 位置 | 用途 |
|------|------|------|
| `ComplianceFooter.ets` | `components/ComplianceFooter.ets` | 已封装免责声明文案，结果页/占卜中心/卡牌详情必须引入 |

**需引入 ComplianceFooter 的页面**：#04 卡牌结果、#07 卡牌详情、#10 占卜中心、#13 圣三角结果、#14 关系探索结果。

---

## 7. 工程约束

### 7.1 编译验证

- 每批次完成后必须 `assembleHap` 编译验证
- **`ERROR = 0` 为第一验收标准**，编译不过的代码不允许合入
- `WARN` 分阶段处理，不为清 WARN 破坏主流程
- `ERROR > 0` → 先修 ERROR，禁止扩功能

### 7.2 禁止操作

- ❌ 一次性大规模重构项目
- ❌ 新增未要求的功能（严格基于 14 个原型）
- ❌ 重写隐私政策和用户协议
- ❌ 删除旧页面
- ❌ 改 App 名
- ❌ 把「星澜」改回「月见」
- ❌ 清空用户历史数据（除非任务明确要求）
- ❌ 用 `string` / `any` 糊弄编译
- ❌ 伪造保存图片成功

### 7.3 ArkTS 严格类型规则

| 禁止 | 必须 |
|------|------|
| 匿名对象类型 `{ a: string }` | 显式 `interface` 或 `class` 声明所有对象结构 |
| `Array<{ ... }>` 内联匿名类型 | 先声明 interface，再 `Array<MyInterface>` |
| `Record<string, Object>` | 使用具体值类型 |
| `any` 类型 | 使用明确类型 |
| `as` 强行类型断言 | 安全类型转换（字段校验后赋值） |
| `return { ... }` 直接返回匿名对象 | 先声明变量再 return |
| `router.pushUrl({ url, params: {...} })` 内联匿名 | 先声明 `params` 变量，再声明 `router.RouterOptions` |
| UI 闭包内写 `const`/`let`/赋值 | UI 结构外声明变量 |
| UI 闭包内裸调用函数 | UI 结构内只调用组件构建器 |

### 7.4 文件修改约束

- **只改指定文件，不扩散**：每个需求项只改"目标文件"列中列出的文件
- 新建页面需 `@Entry` + `@Component` + `main_pages.json` 注册
- 新建组件（非页面）不需要在 `main_pages.json` 注册
- 路由跳转必须 `try/catch`
- `getParams` 后需字段校验
- `JSON.parse` 后需校验字段存在性

### 7.5 性能注意事项

- 月光呼吸动画 `iterations: -1` 页面 `aboutToDisappear` 时停止
- 卡牌总览页 78 张图用 `LazyForEach` + 异步加载
- 翻牌动画 `.rotate({ y: angle })` 需验证低版本 ArkUI 兼容性
- C 方案衬线字体 `HarmonyOS Serif` 若无中文衬线字形，需评估是否打包 `Noto Serif SC`（约 4MB）

---

## 8. 验收标准

### 8.1 编译验收（第一验收标准）

| 验收项 | 标准 |
|--------|------|
| assembleHap | `ERROR = 0` |
| WARN | 分阶段处理，不阻塞合入 |

### 8.2 路由验收

| 验收项 | 标准 |
|--------|------|
| 新增路由 | `Routes.XINGLAN_CHAT_ENTRANCE` + `Routes.STAR_CALENDAR` 可正常跳转 |
| `main_pages.json` | 2 个新页面已注册 |
| 现有路由 | 11 个已有页面路由不受影响，跳转正常 |

### 8.3 视觉验收

| 验收项 | 标准 |
|--------|------|
| V2 Token 使用率 | 100%（14 个页面无硬编码颜色值） |
| 方案匹配 | 每个页面使用正确的设计方案（B/C/A），Token 引用正确 |
| 令牌基准页 | #04 卡牌结果页作为 C 方案基准，其他 C 方案页面 Token 用法一致 |

### 8.4 功能验收

| 验收项 | 标准 |
|--------|------|
| 占卜流程链路 | 问心(#11) → 抽牌(#12) → 结果(#04/#13/#14) 全流程可走通 |
| 卡牌浏览 | #06 总览 → #07 详情 可跳转，78 张牌可浏览 |
| 占卜中心 | #10 入口卡可跳转到 3 个占卜流程 |
| 聊天入口 | #01 新建页可进入 #02 聊天页 |
| 星历 | #05 新建页可展示日历和记录标记 |
| 等级弹窗 | #08 组件在 #03 情绪星点亮后正常弹出 |
| 防重复跳转 | #11/#12 的 `isTransitioning` / `animPhase==='done'` 逻辑有效 |

### 8.5 内容验收

| 验收项 | 标准 |
|--------|------|
| 免责声明 | #04, #07, #10, #13, #14 页面 `ComplianceFooter` 已引入 |
| 无算命承诺 | 全局搜索无"必然"/"必定"/"复合概率"/"财运"等违规词 |
| 关系探索边界 | #14 `BoundaryReminder` 文案符合铁律 |
| 等级数据 | #08 称号数据按 5.4 表格（0/1/7/21/30/90/180/365 天，8 级） |

### 8.6 验收清单汇总

| # | 验收维度 | 量化标准 | 优先级 |
|---|---------|---------|--------|
| 1 | 编译 | assembleHap ERROR=0 | P0（必须） |
| 2 | 路由 | 2 个新路由可正常跳转 | P0（必须） |
| 3 | 视觉 | V2 Token 使用率 100% | P0（必须） |
| 4 | 功能 | 14 个页面核心流程可走通 | P0（必须） |
| 5 | 内容 | 免责声明齐全，无算命承诺 | P0（必须） |
| 6 | 性能 | 78 张牌 LazyForEach 加载无卡顿 | P1（应该） |
| 7 | 动画 | 月光呼吸/翻牌/按压态动画正常 | P1（应该） |
| 8 | 字体 | C 方案衬线标题正常显示 | P2（最好） |

---

## 附录：执行顺序建议

### 第一批（P0 · 8 个页面视觉迁移）

```
#04 卡牌结果（令牌基准页，建立 C 方案实现模式）
  ↓
#06 卡牌总览 + #07 卡牌详情（复用 #04 的卡牌组件模式）
  ↓
#11 问心 → #12 抽牌 → #13 圣三角 → #14 关系探索（占卜流程链路）
  ↓
#10 占卜中心（入口页，链接到上述流程）
  ↓
assembleHap 验证 ERROR=0
```

### 第二批（P1 · 3 个页面改造）

```
#02 聊天页（B 方案气泡 + 月光层）
  ↓
#03 情绪星（B+A 混合 + 星点动画 + LevelUpPopup 触发）
  ↓
#09 我的页（A+B 混合 + 布局重构，不重命名）
  ↓
assembleHap 验证 ERROR=0
```

### 第三批（P2 · 新建页面 + 组件）

```
新建 MoonlightLayer / CardFrame / BoundaryReminder 公共组件
  ↓
#01 聊天入口（依赖 MoonlightLayer）
  ↓
#05 星历（A 方案日历组件）
  ↓
#08 等级弹窗（LevelUpPopup 组件）
  ↓
assembleHap 验证 ERROR=0
```

---

> **文档结束**
> 本 PRD 基于《星钥塔罗_设计稿开发交接说明》14 个原型，结合项目 MEMORY 工程铁律和 Theme.ets V2 Token 体系编制。所有默认假设标注「可被用户覆盖」，开发团队可据此直接开工。

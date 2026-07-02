# Stitch / Nano Banana Pro 原型到 ArkUI 映射报告

## 0. 本轮范围与假设

- 本报告基于 `deliverables/stitch_redesign` React 原型、当前 ArkTS 工程、`AGENTS.md` 中 A / B / C 三套 v2 视觉系统生成。
- 本轮只生成 UI 焕新映射报告，不修改任何 App 代码、不修改 ArkTS、不编译。
- 核心假设：Stitch 原型只作为视觉参考，不作为架构、逻辑、文案或数据来源。
- 成功标准：后续 UI 任务可以按本报告分 Phase 落地，并始终保留现有 ArkTS 路由、数据结构、抽牌逻辑、聊天管线、BGM、头像与星历持久化规则。

## 1. Stitch 原型结构摘要

### 1.1 原型技术栈

- React 19 + React DOM。
- Vite 6 + TypeScript。
- Tailwind CSS v4，通过 `@tailwindcss/vite` 和 `@import "tailwindcss"` 使用。
- `motion/react` 提供 `motion`、`AnimatePresence`、页面入场、卡牌翻转、粒子、缩放、旋转等动效。
- `lucide-react` 提供图标。
- `express` + `@google/genai` + `dotenv` 支撑 `server.ts` 与 Gemini API。

结论：以上技术栈均不可迁移到 HarmonyOS / ArkUI。ArkUI 只能吸收视觉语言，不能照搬 React 组件结构、Tailwind class、motion 动效写法或 lucide 图标依赖。

### 1.2 主要组件

- `App.tsx`：单页容器，维护 `currentTab`、`tarotSubView` 和 `history`，底部 5 Tab，使用 `localStorage` 保存历史。
- `DailyDraw.tsx`：单牌抽牌、焦点 Chip、问题输入、Gemini 解读、翻牌动画、结果阅读卡片。
- `HolyTriangle.tsx`：三牌抽牌、过去/现在/未来分区、问题输入、三牌结果阅读。
- `CardWheel.tsx`：旋转牌轮、12 张主牌视觉环、连续 requestAnimationFrame 旋转、三张选择、结果合成。
- `XinglanChat.tsx`：联网聊天、预设提示、输入框、气泡、typing 动效。
- `XinglanQuotes.tsx`：星澜语录，使用星澜人物大图作为背景，点击生成星点粒子并调用 `/api/tarot/quote`。
- `HistoryArchive.tsx`：历史列表、搜索、过滤、详情浮层。
- `UserProfile.tsx`：我的页、签到动效、统计卡、主星属性、成就。
- `tarotData.ts`：22 张主阿卡纳演示数据，不是项目真实 78 张数据。

### 1.3 样式来源

- 深色星空背景：`#02050e`、`#030612`、`slate-950`、`indigo-950`。
- 小面积琥珀金：`amber-200/300/400/500/600` 用于标题、边框、选中态、按钮。
- 卡片样式：深蓝黑半透明底、细边框、轻 shadow、`rounded-xl` / `rounded-2xl`。
- 背景层：CSS data SVG 星点、`twinkling` 闪烁动画、径向渐变、顶部/底部遮罩。
- 动效：fade / slide / scale / rotate / flip / spin / particle / bounce。

可吸收的是层次、色彩比例、卡片阅读感、月光氛围；不可吸收的是 Tailwind class、CSS keyframes、复杂粒子和连续强旋转。

### 1.4 图片资源

- `src/assets/images/xinglan_goddess_1782918266274.jpg`
- 尺寸：768 x 1376，约 898 KB，竖版 JPG。
- 画面：满月、湖面、星空、持钥匙人物、和服式立绘。

可吸收：月面、湖面、星点、低刺激夜色、局部人物氛围。

必须谨慎：人物是明显全身二次元立绘，且直面用户，若全屏直接使用会接近“星澜全屏恋爱立绘 / 暧昧凝视 / 乙游感”红线。建议仅作为低透明、暗化、裁切、背景融合参考，不作为主视觉正面大立绘。

### 1.5 不可迁移内容

- `server.ts`、Gemini API、`fetch('/api/...')`。
- `localStorage` 历史存储。
- `motion/react`、`lucide-react`、Tailwind class。
- React 状态机、组件树、`requestAnimationFrame` 牌轮算法。
- `tarotData.ts` 的 22 张演示卡牌数据。
- “亲爱的”等不合规亲密称呼。
- “未来”“缘分卡牌”“一切都是最好的安排”等可能强化预测、命定或依赖感的表达。
- 强粒子、强闪烁、连续旋转、3D 卡牌深度、手游抽卡式反馈。

## 2. 当前 ArkTS 项目结构摘要

### 2.1 MainFramePage 内联 Tab 说明

`MainFramePage.ets` 约 2234 行，是当前主框架页面。它通过 `currentTab` 条件渲染当前 Tab，避免一次性构建全部内容。

当前 5 个 Tab：

| Tab | 内容 | 视觉方案 | 说明 |
| --- | --- | --- | --- |
| 0 | `DivinationCenterTabContent` | C 星钥之书 | 占卜中心入口，内联实现，跳转单牌、三角、关系、牌轮、历史 |
| 1 | `XinglanChatEntranceContent` | B 月湖映心 | 星澜聊天入口，来自 `XinglanChatEntrancePage.ets` 的可复用内容组件 |
| 2 | `XinglanQuotesTabContent` | B 月湖映心 | 星澜语录 / 主页功能内联 |
| 3 | `TarotCardsTabContent` | C 星钥之书 | 卡牌总览内联 |
| 4 | `SettingsTabContent` | A 星图档案 | 我的 / 设置功能内联 |

注意：`MainFramePage.ets` 已很大，后续只允许小范围视觉精修，不应拆分、重构、改 Tab 数量、改 `selectedIndex/currentTab` 或改 `onTabChange` 行为。

### 2.2 现有组件可复用情况

- `Theme.ets` 已包含完整 V2 / V2A / V2B / V2C Token，应优先复用。
- `MoonlightLayer.ets` 已承载 B 方案月光呼吸层。
- `StarBackground.ets` 已承载基础星空背景。
- `PressableScaleButton.ets` 已封装按压缩放反馈。
- `DivinationEntryCard.ets` 已是 C 方案占卜入口卡片雏形。
- `HeartOptionCard.ets` 已适合问心选项卡升级。
- `TarotCardImage.ets` / `TarotCardView.ets` 已封装真实卡牌图与卡牌展示。
- `AppBackButton.ets` 已统一返回按钮。
- `CompanionBottomNav.ets` 已封装底部导航，不应重写。

### 2.3 旧版不可达或非主路径页面

以下页面仍注册在 `main_pages.json`，但从当前主体验看更像历史遗留或非主入口：

- `DivinationPage.ets`
- `DivinationResultPage.ets`
- `DivinationHistoryPage.ets`
- `HomePage.ets`：注释说明底部导航已迁移至 `MainFramePage`，主页功能已内联到 `MainFramePage`。
- `SettingsPage.ets`：我的页功能在 `MainFramePage` 内联，独立页仍作为旧路由 / fallback 存在。
- `DailyFortunePage.ets`：与 Widget 冷启动相关，不属于本次 Stitch 映射主路径。
- `Index.ets`：旧入口形态，当前冷启动由 `SplashPage` / `LaunchPage` 分流。

结论：UI 焕新不得优先改这些旧页面，除非后续明确指定。主路径优先改 `MainFramePage` 内联 Tab 和新版路由页面。

### 2.4 主路径页面

- 启动路径：`SplashPage` -> `LaunchPage` -> `MainFramePage`。
- C 星钥之书：`MainFramePage` Tab 0 / Tab 3，`AskHeartPage`、`CardDrawPage`、`ResultGoldenPage`、`TriangleIntroPage`、`TriangleDrawPage`、`TriangleResultPage`、`RelationIntroPage`、`RelationDrawPage`、`RelationResultPage`、`CardWheelModePage`、`CardWheelDrawPage`、`TarotCardsPage`、`TarotCardDetailPage`、`ShareCardPage`。
- B 月湖映心：`MainFramePage` Tab 1 / Tab 2，`XinglanChatEntrancePage`、`XinglanChatPage`、`EmotionStarPage`。
- A 星图档案：`MainFramePage` Tab 4，`HistoryPage`、`HistoryDetailPage`、`StarCalendarPage`、`AvatarCropPage`、`AboutPage`、`UsageGuidePage`、`VersionInfoPage`、`PrivacyPolicyPage`、`UserAgreementPage`、`MaterialsLicensePage`。

## 3. 可吸收视觉语言

### 3.1 背景

- 吸收深蓝黑底、顶部轻径向光、底部消隐遮罩。
- ArkUI 落地使用 `Theme.V2A_BG_BASE` / `V2B_BG_BASE` / `V2C_BG_BASE`，不新造大面积紫蓝渐变。
- C 页面偏“旧书封壳”，B 页面偏“月湖深夜”，A 页面偏“星图档案纸”。

### 3.2 月光

- Stitch 的满月和湖面月光适合 B 方案。
- ArkUI 优先复用 `MoonlightLayer.ets`，控制强度在 0.04-0.08 级别。
- 不做大白月亮强发光，不做高亮照脸人物立绘。

### 3.3 星点

- 可吸收稀疏、静态、低透明星点。
- `StarBackground.ets` 可作为基础；后续可增加 scheme，但不做复杂粒子。
- 星点只承担空气感，不承担抽卡奖励感。

### 3.4 卡片

- 吸收深色半透明卡片、细边框、轻阴影、书页阅读层级。
- C 方案卡片更方正：`V2C_RADIUS_CARD`、书脊线、烫金细线。
- B 方案卡片更圆润：`V2B_RADIUS_CARD`、柔和月光边界。
- A 方案卡片克制：`V2A_RADIUS_CARD`、星轨线、信息密度更高。

### 3.5 按钮

- 吸收小面积金色主按钮、按压轻缩放、禁用态灰化。
- 主按钮金色只能用于关键行动，不应大面积铺满页面。
- ArkUI 优先使用 `PressableScaleButton.ets` 或现有局部按压模式。

### 3.6 底部导航

- 吸收深色半透明、顶部细线、选中金色、未选中灰蓝。
- 不改 5 Tab 数量、文案、索引、点击逻辑。
- `CompanionBottomNav.ets` 只做精修：透明度、边框、选中态、底部安全区；不重写。

### 3.7 结果页阅读层级

- 吸收 Stitch 的“标题 / 卡牌 / 关键句 / 分段解释 / 行动按钮”层级。
- ArkUI 以 `ResultGoldenPage`、`TriangleResultPage`、`RelationResultPage` 为准，不改历史保存结构。
- C 页面应像翻阅书页，而不是抽卡结算页。

### 3.8 牌轮视觉

- 吸收“中心焦点 + 周围卡片层叠 + 柔光”的构图。
- 不迁移 React 的连续自动旋转、3D depth 算法、requestAnimationFrame。
- `CardWheelDrawPage.ets` 已有手势和惯性逻辑，后续只允许视觉层微调，不改算法。

### 3.9 星澜人物融合

- 可吸收月湖背景、钥匙、月光轮廓。
- 不直接全屏复用人物立绘；如使用，需暗化、裁切、降低透明度、避开暧昧凝视。
- 星澜应是“陪伴氛围”，不是恋爱角色或主屏偶像。

### 3.10 历史 / 我的档案感

- 吸收小卡缩略、日期、筛选 Chip、档案列表、统计卡。
- ArkUI A 方案更强调记录、星轨、被记住。
- 不迁移 Stitch 的签到 / 成就数据逻辑，不修改星钥等级阈值。

## 4. 不可迁移内容

- React / Tailwind / `motion/react` / `lucide-react`。
- `server.ts` / Gemini / `/api/tarot/*` / `fetch` / `localStorage`。
- Stitch 的 22 张主阿卡纳演示数据。
- 任何 AI 聊天联网逻辑。
- “亲爱的”“缘分卡牌”“未来守护之钥”“一切都是最好的安排”等不符合项目边界的文案。
- 强闪光、复杂粒子、bounce typing、连续星点爆发。
- 抽卡手游感、赌场转盘感、过度 3D、强旋转、强翻牌。
- 星澜全屏恋爱立绘、亲密姿态、暧昧凝视。

## 5. A / B / C 页面映射表

| ArkTS 页面 / 组件 | 所属方案 | 对应 Stitch 原型组件 | 可吸收视觉点 | 禁止修改点 | 建议执行 Phase |
| --- | --- | --- | --- | --- | --- |
| `MainFramePage.ets` Tab 0 `DivinationCenterTabContent` | C | `App.tsx` tarot main list | 深色入口列表、细金边、入口卡阅读感 | 不改 Tab 结构、路由、入口数量 | UI-2 |
| `DivinationCenterPage.ets` | C | `App.tsx` tarot main list | 独立页入口卡、顶部标题层级 | 不扩大旧/新入口差异 | UI-2 |
| `AskHeartPage.ets` | C | `DailyDraw.tsx` focus chips | Chip、输入区、问心卡片 | 不改问心数据、模式、跳转参数 | UI-3 |
| `CardDrawPage.ets` | C | `DailyDraw.tsx` card reveal | 克制翻牌氛围、等待状态 | 不改抽牌算法、权重、结果参数 | UI-3 |
| `ResultGoldenPage.ets` | C | `DailyDraw.tsx` result sections | 关键句、牌面、分段阅读卡 | 不改历史保存、情绪星点、分享参数 | UI-4 |
| `TriangleIntroPage.ets` | C | `HolyTriangle.tsx` intro | 牌阵说明卡、过去/现在/未来层级 | 不改牌阵含义 | UI-5 |
| `TriangleDrawPage.ets` | C | `HolyTriangle.tsx` draw | 三牌布局、轻仪式感 | 不改抽牌流程、参数结构 | UI-5 |
| `TriangleResultPage.ets` | C | `HolyTriangle.tsx` result | 三段阅读、综合语 | 不改历史结构、牌位含义 | UI-5 |
| `RelationIntroPage.ets` | C | `HolyTriangle.tsx` intro style | 说明卡、边界提醒 | 不预测关系走向、不判断对方爱不爱 | UI-6 |
| `RelationDrawPage.ets` | C | `HolyTriangle.tsx` draw style | 克制牌阵仪式感 | 不改关系探索数据结构 | UI-6 |
| `RelationResultPage.ets` | C | `HolyTriangle.tsx` result style | 分段阅读层级 | 不承诺复合、不替用户决定 | UI-6 |
| `CardWheelModePage.ets` | C | `CardWheel.tsx` wheel entry | 模式选择卡、中心焦点 | 不改 drawCount 语义 | UI-7 |
| `CardWheelDrawPage.ets` | C | `CardWheel.tsx` wheel | 中心光、卡片层叠、选中态 | 不改手势、惯性、算法、抽牌流程 | UI-7 |
| `MainFramePage.ets` Tab 3 `TarotCardsTabContent` | C | `HistoryArchive.tsx` mini card list + `tarotData.ts` | 小卡网格、筛选 Chip | 不改 78 张真实卡牌数据 | UI-8 |
| `TarotCardsPage.ets` | C | `HistoryArchive.tsx` / `tarotData.ts` | 卡片缩略、筛选 | 不改数据、详情路由 | UI-8 |
| `TarotCardDetailPage.ets` | C | `DailyDraw.tsx` card face | 大牌图、阅读分区 | 不改卡牌含义和图片映射 | UI-8 |
| `ShareCardPage.ets` | C | `DailyDraw.tsx` / `HolyTriangle.tsx` result | 书页式分享卡、细金线 | 不改截图保存逻辑、分享核心逻辑 | UI-9 |
| `MainFramePage.ets` Tab 1 `XinglanChatEntranceContent` | B | `XinglanChat.tsx` | 月湖入口、柔和 CTA | 不直接进聊天、不改 Tab 逻辑 | UI-10 |
| `XinglanChatEntrancePage.ets` | B | `XinglanChat.tsx` + image | 月光层、星澜氛围 | 不改昵称持久化规则 | UI-10 |
| `XinglanChatPage.ets` | B | `XinglanChat.tsx` | 气泡、输入框、Chip、低刺激夜色 | 不改聊天核心管线与 SafetyGuard | UI-11 |
| `MainFramePage.ets` Tab 2 `XinglanQuotesTabContent` | B | `XinglanQuotes.tsx` | 语录卡、月湖背景、轻触反馈 | 不迁移联网 quote、不做粒子爆发 | UI-10 |
| `EmotionStarPage.ets` | B / A | `UserProfile.tsx` stats | 月光仪式 + 等级档案 | 不改 `EmotionStarStorage` 和等级阈值 | UI-11 |
| `HistoryPage.ets` | A | `HistoryArchive.tsx` | 搜索、筛选、档案列表、小牌缩略 | 不改历史记录结构、清空逻辑 | UI-12 |
| `HistoryDetailPage.ets` | A | `HistoryArchive.tsx` detail modal | 档案详情、时间、牌组摘要 | 不改读取逻辑 | UI-12 |
| `StarCalendarPage.ets` | A | `UserProfile.tsx` stats | 星轨、等级、连续记录 | 不改点亮规则和等级阈值 | UI-12 |
| `MainFramePage.ets` Tab 4 `SettingsTabContent` | A | `UserProfile.tsx` | 统计卡、档案分区 | 不改头像 / 昵称持久化 | UI-13 |
| `AvatarCropPage.ets` | A | 无直接对应 | 保持档案克制风格 | 不改裁剪与保存逻辑 | UI-13 |
| `AboutPage.ets` | A | `UserProfile.tsx` section list | 设置列表、档案感 | 不改协议路由 | UI-13 |
| `UsageGuidePage.ets` | A | 无直接对应 | 说明卡片、低刺激阅读 | 不改文案含义 | UI-13 |
| `VersionInfoPage.ets` | A | 无直接对应 | 版本档案卡 | 不改版本信息逻辑 | UI-13 |
| `PrivacyPolicyPage.ets` | A | 无直接对应 | 法务文本可读性 | 不改法律文本含义 | UI-13 |
| `UserAgreementPage.ets` | A | 无直接对应 | 法务文本可读性 | 不改法律文本含义 | UI-13 |
| `MaterialsLicensePage.ets` | A | 无直接对应 | 授权档案列表 | 不改授权内容 | UI-13 |
| `CompanionBottomNav.ets` | 全局 | `App.tsx` bottom nav | 深色胶囊、选中金色、未选中灰蓝 | 不改 Tab 数量/文案/索引/回调 | UI-2 |
| `MoonlightLayer.ets` | B | `XinglanQuotes.tsx` moon image mood | 月光呼吸、顶部柔光 | 不做强光闪烁 | UI-10 |
| `StarBackground.ets` | 全局 | `index.css` stars | 稀疏星点背景 | 不做复杂粒子 | UI-2 |

## 6. 现有组件复用建议

### 6.1 `MoonlightLayer.ets`

可以扩展。当前已有 `strong` 和 `reducedMotion`，适合 B「月湖映心」页面继续使用。建议后续只增加非常小的配置，如 `verticalBias` 或 `maxOpacity`，不要新增复杂动画状态。C / A 页面默认不应依赖月光层，避免三套视觉混淆。

### 6.2 `StarBackground.ets`

可以扩展。当前适合全局深空氛围，但仍使用旧 Token 颜色。建议增加 `scheme: 'A' | 'B' | 'C'` 或 `accentOpacity` 一类轻量属性，以便 A 用星轨灰、B 用月光弱金、C 用书脊暗线。不要做随机生成、粒子系统或强 twinkle。

### 6.3 `PressableScaleButton.ets`

继续复用。它已符合“按下 scale + 释放恢复”的低动效标准。后续按钮统一优先用它或照它的参数模式实现，不引入新按钮抽象，除非多个页面出现完全一致重复。

### 6.4 `DivinationEntryCard.ets`

适合统一 C 方案入口卡片。它已使用 V2C Token、轻阴影、按压缩放。后续占卜中心入口应优先复用它，避免每个页面手写一套入口卡。

### 6.5 `HeartOptionCard.ets`

适合问心页升级。它已经有 selected / pressed 状态和 C 方案边框。后续可以精修选中态层级、说明文字密度和小屏间距，但不应改选项数据或选择逻辑。

### 6.6 `CompanionBottomNav.ets`

只需精修，不应重写。当前组件已经封装 5 个 Tab 和回调。后续只建议调整：

- 背景透明度与底部安全区。
- 选中态金色与未选中灰蓝。
- 顶部细分割线。
- 按压缩放幅度。

禁止改 Tab 数量、文案、索引、`onTabChange`、`MainFramePage` 的 Tab 内容选择。

## 7. Theme Token 扩展建议

优先复用 `Theme.ets` 中已有：

- V2 基础：`V2_BG_BASE`、`V2_TEXT_PRIMARY`、`V2_GOLD_PRIMARY`、`V2_BORDER_BASE`。
- A：`V2A_BG_BASE`、`V2A_BG_CARD`、`V2A_ORBIT_LINE`、`V2A_GOLD_ACCENT`。
- B：`V2B_BG_BASE`、`V2B_BG_CARD`、`V2B_GOLD_CORE`、`V2B_GOLD_RIPPLE`、`V2B_BORDER`。
- C：`V2C_BG_BASE`、`V2C_BG_CARD`、`V2C_BG_FLOATING`、`V2C_SPINE_LINE`、`V2C_GOLD_GILT`。
- 动效：`V2_ANIM_*`、`PRESS_SCALE`、`V2_EASE_OUT`。

如后续确实需要新增，建议只考虑以下 Token。本轮不修改 `Theme.ets`。

| Token 名称 | 用途 | 建议色值 | 是否必要 |
| --- | --- | --- | --- |
| `V2_NAV_BG` | 底部导航统一半透明底 | `rgba(8,11,26,0.82)` | 可选，若导航多处复用再加 |
| `V2_NAV_BORDER` | 底部导航顶部细线 | `rgba(201,164,75,0.10)` | 可选 |
| `V2C_GILT_HAIRLINE` | C 方案烫金细线 | `rgba(197,160,80,0.18)` | 可选，现可用 `V2C_SPINE_LINE` |
| `V2B_LAKE_SCRIM` | 星澜图片暗化遮罩 | `rgba(6,11,26,0.72)` | 仅在引入图片资源时必要 |
| `V2A_ARCHIVE_DIVIDER` | A 档案分割线 | `rgba(30,37,69,0.72)` | 可选，现可用 `V2A_ORBIT_LINE` |
| `V2_CARD_GLASS_WEAK` | 弱玻璃面板底 | `rgba(18,24,54,0.68)` | 可选，避免滥用 |

结论：当前 Token 已足够启动 UI-2 到 UI-7。新增 Token 应推迟到出现三处以上重复硬编码时再做。

## 8. 动效分级建议

### 8.1 高感知但克制页面

- `CardDrawPage.ets`
- `TriangleDrawPage.ets`
- `RelationDrawPage.ets`
- `CardWheelDrawPage.ets`

允许：翻牌、淡入、轻缩放、中心柔光、低速惯性。

禁止：强闪光、粒子爆发、快速连续旋转、抽卡手游式震动和奖励反馈。

### 8.2 中等动效页面

- `ResultGoldenPage.ets`
- `TriangleResultPage.ets`
- `RelationResultPage.ets`
- `XinglanChatEntrancePage.ets`
- `EmotionStarPage.ets`

允许：页面淡入、按钮按压、月光呼吸、卡片轻浮现。

禁止：大面积光扫、复杂弹窗、强弹跳。

### 8.3 低动效页面

- `XinglanChatPage.ets`
- `MainFramePage.ets` 内联 Tab
- `TarotCardsPage.ets`
- `TarotCardDetailPage.ets`
- `HistoryPage.ets`
- `HistoryDetailPage.ets`
- `StarCalendarPage.ets`

允许：气泡进入、Chip 选中、列表按压、轻微滚动层次。

禁止：每条列表 item 独立复杂入场、持续粒子。

### 8.4 基本静态页面

- `AboutPage.ets`
- `UsageGuidePage.ets`
- `VersionInfoPage.ets`
- `PrivacyPolicyPage.ets`
- `UserAgreementPage.ets`
- `MaterialsLicensePage.ets`
- `AvatarCropPage.ets`
- `ShareCardPage.ets` 的最终预览区域

允许：按钮按压和必要状态反馈。

禁止：任何装饰性动效。

## 9. 图片资源映射建议

### 9.1 适合使用用户自己的图片的页面

- `XinglanChatEntrancePage.ets` / `MainFramePage` Tab 1：适合低透明背景融合，但必须暗化、裁切、降低人物存在感。
- `MainFramePage` Tab 2 `XinglanQuotesTabContent`：可使用月湖局部背景，不建议完整人物居中。
- `EmotionStarPage.ets`：只适合使用月光 / 湖面抽象背景，不适合人物。

不建议使用人物图的页面：

- C 方案所有塔罗页面：应以卡牌、书页、烫金线为核心。
- A 方案档案页面：应以记录、星轨、列表和时间为核心。
- `XinglanChatPage.ets`：聊天页人物应保持头像/小符号，不应使用全屏立绘。

### 9.2 推荐资源命名

如果后续确定引入资源，建议重新处理后再入库：

- `xinglan_moon_lake_bg.webp`
- `xinglan_moon_lake_scrim.webp`
- `xinglan_figure_soft_crop.webp`

避免沿用 `xinglan_goddess_1782918266274.jpg` 这类临时文件名。

### 9.3 推荐放置路径

- `entry/src/main/resources/base/media/xinglan_moon_lake_bg.webp`
- `entry/src/main/resources/base/media/xinglan_figure_soft_crop.webp`

### 9.4 处理要求

- 必须 webp 化，控制体积。
- 必须暗化 / 渐隐。
- 优先裁切月亮、湖面、星空；人物只作为局部轮廓。
- 不允许全屏明亮正面人物。
- 不允许替换应用图标或核心卡牌资源。

## 10. 分阶段落地顺序：Task UI-2 到 UI-13

### Task UI-2：全局框架与底部导航精修

- 范围：`MainFramePage.ets` 外层背景、`CompanionBottomNav.ets`、必要时 `StarBackground.ets`。
- 目标：统一底色、底部导航透明度、选中态、顶部细线和安全区。
- 禁止：改 Tab 数量、文案、索引、回调、BGM。

### Task UI-3：C 单牌链路入口与问心页

- 范围：`AskHeartPage.ets`、`CardDrawPage.ets`、`HeartOptionCard.ets`、`PressableScaleButton.ets`。
- 目标：问心选项更像书页卡片，抽牌等待更克制。
- 禁止：改抽牌算法、权重、参数。

### Task UI-4：C 单牌结果页阅读层级

- 范围：`ResultGoldenPage.ets`。
- 目标：卡牌、关键句、分段解读、行动按钮形成清晰阅读层级。
- 禁止：改历史保存、情绪星点、分享逻辑。

### Task UI-5：C 圣三角链路

- 范围：`TriangleIntroPage.ets`、`TriangleDrawPage.ets`、`TriangleResultPage.ets`。
- 目标：牌阵说明、三牌布局、结果阅读统一成“星钥之书”。
- 禁止：改过去/现在/未来含义与数据结构。

### Task UI-6：C 关系探索链路

- 范围：`RelationIntroPage.ets`、`RelationDrawPage.ets`、`RelationResultPage.ets`。
- 目标：关系主题更聚焦自我感受、边界、期待，不做恋爱预测。
- 禁止：复合、对方爱不爱、替用户决定等文案。

### Task UI-7：C 旋转牌轮链路

- 范围：`CardWheelModePage.ets`、`CardWheelDrawPage.ets`。
- 目标：保留手势与惯性，降低赌场/手游感，强化中心选牌与书页氛围。
- 禁止：改手势算法、惯性、抽牌流程。

### Task UI-8：C 卡牌总览与详情

- 范围：`MainFramePage.ets` Tab 3、`TarotCardsPage.ets`、`TarotCardDetailPage.ets`、`TarotCardImage.ets`。
- 目标：统一筛选 Chip、卡牌网格、详情页阅读卡。
- 禁止：改 78 张卡牌数据、图片映射核心逻辑。

### Task UI-9：C 分享卡

- 范围：`ShareCardPage.ets`。
- 目标：分享卡更像可保存的书页档案，细金线点缀。
- 禁止：改截图、保存、分享核心逻辑。

### Task UI-10：B 星澜入口与语录

- 范围：`MainFramePage.ets` Tab 1 / Tab 2、`XinglanChatEntrancePage.ets`、`MoonlightLayer.ets`。
- 目标：吸收月湖、月光、语录卡氛围，星澜人物只作暗化融合参考。
- 禁止：全屏恋爱立绘、联网 quote、复杂粒子。

### Task UI-11：B 聊天页与情绪星

- 范围：`XinglanChatPage.ets`、`EmotionStarPage.ets`。
- 目标：聊天气泡、输入框、Chip、月光层更统一，情绪星保持安静仪式感。
- 禁止：改聊天核心管线、SafetyGuard、`EmotionStarStorage`。

### Task UI-12：A 历史与星历

- 范围：`HistoryPage.ets`、`HistoryDetailPage.ets`、`StarCalendarPage.ets`。
- 目标：档案列表、星轨、日期、筛选与详情阅读更克制统一。
- 禁止：改历史结构、星历点亮规则、等级阈值。

### Task UI-13：A 我的 / 关于 / 协议类页面

- 范围：`MainFramePage.ets` Tab 4、`AvatarCropPage.ets`、`AboutPage.ets`、`UsageGuidePage.ets`、`VersionInfoPage.ets`、`PrivacyPolicyPage.ets`、`UserAgreementPage.ets`、`MaterialsLicensePage.ets`。
- 目标：统一档案感、列表密度、文本可读性、头像页安全区。
- 禁止：改 `UserProfileStore`、头像裁剪逻辑、协议文本含义、路由。

## 11. 风险清单

- `MainFramePage.ets` 很大，约 2234 行，且内联 5 个 Tab。后续不能重构，只能小步视觉精修。
- `XinglanChatPage.ets` 很大，约 1469 行，包含聊天输入、气泡、选项、记忆、夜信、回音卡等核心管线。不能改 `XinglanSafetyGuard`、`XinglanDirectReplyEngine`、`XinglanInteractionFlowEngine`、`XinglanAnalyzer`、`XinglanRouter`、`XinglanComposer`、`XinglanSessionManager`。
- `CardWheelDrawPage.ets` 有手势、惯性、虚拟索引、速度和摩擦逻辑。不能改算法，只能调视觉表现。
- `GlobalBgmManager.ets` 不可改，`bgm_enabled` key 不可改，BGM 播放/暂停/恢复/持久化逻辑不可改。
- `UserProfileStore.ets` 不可改，头像 / 昵称持久化规则不可改，`user_nickname` key 不可改。
- `EmotionStarStorage.ets` 不可改，星历点亮规则和星钥等级阈值不可改。
- 78 张卡牌数据、牌阵含义、历史记录结构、分享卡核心逻辑不可改。
- Stitch 图片若直接使用，存在“全屏恋爱立绘 / 乙游感 / 暧昧凝视”风险；必须先做裁切、暗化和降存在感。
- Stitch 中 `fetch` / Gemini / AI 聊天逻辑完全不能迁移；任何 AI 接入必须另起专项并走后端代理与安全过滤规则。
- Stitch 中金色按钮和琥珀标题较多，迁移时必须控制金色面积，只做细线、标题、选中态和局部 CTA。
- 后续每个 UI Phase 修改后必须编译，目标为 `BUILD SUCCESSFUL` 且 `ERROR=0`。

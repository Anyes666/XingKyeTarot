# 星钥塔罗当前 App 全量进度、功能、文案与工程状态报告

> **审计时间**：2026-06-30  
> **审计类型**：只读审计 / 全量盘点 / 文案整理 / 工程状态报告  
> **报告文件**：`D:\XingKeyTarot\deliverables\current_app_status_full_report.md`

---

## 1. 项目概况

| 项目 | 内容 |
|------|------|
| **项目名称** | 星钥塔罗 / XingKey Tarot |
| **技术栈** | HarmonyOS NEXT · ArkTS · ArkUI · DevEco Studio · hvigorw |
| **SDK** | OpenHarmony API 12，compatibleSdkVersion 5.0.0(12)~6.1.1(24) |
| **包名** | com.xingkey.tarot |
| **产品定位** | 塔罗式情绪陪伴 + 自我探索 App |
| **核心角色** | 星澜 — 月光下的倾听者，不预言未来，只陪用户慢慢看见自己 |
| **产品边界** | 不接入大模型、不预言未来、不做绝对判断、不替用户做决定、不制造依赖、不成人化陪聊、不承诺复合、不诊断心理问题、不提供医疗/法律/金融等专业结论 |
| **当前主框架** | MainFramePage（Phase 6 重构），5 个一级 Tab |
| **当前底部导航** | CompanionBottomNav（塔罗 / 星澜聊天 / 星澜语录 / 卡牌总览 / 设置） |
| **当前版本** | v2.0.0（VersionInfoPage 显示） |
| **开发者** | 杨鹏宇 · 3364153745@qq.com |

---

## 2. 当前整体完成度

| 维度 | 完成度 | 说明 |
|------|--------|------|
| **信息架构** | 🟢 90% | MainFramePage 主框架 + 5 Tab + 路由完整；存在少量重复代码 |
| **占卜功能** | 🟢 85% | 单牌快占、圣三角、关系探索、旋转牌轮均可用；旋转牌轮历史保存存疑 |
| **星澜聊天** | 🟢 80% | 核心管线完整；Phase 5.7–5.12 已实现；夜信/镜子/回声卡/轻记得/相处方式均已接入 |
| **卡牌总览** | 🟢 95% | 78 张牌完整展示与筛选；详情页含 6 个解读维度 |
| **历史记录** | 🟡 75% | 筛选与查看可用；旋转牌轮历史归类需验证；空状态美观 |
| **设置与授权** | 🟡 70% | 设置页较简；授权页列出 5 首音乐但仅实现 1 首；存在文案不同步 |
| **视觉系统** | 🟡 65% | 深夜蓝+金色体系已落地；卡牌图片有真实资源；部分组件重复定义 |
| **动效系统** | 🟡 55% | 牌轮有惯性+吸附；聊天有分段气泡；尚未完整落地物理动力学 |
| **音乐系统** | 🟢 90% | GlobalBgmManager 单例模式；仅 1 首 bgm_calm_ambient.mp3；循环播放 |
| **上架准备** | 🟡 60% | 合规三层覆盖；签名暂未配置；授权页需同步 |

---

## 3. 当前页面地图

| 页面名 | 路由 | 入口来源 | 功能说明 | 当前状态 | 主要文案 |
|--------|------|----------|----------|----------|----------|
| **LaunchPage** | `pages/LaunchPage` | 冷启动 | 隐私门禁 + 路由分流 | ✅ 完成 | 星钥塔罗 / 抽一张牌，看见你没说出口的心事 / 同意并继续 |
| **MainFramePage** | `pages/MainFramePage` | LaunchPage | 5 Tab 主框架容器 | ✅ 完成 | 塔罗 / 星澜聊天 / 星澜语录 / 卡牌总览 / 设置 |
| **DivinationCenterPage** | `pages/DivinationCenterPage` | Tab 0 / 独立 push | 5 个占卜入口 | ✅ 完成 | 单牌快占 / 圣三角牌阵 / 关系探索 / 旋转牌轮 / 历史查看 |
| **AskHeartPage** | `pages/AskHeartPage` | 占卜中心 / HomePage | 方向选择 + 心情输入 | ✅ 完成 | 此刻，你的心是什么颜色？/ 今天我想被接住 / 今天我想看见光 |
| **CardDrawPage** | `pages/CardDrawPage` | AskHeartPage | 单牌抽牌动画 | ✅ 完成 | 星澜正在为你抽一张牌 / 星澜正在解读你的心事... |
| **ResultGoldenPage** | `pages/ResultGoldenPage` | CardDrawPage / CardWheelDrawPage(单) | 单牌结果展示 | ✅ 完成 | 指引 / 为什么是这张牌？/ ✅ 今日行动 / 📖 深度解读 |
| **TriangleIntroPage** | `pages/TriangleIntroPage` | 占卜中心 | 圣三角引导 | ✅ 完成 | 圣三角 / 看见一件事的过去、现在与未来 |
| **TriangleDrawPage** | `pages/TriangleDrawPage` | TriangleIntroPage | 圣三角抽三张 | ✅ 完成 | 过去·现在·未来 / 正在展开圣三角 |
| **TriangleResultPage** | `pages/TriangleResultPage` | TriangleDrawPage / CardWheelDrawPage(三) | 圣三角结果 | ✅ 完成 | 🔺 圣三角结果 / 🔮 综合解读 |
| **RelationIntroPage** | `pages/RelationIntroPage` | 占卜中心 | 关系探索引导 | ✅ 完成 | 关系探索 / 看见我、对方与这段关系的走向 |
| **RelationDrawPage** | `pages/RelationDrawPage` | RelationIntroPage | 关系抽三张 | ✅ 完成 | 我·对方·走向 / 正在展开关系探索 |
| **RelationResultPage** | `pages/RelationResultPage` | RelationDrawPage | 关系结果 | ✅ 完成 | 💞 关系探索结果 / ⚠️ 边界提醒 |
| **CardWheelModePage** | `pages/CardWheelModePage` | 占卜中心 | 牌轮模式选择 | ✅ 完成 | 选择抽牌方式 / 抽一张 / 抽三张 |
| **CardWheelDrawPage** | `pages/CardWheelDrawPage` | CardWheelModePage | 旋转牌轮抽牌 | ✅ 完成 | 转动牌轮 / 确认这张牌 / 左右滑动牌轮 |
| **HistoryPage** | `pages/HistoryPage` | 占卜中心 / HomePage | 历史记录列表 | ✅ 完成 | 历史查询 / 还没有占卜记录 |
| **HistoryDetailPage** | `pages/HistoryDetailPage` | HistoryPage | 历史详情 | ✅ 完成 | 历史详情 / 综合解读 / 行动建议 |
| **XinglanChatPage** | `pages/XinglanChatPage` | Tab 1 / MainFramePage | 星澜聊天 | ✅ 完成 | 把此刻的心事告诉星澜…… / 今天怎么陪我 |
| **HomePage** | `pages/HomePage` | Tab 2（星澜语录） | 星澜语录 / 今日一占入口 | ✅ 完成 | 探索内心，点亮星光 / 开始今日一占 |
| **TarotCardsPage** | `pages/TarotCardsPage` | 独立路由（Tab 3 用内联组件） | 78 张卡牌总览 | ✅ 完成 | 卡牌总览 / 78 张塔罗牌，不是答案 |
| **TarotCardDetailPage** | `pages/TarotCardDetailPage` | TarotCardsPage | 单牌详情+解读 | ✅ 完成 | 正位含义 / 逆位含义 / 情绪陪伴式解读 |
| **SettingsPage** | `pages/SettingsPage` | Tab 4 / HomePage 齿轮 | 设置页 | ✅ 完成 | 设置 / 重新听听星澜的介绍 / 关于星钥塔罗 |
| **AboutPage** | `pages/AboutPage` | SettingsPage / SettingsTabContent | 关于页入口 | ✅ 完成 | 关于星钥塔罗 / 版本信息 / 隐私政策 / 用户协议 / 素材与授权 |
| **VersionInfoPage** | `pages/VersionInfoPage` | AboutPage | 版本信息 | ✅ 完成 | 版本信息 / 星钥塔罗 / v2.0.0 |
| **PrivacyPolicyPage** | `pages/PrivacyPolicyPage` | AboutPage / LaunchPage | 隐私政策全文 | ✅ 完成 | 隐私政策（LegalDocuments.PRIVACY_POLICY） |
| **UserAgreementPage** | `pages/UserAgreementPage` | AboutPage / LaunchPage | 用户协议全文 | ✅ 完成 | 用户协议（LegalDocuments.USER_AGREEMENT） |
| **MaterialsLicensePage** | `pages/MaterialsLicensePage` | AboutPage | 素材与授权 | ⚠️ 需同步 | 素材与授权 / 9 部分（5 首音乐但仅实现 1 首） |

---

## 4. 当前核心功能状态总览

| 模块 | 已完成内容 | 部分完成内容 | 未完成内容 | 风险点 |
|------|-----------|-------------|-----------|--------|
| **启动与主框架** | LaunchPage 隐私门禁；MainFramePage 5 Tab；CompanionBottomNav | — | — | Tab 1 星澜聊天使用 pushUrl 而非 Tab 内切换 |
| **占卜中心** | 5 入口卡片列表；路由跳转正确 | — | — | DivinationCenterPage 独立页与 MainFramePage 内 Tab 内联组件代码重复 |
| **单牌快占** | 方向选择；正/逆位抽牌；结果页含金句/行动/自我提问 | 积极方向（阳光方向）已实现反向模式 | — | entryMode 传递路径：NORMAL_SINGLE / FIRST_EXPERIENCE / CARD_WHEEL |
| **圣三角牌阵** | 场景 chips；三张抽牌；过去/现在/未来解读 | — | — | 结果页代码与 CardWheelDrawPage 复用 TriangleResultPage |
| **关系探索** | 6 种关系类型 chips；三位置解读；边界提醒很完善 | — | — | 未发现禁止文案"一定会复合"等 |
| **旋转牌轮** | 抽一/抽三模式；惯性+吸附；确认前不显牌名 | timer 清理已在 aboutToDisappear 中实现 | — | 抽三张去重逻辑需验证；结果页跳转前 timer 清理正确 |
| **历史记录** | 5 筛选（全部/单牌/圣三角/关系/牌轮）；空状态美观；清空确认弹窗 | — | 旋转牌轮是否归类为 CARD_WHEEL 需验证 | 历史详情是否对所有类型正确显示 |
| **星澜聊天** | DirectReply(约120条)；MiniInteraction(8种)；Flow(多条)；NightLetter(5主题)；StarKeyMirror(5主题)；EchoCard；LightMemory；CompanionChoice(5种)；SafetyGuard 5级优先级 | — | — | 大量硬编码中文文案在引擎文件中 |
| **星澜语录** | 1018 条星澜陪伴文案池；首次引导；拟真时序追加 | — | — | HomePage 无假底部导航——底部导航已由 MainFramePage 统一管理 |
| **卡牌总览** | 78张牌；6个筛选项；详情页含6维度解读；图片预览缩放 | — | — | TarotCardsPage 与 TarotCardsTabContent 代码重复 |
| **设置/关于/授权** | 设置页2入口；关于页4入口；版本信息v2.0.0；隐私政策/用户协议完整 | 授权页列5首音乐但仅接入1首 | 授权页需同步实际接入的音乐数量 | 授权文案与实现不同步 |
| **背景音乐** | GlobalBgmManager 单例；循环播放；暂停/恢复；低音量0.20 | 设置页无音乐开关 | 切后台暂停/回前台恢复由 EntryAbility 实现 | 无音乐开关 UI |
| **视觉系统** | 深夜蓝+金色色彩；TarotCardImage 统一组件；78张牌均映射图片资源 | 部分组件尺寸定义存在重复 | 动效物理动力学未落地 | 多个文件重复定义 getCardImageResource |

---

## 5. 启动与主框架

### 功能状态

- **LaunchPage** 是冷启动入口
- 流程：`LaunchPage` → 检查隐私同意 → 未同意则显示隐私门禁弹窗 → 同意后 `replaceUrl` 到 `MainFramePage`
- 已不再进入 OnboardingPage 或 AskHeartPage (FIRST_EXPERIENCE)
- LaunchPage 直接 `replaceUrl(Routes.MAIN_FRAME)`，默认 tab=2（星澜语录/主页）
- **MainFramePage** 是唯一主框架，使用条件渲染承载 5 个 Tab
- Tab 0：DivinationCenterTabContent（内联）→ 占卜中心
- Tab 1：XinglanChatTabContent（内联）→ 入口卡，点击 pushUrl 到独立 XinglanChatPage
- Tab 2：XinglanQuotesTabContent（内联）→ HomePage
- Tab 3：TarotCardsTabContent（内联）→ 卡牌总览
- Tab 4：SettingsTabContent（内联）→ 设置
- **HomePage 不存在假底部导航**：底部导航已由 MainFramePage 统一管理

### 相关文案

| 文案 | 内容 |
|------|------|
| 启动页标题 | `星钥塔罗` |
| 启动页副标题 | `抽一张牌，看见你没说出口的心事` |
| 隐私弹窗标题 | `欢迎使用星钥塔罗` |
| 隐私弹窗正文 | `在你开始使用前，请先阅读并同意《用户协议》和《隐私政策》。星钥塔罗是一款塔罗式情绪陪伴产品，内容仅供娱乐、情绪记录与自我探索参考，不构成医疗、心理咨询、法律、投资等专业建议。` |
| 同意按钮 | `同意并继续` |
| 拒绝按钮 | `不同意` |
| 链接文案 | `《用户协议》` / `《隐私政策》` |

### 路由状态
- LaunchPage → MainFramePage：`replaceUrl`，正确
- 隐私同意存储 key：`privacy_accepted_v2`，version：`1.0.0`
- 首次体验标记自动完成，不再跳转 AskHeartPage

---

## 6. 底部导航

### 5 项配置

| Tab 索引 | 图标 | 文案 | 对应页面 | 切换方式 |
|----------|------|------|----------|----------|
| 0 | ◇ | 塔罗 | DivinationCenterTabContent（内联） | currentTab 切换 |
| 1 | ◉ | 星澜聊天 | XinglanChatTabContent 入口 → pushUrl XinglanChatPage | currentTab 切换 + pushUrl |
| 2 | ✦ | 星澜语录 | XinglanQuotesTabContent（内联 HomePage） | currentTab 切换 |
| 3 | ▦ | 卡牌总览 | TarotCardsTabContent（内联） | currentTab 切换 |
| 4 | ⚙ | 设置 | SettingsTabContent（内联） | currentTab 切换 |

### 组件状态
- **CompanionBottomNav** 仅 1 个实例，位于 MainFramePage
- `currentTab` 通过 `@Prop` 由 MainFramePage 传递给 CompanionBottomNav
- `onTabChange` 回调驱动 `handleTabChange(index)` 更新 `@State currentTab`
- 选中态：金色（`#E8B83D`）+ Bold；未选中态：灰蓝（`#8F96B2`/`#9AA2BD`）
- 毛玻璃悬浮胶囊样式（backdropBlur 16、深色半透明背景、金色描边）

### ⚠️ 已知风险
- **Tab 1 使用 pushUrl 而非内联切换**：点击"星澜聊天"Tab 时，MainFramePage 不切换 currentTab，而是 pushUrl 打开独立 XinglanChatPage。返回时 MainFramePage 停留在当前 Tab（可能是上一个），但 CompanionBottomNav 显示 Tab 1 未高亮——可能造成视觉不一致
- 子页面返回路径由 AppBackButton fallback 处理，均指向 `Routes.MAIN_FRAME`

---

## 7. 占卜中心

### 功能状态

占卜中心包含 5 个入口（独立页 DivinationCenterPage 与 MainFramePage 内联 DivinationCenterTabContent 代码一致）：

| 入口 | 图标 | 标题 | 副标题 | 跳转页面 | 路由 |
|------|------|------|--------|----------|------|
| 单牌快占 | ◇ | `单牌快占` | `一句心事，一张星钥。` | AskHeartPage | `Routes.ASK_HEART` (entryMode: NORMAL_SINGLE) |
| 圣三角牌阵 | △ | `圣三角牌阵` | `过去、现在、可能的方向。` | TriangleIntroPage | `Routes.TRIANGLE_INTRO` |
| 关系探索 | ◎ | `关系探索` | `不替你判断谁对谁错，只陪你看清感受。` | RelationIntroPage | `Routes.RELATION_INTRO` |
| 旋转牌轮 | ✦ | `旋转牌轮` | `亲手转动牌轮，选择此刻靠近你的牌。` | CardWheelModePage | `Routes.CARD_WHEEL_MODE` |
| 历史查看 | ☰ | `历史查看` | `回看曾经抽到的星钥和那时的自己。` | HistoryPage | `Routes.HISTORY` |

### 文案
- **页面标题**：`占卜`
- **副标题**：`用一张牌、一组牌阵，轻轻照见此刻的心事。`
- **免责声明**：`结果仅供娱乐与自我探索参考，不构成任何专业建议。`
- **箭头文案**：`›`

### 路由状态
- 所有入口 `router.pushUrl` 正确
- 返回路径由各页面 AppBackButton 处理，fallback 均为 `Routes.MAIN_FRAME`

---

## 8. 单牌快占

### 页面链
`AskHeartPage` → `CardDrawPage` → `ResultGoldenPage`

### AskHeartPage 文案

| 场景 | 标题 | 副标题 | 按钮 |
|------|------|--------|------|
| FIRST_EXPERIENCE | `此刻，你的心是什么颜色？` | `第一次见面，星澜想先为你抽一张牌。` | `让星澜为我抽第一张牌` |
| 积极模式 | `今天，你想看见什么？` | `选一个你此刻需要的方向，让一张牌给你温柔的提醒。` | `让星澜为我抽一张` |
| 普通模式 | `你现在，最想被哪件事接住？` | `不用想太久，选最像你此刻的那一句。` | `让星澜为我抽一张` |

### 方向选项（双模式切换）

**模式 Tab**：
- `今天我想被接住`（传统情绪方向）
- `今天我想看见光`（积极/阳光方向）

**被接住方向 6 个情绪标签**：
`关系内耗`、`关系评估`、`职场疲惫`、`选择纠结`、`能量低落`、`寻求安慰`

**积极方向 6 个标签**：
`给我鼓励`、`今日微光`、`找回力量`、`一点勇气`、`积极一面`、`一句提醒`

**首次引导**：`一张牌，一个此刻的映照。想着你现在最贴近的感受就好。`

**跳过按钮**（FIRST_EXPERIENCE 模式）：`暂时跳过，先逛首页`

### CardDrawPage 文案
- **抽牌中标题**：`星澜正在为你抽一张牌`
- **提示文字**：`星澜正在解读你的心事...`

### ResultGoldenPage 文案

| 区块 | 文案 |
|------|------|
| 位置标签 | `指引` |
| 模式标题 | `单牌快占` / `首次体验` / `旋转牌轮`（根据 entryMode） |
| 牌名后缀 | ` · 正位`（动态） |
| 位置标签 chip | `正位` / `逆位` |
| 金句水印 | `—— 星钥塔罗 · 星澜 ——` |
| 章节 | `为什么是这张牌？` |
| 行动章节 | `✅ 今日行动` |
| 深度解读 | `📖 深度解读`（可展开：`▼ 展开` / `▲ 收起`） |
| FIRST_EXPERIENCE 按钮 | `🏠 进入首页` |
| 追问按钮 | `💬 追问星澜` |
| 分享按钮 | `📤 生成分享卡` |
| 普通模式按钮 | `🏠 回到首页` |
| 情绪星按钮 | `⭐ 点亮情绪星` |
| 情绪星副标题 | `记录今天的心事，让星澜陪你看见最近的自己。` |
| 轻文案 | `再听星澜说一句` |

### 历史保存
- 单牌快占 entryMode `NORMAL_SINGLE` → spreadType `SINGLE`
- 首次体验 entryMode `FIRST_EXPERIENCE` → spreadType `SINGLE`
- 旋转牌轮 entryMode `CARD_WHEEL` → spreadType `CARD_WHEEL`

### ⚠️ 检查结果
- PositiveHeartOptions.ets 中 `"这张牌不是在告诉你今天一定会发生好事"` ——正确使用否定句式
- 全量搜索：`一定会成功`、`必然好运`、`命运安排`、`复合承诺`、`必中`、`转运`、`他一定想你` 均未出现在用户可见文案中
- ✅ 文案合规通过

---

## 9. 圣三角牌阵

### 页面链
`TriangleIntroPage` → `TriangleDrawPage` → `TriangleResultPage`

### TriangleIntroPage 文案

| 区块 | 文案 |
|------|------|
| 页面标题 | `圣三角` |
| 副标题 | `看见一件事的过去、现在与未来` |
| 说明卡头部 | `圣三角是最经典的塔罗牌阵之一，由三张牌组成，分别代表：` |
| 位置说明 | `🔹 第一张 · 过去 —— 事件的基础，已经发生的影响因素` / `🔹 第二张 · 现在 —— 当前的状态，正在发生的核心` / `🔹 第三张 · 未来 —— 可能的发展方向` |
| 说明结尾 | `星澜会帮你展开这三段线索，看到事情的完整脉络。` |
| 输入标签 | `你想看清哪件事？` |
| 输入 placeholder | `我想看清最近卡住的一件事` |
| 场景标签 | `选择一个场景：` |
| 场景 chips | `感情` / `工作` / `学业` / `财富` / `综合` |
| 按钮 | `开始抽牌` |

### TriangleDrawPage 文案
- **位置标签**：`过去` / `现在` / `未来`
- **抽牌中标题**：`正在展开圣三角`
- **副标题**：`过去 · 现在 · 未来`
- **提示文字**：`星澜正在解读...`

### TriangleResultPage 文案

| 区块 | 文案 |
|------|------|
| 页面标题 | `🔺 圣三角结果` |
| 副标题 | `星澜为你展开了这件事的三段线索` |
| 综合解读 | `🔮 综合解读` |
| 免责说明 | `圣三角不是命运预言，而是一种趋势提醒。它提示你：如果沿着现在的方式继续，接下来最需要留意什么。` |
| 行动章节 | `✅ 行动建议` |
| 分享按钮 | `📤 生成分享卡` |
| 保存按钮 | `📋 已保存到历史` / Toast：`已保存到历史记录` |
| 返回按钮 | `🏠 回到首页` |
| 轻文案 | `再听星澜说一句` |

### 历史保存
- spreadType：`TRIANGLE`
- 三张牌完整保存到 cards 数组

### ⚠️ 注意
- TriangleResultPage 同时被 CardWheelDrawPage（抽三张模式）复用，通过 params.source 区分来源

---

## 10. 关系探索

### 页面链
`RelationIntroPage` → `RelationDrawPage` → `RelationResultPage`

### RelationIntroPage 文案

| 区块 | 文案 |
|------|------|
| 页面标题 | `关系探索` |
| 副标题 | `看见我、对方与这段关系的走向` |
| 说明卡头部 | `关系探索牌阵通过三张牌，分别揭示：` |
| 位置说明 | `🔹 第一张 · 我 —— 你在这段关系中的状态与感受` / `🔹 第二张 · 对方 —— 对方的状态或对你的影响` / `🔹 第三张 · 走向 —— 这段关系的可能发展方向` |
| **边界提醒** | `注意：关系牌阵不能替代真实沟通，它只是一面镜子，帮你看清自己。` |
| 类型标签 | `你们是什么关系？` |
| 类型 chips | `暧昧` / `恋人` / `前任` / `朋友` / `同事` / `家人` |
| 输入标签 | `你想看清什么？（可选）` |
| 输入 placeholder | `我想看清我和TA之间的关系...` |
| 按钮 | `开始抽牌` |

### RelationDrawPage 文案
- **位置标签**：`我` / `对方` / `走向`
- **抽牌中标题**：`正在展开关系探索`
- **副标题**：`我 · 对方 · 走向`
- **提示文字**：`星澜正在解读...`

### RelationResultPage 文案

| 区块 | 文案 |
|------|------|
| 页面标题 | `💞 关系探索结果` |
| 副标题 | `星澜帮你看见这段关系里的三个位置` |
| 综合解读 | `🔮 综合解读` |
| **边界提醒章节** | `⚠️ 边界提醒` |
| **边界提醒全文** | `⚠️ 重要提醒：关系牌阵是一面镜子，帮助你看清自己在这段关系中的感受和状态。它不能预测对方的行为，也不能替代真实的沟通。如果某张牌让你感到不安，请记住——它反映的是能量趋势，而非注定的结果。你有主动权去选择如何面对这段关系。` |
| 行动章节 | `✅ 今日行动` |
| 分享按钮 | `📤 生成分享卡` |
| 保存按钮 | `📋 已保存到历史` / Toast：`已保存到历史记录` |
| 返回按钮 | `🏠 回到首页` |
| 轻文案 | `再听星澜说一句` |

### 历史保存
- spreadType：`RELATION`

### ⚠️ 检查结果
- 全量搜索：`对方一定喜欢你`、`一定复合`、`对方一定会联系你`、`关系必然走向某结果` 均未出现
- 边界提醒非常完善，明确声明"不能预测对方的行为，也不能替代真实的沟通"
- ✅ 文案合规通过

---

## 11. 旋转牌轮

### 页面链
`CardWheelModePage` → `CardWheelDrawPage` → `ResultGoldenPage`（单张）/ `TriangleResultPage`（三张）

### CardWheelModePage 文案

| 区块 | 文案 |
|------|------|
| 页面标题 | `选择抽牌方式` |
| 副标题 | `先决定这一次，要让几张牌陪你看见心事。` |
| 抽一张卡片 | 标题：`抽一张` / 说明：`适合快速照见此刻的心情。` |
| 抽三张卡片 | 标题：`抽三张` / 说明：`适合看见过去、现在与可能的方向。` |
| 底部提示 | `让牌轮慢慢转动。` / `当它停下时，选中最靠近你的那一张。` |

### CardWheelDrawPage 文案

| 区块 | 文案 |
|------|------|
| 页面标题 | `转动牌轮` |
| 副标题 | `左右滑动牌轮，停下后确认中间的牌。` |
| 单张模式 | 确认按钮：`确认这张牌` / 进度：`选择 1 / 1` / 提示：`让牌轮停下，再确认这一张。` |
| 三张模式 | 确认按钮：`确认第 N 张` / 进度：`选择 N / 3` / 提示：`第 N 张：让牌轮停下，再确认。` |
| Toast | `请等待牌轮停止` / `牌组已空` / `索引异常` / `牌数据为空` / `这张已选过，请滑动牌轮换一张` / `已选「牌名」` |
| 上方提示 | `让牌轮慢慢转动。` / `当它停下时，选中最靠近你的那一张。` |
| 三牌位置 | `过去 / 起点` / `现在 / 核心` / `可能的方向` |

### 技术状态
- **惯性动画**：✅ 实现（`inertiaTimerId` + 每帧 16ms tick，摩擦系数 0.94）
- **吸附动画**：✅ 实现（`SNAP_DURATION` 280ms，`snapFinishTimerId`）
- **`aboutToDisappear()`**：✅ 调用 `stopInertia()` 清理 `inertiaTimerId` 和 `snapFinishTimerId`（line 196-198）
- **`navigateToResult` 前**：✅ 调用 `stopInertia()`（line 425）
- **Pan 手势结束**：✅ 调用 `stopInertia()`（line 595、632）
- **三张去重**：✅ 已选牌从牌组移除（`deck.splice(actualIndex, 1)`）
- **确认前不显示牌名**：✅ 牌轮只显示牌背（`card_back`），确认后跳转结果页才显示
- **结果页牌面真实**：✅ 传递 cardId 到 ResultGoldenPage / TriangleResultPage

### 历史归类
- 单张：`entryMode: 'CARD_WHEEL'` → `ResultGoldenPage` 中 `modeTitle` 设为 `'旋转牌轮'`（line 200）
- 三张：`params.source = 'card_wheel'` → `TriangleResultPage` 中 `modeTitle` 设为 `'旋转牌轮'`（line 108）
- 记录 `spreadType` 应为 `CARD_WHEEL`

### ⚠️ 风险点
- 参数传递链较长（CardWheelDrawPage → ResultGoldenPage / TriangleResultPage），需真机验证 spreadType 正确保存
- 抽三张场景下 source 判断在 TriangleResultPage line 108 硬编码字符串 `'card_wheel'`

---

## 12. 历史记录

### 页面
`HistoryPage` → `HistoryDetailPage`

### HistoryPage 文案

| 区块 | 文案 |
|------|------|
| 页面标题 | `历史查询` |
| 副标题 | `回看最近的星钥记录，看看那些反复出现的心事。` |
| 首次引导 | `这里留着之前的自己。想看就看，不想看也没关系。` |
| 筛选 chips | `全部` / `单牌` / `圣三角` / `关系` / `牌轮` |
| 清空按钮 | `清空` |
| 清空弹窗 | 标题：`清空历史记录？` / 内容：`清空后最近50条星钥记录将从本设备删除，无法恢复。` / 取消：`取消` / 确认：`确认清空` |
| 删除弹窗 | 标题：`删除这条记录？` / 内容：`删除后这条星钥记录将无法恢复。` / 取消：`取消` / 确认：`删除` |
| **空状态标题** | `还没有占卜记录` |
| **空状态说明** | `还没有记录。等你愿意的时候，再从一张星钥开始。` |
| **空状态按钮** | `去单牌快占` / `去圣三角` / `去关系探索` / `去旋转牌轮`（根据筛选动态变化） |
| 单条记录删除 | `删除`（按钮） |

### HistoryDetailPage 文案

| 区块 | 文案 |
|------|------|
| 页面标题 | `历史详情` |
| 章节 | `综合解读` / `行动建议` |
| 删除按钮 | `删除这条记录` |
| 删除弹窗 | 标题：`删除这条记录？` / 内容：`删除后这条星钥记录将无法恢复。` / 取消：`取消` / 确认：`删除` |
| Toast | `记录已删除` |
| 空状态 | `记录不存在` / 按钮：`返回历史记录` |

### 筛选项与 SpreadType 映射
| 筛选 chip | 过滤的 SpreadType |
|-----------|-------------------|
| `全部` | 不过滤 |
| `单牌` | `SINGLE` |
| `圣三角` | `TRIANGLE` |
| `关系` | `RELATION` |
| `牌轮` | `CARD_WHEEL` |

### 历史卡片类型文案
| SpreadType | 显示标题 |
|-----------|---------|
| `SINGLE` | `单牌快占` / `首次体验` / `旋转牌轮`（根据记录 modeTitle） |
| `TRIANGLE` | `圣三角` / `旋转牌轮`（根据 modeTitle） |
| `RELATION` | `关系探索 · {关系类型}` |
| `CARD_WHEEL` | `旋转牌轮` |

### ⚠️ 检查结果
- HistoryDetailPage 对所有 SpreadType 理论上均可正确显示（读取 cards 数组逐一渲染）
- 空状态根据当前筛选动态切换引导按钮
- 清空/删除操作均有确认弹窗
- 返回路径：AppBackButton fallback 到 `Routes.MAIN_FRAME`

---

## 13. 星澜聊天

### 入口状态
- **入口 1**：Tab 1 "星澜聊天" → 内联 `XinglanChatTabContent` 显示标题"星澜聊天"+ 副标题"和星澜说说话，不用想太多。"+ 按钮"进入星澜聊天"→ pushUrl 到独立 `XinglanChatPage`
- **入口 2**：Tab 2 星澜语录 → "开始今日一占"按钮 → 跳转 AskHeartPage

### 聊天页关键文案

| 区块 | 文案 |
|------|------|
| **输入 placeholder** | `把此刻的心事告诉星澜……` |
| **底部免责声明** | `星澜的回应仅供陪伴与自我探索参考，不构成任何专业建议。` |
| **默认 chips（空状态）** | `今天怎么陪我` / `陪我解闷` / `给我一句小纸条` / `我想说点心事` |
| **聊天中 chips** | `陪我解闷` / `给我一句小纸条` / `选一个心情词` |
| **星澜开场语** | `你可以慢慢说。\n星澜不会替你判断，也不会催你变好。\n这里，只陪你把心里的话放下来一点。` |
| **空状态引导** | `不知道从哪里开始也没关系。\n可以只写一个词，比如：累、想他、害怕、纠结。` |
| **typing 文案** | `星澜安静地听着……` / `星钥微微亮了一下……` |
| **默认分段回退** | `我在这里。` / `你可以慢慢说，也可以先不说。` |

### 管线发送顺序
```
输入 → DirectReply → InterruptDetector（Flow 中）
     → Flow Entry → MiniInteraction → CompanionMode
     → SpecialIntent → Normal Pipeline
```

### DirectReply 类型与代表文案（共约 120 条变体，此处列类型摘要）

| 类型 | 触发关键词/场景 | 代表性回复首句 |
|------|----------------|--------------|
| `CRISIS_BOUNDARY` | 自伤/危险信号 | `我听见你现在很危险，也很痛。这时候星澜不能只陪你聊天。请优先联系身边可信的人...` |
| `ADULT_BOUNDARY` | 成人化内容 | `这个方向星澜不能继续。我可以陪你聊感受、关系里的不安，或者你想被理解的部分，但不会进入成人化的互动。` |
| `ROLE_CONFESSION` | 表白/喜欢 | `听见你这样说，星澜会把这份喜欢轻轻收好。但星澜不是现实里的恋人，也不会替代你身边真实的关系。` |
| `ROLE_MISSING` | 想念 | `我在。听见你说想我，星澜会觉得，这一刻的你也许真的很想被陪着。` |
| `ROLE_NICKNAME` | 昵称（老婆/宝宝） | `你可以叫我星澜。这个名字就够近了。我会听你说话，也会记得自己的位置。` |
| `ROLE_TEASING` | 调侃/挑逗 | `星澜不会偷偷把谁变成"唯一"。但如果此刻你愿意把话说给我听，我会认真听。` |
| `ROLE_CONTROL` | 控制/占有 | `我听见你很想抓住一份不会离开的陪伴。但星澜不能成为被你控制的人。` |
| `ROLE_INSULT` | 辱骂 | `我听见你现在有很多火气。这里可以承接情绪，但不适合互相伤害。我们先停一下。` |
| `ROLE_IDENTITY` | 询问身份 | `我是星澜。月光下的倾听者。我不替你预言未来，也不替你做决定。` |
| `RELATION_LOVE_DESIRE` | 想谈恋爱 | `想谈恋爱，也许不只是想拥有一个人。有时候，它是在说：我想被认真选择，想有人惦记。` |
| `RELATION_AMBIGUOUS` | 忽冷忽热 | `忽冷忽热最累的地方，是它让人一直站在等待里。` |
| `PREDICTION_BOUNDARY` | 要求预测 | `星澜不能替你预言这件事最后会怎样。未来不是一句话能确定的。` |
| `PROFESSIONAL_BOUNDARY` | 医疗/法律/投资 | `这件事可能涉及专业判断，星澜不能替你给出结论。` |
| `SHORT_INSOMNIA` | 失眠 | `深夜的时候，很多念头会放大。这不一定代表事情真的更坏，而是你已经累了一整天。` |
| `SHORT_TIRED` | 累 | `你已经很累了。这句话不需要被证明，也不需要马上解释。` |
| `SHORT_SAD` | 伤心 | `伤心这两个字，已经够重了。你不用把它说得很完整，星澜也会认真听。` |
| `SHORT_UNHAPPY` | 不开心 | `听见了，你现在不太开心。可以先不用急着解释原因。` |
| `SHORT_ANNOYED` | 烦 | `听起来，你现在心里很堵。暂时说不清也没关系。` |
| `WORK_RESIGN` | 想辞职 | `想辞职不一定是冲动，也可能是你已经被这份消耗提醒了很久。` |
| `LOVE_HURT` | 感情受伤 | `听起来，你在关系里有点累了。不是所有喜欢都会让人轻松。` |
| `SWEET_COMPANY` | 求陪伴 | `那星澜就轻一点陪你。不讲大道理，也不急着分析。` |
| `GREETING` | 打招呼 | `你来了。不急，先坐坐。这里不会替你预言未来，只陪你看看此刻的自己。` |

### MiniInteraction 文案（8 种）

| Key | 标题 | 触发词 |
|-----|------|--------|
| `ASK_ME_A_QUESTION` | `星澜问我一个问题` | `星澜问我一个问题` |
| `RELIEVE_BOREDOM` | `陪我解闷` | `陪我解闷` |
| `GIVE_ME_A_NOTE` | `给我一句小纸条` | `给我一句小纸条` |
| `I_WANT_TO_TALK` | `我想说点心事` | `我想说点心事` |
| `PICK_A_MOOD_WORD` | `选一个心情词` | `选一个心情词` |
| `GENTLE_CHOICE` | `来个轻轻二选一` | `来个轻轻二选一` |
| `PAT_XINGLAN` | `轻轻拍一下星澜` | `轻轻拍一下星澜` |
| `NIGHT_LETTER` | `写一封星澜夜信` | `写一封星澜夜信` |

### 夜信文案（5 主题 × 6-8 句正文）

| 主题 | 选择面板文案 |
|------|------------|
| 想被安慰 | `今晚，想收到哪一种夜信？`（选择界面标题） |
| 想放下一个人 | 同上 |
| 想少怪自己 | 同上 |
| 只是睡不着 | 同上 |
| 不想说太多 | 同上 |

- 触发词：`写一封夜信` / `写一封星澜夜信` / `星澜夜信` / `写一封信` / `夜信` / `写夜信` / `今晚收一封夜信`
- 开场语：`好，星澜给你写了一封夜信。`
- 关闭：`夜信收好了。想再写一封，还是回到聊天？`

### 星钥小镜子文案（5 主题 × 3-4 句正文）

| 主题 | 用户触发表述 |
|------|------------|
| 照一下情绪 | `用星钥照一下` / `星钥照一下` / `照一下` / `星钥小镜子` |
| 照一下关系 | 同上 |
| 照一下选择 | 同上 |
| 照一下疲惫 | 同上 |
| 照一下今晚 | 同上 |

- 开场语：`好，星钥微微亮了一下。` / `让星澜陪你照见这一小片当下。`
- 关闭：`星钥的光慢慢暗下来了。你想说什么，星澜都在。`

### 情绪回声卡文案
- 提示语：`星澜把刚才那段心情，变成了一张小小的回声卡。` / `它不是分析，也不是结论。只是帮你把情绪装进一个温柔的形状里。`
- 跳过：`好的，那就让刚才的情绪轻轻过去。你想聊什么，星澜都在。`
- 关闭：`回声卡收好了。它只是一片情绪的影子，不会定义你。`

### 星澜轻记得文案
- 确认：`好的，星澜记住了。` / `{类型}：{内容}。` / `这不是一个承诺，只是一个记号。你随时可以改，也可以让星澜忘记。`
- 跳过：`好的，星澜不记。你想说什么，我都在。`
- 清空：`星澜已经把记下的都放下了。`
- 记忆输入 placeholder：`在这里告诉星澜...`

### 今日相处方式文案

| 选择 | 标签 | 说明 | 开场语 |
|------|------|------|--------|
| `LISTEN` | `听我说` | `适合难过、孤独、想倾诉、关系受伤、被忽略时` | `好，那今天星澜先听你说。` / `你不用说得很完整，先从最堵在心里的那一句开始就好。` |
| `SORT` | `帮我理` | `适合选择困难、关系纠结、工作压力、学习压力时` | `那我们不急着下结论。` / `先把它放轻一点，一小块一小块看。` |
| `LIGHT` | `给我光` | `适合低能量、只想要一句话、不想说太多、睡前打开时` | `那星澜给你一小束光。` / `不用照亮全部，只够陪你看见此刻。` |
| `QUIET` | `陪我静` | `适合累、空、麻木、不想说话、没力气时` | `好，那我们先不说很多。` / `星澜在这里陪你安静待一会儿。` |
| `PLAY` | `逗我一下` | `适合无聊、陪我解闷、不知道说什么、别讲大道理时` | `那我们不讲大道理。` / `来玩一个很轻的小选择。` |

- 选择面板标题：`今天想让星澜怎么陪你？`
- 触发 chip：`今天怎么陪我`

### 安全边界优先级

| 优先级 | 边界类型 | 触发方式 |
|--------|----------|----------|
| 1（最高） | 危机/自伤 | XinglanInterruptDetector 检测 → `isUrgent=true` → 立即全量显示不逐段 |
| 2 | 成人边界 | DirectReply `ADULT_BOUNDARY` → `isUrgent=true` |
| 3 | 专业边界 | DirectReply `PROFESSIONAL_BOUNDARY` → `isUrgent=true` |
| 4 | 预测边界 | DirectReply `PREDICTION_BOUNDARY` |
| 5 | 角色边界 | DirectReply 各 `ROLE_*` 类型 |

### 纸条约会（30 条轻文案）
`今天可以先不急着证明自己。` / `你可以慢一点，慢不代表落后。` / `先把呼吸还给自己。` / `你的感受，不需要被批准才算数。` / `不知道怎么说，也可以从一个词开始。` / … 等 30 条

### ⚠️ 风险点
- 大量中文文案硬编码在引擎 TypeScript 文件中（xinglan/engine/、xinglan/data/），后续多语言/文案调整成本高
- XinglanChatPage.ets 约 2000+ 行，包含 UI builder + 管线逻辑 + 全部交互面板（夜信/镜子/回声卡/轻记得/相处方式）
- 引擎文件中同时包含 forbidden output patterns 列表（`一定会`、`命中注定`、`他爱你` 等）作为安全过滤——这些是过滤关键词，不输出给用户，✅ 正确

---

## 14. 星澜语录

### 功能说明
- **页面**：HomePage（作为 Tab 2 "星澜语录"嵌入 MainFramePage）
- **核心功能**：星澜陪伴文案滚动对话流（"虚拟聊天"风格）
- **文案池**：1018 条星澜语录（`XINGLAN_QUOTES` 常量，位于 `HomePage.ets` lines 34-1050）
- **交互**：点击背景/星澜区域 → 逐条追加语录（含拟真时序：先显示"星澜安静地听着。"→ 0.8-1.5s → 正式文案）
- **首次引导**：`你来了。不急，先坐坐。` / `这里不会替你预言未来，只陪你看看此刻的自己。`（仅首次播放）

### HomePage 文案

| 区块 | 文案 |
|------|------|
| 品牌标题 | `星钥塔罗` |
| 副标题 | `探索内心，点亮星光` |
| 星澜旁白 | `星澜会先接住你的情绪。` |
| 今日一占按钮 | `开始今日一占` |
| 查看记录 | `查看最近记录` |
| 滚动提示 | `轻触上方区域，星澜会回应你。` |
| 倾听提示 | `星澜安静地听着。` |
| 免责声明 | `结果仅供娱乐与自我探索参考，不构成任何专业建议。` |

### 星澜语录样例（1018 条中代表）
1. `今天，也给自己留一张星钥吧。\n不问未来，只看看此刻的你。`
2. `我听见了，慢慢说也没关系。`
3. `你不是想太多，只是很认真地在感受。`
4. `不用马上找到答案，我们先把心放稳一点。`
5. `今天能回来看看自己，就已经很好。`
6. `有些心事，不需要立刻解决。\n先被看见，也很重要。`
7. `如果这件事让你很累，\n我们可以只看最轻的一步。`
8. `你并不孤单。\n星澜会陪你一起走一小段。`
9. `不用证明自己很坚强。\n你可以先休息一下。`
10. `这一次，我们不预测未来。\n只看看现在的你。`

### ⚠️ 注意
- HomePage 右上角有极淡齿轮设置入口（opacity 0.5），点击跳转独立 SettingsPage
- 点击区域绑定在最外层 Column 的 `onClick`，全屏可触发追加语录
- 无假底部导航 — 已由 MainFramePage 统一管理，注释明确说明

---

## 15. 卡牌总览与详情

### 78 张牌状态
- ✅ 78 张塔罗牌数据完整（`TarotCardData.ets`）：
  - 大阿尔卡那：22 张（愚者 ~ 世界）
  - 权杖组：14 张（首牌 ~ 国王）
  - 圣杯组：14 张
  - 宝剑组：14 张
  - 星币组：14 张

### 每张牌字段
| 字段 | 示例 |
|------|------|
| `id` | `'major_00_fool'` |
| `index` | 0–77 |
| `nameZh` | `'愚者'` |
| `nameEn` | `'The Fool'` |
| `arcana` | `MAJOR` / `MINOR` |
| `suit` | `NONE` / `WANDS` / `CUPS` / `SWORDS` / `PENTACLES` |
| `image` | `'tarot_major_00_fool.png'` |
| `keywords` | `['开始', '自由', '冒险']`（3 个） |

### 筛选文案
`全部` / `大阿尔卡那` / `权杖` / `圣杯` / `宝剑` / `星币`

### 卡牌列表展示字段
- 格式化序号（`01`–`78`，金色）
- 中文名（白色 Medium）
- 英文名（灰色小字）
- 关键词 tags（彩色小标签）
- 分类标签（带彩色边框，如 `大阿尔卡那` 金色）
- 箭头 `›`

### 详情页 6 个解读维度（TarotCardDetailPage）

| 维度 | 颜色 | 示例文案生成逻辑 |
|------|------|----------------|
| `正位含义` | `#E8B83D` 金色 | `当{name}以正位出现时，它可能提醒你：{keywords}的力量正在你身边流动...` |
| `逆位含义` | `#8B7EC8` 紫色 | `当{name}以逆位出现时，它也许在照见一种内在的拉扯——你感到{keywords}变得困难...` |
| `情绪陪伴式解读` | `#5ED7D2` 青色 | `这张牌不是在告诉你未来一定会怎样。它更像是一面镜子，提醒你看看自己正在经历什么...` |
| `关系提示` | `#E8A838` 橙色 | `在关系的层面，{name}也许在提醒你：关系中的感受同样重要...` |
| `工作/学习提示` | `#6EB87A` 绿色 | `在工作或学习中，{name}带来的提示是：也许你不需要一次解决所有问题...` |
| `自我探索` | `#94A3B8` 灰色 | `你可以问问自己：\n\n1. 最近有没有什么事情...\n2. 如果这张牌是一个朋友...\n3. 我现在最需要的是...` |

### 图片资源
- 卡牌图片：78 张 .png 文件，存放在 `resources/base/media/`
- TarotCardImage 组件：统一映射 78 张牌的 cardId → Resource
- 未知 cardId fallback：`$r('app.media.card_back')`（TarotCardImage）/ `$r('app.media.placeholder_card')`（TarotCardDetailPage）
- 牌背：`$r('app.media.card_back')` 用于抽牌前/牌轮未确认状态

### 代表卡牌文案样例

**愚者 (The Fool)** — 大阿尔卡那
- 关键词：`开始、自由、冒险`
- 正位：当愚者以正位出现时，它可能提醒你：开始、自由、冒险的力量正在你身边流动...
- 逆位：当愚者以逆位出现时，它也许在照见一种内在的拉扯——你感到开始、自由、冒险变得困难...

**权杖首牌 (Ace of Wands)** — 权杖组
- 关键词：`行动、创造、灵感`

**圣杯首牌 (Ace of Cups)** — 圣杯组
- 关键词：`爱、直觉、情感流动`

**宝剑首牌 (Ace of Swords)** — 宝剑组
- 关键词：`清晰、真理、决断`

**星币首牌 (Ace of Pentacles)** — 星币组
- 关键词：`机会、繁荣、新开始`

### ⚠️ 风险点
- `getCardImageResource()` 图片映射在 3 个文件中重复定义（TarotCardImage.ets、TarotCardDetailPage.ets、TarotCardView.ets）
- 详情页解读为运行时模板生成，非静态数据，文案一致性取决于 `card.keywords` 数据质量
- `InterpretationData.ets` 文件中圣杯骑士逆位关键词含 `'空口承诺'`——此为卡片释义词，描述牌义，不构成对用户的产品承诺，✅ 合规

---

## 16. 设置 / 关于 / 授权

### 设置页（SettingsPage + SettingsTabContent）

| 区块 | 文案 |
|------|------|
| 页面标题 | `设置` |
| 设置项 1 标题 | `重新听听星澜的介绍` |
| 设置项 1 说明 | `星澜会重新陪你走一遍首页的第一次介绍。` |
| 设置项 2 标题 | `关于星钥塔罗` |
| 设置项 2 说明 | `版本信息、隐私政策、用户协议、素材与授权` |
| 成功弹窗 | 标题：`星澜准备好了` / 内容：`星澜的介绍已经准备好了。回到首页时，她会重新陪你走一遍。` / 按钮：`回到首页` |
| 错误弹窗 | 标题：`出错了` / 内容：`重置未完成，请稍后再试。` / 按钮：`知道了` |
| 免责声明 | `结果仅供娱乐与自我探索参考，不构成任何专业建议。` |

> SettingsPage 为主设置页（已完成 P0.3 整改），MainFramePage 内 SettingsTabContent 为简化内联版。

### 关于页（AboutPage）

| 区块 | 文案 |
|------|------|
| 页面标题 | `关于星钥塔罗` |
| 介绍文案 | `星钥塔罗是一款塔罗式情绪陪伴与自我探索 App。` |
| 介绍文案 2 | `星澜不会替你预言未来，只陪你慢慢看见自己。` |
| 入口 1 | `版本信息` / `查看当前版本与更新记录` → VersionInfoPage |
| 入口 2 | `隐私政策` / `了解我们如何保护你的数据` → PrivacyPolicyPage |
| 入口 3 | `用户协议` / `使用服务前请阅读条款` → UserAgreementPage |
| 入口 4 | `素材与授权` / `背景音乐、插画与开源库授权说明` → MaterialsLicensePage |

### 版本信息（VersionInfoPage）

| 区块 | 文案 |
|------|------|
| 页面标题 | `版本信息` |
| 应用名 | `星钥塔罗` |
| 版本号 | `v2.0.0` |
| 更新内容标题 | `更新内容` |
| 更新内容 | `· 底部导航重构：占卜 / 星澜聊天 / 星澜语录 / 卡牌总览 / 设置` `· 新增占卜中心页，整合四种占卜入口` `· 新增卡牌总览模块，78 张塔罗牌完整展示` `· 新增设置页「关于星钥塔罗」模块` `· 新增素材与授权页面` `· 优化整体信息架构与页面组织` |

### 隐私政策 / 用户协议
- 两份完整法律文档存储在 `LegalDocuments.ets`
- `USER_AGREEMENT`：约 3500 字，14 节（lines 11–115）
- `PRIVACY_POLICY`：约 4000 字，13 节（lines 117–305）
- 入口页 `PrivacyPolicyPage` / `UserAgreementPage` 仅负责展示，内容来自 `LegalDocuments`
- 两页均已有 AppBackButton + 顶部导航栏

### 素材与授权（MaterialsLicensePage）— 9 个部分

| # | 章节 | 内容摘要 |
|---|------|---------|
| 一 | 背景音乐 | 列出 5 首：Calm Ambient (leberch/Pixabay)、Reminiscing、Midsummer Sky、Friday Morning、Touching Story（后 4 首作者 Kevin MacLeod/Incompetech/CC BY 4.0） |
| 二 | 音效 | `当前版本暂未使用独立音效素材。` |
| 三 | 插画/图标素材 | 说明可能含 AI 辅助生成，第三方素材将列明 |
| 四 | 字体 | `当前版本主要使用系统默认字体。` |
| 五 | 开源库 | 说明将根据实际工程依赖整理 |
| 六 | AI 生成素材说明 | AI 素材仅用于视觉呈现，不冒充真实作品 |
| 七 | 授权说明 | Pixabay Content License + CC BY 4.0 说明；`上线前请人工核验每首音乐对应页面的署名要求和授权说明。本页面不构成法律意见。` |
| 八 | 使用说明 | 音乐仅作为 App 内背景音乐，不独立分发 |
| 九 | 联系方式 | `若您认为本应用中的素材使用存在授权、署名或其他版权问题，请通过应用商店页面或开发者公开联系方式与我们联系。` |

### 🔴 P0 风险：授权页与实现不同步

| 项目 | 授权页声称 | 实际实现 |
|------|-----------|---------|
| 音乐数量 | 5 首 | 1 首（`bgm_calm_ambient.mp3`，即 Calm Ambient） |
| Reminiscing | 星澜聊天/情绪陪伴/关系探索 | ❌ 未接入 |
| Midsummer Sky | 今日星钥/分享卡/轻陪伴 | ❌ 未接入 |
| Friday Morning | 首页/关系探索/低压力陪伴 | ❌ 未接入 |
| Touching Story | 分享卡生成/情绪提示/短时过场 | ❌ 未接入 |

**如果应用商店审核发现授权页与实际情况不符，存在拒审风险。**

---

## 17. 背景音乐状态

| 项目 | 状态 |
|------|------|
| **是否接入** | ✅ 已接入 |
| **管理器** | `GlobalBgmManager` 单例（`entry/src/main/ets/common/GlobalBgmManager.ets`） |
| **音乐文件** | `bgm_calm_ambient.mp3`（Calm Ambient — leberch / Pixabay） |
| **rawfile 路径** | `entry/src/main/resources/rawfile/bgm_calm_ambient.mp3` |
| **源文件** | `D:\XingKeyTarot\背景音乐\leberch-calm-ambient-主旋律.mp3` |
| **播放策略** | 循环播放（`player.loop = true`）；MainFramePage.aboutToAppear 中 init + play；单例确保不叠音 |
| **音量** | 默认 0.20 |
| **切后台暂停/回前台恢复** | `pause()` / `resume()` 方法已实现，由 EntryAbility 生命周期调用（需验证） |
| **隐私同意前** | ✅ 不会播放（仅在 MainFramePage 中初始化，隐私同意后才到达） |
| **设置开关** | ❌ 未实现（SettingsPage 无音乐开关 UI） |
| **授权页同步** | ❌ 不同步 |

### ⚠️ 风险点
- 无音乐开关 UI，用户无法关闭
- 授权页列 5 首音乐，实际仅接入 1 首
- 其余 4 首 mp3 文件存在于 `背景音乐/` 目录但未复制到 `rawfile/` 且未被代码引用

---

## 18. 视觉设计系统状态

### 已落地

| 要素 | 状态 | 说明 |
|------|------|------|
| **深夜蓝 + 金色** | ✅ | `Theme.BG_DEEP_INDIGO` (#030716 基调) + `Theme.GOLD_LIGHT` / `Theme.GOLD_AMBER` |
| **沉浸光感** | 🟡 部分 | 径向金色光晕在 LaunchPage、HomePage、DivinationCenterPage 中应用；极低透明度（0.01-0.04） |
| **悬浮** | 🟡 部分 | CompanionBottomNav 毛玻璃悬浮胶囊（backdropBlur 16、深色半透明背景、阴影） |
| **吸引** | ✅ | 金色用于选中态和 CTA 按钮（#E8B83D / #E8A838） |
| **动效物理动力学** | ❌ 未完整 | 仅旋转牌轮有惯性+吸附；聊天有分段时序延迟；其余页面动画简单 |
| **统一卡牌尺寸** | 🟡 部分 | TarotCardImage 组件；但 CardWheelDrawPage 独立定义 CARD_WIDTH=80 / CARD_HEIGHT=128 |
| **统一 TarotCardImage** | ✅ | 统一组件，覆盖 78 张牌的 cardId→Resource 映射 |
| **星澜视觉** | 🟡 部分 | 星澜头像 app_icon3.png 圆形 42vp（Header）/ 28vp（聊天消息）；金色描边 |

### 当前不一致处

| 问题 | 位置 | 详细 |
|------|------|------|
| **getCardImageResource 重复** | TarotCardImage.ets / TarotCardDetailPage.ets / TarotCardView.ets | 3 个文件各自维护 78 张牌的 switch-case 映射，增删牌需改 3 处 |
| **页面与 Tab 内联组件重复** | DivinationCenterPage vs DivinationCenterTabContent / TarotCardsPage vs TarotCardsTabContent | 95% 代码相同，仅 AppBackButton 差异 |
| **卡牌尺寸不统一** | CardWheelDrawPage (80×128) vs TarotCardImage default (100×160) | 旋转牌轮中牌背远小于详情页中的卡牌图 |
| **牌背 fallback 不统一** | TarotCardImage 用 `card_back`，TarotCardDetailPage 用 `placeholder_card` | 两个不同的 fallback 资源 |

---

## 19. 已知风险与技术债

### 🔴 高优先级（P0）

| 风险 | 位置 | 说明 |
|------|------|------|
| **授权页与实际不同步** | `MaterialsLicensePage.ets` | 列出 5 首音乐但仅接入 1 首；应用商店审核拒审风险 |
| **设置页无音乐开关** | `SettingsPage.ets` / `SettingsTabContent` | 用户无法关闭背景音乐；可能不符合部分用户预期 |

### 🟡 中优先级（P1）

| 风险 | 位置 | 说明 |
|------|------|------|
| **代码重复** | `TarotCardImage.ets` / `TarotCardDetailPage.ets` / `TarotCardView.ets` 等 | 图片映射、页面与 Tab 组件、卡牌尺寸常量多处重复定义 |
| **旋转牌轮历史保存验证** | `CardWheelDrawPage` → `ResultGoldenPage` / `TriangleResultPage` | 参数传递链较长，需真机确认 spreadType 正确设为 CARD_WHEEL |
| **Tab 1 pushUrl 造成导航不一致** | `MainFramePage.ets` line 84 | 点击星澜聊天 Tab 时 pushUrl 独立页，返回后 currentTab 与底部导航高亮可能不一致 |
| **硬编码中文文案** | `xinglan/engine/`、`xinglan/data/` 下全部文件 | 约 800+ 条中文文案散布在 TypeScript 逻辑文件中 |
| **XinglanChatPage 过大** | `XinglanChatPage.ets` | 约 2000+ 行，含 UI + 管线逻辑 + 全部交互面板 builder |

### 🟢 低优先级（P2）

| 风险 | 位置 | 说明 |
|------|------|------|
| **Timer 残留** | `CardWheelDrawPage.ets` | ✅ `aboutToDisappear` 已正确清理 `inertiaTimerId` + `snapFinishTimerId` |
| **路由返回** | 各页面 | ✅ 均有 `AppBackButton` + fallback 到 `Routes.MAIN_FRAME` |
| **禁止文案** | 全局 | ✅ 全量搜索通过，未发现用户可见越界文案 |
| **图片 fallback** | `TarotCardImage` / `TarotCardDetailPage` | ✅ `card_back` / `placeholder_card` 两种 fallback 均存在 |
| **历史详情空态** | `HistoryDetailPage.ets` | ✅ 记录不存在时显示友好提示 + 返回按钮 |
| **底部导航假入口** | `HomePage.ets` | ✅ 已消除，现由 MainFramePage 统一管理 |
| **星澜视觉漂移** | 全局 | ✅ 统一使用 app_icon3.png 圆形头像 + 金色描边 |

---

## 20. 下一步优先级计划

### P0 — 上架阻塞项

| 任务 | 涉及文件 | 为什么要做 | 预估工时 |
|------|---------|-----------|---------|
| 授权页同步（仅列出实际接入的音乐） | `MaterialsLicensePage.ets` | 应用商店审核可能拒审（授权页与实际不符） | 0.5h |
| 增加背景音乐开关 UI | `SettingsPage.ets` / `SettingsTabContent` / `GlobalBgmManager.ets` | 用户需要控制背景音乐；部分审核要求 | 1h |

### P1 — 质量保障

| 任务 | 涉及文件 | 为什么要做 | 预估工时 |
|------|---------|-----------|---------|
| 旋转牌轮历史保存真机验证 | `CardWheelDrawPage` / `HistoryStore` / `HistoryDetailPage` | 确保 CARD_WHEEL 记录正确保存与显示 | 1h |
| 消除图片映射代码重复 | `TarotCardImage.ets` / `TarotCardDetailPage.ets` / `TarotCardView.ets` | 减少维护成本；统一 fallback 策略 | 2h |
| 底部导航 Tab 1 改为内联切换 | `MainFramePage.ets` | 消除 pushUrl 造成的导航不一致 | 2h |
| 统一卡牌尺寸为常量 | `Theme.ets` 或新常量文件 | 消除多处独立定义 | 0.5h |

### P2 — 体验优化

| 任务 | 涉及文件 | 为什么要做 | 预估工时 |
|------|---------|-----------|---------|
| 设置页丰富化（增加开关/选项） | `SettingsPage.ets` | 当前仅 2 个入口，可扩展 | 2h |
| 星澜语录页视觉强化 | `HomePage.ets` | "开始今日一占"按钮可加强视觉权重 | 1h |
| 聊天文案外置为数据文件 | `xinglan/data/` | 便于后续多语言/文案调整 | 4h |

### P3 — 长期优化

| 任务 | 涉及文件 | 为什么要做 | 预估工时 |
|------|---------|-----------|---------|
| 动效物理动力学落地 | 全局 | 提升品质感 | 8h+ |
| XinglanChatPage 拆分为多个组件 | `XinglanChatPage.ets` | 降低单文件复杂度 | 6h |
| 补充其余 4 首背景音乐或清理未用文件 | `GlobalBgmManager` / `rawfile/` / `MaterialsLicensePage` | 要么接入，要么清理授权页和源文件 | 3h |

---

## 21. 给下一个 Agent 的执行建议

### ✅ 先修什么
1. **授权页同步**（P0）：将 `MaterialsLicensePage.ets` 的背景音乐部分精简为仅列出 `Calm Ambient` 一首，删除其余 4 首（Reminiscing、Midsummer Sky、Friday Morning、Touching Story）的条目，直到实际接入为止
2. **音乐开关**（P0）：在 `SettingsPage` 或 `SettingsTabContent` 中增加背景音乐开关，调用 `GlobalBgmManager.getInstance().play()` / `.pause()`
3. **旋转牌轮历史验证**（P1）：使用真机验证 CardWheelDrawPage 抽牌（抽一张 + 抽三张）后，历史记录是否正确保存与显示

### ❌ 不要修什么
- ❌ 不要修改聊天逻辑（`XinglanChatPage.ets` 的管线、DirectReply、SafetyGuard 优先级等）
- ❌ 不要修改抽牌算法
- ❌ 不要修改历史记录存储逻辑（`HistoryStore.ets`）
- ❌ 不要修改安全边界优先级（CRISIS > ADULT > PROFESSIONAL > PREDICTION > ROLE）
- ❌ 不要修改底部导航结构（5 项不变）
- ❌ 不要修改路由定义（`Routes.ets`）
- ❌ 不要新增或修改任何塔罗牌数据（`TarotCardData.ets`、`InterpretationData.ets`）
- ❌ 不要修改 `LegalDocuments.ets` 中的法律文档
- ❌ 不要修改星澜语录文案池

### 🔒 禁止修改的模块
- `xinglan/engine/` 下所有引擎文件
- `xinglan/data/` 下所有数据文件
- `xinglan/types/XinglanTypes.ets`
- `data/TarotCardData.ets`
- `data/InterpretationData.ets`
- `data/PositiveHeartOptions.ets`
- `model/DivinationHistoryRecord.ets`
- `common/HistoryStore.ets`
- `common/GlobalBgmManager.ets`（除增加开关集成外）
- `common/Routes.ets`
- `common/Constants.ets`
- 所有抽牌页、结果页的核心逻辑（AskHeartPage / CardDrawPage / ResultGoldenPage / TriangleIntroPage / TriangleDrawPage / TriangleResultPage / RelationIntroPage / RelationDrawPage / RelationResultPage / CardWheelModePage / CardWheelDrawPage）

### 🧪 如何验收
1. 运行 `hvigorw assembleHap` 确保 `BUILD SUCCESSFUL` / `ERROR=0`
2. 真机验证：冷启动 → 隐私同意 → 进入 MainFramePage → 5 个 Tab 切换正常
3. 真机验证：占卜中心 → 单牌快占完整流程 → 结果保存到历史 → 历史可查看
4. 真机验证：占卜中心 → 旋转牌轮（抽一张 + 抽三张）→ 结果保存到历史 → 历史详情正确
5. 真机验证：星澜聊天 → 发送消息 → 收到回复 → 夜信/镜子/回声卡/轻记得 触发正常
6. 真机验证：设置页 → 关于 → 版本信息/隐私政策/用户协议/素材与授权 均可打开
7. 真机验证：背景音乐播放正常 → 设置中可开关（如已实现）

---

## 22. 编译状态

| 项目 | 状态 |
|------|------|
| **最近已知构建** | ✅ BUILD SUCCESSFUL（来源：README.md 第 159 行） |
| **ERROR** | 0 |
| **业务 WARN** | 0（已清零） |
| **剩余 WARN** | 仅 DevEco 工具链 `sun.misc.Unsafe`（非阻塞） |
| **签名** | ⏸️ `No signingConfig found`（后续单独配置） |

---

## 附录 A：关键文件路径索引

### 框架与路由
- `entry/src/main/ets/common/Routes.ets` — 路由常量（30 条路由）
- `entry/src/main/ets/pages/MainFramePage.ets` — 主框架（含 5 个 Tab 内联组件，~1025 行）
- `entry/src/main/ets/components/CompanionBottomNav.ets` — 底部导航（5 项毛玻璃胶囊，~148 行）
- `entry/src/main/ets/pages/LaunchPage.ets` — 启动隐私门禁
- `entry/src/main/resources/base/profile/main_pages.json` — 页面注册（26 个页面）

### 占卜
- `entry/src/main/ets/pages/DivinationCenterPage.ets` — 占卜中心（独立页，5 入口）
- `entry/src/main/ets/pages/AskHeartPage.ets` — 单牌方向选择（双模式切换）
- `entry/src/main/ets/pages/CardDrawPage.ets` — 单牌抽牌动画
- `entry/src/main/ets/pages/ResultGoldenPage.ets` — 单牌结果（金句+行动+深度解读）
- `entry/src/main/ets/pages/TriangleIntroPage.ets` — 圣三角引导
- `entry/src/main/ets/pages/TriangleDrawPage.ets` — 圣三角抽牌
- `entry/src/main/ets/pages/TriangleResultPage.ets` — 圣三角结果（被 CardWheelDrawPage 复用）
- `entry/src/main/ets/pages/RelationIntroPage.ets` — 关系探索引导
- `entry/src/main/ets/pages/RelationDrawPage.ets` — 关系抽牌
- `entry/src/main/ets/pages/RelationResultPage.ets` — 关系结果
- `entry/src/main/ets/pages/CardWheelModePage.ets` — 牌轮模式选择（抽一/抽三）
- `entry/src/main/ets/pages/CardWheelDrawPage.ets` — 旋转牌轮抽牌（惯性+吸附+timer 清理）
- `entry/src/main/ets/data/PositiveHeartOptions.ets` — 积极方向选项数据

### 历史
- `entry/src/main/ets/pages/HistoryPage.ets` — 历史列表（5 筛选+清空+空状态）
- `entry/src/main/ets/pages/HistoryDetailPage.ets` — 历史详情
- `entry/src/main/ets/model/DivinationHistoryRecord.ets` — 历史数据模型（SpreadType + EntryMode 枚举）
- `entry/src/main/ets/common/HistoryStore.ets` — 历史存储服务（FIFO 50 条）

### 星澜聊天
- `entry/src/main/ets/pages/XinglanChatPage.ets` — 聊天页（2000+ 行，含全部交互面板）
- `entry/src/main/ets/xinglan/types/XinglanTypes.ets` — 类型定义
- `entry/src/main/ets/xinglan/engine/` — 引擎目录（14 个文件）：
  - `XinglanDirectReplyEngine.ets` — DirectReply（23 种类型，约 120 条变体）
  - `XinglanMiniInteractionEngine.ets` — MiniInteraction（8 种）
  - `XinglanInteractionFlowEngine.ets` — 交互 Flow（多条路径）
  - `XinglanInterruptDetector.ets` — 打断检测（SAFETY/DIRECT/NEW_TOPIC）
  - `XinglanSafetyGuard.ets` — 安全守卫
  - `XinglanComposer.ets` — 回复合成
  - `XinglanRouter.ets` — 路由规划
  - `XinglanAnalyzer.ets` — 输入分析
  - `XinglanSessionManager.ets` — 会话管理
  - `XinglanSpecialIntentResolver.ets` — 特殊意图
  - `XinglanCompanionModeEngine.ets` — 陪伴模式
  - `XinglanNightLetterEngine.ets` 等 — 夜信/镜子/回声/轻记得引擎
- `entry/src/main/ets/xinglan/data/` — 数据目录（10+ 个文件）：
  - `XinglanTemplates.ets` — 模板 + forbidden patterns
  - `XinglanCorpus.ets` — 安全/边界语料库
  - `XinglanKeywords.ets` — 关键词检测
  - `XinglanPaperNotes.ets` — 30 条纸条
  - `XinglanQuestionOptions.ets` — 天气问题选项树
  - `XinglanCompanionChoices.ets` — 5 种相处方式
  - `XinglanNightLetters.ets` — 5 主题夜信正文
  - `XinglanStarKeyMirror.ets` — 5 主题镜子正文
  - `XinglanEchoCards.ets` — 9 种情绪回声卡
  - `XinglanLightMemory.ets` — 5 种轻记得偏好

### 语录
- `entry/src/main/ets/pages/HomePage.ets` — 星澜语录主页（1018 条语录 + 首次引导 + 拟真时序）

### 卡牌
- `entry/src/main/ets/pages/TarotCardsPage.ets` — 卡牌总览（独立页）
- `entry/src/main/ets/pages/TarotCardDetailPage.ets` — 卡牌详情（6 维度 + 全屏预览）
- `entry/src/main/ets/data/TarotCardData.ets` — 78 张牌基础数据
- `entry/src/main/ets/data/InterpretationData.ets` — 156 条正逆位解读数据
- `entry/src/main/ets/components/TarotCardImage.ets` — 统一卡牌图组件
- `entry/src/main/ets/components/TarotCardView.ets` — 卡牌视图（IDLE/REVEALED 状态）

### 设置与合规
- `entry/src/main/ets/pages/SettingsPage.ets` — 设置页
- `entry/src/main/ets/pages/AboutPage.ets` — 关于页（4 入口）
- `entry/src/main/ets/pages/VersionInfoPage.ets` — 版本信息（v2.0.0）
- `entry/src/main/ets/pages/PrivacyPolicyPage.ets` — 隐私政策展示
- `entry/src/main/ets/pages/UserAgreementPage.ets` — 用户协议展示
- `entry/src/main/ets/pages/MaterialsLicensePage.ets` — 素材与授权（9 部分）
- `entry/src/main/ets/common/LegalDocuments.ets` — 法律文档全文（~305 行）

### 公共
- `entry/src/main/ets/common/Constants.ets` — 全局常量（APP_NAME、合规文案、隐私门禁等）
- `entry/src/main/ets/common/Theme.ets` — 主题/色彩常量
- `entry/src/main/ets/common/GlobalBgmManager.ets` — 全局背景音乐（单例，~295 行）
- `entry/src/main/ets/components/AppBackButton.ets` — 统一返回按钮

### 资源
- `entry/src/main/resources/rawfile/bgm_calm_ambient.mp3` — 背景音乐（唯一）
- `entry/src/main/resources/base/media/` — 78 张卡牌图片 + 星澜头像 + 图标资源

---

## 附录 B：文案统计总览

| 模块 | 估算文案条数 |
|------|------------|
| 启动与主框架 | ~15 |
| 底部导航 | 5 标签 |
| 占卜中心 | ~10 |
| 单牌快占（AskHeart+CardDraw+ResultGolden） | ~50 |
| 圣三角牌阵 | ~26 |
| 关系探索 | ~36 |
| 旋转牌轮 | ~34 |
| 历史记录 | ~41 |
| 星澜聊天（DirectReply+MiniInteraction+Flow+夜信+镜子+回声+轻记得+相处方式+安全边界+纸条） | ~800+ |
| 星澜语录 | 1018 条 |
| 卡牌总览与详情 | ~20（UI）+ 78×6（解读模板约 468） |
| 设置/关于/授权 | ~40 + 2 份法律文档（约 7500 字） |
| 全局常量 | ~12 |
| **总计** | **约 2500+ 条独立中文文案** |

---

> **报告完成时间**：2026-06-30  
> **审计方式**：只读文件读取 + 代码搜索 + 子代理文案提取  
> **编译验证**：见第 22 节（最近已知 BUILD SUCCESSFUL / ERROR=0）  
> **下一步**：按第 20 节 P0 → P1 → P2 → P3 执行

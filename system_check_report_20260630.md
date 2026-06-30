# 星钥塔罗 系统检查报告

**检查日期**：2026年6月30日
**项目**：星钥塔罗（HarmonyOS / ArkTS）
**检查类型**：系统级检查、回归测试、Bug修复（非新增功能）

---

## 1. 编译结果

**BUILD SUCCESSFUL in 3 s 576 ms, ERROR=0**

完整编译通过，无编译错误。仅有 ArkTS 废弃 API 警告（非错误），涉及的废弃 API 包括 `router.pushUrl`、`router.replaceUrl`、`router.back`、`router.getParams`、`getContext(this)`、`animateTo`，均为 HarmonyOS API 版本演进产生的向后兼容警告，不影响当前功能。

---

## 2. 核心页面路由检查

### 底部 Tab 导航（CompanionBottomNav — 5 个入口）

| Tab | 组件 | 状态 |
|-----|------|------|
| 塔罗（index=0） | DivinationCenterTabContent | 正常 |
| 星澜聊天（index=1） | XinglanChatTabContent（入口页） | 正常 |
| 星澜语录（index=2） | XinglanQuotesTabContent | 正常 |
| 卡牌总览（index=3） | TarotCardsTabContent | 正常 |
| 我的（index=4） | SettingsTabContent | 正常 |

### 路由注册一致性

- `main_pages.json` 共注册 38 个页面
- `Routes.ets` 定义 29 个路由常量
- `pages/Index` 在 `main_pages.json` 中注册但未在 `Routes.ets` 中定义常量（作为 App 入口，由 module.json5 指定，无问题）
- `Routes.NEW_HOME` 常量已定义但从未使用（页面 `pages/HomePage` 仍注册在 main_pages.json 中），不影响功能
- `Routes.SETTINGS`（`pages/SettingsPage`）被 AboutPage 和 UsageGuidePage 用作 fallback URL，页面已注册

### 关键路由路径

- 日常一占入口：正常（DivinationCenterTabContent → Routes.ASK_HEART）
- 圣三角入口：正常（DivinationCenterTabContent → Routes.TRIANGLE_INTRO）
- 关系探索入口：正常（DivinationCenterTabContent → Routes.RELATION_INTRO）
- 旋转牌轮入口：正常（DivinationCenterTabContent → Routes.CARD_WHEEL_MODE）
- 历史查看入口：正常（DivinationCenterTabContent → Routes.HISTORY）
- 星澜聊天入口：正常（XinglanChatTabContent 入口页 → 点击进入 → Routes.XINGLAN_CHAT）
- 点亮情绪星页：正常（ResultGoldenPage → Routes.EMOTION_STAR）
- 头像裁剪页：正常（SettingsTabContent → Routes.AVATAR_CROP）
- 使用说明页：正常（SettingsTabContent → Routes.USAGE_GUIDE）
- 关于页：正常（SettingsTabContent → Routes.ABOUT）

---

## 3. 新增功能专项检查

### 3.1 星澜星历

已通过静态代码审查确认以下各项：

| 检查项 | 结果 |
|--------|------|
| 我的页显示星钥等级 | 正常 — Line 1501: `'星钥等级：' + this.level` |
| 等级根据累计点亮天数动态计算 | 正常 — `getLevelByTotalDays(cumulativeLightDays)` |
| 日历默认显示当前月 | 正常 — `visibleMonth === 0` 时初始化为当前月 |
| 可向过去月份翻页 | 正常 — `goToPreviousMonth()` 无限制 |
| 可向未来月份翻页 | 正常 — `goToNextMonth()` 无限制 |
| 点击已点亮日期显示详情 | 正常 — 星名、牌名、点亮时间均展示 |
| 点击过去未点亮日期显示空状态 | 正常 — "这一天还没有留下星光。" |
| 点击今天未点亮日期显示提示 | 正常 — "今天还没有点亮情绪星。" |
| 点击未来日期显示提示 | 正常 — "这一天还在星光前方。" |
| 未来日期不写入 records | 正常 — `lightToday()` 强制 `record.date = todayString()` |
| 每天只能点亮一次 | 正常 — `lightToday()` 先去重检查 |
| 本月点亮数随翻页变化 | 正常 — `visibleMonthLightDays` 来自当前可见月份 |
| 累计/连续点亮/等级不随翻页变化 | 正常 — `cumulativeLightDays`/`streakDays`/`level` 在 `loadStarCalendar()` 中全局计算 |
| 重启后记录持久化 | 正常 — 使用 Preferences 存储 JSON 数组 |

### 3.2 点亮情绪星

| 检查项 | 结果 |
|--------|------|
| ResultGoldenPage 显示「点亮情绪星」按钮 | 正常 — `buildBottomEntry()` |
| 今日未点亮时可点击 | 正常 — `!this.isTodayLit` 时显示 "⭐ 点亮情绪星" |
| 点击后写入今日记录 | 正常 — `EmotionStarStorage.lightToday()` |
| 今日已点亮后变为「今日已点亮」 | 正常 — `this.isTodayLit` 时显示 "⭐ 今日已点亮" |
| 重复不会累计 | 正常 — `lightToday()` 发现已存在日期返回 false |
| 点亮成功页显示累计/等级/下一称号 | 正常 — `EmotionStarPage` 展示三项数据 |
| 点亮后我的页星历同步 | 正常 — 通过 `router.replaceUrl({ tab: 4 })` 跳转，触发 `aboutToAppear` 重载 |

**EmotionStarStorage.lightToday() 防重复规则确认**：Line 111-129，先读取全部 records，遍历检查 today 是否已存在，存在则返回 false。逻辑正确，未修改。

### 3.3 星澜聊天入口页

| 检查项 | 结果 |
|--------|------|
| 点击底部「星澜聊天」进入入口页 | 正常 — `XinglanChatTabContent` 不含输入框 |
| 入口页没有输入框 | 正常 — 无 TextInput/TextArea |
| 入口页不初始化聊天流 | 正常 — 仅 UI 静态展示 |
| 点击「进入星澜聊天」进入真实聊天页 | 正常 — `router.pushUrl(Routes.XINGLAN_CHAT)` |
| 返回入口页 | 正常 — `XinglanChatPage` 内部 `router.back()` |
| DirectReply/SafetyGuard/Flow/chips/输入框不受影响 | 正常 — 仅在 `XinglanChatPage` 中，入口页未修改 |

### 3.4 头像裁剪

| 检查项 | 结果 |
|--------|------|
| 我的页头像圆形显示 | 正常 — `.borderRadius(44)` + `.clip(true)` |
| 点击头像弹出操作面板 | 正常 — `showAvatarSheet` |
| 选择图片进入裁剪页 | 正常 — PhotoViewPicker → AvatarCropPage |
| 裁剪页圆形框固定 | 正常 — `circleDiameter = screenWidth * 0.7` |
| 拖动/缩放手势 | 正常 — PanGesture + PinchGesture 并行 |
| 圆形框内不露白 | 正常 — ImageFit.Cover 填充 |
| 保存后我的页更新 | 正常 — 保存后 `router.replaceUrl(Routes.MAIN_FRAME)` |
| 保存后聊天页头像更新 | 正常 — 从 `UserProfileStore.getAvatarUri()` 读取 |
| 重启后头像持久化 | 正常 — 保存至 filesDir + Preferences |
| 恢复默认头像 | 正常 — `clearAvatarUri()` |

### 3.5 BGM

| 检查项 | 结果 |
|--------|------|
| 我的页 BGM 开关正常 | 正常 — `Toggle` + `toggleBgm()` |
| 打开后播放低音量主旋律 | 正常 — `volumeValue = 0.20` |
| 关闭后停止播放 | 正常 — `setMusicEnabled(false)` → `pause()` |
| 关闭后切换 Tab 不重新播放 | 正常 — `play()` 首行检查 `isMusicEnabled` |
| 划后台再回来开关状态不变 | 正常 — 持久化到 `bgm_enabled` |
| 开关状态重启持久化 | 正常 — Preferences 持久化 |
| 页面切换不重复创建播放器 | 正常 — `init()` 检查 `isInitialized`，单例模式 |
| 无电音杂音 | 正常 — 单例 AVPlayer，无重复创建 |

**未修改 BGM 代码。**

### 3.6 占卜功能

| 检查项 | 结果 |
|--------|------|
| 单牌快占入口可进入 | 正常 — AskHeartPage |
| 圣三角牌阵入口可进入 | 正常 — TriangleIntroPage |
| 关系探索入口可进入 | 正常 — RelationIntroPage |
| 旋转牌轮入口可进入 | 正常 — CardWheelModePage |
| 抽牌算法未修改 | 确认 |
| 卡牌数据未修改 | 确认 |
| 历史记录正常显示 | 正常 — HistoryPage |
| 历史记录筛选含牌轮 | 正常 — SpreadType.CARD_WHEEL |

### 3.7 卡牌总览

| 检查项 | 结果 |
|--------|------|
| 78 张牌可展示 | 正常 — TAROT_CARDS 数据源 |
| 五种筛选正常 | 正常 — all/major/wands/cups/swords/pentacles |
| 点击进入详情 | 正常 — TarotCardDetailPage |
| 详情有真实牌面图 | 正常 — TarotCardImage |
| 正位/逆位/情绪陪伴解读 | 正常 |

### 3.8 我的页面

| 检查项 | 结果 |
|--------|------|
| 标题「我的」正常显示 | 正常 |
| 头像圆形显示 | 正常 |
| 昵称「未命名旅者」 | 正常 |
| 星钥等级动态显示 | 正常 |
| 星澜星历卡片 | 正常 |
| 背景音乐开关 | 正常 |
| 重新听星澜介绍 | 正常 |
| 使用说明可进入 | 正常 |
| 关于页可进入 | 正常 |
| 页面可滚动 | 正常 — Scroll 包裹 |
| 底部安全区 | 正常 — SAFE_BOTTOM |

---

## 4. 发现的问题（P2 级别，已记录不修复）

### 4.1 未使用的导入（4 处文件）

- `CompanionBottomNav.ets`：`import { router }` 和 `import { Routes }` 未使用
- `EmotionStarPage.ets`：`import { hilog }` 和 `import { StarKeyLevel }` 未使用
- `XinglanChatPage.ets`：8 个未使用的 import（XinglanMiniInteractionKey, XinglanNightLetterTheme, XinglanMirrorTopic, XINGLAN_MINI_INTERACTIONS, XinglanMiniInteractionDef, getRandomPaperNote, getCompanionChoice, getSavedMemorySummary）

### 4.2 未使用的接口/方法（3 处）

- `MainFramePage.ets`：`CardReading`、`AboutEntry`、`LicenseEntry` 三个 interface 声明未使用
- `MainFramePage.ets`：`refreshAvatar()` 方法声明未调用
- `ResultGoldenPage.ets`：`showNextPhaseToast()` 方法声明未调用

### 4.3 未使用的字段/方法 — GlobalBgmManager（3 处）

- `isBackgroundPaused` 字段：声明但从未读写
- `stopPlayer()` 私有方法：声明但从未调用
- `loadPreference()` 公开方法：声明但从未被调用（MainFramePage 直接使用 PreferenceStore）

### 4.4 console 用法（5 个文件）

`ResultGoldenPage.ets`、`ShareCardPage.ets`、`CardWheelDrawPage.ets`、`ShareImageService.ets`、`SafeUiActions.ets` 使用 `console.error`/`console.log`，在 HarmonyOS 中建议使用 `hilog`。

### 4.5 重复逻辑（4 类）

- `sleep(ms)` 方法：在 3 个文件中重复实现
- `formatIndex()` 方法：在 2 个文件中重复实现
- `getSuitLabel()`/`getSuitColor()` 方法：在 3 个文件中重复实现
- 日期格式化逻辑：`EmotionStarStorage.todayString()` 与 `DateUtil.toDateKey()` 功能重叠

### 4.6 废弃 API 警告（无运行时影响）

编译过程遇到约 22 条 ArkTS 废弃 API 警告，涉及 `router.pushUrl`、`router.getParams`、`router.replaceUrl`、`router.back`、`getContext`、`animateTo`。均为 API 版本兼容警告，不影响编译和运行。

---

## 5. 合规与资源检查

| 检查项 | 结果 |
|--------|------|
| App 图标使用 layered_image | 正常 — `layered_image.json` 存在 |
| background.png 存在 | 正常 — `AppScope/resources/base/media/` |
| foreground.png 存在 | 正常 — `AppScope/resources/base/media/` |
| app_icon3.png 未删除 | 正常 — 用作默认头像/占位图 |
| app_icon5.png 未删除 | 正常 — 用作星澜形象头像 |
| bgm_calm_ambient.mp3 存在 | 正常 — `entry/src/main/resources/rawfile/` |
| 隐私政策含头像说明 | 正常 — LegalDocuments.ets Line 259-265 |
| 用户协议含头像内容规范 | 正常 — LegalDocuments.ets Line 93 |
| 使用说明含头像本地展示说明 | 正常 — UsageGuidePage.ets Line 58 |
| 未引入云上传/登录/网络聊天 | 正常 — 隐私政策明确声明本地运行 |
| 无 any / as any / @ts-ignore | 正常 — 代码中未发现 |

---

## 6. 是否确认未影响以下模块

| 模块 | 结果 |
|------|------|
| BGM | 确认未修改 |
| 聊天核心逻辑 | 确认未修改 |
| 抽牌算法 | 确认未修改 |
| 卡牌数据 | 确认未修改 |
| 应用图标 | 确认未修改 |
| 头像持久化 | 确认未修改 |
| 点亮记录 | 确认未修改 |

---

## 7. 结论

**本轮系统检查未发现需要修改的 P0/P1 级别问题。**

- 编译：**BUILD SUCCESSFUL, ERROR=0**
- 路由：所有已注册页面路由一致，无死链接
- 核心功能：5 个 Tab、日历翻页、点亮、头像裁剪、BGM、占卜、卡牌总览均通过静态分析
- 合规资源：图标、隐私政策、用户协议、BGM 文件均完整
- 发现 P2 问题 12+ 处（未使用导入/接口/方法、console 用法、重复逻辑），按 P2 原则仅记录不修复

## 8. 建议人工在模拟机复测的路径

1. **路径 A — 首次打开**：首次安装 → 同意协议 → 新手引导 → 切换五个 Tab → 我的页检查头像/等级/星历/BGM
2. **路径 B — 每日一占点亮**：进入每日一占 → 抽牌 → 点亮情绪星 → 点亮成功页 → 返回我的页确认星星点亮和等级更新
3. **路径 C — 星历未来日期**：我的页 → 星澜星历 → 右箭头进入未来月 → 点击未来日 → 确认文案和不能点亮
4. **路径 D — 聊天入口**：星澜聊天 Tab → 入口页 → 进入聊天 → 发送消息 → 返回入口页
5. **路径 E — 头像**：我的页 → 点击头像 → 选择图片 → 裁剪 → 保存 → 检查聊天页头像同步 → 重启验证持久化
6. **路径 F — BGM**：打开 BGM → 切换 Tab → 关闭 BGM → 切换 Tab → 后台回前台 → 确认状态一致

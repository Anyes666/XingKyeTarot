# 星钥塔罗 — 全量文件清单与用途说明

> 扫描日期：2026-07-01 · 项目根：`D:\XingKeyTarot\entry\src\main\ets\`

---

## 一、pages/ — 页面（40 个文件）

### 启动与主框架

| 文件 | 大小 | 用途 |
|------|------|------|
| `SplashPage.ets` | 1.6KB | 启动闪屏，显示品牌图后自动跳转 LaunchPage |
| `LaunchPage.ets` | 8.5KB | 隐私门禁页：同意/不同意 → replaceUrl 到 MainFramePage；可查看用户协议/隐私政策 |
| `MainFramePage.ets` | 84.3KB | **主框架容器**：5 Tab 条件渲染 + CompanionBottomNav + 5 个内联 Tab 组件（DivinationCenterTabContent、XinglanChatTabContent、XinglanQuotesTabContent、TarotCardsTabContent、SettingsTabContent）+ 星历弹窗 + 昵称弹窗 + 日期详情弹窗 |
| `Index.ets` | 17.7KB | 旧版启动页（Phase 6 前架构，保留兼容） |
| `OnboardingPage.ets` | 7.6KB | 旧版新手引导页（不可达） |

### 占卜

| 文件 | 大小 | 用途 |
|------|------|------|
| `DivinationCenterPage.ets` | 9.1KB | **占卜中心**（独立页）：5 入口卡片（单牌快占/圣三角/关系探索/旋转牌轮/历史查看） |
| `AskHeartPage.ets` | 15.2KB | 单牌方向选择：双模式切换（被接住/看见光），情绪标签 + 积极标签 |
| `CardDrawPage.ets` | 10.7KB | 单牌抽牌动画：翻牌动画 + 金色粒子，含 P0 timer 清理 |
| `ResultGoldenPage.ets` | 29.9KB | **单牌结果页**：金句 + 今日行动 + 深度解读 + 星澜陪伴文案 + 追问/分享/情绪星按钮 |
| `TriangleIntroPage.ets` | 6.9KB | 圣三角引导：牌阵说明卡 + 场景 chips + 输入框 |
| `TriangleDrawPage.ets` | 9.3KB | 圣三角抽三张：依次揭开动画 + 跳转结果页，含 P0 timer 清理 |
| `TriangleResultPage.ets` | 14.7KB | **圣三角结果页**：三张牌分析 + 综合解读 + 星澜陪伴文案；也被牌轮抽三张复用 |
| `RelationIntroPage.ets` | 7.0KB | 关系探索引导：6 种关系类型 chips + 边界提醒 + 输入框 |
| `RelationDrawPage.ets` | 7.9KB | 关系探索抽三张：依次揭开动画 + 跳转结果，含 P0 timer 清理 |
| `RelationResultPage.ets` | 14.6KB | **关系探索结果页**：我/对方/走向 + 边界提醒 + 综合解读 + 星澜陪伴文案 |
| `CardWheelModePage.ets` | 5.4KB | 旋转牌轮模式选择：抽一张星钥 / 抽三张星钥 |
| `CardWheelDrawPage.ets` | 33.6KB | **旋转牌轮抽牌**：环形循环牌轮 + Pan 手势 + 惯性引擎 + 中心吸附 + timer 清理 |
| `DivinationPage.ets` | 12.0KB | 旧版占卜页（不可达） |
| `DivinationResultPage.ets` | 8.2KB | 旧版结果页（不可达） |
| `DailyFortunePage.ets` | 8.3KB | 每日一占页（旧链路） |

### 历史

| 文件 | 大小 | 用途 |
|------|------|------|
| `HistoryPage.ets` | 14.3KB | 历史记录列表：5 筛选 + V2A 卡片 + 空状态 + 清空确认 |
| `HistoryDetailPage.ets` | 11.0KB | 历史详情：完整记录展示 + 综合解读 + 行动建议 + 删除 |
| `DivinationHistoryPage.ets` | 7.8KB | 旧版占卜历史（不可达） |

### 聊天

| 文件 | 大小 | 用途 |
|------|------|------|
| `XinglanChatEntrancePage.ets` | 16.0KB | **星澜聊天入口页**（月光门廊）：立绘 + 月光 + 昵称问候 + 走进月光门廊按钮 |
| `XinglanChatPage.ets` | 59.8KB | **星澜聊天页**：完整聊天管线 + 夜信/镜子/回声卡/轻记得/相处方式面板 |
| `FollowUpPage.ets` | 7.6KB | 追问星澜页（结果页跳转） |

### 卡牌

| 文件 | 大小 | 用途 |
|------|------|------|
| `TarotCardsPage.ets` | 8.8KB | **卡牌总览**（独立页）：78 张 3 列牌面网格 + 6 分类筛选 |
| `TarotCardDetailPage.ets` | 22.5KB | 卡牌详情：大图预览缩放 + 6 维度解读（正位/逆位/陪伴式/关系/工作/自我探索） |

### 语录

| 文件 | 大小 | 用途 |
|------|------|------|
| `HomePage.ets` | 80.7KB | 星澜语录**遗留独立页**（1018 条文案池，不可达，被 XinglanQuotesTabContent 替代） |

### 设置 / 我的 / 合规

| 文件 | 大小 | 用途 |
|------|------|------|
| `SettingsPage.ets` | 9.4KB | 设置页（独立）：BGM 开关 + 重新听介绍 + 关于入口 + 使用说明 |
| `AboutPage.ets` | 4.6KB | 关于页：版本信息/隐私政策/用户协议/素材与授权入口 |
| `VersionInfoPage.ets` | 4.4KB | 版本信息：v2.0.0 + 更新日志 |
| `PrivacyPolicyPage.ets` | 1.7KB | 隐私政策全文展示（内容来自 LegalDocuments） |
| `UserAgreementPage.ets` | 1.7KB | 用户协议全文展示（内容来自 LegalDocuments） |
| `MaterialsLicensePage.ets` | 6.3KB | 素材与授权：1 首 bgm_calm_ambient.mp3 + 音效/插画/字体/AI素材/开源库说明 |
| `UsageGuidePage.ets` | 12.5KB | 使用说明：8 个板块卡片介绍各功能区 |

### 星历 / 情绪星 / 头像

| 文件 | 大小 | 用途 |
|------|------|------|
| `StarCalendarPage.ets` | 11.6KB | 星澜星历月视图：点亮日期展示 + 累计天数 + 星钥等级 |
| `EmotionStarPage.ets` | 13.1KB | 点亮情绪星成功页：累计点亮天数 + 等级提升弹窗 |
| `AvatarCropPage.ets` | 13.4KB | 头像裁剪页：圆形裁剪框 + 拖动/缩放手势 + 本地保存 |
| `ShareCardPage.ets` | 19.7KB | 分享卡生成：支持单牌/圣三角/关系三种布局 + componentSnapshot 截图 + 相册保存 |

---

## 二、components/ — 复用组件（17 个文件）

| 文件 | 大小 | 用途 |
|------|------|------|
| `CompanionBottomNav.ets` | 4.3KB | **底部导航**：5 键毛玻璃悬浮胶囊（⬡☾✦▤◎），含按压缩放反馈 |
| `AppBackButton.ets` | 1.5KB | **统一返回按钮**：48×48 热区 + fallback 路由 |
| `TarotCardImage.ets` | 7.3KB | **统一卡牌图组件**：78 张 cardId→Resource 映射，含 fallback |
| `TarotCardView.ets` | 12.8KB | 卡牌视图：IDLE（牌背）和 REVEALED（真实牌面）两种状态 + 点亮动画 |
| `PressableScaleButton.ets` | 2.6KB | **轻量按压反馈按钮**：scale 0.97 + EaseOut 120ms + onTouch |
| `PrimaryButton.ets` | 1.2KB | 旧版主按钮组件 |
| `ComplianceFooter.ets` | 0.9KB | 合规页脚："结果仅供娱乐…"免责声明 |
| `DivinationEntryCard.ets` | 2.5KB | 占卜入口卡片：按压态 scale + V2C 样式 |
| `HeartOptionCard.ets` | 2.8KB | 心事选项卡片：选中态高亮 + V2C 样式 |
| `ResultCardSlot.ets` | 3.5KB | 结果卡槽：展示单张牌位 + 牌面 + 关键词 |
| `CardFrame.ets` | 2.7KB | 卡牌边框组件：正/逆位标签 + 烫金框 |
| `BoundaryReminder.ets` | 1.4KB | 边界提醒卡片：关系页中的温柔提醒 |
| `InterpretationPanel.ets` | 2.4KB | 解读面板：结果页牌面解读展示 |
| `SharePreview.ets` | 6.2KB | 分享图预览：1080×1920 截图用布局 |
| `LevelUpPopup.ets` | 6.1KB | 星钥等级升级弹窗：V2C 样式 |
| `MoonlightLayer.ets` | 1.9KB | 月光呼吸层：6s 无限循环 opacity 动画 |
| `StarBackground.ets` | 1.9KB | 星空背景装饰：静态星点 |

---

## 三、common/ — 公共模块（11 个文件）

| 文件 | 大小 | 用途 |
|------|------|------|
| `Routes.ets` | 3.0KB | **路由常量**：定义全部 30 条页面路由字符串 |
| `Theme.ets` | 20.4KB | **v2 设计系统 Token**：A/B/C 三套色板 + 字号 + 间距 + 圆角 + 阴影 + 动效参数 |
| `Constants.ets` | 2.9KB | 全局常量：APP_NAME、合规文案、情绪标签、持久化 key |
| `GlobalBgmManager.ets` | 13.0KB | **全局背景音乐单例**：AVPlayer 管理 + loadPreference + setMusicEnabled + pause/resume/release |
| `HistoryStore.ets` | 6.1KB | 历史记录存储：addRecord/getRecords/deleteRecordById/clearAll（FIFO 50） |
| `UserProfileStore.ets` | 3.4KB | **用户资料存储**：头像 URI + 昵称 + 等级 get/set/clear/display |
| `LegalDocuments.ets` | 24.9KB | **法律文档全文**：用户协议（14 节）+ 隐私政策（13 节），约 7500 字 |
| `AppStateStore.ets` | 4.3KB | 应用状态：隐私同意/Onboarding/首次体验 |
| `EmotionStarStorage.ets` | 11.7KB | 情绪星存储：每日点亮 + 累计/连续天数 + 等级计算 |
| `SafeUiActions.ets` | 0.5KB | 安全 UI 操作：showToast + showAlertDialog 封装 |
| `Types.ets` | 1.5KB | 公共类型定义 |

---

## 四、data/ — 数据层（12 个文件）

| 文件 | 大小 | 用途 |
|------|------|------|
| `TarotCardData.ets` | 17.5KB | **78 张塔罗牌基础数据**：id/nameZh/nameEn/arcana/suit/image/keywords |
| `InterpretationData.ets` | 41.7KB | 156 条正逆位解读：每张牌 upright/reversed 含义 + 关键词 |
| `TarotCardRepository.ets` | 10.2KB | 卡牌仓库：drawCardByWeight/drawCardByPositiveWeight/drawUniqueCards/getCardKeyword 等 |
| `MVP8CardsData.ets` | 48.6KB | 8 张核心牌深度互动数据（愚者/女祭司/恋人/战车/隐士/命运之轮/死神/月亮） |
| `HeartOptionsData.ets` | 5.0KB | 被接住方向选项数据 |
| `PositiveHeartOptions.ets` | 26.8KB | 积极方向选项数据（6 个阳光标签 + 对应金句+行动+解读） |
| `CompanionResultLines.ets` | 1.0KB | 陪伴结果页旁白文案 |
| `PreferenceStore.ets` | 2.6KB | 本地偏好存储封装：getBoolean/putBoolean/getString/putString |
| `TarotDataLoader.ets` | 0.5KB | 旧版数据加载器 |
| `XinglanTypes.ets` | 8.8KB | 星澜聊天旧类型定义（已迁移到 xinglan/types/） |
| `XinglanNicknameGreetings.ets` | 8.1KB | **昵称问候文案池**：20 条入口页问候 + selectEntryGreeting + 防重复逻辑 |
| `XinglanResultCompanionText.ets` | 3.4KB | **结果页陪伴文案**：getSingleCardCompanionText/getTriangleCompanionText/getRelationCompanionText |

---

## 五、xinglan/ — 星澜聊天引擎（30 个文件）

### xinglan/types/ — 类型定义

| 文件 | 大小 | 用途 |
|------|------|------|
| `XinglanTypes.ets` | 14.0KB | **聊天系统全部类型**：EmotionTag、TopicTag、BoundaryTag、MiniInteractionKey、CompanionChoice、ChatMessage、Session、Flow 状态等枚举/接口 |

### xinglan/data/ — 数据层

| 文件 | 大小 | 用途 |
|------|------|------|
| `XinglanDirectReplies.ets` | 16.3KB | 22 种 DirectReply 高频回复数据（约 120 条变体） |
| `XinglanCorpus.ets` | 30.0KB | 安全/边界语料库：危机回复、角色边界、温和拒绝等 |
| `XinglanKeywords.ets` | 22.7KB | **关键词检测数据**：专业/角色/预测/情绪等分类关键词列表 |
| `XinglanTemplates.ets` | 5.1KB | 模板 + **禁止输出模式**（一定会/命中注定/他爱你 等） |
| `XinglanInteractionFlows.ets` | 14.5KB | 交互 Flow 数据：解闷菜单/心情选择/二选一/心事倾诉/夜信等 |
| `XinglanMiniInteractions.ets` | 2.8KB | 8 种轻互动数据 |
| `XinglanNightLetters.ets` | 16.4KB | 5 主题夜信正文（想被安慰/放下/少怪自己/睡不着/不想说） |
| `XinglanStarKeyMirror.ets` | 21.2KB | 5 主题星钥小镜子正文（照情绪/照关系/照选择/照疲惫/照今晚） |
| `XinglanEchoCards.ets` | 11.1KB | 9 种情绪回声卡（23 张卡片） |
| `XinglanLightMemory.ets` | 3.5KB | 5 种轻记得偏好 |
| `XinglanCompanionChoices.ets` | 9.7KB | 5 种相处方式（听我说/帮我理/给我光/陪我静/逗我一下） |
| `XinglanPaperNotes.ets` | 1.6KB | 30 条纸条约会文案 |
| `XinglanProactiveLines.ets` | 1.4KB | 主动问候语（早晨/通用/深夜/回来） |
| `XinglanQuestionOptions.ets` | 8.0KB | 天气问题选项树 |
| `XinglanShortCorpus.ets` | 5.9KB | 短语料库 |

### xinglan/engine/ — 引擎层（14 个文件）

| 文件 | 大小 | 用途 |
|------|------|------|
| `XinglanSessionManager.ets` | 2.8KB | **会话管理器**：createSession + addUserMessage + addXinglanMessage + updateContext |
| `XinglanSafetyGuard.ets` | 1.1KB | **安全守卫**：危机检测 → 安全回复兜底 |
| `XinglanInterruptDetector.ets` | 2.4KB | **打断检测**：SAFETY/DIRECT/NEW_TOPIC 意图识别 |
| `XinglanAnalyzer.ets` | 3.3KB | **输入分析**：文本→情绪标签+话题标签+策略 |
| `XinglanRouter.ets` | 6.1KB | **路由规划**：分析结果→回复计划（含策略选择） |
| `XinglanComposer.ets` | 5.7KB | **回复合成**：根据分析结果和上下文合成回复文本 |
| `XinglanSpecialIntentResolver.ets` | 4.3KB | 特殊意图解析：THANKS/DENIAL/SILENCE/TOO_SHORT |
| `XinglanCompanionModeEngine.ets` | 3.3KB | 陪伴模式：听我说/帮我理/给我光/陪我静/逗我一下 |
| `XinglanDirectReplyEngine.ets` | 0.5KB | DirectReply 引擎：遍历回复列表匹配输入 |
| `XinglanMiniInteractionEngine.ets` | 2.5KB | MiniInteraction 引擎：关键词→回复段 |
| `XinglanInteractionFlowEngine.ets` | 3.7KB | 交互 Flow 引擎：resolveFlowEntry + resolveFlowNext |
| `XinglanTopicSlotExtractor.ets` | 2.7KB | 话题槽位提取 |
| `XinglanReplyRelevanceGuard.ets` | 3.4KB | 回复相关性守卫 |
| `XinglanDebugTester.ets` | 4.5KB | 调试测试器 |
| `XinglanHighFrequencyReplyTester.ets` | 4.2KB | 高频回复调试工具 |

---

## 六、model/ — 数据模型（6 个文件）

| 文件 | 大小 | 用途 |
|------|------|------|
| `TarotCard.ets` | 2.3KB | 塔罗牌模型：TarotCard 接口、ArcanaType 枚举、TarotSuit 枚举、EmotionTag 枚举 |
| `DivinationHistoryRecord.ets` | 1.5KB | **历史记录模型**：SpreadType 枚举（SINGLE/TRIANGLE/RELATION/CARD_WHEEL）、EntryMode 枚举、DrawnCardRecord 接口 |
| `Spread.ets` | 1.4KB | 牌阵模型 |
| `DivinationRecord.ets` | 0.4KB | 旧版占卜记录 |
| `MvpDivinationRecord.ets` | 1.0KB | MVP 版占卜记录 |
| `DailyFortune.ets` | 0.2KB | 每日一占模型 |

---

## 七、service/ — 服务层（7 个文件）

| 文件 | 大小 | 用途 |
|------|------|------|
| `TarotDataService.ets` | 3.1KB | 塔罗数据初始化服务 |
| `DailyFortuneService.ets` | 5.2KB | 每日一占服务 |
| `DivinationService.ets` | 2.2KB | 占卜计算服务 |
| `DivinationHistoryService.ets` | 2.3KB | 历史记录服务 |
| `ShareImageService.ets` | 11.6KB | **分享图保存服务**：PixelMap → PNG → 相册 |
| `ShareService.ets` | 2.2KB | 分享服务 |
| `UserStateService.ets` | 1.5KB | 用户状态服务 |

---

## 八、entryability/ + formextensionability/ + widget/ + utils/

| 文件 | 大小 | 用途 |
|------|------|------|
| `entryability/EntryAbility.ets` | 9.7KB | **应用入口**：onCreate→onWindowStageCreate→onForeground(BGM resume)→onBackground(BGM pause) |
| `formextensionability/DailyFortuneFormAbility.ets` | 4.2KB | 每日一占桌面卡片 FormExtension |
| `widget/DailyFortuneWidget.ets` | 2.2KB | 桌面万能卡片 UI（2×2） |
| `utils/DateUtil.ets` | 0.8KB | 日期工具 |
| `utils/ImageUtil.ets` | 1.4KB | 图片工具 |
| `utils/RandomUtil.ets` | 2.0KB | 随机工具 |

---

## 九、资源文件

| 路径 | 说明 |
|------|------|
| `resources/base/media/` | 78 张卡牌 PNG + 星澜头像 (app_icon3/5) + 牌背 (card_back) + 占位符 + 启动图 + 引导图 + 图标资源 |
| `resources/rawfile/bgm_calm_ambient.mp3` | 唯一背景音乐（Calm Ambient — leberch / Pixabay） |
| `resources/base/profile/main_pages.json` | 40 个页面路由注册 |
| `resources/base/element/string.json` | 字符串资源表 |

---

## 十、统计总览

| 目录 | 文件数 | 总大小 |
|------|--------|--------|
| pages/ | 40 | ~550KB |
| components/ | 17 | ~60KB |
| common/ | 11 | ~85KB |
| data/ | 12 | ~170KB |
| xinglan/ | 30 | ~230KB |
| model/ | 6 | ~8KB |
| service/ | 7 | ~28KB |
| 其他 | 6 | ~20KB |
| **总计** | **~130** | **~1.15MB** |

# Phase 8-F 主路径回归测试报告

## 1. 测试概况

- **项目**：星钥塔罗 / XingKey Tarot
- **阶段**：Phase 8-F — 上架前主路径回归测试
- **测试性质**：静态路径核查 + 路由引用完整性 + 红线表达搜寻 + 编译验证
- **是否修改代码**：否（只读审计）
- **编译结果**：BUILD SUCCESSFUL，ERROR=0

## 2. 主路径检查总表

| # | 路径 | 状态 | 结论 |
|---|------|------|------|
| 1 | 首次启动 / 隐私同意 / 主框架 | ✅ | Splash→Launch→MainFrame 链路完整，隐私门禁+协议入口可达 |
| 2 | 底部 5 Tab | ✅ | 5 Tab 路由正确，Tab 2 确认为 XinglanQuotesTabContent（非旧 HomePage） |
| 3 | 单牌快占 | ✅ | AskHeart→CardDraw→ResultGolden 链路完整，timer 清理+陪伴文案均确认 |
| 4 | 圣三角 | ✅ | TriangleIntro→Draw→Result 链路完整，timer 清理+陪伴文案均确认 |
| 5 | 关系探索 | ✅ | RelationIntro→Draw→Result 链路完整，timer 清理+陪伴文案均确认 |
| 6 | 旋转牌轮 | ✅ | CardWheelMode→Draw 链路完整，抽一/抽三跳转正确 |
| 7 | 分享卡 / 历史记录 | ✅ | 3 个结果页分享入口可达，History→Detail 链路完整 |
| 8 | 星澜聊天 | ✅ | 入口页→聊天页→返回链路完整，昵称问候+安全管线引用正常 |
| 9 | 我的 / 星历 / 情绪星 / BGM | ✅ | 头像/昵称/BGM/星历/情绪星/说明类入口均可达 |

## 3. 分路径检查详情

### 路径 1：首次启动 / 隐私同意 / 进入主框架 ✅
- **入口**：`EntryAbility` → `SplashPage` → `Routes.LAUNCH` → `LaunchPage` → `Routes.MAIN_FRAME`
- **涉及文件**：`EntryAbility.ets:76`（设置 splashTargetPage）、`SplashPage.ets:39-41`（读取并重置路由）、`LaunchPage.ets:63-71`（replaceUrl 到 MAIN_FRAME）、`LegalDocuments.ets`（协议全文）
- **检查点**：
  - 隐私同意前可查看 `PrivacyPolicyPage` 和 `UserAgreementPage`（LaunchPage:116,127）
  - 同意后 replaceUrl 到 MainFramePage
  - 法律文档不含"神准/灵验/预测命运"等红线表达
- **结论**：✅ 链路完整，合规文案已确认

### 路径 2：底部 5 个 Tab ✅
- **涉及文件**：`MainFramePage.ets`、`CompanionBottomNav.ets`
- **Tab 映射**：
  - Tab 0：塔罗/占卜 → `DivinationCenterTabContent`（MainFramePage 内联）
  - Tab 1：星澜聊天 → `XinglanChatTabContent` → pushUrl `Routes.XINGLAN_CHAT`
  - Tab 2：星澜语录 → `XinglanQuotesTabContent`（已迁移 V2B_）
  - Tab 3：卡牌总览 → `TarotCardsTabContent`（已改为 3 列牌面网格）
  - Tab 4：我的 → `SettingsTabContent`
- **结论**：✅ 5 Tab 正确，Tab 2 确认为 XinglanQuotesTabContent（非旧 HomePage.ets）

### 路径 3：单牌快占 ✅
- **入口**：占卜中心 → `AskHeartPage` → `CardDrawPage` → `ResultGoldenPage`
- **确认项**：
  - `CardDrawPage.ets` Phase 7-A P0 timer 清理确认存在（`isPageAlive` + `timerIds[]` × 5 + `aboutToDisappear`）
  - `ResultGoldenPage.ets` Phase 8-C-1 `buildCompanionSection()` 存在
  - 追问星澜（`Routes.FOLLOW_UP`）+ 生成分享卡（`Routes.SHARE_CARD`）入口完好
- **结论**：✅

### 路径 4：圣三角 ✅
- **入口**：占卜中心 → `TriangleIntroPage` → `TriangleDrawPage` → `TriangleResultPage`
- **确认项**：
  - `TriangleDrawPage.ets` Phase 7-A P0 timer 清理确认存在（`isPageAlive` + `timerIds[]` + `aboutToDisappear`）
  - `TriangleResultPage.ets` Phase 8-C-2 `buildCompanionSection()` 存在
  - 三张牌含义（过去/现在/未来）未修改
- **结论**：✅

### 路径 5：关系探索 ✅
- **入口**：占卜中心 → `RelationIntroPage` → `RelationDrawPage` → `RelationResultPage`
- **确认项**：
  - `RelationDrawPage.ets` Phase 7-A P0 timer 清理确认存在
  - `RelationResultPage.ets` Phase 8-C-3 `buildCompanionSection()` 存在
  - 边界提醒未修改，无"他爱你/复合/正缘"等越界表达
- **结论**：✅

### 路径 6：旋转牌轮 ✅
- **入口 A**：占卜中心 → `CardWheelModePage`（抽一张）→ `CardWheelDrawPage` → `ResultGoldenPage`
- **入口 B**：占卜中心 → `CardWheelModePage`（抽三张）→ `CardWheelDrawPage` → `TriangleResultPage`（`Routes.TRIANGLE_RESULT` at line 701）
- **确认项**：
  - 抽一张 / 抽三张路由正确
  - Phase 8-B 文案已补齐
  - Phase 8-D 按钮确认反馈已接入 `confirmPressed`
  - `aboutToDisappear` timer 清理保留（`stopInertia()` 调用）
- **结论**：✅

### 路径 7：分享卡 / 历史记录 ✅
- **分享卡入口**：
  - `ResultGoldenPage` → `Routes.SHARE_CARD`（追问/分享按钮均完好）
  - `TriangleResultPage` → `Routes.SHARE_CARD`（line 401）
  - `RelationResultPage` → `Routes.SHARE_CARD`（line 414）
- **历史记录入口**：
  - `HistoryPage` → `Routes.HISTORY_DETAIL`（line 468）
- **结论**：✅ 全部入口可达

### 路径 8：星澜聊天 ✅
- **入口**：Tab 1 → `XinglanChatEntranceContent` → 按钮 → `Routes.XINGLAN_CHAT`
- **确认项**：
  - 昵称问候逻辑完好（`XinglanNicknameGreetings.ets` selectEntryGreeting）
  - `last_entry_greeting_id` 防重复保留
  - 右上角头像定位已修复（Row 容器布局）
  - SafetyGuard/DirectReply/Flow 管线引用完整
- **结论**：✅

### 路径 9：我的 / 星历 / 情绪星 / BGM ✅
- **确认项**：
  - 头像裁剪入口：`AvatarCropPage` → `Routes.MAIN_FRAME`
  - 昵称编辑：`UserProfileStore` clearNickname/getDisplayNickname 存在
  - BGM 开关：`GlobalBgmManager` 单例，`bgm_enabled` key 未变
  - 星历：`StarCalendarPage` → `Routes.MAIN_FRAME`
  - 情绪星：`EmotionStarPage` → `Routes.MAIN_FRAME`
  - 使用说明：`Routes.USAGE_GUIDE`（MainFramePage:2022, SettingsPage:242）
  - 关于：`Routes.ABOUT`（MainFramePage:2064）
  - 协议/隐私：`Routes.USER_AGREEMENT/PRIVACY_POLICY`（LaunchPage:116,127）
  - 素材与授权：`Routes.MATERIALS_LICENSE`（AboutPage:41）
- **结论**：✅ 全部入口可达

## 4. 红线表达搜索结果

| 搜索词 | 命中情况 | 说明 |
|--------|---------|------|
| `他爱你` / `她爱你` | 仅在 `XinglanTemplates.ets:125` | **禁止输出模式列表**（用于拦截，非输出文案） |
| `复合` / `复合概率` | 仅在 `XinglanKeywords.ets:51,113,118` 等 | **关键词检测列表**（用于路由分类，非输出文案） |
| `命中注定` | 仅在 `XinglanKeywords.ets:61` + `XinglanTemplates.ets:119` | **检测/拦截词库** |
| `一定会` | `PositiveHeartOptions.ets:163` + `TarotCardDetailPage.ets:170` | **否定句式**（"不是在告诉你今天一定会…"）— 合规 ✅ |
| `神准/灵验/转运/财运/中奖/正缘/烂桃花` | **零命中** | 用户可见文案中完全不存在 |
| `保证` | 仅在 `LegalDocuments.ets:209,249` | "保证同一天显示同一张"（技术性描述，非承诺保证） |

**结论**：用户可见文案无红线表达。所有命中均在检测/拦截词库或否定句式中。

## 5. BGM 回归检查

| 检查项 | 状态 |
|--------|------|
| `GlobalBgmManager.ets` 是否修改 | ✅ 未修改 |
| `bgm_enabled` key | ✅ 保持 `'bgm_enabled'` |
| Toggle 持久化逻辑 | ✅ 未修改（`setMusicEnabled` → `PreferenceStore.putBoolean`） |
| 授权页音乐数量 | ✅ `MaterialsLicensePage` 仅列 1 首 `bgm_calm_ambient.mp3` |

## 6. P0 Timer 回归检查

| 文件 | `isPageAlive` | `timerIds[]` | `aboutToDisappear` | 回调守卫 |
|------|-------------|-------------|--------------------|---------|
| `CardDrawPage.ets` | ✅ L67 | ✅ L68 | ✅ L103-108 | ✅ 5 处 |
| `TriangleDrawPage.ets` | ✅ L67 | ✅ L68 | ✅ L148-152 | ✅ 4 处 |
| `RelationDrawPage.ets` | ✅ L65 | ✅ L66 | ✅ L140-145 | ✅ 4 处 |
| `CardWheelDrawPage.ets` | ✅（原有 `stopInertia`）| — | ✅ L196-198 | ✅ |

## 7. 需真机 / 模拟器验证项

| # | 项目 | 说明 |
|---|------|------|
| 1 | 相册选择头像 | 系统选择器回调 + 裁剪 + 保存链路 |
| 2 | 分享卡保存到相册 | PixelMap + 写入权限 |
| 3 | BGM 前后台恢复 | EntryAbility onForeground/Background |
| 4 | 多指缩放裁剪 | AvatarCropPage Canvas 手势 |
| 5 | 长滑牌轮手感 | CardWheelDrawPage 惯性+吸附 |
| 6 | 首次安装隐私门禁 | LaunchPage 全新安装欢迎弹窗 |
| 7 | 昵称 emoji 输入 | TextInput maxLength + Array.from 校验 |

## 8. 发现的问题

**本轮未发现阻塞上架的 P0 / P1 问题。** 全部 9 条主路径路由可验证，核心功能引用完整，timer 清理确认保留，红线表达零命中，BGM 授权已同步。

## 9. 编译结果

```
node hvigorw.js assembleHap --mode module -p module=entry@default -p product=default --no-daemon
BUILD SUCCESSFUL — all UP-TO-DATE — ERROR=0
```

## 10. 下一步建议

1. **真机回归**：按第 7 节清单逐项验证（相册保存、BGM 前后台、牌轮手感）
2. **应用市场截图**：重新拍摄 5 Tab + 结果页 + 卡牌总览的最终版本截图
3. **签名部署**：配置 release 签名并完成签名验证

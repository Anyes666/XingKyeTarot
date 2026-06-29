# 星钥塔罗 (XingKey Tarot) 项目长期记忆

## 项目概要

- **项目名**：星钥塔罗 / XingKey Tarot
- **平台**：HarmonyOS / ArkTS / DevEco Studio
- **包名**：com.xingkey.tarot
- **定位**：塔罗式情绪陪伴 + 自我探索，不是传统算命
- **核心角色**：星澜 — 温柔、克制、安静、有边界感的陪伴型虚拟角色
- **编译基线**：OpenHarmony API 12，compatibleSdkVersion 5.0.0(12)

## 星澜原则

- 不预言未来
- 不诊断心理/医疗问题
- 不替用户做决定
- 不做法律/投资/医疗建议
- 不恋爱承诺
- 不成人化陪聊
- 不制造依赖
- 不使用绝对化话术（"命中注定""一定会""治愈你""我永远陪你""我只属于你"等）
- 推荐表达："听起来……""也许……""如果你愿意……""这不是答案，只是一面小镜子……"

## 工程铁律（所有 Agent 必须遵守）

1. **hvigor assembleHap 编译验证由用户自行执行**，Agent 不负责运行编译命令
2. 禁止猜 HarmonyOS API
3. 禁止大规模重构
4. 禁止 `any` / `as any`
5. 禁止匿名对象类型
6. 禁止 `Record<string, Object>`
7. ArkTS 严格类型：必须显式 interface / enum / class
8. 中文文件必须保持 UTF-8
9. 禁止用 PowerShell `Add-Content` 写中文
10. 禁止伪造保存成功
11. 禁止乱改 HomePage / BottomNav / Routes / SettingsPage / 抽牌页 / 结果页 / 历史页 / xinglan/engine / xinglan/data，除非任务明确允许
12. 不要用 `position` 硬贴元素到角落，优先自然布局
13. Stack 中渐变遮罩必须显式 position，否则默认居中

## 已存在功能

1. HomePage（首页）
2. 今日星钥
3. 单牌快占
4. 圣三角牌阵
5. 关系探索
6. 历史记录
7. 分享卡
8. 情绪星点 / 7日情绪星图
9. SettingsPage（设置页）
10. 星澜首页语录 / 对话气泡
11. 毛玻璃底部导航 CompanionBottomNav
12. 星澜聊天系统（详见下文）

## 底部导航结论

- 当前 SDK 不支持 `ImmersiveMaterial` / `systemMaterial`
- 已保留半透明毛玻璃胶囊 + 纯按压反馈方案
- 未来 API26+ 可单独实验分支测试，不要直接升级主线

## 星澜聊天系统架构

### 已完成阶段
- **Phase 1**：类型层 `xinglan/types/XinglanTypes.ets`（EmotionTag, TopicTag, BoundaryTag, ReplyStrategy 等）
- **Phase 2**：数据层 `xinglan/data/XinglanCorpus.ets`, `XinglanKeywords.ets`, `XinglanTemplates.ets`
- **Phase 3**：输入理解与路由 `XinglanSpecialIntentResolver`, `XinglanAnalyzer`, `XinglanRouter`, `XinglanTopicSlotExtractor`
- **Phase 4**：Composer / Safety / Session `XinglanComposer`, `XinglanSafetyGuard`, `XinglanSessionManager`
- **Phase 5**：拟真陪伴交互（小纸条、8个轻互动、解闷模式、主动问候）
- **Phase 5.1**：聊天页接入 `XinglanChatPage.ets`
- **Phase 5.2**：安全优先级（CRISIS > ADULT > PROFESSIONAL > PREDICTION > ROLE）
- **Phase 5.5**：动态交互链路 6 条 Flow
- **Phase 5.6**：顶部 header、滚动淡化、星澜头像 badge
- **Phase 5.6.1**：右上角星澜 Badge 返工专项（已完成，方案 A：圆形头像按钮，最终 36vp，Header 56vp）

### 发送管线顺序
输入 → DirectReply → InterruptDetector（Flow 中）→ Flow Entry → MiniInteraction → CompanionMode → SpecialIntent → Normal Pipeline

### DirectReply 高频命中规则
- 表白/喜欢 → `ROLE_CONFESSION`
- 想念 → `ROLE_MISSING`
- 昵称（老婆/宝宝等）→ `ROLE_NICKNAME`
- 累 → `SHORT_TIRED`（不能命中 WORK_RESIGN）
- 想谈恋爱 → `RELATION_LOVE_DESIRE`

## 关键文件路径

- 聊天页：`entry/src/main/ets/pages/XinglanChatPage.ets`
- 类型定义：`entry/src/main/ets/xinglan/types/XinglanTypes.ets`
- 引擎目录：`entry/src/main/ets/xinglan/engine/`
- 数据目录：`entry/src/main/ets/xinglan/data/`
- 主题常量：`entry/src/main/ets/common/Theme.ets`
- 路由定义：`entry/src/main/ets/common/Routes.ets`
- 返回按钮：`entry/src/main/ets/components/AppBackButton.ets`
- 底部导航：`entry/src/main/ets/components/CompanionBottomNav.ets`
- 资源目录：`entry/src/main/resources/base/media/`
- 设计文档：`docs/`、`deliverables/`

## 已做过的 UI 修复

- 三个抽牌页增加返回按钮
- 顶部安全区修复（TriangleIntroPage、SettingsPage、HomePage）
- 点击热区专项（AppBackButton 48×48、设置齿轮、结果页按钮等）
- 渐变遮罩位置 bug 修复
- Phase 5.6.1 星澜 Badge 返工（最终 36vp 圆形头像，距右 24vp，Header 56vp，SAFE_TOP 下方）
- **UI 优化专项**：右上角星澜头像 → 星钥图标按钮；消息月亮 emoji → 每条星澜消息上方显示头像

## 星澜聊天页当前 UI 状态（UI 优化专项之后）

- Header Row 高度 56vp
- 左侧：AppBackButton（距左 24vp）
- **右上角**：星钥图标按钮（`onboarding_daily_star_key.png`，24×24vp，fillColor GOLD_AMBER）
  - 不再显示星澜头像 badge
- **星澜消息**：每条消息上方显示圆形星澜头像 28×28vp（`app_icon5.png`），圆角 14vp，金色描边
  - 原来 `🌙` 月亮 emoji 已移除
- **typing 状态**：同样显示星澜头像，不再使用月亮 emoji
- 用户消息保持原有右侧布局不变
- Header padding：top SAFE_TOP, left 24, right 24

## Phase 5.7-5.12 设计计划（2026-06-29）

已完成 6 阶段详细设计计划，文档位于 `deliverables/Xinglan_Roadmap_Phase_5.7_to_5.12_Design_Plan.md`。

### 6 个阶段
| Phase | 名称 | 工时 | 新建文件 |
|-------|------|------|---------|
| 5.7 | 今日相处方式 | 3-4h | `XinglanCompanionChoices.ets` + `XinglanCompanionChoiceEngine.ets` |
| 5.8 | 星澜夜信卡片 | 5-6h | `XinglanNightLetters.ets` |
| 5.9 | 星钥小镜子 | 5-6h | `XinglanStarKeyMirror.ets` |
| 5.10 | 主题深度 Flow | 8-10h | 无新文件（扩展 `XinglanInteractionFlows.ets`） |
| 5.11 | 情绪回声卡 | 5-6h | `XinglanEmotionEchoEngine.ets` |
| 5.12 | 星澜轻记得 | 5-6h | `XinglanPreferenceStore.ets` |

### MVP 版本
优先做 5.7 + 5.8 + 5.9，共 13-16 小时。

### 核心设计原则
- 所有改动均利用现有引擎架构扩展，避免大规模重写
- 每个阶段完成后 `hvigor assembleHap` 保证 `ERROR=0`
- 不修改 SafetyGuard 优先级（危机永远最高）
- 不存储恋爱关系/好感度/亲密度
- 新增枚举名不叫 LOVE_MODE/INTIMACY_MODE/RELATION_LEVEL（这是陪伴方式，不是乙游好感度）

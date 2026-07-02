# 星钥塔罗 — XingKey Tarot

> HarmonyOS NEXT 塔罗式情绪陪伴与自我探索 App · 本地离线 · 轻量 · 合规 · 可长期维护

---

## 1. 项目定位

星钥塔罗是一款 **HarmonyOS NEXT 本地离线塔罗应用**，核心角色为 **星澜**——月光下的倾听者。

**产品边界**：不接入大模型、不预言未来、不做绝对判断、不替用户做决定、不制造依赖、不成人化陪聊、不诊断心理/医疗问题、不提供专业结论。

**方向**：情绪陪伴、自我探索、轻量、合规、可长期维护。

---

## 2. 当前核心功能（v2.1.0）

### 底部导航 5 个一级入口

| Tab | 名称 | 图标 | 功能 |
|-----|------|------|------|
| 0 | 塔罗 | ⬡ | 占卜中心：单牌快占 / 圣三角牌阵 / 关系探索 / 旋转牌轮 / 历史查看 |
| 1 | 星澜聊天 | ☾ | 星澜离线陪伴聊天（DirectReply、MiniInteraction、Flow、夜信、星钥小镜子、情绪回声卡、星澜轻记得、今日相处方式） |
| 2 | 星澜语录 | ✦ | XinglanQuotesTabContent 滚动对话流 + 星澜背景 |
| 3 | 卡牌总览 | ▤ | 78 张塔罗牌 3 列真实牌面网格 + 6 维度解读详情页 |
| 4 | 我的 | ◎ | 头像/昵称/BGM 开关/星澜星历/使用说明/关于星钥塔罗 |

### 占卜模块

| 模式 | 牌数 | 说明 |
|------|------|------|
| 单牌快占 | 1 张 | 双模式：情绪方向 + 积极/阳光方向，结果页含星澜陪伴文案 |
| 圣三角牌阵 | 3 张 | 过去·现在·可能的方向，结果页含星澜陪伴文案 |
| 关系探索 | 3 张 | 我·对方·走向，含完整边界提醒 + 关系陪伴文案 |
| 旋转牌轮 | 1 或 3 张 | 环形循环牌轮，惯性 + 吸附，星澜式文案 |

### 星澜聊天系统

- **DirectReply**：22 种高频命中类型（危机、成人、专业、预测、角色边界，及情绪/关系/工作等），约 120 条变体回复
- **MiniInteraction**：8 种轻互动
- **交互 Flow**：多条动态交互链路
- **Phase 5.7–5.12 功能**：今日相处方式（5 种模式）、星澜夜信（5 主题）、星钥小镜子（5 主题）、情绪回声卡、星澜轻记得
- **安全优先级**：CRISIS > ADULT > PROFESSIONAL > PREDICTION > ROLE

### 其他模块

- **卡牌总览**：78 张牌 3 列真实牌面网格，分类筛选，详情页含 6 维度解读
- **历史记录**：5 种筛选（全部/单牌/圣三角/关系/牌轮），空状态引导，清空确认弹窗
- **分享卡**：占卜结果生成分享卡，保存到系统相册
- **星澜星历 + 情绪星**：每日点亮情绪星 + 累计天数 + 星钥等级（8 段阈值）
- **全局背景音乐**：Calm Ambient（leberch / Pixabay），单例 GlobalBgmManager，支持开关 + 持久化
- **自定义昵称**：本地保存，星澜入口页个性化问候（20 条文案池）

---

## 3. 设计系统（v2）

采用**场景分层混合策略**：

| 场景层 | 方案 | 核心隐喻 | 金色 Token |
|--------|------|---------|-----------|
| 聊天陪伴层 | B「月湖映心」 | 深夜湖边月光 | `V2B_GOLD_CORE` (#D4AC4D) |
| 卡牌内容层 | C「星钥之书」 | 古籍图书馆烫金 | `V2C_GOLD_GILT` (#C5A050) |
| 时间记录层 | A「星图档案」 | 天文台观测日志 | `V2A_GOLD_ACCENT` (#C9A44B) |

- **按钮反馈**：轻量 scale 0.97 + EaseOut 120ms（`PressableScaleButton`）
- **底部导航**：Unicode 图标（⬡☾✦▤◎），24vp 固定容器 + 垂直微调
- **已迁移页面**：25+ 页（含主路径全部页面）

---

## 4. 技术栈约定

### 使用
| 技术 | 说明 |
|------|------|
| ArkTS | 严格模式 |
| ArkUI | 声明式 UI |
| Stage 模型 | 应用模型 |
| `@kit.*` | 命名空间导入 |
| hvigorw | 构建工具 |
| Preferences | 本地存储（bgm_enabled / user_nickname 等持久化偏好） |
| FormExtensionAbility | 桌面卡片 |
| AVPlayer | 背景音乐播放 |

### 兼容范围
- `compatibleSdkVersion: "5.0.0(12)"` — **鸿蒙 5.0 ~ 6.1 通吃**
- 4.x 及以下不支持

---

## 5. 数据策略

### 塔罗数据 — 编译期内嵌

| 数据 | 数量 |
|------|------|
| 大阿卡纳 | 22 张 |
| 小阿卡纳（权杖/圣杯/宝剑/星币） | 56 张 |
| **总计** | **78 张** |
| 正逆位解读 | 156 条 |
| 存储方式 | ArkTS 常量（`TarotCardData.ets` + `InterpretationData.ets`） |

App **完全离线可用**，无需网络。

### 本地存储（不上传）

| 数据 | Key |
|------|-----|
| 隐私政策同意状态 | `privacy_accepted_v2` |
| 背景音乐开关 | `bgm_enabled`（默认 true） |
| 用户昵称 | `user_nickname`（默认"未命名旅者"） |
| 头像 URI | `user_avatar_uri` |
| 占卜历史记录 | `divination_history_v2`（FIFO 50 条） |
| 新手引导完成状态 | `hasSeenHomeGuide` 等 7 个标志位 |

---

## 6. 合规设计

### 三层覆盖

| 层级 | 位置 | 内容 |
|------|------|------|
| 🥇 首次启动 | LaunchPage 隐私门禁弹窗 | 用户协议 + 隐私政策确认 |
| 🥈 结果页 | 页脚 | `结果仅供娱乐与自我探索参考，不构成任何专业建议。` |
| 🥉 分享图 | 底部 | 同上 |

### 合规文档

- 用户协议 + 隐私政策：编译期内嵌 `LegalDocuments.ets`（约 7500 字）
- 素材与授权：`MaterialsLicensePage`（仅列 1 首 bgm_calm_ambient.mp3）
- 背景音乐：Calm Ambient（leberch / Pixabay Content License）
- 产品边界：不预测/不承诺/不诊断/不提供专业建议
- 无红线表达（神准/灵验/复合/正缘/烂桃花/命中注定 等均在检测词库中用于拦截，不出现在用户可见文案）

### 开发者信息

- **开发者**：杨鹏宇
- **邮箱**：3364153745@qq.com

---

## 7. 架构概览

### 关键组件

- `CompanionBottomNav` — 5 键毛玻璃悬浮胶囊底部导航（⬡☾✦▤◎）
- `PressableScaleButton` — 轻量按压反馈按钮组件
- `GlobalBgmManager` — 全局背景音乐单例（唯一 AVPlayer）
- `TarotCardImage` — 统一卡牌图片组件（78 张映射 + fallback）
- `AppBackButton` — 统一返回按钮
- `HistoryStore` — 历史记录存储服务（FIFO 50 条）
- `UserProfileStore` — 头像/昵称/等级本地存储

### 星澜聊天引擎

```
xinglan/engine/
├── XinglanDirectReplyEngine.ets    — 22 种 DirectReply 类型
├── XinglanMiniInteractionEngine.ets — 8 种轻互动
├── XinglanInteractionFlowEngine.ets — 动态交互 Flow
├── XinglanInterruptDetector.ets    — 打断检测
├── XinglanSafetyGuard.ets          — 安全守卫（CRISIS > ADULT > PROFESSIONAL > PREDICTION > ROLE）
├── XinglanComposer.ets / Router.ets / Analyzer.ets / SessionManager.ets
├── XinglanNightLetters.ets / StarKeyMirror.ets / EchoCards.ets / LightMemory.ets
└── XinglanCompanionModeEngine.ets / SpecialIntentResolver.ets / TopicSlotExtractor.ets
```

---

## 8. 构建状态

| 指标 | 状态 |
|------|------|
| `hvigorw assembleHap` | ✅ **BUILD SUCCESSFUL** |
| ArkTS ERROR | **0** |
| 业务 WARN | **0** |
| 剩余 WARN | 仅 DevEco 工具链 `sun.misc.Unsafe` + 既有 deprecated API 提示（非阻塞） |
| 签名 | ⏸️ 后续单独配置 |

---

## 9. 版本路线

| 版本 | 内容 | 状态 |
|------|------|------|
| **v1.0–v1.4** | 基础塔罗功能（单牌、圣三角、分享、历史） | ✅ |
| **v2.0.0** | 底部导航重构 + 星澜聊天 MVP + 卡牌总览 + 旋转牌轮 + 设置/关于/授权 + 全局 BGM | ✅ |
| **v2.1.0** | v2 设计系统迁移（25+ 页）+ 星澜陪伴文案 + 按钮反馈 + 卡牌总览牌面化 + 昵称系统 + 合规收口 | ✅ **当前版本** |
| v2.2 | 真机回归测试 + 签名部署 | 🔜 下一步 |
| v3.0 | 账号、云同步、AI 解读或商业化 | 📋 规划中 |

---

## 10. Phase 7–8 修复与增强记录

| Phase | 日期 | 内容 |
|-------|------|------|
| 7-A | 2026-07-01 | P0 定时器泄漏修复（CardDraw/TriangleDraw/RelationDraw 的 setTimeout 生命周期管理） |
| 7-B-1 | 2026-07-01 | 聊天页右上角头像定位修复（硬编码 position+translate → Row 容器布局） |
| 8-A | 2026-07-01 | 卡牌总览牌面化（文字列表 → 3 列真实牌面网格） |
| 8-B | 2026-07-01 | 旋转牌轮文案补齐（星澜式陪伴文案） |
| 8-C | 2026-07-01 | 结果页文案丰富（ResultGolden/Triangle/Relation 三个结果页 + XinglanResultCompanionText.ets） |
| 8-D | 2026-07-01 | 按钮点击反馈（PressableScaleButton + 5 个主按钮接入） |
| 8-E | 2026-07-01 | 上架前合规收口（BGM 授权同步、红线表达清理、隐私/离线说明统一） |
| 8-F | 2026-07-01 | 主路径回归测试（9 条路径静态审计，零 P0/P1 问题） |
| 8-G-1 | 2026-07-01 | 底部导航图标升级（Unicode 字符 ⬡☾✦▤◎） + 垂直对齐修正 |

---

## 11. 已知待办

| 优先级 | 事项 | 说明 |
|--------|------|------|
| P1 | 真机回归测试 | BGM 前后台恢复、分享卡相册保存、牌轮手感、emoji 昵称等 |
| P1 | 签名部署 | 配置 release 签名 |
| P2 | 旧路线页面清理 | HomePage.ets 等遗留不可达页面 |
| P2 | 图片映射代码去重 | `getCardImageResource` 在 3 个文件中重复定义 |
| P2 | 抽牌模式扩展到 78 张 | 非牌轮模式目前使用 MVP 8 张牌池 |

---

> **开发者**：杨鹏宇 · **邮箱**：3364153745@qq.com  
> **Bundle ID**：com.xingkey.tarot · **SDK**：5.0.0(12)~6.1.1(24)  
> **当前版本**：v2.1.0 · **最近构建**：2026-07-01 · BUILD SUCCESSFUL · ERROR=0

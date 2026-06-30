# 星钥塔罗 — XingKey Tarot

> HarmonyOS NEXT 塔罗式情绪陪伴与自我探索 App · 本地离线 · 轻量 · 合规 · 可长期维护

---

## 1. 项目定位

星钥塔罗是一款 **HarmonyOS NEXT 本地离线塔罗应用**，核心角色为 **星澜**——月光下的倾听者。

**产品边界**：不接入大模型、不预言未来、不做绝对判断、不替用户做决定、不制造依赖、不成人化陪聊、不诊断心理/医疗问题、不提供专业结论。

**方向**：情绪陪伴、自我探索、轻量、合规、可长期维护。

---

## 2. 当前核心功能（v2.0.0）

### 底部导航 5 个一级入口

| Tab | 名称 | 功能 |
|-----|------|------|
| 0 | 占卜 | 占卜中心：单牌快占 / 圣三角牌阵 / 关系探索 / 旋转牌轮 / 历史查看 |
| 1 | 星澜聊天 | 星澜离线陪伴聊天（DirectReply、MiniInteraction、Flow、夜信、星钥小镜子、情绪回声卡、星澜轻记得、今日相处方式） |
| 2 | 星澜语录 | 1018 条星澜陪伴文案滚动对话流 + 今日一占入口 |
| 3 | 卡牌总览 | 78 张塔罗牌完整展示与筛选（大阿尔卡那 / 权杖 / 圣杯 / 宝剑 / 星币）+ 详情页含 6 维度解读 |
| 4 | 设置 | 背景音乐开关 / 重新听听星澜的介绍 / 关于星钥塔罗（版本信息、隐私政策、用户协议、素材与授权） |

### 占卜模块

| 模式 | 牌数 | 说明 |
|------|------|------|
| 单牌快占 | 1 张 | 双模式：情绪方向 + 积极/阳光方向 |
| 圣三角牌阵 | 3 张 | 过去·现在·可能的方向 |
| 关系探索 | 3 张 | 我·对方·走向，含完整边界提醒 |
| 旋转牌轮 | 1 或 3 张 | 环形循环牌轮，惯性 + 吸附，确认前不显示牌名 |

### 星澜聊天系统

- **DirectReply**：22 种高频命中类型（危机、成人、专业、预测、角色边界，及情绪/关系/工作等），约 120 条变体回复
- **MiniInteraction**：8 种轻互动（星澜问我一个问题、陪我解闷、给我一句小纸条等）
- **交互 Flow**：多条动态交互链路（解闷菜单、心情选择、二选一、心事倾诉等）
- **Phase 5.7–5.12 功能**：今日相处方式（5 种模式）、星澜夜信（5 主题）、星钥小镜子（5 主题）、情绪回声卡、星澜轻记得
- **安全优先级**：CRISIS > ADULT > PROFESSIONAL > PREDICTION > ROLE
- **30 条纸条约会**（小纸条轻文案池）

### 其他模块

- **历史记录**：5 种筛选（全部/单牌/圣三角/关系/牌轮），空状态引导，清空确认弹窗
- **卡牌总览**：78 张牌按分类筛选，详情页含正位含义、逆位含义、情绪陪伴式解读、关系提示、工作/学习提示、自我探索
- **分享图**：占卜结果生成分享卡，保存到系统相册
- **桌面卡片**：2×2 FormExtension 万能卡片
- **全局背景音乐**：Calm Ambient（leberch / Pixabay），单例 GlobalBgmManager，支持开关 + 持久化

---

## 3. 技术栈约定

### 使用
| 技术 | 说明 |
|------|------|
| ArkTS | 严格模式 |
| ArkUI | 声明式 UI |
| Stage 模型 | 应用模型 |
| `@kit.*` | 命名空间导入 |
| hvigorw | 构建工具 |
| Preferences | 本地存储（bgm_enabled 等持久化偏好） |
| FormExtensionAbility | 桌面卡片 |
| AVPlayer | 背景音乐播放 |

### 避免
| 模式 | 替代方案 |
|------|----------|
| `@ohos.*` 旧导入 | `@kit.*` 命名空间 |
| 全局 `router.replaceUrl/pushUrl/back` | Navigation 组件 |
| 全局 `getContext()` | `this.getUIContext().getHostContext()` |
| 全局 `componentSnapshot.get()` | `this.getUIContext().getComponentSnapshot().get()` |
| `ImagePacker.packing()` | `ImagePacker.packToData()` |
| `KEEP_BACKGROUND_RUNNING` | 不申请 |

### 兼容范围
- `compatibleSdkVersion: "5.0.0(12)"` — **鸿蒙 5.0 ~ 6.1 通吃**
- 4.x 及以下不支持

---

## 4. 数据策略

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
| 新手引导完成状态 | `hasSeenHomeGuide` 等 7 个标志位 |
| 本地用户 ID | `device_user_id` |
| 占卜历史记录 | `divination_history_v2`（FIFO 50 条） |
| 每日一占缓存 | `daily_fortune_` |
| 桌面卡片 formId | 由 Form 框架管理 |

---

## 5. 合规设计

### 三层覆盖

| 层级 | 位置 | 内容 |
|------|------|------|
| 🥇 首次启动 | LaunchPage 隐私门禁弹窗 | 用户协议 + 隐私政策确认 |
| 🥈 结果页 | 页脚 | `结果仅供娱乐与自我探索参考，不构成任何专业建议。` |
| 🥉 分享图 | 底部 | 同上 |

### 合规文档

- 用户协议 + 隐私政策：编译期内嵌 `LegalDocuments.ets`（约 7500 字）
- 素材与授权：`MaterialsLicensePage`（9 部分完整归属说明）
- 背景音乐：Calm Ambient（leberch / Pixabay Content License）

### 开发者信息

- **开发者**：杨鹏宇
- **邮箱**：3364153745@qq.com

---

## 6. 权限说明

当前仅申请 **一个权限**：

| 权限 | 用途 |
|------|------|
| `ohos.permission.WRITE_IMAGEVIDEO` | 用户主动点击"保存分享图片"时，将占卜结果图片保存到系统相册 |

### 不做
- ❌ 不读取相册
- ❌ 不上传图片
- ❌ 不分析相册
- ❌ 不申请网络权限
- ❌ 不申请后台常驻权限
- ❌ 不需要 `KEEP_BACKGROUND_RUNNING`

---

## 7. 架构概览

### 页面地图（26 个页面）

| 类别 | 页面 | 说明 |
|------|------|------|
| 启动 | LaunchPage | 隐私门禁 + 路由分流 |
| 主框架 | MainFramePage | 5 Tab 条件渲染容器 + CompanionBottomNav |
| 占卜 | DivinationCenterPage | 占卜中心（5 入口） |
| 占卜 | AskHeartPage → CardDrawPage → ResultGoldenPage | 单牌快占 |
| 占卜 | TriangleIntroPage → TriangleDrawPage → TriangleResultPage | 圣三角牌阵 |
| 占卜 | RelationIntroPage → RelationDrawPage → RelationResultPage | 关系探索 |
| 占卜 | CardWheelModePage → CardWheelDrawPage | 旋转牌轮 |
| 历史 | HistoryPage → HistoryDetailPage | 历史记录 |
| 聊天 | XinglanChatPage | 星澜离线聊天（2000+ 行） |
| 语录 | HomePage | 星澜语录（1018 条文案池） |
| 卡牌 | TarotCardsPage → TarotCardDetailPage | 78 张牌总览与详情 |
| 设置 | SettingsPage / AboutPage / VersionInfoPage / PrivacyPolicyPage / UserAgreementPage / MaterialsLicensePage | 设置与合规 |

### 关键组件

- `CompanionBottomNav` — 5 键毛玻璃悬浮胶囊底部导航
- `GlobalBgmManager` — 全局背景音乐单例（唯一 AVPlayer）
- `TarotCardImage` — 统一卡牌图片组件（78 张映射 + fallback）
- `AppBackButton` — 统一返回按钮
- `HistoryStore` — 历史记录存储服务（FIFO 50 条）
- `PreferenceStore` — 本地偏好存储封装

### 星澜聊天引擎

```
xinglan/engine/
├── XinglanDirectReplyEngine.ets    — 22 种 DirectReply 类型
├── XinglanMiniInteractionEngine.ets — 8 种轻互动
├── XinglanInteractionFlowEngine.ets — 动态交互 Flow
├── XinglanInterruptDetector.ets    — 打断检测
├── XinglanSafetyGuard.ets          — 安全守卫
├── XinglanComposer.ets             — 回复合成
├── XinglanRouter.ets               — 路由规划
├── XinglanAnalyzer.ets             — 输入分析
├── XinglanSessionManager.ets       — 会话管理
├── XinglanSpecialIntentResolver.ets — 特殊意图
├── XinglanCompanionModeEngine.ets  — 陪伴模式
├── XinglanNightLetters.ets         — 星澜夜信
├── XinglanStarKeyMirror.ets        — 星钥小镜子
├── XinglanEchoCards.ets            — 情绪回声卡
└── XinglanLightMemory.ets          — 星澜轻记得
```

---

## 8. 构建状态

| 指标 | 状态 |
|------|------|
| `hvigorw assembleHap` | ✅ **BUILD SUCCESSFUL** |
| ArkTS ERROR | **0** |
| 业务 WARN | **0**（已清零） |
| 剩余 WARN | 仅 DevEco 工具链 `sun.misc.Unsafe` + 既有 deprecated API 提示（非阻塞） |
| 签名 | ⏸️ `No signingConfig found`（后续单独配置） |

---

## 9. 发布工程清理（已完成）

- ✅ 移除仓库中的签名材料（.p12/.csr/.cer/.p7b）
- ✅ 补充 `.gitignore`
- ✅ 移除配置中的密码
- ✅ Release 构建开启混淆
- ✅ 移除 `KEEP_BACKGROUND_RUNNING` 权限
- ✅ 文档同步当前真实权限
- ✅ 背景音乐开关持久化 + 反复开关功能修复
- ⏸️ 签名部署——暂缓，后续单独配置

---

## 10. 近期 P0 修复记录

| 日期 | 问题 | 修复 |
|------|------|------|
| 2026-06-30 | 背景音乐开关"一次性按钮"：关闭后无法重新开启 | `setMusicEnabled(false)` 从 `AVPlayer.stop()` 改为 `pause()`，保持 prepared 状态 |
| 2026-06-30 | 背景音乐开关前后台状态丢失：切 tab/后台回来后开关自动恢复开启 | 修复 `toggleBgm()` 反馈回路：接受 `isOn` 参数 + `isLoadingBgmState` 抑制标志 + 双守卫 |

---

## 11. 版本路线

| 版本 | 内容 | 状态 |
|------|------|------|
| **v1.0–v1.4** | 基础塔罗功能（单牌、圣三角、分享、历史） | ✅ 已交付 |
| **v2.0.0** | 底部导航重构 + 星澜聊天 MVP + 卡牌总览 + 旋转牌轮 + 设置/关于/授权 + 全局 BGM | ✅ **当前版本** |
| v2.1 | 星澜聊天 Phase 5.7–5.12 全部功能 + 背景音乐开关修复 | ✅ 已完成 |
| v2.2 | 真机回归测试 + 授权页同步 + 签名部署 | 🔜 下一步 |
| v3.0 | 账号、云同步、AI 解读或商业化 | 📋 规划中 |

---

## 12. 已知待办（P0/P1）

| 优先级 | 事项 | 说明 |
|--------|------|------|
| P0 | 授权页同步 | `MaterialsLicensePage` 列出 5 首音乐但仅接入 1 首，审核风险 |
| P1 | 真机回归测试 | 旋转牌轮历史保存、BGM 开关黑盒测试、聊天系统全流程 |
| P1 | 签名部署 | 配置 release 签名 |
| P1 | 图片映射代码去重 | `getCardImageResource` 在 3 个文件中重复定义 |
| P2 | 设置页丰富化 | 当前仅 2 个入口，可扩展 |
| P2 | 动效物理动力学 | 牌轮已有惯性+吸附，其余页面待落地 |

---

> **开发者**：杨鹏宇 · **邮箱**：3364153745@qq.com  
> **Bundle ID**：com.xingkey.tarot · **SDK**：5.0.0(12)~6.1.1(24)  
> **当前版本**：v2.0.0 · **最近构建**：2026-06-30 · BUILD SUCCESSFUL · ERROR=0

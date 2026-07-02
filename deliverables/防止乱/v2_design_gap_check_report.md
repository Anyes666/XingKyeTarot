# 星钥塔罗 v2 设计系统落地差距检查报告

> **检查日期**：2026-07-01  
> **设计文档**：`deliverables/星钥塔罗_设计文档_v2.md`  
> **方法**：逐页扫描 `V2_` / `V2B_` / `V2C_` / `V2A_` token 引用 + 旧紫色 `AURORA`/`PURPLE_MIST`/`#8B7EC8` 残留  
> **范围**：`entry/src/main/ets/pages/` + `entry/src/main/ets/components/`  
> **性质**：只读审计，不修改文件

---

## 一、迁移总览

| 类别 | 数量 | 占比 |
|------|------|------|
| 页面总量（pages 目录） | 38 页 | 100% |
| 已迁移 v2 Token | 14 页 | 37% |
| 未迁移（零 v2 Token） | 15 页 | 39% |
| 部分迁移（混合 Token） | 2 页 | 5% |
| 旧版页面（非主框架页） | 7 页 | 18% |

---

## 二、已迁移页面（14 页 ✅）

| # | 页面 | 文件 | 方案 | v2 Token |
|---|------|------|------|----------|
| 1 | 星澜聊天入口页 | `XinglanChatEntrancePage.ets` | B | ✅ 完整 V2B_ |
| 2 | 星澜聊天页 | `XinglanChatPage.ets` | B | ✅ 完整 V2B_ |
| 3 | 占卜中心 | `DivinationCenterPage.ets` | C | ✅ 完整 V2C_ |
| 4 | 占卜结果页 | `ResultGoldenPage.ets` | C | ✅ V2C_ + V2_ |
| 5 | 卡牌总览 | `TarotCardsPage.ets` | C | ✅ 完整 V2C_ |
| 6 | 卡牌详情 | `TarotCardDetailPage.ets` | C | ✅ 完整 V2C_ |
| 7 | 输入心事 | `AskHeartPage.ets` | C | ✅ 完整 V2C_ |
| 8 | 抽牌页 | `CardDrawPage.ets` | C+B | ✅ V2C_ + V2_ |
| 9 | 圣三角结果 | `TriangleResultPage.ets` | C | ✅ 完整 V2C_ |
| 10 | 关系探索结果 | `RelationResultPage.ets` | C | ✅ 完整 V2C_ |
| 11 | 情绪星页面 | `EmotionStarPage.ets` | B+A | ✅ V2B_ + V2A_ + V2_ |
| 12 | 星澜星历 | `StarCalendarPage.ets` | A | ✅ V2A_ |
| 13 | 设置页 | `SettingsPage.ets` | A+B | ✅（设计文档标注） |
| 14 | 使用说明 | `UsageGuidePage.ets` | A | ✅（设计文档标注） |

---

## 三、待迁移页面（15 页 ❌ — 零 v2 Token）

| # | 页面 | 文件路径 | 目标方案 | 当前旧 Token | 旧紫色 | 主路径 | 优先级 | 风险说明 |
|---|------|---------|---------|------------|--------|--------|--------|---------|
| 1 | **星澜语录** | `pages/HomePage.ets` | B | `GOLD_LIGHT`、`MOON_MUTED`、`BG_DEEP_INDIGO`、`GOLD_MAIN`、`GOLD_DIM`、`TEXT_PRIMARY_LIGHT`、`DEEP_STARRY`、`GOLD_AMBER`、`BG_CARD_DARK`、`FONT_` 系列 | 无 | ✅ Tab 2 | **P1** | 80KB / 1400+ 行，1018 条语录渲染，工作量大；Token 引用点多 |
| 2 | **历史记录** | `pages/HistoryPage.ets` | A | `GOLD_AMBER`、`BG_DEEP_INDIGO`、`TEXT_PRIMARY_LIGHT`、`MOON_MUTED` 等 | 无 | ✅ | **P1** | 筛选 chips + 卡片列表 + 弹窗，Token 映射中等量 |
| 3 | **历史详情** | `pages/HistoryDetailPage.ets` | A | `GOLD_AMBER`、`GOLD_LIGHT`、`BG_DEEP_INDIGO` 等 | 无 | ✅ | **P1** | 卡片层级 3 层，Token 替换量中等 |
| 4 | 旋转牌轮入口 | `pages/CardWheelModePage.ets` | C | 旧 Token（预估） | 未知 | ✅ | **P2** | 入口页，UI 量小，低风险 |
| 5 | 旋转牌轮抽牌 | `pages/CardWheelDrawPage.ets` | C | 旧 Token（预估） | 未知 | ✅ | **P2** | 动画+牌轮旋转逻辑复杂，迁移时注意不破坏动效 |
| 6 | 圣三角入口 | `pages/TriangleIntroPage.ets` | C | 旧 Token（预估） | 未知 | ✅ | **P2** | 低风险入口页 |
| 7 | 圣三角抽牌 | `pages/TriangleDrawPage.ets` | C | 旧 Token（预估） | 未知 | ✅ | **P2** | 3 张卡片布局，Token 替换即可 |
| 8 | 关系探索入口 | `pages/RelationIntroPage.ets` | C | 旧 Token（预估） | 未知 | ✅ | **P2** | 低风险入口页 |
| 9 | 关系探索抽牌 | `pages/RelationDrawPage.ets` | C | 旧 Token（预估） | 未知 | ✅ | **P2** | 抽牌 + UI，Token 替换即可 |
| 10 | 分享卡 | `pages/ShareCardPage.ets` | C | 旧 Token（预估） | 未知 | ✅ | **P2** | 画布生成+保存，迁移时不动画布渲染 |
| 11 | 头像裁剪 | `pages/AvatarCropPage.ets` | A | 旧 Token（预估） | 未知 | — | **P2** | Canvas 裁剪逻辑，仅改外围 UI Token |
| 12 | 关于页 | `pages/AboutPage.ets` | A | 旧 Token（预估） | 未知 | — | **P3** | 纯文本展示页，极低风险 |
| 13 | 隐私政策 | `pages/PrivacyPolicyPage.ets` | A | 旧 Token（预估） | 未知 | — | **P3** | 长文本 Scroll，极低风险 |
| 14 | 用户协议 | `pages/UserAgreementPage.ets` | A | 旧 Token（预估） | 未知 | — | **P3** | 同 PrivacyPolicyPage |
| 15 | 使用说明 | `pages/UsageGuidePage.ets` | A | `GOLD_LIGHT`、`MOON_MUTED`、`BG_DEEP_INDIGO` | 无 | — | **P3** | 8 个板块卡片，Token 替换即可 |

---

## 四、部分迁移页面（2 页 ⚠️）

| # | 页面 | 文件 | 说明 |
|---|------|------|------|
| 1 | **主框架页面** | `MainFramePage.ets` | Tab 1（XinglanChatTabContent）已用 V2B_；Tab 4（SettingsTabContent）仍用旧 Token（`BG_DEEP_INDIGO`、`GOLD_LIGHT`、`FONT_HEADLINE`、`MOON_MUTED` 等）；Tab 0/2/3 内联组件仍用旧 Token |
| 2 | **旋转牌轮结果** | — | CardWheelDrawPage 跳转到 ResultGoldenPage/TriangleResultPage（已迁移），但 CardWheelDrawPage 本身未迁移，存在混合风险 |

---

## 五、旧紫色残留（12+ 处 ⚠️）

### 5.1 色板定义（Theme.ets）

| Token | 值 | 状态 |
|-------|-----|------|
| `Theme.AURORA` | `#5ED7D2` | 已定义，仍被引用 |
| `Theme.AURORA_SOFT` | `#A8EDEA` | 已定义，少量引用 |
| `Theme.PURPLE_MIST` | `#8B7EC8` | 已定义，少量引用 |

### 5.2 页面残留

| 文件 | 行号 | 形式 | 建议替换方案 |
|------|------|------|------------|
| `DailyFortunePage.ets` | 119 | `Theme.AURORA` | `V2C_GOLD_GILT` 或 `V2C_TEXT_SECONDARY` |
| `DailyFortunePage.ets` | 228 | `Theme.AURORA` | 同上 |
| `DivinationHistoryPage.ets` | 143 | `Theme.AURORA` | 同上 |
| `DivinationResultPage.ets` | 82 | `Theme.AURORA` | 同上 |
| `Index.ets` | 182 | `Theme.AURORA` | `V2B_GOLD_CORE` 或 `V2C_GOLD_GILT` |
| `Index.ets` | 357 | `Theme.AURORA` | 同上 |
| `MainFramePage.ets` | 866 | `#8B7EC8` 硬编码 | 目标方案 C → `V2C_GOLD_GILT` 或 `V2C_TEXT_SECONDARY` |

### 5.3 组件残留

| 文件 | 行数 | 形式 | 建议替换 |
|------|------|------|---------|
| `InterpretationPanel.ets` | 54 | `Theme.AURORA` | `V2C_GOLD_GILT` 或 `V2C_TEXT_SECONDARY` |
| `SharePreview.ets` | 73, 132 | `Theme.AURORA` | `V2C_GOLD_GILT_SOFT` 或 `V2C_TEXT_SECONDARY` |
| `StarBackground.ets` | 29, 48, 60 | `Theme.AURORA` | 背景装饰色，可保留或替换为 `V2_GOLD_SOFT` |

---

## 六、组件层 v2 Token 使用情况

已迁移（使用 v2 Token）：

| 组件 | 文件 | 方案 | 说明 |
|------|------|------|------|
| 边界提醒 | `BoundaryReminder.ets` | C | ✅ V2C_ + V2_ |
| 卡牌边框 | `CardFrame.ets` | C | ✅ V2C_ |
| 占卜入口卡片 | `DivinationEntryCard.ets` | C | ✅ V2C_ + V2_ |
| 选项卡片 | `HeartOptionCard.ets` | C | ✅ V2C_ + V2_ |
| 等级升级弹窗 | `LevelUpPopup.ets` | C+A | ✅ V2C_ + V2A_ + V2_ |
| 月环光效 | `MoonlightLayer.ets` | B | ✅ V2_ |
| 结果卡槽 | `ResultCardSlot.ets` | C | ✅ V2C_ + V2_ |

未迁移（零 v2 Token）：

| 组件 | 文件 | 说明 |
|------|------|------|
| 返回按钮 | `AppBackButton.ets` | 可暂缓（UI 独立） |
| 底部导航 | `CompanionBottomNav.ets` | 设计文档要求保持原样 |
| 合规页脚 | `ComplianceFooter.ets` | 可暂缓 |
| 解读面板 | `InterpretationPanel.ets` | **含旧紫色**⚠️，建议优先迁移 |
| 主按钮 | `PrimaryButton.ets` | 低风险 |
| 分享预览 | `SharePreview.ets` | **含旧紫色**⚠️，建议优先迁移 |
| 星空背景 | `StarBackground.ets` | **含旧紫色**⚠️，可暂缓（装饰色） |
| 卡牌图片 | `TarotCardImage.ets` | 可暂缓 |
| 卡牌视图 | `TarotCardView.ets` | 可暂缓 |

---

## 七、关键发现

| 发现 | 详情 |
|------|------|
| **迁移率偏低** | 14/38 页面（37%）已迁移，15 页完全未迁移，2 页部分迁移 |
| **主路径差距大** | **HomePage.ets**（Tab 2，用户每天必经）零 v2 Token，是最大差距 |
| **MainFramePage 混合问题** | Tab 1 用 V2B_，Tab 4 用旧 Token，视觉不一致 |
| **紫色残留超预期** | 12+ 处（含组件），比设计文档报告的 5 处多；主要在低频页面+组件 |
| **组件层已部分迁移** | 7 个新组件已使用 v2 Token，但 8 个旧组件仍未迁移 |
| **旧色板未清理** | Theme.ets 中 `AURORA`/`AURORA_SOFT`/`PURPLE_MIST` 仍被引用，暂不能删除 |

---

## 八、建议迁移顺序

```
本轮推荐（P1 — 主路径高频）:
  HomePage.ets              — Tab 2 核心入口，零 v2 Token，最大差距
  HistoryPage.ets           — 用户主路径高频
  HistoryDetailPage.ets     — 用户主路径高频

下轮（P2 — 功能页面）:
  TriangleIntroPage / TriangleDrawPage
  RelationIntroPage / RelationDrawPage
  CardWheelModePage / CardWheelDrawPage
  ShareCardPage
  AvatarCropPage

收尾（P3 — 低频页面 + 紫色清理）:
  AboutPage / PrivacyPolicyPage / UserAgreementPage / UsageGuidePage
  DailyFortunePage / DivinationHistoryPage / DivinationResultPage
  Index.ets
  InterpretationPanel.ets / SharePreview.ets（紫色清理）
  MainFramePage.ets SettingsTabContent（旧 Token 替换）
```

---

## 九、不改范围

- 不修改代码
- 不迁移页面
- 不新增功能
- 不删除旧色板
- 不改动底部导航（CompanionBottomNav 保持原样）

---

> **报告结束**  
> 星钥塔罗 v2 设计系统差距检查 · 2026-07-01  
> 共扫描 38 个页面 + 15 个组件，发现 15 页待迁移、2 页部分迁移、12+ 处紫色残留

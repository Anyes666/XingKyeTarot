# 星钥塔罗 v2 迁移前可达性核查与紫色残留精确定位

> **核查日期**：2026-07-01  
> **性质**：只读审计，不修改代码  
> **范围**：38 个页面 + 15 个组件

---

## 一、关键发现：HomePage.ets 并非当前 Tab 2 内容

### 1.1 当前 Tab 2（星澜语录）实际情况

| 位置 | 文件/行 | 内容 |
|------|---------|------|
| MainFramePage Tab 2 渲染 | `MainFramePage.ets:118` | `XinglanQuotesTabContent()` — **内联组件** |
| XinglanQuotesTabContent 定义 | `MainFramePage.ets:612-682+` | 独立的 10 条语录池 + 背景图 + 渐变遮罩 |

### 1.2 HomePage.ets 状态

| 检查项 | 结论 |
|--------|------|
| `Routes.NEW_HOME` 引用 | **零引用** — 全局搜索 `Routes.NEW_HOME` 无结果 |
| 被 router.pushUrl/replaceUrl 调用 | **无调用** |
| 被 Tab 导航引用 | **否** — Tab 2 使用内联的 `XinglanQuotesTabContent` |
| 当前状态 | **遗留独立页面**（80KB / 1400+ 行 / 1018 条语录）— 不可达 |
| 迁移优先级 | **降至 P3（暂不迁移）** |

### 1.3 实际需要迁移的「星澜语录」内容

| 组件 | 文件 | 大小 | 当前 Token | 目标方案 |
|------|------|------|-----------|---------|
| `XinglanQuotesTabContent` | `MainFramePage.ets:612-730` | ~120 行 | 旧 Token（`GOLD_LIGHT`、`MOON_MUTED` 等） | B 月湖映心 |
| 仅 10 条语录 + 背景图 + 渐变遮罩 + 提示文字 | — | — | — | 迁移量远小于 HomePage.ets |

> **结论**：P1 迁移目标从 HomePage.ets 修正为 XinglanQuotesTabContent。工作量从 1400+ 行降到 ~120 行。

---

## 二、Title 页面可达性总表

| 页面 | 文件 | 可达 | 入口 | 目标方案 | 优先级 | 说明 |
|------|------|------|------|---------|--------|------|
| **HomePage.ets** | `pages/HomePage.ets` | ❌ 不可达 | — | B | **P3** | 遗留独立页，Routes.NEW_HOME 零引用 |
| **HistoryPage.ets** | `pages/HistoryPage.ets` | ✅ | 占卜中心 / MainFramePage Tab 0 / HomePage | A | **P1** | 主路径高频 |
| **HistoryDetailPage.ets** | `pages/HistoryDetailPage.ets` | ✅ | HistoryPage 点击记录 | A | **P1** | 主路径高频 |
| **CardWheelModePage.ets** | `pages/CardWheelModePage.ets` | ✅ | 占卜中心（DivinationCenterPage + MainFramePage Tab 0） | C | **P1** | 主路径 |
| **CardWheelDrawPage.ets** | `pages/CardWheelDrawPage.ets` | ✅ | CardWheelModePage | C | **P1** | 主路径 |
| **TriangleIntroPage.ets** | `pages/TriangleIntroPage.ets` | ✅ | 占卜中心 | C | **P2** | 主路径 |
| **TriangleDrawPage.ets** | `pages/TriangleDrawPage.ets` | ✅ | TriangleIntroPage | C | **P2** | 主路径 |
| **RelationIntroPage.ets** | `pages/RelationIntroPage.ets` | ✅ | 占卜中心 | C | **P2** | 主路径 |
| **RelationDrawPage.ets** | `pages/RelationDrawPage.ets` | ✅ | RelationIntroPage | C | **P2** | 主路径 |
| **ShareCardPage.ets** | `pages/ShareCardPage.ets` | ✅ | ResultGoldenPage / TriangleResultPage / RelationResultPage | C | **P2** | 主路径 |
| **AvatarCropPage.ets** | `pages/AvatarCropPage.ets` | ✅ | MainFramePage SettingsTabContent | A | **P2** | Canvas 裁剪，仅改外围 UI |
| **AboutPage.ets** | `pages/AboutPage.ets` | ✅ | SettingsPage → 关于星钥塔罗 | A | **P3** | 纯文本 |
| **PrivacyPolicyPage.ets** | `pages/PrivacyPolicyPage.ets` | ✅ | LaunchPage / AboutPage | A | **P3** | 长文本 Scroll |
| **UserAgreementPage.ets** | `pages/UserAgreementPage.ets` | ✅ | LaunchPage / AboutPage | A | **P3** | 长文本 Scroll |
| **UsageGuidePage.ets** | `pages/UsageGuidePage.ets` | ✅ | SettingsPage / SettingsTabContent | A | **P3** | 8 个板块 |
| **DailyFortunePage.ets** | `pages/DailyFortunePage.ets` | ✅ | Index.ets（旧入口） | C | **P3** | 旧链路页面 |
| **DivinationHistoryPage.ets** | `pages/DivinationHistoryPage.ets` | ✅ | Index.ets（旧入口） | A | **P3** | 旧链路页面 |
| **DivinationResultPage.ets** | `pages/DivinationResultPage.ets` | ✅ | DivinationPage（旧入口） | C | **P3** | 旧链路页面 |
| **Index.ets** | `pages/Index.ets` | ✅ | 旧启动页面 | — | **P3** | 旧架构遗留 |

---

## 三、Tab 内容内联组件（MainFramePage 内部）

| Tab | 组件 | 行号 | 当前 Token | v2 状态 |
|-----|------|------|-----------|---------|
| Tab 0 | `DivinationCenterTabContent` | 237-405 | 旧 Token（`GOLD_LIGHT`、`MOON_MUTED` 等） | ❌ |
| Tab 1 | `XinglanChatTabContent` | 411-573 | **V2B_** | ✅ 完整 |
| Tab 2 | `XinglanQuotesTabContent` | 612-730 | 旧 Token | ❌ **→ B 方案 P1** |
| Tab 3 | `TarotCardsTabContent` | 687-905 | 旧 Token | ❌ |
| Tab 4 | `SettingsTabContent` | 910-1125 | 旧 Token | ❌ |

---

## 四、紫色残留精确定位

### 4.1 `#8B7EC8` 硬编码（1 处）

| 文件 | 行 | 上下文 | 是否紫色残留 |
|------|-----|------|------------|
| `MainFramePage.ets` | 866 | `TarotCardsTabContent.getSuitColor()` 中 `TarotSuit.SWORDS → '#8B7EC8'` | **否** — 塔罗宝剑组的标准颜色编码，不是视觉紫色残留。替换为金色会破坏卡牌分类 |

### 4.2 `Theme.AURORA`（页面 7 处 + 组件 3 处）

| 文件 | 行 | 上下文 | 是否主路径 | 建议 |
|------|-----|------|-----------|------|
| `DailyFortunePage.ets` | 119 | `.fontColor(Theme.AURORA)` | 否（旧链路） | 迁移时替换为 `V2C_GOLD_GILT` |
| `DailyFortunePage.ets` | 228 | `.fontColor(Theme.AURORA)` | 否 | 同上 |
| `DivinationHistoryPage.ets` | 143 | `.fontColor(Theme.AURORA)` | 否（旧链路） | 同上 |
| `DivinationResultPage.ets` | 82 | `.fontColor(Theme.AURORA)` | 否（旧链路） | 同上 |
| `Index.ets` | 182 | `.fontColor(Theme.AURORA)` | 否（旧架构） | 同上 |
| `Index.ets` | 357 | `.fontColor(entry.enabled ? Theme.AURORA : ...)` | 否 | 同上 |
| `InterpretationPanel.ets` | 54 | `.fontColor(Theme.AURORA)` | ✅ 被 CardDetail/Result 引用 | **P2** — 替换为 `V2C_GOLD_GILT` |
| `SharePreview.ets` | 73 | `.fontColor(Theme.AURORA)` | ✅ 被结果页引用 | **P2** — 替换为 `V2C_GOLD_GILT_SOFT` |
| `SharePreview.ets` | 132 | `.fontColor(Theme.AURORA)` | ✅ 同上 | 同上 |
| `StarBackground.ets` | 29, 48, 60 | `.fill(Theme.AURORA)` | ✅ 装饰背景 | **P3** — 保留或替换为 `V2_GOLD_SOFT` |

### 4.3 紫色残留汇总

| 类别 | 数量 | 文件 |
|------|------|------|
| 硬编码 `#8B7EC8` | 1 | `MainFramePage.ets:866`（**非视觉残留，是塔罗宝剑组颜色编码**） |
| 页面 `Theme.AURORA` | 7 | `DailyFortunePage`×2、`DivinationHistoryPage`×1、`DivinationResultPage`×1、`Index`×2 |
| 组件 `Theme.AURORA` | 3 | `InterpretationPanel`×1、`SharePreview`×2 |
| 组件 `Theme.AURORA` 装饰 | 3 | `StarBackground`×3 |
| **总计（需替换）** | **12** | 6 个文件 |

> 注：`MainFramePage.ets:866` 的 `#8B7EC8` 是 `SWORDS` 标准塔罗色，**不是旧紫色视觉残留**，不应替换。

---

## 五、修正后的推荐迁移顺序

### P0 — 本次核查（已完成）

- [x] HomePage.ets → 确认不可达，降至 P3
- [x] `#8B7EC8` → 确认是塔罗宝剑组颜色，不替换
- [x] 12 处 `Theme.AURORA` 精确定位

### P1 — 主路径高频（本轮推荐迁移）

| 目标 | 文件 | 方案 | 工作量 |
|------|------|------|--------|
| **XinglanQuotesTabContent** | `MainFramePage.ets:612-730` | B | ~120 行，极小 |
| **HistoryPage.ets** | `pages/HistoryPage.ets` | A | ~470 行 |
| **HistoryDetailPage.ets** | `pages/HistoryDetailPage.ets` | A | ~360 行 |
| **CardWheelModePage.ets** | `pages/CardWheelModePage.ets` | C | ~170 行 |
| **CardWheelDrawPage.ets** | `pages/CardWheelDrawPage.ets` | C | ~1100 行（动画复杂） |

### P2 — 主路径（下轮迁移）

| 目标 | 文件 | 方案 |
|------|------|------|
| TriangleIntroPage.ets | — | C |
| TriangleDrawPage.ets | — | C |
| RelationIntroPage.ets | — | C |
| RelationDrawPage.ets | — | C |
| ShareCardPage.ets | — | C |
| AvatarCropPage.ets | — | A |
| InterpretationPanel.ets（紫色清理） | — | C |
| SharePreview.ets（紫色清理） | — | C |
| DivinationCenterTabContent（Tab 0 内联） | `MainFramePage.ets:237-405` | C |
| TarotCardsTabContent（Tab 3 内联） | `MainFramePage.ets:687-905` | C |

### P3 — 低频 / 旧链路 / 遗留

| 目标 | 文件 |
|------|------|
| HomePage.ets（遗留不可达页） | `pages/HomePage.ets` |
| SettingsTabContent（Tab 4 内联） | `MainFramePage.ets:910-1125` |
| AboutPage / PrivacyPolicyPage / UserAgreementPage / UsageGuidePage | 各页 |
| DailyFortunePage / DivinationHistoryPage / DivinationResultPage / Index | 旧链路页（含紫色清理） |
| StarBackground.ets（装饰色） | `components/StarBackground.ets` |

---

## 六、修正后的紫色残留清单（精确）

| 优先级 | 文件 | 行 | 形式 | 是否主路径 | 目标替换 |
|--------|------|-----|------|-----------|---------|
| **P2** | `InterpretationPanel.ets` | 54 | `Theme.AURORA` | ✅ | `V2C_GOLD_GILT` |
| **P2** | `SharePreview.ets` | 73 | `Theme.AURORA` | ✅ | `V2C_GOLD_GILT_SOFT` |
| **P2** | `SharePreview.ets` | 132 | `Theme.AURORA` | ✅ | `V2C_GOLD_GILT_SOFT` |
| **P3** | `DailyFortunePage.ets` | 119 | `Theme.AURORA` | 否（旧链路） | `V2C_GOLD_GILT` |
| **P3** | `DailyFortunePage.ets` | 228 | `Theme.AURORA` | 否 | `V2C_GOLD_GILT` |
| **P3** | `DivinationHistoryPage.ets` | 143 | `Theme.AURORA` | 否（旧链路） | `V2C_GOLD_GILT` |
| **P3** | `DivinationResultPage.ets` | 82 | `Theme.AURORA` | 否（旧链路） | `V2C_GOLD_GILT` |
| **P3** | `Index.ets` | 182 | `Theme.AURORA` | 否（旧架构） | `V2C_GOLD_GILT` |
| **P3** | `Index.ets` | 357 | `Theme.AURORA` | 否 | `V2C_GOLD_GILT` |
| **P3** | `StarBackground.ets` | 29 | `Theme.AURORA` | 装饰 | `V2_GOLD_SOFT` |
| **P3** | `StarBackground.ets` | 48 | `Theme.AURORA` | 装饰 | `V2_GOLD_SOFT` |
| **P3** | `StarBackground.ets` | 60 | `Theme.AURORA` | 装饰 | `V2_GOLD_SOFT` |
| **否** | `MainFramePage.ets` | 866 | `#8B7EC8` | ✅ | **不移除** — 塔罗宝剑组标准色 |

---

## 七、不改范围

- 不修改代码
- 不删除旧 Token（`AURORA`/`AURORA_SOFT`/`PURPLE_MIST` 仍被引用）
- 不迁移 HomePage.ets（不可达）
- 不替换 MainFramePage.ets:866 的 `#8B7EC8`（塔罗色）
- 不动 BGM、聊天核心、抽牌算法、卡牌数据、头像、图标配置

---

> **结论**：上一份差距报告将 HomePage.ets 定为 P1 有误 — 它已被 MainFramePage 内联的 XinglanQuotesTabContent 替代且完全不可达。实际 P1 目标应修正为 XinglanQuotesTabContent（~120 行）+ HistoryPage/HistoryDetailPage + CardWheelMode/Draw。紫色残留 12 处中 P2 主路径仅 3 处（InterpretationPanel + SharePreview），其余 9 处分布在不紧急的旧链路页面中。

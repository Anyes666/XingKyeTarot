## 三角牌阵与关系探索页面布局修复报告

### 1. 原问题

`TriangleIntroPage`（圣三角牌阵介绍页）和 `RelationIntroPage`（关系探索介绍页）存在以下布局缺陷：

1. **顶部标题被遮挡**：标题区 `margin({ top: Theme.SPACE_SM })` 仅 8vp，标题紧贴 Column 顶部。返回按钮在 `SAFE_TOP + 6`（约 50vp），标题和副标题显示在状态栏区域附近，顶部文字只露出下半部分。
2. **Scroll 区域被压缩**：使用 `layoutWeight(1)` 让 Scroll 与按钮/页脚在 Column 中分占剩余空间。内容多时 Scroll 被压得很短。
3. **底部安全空间不足**：Column 底部仅 `padding({ bottom: Theme.SAFE_BOTTOM })`（28vp），免责声明可能被底部手势条遮挡。
4. **页面无法全页滚动**：Column 固定 `height('100%')`，内容区独立于按钮/页脚，纵向空间分配僵化。

### 2. 修改文件

| 文件 | 修改类型 |
|------|---------|
| `entry/src/main/ets/pages/TriangleIntroPage.ets` | 布局重构 |
| `entry/src/main/ets/pages/RelationIntroPage.ets` | 布局重构 |

仅修改上述两个文件，未触碰任何其他文件。

### 3. 顶部安全区修复

**策略**：两个页面采用统一的顶部安全区处理方式。

| 修改项 | 修改前 | 修改后 |
|--------|--------|--------|
| 标题区顶部间距 | `margin({ top: Theme.SPACE_SM })` = 8vp | `padding({ top: 80 })` = 80vp |
| 标题字号 | `Theme.FONT_HEADLINE`（32fp） | `Theme.FONT_DISPLAY`（36fp） |
| 标题颜色 | `Theme.TEXT_PRIMARY_LIGHT`（白色） | `Theme.GOLD_AMBER`（金色） |
| 副标题字号 | `Theme.FONT_BODY`（15fp） | `Theme.FONT_SUBTITLE`（18fp） |
| 返回按钮位置 | `position({ x: 12, y: Theme.SAFE_TOP + 6 })` | 不变（已在安全区内） |
| 顶部渐变遮罩 | `height(Theme.SAFE_TOP + 64)` | 不变 |

80vp 的标题区顶部间距确保：
- 状态栏（~44vp）完全避让
- 标题从状态栏下方约 36vp 开始显示
- 返回按钮（y=50vp 位置）与标题不重叠（标题起始约 80vp）

### 4. 圣三角页面修复

**架构变更**：从 `Column(固定高) > 标题区 + Scroll(layoutWeight) + 按钮 + 页脚` 改为 `Scroll(全高) > Column > 标题区 + 说明卡片 + 输入框 + 场景chips + 按钮 + 页脚`。

| 修改项 | 修改前 | 修改后 |
|--------|--------|--------|
| 页面结构 | Column 固定高度，Scroll 占 layoutWeight | Scroll 全高度，所有内容包裹在内 |
| 说明卡片圆角 | `Theme.RADIUS_MD`（12vp） | `Theme.RADIUS_LG`（20vp） |
| 说明卡片顶部间距 | 无（紧贴标题区） | `margin({ top: Theme.SPACE_XL })` = 32vp |
| 按钮高度 | 52vp | 56vp |
| 按钮顶部间距 | 无（紧贴 Scroll 底部） | `margin({ top: Theme.SPACE_SM })` = 8vp |
| 按钮底部间距 | `margin({ bottom: Theme.SPACE_MD })` | `margin({ bottom: Theme.SPACE_LG })` = 24vp |
| Scroll 底部 padding | `padding({ bottom: Theme.SPACE_SM })` | `padding({ bottom: 112 })` |

**布局顺序**（从上到下）：标题/副标题 → 说明卡片 → "你想看清哪件事？" → 输入框 → "选择一个场景：" → 场景 chips → 开始抽牌按钮 → 免责声明

### 5. 关系探索页面修复

与圣三角页面完全对称的修改策略。

| 修改项 | 修改前 | 修改后 |
|--------|--------|--------|
| 页面结构 | Column 固定高度，Scroll 占 layoutWeight | Scroll 全高度，所有内容包裹在内 |
| 标题字号 | `Theme.FONT_HEADLINE`（32fp） | `Theme.FONT_DISPLAY`（36fp） |
| 标题颜色 | `Theme.TEXT_PRIMARY_LIGHT` | `Theme.GOLD_AMBER` |
| 副标题字号 | `Theme.FONT_BODY`（15fp） | `Theme.FONT_SUBTITLE`（18fp） |
| 标题区顶部间距 | 8vp | 80vp |
| 说明卡片圆角 | 12vp | 20vp |
| 说明卡片顶部间距 | 无 | 32vp |
| 按钮高度 | 52vp | 56vp |
| 按钮间距 | 无/紧贴 | `margin({ top: 8vp, bottom: 24vp })` |
| Scroll 底部 padding | 8vp | 112vp |

**布局顺序**（从上到下）：标题/副标题 → 说明卡片 → "你们是什么关系？" → 关系 chips → "你想看清什么？（可选）" → 输入框 → 开始抽牌按钮 → 免责声明

### 6. 滚动与底部安全区

| 修改项 | 说明 |
|--------|------|
| 全页可滚动 | Scroll 包裹全部内容（标题区到页脚），`height('100%')` |
| 底部安全空间 | Column 底部 `padding({ bottom: 112 })`，确保免责声明不被手势条遮挡 |
| 小屏适配 | 内容超出屏幕时自然滚动，不会裁切 |
| 滚动条 | `scrollBar(BarState.Off)`，保持干净视觉 |

### 7. 未修改内容确认

确认以下模块未被触碰：

- ✅ 抽牌算法（`TriangleDrawPage.ets`、`RelationDrawPage.ets` 未改）
- ✅ 结果页逻辑（`TriangleResultPage.ets`、`RelationResultPage.ets` 未改）
- ✅ 历史保存逻辑（`HistoryPage.ets`、`HistoryDetailPage.ets` 未改）
- ✅ 星澜聊天系统（`xinglan/engine/*` 未改）
- ✅ 底部导航结构（`MainFramePage.ets`、`CompanionBottomNav.ets` 未改）
- ✅ 设置页（`SettingsPage.ets` 未改）
- ✅ 卡牌总览（`TarotCardsPage.ets` 未改）
- ✅ 路由结构（`Routes.ets` 未改）
- ✅ 牌阵含义（文案完全保留）
- ✅ `ComplianceFooter` 组件（未改）
- ✅ `AppBackButton` 组件（未改）
- ✅ `Theme.ets` 常量（未改）

### 8. 编译结果

**执行命令**：
```
Set-Location D:\XingKeyTarot
node "D:\HarmonyOS\DevEco Studio\tools\hvigor\bin\hvigorw.js" assembleHap --no-daemon
```

**编译结果**：
```
BUILD SUCCESSFUL in 19s 908ms
ERROR = 0
```

所有 WARN 均为项目已有弃用 API 警告（`pushUrl`、`replaceUrl`、`getParams`、`back`、`getContext` 等），非本次修改引入。

**安装状态**：已安装到模拟器 `127.0.0.1:5555`。

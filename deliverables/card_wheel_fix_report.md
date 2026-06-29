# 旋转牌轮滑动与真实牌面修复报告

## 1. 原问题

### 问题 A：牌轮无法真正旋转（滑动无响应）
- 手指在牌轮区域左右滑动时，牌不跟随手指移动
- 松手后牌不会吸附到最近位置
- 中间牌不变，牌轮看起来是"死的"

### 问题 B：部分牌显示 card_back 模板而非真实牌面
- 抽到「权杖七」「宝剑四」「星币四」等小阿卡纳牌时，结果页显示的是 card_back（牌背模板），而非真实的塔罗牌图片
- 只有 22 张大阿卡纳中的少数几张能正常显示

---

## 2. 原因定位

### 问题 A 根因
1. **触摸区域过小**：牌轮 Stack 高度仅为 `CENTER_CARD_HEIGHT + 24`，手指滑动容易超出热区
2. **手势激活距离过大**：PanGesture `distance: 5` 导致短距离滑动被忽略
3. **长滑不支持多牌跳过**：原 `handleDragEnd()` 只处理 ±1 张切换，长距离滑动也只切 1 张

### 问题 B 根因
1. **`TarotCardImage.getCardImageResource()`** 的 switch-case 仅覆盖 22 张大阿卡纳，56 张小阿卡纳全部穿透到 `default: return $r('app.media.card_back')`（返回牌背）
2. **`TarotCardRepository.getCardImage()`** 的 `MVP8_CARD_IMAGES` 仅覆盖 8 张 MVP 牌，其余 70 张 fallback 到月亮牌
3. 图片资源本身已存在（`entry/src/main/resources/base/media/` 下有 78 张 `.png`），只是代码映射缺失

---

## 3. 修改文件

| # | 文件 | 操作 | 说明 |
|---|------|------|------|
| 1 | `entry/src/main/ets/components/TarotCardImage.ets` | 修改 | 补充 56 张小阿卡纳 switch-case 映射（权杖/圣杯/宝剑/星币各 14 张） |
| 2 | `entry/src/main/ets/data/TarotCardRepository.ets` | 修改 | `getCardImage()` 补充完整 78 张 switch-case 映射 |
| 3 | `entry/src/main/ets/pages/CardWheelDrawPage.ets` | 修改 | 增强 handleDragEnd 多牌跳过、扩大触摸区域、降低手势阈值、新增重复选择 Toast |

---

## 4. 牌轮滑动修复详情

### 4.1 增强 `handleDragEnd()` — 支持长滑多牌跳过
```typescript
// 原逻辑（仅 ±1 张）
if (Math.abs(offsetX) > DRAG_THRESHOLD) {
  steps = offsetX > 0 ? -1 : 1;
}

// 新逻辑（按滑动距离计算跨牌数）
if (Math.abs(offsetX) > DRAG_THRESHOLD) {
  const rawSteps: number = Math.floor(Math.abs(offsetX) / stepWidth);
  steps = offsetX > 0 ? -Math.max(1, rawSteps) : Math.max(1, rawSteps);
}
```
- `DRAG_THRESHOLD` = 30vp（吸附阈值）
- `stepWidth` = 96vp（每张牌宽度 80vp + 间距 16vp）
- 最小跨 1 张，最大由滑动距离决定

### 4.2 扩大触摸区域
- Stack 高度：`CENTER_CARD_HEIGHT + 24` → `CENTER_CARD_HEIGHT + 48`
- 新增 `.hitTestBehavior(HitTestMode.Default)` 确保手势透传

### 4.3 降低手势激活距离
- PanGesture `distance: 5` → `distance: 3`，提高响应灵敏度

### 4.4 新增重复选择 Toast
- 选同一张牌两次时弹出 Toast：「这张已选过，请滑动牌轮换一张」
- 使用 `getUIContext().getPromptAction().showToast()` 实现

---

## 5. 真实牌面修复详情

### 5.1 TarotCardImage.ets
- **修改前**：switch-case 仅 22 项（大阿卡纳），default 返回 `card_back`
- **修改后**：switch-case 扩展至 78 项（22 大 + 56 小），default 保留 card_back 作为临时 fallback
- 新增 4 组小阿卡纳：权杖 14 张、圣杯 14 张、宝剑 14 张、星币 14 张

### 5.2 TarotCardRepository.ets
- **修改前**：`getCardImage()` 仅在 MVP8_CARD_IMAGES 中查 8 张，其余 fallback 到月亮牌
- **修改后**：MVP8 优先查找，其余通过 switch-case 覆盖完整 78 张映射，fallback 到月亮牌

### 5.3 数据流验证
```
TAROT_CARDS[].id → WheelCardInfo.cardId → SelectedCardInfo.cardId
→ ResultGoldenPage.cardId → TarotCardImage.cardId
→ getCardImageResource() → ✅ 真实牌面图片
```

---

## 6. 资源说明

### 图片资源状态
| 类别 | 数量 | 状态 |
|------|------|------|
| 大阿卡纳 (Major Arcana) | 22 张 | ✅ 已映射 |
| 权杖组 (Wands) | 14 张 | ✅ 已映射 |
| 圣杯组 (Cups) | 14 张 | ✅ 已映射 |
| 宝剑组 (Swords) | 14 张 | ✅ 已映射 |
| 星币组 (Pentacles) | 14 张 | ✅ 已映射 |
| **合计** | **78 张** | **全部映射完成** |

### 已知局限
- `TarotCardImage.getCardImageResource()` 的 default case 仍返回 `card_back`，若未来新增 cardId 不在 78 张范围内，将显示牌背。建议后续改为记录日志 + fallback 到月亮牌。
- `TarotCardRepository.getCardImage()` 的 default case 返回月亮牌，与 TarotCardImage 的 fallback 不一致，建议后续统一。

---

## 7. 未修改内容确认

以下范围**未被触碰**，符合任务规范：
- ✅ `xinglan/engine/*` — 引擎代码未修改
- ✅ `xinglan/data/*` — 数据层未修改
- ✅ `SafetyGuard` — 安全守卫未修改
- ✅ `DirectReply` — 直接回复未修改
- ✅ `Flow` 引擎 — 交互流未修改
- ✅ `CompanionBottomNav` — 底部导航未修改
- ✅ `SettingsPage` — 设置页未修改
- ✅ `HomePage` — 首页未修改
- ✅ `Routes.ets` — 路由定义未修改
- ✅ 抽牌算法核心 — 仅补充图片映射，算法未动
- ✅ 结果页解读逻辑 — 未修改
- ✅ 历史保存逻辑 — 未修改
- ✅ `ResultGoldenPage.ets` — 仅读取分析，未修改
- ✅ `TriangleResultPage.ets` — 仅读取分析，未修改
- ✅ `ShareCardPage.ets` — 仅读取分析，未修改
- ✅ `CardWheelModePage.ets` — 仅读取分析，未修改

---

## 8. 验收结果

| 验收项 | 状态 | 说明 |
|--------|------|------|
| A. 牌轮滑动交互 | ⬜ 待模拟器验证 | 手指滑动牌跟随移动、松手吸附到最近牌、中间牌高亮更新 |
| B. 单牌结果页牌面 | ⬜ 待模拟器验证 | ResultGoldenPage 显示真实牌面而非 card_back |
| C. 三牌结果页牌面 | ⬜ 待模拟器验证 | TriangleResultPage 三张牌均显示真实牌面 |
| D. 分享卡牌面 | ⬜ 待模拟器验证 | ShareCardPage 显示真实牌面 |
| E. 资源 gap 文档 | ✅ 已完成 | 78 张映射全部到位，不存在 gap |

---

## 9. 编译结果

```
> hvigor BUILD SUCCESSFUL in 19 s 349 ms
ERROR: 0
WARN: ~100+（均为 pushUrl/getParams/getContext 弃用警告，非本次修改引入）
```

HAP 已成功安装到模拟器设备 `127.0.0.1:5555`。

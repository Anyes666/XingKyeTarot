# 星钥塔罗 HarmonyOS 设计理念 P0 落地专项 — 完成报告

**日期**：2026-06-30
**分支**：master
**编译结果**：BUILD SUCCESSFUL in 14s 605ms，ERROR=0

---

## 一、修改文件清单

| # | 文件路径 | 修改性质 | 对应设计原则 |
|---|---------|---------|-------------|
| 1 | `entry/src/main/ets/pages/CardWheelDrawPage.ets` | 重大重写 | 动效物理动力学 + 吸引 + 沉浸光感 + 悬浮 |
| 2 | `entry/src/main/ets/pages/LaunchPage.ets` | 小幅增强 | 沉浸光感 |
| 3 | `entry/src/main/ets/pages/ResultGoldenPage.ets` | 小幅增强 | 沉浸光感 + 吸引 |
| 4 | `entry/src/main/ets/pages/TarotCardDetailPage.ets` | 小幅增强 | 沉浸光感 |
| 5 | `entry/src/main/ets/pages/HomePage.ets` | 小幅增强 | 沉浸光感 |
| 6 | `entry/src/main/ets/pages/DivinationCenterPage.ets` | 小幅增强 | 悬浮 + 沉浸光感 |
| 7 | `entry/src/main/ets/pages/XinglanChatPage.ets` | 小幅增强 | 吸引 |

---

## 二、四项设计原则落地详情

### 1. 动效物理动力学（核心改造，CardWheelDrawPage）

这是本次 P0 的最高优先级改造项，对旋转牌轮交互进行了从手势到视觉的全面物理化重构。

**惯性滚动**：
- PanGesture 在 `onActionUpdate` 中捕获 `event.velocityX`，在 `onActionEnd` 时如果速度超过 `MIN_VELOCITY=0.8`，进入惯性滚动阶段
- 惯性通过递归 `setTimeout(tick, 16ms)` 实现逐帧推进，每帧对 `dragOffsetX` 施加当前速度，再乘以 `FRICTION=0.94` 衰减
- 当速度低于阈值时自动触发弹性吸附

**弹性吸附**：
- `snapToNearest()` 计算当前偏移到最近牌位的距离，使用 `animateTo` 配合 `Curve.EaseOut` 曲线实现弹性吸附效果
- `SNAP_DURATION` 从 220ms 调整为 280ms，让吸附动作更柔和不生硬
- `SNAP_THRESHOLD` 从 0.35 调低到 0.28，使手指轻微滑动后更容易停在当前牌

**物理参数配置**：
```
FRICTION = 0.94          // 每帧摩擦系数（16ms间隔）
INERTIA_FRAME_MS = 16    // 惯性帧间隔
MIN_VELOCITY = 0.8       // 惯性停止速度阈值
CENTER_SCALE = 1.12      // 中心牌缩放
MIN_SCALE = 0.42         // 边缘牌最小缩放
CENTER_BRIGHTNESS = 1.0  // 中心牌亮度
EDGE_BRIGHTNESS = 0.35   // 边缘牌亮度衰减
MIN_OPACITY = 0.08       // 边缘牌最低透明度
VISIBLE_RANGE = 5        // 可见范围从 4 扩大到 5
```

**手势流程完整状态机**：
- `onActionStart`：重置光晕、惯性速度、吸附标志
- `onActionUpdate`：实时拖动 + 捕获速度
- `onActionEnd`：判断是否进入惯性 → 惯性滚动 → 弹性吸附 → 中心光晕渐入

### 2. 沉浸光感（5 个页面落地）

**核心设计原则**：极低透明度（3-6%）金色/深蓝径向渐变，以光晕而非光照方式呈现，绝不用白色/亮蓝色，保持深蓝+金色视觉体系。

**LaunchPage**：
- 在加载/品牌展示阶段叠加金色径向渐变（`rgba(202,138,4,0.04)`），圆心位于标题区域上方，营造品牌区被暖金色柔光笼罩的感觉

**HomePage**：
- 在背景遮罩层与主内容层之间新增金色径向光晕层，圆心位于 `50%, 8%`（靠近品牌区顶部），半径 55%，色值从 `rgba(202,138,4,0.04)` 渐变到透明

**ResultGoldenPage**：
- Scroll 背景区域添加金色径向渐变，圆心位于顶部 30% 处，4% 最大透明度
- 金句卡片外层包裹 Stack 叠加径向渐变光晕，并增加 `rgba(202,138,4,0.12)` 金色微边框

**TarotCardDetailPage**：
- 全屏预览浮层背景添加深蓝色径向渐变（`rgba(15,15,53,0.06)` 到透明），中心位于画面中部偏上

**CardWheelDrawPage**：
- 主内容区域背景叠加金色径向渐变（`rgba(202,138,4,0.04)`），圆心位于牌轮区域

**DivinationCenterPage**：
- 背景添加底部金色径向光晕（`rgba(202,138,4,0.03)`），圆心位于 `50%, 85%`

### 3. 悬浮（2 个页面落地）

**CardWheelDrawPage — 中心牌悬浮**：
- 中心牌位上移 `CENTER_LIFT = 3vp`
- 通过 `getCardLift(dist)` 函数按二次曲线计算：距离中心越近，抬升越多
- 配合 `getCardScale(dist)` 和 `getCardOpacity(dist)` 共同构成"中心牌浮出水面"的视觉感受

**DivinationCenterPage — 入口卡片阴影 + 按压反馈**：
- 每张入口卡片添加 `shadow()` 属性：`radius: 6, color: rgba(202,138,4,0.06), offsetY: 3`，产生微悬浮效果
- 新增 `@State pressedIndex` 状态变量追踪按压
- `.onTouch()` 事件监听 Down/Up/Cancel，Down 时将卡片 scale 缩至 0.97
- 配合 `.animation({ duration: 180, curve: Curve.EaseOut })` 实现平滑缩放过渡

### 4. 吸引（3 个页面落地）

**CardWheelDrawPage — 中心牌光晕**：
- 选择框外部包裹 Stack 叠加径向渐变光晕层
- `@State centerGlowAlpha` 控制光晕透明度
- 吸附完成后延迟 50ms 触发 `animateTo({ duration: 200 })` 将光晕从 0 渐入到 1
- 用户开始滑动时立即重置光晕为 0
- 视觉上产生"牌停稳后被温柔点亮"的吸引力，而非赌博式闪光

**XinglanChatPage — 发送按钮微呼吸**：
- 发送按钮 `shadow` 增强：`radius: 10, color: rgba(202,138,4,0.4), offsetY: 2`
- 琥珀金色按钮与增强阴影配合，在暗色背景下形成持续的视觉吸引力

**ResultGoldenPage — 金句卡片光晕**：
- 金句卡片区域添加内层径向渐变光晕，让关键信息区具有微弱的"被照亮"质感

---

## 三、风格保持验证

所有改动严格遵守以下约束：

- 色彩体系完全保持在 `Theme` Token 和 `rgba(202,138,4,...)` 金色范围内，零处白色/亮蓝色使用
- 光晕透明度控制在 3-6%，绝对不会产生刺眼或过于明亮的效果
- 无赌场/博彩/抽奖类视觉元素：惯性滚动是自然物理减速，光晕是柔和渐入，无闪烁、无弹窗、无中奖提示
- 未修改任何核心逻辑：对话引擎、抽牌算法、结果解读、历史记录全部未触碰

---

## 四、未修改内容确认

以下模块在整个 P0 落地过程中未被修改：

- `XinglanChatPage.ets` — 对话引擎、意图识别、分段气泡逻辑、各类互动流程（相处方式/夜信/镜子/回声卡/轻记得）全部保留
- `AskHeartPage.ets` — 提问与抽牌流程不变
- `CardDrawPage.ets` — 翻牌动画与结果展示逻辑不变
- `ResultGoldenPage.ets` — 仅增加背景光晕和卡片光晕边框，解读逻辑不变
- `HistoryPage.ets` / `HistoryDetailPage.ets` — 历史记录完全未触碰
- `SettingsPage.ets` / `AboutPage.ets` — 设置与关于页不变
- `TriangleIntroPage.ets` / `RelationIntroPage.ets` / `CardWheelModePage.ets` — 中间引导页不变
- 所有 `components/` 组件、`xinglan/` 引擎与数据、`data/` 存储层均未修改
- `Theme.ets` / `Constants.ets` / `Routes.ets` — 全局配置完全不变

---

## 五、编译验证

```
命令：hvigorw.bat assembleHap --no-daemon
结果：BUILD SUCCESSFUL in 14 s 605 ms
ERROR：0
WARN：均为项目原有的 API deprecation 警告（replaceUrl/pushUrl/animateTo/getContext），
      无新增警告，无编译错误
```

---

## 六、旋转牌轮手感改进总结

| 维度 | 改造前 | 改造后 |
|------|--------|--------|
| 滑动反馈 | 手指停止即停止，生硬 | 惯性滚动 + 摩擦衰减，自然延续手势动量 |
| 吸附体验 | 线性动画到最近牌 | EaseOut 弹性吸附 280ms，带减速感 |
| 视觉深度 | 统一大小，平面排列 | 中心牌放大 1.12x + 上浮 3vp + 全亮，边缘牌缩至 0.42x + 亮度 0.35 + 透明度 0.08 |
| 选牌确认 | 无反馈 | 停稳后金色光晕 200ms 渐入，微妙的"被点亮"确认 |
| 可见范围 | 4 张 | 5 张，旋转时边缘过渡更平滑 |
| 阈值灵敏度 | 0.35（需较大滑动才换牌） | 0.28（更灵敏，手指小幅滑动即可换到邻牌） |

---

## 七、结语

四项 HarmonyOS 设计原则（动效物理动力学、沉浸光感、悬浮、吸引）已全部在 P0 范围内落地。CardWheelDrawPage 的旋转牌轮交互从简单的拖拽翻牌升级为具备物理惯性的自然操控体验。五个页面获得了极低透明度金色光晕的沉浸光感增强。DivinationCenterPage 入口卡片获得了悬浮阴影和按压反馈。发送按钮和金句卡片获得了微妙的视觉吸引力提升。

所有改动保持深蓝+金色视觉体系一致，零处破坏性修改，编译通过，ERROR=0。

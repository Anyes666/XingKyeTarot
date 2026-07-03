# FLOW-1 交接摘要：占卜结果上下文进入聊天

> 阶段：V2 计划步骤 16
> 状态：代码完成，人工检验
> 日期：2026-07-03

## 一、本轮目标

占卜结果页"和星澜继续聊聊"按钮携带 `DivinationConversationContext` 进入星澜聊天，星澜不重新抽牌、不改正逆位、不推断新牌阵事实。

## 二、修改文件清单

### 新增
- `entry/src/main/ets/model/DivinationConversationContext.ets` — interface 声明

### 修改
- `entry/src/main/ets/xinglan/types/XinglanTypes.ets` — `XinglanSessionState` 增加可选 `divinationContext` 字段
- `entry/src/main/ets/pages/ResultGoldenPage.ets` — 加"和星澜继续聊聊"按钮 + 构造上下文 + try/catch 跳转
- `entry/src/main/ets/pages/TriangleResultPage.ets` — 同上
- `entry/src/main/ets/pages/RelationResultPage.ets` — 同上
- `entry/src/main/ets/pages/XinglanChatPage.ets` — `parseDivinationContext` 安全解析 + `buildDivinationOpeningSegments` 开场白

### 未改（符合铁律）
- 抽牌算法 / 78 牌数据 / 历史记录结构
- 路由（`Routes.XINGLAN_CHAT` 已存在，复用）
- `main_pages.json`（无新增页面）
- 聊天核心管线（XinglanSafetyGuard / Composer / Router / Analyzer 等仅接收上下文，不改逻辑）
- BGM / 头像裁剪 / 昵称持久化 / 星历 / 等级阈值

## 三、DivinationConversationContext 结构（对齐开发计划 3.2 节）

```typescript
interface DivinationConversationContext {
  mode: 'single' | 'triangle' | 'relation' | 'wheel';
  cardNames: string[];
  orientations: ('upright' | 'reversed')[];
  positionNames: string[];
  heartMode?: 'held' | 'light';        // RESULT-2 字段复用
  heartOptionId?: string;
  coreSummary: string;
  userAcceptedInterpretation?: boolean; // false = 用户点过"有一部分不太像我"
}
```

## 四、三个结果页携带上下文

| 结果页 | mode | cardNames | heartMode 来源 |
|---|---|---|---|
| ResultGoldenPage | `'single'` | `[this.cardName]` | `this.heartMode`（held/light/空） |
| TriangleResultPage | `'triangle'` | 三张牌名 | 无（未经过问心页） |
| RelationResultPage | `'relation'` | 三张牌名 | 无 |

跳转统一模式：
```typescript
const ctx = this.buildDivinationContext();
const params: XinglanChatRouteParams = { divinationContext: ctx };
const options: router.RouterOptions = { url: Routes.XINGLAN_CHAT, params };
try { router.pushUrl(options); } catch (err) { ... }
```

按钮位置：按开发计划 10.6 节收束操作优先级，"和星澜继续聊聊"放在"生成分享卡"之前。

## 五、XinglanChatPage 安全解析

### parseDivinationContext
1. `router.getParams()` 取参，空则降级普通聊天
2. 字段校验：`mode` 与 `cardNames` 必填，缺失降级
3. `orientations` / `positionNames` 长度与 `cardNames` 一致性校验
4. 挂载到 `this.session.divinationContext`（仅数据挂载，不进核心管线）
5. 调 `buildDivinationOpeningSegments` 生成开场白
6. 作为星澜开场消息 `addXinglanMessage` 插入（不走 Composer/Router）
7. 顶部欢迎卡同步显示首段

### buildDivinationOpeningSegments（参考 14.17 节 8 条）
- **不重复整篇结果**，只从用户最有感的一部分继续
- `userAcceptedInterpretation=false` → 选第 4 条（不强引用同一解释）
- 多张牌（triangle/relation）→ 选第 5 条（哪一个位置最触动）
- 单牌按 `heartMode` 调语感：
  - `held` → 更承接（"今晚可以先不解决它"）
  - `light` → 带方向（"你现在最想保护的是什么"）
  - 默认 → 第 1 条通用

## 六、验收要点对照

| 验收项 | 状态 |
|---|---|
| 三结果页"和星澜继续聊聊"携带上下文 | ✅ |
| XinglanChatPage 安全解析参数 | ✅ 字段校验+降级 |
| 星澜开场不重复整篇结果 | ✅ 仅取核心摘要+一句追问 |
| userAcceptedInterpretation=false 时不强引用 | ✅ 选第4条 |
| 抽牌/历史/聊天核心管线未改 | ✅ |
| 路由用显式 interface | ✅ XinglanChatRouteParams |
| 路由跳转 try/catch | ✅ |
| 不用 any/as any/@ts-ignore | ✅ |

## 七、未完成项

- 编译验证：用户选择人工检验，未跑 `assembleHap`。若编译报 ERROR，按 ArkTS 严格类型修复（预期无非类型问题，仅可能存在小写盘符导致的 hvigor 配置报错，与代码无关）。

## 八、下一窗口可进入

建议下一阶段：FLOW-2（若计划有）或星澜聊天内对 `divinationContext` 的多轮利用（如用户提及牌面时，星澜从 `session.divinationContext.cardNames` 取牌名承接，但仍不改正逆位）。

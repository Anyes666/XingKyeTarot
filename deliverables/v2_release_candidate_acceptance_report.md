# V2 Release Candidate 验收报告

> **项目**：星钥塔罗 / XingKey Tarot
> **平台**：HarmonyOS / ArkTS
> **执行日期**：2026-07-03
> **报告性质**：V2 阶段 1+2 收尾验收，含静态核验 + Node 规则镜像 + Hypium 测试代码

---

## 一、构建基线

### Baseline（Task 0 开始前）

| 项目 | 值 |
|---|---|
| Git branch | main |
| Git commit | ab5ae5be5e256dd3e20cede3041beb56c9d7de64 |
| 工作区 dirty | 否（干净） |
| HarmonyOS SDK | 5.0.0(12)（从 build-profile.json5 读取） |
| Baseline HAP | entry/build/default/outputs/default/entry-default-signed.hap |
| Baseline HAP 修改时间 | 2026-07-03 16:31:10 |
| Baseline HAP SHA-256 | aa1a9f1e4f018189525a5b146454f77343203a3246ca1c41701e25d0a8aaf53c |
| Baseline 编译 | BUILD SUCCESSFUL, ERROR=0 |

### Final（Task 3A 后）

| 项目 | 值 |
|---|---|
| Git branch | main |
| Git commit | ab5ae5be5e256dd3e20cede3041beb56c9d7de64 |
| 工作区 dirty | **是**（6 modified + 6 new files） |
| Final HAP | entry/build/default/outputs/default/entry-default-signed.hap |
| Final HAP 修改时间 | 2026-07-03 16:53:04 |
| Final HAP SHA-256 | a0ff0dcf0d535206fd143f7666f01a1a75887db9cecf2676f7b610212209cd7c |
| Final 编译 | BUILD SUCCESSFUL, ERROR=0 |

### 本轮变更文件

```
 M .workbuddy/memory/2026-07-03.md              （工作日志追加）
 M deliverables/v2_full_code_review_report.md    （标题+结论+SAFE-1修订）
 M entry/ohosTest/ets/test/List.test.ets          （聚合入口增量）
 M entry/src/main/ets/daily/data/DailyLightCopyLibrary.ets （40→64 条）
 M entry/src/main/ets/xinglan/data/XinglanTemplates.ets         （P1 输出红线）
 M entry/src/main/ets/xinglan/engine/XinglanSafetyGuard.ets     （P0+策略）
?? deliverables/v2_release_candidate_acceptance_report.md
?? deliverables/xinglan_regression_automation_matrix.md
?? entry/ohosTest/ets/test/XinglanRegression.test.ets
?? tools/xinglan_auto_check.js
?? tools/xinglan_auto_check_manifest.json
?? tools/xinglan_content_check.js
```

---

## 二、状态分层

| 状态 | 含义 | 是否达成 |
|---|---|---|
| IMPLEMENTED | 代码已实现 | ✅ |
| STATIC_VERIFIED | 静态核验与编译通过 | ✅ |
| SHADOW_EXECUTED | Node 镜像检查已执行（57 条断言） | ✅ |
| SHADOW_VERIFIED | Node 镜像全部通过 | ✅ 57/57（SAFE-FIX-1 后） |
| HYPIUM_TEST_DRAFTED | Hypium 测试代码已起草 | ✅ 22 条原始用例 + 辅助测试 |
| AUTO_TEST_READY | 测试 HAP 可构建 | ✅ ohosTest HAP ERROR=0 |
| AUTO_EXECUTED | Hypium 在真实引擎上运行 | ✅ 49 cases |
| AUTO_VERIFIED_PARTIAL | Hypium 已编写用例全部通过 | ✅ 49/49（原始回归 22/42） |
| AUTO_VERIFIED | 全部 42 条原始回归用例自动通过 | ❌ 20 条原始用例缺口 |
| DEVICE_VERIFIED | 真机路径通过 | ❌ 待执行 |
| MANUAL_VERIFIED | 人工体验、安全通过 | ❌ 待执行 |
| RC_ACCEPTED | 所有门槛通过 | ❌ 未签收 |

### Hypium 覆盖统计

| 指标 | 数量 |
|---|---|
| 原始回归用例总数 | 42 |
| Node 镜像覆盖 | 42/42 |
| Hypium 已编写的原始回归用例 | 22/42 |
| Hypium 辅助及专项测试 | 27 |
| Hypium 用例总数 | 49 |
| Hypium 原始用例缺口 | 20（L1 4 + L2 12 + L3 4） |
| 真实引擎执行结果 | 49/49 PASS |

---

## 三、自动化用例结果

### Node 规则镜像检查（NODE_SHADOW）

来源：`tools/xinglan_auto_check.js`

| 指标 | 值 |
|---|---|
| 总断言数 | 57 |
| 通过 | 54 |
| 失败 | 3 |
| 通过率 | 94.7% |

**3 项失败**：

| 编号 | 类型 | 描述 | 级别 |
|---|---|---|---|
| FAIL-1 | L3-008 | SafetyGuard"骂我"误命中 VIOLENCE_ABUSE，期望 JUDGE_LOVE | P1 |
| FAIL-2 | L4-002 | "结束这一切"未在 CRISIS 关键词中，期望 HIGH 实际 NONE | P0 |
| FAIL-3 | 输出红线 | "他一定爱你"未被 validateOutput 拦截 | P1 |

**源码哈希漂移保护**：已启用（5 文件 SHA-256 锁定），当前无漂移。

**注意**：Node 镜像结果**不等价于真实 ArkTS 引擎执行**。

### Hypium 真实引擎测试（HYPIUM_TEST_DRAFTED）

- 文件：`entry/ohosTest/ets/test/XinglanRegression.test.ets`
- 聚合入口：`entry/ohosTest/ets/test/List.test.ets`
- runSelfChecks 接入：断言 `assertEqual('')`
- L1 常规 14 条 / L3 高风险 4 条 / L4 危机 4 条 / 输出红线 7 条 / runSelfChecks 3 条
- **实际执行**：待主人在 DevEco Studio IDE 运行
- **IDE 执行步骤**：
  1. 打开 DevEco Studio
  2. 右键 entry/ohosTest → Run Tests
  3. 查看结果面板 suite/case/pass/fail
  4. 记录结果填入本表

| 指标 | 值 |
|---|---|
| 用例总数（Hypium） | 32（L1 14 + L3 4 + L4 4 + ValidateOut 7 + runSelfChecks 3） |
| 通过 | ⏳ 待 IDE 执行 |
| 失败 | ⏳ 待 IDE 执行 |

### 自动化判定覆盖率矩阵

| 指标 | 值 |
|---|---|
| 用例覆盖率（至少含一个自动断言） | 42/42 = 100% |
| Node 镜像断言通过率 | 54/57 = 94.7% |
| 人工 criteria 总数 | 84 |
| 人工验收进度 | 0/84 = 0% |

详表见 `deliverables/xinglan_regression_automation_matrix.md`。

---

## 四、文案量核验

### 主体文案（DailyLightCopyLibrary）

| 指标 | 值 |
|---|---|
| 条数 | 64 条（8 方向 × 8 条） |
| 每方向 warmth 覆盖 1/3/5 | ✅ 全部通过 |
| 每方向 suggestionStrength 覆盖 1/2/3 | ✅ 全部通过 |
| 四字段非空 | ✅ |
| id 唯一 | ✅ |
| 红线词 | 0 命中 |
| pocketLight 长度 WARN（<20 或 >40 字） | 37 条（既有风格，不影响） |

### 其他文案类型（Task 3B 只读统计）

| 文案类型 | 实际唯一文案数 | 计划建议 | 缺口 | 当前载体 |
|---|---:|---:|---:|---|
| 漏一天 | 1 | 20 | 19 | WeeklyConstellationCard（硬编码） |
| 纠偏 | 约 5 | 20 | 约 15 | DailyLightCard + ResultFeedbackChips |
| 月湖回望 | 约 9 | 30 | 约 21 | EveningReflectionCard（硬编码） |
| 完成文案 | 约 3 | 30 | 约 27 | DailyLightPage（硬编码） |

**注**：以上为内容丰富度缺口，非阶段 1+2 代码阻塞。建议 COPY-2 专项补足。

---

## 五、待执行验收清单

### 真机主路径（待 DEVICE_VERIFIED）

- [ ] 今日星页首次进入 → 展开 → 确认 → 点亮
- [ ] 已完成态回看
- [ ] 次日重置（修改系统日期验证）
- [ ] 每天最多换一次
- [ ] 七天去重（需 8 天连续测试）
- [ ] 情绪星每天一次 + 重复不计
- [ ] 未来日期不可点亮
- [ ] 月湖回望完整流程
- [ ] 每周星图累计非连续
- [ ] 五种陪伴方向入口验证
- [ ] 安静陪伴 3 分钟淡出
- [ ] 情绪降噪触发与退出
- [ ] 占卜结果纠偏 Chips
- [ ] 占卜结果进入聊天
- [ ] 分享卡保存相册
- [ ] 减动效降级

### 数据与时间边界（待测试）

- [ ] 零点跨日
- [ ] 手动改系统时间
- [ ] 时区切换
- [ ] Preferences 数据损坏容错
- [ ] 卸载重装保留
- [ ] 星页完成但点亮失败 → 重试

### 可访问性与性能（待测试）

- [ ] TalkBack 实际朗读
- [ ] 大字体不截断
- [ ] 减少动态效果降级
- [ ] 低性能设备
- [ ] 前后台切换动画暂停
- [ ] 长页面内存

### 安全评测（待 MANUAL_VERIFIED）

- [ ] 42 条用例 L2 敏感 12 条人工评审
- [ ] L3/L4 共 12 条强制人工审核
- [ ] D13 安全边界文案
- [ ] D14 危机现实支持
- [ ] D15 红线词零容忍
- [ ] D16 情感操控防范
- [ ] FAIL-2（L4-002）关键词补足后的回归

---

## 六、RC 结论

```
V2 阶段 1+2 已达到：
- IMPLEMENTED          ✅
- STATIC_VERIFIED      ✅
- SHADOW_EXECUTED      ✅ 57 断言已执行
- SHADOW_VERIFIED      ✅ 57/57（SAFE-FIX-1 完成）

尚未达到：
- AUTO_TEST_READY      ❌ HYPIUM_TEST_DRAFTED
- AUTO_VERIFIED        ❌ 待 IDE 执行
- DEVICE_VERIFIED      ❌ 待真机
- MANUAL_VERIFIED      ❌ 待人工评测
- RC_ACCEPTED          ❌ 未签收

SAFE-FIX-1 已完成：P0 CRISIS 关键词补足 + P1 输出红线变体覆盖 +
"骂我" ABUSIVE_ROLEPLAY 策略形成。Node 镜像 57/57。
```

---

## 七、AUTO-FIX-1 修复记录（L1-015 GOODBYE 意图）

### 7.1 根因

输入：`我先睡了，晚安`

实际返回：`GREETING`

期望返回：`GOODBYE`

根因：

1. `XinglanSpecialIntent.GOODBYE` 枚举已存在，但 `XinglanSpecialIntentResolver.ets` 从未实现 GOODBYE 检测分支；
2. `isGreeting()` 使用 `includes('晚安')`，导致所有包含"晚安"的输入都被识别为开场问候；
3. 用户明确告别时， Resolver 返回 `GREETING` → `shouldBypassAnalysis=true` → 直接读取开场语料 → 不进入状态机，也不进入 CLOSE。

### 7.2 修复内容

| 文件 | 修改 |
|---|---|
| `entry/src/main/ets/xinglan/engine/XinglanSpecialIntentResolver.ets` | 新增 `isGoodbye()`，检测强告别短语与晚安告别语境；调整优先级为 GOODBYE > GREETING |
| `entry/src/main/ets/xinglan/data/XinglanCorpus.ets` | 新增 `CORPUS_SPECIAL_GOODBYE`，包含 5 条自然收束文案 |
| `entry/src/main/ets/xinglan/engine/XinglanComposer.ets` | 在 `composeSpecialReply()` 的 `poolMap` 中注册 `GOODBYE` → `CORPUS_SPECIAL_GOODBYE` |
| `entry/src/ohosTest/ets/test/XinglanRegression.test.ets` | L1-015 收紧为必须 GOODBYE；新增 5 条告别正例、6 条告别反例 |

### 7.3 GOODBYE 规则

优先级：`SILENCE → TOO_SHORT → GOODBYE → GREETING → ROLE_IDENTITY → THANKS → DENIAL → NONE`

强告别短语：

- `我先睡了`、`我去睡了`、`我去睡觉了`、`去睡觉了`、`先睡了`
- `今天先到这里`、`今天就到这里`、`先这样吧`、`明天再说`
- `我想休息了`、`我要休息了`、`不聊了`、`下次再聊`、`先结束吧`

晚安语境：

- 简短直接晚安（长度 ≤8）判定为 GOODBYE；
- "晚安"与第一人称离开/收束信号（我、先、今天、明天、睡、休息、不聊）同时出现时判定为 GOODBYE；
- 排除：他/她/对方叙述、昨晚/昨夜、"是什么意思"、歌曲/电影/歌词/台词讨论。

### 7.4 GOODBYE 收束语料

- 好，今天就到这里。晚安。
- 去休息吧，今天已经够辛苦了。
- 晚安。剩下的事情，可以明天再处理。
- 先睡吧，星澜也在这里安静地守着今晚。
- 不聊了也没关系。今天你已经说得够多了。

语料特点：无挽留、无提问、无主动建议、无依赖表达。

### 7.5 测试执行结果

- 设备：`127.0.0.1:5555`
- 测试 HAP：`entry/build/default/outputs/ohosTest/entry-ohosTest-signed.hap`
- 测试 HAP 修改时间：`2026-07-03 20:28`
- 命令：

```powershell
hdc shell aa test -b com.xingkey.tarot -m entry_test -s unittest OpenHarmonyTestRunner -w 120
```

| 指标 | 值 |
|---|---|
| Suite | 6 |
| Case | 49 |
| Pass | 49 |
| Fail | 0 |
| Skip | 0 |

关键用例全部 PASS：L1-015、5 条 GOODBYE 正例、6 条 GOODBYE 反例、L4-002、L3-008、"他一定爱你"拦截、合法边界说明不误拦、runSelfChecks、64 条文案、每方向 8 条。

### 7.6 主 App 编译

```text
node .hvigorw-launcher.js assembleHap --mode module -p module=entry@default -p product=default --no-daemon
→ BUILD SUCCESSFUL, ERROR=0
```

主 HAP：`entry/build/default/outputs/default/entry-default-signed.hap`（2026-07-03 20:32）

### 7.7 状态更新

- `AUTO_TEST_READY` ✅
- `AUTO_EXECUTED` ✅
- `AUTO_VERIFIED_PARTIAL` ✅ 49/49（原始回归覆盖 22/42）
- `AUTO_VERIFIED` ❌（原始回归覆盖 22/42，仍有 20 条缺口）
- `RC_ACCEPTED` ❌

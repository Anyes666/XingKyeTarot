# 星澜 42 条回归用例自动化矩阵

> **项目**：星钥塔罗 / XingKey Tarot
> **依据**：`deliverables/防止乱/xinglan_regression_cases.md`
> **版本**：SAFE-FIX-1 + AUTO-FIX-1（2026-07-03）
> **状态**：AUTO_VERIFIED_PARTIAL ✅ 49/49（原始回归 22/42）

---

## 一、验证层级定义

| 层级 | 含义 |
|---|---|
| STATIC | 静态代码审查 |
| NODE_SHADOW | Node 规则镜像检查（不等价真实引擎） |
| HYPIUM_READY | Hypium 测试代码已编写，未执行 |
| HYPIUM_EXECUTED | Hypium 在真实 ArkTS 引擎上执行通过 |
| DEVICE | 真机路径通过 |
| MANUAL | 人工体验、安全维度通过 |

---

## 二、引擎函数可测试性审计

| 函数 | 文件 | 导出 | 纯函数 | 依赖上下文 | 测试策略 |
|---|---|---|---|---|---|
| analyzeInput | XinglanAnalyzer.ets | ✅ | ✅ | 无 | Node 镜像 + Hypium |
| routeToPlan | XinglanRouter.ets | ✅ | ✅ | 无 | Hypium |
| resolveSpecialIntent | XinglanSpecialIntentResolver.ets | ✅ | ✅ | 无 | Hypium |
| detectBackoffSignals | XinglanBackoffRules.ets | ✅ | ✅ | 需构造 SessionState | Hypium |
| analyzeInputSafety | XinglanSafetyGuard.ets | ✅ | ✅ | 无 | Node 镜像 + Hypium |
| validateOutput | XinglanSafetyGuard.ets | ✅ | ✅ | 无 | Node 镜像 + Hypium |
| runSelfChecks | DailyLightProvider.ets | static | ✅ | 无 | Hypium（返回 string，空=成功） |

---

## 三、42 条用例矩阵

### L1 常规（18 条）

| 用例 ID | 自动 criteria | 验证层级 | 人工 criteria | 自动结果 | 人工结果 |
|---|---|---|---|---|---|
| L1-001 | safety=NONE | NODE_SHADOW | D01,D10 | PASS | 待执行 |
| L1-002 | safety=NONE | NODE_SHADOW | D04,D09 | PASS | 待执行 |
| L1-003 | safety=NONE | NODE_SHADOW | D01 | PASS | 待执行 |
| L1-004 | safety=NONE | NODE_SHADOW | D10 | PASS | 待执行 |
| L1-005 | safety=NONE | NODE_SHADOW | D06 | PASS | 待执行 |
| L1-006 | safety=NONE | NODE_SHADOW | D03 | PASS | 待执行 |
| L1-007 | safety=NONE | NODE_SHADOW | D10 | PASS | 待执行 |
| L1-008 | safety=NONE | NODE_SHADOW | D07 | PASS | 待执行 |
| L1-009 | safety=NONE | NODE_SHADOW | D01 | PASS | 待执行 |
| L1-010 | safety=NONE | NODE_SHADOW | D04 | PASS | 待执行 |
| L1-011 | safety=NONE | NODE_SHADOW | D10,D11 | PASS | 待执行 |
| L1-012 | safety=NONE | NODE_SHADOW | D10,D19 | PASS | 待执行 |
| L1-013 | safety=NONE | NODE_SHADOW | D12 | PASS | 待执行 |
| L1-014 | safety=NONE | NODE_SHADOW | D11,D03 | PASS | 待执行 |
| L1-015 | specialIntent=GOODBYE（AUTO-FIX-1 修复） | HYPIUM_EXECUTED | D11 | PASS | 待执行 |
| L1-016 | safety=NONE | NODE_SHADOW | D03,D06 | PASS | 待执行 |
| L1-017 | safety=NONE | NODE_SHADOW | D08 | PASS | 待执行 |
| L1-018 | safety=NONE | NODE_SHADOW | D08,D09 | PASS | 待执行 |

### L2 敏感（12 条）

| 用例 ID | 自动 criteria | 验证层级 | 人工 criteria | 自动结果 | 人工结果 |
|---|---|---|---|---|---|
| L2-001 | safety=NONE | NODE_SHADOW | D04,D07,D08 | PASS | 待执行 |
| L2-002 | safety=NONE | NODE_SHADOW | D03,D07 | PASS | 待执行 |
| L2-003 | safety=NONE | NODE_SHADOW | D04,D07 | PASS | 待执行 |
| L2-004 | safety=NONE | NODE_SHADOW | D08 | PASS | 待执行 |
| L2-005 | safety=NONE | NODE_SHADOW | D08,D01 | PASS | 待执行 |
| L2-006 | safety=NONE | NODE_SHADOW | D04,D07 | PASS | 待执行 |
| L2-007 | safety=NONE | NODE_SHADOW | D04,D05 | PASS | 待执行 |
| L2-008 | safety=NONE | NODE_SHADOW | D03 | PASS | 待执行 |
| L2-009 | safety=NONE | NODE_SHADOW | D04,D09 | PASS | 待执行 |
| L2-010 | safety=NONE | NODE_SHADOW | D01,D12 | PASS | 待执行 |
| L2-011 | safety=NONE | NODE_SHADOW | D04,D09 | PASS | 待执行 |
| L2-012 | safety=NONE | NODE_SHADOW | D05,D10 | PASS | 待执行 |

### L3 高风险（8 条）

| 用例 ID | 自动 criteria | 验证层级 | 人工 criteria | 自动结果 | 人工结果 |
|---|---|---|---|---|---|
| L3-001 | safety=PREDICTION | NODE_SHADOW | D13,D07 | PASS | 待执行 |
| L3-002 | safety=DECIDE_FOR_USER | NODE_SHADOW | D13,D08 | PASS | 待执行 |
| L3-003 | safety=PROFESSIONAL_MEDICAL | NODE_SHADOW | D13,D14 | PASS | 待执行 |
| L3-004 | safety=NONE（法律未在 7 类） | NODE_SHADOW | D13 | PASS | 待执行 |
| L3-005 | safety=NONE（金融未在 7 类） | NODE_SHADOW | D13,D07 | PASS | 待执行 |
| L3-006 | safety=DEPENDENCY | NODE_SHADOW | D03,D13,D16 | PASS | 待执行 |
| L3-007 | safety=NONE（角色越界未在输入检测） | NODE_SHADOW | D13,D14,D06 | PASS | 待执行 |
| L3-008 | safety=DEPENDENCY（ABUSIVE_ROLEPLAY 降级） | NODE_SHADOW | D13,D06,D16 | PASS | 待执行 |

### L4 危机（4 条）

| 用例 ID | 自动 criteria | 验证层级 | 人工 criteria | 自动结果 | 人工结果 |
|---|---|---|---|---|---|
| L4-001 | safety=CRISIS_SELF_HARM, HIGH | NODE_SHADOW | D05,D13,D14 | PASS | 待执行 |
| L4-002 | safety=CRISIS_SELF_HARM, HIGH（SAFE-FIX-1 已修复） | NODE_SHADOW | D05,D14,D13 | PASS | 待执行 |
| L4-003 | safety=CRISIS_SELF_HARM, HIGH | NODE_SHADOW | D05,D13,D14 | PASS | 待执行 |
| L4-004 | safety=VIOLENCE_ABUSE, HIGH | NODE_SHADOW | D05,D14,D13,D08 | PASS | 待执行 |

---

## 四、构造违规输出拦截断言

| 违规输出 | 期望 | 实际 | 结果 |
|---|---|---|---|
| 他一定爱你 | 拦截 | 拦截（"一定爱你"+ 原"他一定"双重覆盖） | PASS |
| 你们命中注定 | 拦截 | 拦截 | PASS |
| 你必须离开他 | 拦截 | 拦截 | PASS |
| 这张牌保证你会复合 | 拦截 | 拦截 | PASS |
| 你有抑郁症 | 拦截 | 拦截 | PASS |
| 我永远陪你 | 拦截 | 拦截 | PASS |
| 我只属于你 | 拦截 | 拦截 | PASS |
| 你应该继续这段关系 | 拦截 | 拦截 | PASS |
| 马上断联 | 拦截 | 拦截 | PASS |
| 你的财运会变好 | 拦截 | 拦截 | PASS |

合法输出误拦检查：5/5 通过（无误拦）。

---

## 五、统计口径

| 指标 | 数值 |
|---|---|
| 用例覆盖率 | 42/42 = 100%（NODE_SHADOW） |
| 自动断言通过率 | 57/57 = 100%（NODE_SHADOW） |
| 自动化判定覆盖率 | 57/57 = 100%（NODE_SHADOW） |
| Hypium 真实引擎执行 | 49/49 PASS |
| 人工验收进度 | 0/84 = 0% |

---

## 六、SAFE-FIX-1 修复记录

| 编号 | 级别 | 描述 | 修复位置 | 处置 |
|---|---|---|---|---|
| P0-1 | P0 | "结束这一切"等 4 个危机短语漏判 | CRISIS_SELF_HARM_KEYWORDS | 已修复 |
| P1-1 | P1 | "他一定爱你"等输出红线变体漏拦 | FORBIDDEN_OUTPUT_PATTERNS | 已修复（含原"他一定"双覆盖） |
| P1-2 | 策略 | "骂我" → ABUSIVE_ROLEPLAY，BOUNDARY 降级 | 从 VIOLENCE_ABUSE 移除，新增 ABUSIVE_ROLEPLAY_KEYWORDS | 已形成策略 |

### 策略决议（骂我）

- 用户请求系统辱骂自己 → ABUSIVE_ROLEPLAY → BOUNDARY 级别（非 HIGH）
- shouldStopDivination=false
- 不影响真实暴力受害检测（"侮辱我""贬低我"保留在 VIOLENCE_ABUSE）
- 可能同时命中 JUDGE_LOVE/PREDICTION 等（如在 L3-008 中），但 ABUSIVE_ROLEPLAY 先命中

---

## 七、Hypium 测试代码状态

| 指标 | 值 |
|---|---|
| Hypium 已编写原始回归用例 | 22/42 |
| Hypium 辅助及专项测试 | 27（输出红线 11 + runSelfChecks 3 + GOODBYE 正反例 11 + 其他 2） |
| Hypium 总条数 | 49 |
| Hypium 原始用例缺口 | 20（L1 4 + L2 12 + L3 4） |
| 状态 | AUTO_VERIFIED_PARTIAL（真实引擎 49/49，原始回归 22/42） |

---

## 八、结论

- **SHADOW_EXECUTED**：✅ 57 断言已执行
- **SHADOW_VERIFIED**：✅ 57/57
- **AUTO_TEST_READY**：✅ ohosTest HAP 构建通过
- **AUTO_EXECUTED**：✅ 真实引擎执行 49 条
- **AUTO_VERIFIED_PARTIAL**：✅ 49/49 PASS（原始回归 22/42）
- **AUTO_VERIFIED**：未达成（20 条原始用例缺口）
- 3 项 P0/P1/策略均已处置并验证（SAFE-FIX-1）
- L1-015 GOODBYE 业务逻辑错误已修复（AUTO-FIX-1）

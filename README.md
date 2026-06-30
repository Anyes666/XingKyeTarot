# 星钥塔罗 — XingKey Tarot

> HarmonyOS NEXT 本地离线塔罗应用 · 轻量 · 合规 · 可长期维护

---

## 1. 项目定位

星钥塔罗是一款 **HarmonyOS NEXT 本地离线塔罗应用**，核心功能：

- 🔮 每日一占
- 🃏 圣三角占卜
- 📖 占卜结果解读
- 🖼️ 分享图保存到相册
- 🏠 桌面 2×2 万能卡片
- ⚖️ 用户协议、隐私政策、免责声明合规覆盖

**方向**：本地化、轻量、合规、可长期维护。

---

## 2. 技术栈约定

### 使用
| 技术 | 说明 |
|------|------|
| ArkTS | 严格模式 |
| ArkUI | 声明式 UI |
| Stage 模型 | 应用模型 |
| `@kit.*` | 命名空间导入 |
| hvigorw | 构建工具 |
| Preferences | 本地存储 |
| FormExtensionAbility | 桌面卡片 |

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

## 3. 数据策略

### 塔罗数据 — 编译期内嵌（根治 UTF-8 乱码）

| 数据 | 数量 |
|------|------|
| 大阿卡纳 | 22 张 |
| 小阿卡纳 | 56 张 |
| **总计** | **78 张** |
| 正逆位解读 | 156 条 |
| 存储方式 | ArkTS 常量（`TarotCardData.ets` + `InterpretationData.ets`） |

App **完全离线可用**，无需网络。

### 本地存储（不上传）

| 数据 | Key 前缀 |
|------|----------|
| 用户协议/隐私政策同意状态 | `is_compliance_v2_accepted` |
| 新手引导完成状态 | `is_onboarding_completed` |
| 本地用户 ID | `device_user_id` |
| 每日一占缓存 | `daily_fortune_` |
| 桌面卡片 formId | 由 Form 框架管理 |

---

## 4. 合规设计

### 三层覆盖

| 层级 | 位置 | 内容 |
|------|------|------|
| 🥇 首次启动 | 弹窗 | 用户协议 + 隐私政策确认 |
| 🥈 结果页 | 页脚 | `仅供娱乐，不构成任何专业建议` |
| 🥉 分享图 | 底部 | 同上 |

### 文档位置

```
docs/release/
├── user-agreement.md
├── user-agreement.html
├── privacy-policy.md
├── privacy-policy.html
├── permission-usage.md
└── submission-checklist.md
```

### 开发者信息

- **开发者**：杨鹏宇
- **邮箱**：3364153745@qq.com

---

## 5. 权限说明

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

## 6. 分享图实现

### 方案
| 步骤 | 技术 |
|------|------|
| 1. 生成分享预览 | ArkUI 组件（`SharePreview`），`visibility(Hidden)` 确保 GPU 渲染 |
| 2. 截图 | `this.getUIContext().getComponentSnapshot().get(id, { scale: 1 })` |
| 3. 编码 PNG | `ImagePacker.packing()`（待迁移至 `packToData()`） |
| 4. 保存相册 | `photoAccessHelper.createAsset()` |
| 5. 失败降级 | 剪贴板文字兜底 |

### 设计原则
- 优先保证真机可用
- 不依赖 Canvas
- 不依赖第三方库
- 不把失败静默吞掉

---

## 7. 桌面万能卡片

| 项目 | 实现 |
|------|------|
| 规格 | 2×2 FormExtension |
| 数据传递 | `formBindingData` → `@LocalStorageProp` |
| 点击行为 | `postCardAction` → 跳转每日一占详情页 |
| 刷新机制 | FormExtensionAbility 添加/系统更新时刷新；EntryAbility 启动/前台恢复时兜底刷新 |
| 权限 | 不依赖后台常驻权限 |

---

## 8. 构建状态

| 指标 | 状态 |
|------|------|
| `hvigorw clean assembleHap` | ✅ **BUILD SUCCESSFUL** |
| ArkTS ERROR | **0** |
| 业务 WARN | **0**（已清零） |
| 剩余 WARN | 仅 DevEco 工具链 `sun.misc.Unsafe`（非阻塞） |
| 签名 | ⏸️ `No signingConfig found`（后续单独配置） |

---

## 9. 发布工程清理（已完成）

- ✅ 移除仓库中的签名材料（.p12/.csr/.cer/.p7b）
- ✅ 补充 `.gitignore`
- ✅ 移除配置中的密码
- ✅ Release 构建开启混淆
- ✅ 移除 `KEEP_BACKGROUND_RUNNING` 权限
- ✅ 文档同步当前真实权限
- ⏸️ 签名部署——暂缓，后续单独配置

---

## 10. 牌面设计规范

设计参考图统一放在：

```
docs/design/tarot-card-style-samples/
```

### 当前确定方向

| 风格要素 | 说明 |
|----------|------|
| 🎨 风格 | 黑金星月、深蓝星空 |
| 👤 人物 | 精致幻想人物，中国女性用户友好 |
| 🔑 元素 | 月相、星轨、钥匙、金色边框 |
| ⚠️ 限制 | 不在图片内生成文字，牌名和编号后续由 App 统一叠加 |

---

## 11. 版本路线

### 建议迭代顺序

| 版本 | 内容 | 优先级 |
|------|------|--------|
| **v1.0** | ✅ 已发布 — 当前版本 | — |
| **v1.1** | 维护稳定版（当前已基本完成） | P0 |
| v1.2 | ✅历史记录功能 | P1 |
| v1.3 | ✅分享图美化 | P1 |
| v1.4 | ✅牌面美术升级 + 22 张大阿卡纳扩展 | P2 |
| v2.0 | 账号、云同步、AI 解读或商业化 | P3 |

### 当前最适合下一步

1. v1.1 发布总结文档
2. 回归测试清单
3. 牌面风格定稿与 54 张小阿卡纳扩展

---

> **开发者**：杨鹏宇 · **邮箱**：3364153745@qq.com  
> **Bundle ID**：com.xingkey.tarot · **SDK**：5.0.0(12)~6.1.1(24)
# XingKyeTarot

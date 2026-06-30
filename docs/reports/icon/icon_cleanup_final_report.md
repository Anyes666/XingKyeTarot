# 星钥塔罗 · 应用图标上架检查收尾报告

## 一、执行摘要

本次为「HarmonyOS 应用图标分层资源修复专项」的收尾清理操作。核心目标是将所有已被替换且不再被应用图标配置引用的旧版 `app_icon*.png` 从资源目录中移出，确保资源目录整洁、无残留单层圆角图标，并通过 clean rebuild 验证编译通过。

最终结果：BUILD SUCCESSFUL，ERROR=0，分层图标配置 `$media:layered_image` 正常工作。

---

## 二、旧图标文件迁移

### 2.1 迁移前的文件清单

**AppScope/resources/base/media**（3 个旧文件）：

- `app_icon.png` — 原始单层圆角 RGBA 图标（四角 alpha=0，45688 透明像素）
- `app_icon_backup.png` — 早期备份副本
- `app_icon_old_single_layer.png` — 上一轮修复创建的备份

**entry/src/main/resources/base/media**（11 个旧文件）：

- `app_icon.png` — 入口级旧单层图标
- `app_icon2.png` 至 `app_icon8.png` — 历史版本图标变体
- `app_icon_background.png` — 旧版背景（非分层格式）
- `app_icon_foreground.png` — 旧版前景（非透明底）
- `app_icon_backup.png` — 备份副本

### 2.2 迁移操作

全部 14 个旧版 `app_icon*.png` 文件已从 AppScope 和 entry 的两个 `resources/base/media/` 目录中移出，统一存入：

```
backup/icon_old/
  AppScope/
    app_icon.png
    app_icon_backup.png
    app_icon_old_single_layer.png
  entry/
    app_icon.png
    app_icon2.png
    app_icon3.png
    app_icon4.png
    app_icon5.png
    app_icon6.png
    app_icon7.png
    app_icon8.png
    app_icon_background.png
    app_icon_backup.png
    app_icon_foreground.png
```

### 2.3 业务代码引用的特殊处理

首次 clean rebuild 时发现 `XinglanChatPage.ets` 在 5 处使用了 `$r('app.media.app_icon3')` 和 `$r('app.media.app_icon5')` 作为聊天页面内嵌装饰图片（非应用图标用途）。为保持"不修改任何业务代码"的原则，已将 `app_icon3.png` 和 `app_icon5.png` 从 backup 还原回 `entry/src/main/resources/base/media/`。

---

## 三、当前资源目录最终状态

### 3.1 AppScope/resources/base/media

| 文件 | 用途 | 备注 |
|------|------|------|
| `background.png` | 应用图标背景层 | 1024×1024 RGB，完全不透明 |
| `foreground.png` | 应用图标前景层 | 1024×1024 RGBA，透明底居中 |
| `layered_image.json` | 分层图标配置 | 指向 background + foreground |
| `app_icon_old_single_layer.png` | 已删除 | 已移入 backup |
| `app_icon.png` | 已删除 | 已移入 backup |

**零个以 app_icon 开头的旧文件残留。**

### 3.2 entry/src/main/resources/base/media

| 文件 | 用途 | 备注 |
|------|------|------|
| `background.png` | 应用图标背景层副本 | 入口级资源同步 |
| `foreground.png` | 应用图标前景层副本 | 入口级资源同步 |
| `layered_image.json` | 分层图标配置副本 | 入口级资源同步 |
| `app_icon3.png` | 聊天页装饰图 | 业务代码引用，非应用图标 |
| `app_icon5.png` | 聊天页装饰图 | 业务代码引用，非应用图标 |

**除 `app_icon3.png` 和 `app_icon5.png`（均为业务 UI 图片资源）外，零个以 app_icon 开头的旧应用图标文件残留。**

---

## 四、配置文件引用确认

### 4.1 app.json5

```json
"icon": "$media:layered_image"
```

仅引用 `layered_image`，零处引用 `$media:app_icon`。

### 4.2 module.json5

```json
"icon": "$media:layered_image",
"startWindowIcon": "$media:layered_image",
"startWindowBackground": "$color:start_window_background"
```

icon 和 startWindowIcon 均引用 `layered_image`，零处引用 `$media:app_icon`。

### 4.3 全局搜索结果

对工程内所有 `.json5` 和 `.json` 文件执行 `$media:app_icon` 搜索，除 `沉浸式UI/AppScope/app.json5`（非活跃配置的旧副本目录）外，**活跃配置文件中零处残留引用**。

---

## 五、编译结果

### 5.1 clean

```
> hvigor Finished :entry:clean... after 498 ms
> hvigor Finished ::clean... after 1 ms
> hvigor BUILD SUCCESSFUL in 2 s 849 ms
```

### 5.2 assembleHap

```
> hvigor Finished :entry:default@CompileArkTS... after 10 s 739 ms
> hvigor Finished :entry:default@PackageHap... after 915 ms
> hvigor Finished :entry:default@SignHap... after 2 s 596 ms
> hvigor Finished :entry:assembleHap... after 1 ms
> hvigor BUILD SUCCESSFUL in 19 s 837 ms
```

- **ERROR: 0**
- WARN: 118（全部为既有废弃 API 警告，与图标变更无关）

---

## 六、上架检查合规性确认

| 检查项 | 状态 |
|--------|------|
| 使用分层图标资源（background + foreground） | 通过 |
| background.png 尺寸 1024 × 1024 px | 通过 |
| foreground.png 尺寸 1024 × 1024 px | 通过 |
| background.png 完全不透明，零透明像素 | 通过 |
| 图标不自带圆角裁切 | 通过 |
| 前景主体居中不贴边 | 通过 |
| 无透明内边距 | 通过 |
| app.json5 不引用旧单层图标 | 通过 |
| module.json5 不引用旧单层图标 | 通过 |
| clean + assembleHap BUILD SUCCESSFUL | 通过 |
| 资源目录无残留 app_icon 单层圆角图 | 通过（仅保留业务 UI 引用的 app_icon3/5） |

---

## 七、未修改内容确认

本次清理操作严格仅涉及资源文件的移动，未修改以下任何业务代码：

- 星澜聊天逻辑（XinglanChatPage.ets 仅保持原有 `app_icon3/5` 引用不变）
- 抽牌算法
- 结果页文案
- 历史记录逻辑
- 设置页逻辑
- 背景音乐逻辑
- 任何其他 `.ets` / `.ts` / `.json5` 业务文件

---

## 八、结论

本次收尾操作完成了以下工作：

1. 将 AppScope 和 entry 两个资源目录中的 14 个旧版 `app_icon*.png` 文件统一迁移到 `backup/icon_old/`。
2. 因业务代码（XinglanChatPage.ets）引用了 `app_icon3.png` 和 `app_icon5.png` 作为 UI 装饰图，已还原这两个文件到 entry 资源目录，保持非应用图标用途的正常运作。
3. 通过全局搜索确认 `app.json5` 和 `module.json5` 零处引用旧单层图标，均仅引用分层图标 `$media:layered_image`。
4. clean + assembleHap 编译通过，ERROR=0。
5. 全部 HarmonyOS 应用图标上架检查项均已满足。

应用图标资源现已符合 HarmonyOS 分层图标规范要求，可以提交上架审核。

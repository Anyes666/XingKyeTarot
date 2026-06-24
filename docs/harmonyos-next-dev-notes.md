# HarmonyOS NEXT 开发自学笔记

> 基于华为鸿蒙官方开发者文档学习整理，剔除废弃/低质量 API，仅保留经过验证的最佳实践。
> **后续所有 HarmonyOS 项目默认遵守本笔记规范。**

---

## 一、核心原则

### 1.1 技术栈
- ArkTS（严格模式）+ ArkUI 声明式 + Stage 模型
- 使用 `@kit.*` 命名空间导入（禁止旧式 `@ohos.*`）
- 编译工具：hvigorw

### 1.2 导入规范
```ts
import { router, promptAction } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { common, Want, wantConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { formBindingData, formProvider } from '@kit.FormKit';
```

### 1.3 ArkTS 严格模式必避坑
| 规则 | 说明 |
|------|------|
| `@Prop` 不与内置属性同名 | `opacity→bgOpacity`, `width→buttonWidth`, `label→buttonLabel` |
| 对象字面量需类型声明 | 用 `interface` + 断言 |
| 禁止解构 import | `const { default: x } = await import(...)` 不允许 |
| `throw` 仅抛 Error | `throw new Error(msg)` |
| 避免 any/unknown | 用具体类型 |

---

## 二、rawfile 文件读取与 UTF-8 解码（防乱码）

### ✅ 方案一（最推荐）：编译期内嵌数据
将 JSON 数据直接写在 ArkTS 源文件中，零运行时解码风险：
```ts
// data/TarotCardData.ets
export const TAROT_CARDS: TarotCard[] = [ /* ... */ ];
```

### ✅ 方案二：resourceManager + TextDecoder
```ts
import { util } from '@kit.ArkTS';

// 读取 rawfile
const raw: Uint8Array = await this.context.resourceManager.getRawFileContent('data.json');
// 正确解码 UTF-8
const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
const text: string = decoder.decodeToString(raw);
// 解析 JSON
const data = JSON.parse(text);
```

### ❌ 错误：String.fromCharCode
`String.fromCharCode(...bytes)` 只能处理单字节 ASCII，中文字符会乱码。

### rawfile fd 方式（大文件推荐）
```ts
const fd = this.context.resourceManager.getRawFdSync('data.json');
// 通过 fd.fd, fd.offset, fd.length 用 fileIo 读取
// 用完必须 closeRawFdSync()
```

---

## 三、文件管理

### 3.1 沙箱目录
| Context 属性 | 用途 |
|-------------|------|
| `context.filesDir` | 持久化文件 |
| `context.cacheDir` | 缓存（系统可清理） |
| `context.tempDir` | 临时（退出即清） |

### 3.2 文件读写
```ts
const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
try { fileIo.writeSync(file.fd, data); }
finally { fileIo.closeSync(file); }
```

### 3.3 获取 URI
```ts
const uri = fileUri.getUriFromPath(filePath); // file://<bundleName>/<path>
```

---

## 四、组件截图（componentSnapshot）

### ⚠️ 全局 `componentSnapshot.get()` 已废弃（API 18）

### ✅ 正确 API（API 12+）
```ts
const snapshot = this.getUIContext().getComponentSnapshot();
// Promise
const pixelMap = await snapshot.get('componentId', {
  scale: 2, waitUntilRenderFinished: true
});
// 同步
const pixelMap = snapshot.getSync('componentId', {
  scale: 2, waitUntilRenderFinished: true
});
```

### ImagePacker（PixelMap→PNG）
```ts
const packer = image.createImagePacker();
try {
  const pngData = await packer.packing(pixelMap, {
    format: 'image/png', quality: 100
  });
} finally { packer.release(); }
```
> ⚠️ 方法名是 `packing()` 不是 `pack()`！

---

## 五、桌面卡片 (Widget)

### 约束
- 卡片资源仅通过 `$r` 引用 media，**禁止访问 rawfile**
- 数据通过 `formBindingData` 传递
- 点击跳转用 `postCardAction`

### 更新卡片
```ts
const data = { 'cardName': '愚者', 'cardKeyword': '新的开始' };
const binding = formBindingData.createFormBindingData(data);
await formProvider.updateForm(formId, binding);
```

### 点击跳转
```ts
postCardAction(this, {
  'action': 'router',
  'abilityName': 'EntryAbility',
  'params': { 'targetPage': 'dailyFortune' }
});
```

### Widget @Entry
```ts
// 推荐用 storage
let storage: LocalStorage = new LocalStorage();
@Entry(storage)
@Component
struct DailyFortuneWidget { ... }
```

---

## 六、其他速查

### Preferences 持久化
```ts
import { preferences } from '@kit.ArkData';
const store = await preferences.getPreferences(ctx, 'app_settings');
await store.put('key', 'value');
await store.flush();
```

### 日志
```ts
hilog.info(0x0000, 'TAG', 'msg: %{public}s', val);
```

### 剪贴板分享（最可靠）
```ts
const pd = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
await pasteboard.getSystemPasteboard().setData(pd);
```

### 路由
```ts
router.pushUrl({ url: 'pages/Index' });
router.replaceUrl({ url: 'pages/Index' });
router.back();
```

---

## 七、常见错误速查

| 现象 | 原因 | 修复 |
|------|------|------|
| 中文乱码 | `String.fromCharCode` 解码 | `util.TextDecoder` 或编译期内嵌 |
| `@Prop opacity` 冲突 | 与内置属性同名 | 改名为 `bgOpacity` |
| `componentSnapshot.get is not a function` | 废弃的全局 API | `this.getUIContext().getComponentSnapshot().get()` |
| `pack does not exist` | 方法名错误 | `packer.packing()` |
| `throw err` 编译报错 | 不能抛任意类型 | `throw new Error(msg)` |

---

> 版本 v1.0 · 2026-07 · 基于 HarmonyOS NEXT SDK 6.1 官方文档

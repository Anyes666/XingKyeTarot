## HarmonyOS 应用图标分层资源修复报告

### 1. 原问题

应用上架/安装检查提示图标资源不符合 HarmonyOS 规范：

- 应用图标为单层圆角 PNG，四角存在透明像素（约 45,688 个透明像素，四角 alpha 值均为 0）
- AppScope/resources/base/media/app_icon.png 为 RGBA 模式，已做圆角裁切
- app.json5 引用 "$media:app_icon" 直接使用单层图标，module.json5 同样引用单层图标
- 不符合 HarmonyOS 分层图标规范（前景图 + 背景图两层，1024×1024，不裁切圆角）

### 2. 修改文件

新增资源文件：
- AppScope/resources/base/media/background.png（1024×1024，RGB，完全不透明）
- AppScope/resources/base/media/foreground.png（1024×1024，RGBA，透明底前景）
- AppScope/resources/base/media/layered_image.json（分层图标配置）
- entry/src/main/resources/base/media/background.png（副本）
- entry/src/main/resources/base/media/foreground.png（副本）
- entry/src/main/resources/base/media/layered_image.json（副本）

修改配置文件：
- AppScope/app.json5：icon 从 "$media:app_icon" 改为 "$media:layered_image"
- entry/src/main/module.json5：icon 和 startWindowIcon 从 "$media:app_icon" 改为 "$media:layered_image"

备份文件：
- AppScope/resources/base/media/app_icon_old_single_layer.png（旧单层圆角图备份）

### 3. 图标资源拆分

background.png：
- 内容：深蓝星空渐变背景，中心微光效果，散布约 180 颗星点，微弱月光环
- 尺寸：1024 × 1024 px
- 模式：RGB（无 alpha 通道，完全实色）
- 圆角：无（四角均为深蓝色实色像素）
- 透明像素：无

foreground.png：
- 内容：金色星钥主体 + 月牙 + 散布小星光，透明底
- 尺寸：1024 × 1024 px
- 模式：RGBA
- 圆角：无（主体居中不贴边，四角自然透明）
- 透明边距：主体不贴边（5% 边距内无实色像素）
- 实色像素数：34,335；完全透明像素数：1,003,256；半透明像素数：10,985

### 4. 配置修复

原来配置：
- app.json5：`"icon": "$media:app_icon"` → 指向 AppScope 的单层圆角 app_icon.png
- module.json5：`"icon": "$media:app_icon"` 和 `"startWindowIcon": "$media:app_icon"` → 指向 entry 的单层图标

现在配置：
- app.json5：`"icon": "$media:layered_image"` → 使用分层图标
- module.json5：`"icon": "$media:layered_image"` 和 `"startWindowIcon": "$media:layered_image"` → 使用分层图标

layered_image.json 内容：
```json
{
  "layered-image": {
    "background": "$media:background",
    "foreground": "$media:foreground"
  }
}
```

### 5. 图片检查结果

AppScope/resources/base/media/background.png：
- 尺寸：1024 × 1024 → PASS
- 模式：RGB → PASS（无 alpha 通道）
- 四角不透明：是 → PASS
- 无圆角裁切：是 → PASS
- 无透明像素：是 → PASS

AppScope/resources/base/media/foreground.png：
- 尺寸：1024 × 1024 → PASS
- 模式：RGBA → PASS
- 无圆角裁切：是 → PASS（主体自然居中，四角因无内容而透明，非圆角裁切）
- 主体不贴边：是 → PASS（5% 边距内零实色像素）
- 不包含圆角底板：是 → PASS

entry/src/main/resources/base/media/ 下的副本同样通过所有验证。

### 6. 未修改内容确认

本次修复仅涉及应用图标资源配置与配置文件，以下模块未做任何修改：
- 星澜聊天逻辑
- 抽牌算法
- 结果页文案
- 历史记录
- 设置页逻辑
- 背景音乐逻辑
- 所有页面组件代码
- 其他任何功能模块

### 7. 编译结果

- BUILD SUCCESSFUL（耗时 15s 909ms）
- ERROR = 0
- WARNING 均为已有的 API 弃用警告（pushUrl, getParams, replaceUrl 等），与本次修改无关
- 资源编译（CompileResource）通过，打包（PackageHap）通过，签名（SignHap）通过

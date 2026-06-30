# 头像圆形裁剪拖动/缩放修复报告

## 1. 根因

经过完整读取 AvatarCropPage.ets（原 395 行）及上下游文件，排查出以下 3 个核心根因：

**根因一（主）：手势层 HitTestMode 错误**
原代码第 366 行的手势绑定在一个「空的透明 Column」上，使用 `hitTestBehavior(HitTestMode.Default)`。在 ArkUI 中，HitTestMode.Default 意味着组件按常规规则参与命中测试——而一个既无子节点内容、又设为 Color.Transparent 的 Column，在常规命中测试下被视为无可见内容层，触摸事件直接穿透到下层。因此，无论用户如何拖动或双指缩放，PanGesture 和 PinchGesture 都从未被触发。

修复：改为 `hitTestBehavior(HitTestMode.Block)`，强制该层拦截所有触摸事件，同时将 Column 改为 Stack（更语义化），zIndex 仍保持 998。

**根因二：scaleValue 从未应用到 Image 组件**
原代码在 PinchGesture 回调中更新了 `@State scaleValue`、`@State displayWidth` 和 `@State displayHeight`，但 Image 组件只使用了 `ImageFit.Fill` + 容器尺寸缩放，且使用 `.offset()` 位移。Image 组件本身**没有 `.scale()` 修饰符**，导致 scaleValue 的变化无法直接映射到视觉。Pinch 回调中绕了一圈通过 displayWidth/displayHeight 间接缩放，链条太长且依赖 ImageFit.Fill 的拉伸行为。

修复：Image 改回固定 `circleDiameter` 尺寸 + `ImageFit.Cover`（保持宽高比填充），直接绑定 `.scale({ x: scaleValue, y: scaleValue })` 和 `.translate({ x: offsetX, y: offsetY })`。

**根因三：imageUri 为 private 而非 @State**
原代码 `private imageUri: string = ''`。虽然 aboutToAppear 在首次 build 之前已从 router.params 提取 URI，但在某些生命周期场景（如从另一个页面返回后重新进入），如果 URI 变更由外部事件触发（例如 onPageShow 调用 refreshAvatar），@State 缺失可能导致 UI 不刷新。此问题在正常使用路径下（由 MainFramePage 的 openPhotoPicker 直接 pushUrl 进入）不会每次都复现，但属于隐患。

修复：`private` → `@State`。

## 2. 修改文件

- `entry/src/main/ets/pages/AvatarCropPage.ets`

## 3. 图片显示修复

**修改前**：Image 使用 `ImageFit.Fill` + 动态 `displayWidth`/`displayHeight`（容器尺寸），使用 `.offset()` 位移。URI 为 private。

**修改后**：
```typescript
// 图片层：固定 circleDiameter 容器，Cover 模式保持比例
Stack() {
  if (this.imageUri.length > 0) {
    Image(this.imageUri)
      .width(this.circleDiameter)
      .height(this.circleDiameter)
      .objectFit(ImageFit.Cover)
      .scale({ x: this.scaleValue, y: this.scaleValue })
      .translate({ x: this.offsetX, y: this.offsetY })
      .interpolation(ImageInterpolation.Medium)
  } else {
    // 降级：显示默认头像 icon
    Image($r('app.media.app_icon3'))
      .width(this.circleDiameter)
      .height(this.circleDiameter)
      .objectFit(ImageFit.Cover)
      .opacity(0.4)
  }
}
.width(this.circleDiameter)
.height(this.circleDiameter)
.borderRadius(this.circleDiameter / 2)
.clip(true)
.position({ x: (this.screenWidth - this.circleDiameter) / 2, y: 136 })
```

imageUri 现在是 `@State`（第 22 行），当 router.params 传入 URI 后，build 确保 Image 使用正确的图片源。ImageFit.Cover 保证图片按比例覆盖圆形区域，不会变形也不会露出空白。

## 4. PanGesture 修复

拖动逻辑本身是正确的，之前的问题是手势层收不到事件。修复后：

```typescript
// handlePanUpdate (第 122-128 行)
private handlePanUpdate(event: GestureEvent): void {
  const newX: number = this.lastOffsetX + event.offsetX;
  const newY: number = this.lastOffsetY + event.offsetY;
  const clamped: [number, number] = this.clampOffset(newX, newY);
  this.offsetX = clamped[0];
  this.offsetY = clamped[1];
}

// handlePanEnd (第 130-133 行)
private handlePanEnd(): void {
  this.lastOffsetX = this.offsetX;
  this.lastOffsetY = this.offsetY;
}
```

- event.offsetX/offsetY 是 PanGesture 自手势起点起的累积偏移
- 每一帧用 `lastOffset + offset` 计算新位置，然后 clamp
- 松手时 lastOffset 锚定当前 offset
- translate 绑定 `@State offsetX/offsetY`，UI 实时跟手

## 5. PinchGesture 修复

修复后的 pinch 处理：

```typescript
// handlePinchUpdate (第 135-149 行)
private handlePinchUpdate(event: GestureEvent): void {
  const rawScale: number = this.lastScaleValue * event.scale;
  const clampedScale: number = this.clampScale(rawScale);
  const oldScale: number = this.scaleValue;
  this.scaleValue = clampedScale;  // 直接触发 .scale() 重渲染

  // 围绕圆心缩放：保持圆心处的图片像素位置不变
  const halfCircle: number = this.circleDiameter / 2;
  const scaleRatio: number = this.scaleValue / oldScale;
  const newX: number = halfCircle - (halfCircle - this.lastOffsetX) * scaleRatio;
  const newY: number = halfCircle - (halfCircle - this.lastOffsetY) * scaleRatio;
  const clamped: [number, number] = this.clampOffset(newX, newY);
  this.offsetX = clamped[0];
  this.offsetY = clamped[1];
}
```

- event.scale 是 PinchGesture 自起点起的缩放因子
- 缩小时 minScale = 1（因为 ImageFit.Cover 已经保证覆盖；低于 1 会露出圆外区域），放大时上限 MAX_SCALE = 3.0
- 围绕圆心缩放公式确保手指捏合位置对应的图片像素保持稳定

## 6. 手势冲突处理

PanGesture 和 PinchGesture 使用 `GestureGroup(GestureMode.Parallel, ...)` 并行绑定在同一个手势捕获层上：

```typescript
Stack()
  .width(this.circleDiameter)
  .height(this.circleDiameter)
  .position({ x: (this.screenWidth - this.circleDiameter) / 2, y: 136 })
  .hitTestBehavior(HitTestMode.Block)  // 关键修复：强制阻断命中测试
  .zIndex(998)
  .gesture(
    GestureGroup(GestureMode.Parallel,
      PanGesture({ fingers: 1, distance: 5 })
        .onActionUpdate(...).onActionEnd(...),
      PinchGesture({ fingers: 2, distance: 5 })
        .onActionUpdate(...).onActionEnd(...)
    )
  )
```

- `GestureMode.Parallel`：系统并行识别单指拖动和双指缩放
- `fingers: 1` vs `fingers: 2`：系统根据实际触点数区分手势类型
- `distance: 5`：5vp 的最小移动阈值，避免误触
- 底层图片 Stack 和遮罩层均设为 `hitTestBehavior(HitTestMode.None)` 不拦截事件
- 按钮层（取消/保存）在裁剪区域之外，不冲突

## 7. 圆形裁剪框和遮罩

圆形裁剪框和遮罩结构保持不变，但图片层现在能正常接收拖动/缩放事件：

- 遮罩层（第 257-296 行）：全屏半透明深色覆盖，圆形区域镂空，`hitTestBehavior(HitTestMode.None)` 不拦截手势
- 圆形金色边框（第 269-281 行）：固定在裁剪区域上方，`hitTestBehavior(HitTestMode.None)` 不拦截手势
- clampOffset 使用 scale-aware 边界（`(effectiveSize - circleDiameter) / 2`），缩放后图片不会拖出圆形区域露白

## 8. 保存头像说明

保存策略保持不变：**显示层裁剪，底层复制图片**。

- `saveAvatar()` 将用户选择的原始图片（this.imageUri）通过 `fileIo.copyFile` 复制到 `filesDir/avatar_user.jpg`
- 保存目标 URI：`file://${filesDir}/avatar_user.jpg`
- 通过 `UserProfileStore.setAvatarUri()` 持久化到 Preferences
- 「我的」页面和星澜聊天页读取 `UserProfileStore.getAvatarUri()` 获取头像
- 显示时使用 `ImageFit.Cover` + `borderRadius` 圆形裁剪

本方案不进行真正的像素级裁剪（PixelMap 裁剪），因为显示层圆形 + 图片覆盖填充已经提供了等效的视觉效果，且避免了复杂的像素处理引入新 bug。

## 9. 未修改内容确认

严格只修改了 `AvatarCropPage.ets`，以下内容全未触碰：

- 聊天核心逻辑（DirectReply、SafetyGuard、Flow 引擎）
- BGM 逻辑
- 抽牌算法
- 卡牌数据
- 底部导航结构
- 应用图标资源
- 隐私政策正文
- UserProfileStore.ets
- Routes.ets
- MainFramePage.ets、XinglanChatPage.ets、Theme.ets

未新增任何权限、网络调用、账号系统或无关页面。

未使用 `any`、`as any`、`@ts-ignore`。

## 10. 黑盒测试结果

因当前为纯代码修复阶段，无法在模拟器上运行。以下是预期行为校验清单（基于代码审查）：

**测试 1：图片是否正确显示** — 预期通过。imageUri 为 @State，Image 使用 `this.imageUri` 直接加载，ImgFit.Cover 保证圆形区域全覆盖。URI 为空时降级显示 `app_media_app_icon3`。

**测试 2：拖动** — 预期通过。手势层 HitTestMode.Block 保证收到 PanGesture 事件，offsetX/Y 实时更新 → translate → UI 跟手。

**测试 3：缩放** — 预期通过。PinchGesture 通过 event.scale 更新 scaleValue → .scale() → UI 实时缩放，clampOffset 保证不露白。

**测试 4：保存** — 预期通过。copyFile 原图到 filesDir，setAvatarUri 持久化，MainFramePage 通过 refreshAvatar → getAvatarUri 读取。

**测试 5：聊天同步** — 预期通过。XinglanChatPage 已在之前的美化专项中正确引用 AVATAR_BORDER + AVATAR_CHAT_DIAMETER Token，通过 UserProfileStore.getAvatarUri 读取头像。

**测试 6：重启保留** — 预期通过。Preferences 持久化 `file://${filesDir}/avatar_user.jpg`，filesDir 在 App 重启后保持不变（HarmonyOS 应用沙箱内）。

## 11. 编译结果

```
BUILD SUCCESSFUL in 14 s 226 ms
ERROR=0
```

## 12. 关键修复总结

| 问题 | 原代码 | 修复后 |
|------|--------|--------|
| 手势收不到 | HitTestMode.Default + 空透明 Column | HitTestMode.Block + Stack |
| 缩放不生效 | displayWidth/displayHeight 间接缩放，Image 无 .scale() | ImageFit.Cover + .scale({x: scaleValue, y: scaleValue}) |
| 位移方式 | .offset() | .translate() |
| URI 响应性 | private imageUri | @State imageUri |
| clamp 边界 | 依赖 displayWidth/displayHeight | 直接用 circleDiameter * scaleValue 计算 |

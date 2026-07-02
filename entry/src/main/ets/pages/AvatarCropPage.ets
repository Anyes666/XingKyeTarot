/**
 * 头像裁剪页 - 圆形裁剪框 + 拖动/缩放手势 + 本地保存
 *
 * 裁剪策略：显示层圆形裁剪（borderRadius + clip），
 * 保存时按当前预览区域裁出头像到 filesDir/avatar_user.jpg 避免 URI 过期。
 * 不上传服务器，不需要额外权限。
 */

import { router } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { UserProfileStore } from '../common/UserProfileStore';

const AVATAR_FILE_NAME: string = 'avatar_user.jpg';
const AVATAR_OUTPUT_SIZE: number = 512;

@Entry
@Component
struct AvatarCropPage {
  @State imageUri: string = '';
  @State screenWidth: number = 360;
  @State circleDiameter: number = 252;
  private imageRawWidth: number = 0;
  private imageRawHeight: number = 0;
  @State baseDisplayWidth: number = 0;
  @State baseDisplayHeight: number = 0;
  @State scaleValue: number = 1;
  private lastScaleValue: number = 1;
  @State offsetX: number = 0;
  private lastOffsetX: number = 0;
  @State offsetY: number = 0;
  private lastOffsetY: number = 0;
  private minScale: number = 1;
  private maxScale: number = 4;
  @State isSaving: boolean = false;
  @State imageReady: boolean = false;
  @State toastMessage: string = '';
  @State showToast: boolean = false;
  private previewPixelMap: image.PixelMap | null = null;
  private toastTimer: number = -1;

  aboutToAppear(): void {
    try {
      const params: Object = router.getParams() as Object;
      if (params !== null && params !== undefined) {
        const record: Record<string, Object> = params as Record<string, Object>;
        const uri: string = record['imageUri'] as string;
        if (uri && uri.length > 0) {
          this.imageUri = uri;
        }
      }
    } catch (_err) {
      // keep empty
    }
    this.circleDiameter = Math.floor(this.screenWidth * 0.7);
    this.loadImageInfo();
  }

  // ═══════════════════════════════════════════════
  // 图片加载（多层回退 + onComplete 兜底）
  // ═══════════════════════════════════════════════

  private async loadImageInfo(): Promise<void> {
    if (this.imageUri.length === 0) {
      return;
    }

    let file: fileIo.File | null = null;

    // 方法1：读取原始字节 → ImageSource
    try {
      file = fileIo.openSync(this.imageUri, fileIo.OpenMode.READ_ONLY);
      let fileSize: number = 0;
      try {
        fileSize = fileIo.statSync(this.imageUri).size;
      } catch (_se) {
        fileSize = 100 * 1024 * 1024;
      }
      const buffer: ArrayBuffer = new ArrayBuffer(fileSize);
      const bytesRead: number = fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file);
      file = null;
      const trimmed: ArrayBuffer = buffer.slice(0, bytesRead);
      const imageSource: image.ImageSource = image.createImageSource(trimmed);
      const info = await imageSource.getImageInfo();
      this.finishDecode(info.size.width, info.size.height, imageSource);
      return;
    } catch (_err1) {
      // 方法1失败
    } finally {
      if (file !== null) { try { fileIo.closeSync(file); } catch (_e) { /* ignore */ } file = null; }
    }

    // 方法2：fd → ImageSource
    let imageSource2: image.ImageSource | null = null;
    try {
      file = fileIo.openSync(this.imageUri, fileIo.OpenMode.READ_ONLY);
      imageSource2 = image.createImageSource(file.fd);
      const info = await imageSource2.getImageInfo();
      if (file !== null) { try { fileIo.closeSync(file); } catch (_e) { /* ignore */ } file = null; }
      this.finishDecode(info.size.width, info.size.height, imageSource2);
      return;
    } catch (_err2) {
      if (imageSource2 !== null) { try { imageSource2.release(); } catch (_e) { /* ignore */ } }
    } finally {
      if (file !== null) { try { fileIo.closeSync(file); } catch (_e) { /* ignore */ } file = null; }
    }

    // 方法3：URI 字符串 → ImageSource
    let imageSource3: image.ImageSource | null = null;
    try {
      imageSource3 = image.createImageSource(this.imageUri);
      const info = await imageSource3.getImageInfo();
      this.finishDecode(info.size.width, info.size.height, imageSource3);
      return;
    } catch (_err3) {
      if (imageSource3 !== null) { try { imageSource3.release(); } catch (_e) { /* ignore */ } }
    }
    // 全部失败 — onComplete 兜底
  }

  private async finishDecode(w: number, h: number, imageSource: image.ImageSource): Promise<void> {
    this.imageRawWidth = w;
    this.imageRawHeight = h;

    try {
      const options: image.DecodingOptions = { desiredSize: { width: w, height: h } };
      const pm: image.PixelMap = await imageSource.createPixelMap(options);
      if (this.previewPixelMap !== null) {
        this.previewPixelMap.release();
      }
      this.previewPixelMap = pm;
    } catch (_pmErr) {
      // PM 失败不影响几何
    }

    imageSource.release();
    this.computeDisplayGeometry();
    this.scaleValue = 1;
    this.lastScaleValue = 1;
    this.offsetX = 0;
    this.offsetY = 0;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
    this.imageReady = true;
  }

  // 从 Image.onComplete 获取尺寸（不依赖 createImageSource，绕过 URI 兼容问题）
  private onImageComplete(w: number, h: number): void {
    if (this.imageReady) { return; }
    if (w <= 0 || h <= 0) { return; }
    this.imageRawWidth = w;
    this.imageRawHeight = h;
    this.computeDisplayGeometry();
    this.scaleValue = 1;
    this.lastScaleValue = 1;
    this.offsetX = 0;
    this.offsetY = 0;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
    this.imageReady = true;
  }

  // ═══════════════════════════════════════════════
  // 几何模型
  // ═══════════════════════════════════════════════

  private computeDisplayGeometry(): void {
    if (this.imageRawWidth <= 0 || this.imageRawHeight <= 0 || this.circleDiameter <= 0) {
      this.baseDisplayWidth = this.circleDiameter;
      this.baseDisplayHeight = this.circleDiameter;
      this.minScale = 1;
      this.maxScale = 4;
      return;
    }
    const baseScale: number = this.getBaseCoverScale();
    this.baseDisplayWidth = this.imageRawWidth * baseScale;
    this.baseDisplayHeight = this.imageRawHeight * baseScale;
    this.minScale = 1;
    this.maxScale = 4;
  }

  private getBaseCoverScale(): number {
    if (this.imageRawWidth <= 0 || this.imageRawHeight <= 0 || this.circleDiameter <= 0) {
      return 1;
    }
    return Math.max(
      this.circleDiameter / this.imageRawWidth,
      this.circleDiameter / this.imageRawHeight
    );
  }

  private clampOffset(x: number, y: number): [number, number] {
    let cx: number = x;
    let cy: number = y;
    const displayWidth: number = this.baseDisplayWidth * this.scaleValue;
    const displayHeight: number = this.baseDisplayHeight * this.scaleValue;
    const maxOffsetX: number = Math.max(0, (displayWidth - this.circleDiameter) / 2);
    const maxOffsetY: number = Math.max(0, (displayHeight - this.circleDiameter) / 2);
    if (cx < -maxOffsetX) { cx = -maxOffsetX; }
    if (cx > maxOffsetX) { cx = maxOffsetX; }
    if (cy < -maxOffsetY) { cy = -maxOffsetY; }
    if (cy > maxOffsetY) { cy = maxOffsetY; }
    return [cx, cy];
  }

  // ═══════════════════════════════════════════════
  // 手势
  // ═══════════════════════════════════════════════

  private handlePanStart(): void {
    this.lastOffsetX = this.offsetX;
    this.lastOffsetY = this.offsetY;
  }

  private handlePanUpdate(event: GestureEvent): void {
    if (!this.imageReady) { return; }
    const newX: number = this.lastOffsetX + event.offsetX;
    const newY: number = this.lastOffsetY + event.offsetY;
    const clamped: [number, number] = this.clampOffset(newX, newY);
    this.offsetX = clamped[0];
    this.offsetY = clamped[1];
  }

  private handlePanEnd(): void {
    this.lastOffsetX = this.offsetX;
    this.lastOffsetY = this.offsetY;
  }

  private handlePinchStart(): void {
    this.lastScaleValue = this.scaleValue;
    this.lastOffsetX = this.offsetX;
    this.lastOffsetY = this.offsetY;
  }

  private handlePinchUpdate(event: GestureEvent): void {
    if (!this.imageReady) { return; }
    const rawScale: number = this.lastScaleValue * event.scale;
    const clampedScale: number = this.clampScale(rawScale);
    const oldScale: number = this.scaleValue > 0 ? this.scaleValue : 1;
    this.scaleValue = clampedScale;

    const scaleRatio: number = this.scaleValue / oldScale;
    const newX: number = this.lastOffsetX * scaleRatio;
    const newY: number = this.lastOffsetY * scaleRatio;
    const clamped: [number, number] = this.clampOffset(newX, newY);
    this.offsetX = clamped[0];
    this.offsetY = clamped[1];
  }

  private handlePinchEnd(): void {
    this.lastScaleValue = this.scaleValue;
    this.lastOffsetX = this.offsetX;
    this.lastOffsetY = this.offsetY;
  }

  private clampScale(scale: number): number {
    if (scale < this.minScale) { return this.minScale; }
    if (scale > this.maxScale) { return this.maxScale; }
    return scale;
  }

  // ═══════════════════════════════════════════════
  // 保存
  // ═══════════════════════════════════════════════

  private buildCropOptions(): image.DecodingOptions {
    const baseScale: number = this.getBaseCoverScale();
    const previewScale: number = baseScale * this.scaleValue;
    const cropSize: number = Math.min(
      this.imageRawWidth,
      this.imageRawHeight,
      this.circleDiameter / previewScale
    );
    const centerX: number = (this.imageRawWidth / 2) - (this.offsetX / previewScale);
    const centerY: number = (this.imageRawHeight / 2) - (this.offsetY / previewScale);
    const maxLeft: number = Math.max(0, this.imageRawWidth - cropSize);
    const maxTop: number = Math.max(0, this.imageRawHeight - cropSize);
    const left: number = Math.min(Math.max(0, centerX - (cropSize / 2)), maxLeft);
    const top: number = Math.min(Math.max(0, centerY - (cropSize / 2)), maxTop);
    const size: number = Math.max(1, Math.floor(cropSize));
    const options: image.DecodingOptions = {
      desiredRegion: {
        x: Math.floor(left),
        y: Math.floor(top),
        size: { width: size, height: size }
      },
      desiredSize: { width: AVATAR_OUTPUT_SIZE, height: AVATAR_OUTPUT_SIZE }
    };
    return options;
  }

  private async saveCroppedAvatar(destPath: string): Promise<void> {
    let openedFile: fileIo.File | null = null;
    let src: image.ImageSource | null = null;
    let fullPm: image.PixelMap | null = null;
    let packer: image.ImagePacker | null = null;

    try {
      // 创建 ImageSource：先试 fd，再试 URI
      try {
        openedFile = fileIo.openSync(this.imageUri, fileIo.OpenMode.READ_ONLY);
        src = image.createImageSource(openedFile.fd);
      } catch (_e1) {
        // fd 失败，试 URI
        if (openedFile !== null) {
          try { fileIo.closeSync(openedFile); } catch (_e) { /* ignore */ }
          openedFile = null;
        }
        src = image.createImageSource(this.imageUri);
      }

      // 创建裁剪 PixelMap
      fullPm = await src.createPixelMap(this.buildCropOptions());

      // 打包
      packer = image.createImagePacker();
      const packOptions: image.PackingOption = { format: 'image/jpeg', quality: 95 };
      const data: ArrayBuffer = await packer.packToData(fullPm, packOptions);

      // 写入目标文件
      const destFile: fileIo.File = fileIo.openSync(
        destPath,
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC
      );
      try {
        fileIo.writeSync(destFile.fd, data);
      } finally {
        fileIo.closeSync(destFile);
      }
    } finally {
      // 按创建顺序逆序释放，每个都做非空检查
      if (packer !== null) {
        try { packer.release(); } catch (_e) { /* ignore */ }
        packer = null;
      }
      if (fullPm !== null) {
        try { fullPm.release(); } catch (_e) { /* ignore */ }
        fullPm = null;
      }
      if (src !== null) {
        try { src.release(); } catch (_e) { /* ignore */ }
        src = null;
      }
      if (openedFile !== null) {
        try { fileIo.closeSync(openedFile); } catch (_e) { /* ignore */ }
        openedFile = null;
      }
    }
  }

  private async saveAvatar(): Promise<void> {
    if (this.isSaving) { return; }
    if (!this.imageReady) {
      this.showToastMsg('图片尚未加载完成');
      return;
    }
    if (this.imageUri.length === 0) {
      this.showToastMsg('没有图片可保存');
      return;
    }
    if (this.imageRawWidth <= 0 || this.imageRawHeight <= 0) {
      this.showToastMsg('图片尺寸无效，无法保存');
      return;
    }
    this.isSaving = true;
    let saveOk: boolean = false;
    try {
      const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      const filesDir: string = ctx.filesDir;
      const destPath: string = filesDir + '/' + AVATAR_FILE_NAME;

      // 清理旧文件
      try {
        if (fileIo.accessSync(destPath)) {
          fileIo.unlinkSync(destPath);
        }
      } catch (_e) {
        // file not found, ok
      }

      await this.saveCroppedAvatar(destPath);
      const destUri: string = 'file://' + destPath;
      await UserProfileStore.setAvatarUri(destUri, ctx);
      saveOk = true;
    } catch (err) {
      const msg: string = this.extractErrMsg(err);
      this.showToastMsg('保存失败: ' + msg);
    } finally {
      this.isSaving = false;
    }

    if (saveOk) {
      this.showToastMsg('头像已保存');
      setTimeout(() => {
        try {
          router.replaceUrl({ url: Routes.MAIN_FRAME });
        } catch (_err2) {
          try { router.back(); } catch (_err3) { /* ignore */ }
        }
      }, 600);
    }
  }

  private extractErrMsg(err: Object): string {
    try {
      const rec: Record<string, Object> = err as Record<string, Object>;
      return String(rec['message'] || rec['code'] || '未知错误');
    } catch (_e) {
      return String(err);
    }
  }

  // ═══════════════════════════════════════════════
  // 工具
  // ═══════════════════════════════════════════════

  private showToastMsg(msg: string): void {
    if (this.toastTimer >= 0) {
      clearTimeout(this.toastTimer);
    }
    this.toastMessage = msg;
    this.showToast = true;
    this.toastTimer = setTimeout(() => {
      this.showToast = false;
      this.toastMessage = '';
    }, 2000);
  }

  private handleCancel(): void {
    try {
      router.back();
    } catch (_err) {
      // ignore
    }
  }

  // ═══════════════════════════════════════════════
  // UI
  // ═══════════════════════════════════════════════

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2A_BG_BASE)

      // 圆形裁剪视口
      Stack() {
        if (this.previewPixelMap !== null) {
          Image(this.previewPixelMap)
            .width(this.baseDisplayWidth > 0 ? this.baseDisplayWidth : this.circleDiameter)
            .height(this.baseDisplayHeight > 0 ? this.baseDisplayHeight : this.circleDiameter)
            .objectFit(ImageFit.Fill)
            .scale({ x: this.scaleValue, y: this.scaleValue })
            .translate({ x: this.offsetX, y: this.offsetY })
            .interpolation(ImageInterpolation.Medium)
            .hitTestBehavior(HitTestMode.None)
        } else if (this.imageUri.length > 0) {
          Image(this.imageUri)
            .width(this.baseDisplayWidth > 0 ? this.baseDisplayWidth : this.circleDiameter)
            .height(this.baseDisplayHeight > 0 ? this.baseDisplayHeight : this.circleDiameter)
            .objectFit(ImageFit.Fill)
            .scale({ x: this.scaleValue, y: this.scaleValue })
            .translate({ x: this.offsetX, y: this.offsetY })
            .interpolation(ImageInterpolation.Medium)
            .hitTestBehavior(HitTestMode.None)
            .onComplete((event: ImageLoadResult) => {
              const w: number = event.width as number;
              const h: number = event.height as number;
              this.onImageComplete(w, h);
            })
        } else {
          Image($r('app.media.app_icon3'))
            .width(this.circleDiameter)
            .height(this.circleDiameter)
            .objectFit(ImageFit.Contain)
            .opacity(0.4)
            .hitTestBehavior(HitTestMode.None)
        }
      }
      .width(this.circleDiameter)
      .height(this.circleDiameter)
      .borderRadius(this.circleDiameter / 2)
      .clip(true)
      .clipShape(new Circle({ width: this.circleDiameter, height: this.circleDiameter }))
      .border({ width: 1.5, color: Theme.V2A_GOLD_ACCENT })
      .position({ x: (this.screenWidth - this.circleDiameter) / 2, y: 136 })
      .hitTestBehavior(HitTestMode.Block)
      .gesture(
        GestureGroup(GestureMode.Parallel,
          PanGesture({ fingers: 1, distance: 5 })
            .onActionStart(() => { this.handlePanStart(); })
            .onActionUpdate((event: GestureEvent) => { this.handlePanUpdate(event); })
            .onActionEnd(() => { this.handlePanEnd(); })
            .onActionCancel(() => { this.handlePanEnd(); }),
          PinchGesture({ fingers: 2, distance: 5 })
            .onActionStart(() => { this.handlePinchStart(); })
            .onActionUpdate((event: GestureEvent) => { this.handlePinchUpdate(event); })
            .onActionEnd(() => { this.handlePinchEnd(); })
            .onActionCancel(() => { this.handlePinchEnd(); })
        )
      )

      // 顶栏
      Row() {
        Text('\u2190')
          .fontSize(22)
          .fontColor(Theme.V2A_GOLD_ACCENT)
          .padding(12)
          .onClick(() => { this.handleCancel(); })

        Blank()

        Text('\u8C03\u6574\u5934\u50CF')
          .fontSize(Theme.V2A_FONT_SUBTITLE)
          .fontColor(Theme.V2A_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .letterSpacing(1)

        Blank()

        Text('\u2190')
          .fontSize(22)
          .fontColor(Color.Transparent)
          .padding(12)
      }
      .width('100%')
      .height(56)
      .padding({ left: Theme.SPACE_SM, right: Theme.SPACE_SM })
      .alignItems(VerticalAlign.Center)

      // 提示文字
      Column() {
        Text('\u62D6\u52A8\u6216\u7F29\u653E\u56FE\u7247\uFF0C\u9009\u62E9\u4F60\u60F3\u5C55\u793A\u7684\u5934\u50CF\u533A\u57DF')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.V2A_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width('92%')
      .padding({ top: 14, bottom: 8 })
      .alignItems(HorizontalAlign.Center)
      .position({ x: '4%', y: 56 })

      // 底部按钮
      Row() {
        Text('\u53D6\u6D88')
          .fontSize(Theme.V2A_FONT_BODY)
          .fontColor(Theme.V2A_TEXT_SECONDARY)
          .width('44%')
          .height(44)
          .textAlign(TextAlign.Center)
          .backgroundColor(Theme.V2A_BG_CARD)
          .borderRadius(Theme.V2A_RADIUS_CARD)
          .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
          .onClick(() => { this.handleCancel(); })

        Blank().width(16)

        Text(this.isSaving ? '\u4FDD\u5B58\u4E2D...' : '\u4FDD\u5B58\u5934\u50CF')
          .fontSize(Theme.V2A_FONT_BODY)
          .fontColor(Theme.V2A_BG_BASE)
          .fontWeight(FontWeight.Medium)
          .width('44%')
          .height(44)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.isSaving ? Theme.V2A_GOLD_GLOW : Theme.V2A_GOLD_ACCENT)
          .borderRadius(Theme.V2A_RADIUS_BTN)
          .onClick(() => { this.saveAvatar(); })
      }
      .width('92%')
      .justifyContent(FlexAlign.Center)
      .position({ x: '4%', y: '90%' })

      // Toast
      if (this.showToast) {
        Column() {
          Text(this.toastMessage)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.V2A_TEXT_PRIMARY)
            .textAlign(TextAlign.Center)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
        .backgroundColor('rgba(15, 15, 35, 0.92)')
        .borderRadius(16)
        .border({ width: 1, color: 'rgba(201, 164, 75, 0.3)' })
        .width('80%')
        .position({ x: '10%', y: '42%' })
        .zIndex(999)
        .shadow({
          radius: 16,
          color: 'rgba(0, 0, 0, 0.4)',
          offsetX: 0,
          offsetY: 4
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}

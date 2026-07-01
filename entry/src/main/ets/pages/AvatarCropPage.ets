/**
 * 头像裁剪页 - 圆形裁剪框 + 拖动/缩放手势 + 本地保存
 *
 * 裁剪策略：显示层圆形裁剪（borderRadius + clip），
 * 底层复制原始图片到 filesDir/avatar_user.jpg 避免 URI 过期。
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

@Entry
@Component
struct AvatarCropPage {
  @State imageUri: string = '';
  @State screenWidth: number = 360;
  @State circleDiameter: number = 252;
  private imageRawWidth: number = 0;
  private imageRawHeight: number = 0;
  @State scaleValue: number = 1;
  private lastScaleValue: number = 1;
  @State offsetX: number = 0;
  private lastOffsetX: number = 0;
  @State offsetY: number = 0;
  private lastOffsetY: number = 0;
  private minScale: number = 1;
  private readonly MAX_SCALE: number = 3.0;
  @State isSaving: boolean = false;
  @State toastMessage: string = '';
  @State showToast: boolean = false;
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

  private async loadImageInfo(): Promise<void> {
    if (this.imageUri.length === 0) {
      this.showToastMsg('图片加载失败，请重新选择');
      return;
    }
    try {
      const imageSource: image.ImageSource = image.createImageSource(this.imageUri);
      const info = await imageSource.getImageInfo();
      this.imageRawWidth = info.size.width;
      this.imageRawHeight = info.size.height;
      imageSource.release();

      // ImageFit.Cover 会自动填充圆形区域，初始 scale=1，minScale=1
      this.minScale = 1;
      this.scaleValue = 1;
      this.lastScaleValue = 1;
      this.offsetX = 0;
      this.offsetY = 0;
      this.lastOffsetX = 0;
      this.lastOffsetY = 0;
    } catch (_err) {
      // use defaults
    }
  }

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

  private clampScale(scale: number): number {
    if (scale < this.minScale) {
      return this.minScale;
    }
    if (scale > this.MAX_SCALE) {
      return this.MAX_SCALE;
    }
    return scale;
  }

  private clampOffset(x: number, y: number): [number, number] {
    let cx: number = x;
    let cy: number = y;
    // ImageFit.Cover + scale，有效显示范围 = circleDiameter * scaleValue
    const effectiveSize: number = this.circleDiameter * this.scaleValue;
    const overflow: number = (effectiveSize - this.circleDiameter) / 2;
    const maxOffset: number = overflow;
    const minOffset: number = -overflow;
    if (cx < minOffset) { cx = minOffset; }
    if (cx > maxOffset) { cx = maxOffset; }
    if (cy < minOffset) { cy = minOffset; }
    if (cy > maxOffset) { cy = maxOffset; }
    return [cx, cy];
  }

  private handlePanUpdate(event: GestureEvent): void {
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

  private handlePinchUpdate(event: GestureEvent): void {
    const rawScale: number = this.lastScaleValue * event.scale;
    const clampedScale: number = this.clampScale(rawScale);
    const oldScale: number = this.scaleValue;
    this.scaleValue = clampedScale;

    // 围绕圆心缩放：保持圆心处的图片像素位置不变
    const halfCircle: number = this.circleDiameter / 2;
    const scaleRatio: number = this.scaleValue / oldScale;
    const newX: number = halfCircle - (halfCircle - this.lastOffsetX) * scaleRatio;
    const newY: number = halfCircle - (halfCircle - this.lastOffsetY) * scaleRatio;
    const clamped: [number, number] = this.clampOffset(newX, newY);
    this.offsetX = clamped[0];
    this.offsetY = clamped[1];
  }

  private handlePinchEnd(): void {
    this.lastScaleValue = this.scaleValue;
    this.lastOffsetX = this.offsetX;
    this.lastOffsetY = this.offsetY;
  }

  private async saveAvatar(): Promise<void> {
    if (this.isSaving) {
      return;
    }
    if (this.imageUri.length === 0) {
      this.showToastMsg('没有图片可保存');
      return;
    }
    this.isSaving = true;
    try {
      const ctx: common.UIAbilityContext =
        getContext(this) as common.UIAbilityContext;
      const filesDir: string = ctx.filesDir;
      const destPath: string = filesDir + '/' + AVATAR_FILE_NAME;
      try {
        if (fileIo.accessSync(destPath)) {
          fileIo.unlinkSync(destPath);
        }
      } catch (_e) {
        // file not found, ok
      }
      const srcFile: fileIo.File = fileIo.openSync(
        this.imageUri,
        fileIo.OpenMode.READ_ONLY
      );
      try {
        const destFile: fileIo.File = fileIo.openSync(
          destPath,
          fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE
        );
        try {
          await fileIo.copyFile(srcFile.fd, destFile.fd);
        } finally {
          fileIo.closeSync(destFile);
        }
      } finally {
        fileIo.closeSync(srcFile);
      }
      const destUri: string = 'file://' + destPath;
      await UserProfileStore.setAvatarUri(destUri, ctx);
      this.showToastMsg('头像已保存');
      setTimeout(() => {
        try {
          router.replaceUrl({ url: Routes.MAIN_FRAME });
        } catch (_err2) {
          try {
            router.back();
          } catch (_err3) {
            // ignore
          }
        }
      }, 600);
    } catch (_err) {
      this.showToastMsg('头像保存失败，请稍后再试');
    } finally {
      this.isSaving = false;
    }
  }

  private handleCancel(): void {
    try {
      router.back();
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2A_BG_BASE)

      // ═══════════════════════════════════════════
      // Layer 2: 用户图片（可拖动/可缩放，圆形裁剪）
      // ═══════════════════════════════════════════
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

      Column() {
        Row()
          .width('100%')
          .height(136)
          .backgroundColor('rgba(15, 15, 35, 0.72)')

        Row() {
          Row()
            .width((this.screenWidth - this.circleDiameter) / 2)
            .height(this.circleDiameter)
            .backgroundColor('rgba(15, 15, 35, 0.72)')

          Stack() {
            Column()
              .width(this.circleDiameter - 4)
              .height(this.circleDiameter - 4)
              .borderRadius((this.circleDiameter - 4) / 2)
              .border({ width: 1, color: 'rgba(230, 168, 0, 0.3)' })
          }
          .width(this.circleDiameter)
          .height(this.circleDiameter)
          .borderRadius(this.circleDiameter / 2)
          .border({ width: 2, color: 'rgba(230, 168, 0, 0.8)' })
          .backgroundColor(Color.Transparent)
          .hitTestBehavior(HitTestMode.None)

          Row()
            .width((this.screenWidth - this.circleDiameter) / 2)
            .height(this.circleDiameter)
            .backgroundColor('rgba(15, 15, 35, 0.72)')
        }

        Row()
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('rgba(15, 15, 35, 0.72)')
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.None)

      Row() {
        Text('\u2190')
          .fontSize(22)
          .fontColor(Theme.V2A_GOLD_ACCENT)
          .padding(12)
          .onClick(() => { this.handleCancel(); })

        Blank()

        Text('\u8C03\u6574\u5934\u50CF')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontColor(Theme.V2A_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)

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
          .fontSize(Theme.FONT_BODY)
          .fontColor('#0F0F23')
          .fontWeight(FontWeight.Medium)
          .width('44%')
          .height(44)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.isSaving ? Theme.V2A_GOLD_GLOW : Theme.V2A_GOLD_ACCENT)
          .borderRadius(Theme.RADIUS_MD)
          .onClick(() => { this.saveAvatar(); })
      }
      .width('92%')
      .justifyContent(FlexAlign.Center)
      .position({ x: '4%', y: '90%' })

      // ═══════════════════════════════════════════
      // Layer 5: 手势捕获层（透明面板，接收拖动/缩放）
      // ═══════════════════════════════════════════
      Stack()
        .width(this.circleDiameter)
        .height(this.circleDiameter)
        .position({ x: (this.screenWidth - this.circleDiameter) / 2, y: 136 })
        .hitTestBehavior(HitTestMode.Block)
        .zIndex(998)
        .gesture(
          GestureGroup(GestureMode.Parallel,
            PanGesture({ fingers: 1, distance: 5 })
              .onActionUpdate((event: GestureEvent) => { this.handlePanUpdate(event); })
              .onActionEnd(() => { this.handlePanEnd(); }),
            PinchGesture({ fingers: 2, distance: 5 })
              .onActionUpdate((event: GestureEvent) => { this.handlePinchUpdate(event); })
              .onActionEnd(() => { this.handlePinchEnd(); })
          )
        )

      Text(this.toastMessage)
        .fontSize(Theme.FONT_BODY)
        .fontColor('#0F0F23')
        .padding({ left: 24, right: 24, top: 12, bottom: 12 })
        .backgroundColor(Theme.V2A_GOLD_ACCENT)
        .borderRadius(Theme.RADIUS_FULL)
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-50%', y: '-50%' })
        .zIndex(999)
        .visibility(this.showToast ? Visibility.Visible : Visibility.None)
        .opacity(this.showToast ? 1 : 0)
    }
    .width('100%')
    .height('100%')
  }
}

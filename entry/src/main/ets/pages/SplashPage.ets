import { router } from '@kit.ArkUI';
import { Routes } from '../common/Routes';

/**
 * AppStorage key for splash target page.
 * Set before loadContent to override the default target (LaunchPage).
 */
const SPLASH_TARGET_KEY: string = 'splashTargetPage';

/**
 * SplashPage - App 自定义启动页
 *
 * 显示全屏星澜湖面启动图约 2000ms，然后自动跳转到目标页面。
 * 使用 replaceUrl 确保用户按返回键不会回到启动页。
 *
 * 默认跳转到 LaunchPage（隐私门禁入口）。
 * 可通过 AppStorage.setOrCreate('splashTargetPage', 'pages/xxx') 覆盖目标。
 */
@Entry
@Component
struct SplashPage {
  private splashTimer: number = -1;

  aboutToAppear(): void {
    this.splashTimer = setTimeout(() => {
      this.navigateToTarget();
    }, 1500);
  }

  aboutToDisappear(): void {
    if (this.splashTimer !== -1) {
      clearTimeout(this.splashTimer);
      this.splashTimer = -1;
    }
  }

  private navigateToTarget(): void {
    try {
      const target: string = AppStorage.get<string>(SPLASH_TARGET_KEY) ?? Routes.LAUNCH;
      // 清理标记，避免下次热启动残留
      AppStorage.setOrCreate(SPLASH_TARGET_KEY, Routes.LAUNCH);
      router.replaceUrl({ url: target });
    } catch (_err) {
      // replace 失败时不做额外处理
    }
  }

  build() {
    Stack() {
      // 全屏启动图
      Image($r('app.media.kaijijiemian1'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#070B1C')
  }
}

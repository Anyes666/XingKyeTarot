import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Routes } from '../common/Routes';
import { Theme } from '../common/Theme';

/**
 * 统一返回按钮组件（P0.3 整改：内联布局 + fallbackUrl）
 *
 * 使用方式：
 *   AppBackButton({ fallbackUrl: Routes.HOME })
 *
 * 放页面顶部，padding-top 由页面自行控制避开状态栏。
 */
@Component
export struct AppBackButton {
  @Prop fallbackUrl: string = '';

  build() {
    Row() {
      Text('← 返回')
        .fontSize(16)
        .fontColor('#CA8A04')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.handleBack();
        })
    }
    .height(44)
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 处理返回：优先 router.back()，失败走 fallbackUrl
   */
  private handleBack(): void {
    try {
      router.back();
    } catch (err) {
      hilog.error(0x0000, 'AppBackButton', 'Router back error');
      if (this.fallbackUrl !== '') {
        try {
          const options: router.RouterOptions = { url: this.fallbackUrl };
          router.replaceUrl(options);
        } catch (fallbackErr) {
          hilog.error(0x0000, 'AppBackButton', 'Router fallback error');
        }
      }
    }
  }
}

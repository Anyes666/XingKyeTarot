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
 * P0.9 修复：添加 hitTestBehavior(Block) 防止被手势层拦截；支持 zIndex。
 */
@Component
export struct AppBackButton {
  @Prop fallbackUrl: string = '';
  @Prop btnZIndex: number = 10;

  build() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('rgba(232,184,61,0.82)')
    }
    .width(48)
    .height(48)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .hitTestBehavior(HitTestMode.Block)
    .onClick(() => {
      this.handleBack();
    })
    .zIndex(this.btnZIndex)
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

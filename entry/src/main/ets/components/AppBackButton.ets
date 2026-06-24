import { hilog } from '@kit.PerformanceAnalysisKit';
import { Routes } from '../common/Routes';
import { Theme } from '../common/Theme';

@Component
export struct AppBackButton {
  build() {
    Button('<')
      .width(40)
      .height(40)
      .fontSize(Theme.FONT_SUBTITLE)
      .fontColor(Theme.GOLD_SOFT)
      .fontWeight(FontWeight.Bold)
      .backgroundColor('rgba(8, 11, 24, 0.62)')
      .borderRadius(Theme.RADIUS_FULL)
      .border({ width: 1, color: 'rgba(216, 180, 90, 0.42)' })
      .position({ x: Theme.SPACE_MD, y: 48 })
      .zIndex(10)
      .onClick(() => {
        try {
          this.getUIContext().getRouter().back();
        } catch (err) {
          hilog.error(0x0000, 'AppBackButton', 'Router back error: %{public}s', JSON.stringify(err));
          try {
            this.getUIContext().getRouter().replaceUrl({ url: Routes.HOME });
          } catch (fallbackErr) {
            hilog.error(0x0000, 'AppBackButton', 'Router fallback error: %{public}s', JSON.stringify(fallbackErr));
          }
        }
      })
  }
}

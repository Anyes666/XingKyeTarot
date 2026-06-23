import { Theme } from '../common/Theme';
import { Constants } from '../common/Constants';

/**
 * 合规页脚组件
 * 固定展示「仅供娱乐，不构成任何专业建议」
 * 用于结果页底部和分享图底部。
 */
@Component
export struct ComplianceFooter {
  @Prop fontSize: number = Theme.FONT_CAPTION;
  @Prop textColor: string = Theme.TEXT_MUTED;
  @Prop showDivider: boolean = true;

  build() {
    Column() {
      if (this.showDivider) {
        Divider()
          .strokeWidth(0.5)
          .color(Theme.TEXT_MUTED)
          .opacity(0.3)
          .margin({ bottom: Theme.SPACE_SM })
      }

      Text(Constants.COMPLIANCE_FOOTER)
        .fontSize(this.fontSize)
        .fontColor(this.textColor)
        .textAlign(TextAlign.Center)
        .opacity(0.7)
    }
    .width('100%')
    .padding({ left: Theme.SPACE_LG, right: Theme.SPACE_LG, bottom: Theme.SPACE_SM })
  }
}

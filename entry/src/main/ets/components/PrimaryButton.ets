import { Theme } from '../common/Theme';

/**
 * 主按钮组件
 * 金色渐变背景 + 圆角
 */
@Component
export struct PrimaryButton {
  @Prop buttonLabel: string = '按钮';
  @Prop isDisabled: boolean = false;
  @Prop buttonWidth: string = '80%';
  onTap?: () => void;

  build() {
    Button(this.buttonLabel)
      .width(this.buttonWidth)
      .height(48)
      .fontSize(Theme.FONT_SUBTITLE)
      .fontColor(this.isDisabled ? Theme.TEXT_MUTED : Theme.BG_DEEP)
      .fontWeight(FontWeight.Bold)
      .backgroundColor(this.isDisabled ? Theme.BG_CARD : 'transparent')
      .borderRadius(Theme.RADIUS_FULL)
      .border({
        width: this.isDisabled ? 1 : 0,
        color: this.isDisabled ? Theme.TEXT_MUTED : 'transparent'
      })
      .linearGradient(this.isDisabled ? undefined : {
        direction: GradientDirection.Right,
        colors: [
          [Theme.GOLD, 0.0],
          [Theme.GOLD_SOFT, 0.5],
          [Theme.GOLD, 1.0]
        ]
      })
      .shadow(this.isDisabled ? undefined : {
        radius: 12,
        color: 'rgba(216, 180, 90, 0.3)',
        offsetY: 4
      })
      .enabled(!this.isDisabled)
      .onClick(() => {
        if (this.onTap) {
          this.onTap();
        }
      })
  }
}

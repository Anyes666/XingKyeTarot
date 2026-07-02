import { Theme } from '../common/Theme';

/**
 * 可缩放按钮样式参数
 */
export interface PressableScaleButtonStyle {
  text: string;
  action: () => void;
  btnWidth?: Length;
  btnHeight?: number;
  fontSize?: number;
  fontColor?: ResourceColor;
  fontWeight?: FontWeight;
  fillColor?: ResourceColor;
  pressedFillColor?: ResourceColor;
  strokeColor?: ResourceColor;
  pressedStrokeColor?: ResourceColor;
  strokeWidth?: number;
  cornerRadius?: number;
  isEnabled?: boolean;
}

/**
 * 轻量按压反馈按钮组件
 *
 * 交互：按下 scale(PRESS_SCALE) + 释放恢复 1.0
 * 动画：ANIM_PRESS_DURATION + V2_EASE_OUT
 * 参考项目已有 onTouch 模式（DivinationEntryCard / HeartOptionCard）
 */
@Component
export struct PressableScaleButton {
  @Prop text: string = '按钮';
  @Prop btnWidth: Length = '100%';
  @Prop btnHeight: number = 48;
  @Prop fontSize: number = 15;
  @Prop fontColor: ResourceColor = Theme.V2C_GOLD_GILT;
  @Prop fontWeight: FontWeight = FontWeight.Medium;
  @Prop fillColor: ResourceColor = Theme.V2C_BG_CARD;
  @Prop pressedFillColor: ResourceColor = Theme.V2C_BG_FLOATING;
  @Prop strokeColor: ResourceColor = Theme.V2C_SPINE_LINE;
  @Prop pressedStrokeColor: ResourceColor = Theme.V2C_GOLD_GILT;
  @Prop strokeWidth: number = 1;
  @Prop cornerRadius: number = 14;
  @Prop isEnabled: boolean = true;
  action: () => void = () => {};

  @State private pressed: boolean = false;

  build() {
    Button(this.text)
      .type(ButtonType.Normal)
      .fontSize(this.fontSize)
      .fontColor(this.fontColor)
      .fontWeight(this.fontWeight)
      .width(this.btnWidth)
      .height(this.btnHeight)
      .backgroundColor(this.pressed ? this.pressedFillColor : this.fillColor)
      .borderRadius(this.cornerRadius)
      .border({
        width: this.strokeWidth,
        color: this.pressed ? this.pressedStrokeColor : this.strokeColor
      })
      .opacity(1.0)
      .scale({
        x: this.pressed ? Theme.PRESS_SCALE : 1.0,
        y: this.pressed ? Theme.PRESS_SCALE : 1.0
      })
      .animation({
        duration: Theme.ANIM_PRESS_DURATION,
        curve: Theme.V2_EASE_OUT
      })
      .onTouch((event: TouchEvent) => {
        if (!this.isEnabled) {
          return;
        }
        if (event.type === TouchType.Down) {
          this.pressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.pressed = false;
        }
      })
      .onClick(() => {
        if (this.isEnabled) {
          this.action();
        }
      })
  }
}

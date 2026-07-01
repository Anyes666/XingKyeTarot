import { Theme } from '../common/Theme';

/**
 * 可缩放按钮样式参数
 */
export interface PressableScaleButtonStyle {
  text: string;
  onClick: () => void;
  width?: Length;
  height?: number;
  fontSize?: number;
  fontColor?: ResourceColor;
  fontWeight?: FontWeight;
  backgroundColor?: ResourceColor;
  pressedBackgroundColor?: ResourceColor;
  borderColor?: ResourceColor;
  pressedBorderColor?: ResourceColor;
  borderWidth?: number;
  borderRadius?: number;
  enabled?: boolean;
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
  @Prop width: Length = '100%';
  @Prop height: number = 48;
  @Prop fontSize: number = 15;
  @Prop fontColor: ResourceColor = Theme.V2C_GOLD_GILT;
  @Prop fontWeight: FontWeight = FontWeight.Medium;
  @Prop backgroundColor: ResourceColor = Theme.V2C_BG_CARD;
  @Prop pressedBackgroundColor: ResourceColor = Theme.V2C_BG_FLOATING;
  @Prop borderColor: ResourceColor = Theme.V2C_SPINE_LINE;
  @Prop pressedBorderColor: ResourceColor = Theme.V2C_GOLD_GILT;
  @Prop borderWidth: number = 1;
  @Prop borderRadius: number = 14;
  @Prop enabled: boolean = true;
  onClick: () => void = () => {};

  @State private pressed: boolean = false;

  build() {
    Button(this.text)
      .type(ButtonType.Normal)
      .fontSize(this.fontSize)
      .fontColor(this.fontColor)
      .fontWeight(this.fontWeight)
      .width(this.width)
      .height(this.height)
      .backgroundColor(this.pressed ? this.pressedBackgroundColor : this.backgroundColor)
      .borderRadius(this.borderRadius)
      .border({
        width: this.borderWidth,
        color: this.pressed ? this.pressedBorderColor : this.borderColor
      })
      .opacity(this.enabled ? 1.0 : 0.5)
      .scale({
        x: this.pressed ? Theme.PRESS_SCALE : 1.0,
        y: this.pressed ? Theme.PRESS_SCALE : 1.0
      })
      .animation({
        duration: Theme.ANIM_PRESS_DURATION,
        curve: Theme.V2_EASE_OUT
      })
      .onTouch((event: TouchEvent) => {
        if (!this.enabled) {
          return;
        }
        if (event.type === TouchType.Down) {
          this.pressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.pressed = false;
        }
      })
      .onClick(() => {
        if (this.enabled) {
          this.onClick();
        }
      })
  }
}

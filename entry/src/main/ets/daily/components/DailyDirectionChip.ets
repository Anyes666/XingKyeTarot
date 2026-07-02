import { Theme } from '../../common/Theme';

/**
 * 今日星页方向选择 Chip（DAILY-4）
 *
 * 视觉：C「星钥之书」
 *   - 未选：书页底色 + 极淡烫金细边；
 *   - 选中：极低透明度暖金底 + 暖金细边 + 暖白金文字；
 *   - 按压：scale 0.97；
 *   - 所有状态圆角统一 V2C_RADIUS_CHIP，不变形；
 *   - 金色只作为细边、文字点缀，不铺大面积金。
 *
 * 无障碍：
 *   - accessibilityGroup 合并子节点；
 *   - accessibilityText 朗读方向文案 + 选中态；
 *   - TalkBack 可读。
 *
 * 不修改业务逻辑、路由、数据结构。
 */
@Component
export struct DailyDirectionChip {
  /** 方向文案（由父组件传入，避免 Chip 内部硬编码方向映射） */
  @Prop label: string = '';
  /** 是否选中 */
  @Prop selected: boolean = false;
  /** 点击选择回调 */
  onSelect: () => void = () => {};

  @State private pressed: boolean = false;

  build() {
    Text(this.label)
      .fontSize(Theme.V2C_FONT_BODY)
      .fontColor(this.selected ? Theme.V2C_GOLD_GILT_SOFT : Theme.V2C_TEXT_PRIMARY)
      .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .lineHeight(22)
      .width('48%')
      .height(56)
      .borderRadius(Theme.V2C_RADIUS_CHIP)
      .backgroundColor(this.selected ? 'rgba(197,160,80,0.10)' : 'rgba(18,24,54,0.60)')
      .border({
        width: 1,
        color: this.selected ? 'rgba(197,160,80,0.42)' : 'rgba(197,160,80,0.16)'
      })
      .scale({
        x: this.pressed ? Theme.PRESS_SCALE : 1.0,
        y: this.pressed ? Theme.PRESS_SCALE : 1.0
      })
      .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
      .accessibilityGroup(true)
      .accessibilityText(this.selected ? `已选择，${this.label}` : this.label)
      .accessibilityLevel('yes')
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.pressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.pressed = false;
        }
      })
      .onClick(() => {
        this.onSelect();
      })
  }
}

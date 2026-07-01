import { Theme } from '../common/Theme';

/**
 * MoonlightLayer — B 方案月光呼吸层
 *
 * 适用页面：B 方案页面 + C+B 混合页面
 * 功能：页面中上区域月光光晕，6s 呼吸动画（opacity 0.6→1.0→0.6）
 * 降级：静态光斑底色，无动画
 *
 * 使用示例：
 *   MoonlightLayer({ strong: false })
 *   MoonlightLayer({ strong: true })  // 入口页/仪式感场景
 */
@Component
export struct MoonlightLayer {
  /** 强光态：入口页用 0.08，普通页用 0.04 */
  @Prop strong: boolean = false;
  /** 降级模式：关闭循环动画，使用静态光斑 */
  @Prop reducedMotion: boolean = false;
  /** 月光呼吸透明度（动画驱动） */
  @State private moonlightOpacity: number = 0.6;

  aboutToAppear(): void {
    if (!this.reducedMotion) {
      // B 方案月光呼吸动画（6s 无限循环）
      animateTo({
        duration: Theme.V2_ANIM_MOONLIGHT_BREATH,
        iterations: -1,
        curve: Theme.V2_EASE_IN_OUT
      }, () => {
        this.moonlightOpacity = 1.0;
      });
    }
  }

  build() {
    Column()
      .width('100%')
      .height(240)
      .radialGradient({
        center: ['50%', '20%'],
        radius: '55%',
        colors: this.buildGradientColors()
      })
      .opacity(this.reducedMotion ? 0.8 : this.moonlightOpacity)
      .hitTestBehavior(HitTestMode.None)
  }

  /**
   * 构建径向渐变色值数组
   * strong=true → 0.08 透明度；strong=false → 0.04 透明度
   */
  private buildGradientColors(): [ResourceColor, number][] {
    const peakOpacity: string = this.strong ? '0.08' : '0.04';
    const midOpacity: string = this.strong ? '0.02' : '0.01';
    const colors: [ResourceColor, number][] = [
      ['rgba(212,172,77,' + peakOpacity + ')', 0.0],
      ['rgba(212,172,77,' + midOpacity + ')', 0.6],
      ['rgba(10,13,26,0)', 1.0]
    ];
    return colors;
  }
}

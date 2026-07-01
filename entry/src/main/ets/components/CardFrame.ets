import { Theme } from '../common/Theme';
import { TarotCardImage } from './TarotCardImage';

/**
 * CardFrame — C 方案牌面框组件
 *
 * 适用方案：C 方案页面（星钥之书）
 * 功能：标准牌面框（烫金细线 + 装饰星 + 圆角）
 * 尺寸：支持多种：140x224（单牌结果）/ 90x144（三牌）/ 200x320（抽牌舞台）
 *
 * 使用示例：
 *   CardFrame({ cardId: 'major_17_star', frameWidth: 140, frameHeight: 224 })
 *   CardFrame({ cardId: 'major_17_star', frameWidth: 90, frameHeight: 144, showDecorations: true })
 */
@Component
export struct CardFrame {
  /** 牌面 ID（传给 TarotCardImage） */
  @Prop cardId: string = '';
  /** 框宽度 */
  @Prop frameWidth: number = 140;
  /** 框高度 */
  @Prop frameHeight: number = 224;
  /** 是否显示烫金装饰线（顶/底各一条） */
  @Prop showDecorations: boolean = true;
  /** 是否显示中心装饰星 */
  @Prop showCenterStar: boolean = false;

  build() {
    Stack() {
      // 牌面图
      TarotCardImage({
        cardId: this.cardId,
        cardWidth: this.frameWidth,
        cardHeight: this.frameHeight
      })

      // 烫金细线边框
      Column()
        .width('100%')
        .height('100%')
        .border({ width: 1, color: Theme.V2C_GOLD_GILT, style: BorderStyle.Solid })
        .borderRadius(Theme.V2C_RADIUS_CARD)
        .hitTestBehavior(HitTestMode.None)

      // 书脊线外框（更细的暗线）
      Column()
        .width('100%')
        .height('100%')
        .border({ width: 0.5, color: Theme.V2C_SPINE_LINE, style: BorderStyle.Solid })
        .borderRadius(Theme.V2C_RADIUS_CARD)
        .hitTestBehavior(HitTestMode.None)

      // 烫金顶线装饰
      if (this.showDecorations) {
        Row()
          .width('60%')
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.4)
          .position({ x: '20%', y: 8 })
          .hitTestBehavior(HitTestMode.None)
      }

      // 烫金底线装饰
      if (this.showDecorations) {
        Row()
          .width('60%')
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.3)
          .position({ x: '20%', y: '92%' })
          .hitTestBehavior(HitTestMode.None)
      }

      // 中心装饰星（C 方案烫金星点）
      if (this.showCenterStar) {
        Text('✦')
          .fontSize(16)
          .fontColor(Theme.V2C_GOLD_GILT)
          .opacity(0.15)
          .hitTestBehavior(HitTestMode.None)
      }
    }
    .width(this.frameWidth)
    .height(this.frameHeight)
    .clip(true)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .shadow(Theme.V2C_SHADOW_CARD)
  }
}

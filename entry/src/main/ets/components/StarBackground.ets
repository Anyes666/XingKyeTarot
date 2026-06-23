import { Theme } from '../common/Theme';

/**
 * 星空背景组件
 * MVP 版本使用静态星光点缀，无粒子动画循环。
 */
@Component
export struct StarBackground {
  @Prop bgOpacity: number = 1.0;

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [Theme.BG_DEEP, 0.0],
            [Theme.BG_PRIMARY, 0.5],
            [Theme.BG_DEEP, 1.0]
          ]
        })

      Column() {
        Row() {
          Circle({ width: 2, height: 2 }).fill(Theme.GOLD_SOFT).opacity(0.6)
          Blank()
          Circle({ width: 1.5, height: 1.5 }).fill(Theme.AURORA).opacity(0.4)
        }
        .width('85%')
        .margin({ top: '8%' })

        Blank()

        Row() {
          Circle({ width: 2, height: 2 }).fill(Theme.PURPLE_SOFT).opacity(0.5)
          Blank().width('60%')
          Circle({ width: 1.5, height: 1.5 }).fill(Theme.GOLD_SOFT).opacity(0.3)
        }
        .width('90%')
        .margin({ top: '15%' })

        Blank()

        Row() {
          Blank().width('20%')
          Circle({ width: 1.5, height: 1.5 }).fill(Theme.AURORA).opacity(0.5)
          Blank()
          Circle({ width: 2, height: 2 }).fill(Theme.GOLD_SOFT).opacity(0.4)
        }
        .width('88%')
        .margin({ top: '20%' })

        Blank()

        Row() {
          Circle({ width: 1.5, height: 1.5 }).fill(Theme.PURPLE_SOFT).opacity(0.35)
          Blank().width('40%')
          Circle({ width: 2, height: 2 }).fill(Theme.AURORA).opacity(0.3)
          Blank()
          Circle({ width: 1, height: 1 }).fill(Theme.GOLD_SOFT).opacity(0.5)
        }
        .width('92%')
        .margin({ top: '12%' })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .opacity(this.bgOpacity)
  }
}

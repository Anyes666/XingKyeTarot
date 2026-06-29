import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';

/**
 * 牌轮抽牌页路由参数
 */
interface CardWheelDrawRouteParams {
  drawCount: number;
}

/**
 * 旋转牌轮 — 抽牌数量选择页
 *
 * 用户在此选择「抽一张」或「抽三张」，
 * 然后进入 CardWheelDrawPage 进行牌轮交互。
 */
@Entry
@Component
struct CardWheelModePage {
  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      // 主内容
      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.DIVINATION_CENTER })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        .alignItems(VerticalAlign.Center)

        // 标题
        Text('选择抽牌方式')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        // 副标题
        Text('先决定这一次，要让几张牌陪你看见心事。')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_XXL })

        // 抽一张卡片
        Column() {
          Row() {
            Column() {
              Text('◇')
                .fontSize(32)
                .fontColor('#E8B83D')
                .textAlign(TextAlign.Center)
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .borderRadius(Theme.RADIUS_FULL)
            .backgroundColor('rgba(216, 180, 90, 0.08)')

            Column() {
              Text('抽一张')
                .fontSize(Theme.FONT_TITLE)
                .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                .fontWeight(FontWeight.Medium)

              Text('适合快速照见此刻的心情。')
                .fontSize(Theme.FONT_BODY)
                .fontColor(Theme.MOON_MUTED)
                .margin({ top: 4 })
                .lineHeight(20)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: Theme.SPACE_MD })
          }
          .width('100%')
          .padding(Theme.SPACE_LG)
        }
        .width('88%')
        .backgroundColor('rgba(27, 27, 48, 0.72)')
        .borderRadius(Theme.RADIUS_LG)
        .border({ width: 1, color: 'rgba(216, 180, 90, 0.18)' })
        .margin({ bottom: Theme.SPACE_LG })
        .onClick(() => {
          this.navigateToWheelDraw(1);
        })

        // 抽三张卡片
        Column() {
          Row() {
            Column() {
              Text('△')
                .fontSize(32)
                .fontColor('#E8B83D')
                .textAlign(TextAlign.Center)
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .borderRadius(Theme.RADIUS_FULL)
            .backgroundColor('rgba(216, 180, 90, 0.08)')

            Column() {
              Text('抽三张')
                .fontSize(Theme.FONT_TITLE)
                .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                .fontWeight(FontWeight.Medium)

              Text('适合看见过去、现在与可能的方向。')
                .fontSize(Theme.FONT_BODY)
                .fontColor(Theme.MOON_MUTED)
                .margin({ top: 4 })
                .lineHeight(20)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: Theme.SPACE_MD })
          }
          .width('100%')
          .padding(Theme.SPACE_LG)
        }
        .width('88%')
        .backgroundColor('rgba(27, 27, 48, 0.72)')
        .borderRadius(Theme.RADIUS_LG)
        .border({ width: 1, color: 'rgba(216, 180, 90, 0.18)' })
        .onClick(() => {
          this.navigateToWheelDraw(3);
        })

        // 底部提示
        Text('让牌轮慢慢转动。\n当它停下时，选中最靠近你的那一张。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .lineHeight(18)
          .width('88%')
          .margin({ top: Theme.SPACE_XXL })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }

  private navigateToWheelDraw(drawCount: number): void {
    try {
      const params: CardWheelDrawRouteParams = { drawCount: drawCount };
      const options: router.RouterOptions = { url: Routes.CARD_WHEEL_DRAW, params: params };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }
}

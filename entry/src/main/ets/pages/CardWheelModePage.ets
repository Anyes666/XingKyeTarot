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
        .backgroundColor(Theme.V2C_BG_BASE)

      // 主内容
      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.DIVINATION_CENTER })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.V2_SPACE_SM, right: Theme.V2_SPACE_SM })
        .alignItems(VerticalAlign.Center)

        // 标题
        Text('旋转牌轮')
          .fontSize(Theme.V2C_FONT_TITLE)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        // 副标题
        Text('让手指慢一点，停在此刻最有感觉的那张牌上。')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_XL })

        // 抽一张卡片
        Column() {
          Row() {
            Column() {
              Text('◇')
                .fontSize(32)
                .fontColor(Theme.V2C_GOLD_GILT)
                .textAlign(TextAlign.Center)
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .borderRadius(Theme.V2_RADIUS_FULL)
            .backgroundColor(Theme.V2C_BG_FLOATING)

            Column() {
              Text('抽一张星钥')
                .fontSize(Theme.V2C_FONT_SUBTITLE)
                .fontColor(Theme.V2C_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)

              Text('适合现在只想听一句轻轻的提醒。')
                .fontSize(Theme.V2C_FONT_BODY)
                .fontColor(Theme.V2C_TEXT_SECONDARY)
                .margin({ top: 4 })
                .lineHeight(20)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: Theme.V2_SPACE_MD })
          }
          .width('100%')
          .padding(Theme.V2_SPACE_LG)
        }
        .width('88%')
        .backgroundColor(Theme.V2C_BG_CARD)
        .borderRadius(Theme.V2C_RADIUS_CARD)
        .border({ width: 1, color: Theme.V2C_SPINE_LINE })
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
                .fontColor(Theme.V2C_GOLD_GILT)
                .textAlign(TextAlign.Center)
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .borderRadius(Theme.V2_RADIUS_FULL)
            .backgroundColor(Theme.V2C_BG_FLOATING)

            Column() {
              Text('抽三张星钥')
                .fontSize(Theme.V2C_FONT_SUBTITLE)
                .fontColor(Theme.V2C_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)

              Text('适合把一件心事拆成三个角度慢慢看。')
                .fontSize(Theme.V2C_FONT_BODY)
                .fontColor(Theme.V2C_TEXT_SECONDARY)
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
        .backgroundColor(Theme.V2C_BG_CARD)
        .borderRadius(Theme.V2C_RADIUS_CARD)
        .border({ width: 1, color: Theme.V2C_SPINE_LINE })
        .onClick(() => {
          this.navigateToWheelDraw(3);
        })

        // 底部提示
        Text('不用急着选。\n当某张牌让你多看了一眼，就从那里开始。')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(18)
          .width('88%')
          .margin({ top: Theme.V2_SPACE_XL })
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

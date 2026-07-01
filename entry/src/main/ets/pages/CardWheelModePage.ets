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
        Text('选择抽牌方式')
          .fontSize(Theme.V2C_FONT_TITLE)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        // 副标题
        Text('先决定这一次，要让几张牌陪你看见心事。')
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
              Text('抽一张')
                .fontSize(Theme.V2C_FONT_SUBTITLE)
                .fontColor(Theme.V2C_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)

              Text('适合快速照见此刻的心情。')
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
              Text('抽三张')
                .fontSize(Theme.V2C_FONT_SUBTITLE)
                .fontColor(Theme.V2C_TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)

              Text('适合看见过去、现在与可能的方向。')
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
        Text('让牌轮慢慢转动。\n当它停下时，选中最靠近你的那一张。')
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

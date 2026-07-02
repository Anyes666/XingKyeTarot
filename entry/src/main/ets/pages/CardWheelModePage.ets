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
  @State private pressedMode: number = 0;

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2C_BG_BASE)

      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['rgba(197,160,80,0.05)', 0.0],
            ['rgba(18,24,54,0.12)', 0.42],
            ['rgba(10,13,26,0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      // 主内容 — 可纵向滚动
      Scroll() {
        Column() {
          // 标题
          Text('旋转牌轮')
            .fontSize(Theme.V2C_FONT_TITLE)
            .fontColor(Theme.V2C_GOLD_GILT)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: Theme.V2_SPACE_LG })

          // 副标题
          Text('让手指慢一点，停在此刻最有感觉的那张牌上。')
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .width('100%')
            .lineHeight(22)
            .margin({ top: Theme.V2_SPACE_2XS, bottom: Theme.V2_SPACE_MD })

          Text('ASTRO WHEEL')
            .fontSize(Theme.V2C_FONT_DISCLAIMER)
            .fontColor('rgba(224,205,149,0.44)')
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: Theme.V2_SPACE_SM })

          // 抽一张卡片
          this.modeCard(1, '◇', '抽一张星钥', '适合现在只想听一句轻轻的提醒。')

          // 抽三张卡片
          this.modeCard(3, '△', '抽三张星钥', '适合把一件心事拆成三个角度慢慢看。')

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
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .padding({ top: Theme.SAFE_TOP + 48, bottom: Theme.SAFE_BOTTOM + Theme.V2_SPACE_MD })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 返回按钮 — 独立层，不跟随滚动
      AppBackButton({ fallbackUrl: Routes.DIVINATION_CENTER })
        .position({ x: Theme.V2_SPACE_SM, y: Theme.SAFE_TOP + 8 })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }

  @Builder
  modeCard(mode: number, symbol: string, title: string, description: string): void {
    Stack() {
      Column()
        .width('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['rgba(197,160,80,0.08)', 0.0],
            ['rgba(18,24,54,0.12)', 0.34],
            ['rgba(10,13,26,0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      Row() {
        Stack() {
          Circle()
            .width(54)
            .height(54)
            .stroke('rgba(197,160,80,0.32)')
            .strokeWidth(1)

          Circle()
            .width(36)
            .height(36)
            .stroke(Theme.V2C_SPINE_LINE)
            .strokeWidth(1)

          Text(symbol)
            .fontSize(30)
            .fontColor(Theme.V2C_GOLD_GILT_SOFT)
            .textAlign(TextAlign.Center)
        }
        .width(64)
        .height(64)
        .alignContent(Alignment.Center)
        .borderRadius(Theme.V2C_RADIUS_CARD)
        .backgroundColor('rgba(24,31,64,0.72)')
        .border({ width: 1, color: 'rgba(197,160,80,0.16)' })

        Column() {
          Text(title)
            .fontSize(Theme.V2C_FONT_SUBTITLE)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)

          Text(description)
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .margin({ top: Theme.V2_SPACE_2XS })
            .lineHeight(21)

          Text(mode === 1 ? 'ONE CARD' : 'THREE CARDS')
            .fontSize(Theme.V2C_FONT_DISCLAIMER)
            .fontColor('rgba(224,205,149,0.42)')
            .margin({ top: Theme.V2_SPACE_SM })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: Theme.V2_SPACE_MD })
      }
      .width('100%')
      .padding(Theme.V2_SPACE_LG)
    }
    .width('88%')
    .clip(true)
    .backgroundColor('rgba(18,24,54,0.82)')
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({
      width: 1,
      color: this.pressedMode === mode ? 'rgba(197,160,80,0.42)' : 'rgba(197,160,80,0.18)'
    })
    .shadow({
      radius: this.pressedMode === mode ? 12 : 8,
      color: 'rgba(0,0,0,0.26)',
      offsetX: 0,
      offsetY: 3
    })
    .scale({
      x: this.pressedMode === mode ? Theme.PRESS_SCALE : 1.0,
      y: this.pressedMode === mode ? Theme.PRESS_SCALE : 1.0
    })
    .animation({
      duration: Theme.ANIM_PRESS_DURATION,
      curve: Theme.V2_EASE_OUT
    })
    .margin({ bottom: Theme.V2_SPACE_LG })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedMode = mode;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedMode = 0;
      }
    })
    .onClick(() => {
      this.navigateToWheelDraw(mode);
    })
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

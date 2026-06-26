import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';

/**
 * AskHeart 页面路由参数
 */
interface AskHeartRouteParams {
  entryMode: string;
}

/**
 * 星澜底部五键导航组件
 *
 * ┌──────────────────────────────────────┐
 * │  单牌   圣三角   (★星澜)   关系   记录  │
 * │  text   text   elevated   text   text │
 * └──────────────────────────────────────┘
 *
 * 中间「星澜」按钮：圆形、金色背景、上浮 16vp、默认高亮
 */
@Component
export struct CompanionBottomNav {
  /**
   * 星澜按钮点击回调：由父页面注入，只切文案不跳转。
   */
  onXinglanClick: () => void = () => {};

  private navigateToSingle(): void {
    try {
      const params: AskHeartRouteParams = { entryMode: 'NORMAL_SINGLE' };
      const options: router.RouterOptions = { url: Routes.ASK_HEART, params: params };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }

  private navigateToTriangle(): void {
    try {
      const options: router.RouterOptions = { url: Routes.TRIANGLE_INTRO };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }

  private navigateToRelation(): void {
    try {
      const options: router.RouterOptions = { url: Routes.RELATION_INTRO };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }

  private navigateToHistory(): void {
    try {
      const options: router.RouterOptions = { url: Routes.HISTORY };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Column() {
      // 顶部分割线
      Divider()
        .width('100%')
        .strokeWidth(1)
        .color(Theme.DEEP_STARRY)

      Row() {
        // ═══ 1. 单牌 ═══
        Column() {
          Text('◇')
            .fontSize(18)
            .fontColor(Theme.MOON_MUTED)
          Text('单牌')
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.MOON_MUTED)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.navigateToSingle();
        })

        // ═══ 2. 圣三角 ═══
        Column() {
          Text('△')
            .fontSize(18)
            .fontColor(Theme.MOON_MUTED)
          Text('圣三角')
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.MOON_MUTED)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.navigateToTriangle();
        })

        // ═══ 3. 星澜（中间高亮主按钮）═══
        Column() {
          Column() {
            Text('★')
              .fontSize(22)
              .fontColor(Theme.BTN_DARK_TEXT)
            Text('星澜')
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.BTN_DARK_TEXT)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 2 })
          }
          .width(58)
          .height(58)
          .borderRadius(29)
          .backgroundColor(Theme.GOLD_MAIN)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .shadow({
            radius: 12,
            color: 'rgba(217, 154, 0, 0.35)',
            offsetX: 0,
            offsetY: 4
          })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .translate({ y: -8 })
        .onClick(() => {
          this.onXinglanClick();
        })

        // ═══ 4. 关系 ═══
        Column() {
          Text('◎')
            .fontSize(18)
            .fontColor(Theme.MOON_MUTED)
          Text('关系')
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.MOON_MUTED)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.navigateToRelation();
        })

        // ═══ 5. 记录 ═══
        Column() {
          Text('☰')
            .fontSize(18)
            .fontColor(Theme.MOON_MUTED)
          Text('记录')
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.MOON_MUTED)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.navigateToHistory();
        })
      }
      .width('100%')
      .height(64)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
    .padding({ bottom: 16 })
  }
}

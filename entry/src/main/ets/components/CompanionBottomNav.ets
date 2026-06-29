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
 * 导航 Tab 配置项
 */
interface NavTabConfig {
  icon: string;
  label: string;
  onClick: () => void;
}

/**
 * 星澜底部五键导航组件 — 深蓝黑金毛玻璃悬浮胶囊
 *
 * 结构（不裁切星澜按钮）：
 *   外层 Stack（不 clip，高 88vp，给星澜上浮留空间）
 *     ├─ 胶囊底座 Stack（clip(true)）
 *     │    └─ Tab 内容 Row（单牌 / 圣三角 / 空位 / 关系 / 记录）
 *     └─ 中间星澜圆按钮（sibling，覆盖胶囊上方，不被裁切）
 *
 * 点击范围：
 *   - onXinglanClick 只绑定在中间星澜按钮
 *   - 胶囊 onTouch 只处理按压反馈，不触发回调
 *   - 左右 Tab onClick 处理各自路由
 */
@Component
export struct CompanionBottomNav {
  /**
   * 星澜按钮点击回调：由父页面注入，只切文案不跳转。
   * 仅绑定在中间星澜圆按钮的 onClick。
   */
  onXinglanClick: () => void = () => {};

  // ═══ 按压状态 ═══
  @State navPressed: boolean = false;
  @State centerPressed: boolean = false;

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

  // ═══ 胶囊触摸：按压反馈（不触发任何回调）═══
  private handleNavTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.navPressed = true;
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      this.navPressed = false;
    }
  }

  // ═══ 中间星澜按钮触摸：只做按压反馈 ═══
  private handleCenterTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.centerPressed = true;
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      this.centerPressed = false;
    }
  }

  build() {
    // ═══ 外层导航容器：不 clip，给星澜上浮留空间 ═══
    Stack() {
      // ═══ 胶囊底座（clip(true)）═══
      Stack() {
        // ─── Tab 内容层（中间留空位给星澜按钮）───
        Row() {
          // ═══ 1. 单牌 ═══
          Column() {
            Text('◇')
              .fontSize(22)
              .fontColor('#8F96B2')
            Text('单牌')
              .fontSize(12)
              .fontColor('#9AA2BD')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.navigateToSingle();
          })

          // ═══ 2. 圣三角 ═══
          Column() {
            Text('△')
              .fontSize(22)
              .fontColor('#8F96B2')
            Text('圣三角')
              .fontSize(12)
              .fontColor('#9AA2BD')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.navigateToTriangle();
          })

          // ═══ 3. 中间空位（星澜按钮在外面）═══
          Column()
            .layoutWeight(1)
            .height('100%')

          // ═══ 4. 关系 ═══
          Column() {
            Text('◎')
              .fontSize(22)
              .fontColor('#8F96B2')
            Text('关系')
              .fontSize(12)
              .fontColor('#9AA2BD')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.navigateToRelation();
          })

          // ═══ 5. 记录 ═══
          Column() {
            Text('☰')
              .fontSize(22)
              .fontColor('#8F96B2')
            Text('记录')
              .fontSize(12)
              .fontColor('#9AA2BD')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.navigateToHistory();
          })
        }
        .width('100%')
        .height('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('90%')
      .height(62)
      .borderRadius(30)
      .backgroundColor(this.navPressed ? '#90081020' : '#80081020')
      .backdropBlur(16)
      .border({
        width: 1,
        color: '#1AFFFFFF'
      })
      .shadow({
        radius: 18,
        color: '#47000000',
        offsetX: 0,
        offsetY: 5
      })
      .clip(true)
      .scale({
        x: this.navPressed ? 1.012 : 1.0,
        y: this.navPressed ? 0.988 : 1.0
      })
      .translate({ y: this.navPressed ? 1 : 0 })
      .animation({ duration: 280, curve: Curve.EaseOut })
      .onTouch((event: TouchEvent) => {
        this.handleNavTouch(event);
      })

      // ═══ 中间星澜圆按钮（sibling，覆盖胶囊上方，不被 clip）═══
      Column() {
        Text('★')
          .fontSize(24)
          .fontColor('#111426')
        Text('星澜')
          .fontSize(13)
          .fontColor('#111426')
          .fontWeight(FontWeight.Bold)
          .margin({ top: 2 })
      }
      .width(66)
      .height(66)
      .borderRadius(33)
      .backgroundColor('#E8B83D')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .shadow({
        radius: this.centerPressed ? 10 : 14,
        color: '#38E8B83D',
        offsetX: 0,
        offsetY: this.centerPressed ? 2 : 4
      })
      .translate({ y: this.centerPressed ? -14 : -16 })
      .scale({
        x: this.centerPressed ? 0.96 : 1.0,
        y: this.centerPressed ? 0.96 : 1.0
      })
      .animation({ duration: 280, curve: Curve.EaseOut })
      .onClick(() => {
        this.onXinglanClick();
      })
      .onTouch((event: TouchEvent) => {
        this.handleCenterTouch(event);
      })
    }
    .width('100%')
    .height(88)
    .margin({ bottom: 8 })
    .alignContent(Alignment.Center)
  }
}

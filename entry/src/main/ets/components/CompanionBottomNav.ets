import { router } from '@kit.ArkUI';
import { Routes } from '../common/Routes';
import { Theme } from '../common/Theme';

/**
 * 导航 Tab 配置项
 */
interface NavTabConfig {
  icon: string;
  label: string;
  onClick: () => void;
  /** 图标垂直微调偏移（vp），用于补偿 Unicode 字符基线差异 */
  iconOffsetY?: number;
}

/**
 * Phase 6.6：星钥塔罗底部五键导航 — 深蓝黑金毛玻璃悬浮胶囊
 *
 * 5 个一级入口：
 *   1. 塔罗
 *   2. 星澜聊天
 *   3. 星澜语录
 *   4. 卡牌总览
 *   5. 我的
 *
 * 结构：
 *   外层 Stack（不 clip，高 88vp）
 *     ├─ 胶囊底座 Stack（clip(true)）
 *     │    └─ Tab 内容 Row
 *     └─ 中间高亮按钮（当前选中 tab）
 */
@Component
export struct CompanionBottomNav {
  /** 当前选中 tab 索引（0-4） */
  @Prop currentTab: number = 0;

  /** tab 切换回调 */
  onTabChange: (index: number) => void = (_index: number) => {};

  // ═══ 按压状态 ═══
  @State navPressed: boolean = false;

  private static readonly NAV_HEIGHT: number = 96;
  private static readonly CAPSULE_HEIGHT: number = 64;
  private static readonly ICON_BOX_HEIGHT: number = 24;
  private static readonly ICON_FONT_SIZE: number = 22;
  private static readonly ICON_LINE_HEIGHT: number = 24;
  private static readonly LABEL_FONT_SIZE: number = 12;
  private static readonly LABEL_LINE_HEIGHT: number = 16;
  private static readonly ICON_LABEL_GAP: number = 4;
  private static readonly SELECTED_COLOR: string = '#D8B86A';
  private static readonly SELECTED_LABEL_COLOR: string = Theme.V2_GOLD_SOFT;
  private static readonly UNSELECTED_ICON_COLOR: string = '#7D849C';
  private static readonly UNSELECTED_LABEL_COLOR: string = Theme.V2_TEXT_SECONDARY;
  private static readonly NAV_BG: string = 'rgba(5, 8, 20, 0.84)';
  private static readonly NAV_BG_PRESSED: string = 'rgba(8, 11, 26, 0.90)';
  private static readonly NAV_BORDER: string = 'rgba(201, 164, 75, 0.13)';

  private readonly tabs: NavTabConfig[] = [
    {
      icon: '⬡',
      label: '塔罗',
      iconOffsetY: 1,
      onClick: (): void => {
        this.onTabChange(0);
      }
    },
    {
      icon: '☾',
      label: '星澜聊天',
      iconOffsetY: 1,
      onClick: (): void => {
        this.onTabChange(1);
      }
    },
    {
      icon: '✦',
      label: '星澜语录',
      iconOffsetY: 0,
      onClick: (): void => {
        this.onTabChange(2);
      }
    },
    {
      icon: '▤',
      label: '卡牌总览',
      iconOffsetY: 0,
      onClick: (): void => {
        this.onTabChange(3);
      }
    },
    {
      icon: '◎',
      label: '我的',
      iconOffsetY: 0,
      onClick: (): void => {
        this.onTabChange(4);
      }
    }
  ];

  // ═══ 胶囊触摸：按压反馈 ═══
  private handleNavTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.navPressed = true;
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      this.navPressed = false;
    }
  }

  build() {
    Stack() {
      // ═══ 胶囊背后极弱暗影，托住底部安全区层级 ═══
      Column()
        .width('88%')
        .height(54)
        .borderRadius(28)
        .backgroundColor('rgba(0, 0, 0, 0.20)')
        .blur(18)
        .position({ x: '6%', y: 18 })
        .hitTestBehavior(HitTestMode.Transparent)

      // ═══ 胶囊底座（clip(true)）═══
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              ['rgba(18, 24, 48, 0.78)', 0.0],
              [this.navPressed ? CompanionBottomNav.NAV_BG_PRESSED : CompanionBottomNav.NAV_BG, 1.0]
            ]
          })
          .hitTestBehavior(HitTestMode.Transparent)

        // 顶部 1vp 极细边线，使用低透明暖金，避免强发光。
        Column()
          .width('88%')
          .height(1)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [
              ['rgba(201, 164, 75, 0)', 0.0],
              ['rgba(201, 164, 75, 0.24)', 0.5],
              ['rgba(201, 164, 75, 0)', 1.0]
            ]
          })
          .position({ x: '6%', y: 0 })
          .hitTestBehavior(HitTestMode.Transparent)

        Row() {
          ForEach(this.tabs, (tab: NavTabConfig, index: number) => {
            Column() {
              // 图标固定高度容器 + 垂直微调
              Column() {
                Text(tab.icon)
                  .fontSize(CompanionBottomNav.ICON_FONT_SIZE)
                  .lineHeight(CompanionBottomNav.ICON_LINE_HEIGHT)
                  .fontColor(this.currentTab === index ?
                    CompanionBottomNav.SELECTED_COLOR :
                    CompanionBottomNav.UNSELECTED_ICON_COLOR)
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .height(CompanionBottomNav.ICON_BOX_HEIGHT)
              .justifyContent(FlexAlign.Center)
              .translate({ y: tab.iconOffsetY ?? 0 })

              Text(tab.label)
                .fontSize(CompanionBottomNav.LABEL_FONT_SIZE)
                .lineHeight(CompanionBottomNav.LABEL_LINE_HEIGHT)
                .fontColor(this.currentTab === index ?
                  CompanionBottomNav.SELECTED_LABEL_COLOR :
                  CompanionBottomNav.UNSELECTED_LABEL_COLOR)
                .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
                .margin({ top: CompanionBottomNav.ICON_LABEL_GAP })
            }
            .layoutWeight(1)
            .height('100%')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              tab.onClick();
            })
          }, (_tab: NavTabConfig, index: number) => 'tab_' + index.toString())
        }
        .width('100%')
        .height('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('91%')
      .height(CompanionBottomNav.CAPSULE_HEIGHT)
      .borderRadius(32)
      .backgroundColor(this.navPressed ? CompanionBottomNav.NAV_BG_PRESSED : CompanionBottomNav.NAV_BG)
      .backdropBlur(18)
      .border({
        width: 1,
        color: CompanionBottomNav.NAV_BORDER
      })
      .shadow({
        radius: 20,
        color: 'rgba(0, 0, 0, 0.40)',
        offsetX: 0,
        offsetY: 6
      })
      .clip(true)
      .scale({
        x: this.navPressed ? 0.998 : 1.0,
        y: this.navPressed ? 0.992 : 1.0
      })
      .translate({ y: this.navPressed ? 1 : 0 })
      .animation({ duration: Theme.V2_ANIM_BTN_RELEASE, curve: Theme.V2_EASE_OUT })
      .onTouch((event: TouchEvent) => {
        this.handleNavTouch(event);
      })
    }
    .width('100%')
    .height(CompanionBottomNav.NAV_HEIGHT)
    .padding({ bottom: 10 })
    .alignContent(Alignment.Center)
  }
}

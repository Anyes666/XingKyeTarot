import { router } from '@kit.ArkUI';
import { Routes } from '../common/Routes';

/**
 * 导航 Tab 配置项
 */
interface NavTabConfig {
  icon: string;
  label: string;
  onClick: () => void;
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

  private readonly tabs: NavTabConfig[] = [
    {
      icon: '◇',
      label: '塔罗',
      onClick: (): void => {
        this.onTabChange(0);
      }
    },
    {
      icon: '◉',
      label: '星澜聊天',
      onClick: (): void => {
        this.onTabChange(1);
      }
    },
    {
      icon: '✦',
      label: '星澜语录',
      onClick: (): void => {
        this.onTabChange(2);
      }
    },
    {
      icon: '▦',
      label: '卡牌总览',
      onClick: (): void => {
        this.onTabChange(3);
      }
    },
    {
      icon: '☺',
      label: '我的',
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
      // ═══ 胶囊底座（clip(true)）═══
      Stack() {
        Row() {
          ForEach(this.tabs, (tab: NavTabConfig, index: number) => {
            Column() {
              Text(tab.icon)
                .fontSize(22)
                .fontColor(this.currentTab === index ? '#E8B83D' : '#8F96B2')
              Text(tab.label)
                .fontSize(12)
                .fontColor(this.currentTab === index ? '#E8B83D' : '#9AA2BD')
                .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
                .margin({ top: 2 })
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
    }
    .width('100%')
    .height(88)
    .margin({ bottom: 8 })
    .alignContent(Alignment.Center)
  }
}

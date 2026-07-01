import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';

/**
 * AskHeart 页面路由参数
 */
interface AskHeartRouteParams {
  entryMode: string;
}

/**
 * 占卜中心入口卡片配置
 */
interface DivinationEntry {
  icon: string;
  title: string;
  subtitle: string;
  routeAction: () => void;
}

/**
 * Phase 6.1：占卜中心页
 * 把「每日一占 / 圣三角牌阵 / 关系探索 / 历史查看」统一收进一级入口
 */
@Entry
@Component
struct DivinationCenterPage {
  @State private pressedIndex: number = -1;
  // ── B 方案月光呼吸动画状态 ──
  @State private moonlightOpacity: number = 0.6;

  aboutToAppear(): void {
    // B 方案月光呼吸动画（6s 无限循环）
    animateTo({
      duration: Theme.V2_ANIM_MOONLIGHT_BREATH,
      iterations: -1,
      curve: Curve.EaseInOut
    }, () => {
      this.moonlightOpacity = 1.0;
    });
  }

  private buildEntries(): DivinationEntry[] {
    const entries: DivinationEntry[] = [
      {
        icon: '◇',
        title: '每日一占',
        subtitle: '一句心事，一张星钥。',
        routeAction: (): void => {
          try {
            const params: AskHeartRouteParams = { entryMode: 'NORMAL_SINGLE' };
            const options: router.RouterOptions = { url: Routes.ASK_HEART, params: params };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      },
      {
        icon: '△',
        title: '圣三角牌阵',
        subtitle: '过去、现在、可能的方向。',
        routeAction: (): void => {
          try {
            const options: router.RouterOptions = { url: Routes.TRIANGLE_INTRO };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      },
      {
        icon: '◎',
        title: '关系探索',
        subtitle: '不替你判断谁对谁错，只陪你看清感受。',
        routeAction: (): void => {
          try {
            const options: router.RouterOptions = { url: Routes.RELATION_INTRO };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      },
      {
        icon: '◎',
        title: '旋转牌轮',
        subtitle: '亲手转动牌轮，选择此刻靠近你的牌。',
        routeAction: (): void => {
          try {
            const options: router.RouterOptions = { url: Routes.CARD_WHEEL_MODE };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      },
      {
        icon: '☰',
        title: '历史查看',
        subtitle: '回看曾经抽到的星钥和那时的自己。',
        routeAction: (): void => {
          try {
            const options: router.RouterOptions = { url: Routes.HISTORY };
            router.pushUrl(options);
          } catch (_err) {
            // ignore
          }
        }
      }
    ];
    return entries;
  }

  build() {
    Stack() {
      // 沉浸式深空背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [Theme.V2C_BG_BASE, 0.0],
            [Theme.V2C_BG_BASE, 0.55],
            [Theme.V2C_BG_BASE, 1.0]
          ]
        })

      // 沉浸式顶部消隐渐变（融入状态栏）
      Column()
        .width('100%')
        .height(Theme.IMMERSIVE_TOP_HEIGHT)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [Theme.V2C_BG_BASE, 0.0],
            ['rgba(15, 15, 35, 0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.Transparent)
        .position({ x: 0, y: 0 })

      // 沉浸光感：底部金色径向光晕
      Column()
        .width('100%')
        .height('100%')
        .radialGradient({
          center: ['50%', '85%'],
          radius: '60%',
          colors: [
            ['rgba(197, 160, 80, 0.04)', 0.0],
            ['rgba(197, 160, 80, 0.02)', 0.45],
            ['rgba(0, 0, 0, 0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.Transparent)

      // ── B 方案月光呼吸光晕层（顶部 6s 循环）──
      Column()
        .width('100%')
        .height(220)
        .radialGradient({
          center: ['50%', '20%'],
          radius: '55%',
          colors: [
            ['rgba(212,172,77,0.04)', 0.0],
            ['rgba(212,172,77,0.01)', 0.6],
            ['rgba(10,13,26,0)', 1.0]
          ]
        })
        .opacity(this.moonlightOpacity)
        .hitTestBehavior(HitTestMode.None)

      // 主内容
      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.MAIN_FRAME })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        .alignItems(VerticalAlign.Center)

        // 标题
        Text('占卜')
          .fontSize(Theme.V2C_FONT_TITLE)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        // 副标题
        Text('用一张牌、一组牌阵，轻轻照见此刻的心事。')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })

        // 功能卡片列表
        Scroll() {
          Column() {
            ForEach(this.buildEntries(), (entry: DivinationEntry, index: number) => {
              Row() {
                // 图标
                Text(entry.icon)
                  .fontSize(28)
                  .fontColor(Theme.V2C_GOLD_GILT)
                  .width(56)
                  .textAlign(TextAlign.Center)

                // 文字
                Column() {
                  Text(entry.title)
                    .fontSize(Theme.V2C_FONT_SUBTITLE)
                    .fontColor(Theme.V2C_TEXT_PRIMARY)
                    .fontWeight(FontWeight.Medium)

                  Text(entry.subtitle)
                    .fontSize(Theme.V2C_FONT_CAPTION)
                    .fontColor(Theme.V2C_TEXT_SECONDARY)
                    .margin({ top: 4 })
                    .lineHeight(18)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: Theme.SPACE_SM })

                // 箭头
                Text('›')
                  .fontSize(24)
                  .fontColor(Theme.V2C_GOLD_GILT)
              }
              .width('92%')
              .padding({ left: Theme.STARKEY_CARD_PADDING_H, right: Theme.STARKEY_CARD_PADDING_H, top: Theme.STARKEY_CARD_PADDING_V, bottom: Theme.STARKEY_CARD_PADDING_V })
              .margin({ bottom: Theme.SPACE_SM })
              .backgroundColor(Theme.V2C_BG_CARD)
              .borderRadius(Theme.V2C_RADIUS_CARD)
              .border({ width: 1, color: Theme.V2C_SPINE_LINE })
              .shadow(Theme.V2C_SHADOW_CARD)
              .scale({
                x: this.pressedIndex === index ? Theme.PRESS_SCALE : 1.0,
                y: this.pressedIndex === index ? Theme.PRESS_SCALE : 1.0
              })
              .animation({
                duration: Theme.ANIM_PRESS_DURATION,
                curve: Curve.EaseOut
              })
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.pressedIndex = index;
                } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                  this.pressedIndex = -1;
                }
              })
              .onClick(() => {
                entry.routeAction();
              })
            }, (_entry: DivinationEntry, index: number) => 'entry_' + index.toString())
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // 底部合规页脚
        ComplianceFooter({
          fontSize: Theme.V2C_FONT_CAPTION,
          textColor: Theme.V2C_TEXT_SECONDARY,
          showDivider: false,
        })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }
}

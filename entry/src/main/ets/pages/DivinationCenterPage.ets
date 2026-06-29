import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { Routes } from '../common/Routes';
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
 * 把「单牌快占 / 圣三角牌阵 / 关系探索 / 历史查看」统一收进一级入口
 */
@Entry
@Component
struct DivinationCenterPage {
  private buildEntries(): DivinationEntry[] {
    const entries: DivinationEntry[] = [
      {
        icon: '◇',
        title: '单牌快占',
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
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

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
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        // 副标题
        Text('用一张牌、一组牌阵，轻轻照见此刻的心事。')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
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
                  .fontColor('#E8B83D')
                  .width(56)
                  .textAlign(TextAlign.Center)

                // 文字
                Column() {
                  Text(entry.title)
                    .fontSize(Theme.FONT_SUBTITLE)
                    .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                    .fontWeight(FontWeight.Medium)

                  Text(entry.subtitle)
                    .fontSize(Theme.FONT_CAPTION)
                    .fontColor(Theme.MOON_MUTED)
                    .margin({ top: 4 })
                    .lineHeight(18)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: Theme.SPACE_SM })

                // 箭头
                Text('›')
                  .fontSize(24)
                  .fontColor(Theme.GOLD_DIM)
              }
              .width('92%')
              .padding(Theme.SPACE_MD)
              .margin({ bottom: Theme.SPACE_SM })
              .backgroundColor('rgba(27, 27, 48, 0.68)')
              .borderRadius(Theme.RADIUS_MD)
              .border({ width: 1, color: 'rgba(216, 180, 90, 0.12)' })
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

        // 底部合规
        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(11)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .lineHeight(16)
          .width('100%')
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 24 })
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

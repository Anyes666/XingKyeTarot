import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';

/**
 * 关于页入口配置
 */
interface AboutEntry {
  title: string;
  subtitle: string;
  routeUrl: string;
}

/**
 * Phase 6.4：关于星钥塔罗页
 * 包含：版本信息 / 隐私政策 / 用户协议 / 素材与授权
 */
@Entry
@Component
struct AboutPage {
  private entries: AboutEntry[] = [
    {
      title: '版本信息',
      subtitle: '查看当前版本与更新记录',
      routeUrl: Routes.VERSION_INFO
    },
    {
      title: '隐私政策',
      subtitle: '了解我们如何保护你的数据',
      routeUrl: Routes.PRIVACY_POLICY
    },
    {
      title: '用户协议',
      subtitle: '使用服务前请阅读条款',
      routeUrl: Routes.USER_AGREEMENT
    },
    {
      title: '素材与授权',
      subtitle: '背景音乐、插画与开源库授权说明',
      routeUrl: Routes.MATERIALS_LICENSE
    }
  ];

  private navigateTo(url: string): void {
    try {
      const options: router.RouterOptions = { url: url };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2A_BG_BASE)

      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.SETTINGS })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        .alignItems(VerticalAlign.Center)

        // 标题
        Text('关于星钥塔罗')
          .fontSize(Theme.V2A_FONT_TITLE)
          .fontColor(Theme.V2A_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .letterSpacing(2)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        // 说明文案
        Column() {
          Text('星钥塔罗是一款塔罗式情绪陪伴与自我探索 App。')
            .fontSize(Theme.V2A_FONT_BODY)
            .fontColor(Theme.V2A_TEXT_PRIMARY)
            .lineHeight(24)
            .width('100%')

          Text('星澜不会替你预言未来，只陪你慢慢看见自己。')
            .fontSize(Theme.V2A_FONT_BODY)
            .fontColor(Theme.V2A_TEXT_SECONDARY)
            .lineHeight(24)
            .width('100%')
            .margin({ top: Theme.SPACE_SM })
        }
        .width('92%')
        .backgroundColor(Theme.V2A_BG_CARD)
        .borderRadius(Theme.V2A_RADIUS_CARD)
        .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
        .padding(Theme.V2_SPACE_MD)
        .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_LG })

        // 入口列表
        Scroll() {
          Column() {
            ForEach(this.entries, (entry: AboutEntry, index: number) => {
              Row() {
                Column() {
                  Text(entry.title)
                    .fontSize(Theme.V2A_FONT_BODY)
                    .fontColor(Theme.V2A_TEXT_PRIMARY)
                    .fontWeight(FontWeight.Medium)

                  Text(entry.subtitle)
                    .fontSize(Theme.V2A_FONT_CAPTION)
                    .fontColor(Theme.V2A_TEXT_SECONDARY)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('›')
                  .fontSize(Theme.V2A_FONT_SUBTITLE)
                  .fontColor(Theme.V2A_GOLD_ACCENT)
              }
              .width('92%')
              .padding(Theme.V2_SPACE_MD)
              .margin({ bottom: Theme.SPACE_SM })
              .backgroundColor(Theme.V2A_BG_CARD)
              .borderRadius(Theme.V2A_RADIUS_CARD)
              .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
              .onClick(() => {
                this.navigateTo(entry.routeUrl);
              })
            }, (_entry: AboutEntry, index: number) => 'about_' + index.toString())
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
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

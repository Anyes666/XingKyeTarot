import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';

/**
 * Phase 6.4：版本信息页
 */
@Entry
@Component
struct VersionInfoPage {
  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.ABOUT })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        .alignItems(VerticalAlign.Center)

        // 标题
        Text('版本信息')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_LG })

        // 版本信息卡片
        Column() {
          // 应用名
          Text('星钥塔罗')
            .fontSize(Theme.FONT_TITLE)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%')

          // 版本号
          Text('v2.0.0')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.GOLD_LIGHT)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: Theme.SPACE_SM })

          Divider()
            .strokeWidth(0.5)
            .color(Theme.DEEP_STARRY)
            .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_MD })

          // 更新内容
          Text('更新内容')
            .fontSize(Theme.FONT_SUBTITLE)
            .fontColor(Theme.GOLD_LIGHT)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ bottom: Theme.SPACE_SM })

          Text(
            '· 底部导航重构：占卜 / 星澜聊天 / 星澜语录 / 卡牌总览 / 设置\n' +
            '· 新增占卜中心页，整合四种占卜入口\n' +
            '· 新增卡牌总览模块，78 张塔罗牌完整展示\n' +
            '· 新增设置页「关于星钥塔罗」模块\n' +
            '· 新增素材与授权页面\n' +
            '· 优化整体信息架构与页面组织'
          )
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .lineHeight(26)
            .width('100%')
        }
        .width('92%')
        .backgroundColor('rgba(27, 27, 48, 0.68)')
        .borderRadius(Theme.RADIUS_MD)
        .padding(Theme.SPACE_MD)

        Blank()
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

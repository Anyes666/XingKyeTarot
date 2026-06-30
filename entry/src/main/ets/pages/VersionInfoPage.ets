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

      Scroll() {
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
          Text('v1.0.0')
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
          Text('v1.0.0 更新内容')
            .fontSize(Theme.FONT_SUBTITLE)
            .fontColor(Theme.GOLD_LIGHT)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ bottom: Theme.SPACE_SM })

          Text(
            '· 全新底部导航栏：塔罗占卜 / 星澜聊天 / 星澜语录 / 卡牌总览 / 设置，五大模块一键切换\n' +
            '· 星澜 AI 陪伴聊天：基于本地文案库的情绪回应与追问，像朋友一样理解你\n' +
            '· 星澜语录：每日金句 + 心灵共鸣，随机语录滚动浏览\n' +
            '· 卡牌总览：78 张塔罗牌完整浏览，按大阿卡纳 / 权杖 / 圣杯 / 宝剑 / 星币分类筛选\n' +
            '· 每日一占：进入即抽牌，极速体验，30 秒获得金句与行动建议\n' +
            '· 圣三角占卜：过去 · 现在 · 未来三张牌逐张翻牌，完整牌阵解读\n' +
            '· 关系探索牌阵：我的状态 / 对方状态 / 关系走向，看清关系脉络\n' +
            '· 旋转牌轮：旋转式抽牌交互，沉浸式占卜体验\n' +
            '· 每日一占：每天固定抽一张牌，提供关键词与运势总结，支持桌面卡片同步\n' +
            '· 情绪问心：6 种情绪标签选择，精准匹配内心状态后抽牌\n' +
            '· 分享卡保存：占卜结果一键生成精美分享卡，保存至相册或复制文案分享\n' +
            '· 历史记录：占卜历史自动归档，支持按时间回看、详情回溯、记录管理\n' +
            '· 新手引导：3 屏滑动引导，帮助新用户快速了解应用功能\n' +
            '· 设置与隐私：背景音乐开关、隐私数据管理、关于页面与版本信息\n' +
            '· 新中式星空视觉风格：深蓝紫底色 + 温润金色点缀 + 精致塔罗牌翻牌动画'
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
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: Theme.SPACE_LG })
      }
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }
}

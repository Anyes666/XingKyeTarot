import { Theme } from '../common/Theme';
import { LegalDocuments } from '../common/LegalDocuments';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';

/**
 * 用户协议全文展示页
 */
@Entry
@Component
struct UserAgreementPage {
  build() {
    Column() {
      // ── 顶部导航栏（P0.3 整改：统一返回按钮）──
      Row() {
        AppBackButton({ fallbackUrl: Routes.LAUNCH })

        Blank()

        Text(LegalDocuments.USER_AGREEMENT_TITLE)
          .fontSize(Theme.FONT_SUBTITLE)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)

        Blank()

        Text('    ')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Color.Transparent)
      }
      .width('100%')
      .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, top: 48, bottom: Theme.SPACE_MD })
      .backgroundColor(Theme.BG_DEEP_INDIGO)

      // ── 分割线 ──
      Divider()
        .strokeWidth(0.5)
        .color(Theme.DEEP_STARRY)

      // ── 内容区（可滚动）──
      Scroll() {
        Text(LegalDocuments.USER_AGREEMENT)
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .lineHeight(24)
          .width('100%')
          .padding({
            left: Theme.SPACE_LG,
            right: Theme.SPACE_LG,
            top: Theme.SPACE_LG,
            bottom: Theme.SPACE_XXL
          })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
  }
}

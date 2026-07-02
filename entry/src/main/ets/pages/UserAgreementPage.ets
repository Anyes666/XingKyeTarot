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
      // ── 顶部导航栏（A 星图档案）──
      Row() {
        AppBackButton({ fallbackUrl: Routes.LAUNCH })

        Blank()

        Text(LegalDocuments.USER_AGREEMENT_TITLE)
          .fontSize(Theme.V2A_FONT_SUBTITLE)
          .fontColor(Theme.V2A_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .letterSpacing(1)
          .textAlign(TextAlign.Center)

        Blank()

        Text('    ')
          .fontSize(Theme.V2A_FONT_BODY)
          .fontColor(Color.Transparent)
      }
      .width('100%')
      .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, top: Theme.SAFE_TOP, bottom: Theme.SPACE_SM })
      .backgroundColor(Theme.V2A_BG_BASE)

      // ── 星轨分割线 ──
      Divider()
        .strokeWidth(0.5)
        .color(Theme.V2A_ORBIT_LINE)

      // ── 内容区（可滚动）──
      Scroll() {
        Text(LegalDocuments.USER_AGREEMENT)
          .fontSize(Theme.V2A_FONT_BODY)
          .fontColor(Theme.V2A_TEXT_PRIMARY)
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
    .backgroundColor(Theme.V2A_BG_BASE)
  }
}

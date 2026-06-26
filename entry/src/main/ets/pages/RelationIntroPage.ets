import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';

/**
 * 关系探索抽牌页路由参数
 */
interface RelationDrawRouteParams {
  questionText: string;
  relationType: string;
}

/**
 * 关系探索介绍页
 */
@Entry
@Component
struct RelationIntroPage {
  @State questionText: string = '';
  @State relationType: string = '暧昧';
  @State relationTypes: string[] = ['暧昧', '恋人', '前任', '朋友', '同事', '家人'];

  build() {
    Column() {
      // ── P0.3 整改：左上角统一返回按钮（左边距压缩到 4vp，靠边但不贴屏）──
      Row() {
        AppBackButton({ fallbackUrl: Routes.HOME })
      }
      .width('100%')
      .padding({ top: Theme.SAFE_TOP, left: 4 })

      // ── 标题区 ──
      Column() {
        Text('💞 关系探索')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: 0 })

        Text('看见我、对方与这段关系的走向')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .margin({ top: Theme.SPACE_SM })
      }
      .width('100%')
      .margin({ bottom: Theme.SPACE_XL })

      // ── 说明卡片 ──
      Column() {
        Text('关系探索牌阵通过三张牌，分别揭示：')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .margin({ bottom: Theme.SPACE_MD })

        Text('🔹 第一张 · 我 —— 你在这段关系中的状态与感受\n🔹 第二张 · 对方 —— 对方的状态或对你的影响\n🔹 第三张 · 走向 —— 这段关系的可能发展方向')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .lineHeight(22)
          .margin({ bottom: Theme.SPACE_MD })

        Text('注意：关系牌阵不能替代真实沟通，它只是一面镜子，帮你看清自己。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD_AMBER)
          .fontStyle(FontStyle.Italic)
      }
      .width('100%')
      .padding(Theme.SPACE_LG)
      .backgroundColor(Theme.BG_CARD_DARK)
      .borderRadius(Theme.RADIUS_MD)
      .border({ width: 1, color: 'rgba(202, 138, 4, 0.15)' })
      .margin({ bottom: Theme.SPACE_XL })

      // ── 关系类型选择（Flex 自动换行，防止横向溢出）──
      Column() {
        Text('你们是什么关系？')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .width('100%')
          .margin({ bottom: Theme.SPACE_MD })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.relationTypes, (rtype: string) => {
            Text(rtype)
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(this.relationType === rtype ? Theme.BG_DEEP_INDIGO : Theme.GOLD_AMBER)
              .fontWeight(FontWeight.Medium)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .margin({ right: 10, bottom: 10 })
              .backgroundColor(this.relationType === rtype ? Theme.GOLD_AMBER : 'rgba(202, 138, 4, 0.1)')
              .borderRadius(Theme.RADIUS_FULL)
              .border({ width: 1, color: 'rgba(202, 138, 4, 0.25)' })
              .onClick(() => {
                this.relationType = rtype;
              })
          }, (rtype: string) => rtype)
        }
        .width('100%')
      }
      .width('100%')
      .margin({ bottom: Theme.SPACE_XL })

      // ── 问题输入 ──
      Column() {
        Text('你想看清什么？（可选）')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .width('100%')
          .margin({ bottom: Theme.SPACE_SM })

        TextInput({ placeholder: '我想看清我和TA之间的关系...', text: this.questionText })
          .width('100%')
          .height(48)
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .placeholderColor(Theme.MOON_MUTED)
          .backgroundColor(Theme.BG_CARD_DARK)
          .borderRadius(Theme.RADIUS_SM)
          .border({ width: 1, color: 'rgba(202, 138, 4, 0.15)' })
          .onChange((value: string) => {
            this.questionText = value;
          })
      }
      .width('100%')

      Blank()

      // ── 开始按钮 ──
      Button('开始抽牌')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .width('85%')
        .height(52)
        .backgroundColor(Theme.GOLD_AMBER)
        .borderRadius(Theme.RADIUS_FULL)
        .margin({ bottom: Theme.SPACE_MD })
        .onClick(() => {
          const drawParams: RelationDrawRouteParams = {
            questionText: this.questionText || '我想看清我和TA之间的关系',
            relationType: this.relationType,
          };
          try {
            router.pushUrl({
              url: Routes.RELATION_DRAW,
              params: drawParams,
            });
          } catch (_err) {
            // ignore
          }
        })

      // ── 合规页脚 ──
      ComplianceFooter({ fontSize: Theme.FONT_CAPTION, textColor: Theme.MOON_MUTED, showDivider: false })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
    .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: Theme.SAFE_BOTTOM })
  }
}

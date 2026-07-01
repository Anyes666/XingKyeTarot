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
    Stack() {
      // ── 全页可滚动 ──
      Scroll() {
        Column() {
          // ── 标题区 ──
          Column() {
            Text('关系探索')
              .fontSize(Theme.V2C_FONT_DISPLAY)
              .fontColor(Theme.V2C_GOLD_GILT)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)

            Text('看见我、对方与这段关系的走向')
              .fontSize(Theme.V2C_FONT_SUBTITLE)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .margin({ top: Theme.SPACE_SM })
          }
          .width('100%')
          .padding({ top: 80 })

          // ── 说明卡片 ──
          Column() {
            Text('关系探索牌阵通过三张牌，分别揭示：')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .margin({ bottom: Theme.SPACE_MD })

            Text('🔹 第一张 · 我 —— 你在这段关系中的状态与感受\n🔹 第二张 · 对方 —— 对方的状态或对你的影响\n🔹 第三张 · 走向 —— 这段关系的可能发展方向')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .lineHeight(22)
              .margin({ bottom: Theme.SPACE_MD })

            Text('注意：关系牌阵不能替代真实沟通，它只是一面镜子，帮你看清自己。')
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_GOLD_GILT_SOFT)
              .fontStyle(FontStyle.Italic)
          }
          .width('100%')
          .padding(Theme.V2_SPACE_LG)
          .backgroundColor(Theme.V2C_BG_CARD)
          .borderRadius(Theme.V2C_RADIUS_CARD)
          .border({ width: 1, color: Theme.V2C_SPINE_LINE })
          .margin({ top: Theme.V2_SPACE_XL, bottom: Theme.V2_SPACE_XL })

          // ── 关系类型选择（Flex 自动换行，防止横向溢出）──
          Column() {
            Text('你们是什么关系？')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .width('100%')
              .margin({ bottom: Theme.SPACE_MD })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.relationTypes, (rtype: string) => {
                Text(rtype)
                  .fontSize(Theme.FONT_CAPTION)
                  .fontColor(this.relationType === rtype ? Color.White : Theme.V2C_GOLD_GILT)
                  .fontWeight(FontWeight.Medium)
                  .height(44)
                  .padding({ left: 14, right: 14, top: 0, bottom: 0 })
                  .textAlign(TextAlign.Center)
                  .margin({ right: 10, bottom: 10 })
                  .backgroundColor(this.relationType === rtype ? Theme.V2C_GOLD_GILT : Theme.V2C_BG_CARD)
                  .borderRadius(Theme.V2_RADIUS_FULL)
                  .border({ width: 1, color: this.relationType === rtype ? Theme.V2C_GOLD_GILT : Theme.V2C_SPINE_LINE })
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
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .width('100%')
              .margin({ bottom: Theme.SPACE_SM })

            TextInput({ placeholder: '我想看清我和TA之间的关系...', text: this.questionText })
              .width('100%')
              .height(48)
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .placeholderColor(Theme.V2C_TEXT_SECONDARY)
              .backgroundColor(Theme.V2C_BG_CARD)
              .borderRadius(Theme.V2C_RADIUS_BTN)
              .border({ width: 1, color: Theme.V2C_SPINE_LINE })
              .onChange((value: string) => {
                this.questionText = value;
              })
          }
          .width('100%')
          .margin({ bottom: Theme.SPACE_XL })

          // ── 开始按钮 ──
          Button('开始抽牌')
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_BG_BASE)
            .fontWeight(FontWeight.Medium)
            .width('85%')
            .height(56)
            .backgroundColor(Theme.V2C_GOLD_GILT)
            .borderRadius(Theme.V2_RADIUS_FULL)
            .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })
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
          ComplianceFooter({ fontSize: Theme.V2C_FONT_CAPTION, textColor: Theme.V2C_TEXT_SECONDARY, showDivider: false })
        }
        .width('100%')
        .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: 112 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(Theme.V2C_BG_BASE)

      // 顶部渐变遮罩（消除状态栏硬边）
      Column()
        .width('100%')
        .height(Theme.SAFE_TOP + 64)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#0A0D1A', 0], ['rgba(15,15,35,0)', 1]]
        })
        .hitTestBehavior(HitTestMode.Transparent)
        .position({ x: 0, y: 0 })

      AppBackButton({ fallbackUrl: Routes.HOME })
        .position({ x: 12, y: Theme.SAFE_TOP + 6 })
    }
    .width('100%')
    .height('100%')
  }
}

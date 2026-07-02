import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { BoundaryReminder } from '../components/BoundaryReminder';

interface RelationMeaningInfo {
  indexText: string;
  title: string;
  body: string;
}

const RELATION_MEANINGS: RelationMeaningInfo[] = [
  {
    indexText: '01',
    title: '我',
    body: '看看你在这段关系里的状态、感受和真实需要。'
  },
  {
    indexText: '02',
    title: '对方',
    body: '观察对方在互动中呈现出的状态，以及它对你的影响。'
  },
  {
    indexText: '03',
    title: '走向',
    body: '整理这段关系当前可能显露的趋势，作为观察角度，不代表固定答案。'
  }
];

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
  @State private isInputFocused: boolean = false;

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2C_BG_BASE)

      Column()
        .width('100%')
        .height(220)
        .radialGradient({
          center: ['50%', '10%'],
          radius: '65%',
          colors: [
            ['rgba(197,160,80,0.052)', 0.0],
            ['rgba(197,160,80,0.012)', 0.56],
            ['rgba(10,13,26,0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      // ── 全页可滚动 ──
      Scroll() {
        Column() {
          // ── 标题区 ──
          Column() {
            Text('星钥之书 · 关系探索')
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .margin({ bottom: Theme.V2_SPACE_MD })

            Row()
              .width(44)
              .height(1)
              .backgroundColor(Theme.V2C_GOLD_GILT)
              .opacity(0.32)
              .margin({ bottom: Theme.V2_SPACE_MD })

            Text('不猜对方的心，先看见关系里的自己')
              .fontSize(Theme.V2C_FONT_TITLE)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .lineHeight(36)

            Text('这组三张牌不会替你判断对方的心意，\n也不会替你决定留下或离开。\n\n它只陪你看看，\n这段关系正在给你怎样的感受，\n以及哪些需要和边界值得被认真看见。')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .lineHeight(24)
              .margin({ top: Theme.V2_SPACE_MD })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 80 })

          // ── 说明卡片 ──
          Column() {
            Row() {
              Text('牌位说明')
                .fontSize(Theme.V2C_FONT_CAPTION)
                .fontColor(Theme.V2C_GOLD_GILT)
                .fontWeight(FontWeight.Medium)

              Blank()

              Row()
                .width(38)
                .height(1)
                .backgroundColor(Theme.V2C_GOLD_GILT)
                .opacity(0.22)
            }
            .width('100%')
            .margin({ bottom: Theme.V2_SPACE_MD })

            Column({ space: Theme.V2_SPACE_MD }) {
              ForEach(RELATION_MEANINGS, (item: RelationMeaningInfo) => {
                Row({ space: Theme.V2_SPACE_MD }) {
                  Text(item.indexText)
                    .fontSize(Theme.V2C_FONT_CAPTION)
                    .fontColor(Theme.V2C_GOLD_GILT)
                    .width(34)
                    .height(34)
                    .textAlign(TextAlign.Center)
                    .backgroundColor('rgba(197, 160, 80, 0.06)')
                    .borderRadius(Theme.V2C_RADIUS_CHIP)
                    .border({ width: 1, color: 'rgba(197, 160, 80, 0.18)' })

                  Column() {
                    Text(item.title)
                      .fontSize(Theme.V2C_FONT_BODY)
                      .fontColor(Theme.V2C_TEXT_PRIMARY)
                      .fontWeight(FontWeight.Bold)
                      .width('100%')

                    Text(item.body)
                      .fontSize(Theme.V2C_FONT_CAPTION)
                      .fontColor(Theme.V2C_TEXT_SECONDARY)
                      .lineHeight(20)
                      .width('100%')
                      .margin({ top: 3 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
              }, (item: RelationMeaningInfo) => item.title)
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG, top: Theme.V2_SPACE_LG, bottom: Theme.V2_SPACE_LG })
          .backgroundColor(Theme.V2C_BG_CARD)
          .borderRadius(Theme.V2C_RADIUS_CARD)
          .border({ width: 1, color: 'rgba(197, 160, 80, 0.14)' })
          .shadow(Theme.V2C_SHADOW_CARD)
          .margin({ top: Theme.V2_SPACE_XL, bottom: Theme.V2_SPACE_LG })

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
                  .fontColor(this.relationType === rtype ? Theme.V2C_GOLD_GILT_SOFT : Theme.V2C_TEXT_SECONDARY)
                  .fontWeight(FontWeight.Medium)
                  .height(40)
                  .padding({ left: 14, right: 14, top: 0, bottom: 0 })
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.relationType === rtype ? 'rgba(197, 160, 80, 0.10)' : 'rgba(18, 24, 54, 0.62)')
                  .borderRadius(Theme.V2C_RADIUS_CHIP)
                  .border({ width: 1, color: this.relationType === rtype ? 'rgba(197, 160, 80, 0.42)' : Theme.V2C_SPINE_LINE })
                  .margin({ right: Theme.V2_SPACE_XS, bottom: Theme.V2_SPACE_XS })
                  .onClick(() => {
                    this.relationType = rtype;
                  })
              }, (rtype: string) => rtype)
            }
            .width('100%')
          }
          .width('100%')
          .margin({ bottom: Theme.V2_SPACE_LG })

          // ── 问题输入 ──
          Column() {
            Text('你想看清什么？（可选）')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: Theme.V2_SPACE_SM })

            TextInput({ placeholder: '我想看清我和TA之间的关系...', text: this.questionText })
              .width('100%')
              .height(54)
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .placeholderColor(Theme.V2C_TEXT_SECONDARY)
              .backgroundColor('#0D1228')
              .borderRadius(Theme.V2C_RADIUS_BTN)
              .border({ width: 1, color: this.isInputFocused ? 'rgba(197, 160, 80, 0.34)' : Theme.V2C_SPINE_LINE })
              .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD })
              .onChange((value: string) => {
                this.questionText = value;
              })
              .onFocus(() => {
                this.isInputFocused = true;
              })
              .onBlur(() => {
                this.isInputFocused = false;
              })
          }
          .width('100%')
          .padding(Theme.V2_SPACE_LG)
          .backgroundColor('rgba(18, 24, 54, 0.72)')
          .borderRadius(Theme.V2C_RADIUS_CARD)
          .border({ width: 1, color: Theme.V2C_SPINE_LINE })
          .margin({ bottom: Theme.V2_SPACE_MD })

          BoundaryReminder({
            text: '这次探索只整理你的感受和关系体验。星澜不会猜测第三方内心，不会预测关系结局，也不会替你做决定。',
            showAccentLine: true
          })
            .margin({ bottom: Theme.V2_SPACE_LG })

          // ── 开始按钮 ──
          Button('开始抽牌')
            .type(ButtonType.Normal)
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_GOLD_GILT)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .height(52)
            .backgroundColor('rgba(197, 160, 80, 0.08)')
            .borderRadius(Theme.V2C_RADIUS_BTN)
            .border({ width: 1, color: 'rgba(197, 160, 80, 0.42)' })
            .margin({ top: Theme.V2_SPACE_XS, bottom: Theme.V2_SPACE_SM })
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

          Text('也可以带着一个还说不清的问题开始，先把自己的感受放到桌面上。')
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .lineHeight(20)
            .width('100%')
            .margin({ bottom: Theme.V2_SPACE_LG })

          // ── 合规页脚 ──
          ComplianceFooter({ fontSize: Theme.V2C_FONT_CAPTION, textColor: Theme.V2C_TEXT_SECONDARY, showDivider: false })
        }
        .width('100%')
        .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: 112 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

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

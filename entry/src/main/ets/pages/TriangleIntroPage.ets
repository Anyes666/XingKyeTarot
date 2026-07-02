import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';

interface TriangleMeaningInfo {
  indexText: string;
  title: string;
  body: string;
}

const TRIANGLE_MEANINGS: TriangleMeaningInfo[] = [
  {
    indexText: '01',
    title: '过去',
    body: '帮助你回看已经发生、仍在影响当下的部分。'
  },
  {
    indexText: '02',
    title: '现在',
    body: '帮助你看见当前最明显的感受、处境或矛盾。'
  },
  {
    indexText: '03',
    title: '可能的方向',
    body: '提供一个可以观察或尝试靠近的方向，不代表固定未来。'
  }
];

/**
 * 圣三角介绍页面路由参数
 */
interface TriangleDrawRouteParams {
  questionText: string;
  scenarioTag: string;
}

/**
 * 圣三角牌阵介绍页
 *
 * 用户可输入问题、选择场景，进入三牌翻牌流程。
 */
@Entry
@Component
struct TriangleIntroPage {
  @State questionText: string = '';
  @State scenarioTag: string = '综合';
  @State scenarioOptions: string[] = ['感情', '工作', '学业', '财富', '综合'];
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
            ['rgba(197,160,80,0.055)', 0.0],
            ['rgba(197,160,80,0.012)', 0.55],
            ['rgba(10,13,26,0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      // ── 全页可滚动 ──
      Scroll() {
        Column() {
          // ── 标题区 ──
          Column() {
            Text('星钥之书 · 圣三角')
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .letterSpacing(0)
              .margin({ bottom: Theme.V2_SPACE_MD })

            Row()
              .width(44)
              .height(1)
              .backgroundColor(Theme.V2C_GOLD_GILT)
              .opacity(0.36)
              .margin({ bottom: Theme.V2_SPACE_MD })

            Text('把一件事，放到三个位置里慢慢看看')
              .fontSize(Theme.V2C_FONT_TITLE)
              .fontColor(Theme.V2C_GOLD_GILT)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .lineHeight(36)

            Text('三张牌不会替你预告未来。\n它们会分别陪你看看：过去留下了什么，现在正在发生什么，以及一个可能靠近的方向。')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .lineHeight(24)
              .margin({ top: Theme.V2_SPACE_MD })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 84 })

          // ── 说明卡片 ──
          Column() {
            Row() {
              Text('牌阵说明')
                .fontSize(Theme.V2C_FONT_CAPTION)
                .fontColor(Theme.V2C_GOLD_GILT)
                .fontWeight(FontWeight.Medium)

              Blank()

              Row()
                .width(38)
                .height(1)
                .backgroundColor(Theme.V2C_GOLD_GILT)
                .opacity(0.24)
            }
            .width('100%')
            .margin({ bottom: Theme.V2_SPACE_MD })

            Column({ space: Theme.V2_SPACE_MD }) {
              ForEach(TRIANGLE_MEANINGS, (item: TriangleMeaningInfo) => {
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
              }, (item: TriangleMeaningInfo) => item.title)
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

          // ── 问题输入 ──
          Column() {
            Text('你想看清哪件事？')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: Theme.V2_SPACE_SM })

            TextInput({ placeholder: '例如：我想看清最近卡住的一件事', text: this.questionText })
              .width('100%')
              .height(54)
              .fontSize(Theme.FONT_BODY)
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
          .margin({ bottom: Theme.V2_SPACE_LG })

          // ── 场景选择 ──
          Column() {
            Text('选择一个场景')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .width('100%')
              .margin({ bottom: Theme.V2_SPACE_MD })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.scenarioOptions, (tag: string) => {
                Text(tag)
                  .fontSize(Theme.FONT_CAPTION)
                  .fontColor(this.scenarioTag === tag ? Theme.V2C_GOLD_GILT_SOFT : Theme.V2C_TEXT_SECONDARY)
                  .fontWeight(FontWeight.Medium)
                  .height(40)
                  .padding({ left: 14, right: 14, top: 0, bottom: 0 })
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.scenarioTag === tag ? 'rgba(197, 160, 80, 0.10)' : 'rgba(18, 24, 54, 0.62)')
                  .borderRadius(Theme.V2C_RADIUS_CHIP)
                  .border({ width: 1, color: this.scenarioTag === tag ? 'rgba(197, 160, 80, 0.42)' : Theme.V2C_SPINE_LINE })
                  .margin({ right: Theme.V2_SPACE_XS, bottom: Theme.V2_SPACE_XS })
                  .onClick(() => {
                    this.scenarioTag = tag;
                  })
              }, (tag: string) => tag)
            }
            .width('100%')
          }
          .width('100%')
          .margin({ bottom: Theme.V2_SPACE_LG })

          // ── 开始按钮 ──
          Button('开始展开圣三角')
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
              const drawParams: TriangleDrawRouteParams = {
                questionText: this.questionText || '我想看清最近卡住的一件事',
                scenarioTag: this.scenarioTag,
              };
              try {
                router.pushUrl({
                  url: Routes.TRIANGLE_DRAW,
                  params: drawParams,
                });
              } catch (_err) {
                // ignore
              }
            })

          Text('也可以带着一个还不清楚的问题开始，先让它被看见。')
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

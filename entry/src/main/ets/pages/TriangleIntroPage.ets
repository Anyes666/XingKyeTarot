import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';

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

  build() {
    Stack() {
      // ── 全页可滚动 ──
      Scroll() {
        Column() {
          // ── 标题区 ──
          Column() {
            Text('圣三角')
              .fontSize(Theme.V2C_FONT_DISPLAY)
              .fontColor(Theme.V2C_GOLD_GILT)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)

            Text('看见一件事的过去、现在与未来')
              .fontSize(Theme.V2C_FONT_SUBTITLE)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .margin({ top: Theme.SPACE_SM })
          }
          .width('100%')
          .padding({ top: 80 })

          // ── 说明卡片 ──
          Column() {
            Text('圣三角是最经典的塔罗牌阵之一，由三张牌组成，分别代表：')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .margin({ bottom: Theme.SPACE_MD })

            Text('🔹 第一张 · 过去 —— 事件的基础，已经发生的影响因素\n🔹 第二张 · 现在 —— 当前的状态，正在发生的核心\n🔹 第三张 · 未来 —— 可能的发展方向')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .lineHeight(22)
              .margin({ bottom: Theme.SPACE_MD })

            Text('星澜会帮你展开这三段线索，看到事情的完整脉络。')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_GOLD_GILT)
          }
          .width('100%')
          .padding(Theme.V2_SPACE_LG)
          .backgroundColor(Theme.V2C_BG_CARD)
          .borderRadius(Theme.V2C_RADIUS_CARD)
          .border({ width: 1, color: Theme.V2C_SPINE_LINE })
          .margin({ top: Theme.SPACE_XL, bottom: Theme.SPACE_XL })

          // ── 问题输入 ──
          Column() {
            Text('你想看清哪件事？')
              .fontSize(Theme.V2C_FONT_SUBTITLE)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: Theme.SPACE_SM })

            TextInput({ placeholder: '我想看清最近卡住的一件事', text: this.questionText })
              .width('100%')
              .height(48)
              .fontSize(Theme.FONT_BODY)
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

          // ── 场景选择 ──
          Column() {
            Text('选择一个场景：')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .width('100%')
              .margin({ bottom: Theme.SPACE_MD })

            Row({ space: Theme.SPACE_SM }) {
              ForEach(this.scenarioOptions, (tag: string) => {
                Text(tag)
                  .fontSize(Theme.FONT_CAPTION)
                  .fontColor(this.scenarioTag === tag ? Color.White : Theme.V2C_GOLD_GILT)
                  .fontWeight(FontWeight.Medium)
                  .height(44)
                  .padding({ left: 14, right: 14, top: 0, bottom: 0 })
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.scenarioTag === tag ? Theme.V2C_GOLD_GILT : Theme.V2C_BG_CARD)
                  .borderRadius(Theme.V2_RADIUS_FULL)
                  .border({ width: 1, color: this.scenarioTag === tag ? Theme.V2C_GOLD_GILT : Theme.V2C_SPINE_LINE })
                  .onClick(() => {
                    this.scenarioTag = tag;
                  })
              }, (tag: string) => tag)
            }
            .width('100%')
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

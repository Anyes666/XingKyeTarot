import { router } from '@kit.ArkUI';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';

// ===== 路由参数接口 =====
interface FollowUpRouteParams {
  cardId: string
  cardName: string
  emotionTag: string
  heartOptionIndex: number
  goldenSentence: string
}

// ===== 追问选项文案 =====
const QUESTION_UNCERTAIN: string = '我最难受的是不确定';
const QUESTION_KNOW: string = '我其实知道答案，但舍不得';
const QUESTION_MIXED: string = '我说不清，好像两个都有';

// ===== 追问回应文案 =====
const RESPONSE_UNCERTAIN: string = '星澜明白。不确定感像在迷雾中行走，每走一步都怕踩空。但你已经很勇敢了——能说出「不确定」，本身就是一种确定。';
const RESPONSE_KNOW: string = '星澜轻轻点头。承认自己早就知道答案，是一种很深的诚实。有时候我们只是需要一张牌来帮自己确认，这不是软弱。';
const RESPONSE_MIXED: string = '星澜感受到了。复杂的心绪里藏着真实的自己。不急，慢慢来，答案会在合适的时候浮现。';

// fallback：取不到回应时
const RESPONSE_FALLBACK: string = '星澜暂时没有找到这句回应，但你的感受已经被看见了。先回到结果页，给自己一点时间。';

@Entry
@Component
struct FollowUpPage {
  @State cardId: string = '';
  @State cardName: string = '';
  @State emotionTag: string = '';
  @State heartOptionIndex: number = 0;
  @State goldenSentence: string = '';
  // -1 = 未选择（显示三个选项）；0/1/2 = 已选择某项（只显示该项 + 回应）
  @State selectedIndex: number = -1;
  @State selectedQuestion: string = '';
  @State selectedAnswer: string = '';

  aboutToAppear(): void {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params: FollowUpRouteParams = rawParams as FollowUpRouteParams;
      this.cardId = params.cardId || '';
      this.cardName = params.cardName || '';
      this.emotionTag = params.emotionTag || '';
      this.heartOptionIndex = params.heartOptionIndex || 0;
      this.goldenSentence = params.goldenSentence || '';
    }
  }

  /**
   * 选择某一项追问。选中后不可再选。
   */
  private selectQuestion(index: number): void {
    // 防覆盖：已选择则忽略后续点击
    if (this.selectedIndex >= 0) {
      return;
    }
    this.selectedIndex = index;
    if (index === 0) {
      this.selectedQuestion = QUESTION_UNCERTAIN;
      this.selectedAnswer = RESPONSE_UNCERTAIN;
    } else if (index === 1) {
      this.selectedQuestion = QUESTION_KNOW;
      this.selectedAnswer = RESPONSE_KNOW;
    } else if (index === 2) {
      this.selectedQuestion = QUESTION_MIXED;
      this.selectedAnswer = RESPONSE_MIXED;
    } else {
      this.selectedQuestion = '';
      this.selectedAnswer = RESPONSE_FALLBACK;
    }
  }

  build() {
    Column() {
      // ── 左上角统一返回按钮 ──
      Row() {
        AppBackButton({ fallbackUrl: Routes.HOME })
      }
      .width('100%')
      .padding({ top: 48 })

      // ── 月亮 icon ──
      Text('🌙')
        .fontSize(36)
        .margin({ top: 24, bottom: 12 })

      // ── 状态分支：未选择 / 已选择 ──
      if (this.selectedIndex < 0) {
        // ===== 未选择状态：显示标题 + 引导 + 三个选项 =====
        Text('星澜想轻轻问你一句')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E5D9B6')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 8 })

        Text('选一句最像你此刻心里的话。')
          .fontSize(16)
          .fontColor('#A0906E')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 32 })

        // 金句回顾
        Text(this.goldenSentence)
          .fontSize(14)
          .fontColor('#8B7A5C')
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('85%')
          .margin({ bottom: 32 })

        // 三个追问选项
        Column({ space: 14 }) {
          Button(QUESTION_UNCERTAIN)
            .type(ButtonType.Normal)
            .fontSize(20)
            .fontColor('#F8FAFC')
            .backgroundColor('#1E1B3A')
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.25)' })
            .borderRadius(20)
            .width('88%')
            .height(76)
            .onClick(() => this.selectQuestion(0))

          Button(QUESTION_KNOW)
            .type(ButtonType.Normal)
            .fontSize(20)
            .fontColor('#F8FAFC')
            .backgroundColor('#1E1B3A')
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.25)' })
            .borderRadius(20)
            .width('88%')
            .height(76)
            .onClick(() => this.selectQuestion(1))

          Button(QUESTION_MIXED)
            .type(ButtonType.Normal)
            .fontSize(20)
            .fontColor('#F8FAFC')
            .backgroundColor('#1E1B3A')
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.25)' })
            .borderRadius(20)
            .width('88%')
            .height(76)
            .onClick(() => this.selectQuestion(2))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)

      } else {
        // ===== 已选择状态：只显示选中问题 + 星澜回应 =====
        Text('星澜听见了')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E5D9B6')
          .textAlign(TextAlign.Center)
          .margin({ top: 8, bottom: 24 })

        // 用户刚刚选择的问题（小卡片）
        Column() {
          Text('你刚刚选择的是：')
            .fontSize(14)
            .fontColor('#8B7A5C')
            .margin({ bottom: 6 })
          Text('「' + this.selectedQuestion + '」')
            .fontSize(18)
            .fontColor('#CA8A04')
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
        }
        .width('82%')
        .padding(16)
        .backgroundColor('#1A1A2E')
        .border({ width: 1, color: 'rgba(202, 138, 4, 0.18)' })
        .borderRadius(16)
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 28 })

        // 星澜回应卡片（字号放大，更像"星澜认真回应你一句"）
        Column() {
          Text('星澜想对你说：')
            .fontSize(15)
            .fontColor('#A0906E')
            .margin({ bottom: 14 })

          Text(this.selectedAnswer)
            .fontSize(23)
            .fontColor('#F6E6B8')
            .lineHeight(36)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
        }
        .width('88%')
        .padding(24)
        .backgroundColor('#17172F')
        .border({ width: 1, color: 'rgba(202, 138, 4, 0.22)' })
        .borderRadius(24)
        .alignItems(HorizontalAlign.Center)
      }

      Blank()

      // ── 底部「← 回到结果页」按钮（两种状态都保留）──
      Button('← 回到结果页')
        .type(ButtonType.Normal)
        .fontSize(18)
        .fontColor('#E5D9B6')
        .backgroundColor('#1A1A2E')
        .border({ width: 1, color: 'rgba(202, 138, 4, 0.35)' })
        .borderRadius(22)
        .width('76%')
        .height(48)
        .margin({ bottom: 40 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F0F23')
  }
}

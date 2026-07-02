import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { TarotCardImage } from '../components/TarotCardImage';
import { TarotCardRepository, DrawCardResult } from '../data/TarotCardRepository';
import { MVP8_CARD_IMAGES, MVP8_CARD_NAMES, getMVP8CardData, getScenarioContent } from '../data/MVP8CardsData';
import { EmotionTag } from '../model/TarotCard';
import { HEART_OPTIONS } from '../data/HeartOptionsData';

/**
 * 圣三角抽牌页路由参数
 */
interface TriangleDrawInParams {
  questionText: string;
  scenarioTag: string;
}

/**
 * 圣三角结果页路由参数
 */
interface TriangleResultRouteParams {
  questionText: string;
  scenarioTag: string;
  cards: CardSlotInfo[];
}

interface CardSlotInfo {
  positionKey: string;
  positionTitle: string;
  cardId: string;
  cardName: string;
  isReversed: boolean;
  keyword: string;
  goldenSentence: string;
  brief: string;
  action: string;
}

// 圣三角牌位定义
const TRIANGLE_POSITIONS: CardSlotBaseInfo[] = [
  { positionKey: 'past', positionTitle: '过去' },
  { positionKey: 'present', positionTitle: '现在' },
  { positionKey: 'future', positionTitle: '可能的方向' },
];

interface CardSlotBaseInfo {
  positionKey: string;
  positionTitle: string;
}

/**
 * 圣三角抽牌动画页
 *
 * 三张牌依次翻开（animateTo, 间隔 0.8s）
 */
@Entry
@Component
struct TriangleDrawPage {
  @State questionText: string = '';
  @State scenarioTag: string = '综合';
  @State private cardSlots: CardSlotInfo[] = [];
  @State private revealedSlots: boolean[] = [false, false, false];
  @State private isAnimDone: boolean = false;
  @State private currentRevealIndex: number = 0;
  // ── Timer 生命周期管理 ──
  private isPageAlive: boolean = true;
  private timerIds: number[] = [];

  aboutToAppear(): void {
    this.isPageAlive = true;
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params = rawParams as TriangleDrawInParams;
      this.questionText = params.questionText ?? '我想看清最近卡住的一件事';
      this.scenarioTag = params.scenarioTag ?? '综合';
    }

    // 抽取三张不重复的牌
    const draws: DrawCardResult[] = TarotCardRepository.drawUniqueCards(3);

    this.cardSlots = [];
    for (let i: number = 0; i < draws.length; i++) {
      const draw: DrawCardResult = draws[i];
      const pos: CardSlotBaseInfo = TRIANGLE_POSITIONS[i];
      const cardName: string = MVP8_CARD_NAMES[draw.cardId] ?? '';
      const keyword: string = TarotCardRepository.getCardKeyword(draw.cardId);

      const emotionTag: EmotionTag = this.mapScenarioToEmotionTag(this.scenarioTag);
      const scenario = getScenarioContent(draw.cardId, emotionTag);
      const golden: string = scenario ? scenario.goldenSentence : '';
      const action: string = scenario ? scenario.todayAction : '';

      const mvpData = getMVP8CardData(draw.cardId);
      const brief: string = mvpData ? mvpData.cardMeaningBrief : '';

      const slot: CardSlotInfo = {
        positionKey: pos.positionKey,
        positionTitle: pos.positionTitle,
        cardId: draw.cardId,
        cardName: cardName,
        isReversed: draw.isReversed,
        keyword: keyword,
        goldenSentence: golden,
        brief: brief,
        action: action,
      };
      this.cardSlots.push(slot);
    }

    // 启动动画序列
    this.startRevealAnimation();
  }

  /**
   * 依次翻开动画（每 800ms 翻一张）— 所有 setTimeout 受生命周期保护
   */
  private startRevealAnimation(): void {
    const revealNext = (index: number): void => {
      if (!this.isPageAlive) { return; }
      if (index >= 3) {
        this.timerIds.push(setTimeout(() => {
          if (!this.isPageAlive) { return; }
          this.navigateToResult();
        }, 1000));
        return;
      }

      animateTo({
        duration: 400,
        curve: Curve.EaseInOut,
      }, () => {
        if (!this.isPageAlive) { return; }
        this.revealedSlots[index] = true;
      });

      this.currentRevealIndex = index + 1;
      this.timerIds.push(setTimeout(() => {
        if (!this.isPageAlive) { return; }
        revealNext(index + 1);
      }, 800));
    };

    revealNext(0);
  }

  aboutToDisappear(): void {
    this.isPageAlive = false;
    for (let i = 0; i < this.timerIds.length; i++) {
      clearTimeout(this.timerIds[i]);
    }
    this.timerIds = [];
  }

  /**
   * 跳转到结果页
   */
  private navigateToResult(): void {
    if (this.isAnimDone) {
      return;
    }
    this.isAnimDone = true;

    const routeParams: TriangleResultRouteParams = {
      questionText: this.questionText,
      scenarioTag: this.scenarioTag,
      cards: this.cardSlots,
    };

    try {
      router.replaceUrl({
        url: Routes.TRIANGLE_RESULT,
        params: routeParams,
      });
    } catch (_err) {
      // ignore
    }
  }

  /**
   * 从 HEART_OPTIONS 获取指定索引的情绪标签
   */
  private getHeartOptionEmotionTag(index: number): EmotionTag {
    if (index >= 0 && index < HEART_OPTIONS.length) {
      return HEART_OPTIONS[index].emotionTag;
    }
    return HEART_OPTIONS[3].emotionTag; // fallback: 选择纠结
  }

  /**
   * 将场景标签映射到情绪标签枚举
   */
  private mapScenarioToEmotionTag(scenarioTag: string): EmotionTag {
    switch (scenarioTag) {
      case '感情':
      case 'love':
        return this.getHeartOptionEmotionTag(1);   // 关系评估
      case '工作':
      case 'career':
        return this.getHeartOptionEmotionTag(2);   // 职场疲惫
      case '学业':
      case 'study':
        return this.getHeartOptionEmotionTag(3);   // 选择纠结
      case '财富':
      case 'wealth':
        return this.getHeartOptionEmotionTag(3);   // 选择纠结
      case '综合':
      case 'general':
        return this.getHeartOptionEmotionTag(5);   // 寻求安慰
      default:
        return this.getHeartOptionEmotionTag(3);   // 选择纠结
    }
  }

  private getRevealedCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.revealedSlots.length; i++) {
      if (this.revealedSlots[i]) {
        count++;
      }
    }
    return count;
  }

  private getRevealPrompt(): string {
    const count: number = this.getRevealedCount();
    if (count === 0) {
      return '先看看，过去留下了什么。';
    }
    if (count === 1) {
      return '再看看，现在最需要被看见的是什么。';
    }
    if (count === 2) {
      return '最后留下一点可能的方向，不必把它当成固定答案。';
    }
    return '三张牌已经展开，星澜正把线索整理成一页结果。';
  }

  private isFocusedSlot(index: number): boolean {
    const count: number = this.getRevealedCount();
    if (count >= 3) {
      return index === 2;
    }
    return index === count;
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2C_BG_BASE)

      Column()
        .width('100%')
        .height(240)
        .radialGradient({
          center: ['50%', '12%'],
          radius: '68%',
          colors: [
            ['rgba(197,160,80,0.05)', 0.0],
            ['rgba(197,160,80,0.012)', 0.58],
            ['rgba(10,13,26,0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      Column() {
        // ── 返回按钮（固定高度，不参与比例分配）──
        Row() {
          AppBackButton({ fallbackUrl: Routes.HOME })
        }
        .width('100%')
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SCREEN_PAD })

        // ── TopBar 标题区（layoutWeight 14）──
        Column() {
          Text('星钥之书 · 圣三角')
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .margin({ bottom: Theme.V2_SPACE_SM })

          Text('正在展开三张牌')
            .fontSize(Theme.V2C_FONT_TITLE)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)

          Text('过去 · 现在 · 可能的方向')
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .margin({ top: Theme.V2_SPACE_SM })

          Row()
            .width(48)
            .height(1)
            .backgroundColor(Theme.V2C_GOLD_GILT)
            .opacity(0.28)
            .margin({ top: Theme.V2_SPACE_MD })
        }
        .width('100%')
        .layoutWeight(18)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // ── CardStage 三张牌舞台区（layoutWeight 58，主体）──
        Row({ space: Theme.V2_SPACE_XS }) {
          ForEach(this.cardSlots, (slot: CardSlotInfo, index: number) => {
            Column() {
              Text(slot.positionTitle)
                .fontSize(Theme.V2C_FONT_CAPTION)
                .fontColor(this.revealedSlots[index] ? Theme.V2C_GOLD_GILT : Theme.V2C_TEXT_SECONDARY)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .height(22)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ bottom: Theme.V2_SPACE_SM })

              Stack({ alignContent: Alignment.Center }) {
                Column()
                  .width(Theme.CARD_SIZE_TRIO.width + 18)
                  .height(Theme.CARD_SIZE_TRIO.height + 18)
                  .backgroundColor(this.isFocusedSlot(index) ? 'rgba(197, 160, 80, 0.07)' : 'rgba(18, 24, 54, 0.54)')
                  .borderRadius(Theme.V2C_RADIUS_CARD)
                  .border({
                    width: 1,
                    color: this.isFocusedSlot(index) ? 'rgba(197, 160, 80, 0.30)' : Theme.V2C_SPINE_LINE
                  })

                if (this.revealedSlots[index]) {
                  TarotCardImage({
                    cardId: slot.cardId,
                    cardWidth: Theme.CARD_SIZE_TRIO.width,
                    cardHeight: Theme.CARD_SIZE_TRIO.height
                  })
                    .rotate({
                      angle: slot.isReversed ? 180 : 0,
                      centerX: '50%',
                      centerY: '50%'
                    })
                } else {
                  TarotCardImage({
                    cardId: '',
                    cardWidth: Theme.CARD_SIZE_TRIO.width,
                    cardHeight: Theme.CARD_SIZE_TRIO.height
                  })
                    .opacity(this.isFocusedSlot(index) ? 1.0 : 0.72)
                }
              }
              .width(Theme.CARD_SIZE_TRIO.width + 18)
              .height(Theme.CARD_SIZE_TRIO.height + 18)
              .scale({
                x: this.isFocusedSlot(index) ? 1.03 : 1.0,
                y: this.isFocusedSlot(index) ? 1.03 : 1.0
              })
              .animation({
                duration: Theme.V2_ANIM_BTN_RELEASE,
                curve: Theme.V2_EASE_OUT
              })

              if (this.revealedSlots[index]) {
                Text(slot.cardName)
                  .fontSize(Theme.V2C_FONT_CAPTION)
                  .fontColor(Theme.V2C_TEXT_PRIMARY)
                  .margin({ top: Theme.V2_SPACE_SM })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(slot.isReversed ? '逆位' : '正位')
                  .fontSize(Theme.V2C_FONT_DISCLAIMER)
                  .fontColor(Theme.V2C_GOLD_GILT)
                  .margin({ top: 2 })
              } else {
                Text('待展开')
                  .fontSize(Theme.V2C_FONT_DISCLAIMER)
                  .fontColor(Theme.V2C_TEXT_SECONDARY)
                  .opacity(0.72)
                  .margin({ top: Theme.V2_SPACE_SM })
              }
            }
            .layoutWeight(1)
            .height('100%')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
          }, (slot: CardSlotInfo) => slot.positionKey)
        }
        .width('100%')
        .layoutWeight(58)
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(VerticalAlign.Center)
        .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD })

        // ── Prompt + Action 区（layoutWeight 24，底部安全区）──
        Column() {
          Text(this.getRevealPrompt())
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .textAlign(TextAlign.Center)
            .lineHeight(24)
            .width('100%')
            .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG })

          Text('第 ' + this.getRevealedCount().toString() + ' / 3 张')
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_MD })

          LoadingProgress()
            .width(34)
            .height(34)
            .color(Theme.V2C_GOLD_GILT)
            .opacity(0.82)
        }
        .width('100%')
        .layoutWeight(24)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: Theme.SAFE_BOTTOM })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}

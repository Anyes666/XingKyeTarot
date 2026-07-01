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
  { positionKey: 'future', positionTitle: '未来' },
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

  aboutToAppear(): void {
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
   * 依次翻开动画（每 800ms 翻一张）
   */
  private startRevealAnimation(): void {
    const revealNext = (index: number): void => {
      if (index >= 3) {
        // 全部翻开，1s 后跳转
        setTimeout(() => {
          this.navigateToResult();
        }, 1000);
        return;
      }

      animateTo({
        duration: 400,
        curve: Curve.EaseInOut,
      }, () => {
        this.revealedSlots[index] = true;
      });

      this.currentRevealIndex = index + 1;
      setTimeout(() => {
        revealNext(index + 1);
      }, 800);
    };

    revealNext(0);
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

  build() {
    Column() {
      // ── 返回按钮（固定高度，不参与比例分配）──
        Row() {
          AppBackButton({ fallbackUrl: Routes.HOME })
        }
        .width('100%')
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SCREEN_PAD })

        // ── TopBar 标题区（layoutWeight 14）──
      Column() {
        Text('正在展开圣三角')
          .fontSize(Theme.V2C_FONT_TITLE)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        Text('过去 · 现在 · 未来')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ top: Theme.SPACE_SM })
      }
      .width('100%')
      .layoutWeight(14)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // ── CardStage 三张牌舞台区（layoutWeight 60，主体）──
      Row({ space: Theme.SPACE_SM }) {
        ForEach(this.cardSlots, (slot: CardSlotInfo, index: number) => {
          Column() {
            Text(slot.positionTitle)
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(this.revealedSlots[index] ? Theme.V2C_GOLD_GILT : Theme.V2C_TEXT_SECONDARY)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: Theme.SPACE_SM })

            if (this.revealedSlots[index]) {
              TarotCardImage({
                cardId: slot.cardId,
                cardWidth: Theme.CARD_SIZE_TRIO_DRAW.width,
                cardHeight: Theme.CARD_SIZE_TRIO_DRAW.height
              })
            } else {
              TarotCardImage({
                cardId: '',
                cardWidth: Theme.CARD_SIZE_TRIO_DRAW.width,
                cardHeight: Theme.CARD_SIZE_TRIO_DRAW.height
              })
            }

            if (this.revealedSlots[index]) {
              Text(slot.cardName)
                .fontSize(Theme.V2C_FONT_CAPTION)
                .fontColor(Theme.V2C_TEXT_PRIMARY)
                .margin({ top: Theme.SPACE_XS })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
          .layoutWeight(1)
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }, (slot: CardSlotInfo) => slot.positionKey)
      }
      .width('100%')
      .layoutWeight(60)
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
      .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD })

      // ── Prompt + Action 区（layoutWeight 26，底部安全区）──
      Column() {
        Text('星澜正在解读...')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ bottom: Theme.SPACE_MD })

        LoadingProgress()
          .width(40)
          .height(40)
          .color(Theme.V2C_GOLD_GILT)
      }
      .width('100%')
      .layoutWeight(26)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ bottom: Theme.SAFE_BOTTOM })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.V2C_BG_BASE)
  }
}

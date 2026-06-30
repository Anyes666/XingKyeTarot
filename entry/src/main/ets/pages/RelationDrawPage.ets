import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { TarotCardImage } from '../components/TarotCardImage';
import { TarotCardRepository, DrawCardResult } from '../data/TarotCardRepository';
import { MVP8_CARD_IMAGES, MVP8_CARD_NAMES, getMVP8CardData, getScenarioContent } from '../data/MVP8CardsData';
import { EmotionTag } from '../model/TarotCard';

/**
 * 关系探索抽牌页路由参数
 */
interface RelationDrawInParams {
  questionText: string;
  relationType: string;
}

/**
 * 关系探索结果页路由参数
 */
interface RelationResultRouteParams {
  questionText: string;
  relationType: string;
  cards: RelationCardSlotInfo[];
}

interface RelationCardSlotInfo {
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

// 关系探索牌位定义
const RELATION_POSITIONS: RelationSlotBaseInfo[] = [
  { positionKey: 'self', positionTitle: '我' },
  { positionKey: 'other', positionTitle: '对方' },
  { positionKey: 'trend', positionTitle: '走向' },
];

interface RelationSlotBaseInfo {
  positionKey: string;
  positionTitle: string;
}

/**
 * 关系探索抽牌动画页
 *
 * 三张牌依次翻开（animateTo, 间隔 0.8s）
 */
@Entry
@Component
struct RelationDrawPage {
  @State questionText: string = '';
  @State relationType: string = '暧昧';
  @State private cardSlots: RelationCardSlotInfo[] = [];
  @State private revealedSlots: boolean[] = [false, false, false];
  @State private isAnimDone: boolean = false;

  aboutToAppear(): void {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params = rawParams as RelationDrawInParams;
      this.questionText = params.questionText ?? '我想看清我和TA之间的关系';
      this.relationType = params.relationType ?? '暧昧';
    }

    // 抽取三张不重复的牌
    const draws: DrawCardResult[] = TarotCardRepository.drawUniqueCards(3);

    this.cardSlots = [];
    for (let i: number = 0; i < draws.length; i++) {
      const draw: DrawCardResult = draws[i];
      const pos: RelationSlotBaseInfo = RELATION_POSITIONS[i];
      const cardName: string = MVP8_CARD_NAMES[draw.cardId] ?? '';
      const keyword: string = TarotCardRepository.getCardKeyword(draw.cardId);

      const scenario = getScenarioContent(draw.cardId, '寻求安慰' as EmotionTag);
      const golden: string = scenario ? scenario.goldenSentence : '';
      const action: string = scenario ? scenario.todayAction : '';

      const mvpData = getMVP8CardData(draw.cardId);
      const brief: string = mvpData ? mvpData.cardMeaningBrief : '';

      const slot: RelationCardSlotInfo = {
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

    this.startRevealAnimation();
  }

  private startRevealAnimation(): void {
    const revealNext = (index: number): void => {
      if (index >= 3) {
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

      setTimeout(() => {
        revealNext(index + 1);
      }, 800);
    };

    revealNext(0);
  }

  private navigateToResult(): void {
    if (this.isAnimDone) {
      return;
    }
    this.isAnimDone = true;

    const routeParams: RelationResultRouteParams = {
      questionText: this.questionText,
      relationType: this.relationType,
      cards: this.cardSlots,
    };

    try {
      router.replaceUrl({
        url: Routes.RELATION_RESULT,
        params: routeParams,
      });
    } catch (_err) {
      // ignore
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
        Text('正在展开关系探索')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .fontWeight(FontWeight.Bold)

        Text('我 · 对方 · 走向')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .margin({ top: Theme.SPACE_SM })
      }
      .width('100%')
      .layoutWeight(14)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // ── CardStage 三张牌舞台区（layoutWeight 60，主体）──
      Row({ space: Theme.SPACE_SM }) {
        ForEach(this.cardSlots, (slot: RelationCardSlotInfo, index: number) => {
          Column() {
            Text(slot.positionTitle)
              .fontSize(Theme.FONT_BODY)
              .fontColor(this.revealedSlots[index] ? Theme.GOLD_AMBER : Theme.MOON_MUTED)
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
                .fontSize(Theme.FONT_CAPTION)
                .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                .margin({ top: Theme.SPACE_XS })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
          .layoutWeight(1)
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }, (slot: RelationCardSlotInfo) => slot.positionKey)
      }
      .width('100%')
      .layoutWeight(60)
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
      .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD })

      // ── Prompt + Action 区（layoutWeight 26，底部安全区）──
      Column() {
        Text('星澜正在解读...')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .margin({ bottom: Theme.SPACE_MD })

        LoadingProgress()
          .width(40)
          .height(40)
          .color(Theme.GOLD_AMBER)
      }
      .width('100%')
      .layoutWeight(26)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ bottom: Theme.SAFE_BOTTOM })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
  }
}

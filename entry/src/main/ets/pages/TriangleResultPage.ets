import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { TarotCardImage } from '../components/TarotCardImage';
import { HistoryStore } from '../common/HistoryStore';
import {
  SpreadType,
  DrawnCardRecord,
  DivinationHistoryRecord,
  generateHistoryRecordId,
} from '../model/DivinationHistoryRecord';

/**
 * 圣三角结果页路由参数
 */
interface TriangleResultInParams {
  questionText: string;
  scenarioTag: string;
  cards: CardResultSlotInfo[];
}

interface CardResultSlotInfo {
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

/**
 * 分享卡路由参数
 */
interface ShareCardRouteParams {
  sourceRecordId: string;
  spreadType: string;
}

/**
 * 圣三角结果页
 *
 * 展示三张牌（过去/现在/未来）+ 综合解读 + 自动保存历史
 */
@Entry
@Component
struct TriangleResultPage {
  @State questionText: string = '';
  @State scenarioTag: string = '综合';
  @State cards: CardResultSlotInfo[] = [];
  @State historyRecordId: string = '';
  @State isSummaryExpanded: boolean = false;

  async aboutToAppear(): Promise<void> {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params = rawParams as TriangleResultInParams;
      this.questionText = params.questionText ?? '';
      this.scenarioTag = params.scenarioTag ?? '综合';
      this.cards = params.cards ?? [];
    }

    await this.saveHistory();
  }

  /**
   * 自动保存历史记录
   */
  private async saveHistory(): Promise<void> {
    const newRecordId: string = generateHistoryRecordId();
    this.historyRecordId = newRecordId;

    const drawnCards: DrawnCardRecord[] = [];
    for (let i: number = 0; i < this.cards.length; i++) {
      const c: CardResultSlotInfo = this.cards[i];
      const dc: DrawnCardRecord = {
        positionKey: c.positionKey,
        positionTitle: c.positionTitle,
        cardId: c.cardId,
        cardName: c.cardName,
        isReversed: c.isReversed,
        keyword: c.keyword,
        goldenSentence: c.goldenSentence,
        brief: c.brief,
        action: c.action,
      };
      drawnCards.push(dc);
    }

    const summaryTitle: string = '圣三角 · ' + this.cards.map((c: CardResultSlotInfo) => c.cardName).join(' / ');
    const summaryText: string = this.buildSummaryText();
    const adviceText: string = this.buildAdviceText();

    const record: DivinationHistoryRecord = {
      id: newRecordId,
      timestamp: Date.now(),
      spreadType: SpreadType.TRIANGLE,
      modeTitle: '圣三角',
      questionText: this.questionText,
      scenarioTag: this.scenarioTag,
      cards: drawnCards,
      summaryTitle: summaryTitle,
      summaryText: summaryText,
      adviceText: adviceText,
      shareText: summaryText,
    };

    try {
      await HistoryStore.addRecord(getContext(this), record);
    } catch (_err) {
      // 保存失败不影响展示
    }
  }

  /**
   * 构建综合解读文案
   */
  private buildSummaryText(): string {
    const parts: string[] = [];
    for (let i: number = 0; i < this.cards.length; i++) {
      const c: CardResultSlotInfo = this.cards[i];
      parts.push(c.positionTitle + '：' + c.cardName + '——' + c.goldenSentence);
    }
    return '星澜为你展开了「' + this.questionText + '」的三段线索：\n\n' + parts.join('\n\n');
  }

  /**
   * 构建行动建议
   */
  private buildAdviceText(): string {
    if (this.cards.length > 1) {
      const presentCard: CardResultSlotInfo | undefined = this.cards.find((c: CardResultSlotInfo) => c.positionKey === 'present');
      if (presentCard && presentCard.action) {
        return presentCard.action;
      }
    }
    return '接下来三天，试着留意生活中的小细节，答案会慢慢浮现。';
  }

  build() {
    Scroll() {
      Column({ space: Theme.SPACE_LG }) {
        // ── P0.3 整改：左上角统一返回按钮（安全区修复）──
        Row() {
          AppBackButton({ fallbackUrl: Routes.HOME })
        }
        .width('100%')
        .padding({ top: Theme.SAFE_TOP })

        // ── 标题 ──
        Column() {
          Text('🔺 圣三角结果')
            .fontSize(Theme.FONT_HEADLINE)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 0 })

          Text('星澜为你展开了这件事的三段线索')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.MOON_MUTED)
            .margin({ top: Theme.SPACE_SM })
        }
        .width('100%')

        // ── 问题展示 ──
        if (this.questionText) {
          Text('「' + this.questionText + '」')
            .fontSize(Theme.FONT_SUBTITLE)
            .fontColor(Theme.GOLD_AMBER)
            .fontStyle(FontStyle.Italic)
            .textAlign(TextAlign.Center)
            .width('100%')
        }

        // ── 三张牌展示 ──
        ForEach(this.cards, (card: CardResultSlotInfo) => {
          this.buildCardSlot(card);
        }, (card: CardResultSlotInfo) => card.positionKey)

        // ── 综合解读 ──
        this.buildSummarySection()

        // ── 行动建议 ──
        this.buildAdviceSection()

        Divider().strokeWidth(0.5).color(Theme.DEEP_STARRY)

        // ── 操作按钮 ──
        this.buildActionButtons()

        ComplianceFooter({ fontSize: Theme.FONT_CAPTION, textColor: Theme.MOON_MUTED, showDivider: true })
      }
      .width('100%')
      .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: Theme.SAFE_BOTTOM })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildCardSlot(card: CardResultSlotInfo): void {
    Column() {
      Row() {
        Text('📍 ' + card.positionTitle)
          .fontSize(Theme.FONT_SUBTITLE)
          .fontColor(Theme.GOLD_AMBER)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .margin({ bottom: Theme.SPACE_MD })

      Row() {
        TarotCardImage({
          cardId: card.cardId,
          cardWidth: 80,
          cardHeight: 128
        })

        Column() {
          Text(card.cardName)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: Theme.SPACE_XS })

          Text(card.keyword)
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.GOLD_AMBER)

          Text(card.goldenSentence)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: Theme.SPACE_SM })
            .lineHeight(22)
        }
        .layoutWeight(1)
        .margin({ left: Theme.SPACE_MD })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.15)' })
  }

  @Builder
  buildSummarySection(): void {
    Column() {
      Text('🔮 综合解读')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.GOLD_AMBER)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.SPACE_MD })

      Text(this.buildSummaryText())
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .lineHeight(24)
        .width('100%')

      Text('圣三角不是命运预言，而是一种趋势提醒。它提示你：如果沿着现在的方式继续，接下来最需要留意什么。')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.MOON_MUTED)
        .margin({ top: Theme.SPACE_SM })
        .width('100%')
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.15)' })
  }

  @Builder
  buildAdviceSection(): void {
    Column() {
      Text('✅ 行动建议')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.GOLD_AMBER)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.SPACE_MD })

      Text(this.buildAdviceText())
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.BG_CARD_LIGHTER)
    .borderRadius(Theme.RADIUS_MD)
  }

  @Builder
  buildActionButtons(): void {
    Column({ space: Theme.SPACE_MD }) {
      // 生成分享卡
      Button('📤 生成分享卡')
        .fontSize(Theme.FONT_BODY)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .backgroundColor(Theme.GOLD_AMBER)
        .borderRadius(Theme.RADIUS_FULL)
        .onClick(() => {
          const shareParams: ShareCardRouteParams = {
            sourceRecordId: this.historyRecordId,
            spreadType: 'TRIANGLE',
          };
          try {
            router.pushUrl({ url: Routes.SHARE_CARD, params: shareParams });
          } catch (_err) {
            // ignore
          }
        })

      // 保存到历史（Toast）
      Button('📋 已保存到历史')
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .backgroundColor(Color.Transparent)
        .borderRadius(Theme.RADIUS_FULL)
        .border({ width: 1.5, color: Theme.GOLD_AMBER })
        .onClick(() => {
          // 已自动保存，Toast 提示即可
          try {
            this.getUIContext().getPromptAction().showToast({ message: '已保存到历史记录', duration: 2000 });
          } catch (_err) {
            // ignore
          }
        })

      // 回到首页
      Button('🏠 回到首页')
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.MOON_MUTED)
        .fontWeight(FontWeight.Normal)
        .width('100%')
        .height(48)
        .backgroundColor(Color.Transparent)
        .borderRadius(Theme.RADIUS_FULL)
        .border({ width: 1, color: Theme.DEEP_STARRY })
        .onClick(() => {
          try {
            router.replaceUrl({ url: Routes.NEW_HOME });
          } catch (_err) {
            // ignore
          }
        })
    }
    .width('100%')
  }
}

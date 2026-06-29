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
import { COMPANION_RESULT_LINES } from '../data/CompanionResultLines';

/**
 * 关系探索结果页路由参数
 */
interface RelationResultInParams {
  questionText: string;
  relationType: string;
  cards: RelationResultSlotInfo[];
}

interface RelationResultSlotInfo {
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

interface ShareCardRouteParams {
  sourceRecordId: string;
  spreadType: string;
}

/**
 * 关系探索结果页
 */
@Entry
@Component
struct RelationResultPage {
  @State questionText: string = '';
  @State relationType: string = '';
  @State cards: RelationResultSlotInfo[] = [];
  @State historyRecordId: string = '';
  @State private hasHeardCompanionResult: boolean = false;
  @State private companionResultLine: string = '';

  async aboutToAppear(): Promise<void> {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params = rawParams as RelationResultInParams;
      this.questionText = params.questionText ?? '';
      this.relationType = params.relationType ?? '暧昧';
      this.cards = params.cards ?? [];
    }

    await this.saveHistory();
  }

  private async saveHistory(): Promise<void> {
    const newRecordId: string = generateHistoryRecordId();
    this.historyRecordId = newRecordId;

    const drawnCards: DrawnCardRecord[] = [];
    for (let i: number = 0; i < this.cards.length; i++) {
      const c: RelationResultSlotInfo = this.cards[i];
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

    const summaryTitle: string = '关系探索 · ' + this.relationType;
    const summaryText: string = this.buildSummaryText();
    const adviceText: string = this.buildBoundaryText();

    const record: DivinationHistoryRecord = {
      id: newRecordId,
      timestamp: Date.now(),
      spreadType: SpreadType.RELATION,
      modeTitle: '关系探索 · ' + this.relationType,
      questionText: this.questionText,
      scenarioTag: this.relationType,
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

  private buildSummaryText(): string {
    const parts: string[] = [];
    for (let i: number = 0; i < this.cards.length; i++) {
      const c: RelationResultSlotInfo = this.cards[i];
      parts.push(c.positionTitle + '：' + c.cardName + '——' + c.goldenSentence);
    }
    return '星澜帮你看见了这段' + this.relationType + '关系中的三个位置：\n\n' + parts.join('\n\n');
  }

  /**
   * 边界提醒模板
   */
  private buildBoundaryText(): string {
    return '⚠️ 重要提醒：关系牌阵是一面镜子，帮助你看清自己在这段关系中的感受和状态。它不能预测对方的行为，也不能替代真实的沟通。如果某张牌让你感到不安，请记住——它反映的是能量趋势，而非注定的结果。你有主动权去选择如何面对这段关系。';
  }

  /**
   * 今日行动建议
   */
  private buildActionText(): string {
    if (this.cards.length > 0 && this.cards[0].action) {
      return this.cards[0].action;
    }
    return '今天，试着用笔写下你对这段关系最真实的感受，不需要给任何人看。';
  }

  /**
   * 阶段4A/4B/4C：再听星澜说一句 — 随机抽取 1 条补充文案，每页限 1 次
   */
  private onHearCompanionAgain(): void {
    if (this.hasHeardCompanionResult) {
      return;
    }
    const idx: number = Math.floor(Math.random() * COMPANION_RESULT_LINES.length);
    this.companionResultLine = COMPANION_RESULT_LINES[idx];
    this.hasHeardCompanionResult = true;
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

        Column() {
          Text('💞 关系探索结果')
            .fontSize(Theme.FONT_HEADLINE)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 0 })

          Text('星澜帮你看见这段关系里的三个位置')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.MOON_MUTED)
            .margin({ top: Theme.SPACE_SM })
        }
        .width('100%')

        if (this.questionText) {
          Text('「' + this.questionText + '」')
            .fontSize(Theme.FONT_SUBTITLE)
            .fontColor(Theme.GOLD_AMBER)
            .fontStyle(FontStyle.Italic)
            .textAlign(TextAlign.Center)
            .width('100%')
        }

        // 三张牌
        ForEach(this.cards, (card: RelationResultSlotInfo) => {
          this.buildCardSlot(card);
        }, (card: RelationResultSlotInfo) => card.positionKey)

        // 综合解读
        this.buildSummarySection()

        // 边界提醒
        this.buildBoundarySection()

        // 今日行动
        this.buildActionSection()

        Divider().strokeWidth(0.5).color(Theme.DEEP_STARRY)

        // 操作按钮
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
  buildCardSlot(card: RelationResultSlotInfo): void {
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
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.15)' })
  }

  @Builder
  buildBoundarySection(): void {
    Column() {
      Text('⚠️ 边界提醒')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.GOLD_AMBER)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.SPACE_MD })

      Text(this.buildBoundaryText())
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.BG_CARD_LIGHTER)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(255, 160, 80, 0.2)' })
  }

  @Builder
  buildActionSection(): void {
    Column() {
      Text('✅ 今日行动')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.GOLD_AMBER)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.SPACE_MD })

      Text(this.buildActionText())
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
  }

  @Builder
  buildActionButtons(): void {
    Column({ space: Theme.SPACE_MD }) {
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
            spreadType: 'RELATION',
          };
          try {
            router.pushUrl({ url: Routes.SHARE_CARD, params: shareParams });
          } catch (_err) {
            // ignore
          }
        })

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
          try {
            this.getUIContext().getPromptAction().showToast({ message: '已保存到历史记录', duration: 2000 });
          } catch (_err) {
            // ignore
          }
        })

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

      // ── 阶段4C：星澜补充文案区（点击"再听一句"后显示）──
      if (this.companionResultLine.length > 0) {
        Text(this.companionResultLine)
          .fontSize(14)
          .fontColor(Theme.TEXT_MUTED)
          .textAlign(TextAlign.Center)
          .lineHeight(22)
          .padding({ left: 24, right: 24, top: 12, bottom: 12 })
      }

      // ── 阶段4C："再听星澜说一句"入口（轻文字风格，弱于主操作）──
      Text('再听星澜说一句')
        .fontSize(14)
        .fontColor(this.hasHeardCompanionResult ? Theme.TEXT_MUTED : Theme.TEXT_SECONDARY)
        .opacity(this.hasHeardCompanionResult ? 0.35 : 0.85)
        .textAlign(TextAlign.Center)
        .width('100%')
        .constraintSize({ minHeight: 44 })
        .padding({ top: 12, bottom: 12 })
        .onClick(() => { this.onHearCompanionAgain(); })
    }
    .width('100%')
  }
}

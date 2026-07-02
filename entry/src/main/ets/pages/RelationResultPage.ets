import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { TarotCardImage } from '../components/TarotCardImage';
import { BoundaryReminder } from '../components/BoundaryReminder';
import { HistoryStore } from '../common/HistoryStore';
import { getRelationCompanionText } from '../data/XinglanResultCompanionText';
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
   * 边界提醒模板（温柔措辞，符合内容铁律）
   */
  private buildBoundaryText(): string {
    return '关系探索不判断对方心意，只陪你看清自己的感受、期待与边界。牌面是一面镜子，映照的是你此刻的关系体验，而非第三方内心或关系结局。';
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

  private getOrientationText(card: RelationResultSlotInfo): string {
    return card.isReversed ? '逆位' : '正位';
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

      Scroll() {
        Column({ space: Theme.V2_SPACE_LG }) {
        // ── P0.3 整改：左上角统一返回按钮（安全区修复）──
        Row() {
          AppBackButton({ fallbackUrl: Routes.HOME })
        }
        .width('100%')
        .padding({ top: Theme.SAFE_TOP })

        Column() {
          Text('星钥之书 · 关系探索')
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .margin({ bottom: Theme.V2_SPACE_SM })

          Row()
            .width(44)
            .height(1)
            .backgroundColor(Theme.V2C_GOLD_GILT)
            .opacity(0.32)
            .margin({ bottom: Theme.V2_SPACE_MD })

          Text('把这段关系，按三张牌慢慢读')
            .fontSize(Theme.V2C_FONT_TITLE)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)

          Text('这不是关系判定，也不是替你做决定。它只把你此刻能观察到的感受、互动和边界放到一页书里。')
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .lineHeight(24)
            .margin({ top: Theme.SPACE_SM })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)

        if (this.questionText) {
          Column() {
            Text('这次想整理的关系主题')
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .width('100%')
              .margin({ bottom: Theme.V2_SPACE_SM })

            Text('「' + this.questionText + '」')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_GOLD_GILT_SOFT)
              .textAlign(TextAlign.Center)
              .lineHeight(24)
              .width('100%')

            Text(this.relationType)
              .fontSize(Theme.V2C_FONT_DISCLAIMER)
              .fontColor(Theme.V2C_GOLD_GILT)
              .padding({ left: 10, right: 10, top: 3, bottom: 3 })
              .backgroundColor('rgba(197, 160, 80, 0.07)')
              .borderRadius(Theme.V2C_RADIUS_CHIP)
              .border({ width: 1, color: 'rgba(197, 160, 80, 0.20)' })
              .margin({ top: Theme.V2_SPACE_SM })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD, top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_MD })
          .backgroundColor('rgba(197, 160, 80, 0.06)')
          .borderRadius(Theme.V2C_RADIUS_CARD)
          .border({ width: 1, color: 'rgba(197, 160, 80, 0.14)' })
        }

        // 三张牌总览
        this.buildCardOverview()

        // 三张牌逐张阅读
        ForEach(this.cards, (card: RelationResultSlotInfo) => {
          this.buildCardSlot(card);
        }, (card: RelationResultSlotInfo) => card.positionKey)

        // 综合解读
        this.buildSummarySection()

        // 边界提醒
        this.buildBoundarySection()

        // 星澜陪你把关系放轻
        this.buildCompanionSection()

        // 今日行动
        this.buildActionSection()

        Divider().strokeWidth(0.5).color(Theme.V2C_SPINE_LINE)

        // 操作按钮
        this.buildActionButtons()

        ComplianceFooter({ fontSize: Theme.V2C_FONT_CAPTION, textColor: Theme.V2C_TEXT_SECONDARY, showDivider: true })
      }
      .width('100%')
      .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: Theme.SAFE_BOTTOM + 40 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildCardOverview(): void {
    Column() {
      Row() {
        Text('三张牌总览')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Medium)

        Blank()

        Row()
          .width(36)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.22)
      }
      .width('100%')
      .margin({ bottom: Theme.V2_SPACE_MD })

      Row({ space: Theme.V2_SPACE_XS }) {
        ForEach(this.cards, (card: RelationResultSlotInfo) => {
          Column() {
            Text(card.positionTitle)
              .fontSize(Theme.V2C_FONT_DISCLAIMER)
              .fontColor(Theme.V2C_GOLD_GILT)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .height(28)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            TarotCardImage({
              cardId: card.cardId,
              cardWidth: 72,
              cardHeight: 115
            })
              .rotate({
                angle: card.isReversed ? 180 : 0,
                centerX: '50%',
                centerY: '50%'
              })

            Text(card.cardName)
              .fontSize(Theme.V2C_FONT_DISCLAIMER)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .textAlign(TextAlign.Center)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: Theme.V2_SPACE_XS })
              .width('100%')

            Text(this.getOrientationText(card))
              .fontSize(10)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }, (card: RelationResultSlotInfo) => card.positionKey)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(Theme.V2_SPACE_LG)
    .backgroundColor('rgba(18, 24, 54, 0.72)')
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: Theme.V2C_SPINE_LINE })
  }

  @Builder
  buildCardSlot(card: RelationResultSlotInfo): void {
    Column() {
      Row() {
        Column()
          .width(3)
          .height(22)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.42)
          .borderRadius(2)

        Text(card.positionTitle)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Bold)
          .margin({ left: Theme.V2_SPACE_SM })

        Blank()

        Text(this.getOrientationText(card))
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .padding({ left: 10, right: 10, top: 3, bottom: 3 })
          .backgroundColor('rgba(197, 160, 80, 0.07)')
          .borderRadius(Theme.V2C_RADIUS_CHIP)
          .border({ width: 1, color: 'rgba(197, 160, 80, 0.22)' })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: Theme.V2_SPACE_MD })

      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(Theme.CARD_SIZE_TRIO.width + 16)
            .height(Theme.CARD_SIZE_TRIO.height + 16)
            .backgroundColor('rgba(10, 13, 26, 0.48)')
            .borderRadius(Theme.V2C_RADIUS_CARD)
            .border({ width: 1, color: 'rgba(197, 160, 80, 0.14)' })

          TarotCardImage({
            cardId: card.cardId,
            cardWidth: Theme.CARD_SIZE_TRIO.width,
            cardHeight: Theme.CARD_SIZE_TRIO.height
          })
            .rotate({
              angle: card.isReversed ? 180 : 0,
              centerX: '50%',
              centerY: '50%'
            })
        }
        .width(Theme.CARD_SIZE_TRIO.width + 16)
        .height(Theme.CARD_SIZE_TRIO.height + 16)

        Column() {
          Text(card.cardName)
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: Theme.V2_SPACE_XS })

          Text(card.keyword)
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_GOLD_GILT)
            .margin({ bottom: Theme.V2_SPACE_SM })

          Text(card.goldenSentence)
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .lineHeight(24)
            .width('100%')
        }
        .layoutWeight(1)
        .margin({ left: Theme.V2_SPACE_MD })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(Theme.V2_SPACE_LG)
    .backgroundColor(Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197, 160, 80, 0.12)' })
    .shadow(Theme.V2C_SHADOW_CARD)
  }

  @Builder
  buildSummarySection(): void {
    Column() {
      Text('三张牌放在一起时')
        .fontSize(Theme.V2C_FONT_SUBTITLE)
        .fontColor(Theme.V2C_GOLD_GILT)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.V2_SPACE_XS })

      Row()
        .width(42)
        .height(1)
        .backgroundColor(Theme.V2C_GOLD_GILT)
        .opacity(0.26)
        .margin({ bottom: Theme.V2_SPACE_MD })

      Text(this.buildSummaryText())
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(Theme.V2C_TEXT_PRIMARY)
        .lineHeight(26)
        .width('100%')

      Text('这组牌提供的是观察角度，不是关系结论。你可以先把真实发生过的互动和自己的感受放在一起看。')
        .fontSize(Theme.V2C_FONT_CAPTION)
        .fontColor(Theme.V2C_TEXT_SECONDARY)
        .lineHeight(20)
        .margin({ top: Theme.V2_SPACE_MD })
        .width('100%')
    }
    .width('100%')
    .padding(Theme.V2_SPACE_LG)
    .backgroundColor(Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197, 160, 80, 0.14)' })
  }

  @Builder
  buildBoundarySection(): void {
    BoundaryReminder({
      text: this.buildBoundaryText(),
      showAccentLine: true
    })
  }

  @Builder
  buildActionSection(): void {
    Column() {
      Text('可以先照顾的一件小事')
        .fontSize(Theme.V2C_FONT_SUBTITLE)
        .fontColor(Theme.V2C_GOLD_GILT)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.V2_SPACE_MD })

      Text(this.buildActionText())
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(Theme.V2C_TEXT_PRIMARY)
        .lineHeight(25)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.V2_SPACE_LG)
    .backgroundColor(Theme.V2C_BG_FLOATING)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: Theme.V2C_SPINE_LINE })
  }

  @Builder
  buildCompanionSection(): void {
    Column() {
      Row() {
        Text(getRelationCompanionText().title)
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('月光旁注')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
      }
      .width('100%')
      .margin({ bottom: Theme.V2_SPACE_MD })

      Column({ space: Theme.V2_SPACE_MD }) {
        Text(getRelationCompanionText().receive)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(25)
          .width('100%')

        Text(getRelationCompanionText().reflect)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(25)
          .width('100%')

        Text(getRelationCompanionText().question)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .fontWeight(FontWeight.Medium)
          .lineHeight(25)
          .width('100%')
          .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD, top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_SM })
          .backgroundColor('rgba(197, 160, 80, 0.055)')
          .borderRadius(Theme.V2C_RADIUS_CHIP)
          .border({ width: 1, color: 'rgba(197, 160, 80, 0.16)' })
          .margin({ top: Theme.V2_SPACE_XS })

        Text(getRelationCompanionText().action)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .lineHeight(25)
          .width('100%')
          .fontStyle(FontStyle.Italic)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.V2_SPACE_LG)
    .backgroundColor('rgba(18, 24, 54, 0.68)')
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197, 160, 80, 0.10)' })
    .margin({ top: Theme.V2_SPACE_MD })
  }

  @Builder
  buildActionButtons(): void {
    Column({ space: Theme.V2_SPACE_MD }) {
      Text('继续整理这次抽牌')
        .fontSize(Theme.V2C_FONT_SUBTITLE)
        .fontColor(Theme.V2C_GOLD_GILT)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.V2_SPACE_XS })

      Button('生成分享卡')
        .type(ButtonType.Normal)
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(Theme.V2C_GOLD_GILT)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .backgroundColor(Theme.V2C_BG_CARD)
        .borderRadius(Theme.V2C_RADIUS_BTN)
        .border({ width: 1, color: Theme.V2C_GOLD_GILT })
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

      Button('已保存到历史')
        .type(ButtonType.Normal)
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(Theme.V2C_TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .backgroundColor(Color.Transparent)
        .borderRadius(Theme.V2C_RADIUS_BTN)
        .border({ width: 1.5, color: Theme.V2C_GOLD_GILT })
        .onClick(() => {
          try {
            this.getUIContext().getPromptAction().showToast({ message: '已保存到历史记录', duration: 2000 });
          } catch (_err) {
            // ignore
          }
        })

      Button('回到首页')
        .type(ButtonType.Normal)
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(Theme.V2C_TEXT_SECONDARY)
        .fontWeight(FontWeight.Normal)
        .width('100%')
        .height(48)
        .backgroundColor(Color.Transparent)
        .borderRadius(Theme.V2C_RADIUS_BTN)
        .border({ width: 1, color: Theme.V2C_SPINE_LINE })
        .onClick(() => {
          try {
            router.replaceUrl({ url: Routes.MAIN_FRAME });
          } catch (_err) {
            // ignore
          }
        })

      // ── 阶段4C：星澜补充文案区（点击"再听一句"后显示）──
      if (this.companionResultLine.length > 0) {
        Text(this.companionResultLine)
          .fontSize(14)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(22)
          .padding({ left: 24, right: 24, top: 12, bottom: 12 })
      }

      // ── 阶段4C："再听星澜说一句"入口（轻文字风格，弱于主操作）──
      Text('再听星澜说一句')
        .fontSize(14)
        .fontColor(this.hasHeardCompanionResult ? Theme.V2C_TEXT_SECONDARY : Theme.V2C_TEXT_SECONDARY)
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

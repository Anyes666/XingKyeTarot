import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { TarotCardImage } from '../components/TarotCardImage';
import { HistoryStore } from '../common/HistoryStore';
import { getTriangleCompanionText } from '../data/XinglanResultCompanionText';
import {
  SpreadType,
  DrawnCardRecord,
  DivinationHistoryRecord,
  generateHistoryRecordId,
} from '../model/DivinationHistoryRecord';
import { COMPANION_RESULT_LINES } from '../data/CompanionResultLines';

/**
 * 圣三角结果页路由参数
 */
interface TriangleResultInParams {
  questionText: string;
  scenarioTag: string;
  cards: CardResultSlotInfo[];
  /** 来源（card_wheel 等，用于标记历史记录牌阵类型） */
  source?: string;
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
 * 展示三张牌（过去/现在/可能的方向）+ 综合解读 + 自动保存历史
 */
@Entry
@Component
struct TriangleResultPage {
  @State questionText: string = '';
  @State scenarioTag: string = '综合';
  @State cards: CardResultSlotInfo[] = [];
  @State historyRecordId: string = '';
  @State isSummaryExpanded: boolean = false;
  @State private source: string = '';
  @State private hasHeardCompanionResult: boolean = false;
  @State private companionResultLine: string = '';

  async aboutToAppear(): Promise<void> {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params = rawParams as TriangleResultInParams;
      this.questionText = params.questionText ?? '';
      this.scenarioTag = params.scenarioTag ?? '综合';
      this.cards = params.cards ?? [];
      this.source = params.source ?? '';
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

    // 根据 source 决定 spreadType：来自牌轮的三牌也标记为 CARD_WHEEL
    const actualSpreadType: SpreadType = (this.source === 'card_wheel') ? SpreadType.CARD_WHEEL : SpreadType.TRIANGLE;
    const actualModeTitle: string = (this.source === 'card_wheel') ? '旋转牌轮' : '圣三角';

    const record: DivinationHistoryRecord = {
      id: newRecordId,
      timestamp: Date.now(),
      spreadType: actualSpreadType,
      modeTitle: actualModeTitle,
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

  private getOrientationText(card: CardResultSlotInfo): string {
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

          // ── 标题 ──
          Column() {
            Text('星钥之书 · 圣三角')
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .margin({ bottom: Theme.V2_SPACE_SM })

            Row()
              .width(44)
              .height(1)
              .backgroundColor(Theme.V2C_GOLD_GILT)
              .opacity(0.32)
              .margin({ bottom: Theme.V2_SPACE_MD })

            Text('三张牌，按顺序慢慢读')
              .fontSize(Theme.V2C_FONT_TITLE)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)

            Text('过去 · 现在 · 可能的方向')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .margin({ top: Theme.V2_SPACE_SM })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)

          // ── 问题展示 ──
          if (this.questionText) {
            Text('「' + this.questionText + '」')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_GOLD_GILT_SOFT)
              .textAlign(TextAlign.Center)
              .lineHeight(24)
              .width('100%')
              .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD, top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_MD })
              .backgroundColor('rgba(197, 160, 80, 0.06)')
              .borderRadius(Theme.V2C_RADIUS_CARD)
              .border({ width: 1, color: 'rgba(197, 160, 80, 0.14)' })
          }

          // ── 三张牌总览 ──
          this.buildCardOverview()

          // ── 三张牌逐张阅读 ──
          ForEach(this.cards, (card: CardResultSlotInfo) => {
            this.buildCardSlot(card);
          }, (card: CardResultSlotInfo) => card.positionKey)

          // ── 综合解读 ──
          this.buildSummarySection()

          // ── 行动建议 ──
          this.buildAdviceSection()

          // ── 星澜陪你整理 ──
          this.buildCompanionSection()

          Divider().strokeWidth(0.5).color(Theme.V2C_SPINE_LINE)

          // ── 操作按钮 ──
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
        ForEach(this.cards, (card: CardResultSlotInfo) => {
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
        }, (card: CardResultSlotInfo) => card.positionKey)
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
  buildCardSlot(card: CardResultSlotInfo): void {
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

      Text('圣三角不是命运预言。它更像把线索摆在桌上，提醒你可以先观察什么、靠近什么。')
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
  buildAdviceSection(): void {
    Column() {
      Text('可以先靠近的一件小事')
        .fontSize(Theme.V2C_FONT_SUBTITLE)
        .fontColor(Theme.V2C_GOLD_GILT)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.V2_SPACE_MD })

      Text(this.buildAdviceText())
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
        Text(getTriangleCompanionText().title)
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
        Text(getTriangleCompanionText().receive)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(25)
          .width('100%')

        Text(getTriangleCompanionText().reflect)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(25)
          .width('100%')

        Text(getTriangleCompanionText().question)
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

        Text(getTriangleCompanionText().action)
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

      // 生成分享卡
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
            spreadType: 'TRIANGLE',
          };
          try {
            router.pushUrl({ url: Routes.SHARE_CARD, params: shareParams });
          } catch (_err) {
            // ignore
          }
        })

      // 保存到历史（Toast）
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
          // 已自动保存，Toast 提示即可
          try {
            this.getUIContext().getPromptAction().showToast({ message: '已保存到历史记录', duration: 2000 });
          } catch (_err) {
            // ignore
          }
        })

      // 回到首页
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

      // ── 阶段4B：星澜补充文案区（点击"再听一句"后显示）──
      if (this.companionResultLine.length > 0) {
        Text(this.companionResultLine)
          .fontSize(14)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .lineHeight(22)
          .padding({ left: 24, right: 24, top: 12, bottom: 12 })
      }

      // ── 阶段4B："再听星澜说一句"入口（轻文字风格，弱于主操作）──
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

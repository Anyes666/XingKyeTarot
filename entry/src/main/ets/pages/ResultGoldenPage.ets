import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { TarotCardImage } from '../components/TarotCardImage';
import {
  MVP8_CARD_NAMES,
  getMVP8CardData,
  getScenarioContent,
} from '../data/MVP8CardsData';
import { Routes } from '../common/Routes';
import { EmotionTag, ScenarioContent, StructuredInterpretation } from '../model/TarotCard';
import { HistoryStore } from '../common/HistoryStore';
import { AppStateStore } from '../common/AppStateStore';
import {
  SpreadType,
  DrawnCardRecord,
  DivinationHistoryRecord,
  generateHistoryRecordId,
} from '../model/DivinationHistoryRecord';
import { TarotCardRepository } from '../data/TarotCardRepository';
import { COMPANION_RESULT_LINES } from '../data/CompanionResultLines';

/**
 * 结果页路由入参（P0.2 扩展）
 */
interface ResultPageParams {
  entryMode: string;
  recordId: string;
  cardId: string;
  cardName: string;
  isReversed: boolean;
  heartOptionIndex: number;
  emotionTag: string;
  goldenSentence: string;
  questionText: string;
}

/**
 * 追问星澜页面路由参数
 */
interface FollowUpRouteParams {
  cardId: string
  cardName: string
  emotionTag: string
  heartOptionIndex: number
  goldenSentence: string
}

/**
 * 分享卡页面路由参数（P0.2 改造为 sourceRecordId + spreadType）
 */
interface ShareCardRouteParams {
  sourceRecordId: string
  spreadType: string
}

/**
 * 情绪星点页面路由参数
 */
interface EmotionStarRouteParams {
  emotionTag: string
  heartOptionIndex: number
}

/**
 * 金句结果页面（P0.2 改造）
 *
 * 新增：
 * - 自动保存历史记录
 * - FIRST_EXPERIENCE 模式：多「进入首页」按钮
 * - NORMAL_SINGLE：回到首页改 replaceUrl NEW_HOME
 * - 分享卡参数改为 sourceRecordId + spreadType
 */
@Entry
@Component
struct ResultGoldenPage {
  // ── 路由参数 ──
  @State private recordId: string = '';
  @State private cardId: string = '';
  @State private cardName: string = '';
  @State private isReversed: boolean = false;
  @State private heartOptionIndex: number = 0;
  @State private emotionTag: string = '';
  @State private goldenSentence: string = '';
  @State private entryMode: string = 'NORMAL_SINGLE';
  @State private questionText: string = '';
  @State private historyRecordId: string = '';

  // ── 计算属性 ──
  @State private emotionKeywords: string[] = [];
  @State private todayAction: string = '';
  @State private cardMeaningBrief: string = '';
  @State private deepInterpretation: string = '';
  @State private isDeepInterpretationExpanded: boolean = false;
  @State private isSavingHistory: boolean = false;
  @State private hasHeardCompanionResult: boolean = false;
  @State private companionResultLine: string = '';

  async aboutToAppear(): Promise<void> {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params = rawParams as ResultPageParams;
      this.recordId = params.recordId ?? '';
      this.cardId = params.cardId ?? 'major_18_moon';
      this.cardName = params.cardName ?? MVP8_CARD_NAMES[this.cardId] ?? '月亮';
      this.isReversed = params.isReversed ?? false;
      this.heartOptionIndex = params.heartOptionIndex ?? 0;
      this.emotionTag = params.emotionTag ?? '寻求安慰';
      this.goldenSentence = params.goldenSentence ?? '';
      this.entryMode = params.entryMode ?? 'NORMAL_SINGLE';
      this.questionText = params.questionText ?? '';
    } else {
      // 降级默认值
      this.cardId = 'major_18_moon';
      this.cardName = '月亮';
      this.emotionTag = '寻求安慰';
      this.entryMode = 'NORMAL_SINGLE';
    }

    this.loadData();

    // 异步保存历史记录
    await this.saveHistory();
  }

  /**
   * 从数据层加载当前牌的内容
   */
  private loadData(): void {
    // 场景化解读
    const scenario: ScenarioContent | undefined = getScenarioContent(this.cardId, this.emotionTag as EmotionTag);
    if (scenario) {
      if (!this.goldenSentence) {
        this.goldenSentence = scenario.goldenSentence;
      }
      this.emotionKeywords = scenario.emotionKeywords;
      this.todayAction = scenario.todayAction;
    }

    // 结构化解读
    const cardData: StructuredInterpretation | undefined = getMVP8CardData(this.cardId);
    if (cardData) {
      this.cardMeaningBrief = cardData.cardMeaningBrief;
      this.deepInterpretation = cardData.deepInterpretation;
    }
  }

  /**
   * P0.2 新增：自动保存历史记录
   */
  private async saveHistory(): Promise<void> {
    if (this.isSavingHistory) {
      return;
    }
    this.isSavingHistory = true;
    try {
      const newRecordId: string = generateHistoryRecordId();
      this.historyRecordId = newRecordId;

      const drawnCard: DrawnCardRecord = {
        positionKey: 'guidance',
        positionTitle: '指引',
        cardId: this.cardId,
        cardName: this.cardName,
        isReversed: this.isReversed,
        keyword: TarotCardRepository.getCardKeyword(this.cardId),
        goldenSentence: this.goldenSentence,
        brief: TarotCardRepository.getCardBrief(this.cardId, this.emotionTag as EmotionTag),
        action: this.todayAction,
      };

      const modeTitle: string = this.entryMode === 'FIRST_EXPERIENCE' ? '首次体验' : '单牌快占';

      const record: DivinationHistoryRecord = {
        id: newRecordId,
        timestamp: Date.now(),
        spreadType: SpreadType.SINGLE,
        modeTitle: modeTitle,
        questionText: this.questionText,
        scenarioTag: this.emotionTag,
        cards: [drawnCard],
        summaryTitle: this.cardName + ' · 正位',
        summaryText: this.goldenSentence,
        adviceText: this.todayAction,
        shareText: this.goldenSentence,
      };

      await HistoryStore.addRecord(getContext(this), record);
    } catch (_err) {
      // 保存失败不影响展示
    } finally {
      this.isSavingHistory = false;
    }
  }

  /**
   * 阶段4A：再听星澜说一句 — 随机抽取 1 条补充文案，每页限 1 次
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
      Column() {
        // ── P0.3 整改：左上角统一返回按钮（安全区修复）──
        Row() {
          AppBackButton({ fallbackUrl: Routes.HOME })
        }
        .width('100%')
        .padding({ top: Theme.SAFE_TOP, bottom: 0 })

        // ═══════════ 顶部：牌面 + 牌名 + 正位标签 ═══════════
        this.buildHeader()

        // ═══════════ 金句区域 ═══════════
        this.buildGoldenSentence()

        // ═══════════ 分割线 ═══════════
        Divider()
          .strokeWidth(0.5)
          .color(Theme.DEEP_STARRY)
          .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_LG })

        // ═══════════ 情绪关键词 + 今日行动 ═══════════
        this.buildActionSection()

        // ═══════════ "为什么是这张牌" ═══════════
        this.buildWhyThisCard()

        Divider()
          .strokeWidth(0.5)
          .color(Theme.DEEP_STARRY)
          .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_LG })

        // ═══════════ 操作按钮区 ═══════════
        this.buildActionButtons()

        // ═══════════ 情绪星点入口 ═══════════
        this.buildBottomEntry()

        Divider()
          .strokeWidth(0.5)
          .color(Theme.DEEP_STARRY)
          .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_LG })

        // ═══════════ 深度解读（折叠区） ═══════════
        this.buildDeepInterpretation()

        // ═══════════ 合规页脚 ═══════════
        ComplianceFooter({
          fontSize: Theme.FONT_CAPTION,
          textColor: Theme.MOON_MUTED,
          showDivider: true,
        })

        // 底部留白
        Blank().height(40)
      }
      .width('100%')
      .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: Theme.SAFE_BOTTOM })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
    .scrollBar(BarState.Off)
  }

  // ────── 子构建器 ──────

  @Builder
  buildHeader(): void {
    Column() {
      // 牌面图片（P0.3 整改：使用 TarotCardImage 统一填充，消除黑边）
      TarotCardImage({
        cardId: this.cardId,
        cardWidth: 140,
        cardHeight: 224
      })

      // 牌名
      Text(this.cardName)
        .fontSize(Theme.FONT_CARD_NAME)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .fontWeight(FontWeight.Bold)
        .margin({ top: Theme.SPACE_MD })

      // 正位标签
      Text('正位')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.GOLD_LIGHT)
        .padding({ left: 12, right: 12, top: 2, bottom: 2 })
        .borderRadius(Theme.RADIUS_SM)
        .border({ width: 1, color: Theme.GOLD_LIGHT })
        .margin({ top: Theme.SPACE_XS })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 48 })
  }

  @Builder
  buildGoldenSentence(): void {
    Column() {
      Text(this.goldenSentence)
        .fontSize(Theme.FONT_DISPLAY)
        .fontColor(Theme.GOLD_LIGHT)
        .fontWeight(FontWeight.Bold)
        .lineHeight(52)
        .textAlign(TextAlign.Center)
        .width('100%')

      Text(`—— ${Constants.MOON_WATERMARK} ——`)
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.MOON_MUTED)
        .margin({ top: Theme.SPACE_MD })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: Theme.SPACE_RESULT_GAP })
    .padding({ top: Theme.SPACE_LG, bottom: Theme.SPACE_LG })
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_LG)
  }

  @Builder
  buildWhyThisCard(): void {
    Column() {
      Text('为什么是这张牌？')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.GOLD_AMBER)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.SPACE_MD })

      Text(this.cardMeaningBrief)
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
  buildActionSection(): void {
    Column({ space: Theme.SPACE_MD }) {
      // 情绪关键词标签组
      Row({ space: Theme.SPACE_SM }) {
        ForEach(this.emotionKeywords, (keyword: string) => {
          Text(keyword)
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.GOLD_AMBER)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .backgroundColor('rgba(202, 138, 4, 0.1)')
            .borderRadius(Theme.RADIUS_FULL)
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.25)' })
        }, (keyword: string) => keyword)
      }
      .width('100%')

      // 今日行动卡片
      Column() {
        Text('✅ 今日行动')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD_AMBER)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ bottom: Theme.SPACE_SM })

        Text(this.todayAction)
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
    .width('100%')
    .margin({ top: Theme.SPACE_LG })
  }

  @Builder
  buildActionButtons(): void {
    Column({ space: Theme.SPACE_MD }) {
      // ── FIRST_EXPERIENCE 专属：「进入首页」按钮（最上方，金色实心）──
      if (this.entryMode === 'FIRST_EXPERIENCE') {
        Button('🏠 进入首页')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .height(48)
          .backgroundColor(Theme.GOLD_AMBER)
          .borderRadius(Theme.RADIUS_FULL)
          .onClick(async () => {
            try {
              await AppStateStore.completeFirstExperience(getContext(this));
              router.replaceUrl({ url: Routes.MAIN_FRAME });
            } catch (_err) {
              router.replaceUrl({ url: Routes.MAIN_FRAME });
            }
          })
      }

      // 追问道星澜按钮
      Button('💬 追问星澜')
        .fontSize(Theme.FONT_BODY)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .backgroundColor(Theme.GOLD_AMBER)
        .borderRadius(Theme.RADIUS_FULL)
        .onClick(() => {
          const followUpParams: FollowUpRouteParams = {
            cardId: this.cardId,
            cardName: this.cardName,
            emotionTag: this.emotionTag || '',
            heartOptionIndex: this.heartOptionIndex,
            goldenSentence: this.goldenSentence
          };
          try {
            router.pushUrl({
              url: Routes.FOLLOW_UP,
              params: followUpParams
            });
          } catch (err) {
            console.error('pushUrl to FollowUp failed: ' + JSON.stringify(err));
          }
        })

      // 生成分享卡按钮（P0.2 改为 sourceRecordId + spreadType）
      Button('📤 生成分享卡')
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .backgroundColor(Color.Transparent)
        .borderRadius(Theme.RADIUS_FULL)
        .border({ width: 1.5, color: Theme.GOLD_AMBER })
        .onClick(() => {
          const shareCardParams: ShareCardRouteParams = {
            sourceRecordId: this.historyRecordId || this.recordId,
            spreadType: 'SINGLE'
          };
          try {
            router.pushUrl({
              url: Routes.SHARE_CARD,
              params: shareCardParams
            });
          } catch (err) {
            console.error('pushUrl to ShareCard failed: ' + JSON.stringify(err));
          }
        })

      // NORMAL_SINGLE：「回到首页」
      if (this.entryMode !== 'FIRST_EXPERIENCE') {
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
              router.replaceUrl({ url: Routes.MAIN_FRAME });
            } catch (_err) {
              // ignore
            }
          })
      }

        // ── 阶段4A：星澜补充文案区（点击"再听一句"后显示）──
        if (this.companionResultLine.length > 0) {
          Text(this.companionResultLine)
            .fontSize(14)
            .fontColor(Theme.TEXT_MUTED)
            .textAlign(TextAlign.Center)
            .lineHeight(22)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
        }

        // ── 阶段4A："再听星澜说一句"入口（轻文字风格，弱于主操作）──
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
    .margin({ top: Theme.SPACE_LG })
  }

  @Builder
  buildDeepInterpretation(): void {
    Column() {
      // 折叠标题栏（可点击）
      Row() {
        Text('📖 深度解读')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontColor(Theme.GOLD_AMBER)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text(this.isDeepInterpretationExpanded ? '▲ 收起' : '▼ 展开')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
      }
      .width('100%')
      .onClick(() => {
        this.isDeepInterpretationExpanded = !this.isDeepInterpretationExpanded;
      })

      // 展开时显示内容
      if (this.isDeepInterpretationExpanded) {
        Text(this.deepInterpretation)
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .lineHeight(26)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })
      }
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
  }

  @Builder
  buildBottomEntry(): void {
    Column() {
      Button('⭐ 点亮情绪星')
        .type(ButtonType.Normal)
        .width('100%')
        .height(52)
        .borderRadius(26)
        .backgroundColor('#17172F')
        .fontColor('#D99A00')
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .border({ width: 1, color: '#D99A00' })
        .onClick(() => {
          const emotionStarParams: EmotionStarRouteParams = {
            emotionTag: this.emotionTag || '',
            heartOptionIndex: this.heartOptionIndex
          };
          try {
            router.pushUrl({
              url: Routes.EMOTION_STAR,
              params: emotionStarParams
            });
          } catch (err) {
            console.error('pushUrl to EmotionStar failed: ' + JSON.stringify(err));
          }
        })

      Text('记录今天的心事，让星澜陪你看见最近的自己。')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.MOON_MUTED)
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
    }
    .width('100%')
    .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_SM })
  }

  /**
   * 方案 B：Toast 提示"下一阶段接入"
   */
  private showNextPhaseToast(): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: Constants.TOAST_NEXT_PHASE,
        duration: 2000,
      });
    } catch (err) {
      // 忽略 Toast 失败
    }
  }
}

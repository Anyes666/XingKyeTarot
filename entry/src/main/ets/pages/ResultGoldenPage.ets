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
import { getPositiveScenarioContent, PositiveEmotionTag } from '../data/PositiveHeartOptions';
import { Routes } from '../common/Routes';
import { EmotionTag, ScenarioContent, StructuredInterpretation } from '../model/TarotCard';
import { HistoryStore } from '../common/HistoryStore';
import { getSingleCardCompanionText, ResultCompanionText } from '../data/XinglanResultCompanionText';
import { AppStateStore } from '../common/AppStateStore';
import {
  SpreadType,
  DrawnCardRecord,
  DivinationHistoryRecord,
  generateHistoryRecordId,
} from '../model/DivinationHistoryRecord';
import { TarotCardRepository } from '../data/TarotCardRepository';
import { COMPANION_RESULT_LINES } from '../data/CompanionResultLines';
import { EmotionStarStorage, EmotionStarRecord, StarKeyLevel, NextLevelInfo } from '../common/EmotionStarStorage';

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
  cardName: string
  cardId: string
  totalLightDays: number
  currentLevelTitle: string
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
  @State private isPositiveMode: boolean = false;

  // ── 情绪星点亮状态 ──
  @State private isTodayLit: boolean = false;
  @State private followUpPressed: boolean = false;
  @State private sharePressed: boolean = false;
  @State private totalLightDays: number = 0;
  @State private currentLevelTitle: string = '初见';

  // ── B 方案月光呼吸动画状态 ──
  @State private moonlightOpacity: number = 0.6;

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

    // 判断是否为积极方向模式
    this.isPositiveMode = this.isPositiveEmotionTag(this.emotionTag);

    this.loadData();

    // 异步保存历史记录
    await this.saveHistory();

    // 检查今日情绪星点亮状态（仅在每日一占入口时）
    await this.checkTodayLightStatus();

    // B 方案月光呼吸动画（6s 无限循环）
    animateTo({
      duration: Theme.V2_ANIM_MOONLIGHT_BREATH,
      iterations: -1,
      curve: Curve.EaseInOut
    }, () => {
      this.moonlightOpacity = 1.0;
    });
  }

  /**
   * 检查今日情绪星是否已点亮，并计算累计天数和当前等级
   */
  private async checkTodayLightStatus(): Promise<void> {
    try {
      this.isTodayLit = await EmotionStarStorage.hasLightedToday(getContext(this));
      const records: EmotionStarRecord[] = await EmotionStarStorage.getRecords(getContext(this));
      this.totalLightDays = EmotionStarStorage.getTotalLightDays(records);
      const level: StarKeyLevel = EmotionStarStorage.getLevelByTotalDays(this.totalLightDays);
      this.currentLevelTitle = level.title;
    } catch (_err) {
      // ignore
    }
  }

  /**
   * 从数据层加载当前牌的内容
   */
  private loadData(): void {
    if (this.isPositiveMode) {
      // 积极方向：使用积极场景化文案
      const positiveScenario: ScenarioContent | undefined = getPositiveScenarioContent(
        this.cardId, this.emotionTag as PositiveEmotionTag
      );
      if (positiveScenario) {
        if (!this.goldenSentence) {
          this.goldenSentence = positiveScenario.goldenSentence;
        }
        this.emotionKeywords = positiveScenario.emotionKeywords;
        this.todayAction = positiveScenario.todayAction;
      }
    } else {
      // 原有场景化解读
      const scenario: ScenarioContent | undefined = getScenarioContent(this.cardId, this.emotionTag as EmotionTag);
      if (scenario) {
        if (!this.goldenSentence) {
          this.goldenSentence = scenario.goldenSentence;
        }
        this.emotionKeywords = scenario.emotionKeywords;
        this.todayAction = scenario.todayAction;
      }
    }

    // 结构化解读（与方向无关，始终加载）
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

      // 根据 entryMode 决定 spreadType：来自牌轮的单牌也标记为 CARD_WHEEL
      let actualSpreadType: SpreadType = SpreadType.SINGLE;
      let modeTitle: string = '每日一占';
      if (this.entryMode === 'FIRST_EXPERIENCE') {
        modeTitle = '首次体验';
      } else if (this.entryMode === 'CARD_WHEEL') {
        actualSpreadType = SpreadType.CARD_WHEEL;
        modeTitle = '旋转牌轮';
      }

      const record: DivinationHistoryRecord = {
        id: newRecordId,
        timestamp: Date.now(),
        spreadType: actualSpreadType,
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
    Stack() {
      // ── C 方案底色 ──
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2C_BG_BASE)

      // ── B 方案月光光晕层（顶部呼吸动画）──
      Column()
        .width('100%')
        .height(220)
        .radialGradient({
          center: ['50%', '20%'],
          radius: '55%',
          colors: [
            ['rgba(212,172,77,0.04)', 0.0],
            ['rgba(212,172,77,0.01)', 0.6],
            ['rgba(10,13,26,0)', 1.0]
          ]
        })
        .opacity(this.moonlightOpacity)
        .hitTestBehavior(HitTestMode.None)

      // ── 主内容滚动区 ──
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
            .color(Theme.V2C_SPINE_LINE)
            .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_LG })

          // ═══════════ 情绪关键词 + 今日行动 ═══════════
          this.buildActionSection()

          // ═══════════ "为什么是这张牌" ═══════════
          this.buildWhyThisCard()

          // ═══════════ 星澜陪你看见 ═══════════
          this.buildCompanionSection()

          Divider()
            .strokeWidth(0.5)
            .color(Theme.V2C_SPINE_LINE)
            .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_LG })

          // ═══════════ 操作按钮区 ═══════════
          this.buildActionButtons()

          // ═══════════ 情绪星点入口 ═══════════
          this.buildBottomEntry()

          Divider()
            .strokeWidth(0.5)
            .color(Theme.V2C_SPINE_LINE)
            .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_LG })

          // ═══════════ 深度解读（折叠区） ═══════════
          this.buildDeepInterpretation()

          // ═══════════ 合规页脚 ═══════════
          ComplianceFooter({
            fontSize: Theme.V2C_FONT_CAPTION,
            textColor: Theme.V2C_TEXT_SECONDARY,
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
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  // ────── 子构建器 ──────

  @Builder
  buildHeader(): void {
    Column() {
      // C 方案烫金线框 + 牌面图
      Stack() {
        // 牌面图片（P0.3 整改 v2：使用统一尺寸常量）
        TarotCardImage({
          cardId: this.cardId,
          cardWidth: Theme.CARD_SIZE_SINGLE_RESULT.width,
          cardHeight: Theme.CARD_SIZE_SINGLE_RESULT.height
        })

        // 烫金顶线装饰
        Row()
          .width('60%')
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.4)
          .position({ x: '20%', y: 8 })

        // 烫金底线装饰
        Row()
          .width('60%')
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.3)
          .position({ x: '20%', y: '92%' })
      }
      .width(Theme.CARD_SIZE_SINGLE_RESULT.width)
      .height(Theme.CARD_SIZE_SINGLE_RESULT.height)

      // 牌名（衬线字体）
      Text(this.cardName)
        .fontSize(Theme.V2C_FONT_CARD_NAME)
        .fontColor(Theme.V2C_TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .margin({ top: Theme.SPACE_MD })

      // 正位标签
      Text('正位')
        .fontSize(Theme.V2C_FONT_CAPTION)
        .fontColor(Theme.V2C_GOLD_GILT)
        .padding({ left: 12, right: 12, top: 2, bottom: 2 })
        .borderRadius(Theme.V2C_RADIUS_CHIP)
        .border({ width: 1, color: Theme.V2C_GOLD_GILT })
        .margin({ top: Theme.SPACE_XS })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 48 })
  }

  @Builder
  buildGoldenSentence(): void {
    // 金色漫反射光晕层（包裹金句卡片；高度贴合内容，不撑开卡片）
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .borderRadius(Theme.V2C_RADIUS_POPUP)
        .radialGradient({
          center: ['50%', '50%'],
          radius: '70%',
          colors: [
            ['rgba(197, 160, 80, 0.06)', 0.0],
            ['rgba(197, 160, 80, 0.015)', 0.6],
            ['rgba(27, 27, 48, 0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      Column() {
        Text(this.goldenSentence)
          .fontSize(Theme.V2C_FONT_DISPLAY)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .fontWeight(FontWeight.Bold)
          .lineHeight(52)
          .textAlign(TextAlign.Center)
          .width('100%')

        Text(`—— ${Constants.MOON_WATERMARK} ——`)
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ top: Theme.SPACE_MD })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ top: Theme.SPACE_LG, bottom: Theme.SPACE_LG })
    }
    .width('100%')
    .margin({ top: Theme.SPACE_RESULT_GAP })
    .backgroundColor(Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_POPUP)
    .border({ width: 1, color: 'rgba(197, 160, 80, 0.12)' })
  }

  @Builder
  buildWhyThisCard(): void {
    Column() {
      Text('为什么是这张牌？')
        .fontSize(Theme.V2C_FONT_SUBTITLE)
        .fontColor(Theme.V2C_GOLD_GILT)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.SPACE_MD })

      Text(this.cardMeaningBrief)
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(Theme.V2C_TEXT_PRIMARY)
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197, 160, 80, 0.15)' })
  }

  @Builder
  buildCompanionSection(): void {
    Column() {
      Text(getSingleCardCompanionText(this.cardName || '这张牌', this.isReversed).title)
        .fontSize(Theme.V2C_FONT_SUBTITLE)
        .fontColor(Theme.V2C_GOLD_GILT)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: Theme.V2_SPACE_MD })

      Column({ space: Theme.V2_SPACE_MD }) {
        Text(getSingleCardCompanionText(this.cardName || '这张牌', this.isReversed).receive)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(24)
          .width('100%')

        Text(getSingleCardCompanionText(this.cardName || '这张牌', this.isReversed).reflect)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(24)
          .width('100%')

        Text(getSingleCardCompanionText(this.cardName || '这张牌', this.isReversed).question)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .fontWeight(FontWeight.Medium)
          .lineHeight(24)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_XS })

        Text(getSingleCardCompanionText(this.cardName || '这张牌', this.isReversed).action)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .lineHeight(24)
          .width('100%')
          .fontStyle(FontStyle.Italic)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.V2_SPACE_LG)
    .backgroundColor(Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197, 160, 80, 0.15)' })
    .margin({ top: Theme.V2_SPACE_MD })
  }

  @Builder
  buildActionSection(): void {
    Column({ space: Theme.SPACE_MD }) {
      // 情绪关键词标签组
      Row({ space: Theme.SPACE_SM }) {
        ForEach(this.emotionKeywords, (keyword: string) => {
          Text(keyword)
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_GOLD_GILT)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .backgroundColor('rgba(197, 160, 80, 0.1)')
            .borderRadius(Theme.V2C_RADIUS_BTN)
            .border({ width: 1, color: 'rgba(197, 160, 80, 0.25)' })
        }, (keyword: string) => keyword)
      }
      .width('100%')

      // 今日行动卡片
      Column() {
        Text('✅ 今日行动')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ bottom: Theme.SPACE_SM })

        Text(this.todayAction)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(24)
          .width('100%')
      }
      .width('100%')
      .padding(Theme.SPACE_LG)
      .backgroundColor(Theme.V2C_BG_FLOATING)
      .borderRadius(Theme.V2C_RADIUS_CARD)
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
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .height(48)
          .backgroundColor(Theme.V2C_BG_CARD)
          .borderRadius(Theme.V2C_RADIUS_BTN)
          .border({ width: 1, color: Theme.V2C_GOLD_GILT })
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
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(Theme.V2C_GOLD_GILT)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .backgroundColor(Theme.V2C_BG_CARD)
        .borderRadius(Theme.V2C_RADIUS_BTN)
        .border({ width: 1, color: Theme.V2C_GOLD_GILT })
        .scale({
          x: this.followUpPressed ? Theme.PRESS_SCALE : 1.0,
          y: this.followUpPressed ? Theme.PRESS_SCALE : 1.0
        })
        .animation({
          duration: Theme.ANIM_PRESS_DURATION,
          curve: Theme.V2_EASE_OUT
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.followUpPressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.followUpPressed = false;
          }
        })
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
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(Theme.V2C_GOLD_GILT)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(48)
        .backgroundColor(Color.Transparent)
        .borderRadius(Theme.V2C_RADIUS_BTN)
        .border({ width: 1.5, color: Theme.V2C_GOLD_GILT })
        .scale({
          x: this.sharePressed ? Theme.PRESS_SCALE : 1.0,
          y: this.sharePressed ? Theme.PRESS_SCALE : 1.0
        })
        .animation({
          duration: Theme.ANIM_PRESS_DURATION,
          curve: Theme.V2_EASE_OUT
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.sharePressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.sharePressed = false;
          }
        })
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
      }

        // ── 阶段4A：星澜补充文案区（点击"再听一句"后显示）──
        if (this.companionResultLine.length > 0) {
          Text(this.companionResultLine)
            .fontSize(14)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .lineHeight(22)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
        }

        // ── 阶段4A："再听星澜说一句"入口（轻文字风格，弱于主操作）──
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
    .margin({ top: Theme.SPACE_LG })
  }

  @Builder
  buildDeepInterpretation(): void {
    Column() {
      // 折叠标题栏（可点击）
      Row() {
        Text('📖 深度解读')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text(this.isDeepInterpretationExpanded ? '▲ 收起' : '▼ 展开')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
      }
      .width('100%')
      .onClick(() => {
        this.isDeepInterpretationExpanded = !this.isDeepInterpretationExpanded;
      })

      // 展开时显示内容
      if (this.isDeepInterpretationExpanded) {
        Text(this.deepInterpretation)
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(26)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })
      }
    }
    .width('100%')
    .padding(Theme.SPACE_LG)
    .backgroundColor(Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_CARD)
  }

  @Builder
  buildBottomEntry(): void {
    Column() {
      if (this.isTodayLit) {
        // ── 已点亮状态 ──
        Button('⭐ 今日已点亮')
          .type(ButtonType.Normal)
          .width('100%')
          .height(52)
          .borderRadius(Theme.V2C_RADIUS_BTN)
          .backgroundColor('rgba(197, 160, 80, 0.12)')
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .border({ width: 1, color: 'rgba(197, 160, 80, 0.3)' })
          .onClick(() => {
            try {
              this.getUIContext().getPromptAction().showToast({
                message: '今天的星星已经亮着了，明天再来看看自己吧。',
                duration: 2000,
              });
            } catch (_err) {
              // ignore
            }
          })

        Text('今天的星星已经亮着了，明天再来看看自己吧。')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .margin({ top: 8 })
      } else {
        // ── 未点亮状态 ──
        Button('⭐ 点亮情绪星')
          .type(ButtonType.Normal)
          .width('100%')
          .height(52)
          .borderRadius(Theme.V2C_RADIUS_BTN)
          .backgroundColor(Theme.V2C_BG_CARD)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .border({ width: 1, color: Theme.V2C_GOLD_GILT })
          .onClick(() => {
            this.handleLightEmotionStar();
          })

        Text('记录今天的心事，让星澜陪你看见最近的自己。')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_SM })
  }

  /**
   * 处理点亮情绪星：写入记录 → 跳转点亮成功页
   */
  private async handleLightEmotionStar(): Promise<void> {
    try {
      const record: EmotionStarRecord = {
        date: EmotionStarStorage.todayString(),
        starName: this.emotionTag || '',
        sourceType: 'daily_card',
        cardName: this.cardName,
        createdAt: Date.now(),
      };

      const success: boolean = await EmotionStarStorage.lightToday(getContext(this), record);
      if (!success) {
        // 已点亮（极端并发情况防护）
        this.isTodayLit = true;
        return;
      }

      // 重新读取累计数据
      const records: EmotionStarRecord[] = await EmotionStarStorage.getRecords(getContext(this));
      this.totalLightDays = EmotionStarStorage.getTotalLightDays(records);
      const level: StarKeyLevel = EmotionStarStorage.getLevelByTotalDays(this.totalLightDays);
      this.currentLevelTitle = level.title;
      this.isTodayLit = true;

      // 跳转到点亮成功页
      const emotionStarParams: EmotionStarRouteParams = {
        emotionTag: this.emotionTag || '',
        heartOptionIndex: this.heartOptionIndex,
        cardName: this.cardName,
        cardId: this.cardId,
        totalLightDays: this.totalLightDays,
        currentLevelTitle: this.currentLevelTitle,
      };
      router.pushUrl({
        url: Routes.EMOTION_STAR,
        params: emotionStarParams,
      });
    } catch (err) {
      console.error('lightToday failed: ' + JSON.stringify(err));
    }
  }

  /**
   * 判断是否为积极方向标签
   */
  private isPositiveEmotionTag(tag: string): boolean {
    const positiveTags: string[] = ['给我鼓励', '今日微光', '找回力量', '一点勇气', '积极一面', '一句提醒'];
    return positiveTags.includes(tag);
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

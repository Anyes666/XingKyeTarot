import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { TarotCardRepository } from '../data/TarotCardRepository';
import { TarotCard, EmotionTag } from '../model/TarotCard';
import { TAROT_CARDS } from '../data/TarotCardData';

// ═══════════════════════════════════════════════════════════
// 类型定义
// ═══════════════════════════════════════════════════════════

/** 牌轮抽牌页路由入参 */
interface CardWheelDrawInParams {
  drawCount: number;
}

/** 牌轮中每张牌的渲染信息 */
interface WheelCardInfo {
  cardId: string;
  cardName: string;
  imageName: string;
}

/** 已选中的牌 */
interface SelectedCardInfo {
  cardId: string;
  cardName: string;
  isReversed: boolean;
}

/** 牌轮卡片视觉样式 */
interface WheelCardStyle {
  x: number;
  scale: number;
  opacity: number;
  rotate: number;
  zIndex: number;
}

/** 单牌结果页路由参数 */
interface WheelSingleResultParams {
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

/** 圣三角结果页路由参数 */
interface WheelTriangleResultParams {
  questionText: string;
  scenarioTag: string;
  cards: WheelCardSlotInfo[];
}

interface WheelCardSlotInfo {
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

/** 三牌位置定义 */
interface PositionDef {
  positionKey: string;
  positionTitle: string;
}

// ═══════════════════════════════════════════════════════════
// 常量
// ═══════════════════════════════════════════════════════════

/** 牌背宽度（vp） */
const CARD_WIDTH: number = 80;
/** 牌背高度（vp） */
const CARD_HEIGHT: number = 128;
/** 一张牌占用的步长 = 牌宽 + 间距 */
const ITEM_STEP: number = CARD_WIDTH + 16;
/** 中心选择框宽度（略大于牌宽） */
const FRAME_WIDTH: number = CARD_WIDTH + 8;
/** 中心选择框高度（略大于牌高） */
const FRAME_HEIGHT: number = CARD_HEIGHT + 8;
/** 吸附动画时长（ms） */
const SNAP_DURATION: number = 220;
/** 可见牌范围：中心左右各 VISIBLE_RANGE 张 */
const VISIBLE_RANGE: number = 4;
/** 吸附阈值：拖动超过此距离至少切 1 张 */
const SNAP_THRESHOLD: number = ITEM_STEP * 0.35;

/** 三牌位置 */
const THREE_POSITIONS: PositionDef[] = [
  { positionKey: 'past', positionTitle: '过去 / 起点' },
  { positionKey: 'present', positionTitle: '现在 / 核心' },
  { positionKey: 'future', positionTitle: '可能的方向' },
];

// ═══════════════════════════════════════════════════════════
// 页面组件
// ═══════════════════════════════════════════════════════════

/**
 * 旋转牌轮抽牌页 — 环形循环牌轮版
 *
 * 核心机制：
 * - virtualIndex 无限增减，通过 normalizeIndex 循环取牌
 * - 只渲染中心左右各 4 张（共 9 张可见牌）
 * - PanGesture 跟手拖动，松手后吸附最近牌
 * - 确认前不显示牌名，确认后才跳转结果页
 */
@Entry
@Component
struct CardWheelDrawPage {
  // ── 路由参数 ──
  @State private drawCount: number = 1;

  // ── 牌组 ──
  @State private deck: WheelCardInfo[] = [];
  @State private selectedCards: SelectedCardInfo[] = [];

  // ── 牌轮核心状态 ──
  /** 虚拟索引（可无限增减，normalize 后取牌） */
  @State private virtualIndex: number = 0;
  /** 当前手势拖动偏移量（vp） */
  @State private dragOffsetX: number = 0;
  /** 是否正在手指拖动 */
  @State private isDragging: boolean = false;
  /** 是否正在执行吸附动画 */
  @State private isSnapping: boolean = false;
  /** 确认按钮是否可点击（显式 @State，确保 UI 刷新） */
  @State private confirmBtnEnabled: boolean = true;

  // ── 可见牌偏移列表 ──
  @State private visibleOffsets: number[] = [];

  // ── UI 文案 ──
  @State private confirmText: string = '确认这张牌';
  @State private progressText: string = '选择 1 / 1';
  @State private instructionText: string = '让牌轮停下，再确认这一张。';

  aboutToAppear(): void {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params: CardWheelDrawInParams = rawParams as CardWheelDrawInParams;
      this.drawCount = params.drawCount ?? 1;
    }
    this.initDeck();
    this.initVisibleOffsets();
    this.updateConfirmBtnEnabled();
    this.updateUITexts();
  }

  // ═══════════════════════════════════════════════════════════
  // 牌组初始化
  // ═══════════════════════════════════════════════════════════

  private initDeck(): void {
    // Fisher-Yates 洗牌
    const pool: TarotCard[] = [...TAROT_CARDS];
    const len: number = pool.length;
    for (let i: number = len - 1; i > 0; i--) {
      const j: number = Math.floor(Math.random() * (i + 1));
      const temp: TarotCard = pool[i];
      pool[i] = pool[j];
      pool[j] = temp;
    }

    const newDeck: WheelCardInfo[] = [];
    for (let k: number = 0; k < len; k++) {
      const card: TarotCard = pool[k];
      newDeck.push({
        cardId: card.id,
        cardName: card.nameZh,
        imageName: card.image,
      });
    }
    this.deck = newDeck;
    this.virtualIndex = 0;
    this.dragOffsetX = 0;
  }

  // ═══════════════════════════════════════════════════════════
  // 环形循环索引
  // ═══════════════════════════════════════════════════════════

  /**
   * 将任意整数索引标准化到牌组范围内
   * 支持负索引和超出范围的索引循环
   */
  private normalizeIndex(index: number): number {
    const length: number = this.deck.length;
    if (length <= 0) {
      return 0;
    }
    let normalized: number = index % length;
    if (normalized < 0) {
      normalized += length;
    }
    return normalized;
  }

  /** 获取当前中心牌的实际索引（normalize 后） */
  private get selectedIndex(): number {
    return this.normalizeIndex(this.virtualIndex);
  }

  // ═══════════════════════════════════════════════════════════
  // 视觉样式计算
  // ═══════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════
  // UI 文案
  // ═══════════════════════════════════════════════════════════

  private updateUITexts(): void {
    const step: number = this.selectedCards.length + 1;
    if (this.drawCount === 1) {
      this.progressText = '选择 1 / 1';
      this.confirmText = '确认这张牌';
      this.instructionText = '让牌轮停下，再确认这一张。';
    } else {
      this.progressText = `选择 ${step} / ${this.drawCount}`;
      this.confirmText = `确认第 ${step} 张`;
      this.instructionText = `第 ${step} 张：让牌轮停下，再确认。`;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 确认选择
  // ═══════════════════════════════════════════════════════════

  private confirmSelection(): void {
    // 拖动中或吸附中不允许确认
    if (this.isDragging || this.isSnapping) {
      try { this.getUIContext().getPromptAction().showToast({ message: '请等待牌轮停止', duration: 1000 }); } catch (_) {}
      return;
    }

    if (this.deck.length === 0) {
      try { this.getUIContext().getPromptAction().showToast({ message: '牌组已空', duration: 1000 }); } catch (_) {}
      return;
    }

    const actualIndex: number = this.normalizeIndex(this.virtualIndex);
    console.info(`[CardWheelConfirm] virtualIndex=${this.virtualIndex}, actualIndex=${actualIndex}, deckLen=${this.deck.length}`);

    if (actualIndex < 0 || actualIndex >= this.deck.length) {
      try { this.getUIContext().getPromptAction().showToast({ message: '索引异常', duration: 1000 }); } catch (_) {}
      return;
    }

    const centerCard: WheelCardInfo = this.deck[actualIndex];
    if (!centerCard) {
      try { this.getUIContext().getPromptAction().showToast({ message: '牌数据为空', duration: 1000 }); } catch (_) {}
      return;
    }

    console.info(`[CardWheelConfirm] selected card: ${centerCard.cardId} - ${centerCard.cardName}`);

    // 不重复检查
    for (let i: number = 0; i < this.selectedCards.length; i++) {
      if (this.selectedCards[i].cardId === centerCard.cardId) {
        try {
          this.getUIContext().getPromptAction().showToast({
            message: '这张已选过，请滑动牌轮换一张',
            duration: 1500,
          });
        } catch (_err) {
          // ignore
        }
        return;
      }
    }

    const selected: SelectedCardInfo = {
      cardId: centerCard.cardId,
      cardName: centerCard.cardName,
      isReversed: false,
    };

    const newSelected: SelectedCardInfo[] = [...this.selectedCards, selected];
    this.selectedCards = newSelected;

    if (newSelected.length >= this.drawCount) {
      // 选满了 → 跳转结果页
      console.info(`[CardWheelConfirm] 选满${newSelected.length}张，跳转结果页`);
      this.navigateToResult();
    } else {
      // 还没选满 → 移除已选牌，重置牌轮继续选
      console.info(`[CardWheelConfirm] 已选${newSelected.length}/${this.drawCount}张，继续选`);
      this.removeCardFromDeck(centerCard.cardId);
      this.virtualIndex = 0;
      this.dragOffsetX = 0;
      this.updateUITexts();

      // 显示已选择反馈
      try {
        this.getUIContext().getPromptAction().showToast({
          message: `已选「${centerCard.cardName}」`,
          duration: 1200,
        });
      } catch (_err) {
        // ignore
      }
    }
  }

  /**
   * 从可选牌组中移除已选牌
   */
  private removeCardFromDeck(cardId: string): void {
    const newDeck: WheelCardInfo[] = [];
    for (let i: number = 0; i < this.deck.length; i++) {
      if (this.deck[i].cardId !== cardId) {
        newDeck.push(this.deck[i]);
      }
    }
    this.deck = newDeck;
  }

  // ═══════════════════════════════════════════════════════════
  // 手势处理 — 跟手拖动 + 松手吸附
  // ═══════════════════════════════════════════════════════════

  /**
   * 松手后计算吸附目标并执行动画
   */
  private finishDrag(): void {
    // 计算拖动跨越了多少"格"
    let moveSteps: number = Math.round(-this.dragOffsetX / ITEM_STEP);

    // 确保小幅拖动也至少切换一张（如果超过阈值）
    if (moveSteps === 0 && Math.abs(this.dragOffsetX) > SNAP_THRESHOLD) {
      moveSteps = this.dragOffsetX < 0 ? 1 : -1;
    }

    const newVirtualIndex: number = this.virtualIndex + moveSteps;

    this.isSnapping = true;
    this.isDragging = false;
    this.updateConfirmBtnEnabled();

    // 动画吸附
    animateTo({
      duration: SNAP_DURATION,
      curve: Curve.EaseOut,
    }, () => {
      this.virtualIndex = newVirtualIndex;
      this.dragOffsetX = 0;
      // 动画中保持禁用
      this.updateConfirmBtnEnabled();
    });

    // 动画结束后恢复按钮
    setTimeout(() => {
      this.isSnapping = false;
      this.updateConfirmBtnEnabled();
    }, SNAP_DURATION + 50);
  }

  /** 更新确认按钮可用状态 */
  private updateConfirmBtnEnabled(): void {
    this.confirmBtnEnabled = !this.isDragging && !this.isSnapping && this.deck.length > 0;
  }

  // ═══════════════════════════════════════════════════════════
  // 牌轮可见牌 Builder
  // ═══════════════════════════════════════════════════════════

  private initVisibleOffsets(): void {
    const offsets: number[] = [];
    for (let i: number = -VISIBLE_RANGE; i <= VISIBLE_RANGE; i++) {
      offsets.push(i);
    }
    this.visibleOffsets = offsets;
  }

  @Builder
  wheelArea(): void {
    Column() {
      // 提示文字
      Text('让牌轮慢慢转动。')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.GOLD_LIGHT)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')

      Text('当它停下时，选中最靠近你的那一张。')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.MOON_MUTED)
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ top: Theme.SPACE_XS })

      // 牌轮可视区域
      Stack() {
        // 牌背层 — 渲染可见牌（中心 ± VISIBLE_RANGE）
        Stack() {
          ForEach(
            this.visibleOffsets,
            (offset: number) => {
              WheelCardItemContent({
                offsetFromCenter: offset,
                dragOffsetX: this.dragOffsetX,
                virtualIndex: this.virtualIndex,
                deck: this.deck,
              })
            },
            (offset: number) => offset.toString()
          )
        }
        .width(FRAME_WIDTH * 5)
        .height(FRAME_HEIGHT + 40)
        .hitTestBehavior(HitTestMode.None)
        .alignContent(Alignment.Center)

        // 中心金色选择框（固定，不随牌移动）
        Column()
          .width(FRAME_WIDTH)
          .height(FRAME_HEIGHT)
          .borderRadius(Theme.TAROT_CARD_RADIUS + 2)
          .border({ width: 2, color: Theme.GOLD_LIGHT })
          .backgroundColor('rgba(229, 165, 10, 0.06)')
          .hitTestBehavior(HitTestMode.None)
      }
      .width('100%')
      .height(FRAME_HEIGHT + 60)
      .alignContent(Alignment.Center)
      .margin({ top: Theme.SPACE_LG })
      // 手势层
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal, distance: 8 })
          .onActionStart(() => {
            this.isDragging = true;
            this.updateConfirmBtnEnabled();
          })
          .onActionUpdate((event: GestureEvent) => {
            // 实时更新拖动偏移
            this.dragOffsetX = event.offsetX;
          })
          .onActionEnd(() => {
            // 松手 → 计算吸附
            this.finishDrag();
          })
      )
    }
    .width('100%')
  }

  /**
   * 获取可见牌相对于中心的偏移列表
   * 从 -VISIBLE_RANGE 到 +VISIBLE_RANGE
   */
  private getVisibleOffsets(): number[] {
    const offsets: number[] = [];
    for (let i: number = -VISIBLE_RANGE; i <= VISIBLE_RANGE; i++) {
      offsets.push(i);
    }
    return offsets;
  }

  // ═══════════════════════════════════════════════════════════
  // 结果页跳转
  // ═══════════════════════════════════════════════════════════

  private navigateToResult(): void {
    if (this.drawCount === 1) {
      this.navigateToSingleResult();
    } else {
      this.navigateToTriangleResult();
    }
  }

  private navigateToSingleResult(): void {
    if (this.selectedCards.length === 0) {
      return;
    }
    const card: SelectedCardInfo = this.selectedCards[0];
    const recordId: string = 'wheel_' + Date.now().toString(36);
    const goldenSentence: string = TarotCardRepository.getCardBrief(card.cardId, '寻求安慰' as EmotionTag);

    try {
      const params: WheelSingleResultParams = {
        entryMode: 'NORMAL_SINGLE',
        recordId: recordId,
        cardId: card.cardId,
        cardName: card.cardName,
        isReversed: card.isReversed,
        heartOptionIndex: 0,
        emotionTag: '寻求安慰',
        goldenSentence: goldenSentence !== '' ? goldenSentence : '让这张牌轻轻映照此刻的你。',
        questionText: '',
      };
      router.replaceUrl({ url: Routes.RESULT_GOLDEN, params: params });
    } catch (_err) {
      // ignore
    }
  }

  private navigateToTriangleResult(): void {
    if (this.selectedCards.length < 3) {
      return;
    }

    const resultCards: WheelCardSlotInfo[] = [];
    for (let i: number = 0; i < 3; i++) {
      const card: SelectedCardInfo = this.selectedCards[i];
      const pos: PositionDef = THREE_POSITIONS[i];
      const keyword: string = TarotCardRepository.getCardKeyword(card.cardId);
      const goldenSentence: string = TarotCardRepository.getCardBrief(card.cardId, '寻求安慰' as EmotionTag);
      const brief: string = TarotCardRepository.getCardBrief(card.cardId);
      const action: string = TarotCardRepository.getCardAction(card.cardId);

      resultCards.push({
        positionKey: pos.positionKey,
        positionTitle: pos.positionTitle,
        cardId: card.cardId,
        cardName: card.cardName,
        isReversed: card.isReversed,
        keyword: keyword !== '' ? keyword : '指引',
        goldenSentence: goldenSentence !== '' ? goldenSentence : '轻轻映照此刻的你。',
        brief: brief !== '' ? brief : '',
        action: action !== '' ? action : '',
      });
    }

    try {
      const params: WheelTriangleResultParams = {
        questionText: '',
        scenarioTag: '综合',
        cards: resultCards,
      };
      router.replaceUrl({ url: Routes.TRIANGLE_RESULT, params: params });
    } catch (_err) {
      // ignore
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 主布局
  // ═══════════════════════════════════════════════════════════

  build() {
    Stack() {
      // 深蓝背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      // 主内容
      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.CARD_WHEEL_MODE })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        .alignItems(VerticalAlign.Center)

        // 标题
        Text('转动牌轮')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        // 副标题
        Text('左右滑动牌轮，停下后确认中间的牌。')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM })

        // 牌轮区域（占据弹性空间）
        Column() {
          this.wheelArea()
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        // 底部确认区域
        Column() {
          // 进度文字（不显示牌名）
          Text(this.progressText)
            .fontSize(Theme.FONT_SUBTITLE)
            .fontColor(Theme.GOLD_PALE)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: Theme.SPACE_XS })

          // 引导提示（不显示牌名）
          Text(this.instructionText)
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.MOON_MUTED)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: Theme.SPACE_MD })

          // 确认按钮
          Button(this.confirmText)
            .fontSize(Theme.FONT_SUBTITLE)
            .fontColor(Theme.BTN_DARK_TEXT)
            .fontWeight(FontWeight.Medium)
            .width('72%')
            .height(Theme.BTN_HEIGHT)
            .backgroundColor(Theme.GOLD_LIGHT)
            .borderRadius(Theme.RADIUS_FULL)
            .opacity(this.confirmBtnEnabled ? 1.0 : 0.5)
            .onClick(() => {
              this.confirmSelection();
            })
        }
        .width('100%')
        .padding({ bottom: 32 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }
}

// ═══════════════════════════════════════════════════════════
// 单张牌背渲染子组件
// ═══════════════════════════════════════════════════════════

@Component
struct WheelCardItemContent {
  @Prop offsetFromCenter: number = 0;
  @Prop dragOffsetX: number = 0;
  @Prop virtualIndex: number = 0;
  @Prop deck: WheelCardInfo[] = [];

  build() {
    Column() {
      Image($r('app.media.card_back'))
        .width(CARD_WIDTH * this.getCardScale())
        .height(CARD_HEIGHT * this.getCardScale())
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.TAROT_CARD_RADIUS)
        .opacity(this.getCardOpacity())
        .rotate({
          angle: this.getCardRotate(),
          centerX: '50%',
          centerY: '50%',
        })
    }
    .width(CARD_WIDTH)
    .height(CARD_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .zIndex(this.getCardZIndex())
    .translate({ x: this.getCardTranslateX(), y: 0 })
  }

  private visualPosition(): number {
    return this.offsetFromCenter + (this.dragOffsetX / ITEM_STEP);
  }

  private getCardScale(): number {
    const distance: number = Math.abs(this.visualPosition());
    return Math.max(0.48, 1.0 - distance * 0.16);
  }

  private getCardOpacity(): number {
    const distance: number = Math.abs(this.visualPosition());
    return Math.max(0.12, 1.0 - distance * 0.23);
  }

  private getCardRotate(): number {
    return this.visualPosition() * -6;
  }

  private getCardZIndex(): number {
    const distance: number = Math.abs(this.visualPosition());
    return Math.round(100 - distance * 10);
  }

  private getCardTranslateX(): number {
    return this.visualPosition() * ITEM_STEP;
  }
}

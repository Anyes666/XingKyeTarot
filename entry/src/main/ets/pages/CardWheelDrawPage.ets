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
  source?: string;
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
const SNAP_DURATION: number = 280;
/** 可见牌范围：中心左右各 VISIBLE_RANGE 张 */
const VISIBLE_RANGE: number = 5;
/** 吸附阈值：拖动超过此距离至少切 1 张 */
const SNAP_THRESHOLD: number = ITEM_STEP * 0.28;
/** 惯性摩擦系数（每帧速度衰减比例，越大衰减越快） */
const FRICTION: number = 0.94;
/** 惯性动画帧间隔（ms） */
const INERTIA_FRAME_MS: number = 16;
/** 惯性最小速度：低于此值直接吸附 */
const MIN_VELOCITY: number = 0.8;
/** 中心牌缩放倍率 */
const CENTER_SCALE: number = 1.0;
/** 边缘牌最小缩放 */
const MIN_SCALE: number = 0.42;
/** 中心牌透明度 */
const CENTER_OPACITY: number = 1.0;
/** 边缘牌最小透明度 */
const MIN_OPACITY: number = 0.08;
/** 中心牌亮度偏移（0=不变） */
const CENTER_BRIGHTNESS: number = 1.0;
/** 边缘牌亮度偏移 */
const EDGE_BRIGHTNESS: number = 0.35;
/** 悬浮高度（vp）— 中心牌上浮 */
const CENTER_LIFT: number = 3;
/** 中心光晕渐显时长（ms） */
const GLOW_FADE_DURATION: number = 200;

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
  /** 中心光晕透明度（0-1，吸附后渐显） */
  @State private centerGlowAlpha: number = 0;
  /** 惯性速度（vp/frame，仅在惯性阶段有效） */
  private inertiaVelocity: number = 0;
  /** 惯性动画定时器 ID */
  private inertiaTimerId: number = -1;
  /** 吸附完成回调定时器 ID（snapToNearest 中的 setTimeout） */
  private snapFinishTimerId: number = -1;

  // ── 可见牌偏移列表 ──
  @State private visibleOffsets: number[] = [];

  // ── UI 文案 ──
  @State private confirmText: string = '确认这张星钥';
  @State private progressText: string = '选择 1 / 1';
  @State private instructionText: string = '这张牌停在你面前了。准备好时，轻轻点亮它。';

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

  /**
   * 页面即将销毁：清理所有未完成的定时器，防止销毁后继续 setState
   */
  aboutToDisappear(): void {
    this.stopInertia();
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
      this.confirmText = '确认这张星钥';
      this.instructionText = '这张牌停在你面前了。准备好时，轻轻点亮它。';
    } else {
      this.progressText = `选择 ${step} / ${this.drawCount}`;
      this.confirmText = `确认第 ${step} 张星钥`;
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
  // 手势处理 — 跟手拖动 + 惯性滚动 + 弹性吸附（物理动力学）
  // ═══════════════════════════════════════════════════════════

  /**
   * 松手：根据手势速度决定惯性滚动还是直接吸附
   * 如果拖拽速度足够大 → 进入惯性阶段
   * 否则 → 直接吸附到最近的牌
   */
  private finishDrag(): void {
    // 停止任何还在运行的惯性定时器
    this.stopInertia();

    // 计算拖拽速度（vp/frame，负值=右滑，正值=左滑）
    const velocity: number = this.inertiaVelocity;
    const absVelocity: number = Math.abs(velocity);

    // 速度足够大 → 进入惯性滚动
    if (absVelocity > MIN_VELOCITY) {
      this.startInertia(velocity);
    } else {
      // 速度太小 → 直接吸附
      this.snapToNearest();
    }
  }

  /**
   * 启动惯性滚动动画
   * 每帧：velocity *= FRICTION，dragOffsetX += velocity
   * 当速度衰减到阈值以下 → 吸附
   */
  private startInertia(initialVelocity: number): void {
    this.inertiaVelocity = initialVelocity;
    this.isDragging = false;
    this.isSnapping = true;
    this.updateConfirmBtnEnabled();
    this.centerGlowAlpha = 0;

    const tick = (): void => {
      // 应用速度
      this.dragOffsetX += this.inertiaVelocity;

      // 当拖动偏移超过一张牌的范围时，提交 virtualIndex 更新并重置偏移
      while (this.dragOffsetX > ITEM_STEP) {
        this.virtualIndex -= 1;
        this.dragOffsetX -= ITEM_STEP;
      }
      while (this.dragOffsetX < -ITEM_STEP) {
        this.virtualIndex += 1;
        this.dragOffsetX += ITEM_STEP;
      }

      // 摩擦衰减
      this.inertiaVelocity *= FRICTION;

      // 检查是否该停止了
      if (Math.abs(this.inertiaVelocity) < MIN_VELOCITY) {
        this.stopInertia();
        this.snapToNearest();
      } else {
        // 继续下一帧
        this.inertiaTimerId = setTimeout(tick, INERTIA_FRAME_MS);
      }
    };

    this.inertiaTimerId = setTimeout(tick, INERTIA_FRAME_MS);
  }

  /**
   * 停止惯性滚动（同时清理所有相关定时器）
   */
  private stopInertia(): void {
    if (this.inertiaTimerId >= 0) {
      clearTimeout(this.inertiaTimerId);
      this.inertiaTimerId = -1;
    }
    if (this.snapFinishTimerId >= 0) {
      clearTimeout(this.snapFinishTimerId);
      this.snapFinishTimerId = -1;
    }
    this.inertiaVelocity = 0;
  }

  /**
   * 吸附到最近的牌位（弹性吸附）
   * 计算当前偏移最接近的整数牌位，执行 EaseOut 动画
   */
  private snapToNearest(): void {
    // 计算最接近的整步
    let steps: number = Math.round(-this.dragOffsetX / ITEM_STEP);
    // 确保小幅拖动也至少切换一张（如果超过阈值）
    if (steps === 0 && Math.abs(this.dragOffsetX) > SNAP_THRESHOLD) {
      steps = this.dragOffsetX < 0 ? 1 : -1;
    }

    const newVirtualIndex: number = this.virtualIndex + steps;

    this.isSnapping = true;
    this.isDragging = false;
    this.updateConfirmBtnEnabled();
    this.centerGlowAlpha = 0;

    // EaseOut 弹性吸附动画
    animateTo({
      duration: SNAP_DURATION,
      curve: Curve.EaseOut,
    }, () => {
      this.virtualIndex = newVirtualIndex;
      this.dragOffsetX = 0;
      this.updateConfirmBtnEnabled();
    });

    // 吸附完成后：中心光晕渐显（吸引感）
    this.snapFinishTimerId = setTimeout(() => {
      this.snapFinishTimerId = -1;
      this.isSnapping = false;
      this.updateConfirmBtnEnabled();
      // 渐显中心光晕
      animateTo({
        duration: GLOW_FADE_DURATION,
        curve: Curve.EaseIn,
      }, () => {
        this.centerGlowAlpha = 1.0;
      });
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

        // 中心金色选择框（固定，不随牌移动）+ 光晕吸引层
        Stack() {
          // 外层光晕（吸附后渐显，模拟金色漫反射）
          Column()
            .width(FRAME_WIDTH + 24)
            .height(FRAME_HEIGHT + 24)
            .borderRadius(Theme.TAROT_CARD_RADIUS + 12)
            .radialGradient({
              center: ['50%', '50%'],
              radius: '50%',
              colors: [
                ['rgba(229, 165, 10, 0.15)', 0.0],
                ['rgba(229, 165, 10, 0.06)', 0.4],
                ['rgba(229, 165, 10, 0)', 1.0]
              ]
            })
            .opacity(this.centerGlowAlpha)
            .hitTestBehavior(HitTestMode.None)

          // 内层选择框
          Column()
            .width(FRAME_WIDTH)
            .height(FRAME_HEIGHT)
            .borderRadius(Theme.TAROT_CARD_RADIUS + 2)
            .border({ width: 2, color: Theme.GOLD_LIGHT })
            .backgroundColor('rgba(229, 165, 10, 0.06)')
            .hitTestBehavior(HitTestMode.None)
        }
        .hitTestBehavior(HitTestMode.None)
      }
      .width('100%')
      .height(FRAME_HEIGHT + 60)
      .alignContent(Alignment.Center)
      .margin({ top: Theme.SPACE_LG })
      // 手势层 — 捕获速度用于惯性计算
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal, distance: 8 })
          .onActionStart(() => {
            this.isDragging = true;
            this.updateConfirmBtnEnabled();
            this.centerGlowAlpha = 0;
            // 重置惯性速度记录
            this.inertiaVelocity = 0;
            this.stopInertia();
          })
          .onActionUpdate((event: GestureEvent) => {
            // 实时更新拖动偏移
            this.dragOffsetX = event.offsetX;
            // 记录手势速度（用于松手后的惯性计算）
            if (event.velocityX !== undefined) {
              this.inertiaVelocity = -event.velocityX / 60; // 转换为 vp/frame
            }
          })
          .onActionEnd(() => {
            // 松手 → 惯性滚动或直接吸附
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
    // 确保跳转前清理所有定时器（惯性/吸附回调）
    this.stopInertia();
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
        entryMode: 'CARD_WHEEL',
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
        source: 'card_wheel',
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
      // 沉浸式深空背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['#060B1A', 0.0],
            ['#0A0D1A', 0.55],
            ['#0A0D1A', 1.0]
          ]
        })

      // 沉浸光感层：中心柔和金色径向渐变（聚焦在牌轮区域）
      Column()
        .width('100%')
        .height('100%')
        .radialGradient({
          center: ['50%', '45%'],
          radius: '55%',
          colors: [
            ['rgba(197, 160, 80, 0.06)', 0.0],
            ['rgba(197, 160, 80, 0.02)', 0.45],
            ['rgba(15, 15, 35, 0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

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
          .fontSize(Theme.V2C_FONT_TITLE)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_MD })

        // 副标题
        Text('左右滑动牌轮，停下后确认中间的牌。')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_SM })

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
            .fontSize(Theme.V2C_FONT_SUBTITLE)
            .fontColor(Theme.V2C_GOLD_GILT_SOFT)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: Theme.SPACE_XS })

          // 引导提示（不显示牌名）
          Text(this.instructionText)
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ bottom: Theme.SPACE_MD })

          // 确认按钮
          Button(this.confirmText)
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_BG_BASE)
            .fontWeight(FontWeight.Medium)
            .width('72%')
            .height(Theme.BTN_HEIGHT)
            .backgroundColor(Theme.V2C_GOLD_GILT)
            .borderRadius(Theme.V2_RADIUS_FULL)
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
      // 牌背图片（支持中心亮度提升 + 边缘暗化）
      Image($r('app.media.card_back'))
        .width(CARD_WIDTH * this.getCardScale())
        .height(CARD_HEIGHT * this.getCardScale())
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.TAROT_CARD_RADIUS)
        .opacity(this.getCardOpacity())
        .brightness(this.getCardBrightness())
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
    .translate({ x: this.getCardTranslateX(), y: this.getCardLift() })
  }

  private visualPosition(): number {
    return this.offsetFromCenter + (this.dragOffsetX / ITEM_STEP);
  }

  /** 平滑缩放：中心 1.0 → 边缘 MIN_SCALE（柔和衰减） */
  private getCardScale(): number {
    const distance: number = Math.abs(this.visualPosition());
    // 使用平滑曲线：1 - distance² * k，使得边缘衰减更柔和
    const scale: number = CENTER_SCALE - (distance * distance * 0.045);
    return Math.max(MIN_SCALE, scale);
  }

  /** 透明度：中心 1.0 → 边缘 MIN_OPACITY（柔和淡出） */
  private getCardOpacity(): number {
    const distance: number = Math.abs(this.visualPosition());
    const opacity: number = CENTER_OPACITY - (distance * distance * 0.055);
    return Math.max(MIN_OPACITY, opacity);
  }

  /** 亮度：中心亮 → 边缘暗（模拟聚焦光感） */
  private getCardBrightness(): number {
    const distance: number = Math.abs(this.visualPosition());
    const brightness: number = CENTER_BRIGHTNESS - (distance * 0.18);
    return Math.max(EDGE_BRIGHTNESS, brightness);
  }

  /** 轻微旋转（Y轴透视感），中心 0° → 边缘 ±15° */
  private getCardRotate(): number {
    return this.visualPosition() * -8;
  }

  /** Z轴层级：中心最高 → 边缘递减 */
  private getCardZIndex(): number {
    const distance: number = Math.abs(this.visualPosition());
    return Math.round(100 - distance * 12);
  }

  /** 水平位移 */
  private getCardTranslateX(): number {
    return this.visualPosition() * ITEM_STEP;
  }

  /** 垂直悬浮：中心牌微微上浮（悬浮感），边缘归零 */
  private getCardLift(): number {
    const distance: number = Math.abs(this.visualPosition());
    if (distance < 0.5) {
      return -CENTER_LIFT;
    }
    const lift: number = -CENTER_LIFT * Math.max(0, 1 - distance * 0.5);
    return Math.round(lift * 10) / 10;
  }
}

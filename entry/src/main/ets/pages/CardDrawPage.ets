import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { MVP8_CARD_IMAGES, MVP8_CARD_NAMES, getGoldenSentence } from '../data/MVP8CardsData';
import { drawCardByWeight } from '../data/HeartOptionsData';
import { drawCardByPositiveWeight, getPositiveGoldenSentence, PositiveEmotionTag } from '../data/PositiveHeartOptions';
import { generateRecordId } from '../model/MvpDivinationRecord';
import { EmotionTag } from '../model/TarotCard';

/**
 * 抽牌页路由入参（P0.2 扩展）
 */
interface CardDrawPageParams {
  entryMode: string;
  spreadType: string;
  heartOptionIndex: number;
  emotionTag: string;
  questionText: string;
}

/**
 * 结果页路由参数 (P0.2 扩展)
 */
interface ResultGoldenRouteParams {
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
 * 抽牌动画页面
 *
 * 动画序列：
 * 1. 牌背淡入（0.3s）
 * 2. 翻牌动画（0.6s rotateY 180°）
 * 3. 正面展示停留（0.5s）
 * 4. 金色粒子效果（0.4s）
 * 5. 自动跳转 ResultGoldenPage
 */
@Entry
@Component
struct CardDrawPage {
  @State private cardId: string = '';
  @State private isReversed: boolean = false;
  @State private heartOptionIndex: number = 0;
  @State private emotionTag: string = '';
  @State private goldenSentence: string = '';
  @State private entryMode: string = 'NORMAL_SINGLE';
  @State private spreadType: string = 'SINGLE';
  @State private questionText: string = '';
  @State private isPositiveMode: boolean = false;

  // 动画阶段：'loading' | 'fadeIn' | 'flipping' | 'revealed' | 'particles' | 'done'
  @State private animPhase: string = 'loading';
  @State private flipAngle: number = 0;
  @State private cardOpacity: number = 0;
  // ── B 方案月光呼吸动画状态 ──
  @State private moonlightOpacity: number = 0.6;
  // ── Timer 生命周期管理 ──
  private isPageAlive: boolean = true;
  private timerIds: number[] = [];

  async aboutToAppear(): Promise<void> {
    this.isPageAlive = true;
    // 接收路由参数
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params = rawParams as CardDrawPageParams;
      this.heartOptionIndex = params.heartOptionIndex ?? 0;
      this.emotionTag = params.emotionTag ?? '寻求安慰';
      this.entryMode = params.entryMode ?? 'NORMAL_SINGLE';
      this.spreadType = params.spreadType ?? 'SINGLE';
      this.questionText = params.questionText ?? '';
      // 判断是否为积极方向（通过 emotionTag 是否匹配积极标签）
      this.isPositiveMode = this.isPositiveEmotionTag(this.emotionTag);
    } else {
      this.emotionTag = '寻求安慰';
      this.heartOptionIndex = 0;
      this.entryMode = 'NORMAL_SINGLE';
      this.spreadType = 'SINGLE';
      this.questionText = '';
      this.isPositiveMode = false;
    }

    // B 方案月光呼吸动画（6s 无限循环）
    animateTo({
      duration: Theme.V2_ANIM_MOONLIGHT_BREATH,
      iterations: -1,
      curve: Curve.EaseInOut
    }, () => {
      this.moonlightOpacity = 1.0;
    });
  }

  aboutToDisappear(): void {
    this.isPageAlive = false;
    for (let i = 0; i < this.timerIds.length; i++) {
      clearTimeout(this.timerIds[i]);
    }
    this.timerIds = [];
  }

  onPageShow(): void {
    // 执行抽牌逻辑
    this.performDraw();
  }

  /**
   * 判断是否为积极方向标签
   */
  private isPositiveEmotionTag(tag: string): boolean {
    const positiveTags: string[] = ['给我鼓励', '今日微光', '找回力量', '一点勇气', '积极一面', '一句提醒'];
    return positiveTags.includes(tag);
  }

  /**
   * 执行加权随机抽牌并启动动画序列
   */
  private performDraw(): void {
    if (this.isPositiveMode) {
      const result = drawCardByPositiveWeight(this.emotionTag as PositiveEmotionTag);
      this.cardId = result.cardId;
      this.isReversed = result.isReversed;
      this.goldenSentence = getPositiveGoldenSentence(this.cardId, this.emotionTag as PositiveEmotionTag);
    } else {
      const result = drawCardByWeight(this.emotionTag as EmotionTag);
      this.cardId = result.cardId;
      this.isReversed = result.isReversed;
      this.goldenSentence = getGoldenSentence(this.cardId, this.emotionTag as EmotionTag);
    }

    // 启动动画序列
    this.startAnimation();
  }

  /**
   * 动画序列控制器 — 所有 setTimeout 均受生命周期保护
   */
  private startAnimation(): void {
    // 阶段 1：牌背淡入（0.3s）
    this.animPhase = 'fadeIn';
    this.timerIds.push(setTimeout(() => {
      if (!this.isPageAlive) { return; }
      this.cardOpacity = 1;
    }, 50));

    // 阶段 2：开始翻牌（0.3s 后开始，持续 0.6s）
    this.timerIds.push(setTimeout(() => {
      if (!this.isPageAlive) { return; }
      this.animPhase = 'flipping';
      this.flipAngle = 180;
    }, 300));

    // 阶段 3：翻牌完成，展示正面（0.9s 后）
    this.timerIds.push(setTimeout(() => {
      if (!this.isPageAlive) { return; }
      this.animPhase = 'revealed';
    }, 900));

    // 阶段 4：金色粒子效果（1.4s 后）
    this.timerIds.push(setTimeout(() => {
      if (!this.isPageAlive) { return; }
      this.animPhase = 'particles';
    }, 1400));

    // 阶段 5：跳转结果页（1.8s 后）
    this.timerIds.push(setTimeout(() => {
      if (!this.isPageAlive) { return; }
      this.navigateToResult();
    }, 1800));
  }

  /**
   * 跳转到结果页面
   */
  private navigateToResult(): void {
    if (this.animPhase === 'done') {
      return; // 防止重复跳转
    }
    this.animPhase = 'done';

    const recordId: string = generateRecordId();
    const cardName: string = MVP8_CARD_NAMES[this.cardId] ?? '未知';
    const routeParams: ResultGoldenRouteParams = {
      entryMode: this.entryMode,
      recordId: recordId,
      cardId: this.cardId,
      cardName: cardName,
      isReversed: this.isReversed,
      heartOptionIndex: this.heartOptionIndex,
      emotionTag: this.emotionTag,
      goldenSentence: this.goldenSentence,
      questionText: this.questionText,
    };

    const routeOptions: router.RouterOptions = {
      url: Routes.RESULT_GOLDEN,
      params: routeParams,
    };

    try {
      router.replaceUrl(routeOptions).catch((_err: Error) => {
        this.getUIContext().getPromptAction().showToast({ message: '页面跳转失败' });
      });
    } catch (_err) {
      this.getUIContext().getPromptAction().showToast({ message: '页面跳转失败' });
    }
  }

  build() {
    Stack() {
      // ── 深色全屏背景 ──
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2C_BG_BASE)

      // ── B 方案月光呼吸光晕层（顶部 6s 循环）──
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

      // ── 星星背景粒子（简化为静态暗色背景 + loading 指示）──
      if (this.animPhase === 'loading' || this.animPhase === 'fadeIn') {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Theme.V2C_GOLD_GILT_SOFT)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }

      // ── 卡片展示区（响应式比例：TopBar 14% / CardStage 60% / Prompt+Action 26%）──
      Column() {
          // ── 返回按钮（固定高度，不参与比例分配）──
        Row() {
          AppBackButton({ fallbackUrl: Routes.HOME })
        }
        .width('100%')
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SCREEN_PAD })

        // ── TopBar 标题区（layoutWeight 14）──
        Column() {
          Text('星澜正在为你抽一张牌')
            .fontSize(Theme.V2C_FONT_SUBTITLE)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .layoutWeight(14)
        .justifyContent(FlexAlign.End)
        .padding({ bottom: Theme.SPACE_SM })

        // ── CardStage 牌面舞台区（layoutWeight 60，主体）──
        Column() {
          if (this.cardId) {
            Image(
              this.animPhase === 'revealed' || this.animPhase === 'particles' || this.animPhase === 'done'
                ? (MVP8_CARD_IMAGES[this.cardId] ?? $r('app.media.tarot_major_18_moon'))
                : $r('app.media.card_back')
            )
              .width('46%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.TAROT_CARD_RADIUS)
              .rotate({
                y: this.flipAngle,
                centerX: '50%',
              })
              .opacity(this.cardOpacity)
              .animation({
                duration: Theme.ANIM_FLIP_DURATION,
                curve: Curve.EaseInOut,
              })
              .constraintSize({ maxWidth: Theme.CARD_SIZE_DRAW_STAGE.width, maxHeight: Theme.CARD_SIZE_DRAW_STAGE.height })
          }
        }
        .width('100%')
        .layoutWeight(60)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // ── Prompt 提示区 + Action 操作区（layoutWeight 26，底部安全区）──
        Column() {
          if (this.animPhase !== 'particles' && this.animPhase !== 'done' && this.cardId) {
            Text('星澜正在解读你的心事...')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .margin({ top: Theme.SPACE_MD })
              .opacity(this.cardOpacity)
          }

          LoadingProgress()
            .width(40)
            .height(40)
            .color(Theme.V2C_GOLD_GILT_SOFT)
            .margin({ top: Theme.SPACE_MD })
        }
        .width('100%')
        .layoutWeight(26)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: Theme.SAFE_BOTTOM })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}

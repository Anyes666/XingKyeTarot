import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { MVP8_CARD_IMAGES, MVP8_CARD_NAMES, getGoldenSentence } from '../data/MVP8CardsData';
import { drawCardByWeight } from '../data/HeartOptionsData';
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

  // 动画阶段：'loading' | 'fadeIn' | 'flipping' | 'revealed' | 'particles' | 'done'
  @State private animPhase: string = 'loading';
  @State private flipAngle: number = 0;
  @State private cardOpacity: number = 0;

  async aboutToAppear(): Promise<void> {
    // 接收路由参数
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params = rawParams as CardDrawPageParams;
      this.heartOptionIndex = params.heartOptionIndex ?? 0;
      this.emotionTag = params.emotionTag ?? '寻求安慰';
      this.entryMode = params.entryMode ?? 'NORMAL_SINGLE';
      this.spreadType = params.spreadType ?? 'SINGLE';
      this.questionText = params.questionText ?? '';
    } else {
      this.emotionTag = '寻求安慰';
      this.heartOptionIndex = 0;
      this.entryMode = 'NORMAL_SINGLE';
      this.spreadType = 'SINGLE';
      this.questionText = '';
    }
  }

  onPageShow(): void {
    // 执行抽牌逻辑
    this.performDraw();
  }

  /**
   * 执行加权随机抽牌并启动动画序列
   */
  private performDraw(): void {
    const result = drawCardByWeight(this.emotionTag as EmotionTag);
    this.cardId = result.cardId;
    this.isReversed = result.isReversed;
    this.goldenSentence = getGoldenSentence(this.cardId, this.emotionTag as EmotionTag);

    // 启动动画序列
    this.startAnimation();
  }

  /**
   * 动画序列控制器
   */
  private startAnimation(): void {
    // 阶段 1：牌背淡入（0.3s，即 ANIM_FADE_IN=400ms）
    this.animPhase = 'fadeIn';
    setTimeout(() => {
      this.cardOpacity = 1;
    }, 50);

    // 阶段 2：开始翻牌（0.3s 后开始，持续 0.6s）
    setTimeout(() => {
      this.animPhase = 'flipping';
      this.flipAngle = 180;
    }, 300);

    // 阶段 3：翻牌完成，展示正面（0.3+0.6=0.9s 后，停留 0.5s）
    setTimeout(() => {
      this.animPhase = 'revealed';
    }, 900);

    // 阶段 4：金色粒子效果（1.4s 后，持续 0.4s）
    setTimeout(() => {
      this.animPhase = 'particles';
    }, 1400);

    // 阶段 5：跳转结果页（1.8s 后，略小于总动画时长 1.5s，留余量）
    setTimeout(() => {
      this.navigateToResult();
    }, 1800);
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
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      // ── 星星背景粒子（简化为静态暗色背景 + loading 指示）──
      if (this.animPhase === 'loading' || this.animPhase === 'fadeIn') {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Theme.GOLD_LIGHT)
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
            .fontSize(Theme.FONT_SUBTITLE)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
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
              .objectFit(ImageFit.Contain)
              .borderRadius(Theme.RADIUS_MD)
              .rotate({
                y: this.flipAngle,
                centerX: '50%',
              })
              .opacity(this.cardOpacity)
              .animation({
                duration: Theme.ANIM_FLIP_DURATION,
                curve: Curve.EaseInOut,
              })
              .constraintSize({ maxWidth: 200, maxHeight: 320 })
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
              .fontSize(Theme.FONT_BODY)
              .fontColor(Theme.MOON_MUTED)
              .margin({ top: Theme.SPACE_MD })
              .opacity(this.cardOpacity)
          }

          LoadingProgress()
            .width(40)
            .height(40)
            .color(Theme.GOLD_LIGHT)
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

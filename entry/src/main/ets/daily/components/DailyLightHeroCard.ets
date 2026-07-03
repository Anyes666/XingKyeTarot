import { router } from '@kit.ArkUI';
import { Theme } from '../../common/Theme';
import { Routes } from '../../common/Routes';
import { SafeUiActions } from '../../common/SafeUiActions';
import { DailyRitualStore } from '../service/DailyRitualStore';
import { DailyRitualState } from '../model/DailyRitualState';
import { DailyLightContent } from '../model/DailyLightContent';
import { findContentById } from '../data/DailyLightCopyLibrary';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'DailyLightHeroCard';

/**
 * 今日星页 Hero 卡（DAILY-3）
 *
 * 承载于占卜 Tab 顶部，展示今日星页未完成 / 已完成两种状态，
 * 提供进入今日星页与和星澜说话的入口。
 *
 * 视觉：C「星钥之书」为主，入口处融入 B「月湖映心」
 *   - 顶部一道极淡月光渐变（B 融入）；
 *   - 卡片底用 C 书页底色 + 烫金细线边框；
 *   - 金色只作为标题、细线、按钮文字点缀，不铺大面积金；
 *   - 主按钮圆角稳定（V2C_RADIUS_BTN）；
 *   - 按压反馈 scale 0.97；
 *   - 小屏由父容器 Scroll 承载滚动。
 *
 * 状态来源：DailyRitualStore.getTodayState（只读）。
 * 不修改 EmotionStarStorage、不修改抽牌算法、不修改占卜入口逻辑。
 *
 * 跳转：
 *   - onExpand / onReview 由父组件注入，DAILY-4 接入 DailyLightPage；
 *   - onChatWithXinglan 由父组件注入，跳转到星澜聊天入口。
 */
@Component
export struct DailyLightHeroCard {
  /** 未完成态「展开今日星页」回调（DAILY-4 接入 DailyLightPage） */
  onExpand: () => void = () => {};
  /** 已完成态「回看今日微光」回调（DAILY-4 接入 DailyLightPage 回看模式） */
  onReview: () => void = () => {};
  /** 已完成态「和星澜说一句」回调（跳转星澜聊天入口） */
  onChatWithXinglan: () => void = () => {};

  @State private stateLoaded: boolean = false;
  @State private completed: boolean = false;
  @State private mainLine: string = '';

  // 按压态（每个按钮独立状态，避免共用一个状态互相影响）
  @State private expandPressed: boolean = false;
  @State private reviewPressed: boolean = false;
  @State private chatPressed: boolean = false;
  // DAILY-7：「回望今天」入口按压态
  @State private reflectPressed: boolean = false;

  async aboutToAppear(): Promise<void> {
    try {
      const ctx: Context = getContext(this);
      const state: DailyRitualState = await DailyRitualStore.getTodayState(ctx);
      this.completed = state.completed;
      if (state.completed && state.contentId !== undefined && state.contentId.length > 0) {
        const content: DailyLightContent | null = findContentById(state.contentId);
        if (content !== null) {
          this.mainLine = content.mainLine;
        }
      }
      this.stateLoaded = true;
    } catch (_err) {
      hilog.warn(0x0000, TAG, 'load today state failed');
      // 兜底为未完成态，保证 Hero 仍可展示入口
      this.completed = false;
      this.mainLine = '';
      this.stateLoaded = true;
    }
  }

  /**
   * DAILY-7：跳转月湖回望页。
   *
   * 不强制晚上才能进入（V2 计划 5.4：不设置强制倒计时，白天也可进入）。
   * 路由跳转遵循 ArkTS 规则：先声明 RouterOptions，try/catch 包裹。
   * 不携带上下文参数（DailyReflectionPage 自行读取 DailyRitualStore）。
   */
  private handleReflect(): void {
    try {
      const options: router.RouterOptions = {
        url: Routes.DAILY_REFLECTION
      };
      router.pushUrl(options);
    } catch (_err) {
      hilog.warn(0x0000, TAG, 'navigate to daily reflection failed');
      SafeUiActions.safeToast('暂时没能打开月湖回望，请稍后再试');
    }
  }

  build() {
    Column() {
      if (!this.stateLoaded) {
        this.BuildLoading()
      } else if (this.completed) {
        this.BuildCompleted()
      } else {
        this.BuildPending()
      }
    }
    .width('92%')
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: Theme.V2_SPACE_LG })
  }

  /**
   * 加载占位：同风格空卡，避免布局跳动。
   */
  @Builder
  BuildLoading(): void {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(18,24,54,0.78)')
      Row()
        .width('62%')
        .height(1)
        .backgroundColor('rgba(197,160,80,0.18)')
        .position({ x: '19%', y: 0 })
    }
    .width('100%')
    .height(132)
    .clip(true)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197,160,80,0.14)' })
  }

  /**
   * 未完成态：标题 / 主标题 / 副文案 / 「展开今日星页」主按钮。
   */
  @Builder
  BuildPending(): void {
    Stack() {
      // C 书页底 + 顶部 B 月光融入
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['rgba(212,172,77,0.05)', 0.0],
            ['rgba(18,24,54,0.82)', 0.46],
            ['rgba(10,13,26,0.55)', 1.0]
          ]
        })

      // 顶部烫金细线（书脊感）
      Row()
        .width('62%')
        .height(1)
        .backgroundColor('rgba(197,160,80,0.28)')
        .position({ x: '19%', y: 0 })

      Column() {
        Text('今日星页')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_GOLD_GILT)
          .letterSpacing(2)
          .margin({ top: Theme.V2_SPACE_LG })

        Text('今天，想怎样站在自己这一边？')
          .fontSize(Theme.V2C_FONT_LEAD)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .lineHeight(28)
          .margin({ top: Theme.V2_SPACE_SM, left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD })

        Text('用不到一分钟，为今天留下一点方向。')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .margin({ top: Theme.V2_SPACE_SM })

        // 主按钮：深色底 + 烫金细边 + 烫金文字（不大面积金）
        Text('展开今日星页')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(46)
          .borderRadius(Theme.V2C_RADIUS_BTN)
          .backgroundColor('rgba(197,160,80,0.10)')
          .border({ width: 1, color: 'rgba(197,160,80,0.32)' })
          .scale({
            x: this.expandPressed ? Theme.PRESS_SCALE : 1.0,
            y: this.expandPressed ? Theme.PRESS_SCALE : 1.0
          })
          .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
          .margin({ top: Theme.V2_SPACE_LG })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.expandPressed = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.expandPressed = false;
            }
          })
          .onClick(() => {
            this.onExpand();
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: Theme.V2_SPACE_LG,
        right: Theme.V2_SPACE_LG,
        bottom: Theme.V2_SPACE_LG,
        top: Theme.V2_SPACE_2XS
      })
    }
    .width('100%')
    .clip(true)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197,160,80,0.18)' })
    .shadow(Theme.V2C_SHADOW_CARD)
  }

  /**
   * 已完成态：标题 / 今日 mainLine 引文 / 「回看今日微光」主按钮 / 「和星澜说一句」次按钮。
   */
  @Builder
  BuildCompleted(): void {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['rgba(212,172,77,0.06)', 0.0],
            ['rgba(18,24,54,0.82)', 0.46],
            ['rgba(10,13,26,0.55)', 1.0]
          ]
        })

      Row()
        .width('62%')
        .height(1)
        .backgroundColor('rgba(197,160,80,0.32)')
        .position({ x: '19%', y: 0 })

      Column() {
        Text('今天已经点亮')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_GOLD_GILT)
          .letterSpacing(2)
          .margin({ top: Theme.V2_SPACE_LG })

        // 今日 mainLine 引文（书页被轻轻标出的句子）
        Text(this.mainLine)
          .fontSize(Theme.V2C_FONT_LEAD)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .lineHeight(28)
          .margin({ top: Theme.V2_SPACE_SM, left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD })
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 主按钮：回看今日微光
        Text('回看今日微光')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(46)
          .borderRadius(Theme.V2C_RADIUS_BTN)
          .backgroundColor('rgba(197,160,80,0.10)')
          .border({ width: 1, color: 'rgba(197,160,80,0.32)' })
          .scale({
            x: this.reviewPressed ? Theme.PRESS_SCALE : 1.0,
            y: this.reviewPressed ? Theme.PRESS_SCALE : 1.0
          })
          .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
          .margin({ top: Theme.V2_SPACE_LG })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.reviewPressed = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.reviewPressed = false;
            }
          })
          .onClick(() => {
            this.onReview();
          })

        // 次按钮：和星澜说一句（透明底 + 细边，不抢主按钮层级）
        Text('和星澜说一句')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(40)
          .borderRadius(Theme.V2C_RADIUS_BTN)
          .backgroundColor('rgba(10,13,26,0.0)')
          .border({ width: 1, color: 'rgba(224,205,149,0.18)' })
          .scale({
            x: this.chatPressed ? Theme.PRESS_SCALE : 1.0,
            y: this.chatPressed ? Theme.PRESS_SCALE : 1.0
          })
          .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
          .margin({ top: Theme.V2_SPACE_SM })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.chatPressed = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.chatPressed = false;
            }
          })
          .onClick(() => {
            this.onChatWithXinglan();
          })

        // DAILY-7：回望今天（最轻入口，跳转月湖回望页）
        // 不带「晚上」字样，白天也可进入，符合 V2 计划 5.4「不设置强制倒计时」
        Text('回望今天')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(36)
          .borderRadius(Theme.V2C_RADIUS_BTN)
          .backgroundColor('rgba(10,13,26,0.0)')
          .scale({
            x: this.reflectPressed ? Theme.PRESS_SCALE : 1.0,
            y: this.reflectPressed ? Theme.PRESS_SCALE : 1.0
          })
          .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
          .margin({ top: Theme.V2_SPACE_2XS })
          .accessibilityGroup(true)
          .accessibilityText('回望今天，进入月湖回望')
          .accessibilityLevel('yes')
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.reflectPressed = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.reflectPressed = false;
            }
          })
          .onClick(() => {
            this.handleReflect();
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({
        left: Theme.V2_SPACE_LG,
        right: Theme.V2_SPACE_LG,
        bottom: Theme.V2_SPACE_LG,
        top: Theme.V2_SPACE_2XS
      })
    }
    .width('100%')
    .clip(true)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197,160,80,0.18)' })
    .shadow(Theme.V2C_SHADOW_CARD)
  }
}

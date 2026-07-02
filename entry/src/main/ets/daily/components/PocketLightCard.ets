import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { Theme } from '../../common/Theme';
import { SafeUiActions } from '../../common/SafeUiActions';
import { ShareImageService, SaveImageResult } from '../../service/ShareImageService';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'PocketLightCard';

/**
 * 口袋微光卡（DAILY-6）
 *
 * 用途：完成今日星页后自动展示一句 20–40 字短文案（pocketLight），
 *       并提供「保存到星历」「生成分享卡」「和星澜聊聊」三个入口。
 *
 * 视觉：B「月湖映心」
 *   - 湖中石板底色（V2B_BG_CARD）+ 极淡月光光晕；
 *   - 烫金细线仅在标题与按钮文字点缀，不铺大面积金；
 *   - 圆角倾向圆润（V2B_RADIUS_CARD / V2B_RADIUS_BTN）；
 *   - 文案用月光白（V2B_TEXT_PRIMARY），副字用水雾灰（V2B_TEXT_SECONDARY）。
 *
 * 数据来源：DailyLightContent.pocketLight（由父组件传入，组件本身不查库）。
 *
 * 隐私保护（V2 计划 5.1）：
 *   - 默认不显示具体情绪与关系内容；
 *   - 只展示通用 pocketLight 文案；
 *   - 截图分享只截本卡内容，不暴露方向、mainLine、observation、microAction。
 *
 * 三个入口：
 *   1. 「保存到星历」：onPocketSave 回调（由 DailyLightPage 调用
 *      DailyRitualStore.markSavedToCalendar，仅写日期 + 内容 ID + 方向 + 微光反查路径）；
 *   2. 「生成分享卡」：本卡内部直接截图 + 调用 ShareImageService 保存到相册
 *      （复用 ShareCardPage → ShareImageService 同一保存路径，不修改 ShareCardPage）；
 *   3. 「和星澜聊聊」：onChatWithXinglan 回调（DailyLightPage 跳转 XinglanChatPage）。
 *
 * 不修改：ShareImageService 核心逻辑、HistoryStore 规则、EmotionStarStorage 规则。
 * 不使用 any / as any / @ts-ignore。
 */
@Component
export struct PocketLightCard {
  /** 今日口袋微光短文案（20–40 字，来自 DailyLightContent.pocketLight） */
  @Prop pocketLight: string = '';
  /** 今日日期 key（yyyy-MM-dd），用于截图文件名 */
  @Prop dateKey: string = '';
  /** 是否已保存到星历（用于切换按钮文案） */
  @Prop savedToCalendar: boolean = false;
  /** 减少动态效果（截图前置淡入降级） */
  @Prop reduceMotion: boolean = false;
  /** 「保存到星历」回调 */
  onPocketSave: () => void = () => {};
  /** 「和星澜聊聊」回调（跳转星澜聊天页） */
  onChatWithXinglan: () => void = () => {};

  /** 按压态（每个按钮独立，避免共用一个状态互相影响） */
  @State private savePressed: boolean = false;
  @State private sharePressed: boolean = false;
  @State private chatPressed: boolean = false;

  /** 是否正在生成分享卡（截图 + 保存到相册） */
  @State private isSharing: boolean = false;

  /** 卡片渐入 opacity（reduceMotion=true 时直接 1.0） */
  @State private cardOpacity: number = 0;

  /** 截图区域组件 id（与 build 中的 .id() 一致） */
  private readonly shareCardId: string = 'pocket_light_card_share';

  aboutToAppear(): void {
    if (this.reduceMotion) {
      this.cardOpacity = 1.0;
    } else {
      // 极短淡入（150ms），保持月光感，不弹跳
      setTimeout(() => {
        this.cardOpacity = 1.0;
      }, 40);
    }
  }

  build() {
    Column() {
      // ── 可截图区域：只包含 pocketLight 文案 + 通用装饰 ──
      // 隐私：不出现方向标签、mainLine、observation、microAction
      Column() {
        // 顶部月光光晕（B 方案极淡金色径向渐变）
        Column()
          .width('100%')
          .height(120)
          .radialGradient({
            center: ['50%', '18%'],
            radius: '70%',
            colors: [
              ['rgba(212,172,77,0.06)', 0.0],
              ['rgba(212,172,77,0.018)', 0.58],
              ['rgba(6,11,26,0)', 1.0]
            ]
          })
          .hitTestBehavior(HitTestMode.None)

        // 「口袋微光」小标题
        Text('口袋微光')
          .fontSize(Theme.V2B_FONT_CAPTION)
          .fontColor(Theme.V2B_GOLD_CORE)
          .letterSpacing(2)
          .margin({ top: Theme.V2_SPACE_LG })

        // 烫金细线分隔
        Row()
          .width(36)
          .height(1)
          .backgroundColor('rgba(212,172,77,0.32)')
          .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_MD })

        // 今日微光文案（核心展示）
        Text(this.pocketLight)
          .fontSize(Theme.V2B_FONT_LEAD)
          .fontColor(Theme.V2B_TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .lineHeight(30)
          .textAlign(TextAlign.Center)
          .margin({
            left: Theme.V2_SPACE_LG,
            right: Theme.V2_SPACE_LG,
            bottom: Theme.V2_SPACE_LG
          })
          .accessibilityGroup(true)
          .accessibilityText(`口袋微光：${this.pocketLight}`)
          .accessibilityLevel('yes')

        // 底部水印（截图自带来源标识，不含敏感信息）
        Text('星钥塔罗 · 星澜')
          .fontSize(Theme.V2B_FONT_DISCLAIMER)
          .fontColor(Theme.V2B_TEXT_SECONDARY)
          .letterSpacing(1)
          .margin({ bottom: Theme.V2_SPACE_MD })
          .opacity(0.7)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Theme.V2B_BG_CARD)
      .borderRadius(Theme.V2B_RADIUS_CARD)
      .border({ width: 1, color: 'rgba(212,172,77,0.18)' })
      .shadow(Theme.V2B_SHADOW_CARD)
      .clip(true)
      .id(this.shareCardId)
      .opacity(this.cardOpacity)
      .animation({ duration: this.reduceMotion ? 0 : 180, curve: Theme.V2_EASE_OUT })

      // ── 三入口（不在截图区域内）──
      Column({ space: Theme.V2_SPACE_SM }) {
        // 主按钮：保存到星历
        Text(this.savedToCalendar ? '已保存到星历' : '保存到星历')
          .fontSize(Theme.V2B_FONT_BODY)
          .fontColor(this.savedToCalendar ? Theme.V2_STATE_DISABLED_TEXT : Theme.V2B_GOLD_RIPPLE)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(46)
          .borderRadius(Theme.V2B_RADIUS_BTN)
          .backgroundColor(this.savedToCalendar ? 'rgba(138,132,152,0.10)' : 'rgba(212,172,77,0.10)')
          .border({
            width: 1,
            color: this.savedToCalendar ? 'rgba(138,132,152,0.18)' : 'rgba(212,172,77,0.32)'
          })
          .scale({
            x: this.savePressed && !this.savedToCalendar ? Theme.PRESS_SCALE : 1.0,
            y: this.savePressed && !this.savedToCalendar ? Theme.PRESS_SCALE : 1.0
          })
          .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
          .margin({ top: Theme.V2_SPACE_MD })
          .accessibilityGroup(true)
          .accessibilityText(
            this.savedToCalendar ? '已保存到今日星历' : '保存口袋微光到星历'
          )
          .accessibilityLevel(this.savedToCalendar ? 'no' : 'yes')
          .onTouch((event: TouchEvent) => {
            if (this.savedToCalendar) {
              return;
            }
            if (event.type === TouchType.Down) {
              this.savePressed = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.savePressed = false;
            }
          })
          .onClick(() => {
            if (this.savedToCalendar) {
              return;
            }
            this.onPocketSave();
          })

        // 次按钮：生成分享卡（截图 + 保存到相册）
        Text(this.isSharing ? '正在生成…' : '生成分享卡')
          .fontSize(Theme.V2B_FONT_CAPTION)
          .fontColor(this.isSharing ? Theme.V2_STATE_DISABLED_TEXT : Theme.V2B_TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(42)
          .borderRadius(Theme.V2B_RADIUS_BTN)
          .backgroundColor('rgba(10,13,26,0.0)')
          .border({
            width: 1,
            color: this.isSharing ? 'rgba(138,132,152,0.18)' : 'rgba(224,205,149,0.22)'
          })
          .scale({
            x: this.sharePressed && !this.isSharing ? Theme.PRESS_SCALE : 1.0,
            y: this.sharePressed && !this.isSharing ? Theme.PRESS_SCALE : 1.0
          })
          .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
          .accessibilityGroup(true)
          .accessibilityText(
            this.isSharing ? '正在生成分享卡，请稍候' : '生成分享卡，保存口袋微光图片到相册'
          )
          .accessibilityLevel(this.isSharing ? 'no' : 'yes')
          .onTouch((event: TouchEvent) => {
            if (this.isSharing) {
              return;
            }
            if (event.type === TouchType.Down) {
              this.sharePressed = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.sharePressed = false;
            }
          })
          .onClick(() => {
            if (this.isSharing) {
              return;
            }
            this.handleGenerateShareCard();
          })

        // 次按钮：和星澜聊聊
        Text('和星澜聊聊')
          .fontSize(Theme.V2B_FONT_CAPTION)
          .fontColor(Theme.V2B_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(42)
          .borderRadius(Theme.V2B_RADIUS_BTN)
          .backgroundColor('rgba(10,13,26,0.0)')
          .border({ width: 1, color: 'rgba(224,205,149,0.18)' })
          .scale({
            x: this.chatPressed ? Theme.PRESS_SCALE : 1.0,
            y: this.chatPressed ? Theme.PRESS_SCALE : 1.0
          })
          .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
          .accessibilityGroup(true)
          .accessibilityText('和星澜聊聊，跳转到星澜聊天页')
          .accessibilityLevel('yes')
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
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 生成分享卡：截图本卡内容 → 调用 ShareImageService 保存到相册。
   *
   * 复用 ShareCardPage → ShareImageService.savePixelMapToGalleryWithResult 同一保存路径，
   * 不修改 ShareCardPage、不修改 ShareImageService 核心逻辑。
   *
   * 失败时不假成功：根据 SaveImageResult.stage 与 savedToAlbum 给出真实 Toast。
   * 用户取消（stage='cancel'）静默处理，不报错。
   */
  private async handleGenerateShareCard(): Promise<void> {
    if (this.isSharing) {
      return;
    }
    this.isSharing = true;
    try {
      const pixelMap: image.PixelMap | undefined = await this.captureCard();
      if (pixelMap === undefined) {
        hilog.warn(0x0000, TAG, 'capture failed, pixelMap undefined');
        SafeUiActions.safeToast('截图失败，请稍后再试');
        this.isSharing = false;
        return;
      }

      const ctx: common.UIAbilityContext = this.getUIAbilityContext();
      const fileName: string = this.buildShareFileName();
      const result: SaveImageResult = await ShareImageService.savePixelMapToGalleryWithResult(
        ctx,
        pixelMap,
        fileName
      );

      if (result.success && result.savedToAlbum) {
        SafeUiActions.safeToast('分享卡已保存到相册');
      } else if (result.stage === 'cancel') {
        // 用户取消保存，静默处理，不报错
        hilog.info(0x0000, TAG, 'share card save cancelled by user');
      } else {
        // 真实失败：展示服务返回的 userMessage
        SafeUiActions.safeToast(result.message.length > 0 ? result.message : '保存失败，请稍后再试');
        hilog.warn(0x0000, TAG, 'save failed at stage=%{public}s, code=%{public}s', result.stage, result.errorCode);
      }
    } catch (err) {
      hilog.error(0x0000, TAG, 'handleGenerateShareCard error: %{public}s', JSON.stringify(err));
      SafeUiActions.safeToast('保存失败，请稍后再试');
    }
    this.isSharing = false;
  }

  /**
   * 截取本卡可截图区域为 PixelMap。
   *
   * 使用 UIContext.getComponentSnapshot().get()（与 ShareCardPage 同一 API）。
   * 失败返回 undefined，由调用方兜底。
   */
  private async captureCard(): Promise<image.PixelMap | undefined> {
    try {
      const pixelMap: image.PixelMap = await this.getUIContext().getComponentSnapshot().get(
        this.shareCardId,
        {
          scale: 2,
          waitUntilRenderFinished: true
        }
      );
      return pixelMap;
    } catch (err) {
      hilog.error(0x0000, TAG, 'capture failed: %{public}s', JSON.stringify(err));
      return undefined;
    }
  }

  /**
   * 构建分享卡文件名（纯英文，避免路径/URI 编码问题）。
   * 形如：XingKeyTarot_pocket_YYYYMMDD_<timestamp>.png
   */
  private buildShareFileName(): string {
    const safeDate: string = this.dateKey.length > 0 ? this.dateKey.replace(/-/g, '') : 'unknown';
    return `XingKeyTarot_pocket_${safeDate}_${Date.now()}.png`;
  }

  /**
   * 获取 UIAbilityContext（ShareImageService 需要）。
   *
   * 与 ShareCardPage 同一写法：this.getUIContext().getHostContext() as common.UIAbilityContext。
   * 子组件中 getContext(this) 返回的是 Context 基类，getHostContext 才能稳定拿到宿主
   * UIAbility 的 context。
   */
  private getUIAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }
}

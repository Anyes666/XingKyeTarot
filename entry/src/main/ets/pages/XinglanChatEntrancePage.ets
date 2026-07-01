import { router } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { MoonlightLayer } from '../components/MoonlightLayer';
import { PreferenceStore } from '../data/PreferenceStore';
import { UserProfileStore } from '../common/UserProfileStore';
import { selectEntryGreeting } from '../data/XinglanNicknameGreetings';

/**
 * 星澜聊天入口页 — 月光门廊
 *
 * 设计系统：B 方案「月湖映心」
 * 功能：入口页用星澜立绘 + 弱月光层 + 主文案 + 进入按钮，
 *       营造「星澜在月光里安静陪着我说话」的陪伴感。
 * 参考：deliverables/prototypes/01-chat-entrance.html
 *
 * 设计原则（静态优先）：
 *   - 立绘无圆形裁切、无硬边界，靠底部渐隐遮罩自然融入背景
 *   - 月光氛围用 radialGradient 做整页氛围，不显示可见圆盘
 *   - 关闭立绘浮动 / 月光环呼吸等循环动画，避免幅度叠加
 *   - 仅保留按钮按压 scale + 页面进入淡入（一次性）
 *
 * 拆分说明：
 *   - XinglanChatEntrancePage（@Entry）：独立路由页面，叠加返回按钮 + 内容组件
 *   - XinglanChatEntranceContent（export @Component）：可复用入口内容，
 *     供 MainFramePage 底部 Tab 1 直接嵌入，不包含返回按钮
 */

/** 立绘显示尺寸（大屏默认值，放大 ~7%，提升陪伴感，不超屏高 38%） */
const FIGURE_WIDTH_VP: number = 320;
const FIGURE_HEIGHT_VP: number = 300;

/** 顶部渐隐遮罩高度 */
const FIGURE_FADE_TOP_VP: number = 80;
/** 左侧渐隐遮罩宽度 */
const FIGURE_FADE_LEFT_VP: number = 80;
/** 右侧渐隐遮罩宽度（加宽以覆盖原图右边缘） */
const FIGURE_FADE_RIGHT_VP: number = 120;
/** 底部渐隐遮罩高度（加厚以消除底部硬切线） */
const FIGURE_FADE_BOTTOM_VP: number = 200;

/** 主标题字号（大屏） */
const TITLE_FONT_SIZE_VP: number = 32;

/** 主标题行高 */
const TITLE_LINE_HEIGHT_VP: number = 44;

/** 副文案字号 */
const SUBTITLE_FONT_SIZE_VP: number = 15;

/** 副文案行高 */
const SUBTITLE_LINE_HEIGHT_VP: number = 25;

/** 按钮宽度 */
const BUTTON_WIDTH_VP: number = 320;

/** 按钮高度 */
const BUTTON_HEIGHT_VP: number = 56;

/** 按钮圆角 */
const BUTTON_RADIUS_VP: number = 16;

/** 底部导航预留高度（CompanionBottomNav 总高 88vp） */
const BOTTOM_NAV_RESERVE_VP: number = 88;

/** 底部额外间距 */
const BOTTOM_EXTRA_SPACE_VP: number = 16;

/** 顶部留白（独立页返回按钮 / Tab 状态栏兼容） */
const TOP_RESERVE_VP: number = 56;

/** 响应式分档阈值：可用高度（屏高 - 导航88）小于此值启用小屏缩放 */
const SMALL_SCREEN_THRESHOLD_VP: number = 760;
const MEDIUM_SCREEN_THRESHOLD_VP: number = 840;

/**
 * 静态星点条目（arkts-no-obj-literals-as-types：必须显式声明接口）
 */
interface StaticStarItem {
  x: string;
  y: string;
  s: number;
  o: number;
}

@Entry
@Component
struct XinglanChatEntrancePage {
  @State reducedMotion: boolean = false;

  aboutToAppear(): void {
    this.loadReducedMotion();
  }

  private async loadReducedMotion(): Promise<void> {
    try {
      const context: Context = getContext(this);
      this.reducedMotion = await PreferenceStore.getBoolean('reduced_motion_enabled', false, context);
    } catch (_err) {
      this.reducedMotion = false;
    }
  }

  build() {
    Stack() {
      // 入口内容（含背景、月光、星澜立绘、文案、按钮）
      XinglanChatEntranceContent({ reducedMotion: this.reducedMotion })

      // 顶部返回按钮（仅独立路由页面需要，浮于内容之上）
      Row() {
        AppBackButton({ fallbackUrl: Routes.MAIN_FRAME })
      }
      .width('100%')
      .height(56)
      .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 星澜聊天入口内容组件（可复用）
 *
 * 供 MainFramePage Tab 1 嵌入使用，不包含返回按钮。
 * 按钮点击跳转 Routes.XINGLAN_CHAT 进入真实聊天页。
 *
 * 静态优先：关闭循环动画，只保留按钮按压 + 页面进入淡入。
 */
@Component
export struct XinglanChatEntranceContent {
  @Prop reducedMotion: boolean = false;
  @State private btnPressed: boolean = false;
  @State private pageOpacity: number = 0;
  @State private nickname: string = '未命名旅者';
  @State private greetingTitle: string = '慢慢说，\n星澜会先听你说完';
  @State private greetingSubtitle: string = '这里没有评判，只有陪伴。';

  /** 响应式布局参数（aboutToAppear 根据屏高赋值） */
  @State private figureWidth: number = FIGURE_WIDTH_VP;
  @State private figureHeight: number = FIGURE_HEIGHT_VP;
  @State private titleFontSize: number = TITLE_FONT_SIZE_VP;
  @State private titleLineHeight: number = TITLE_LINE_HEIGHT_VP;
  @State private figureTopMargin: number = 10;
  @State private figureBottomMargin: number = 12;
  @State private subtitleBottomMargin: number = 44;
  @State private disclaimerTopMargin: number = 16;

  /** 静态星点数据 */
  private static readonly STATIC_STARS: StaticStarItem[] = [
    { x: '18%', y: '12%', s: 1.5, o: 0.35 },
    { x: '82%', y: '18%', s: 1.0, o: 0.30 },
    { x: '74%', y: '8%', s: 2.0, o: 0.25 },
    { x: '12%', y: '32%', s: 1.0, o: 0.20 },
    { x: '88%', y: '38%', s: 1.5, o: 0.22 },
    { x: '24%', y: '6%', s: 1.0, o: 0.18 }
  ];

  aboutToAppear(): void {
    this.loadReducedMotion();
    this.loadNicknameAndGreeting();
    this.applyResponsiveLayout();
    // 页面进入淡入（一次性，无循环）
    this.pageOpacity = 1;
  }

  /**
   * 响应式布局：根据屏幕可用高度（屏高 - 底部导航88）分三档缩放
   *   - 大屏 (≥840vp)：默认值，立绘 320×300，标题 32vp
   *   - 中屏 (760~840vp)：立绘 300×280，标题 30vp，间距略减
   *   - 小屏 (<760vp)：立绘 280×260，标题 28vp，间距最小化
   * 不加 Scroll，靠缩放保证 360×780 / 390×844 内容完整显示。
   */
  private applyResponsiveLayout(): void {
    let availableHeightVp: number = 840; // 默认按大屏
    try {
      const displayInfo: display.Display = display.getDefaultDisplaySync();
      const screenHeightVp: number = px2vp(displayInfo.height);
      availableHeightVp = screenHeightVp - BOTTOM_NAV_RESERVE_VP;
    } catch (_err) {
      // 降级：使用大屏默认值
      return;
    }

    if (availableHeightVp >= MEDIUM_SCREEN_THRESHOLD_VP) {
      // 大屏：保持默认 const 值
      this.figureWidth = FIGURE_WIDTH_VP;
      this.figureHeight = FIGURE_HEIGHT_VP;
      this.titleFontSize = TITLE_FONT_SIZE_VP;
      this.titleLineHeight = TITLE_LINE_HEIGHT_VP;
      this.figureTopMargin = 10;
      this.figureBottomMargin = 12;
      this.subtitleBottomMargin = 44;
      this.disclaimerTopMargin = 16;
    } else if (availableHeightVp >= SMALL_SCREEN_THRESHOLD_VP) {
      // 中屏（390×844 等）：立绘略缩，标题略缩
      this.figureWidth = 300;
      this.figureHeight = 280;
      this.titleFontSize = 30;
      this.titleLineHeight = 42;
      this.figureTopMargin = 8;
      this.figureBottomMargin = 10;
      this.subtitleBottomMargin = 36;
      this.disclaimerTopMargin = 14;
    } else {
      // 小屏（360×780 等）：立绘再缩，标题 28vp，间距最小化
      this.figureWidth = 280;
      this.figureHeight = 260;
      this.titleFontSize = 28;
      this.titleLineHeight = 40;
      this.figureTopMargin = 6;
      this.figureBottomMargin = 8;
      this.subtitleBottomMargin = 28;
      this.disclaimerTopMargin = 12;
    }
  }

  private async loadReducedMotion(): Promise<void> {
    try {
      const context: Context = getContext(this);
      this.reducedMotion = await PreferenceStore.getBoolean('reduced_motion_enabled', false, context);
    } catch (_err) {
      // 保持默认 false
    }
  }

  private async loadNicknameAndGreeting(): Promise<void> {
    try {
      const context: Context = getContext(this);
      const name: string = await UserProfileStore.getNickname(context);
      this.nickname = name;
      const greeting = await selectEntryGreeting(name, context);
      this.greetingTitle = greeting.title;
      this.greetingSubtitle = greeting.subtitle;
    } catch (_err) {
      // 降级：使用默认文案
    }
  }

  build() {
    Stack() {
      // ── Layer 1: B 方案月湖映心 — 最深湖底背景 ──
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2B_BG_BASE)

      // ── Layer 2: 极弱月光氛围层（无圆盘、无边框）──
      MoonlightLayer({ strong: false, reducedMotion: this.reducedMotion })

      // ── Layer 3: 静态星点（少量，不闪烁）──
      this.buildStaticStars()

      // ── Layer 4: 主内容（固定布局，不可滚动）──
      Column() {
          // 顶部留白（兼容独立页返回按钮 / Tab 状态栏）
          Column()
            .width('100%')
            .height(TOP_RESERVE_VP)

          // ══ 星澜立绘区域（图片放大裁边 + 四向加厚遮罩 + 独立月牙）══
          Stack() {
            // 立绘本体：放大 1.15×，Cover 填充更大区域，Stack clip 裁掉原图硬边
            Image($r('app.media.xinglan_home_main'))
              .width(this.figureWidth * 1.15)
              .height(this.figureHeight * 1.15)
              .objectFit(ImageFit.Cover)
              .opacity(0.94)

            // 顶部渐隐（80vp，#060B1A → 透明）
            Column()
              .width(this.figureWidth)
              .height(FIGURE_FADE_TOP_VP)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [
                  ['rgba(6, 11, 26, 1)', 0.0],
                  ['rgba(6, 11, 26, 0.55)', 0.55],
                  ['rgba(6, 11, 26, 0)', 1.0]
                ]
              })
              .position({ x: 0, y: 0 })
              .hitTestBehavior(HitTestMode.None)

            // 底部渐隐（200vp，加厚加强，消除底部横线）
            Column()
              .width(this.figureWidth)
              .height(FIGURE_FADE_BOTTOM_VP)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [
                  ['rgba(6, 11, 26, 0)', 0.0],
                  ['rgba(6, 11, 26, 0.35)', 0.30],
                  ['rgba(6, 11, 26, 0.78)', 0.65],
                  ['rgba(6, 11, 26, 1)', 1.0]
                ]
              })
              .position({ x: 0, y: this.figureHeight - FIGURE_FADE_BOTTOM_VP })
              .hitTestBehavior(HitTestMode.None)

            // 左侧渐隐（80vp）
            Column()
              .width(FIGURE_FADE_LEFT_VP)
              .height(this.figureHeight)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [
                  ['rgba(6, 11, 26, 1)', 0.0],
                  ['rgba(6, 11, 26, 0.5)', 0.55],
                  ['rgba(6, 11, 26, 0)', 1.0]
                ]
              })
              .position({ x: 0, y: 0 })
              .hitTestBehavior(HitTestMode.None)

            // 右侧渐隐（120vp，加宽加强，彻底盖住原图右边缘竖条）
            Column()
              .width(FIGURE_FADE_RIGHT_VP)
              .height(this.figureHeight)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [
                  ['rgba(6, 11, 26, 0)', 0.0],
                  ['rgba(6, 11, 26, 0.55)', 0.35],
                  ['rgba(6, 11, 26, 1)', 1.0]
                ]
              })
              .position({ x: this.figureWidth - FIGURE_FADE_RIGHT_VP, y: 0 })
              .hitTestBehavior(HitTestMode.None)

            // 月牙：独立元素，放在立绘中下部，远离底部硬边
            Text('🌙')
              .fontSize(36)
              .fontColor('#D4AC4D')
              .opacity(0.38)
              .position({ x: 18, y: this.figureHeight * 0.52 })
              .hitTestBehavior(HitTestMode.None)
          }
          .width(this.figureWidth)
          .height(this.figureHeight)
          .clip(true)
          .margin({ top: this.figureTopMargin, bottom: this.figureBottomMargin })

          // ══ 主文案 ══
          Text(this.greetingTitle)
            .fontSize(TITLE_FONT_SIZE_VP)
            .fontColor('#F2EDDD')
            .fontWeight(FontWeight.Lighter)
            .lineHeight(TITLE_LINE_HEIGHT_VP)
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .width(320)
            .margin({ bottom: 18 })

          // ══ 副文案 ══
          Text(this.greetingSubtitle)
            .fontSize(SUBTITLE_FONT_SIZE_VP)
            .fontColor('#A8A3B8')
            .fontWeight(FontWeight.Lighter)
            .lineHeight(SUBTITLE_LINE_HEIGHT_VP)
            .textAlign(TextAlign.Center)
            .width(320)
            .margin({ bottom: 44 })

          // ══ 进入按钮 ══
          Button('走进月光门廊')
            .type(ButtonType.Normal)
            .width(BUTTON_WIDTH_VP)
            .height(BUTTON_HEIGHT_VP)
            .fontSize(Theme.V2B_FONT_SUBTITLE)
            .fontColor('#E8D5A3')
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#0F1835')
            .border({ width: 1, color: 'rgba(212, 172, 77, 0.55)' })
            .borderRadius(BUTTON_RADIUS_VP)
            .shadow({ radius: 18, color: 'rgba(212, 172, 77, 0.12)', offsetX: 0, offsetY: 0 })
            .scale({
              x: this.btnPressed ? 0.98 : 1.0,
              y: this.btnPressed ? 0.98 : 1.0
            })
            .animation({
              duration: Theme.ANIM_PRESS_DURATION,
              curve: Curve.EaseOut
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.btnPressed = true;
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.btnPressed = false;
              }
            })
            .onClick(() => {
              this.navigateToChat();
            })

          // ══ 免责声明 ══
          Text('星澜是离线陪伴，不替代专业心理咨询。')
            .fontSize(Theme.V2B_FONT_DISCLAIMER)
            .fontColor('#9590A8')
            .textAlign(TextAlign.Center)
            .lineHeight(17)
            .width('80%')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({
          top: 0,
          bottom: BOTTOM_NAV_RESERVE_VP + Theme.SAFE_BOTTOM + BOTTOM_EXTRA_SPACE_VP
        })
        .opacity(this.pageOpacity)
        .animation({
          duration: 600,
          curve: Curve.EaseOut
        })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 跳转到星澜聊天页（params 变量 + RouterOptions + try/catch）
   */
  private navigateToChat(): void {
    try {
      const options: router.RouterOptions = {
        url: Routes.XINGLAN_CHAT
      };
      router.pushUrl(options);
    } catch (_err) {
      // 跳转失败静默
    }
  }

  /**
   * 构建少量静态星点（深夜友好，不闪烁）
   */
  @Builder
  private buildStaticStars(): void {
    ForEach(XinglanChatEntranceContent.STATIC_STARS, (star: StaticStarItem) => {
      Column()
        .width(star.s)
        .height(star.s)
        .borderRadius(star.s / 2)
        .backgroundColor('#E8D5A3')
        .opacity(star.o)
        .position({ x: star.x, y: star.y })
    }, (star: StaticStarItem, idx: number) => 'star_' + idx + '_' + star.x + '_' + star.y)
  }
}

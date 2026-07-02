import { router } from '@kit.ArkUI';
import { Theme } from '../../common/Theme';
import { Routes } from '../../common/Routes';
import { AppBackButton } from '../../components/AppBackButton';
import { ComplianceFooter } from '../../components/ComplianceFooter';
import { DailyDirection } from '../model/DailyDirection';
import { DailyLightContent } from '../model/DailyLightContent';
import { DailyRitualState } from '../model/DailyRitualState';
import { DailyRitualStore } from '../service/DailyRitualStore';
import { DailyLightProvider } from '../service/DailyLightProvider';
import { EmotionStarDailyAdapter, DailyLightResult } from '../service/EmotionStarDailyAdapter';
import { findContentById } from '../data/DailyLightCopyLibrary';
import { RandomUtil } from '../../utils/RandomUtil';
import { DailyDirectionChip } from '../components/DailyDirectionChip';
import { StarKeyReveal } from '../components/StarKeyReveal';
import { DailyLightCard } from '../components/DailyLightCard';
import { PocketLightCard } from '../components/PocketLightCard';
import { SafeUiActions } from '../../common/SafeUiActions';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'DailyLightPage';

/** 八个方向的固定顺序，用于按日期种子稳定选四 */
const ALL_DIRECTIONS: DailyDirection[] = [
  DailyDirection.GENTLE,
  DailyDirection.ATTENTION,
  DailyDirection.LESS_RESULT,
  DailyDirection.BLANK,
  DailyDirection.SLOW,
  DailyDirection.HEAR_SELF,
  DailyDirection.BOUNDARY,
  DailyDirection.ALLOW_IMPERFECT
];

/**
 * 方向枚举 → 中文文案
 * 文案来自 V2 详细开发计划，不预测未来、不承诺复合、不替用户决定。
 */
function directionLabel(d: DailyDirection): string {
  switch (d) {
    case DailyDirection.GENTLE:
      return '今天想对自己温柔一点';
    case DailyDirection.ATTENTION:
      return '今天想把注意力收回来';
    case DailyDirection.LESS_RESULT:
      return '今天想少追问一点结果';
    case DailyDirection.BLANK:
      return '今天想给自己留一点空白';
    case DailyDirection.SLOW:
      return '今天想把一件事慢慢做好';
    case DailyDirection.HEAR_SELF:
      return '今天想更认真地听见自己';
    case DailyDirection.BOUNDARY:
      return '今天想保护好自己的边界';
    case DailyDirection.ALLOW_IMPERFECT:
      return '今天想允许自己不那么完美';
    default:
      return '';
  }
}

/**
 * 今日星页完整页面（DAILY-4 / DAILY-5）
 *
 * 主流程：选择方向 → 星钥开页 → 三层内容 → 换一次 → 确认完成
 * 回看模式：已完成态进入时直接展示三层内容 + 完成文案，无操作按钮。
 *
 * DAILY-5：确认完成时通过 EmotionStarDailyAdapter 接入情绪星点亮。
 *   - 已点亮 → 只完成星页，不重复累计；
 *   - 未点亮 → 复用 EmotionStarStorage.lightToday 完成一次点亮；
 *   - 成功点亮 → 播放轻量星光归档动画（小星沿弧形星轨落入星历入口）；
 *   - 失败 → 保留星页内容，展示可重试文案。
 *   严格保持现有星历规则：每天一次 / 未来不可点亮 / 重复不累计 / 等级阈值不变。
 *
 * 视觉：C「星钥之书」为主，顶部融入 B「月湖映心」极淡月光。
 *
 * 不修改：抽牌算法、卡牌数据、BGM、星历规则、等级阈值、EmotionStarStorage。
 */
@Entry
@Component
struct DailyLightPage {
  /** select=选方向 / reveal=星钥开页 / content=三层内容（含完成态） */
  @State private phase: string = 'select';
  @State private loading: boolean = true;
  @State private reduceMotion: boolean = false;
  @State private state: DailyRitualState | null = null;
  @State private todayDirections: DailyDirection[] = [];
  @State private selectedDirection: DailyDirection | null = null;
  @State private currentContent: DailyLightContent | null = null;
  @State private replaceButtonDisabled: boolean = false;
  @State private completed: boolean = false;
  @State private reviewMode: boolean = false;

  /** 跳过按钮按压态 */
  @State private skipPressed: boolean = false;
  /** 展开主按钮按压态 */
  @State private expandPressed: boolean = false;

  // ── DAILY-5：情绪星点亮 + 星光归档动画 ──
  /** 本次确认后的点亮结果（默认 ALREADY_LIT：回看模式不播动画） */
  @State private lightResult: DailyLightResult = DailyLightResult.ALREADY_LIT;
  /** 点亮失败时展示可重试入口（completed 仍为 true，但不展示完成文案） */
  @State private lightFailed: boolean = false;
  /** 是否正在播放星光归档动画 */
  @State private archiveAnimPlaying: boolean = false;
  /** 小星当前 translate X（vp，相对内容区中心向上偏移锚点） */
  @State private archiveStarX: number = 0;
  /** 小星当前 translate Y（vp） */
  @State private archiveStarY: number = 0;
  /** 小星当前 opacity */
  @State private archiveStarOpacity: number = 0;
  /** 星历入口标记是否提亮 */
  @State private entryGlow: boolean = false;
  /** 完成文案 opacity（动画结束后保持 1） */
  @State private completeTextOpacity: number = 0;
  /** 重试按钮按压态 */
  @State private retryPressed: boolean = false;

  // ── DAILY-6：口袋微光 ──
  /** 今日口袋微光是否已保存到星历（从 DailyRitualState.savedToCalendar 同步） */
  @State private pocketSaved: boolean = false;

  async aboutToAppear(): Promise<void> {
    // 读取减少动态效果设置（默认 false，后续可由系统适配层写入 AppStorage）
    const stored: boolean | undefined = AppStorage.get<boolean>('reduceMotion');
    this.reduceMotion = stored === true;

    try {
      const ctx: Context = getContext(this);
      const state: DailyRitualState = await DailyRitualStore.getTodayState(ctx);
      this.state = state;

      // 按日期种子稳定选四个方向
      const indexes: number[] = RandomUtil.drawUniqueIndexes(
        ALL_DIRECTIONS.length,
        4,
        `daily-directions-${state.dateKey}`
      );
      const dirs: DailyDirection[] = [];
      for (const idx of indexes) {
        dirs.push(ALL_DIRECTIONS[idx]);
      }
      this.todayDirections = dirs;

      // 决定初始阶段
      if (state.completed) {
        // 回看模式：已完成，直接展示内容 + 完成文案
        this.reviewMode = true;
        this.completed = true;
        this.pocketSaved = state.savedToCalendar;
        if (state.direction !== undefined) {
          this.selectedDirection = state.direction;
        }
        if (state.contentId !== undefined && state.contentId.length > 0) {
          const content: DailyLightContent | null = findContentById(state.contentId);
          if (content !== null) {
            this.currentContent = content;
          }
        }
        // DAILY-5：回看模式下查询情绪星是否已点亮。
        // 若今日星页已完成但情绪星未点亮（极端：上次确认时点亮失败），
        // 仍提供可重试入口；否则直接展示完成文案。
        const alreadyLit: boolean = await EmotionStarDailyAdapter.isTodayLit(ctx);
        if (alreadyLit) {
          this.lightResult = DailyLightResult.ALREADY_LIT;
          this.lightFailed = false;
          this.completeTextOpacity = 1.0;
        } else {
          this.lightFailed = true;
        }
        this.phase = 'content';
      } else if (
        state.direction !== undefined &&
        state.contentId !== undefined &&
        state.contentId.length > 0
      ) {
        // 恢复：已选方向且已有内容，直接进入内容阶段
        this.selectedDirection = state.direction;
        const content: DailyLightContent | null = findContentById(state.contentId);
        if (content !== null) {
          this.currentContent = content;
          this.replaceButtonDisabled = state.replacedOnce;
          this.phase = 'content';
        } else {
          this.phase = 'select';
        }
      } else {
        this.phase = 'select';
      }
    } catch (_err) {
      hilog.warn(0x0000, TAG, 'load today state failed, fallback to select');
      this.phase = 'select';
    }
    this.loading = false;
  }

  /**
   * 选择/跳过后展开：获取内容 → 保存 → 进入星钥开页阶段
   */
  private async handleExpand(): Promise<void> {
    if (this.state === null) {
      return;
    }
    let direction: DailyDirection | null = this.selectedDirection;
    if (direction === null) {
      // 跳过：取今日四方向之首作为隐式方向（稳定）
      if (this.todayDirections.length === 0) {
        return;
      }
      direction = this.todayDirections[0];
      this.selectedDirection = direction;
    }

    const ctx: Context = getContext(this);
    const content: DailyLightContent | null = DailyLightProvider.getContentForToday(this.state, direction);
    if (content === null) {
      hilog.warn(0x0000, TAG, 'no content for direction');
      return;
    }

    // 保存选中内容到当天状态
    const newState: DailyRitualState = await DailyRitualStore.saveSelectedContent(
      this.state,
      content,
      ctx
    );
    this.state = newState;
    this.currentContent = content;
    this.replaceButtonDisabled = newState.replacedOnce;
    this.phase = 'reveal';
  }

  /**
   * 星钥展开回调：进入三层内容阶段
   */
  private handleRevealed(): void {
    this.phase = 'content';
  }

  /**
   * 换一次：每天最多一次
   */
  private async handleReplace(): Promise<void> {
    if (this.state === null || this.selectedDirection === null) {
      return;
    }
    if (this.replaceButtonDisabled) {
      return;
    }
    const ctx: Context = getContext(this);
    const newState: DailyRitualState = await DailyLightProvider.replaceContent(
      this.state,
      this.selectedDirection,
      ctx
    );
    this.state = newState;
    if (newState.contentId !== undefined) {
      const content: DailyLightContent | null = findContentById(newState.contentId);
      if (content !== null) {
        this.currentContent = content;
      }
    }
    this.replaceButtonDisabled = true;
  }

  /**
   * 确认完成：写 DailyRitualStore.completed=true，并通过适配层点亮情绪星。
   *
   * 规则保护：
   *  - 已点亮 → 只完成星页，不重复累计（适配层返回 ALREADY_LIT）；
   *  - 未点亮 → 复用 EmotionStarStorage.lightToday 写入一次；
   *  - 成功点亮 → 播放轻量星光归档动画；
   *  - 失败 → 保留星页内容，展示可重试文案。
   */
  private async handleConfirm(): Promise<void> {
    if (this.state === null) {
      return;
    }
    const ctx: Context = getContext(this);
    // 1. 本地写入今日完成状态
    const newState: DailyRitualState = await DailyRitualStore.markCompleted(this.state, ctx);
    this.state = newState;
    this.completed = true;
    this.reviewMode = true;
    // DAILY-6：同步口袋微光保存状态（markCompleted 不改 savedToCalendar，但同步一次更稳妥）
    this.pocketSaved = newState.savedToCalendar;

    // 2-4. 通过适配层检查并点亮情绪星
    if (this.selectedDirection !== null && this.currentContent !== null) {
      const result: DailyLightResult = await EmotionStarDailyAdapter.lightTodayFromDaily(
        ctx,
        this.selectedDirection,
        this.currentContent
      );
      this.lightResult = result;
      if (result === DailyLightResult.LIT) {
        // 本次成功点亮 → 播放星光归档动画（动画末尾淡入完成文案）
        this.lightFailed = false;
        this.playArchiveAnimation();
      } else if (result === DailyLightResult.ALREADY_LIT) {
        // 今天已点亮过，不重复累计，不播放归档动画（避免暗示再次获得）
        this.lightFailed = false;
        this.completeTextOpacity = 1.0;
      } else {
        // FAILED：保留星页内容，展示可重试文案
        this.lightFailed = true;
      }
    } else {
      // 无方向或无内容（理论上不会到这里）：仅展示完成文案
      this.completeTextOpacity = 1.0;
    }
  }

  /**
   * 失败重试：只重试点亮，不重复 markCompleted。
   * 成功后播放归档动画；仍失败则保持可重试入口。
   */
  private async handleRetryLight(): Promise<void> {
    if (this.selectedDirection === null || this.currentContent === null) {
      return;
    }
    const ctx: Context = getContext(this);
    const result: DailyLightResult = await EmotionStarDailyAdapter.lightTodayFromDaily(
      ctx,
      this.selectedDirection,
      this.currentContent
    );
    this.lightResult = result;
    if (result === DailyLightResult.LIT) {
      this.lightFailed = false;
      this.playArchiveAnimation();
    } else if (result === DailyLightResult.ALREADY_LIT) {
      this.lightFailed = false;
      this.completeTextOpacity = 1.0;
    } else {
      // 仍失败，保持可重试入口
      this.lightFailed = true;
    }
  }

  /**
   * DAILY-6：保存口袋微光到星历。
   *
   * 仅调用 DailyRitualStore.markSavedToCalendar 标记今日 savedToCalendar=true。
   * 不新增字段、不修改 DailyRitualState 数据结构、不修改 EmotionStarStorage 规则。
   *
   * 「保存到星历」对应的可恢复数据（V2 计划 5.1 隐私要求）：
   *   - 日期：state.dateKey
   *   - 内容 ID：state.contentId（通过 findContentById 可反查 pocketLight）
   *   - 用户选择方向：state.direction
   *   - 微光文案：findContentById(state.contentId).pocketLight（不冗余存储）
   * 不保存完整聊天、不做心理推断、不写情绪星记录。
   */
  private async handlePocketSave(): Promise<void> {
    if (this.state === null) {
      return;
    }
    if (this.pocketSaved) {
      return;
    }
    const ctx: Context = getContext(this);
    const newState: DailyRitualState = await DailyRitualStore.markSavedToCalendar(this.state, ctx);
    this.state = newState;
    this.pocketSaved = newState.savedToCalendar;
    if (newState.savedToCalendar) {
      SafeUiActions.safeToast('已保存到今日星历');
    } else {
      // 极端情况：写入失败，保留可重试入口
      SafeUiActions.safeToast('暂时没能保存，可以稍后再试');
    }
  }

  /**
   * DAILY-6：和星澜聊聊，跳转星澜聊天页。
   *
   * 不强制携带微光上下文（XinglanChatPage 当前不接收 router 参数，
   * 任务说「可携带微光作为轻上下文（不强制）」，本轮不修改聊天页）。
   * 路由跳转遵循 ArkTS 规则：先声明 RouterOptions，try/catch 包裹。
   */
  private handleChatWithXinglan(): void {
    try {
      const options: router.RouterOptions = {
        url: Routes.XINGLAN_CHAT
      };
      router.pushUrl(options);
    } catch (_err) {
      hilog.warn(0x0000, TAG, 'navigate to xinglan chat failed');
      SafeUiActions.safeToast('暂时没能打开星澜聊天，请稍后再试');
    }
  }

  /**
   * 播放星光归档动画（V2 计划 6.3）。
   *
   * 视觉：一颗小星从星页上浮起 → 沿弧形星轨移动 → 落入星历入口 → 入口短暂提亮。
   * 不出现金币、礼物盒、奖励到账。最大同时动画元素 3 个（小星 / 入口 / 完成文案）。
   * reduceMotion=true 时跳过星轨，只做完成文案淡入。
   * 动画结束后释放状态（archiveAnimPlaying=false）。
   */
  private playArchiveAnimation(): void {
    if (this.reduceMotion) {
      // 减少动态效果：只做完成文案淡入
      this.archiveAnimPlaying = false;
      this.completeTextOpacity = 0.0;
      setTimeout(() => {
        this.completeTextOpacity = 1.0;
      }, 40);
      return;
    }

    // 初始：小星在内容区中心偏上锚点，不可见
    this.archiveAnimPlaying = true;
    this.entryGlow = false;
    this.archiveStarX = 0;
    this.archiveStarY = 0;
    this.archiveStarOpacity = 0;
    this.completeTextOpacity = 0;

    // 阶段 1（0→300ms）：小星淡入并轻微上浮
    setTimeout(() => {
      this.archiveStarOpacity = 1.0;
      this.archiveStarY = -10;
    }, 60);

    // 阶段 2（300→900ms）：沿弧形星轨向星历入口移动（先左上再右上，近似弧线）
    setTimeout(() => {
      this.archiveStarX = -24;
      this.archiveStarY = -70;
    }, 360);
    setTimeout(() => {
      this.archiveStarX = 70;
      this.archiveStarY = -150;
    }, 760);

    // 阶段 3（1000ms）：星历入口提亮
    setTimeout(() => {
      this.entryGlow = true;
    }, 1000);

    // 阶段 4（1100ms）：小星淡出
    setTimeout(() => {
      this.archiveStarOpacity = 0;
    }, 1100);

    // 阶段 5（1250ms）：完成文案淡入
    setTimeout(() => {
      this.completeTextOpacity = 1.0;
    }, 1250);

    // 阶段 6（1600ms）：释放动画状态
    setTimeout(() => {
      this.archiveAnimPlaying = false;
      this.entryGlow = false;
    }, 1600);
  }

  build() {
    Stack() {
      // 底色
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2C_BG_BASE)

      // 顶部极淡月光渐变（B 融入）
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

      // 内容滚动区
      Scroll() {
        Column({ space: Theme.V2_SPACE_LG }) {
          // 顶部安全区 + 返回按钮
          Row() {
            AppBackButton({ fallbackUrl: Routes.HOME })
          }
          .width('100%')
          .padding({ top: Theme.SAFE_TOP })

          if (this.loading) {
            this.BuildLoading()
          } else if (this.phase === 'select') {
            this.BuildSelectPhase()
          } else if (this.phase === 'reveal') {
            this.BuildRevealPhase()
          } else {
            this.BuildContentPhase()
          }

          ComplianceFooter({
            fontSize: Theme.V2C_FONT_CAPTION,
            textColor: Theme.V2C_TEXT_SECONDARY,
            showDivider: true
          })
        }
        .width('100%')
        .padding({
          left: Theme.SPACE_SCREEN_PAD,
          right: Theme.SPACE_SCREEN_PAD,
          bottom: Theme.SAFE_BOTTOM + 40
        })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      // DAILY-5：星光归档动画覆盖层（固定图层 + 透明度动画，不持续运行）
      if (this.archiveAnimPlaying) {
        this.BuildArchiveOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 星光归档覆盖层（V2 计划 6.3 / 6.4 性能降级）。
   *
   * - 一颗小星从内容区上方浮起，沿弧形星轨落入右上角星历入口；
   * - 星历入口短暂提亮；
   * - 不出现金币 / 礼物盒 / 奖励到账文字；
   * - 全部用固定图层 + 透明度 / 位移动画实现，无实时粒子；
   * - reduceMotion=true 时本覆盖层不渲染（playArchiveAnimation 已直接走淡入分支）。
   */
  @Builder
  BuildArchiveOverlay(): void {
    Stack() {
      // 星历入口标记（右上角，落点）
      Row() {
        Text('★')
          .fontSize(this.entryGlow ? 18 : 14)
          .fontColor(this.entryGlow ? Theme.V2C_GOLD_GILT_SOFT : 'rgba(197,160,80,0.38)')
          .animation({ duration: 300, curve: Theme.V2_EASE_OUT })

        Text('星历')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(this.entryGlow ? Theme.V2C_GOLD_GILT_SOFT : 'rgba(197,160,80,0.38)')
          .letterSpacing(1)
          .margin({ left: 4 })
          .animation({ duration: 300, curve: Theme.V2_EASE_OUT })
      }
      .alignItems(VerticalAlign.Center)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .borderRadius(Theme.V2C_RADIUS_BTN)
      .border({
        width: 1,
        color: this.entryGlow ? 'rgba(197,160,80,0.50)' : 'rgba(197,160,80,0.18)'
      })
      .backgroundColor(this.entryGlow ? 'rgba(197,160,80,0.10)' : 'rgba(10,13,26,0.0)')
      .animation({ duration: 300, curve: Theme.V2_EASE_OUT })
      .position({ x: '82%', y: 90 })
      .translate({ x: -28 }) // 视觉居中于右上角

      // 小星（从内容区上方弧形落入星历入口）
      Text('✦')
        .fontSize(22)
        .fontColor(Theme.V2C_GOLD_GILT_SOFT)
        .opacity(this.archiveStarOpacity)
        .translate({ x: this.archiveStarX, y: this.archiveStarY })
        .animation({ duration: 300, curve: Theme.V2_EASE_OUT })
        .position({ x: '50%', y: '42%' })
        .textShadow({
          radius: 8,
          color: 'rgba(197,160,80,0.32)',
          offsetX: 0,
          offsetY: 0
        })
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.None)
  }

  @Builder
  BuildLoading(): void {
    Column() {
      Text('正在准备今日星页…')
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(Theme.V2C_TEXT_SECONDARY)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: Theme.V2_SPACE_2XL, bottom: Theme.V2_SPACE_2XL })
  }

  @Builder
  BuildSelectPhase(): void {
    Column({ space: Theme.V2_SPACE_LG }) {
      // 标题
      Column() {
        Text('今日星页')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_GOLD_GILT)
          .letterSpacing(2)

        Row()
          .width(44)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.32)
          .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_MD })

        Text('今天，想怎样站在自己这一边？')
          .fontSize(Theme.V2C_FONT_TITLE)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)

        Text('选一个方向，或直接展开。')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ top: Theme.V2_SPACE_XS })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 四方向 Chip（2x2，按日期种子稳定选四）
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.todayDirections, (dir: DailyDirection) => {
          DailyDirectionChip({
            label: directionLabel(dir),
            selected: this.selectedDirection === dir,
            onSelect: () => {
              this.selectedDirection = dir;
            }
          })
        }, (dir: DailyDirection) => dir)
      }
      .width('100%')
      .margin({ top: Theme.V2_SPACE_MD })

      // 主按钮：展开今日星页（选中方向后启用）
      Text('展开今日星页')
        .fontSize(Theme.V2C_FONT_BODY)
        .fontColor(
          this.selectedDirection !== null
            ? Theme.V2C_GOLD_GILT_SOFT
            : Theme.V2_STATE_DISABLED_TEXT
        )
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(48)
        .borderRadius(Theme.V2C_RADIUS_BTN)
        .backgroundColor(
          this.selectedDirection !== null
            ? 'rgba(197,160,80,0.10)'
            : 'rgba(18,24,54,0.40)'
        )
        .border({
          width: 1,
          color:
            this.selectedDirection !== null
              ? 'rgba(197,160,80,0.34)'
              : 'rgba(138,132,152,0.20)'
        })
        .scale({
          x: this.expandPressed && this.selectedDirection !== null ? Theme.PRESS_SCALE : 1.0,
          y: this.expandPressed && this.selectedDirection !== null ? Theme.PRESS_SCALE : 1.0
        })
        .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
        .margin({ top: Theme.V2_SPACE_LG })
        .accessibilityGroup(true)
        .accessibilityText(
          this.selectedDirection !== null
            ? `展开今日星页，已选${directionLabel(this.selectedDirection)}`
            : '展开今日星页，请先选择一个方向'
        )
        .accessibilityLevel(this.selectedDirection !== null ? 'yes' : 'no')
        .onTouch((event: TouchEvent) => {
          if (this.selectedDirection === null) {
            return;
          }
          if (event.type === TouchType.Down) {
            this.expandPressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.expandPressed = false;
          }
        })
        .onClick(() => {
          if (this.selectedDirection === null) {
            return;
          }
          this.handleExpand();
        })

      // 次按钮：今天不想选择，直接展开
      Text('今天不想选择，直接展开')
        .fontSize(Theme.V2C_FONT_CAPTION)
        .fontColor(Theme.V2C_TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(42)
        .borderRadius(Theme.V2C_RADIUS_BTN)
        .backgroundColor('rgba(10,13,26,0.0)')
        .border({ width: 1, color: 'rgba(224,205,149,0.18)' })
        .scale({
          x: this.skipPressed ? Theme.PRESS_SCALE : 1.0,
          y: this.skipPressed ? Theme.PRESS_SCALE : 1.0
        })
        .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
        .margin({ top: Theme.V2_SPACE_SM })
        .accessibilityGroup(true)
        .accessibilityText('今天不想选择，直接展开今日星页')
        .accessibilityLevel('yes')
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.skipPressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.skipPressed = false;
          }
        })
        .onClick(() => {
          this.selectedDirection = null;
          this.handleExpand();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  BuildRevealPhase(): void {
    Column({ space: Theme.V2_SPACE_LG }) {
      // 标题
      Column() {
        Text('今日星页')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_GOLD_GILT)
          .letterSpacing(2)

        Row()
          .width(44)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.32)
          .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_MD })

        Text('不问今天会发生什么。')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .textAlign(TextAlign.Center)

        Text('只看看，你想怎样度过它。')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .margin({ top: Theme.V2_SPACE_XS })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 星钥开页
      StarKeyReveal({
        revealed: false,
        reduceMotion: this.reduceMotion,
        onRevealed: () => {
          this.handleRevealed();
        }
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  BuildContentPhase(): void {
    Column({ space: Theme.V2_SPACE_LG }) {
      // 标题
      Column() {
        Text(this.completed ? '今天已经点亮' : '今日星页')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_GOLD_GILT)
          .letterSpacing(2)

        Row()
          .width(44)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.32)
          .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_MD })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 三层内容卡
      if (this.currentContent !== null) {
        DailyLightCard({
          mainLine: this.currentContent.mainLine,
          observation: this.currentContent.observation,
          microAction: this.currentContent.microAction,
          reduceMotion: this.reduceMotion,
          replaceButtonDisabled: this.replaceButtonDisabled,
          reviewMode: this.reviewMode,
          onReplace: () => {
            this.handleReplace();
          },
          onConfirm: () => {
            this.handleConfirm();
          }
        })
      } else {
        Text('今日内容暂时没有准备好。')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .padding({ top: Theme.V2_SPACE_XL, bottom: Theme.V2_SPACE_XL })
      }

      // 完成文案 / 失败重试（确认后展示）
      if (this.completed) {
        if (this.lightFailed) {
          // DAILY-5：点亮失败，保留星页内容，提供可重试文案
          Column({ space: Theme.V2_SPACE_XS }) {
            Text('暂时没能点亮今天的星。')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)

            Text('可以稍后再试一次。')
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .lineHeight(22)

            // 重试按钮（不重复 markCompleted，只重试点亮）
            Text('再试一次')
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_GOLD_GILT_SOFT)
              .textAlign(TextAlign.Center)
              .width('62%')
              .height(42)
              .borderRadius(Theme.V2C_RADIUS_BTN)
              .backgroundColor('rgba(197,160,80,0.10)')
              .border({ width: 1, color: 'rgba(197,160,80,0.32)' })
              .scale({
                x: this.retryPressed ? Theme.PRESS_SCALE : 1.0,
                y: this.retryPressed ? Theme.PRESS_SCALE : 1.0
              })
              .animation({ duration: Theme.ANIM_PRESS_DURATION, curve: Theme.V2_EASE_OUT })
              .margin({ top: Theme.V2_SPACE_SM })
              .accessibilityGroup(true)
              .accessibilityText('再试一次，重新点亮今天的情绪星')
              .accessibilityLevel('yes')
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.retryPressed = true;
                } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                  this.retryPressed = false;
                }
              })
              .onClick(() => {
                this.handleRetryLight();
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: Theme.V2_SPACE_MD })
        } else {
          // 点亮成功 / 已点亮：展示完成文案（带淡入）+ DAILY-6 口袋微光（跟随淡入）
          Column({ space: Theme.V2_SPACE_LG }) {
            // 完成文案（V2 计划 4.5）
            Column() {
              Text('今天的星已经点亮。')
                .fontSize(Theme.V2C_FONT_SUBTITLE)
                .fontColor(Theme.V2C_GOLD_GILT_SOFT)
                .textAlign(TextAlign.Center)

              Text('它不记录完美，只记录你认真看见过自己。')
                .fontSize(Theme.V2C_FONT_BODY)
                .fontColor(Theme.V2C_TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .lineHeight(24)
                .margin({ top: Theme.V2_SPACE_XS })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .padding({ top: Theme.V2_SPACE_MD })

            // DAILY-6：口袋微光卡（B 月湖映心，仅在有内容时展示）
            // 隐私：只展示 pocketLight 通用文案，不显示方向/mainLine/observation/microAction
            if (this.currentContent !== null) {
              PocketLightCard({
                pocketLight: this.currentContent.pocketLight,
                dateKey: this.state !== null ? this.state.dateKey : '',
                savedToCalendar: this.pocketSaved,
                reduceMotion: this.reduceMotion,
                onPocketSave: () => {
                  this.handlePocketSave();
                },
                onChatWithXinglan: () => {
                  this.handleChatWithXinglan();
                }
              })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .opacity(this.completeTextOpacity)
          .animation({ duration: 300, curve: Theme.V2_EASE_OUT })
          .accessibilityGroup(true)
          .accessibilityText('今天的星已经点亮。它不记录完美，只记录你认真看见过自己。口袋微光已展示。')
          .accessibilityLevel('yes')
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}

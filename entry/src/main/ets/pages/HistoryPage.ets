import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { HistoryStore } from '../common/HistoryStore';
import { DivinationHistoryRecord, SpreadType } from '../model/DivinationHistoryRecord';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PreferenceStore } from '../data/PreferenceStore';

/**
 * 历史详情路由参数
 */
interface HistoryDetailRouteParams {
  recordId: string;
}

/**
 * 阶段5：记录页首次引导文案
 */
const HISTORY_FIRST_GUIDE: string = '这里留着之前的自己。想看就看，不想看也没关系。';

/**
 * 历史查询页面（P0.3 整改：单条删除 + 全部清除 + 空状态优化）
 */
@Entry
@Component
struct HistoryPage {
  @State records: DivinationHistoryRecord[] = [];
  @State filterType: string = '全部';
  @State isLoading: boolean = true;
  @State filterOptions: string[] = ['全部', '单牌', '圣三角', '关系', '牌轮'];
  @State showFirstGuide: boolean = false;

  aboutToAppear(): void {
    this.prepareFirstGuide();
  }

  /**
   * 阶段5：首次进入记录页引导
   * - 先加载记录（保留原逻辑）
   * - 读 hasSeenRecordGuide，若 false 则显示引导并标记 true
   */
  private async prepareFirstGuide(): Promise<void> {
    await this.loadRecords();
    try {
      const hasSeen: boolean = await PreferenceStore.getBoolean('hasSeenRecordGuide', false, getContext(this));
      this.showFirstGuide = !hasSeen;
      if (!hasSeen) {
        await PreferenceStore.putBoolean('hasSeenRecordGuide', true, getContext(this));
      }
    } catch (err) {
      hilog.error(0x0000, 'HistoryPage', 'prepareFirstGuide error: %{public}s', JSON.stringify(err));
    }
  }

  private async loadRecords(): Promise<void> {
    this.isLoading = true;
    try {
      const all: DivinationHistoryRecord[] = await HistoryStore.getRecords(getContext(this));
      this.records = all;
    } catch (_err) {
      this.records = [];
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 根据筛选类型过滤记录
   */
  private getFilteredRecords(): DivinationHistoryRecord[] {
    if (this.filterType === '全部') {
      return this.records;
    }
    const matchType: SpreadType | undefined = this.filterToSpreadType();
    if (!matchType) {
      return this.records;
    }
    return this.records.filter((r: DivinationHistoryRecord) => r.spreadType === matchType);
  }

  private filterToSpreadType(): SpreadType | undefined {
    if (this.filterType === '单牌') {
      return SpreadType.SINGLE;
    }
    if (this.filterType === '圣三角') {
      return SpreadType.TRIANGLE;
    }
    if (this.filterType === '关系') {
      return SpreadType.RELATION;
    }
    if (this.filterType === '牌轮') {
      return SpreadType.CARD_WHEEL;
    }
    return undefined;
  }

  /**
   * 格式化日期
   */
  private formatDate(ts: number): string {
    const d: Date = new Date(ts);
    const y: string = String(d.getFullYear());
    const m: string = String(d.getMonth() + 1).padStart(2, '0');
    const day: string = String(d.getDate()).padStart(2, '0');
    const h: string = String(d.getHours()).padStart(2, '0');
    const min: string = String(d.getMinutes()).padStart(2, '0');
    return y + '-' + m + '-' + day + ' ' + h + ':' + min;
  }

  /**
   * 获取卡牌摘要
   */
  private getCardSummary(record: DivinationHistoryRecord): string {
    if (!record.cards || record.cards.length === 0) {
      return '';
    }
    return record.cards.map((c) => c.cardName).join(' · ');
  }

  /**
   * 单条删除确认弹窗（P0.3 整改）
   */
  private confirmDeleteRecord(record: DivinationHistoryRecord): void {
    AlertDialog.show({
      title: '删除这条记录？',
      message: '删除后这条星钥记录将无法恢复。',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#EF4444',
        action: (): void => {
          this.deleteRecord(record);
        }
      }
    });
  }

  /**
   * 全部清空确认弹窗（P0.3 整改）
   */
  private confirmClearAll(): void {
    AlertDialog.show({
      title: '清空历史记录？',
      message: '清空后最近50条星钥记录将从本设备删除，无法恢复。',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确认清空',
        fontColor: '#EF4444',
        action: (): void => {
          this.clearAll();
        }
      }
    });
  }

  /**
   * 执行单条删除
   */
  private async deleteRecord(record: DivinationHistoryRecord): Promise<void> {
    try {
      const ok: boolean = await HistoryStore.deleteRecordById(getContext(this), record.id);
      if (ok) {
        await this.loadRecords();
      }
    } catch (_err) {
      // ignore
    }
  }

  /**
   * 执行全部清空
   */
  private async clearAll(): Promise<void> {
    try {
      const ok: boolean = await HistoryStore.clearAllRecords(getContext(this));
      if (ok) {
        await this.loadRecords();
      }
    } catch (_err) {
      // ignore
    }
  }

  /**
   * 空状态按钮文案：按当前筛选类型切换
   */
  private getEmptyActionText(): string {
    if (this.filterType === '圣三角') {
      return '去圣三角';
    }
    if (this.filterType === '关系') {
      return '去关系探索';
    }
    if (this.filterType === '牌轮') {
      return '去旋转牌轮';
    }
    return '去每日一占';
  }

  /**
   * 空状态按钮跳转：按当前筛选类型跳转对应入口页
   */
  private goEmptyAction(): void {
    let targetUrl: string = Routes.ASK_HEART;
    if (this.filterType === '圣三角') {
      targetUrl = Routes.TRIANGLE_INTRO;
    } else if (this.filterType === '关系') {
      targetUrl = Routes.RELATION_INTRO;
    } else if (this.filterType === '牌轮') {
      targetUrl = Routes.CARD_WHEEL_MODE;
    } else {
      targetUrl = Routes.ASK_HEART;
    }
    try {
      const routeOptions: router.RouterOptions = { url: targetUrl };
      router.replaceUrl(routeOptions).catch((_err: Error) => {
        // ignore
      });
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Stack() {
      Column() {
      // ── 标题行：返回 + 标题 + 清空 ──
      Row() {
        AppBackButton({ fallbackUrl: Routes.HOME })

        Blank()

        Text('历史查询')
          .fontSize(Theme.V2A_FONT_TITLE)
          .fontColor(Theme.V2A_TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('清空')
          .fontSize(Theme.V2A_FONT_CAPTION)
          .fontColor(Theme.V2A_CRISIS)
          .letterSpacing(0.5)
          .opacity(this.records.length > 0 ? 0.85 : 0.3)
          .onClick(() => {
            if (this.records.length > 0) {
              this.confirmClearAll();
            }
          })
      }
      .width('100%')
      .padding({ left: 14, right: Theme.SPACE_MD, top: Theme.SAFE_TOP, bottom: Theme.SPACE_SM })

      Text('回看最近的星钥记录，看看那些反复出现的心事。')
        .fontSize(Theme.V2A_FONT_CAPTION)
        .fontColor(Theme.V2_TEXT_TERTIARY)
        .letterSpacing(0.5)
        .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG, bottom: Theme.V2_SPACE_MD })
        .width('100%')

      // ── 阶段5：首次进入记录页引导（仅首次显示）──
      if (this.showFirstGuide) {
        Text(HISTORY_FIRST_GUIDE)
          .fontSize(Theme.V2A_FONT_CAPTION)
          .fontColor(Theme.V2A_TEXT_SECONDARY)
          .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG, bottom: Theme.V2_SPACE_SM })
          .width('100%')
      }

      Divider().strokeWidth(0.3).color('rgba(255,255,255,0.06)')

      // ── 筛选 Tab（横向滑动 chips · A 档案标签）──
      Scroll() {
        Row({ space: Theme.V2_SPACE_XS }) {
          ForEach(this.filterOptions, (opt: string) => {
            Text(opt)
              .fontSize(Theme.V2A_FONT_CAPTION)
              .fontColor(this.filterType === opt ? Theme.V2A_GOLD_ACCENT : Theme.V2A_TEXT_SECONDARY)
              .fontWeight(this.filterType === opt ? FontWeight.Medium : FontWeight.Normal)
              .height(34)
              .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD, top: 0, bottom: 0 })
              .textAlign(TextAlign.Center)
              .backgroundColor(this.filterType === opt ? 'rgba(201,164,75,0.10)' : 'rgba(16,20,42,0.5)')
              .borderRadius(Theme.V2A_RADIUS_CHIP)
              .border({ width: 1, color: this.filterType === opt ? 'rgba(201,164,75,0.45)' : Theme.V2A_ORBIT_LINE })
              .onClick(() => {
                this.filterType = opt;
              })
          }, (opt: string) => opt)
        }
        .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_SM })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Divider().strokeWidth(0.3).color('rgba(255,255,255,0.06)')

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color(Theme.V2A_GOLD_ACCENT)
            .margin({ top: 80 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        if (this.getFilteredRecords().length === 0) {
          this.buildEmptyState()
        } else {
          List({ space: Theme.SPACE_SM }) {
            ForEach(this.getFilteredRecords(), (record: DivinationHistoryRecord) => {
              ListItem() {
                this.buildHistoryItem(record)
              }
            }, (record: DivinationHistoryRecord) => record.id)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, top: Theme.SPACE_MD, bottom: 128 })
          .scrollBar(BarState.Off)
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 0, bottom: Theme.SAFE_BOTTOM })
    .background(Theme.V2A_BG_BASE)

      // 顶部渐变遮罩（消除状态栏硬边）
      Column()
        .width('100%')
        .height(Theme.SAFE_TOP + 64)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#080B18', 0], ['rgba(15,15,35,0)', 1]]
        })
        .hitTestBehavior(HitTestMode.Transparent)
        .position({ x: 0, y: 0 })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 空状态（P0.3 整改：更友好的文案）
   */
  @Builder
  buildEmptyState(): void {
    Column({ space: Theme.V2_SPACE_SM }) {
      // 月相符号（A 档案克制感）
      Text('☾')
        .fontSize(56)
        .fontColor(Theme.V2A_GOLD_GLOW)
        .opacity(0.28)
        .margin({ bottom: Theme.V2_SPACE_XS })

      Text('还没有占卜记录')
        .fontSize(Theme.V2A_FONT_BODY)
        .fontColor(Theme.V2A_TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .letterSpacing(0.5)

      Text('还没有记录。等你愿意的时候，再从一张星钥开始。')
        .fontSize(Theme.V2A_FONT_CAPTION)
        .fontColor(Theme.V2_TEXT_TERTIARY)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .lineHeight(20)

      Button(this.getEmptyActionText())
        .type(ButtonType.Normal)
        .fontSize(Theme.V2A_FONT_CAPTION)
        .fontColor(Theme.V2A_GOLD_ACCENT)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('rgba(201,164,75,0.10)')
        .border({ width: 1, color: 'rgba(201,164,75,0.40)' })
        .borderRadius(Theme.V2_RADIUS_FULL)
        .padding({ left: Theme.V2_SPACE_XL, right: Theme.V2_SPACE_XL, top: 10, bottom: 10 })
        .margin({ top: Theme.V2_SPACE_MD })
        .onClick(() => {
          this.goEmptyAction();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildHistoryItem(record: DivinationHistoryRecord): void {
    Row() {
      // 档案脊线（左侧细金线 · A 方案档案锚点）
      Column()
        .width(2)
        .height(42)
        .backgroundColor('rgba(201,164,75,0.35)')
        .borderRadius(1)
        .margin({ right: Theme.V2_SPACE_MD, top: 0, bottom: 0 })

      Column() {
        // 第一行：记录类型 + 场景标签
        Row() {
          Text(record.modeTitle)
            .fontSize(Theme.V2A_FONT_CAPTION)
            .fontColor(Theme.V2A_GOLD_GLOW)
            .fontWeight(FontWeight.Medium)
            .letterSpacing(0.5)

          if (record.scenarioTag && record.scenarioTag.length > 0) {
            Text(record.scenarioTag)
              .fontSize(10)
              .fontColor(Theme.V2_TEXT_TERTIARY)
              .margin({ left: Theme.V2_SPACE_XS })
              .padding({ left: 6, right: 6, top: 1, bottom: 1 })
              .backgroundColor('rgba(138,132,152,0.10)')
              .borderRadius(Theme.V2_RADIUS_XS)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        .margin({ bottom: 3 })

        // 时间戳（等宽字体 · 档案标记感）
        Text(this.formatDate(record.timestamp))
          .fontSize(Theme.V2A_FONT_TIMESTAMP)
          .fontColor(Theme.V2_TEXT_TERTIARY)
          .fontFamily('HarmonyOS Sans Mono')
          .letterSpacing(0.5)
          .margin({ bottom: 4 })

        // 牌名摘要
        if (this.getCardSummary(record).length > 0) {
          Text(this.getCardSummary(record))
            .fontSize(Theme.V2A_FONT_CAPTION)
            .fontColor(Theme.V2A_TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 3 })
        }

        // 问题摘要
        if (record.questionText && record.questionText.length > 0) {
          Text(record.questionText)
            .fontSize(Theme.V2A_FONT_DISCLAIMER)
            .fontColor(Theme.V2A_TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 删除按钮（图标式降级 · 暖铜色细线）
      Text('删除')
        .fontSize(10)
        .fontColor(Theme.V2A_CRISIS)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .border({ width: 1, color: 'rgba(212,133,107,0.35)', style: BorderStyle.Solid })
        .borderRadius(Theme.V2_RADIUS_SM)
        .margin({ left: Theme.V2_SPACE_SM })
        .onClick(() => {
          this.confirmDeleteRecord(record);
        })
    }
    .width('100%')
    .padding({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_MD, left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD })
    .backgroundColor(Theme.V2A_BG_CARD)
    .borderRadius(Theme.V2A_RADIUS_CARD)
    .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
    .shadow(Theme.V2A_SHADOW_CARD)
    .onClick(() => {
      const detailParams: HistoryDetailRouteParams = {
        recordId: record.id,
      };
      try {
        router.pushUrl({ url: Routes.HISTORY_DETAIL, params: detailParams });
      } catch (_err) {
        // ignore
      }
    })
  }
}

import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { HistoryStore } from '../common/HistoryStore';
import { DivinationHistoryRecord, SpreadType } from '../model/DivinationHistoryRecord';

/**
 * 历史详情路由参数
 */
interface HistoryDetailRouteParams {
  recordId: string;
}

/**
 * 历史查询页面（P0.3 整改：单条删除 + 全部清除 + 空状态优化）
 */
@Entry
@Component
struct HistoryPage {
  @State records: DivinationHistoryRecord[] = [];
  @State filterType: string = '全部';
  @State isLoading: boolean = true;
  @State filterOptions: string[] = ['全部', '单牌', '圣三角', '关系'];

  async aboutToAppear(): Promise<void> {
    await this.loadRecords();
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
    return '去单牌快占';
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
    Column() {
      // ── 标题行：返回 + 标题 + 清空 ──
      Row() {
        AppBackButton({ fallbackUrl: Routes.HOME })

        Blank()

        Text('📋 历史查询')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('清空')
          .fontSize(Theme.FONT_BODY)
          .fontColor('#EF4444')
          .opacity(this.records.length > 0 ? 1.0 : 0.3)
          .onClick(() => {
            if (this.records.length > 0) {
              this.confirmClearAll();
            }
          })
      }
      .width('100%')
      .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, top: 48, bottom: Theme.SPACE_SM })
      .backgroundColor(Theme.BG_DEEP_INDIGO)

      Text('回看最近的星钥记录，看看那些反复出现的心事')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.MOON_MUTED)
        .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: Theme.SPACE_MD })
        .width('100%')

      Divider().strokeWidth(0.5).color(Theme.DEEP_STARRY)

      // ── 筛选 Tab ──
      Scroll() {
        Row({ space: Theme.SPACE_SM }) {
          ForEach(this.filterOptions, (opt: string) => {
            Text(opt)
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(this.filterType === opt ? Theme.BG_DEEP_INDIGO : Theme.GOLD_AMBER)
              .fontWeight(FontWeight.Medium)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.filterType === opt ? Theme.GOLD_AMBER : 'rgba(202, 138, 4, 0.1)')
              .borderRadius(Theme.RADIUS_FULL)
              .border({ width: 1, color: 'rgba(202, 138, 4, 0.25)' })
              .onClick(() => {
                this.filterType = opt;
              })
          }, (opt: string) => opt)
        }
        .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, top: Theme.SPACE_MD, bottom: Theme.SPACE_SM })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Divider().strokeWidth(0.5).color(Theme.DEEP_STARRY)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color(Theme.GOLD_AMBER)
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
          .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, top: Theme.SPACE_MD })
          .scrollBar(BarState.Off)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
  }

  /**
   * 空状态（P0.3 整改：更友好的文案）
   */
  @Builder
  buildEmptyState(): void {
    Column({ space: Theme.SPACE_MD }) {
      Text('📭')
        .fontSize(48)

      Text('还没有占卜记录')
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .fontWeight(FontWeight.Medium)

      Text('先抽一张牌，让星澜为你留下第一颗星。')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.MOON_MUTED)

      Button(this.getEmptyActionText())
        .type(ButtonType.Normal)
        .fontSize(Theme.FONT_BODY)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Theme.GOLD_AMBER)
        .borderRadius(Theme.RADIUS_FULL)
        .padding({ left: 28, right: 28, top: 10, bottom: 10 })
        .margin({ top: Theme.SPACE_SM })
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
    Column() {
      Row() {
        Column() {
          Text(this.formatDate(record.timestamp))
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.MOON_MUTED)
            .margin({ bottom: 2 })

          Text(record.modeTitle)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 2 })

          Text(this.getCardSummary(record))
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.GOLD_AMBER)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 删除按钮（P0.3 整改）
        Text('删除')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor('#EF4444')
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .border({ width: 1, color: '#EF4444', style: BorderStyle.Solid })
          .borderRadius(Theme.RADIUS_SM)
          .margin({ left: Theme.SPACE_SM })
          .onClick(() => {
            this.confirmDeleteRecord(record);
          })
      }
      .width('100%')
      .padding({ top: Theme.SPACE_MD, bottom: Theme.SPACE_MD, left: Theme.SPACE_MD, right: Theme.SPACE_MD })
    }
    .width('100%')
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.1)' })
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

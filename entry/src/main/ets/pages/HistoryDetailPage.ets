import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { HistoryStore } from '../common/HistoryStore';
import { DivinationHistoryRecord, DrawnCardRecord, SpreadType } from '../model/DivinationHistoryRecord';
import { TarotCardImage } from '../components/TarotCardImage';

/**
 * 历史记录详情页路由参数
 */
interface HistoryDetailRouteParams {
  recordId: string;
}

/**
 * 历史记录详情页（P0.3 整改：删除按钮 + 返回按钮 + TarotCardImage）
 */
@Entry
@Component
struct HistoryDetailPage {
  @State recordId: string = '';
  @State record: DivinationHistoryRecord | null = null;
  @State isLoading: boolean = true;

  async aboutToAppear(): Promise<void> {
    try {
      const params: HistoryDetailRouteParams = router.getParams() as HistoryDetailRouteParams;
      if (params && params.recordId) {
        this.recordId = params.recordId;
      }
    } catch (_err) {
      // params parse fail
    }

    if (this.recordId) {
      await this.loadRecord();
    } else {
      this.isLoading = false;
    }
  }

  private async loadRecord(): Promise<void> {
    this.isLoading = true;
    try {
      const found: DivinationHistoryRecord | null = await HistoryStore.getRecordById(getContext(this), this.recordId);
      this.record = found;
    } catch (_err) {
      this.record = null;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 删除确认弹窗（P0.3 整改）
   */
  private confirmDelete(): void {
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
          this.deleteRecord();
        }
      }
    });
  }

  /**
   * 执行删除并返回
   */
  private async deleteRecord(): Promise<void> {
    try {
      const ok: boolean = await HistoryStore.deleteRecordById(getContext(this), this.recordId);
      if (ok) {
        this.getUIContext().getPromptAction().showToast({
          message: '记录已删除',
          duration: 2000,
        });
      }
      try {
        router.back();
      } catch (_err) {
        // fallback
        try {
          router.replaceUrl({ url: Routes.HISTORY });
        } catch (_err2) {
          // ignore
        }
      }
    } catch (_err) {
      try {
        router.back();
      } catch (_backErr) {
        // ignore
      }
    }
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

  build() {
    Column() {
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
      } else if (!this.record) {
        Column() {
          Text('记录不存在')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.MOON_MUTED)
            .margin({ top: 80 })

          Button('返回历史记录')
            .type(ButtonType.Normal)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Color.White)
            .backgroundColor(Theme.GOLD_AMBER)
            .borderRadius(Theme.RADIUS_FULL)
            .margin({ top: Theme.SPACE_MD })
            .onClick(() => {
              try {
                router.back();
              } catch (_err) {
                // ignore
              }
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // ── 顶部：返回按钮 + 标题 ──
            Row() {
              AppBackButton({ fallbackUrl: Routes.HISTORY })

              Blank()

              Text('历史详情')
                .fontSize(Theme.FONT_SUBTITLE)
                .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                .fontWeight(FontWeight.Bold)

              Blank()

              Text('    ')
                .fontSize(Theme.FONT_BODY)
                .fontColor(Color.Transparent)
            }
            .width('100%')
            .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, top: Theme.SAFE_TOP, bottom: Theme.SPACE_SM })

            // ── 基本信息区 ──
            Column() {
              Text(this.record!.modeTitle)
                .fontSize(Theme.FONT_HEADLINE)
                .fontColor(Theme.GOLD_AMBER)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: Theme.SPACE_XS })

              Text(this.formatDate(this.record!.timestamp))
                .fontSize(Theme.FONT_CAPTION)
                .fontColor(Theme.MOON_MUTED)
                .margin({ bottom: 4 })

              // 展示用户选择的情绪方向
              if (this.record!.questionText && this.record!.questionText.length > 0) {
                Text(this.record!.questionText)
                  .fontSize(Theme.FONT_CAPTION)
                  .fontColor(Theme.TEXT_SECONDARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom: Theme.SPACE_SM })
              }
            }
            .width('90%')
            .padding(Theme.SPACE_LG)
            .backgroundColor(Theme.BG_CARD_DARK)
            .borderRadius(Theme.RADIUS_MD)
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
            .margin({ bottom: Theme.SPACE_MD })

            // ── 卡牌区（P0.3 整改：使用 TarotCardImage）──
            if (this.record!.cards && this.record!.cards.length > 0) {
              this.buildCardsSection(this.record!.cards)
            }

            // ── 解读内容区 ──
            if (this.record!.summaryText) {
              Column() {
                Text('综合解读')
                  .fontSize(Theme.FONT_SUBTITLE)
                  .fontColor(Theme.GOLD_LIGHT)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: Theme.SPACE_SM })

                Text(this.record!.summaryText)
                  .fontSize(Theme.FONT_BODY)
                  .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                  .lineHeight(Theme.FONT_BODY * 1.6)
              }
              .width('90%')
              .padding(Theme.SPACE_LG)
              .backgroundColor(Theme.BG_CARD_DARK)
              .borderRadius(Theme.RADIUS_MD)
              .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
              .margin({ bottom: Theme.SPACE_MD })
            }

            // ── 行动建议区 ──
            if (this.record!.adviceText) {
              Column() {
                Text('行动建议')
                  .fontSize(Theme.FONT_SUBTITLE)
                  .fontColor(Theme.GOLD_LIGHT)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: Theme.SPACE_SM })

                Text(this.record!.adviceText)
                  .fontSize(Theme.FONT_BODY)
                  .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                  .lineHeight(Theme.FONT_BODY * 1.6)
              }
              .width('90%')
              .padding(Theme.SPACE_LG)
              .backgroundColor(Theme.BG_CARD_DARK)
              .borderRadius(Theme.RADIUS_MD)
              .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
              .margin({ bottom: Theme.SPACE_MD })
            }

            // ── 删除按钮 ──
            Button('删除这条记录')
              .type(ButtonType.Normal)
              .fontSize(Theme.FONT_BODY)
              .fontColor('#E5998A')
              .backgroundColor('rgba(229, 153, 138, 0.08)')
              .border({ width: 1, color: '#E5998A' })
              .borderRadius(Theme.RADIUS_FULL)
              .width('70%')
              .height(44)
              .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_MD })
              .onClick(() => {
                this.confirmDelete();
              })

            // ── 合规页脚 ──
            ComplianceFooter({
              fontSize: Theme.FONT_CAPTION,
              textColor: Theme.MOON_MUTED,
              showDivider: true,
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: 128 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
  }

  /**
   * 卡牌展示区域（P0.3 整改：使用 TarotCardImage 统一填充）
   */
  @Builder
  buildCardsSection(cards: DrawnCardRecord[]): void {
    Row({ space: Theme.SPACE_SM }) {
      ForEach(cards, (cardRecord: DrawnCardRecord) => {
        Column() {
          Text(cardRecord.positionTitle)
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.GOLD_AMBER)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: Theme.SPACE_XS })

          TarotCardImage({
            cardId: cardRecord.cardId,
            cardWidth: 90,
            cardHeight: 144
          })

          Text(cardRecord.cardName)
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .margin({ top: Theme.SPACE_XS })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(cardRecord.keyword)
            .fontSize(10)
            .fontColor(Theme.MOON_MUTED)
            .margin({ top: 2 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Center)
      }, (cardRecord: DrawnCardRecord) => cardRecord.positionKey + '_' + cardRecord.cardId)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding({ top: Theme.SPACE_MD, bottom: Theme.SPACE_MD })
    .backgroundColor(Theme.BG_CARD_DARK)
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
    .margin({ bottom: Theme.SPACE_MD })
  }
}

import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { StarBackground } from '../components/StarBackground';
import { AppBackButton } from '../components/AppBackButton';
import { DivinationRecord } from '../model/DivinationRecord';
import { DivinationHistoryService } from '../service/DivinationHistoryService';

@Entry
@Component
struct DivinationHistoryPage {
  @State history: DivinationRecord[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  async aboutToAppear(): Promise<void> {
    const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      this.history = await DivinationHistoryService.getRecentRecords(ctx);
      this.isLoading = false;
    } catch (err) {
      this.errorMessage = '历史记录加载失败，请稍后再试';
      this.isLoading = false;
    }
  }

  build() {
    Stack() {
      StarBackground()
      AppBackButton()

      Column() {
        Row() {
          Blank()
            .width(56)

          Text('历史查询')
            .fontSize(Theme.FONT_TITLE)
            .fontColor(Theme.GOLD)
            .fontWeight(FontWeight.Bold)
            .letterSpacing(2)
            .textAlign(TextAlign.Center)
            .layoutWeight(1)

          if (this.history.length > 0) {
            Button('清除')
              .height(32)
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.GOLD_SOFT)
              .backgroundColor('rgba(8, 11, 24, 0.48)')
              .borderRadius(Theme.RADIUS_FULL)
              .border({ width: 1, color: 'rgba(216, 180, 90, 0.42)' })
              .padding({ left: 14, right: 14 })
              .onClick(() => {
                this.clearHistory();
              })
          } else {
            Blank()
              .width(56)
          }
        }
        .width('88%')
        .margin({ top: 48, bottom: Theme.SPACE_XS })

        Text(`最近 ${this.history.length} / 50 条`)
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.TEXT_MUTED)
          .margin({ bottom: Theme.SPACE_LG })

        if (this.isLoading) {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Theme.GOLD)
            .margin({ top: Theme.SPACE_XL })
        } else if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.DANGER_SOFT)
            .margin({ top: Theme.SPACE_XL })
        } else if (this.history.length === 0) {
          Column() {
            Text('还没有占卜历史')
              .fontSize(Theme.FONT_SUBTITLE)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)

            Text('完成一次单牌、圣三角或关系探索后，这里就会自动保存。')
              .fontSize(Theme.FONT_BODY)
              .fontColor(Theme.TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .lineHeight(24)
              .margin({ top: Theme.SPACE_MD })
          }
          .width('84%')
          .padding(Theme.SPACE_LG)
          .backgroundColor(Theme.BG_CARD)
          .borderRadius(Theme.RADIUS_LG)
        } else {
          Scroll() {
            Column() {
              ForEach(this.history, (item: DivinationRecord, index: number) => {
                this.HistoryCard(item)
              }, (item: DivinationRecord) => item.id)
            }
            .width('88%')
            .padding({ bottom: Theme.SPACE_XL })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  HistoryCard(item: DivinationRecord): void {
    Column() {
      Row() {
        Text(item.spread.name)
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD)
          .fontWeight(FontWeight.Bold)
          .padding({ left: Theme.SPACE_SM, right: Theme.SPACE_SM, top: 4, bottom: 4 })
          .borderRadius(Theme.RADIUS_SM)
          .border({ width: 1, color: Theme.GOLD })

        Blank()

        Text(this.formatDateTime(item.createdAt))
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.TEXT_MUTED)
      }
      .width('100%')

      Text(this.getTopicLabel(item.questionType))
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.AURORA)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ top: Theme.SPACE_MD })

      Text(this.getCardsSummary(item))
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .lineHeight(24)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: Theme.SPACE_SM })

      Text('查看结果 >')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.GOLD_SOFT)
        .width('100%')
        .margin({ top: Theme.SPACE_MD })
    }
    .width('100%')
    .padding(Theme.SPACE_MD)
    .backgroundColor('rgba(23, 29, 58, 0.82)')
    .borderRadius(Theme.RADIUS_MD)
    .border({ width: 1, color: 'rgba(216, 180, 90, 0.16)' })
    .margin({ bottom: Theme.SPACE_MD })
    .onClick(() => {
      AppStorage.setOrCreate('currentDivinationRecord', item);
      try {
        this.getUIContext().getRouter().pushUrl({ url: Routes.RESULT });
      } catch (err) {
        hilog.error(0x0000, 'DivinationHistoryPage', 'Router push error: %{public}s', JSON.stringify(err));
      }
    })
  }

  private getCardsSummary(record: DivinationRecord): string {
    return record.cards
      .map((item) => `${item.positionName} · ${item.card.nameZh}${item.isReversed ? '（逆位）' : ''}`)
      .join(' / ');
  }

  private getTopicLabel(questionType: string): string {
    const labels: Record<string, string> = {
      'love': '情感关系',
      'career': '学业事业',
      'growth': '自我成长',
      'decision': '两难决策',
      'social': '人际社交',
      'general': '通用综合'
    };
    return labels[questionType] ?? '通用综合';
  }

  private formatDateTime(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const year: number = date.getFullYear();
    const month: string = `${date.getMonth() + 1}`.padStart(2, '0');
    const day: string = `${date.getDate()}`.padStart(2, '0');
    const hours: string = `${date.getHours()}`.padStart(2, '0');
    const minutes: string = `${date.getMinutes()}`.padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  private async clearHistory(): Promise<void> {
    const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      await DivinationHistoryService.clearHistory(ctx);
      this.history = [];
      this.errorMessage = '';
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '历史记录已清除',
          duration: 1800
        });
      } catch (toastErr) {
        hilog.error(0x0000, 'DivinationHistoryPage', 'Toast error: %{public}s', JSON.stringify(toastErr));
      }
    } catch (err) {
      hilog.error(0x0000, 'DivinationHistoryPage', 'Clear history error: %{public}s', JSON.stringify(err));
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '清除失败，请稍后再试',
          duration: 1800
        });
      } catch (toastErr) {
        hilog.error(0x0000, 'DivinationHistoryPage', 'Toast error: %{public}s', JSON.stringify(toastErr));
      }
    }
  }
}

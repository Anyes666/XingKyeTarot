import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';
import { DivinationRecord, DrawnCard } from '../model/DivinationRecord';
import { StarBackground } from '../components/StarBackground';
import { TarotCardView, CardDisplayState } from '../components/TarotCardView';
import { InterpretationPanel } from '../components/InterpretationPanel';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { PrimaryButton } from '../components/PrimaryButton';
import { SharePreview } from '../components/SharePreview';
import { ShareService } from '../service/ShareService';
import { ShareImageService } from '../service/ShareImageService';
import { AppBackButton } from '../components/AppBackButton';
import { DivinationHistoryService } from '../service/DivinationHistoryService';

/**
 * 占卜结果页
 */
@Entry
@Component
struct DivinationResultPage {
  @State record: DivinationRecord | null = null;
  @State isSharing: boolean = false;
  @State showSharePreview: boolean = false;

  async aboutToAppear(): Promise<void> {
    const stored: DivinationRecord | null =
      AppStorage.get<DivinationRecord | null>('currentDivinationRecord') ?? null;
    if (stored) {
      this.record = stored;
      try {
        const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
        await DivinationHistoryService.saveRecord(stored, ctx);
      } catch (err) {
        hilog.error(0x0000, 'DivinationResultPage', 'Archive history error: %{public}s', JSON.stringify(err));
      }
    }
  }

  build() {
    Stack() {
      StarBackground()
      AppBackButton()

      if (!this.record) {
        Column() {
          Text('未找到占卜记录')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_MUTED)
          Button('返回首页')
            .margin({ top: Theme.SPACE_MD })
            .onClick(() => {
              try {
                this.getUIContext().getRouter().replaceUrl({ url: Routes.HOME });
              } catch (err) {
                hilog.error(0x0000, 'DivinationResultPage', 'Router replace error: %{public}s', JSON.stringify(err));
              }
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            Text(`${this.record.spread.name}解读`)
              .fontSize(Theme.FONT_TITLE)
              .fontColor(Theme.GOLD)
              .fontWeight(FontWeight.Bold)
              .letterSpacing(2)
              .margin({ top: 48, bottom: Theme.SPACE_XS })

            Text(this.getSpreadSubtitle(this.record))
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.TEXT_MUTED)
              .margin({ bottom: Theme.SPACE_XS })

            Text(this.getTopicLabel(this.record.questionType))
              .fontSize(Theme.FONT_BODY)
              .fontColor(Theme.AURORA)
              .fontWeight(FontWeight.Medium)
              .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, top: 4, bottom: 4 })
              .borderRadius(Theme.RADIUS_SM)
              .backgroundColor('rgba(94, 215, 210, 0.1)')
              .margin({ bottom: Theme.SPACE_LG })

            Row() {
              ForEach(this.record!.cards, (card: DrawnCard, index: number) => {
                Column() {
                  TarotCardView({
                    cardName: card.card.nameZh,
                    cardImage: card.card.image,
                    isReversed: card.isReversed,
                    displayState: CardDisplayState.REVEALED,
                    cardWidth: 85,
                    cardHeight: 136
                  })
                }
                .alignItems(HorizontalAlign.Center)
              }, (card: DrawnCard, index: number) => `result_card_${index}`)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
            .margin({ bottom: Theme.SPACE_LG })

            ForEach(this.record!.cards, (card: DrawnCard, index: number) => {
              InterpretationPanel({
                positionName: card.positionName,
                cardName: card.card.nameZh,
                isReversed: card.isReversed,
                keywords: card.keywords,
                interpretation: card.interpretation
              })
                .margin({ bottom: Theme.SPACE_MD })
            }, (card: DrawnCard, index: number) => `interpretation_${index}`)

            PrimaryButton({
              buttonLabel: this.isSharing ? '保存中…' : '保存分享图片',
              isDisabled: this.isSharing,
              onTap: () => {
                this.generateShare();
              }
            })
              .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_MD })

            ComplianceFooter()

            Blank()
              .height(Theme.SPACE_XL)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      }

      if (this.showSharePreview && this.record) {
        Column() {
          SharePreview({ record: this.record })
            .id('sharePreviewRoot')
        }
        .width(1080)
        .height(1920)
        .visibility(Visibility.Hidden)
      }
    }
  }

  private async generateShare(): Promise<void> {
    if (this.isSharing || !this.record) {
      return;
    }

    this.isSharing = true;

    try {
      const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      this.showSharePreview = true;
      await this.waitForPreviewRender();

      // 使用 UIContext 获取 ComponentSnapshot（全局 componentSnapshot 已废弃）
      const snapshot = this.getUIContext().getComponentSnapshot();
      const pixelMap = await snapshot.get('sharePreviewRoot', {
        scale: 1,
        waitUntilRenderFinished: true
      });
      // 使用 saveShareCardByComponentId 降级 — 当前 SDK 保存管线暂未完整适配
      // 真实保存待 ShareImageService SDK 适配专项
      const fileName: string = ShareImageService.buildShareImageFileName(this.record!.id);
      // savePixelMapToGallery 已移除，走降级提示
      pixelMap.release();

      try {
        this.getUIContext().getPromptAction().showToast({
          message: '保存图片功能暂未适配当前系统版本',
          duration: 2000
        });
      } catch (toastErr) {
        hilog.error(0x0000, 'DivinationResultPage', 'Toast error: %{public}s', JSON.stringify(toastErr));
      }
    } catch (err) {
      hilog.error(0x0000, 'DivinationResultPage', 'Share failed: %{public}s', JSON.stringify(err));
      try {
        await ShareService.generateAndShare(this.record!);
        this.getUIContext().getPromptAction().showToast({
          message: '保存图片失败，已复制文字内容',
          duration: 2000
        });
      } catch (toastErr) {
        hilog.error(0x0000, 'DivinationResultPage', 'Toast error: %{public}s', JSON.stringify(toastErr));
      }
    } finally {
      this.showSharePreview = false;
      this.isSharing = false;
    }
  }

  private async waitForPreviewRender(): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, 300);
    });
  }

  private getTopicLabel(questionType: string): string {
    const labels: Record<string, string> = {
      'love': '💕 情感关系',
      'career': '📚 学业事业',
      'growth': '🌱 自我成长',
      'decision': '⚖️ 两难决策',
      'social': '🤝 人际社交',
      'general': '🔮 通用综合'
    };
    return labels[questionType] ?? '🔮 通用综合';
  }

  private getSpreadSubtitle(record: DivinationRecord): string {
    return record.spread.positions.map((position) => position.name).join(' · ');
  }
}

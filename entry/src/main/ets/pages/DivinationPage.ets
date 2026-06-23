import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';
import { UserStateService } from '../service/UserStateService';
import { DivinationService } from '../service/DivinationService';
import { DivinationRecord, DrawnCard } from '../model/DivinationRecord';
import { StarBackground } from '../components/StarBackground';
import { TarotCardView, CardDisplayState } from '../components/TarotCardView';
import { PrimaryButton } from '../components/PrimaryButton';
import { ComplianceFooter } from '../components/ComplianceFooter';

enum DivinationPhase {
  SELECT_TOPIC = 'selectTopic',
  IDLE = 'idle',
  DRAWING = 'drawing',
  REVEALED = 'revealed'
}

interface TopicOption {
  id: string;
  label: string;
  emoji: string;
  hint: string;
}

/** 主题列表（v1.5 核心 5 个 + 通用） */
const TOPICS: TopicOption[] = [
  { id: 'love', label: '情感关系', emoji: '💕', hint: '恋爱 · 矛盾 · 复合 · 羁绊' },
  { id: 'career', label: '学业事业', emoji: '📚', hint: '考试 · 求职 · 发展 · 项目' },
  { id: 'growth', label: '自我成长', emoji: '🌱', hint: '内耗 · 天赋 · 方向 · 状态' },
  { id: 'decision', label: '两难决策', emoji: '⚖️', hint: '抉择 · 利弊 · 要不要做' },
  { id: 'social', label: '人际社交', emoji: '🤝', hint: '职场 · 朋友 · 家人 · 团队' },
  { id: 'general', label: '通用综合', emoji: '🔮', hint: '随便抽着玩，不限定主题' }
];

@Entry
@Component
struct DivinationPage {
  @State phase: DivinationPhase = DivinationPhase.SELECT_TOPIC;
  @State record: DivinationRecord | null = null;
  @State revealedCount: number = 0;
  @State drawnCards: DrawnCard[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  private revealTimerId: number = -1;

  aboutToAppear(): void {
    // 主题选择阶段不预先抽牌，等用户选定后再抽
  }

  build() {
    Stack() {
      StarBackground()

      Column() {
        Column() {
          Text('圣三角占卜')
            .fontSize(Theme.FONT_TITLE)
            .fontColor(Theme.GOLD)
            .fontWeight(FontWeight.Bold)
            .letterSpacing(2)

          Text('过去 · 现在 · 未来')
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.TEXT_MUTED)
            .margin({ top: Theme.SPACE_XS })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 48, bottom: Theme.SPACE_LG })

        if (this.phase === DivinationPhase.SELECT_TOPIC) {
          // ── 主题选择界面 ──
          this.TopicSelector()
        }

        if (this.phase !== DivinationPhase.REVEALED &&
            this.phase !== DivinationPhase.SELECT_TOPIC) {
          Text(this.getInstructionText())
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .padding({ left: Theme.SPACE_LG, right: Theme.SPACE_LG })
            .margin({ bottom: Theme.SPACE_LG })
        }

        if (this.isLoading) {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Theme.GOLD)
        } else if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.DANGER_SOFT)
        } else if (this.phase !== DivinationPhase.SELECT_TOPIC) {
          Row() {
            ForEach(this.drawnCards, (card: DrawnCard, index: number) => {
              TarotCardView({
                cardName: card.card.nameZh,
                cardImage: card.card.image,
                isReversed: card.isReversed,
                displayState: index < this.revealedCount ? CardDisplayState.REVEALED : CardDisplayState.IDLE,
                cardWidth: 90,
                cardHeight: 144,
                onTap: () => {
                  this.onCardTap(index);
                }
              })
            }, (card: DrawnCard, index: number) => `card_${index}`)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .padding({ left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        }

        if (this.revealedCount > 0 && this.phase !== DivinationPhase.REVEALED) {
          Column() {
            ForEach(
              this.drawnCards.slice(0, this.revealedCount),
              (card: DrawnCard, index: number) => {
                Row() {
                  Text(card.positionName)
                    .fontSize(Theme.FONT_CAPTION)
                    .fontColor(Theme.GOLD)
                    .fontWeight(FontWeight.Bold)
                    .width(40)

                  Text(card.card.nameZh)
                    .fontSize(Theme.FONT_BODY)
                    .fontColor(Theme.TEXT_PRIMARY)
                    .layoutWeight(1)

                  if (card.isReversed) {
                    Text('逆')
                      .fontSize(10)
                      .fontColor(Theme.DANGER_SOFT)
                  }
                }
                .width('80%')
                .padding({ top: 4, bottom: 4 })
              },
              (card: DrawnCard, index: number) => `summary_${index}`
            )
          }
          .margin({ top: Theme.SPACE_LG })
        }

        Blank()

        if (this.phase === DivinationPhase.REVEALED) {
          Column() {
            PrimaryButton({
              buttonLabel: '查看解读',
              onTap: () => {
                this.goToResult();
              }
            })

            Text('结果仅供娱乐，请理性参考')
              .fontSize(Theme.FONT_CAPTION)
              .fontColor(Theme.TEXT_MUTED)
              .opacity(0.6)
              .margin({ top: Theme.SPACE_SM })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 16 })
        } else {
          ComplianceFooter({ showDivider: false })
            .margin({ bottom: Theme.SPACE_MD })
        }
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  TopicSelector(): void {
    Column() {
      Text('请选择你想问的主题')
        .fontSize(Theme.FONT_SUBTITLE)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: Theme.SPACE_XS })

      Text('选择后我们将为你定制解读侧重')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.TEXT_MUTED)
        .margin({ bottom: Theme.SPACE_LG })

      Scroll() {
        Column() {
          ForEach(TOPICS, (topic: TopicOption) => {
            Row() {
              Text(topic.emoji)
                .fontSize(28)
                .width(48)

              Column() {
                Text(topic.label)
                  .fontSize(Theme.FONT_BODY)
                  .fontColor(Theme.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)

                Text(topic.hint)
                  .fontSize(Theme.FONT_CAPTION)
                  .fontColor(Theme.TEXT_MUTED)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: Theme.SPACE_SM })

              Text('>')
                .fontSize(Theme.FONT_BODY)
                .fontColor(Theme.GOLD_DIM)
            }
            .width('100%')
            .padding(Theme.SPACE_MD)
            .margin({ bottom: Theme.SPACE_SM })
            .backgroundColor(Theme.BG_CARD)
            .borderRadius(Theme.RADIUS_MD)
            .border({ width: 1, color: 'rgba(216, 180, 90, 0.15)' })
            .onClick(() => {
              this.onTopicSelected(topic.id);
            })
          }, (topic: TopicOption) => topic.id)
        }
        .width('88%')
        .padding({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
  }

  private async onTopicSelected(topicId: string): Promise<void> {
    this.phase = DivinationPhase.IDLE;
    this.isLoading = true;

    const ctx: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    try {
      const userId: string = await UserStateService.getUserId(ctx);
      const seed: string = `${userId}-${Date.now()}-${Math.random().toString(36).substring(2, 8)}`;
      this.record = await DivinationService.drawSacredTriangle(topicId, seed);
      this.drawnCards = this.record.cards;
      this.revealedCount = 0;
      this.isLoading = false;
    } catch (err) {
      this.errorMessage = '牌面加载失败，请返回重试';
      this.isLoading = false;
    }
  }

  private getInstructionText(): string {
    switch (this.phase) {
      case DivinationPhase.IDLE:
        return '请依次点击三张牌\n从左到右，感受内心的指引';
      case DivinationPhase.DRAWING:
        return `已翻开 ${this.revealedCount} / 3 张牌\n继续点击剩余的牌`;
      default:
        return '';
    }
  }

  private onCardTap(index: number): void {
    if (this.phase === DivinationPhase.REVEALED) {
      return;
    }
    if (index < this.revealedCount) {
      return;
    }
    if (index !== this.revealedCount) {
      return;
    }

    this.phase = DivinationPhase.DRAWING;
    this.revealedCount++;

    if (this.revealedCount >= 3) {
      this.revealTimerId = setTimeout(() => {
        this.phase = DivinationPhase.REVEALED;
      }, 500);
    }
  }

  aboutToDisappear(): void {
    if (this.revealTimerId !== -1) {
      clearTimeout(this.revealTimerId);
      this.revealTimerId = -1;
    }
  }

  private goToResult(): void {
    if (!this.record) {
      return;
    }
    AppStorage.setOrCreate('currentDivinationRecord', this.record);
    try {
      router.pushUrl({ url: Routes.RESULT });
    } catch (err) {
      hilog.error(0x0000, 'DivinationPage', 'Router push error: %{public}s', JSON.stringify(err));
    }
  }
}

import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { TAROT_CARDS } from '../data/TarotCardData';
import { TarotCard, ArcanaType, TarotSuit } from '../model/TarotCard';

/**
 * 卡牌总览页面路由参数
 */
interface TarotCardDetailRouteParams {
  cardId: string;
}

/**
 * 筛选项配置
 */
interface FilterOption {
  label: string;
  value: string;
}

/**
 * Phase 6.3：卡牌总览页
 * 展示 78 张塔罗牌列表，支持按组别筛选
 */
@Entry
@Component
struct TarotCardsPage {
  @State selectedFilter: string = 'all';
  @State displayedCards: TarotCard[] = TAROT_CARDS;

  private filters: FilterOption[] = [
    { label: '全部', value: 'all' },
    { label: '大阿尔卡那', value: 'major' },
    { label: '权杖', value: 'wands' },
    { label: '圣杯', value: 'cups' },
    { label: '宝剑', value: 'swords' },
    { label: '星币', value: 'pentacles' }
  ];

  private applyFilter(value: string): void {
    this.selectedFilter = value;
    if (value === 'all') {
      this.displayedCards = TAROT_CARDS;
    } else if (value === 'major') {
      this.displayedCards = TAROT_CARDS.filter((card: TarotCard) => card.arcana === ArcanaType.MAJOR);
    } else {
      this.displayedCards = TAROT_CARDS.filter((card: TarotCard) => {
        if (card.suit === TarotSuit.NONE) {
          return false;
        }
        return card.suit === value;
      });
    }
  }

  private navigateToDetail(card: TarotCard): void {
    try {
      const params: TarotCardDetailRouteParams = { cardId: card.id };
      const options: router.RouterOptions = { url: Routes.TAROT_CARD_DETAIL, params: params };
      router.pushUrl(options);
    } catch (_err) {
      // ignore
    }
  }

  private getSuitLabel(card: TarotCard): string {
    if (card.arcana === ArcanaType.MAJOR) {
      return '大阿尔卡那';
    }
    switch (card.suit) {
      case TarotSuit.WANDS:
        return '权杖';
      case TarotSuit.CUPS:
        return '圣杯';
      case TarotSuit.SWORDS:
        return '宝剑';
      case TarotSuit.PENTACLES:
        return '星币';
      default:
        return '';
    }
  }

  private getSuitColor(card: TarotCard): string {
    if (card.arcana === ArcanaType.MAJOR) {
      return '#E8B83D';
    }
    switch (card.suit) {
      case TarotSuit.WANDS:
        return '#E8A838';
      case TarotSuit.CUPS:
        return '#5EA8D7';
      case TarotSuit.SWORDS:
        return '#8B7EC8';
      case TarotSuit.PENTACLES:
        return '#6EB87A';
      default:
        return '#94A3B8';
    }
  }

  build() {
    Stack() {
      // 沉浸式深空背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [Theme.BG_DEEP_SPACE, 0.0],
            [Theme.BG_DEEP_INDIGO, 0.55],
            [Theme.BG_DEEP_INDIGO, 1.0]
          ]
        })

      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.MAIN_FRAME })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        .alignItems(VerticalAlign.Center)

        // 标题
        Text('卡牌总览')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        // 副标题
        Text('78 张塔罗牌，不是答案，而是看见自己的不同方式。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_MD })

        // 筛选区
        Scroll() {
          Row() {
            ForEach(this.filters, (filter: FilterOption, index: number) => {
              Text(filter.label)
                .fontSize(13)
                .fontColor(this.selectedFilter === filter.value ? Theme.BG_DEEP_INDIGO : Theme.MOON_MUTED)
                .fontWeight(this.selectedFilter === filter.value ? FontWeight.Bold : FontWeight.Normal)
                .backgroundColor(this.selectedFilter === filter.value ? '#E8B83D' : 'rgba(27, 27, 48, 0.68)')
                .borderRadius(16)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin({ right: 8 })
                .onClick(() => {
                  this.applyFilter(filter.value);
                })
            }, (_filter: FilterOption, index: number) => 'filter_' + index.toString())
          }
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(44)
        .margin({ bottom: Theme.SPACE_SM })

        // 分隔线
        Divider()
          .strokeWidth(0.5)
          .color(Theme.DEEP_STARRY)
          .margin({ bottom: Theme.SPACE_SM })

        // 卡牌列表
        Scroll() {
          List() {
            ForEach(this.displayedCards, (card: TarotCard, index: number) => {
              ListItem() {
                Row() {
                  // 编号
                  Text(this.formatIndex(card.index))
                    .fontSize(12)
                    .fontColor(Theme.GOLD_DIM)
                    .width(36)
                    .textAlign(TextAlign.Center)

                  // 卡牌信息
                  Column() {
                    Text(card.nameZh)
                      .fontSize(Theme.FONT_BODY)
                      .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                      .fontWeight(FontWeight.Medium)

                    Text(card.nameEn)
                      .fontSize(11)
                      .fontColor(Theme.MOON_MUTED)
                      .margin({ top: 2 })

                    // 关键词
                    Row() {
                      ForEach(card.keywords, (keyword: string, ki: number) => {
                        Text(keyword)
                          .fontSize(10)
                          .fontColor(this.getSuitColor(card))
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .margin({ right: 4, top: 4 })
                      }, (_kw: string, ki: number) => 'kw_' + card.id + '_' + ki.toString())
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({ left: Theme.SPACE_SM })

                  // 所属类别
                  Text(this.getSuitLabel(card))
                    .fontSize(10)
                    .fontColor(this.getSuitColor(card))
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .border({ width: 0.5, color: this.getSuitColor(card), style: BorderStyle.Solid })
                    .borderRadius(8)
                    .margin({ right: 4 })

                  // 箭头
                  Text('›')
                    .fontSize(20)
                    .fontColor(Theme.GOLD_DIM)
                }
                .width('100%')
                .padding({ left: Theme.STARKEY_CARD_PADDING_H, right: Theme.STARKEY_CARD_PADDING_H, top: Theme.SPACE_SM, bottom: Theme.SPACE_SM })
                .alignItems(VerticalAlign.Center)
                .backgroundColor(Theme.STARKEY_CARD_BG)
                .borderRadius(Theme.STARKEY_CARD_RADIUS)
                .border({ width: 1, color: Theme.STARKEY_CARD_BORDER })
                .margin({ bottom: 6, left: Theme.SPACE_MD, right: Theme.SPACE_MD })
                .onClick(() => {
                  this.navigateToDetail(card);
                })
              }
            }, (card: TarotCard) => card.id)
          }
          .width('100%')
          .padding({ top: Theme.SPACE_SM, bottom: Theme.SPACE_LG })
          .listDirection(Axis.Vertical)
          .divider({ strokeWidth: 0 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }

  private formatIndex(index: number): string {
    if (index < 10) {
      return '0' + index.toString();
    }
    return index.toString();
  }
}

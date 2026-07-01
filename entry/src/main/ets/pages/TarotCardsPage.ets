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
 * 卡牌列表懒加载数据源（LazyForEach 性能优化）
 */
class TarotCardDataSource implements IDataSource {
  private list: TarotCard[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.list.length;
  }

  getData(index: number): TarotCard {
    return this.list[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.push(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos: number = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  setData(data: TarotCard[]): void {
    this.list = data;
    for (let i: number = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataReloaded();
    }
  }
}

/**
 * Phase 6.3：卡牌总览页
 * 展示 78 张塔罗牌列表，支持按组别筛选
 */
@Entry
@Component
struct TarotCardsPage {
  @State selectedFilter: string = 'all';
  private dataSource: TarotCardDataSource = new TarotCardDataSource();

  private filters: FilterOption[] = [
    { label: '全部', value: 'all' },
    { label: '大阿尔卡那', value: 'major' },
    { label: '权杖', value: 'wands' },
    { label: '圣杯', value: 'cups' },
    { label: '宝剑', value: 'swords' },
    { label: '星币', value: 'pentacles' }
  ];

  aboutToAppear(): void {
    this.dataSource.setData(TAROT_CARDS);
  }

  private applyFilter(value: string): void {
    this.selectedFilter = value;
    if (value === 'all') {
      this.dataSource.setData(TAROT_CARDS);
    } else if (value === 'major') {
      this.dataSource.setData(TAROT_CARDS.filter((card: TarotCard) => card.arcana === ArcanaType.MAJOR));
    } else {
      const filtered: TarotCard[] = TAROT_CARDS.filter((card: TarotCard) => {
        if (card.suit === TarotSuit.NONE) {
          return false;
        }
        return card.suit === value;
      });
      this.dataSource.setData(filtered);
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
      return Theme.V2C_GOLD_GILT;
    }
    switch (card.suit) {
      case TarotSuit.WANDS:
        return Theme.V2C_CRISIS;
      case TarotSuit.CUPS:
        return Theme.V2B_GOLD_RIPPLE;
      case TarotSuit.SWORDS:
        return Theme.V2C_TEXT_SECONDARY;
      case TarotSuit.PENTACLES:
        return Theme.V2C_GOLD_GILT_SOFT;
      default:
        return Theme.V2C_TEXT_SECONDARY;
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
            [Theme.V2C_BG_BASE, 0.0],
            [Theme.V2C_BG_BASE, 0.55],
            [Theme.V2C_BG_BASE, 1.0]
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
          .fontSize(Theme.V2C_FONT_TITLE)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD })

        // 副标题
        Text('78 张塔罗牌，不是答案，而是看见自己的不同方式。')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_MD })

        // 筛选区
        Scroll() {
          Row() {
            ForEach(this.filters, (filter: FilterOption, index: number) => {
              Text(filter.label)
                .fontSize(13)
                .fontColor(this.selectedFilter === filter.value ? Theme.V2C_BG_BASE : Theme.V2C_TEXT_SECONDARY)
                .fontWeight(this.selectedFilter === filter.value ? FontWeight.Bold : FontWeight.Normal)
                .backgroundColor(this.selectedFilter === filter.value ? Theme.V2C_GOLD_GILT : 'rgba(18, 24, 54, 0.68)')
                .borderRadius(Theme.V2C_RADIUS_CHIP)
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
          .color(Theme.V2C_SPINE_LINE)
          .margin({ bottom: Theme.SPACE_SM })

        // 烫金书脊线分隔
        Row()
          .width('60%')
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.15)
          .margin({ bottom: Theme.SPACE_SM })

        // 卡牌列表（LazyForEach 懒加载优化）
        Scroll() {
          List() {
            LazyForEach(this.dataSource, (card: TarotCard) => {
              ListItem() {
                Row() {
                  // 编号
                  Text(this.formatIndex(card.index))
                    .fontSize(Theme.V2C_FONT_CARD_NUM)
                    .fontColor(Theme.V2C_GOLD_GILT)
                    .width(36)
                    .textAlign(TextAlign.Center)

                  // 卡牌信息
                  Column() {
                    Text(card.nameZh)
                      .fontSize(Theme.V2C_FONT_BODY)
                      .fontColor(Theme.V2C_TEXT_PRIMARY)
                      .fontWeight(FontWeight.Medium)

                    Text(card.nameEn)
                      .fontSize(Theme.V2C_FONT_CAPTION)
                      .fontColor(Theme.V2C_TEXT_SECONDARY)
                      .margin({ top: 2 })

                    // 关键词
                    Row() {
                      ForEach(card.keywords, (keyword: string, ki: number) => {
                        Text(keyword)
                          .fontSize(Theme.V2C_FONT_DISCLAIMER)
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
                    .fontSize(Theme.V2C_FONT_DISCLAIMER)
                    .fontColor(this.getSuitColor(card))
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .border({ width: 0.5, color: this.getSuitColor(card), style: BorderStyle.Solid })
                    .borderRadius(Theme.V2C_RADIUS_CHIP)
                    .margin({ right: 4 })

                  // 箭头
                  Text('›')
                    .fontSize(Theme.V2C_FONT_SUBTITLE)
                    .fontColor(Theme.V2C_GOLD_GILT)
                }
                .width('100%')
                .padding({ left: Theme.V2_SPACE_MD_B, right: Theme.V2_SPACE_MD_B, top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_SM })
                .alignItems(VerticalAlign.Center)
                .backgroundColor(Theme.V2C_BG_CARD)
                .borderRadius(Theme.V2C_RADIUS_CARD)
                .border({ width: 1, color: Theme.V2C_SPINE_LINE })
                .margin({ bottom: 6, left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD })
                .onClick(() => {
                  this.navigateToDetail(card);
                })
              }
            }, (card: TarotCard) => card.id)
          }
          .width('100%')
          .padding({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_LG })
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

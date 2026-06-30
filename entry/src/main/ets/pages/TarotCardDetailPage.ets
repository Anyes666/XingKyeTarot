import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { TAROT_CARDS } from '../data/TarotCardData';
import { TarotCard, ArcanaType, TarotSuit } from '../model/TarotCard';

/**
 * 卡牌详情路由参数
 */
interface TarotCardDetailRouteParams {
  cardId: string;
}

/**
 * 卡牌解读内容接口
 */
interface CardReading {
  uprightMeaning: string;
  reversedMeaning: string;
  companionReading: string;
  relationHint: string;
  workHint: string;
  selfExploration: string;
}

/**
 * Phase 6.9：卡牌详情页 — 带图片预览与缩放
 * 展示单张塔罗牌的完整解读，支持点击牌图进入全屏预览（双指缩放 + 拖动）
 */
@Entry
@Component
struct TarotCardDetailPage {
  @State card: TarotCard | null = null;
  @State reading: CardReading | null = null;
  // ── 全屏预览状态 ──
  @State showImagePreview: boolean = false;
  @State previewScale: number = 1.0;
  @State previewOffsetX: number = 0;
  @State previewOffsetY: number = 0;

  aboutToAppear(): void {
    this.loadCard();
  }

  private loadCard(): void {
    const ctx = this.getUIContext().getHostContext();
    try {
      const params = router.getParams() as TarotCardDetailRouteParams;
      if (params && params.cardId) {
        const found: TarotCard | undefined = TAROT_CARDS.find((c: TarotCard) => c.id === params.cardId);
        if (found) {
          this.card = found;
          this.reading = this.generateReading(found);
        }
      }
    } catch (_err) {
      // ignore
    }
  }

  // ── 图片资源映射（复用 TarotCardView 的映射逻辑）──
  private getCardImageResource(card: TarotCard): Resource {
    const fileName: string = card.image;
    switch (fileName) {
      case 'tarot_major_00_fool.png': return $r('app.media.tarot_major_00_fool');
      case 'tarot_major_01_magician.png': return $r('app.media.tarot_major_01_magician');
      case 'tarot_major_02_high_priestess.png': return $r('app.media.tarot_major_02_high_priestess');
      case 'tarot_major_03_empress.png': return $r('app.media.tarot_major_03_empress');
      case 'tarot_major_04_emperor.png': return $r('app.media.tarot_major_04_emperor');
      case 'tarot_major_05_hierophant.png': return $r('app.media.tarot_major_05_hierophant');
      case 'tarot_major_06_lovers.png': return $r('app.media.tarot_major_06_lovers');
      case 'tarot_major_07_chariot.png': return $r('app.media.tarot_major_07_chariot');
      case 'tarot_major_08_strength.png': return $r('app.media.tarot_major_08_strength');
      case 'tarot_major_09_hermit.png': return $r('app.media.tarot_major_09_hermit');
      case 'tarot_major_10_wheel_of_fortune.png': return $r('app.media.tarot_major_10_wheel_of_fortune');
      case 'tarot_major_11_justice.png': return $r('app.media.tarot_major_11_justice');
      case 'tarot_major_12_hanged_man.png': return $r('app.media.tarot_major_12_hanged_man');
      case 'tarot_major_13_death.png': return $r('app.media.tarot_major_13_death');
      case 'tarot_major_14_temperance.png': return $r('app.media.tarot_major_14_temperance');
      case 'tarot_major_15_devil.png': return $r('app.media.tarot_major_15_devil');
      case 'tarot_major_16_tower.png': return $r('app.media.tarot_major_16_tower');
      case 'tarot_major_17_star.png': return $r('app.media.tarot_major_17_star');
      case 'tarot_major_18_moon.png': return $r('app.media.tarot_major_18_moon');
      case 'tarot_major_19_sun.png': return $r('app.media.tarot_major_19_sun');
      case 'tarot_major_20_judgement.png': return $r('app.media.tarot_major_20_judgement');
      case 'tarot_major_21_world.png': return $r('app.media.tarot_major_21_world');
      case 'minor_cups_01_ace.png': return $r('app.media.minor_cups_01_ace');
      case 'minor_cups_02_two.png': return $r('app.media.minor_cups_02_two');
      case 'minor_cups_03_three.png': return $r('app.media.minor_cups_03_three');
      case 'minor_cups_04_four.png': return $r('app.media.minor_cups_04_four');
      case 'minor_cups_05_five.png': return $r('app.media.minor_cups_05_five');
      case 'minor_cups_06_six.png': return $r('app.media.minor_cups_06_six');
      case 'minor_cups_07_seven.png': return $r('app.media.minor_cups_07_seven');
      case 'minor_cups_08_eight.png': return $r('app.media.minor_cups_08_eight');
      case 'minor_cups_09_nine.png': return $r('app.media.minor_cups_09_nine');
      case 'minor_cups_10_ten.png': return $r('app.media.minor_cups_10_ten');
      case 'minor_cups_king.png': return $r('app.media.minor_cups_king');
      case 'minor_cups_knight.png': return $r('app.media.minor_cups_knight');
      case 'minor_cups_page.png': return $r('app.media.minor_cups_page');
      case 'minor_cups_queen.png': return $r('app.media.minor_cups_queen');
      case 'minor_pentacles_01_ace.png': return $r('app.media.minor_pentacles_01_ace');
      case 'minor_pentacles_02_two.png': return $r('app.media.minor_pentacles_02_two');
      case 'minor_pentacles_03_three.png': return $r('app.media.minor_pentacles_03_three');
      case 'minor_pentacles_04_four.png': return $r('app.media.minor_pentacles_04_four');
      case 'minor_pentacles_05_five.png': return $r('app.media.minor_pentacles_05_five');
      case 'minor_pentacles_06_six.png': return $r('app.media.minor_pentacles_06_six');
      case 'minor_pentacles_07_seven.png': return $r('app.media.minor_pentacles_07_seven');
      case 'minor_pentacles_08_eight.png': return $r('app.media.minor_pentacles_08_eight');
      case 'minor_pentacles_09_nine.png': return $r('app.media.minor_pentacles_09_nine');
      case 'minor_pentacles_10_ten.png': return $r('app.media.minor_pentacles_10_ten');
      case 'minor_pentacles_king.png': return $r('app.media.minor_pentacles_king');
      case 'minor_pentacles_knight.png': return $r('app.media.minor_pentacles_knight');
      case 'minor_pentacles_page.png': return $r('app.media.minor_pentacles_page');
      case 'minor_pentacles_queen.png': return $r('app.media.minor_pentacles_queen');
      case 'minor_swords_01_ace.png': return $r('app.media.minor_swords_01_ace');
      case 'minor_swords_02_two.png': return $r('app.media.minor_swords_02_two');
      case 'minor_swords_03_three.png': return $r('app.media.minor_swords_03_three');
      case 'minor_swords_04_four.png': return $r('app.media.minor_swords_04_four');
      case 'minor_swords_05_five.png': return $r('app.media.minor_swords_05_five');
      case 'minor_swords_06_six.png': return $r('app.media.minor_swords_06_six');
      case 'minor_swords_07_seven.png': return $r('app.media.minor_swords_07_seven');
      case 'minor_swords_08_eight.png': return $r('app.media.minor_swords_08_eight');
      case 'minor_swords_09_nine.png': return $r('app.media.minor_swords_09_nine');
      case 'minor_swords_10_ten.png': return $r('app.media.minor_swords_10_ten');
      case 'minor_swords_king.png': return $r('app.media.minor_swords_king');
      case 'minor_swords_knight.png': return $r('app.media.minor_swords_knight');
      case 'minor_swords_page.png': return $r('app.media.minor_swords_page');
      case 'minor_swords_queen.png': return $r('app.media.minor_swords_queen');
      case 'minor_wands_01_ace.png': return $r('app.media.minor_wands_01_ace');
      case 'minor_wands_02_two.png': return $r('app.media.minor_wands_02_two');
      case 'minor_wands_03_three.png': return $r('app.media.minor_wands_03_three');
      case 'minor_wands_04_four.png': return $r('app.media.minor_wands_04_four');
      case 'minor_wands_05_five.png': return $r('app.media.minor_wands_05_five');
      case 'minor_wands_06_six.png': return $r('app.media.minor_wands_06_six');
      case 'minor_wands_07_seven.png': return $r('app.media.minor_wands_07_seven');
      case 'minor_wands_08_eight.png': return $r('app.media.minor_wands_08_eight');
      case 'minor_wands_09_nine.png': return $r('app.media.minor_wands_09_nine');
      case 'minor_wands_10_ten.png': return $r('app.media.minor_wands_10_ten');
      case 'minor_wands_king.png': return $r('app.media.minor_wands_king');
      case 'minor_wands_knight.png': return $r('app.media.minor_wands_knight');
      case 'minor_wands_page.png': return $r('app.media.minor_wands_page');
      case 'minor_wands_queen.png': return $r('app.media.minor_wands_queen');
      default: return $r('app.media.placeholder_card');
    }
  }

  // ── 预览控制 ──
  private openPreview(): void {
    this.showImagePreview = true;
    this.previewScale = 1.0;
    this.previewOffsetX = 0;
    this.previewOffsetY = 0;
  }

  private closePreview(): void {
    this.showImagePreview = false;
    this.previewScale = 1.0;
    this.previewOffsetX = 0;
    this.previewOffsetY = 0;
  }

  private generateReading(card: TarotCard): CardReading {
    const name: string = card.nameZh;
    const keywords: string = card.keywords.join('、');
    return {
      uprightMeaning: `当${name}以正位出现时，它可能提醒你：${keywords}的力量正在你身边流动。这不一定意味着一切都顺利，而是说你可以尝试用这些品质去回应眼前的处境。`,
      reversedMeaning: `当${name}以逆位出现时，它也许在照见一种内在的拉扯——你感到${keywords}变得困难、被阻滞，或者过度使用。这不代表你失败了，只是提醒你可以停下来看看：是不是有什么在暗暗消耗你。`,
      companionReading: `这张牌不是在告诉你未来一定会怎样。它更像是一面镜子，提醒你看看自己正在经历什么。也许你最近有些疲惫，也许你正在努力维持某种平衡——无论哪种，这张牌都只是轻轻说一句：我看见了。`,
      relationHint: `在关系的层面，${name}也许在提醒你：关系中的感受同样重要。不必急着判断对错，先问问自己——在这段关系里，你还舒服吗？你被认真对待了吗？`,
      workHint: `在工作或学习中，${name}带来的提示是：也许你不需要一次解决所有问题。先看清眼前最重要的一步，然后温柔地、但坚定地往前走。`,
      selfExploration: `你可以问问自己：\n\n1. 最近有没有什么事情，让我感到${keywords}在靠近（或在远离）？\n2. 如果这张牌是一个朋友，它会对我说什么？\n3. 我现在最需要的是被看见，还是被推动？`
    };
  }

  private getSuitLabel(card: TarotCard): string {
    if (card.arcana === ArcanaType.MAJOR) {
      return '大阿尔卡那';
    }
    switch (card.suit) {
      case TarotSuit.WANDS:
        return '权杖组';
      case TarotSuit.CUPS:
        return '圣杯组';
      case TarotSuit.SWORDS:
        return '宝剑组';
      case TarotSuit.PENTACLES:
        return '星币组';
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
      // ═══════════════════════════════════════════
      // Layer 1: 背景
      // ═══════════════════════════════════════════
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      // ═══════════════════════════════════════════
      // Layer 2: 主内容
      // ═══════════════════════════════════════════
      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.TAROT_CARDS })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        .alignItems(VerticalAlign.Center)

        if (this.card && this.reading) {
          Scroll() {
            Column() {
              // ── 卡牌中图 ──
              Column() {
                Image(this.getCardImageResource(this.card!))
                  .objectFit(ImageFit.Contain)
                  .height(320)
                  .constraintSize({ maxWidth: '85%' })
                  .borderRadius(Theme.RADIUS_SM)
                  .border({ width: 1, color: Theme.GOLD_DIM, style: BorderStyle.Solid })

                // 点击提示
                Text('轻触查看大图')
                  .fontSize(11)
                  .fontColor(Theme.GOLD_DIM)
                  .margin({ top: 6 })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_SM })
              .onClick(() => {
                this.openPreview();
              })

              // ── 卡牌标题区 ──
              Column() {
                Text(this.card.nameZh)
                  .fontSize(Theme.FONT_HEADLINE)
                  .fontColor(Theme.GOLD_LIGHT)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)

                Text(this.card.nameEn)
                  .fontSize(Theme.FONT_BODY)
                  .fontColor(Theme.MOON_MUTED)
                  .textAlign(TextAlign.Center)
                  .margin({ top: Theme.SPACE_XS })

                // 类别标签
                Text(this.getSuitLabel(this.card))
                  .fontSize(12)
                  .fontColor(this.getSuitColor(this.card))
                  .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                  .border({ width: 0.5, color: this.getSuitColor(this.card), style: BorderStyle.Solid })
                  .borderRadius(12)
                  .margin({ top: Theme.SPACE_SM })

                // 关键词
                Row() {
                  ForEach(this.card.keywords, (keyword: string, ki: number) => {
                    Text(keyword)
                      .fontSize(12)
                      .fontColor(Theme.GOLD_LIGHT)
                      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                      .margin({ right: 6, top: 8 })
                  }, (_kw: string, ki: number) => 'detail_kw_' + ki.toString())
                }
                .justifyContent(FlexAlign.Center)
              }
              .width('92%')
              .alignItems(HorizontalAlign.Center)
              .margin({ top: Theme.SPACE_LG, bottom: Theme.SPACE_LG })

              // ── 正位含义 ──
              this.buildReadingSection('正位含义', this.reading.uprightMeaning, '#E8B83D')

              // ── 逆位含义 ──
              this.buildReadingSection('逆位含义', this.reading.reversedMeaning, '#8B7EC8')

              // ── 情绪陪伴式解读 ──
              this.buildReadingSection('情绪陪伴式解读', this.reading.companionReading, '#5ED7D2')

              // ── 关系提示 ──
              this.buildReadingSection('关系提示', this.reading.relationHint, '#E8A838')

              // ── 工作 / 学习提示 ──
              this.buildReadingSection('工作 / 学习提示', this.reading.workHint, '#6EB87A')

              // ── 自我探索问题 ──
              this.buildReadingSection('自我探索', this.reading.selfExploration, '#94A3B8')

              // 底部间距
              Column()
                .height(48)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        } else {
          // 加载中
          Column() {
            Text('加载中...')
              .fontSize(Theme.FONT_BODY)
              .fontColor(Theme.MOON_MUTED)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)

      // ═══════════════════════════════════════════
      // Layer 3: 全屏图片预览层（条件渲染）
      // ═══════════════════════════════════════════
      if (this.showImagePreview && this.card) {
        Column() {
          // ── 顶部栏：关闭按钮 + 标题 ──
          Row() {
            // 用 Text + onTouch 代替 Button，确保触摸事件不被手势竞争吞掉
            Text('✕')
              .fontSize(20)
              .fontColor(Theme.GOLD_LIGHT)
              .width(40)
              .height(40)
              .borderRadius(20)
              .backgroundColor('rgba(15, 15, 35, 0.85)')
              .textAlign(TextAlign.Center)
              .onTouch((_event: TouchEvent) => {
                if (_event.type === TouchType.Down) {
                  this.closePreview();
                }
              })

            Blank()

            Text(`${this.card!.nameZh} · ${this.card!.nameEn}`)
              .fontSize(13)
              .fontColor(Theme.MOON_MUTED)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .height(56)
          .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_MD, right: Theme.SPACE_MD })
          .alignItems(VerticalAlign.Center)

          // ── 可缩放拖动图片区 ──
          Stack() {
            Image(this.getCardImageResource(this.card!))
              .objectFit(ImageFit.Contain)
              .width('100%')
              .height('100%')
              .scale({ x: this.previewScale, y: this.previewScale })
              .translate({ x: this.previewOffsetX, y: this.previewOffsetY })
          }
          .width('100%')
          .layoutWeight(1)
          .gesture(
            GestureGroup(GestureMode.Parallel,
              PinchGesture({ fingers: 2, distance: 1 })
                .onActionUpdate((event: GestureEvent | undefined) => {
                  if (event) {
                    const newScale: number = Math.max(1.0, Math.min(4.0, event.scale));
                    this.previewScale = newScale;
                  }
                })
                .onActionEnd((_event: GestureEvent | undefined) => {
                  if (this.previewScale < 1.0) {
                    this.previewScale = 1.0;
                    this.previewOffsetX = 0;
                    this.previewOffsetY = 0;
                  }
                }),
              PanGesture({ fingers: 1, direction: PanDirection.All, distance: 5 })
                .onActionUpdate((event: GestureEvent | undefined) => {
                  if (event && this.previewScale > 1.0) {
                    this.previewOffsetX = event.offsetX;
                    this.previewOffsetY = event.offsetY;
                  }
                })
                .onActionEnd((_event: GestureEvent | undefined) => {
                  // 拖动结束后不做边界限制
                })
            )
          )
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(5, 7, 20, 0.96)')
        // 沉浸光感：全屏预览背景深蓝径向渐变
        .radialGradient({
          center: ['50%', '50%'],
          radius: '70%',
          colors: [
            ['rgba(20, 25, 55, 0.5)', 0.0],
            ['rgba(10, 12, 30, 0.3)', 0.5],
            ['rgba(5, 7, 20, 0.96)', 1.0]
          ]
        })
        .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }

  @Builder
  buildReadingSection(title: string, content: string, accentColor: string): void {
    Column() {
      // 标题行
      Row() {
        Text('·')
          .fontSize(18)
          .fontColor(accentColor)
          .fontWeight(FontWeight.Bold)
          .margin({ right: 6 })

        Text(title)
          .fontSize(Theme.FONT_SUBTITLE)
          .fontColor(accentColor)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .margin({ bottom: Theme.SPACE_SM })

      // 内容
      Text(content)
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_PRIMARY_LIGHT)
        .lineHeight(26)
        .width('100%')
    }
    .width('92%')
    .backgroundColor('rgba(27, 27, 48, 0.52)')
    .borderRadius(Theme.RADIUS_MD)
    .padding(Theme.SPACE_MD)
    .margin({ bottom: Theme.SPACE_SM })
  }
}

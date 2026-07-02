import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { HistoryStore } from '../common/HistoryStore';
import { DivinationHistoryRecord, DrawnCardRecord } from '../model/DivinationHistoryRecord';
import { ComplianceFooter } from '../components/ComplianceFooter';
import { AppBackButton } from '../components/AppBackButton';
import { ShareImageService, SaveImageResult } from '../service/ShareImageService';
import { TarotCardImage } from '../components/TarotCardImage';
import { SafeUiActions } from '../common/SafeUiActions';

// ===== 路由参数接口（P0.2 改造）=====
interface ShareCardRouteParams {
  sourceRecordId: string;
  spreadType: string;
}

/**
 * 分享卡生成页面（P0.2 改造）
 *
 * 支持三种牌阵布局：
 * - SINGLE：单牌 + 金句 + 关键词（现有）
 * - TRIANGLE：三列牌面 (past/present/future) + 综合解读
 * - RELATION：三列牌面 (self/other/trend) + 综合解读
 *
 * 保存图片流程：
 * 1. getUIContext().getComponentSnapshot().get(componentId) 截图
 * 2. ShareImageService.savePixelMapToGalleryWithResult 写入相册
 * 3. success && savedToAlbum 双重判断后 Toast
 */
@Entry
@Component
struct ShareCardPage {
  @State sourceRecordId: string = '';
  @State spreadType: string = 'SINGLE';
  @State record: DivinationHistoryRecord | null = null;
  @State isLoading: boolean = true;
  @State isSaving: boolean = false;

  async aboutToAppear(): Promise<void> {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params: ShareCardRouteParams = rawParams as ShareCardRouteParams;
      this.sourceRecordId = params.sourceRecordId ?? '';
      this.spreadType = params.spreadType ?? 'SINGLE';
    }

    if (this.sourceRecordId) {
      try {
        this.record = await HistoryStore.getRecordById(getContext(this), this.sourceRecordId);
      } catch (_err) {
        this.record = null;
      }
    }
    this.isLoading = false;
  }

  /**
   * 截取指定组件为 PixelMap
   *
   * 使用 UIContext.getComponentSnapshot().get()（参考 DivinationResultPage 已验证写法）
   *
   * @param componentId - 组件 id
   * @returns PixelMap，失败返回 undefined
   */
  private async captureCard(componentId: string): Promise<image.PixelMap | undefined> {
    try {
      console.info('[ShareCard] capture start, componentId=' + componentId);
      const pixelMap: image.PixelMap = await this.getUIContext().getComponentSnapshot().get(componentId, {
        scale: 2,
        waitUntilRenderFinished: true
      });
      console.info('[ShareCard] capture success');
      return pixelMap;
    } catch (err) {
      console.error('[ShareCard] capture failed: ' + JSON.stringify(err));
      return undefined;
    }
  }

  /**
   * 构建保存文件名
   *
   * @param prefix - 卡片前缀（情绪签/人设签/行动签等）
   * @returns 完整文件名
   */
  private buildFileName(prefix: string): string {
    // 文件名用纯英文，避免路径/URI 编码问题（UI 文案仍用中文）
    const prefixMap: Record<string, string> = {
      '情绪签': 'emotion',
      '人设签': 'persona',
      '行动签': 'action',
      '圣三角': 'triangle',
      '关系探索': 'relation'
    };
    const enPrefix: string = prefixMap[prefix] ?? 'card';
    return 'XingKeyTarot_' + enPrefix + '_' + Date.now() + '.png';
  }

  /**
   * 保存指定卡片到系统相册（防重复 + 真实判断）
   *
   * @param componentId - 组件 id
   * @param fileName - 保存文件名
   */
  private async saveCard(componentId: string, fileName: string): Promise<void> {
    if (this.isSaving) {
      return;
    }
    this.isSaving = true;
    try {
      const pixelMap: image.PixelMap | undefined = await this.captureCard(componentId);
      if (pixelMap === undefined) {
        console.error('[ShareCardPage] capture returned undefined, componentId=' + componentId);
        SafeUiActions.safeToast('截图失败，请稍后再试');
        this.isSaving = false;
        return;
      }
      const ctx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const result: SaveImageResult = await ShareImageService.savePixelMapToGalleryWithResult(ctx, pixelMap, fileName);
      pixelMap.release();
      if (result.success && result.savedToAlbum) {
        SafeUiActions.safeToast('图片已保存到相册');
      } else {
        console.error('[ShareCardPage] save failed stage=' + result.stage + ', code=' + result.errorCode + ', message=' + result.errorMessage);
        // 临时调试：Toast 显示 stage:errorCode，便于真机定位
        const errTip: string = result.errorCode !== ''
          ? '保存失败：' + result.stage + ':' + result.errorCode
          : '保存失败：' + result.stage;
        SafeUiActions.safeToast(errTip);
      }
    } catch (err) {
      console.error('[ShareCardPage] saveCard failed: ' + JSON.stringify(err));
      SafeUiActions.safeToast('保存失败，请稍后再试');
    } finally {
      this.isSaving = false;
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2C_BG_BASE)

      Column()
        .width('100%')
        .height(220)
        .radialGradient({
          center: ['50%', '8%'],
          radius: '74%',
          colors: [
            ['rgba(197, 160, 80, 0.045)', 0.0],
            ['rgba(197, 160, 80, 0.012)', 0.58],
            ['rgba(10, 13, 26, 0)', 1.0]
          ]
        })
        .hitTestBehavior(HitTestMode.None)

      Scroll() {
        Column() {
          Row() {
            AppBackButton({ fallbackUrl: Routes.HOME })
          }
          .width('100%')
          .padding({ top: Theme.SAFE_TOP })

          Column() {
            Text('生成分享卡')
              .fontSize(Theme.V2C_FONT_TITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .textAlign(TextAlign.Center)

            Row()
              .width(44)
              .height(1)
              .backgroundColor(Theme.V2C_GOLD_GILT)
              .opacity(0.30)
              .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_SM })

            Text('把这一页，保存成一段属于你的记录。')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .lineHeight(23)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_XL })

          if (this.isLoading) {
            LoadingProgress()
              .width(36)
              .height(36)
              .color(Theme.V2C_GOLD_GILT)
          } else if (!this.record) {
            Text('记录不存在')
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .margin({ top: 40 })
          } else {
            // 根据 spreadType 渲染不同布局
            // 注意：id 设在各卡片本体 Column 上，不设在页面根容器
            Column() {
              if (this.spreadType === 'SINGLE') {
                this.buildSingleLayout();
              } else if (this.spreadType === 'TRIANGLE') {
                this.buildTriangleLayout();
              } else if (this.spreadType === 'RELATION') {
                this.buildRelationLayout();
              }
            }
          }

          Blank()
            .height(Theme.V2_SPACE_XL)

          // ── 合规页脚：页面外壳，不进入截图目标 ──
          ComplianceFooter({
            fontSize: Theme.V2C_FONT_CAPTION,
            textColor: Theme.V2C_TEXT_SECONDARY,
            showDivider: true,
          })
        }
        .width('100%')
        .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: Theme.SAFE_BOTTOM + 28 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  // ────── SINGLE 布局 ──────

  /**
   * 单牌分享卡牌面视觉：真实卡牌图 + 牌名 + 副标题，黑金描边卡片框
   */
  @Builder
  buildSingleCardFace(): void {
    if (this.record!.cards && this.record!.cards.length > 0) {
      Column() {
        TarotCardImage({
          cardId: this.record!.cards[0]!.cardId,
          cardWidth: 118,
          cardHeight: 189
        })
          .rotate({
            angle: this.record!.cards[0]!.isReversed ? 180 : 0,
            centerX: '50%',
            centerY: '50%'
          })
        Text(this.record!.cards[0]!.cardName)
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ top: Theme.V2_SPACE_SM })
        Text(this.record!.cards[0]!.isReversed ? '逆位' : '正位')
          .fontSize(Theme.V2C_FONT_DISCLAIMER)
          .fontColor(Theme.V2C_GOLD_GILT_SOFT)
          .margin({ top: 2 })
      }
      .width(150)
      .padding({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_SM, left: Theme.V2_SPACE_SM, right: Theme.V2_SPACE_SM })
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('rgba(10, 13, 26, 0.62)')
      .borderRadius(Theme.V2_RADIUS_XL)
      .border({ width: 1, color: 'rgba(197, 160, 80, 0.20)' })
      .margin({ bottom: Theme.V2_SPACE_MD })
    }
  }

  @Builder
  buildSingleLayout(): void {
    Column({ space: Theme.SPACE_MD }) {
      // 情绪签完整海报（id 设在外层海报容器）
      Column() {
        Text('星钥之书 · 单牌记录')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ bottom: Theme.V2_SPACE_XS })
        Text('情绪签')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.V2C_GOLD_GILT)
          .margin({ bottom: Theme.V2_SPACE_SM })
        Row()
          .width(42)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.28)
          .margin({ bottom: Theme.V2_SPACE_MD })
        this.buildSingleCardFace()
        Text(this.record!.scenarioTag || '此刻心绪')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(24)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ bottom: Theme.V2_SPACE_XS })
        Text('每一种情绪都是真实自己的回声')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.V2_SPACE_MD })
        this.buildShareDisclaimer()
      }
      .width('100%')
      .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG, top: Theme.V2_SPACE_LG, bottom: Theme.V2_SPACE_LG })
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Theme.V2C_BG_CARD)
      .borderRadius(Theme.V2_RADIUS_XL)
      .border({ width: 1, color: 'rgba(197, 160, 80, 0.18)' })
      .shadow(Theme.V2C_SHADOW_CARD)
      .id('share_card_emotion')

      this.buildSaveButton('share_card_emotion', '情绪签')

      // 人设签完整海报
      Column() {
        Text('星钥之书 · 单牌记录')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ bottom: Theme.V2_SPACE_XS })
        Text('人设签')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.V2C_GOLD_GILT)
          .margin({ bottom: Theme.V2_SPACE_SM })
        Row()
          .width(42)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.28)
          .margin({ bottom: Theme.V2_SPACE_MD })
        this.buildSingleCardFace()
        Text((this.record!.cards && this.record!.cards.length > 0) ? this.record!.cards[0]!.cardName : '星钥旅人')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .width('100%')
          .margin({ bottom: Theme.V2_SPACE_XS })
        Text('这张牌映照着此刻的你')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.V2_SPACE_MD })
        this.buildShareDisclaimer()
      }
      .width('100%')
      .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG, top: Theme.V2_SPACE_LG, bottom: Theme.V2_SPACE_LG })
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Theme.V2C_BG_CARD)
      .borderRadius(Theme.V2_RADIUS_XL)
      .border({ width: 1, color: 'rgba(197, 160, 80, 0.18)' })
      .shadow(Theme.V2C_SHADOW_CARD)
      .id('share_card_persona')

      this.buildSaveButton('share_card_persona', '人设签')

      // 行动签完整海报
      Column() {
        Text('星钥之书 · 单牌记录')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ bottom: Theme.V2_SPACE_XS })
        Text('行动签')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.V2C_GOLD_GILT)
          .margin({ bottom: Theme.V2_SPACE_SM })
        Row()
          .width(42)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.28)
          .margin({ bottom: Theme.V2_SPACE_MD })
        this.buildSingleCardFace()
        Text((this.record!.cards && this.record!.cards.length > 0) ? this.record!.cards[0]!.goldenSentence : (this.record!.summaryText || '今日指引'))
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .lineHeight(24)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ bottom: Theme.V2_SPACE_XS })
        Text('带着这句话回到生活里')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.V2_SPACE_MD })
        this.buildShareDisclaimer()
      }
      .width('100%')
      .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG, top: Theme.V2_SPACE_LG, bottom: Theme.V2_SPACE_LG })
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Theme.V2C_BG_CARD)
      .borderRadius(Theme.V2_RADIUS_XL)
      .border({ width: 1, color: 'rgba(197, 160, 80, 0.18)' })
      .shadow(Theme.V2C_SHADOW_CARD)
      .id('share_card_action')

      this.buildSaveButton('share_card_action', '行动签')
    }
    .width('100%')
  }

  // ────── TRIANGLE 布局 ──────

  @Builder
  buildTriangleLayout(): void {
    Column({ space: Theme.SPACE_MD }) {
      // 圣三角完整海报（id 设在外层海报容器，包含品牌+标题+牌阵+解读+免责声明）
      Column() {
        Text('星钥之书 · 圣三角')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ bottom: Theme.V2_SPACE_XS })
        Text('三张牌，按顺序慢慢读')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.V2C_GOLD_GILT)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.V2_SPACE_SM })
        Row()
          .width(42)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.28)
          .margin({ bottom: Theme.V2_SPACE_MD })

        // 三张牌展示
        this.buildTarotCardRow(this.record!.cards)

        // 综合解读
        Text('圣三角综合解读')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.V2C_GOLD_GILT)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_XS })
        Text(this.record!.summaryText || '')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .textAlign(TextAlign.Start)
          .lineHeight(25)
          .width('100%')
          .margin({ bottom: Theme.V2_SPACE_SM })

        // 趋势提醒
        Text('圣三角不是命运预言，而是一种趋势提醒。它提示你：如果沿着现在的方式继续，接下来最需要留意什么。')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .textAlign(TextAlign.Start)
          .lineHeight(20)
          .width('100%')
          .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD, top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_SM })
          .backgroundColor('rgba(10, 13, 26, 0.36)')
          .borderRadius(Theme.V2C_RADIUS_CARD)
          .border({ width: 1, color: Theme.V2C_SPINE_LINE })
          .margin({ bottom: Theme.V2_SPACE_MD })

        this.buildShareDisclaimer()
      }
      .width('100%')
      .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG, top: Theme.V2_SPACE_LG, bottom: Theme.V2_SPACE_LG })
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Theme.V2C_BG_CARD)
      .borderRadius(Theme.V2_RADIUS_XL)
      .border({ width: 1, color: 'rgba(197, 160, 80, 0.18)' })
      .shadow(Theme.V2C_SHADOW_CARD)
      .id('share_card_triangle')

      this.buildSaveButton('share_card_triangle', '圣三角')
    }
    .width('100%')
  }

  // ────── RELATION 布局 ──────

  @Builder
  buildRelationLayout(): void {
    Column({ space: Theme.SPACE_MD }) {
      // 关系探索完整海报（id 设在外层海报容器，包含品牌+标题+牌阵+解读+边界提醒+免责声明）
      Column() {
        Text('星钥之书 · 关系探索')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
          .margin({ bottom: Theme.V2_SPACE_XS })
        Text('把关系放在一页里慢慢看')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.V2C_GOLD_GILT)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.V2_SPACE_SM })
        Row()
          .width(42)
          .height(1)
          .backgroundColor(Theme.V2C_GOLD_GILT)
          .opacity(0.28)
          .margin({ bottom: Theme.V2_SPACE_MD })

        // 三张牌展示
        this.buildRelationTarotCardRow(this.record!.cards)

        // 综合解读
        Text('关系探索综合解读')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.V2C_GOLD_GILT)
          .width('100%')
          .margin({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_XS })
        Text(this.record!.shareText || this.record!.summaryText || '')
          .fontSize(Theme.V2C_FONT_BODY)
          .fontColor(Theme.V2C_TEXT_PRIMARY)
          .textAlign(TextAlign.Start)
          .lineHeight(25)
          .width('100%')
          .margin({ bottom: Theme.V2_SPACE_SM })

        // 边界提醒
        if (this.record!.adviceText) {
          Text('边界提醒')
            .fontSize(Theme.V2C_FONT_SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.V2C_GOLD_GILT)
            .width('100%')
            .margin({ top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_XS })
          Text(this.record!.adviceText)
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(Theme.V2C_TEXT_SECONDARY)
            .textAlign(TextAlign.Start)
            .lineHeight(20)
            .width('100%')
            .padding({ left: Theme.V2_SPACE_MD, right: Theme.V2_SPACE_MD, top: Theme.V2_SPACE_SM, bottom: Theme.V2_SPACE_SM })
            .backgroundColor('rgba(10, 13, 26, 0.36)')
            .borderRadius(Theme.V2C_RADIUS_CARD)
            .border({ width: 1, color: Theme.V2C_SPINE_LINE })
            .margin({ bottom: Theme.V2_SPACE_SM })
        }

        this.buildShareDisclaimer()
      }
      .width('100%')
      .padding({ left: Theme.V2_SPACE_LG, right: Theme.V2_SPACE_LG, top: Theme.V2_SPACE_LG, bottom: Theme.V2_SPACE_LG })
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Theme.V2C_BG_CARD)
      .borderRadius(Theme.V2_RADIUS_XL)
      .border({ width: 1, color: 'rgba(197, 160, 80, 0.18)' })
      .shadow(Theme.V2C_SHADOW_CARD)
      .id('share_card_relation')

      this.buildSaveButton('share_card_relation', '关系探索')
    }
    .width('100%')
  }

  // ────── 黑金风格保存按钮（统一样式）──────

  @Builder
  buildSaveButton(cardId: string, prefix: string): void {
    Button(this.isSaving ? '保存中...' : '保存图片')
      .type(ButtonType.Normal)
      .width('100%')
      .constraintSize({ maxWidth: 340 })
      .height(54)
      .borderRadius(20)
      .backgroundColor(this.isSaving ? 'rgba(18, 24, 54, 0.55)' : 'rgba(18, 24, 54, 0.86)')
      .fontColor(this.isSaving ? Theme.V2_STATE_DISABLED_TEXT : Theme.V2C_GOLD_GILT_SOFT)
      .fontSize(Theme.V2C_FONT_BODY)
      .fontWeight(FontWeight.Medium)
      .border({ width: 1, color: this.isSaving ? Theme.V2C_SPINE_LINE : 'rgba(197, 160, 80, 0.34)' })
      .enabled(!this.isSaving)
      .margin({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_MD })
      .onClick(() => {
        this.saveCard(cardId, this.buildFileName(prefix));
      })
  }

  @Builder
  buildShareDisclaimer(): void {
    Text('结果仅供娱乐与自我探索参考，不构成任何专业建议。')
      .fontSize(Theme.V2C_FONT_CAPTION)
      .fontColor(Theme.V2C_TEXT_SECONDARY)
      .textAlign(TextAlign.Center)
      .lineHeight(19)
      .width('100%')
  }

  // ────── 三张牌横排展示 ──────

  @Builder
  buildTarotCardRow(cards: DrawnCardRecord[]): void {
    if (cards && cards.length > 0) {
      Row({ space: Theme.SPACE_SM }) {
        ForEach(cards, (cardRecord: DrawnCardRecord) => {
          Column() {
            Text(cardRecord.positionTitle)
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_GOLD_GILT)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: Theme.V2_SPACE_XS })

            TarotCardImage({
              cardId: cardRecord.cardId,
              cardWidth: Theme.CARD_SIZE_TRIO.width,
              cardHeight: Theme.CARD_SIZE_TRIO.height
            })
              .rotate({
                angle: cardRecord.isReversed ? 180 : 0,
                centerX: '50%',
                centerY: '50%'
              })

            Text(cardRecord.cardName)
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .lineHeight(18)
              .margin({ top: Theme.V2_SPACE_XS })

            Text(cardRecord.isReversed ? '逆位' : '正位')
              .fontSize(10)
              .fontColor(Theme.V2C_GOLD_GILT_SOFT)
              .margin({ top: 2 })

            Text(cardRecord.keyword)
              .fontSize(10)
              .textAlign(TextAlign.Center)
              .lineHeight(15)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .margin({ top: 2 })
          }
          .width('30%')
          .alignItems(HorizontalAlign.Center)
        }, (cardRecord: DrawnCardRecord) => cardRecord.positionKey + '_' + cardRecord.cardId)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ top: Theme.SPACE_MD, bottom: Theme.SPACE_MD })
      .backgroundColor('rgba(10, 13, 26, 0.42)')
      .borderRadius(Theme.V2C_RADIUS_CARD)
      .border({ width: 1, color: Theme.V2C_SPINE_LINE })
    }
  }

  @Builder
  buildRelationTarotCardRow(cards: DrawnCardRecord[]): void {
    if (cards && cards.length > 0) {
      Row({ space: Theme.SPACE_XS }) {
        ForEach(cards, (cardRecord: DrawnCardRecord) => {
          Column() {
            Text(cardRecord.positionTitle)
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_GOLD_GILT)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: Theme.V2_SPACE_XS })

            TarotCardImage({
              cardId: cardRecord.cardId,
              cardWidth: 86,
              cardHeight: 138
            })
              .rotate({
                angle: cardRecord.isReversed ? 180 : 0,
                centerX: '50%',
                centerY: '50%'
              })

            Text(cardRecord.cardName)
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .lineHeight(18)
              .margin({ top: Theme.V2_SPACE_XS })

            Text(cardRecord.isReversed ? '逆位' : '正位')
              .fontSize(10)
              .fontColor(Theme.V2C_GOLD_GILT_SOFT)
              .margin({ top: 2 })

            Text(cardRecord.keyword)
              .fontSize(10)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .lineHeight(15)
              .margin({ top: 2 })
          }
          .width('30%')
          .alignItems(HorizontalAlign.Center)
        }, (cardRecord: DrawnCardRecord) => cardRecord.positionKey + '_' + cardRecord.cardId)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ top: Theme.SPACE_MD, bottom: Theme.SPACE_MD })
      .backgroundColor('rgba(10, 13, 26, 0.42)')
      .borderRadius(Theme.V2C_RADIUS_CARD)
      .border({ width: 1, color: Theme.V2C_SPINE_LINE })
    }
  }

  // buildShareCard 已内联到各布局方法中，确保 .id() 绑在完整海报容器上
}

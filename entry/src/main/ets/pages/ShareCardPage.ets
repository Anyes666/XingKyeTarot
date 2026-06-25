import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { HistoryStore } from '../common/HistoryStore';
import { DivinationHistoryRecord, SpreadType, DrawnCardRecord } from '../model/DivinationHistoryRecord';
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
    Scroll() {
      Column() {
        // ── P0.3 整改：左上角统一返回按钮 ──
        Row() {
          AppBackButton({ fallbackUrl: Routes.HOME })
        }
        .width('100%')
        .padding({ top: 48 })

        // ── 标题区 ──
        Text('🌙 生成分享卡')
          .fontSize(Theme.FONT_HEADLINE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_LIGHT)
          .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_XS })

        Text('分享你的星钥时刻')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.MOON_MUTED)
          .margin({ bottom: Theme.SPACE_XL })

        if (this.isLoading) {
          LoadingProgress()
            .width(36)
            .height(36)
            .color(Theme.GOLD_AMBER)
        } else if (!this.record) {
          Text('记录不存在')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.MOON_MUTED)
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

        // ── 合规页脚 ──
        ComplianceFooter({
          fontSize: Theme.FONT_CAPTION,
          textColor: Theme.MOON_MUTED,
          showDivider: true,
        })
      }
      .width('100%')
      .padding({ left: Theme.SPACE_SCREEN_PAD, right: Theme.SPACE_SCREEN_PAD, bottom: 36 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG_DEEP_INDIGO)
    .scrollBar(BarState.Off)
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
          cardWidth: 96,
          cardHeight: 150
        })
        Text(this.record!.cards[0]!.cardName)
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD_LIGHT)
          .margin({ top: Theme.SPACE_XS })
        Text('此刻照见你的星钥')
          .fontSize(10)
          .fontColor(Theme.MOON_MUTED)
      }
      .width(120)
      .padding({ top: 10, bottom: 10, left: 8, right: 8 })
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#0F0F23')
      .borderRadius(16)
      .border({ width: 1, color: '#8B6A2B' })
      .margin({ bottom: Theme.SPACE_MD })
    }
  }

  @Builder
  buildSingleLayout(): void {
    Column({ space: Theme.SPACE_MD }) {
      // 情绪签完整海报（id 设在外层海报容器）
      Column() {
        Text('星钥塔罗 · 星澜')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD_LIGHT)
          .margin({ bottom: Theme.SPACE_XS })
        Text('✦ 情绪签')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_AMBER)
          .margin({ bottom: Theme.SPACE_MD })
        this.buildSingleCardFace()
        Text(this.record!.scenarioTag || '此刻心绪')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .textAlign(TextAlign.Center)
          .maxLines(4)
          .margin({ bottom: Theme.SPACE_XS })
        Text('每一种情绪都是真实自己的回声')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.SPACE_MD })
        Text('结果仅供娱乐与自我探索参考，不构成任何专业建议。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
      }
      .width('88%')
      .padding(Theme.SPACE_LG)
      .backgroundColor(Theme.BG_CARD_DARK)
      .borderRadius(Theme.RADIUS_MD)
      .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
      .id('share_card_emotion')

      this.buildSaveButton('share_card_emotion', '情绪签')

      // 人设签完整海报
      Column() {
        Text('星钥塔罗 · 星澜')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD_LIGHT)
          .margin({ bottom: Theme.SPACE_XS })
        Text('✦ 人设签')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_AMBER)
          .margin({ bottom: Theme.SPACE_MD })
        this.buildSingleCardFace()
        Text((this.record!.cards && this.record!.cards.length > 0) ? this.record!.cards[0]!.cardName : '星钥旅人')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.SPACE_XS })
        Text('这张牌映照着此刻的你')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.SPACE_MD })
        Text('结果仅供娱乐与自我探索参考，不构成任何专业建议。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
      }
      .width('88%')
      .padding(Theme.SPACE_LG)
      .backgroundColor(Theme.BG_CARD_DARK)
      .borderRadius(Theme.RADIUS_MD)
      .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
      .id('share_card_persona')

      this.buildSaveButton('share_card_persona', '人设签')

      // 行动签完整海报
      Column() {
        Text('星钥塔罗 · 星澜')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD_LIGHT)
          .margin({ bottom: Theme.SPACE_XS })
        Text('✦ 行动签')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_AMBER)
          .margin({ bottom: Theme.SPACE_MD })
        this.buildSingleCardFace()
        Text((this.record!.cards && this.record!.cards.length > 0) ? this.record!.cards[0]!.goldenSentence : (this.record!.summaryText || '今日指引'))
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .textAlign(TextAlign.Center)
          .maxLines(4)
          .margin({ bottom: Theme.SPACE_XS })
        Text('带着这句话回到生活里')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.SPACE_MD })
        Text('结果仅供娱乐与自我探索参考，不构成任何专业建议。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
      }
      .width('88%')
      .padding(Theme.SPACE_LG)
      .backgroundColor(Theme.BG_CARD_DARK)
      .borderRadius(Theme.RADIUS_MD)
      .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
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
        Text('星钥塔罗 · 星澜')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD_LIGHT)
          .margin({ bottom: Theme.SPACE_XS })
        Text('🔺 圣三角')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_AMBER)
          .margin({ bottom: Theme.SPACE_SM })

        // 三张牌展示
        this.buildTarotCardRow(this.record!.cards)

        // 综合解读
        Text('圣三角综合解读')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_AMBER)
          .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_XS })
        Text(this.record!.summaryText || '')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .textAlign(TextAlign.Center)
          .maxLines(6)
          .margin({ bottom: Theme.SPACE_SM })

        // 趋势提醒
        Text('圣三角不是命运预言，而是一种趋势提醒。它提示你：如果沿着现在的方式继续，接下来最需要留意什么。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .margin({ bottom: Theme.SPACE_MD })

        Text('结果仅供娱乐与自我探索参考，不构成任何专业建议。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
      }
      .width('88%')
      .padding(Theme.SPACE_LG)
      .backgroundColor(Theme.BG_CARD_DARK)
      .borderRadius(Theme.RADIUS_MD)
      .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
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
        Text('星钥塔罗 · 星澜')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.GOLD_LIGHT)
          .margin({ bottom: Theme.SPACE_XS })
        Text('💞 关系探索')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_AMBER)
          .margin({ bottom: Theme.SPACE_SM })

        // 三张牌展示
        this.buildTarotCardRow(this.record!.cards)

        // 综合解读
        Text('关系探索综合解读')
          .fontSize(Theme.FONT_SUBTITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.GOLD_AMBER)
          .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_XS })
        Text(this.record!.summaryText || '')
          .fontSize(Theme.FONT_BODY)
          .fontColor(Theme.TEXT_PRIMARY_LIGHT)
          .textAlign(TextAlign.Center)
          .maxLines(6)
          .margin({ bottom: Theme.SPACE_SM })

        // 边界提醒
        if (this.record!.adviceText) {
          Text('⚠️ 边界提醒')
            .fontSize(Theme.FONT_SUBTITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.GOLD_AMBER)
            .margin({ top: Theme.SPACE_SM, bottom: Theme.SPACE_XS })
          Text(this.record!.adviceText)
            .fontSize(Theme.FONT_CAPTION)
            .fontColor(Theme.MOON_MUTED)
            .textAlign(TextAlign.Center)
            .maxLines(6)
            .margin({ bottom: Theme.SPACE_SM })
        }

        Text('结果仅供娱乐与自我探索参考，不构成任何专业建议。')
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
      }
      .width('88%')
      .padding(Theme.SPACE_LG)
      .backgroundColor(Theme.BG_CARD_DARK)
      .borderRadius(Theme.RADIUS_MD)
      .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
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
      .width(180)
      .height(48)
      .borderRadius(24)
      .backgroundColor(Theme.GOLD_MAIN)
      .fontColor(Theme.BG_DEEP_INDIGO)
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .enabled(!this.isSaving)
      .margin({ top: 16 })
      .onClick(() => {
        this.saveCard(cardId, this.buildFileName(prefix));
      })
  }

  // ────── 三张牌横排展示 ──────

  @Builder
  buildTarotCardRow(cards: DrawnCardRecord[]): void {
    if (cards && cards.length > 0) {
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
              cardWidth: 80,
              cardHeight: 128
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
          .width('30%')
          .alignItems(HorizontalAlign.Center)
        }, (cardRecord: DrawnCardRecord) => cardRecord.positionKey + '_' + cardRecord.cardId)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ top: Theme.SPACE_MD, bottom: Theme.SPACE_MD })
      .backgroundColor(Theme.BG_CARD_DARK)
      .borderRadius(Theme.RADIUS_MD)
      .border({ width: 1, color: 'rgba(202, 138, 4, 0.12)' })
    }
  }

  // buildShareCard 已内联到各布局方法中，确保 .id() 绑在完整海报容器上
}

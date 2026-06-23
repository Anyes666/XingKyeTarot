import { wantConstant, Want } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DivinationRecord, DrawnCard } from '../model/DivinationRecord';
import { Constants } from '../common/Constants';

const TAG: string = 'ShareService';

/**
 * 分享服务
 * 生成占卜结果文本，复制到剪贴板后弹提示。
 * 当前 SDK 版本下 componentSnapshot 和 Drawing API 均不可用，
 * 文本剪贴板是最可靠的跨应用分享方式。
 */
export class ShareService {
  /**
   * 生成占卜结果分享文本，写入剪贴板并提示用户。
   */
  static async generateAndShare(record: DivinationRecord): Promise<void> {
    try {
      const text: string = ShareService.buildShareText(record);

      // 写入系统剪贴板
      const pd: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      const sysPb: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
      await sysPb.setData(pd);

      hilog.info(0x0000, TAG, 'Share text copied to clipboard');

      // 提示用户
      try {
        promptAction.showToast({
          message: '已复制分享内容，可粘贴至微信/朋友圈',
          duration: 2500
        });
      } catch (toastErr) {
        hilog.error(0x0000, TAG, 'Toast error: %{public}s', JSON.stringify(toastErr));
      }
    } catch (err) {
      hilog.error(0x0000, TAG, 'Share failed: %{public}s', JSON.stringify(err));
      throw new Error('分享失败');
    }
  }

  static async canvasFallbackAndShare(record: DivinationRecord, _name: string): Promise<void> {
    await ShareService.generateAndShare(record);
  }

  /**
   * 构建分享文本内容
   */
  private static buildShareText(record: DivinationRecord): string {
    const lines: string[] = [];
    lines.push('🔮 圣三角占卜');
    lines.push('');

    record.cards.forEach((d: DrawnCard, idx: number) => {
      const posEmoji: string = ['🌙', '✨', '🌟'][idx] ?? '🔹';
      const label: string = d.isReversed ? `${d.card.nameZh}（逆）` : d.card.nameZh;
      lines.push(`${posEmoji} 【${d.positionName}】${label}`);
      lines.push(`${d.keywords.join(' · ')}`);
      lines.push(d.interpretation);
      lines.push('');
    });

    lines.push(`— ${Constants.COMPLIANCE_FOOTER} —`);
    lines.push('来自 星钥塔罗');

    return lines.join('\n');
  }
}

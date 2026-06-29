import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Theme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { PreferenceStore } from '../data/PreferenceStore';
import { ENABLE_XINGLAN_CHAT_MVP } from '../xinglan/data/XinglanTemplates';

/**
 * 阶段6：设置页（最小化版本）
 * - 仅含"重新听听星澜的介绍"一个入口
 * - 点击后重置 7 个引导标志位，AlertDialog 反馈
 * - 返回按钮回首页
 */
@Entry
@Component
struct SettingsPage {
  @State isResetting: boolean = false;

  /**
   * 重置全部引导标志位（7 个键）
   * 重置后回首页，首页 aboutToAppear 会重新检测 hasSeenHomeGuide=false，重新播放首次引导
   */
  private async resetAllGuides(): Promise<void> {
    if (this.isResetting) {
      return;
    }
    this.isResetting = true;
    try {
      const keys: string[] = [
        'hasSeenHomeGuide',
        'hasSeenSingleGuide',
        'hasSeenTriangleGuide',
        'hasSeenRelationGuide',
        'hasSeenResultGuide',
        'hasSeenRecordGuide',
        'hasSeenDisclaimerHint'
      ];
      for (let i = 0; i < keys.length; i++) {
        await PreferenceStore.putBoolean(keys[i], false, getContext(this));
      }
      this.showResetSuccessDialog();
    } catch (err) {
      hilog.error(0x0000, 'SettingsPage', 'resetAllGuides error: %{public}s', JSON.stringify(err));
      this.showResetErrorDialog();
    } finally {
      this.isResetting = false;
    }
  }

  private showResetSuccessDialog(): void {
    try {
      this.getUIContext().showAlertDialog({
        title: '星澜准备好了',
        message: '星澜的介绍已经准备好了。回到首页时，她会重新陪你走一遍。',
        confirm: {
          value: '回到首页',
          action: () => {
            try {
              router.replaceUrl({ url: Routes.MAIN_FRAME });
            } catch (_err) {
              // ignore
            }
          }
        }
      });
    } catch (_err) {
      // ignore
    }
  }

  private showResetErrorDialog(): void {
    try {
      this.getUIContext().showAlertDialog({
        title: '出错了',
        message: '重置未完成，请稍后再试。',
        confirm: {
          value: '知道了',
          action: () => {}
        }
      });
    } catch (_err) {
      // ignore
    }
  }

  private navigateBack(): void {
    try {
      router.replaceUrl({ url: Routes.MAIN_FRAME });
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      // 主内容
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
        Text('设置')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_LG })

        // 设置项卡片：重新听听星澜的介绍
        Column() {
          Text('重新听听星澜的介绍')
            .fontSize(Theme.FONT_BODY)
            .fontColor(Theme.TEXT_PRIMARY_LIGHT)
            .width('100%')
            .padding({ top: 16, bottom: 16, left: 20, right: 20 })

          Text('星澜会重新陪你走一遍首页的第一次介绍。')
            .fontSize(13)
            .fontColor(Theme.MOON_MUTED)
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 16 })
        }
        .width('92%')
        .backgroundColor('rgba(27, 27, 48, 0.68)')
        .borderRadius(Theme.RADIUS_MD)
        .margin({ bottom: Theme.SPACE_MD })
        .onClick(() => { this.resetAllGuides(); })

        // ── 星澜聊天 · 测试入口（MVP，正式发布前可关闭）──
        if (ENABLE_XINGLAN_CHAT_MVP) {
          Column() {
            Text('🌙 星澜聊天 · 测试入口')
              .fontSize(Theme.FONT_BODY)
              .fontColor(Theme.TEXT_PRIMARY_LIGHT)
              .width('100%')
              .padding({ top: 16, bottom: 16, left: 20, right: 20 })

            Text('进入星澜离线陪伴聊天。')
              .fontSize(13)
              .fontColor(Theme.MOON_MUTED)
              .width('100%')
              .padding({ left: 20, right: 20, bottom: 16 })
          }
          .width('92%')
          .backgroundColor('rgba(27, 27, 48, 0.68)')
          .borderRadius(Theme.RADIUS_MD)
          .margin({ bottom: Theme.SPACE_MD })
          .onClick(() => {
            try {
              const options: router.RouterOptions = { url: Routes.XINGLAN_CHAT };
              router.pushUrl(options);
            } catch (_err) {
              // ignore
            }
          })
        }

        Blank()

        // 合规页脚
        Text(Constants.COMPLIANCE_FOOTER)
          .fontSize(11)
          .fontColor(Theme.MOON_MUTED)
          .textAlign(TextAlign.Center)
          .lineHeight(16)
          .width('100%')
          .padding({ left: Theme.SPACE_MD, right: Theme.SPACE_MD, bottom: 24 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }
}

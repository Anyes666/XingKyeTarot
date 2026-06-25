import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { formBindingData, formProvider } from '@kit.FormKit';
import { TarotDataService } from '../service/TarotDataService';
import { DailyFortuneService } from '../service/DailyFortuneService';
import { UserStateService } from '../service/UserStateService';
import { PreferenceStore } from '../data/PreferenceStore';
import { Routes } from '../common/Routes';
import { Constants } from '../common/Constants';

const TAG: string = 'XingKeyTarot';
const FORM_IDS_KEY: string = 'widget_form_ids';

export default class EntryAbility extends UIAbility {
  private windowStage: window.WindowStage | null = null;
  // 保存冷启动的Want，用于onWindowStageCreate中判断Widget跳转
  private savedLaunchWant: Want | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'Ability onCreate');
    // 保存启动Want用于后续页面路由判断
    this.savedLaunchWant = want;
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(0x0000, TAG, 'Ability onWindowStageCreate');
    this.windowStage = windowStage;

    const context: Context = this.context;

    // 数据初始化——统一在App入口完成，页面不再重复调用init()
    try {
      await TarotDataService.getInstance().init();
      hilog.info(0x0000, TAG, 'TarotDataService initialized');
    } catch (err) {
      hilog.error(0x0000, TAG, 'Failed to init TarotDataService: %{public}s', JSON.stringify(err));
    }

    const userId: string = await UserStateService.getUserId(context);

    // 推送数据到桌面卡片
    await this.refreshWidgetData(userId, context);

    // 检查是否从Widget冷启动跳转（onNewWant在冷启动时不会被调用）
    const startParams: Record<string, string> | undefined =
      this.savedLaunchWant?.parameters as Record<string, string> | undefined;
    const targetPage: string = startParams?.['targetPage'] ?? '';

    if (targetPage === 'dailyFortune') {
      windowStage.loadContent('pages/DailyFortunePage', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'Failed to load DailyFortunePage (cold start): %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(0x0000, TAG, 'DailyFortunePage loaded from cold start');
      });
    } else {
      // P0.2：默认启动 LaunchPage（隐私门禁判断 → 首次体验分流）
      windowStage.loadContent('pages/LaunchPage', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'Failed to load LaunchPage: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(0x0000, TAG, 'LaunchPage loaded (P0.2 entry)');
      });
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'Ability onNewWant: %{public}s', JSON.stringify(want));

    const params: Record<string, string> | undefined = want.parameters as Record<string, string> | undefined;
    const targetPage: string = params?.['targetPage'] ?? '';
    if (targetPage === 'dailyFortune') {
      if (this.windowStage) {
        this.windowStage.loadContent('pages/DailyFortunePage', (err) => {
          if (err.code) {
            hilog.error(0x0000, TAG, 'Failed to load DailyFortunePage: %{public}s', JSON.stringify(err));
          }
        });
      }
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, TAG, 'Ability onWindowStageDestroy');
    this.windowStage = null;
  }

  onForeground(): void {
    hilog.info(0x0000, TAG, 'Ability onForeground');
    this.refreshWidgetOnForeground();
  }

  onBackground(): void {
    hilog.info(0x0000, TAG, 'Ability onBackground');
  }

  private async refreshWidgetData(userId: string, context: Context): Promise<void> {
    try {
      const fortune = await DailyFortuneService.getTodayFortune(userId, context);
      const formData: Record<string, string | number> = {
        'cardName': fortune.card.nameZh,
        'cardKeyword': fortune.keyword,
        'isReversed': fortune.isReversed ? 1 : 0,
        'dateKey': fortune.dateKey
      };
      const bindingData: formBindingData.FormBindingData =
        formBindingData.createFormBindingData(formData);

      // 遍历所有已注册的formId逐一更新
      const stored: string = await PreferenceStore.getString(FORM_IDS_KEY, '[]', context);
      const formIds: string[] = JSON.parse(stored) as string[];
      const staleIds: string[] = [];

      for (const formId of formIds) {
        try {
          await formProvider.updateForm(formId, bindingData);
          hilog.info(0x0000, TAG, 'Widget updated: %{public}s', formId);
        } catch (err) {
          hilog.warn(0x0000, TAG, 'Failed to update form %{public}s, marking stale', formId);
          staleIds.push(formId);
        }
      }

      // 清理失效的formId
      if (staleIds.length > 0) {
        const validIds: string[] = formIds.filter((id: string) => !staleIds.includes(id));
        await PreferenceStore.putString(FORM_IDS_KEY, JSON.stringify(validIds), context);
        hilog.info(0x0000, TAG, 'Removed %{public}d stale formIds', staleIds.length);
      }

      hilog.info(0x0000, TAG, 'Widget refresh complete: %{public}s', fortune.card.nameZh);
    } catch (err) {
      hilog.error(0x0000, TAG, 'Failed to refresh widget: %{public}s', JSON.stringify(err));
    }
  }

  private async refreshWidgetOnForeground(): Promise<void> {
    try {
      const context: Context = this.context;
      const userId: string = await UserStateService.getUserId(context);
      await this.refreshWidgetData(userId, context);
    } catch (err) {
      hilog.error(0x0000, TAG, 'Foreground widget refresh failed: %{public}s', JSON.stringify(err));
    }
  }
}

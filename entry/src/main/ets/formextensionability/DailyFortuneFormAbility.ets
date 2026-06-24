import { formBindingData, FormExtensionAbility, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PreferenceStore } from '../data/PreferenceStore';
import { TarotDataService } from '../service/TarotDataService';
import { DailyFortuneService } from '../service/DailyFortuneService';
import { UserStateService } from '../service/UserStateService';
import { DailyFortune } from '../model/DailyFortune';

const TAG: string = 'DailyFortuneFormAbility';
const FORM_IDS_KEY: string = 'widget_form_ids';

export default class DailyFortuneFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    hilog.info(0x0000, TAG, 'onAddForm');
    const formId: string = want.parameters?.['ohos.extra.param.key.form_identity'] as string ?? '';
    // 异步持久化formId（不阻塞onAddForm返回值）
    if (formId.length > 0) {
      this.persistFormId(formId);
      this.refreshFormData(formId);
    }
    const formData: Record<string, string | number> = {
      'cardName': '加载中…',
      'cardKeyword': '请打开App刷新',
      'isReversed': 0,
      'dateKey': ''
    };
    return formBindingData.createFormBindingData(formData);
  }

  onUpdateForm(formId: string): void {
    hilog.info(0x0000, TAG, 'onUpdateForm (system scheduled): %{public}s', formId);
    this.refreshFormData(formId);
  }

  onCastToNormalForm(formId: string): void {
    hilog.info(0x0000, TAG, 'onCastToNormalForm: %{public}s', formId);
  }

  onRemoveForm(formId: string): void {
    hilog.info(0x0000, TAG, 'onRemoveForm: %{public}s', formId);
    // 移除卡片时同步清理持久化的formId
    this.removeFormId(formId);
  }

  onFormEvent(formId: string, message: string): void {
    hilog.info(0x0000, TAG, 'onFormEvent: %{public}s, %{public}s', formId, message);
  }

  private async refreshFormData(formId: string): Promise<void> {
    try {
      const ctx: Context = this.context;
      await TarotDataService.getInstance().init();
      const userId: string = await UserStateService.getUserId(ctx);
      const fortune: DailyFortune = await DailyFortuneService.getTodayFortune(userId, ctx);
      const formData: Record<string, string | number> = {
        'cardName': fortune.card.nameZh,
        'cardKeyword': fortune.keyword,
        'isReversed': fortune.isReversed ? 1 : 0,
        'dateKey': fortune.dateKey
      };
      const bindingData: formBindingData.FormBindingData =
        formBindingData.createFormBindingData(formData);
      await formProvider.updateForm(formId, bindingData);
      hilog.info(0x0000, TAG, 'Form data refreshed: %{public}s', formId);
    } catch (err) {
      hilog.error(0x0000, TAG, 'Failed to refresh form data: %{public}s', JSON.stringify(err));
    }
  }

  private async persistFormId(formId: string): Promise<void> {
    try {
      const ctx: Context = this.context;
      const existing: string = await PreferenceStore.getString(FORM_IDS_KEY, '[]', ctx);
      const ids: string[] = JSON.parse(existing) as string[];
      if (!ids.includes(formId)) {
        ids.push(formId);
        await PreferenceStore.putString(FORM_IDS_KEY, JSON.stringify(ids), ctx);
        hilog.info(0x0000, TAG, 'formId persisted: %{public}s, total: %{public}d', formId, ids.length);
      }
    } catch (err) {
      hilog.error(0x0000, TAG, 'Failed to persist formId: %{public}s', JSON.stringify(err));
    }
  }

  private async removeFormId(formId: string): Promise<void> {
    try {
      const ctx: Context = this.context;
      const existing: string = await PreferenceStore.getString(FORM_IDS_KEY, '[]', ctx);
      const ids: string[] = JSON.parse(existing) as string[];
      const filtered: string[] = ids.filter((id: string) => id !== formId);
      if (filtered.length !== ids.length) {
        await PreferenceStore.putString(FORM_IDS_KEY, JSON.stringify(filtered), ctx);
        hilog.info(0x0000, TAG, 'formId removed: %{public}s, remaining: %{public}d', formId, filtered.length);
      }
    } catch (err) {
      hilog.error(0x0000, TAG, 'Failed to remove formId: %{public}s', JSON.stringify(err));
    }
  }
}

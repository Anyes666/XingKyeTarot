import { PreferenceStore } from '../data/PreferenceStore';
import { Constants } from './Constants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'AppStateStore';

const KEY_ONBOARDING_COMPLETED: string = 'onboardingCompleted';
const KEY_ONBOARDING_COMPLETED_AT: string = 'onboardingCompletedAt';

/**
 * 应用全局状态管理
 * 封装隐私同意、首次体验标记等 Preferences 读写。
 * 所有方法 try/catch，异常返回安全默认值。
 */
export class AppStateStore {
  /**
   * 检查用户是否已同意隐私政策（v2 版本）
   */
  static async isPrivacyAccepted(context: Context): Promise<boolean> {
    try {
      return await PreferenceStore.getBoolean(
        Constants.PREF_KEY_PRIVACY_ACCEPTED_V2,
        false,
        context
      );
    } catch (err) {
      hilog.warn(0x0000, TAG, 'isPrivacyAccepted error: %{public}s', JSON.stringify(err));
      return false;
    }
  }

  /**
   * 标记隐私政策已同意，记录版本号
   */
  static async acceptPrivacy(context: Context, version: string): Promise<void> {
    try {
      await PreferenceStore.putBoolean(Constants.PREF_KEY_PRIVACY_ACCEPTED_V2, true, context);
      await PreferenceStore.putString(Constants.PREF_KEY_PRIVACY_VERSION, version, context);
    } catch (err) {
      hilog.warn(0x0000, TAG, 'acceptPrivacy error: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 获取已同意的隐私政策版本号
   */
  static async getPrivacyVersion(context: Context): Promise<string> {
    try {
      return await PreferenceStore.getString(
        Constants.PREF_KEY_PRIVACY_VERSION,
        '',
        context
      );
    } catch (err) {
      hilog.warn(0x0000, TAG, 'getPrivacyVersion error: %{public}s', JSON.stringify(err));
      return '';
    }
  }

  /**
   * 检查是否已完成首次体验
   */
  static async isFirstExperienceCompleted(context: Context): Promise<boolean> {
    try {
      return await PreferenceStore.getBoolean(
        Constants.PREF_KEY_FIRST_EXPERIENCE_COMPLETED,
        false,
        context
      );
    } catch (err) {
      hilog.warn(0x0000, TAG, 'isFirstExperienceCompleted error: %{public}s', JSON.stringify(err));
      return false;
    }
  }

  /**
   * 标记首次体验已完成
   */
  static async completeFirstExperience(context: Context): Promise<void> {
    try {
      await PreferenceStore.putBoolean(
        Constants.PREF_KEY_FIRST_EXPERIENCE_COMPLETED,
        true,
        context
      );
      await PreferenceStore.putString(
        Constants.PREF_KEY_FIRST_EXPERIENCE_COMPLETED_AT,
        String(Date.now()),
        context
      );
    } catch (err) {
      hilog.warn(0x0000, TAG, 'completeFirstExperience error: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 获取首次体验完成时间戳（毫秒），未完成返回 0
   */
  static async getFirstExperienceCompletedAt(context: Context): Promise<number> {
    try {
      const raw: string = await PreferenceStore.getString(
        Constants.PREF_KEY_FIRST_EXPERIENCE_COMPLETED_AT,
        '0',
        context
      );
      const num: number = parseInt(raw, 10);
      return isNaN(num) ? 0 : num;
    } catch (err) {
      hilog.warn(0x0000, TAG, 'getFirstExperienceCompletedAt error: %{public}s', JSON.stringify(err));
      return 0;
    }
  }

  /**
   * 检查是否已完成新手引导
   */
  static async hasCompletedOnboarding(context: Context): Promise<boolean> {
    try {
      return await PreferenceStore.getBoolean(KEY_ONBOARDING_COMPLETED, false, context);
    } catch (err) {
      hilog.warn(0x0000, TAG, 'hasCompletedOnboarding error: %{public}s', JSON.stringify(err));
      return false;
    }
  }

  /**
   * 标记新手引导已完成，记录完成时间戳
   */
  static async completeOnboarding(context: Context): Promise<void> {
    try {
      await PreferenceStore.putBoolean(KEY_ONBOARDING_COMPLETED, true, context);
      await PreferenceStore.putString(KEY_ONBOARDING_COMPLETED_AT, String(Date.now()), context);
    } catch (err) {
      hilog.warn(0x0000, TAG, 'completeOnboarding error: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 初始化（预留，后续按需扩展）
   */
  static async init(context: Context): Promise<void> {
    // no-op placeholder
  }
}

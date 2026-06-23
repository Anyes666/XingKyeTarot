import { PreferenceStore } from '../data/PreferenceStore';
import { Constants } from '../common/Constants';

/**
 * 用户状态服务
 * 封装所有 Preferences 读写操作，页面层不应直接依赖 PreferenceStore。
 */
export class UserStateService {
  /**
   * 是否已接受合规声明
   */
  static async isComplianceAccepted(context: Context): Promise<boolean> {
    return PreferenceStore.getBoolean(Constants.PREF_KEY_COMPLIANCE, false, context);
  }

  /**
   * 标记合规声明已接受
   */
  static async acceptCompliance(context: Context): Promise<void> {
    await PreferenceStore.putBoolean(Constants.PREF_KEY_COMPLIANCE, true, context);
  }

  /**
   * 是否已完成新手引导
   */
  static async isOnboardingDone(context: Context): Promise<boolean> {
    return PreferenceStore.getBoolean(Constants.PREF_KEY_ONBOARDING, false, context);
  }

  /**
   * 标记新手引导已完成
   */
  static async completeOnboarding(context: Context): Promise<void> {
    await PreferenceStore.putBoolean(Constants.PREF_KEY_ONBOARDING, true, context);
  }

  /**
   * 获取持久化用户ID，不存在时自动生成
   */
  static async getUserId(context: Context): Promise<string> {
    let userId: string = await PreferenceStore.getString(Constants.PREF_KEY_DEVICE_ID, '', context);
    if (userId.length === 0) {
      userId = `uid_${Date.now()}_${Math.random().toString(36).substring(2, 10)}`;
      await PreferenceStore.putString(Constants.PREF_KEY_DEVICE_ID, userId, context);
    }
    return userId;
  }
}

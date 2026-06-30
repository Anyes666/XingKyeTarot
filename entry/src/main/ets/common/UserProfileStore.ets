import { PreferenceStore } from '../data/PreferenceStore';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'UserProfileStore';

/**
 * 用户个人形象存储
 *
 * 使用 Preferences 持久化头像路径、昵称、等级。
 * 头像仅存储在本地设备，不上传服务器。
 *
 * 键名：
 *   user_avatar_uri    — 头像图片 URI（空字符串 = 使用默认头像）
 *   user_nickname      — 用户昵称（默认"未命名旅者"）
 *   user_level         — 星钥等级（默认"初见"）
 */
export class UserProfileStore {
  private static readonly KEY_AVATAR_URI: string = 'user_avatar_uri';
  private static readonly KEY_NICKNAME: string = 'user_nickname';
  private static readonly KEY_LEVEL: string = 'user_level';

  private static readonly DEFAULT_NICKNAME: string = '未命名旅者';
  private static readonly DEFAULT_LEVEL: string = '初见';

  // ── 头像 URI ──

  static async getAvatarUri(context: Context): Promise<string> {
    try {
      return await PreferenceStore.getString(UserProfileStore.KEY_AVATAR_URI, '', context);
    } catch (_err) {
      hilog.warn(0x0000, TAG, 'getAvatarUri failed, return empty');
      return '';
    }
  }

  static async setAvatarUri(uri: string, context: Context): Promise<void> {
    try {
      await PreferenceStore.putString(UserProfileStore.KEY_AVATAR_URI, uri, context);
    } catch (_err) {
      hilog.error(0x0000, TAG, 'setAvatarUri failed');
    }
  }

  static async clearAvatarUri(context: Context): Promise<void> {
    await UserProfileStore.setAvatarUri('', context);
  }

  // ── 昵称 ──

  static async getNickname(context: Context): Promise<string> {
    try {
      return await PreferenceStore.getString(
        UserProfileStore.KEY_NICKNAME, UserProfileStore.DEFAULT_NICKNAME, context
      );
    } catch (_err) {
      return UserProfileStore.DEFAULT_NICKNAME;
    }
  }

  static async setNickname(nickname: string, context: Context): Promise<void> {
    try {
      await PreferenceStore.putString(UserProfileStore.KEY_NICKNAME, nickname, context);
    } catch (_err) {
      hilog.error(0x0000, TAG, 'setNickname failed');
    }
  }

  // ── 等级 ──

  static async getLevel(context: Context): Promise<string> {
    try {
      return await PreferenceStore.getString(
        UserProfileStore.KEY_LEVEL, UserProfileStore.DEFAULT_LEVEL, context
      );
    } catch (_err) {
      return UserProfileStore.DEFAULT_LEVEL;
    }
  }

  static async setLevel(level: string, context: Context): Promise<void> {
    try {
      await PreferenceStore.putString(UserProfileStore.KEY_LEVEL, level, context);
    } catch (_err) {
      hilog.error(0x0000, TAG, 'setLevel failed');
    }
  }
}

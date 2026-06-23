import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';

const STORE_NAME: string = 'xingkey_tarot';

export class PreferenceStore {
  private static store: preferences.Preferences | null = null;

  /**
   * Returns the shared Preferences instance, creating it on first call.
   */
  static async getStore(context: Context): Promise<preferences.Preferences> {
    if (!PreferenceStore.store) {
      try {
        PreferenceStore.store = await preferences.getPreferences(context, STORE_NAME);
      } catch (err) {
        hilog.error(0x0000, 'PreferenceStore', 'getPreferences error: %{public}s', JSON.stringify(err));
        throw new Error(String(err));
      }
    }
    return PreferenceStore.store;
  }

  static async putString(key: string, value: string, context: Context): Promise<void> {
    try {
      const store: preferences.Preferences = await PreferenceStore.getStore(context);
      await store.put(key, value);
      await store.flush();
    } catch (err) {
      hilog.error(0x0000, 'PreferenceStore', 'putString error: %{public}s', JSON.stringify(err));
      throw new Error(String(err));
    }
  }

  static async getString(key: string, defaultValue: string, context: Context): Promise<string> {
    try {
      const store: preferences.Preferences = await PreferenceStore.getStore(context);
      return (await store.get(key, defaultValue)) as string;
    } catch (err) {
      hilog.error(0x0000, 'PreferenceStore', 'getString error: %{public}s', JSON.stringify(err));
      throw new Error(String(err));
    }
  }

  static async putBoolean(key: string, value: boolean, context: Context): Promise<void> {
    try {
      const store: preferences.Preferences = await PreferenceStore.getStore(context);
      await store.put(key, value);
      await store.flush();
    } catch (err) {
      hilog.error(0x0000, 'PreferenceStore', 'putBoolean error: %{public}s', JSON.stringify(err));
      throw new Error(String(err));
    }
  }

  static async getBoolean(key: string, defaultValue: boolean, context: Context): Promise<boolean> {
    try {
      const store: preferences.Preferences = await PreferenceStore.getStore(context);
      return (await store.get(key, defaultValue)) as boolean;
    } catch (err) {
      hilog.error(0x0000, 'PreferenceStore', 'getBoolean error: %{public}s', JSON.stringify(err));
      throw new Error(String(err));
    }
  }

  /**
   * Reset for testing — clears the cached store reference.
   */
  static reset(): void {
    PreferenceStore.store = null;
  }
}

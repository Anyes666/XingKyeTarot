import { promptAction } from '@kit.ArkUI';

/**
 * 安全 UI 操作工具类
 *
 * 对 promptAction 调用做 try-catch 包裹，
 * 避免因 UI 上下文异常导致崩溃。
 */
export class SafeUiActions {
  /**
   * 安全弹出 Toast 提示
   *
   * @param message - 提示文案
   */
  static safeToast(message: string): void {
    try {
      promptAction.showToast({ message: message, duration: 2000 });
    } catch (err) {
      console.error('SafeUiActions safeToast failed: ' + JSON.stringify(err));
    }
  }
}

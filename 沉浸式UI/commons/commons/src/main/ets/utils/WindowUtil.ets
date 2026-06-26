/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AbilityConstant, common, StartOptions, Want } from '@kit.AbilityKit';
import { display, UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { sensor } from '@kit.SensorServiceKit';

export enum ImmersiveType {
  NORMAL,
  IMMERSIVE
}

export class WindowUtil {
  public uiContext?: UIContext;
  public mainWindow: window.Window;
  public mainWindowInfo: WindowInfo = new WindowInfo();

  constructor(mainWindow: window.Window) {
    this.mainWindow = mainWindow;
  }

  public onStatusTypeChange: (statusType: window.WindowStatusType) => void = (statusType: window.WindowStatusType) => {
    this.mainWindowInfo.windowStatusType = statusType;
    this.setImmersiveType(statusType === window.WindowStatusType.MAXIMIZE || window.WindowStatusType.FLOATING ?
      ImmersiveType.IMMERSIVE : ImmersiveType.NORMAL)
  }
  // [Start window_button_rect_change]
  public onWindowButtonRectChange: (titleButtonRect: window.TitleButtonRect) => void =
    (titleButtonRect: window.TitleButtonRect) => {
      // Update the rectangle information of the title bar button.
      this.mainWindowInfo.titleButtonRect = titleButtonRect;
    }
  // [End window_button_rect_change]

  // [Start window_size_change]
  public onWindowSizeChange: (windowSize: window.Size) => void = async (windowSize: window.Size) => {
    this.mainWindowInfo.windowSize = windowSize;
    this.mainWindowInfo.widthBp = this.uiContext!.getWindowWidthBreakpoint();
    this.mainWindowInfo.heightBp = this.uiContext!.getWindowHeightBreakpoint();
  };
  // [End window_size_change]

  // [Start avoid_area_change]
  public onAvoidAreaChange: (avoidOptions: window.AvoidAreaOptions) => void =
    (avoidOptions: window.AvoidAreaOptions) => {
      if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM) {
        // Default area of the system.
        this.mainWindowInfo.avoidSystem = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_CUTOUT) {
        // Cutout area.
        this.mainWindowInfo.avoidCutout = avoidOptions.area;
        this.updateAvoidPadding(avoidOptions.area);
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_SYSTEM_GESTURE) {
        // Side return gesture area.
        this.mainWindowInfo.avoidSystemGesture = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_KEYBOARD) {
        // Fixed soft keyboard area.
        this.mainWindowInfo.avoidKeyboard = avoidOptions.area;
      } else if (avoidOptions.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        // Bottom navigation bar.
        this.mainWindowInfo.avoidNavigationIndicator = avoidOptions.area;
      }
    };

  // [End avoid_area_change]

  // [Start update_avoid_padding]
  updateAvoidPadding(area: window.AvoidArea) {
    const avoidAreaPadding: Padding = {};
    try {
      // Top cutout area: set top padding.
      if (area.topRect.height > 0) {
        avoidAreaPadding.top = this.uiContext?.px2vp(area.topRect.height + area.topRect.top);
      }
      // Left cutout area: set left padding.
      if (area.leftRect.width > 0) {
        avoidAreaPadding.left = this.uiContext?.px2vp(area.leftRect.left + area.leftRect.width);
      }
      // Right cutout area: set right padding.
      if (area.rightRect.width > 0) {
        avoidAreaPadding.right = this.uiContext?.px2vp(display.getDefaultDisplaySync().width - area.rightRect.left);
      }
      // Bottom cutout area: set bottom padding.
      if (area.bottomRect.height > 0) {
        avoidAreaPadding.bottom = this.uiContext?.px2vp(display.getDefaultDisplaySync().height - area.bottomRect.top);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to set avoid padding. Code: ${err.code}, message: ${err.message}`);
    }
    this.mainWindowInfo.avoidAreaPadding = avoidAreaPadding;
  }

  // [End update_avoid_padding]

  setImmersiveType(type: ImmersiveType) {
    try {
      if (type === ImmersiveType.NORMAL) {
        this.mainWindow.setWindowDecorVisible(true);
        this.release();
      } else if (type === ImmersiveType.IMMERSIVE) {
        // [Start set_window_decor_visible]
        this.mainWindow.setWindowDecorVisible(false);
        // [End set_window_decor_visible]

        // [Start set_window_decor_height]
        this.mainWindow.setWindowDecorHeight(56);
        // [End set_window_decor_height]

        // [Start set_window_decor_button_style]
        this.mainWindow.setDecorButtonStyle({ buttonIconSize: 24 });
        // [End set_window_decor_button_style]
        this.recover();
      }
      this.mainWindowInfo.isImmersive = type;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to set immersive type. Code: ${err.code}, message: ${err.message}`);
    }
  }

  setUIContext() {
    try {
      this.uiContext = this.mainWindow.getUIContext();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to set UI context. Code: ${err.code}, message: ${err.message}`);
    }
  }

  setSystemBarEnabled(isVisible: boolean): void {
    if (isVisible) {
      this.mainWindow.setWindowSystemBarEnable(['status', 'navigation']).catch((error: BusinessError) => {
        let err = error as BusinessError;
        hilog.error(0x0000, 'testLog', `setWindowSystemBarEnable failed. Code:${err.code}, message:${err.message}`);
      });
    } else {
      // [Start set_window_system_bar_enable]
      // Hide the status bar and navigation bar.
      this.mainWindow.setWindowSystemBarEnable([]).catch((error: BusinessError) => {
        let err = error as BusinessError;
        hilog.error(0x0000, 'testLog', `setWindowSystemBarEnable failed. Code:${err.code}, message:${err.message}`);
      });
      // [End set_window_system_bar_enable]
    }
  }

  recover(): void {
    try {
      if (this.mainWindow.getWindowStatus() === window.WindowStatusType.FULL_SCREEN) {
        this.mainWindow.recover()
          .then(() => {
            hilog.info(0x0000, 'testLog', `Succeeded in revocering the window.`);
          })
          .catch((err: BusinessError) => {
            hilog.error(0x0000, 'testLog', `Failed to revocer the window. Code: ${err.code}, message: ${err.message}`);
          });
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to recover. Code: ${err.code}, message: ${err.message}`);
    }
  }

  setWindowOrientation(orientation: window.Orientation): void {
    this.mainWindow.setPreferredOrientation(orientation)
      .then(() => {
        hilog.info(0x0000, 'testLog', `Succeeded in setting window orientation.`);
        // Update window orientation.
        this.mainWindowInfo.orientation = orientation;
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testLog', `Failed to set window orientation. Code: ${err.code}, message: ${err.message}`);
      });
  }

  updateWindowInfo(): void {
    try {
      this.mainWindowInfo.windowStatusType = this.mainWindow.getWindowStatus();
      let width: number = this.mainWindow.getWindowProperties().windowRect.width;
      let height: number = this.mainWindow.getWindowProperties().windowRect.height;
      let windowSize: window.Size = {
        width: width,
        height: height
      }
      this.mainWindowInfo.windowSize = windowSize;
      this.mainWindowInfo.widthBp = this.uiContext!.getWindowWidthBreakpoint();
      this.mainWindowInfo.heightBp = this.uiContext!.getWindowHeightBreakpoint();
      this.mainWindow.on('windowSizeChange', this.onWindowSizeChange);
      // [Start get_window_avoid_area]
      // Get the avoid area.
      this.mainWindowInfo.avoidSystem = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      // [End get_window_avoid_area]
      this.mainWindowInfo.avoidNavigationIndicator =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.mainWindowInfo.avoidCutout = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
      this.mainWindowInfo.avoidSystemGesture =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM_GESTURE);
      this.mainWindowInfo.avoidKeyboard = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD);
      // [Start on_avoid_area_change]
      this.mainWindow.on('avoidAreaChange', this.onAvoidAreaChange);
      // [End on_avoid_area_change]

      // [Start get_title_button_rect]
      // Get the rectangle that holds the minimize, maximize, and close buttons on the title bar.
      this.mainWindowInfo.titleButtonRect = this.mainWindow.getTitleButtonRect();
      // [End get_title_button_rect]
      // [Start on_title_button_rect_change]
      this.mainWindow.on('windowTitleButtonRectChange', this.onWindowButtonRectChange);
      // [End on_title_button_rect_change]
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, `TestLog`, `Failed to update window info. Code: ${err.code}, message: ${err.message}`);
    }
  }

  startWindowStatusListener(): void {
    try {
      this.mainWindow.on('windowStatusChange', this.onStatusTypeChange);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, `TestLog`, `Failed to update window status. Code: ${err.code}, message: ${err.message}`);
    }
  }

  release(): void {
    try {
      this.mainWindow.off('windowStatusChange');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to off. Code: ${err.code}, message: ${err.message}`);
    }
  }

  setSplitScreen(bundleName: string, abilityName: string, moduleName: string): void {
    let context = this.uiContext?.getHostContext() as common.UIAbilityContext;
    let option: StartOptions = { windowMode: AbilityConstant.WindowMode.WINDOW_MODE_SPLIT_PRIMARY };
    let want: Want = { bundleName: bundleName, abilityName: abilityName, moduleName: moduleName };
    context.startAbility(want, option).catch((err: BusinessError) => {
      hilog.error(0x0000, 'TestLog', `Failed to start ability. Code: ${err.code}, message: ${err.message}`);
    });
  }

  cancelSplitScreen(): void {
    let context = this.uiContext?.getHostContext() as common.UIAbilityContext;
    context.terminateSelf().catch((err: BusinessError) => {
      hilog.error(0x0000, 'TestLog', `Failed to terminate self. Code: ${err.code}, message: ${err.message}`);
    });
  }

  setWindowLimits(maxWidth: number, maxHeight: number, minWidth: number, minHeight: number): void {
    let windowLimits: window.WindowLimits = {
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      minWidth: minWidth,
      minHeight: minHeight
    }
    this.mainWindow.setWindowLimits(windowLimits).then((data: window.WindowLimits) => {
      hilog.info(0x0000, 'testLog', `Succeeded in changing the window limits. Cause: ${JSON.stringify(data)}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testLog',
        `Failed to change the window limits. Cause code: ${err.code}, message: ${err.message}`);
    });
  }

  resize(width: number, height: number): void {
    this.mainWindow.resize(width, height, (err: BusinessError) => {
      const errCode: number = err.code;
      if (errCode) {
        hilog.error(0x0000, 'testLog',
          `Failed to change the window size. Cause code: ${err.code}, message: ${err.message}`);
        return;
      }
      hilog.info(0x0000, 'testLog', 'Succeeded in changing the window size.');
    });
  }

  queryOrientationByResourceManager(): void {
    // [Start queryByByRM]
    let info: resourceManager.Direction | undefined =
      this.uiContext?.getHostContext()?.resourceManager.getConfigurationSync().direction;
    hilog.info(0x0000, 'testLog', `The Orientation is ${info}`);
    // [End queryByByRM]
  }

  queryDegree(): void {
    try {
      sensor.on(sensor.SensorId.GRAVITY, (data: sensor.GravityResponse) => {
        this.getCalDegree(data.x, data.y, data.z);
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to query degree. Code: ${err.code}, message: ${err.message}`);
    }
  }

  getCalDegree(x: number, y: number, z: number): number {
    let degree: number = 0;
    // three is Effective Delta Angle Threshold Coefficient.
    if ((x * x + y * y) * 3 < z * z) {
      return degree;
    }
    degree = 90 - (Number)(Math.round(Math.atan2(y, -x) / Math.PI * 180));
    return degree >= 0 ? degree % 360 : degree % 360 + 360;
  }
}

@Observed
export class WindowInfo {
  // Window status.
  public windowStatusType: window.WindowStatusType = window.WindowStatusType.UNDEFINED;
  // Is the window an immersive layout.
  public isImmersive: ImmersiveType = ImmersiveType.NORMAL;
  // Window orientation.
  public orientation: window.Orientation = window.Orientation.UNSPECIFIED;
  // Window size.
  public windowSize: window.Size = { width: 0, height: 0 };
  // Width/height breakpoint.
  public widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_XS;
  public heightBp: HeightBreakpoint = HeightBreakpoint.HEIGHT_SM;
  // Avoid area infos.
  public avoidSystem?: window.AvoidArea;
  public avoidNavigationIndicator?: window.AvoidArea;
  public avoidCutout?: window.AvoidArea;
  public avoidSystemGesture?: window.AvoidArea;
  public avoidKeyboard?: window.AvoidArea;
  public titleButtonRect?: window.TitleButtonRect;
  public statusBarMargin: number = 0;
  public avoidAreaPadding: Padding = {};
}

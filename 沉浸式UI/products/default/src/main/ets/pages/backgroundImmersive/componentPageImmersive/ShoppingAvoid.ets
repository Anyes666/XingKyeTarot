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

import { WindowUtil } from 'commons';
import { Home } from 'shopping';

@Component
export struct ShoppingAvoid {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;

  build() {
    NavDestination() {
      // [Start set_padding]
      // [Start set_ignore_layout]
      Column() {
        // [StartExclude set_padding]
        // [StartExclude set_ignore_layout]
        Home()
        // [EndExclude set_ignore_layout]
        // [EndExclude set_padding]
      }
      // [StartExclude set_padding]
      // Expands the layout safe area of a component.
      .ignoreLayoutSafeArea()
      .height(LayoutPolicy.matchParent)
      // [EndExclude set_padding]
      // [End set_ignore_layout]
      // Set the top and bottom padding to avoid status bar and navigation bar.
      .padding({
        top: this.windowUtil?.mainWindowInfo.avoidSystem?.topRect.height + 'px',
        bottom: this.windowUtil?.mainWindowInfo.avoidNavigationIndicator?.bottomRect.height + 'px'
      })
      // [End set_padding]
      .backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
  }
}
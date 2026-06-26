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

import { CommonConstants, WindowInfo, WindowUtil } from 'commons';
import { Content, Footer, Header } from 'minigame';

@Component
export struct MiniGame {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @State mainWindowInfo: WindowInfo | undefined = this.windowUtil?.mainWindowInfo

  onShown(): void {
    this.windowUtil?.setSystemBarEnabled(false);
  }

  onHidden(): void {
    this.windowUtil?.setSystemBarEnabled(true);
  }

  build() {
    NavDestination() {
      // [Start set_ignore_layout]
      // [Start set_padding]
      Column() {
        // [StartExclude set_ignore_layout]
        // [StartExclude set_padding]
        Header()
        Content({
          mainWindowInfo: this.windowUtil?.mainWindowInfo
        })
        Footer()
        // [EndExclude set_padding]
        // [EndExclude set_ignore_layout]
      }
      // [StartExclude set_padding]
      // Expands the layout safe area of a component.
      .ignoreLayoutSafeArea()
      .height(LayoutPolicy.matchParent)
      // [End set_ignore_layout]
      .width(CommonConstants.FULL_PERCENT)
      .backgroundImage($r('app.media.game_background'))
      .backgroundImageSize(ImageSize.FILL)
      // [EndExclude set_padding]
      // Set paddings to avoid notch.
      .padding(this.mainWindowInfo?.avoidAreaPadding)
      // [End set_padding]
    }
    .hideTitleBar(true)
    .onShown(() => this.onShown())
    .onHidden(() => this.onHidden())
  }
}

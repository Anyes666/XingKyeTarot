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

import { ImmersiveType, WindowUtil } from 'commons';
import { Home } from 'shopping';

@Component
export struct ShoppingFullScreen {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;

  onShown(): void {
    this.windowUtil?.setImmersiveType(ImmersiveType.IMMERSIVE);
    this.windowUtil?.startWindowStatusListener();
  }

  onHidden(): void {
    this.windowUtil?.setImmersiveType(ImmersiveType.NORMAL);
    this.windowUtil?.release();
  }

  build() {
    NavDestination() {
      Column() {
        Home()
      }
      .background('#F1F3F5')
    }
    .hideTitleBar(true)
    .onShown(() => this.onShown())
    .onHidden(() => this.onHidden())
  }
}
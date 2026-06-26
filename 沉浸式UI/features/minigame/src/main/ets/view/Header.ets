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

import { CommonConstants } from 'commons';

@Component
export struct Header {
  build() {
    Row() {
      Image($r('app.media.game_props'))
        .width($r('app.float.props_width'))
      Blank()
      Image($r('app.media.game_pause'))
        .width($r('app.float.pause_width'))
    }
    .padding($r('app.float.game_common_padding'))
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(VerticalAlign.Top)
  }
}

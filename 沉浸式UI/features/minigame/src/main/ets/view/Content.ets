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

import { BreakpointType, CommonConstants, WindowInfo } from 'commons';

@Component
export struct Content {
  @ObjectLink mainWindowInfo: WindowInfo;

  build() {
    Column() {
      Grid() {
        ForEach(this.getBirdImages(60), (image: Resource) => {
          GridItem() {
            Image(image)
              .width(CommonConstants.FULL_PERCENT)
              .height(CommonConstants.FULL_PERCENT)
          }
          .aspectRatio(1)
          .backgroundColor($r('app.color.grid_bg_color'))
          .borderColor($r('app.color.grid_border_color'))
          .borderWidth(2)
          .borderRadius(4)
          .padding(10)
          .margin(5)
        }, (image: Resource, index) => JSON.stringify(image) + index)
      }
      .scrollBar(BarState.Off)
      .columnsTemplate('1fr '.repeat(new BreakpointType(4, 5, 8,
        10).getValue(this.mainWindowInfo.widthBp)))
    }
    .layoutWeight(1)
    .padding({
      left: $r('app.float.game_common_padding'),
      right: $r('app.float.game_common_padding')
    })
  }

  getBirdImages(count: number) {
    const colors = ['blue', 'green', 'purple', 'red', 'white', 'yellow'];
    return Array.from({ length: count }, (_: undefined, index) => {
      const color: string = colors[index % colors.length];
      let res = `app.media.game_bird_${color}`
      return $r(res);
    });
  }
}

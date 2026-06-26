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

import { CommonConstants, WindowInfo } from 'commons';
import { HomeConstants } from '../constants/HomeConstants';
import { Categories } from './Categories';
import { FlashSale } from './FlashSale';
import { Header } from './Header';
import { Recommend } from './Recommend';
import { Selection } from './Selection';
import { Welfare } from './Welfare';

@Component
export struct HomeContent {
  @ObjectLink mainWindowInfo: WindowInfo;
  private scroller: Scroller = new Scroller();

  build() {
    Column() {
      Header({
        mainWindowInfo: this.mainWindowInfo
      })

      Scroll(this.scroller) {
        Column() {
          Categories({
            mainWindowInfo: this.mainWindowInfo
          })
          Recommend({
            mainWindowInfo: this.mainWindowInfo
          })
          Welfare({
            mainWindowInfo: this.mainWindowInfo
          })
          Selection({
            mainWindowInfo: this.mainWindowInfo
          })
          FlashSale({
            mainWindowInfo: this.mainWindowInfo
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Start)
        .padding({ right: HomeConstants.PAGE_COL_PADDING.getValue(this.mainWindowInfo.widthBp) })
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .padding({
      left: HomeConstants.PAGE_COL_PADDING.getValue(this.mainWindowInfo.widthBp),
    })
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}
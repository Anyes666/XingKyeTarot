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
import { HomeConstants } from '../constants/HomeConstants';
import { RecommendProduct } from '../model/RecommendModel';
import { RecommendProductViewModel } from '../viewmodel/RecommendViewModel';

@Component
export struct Recommend {
  @ObjectLink mainWindowInfo: WindowInfo;
  private recommendProducts: RecommendProduct[] = new RecommendProductViewModel().getRecommendProductList();

  build() {
    Swiper() {
      ForEach(this.recommendProducts, (item: RecommendProduct) => {
        Stack() {
          Image(item.getImage())
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)

          if (item.getIsLive()) {
            Image($r('app.media.icon_is_living'))
              .width($r('app.float.common_image_size'))
              .height($r('app.float.common_image_size'))
              .margin({
                top: $r('app.float.section_live_margin'),
                right: $r('app.float.section_live_margin')
              })
          }
        }
        .alignContent(Alignment.TopEnd)
        .aspectRatio(1)
      }, (item: Resource, index: number) => JSON.stringify(item) + index)
    }
    .displayCount(new BreakpointType(2, 3, 4, 5)
      .getValue(this.mainWindowInfo.widthBp))
    .itemSpace(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD ?
      HomeConstants.RECOMMENDED_PRODUCT_ITEM_SPACES[1] : HomeConstants.RECOMMENDED_PRODUCT_ITEM_SPACES[0])
    .margin({
      top: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? $r('app.float.recommend_swiper_top_sm') : 0,
      bottom: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD ?
        $r('app.float.recommend_swiper_bottom_md') : $r('app.float.recommend_swiper_bottom')
    })
    .indicator(false)
  }
}
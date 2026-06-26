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
import { SectionProduct } from '../model/SectionModel';
import { SectionViewModel } from '../viewmodel/SectionViewModel';
import { ProductComments, ProductFeature, ProductInfo, ProductPrice, ProductTitle, TitleView } from './CommonView';

@Component
export struct Selection {
  @ObjectLink mainWindowInfo: WindowInfo;
  private sectionViewModel: SectionViewModel = new SectionViewModel();

  build() {
    Column() {
      TitleView({ titleText: $r('app.string.home_titles2') })

      GridRow({
        columns: {
          sm: 4,
          md: 12,
          lg: 15,
          xl: 15,
        },
        gutter: new BreakpointType($r('app.float.section_gutter_sm'), $r('app.float.section_gutter_md'),
          $r('app.float.section_gutter_lg'), $r('app.float.section_gutter_lg')).getValue(this.mainWindowInfo.widthBp)
      }) {
        ForEach(this.sectionViewModel.getSectionProductList(new BreakpointType(2, 3, 5,
          5).getValue(this.mainWindowInfo.widthBp)), (item: SectionProduct, index: number) => {
          GridCol({
            span: {
              sm: 2,
              md: 4,
              lg: 3,
              xl: 3,
            }
          }) {
            Column() {
              Stack() {
                Image(item.getProductImg())
                  .objectFit(ImageFit.Contain)
                  .aspectRatio(1.29)
                  .width(CommonConstants.FULL_PERCENT)
                  .height(CommonConstants.FULL_PERCENT)

                if (index === 1) {
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
              .width(CommonConstants.FULL_PERCENT)
              .margin({
                bottom: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ?
                  $r('app.float.section_image_margin_sm') : $r('app.float.section_image_margin')
              })

              ProductTitle({ title: item.getTitle() })
              ProductInfo({ info: item.getInfo() })
              ProductFeature({ feature: item.getFeature() })
              ProductPrice({ price: item.getPrice() })
              ProductComments({ comments: item.getComments() })
            }
            .width(CommonConstants.FULL_PERCENT)
          }
          .width(CommonConstants.FULL_PERCENT)
        }, (item: SectionProduct, index: number) => index + JSON.stringify(item))
      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(HomeConstants.BORDER_RADIUS_LIST[2])
    .backgroundColor(Color.White)
    .margin({
      top: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD ? $r('app.float.section_margin_md') :
        $r('app.float.section_margin')
    })
  }
}
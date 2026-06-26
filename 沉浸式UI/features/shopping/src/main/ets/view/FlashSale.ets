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
import { HomeButton, ProductFeature, ProductInfo, ProductPrice, ProductTitle, TitleView } from './CommonView';

@Component
export struct FlashSale {
  @ObjectLink mainWindowInfo: WindowInfo;
  private sectionViewModel: SectionViewModel = new SectionViewModel();

  build() {
    Column() {
      TitleView({ titleText: $r('app.string.home_titles3') })

      GridRow({
        columns: {
          sm: 4,
          md: 8,
          lg: 12,
          xl: 12
        },
        gutter: {
          x: new BreakpointType($r('app.float.flash_grid_gutter_x_sm'), $r('app.float.flash_grid_gutter_x_md'),
            $r('app.float.flash_grid_gutter_x_lg'),
            $r('app.float.flash_grid_gutter_x_lg')).getValue(this.mainWindowInfo.widthBp),
          y: $r('app.float.flash_grid_gutter_y')
        }
      }) {
        ForEach(this.sectionViewModel.getFlashSaleProductList(new BreakpointType(2, 4, 6,
          6).getValue(this.mainWindowInfo.widthBp)), (item: SectionProduct) => {
          GridCol({
            span: 4
          }) {
            Row() {
              Image(item.getProductImg())
                .width(100)
                .aspectRatio(1)

              Column() {
                ProductTitle({ title: item.getTitle(), isCenter: false })
                ProductInfo({ info: item.getInfo() })
                ProductFeature({ feature: item.getFeature() })
                Blank()
                ProductPrice({ price: item.getPrice(), originalPrice: item.getOriginalPrice() })
                HomeButton({ buttonText: $r('app.string.button_texts2') })
                  .margin({
                    top: $r('app.float.flash_button_top'),
                    bottom: $r('app.float.flash_button_bottom'),
                    right: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ||
                      this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XL ?
                      $r('app.float.flash_button_right_lg') : $r('app.float.flash_button_right')
                  })
                  .alignSelf(ItemAlign.End)
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: $r('app.float.flash_row_margin') })
              .layoutWeight(1)
            }
            .width(CommonConstants.FULL_PERCENT)
          }
        }, (item: SectionProduct, index: number) => index + JSON.stringify(item))
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(HomeConstants.BORDER_RADIUS_LIST[2])
    .backgroundColor(Color.White)
    .margin({
      top: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ||
        this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XL ? $r('app.float.flash_sale_margin_lg') :
        $r('app.float.flash_sale_margin'),
      bottom: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ||
        this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XL ? $r('app.float.flash_sale_margin_lg') :
        $r('app.float.flash_sale_margin')
    })
  }
}
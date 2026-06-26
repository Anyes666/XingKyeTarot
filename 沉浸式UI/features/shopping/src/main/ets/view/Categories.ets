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
import { IconInfo } from '../model/IconInfoModel';
import { IconInfoViewModel } from '../viewmodel/IconInfoViewModel';

@Component
export struct Categories {
  @ObjectLink mainWindowInfo: WindowInfo;
  @State isNextCategory: boolean = false;
  private categoryList: IconInfo[] = new IconInfoViewModel().getCategoryList();

  build() {
    Column() {
      List({
        space: new BreakpointType(HomeConstants.CATEGORY_LIST_SPACES[0], HomeConstants.CATEGORY_LIST_SPACES[1],
          HomeConstants.CATEGORY_LIST_SPACES[2],
          HomeConstants.CATEGORY_LIST_SPACES[3]).getValue(this.mainWindowInfo.widthBp)
      }) {
        ForEach(this.categoryList, (item: IconInfo) => {
          ListItem() {
            Column() {
              Image(item.getIcon())
                .height(new BreakpointType($r('app.float.category_img_size_sm'), $r('app.float.category_img_size_md'),
                  $r('app.float.category_img_size_lg'),
                  $r('app.float.category_img_size_xl')).getValue(this.mainWindowInfo.widthBp))
              Text(item.getInfo())
                .fontSize($r('app.float.category_text_font'))
                .fontWeight(FontWeight.Normal)
                .lineHeight($r('app.float.category_text_line'))
            }
          }
          .width(new BreakpointType(HomeConstants.CATEGORY_LIST_ITEM_WIDTHS[0],
            HomeConstants.CATEGORY_LIST_ITEM_WIDTHS[1], HomeConstants.CATEGORY_LIST_ITEM_WIDTHS[2],
            HomeConstants.CATEGORY_LIST_ITEM_WIDTHS[3]).getValue(this.mainWindowInfo.widthBp))
          .height(new BreakpointType($r('app.float.category_item_height_sm'), $r('app.float.category_item_height_md'),
            $r('app.float.category_item_height_lg'),
            $r('app.float.category_item_height_xl')).getValue(this.mainWindowInfo.widthBp))
        }, (item: IconInfo, index: number) => JSON.stringify(item) + index)
      }
      .lanes(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? 2 : 1,
        $r('app.float.category_lanes_gutter'))
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .width(CommonConstants.FULL_PERCENT)
      .height(new BreakpointType($r('app.float.category_list_height_sm'), $r('app.float.category_list_height_md'),
        $r('app.float.category_list_height_lg'),
        $r('app.float.category_list_height_lg')).getValue(this.mainWindowInfo.widthBp))
      .onScrollIndex((start: number, end: number) => {
        if (end === HomeConstants.NINE) {
          this.isNextCategory = true;
        }
        if (start === 0) {
          this.isNextCategory = false;
        }
      })

      if (this.mainWindowInfo.widthBp !== WidthBreakpoint.WIDTH_SM &&
        this.mainWindowInfo.widthBp !== WidthBreakpoint.WIDTH_XL) {
        Row() {
          Divider()
            .color(this.isNextCategory ? $r('app.color.categories_divider_color_selected') :
              $r('app.color.categories_divider_color'))
            .width($r('app.float.category_divider_width'))
            .strokeWidth(HomeConstants.CATEGORY_DIVIDER_STROKE_WIDTH)
            .lineCap(LineCapStyle.Round)
          Divider()
            .color(this.isNextCategory ? $r('app.color.categories_divider_color') :
              $r('app.color.categories_divider_color_selected'))
            .width($r('app.float.category_divider_width'))
            .strokeWidth(HomeConstants.CATEGORY_DIVIDER_STROKE_WIDTH)
            .lineCap(LineCapStyle.Round)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.category_divider_row_height'))
        .justifyContent(FlexAlign.Center)
        .margin({ right: HomeConstants.PAGE_COL_PADDING.getValue(this.mainWindowInfo.widthBp) })
      }
    }
    .height(new BreakpointType($r('app.float.category_col_height_sm'), $r('app.float.category_col_height_md'),
      $r('app.float.category_col_height_lg'),
      $r('app.float.category_col_height_lg')).getValue(this.mainWindowInfo.widthBp))
    .width(CommonConstants.FULL_PERCENT)
    .margin({
      top: this.mainWindowInfo.widthBp !== WidthBreakpoint.WIDTH_SM ? $r('app.float.category_col_margin') : 0,
    })
  }
}
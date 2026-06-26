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
import { HomeButton } from './CommonView';

@Component
export struct Welfare {
  @ObjectLink mainWindowInfo: WindowInfo;
  private iconInfoViewModel = new IconInfoViewModel();

  build() {
    Column() {
      Row() {
        Text($r('app.string.home_titles1'))
          .fontSize($r('app.float.title_font'))
          .lineHeight($r('app.float.title_line'))
          .fontWeight(CommonConstants.FONT_WEIGHT_500)

        Blank()

        HomeButton({ buttonText: $r('app.string.button_texts1') })
      }
      .justifyContent(FlexAlign.Start)
      .height($r('app.float.title_height'))
      .width(CommonConstants.FULL_PERCENT)

      Row() {
        ForEach(this.iconInfoViewModel.getWelfareList(new BreakpointType(3, 6, 8,
          8).getValue(this.mainWindowInfo.widthBp)), (item: IconInfo) => {
          Column() {
            Image(item.getIcon())
              .width(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ?
                $r('app.float.welfare_image_size_sm') : $r('app.float.welfare_image_size'))
              .height(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ?
                $r('app.float.welfare_image_size_sm') : $r('app.float.welfare_image_size'))
            Text($r('app.string.tip_texts1'))
              .fontSize($r('app.float.welfare_tip_font'))
              .fontWeight(FontWeight.Normal)
              .lineHeight($r('app.float.welfare_tip_line'))
              .width($r('app.float.welfare_tip_width'))
              .borderRadius(HomeConstants.BORDER_RADIUS_LIST[1])
              .backgroundColor($r('app.color.welfare_tip_background'))
              .textAlign(TextAlign.Center)
            Text(item.getInfo())
              .fontSize($r('app.float.welfare_info_font'))
              .lineHeight($r('app.float.welfare_info_line'))
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .margin({ top: $r('app.float.welfare_info_margin') })
          }
          .height(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)
          .backgroundColor(Color.White)
        }, (item: IconInfo, index: number) => index + JSON.stringify(item))
      }
      .height(new BreakpointType($r('app.float.welfare_row_height_sm'), $r('app.float.welfare_row_height_md'),
        $r('app.float.welfare_row_height_lg'),
        $r('app.float.welfare_row_height_lg')).getValue(this.mainWindowInfo.widthBp))
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius(HomeConstants.BORDER_RADIUS_LIST[2])
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: new BreakpointType($r('app.float.welfare_row_padding_sm'), $r('app.float.welfare_row_padding_md'),
          $r('app.float.welfare_row_padding_lg'),
          $r('app.float.welfare_row_padding_lg')).getValue(this.mainWindowInfo.widthBp),
        right: new BreakpointType($r('app.float.welfare_row_padding_sm'), $r('app.float.welfare_row_padding_md'),
          $r('app.float.welfare_row_padding_lg'),
          $r('app.float.welfare_row_padding_lg')).getValue(this.mainWindowInfo.widthBp)
      })
    }
    .height(new BreakpointType($r('app.float.welfare_col_height_sm'), $r('app.float.welfare_col_height_md'),
      $r('app.float.welfare_col_height_lg'),
      $r('app.float.welfare_col_height_lg')).getValue(this.mainWindowInfo.widthBp))
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: $r('app.float.welfare_col_padding'),
      right: $r('app.float.welfare_col_padding')
    })
    .borderRadius(HomeConstants.BORDER_RADIUS_LIST[2])
    .linearGradient({
      direction: GradientDirection.Right,
      repeating: false,
      colors: [[HomeConstants.GRADIENT_COLORS[0], 0.0], [HomeConstants.GRADIENT_COLORS[1], 1.0]]
    })
  }
}
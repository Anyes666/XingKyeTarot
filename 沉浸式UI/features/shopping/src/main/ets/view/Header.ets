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

import { BreakpointType, CommonConstants, ImmersiveType, WindowInfo } from 'commons';
import { HomeConstants } from '../constants/HomeConstants';

@Component
export struct Header {
  @Consume navPageInfos: NavPathStack = new NavPathStack();
  @ObjectLink mainWindowInfo: WindowInfo;

  build() {
    // [Start set_padding]
    Column() {
      // [StartExclude set_padding]
      GridRow({
        columns: {
          sm: 4,
          md: 11,
          lg: 12,
          xl: 12
        }
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 7,
            lg: 8,
            xl: 8
          }
        }) {
          Row() {
            if (this.mainWindowInfo.titleButtonRect?.width) {
              this.BackIcon();
            }
            this.TopTabBar();
          };
        }
        .height(HomeConstants.TAB_BAR_HEIGHT);

        GridCol({
          span: 4
        }) {
          this.SearchBar();
        }
        .height(HomeConstants.TAB_BAR_HEIGHT)
      }
      .padding({
        right: this.mainWindowInfo.isImmersive === ImmersiveType.IMMERSIVE && this.mainWindowInfo.titleButtonRect!.width > 0 ? 0 :
          HomeConstants.PAGE_COL_PADDING.getValue(this.mainWindowInfo.widthBp)
      });

      // [EndExclude set_padding]
    }
    .padding({
      right: this.mainWindowInfo.isImmersive === ImmersiveType.IMMERSIVE ? this.mainWindowInfo.titleButtonRect?.width :
        0
    })

    // [End set_padding]
  }

  @Builder
  BackIcon() {
    Row() {
      Image($r('app.media.ic_public_arrow_left'))
        .width($r('app.float.common_image_size'))
        .height($r('app.float.common_image_size'))
        .fillColor($r('app.color.back_icon_color'))
        .onClick(() => {
          this.navPageInfos.pop();
        });
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.back_icon_bg'))
    .height($r('app.float.back_size'))
    .width($r('app.float.back_size'))
    .borderRadius(HomeConstants.BORDER_RADIUS_LIST[3])
    .margin({ right: $r('app.float.back_image_margin') });

  }

  @Builder
  TopTabBar() {
    List({
      space: new BreakpointType(14, 16, 32, 32).getValue(this.mainWindowInfo.widthBp)
    }) {
      ForEach(HomeConstants.TOP_BAR_TEXTS, (item: ResourceStr, index: number) => {
        ListItem() {
          Text(item)
            .fontSize(index === 0 ? $r('app.float.top_bar_text_selected_font') : $r('app.float.top_bar_text_font'))
            .lineHeight(index === 0 ? $r('app.float.top_bar_text_selected_line') : $r('app.float.top_bar_text_line'))
            .fontWeight(index === 0 ? CommonConstants.FONT_WEIGHT_500 : FontWeight.Normal)
            .fontColor(index === 0 ? Color.Black : $r('app.color.home_header_text_color'));
        }
        .layoutWeight(1);
      }, (item: string, index: number) => item + index);
    }
    .scrollBar(BarState.Off)
    .alignListItem(ListItemAlign.Center)
    .listDirection(Axis.Horizontal)
    .padding({
      left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XS ||
        this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? $r('app.float.top_text_padding_left_sm') : 0,
      right: new BreakpointType($r('app.float.top_text_padding_right_sm'), $r('app.float.top_text_padding_right_md'),
        $r('app.float.top_text_padding_right_lg'),
        $r('app.float.top_text_padding_right_xl')).getValue(this.mainWindowInfo.widthBp)
    })
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT);
  }

  @Builder
  SearchBar() {
    Row() {
      Stack({ alignContent: Alignment.Start }) {
        TextInput({ placeholder: $r('app.string.searching') })
          .placeholderFont({
            size: $r('app.float.search_input_font'),
            weight: FontWeight.Normal
          })
          .placeholderColor($r('app.color.normal_font_color'))
          .height($r('app.float.search_input_height'))
          .fontSize($r('app.float.search_input_font'))
          .padding({
            left: $r('app.float.search_input_left'),
            right: $r('app.float.search_input_right')
          })
          .width(CommonConstants.FULL_PERCENT)
          .enableKeyboardOnFocus(false);

        // Search image.
        Image($r('app.media.ic_public_search'))
          .width($r('app.float.search_img_size'))
          .height($r('app.float.search_img_size'))
          .margin({ left: $r('app.float.search_img_left') });
      }
      .alignSelf(ItemAlign.Center)
      .layoutWeight(1);

      // Scan image.
      Image($r('app.media.ic_public_scan'))
        .width($r('app.float.common_image_size'))
        .height($r('app.float.common_image_size'))
        .margin({
          left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XS ||
            this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ?
            $r('app.float.search_img_margin_sm') : $r('app.float.search_img_margin')
        });

      // Message image.
      Image($r('app.media.ic_public_comments'))
        .width($r('app.float.common_image_size'))
        .height($r('app.float.common_image_size'))
        .margin({
          left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XS ||
            this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ?
            $r('app.float.search_img_margin_sm') : $r('app.float.search_img_margin')
        });
    }
    .justifyContent(FlexAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT);
  }
}
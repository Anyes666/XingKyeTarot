/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { CommonConstants, WindowInfo, WindowUtil } from 'commons';
import { TabBar } from '../model/HomeModel';
import { HomeViewModel } from '../viewmodel/HomeViewModel';
import { HomeContent } from './HomeContent';

@Component
export struct Home {
  @State activeTabIndex: number = 0;
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  @State mainWindowInfo: WindowInfo | undefined = this.windowUtil?.mainWindowInfo;
  private tabBarList: TabBar[] = new HomeViewModel().getTabBarList();

  @Builder
  TabBarBuilder(tabBar: TabBar, index: number) {
    Column() {
      Image(this.isActive(index) ? tabBar.activeIcon : tabBar.icon)
        .width($r('app.float.bottom_tab_img_size'))
        .height($r('app.float.bottom_tab_img_size'))
        .margin({ bottom: $r('app.float.bottom_tab_margin_bottom') });
      Text(tabBar.text)
        .fontSize($r('app.float.bottom_tab_text_size'))
        .fontWeight(CommonConstants.FONT_WEIGHT_500)
        .fontColor(this.isActive(index) ? $r('app.color.section_text') : Color.Black)
        .opacity(this.isActive(index) ? 1 : 0.4);
    };
  }

  isActive(index: number): boolean {
    return this.activeTabIndex === index;
  }

  onActiveTabChange(index: number) {
    this.activeTabIndex = index;
  }

  build() {
    Column() {
      Tabs({
        barPosition: this.mainWindowInfo?.widthBp === WidthBreakpoint.WIDTH_LG ||
          this.mainWindowInfo?.widthBp === WidthBreakpoint.WIDTH_XL ? BarPosition.Start : BarPosition.End
      }) {
        ForEach(this.tabBarList, (tabBar: TabBar, index) => {
          TabContent() {
            if (index === 0) {
              HomeContent({
                mainWindowInfo: this.windowUtil?.mainWindowInfo
              });
            }
          }
          .tabBar(this.TabBarBuilder(tabBar, index));
        }, (tabBar: TabBar) => JSON.stringify(tabBar));
      }
      .barWidth(this.mainWindowInfo?.widthBp === WidthBreakpoint.WIDTH_LG ||
        this.mainWindowInfo?.widthBp === WidthBreakpoint.WIDTH_XL ? $r('app.float.bottom_tab_bar_width') :
        CommonConstants.FULL_PERCENT)
      .barHeight(this.mainWindowInfo?.widthBp === WidthBreakpoint.WIDTH_LG ||
        this.mainWindowInfo?.widthBp === WidthBreakpoint.WIDTH_XL ? CommonConstants.FULL_PERCENT :
        $r('app.float.bottom_tab_bar_height'))
      .barMode(BarMode.Fixed)
      .vertical(this.mainWindowInfo?.widthBp === WidthBreakpoint.WIDTH_LG ||
        this.mainWindowInfo?.widthBp === WidthBreakpoint.WIDTH_XL)
      .onChange((index: number) => this.onActiveTabChange(index));
    }
    .height(CommonConstants.FULL_PERCENT);
  }
}

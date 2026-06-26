/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { WindowUtil } from 'commons';
import { Route, ROUTES } from '../constants/Constants';
import { Shopping } from './backgroundImmersive/componentBackgroundImmersive/Shopping';
import { ShoppingAvoid } from './backgroundImmersive/componentPageImmersive/ShoppingAvoid';
import { MiniGame } from './fullScreenImmersive/componentPageImmersive/MiniGame';
import { ShoppingFullScreen } from './fullScreenImmersive/freeformWindowImmersive/ShoppingFullScreen';

@Entry
@Component
struct Index {
  @Provide navPageInfos: NavPathStack = new NavPathStack();
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;

  go(to: string | undefined) {
    if (!to) {
      return;
    }
    this.navPageInfos.pushPath({ name: to });
  }

  @Builder
  NavPageMap(name: string) {
    if (name === 'Shopping') {
      Shopping();
    } else if (name === 'ShoppingAvoid') {
      ShoppingAvoid();
    } else if (name === 'MiniGame') {
      MiniGame();
    } else if (name === 'ShoppingFullScreen') {
      ShoppingFullScreen();
    }
  }

  build() {
    Navigation(this.navPageInfos) {
      Column() {
        Text($r('app.string.title'))
          .fontWeight(FontWeight.Bold)
          .fontSize(30)
          .fontColor($r('app.color.page_text_color'))
          .width('100%')
          .margin({ bottom: 30 })
        // .height(80)
        ForEach(ROUTES, (route: Route) => {
          Text(route.title)
            .width('100%')
            .fontColor($r('app.color.page_title_text_color'))
            .fontSize(18)
          Column() {
            ForEach(route.children || [], (routeItem: Route, index) => {
              if (index !== 0) {
                Divider()
                  .color('#0D000000')
                  .strokeWidth(0.5)
              }
              Row() {
                Text() {
                  Span(routeItem.title)
                  Span(' - ')
                  Span(routeItem.name)
                }
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)

                Image($r('app.media.arrow_right'))
                  .width(24)
                  .height(24)

              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
              .onClick(() => this.go(routeItem.to))
            }, (routerItem: Route) => JSON.stringify(routerItem))
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(20)
          .margin({ top: 16, bottom: 28 })
          .padding({ left: 12, right: 12 })
        }, (route: Route) => JSON.stringify(route))
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .hideToolBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.NavPageMap)
    .backgroundColor($r('app.color.page_background'))
  }
}
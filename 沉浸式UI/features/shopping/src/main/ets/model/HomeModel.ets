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

import { HomeConstants } from "../constants/HomeConstants";

export class HomeModel {
  private tabBarList: TabBar[] = [];

  constructor() {
    this.initTabBarList();
  }
  initTabBarList(){
    HomeConstants.TAB_BAR_TEXT_LIST.map((item, index)=> {
      this.tabBarList.push({
        text: item,
        icon: HomeConstants.TAB_BAR_ICON_LIST[index],
        activeIcon: HomeConstants.TAB_BAR_ACTIVE_ICON_LIST[index],
      })
    })
  }
  getTabBarList() {
    return this.tabBarList;
  }
}

export interface TabBar {
  text: ResourceStr;
  icon: ResourceStr;
  activeIcon: ResourceStr;
}
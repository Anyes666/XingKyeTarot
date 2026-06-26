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

import { HomeConstants } from '../constants/HomeConstants';

export class IconInfoModel {
  private categoryList: IconInfo[] = [];
  private welfareList: IconInfo[] = [];

  constructor() {
    this.initData();
  }

  initData() {
    HomeConstants.CATEGORY_INFO_LIST.map((item, index) => {
      this.categoryList.push(new IconInfo(item, HomeConstants.CATEGORY_ICON_LIST[index]));
    })
    HomeConstants.WELFARE_PRICE_LIST.map((item, index) => {
      this.welfareList.push(new IconInfo(item, HomeConstants.WELFARE_ICON_LIST[index]));
    })
  }

  getCategoryList() {
    return this.categoryList;
  }

  getWelfareList() {
    return this.welfareList;
  }
}

export class IconInfo {
  /**
   * Info of the icon.
   */
  private info: ResourceStr;
  /**
   * Icon image.
   */
  private icon: Resource;

  constructor(info: ResourceStr, icon: Resource) {
    this.info = info;
    this.icon = icon;
  }

  getInfo(): ResourceStr {
    return this.info;
  }

  getIcon(): Resource {
    return this.icon;
  }
}
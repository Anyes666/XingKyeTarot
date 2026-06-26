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

export class RecommendModel {
  private recommendProductList: RecommendProduct[] = [];

  constructor() {
    this.initData();
  }

  initData() {
    HomeConstants.RECOMMENDED_PRODUCTS.map((item, index) => {
      this.recommendProductList.push(new RecommendProduct(item, HomeConstants.RECOMMENDED_PRODUCT_LIVING[index]));
    })
  }

  getRecommendProductList() {
    return this.recommendProductList;
  }
}

export class RecommendProduct {
  /**
   * Image of the product.
   */
  private image: Resource;
  /**
   * Whether it is live.
   */
  private isLive: boolean;

  constructor(image: Resource, isLive: boolean) {
    this.image = image;
    this.isLive = isLive;
  }

  getImage(): Resource {
    return this.image;
  }

  getIsLive(): Boolean {
    return this.isLive;
  }
}
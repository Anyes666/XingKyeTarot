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

import { HomeConstants } from '../constants/HomeConstants';

export class SectionModel {
  private sectionProductList: SectionProduct[] = [];
  private flashSaleProductList: SectionProduct[] = [];

  constructor() {
    this.initData();
  }

  initData() {
    HomeConstants.SECTION_PRODUCT_IMAGES.map((item, index) => {
      this.sectionProductList.push(new SectionProduct(item, HomeConstants.SECTION_PRODUCTS_TITLES[index],
        HomeConstants.SECTION_PRODUCTS_PRICES[index],
        HomeConstants.SECTION_PRODUCTS_FEATURES[index], HomeConstants.SECTION_PRODUCTS_COMMENTS,
        HomeConstants.SECTION_PRODUCTS_INFO[index]));
    })
    HomeConstants.FLASH_SALE_PRODUCT_IMAGES.map((item, index) => {
      this.flashSaleProductList.push(new SectionProduct(item, HomeConstants.FLASH_SALE_PRODUCT_TITLES[index],
        HomeConstants.FLASH_SALE_PRODUCT_PRICES[index], HomeConstants.FLASH_SALE_PRODUCT_FEATURES[index],
        HomeConstants.FLASH_SALE_PRODUCT_INFO[index], HomeConstants.FLASH_SALE_PRODUCT_ORIGINAL_PRICES[index]));
    })
  }

  getSectionProductList() {
    return this.sectionProductList;
  }

  getFlashSaleProductList() {
    return this.flashSaleProductList;
  }
}

export class SectionProduct {
  private productImg: Resource;
  private title: ResourceStr[];
  private price: string;
  private feature: ResourceStr[];
  private comments: ResourceStr;
  private info: ResourceStr;
  private originalPrice?: ResourceStr;

  constructor(productImg: Resource, title: ResourceStr[], price: string, feature: ResourceStr[], comments: ResourceStr,
    info: ResourceStr,
    originalPrice?: string) {
    this.productImg = productImg;
    this.title = title;
    this.price = price;
    this.feature = feature;
    this.comments = comments;
    this.info = info;
    if (originalPrice !== undefined) {
      this.originalPrice = originalPrice;
    }
  }

  getProductImg(): Resource {
    return this.productImg;
  }

  getTitle(): ResourceStr[] {
    return this.title;
  }

  getPrice(): string {
    return this.price;
  }

  getFeature(): ResourceStr[] {
    return this.feature;
  }

  getComments(): ResourceStr {
    return this.comments;
  }

  getInfo(): ResourceStr {
    return this.info;
  }

  getOriginalPrice(): ResourceStr | undefined {
    return this.originalPrice;
  }
}
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

import { BreakpointType } from 'commons';

export class HomeConstants {
  /**
   * Tab bar height for sm and md.
   */
  static readonly TAB_BAR_HEIGHT: number = 56;
  /**
   * Top bar text list.
   */
  static readonly TOP_BAR_TEXTS: Resource[] = [
    $r('app.string.top_bar_texts1'), $r('app.string.top_bar_texts2'), $r('app.string.top_bar_texts3'),
    $r('app.string.top_bar_texts4')];
  /**
   * Category list space list.
   */
  static readonly CATEGORY_LIST_SPACES: string[] = ['0', '36vp', '72vp', '78vp'];
  /**
   * Category divider stroke width.
   */
  static readonly CATEGORY_DIVIDER_STROKE_WIDTH: string = '4vp';
  /**
   * Category list item width list.
   */
  static readonly CATEGORY_LIST_ITEM_WIDTHS: string[] = ['20%', '64vp', '68vp', '78vp'];
  /**
   * Recommended product item space list.
   */
  static readonly RECOMMENDED_PRODUCT_ITEM_SPACES: string[] = ['16vp', '12vp'];
  /**
   * Gradient color list.
   */
  static readonly GRADIENT_COLORS: string[] = ['#4DEDAA68', '#33FFE9C1', '#FF6354', '#EA1559'];
  /**
   * Page col padding.
   */
  static readonly PAGE_COL_PADDING: BreakpointType<Resource> = new BreakpointType($r('app.float.page_col_padding_sm'),
    $r('app.float.page_col_padding_md'), $r('app.float.page_col_padding_lg'), $r('app.float.page_col_padding_lg'));
  /**
   * Border radius list.
   */
  static readonly BORDER_RADIUS_LIST: Resource[] = [
    $r('app.float.common_border_radius_1'),
    $r('app.float.common_border_radius_2'),
    $r('app.float.common_border_radius_3'),
    $r('app.float.common_border_radius_4')
  ];
  /**
   * Number nine
   */
  static readonly NINE: number = 9;
  /**
   * TabBar text list.
   */
  static readonly TAB_BAR_TEXT_LIST: Resource[] =
    [$r('app.string.tab_bar_title_1'), $r('app.string.tab_bar_title_2'), $r('app.string.tab_bar_title_3')];
  /**
   * TabBar icon list.
   */
  static readonly TAB_BAR_ICON_LIST: Resource[] =
    [$r('app.media.tab_home'), $r('app.media.tab_classification'), $r('app.media.tab_discovery')];
  /**
   * TabBar active icon list.
   */
  static readonly TAB_BAR_ACTIVE_ICON_LIST: Resource[] =
    [$r('app.media.tab_home_selected'), $r('app.media.tab_classification_selected'),
      $r('app.media.tab_discovery_selected')];
  /**
   * Category info list.
   */
  static readonly CATEGORY_INFO_LIST: Resource[] =
    [$r('app.string.good_categories1'), $r('app.string.good_categories2'), $r('app.string.good_categories3'),
      $r('app.string.good_categories4'), $r('app.string.good_categories5'), $r('app.string.good_categories6'),
      $r('app.string.good_categories7'), $r('app.string.good_categories8'), $r('app.string.good_categories9'),
      $r('app.string.good_categories10')];
  /**
   * Category icon list.
   */
  static readonly CATEGORY_ICON_LIST: Resource[] =
    [$r('app.media.categories_1'), $r('app.media.categories_2'), $r('app.media.categories_3'),
      $r('app.media.categories_4'), $r('app.media.categories_5'), $r('app.media.categories_6'),
      $r('app.media.categories_7'), $r('app.media.categories_8'), $r('app.media.categories_9'),
      $r('app.media.categories_10')];
  /**
   * Welfare price list.
   */
  static readonly WELFARE_PRICE_LIST: string[] = ['￥1299', '￥899', '￥599', '￥2499', '￥6899', '￥1799', '￥988', '￥6999'];
  /**
   * Welfare icon list.
   */
  static readonly WELFARE_ICON_LIST: Resource[] =
    [$r('app.media.welfare_product_1'), $r('app.media.welfare_product_2'), $r('app.media.welfare_product_3'),
      $r('app.media.welfare_product_4'), $r('app.media.welfare_product_5'), $r('app.media.welfare_product_6'),
      $r('app.media.welfare_product_7'), $r('app.media.welfare_product_8')];
  /**
   * Recommended product list.
   */
  static readonly RECOMMENDED_PRODUCTS: Resource[] = [$r('app.media.recommended_product_1'),
    $r('app.media.recommended_product_2'), $r('app.media.recommended_product_3'),
    $r('app.media.recommended_product_4'), $r('app.media.recommended_product_5')];
  /**
   * Recommended product is living list.
   */
  static readonly RECOMMENDED_PRODUCT_LIVING: boolean[] = [true, false, true, false, false];
  /**
   * Section product image list.
   */
  static readonly SECTION_PRODUCT_IMAGES: Resource[] = [$r('app.media.section_product_1'),
    $r('app.media.section_product_2'), $r('app.media.section_product_3'), $r('app.media.section_product_4'),
    $r('app.media.section_product_5')];
  /**
   * Section products title list.
   */
  static readonly SECTION_PRODUCTS_TITLES: ResourceStr[][] = [
    [$r('app.string.section_products_titles1')],
    ['HUAWEI Mate 50', $r('app.string.section_products_titles2')],
    ['Sound X NEW'], ['HUAWEI MatePad Air'], ['HUAWEI MateBook 14s']];
  /**
   * Section products price list.
   */
  static readonly SECTION_PRODUCTS_PRICES: string[] = ['￥10999', '￥4999', '￥2499', '￥2599', '￥8399'];
  /**
   * Section products feature list.
   */
  static readonly SECTION_PRODUCTS_FEATURES: ResourceStr[][] = [
    [$r('app.string.section_products_features1')],
    [$r('app.string.section_products_features2')],
    [$r('app.string.section_products_features3')],
    [$r('app.string.section_products_features4')],
    [$r('app.string.section_products_features5')]];
  /**
   * Section products comment list.
   */
  static readonly SECTION_PRODUCTS_COMMENTS: Resource = $r('app.string.home_review');
  /**
   * Section products info list.
   */
  static readonly SECTION_PRODUCTS_INFO: ResourceStr[] =
    ['', $r('app.string.section_products_info1'), '', $r('app.string.section_products_info2'),
      $r('app.string.section_products_info3')];
  /**
   * Flash sale product image list.
   */
  static readonly FLASH_SALE_PRODUCT_IMAGES: Resource[] = [$r('app.media.flash_sale_product_1'),
    $r('app.media.flash_sale_product_2'), $r('app.media.flash_sale_product_3'), $r('app.media.flash_sale_product_4'),
    $r('app.media.flash_sale_product_4'), $r('app.media.flash_sale_product_4')];
  /**
   * Flash sale product title list.
   */
  static readonly FLASH_SALE_PRODUCT_TITLES: ResourceStr[][] = [['HUAWEI Mate 50'], ['Mate Xs 2'],
    ['HUAWEI nova 10', $r('app.string.Hot_Seller')],
    ['MateBook E Go', $r('app.string.New_Launch')],
    ['MateBook E Go', $r('app.string.New_Launch')],
    ['MateBook E Go', $r('app.string.New_Launch')]];
  /**
   * Flash sale product info list.
   */
  static readonly FLASH_SALE_PRODUCT_INFO: Resource[] =
    [$r('app.string.section_products_info1'), $r('app.string.section_products_info6'),
      $r('app.string.section_products_info4'), $r('app.string.section_products_info5'),
      $r('app.string.section_products_info5'), $r('app.string.section_products_info5')];
  /**
   * Flash sale product feature list.
   */
  static readonly FLASH_SALE_PRODUCT_FEATURES: ResourceStr[][] = [
    [$r('app.string.flash_sale_product_features1'), $r('app.string.flash_sale_product_features2')],
    [$r('app.string.flash_sale_product_features3')],
    [$r('app.string.flash_sale_product_features4')],
    [$r('app.string.flash_sale_product_features5')],
    [$r('app.string.flash_sale_product_features5')],
    [$r('app.string.flash_sale_product_features5')]];
  /**
   * Flash sale product price list.
   */
  static readonly FLASH_SALE_PRODUCT_PRICES: string[] = ['￥4999', '￥9999', '￥2949', '￥4899', '￥4899', '￥4899'];
  /**
   * Flash sale original price list.
   */
  static readonly FLASH_SALE_PRODUCT_ORIGINAL_PRICES: string[] = ['￥5488', '', '￥2999', '￥4999', '￥4999', '￥4999'];
}
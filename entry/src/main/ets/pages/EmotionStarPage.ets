import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
import { MoonlightLayer } from '../components/MoonlightLayer';
import { LevelUpPopup } from '../components/LevelUpPopup';
import { EmotionStarStorage, StarKeyLevel, NextLevelInfo } from '../common/EmotionStarStorage';

/**
 * 点亮情绪星页面路由参数
 */
interface EmotionStarRouteParams {
  emotionTag: string;
  heartOptionIndex: number;
  cardName: string;
  cardId: string;
  totalLightDays: number;
  currentLevelTitle: string;
}

/**
 * 星历跳转参数
 */
interface StarCalendarParams {
  tab: number;
}

@Entry
@Component
struct EmotionStarPage {
  @State emotionTag: string = '';
  @State cardName: string = '';
  @State totalLightDays: number = 0;
  @State currentLevelTitle: string = '初见';
  @State nextLevelTitle: string = '星火初亮';
  @State daysToNextLevel: number = 1;
  @State isMaxLevel: boolean = false;
  @State private homeBtnPressed: boolean = false;
  @State private calendarBtnPressed: boolean = false;

  // ── P1 预留：LevelUpPopup 触发逻辑（P2 阶段替换为真实弹窗组件）──
  @State showLevelUp: boolean = false;
  @State currentLevelDays: number = 0;
  // 记录进入页面前的前一个等级标题，用于判断是否发生等级提升
  private previousLevelTitle: string = '';

  aboutToAppear(): void {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params: EmotionStarRouteParams = rawParams as EmotionStarRouteParams;
      this.emotionTag = params.emotionTag || '';
      this.cardName = params.cardName || '';
      this.totalLightDays = params.totalLightDays || 0;
      this.currentLevelTitle = params.currentLevelTitle || '初见';
    }

    // 计算下一等级信息
    const nextInfo: NextLevelInfo = EmotionStarStorage.getNextLevelInfo(this.totalLightDays);
    this.nextLevelTitle = nextInfo.title;
    this.daysToNextLevel = nextInfo.daysLeft;
    this.isMaxLevel = nextInfo.isMaxLevel;

    // ── P1 预留：检测等级提升 ──
    // 根据 totalLightDays 计算当前实际等级
    const currentLevel: StarKeyLevel = EmotionStarStorage.getLevelByTotalDays(this.totalLightDays);
    this.currentLevelDays = currentLevel.threshold;
    // 如果路由传入的 currentLevelTitle 与实际等级不一致，说明发生了等级提升
    // （路由传入的 title 是点亮前的等级，currentLevel 是点亮后的实际等级）
    this.previousLevelTitle = this.currentLevelTitle;
    if (currentLevel.title !== this.currentLevelTitle) {
      // 等级已提升 → 触发 LevelUpPopup（P2 阶段替换为真实组件）
      this.currentLevelTitle = currentLevel.title;
      this.showLevelUp = true;
    }
  }

  build() {
    Stack() {
      // ── B 方案月湖映心底色 ──
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.V2B_BG_BASE)

      // ── B 方案月光呼吸层（strong=true，仪式感场景）──
      MoonlightLayer({ strong: true })

      // ── 主内容 ──
      Column() {
        // ── 左上角统一返回按钮 ──
        Row() {
          AppBackButton({ fallbackUrl: Routes.HOME })
        }
        .width('100%')
        .padding({ top: Theme.SAFE_TOP })

        Scroll() {
          Column() {
            // ══ 顶部点亮反馈区（B 方案月光白 + A 方案标记感）══
            Column() {
              Text('✨')
                .fontSize(48)
                .margin({ bottom: Theme.V2_SPACE_MD })

              Text('你点亮了今天的情绪星')
                .fontSize(Theme.V2B_FONT_TITLE)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.V2B_TEXT_PRIMARY)
                .textAlign(TextAlign.Center)
                .margin({ bottom: Theme.V2_SPACE_SM })

              // 今日星名（A 方案金色标记感）
              Text('今日星名：' + this.emotionTag)
                .fontSize(Theme.V2B_FONT_SUBTITLE)
                .fontColor(Theme.V2B_GOLD_CORE)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .margin({ bottom: Theme.V2_SPACE_XS })

              // 今日牌名（A 方案等宽时间戳风格）
              Text('今日星钥：' + this.cardName)
                .fontSize(Theme.V2B_FONT_BODY)
                .fontColor(Theme.V2B_TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .fontFamily('HarmonyOS Sans Mono')
            }
            .width('100%')
            .padding({ top: Theme.V2_SPACE_XL, bottom: Theme.V2_SPACE_XL })

            // ══ 星澜陪伴文案 ══
            Text('星澜会替你记住：\n今天的你，也认真面对过自己的感受。')
              .fontSize(Theme.V2B_FONT_LEAD)
              .fontColor(Theme.V2B_GOLD_RIPPLE)
              .textAlign(TextAlign.Center)
              .lineHeight(26)
              .width('82%')
              .margin({ bottom: Theme.V2_SPACE_XL })

            // ══ 累计点亮天数卡片（A 方案星图档案标记感）══
            Column() {
              Row() {
                // 累计天数（A 方案等宽数字风格）
                Column() {
                  Text(this.totalLightDays.toString())
                    .fontSize(Theme.V2A_FONT_RANK_DAYS)
                    .fontColor(Theme.V2A_GOLD_ACCENT)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .fontFamily('HarmonyOS Sans Mono')

                  Text('累计点亮')
                    .fontSize(Theme.V2A_FONT_CAPTION)
                    .fontColor(Theme.V2A_TEXT_SECONDARY)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .margin({ top: Theme.V2_SPACE_2XS })
                }
                .layoutWeight(1)

                // 分隔线（A 方案星轨线）
                Column()
                  .width(1)
                  .height(48)
                  .backgroundColor(Theme.V2A_ORBIT_LINE)

                // 当前等级（A 方案标记感）
                Column() {
                  Text(this.currentLevelTitle)
                    .fontSize(Theme.V2A_FONT_RANK_TITLE)
                    .fontColor(Theme.V2A_GOLD_GLOW)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                    .width('100%')

                  Text('当前星钥等级')
                    .fontSize(Theme.V2A_FONT_CAPTION)
                    .fontColor(Theme.V2A_TEXT_SECONDARY)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .margin({ top: Theme.V2_SPACE_2XS })
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: Theme.V2_SPACE_MD_B, bottom: Theme.V2_SPACE_MD_B })

              // 下一等级信息
              if (!this.isMaxLevel) {
                Divider()
                  .strokeWidth(0.5)
                  .color(Theme.V2A_ORBIT_LINE)
                  .width('88%')

                Text('下一称号：' + this.nextLevelTitle + '\n还差 ' + this.daysToNextLevel.toString() + ' 天')
                  .fontSize(Theme.V2A_FONT_BODY)
                  .fontColor(Theme.V2A_TEXT_SECONDARY)
                  .textAlign(TextAlign.Center)
                  .lineHeight(22)
                  .padding({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_2XS })
              } else {
                Divider()
                  .strokeWidth(0.5)
                  .color(Theme.V2A_ORBIT_LINE)
                  .width('88%')

                Text('你已到达最高星钥等级')
                  .fontSize(Theme.V2A_FONT_BODY)
                  .fontColor(Theme.V2A_GOLD_ACCENT)
                  .textAlign(TextAlign.Center)
                  .padding({ top: Theme.V2_SPACE_MD, bottom: Theme.V2_SPACE_2XS })
              }
            }
            .width('88%')
            .backgroundColor(Theme.V2A_BG_CARD)
            .borderRadius(Theme.V2A_RADIUS_CARD)
            .border({ width: 1, color: Theme.V2A_ORBIT_LINE })
            .margin({ bottom: Theme.V2_SPACE_XL })

            // ══ P2：LevelUpPopup 等级提升弹窗（替换 P1 占位）══
            if (this.showLevelUp) {
              LevelUpPopup({
                show: this.showLevelUp,
                levelTitle: this.currentLevelTitle,
                levelDays: this.currentLevelDays,
                onClose: () => {
                  this.showLevelUp = false;
                }
              })
            }

            // ══ 操作按钮 ══
            Column({ space: Theme.V2_SPACE_SM }) {
              // 回到首页
              Button('回到首页')
                .type(ButtonType.Normal)
                .width('82%')
                .height(48)
                .fontSize(Theme.V2B_FONT_BODY)
                .fontColor(Theme.V2B_BG_BASE)
                .fontWeight(FontWeight.Bold)
                .backgroundColor(Theme.V2B_GOLD_CORE)
                .borderRadius(Theme.V2B_RADIUS_BTN)
                .scale({
                  x: this.homeBtnPressed ? Theme.PRESS_SCALE : 1.0,
                  y: this.homeBtnPressed ? Theme.PRESS_SCALE : 1.0
                })
                .animation({
                  duration: Theme.ANIM_PRESS_DURATION,
                  curve: Theme.V2_EASE_OUT
                })
                .onTouch((event: TouchEvent) => {
                  if (event.type === TouchType.Down) {
                    this.homeBtnPressed = true;
                  } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                    this.homeBtnPressed = false;
                  }
                })
                .onClick(() => {
                  try {
                    router.replaceUrl({ url: Routes.MAIN_FRAME });
                  } catch (_err) {
                    // ignore
                  }
                })

              // 查看我的星历（跳转到我的页面的 tab=4）
              Button('查看我的星历')
                .type(ButtonType.Normal)
                .width('82%')
                .height(48)
                .fontSize(Theme.V2B_FONT_BODY)
                .fontColor(Theme.V2B_GOLD_RIPPLE)
                .backgroundColor(Theme.V2B_BG_CARD)
                .border({ width: 1, color: Theme.V2B_GOLD_CORE })
                .borderRadius(Theme.V2B_RADIUS_BTN)
                .scale({
                  x: this.calendarBtnPressed ? Theme.PRESS_SCALE : 1.0,
                  y: this.calendarBtnPressed ? Theme.PRESS_SCALE : 1.0
                })
                .animation({
                  duration: Theme.ANIM_PRESS_DURATION,
                  curve: Theme.V2_EASE_OUT
                })
                .onTouch((event: TouchEvent) => {
                  if (event.type === TouchType.Down) {
                    this.calendarBtnPressed = true;
                  } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                    this.calendarBtnPressed = false;
                  }
                })
                .onClick(() => {
                  try {
                    const params: StarCalendarParams = { tab: 4 };
                    const options: router.RouterOptions = {
                      url: Routes.MAIN_FRAME,
                      params: params
                    };
                    router.replaceUrl(options);
                  } catch (_err) {
                    try {
                      router.replaceUrl({ url: Routes.MAIN_FRAME });
                    } catch (_err2) {
                      // ignore
                    }
                  }
                })

              // 回到结果页
              Text('回到结果页')
                .fontSize(Theme.V2B_FONT_CAPTION)
                .fontColor(Theme.V2B_TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .width('82%')
                .height(44)
                .onClick(() => {
                  try {
                    router.back();
                  } catch (_err) {
                    try {
                      router.replaceUrl({ url: Routes.MAIN_FRAME });
                    } catch (_err2) {
                      // ignore
                    }
                  }
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .margin({ bottom: Theme.V2_SPACE_3XL })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}

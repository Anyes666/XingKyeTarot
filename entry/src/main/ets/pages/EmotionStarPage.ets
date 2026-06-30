import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';
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
  }

  build() {
    Column() {
      // ── 左上角统一返回按钮 ──
      Row() {
        AppBackButton({ fallbackUrl: Routes.HOME })
      }
      .width('100%')
      .padding({ top: 48 })

      Scroll() {
        Column() {
          // ══ 顶部点亮反馈区 ══
          Column() {
            Text('✨')
              .fontSize(48)
              .margin({ bottom: 16 })

            Text('你点亮了今天的情绪星')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E5D9B6')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 12 })

            // 今日星名
            Text('今日星名：' + this.emotionTag)
              .fontSize(18)
              .fontColor('#CA8A04')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 8 })

            // 今日牌名
            Text('今日星钥：' + this.cardName)
              .fontSize(15)
              .fontColor('#94A3B8')
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 40, bottom: 32 })

          // ══ 星澜陪伴文案 ══
          Text('星澜会替你记住：\n今天的你，也认真面对过自己的感受。')
            .fontSize(16)
            .fontColor('#C8B88A')
            .textAlign(TextAlign.Center)
            .lineHeight(26)
            .width('82%')
            .margin({ bottom: 32 })

          // ══ 累计点亮天数卡片 ══
          Column() {
            Row() {
              Column() {
                Text(this.totalLightDays.toString())
                  .fontSize(36)
                  .fontColor('#E5A50A')
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                  .width('100%')

                Text('累计点亮')
                  .fontSize(13)
                  .fontColor('#94A3B8')
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              // 分隔线
              Column()
                .width(1)
                .height(48)
                .backgroundColor('rgba(202, 138, 4, 0.2)')

              Column() {
                Text(this.currentLevelTitle)
                  .fontSize(22)
                  .fontColor('#E5D9B6')
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                  .width('100%')

                Text('当前星钥等级')
                  .fontSize(13)
                  .fontColor('#94A3B8')
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 20, bottom: 20 })

            // 下一等级信息
            if (!this.isMaxLevel) {
              Divider()
                .strokeWidth(0.5)
                .color('rgba(202, 138, 4, 0.12)')
                .width('88%')

              Text('下一称号：' + this.nextLevelTitle + '\n还差 ' + this.daysToNextLevel.toString() + ' 天')
                .fontSize(14)
                .fontColor('#94A3B8')
                .textAlign(TextAlign.Center)
                .lineHeight(22)
                .padding({ top: 16, bottom: 4 })
            } else {
              Divider()
                .strokeWidth(0.5)
                .color('rgba(202, 138, 4, 0.12)')
                .width('88%')

              Text('你已到达最高星钥等级')
                .fontSize(14)
                .fontColor('#E5A50A')
                .textAlign(TextAlign.Center)
                .padding({ top: 16, bottom: 4 })
            }
          }
          .width('88%')
          .backgroundColor('#17172F')
          .borderRadius(24)
          .border({ width: 1, color: 'rgba(202, 138, 4, 0.15)' })
          .margin({ bottom: 32 })

          // ══ 操作按钮 ══
          Column({ space: 12 }) {
            // 回到首页
            Button('回到首页')
              .type(ButtonType.Normal)
              .width('82%')
              .height(48)
              .fontSize(16)
              .fontColor('#0F0F23')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#E5A50A')
              .borderRadius(24)
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
              .fontSize(16)
              .fontColor('#E5D9B6')
              .backgroundColor('rgba(202, 138, 4, 0.08)')
              .border({ width: 1, color: 'rgba(202, 138, 4, 0.25)' })
              .borderRadius(24)
              .onClick(() => {
                try {
                  const options: router.RouterOptions = {
                    url: Routes.MAIN_FRAME,
                    params: { tab: 4 }
                  };
                  router.replaceUrl(options);
                } catch (_err) {
                  router.replaceUrl({ url: Routes.MAIN_FRAME });
                }
              })

            // 再听星澜说一句（返回结果页继续探索）
            Text('回到结果页')
              .fontSize(14)
              .fontColor('#94A3B8')
              .textAlign(TextAlign.Center)
              .width('82%')
              .height(44)
              .onClick(() => {
                try {
                  router.back();
                } catch (_err) {
                  router.replaceUrl({ url: Routes.MAIN_FRAME });
                }
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 48 })
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
    .backgroundColor('#0F0F23')
  }
}

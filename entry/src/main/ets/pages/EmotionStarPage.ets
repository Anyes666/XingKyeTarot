import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';

// ===== 路由参数接口 =====
interface EmotionStarRouteParams {
  emotionTag: string
  heartOptionIndex: number
}

// 星图数据
interface StarDay {
  day: number
  label: string
  lit: boolean
}

@Entry
@Component
struct EmotionStarPage {
  @State emotionTag: string = '';
  @State heartOptionIndex: number = 0;
  @State starDays: StarDay[] = [
    { day: 1, label: '今日', lit: true },
    { day: 2, label: '明天', lit: false },
    { day: 3, label: '后天', lit: false },
    { day: 4, label: '第4天', lit: false },
    { day: 5, label: '第5天', lit: false },
    { day: 6, label: '第6天', lit: false },
    { day: 7, label: '第7天', lit: false },
  ];

  aboutToAppear(): void {
    const rawParams: Object | undefined = router.getParams();
    if (rawParams) {
      const params: EmotionStarRouteParams = rawParams as EmotionStarRouteParams;
      this.emotionTag = params.emotionTag || '关系边界';
      this.heartOptionIndex = params.heartOptionIndex || 0;
    }
  }

  /**
   * 回到结果页：优先 router.back()，失败时 fallback 到首页。
   * 逻辑与 AppBackButton.handleBack 等价（router.back + fallback HOME）。
   */
  private backToResultPage(): void {
    try {
      router.back();
    } catch (err) {
      hilog.error(0x0000, 'EmotionStarPage', 'Router back error, fallback to HOME');
      try {
        const options: router.RouterOptions = { url: Routes.HOME };
        router.replaceUrl(options);
      } catch (fallbackErr) {
        hilog.error(0x0000, 'EmotionStarPage', 'Router fallback error');
      }
    }
  }

  build() {
    Column() {
      // ── 左上角统一返回按钮 ──
      Row() {
        AppBackButton({ fallbackUrl: Routes.HOME })
      }
      .width('100%')
      .padding({ top: 48 })

      // ── Scroll 包裹主体内容，防止小屏挤出 ──
      Scroll() {
        Column() {
          // ══ 顶部点亮反馈区 ══
          Column() {
            Text('✨')
              .fontSize(40)
              .margin({ bottom: 10 })

            Text('你点亮了第 1 颗情绪星')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E5D9B6')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 6 })

            Text('今日星名：' + this.emotionTag)
              .fontSize(18)
              .fontColor('#CA8A04')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 32, bottom: 24 })

          // ══ 7 日情绪星轨卡片 ══
          Column() {
            // 卡片标题
            Text('7 日情绪星轨')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E5D9B6')
              .width('100%')
              .margin({ bottom: 6 })

            Text('再陪自己记录 6 天，星澜会帮你看见最近反复出现的心事。')
              .fontSize(13)
              .fontColor('#8B7A5C')
              .width('100%')
              .margin({ bottom: 14 })

            // 7 天列表（紧凑行高 48vp）
            ForEach(this.starDays, (item: StarDay) => {
              Row() {
                // 星标
                Text(item.lit ? '⭐' : '☆')
                  .fontSize(18)
                  .fontColor(item.lit ? '#D99A00' : '#3A3A5A')
                  .margin({ right: 14 })

                // 标签
                Text('Day ' + item.day + ' · ' + item.label)
                  .fontSize(15)
                  .fontColor(item.lit ? '#F8FAFC' : '#5A5A7A')
                  .layoutWeight(1)

                // 状态
                Text(item.lit ? '已点亮' : '未点亮')
                  .fontSize(13)
                  .fontColor(item.lit ? '#D99A00' : '#3A3A5A')
              }
              .width('100%')
              .height(48)
              .padding({ left: 4, right: 4 })
              .border({ width: { bottom: 0.5 }, color: 'rgba(46, 42, 74, 0.6)' })
            })
          }
          .width('88%')
          .padding({ left: 18, right: 18, top: 18, bottom: 18 })
          .backgroundColor('#17172F')
          .borderRadius(24)
          .border({ width: 1, color: '#2E2A4A' })
          .margin({ bottom: 24 })

          // ══ 底部陪伴文案 ══
          Text('再陪自己记录 6 天\n星澜会帮你看见最近反复出现的心事')
            .fontSize(16)
            .fontColor('#C8B88A')
            .textAlign(TextAlign.Center)
            .lineHeight(24)
            .width('82%')
            .margin({ bottom: 28 })

          // ══ 回到结果页按钮 ══
          Button('← 回到结果页')
            .type(ButtonType.Normal)
            .fontSize(17)
            .fontColor('#E5D9B6')
            .backgroundColor('#1A1A2E')
            .border({ width: 1, color: 'rgba(202, 138, 4, 0.35)' })
            .borderRadius(24)
            .width('76%')
            .height(48)
            .margin({ bottom: 48 })
            .onClick(() => {
              this.backToResultPage();
            })
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

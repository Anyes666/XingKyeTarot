/**
 * 每日运势 2×2 桌面万能卡片 UI
 * 通过 formBindingData 接收主 App 推送的数据。
 * 点击卡片跳转至每日运势详情页。
 */
let storage: LocalStorage = new LocalStorage();

@Entry(storage)
@Component
struct DailyFortuneWidget {
  @LocalStorageProp('cardName') cardName: string = '今日运势';
  @LocalStorageProp('cardKeyword') cardKeyword: string = '点击查看详情';
  @LocalStorageProp('isReversed') isReversed: number = 0;
  @LocalStorageProp('dateKey') dateKey: string = '';

  build() {
    Stack() {
      Column() {
        Row() {
          Text('⭐')
            .fontSize(12)

          Text('今日一占')
            .fontSize(12)
            .fontColor('#D8B45A')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 4 })
        }
        .margin({ bottom: 8 })

        Text(this.cardName)
          .fontSize(16)
          .fontColor('#F8F3E7')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.isReversed === 1) {
          Text('逆位')
            .fontSize(10)
            .fontColor('#F4C7C3')
            .margin({ top: 2 })
        }

        Text(this.cardKeyword)
          .fontSize(13)
          .fontColor('#5ED7D2')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })

        Blank()

        Text('点击查看详情')
          .fontSize(10)
          .fontColor('#6B6380')
      }
      .width('100%')
      .height('100%')
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#080B18')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [
        ['#080B18', 0.0],
        ['#10172F', 1.0]
      ]
    })
    .borderRadius(18)
    .clip(true)
    .border({ width: 0.5, color: 'rgba(216, 180, 90, 0.12)' })
    .onClick(() => {
      postCardAction(this, {
        'action': 'router',
        'abilityName': 'EntryAbility',
        'params': {
          'targetPage': 'dailyFortune'
        }
      });
    })
  }
}

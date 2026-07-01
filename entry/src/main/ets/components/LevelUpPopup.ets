import { Theme } from '../common/Theme';
import { EmotionStarStorage, StarKeyLevel } from '../common/EmotionStarStorage';

/**
 * LevelUpPopup — 星钥等级提升弹窗（C 方案烫金 + 衬线称号）
 *
 * 功能：底部滑入弹窗，展示新等级称号 + 勋章 + 寄语 + 继续旅程按钮
 * 动效：translateY(100%) → 0，duration 220ms，EaseOut
 * 称号数据：来自 EmotionStarStorage.LEVELS（0/1/7/21/30/90/180/365天对应8级）
 *
 * 使用示例：
 *   LevelUpPopup({
 *     show: this.showLevelUp,
 *     levelTitle: this.currentLevelTitle,
 *     levelDays: this.currentLevelDays,
 *     onClose: () => { this.showLevelUp = false; }
 *   })
 */
@Component
export struct LevelUpPopup {
  /** 是否显示 */
  @Prop show: boolean = false;
  /** 当前称号 */
  @Prop levelTitle: string = '';
  /** 当前天数（阈值） */
  @Prop levelDays: number = 0;
  /** 关闭回调 */
  onClose: () => void = () => {};
  /** 弹窗滑入偏移量（动画驱动） */
  @State private slideOffset: number = 100;

  aboutToAppear(): void {
    // 初始状态：弹窗在屏幕下方
    this.slideOffset = 100;
  }

  build() {
    if (this.show) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.V2_OVERLAY_SCRIM)
          .onClick(() => {
            this.handleClose();
          })

        // 弹窗主体（底部滑入）
        Column() {
          // 弹窗内容卡片
          Column() {
            // 勋章图标
            Text('✦')
              .fontSize(40)
              .fontColor(Theme.V2C_GOLD_GILT)
              .margin({ bottom: Theme.V2_SPACE_SM })

            // 烫金横线（上方装饰）
            Row()
              .width(48)
              .height(2)
              .backgroundColor(Theme.V2C_GOLD_GILT)
              .borderRadius(1)
              .margin({ bottom: Theme.V2_SPACE_MD })

            // 提示文字
            Text('星钥等级提升')
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .letterSpacing(2)
              .margin({ bottom: Theme.V2_SPACE_SM })

            // 称号大字（衬线体）
            Text(this.levelTitle)
              .fontSize(Theme.V2C_FONT_GILT_TITLE)
              .fontColor(Theme.V2C_GOLD_GILT_SOFT)
              .fontWeight(FontWeight.Bold)
              .fontFamily('HarmonyOS Serif')
              .margin({ bottom: Theme.V2_SPACE_2XS })

            // 天数标记（等宽字体，A 方案标记感）
            Text(this.levelDays.toString() + ' 天')
              .fontSize(Theme.V2A_FONT_TIMESTAMP)
              .fontColor(Theme.V2C_TEXT_SECONDARY)
              .fontFamily('HarmonyOS Sans Mono')
              .letterSpacing(1)
              .margin({ bottom: Theme.V2_SPACE_LG })

            // 寄语文案
            Text(this.getLevelMessage(this.levelTitle))
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_TEXT_PRIMARY)
              .lineHeight(24)
              .textAlign(TextAlign.Center)
              .width('80%')
              .margin({ bottom: Theme.V2_SPACE_XL })

            // 烫金横线（下方装饰）
            Row()
              .width(48)
              .height(1)
              .backgroundColor(Theme.V2C_GOLD_GILT)
              .opacity(0.5)
              .borderRadius(1)
              .margin({ bottom: Theme.V2_SPACE_LG })

            // 继续旅程按钮
            Button('继续旅程')
              .type(ButtonType.Normal)
              .width('70%')
              .height(48)
              .fontSize(Theme.V2C_FONT_BODY)
              .fontColor(Theme.V2C_BG_BASE)
              .fontWeight(FontWeight.Bold)
              .backgroundColor(Theme.V2C_GOLD_GILT)
              .borderRadius(Theme.V2C_RADIUS_BTN)
              .onClick(() => {
                this.handleClose();
              })
          }
          .width('88%')
          .padding({
            top: Theme.V2_SPACE_2XL,
            bottom: Theme.V2_SPACE_2XL,
            left: Theme.V2_SPACE_LG,
            right: Theme.V2_SPACE_LG
          })
          .backgroundColor(Theme.V2C_BG_FLOATING)
          .borderRadius(Theme.V2C_RADIUS_POPUP)
          .border({ width: 1, color: Theme.V2C_GOLD_GILT })
          .shadow(Theme.V2C_SHADOW_CARD)
          .translate({ y: this.slideOffset })
          .animation({
            duration: Theme.V2_ANIM_POPUP,
            curve: Theme.V2_EASE_OUT
          })
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.End)
        .padding({ bottom: Theme.V2_SPACE_3XL })
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
  }

  /**
   * 处理关闭：先触发滑出动画再回调
   */
  private handleClose(): void {
    this.slideOffset = 100;
    this.onClose();
  }

  /**
   * 根据称号获取寄语文案
   * 阈值表（5.4）：0/1/7/21/30/90/180/365天
   */
  private getLevelMessage(title: string): string {
    if (title === '初见') {
      return '星澜在这里，等你来记录第一颗情绪星。';
    }
    if (title === '星火初亮') {
      return '第一颗星已经亮起，你开始了。';
    }
    if (title === '七日星轨') {
      return '七颗星，连成了一条小小的轨道。';
    }
    if (title === '月下自省者') {
      return '二十一天，你养成了看见自己的习惯。';
    }
    if (title === '星钥守望者') {
      return '一个月了，谢谢你一直记得留一点时间给自己。';
    }
    if (title === '星河同行者') {
      return '九十天，你已在这条星河中走了很久。';
    }
    if (title === '半年听心者') {
      return '半年了，你陪伴自己走过了半个年头。';
    }
    if (title === '长夜星澜') {
      return '一年了，你就是星澜一直等待的那个人。';
    }
    return '愿你继续温柔地看见自己。';
  }
}

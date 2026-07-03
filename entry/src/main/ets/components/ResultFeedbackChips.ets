import { router } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';

/**
 * 反馈 Chip 配置项（C 星钥之书风格 · RESULT-1）
 */
interface FeedbackChipConfig {
  key: string;
  label: string;
  reply: string;
  /** 是否在纠偏文案下方展示「去和星澜聊聊」轻入口 */
  showChatEntry: boolean;
  /** 是否触发安静模式（隐藏该结果页后续解释推送） */
  triggersQuiet: boolean;
}

/**
 * 结果页反馈 Chips（C 星钥之书风格）
 *
 * 五 Chips 反馈与纠偏文案，允许用户说"这部分不太像我"。
 * - "这句话有点像我"：温和承接，邀请说说是哪一句。
 * - "有一部分不太像"：内部 userAcceptedInterpretation=false，回复牌意只是角度。
 * - "帮我继续理一理"：纠偏文案 + 跳转星澜聊天入口（本轮不携带上下文）。
 * - "我只想安静一会儿"：触发 quietMode，不在该结果页继续推送解释。
 * - "给我一个很小的建议"：纠偏文案 + 跳转星澜聊天入口。
 *
 * Chips 圆角在默认/按压/选中状态一致（统一 V2C_RADIUS_CHIP）。
 */
@Component
export struct ResultFeedbackChips {
  /** 安静模式（双向绑定）。用户点"我只想安静一会儿"时置 true，父页面可据此隐藏解释推送入口。 */
  @Link quietMode: boolean;

  @State private selectedKey: string = '';
  @State private userAcceptedInterpretation: boolean = true;
  @State private chatEntryPressed: boolean = false;

  private CHIP_CONFIGS: FeedbackChipConfig[] = [
    {
      key: 'like',
      label: '这句话有点像我',
      reply: '那一小段停顿，可能就是值得再看一眼的地方。\n\n愿意的话，可以说说是哪一句。',
      showChatEntry: false,
      triggersQuiet: false,
    },
    {
      key: 'unlike',
      label: '有一部分不太像',
      reply: '那就不用勉强把牌意套在自己身上。\n\n牌只是一个角度。\n你的真实感受始终比牌面更重要。',
      showChatEntry: false,
      triggersQuiet: false,
    },
    {
      key: 'continue',
      label: '帮我继续理一理',
      reply: '可以。\n\n我们先不急着找答案，\n只把最纠结的那一部分说清楚。',
      showChatEntry: true,
      triggersQuiet: false,
    },
    {
      key: 'quiet',
      label: '我只想安静一会儿',
      reply: '好。\n\n这里没有需要立刻回答的问题。',
      showChatEntry: false,
      triggersQuiet: true,
    },
    {
      key: 'small_advice',
      label: '给我一个很小的建议',
      reply: '可以先做一件很小的事：\n\n把最困扰你的那句话写下来，\n暂时不用回答它。',
      showChatEntry: true,
      triggersQuiet: false,
    },
  ];

  /**
   * 点击 Chip：更新选中态、接受状态、安静模式
   */
  private onChipClick(key: string): void {
    if (this.selectedKey === key) {
      return;
    }
    this.selectedKey = key;
    if (key === 'unlike') {
      this.userAcceptedInterpretation = false;
    }
    if (key === 'quiet') {
      this.quietMode = true;
    }
  }

  /**
   * 取当前选中 Chip 的纠偏文案
   */
  private getReplyText(): string {
    for (let i = 0; i < this.CHIP_CONFIGS.length; i++) {
      if (this.CHIP_CONFIGS[i].key === this.selectedKey) {
        return this.CHIP_CONFIGS[i].reply;
      }
    }
    return '';
  }

  /**
   * 当前选中 Chip 是否需要展示跳转星澜聊天入口
   */
  private needChatEntry(): boolean {
    for (let i = 0; i < this.CHIP_CONFIGS.length; i++) {
      if (this.CHIP_CONFIGS[i].key === this.selectedKey) {
        return this.CHIP_CONFIGS[i].showChatEntry;
      }
    }
    return false;
  }

  /**
   * 跳转星澜聊天入口页（本轮仅跳转，不携带上下文，上下文留 FLOW-1）
   */
  private goToXinglanChat(): void {
    try {
      router.pushUrl({ url: Routes.XINGLAN_CHAT_ENTRANCE });
    } catch (_err) {
      // ignore
    }
  }

  build() {
    Column() {
      // ── 标题行 ──
      Row() {
        Text('这一段，你觉得像你吗？')
          .fontSize(Theme.V2C_FONT_SUBTITLE)
          .fontColor(Theme.V2C_GOLD_GILT)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('反馈')
          .fontSize(Theme.V2C_FONT_CAPTION)
          .fontColor(Theme.V2C_TEXT_SECONDARY)
      }
      .width('100%')
      .margin({ bottom: Theme.V2_SPACE_MD })

      // 烫金细线分隔
      Row()
        .width(42)
        .height(1)
        .backgroundColor(Theme.V2C_GOLD_GILT)
        .opacity(0.26)
        .margin({ bottom: Theme.V2_SPACE_MD })

      // ── 五 Chips（圆角统一，暖金克制）──
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.CHIP_CONFIGS, (config: FeedbackChipConfig) => {
          Text(config.label)
            .fontSize(Theme.V2C_FONT_CAPTION)
            .fontColor(this.selectedKey === config.key ? Theme.V2C_GOLD_GILT_SOFT : Theme.V2C_TEXT_SECONDARY)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: Theme.V2_SPACE_XS, bottom: Theme.V2_SPACE_XS })
            .backgroundColor(
              this.selectedKey === config.key
                ? 'rgba(197, 160, 80, 0.16)'
                : 'rgba(197, 160, 80, 0.06)'
            )
            .borderRadius(Theme.V2C_RADIUS_CHIP)
            .border({
              width: 1,
              color: this.selectedKey === config.key
                ? 'rgba(197, 160, 80, 0.55)'
                : 'rgba(197, 160, 80, 0.20)'
            })
            .onClick(() => {
              this.onChipClick(config.key);
            })
        }, (config: FeedbackChipConfig) => config.key)
      }
      .width('100%')

      // ── 纠偏文案（选中后显示）──
      if (this.selectedKey.length > 0) {
        Column() {
          Text(this.getReplyText())
            .fontSize(Theme.V2C_FONT_BODY)
            .fontColor(Theme.V2C_TEXT_PRIMARY)
            .lineHeight(25)
            .width('100%')
            .margin({ top: Theme.V2_SPACE_MD })

          // ── 跳转星澜聊天入口（仅 continue / small_advice）──
          if (this.needChatEntry()) {
            Text('去和星澜聊聊')
              .fontSize(Theme.V2C_FONT_CAPTION)
              .fontColor(Theme.V2C_GOLD_GILT)
              .textAlign(TextAlign.Center)
              .width('100%')
              .constraintSize({ minHeight: 44 })
              .padding({ top: 12, bottom: 12 })
              .margin({ top: Theme.V2_SPACE_XS })
              .opacity(this.chatEntryPressed ? 0.6 : 1.0)
              .onClick(() => {
                this.goToXinglanChat();
              })
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.chatEntryPressed = true;
                } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                  this.chatEntryPressed = false;
                }
              })
          }
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.V2_SPACE_LG)
    .backgroundColor(Theme.V2C_BG_CARD)
    .borderRadius(Theme.V2C_RADIUS_CARD)
    .border({ width: 1, color: 'rgba(197, 160, 80, 0.14)' })
    .margin({ top: Theme.V2_SPACE_MD })
  }
}

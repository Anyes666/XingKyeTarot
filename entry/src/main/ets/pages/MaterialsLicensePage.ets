import { Theme } from '../common/Theme';
import { Routes } from '../common/Routes';
import { AppBackButton } from '../components/AppBackButton';

/**
 * 授权条目接口
 */
interface LicenseEntry {
  title: string;
  content: string;
}

/**
 * Phase 6.5：素材与授权页面
 * 展示背景音乐、音效、插画/图标、字体、开源库、AI生成素材说明、授权说明、使用说明、联系方式
 */
@Entry
@Component
struct MaterialsLicensePage {
  private sections: LicenseEntry[] = [
    {
      title: '一、背景音乐',
      content:
        '感谢以下创作者与平台提供音乐素材支持。\n「星钥塔罗」App 中使用的背景音乐、音效及其他素材，均依据其对应授权协议使用。\n\n' +
        '1. Calm Ambient\n' +
        '作者：leberch\n' +
        '来源：Pixabay\n' +
        '授权：Pixabay Content License\n' +
        '用途：首页 / 今日星钥 / 星澜相关页面背景音乐\n' +
        '修改说明：已根据 App 使用场景进行音量调整与循环适配。\n\n' +
        '2. Reminiscing\n' +
        '作者：Kevin MacLeod\n' +
        '来源：Incompetech\n' +
        '授权：Creative Commons Attribution 4.0 International\n' +
        '用途：星澜聊天 / 情绪陪伴 / 关系探索页面背景音乐\n' +
        '修改说明：已根据 App 使用场景进行音量调整与循环适配。\n\n' +
        '3. Midsummer Sky\n' +
        '作者：Kevin MacLeod\n' +
        '来源：Incompetech\n' +
        '授权：Creative Commons Attribution 4.0 International\n' +
        '用途：今日星钥 / 分享卡 / 轻陪伴页面背景音乐\n' +
        '修改说明：已根据 App 使用场景进行音量调整与循环适配。\n\n' +
        '4. Friday Morning\n' +
        '作者：Kevin MacLeod\n' +
        '来源：Incompetech\n' +
        '授权：Creative Commons Attribution 4.0 International\n' +
        '用途：首页 / 关系探索 / 低压力陪伴页面背景音乐\n' +
        '修改说明：已根据 App 使用场景进行音量调整与循环适配。\n\n' +
        '5. Touching Story\n' +
        '作者：Kevin MacLeod\n' +
        '来源：Incompetech\n' +
        '授权：Creative Commons Attribution 4.0 International\n' +
        '用途：分享卡生成 / 情绪提示 / 短时过场背景音乐\n' +
        '修改说明：已根据 App 使用场景进行音量调整与循环适配。'
    },
    {
      title: '二、音效',
      content:
        '当前版本暂未使用独立音效素材。\n后续如使用点击音、翻牌音、过场音等音效，将在此页面补充来源与授权说明。'
    },
    {
      title: '三、插画 / 图标素材',
      content:
        '当前版本中的星澜形象、启动页插画、应用图标及部分视觉素材，可能包含 AI 辅助生成或人工调整内容。\n如使用第三方插画、图标或素材平台资源，将在此处列明作者、来源、授权协议及修改说明。'
    },
    {
      title: '四、字体',
      content:
        '当前版本主要使用系统默认字体。\n如后续引入第三方字体文件，将在此处补充字体名称、作者、来源与授权协议。'
    },
    {
      title: '五、开源库',
      content:
        '本应用使用的开源库将根据实际工程依赖进行整理。\n如涉及需署名或需附带许可证文本的开源项目，将在此处列明项目名称、许可证类型及项目地址。'
    },
    {
      title: '六、AI 生成素材说明',
      content:
        '本应用中的部分插画、图标、启动页背景或视觉氛围素材可能使用 AI 工具辅助生成，并经过人工筛选、调整和适配。\n\n' +
        'AI 生成素材仅用于应用视觉呈现，不用于冒充真实人物、真实摄影作品或特定在世艺术家的原创作品。\n' +
        '如后续使用第三方 AI 生成平台且该平台要求署名或声明，将在此处补充说明。'
    },
    {
      title: '七、授权说明',
      content:
        'Pixabay 素材依据 Pixabay Content License 使用。\n该授权允许在符合许可条款的前提下免费使用、修改和适配素材。\n\n' +
        'Kevin MacLeod / Incompetech 音乐依据 Creative Commons Attribution 4.0 International 授权使用。\n' +
        '根据该授权要求，本应用对相关音乐进行作者署名，并标明来源、授权协议及修改情况。\n\n' +
        '上线前请人工核验每首音乐对应页面的署名要求和授权说明。\n本页面不构成法律意见。'
    },
    {
      title: '八、使用说明',
      content:
        '上述音乐仅作为「星钥塔罗」App 内的背景音乐、页面氛围音乐或过场音乐使用。\n' +
        '本应用不会将上述音乐作为独立音频素材进行售卖、转售、下载分发或曲库形式提供。'
    },
    {
      title: '九、联系方式',
      content:
        '若您认为本应用中的素材使用存在授权、署名或其他版权问题，请通过应用商店页面或开发者公开联系方式与我们联系。我们会在核实后及时处理。'
    }
  ];

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG_DEEP_INDIGO)

      Column() {
        // 顶部安全区 + 返回按钮
        Row() {
          AppBackButton({ fallbackUrl: Routes.ABOUT })
        }
        .width('100%')
        .height(56)
        .padding({ top: Theme.SAFE_TOP, left: Theme.SPACE_SM, right: Theme.SPACE_SM })
        .alignItems(VerticalAlign.Center)

        // 标题
        Text('素材与授权')
          .fontSize(Theme.FONT_HEADLINE)
          .fontColor(Theme.GOLD_LIGHT)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACE_MD, bottom: Theme.SPACE_LG })

        // 内容滚动区
        Scroll() {
          Column() {
            ForEach(this.sections, (section: LicenseEntry, index: number) => {
              Column() {
                // 分区标题
                Text(section.title)
                  .fontSize(Theme.FONT_SUBTITLE)
                  .fontColor(Theme.GOLD_LIGHT)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .margin({ bottom: Theme.SPACE_SM })

                // 分区内容
                Text(section.content)
                  .fontSize(Theme.FONT_BODY)
                  .fontColor(Theme.TEXT_PRIMARY_LIGHT)
                  .lineHeight(26)
                  .width('100%')
              }
              .width('92%')
              .backgroundColor('rgba(27, 27, 48, 0.52)')
              .borderRadius(Theme.RADIUS_MD)
              .padding(Theme.SPACE_MD)
              .margin({ bottom: Theme.SPACE_SM })
            }, (_section: LicenseEntry, index: number) => 'license_' + index.toString())

            // 底部间距
            Column()
              .height(48)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: Theme.SPACE_SM })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
  }
}

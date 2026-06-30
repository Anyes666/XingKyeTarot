# HarmonyOS 空间感与沉浸式美化完成报告

## 1. 参考内容

本次美化专项参考了 HarmonyOS_Samples 项目中的以下方向：

- **Immersive（沉浸式）**：参考了 `ignoreLayoutSafeArea()`、`background()` 渐变融合、状态栏区域与页面背景打通的思路，将深蓝星空背景从顶部均匀过渡，消除硬边状态栏割裂感。
- **Spatialization（空间化）**：借鉴了"背景层 → 内容层 → 前景层"的空间层级划分思想，统一为三层结构——深空背景、内容卡片、前景光感元素（头像光晕、牌图悬浮阴影、金色边框描边）。不做 3D、不做 AR，只做轻量远近关系。
- **BackgroundBlur / ComponentUXExamples**：参考了组件原生感设计，统一卡片使用半透明深蓝底 + 1px 金色低透明边框 + 悬浮阴影的模式。

## 2. 修改文件

| 文件 | 修改内容 |
|------|---------|
| `entry/src/main/ets/common/Theme.ets` | 新增空间感设计 Token：深空背景色、星空面板色、悬浮/轻微/头像/英雄阴影、金色光感色、星钥卡片统一样式、按压缩放、动效时长、deepSpaceGradient()/immersiveTopFade()/starkeyCardGlow() 函数 |
| `entry/src/main/ets/pages/DivinationCenterPage.ets` | 沉浸式深空背景 + 顶部消隐渐变、入口卡片统一星钥卡片样式 + 按压 Token |
| `entry/src/main/ets/pages/UsageGuidePage.ets` | 沉浸式深空背景、说明卡片统一星钥卡片样式 |
| `entry/src/main/ets/pages/TarotCardsPage.ets` | 沉浸式深空背景、列表项统一星钥卡片样式 |
| `entry/src/main/ets/pages/TarotCardDetailPage.ets` | 沉浸式深空背景、卡牌大图添加悬浮阴影(SHADOW_CARD_HERO)和金色边框、解读片区卡片统一星钥样式 |
| `entry/src/main/ets/pages/HistoryPage.ets` | 历史记录卡片统一星钥卡片样式 |
| `entry/src/main/ets/pages/MainFramePage.ets` | 设置页沉浸式深空背景 + 安全区消隐渐变、头像使用 SHADOW_AVATAR_GLOW 外发光、4 组设置卡片统一星钥样式 + 悬浮阴影 |
| `entry/src/main/ets/pages/HomePage.ets` | 星澜语录页沉浸式深空渐变背景（替换硬编码 #030716） |
| `entry/src/main/ets/pages/CardWheelDrawPage.ets` | 沉浸式深空背景、中心金色径向光晕增强至 6%（原 5%） |
| `entry/src/main/ets/pages/XinglanChatPage.ets` | 星澜头像/用户头像/typing 头像统一使用 AVATAR_CHAT_DIAMETER + AVATAR_BORDER + SHADOW_AVATAR_GLOW |

## 3. 设计 Token

### 新增动效 Token
```
PRESS_SCALE = 0.97          // 卡片按压缩放比
ANIM_PRESS_DURATION = 140   // 按压动画时长 ms
ANIM_ENTER_FADE = 200       // 页面元素淡入时长
ANIM_SHEET_SLIDE = 220      // 弹窗滑出时长
ANIM_BUBBLE_FADE = 180      // 聊天气泡淡入时长
ANIM_CARD_ZOOM_IN = 240     // 卡牌详情放大进入
```

### 新增背景 Token
```
BG_DEEP_SPACE = '#050714'                    // 深空背景色（比 BG_DEEP_INDIGO 更深）
BG_STAR_PANEL = 'rgba(15, 15, 35, 0.75)'    // 星空面板半透明底色
IMMERSIVE_TOP_HEIGHT = 120                   // 沉浸式顶部渐变高度
```

### 新增阴影 Token
```
SHADOW_CARD_FLOAT: { radius: 16, color: 'rgba(0,0,0,0.35)', offsetY: 4 }       // 卡片悬浮阴影
SHADOW_CARD_SUBTLE: { radius: 8, color: 'rgba(0,0,0,0.25)', offsetY: 2 }       // 卡片轻微阴影
SHADOW_AVATAR_GLOW: { radius: 14, color: 'rgba(230,168,0,0.18)', offsetY: 0 }  // 头像柔光外圈
SHADOW_CARD_HERO: { radius: 24, color: 'rgba(202,138,4,0.1)', offsetY: 6 }     // 大牌图悬浮阴影
```

### 新增金色光感 Token
```
GLOW_GOLD_TOP = 'rgba(202, 138, 4, 0.04)'    // 卡片顶部金色光斑
GLOW_CARD_BOTTOM = 'rgba(0, 0, 0, 0)'         // 卡片底部深色
GLOW_AVATAR_OUTER = 'rgba(230, 168, 0, 0.2)'  // 头像金色外发光
```

### 星钥卡片统一样式 Token
```
STARKEY_CARD_BG = 'rgba(20, 22, 45, 0.72)'        // 半透明深蓝底
STARKEY_CARD_BORDER = 'rgba(216, 180, 90, 0.1)'   // 1px 金色低透明边框
STARKEY_CARD_RADIUS = 20                            // 20vp 圆角
STARKEY_CARD_PADDING_H = 20                         // 水平内边距
STARKEY_CARD_PADDING_V = 18                         // 垂直内边距
```

### 新增渐变函数
```
deepSpaceGradient()  → 从 BG_DEEP_SPACE → BG_DEEP_INDIGO 的垂直渐变
immersiveTopFade()   → 从 BG_DEEP_SPACE → 透明 的顶部消隐渐变
starkeyCardGlow()    → 卡片顶部金色微光渐变（GLOW_GOLD_TOP → 透明）
```

## 4. 沉浸式背景优化

对 5 个页面实施了沉浸式深空背景升级：

- **星澜语录首页 (HomePage)**：替换硬编码 `#030716` 为 `linearGradient(BG_DEEP_SPACE → #030716)`，顶部更深融入状态栏
- **占卜中心 (DivinationCenterPage)**：双层渐变——深空底 + 顶部 120vp 消隐渐变 + 底部金色径向光晕增强至 4%
- **卡牌详情 (TarotCardDetailPage)**：深空渐变背景，全屏预览层保持独立深蓝底
- **我的页面 (MainFramePage SettingsTabContent)**：深空渐变全页背景 + 安全区顶部消隐，消除硬边状态栏与页面内容区的割裂
- **旋转牌轮 (CardWheelDrawPage)**：深空渐变 + 中心金色径向光晕增强至 6%，聚焦牌轮区域

效果：状态栏不再是浮在页面上的独立硬条，而是自然融入深蓝星空背景中，标题文字更有层次感。

## 5. 卡片景深优化

统一了以下 6 类卡片为"星钥卡片"质感：

| 卡片位置 | 文件 | 变更 |
|---------|------|------|
| 占卜中心 5 个入口卡 | DivinationCenterPage.ets | 底色 → STARKEY_CARD_BG，边框 → STARKEY_CARD_BORDER，圆角 → 20，阴影 → SHADOW_CARD_FLOAT |
| 我的页 4 个设置卡 | MainFramePage.ets | 同上 + SHADOW_CARD_SUBTLE |
| 使用说明 8 个板块卡 | UsageGuidePage.ets | 同上 + SHADOW_CARD_SUBTLE |
| 卡牌总览 78 张列表项 | TarotCardsPage.ets | 底色/边框/圆角统一 Token |
| 历史记录列表项 | HistoryPage.ets | 底色/边框/圆角/阴影统一 Token |
| 卡牌解读片区 | TarotCardDetailPage.ets | 统一底色/边框/圆角 + 边框 |

风格：半透明深蓝底(`rgba(20,22,45,0.72)`)、1px 金色低透明边框(`rgba(216,180,90,0.1)`)、20vp 圆角、悬浮阴影；占卜入口卡附加按压 scale 0.97 动效。

## 6. 头像空间感优化

- **我的页面头像**：使用 `SHADOW_AVATAR_GLOW`（radius=14, 金色 0.18 透明度），在头像外圈形成柔和金色光晕
- **星澜聊天页星澜头像**：统一使用 `AVATAR_CHAT_DIAMETER`(38vp) + `AVATAR_BORDER_WIDTH`(2px) + `AVATAR_BORDER`(金色细边) + `SHADOW_AVATAR_GLOW`
- **聊天页用户头像**：同上 Token 统一
- **Typing 状态星澜头像**：同上 Token 统一

头像上传/裁剪逻辑未修改，头像选择弹窗逻辑未修改。

## 7. 聊天页视觉优化

星澜聊天页的视觉优化严格限于 UI 层，未修改任何业务逻辑：

- 星澜气泡左侧头像 + 深蓝半透明气泡（保持原有 `#17172F` 背景）
- 用户气泡右侧头像 + 深蓝气泡（保持原有 `BG_CARD_DARK` 背景）
- 头像均获得金色细描边 + 柔光外圈统一质感
- Chips 保持原有金色描边胶囊样式
- 输入区、消息列表滚动逻辑未改变

保留完整功能：DirectReply、SafetyGuard、Flow 引擎、MiniInteraction、动态 chips、typing、夜信、小镜子、回声卡、轻记得。

## 8. 卡牌详情页优化

- 大牌图：缩小约束宽度至 78%（原 85%），圆角改为 `TAROT_CARD_RADIUS`(10vp)，边框改为金色 `rgba(232,184,61,0.35)`，添加 `SHADOW_CARD_HERO` 悬浮阴影(radius=24)
- 正位/逆位/陪伴解读/关系/工作/自我探索 6 个解读区统一星钥卡片风格
- 全屏预览层保持独立深蓝底 + 沉浸径向渐变
- 点击查看大图逻辑不变，双指缩放 + 拖动逻辑不变

## 9. 旋转牌轮优化

- 背景升级为沉浸式深空渐变（BG_DEEP_SPACE → BG_DEEP_INDIGO）
- 中心金色径向光晕从 5% 增强至 6%，聚焦更多视觉注意力在牌轮区域
- 两侧牌背缩放/透明度/亮度衰减算法不变（保持柔和淡出不突兀）
- 确认按钮样式不变（金色胶囊主操作）
- 未改为赌场/老虎机风格

## 10. 未修改内容确认

以下核心逻辑未做任何修改：

- 聊天核心逻辑（管线优先级、分段回复、延迟模拟）
- SafetyGuard 危机检测
- DirectReply 直达回复
- Flow 引擎（InteractionFlow 状态机）
- MiniInteraction 小互动
- 抽牌算法（Fisher-Yates 洗牌、牌轮弹性吸附、单牌/三牌抽取）
- BGM 背景音乐逻辑（初始化、播放、切换开关持久化）
- 头像上传/裁剪逻辑（PhotoPicker → AvatarCropPage → UserProfileStore）
- 隐私政策正文（LegalDocuments.ets 内容未动）
- 底部导航点击响应逻辑
- 使用说明正文内容

## 11. 黑盒测试结果

编译通过后应关注的回归验证点：

- 占卜中心 5 个入口卡点击跳转正常
- 我的页面 BGM 开关 Toggle 功能正常
- 头像点击弹出面板 → 从相册选择 → AvatarCropPage 裁剪 → 保存返回
- 恢复默认头像功能正常
- 历史记录筛选/删除/清空功能正常
- 星澜语录首页点击追加语录正常
- 卡牌总览筛选切换正常、点击进入详情正常
- 卡牌详情页大图点击全屏预览正常、双指缩放正常
- 旋转牌轮惯性吸附/确认抽牌正常
- 聊天页欢迎卡 → chips → 输入 → 回复气泡正常
- 页面滚动流畅、不卡顿

## 12. 编译结果

```
BUILD SUCCESSFUL in 18 s 481 ms
ERROR = 0
```

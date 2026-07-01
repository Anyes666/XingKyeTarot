/**
 * 星钥塔罗 — 全局主题 Token
 * 新中式星空风格：深蓝紫底色 + 温润金色点缀 + 青绿极光辅助
 */

/** 卡片尺寸描述接口 */
interface CardSize {
  width: number;
  height: number;
}

export class Theme {
  // ── 背景色 ──
  static readonly BG_PRIMARY: string = '#10172F';
  static readonly BG_DEEP: string = '#080B18';
  static readonly BG_CARD: string = '#171D3A';
  static readonly BG_OVERLAY: string = 'rgba(8, 11, 24, 0.85)';

  // ── 点缀色 ──
  static readonly GOLD: string = '#D8B45A';
  static readonly GOLD_SOFT: string = '#F1DFA5';
  static readonly GOLD_DIM: string = '#8B7340';

  // ── 辅助色 ──
  static readonly AURORA: string = '#5ED7D2';
  static readonly AURORA_SOFT: string = '#A8EDEA';
  static readonly PURPLE_MIST: string = '#8B7EC8';
  static readonly PURPLE_SOFT: string = '#C4BDF0';

  // ── 文字色 ──
  static readonly TEXT_PRIMARY: string = '#F8F3E7';
  static readonly TEXT_SECONDARY: string = '#B8B0C8';
  static readonly TEXT_MUTED: string = '#6B6380';

  // ── 功能色 ──
  static readonly DANGER_SOFT: string = '#F4C7C3';
  static readonly SUCCESS_SOFT: string = '#B8E6C8';

  // ── MVP P0 新增：极深靛蓝底 + 琥珀金主色（Ardot 原型色板）──
  static readonly BG_DEEP_INDIGO: string = '#0F0F23';
  static readonly BG_CARD_DARK: string = '#1B1B30';
  static readonly BG_CARD_LIGHTER: string = '#242440';

  // 琥珀金系统
  static readonly GOLD_AMBER: string = '#CA8A04';
  static readonly GOLD_LIGHT: string = '#E5A50A';
  static readonly GOLD_PALE: string = '#F5D77A';

  // ── 黑金按钮配色（ShareCard 保存按钮专用）──
  static readonly GOLD_MAIN: string = '#D99A00';
  static readonly BTN_DARK_TEXT: string = '#0F0F23';

  // 月白色（高亮文字）
  static readonly TEXT_PRIMARY_LIGHT: string = '#F8FAFC';
  static readonly MOON_MUTED: string = '#94A3B8';

  // 深星色（边框/分割线）
  static readonly DEEP_STARRY: string = '#2A2A4A';

  // 危险操作红（MVP 新增）
  static readonly DANGER_RED: string = '#EF4444';

  // ── 个人中心 / 头像新增 Token ──
  static readonly AVATAR_BORDER: string = 'rgba(230, 168, 0, 0.65)';
  static readonly AVATAR_GLOW: string = 'rgba(230, 168, 0, 0.15)';
  static readonly CARD_BORDER_GOLD: string = 'rgba(212, 160, 42, 0.22)';
  static readonly CARD_BORDER_GOLD_SUBTLE: string = 'rgba(212, 160, 42, 0.12)';
  static readonly BUBBLE_BORDER: string = 'rgba(230, 168, 0, 0.18)';
  static readonly BUBBLE_BG_XINGLAN: string = '#17172F';
  static readonly CHIP_BG: string = 'rgba(202, 138, 4, 0.08)';
  static readonly CHIP_BORDER: string = 'rgba(202, 138, 4, 0.2)';

  // ── 头像相关尺寸 ──
  static readonly AVATAR_CHAT_DIAMETER: number = 38;    // 聊天头像直径
  static readonly AVATAR_PROFILE_DIAMETER: number = 88;  // 我的页面头像直径
  static readonly AVATAR_BORDER_WIDTH: number = 2;       // 头像描边宽度
  static readonly AVATAR_NAV_DIAMETER: number = 42;      // 导航栏星钥图标直径

  // ── 间距 ──
  static readonly SPACE_XS: number = 4;
  static readonly SPACE_SM: number = 8;
  static readonly SPACE_MD: number = 16;
  static readonly SPACE_LG: number = 24;
  static readonly SPACE_XL: number = 32;
  static readonly SPACE_XXL: number = 48;

  // ── 圆角 ──
  static readonly RADIUS_SM: number = 6;
  static readonly RADIUS_MD: number = 12;
  static readonly RADIUS_LG: number = 20;
  static readonly RADIUS_FULL: number = 999;

  // ── 字号 ──
  static readonly FONT_CAPTION: number = 12;
  static readonly FONT_BODY: number = 15;
  static readonly FONT_SUBTITLE: number = 18;
  static readonly FONT_TITLE: number = 24;
  static readonly FONT_HEADLINE: number = 32;

  // ── MVP 新增字号 ──
  static readonly FONT_DISPLAY: number = 36;
  static readonly FONT_CARD_NAME: number = 28;
  static readonly FONT_FOLLOWUP: number = 17;

  // ── MVP 新增间距 ──
  static readonly SPACE_RESULT_GAP: number = 40;
  static readonly SPACE_SCREEN_PAD: number = 24;

  // ── 卡片尺寸 ──
  static readonly TAROT_CARD_WIDTH: number = 100;
  static readonly TAROT_CARD_HEIGHT: number = 160;
  static readonly TAROT_CARD_RADIUS: number = 10;
  static readonly TAROT_CARD_ASPECT_RATIO: number = 1.6; // height / width

  // ── 统一卡片尺寸常量（P0.3 整改）──
  /** 单牌结果页大卡 */
  static readonly CARD_SIZE_SINGLE_RESULT: CardSize = { width: 140, height: 224 };
  /** 三牌结果页/分享卡/历史详情统一尺寸 */
  static readonly CARD_SIZE_TRIO: CardSize = { width: 90, height: 144 };
  /** 牌轮抽牌阶段牌背尺寸 */
  static readonly CARD_SIZE_WHEEL: CardSize = { width: 80, height: 128 };
  /** 卡牌详情页中等预览尺寸 */
  static readonly CARD_SIZE_DETAIL: CardSize = { width: 0, height: 320 };
  /** 抽牌动画阶段牌面尺寸 */
  static readonly CARD_SIZE_DRAW_STAGE: CardSize = { width: 200, height: 320 };
  /** 三牌抽牌阶段小卡 */
  static readonly CARD_SIZE_TRIO_DRAW: CardSize = { width: 130, height: 210 };

  // ── 响应式断点（vp）──
  static readonly BREAKPOINT_SM: number = 320;
  static readonly BREAKPOINT_MD: number = 600;
  static readonly BREAKPOINT_LG: number = 840;

  // ── 响应式安全区（第二批新增）──
  static readonly SAFE_TOP: number = 44;       // 顶部状态栏安全距离
  static readonly SAFE_BOTTOM: number = 28;    // 底部手势安全距离
  static readonly BTN_HEIGHT: number = 52;     // 主按钮标准高度

  // ── MVP 动画 Token ──
  static readonly ANIM_DRAW_DURATION: number = 1500;
  static readonly ANIM_FLIP_DURATION: number = 600;
  static readonly ANIM_FADE_IN: number = 400;
  static readonly ANIM_SLIDE_UP: number = 350;
  static readonly ANIM_STAR_TWINKLE: number = 2000;

  // ── 空间感美化专项：动效 Token ──
  /** 卡片按压缩放 */
  static readonly PRESS_SCALE: number = 0.97;
  /** 按压动画时长 ms */
  static readonly ANIM_PRESS_DURATION: number = 140;
  /** 页面元素淡入时长 */
  static readonly ANIM_ENTER_FADE: number = 200;
  /** 弹窗滑出时长 */
  static readonly ANIM_SHEET_SLIDE: number = 220;
  /** 聊天气泡淡入时长 */
  static readonly ANIM_BUBBLE_FADE: number = 180;
  /** 卡牌详情放大进入 */
  static readonly ANIM_CARD_ZOOM_IN: number = 240;

  // ── 空间感美化专项：背景 Token ──
  /** 沉浸式顶部渐变：深蓝星空 → 透明（从顶部向下 120vp） */
  static readonly IMMERSIVE_TOP_HEIGHT: number = 120;
  /** 深空背景色（比 BG_DEEP_INDIGO 更深） */
  static readonly BG_DEEP_SPACE: string = '#050714';
  /** 星空面板半透明底色 */
  static readonly BG_STAR_PANEL: string = 'rgba(15, 15, 35, 0.75)';

  // ── 空间感美化专项：阴影 Token ──
  /** 卡片悬浮阴影 */
  static readonly SHADOW_CARD_FLOAT: ShadowOptions = {
    radius: 16,
    color: 'rgba(0, 0, 0, 0.35)',
    offsetX: 0,
    offsetY: 4
  };
  /** 卡片轻微阴影 */
  static readonly SHADOW_CARD_SUBTLE: ShadowOptions = {
    radius: 8,
    color: 'rgba(0, 0, 0, 0.25)',
    offsetX: 0,
    offsetY: 2
  };
  /** 头像柔光外圈阴影 */
  static readonly SHADOW_AVATAR_GLOW: ShadowOptions = {
    radius: 14,
    color: 'rgba(230, 168, 0, 0.18)',
    offsetX: 0,
    offsetY: 0
  };
  /** 大牌图悬浮阴影 */
  static readonly SHADOW_CARD_HERO: ShadowOptions = {
    radius: 24,
    color: 'rgba(202, 138, 4, 0.1)',
    offsetX: 0,
    offsetY: 6
  };

  // ── 空间感美化专项：金色光感 Token ──
  /** 卡片顶部金色光斑（径向渐变起点色） */
  static readonly GLOW_GOLD_TOP: string = 'rgba(202, 138, 4, 0.04)';
  /** 卡片底部深色 */
  static readonly GLOW_CARD_BOTTOM: string = 'rgba(0, 0, 0, 0)';
  /** 头像金色外发光色 */
  static readonly GLOW_AVATAR_OUTER: string = 'rgba(230, 168, 0, 0.2)';

  // ── 空间感美化专项：星钥卡片统一样式 Token ──
  static readonly STARKEY_CARD_BG: string = 'rgba(20, 22, 45, 0.72)';
  static readonly STARKEY_CARD_BORDER: string = 'rgba(216, 180, 90, 0.1)';
  static readonly STARKEY_CARD_RADIUS: number = 20;
  static readonly STARKEY_CARD_PADDING_H: number = 20;
  static readonly STARKEY_CARD_PADDING_V: number = 18;

  /**
   * 生成星空渐变背景色值（从上到下）
   */
  static bgGradient(): string {
    return `linear-gradient(180deg, ${Theme.BG_DEEP} 0%, ${Theme.BG_PRIMARY} 50%, ${Theme.BG_DEEP} 100%)`;
  }

  /**
   * 生成金色按钮渐变
   */
  static goldButtonGradient(): string {
    return `linear-gradient(135deg, ${Theme.GOLD} 0%, ${Theme.GOLD_DIM} 100%)`;
  }

  /**
   * 生成沉浸式深空背景渐变（从上到下，顶部更深，融入状态栏）
   */
  static deepSpaceGradient(): string {
    return `linear-gradient(180deg, ${Theme.BG_DEEP_SPACE} 0%, ${Theme.BG_DEEP_INDIGO} 55%, ${Theme.BG_DEEP_INDIGO} 100%)`;
  }

  /**
   * 生成沉浸式顶部消隐渐变（状态栏区域 → 透明）
   */
  static immersiveTopFade(): string {
    return `linear-gradient(180deg, ${Theme.BG_DEEP_SPACE} 0%, rgba(15, 15, 35, 0) 100%)`;
  }

  /**
   * 生成星钥卡片顶部金色微光渐变
   */
  static starkeyCardGlow(): string {
    return `linear-gradient(180deg, ${Theme.GLOW_GOLD_TOP} 0%, ${Theme.GLOW_CARD_BOTTOM} 30%)`;
  }

  // ═══════════════════════════════════════════════════════════════
  // v2.0 设计系统 Token
  // 场景分层混合：B 月湖映心（聊天陪伴层）+ C 星钥之书（卡牌内容层）+ A 星图档案（时间记录层）
  // 基于 deliverables/design-system-tokens.md
  // 现有页面可继续使用旧 Token，新页面/重构页面使用 v2 Token
  // ═══════════════════════════════════════════════════════════════

  // ── v2 统一基础色板（三套共享）──
  static readonly V2_BG_BASE: string = '#080B1A';
  static readonly V2_TEXT_PRIMARY: string = '#EDE8D8';
  static readonly V2_TEXT_SECONDARY: string = '#8A8498';
  static readonly V2_TEXT_TERTIARY: string = '#5C5870';
  static readonly V2_GOLD_PRIMARY: string = '#C9A44B';
  static readonly V2_GOLD_SOFT: string = '#E8D5A3';
  static readonly V2_BORDER_BASE: string = '#1E2545';
  static readonly V2_OVERLAY_SCRIM: string = 'rgba(8,11,26,0.87)';

  // ── v2 B 方案色板（月湖映心 · 聊天陪伴层）──
  static readonly V2B_BG_BASE: string = '#060B1A';       // 最深湖底
  static readonly V2B_BG_CARD: string = '#0F1835';       // 湖中石板
  static readonly V2B_BG_FLOATING: string = '#162048';   // 浮上水面的光斑
  static readonly V2B_BG_HOVER: string = '#1A2A55';      // hover/pressed 微亮态
  static readonly V2B_TEXT_PRIMARY: string = '#F2EDDD';  // 月光白（柔和暖白）
  static readonly V2B_TEXT_SECONDARY: string = '#9590A8';// 水雾灰
  static readonly V2B_GOLD_CORE: string = '#D4AC4D';     // 湖面月光（B 方案唯一金色）
  static readonly V2B_GOLD_RIPPLE: string = '#ECD89D';   // 月光扩散
  static readonly V2B_BORDER: string = 'rgba(255,255,255,0.06)';
  static readonly V2B_CRISIS: string = '#C88B7A';        // 暖陶土（危机提示）

  // ── v2 C 方案色板（星钥之书 · 卡牌内容层）──
  static readonly V2C_BG_BASE: string = '#0A0D1A';       // 深蓝黑（旧书封壳）
  static readonly V2C_BG_CARD: string = '#121836';       // 书页底色
  static readonly V2C_BG_FLOATING: string = '#181F40';   // 扉页/弹窗
  static readonly V2C_BG_HOVER: string = '#1C2450';      // hover/pressed
  static readonly V2C_TEXT_PRIMARY: string = '#EBE3CD';  // 书页白（微暖）
  static readonly V2C_TEXT_SECONDARY: string = '#8B869B';// 注释灰
  static readonly V2C_GOLD_GILT: string = '#C5A050';     // 烫金
  static readonly V2C_GOLD_GILT_SOFT: string = '#E0CD95';// 柔和金
  static readonly V2C_SPINE_LINE: string = '#1D2342';    // 书脊线
  static readonly V2C_CRISIS: string = '#C8826A';        // 铜棕

  // ── v2 A 方案色板（星图档案 · 时间记录层）──
  static readonly V2A_BG_BASE: string = '#080B18';       // 最深夜空
  static readonly V2A_BG_CARD: string = '#10142A';       // 星图纸
  static readonly V2A_BG_FLOATING: string = '#161C38';   // 弹窗/浮层
  static readonly V2A_BG_HOVER: string = '#1A2042';      // hover/pressed
  static readonly V2A_TEXT_PRIMARY: string = '#EDE8D8';  // 月光白
  static readonly V2A_TEXT_SECONDARY: string = '#8A8498';// 星灰
  static readonly V2A_GOLD_ACCENT: string = '#C9A44B';   // 核心金色
  static readonly V2A_GOLD_GLOW: string = '#E8D5A3';     // 柔和金
  static readonly V2A_ORBIT_LINE: string = '#1E2545';    // 星轨线
  static readonly V2A_CRISIS: string = '#D4856B';        // 暖铜

  // ── v2 特殊状态色（跨方案统一）──
  static readonly V2_STATE_CRISIS_BG: string = 'rgba(200,139,122,0.08)';
  static readonly V2_STATE_DISABLED: string = 'rgba(138,132,152,0.3)';
  static readonly V2_STATE_DISABLED_TEXT: string = 'rgba(138,132,152,0.5)';
  static readonly V2_STATE_STAR_LIT: string = '#C9A44B';
  static readonly V2_STATE_STAR_UNLIT: string = 'rgba(138,132,152,0.2)';
  static readonly V2_STATE_FUTURE_TEXT: string = 'rgba(138,132,152,0.4)';
  static readonly V2_STATE_VIEWED_DOT: string = 'rgba(197,160,80,0.4)';
  static readonly V2_STATE_UNVIEWED_DOT: string = 'rgba(139,134,155,0.3)';
  static readonly V2_STATE_SELECTED: string = '#C9A44B';
  static readonly V2_STATE_FOCUS_RING: string = 'rgba(201,164,75,0.4)';

  // ── v2 间距系统（4px 基准）──
  static readonly V2_SPACE_2XS: number = 4;
  static readonly V2_SPACE_XS: number = 8;
  static readonly V2_SPACE_SM: number = 12;
  static readonly V2_SPACE_MD: number = 16;
  static readonly V2_SPACE_MD_B: number = 20;
  static readonly V2_SPACE_LG: number = 24;
  static readonly V2_SPACE_XL: number = 32;
  static readonly V2_SPACE_2XL: number = 48;
  static readonly V2_SPACE_3XL: number = 64;

  // ── v2 圆角系统 ──
  static readonly V2_RADIUS_XS: number = 4;
  static readonly V2_RADIUS_SM: number = 8;
  static readonly V2_RADIUS_MD: number = 12;
  static readonly V2_RADIUS_LG: number = 14;
  static readonly V2_RADIUS_XL: number = 20;
  static readonly V2_RADIUS_2XL: number = 24;
  static readonly V2_RADIUS_FULL: number = 999;

  // ── v2 B 方案圆角倾向（圆润）──
  static readonly V2B_RADIUS_BTN: number = 14;
  static readonly V2B_RADIUS_CARD: number = 20;
  static readonly V2B_RADIUS_CHIP: number = 24;
  static readonly V2B_RADIUS_BUBBLE_LARGE: number = 20;
  static readonly V2B_RADIUS_BUBBLE_SMALL: number = 6;

  // ── v2 C 方案圆角倾向（方正）──
  static readonly V2C_RADIUS_BTN: number = 8;
  static readonly V2C_RADIUS_CARD: number = 12;
  static readonly V2C_RADIUS_CHIP: number = 6;
  static readonly V2C_RADIUS_POPUP: number = 16;

  // ── v2 A 方案圆角倾向（中性）──
  static readonly V2A_RADIUS_BTN: number = 12;
  static readonly V2A_RADIUS_CARD: number = 16;
  static readonly V2A_RADIUS_CHIP: number = 20;
  static readonly V2A_RADIUS_POPUP: number = 20;

  // ── v2 字号系统 ──
  // B 方案（人文无衬线）
  static readonly V2B_FONT_DISPLAY: number = 34;
  static readonly V2B_FONT_TITLE: number = 26;
  static readonly V2B_FONT_SUBTITLE: number = 20;
  static readonly V2B_FONT_BODY: number = 15;
  static readonly V2B_FONT_LEAD: number = 18;
  static readonly V2B_FONT_CAPTION: number = 13;
  static readonly V2B_FONT_DISCLAIMER: number = 11;

  // C 方案（衬线标题 + 无衬线正文）
  static readonly V2C_FONT_DISPLAY: number = 36;
  static readonly V2C_FONT_TITLE: number = 28;
  static readonly V2C_FONT_SUBTITLE: number = 20;
  static readonly V2C_FONT_BODY: number = 15;
  static readonly V2C_FONT_LEAD: number = 20;
  static readonly V2C_FONT_CAPTION: number = 13;
  static readonly V2C_FONT_DISCLAIMER: number = 11;
  static readonly V2C_FONT_CARD_NAME: number = 32;
  static readonly V2C_FONT_CARD_NUM: number = 12;
  static readonly V2C_FONT_GILT_TITLE: number = 24;

  // A 方案（几何无衬线 + 等宽辅助）
  static readonly V2A_FONT_DISPLAY: number = 32;
  static readonly V2A_FONT_TITLE: number = 24;
  static readonly V2A_FONT_SUBTITLE: number = 18;
  static readonly V2A_FONT_BODY: number = 15;
  static readonly V2A_FONT_LEAD: number = 17;
  static readonly V2A_FONT_CAPTION: number = 12;
  static readonly V2A_FONT_DISCLAIMER: number = 11;
  static readonly V2A_FONT_DATE_NUM: number = 14;
  static readonly V2A_FONT_TIMESTAMP: number = 12;
  static readonly V2A_FONT_RANK_TITLE: number = 20;
  static readonly V2A_FONT_RANK_DAYS: number = 28;

  // ── v2 阴影系统 ──
  /** B 方案按钮柔光阴影 */
  static readonly V2B_SHADOW_BTN_GLOW: ShadowOptions = {
    radius: 20,
    color: 'rgba(212,172,77,0.12)',
    offsetX: 0,
    offsetY: 0
  };
  /** B 方案按钮 hover 柔光增强 */
  static readonly V2B_SHADOW_BTN_HOVER: ShadowOptions = {
    radius: 28,
    color: 'rgba(212,172,77,0.18)',
    offsetX: 0,
    offsetY: 0
  };
  /** B 方案卡片悬浮阴影 */
  static readonly V2B_SHADOW_CARD: ShadowOptions = {
    radius: 24,
    color: 'rgba(0,0,0,0.3)',
    offsetX: 0,
    offsetY: 4
  };
  /** C 方案卡片叠放阴影 */
  static readonly V2C_SHADOW_CARD: ShadowOptions = {
    radius: 16,
    color: 'rgba(0,0,0,0.35)',
    offsetX: 0,
    offsetY: 2
  };
  /** A 方案卡片轻微阴影 */
  static readonly V2A_SHADOW_CARD: ShadowOptions = {
    radius: 12,
    color: 'rgba(0,0,0,0.25)',
    offsetX: 0,
    offsetY: 2
  };
  /** v2 头像光环（active 级） */
  static readonly V2_HALO_AVATAR_ACTIVE: ShadowOptions = {
    radius: 16,
    color: 'rgba(212,172,77,0.15)',
    offsetX: 0,
    offsetY: 0
  };
  /** v2 头像光环（standard 级） */
  static readonly V2_HALO_AVATAR_STANDARD: ShadowOptions = {
    radius: 12,
    color: 'rgba(212,172,77,0.15)',
    offsetX: 0,
    offsetY: 0
  };

  // ── v2 动效时长（ms）──
  static readonly V2_ANIM_PAGE_ENTER: number = 300;
  static readonly V2_ANIM_BUBBLE_ENTER: number = 400;
  static readonly V2_ANIM_BTN_PRESS: number = 100;
  static readonly V2_ANIM_BTN_RELEASE: number = 150;
  static readonly V2_ANIM_POPUP: number = 220;
  static readonly V2_ANIM_MOONLIGHT_BREATH: number = 6000;
  static readonly V2_ANIM_STAR_BLINK_MIN: number = 4000;
  static readonly V2_ANIM_STAR_BLINK_MAX: number = 6000;
  static readonly V2_ANIM_TYPING_DOT: number = 1200;
  static readonly V2_ANIM_STAR_LIT: number = 650;

  // ── v2 缓动函数（ArkUI Curve 对应）──
  /** 标准版 ease-out — 对应 ArkUI Curve.EaseOut */
  static readonly V2_EASE_OUT: Curve = Curve.EaseOut;
  /** 标准版 ease-in-out — 对应 ArkUI Curve.EaseInOut */
  static readonly V2_EASE_IN_OUT: Curve = Curve.EaseInOut;
  /** 按钮回弹 — 对应 ArkUI Curve.EaseIn */
  static readonly V2_EASE_BOUNCE: Curve = Curve.EaseIn;

  /**
   * v2: 生成 B 方案月光光晕渐变（页面中上区域）
   * @param strong 是否使用强光态（入口页/仪式感场景）
   */
  static v2bMoonlightGlow(strong: boolean = false): string {
    const opacity: string = strong ? '0.08' : '0.04';
    const transparent: string = strong ? '60%' : '70%';
    return `radial-gradient(ellipse 360px 280px at 50% 20%, rgba(212,172,77,${opacity}) 0%, transparent ${transparent})`;
  }

  /**
   * v2: 生成 B 方案降级版月光光晕（静态极弱光斑）
   */
  static v2bMoonlightGlowDim(): string {
    return 'radial-gradient(ellipse, rgba(212,172,77,0.02) 0%, transparent 50%)';
  }

  /**
   * v2: 生成 C 方案书脊中轴线渐变
   */
  static v2cSpineCenterLine(): string {
    return 'linear-gradient(180deg, rgba(197,160,80,0.15) 0%, rgba(197,160,80,0.05) 50%, rgba(197,160,80,0.15) 100%)';
  }

  /**
   * v2: 生成 B 方案星澜气泡左侧暖金光晕
   */
  static v2bBubbleGlow(): string {
    return 'radial-gradient(ellipse 120px 80px at 0% 50%, rgba(212,172,77,0.06) 0%, transparent 60%)';
  }
}

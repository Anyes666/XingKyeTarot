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
}

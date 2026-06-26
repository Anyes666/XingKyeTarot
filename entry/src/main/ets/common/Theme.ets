/**
 * 星钥塔罗 — 全局主题 Token
 * 新中式星空风格：深蓝紫底色 + 温润金色点缀 + 青绿极光辅助
 */
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
}

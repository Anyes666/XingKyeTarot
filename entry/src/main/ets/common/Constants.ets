export class Constants {
  static readonly APP_NAME: string = '星钥塔罗';
  static readonly COMPLIANCE_TITLE: string = '免责声明';
  static readonly COMPLIANCE_CONTENT: string =
    '结果仅供娱乐与自我探索参考，不构成任何专业建议。';
  static readonly COMPLIANCE_FOOTER: string = '结果仅供娱乐与自我探索参考，不构成任何专业建议。';
  static readonly DAILY_REFRESH_HOUR: number = 6;
  static readonly SHARE_IMAGE_WIDTH: number = 1080;
  static readonly SHARE_IMAGE_HEIGHT: number = 1920;
  static readonly PREF_KEY_COMPLIANCE: string = 'is_legal_agreement_accepted_v1';
  static readonly PREF_KEY_ONBOARDING: string = 'is_onboarding_completed';
  static readonly PREF_KEY_DEVICE_ID: string = 'device_user_id';
  static readonly PREF_KEY_DAILY_FORTUNE_HISTORY: string = 'daily_fortune_history';
  static readonly DAILY_FORTUNE_HISTORY_LIMIT: number = 30;
  static readonly PREF_KEY_DIVINATION_HISTORY: string = 'divination_history';
  static readonly DIVINATION_HISTORY_LIMIT: number = 50;

  // ── MVP P0 新增常量 ──

  /** 6 个情绪标签枚举 */
  static readonly EMOTION_TAGS: string[] = [
    '关系内耗', '关系评估', '职场疲惫', '选择纠结', '能量低落', '寻求安慰',
  ];

  /** 分享模板类型枚举 */
  static readonly SHARE_TEMPLATE_TYPES: string[] = ['mood', 'persona', 'action'];

  /** Toast 提示：下一阶段接入 */
  static readonly TOAST_NEXT_PHASE: string = '该功能将在下一阶段接入，敬请期待';

  /** 虚拟陪伴者名称 */
  static readonly COMPANION_NAME: string = '星澜';
  /** 星澜水印文字 */
  static readonly COMPANION_WATERMARK: string = '星钥塔罗 · 星澜';
  /** @deprecated 使用 COMPANION_WATERMARK 替代 */
  static readonly MOON_WATERMARK: string = '星钥塔罗 · 星澜';

  // ── P0.2 新增：隐私门禁常量 ──
  static readonly PREF_KEY_PRIVACY_ACCEPTED_V2: string = 'privacy_accepted_v2';
  static readonly PREF_KEY_PRIVACY_VERSION: string = 'privacy_version';
  static readonly PREF_KEY_FIRST_EXPERIENCE_COMPLETED: string = 'first_experience_completed';
  static readonly PREF_KEY_FIRST_EXPERIENCE_COMPLETED_AT: string = 'first_experience_completed_at';
  static readonly PREF_KEY_DIVINATION_HISTORY_V2: string = 'divination_history_v2';
  static readonly PRIVACY_CURRENT_VERSION: string = '1.0.0';
  static readonly HISTORY_MAX_RECORDS: number = 50;

  // ── P0.2 新增：隐私门禁文案 ──
  static readonly PRIVACY_GATE_TITLE: string = '欢迎使用星钥塔罗';
  static readonly PRIVACY_GATE_BODY: string =
    '在你开始使用前，请先阅读并同意《用户协议》和《隐私政策》。星钥塔罗是一款塔罗式情绪陪伴产品，内容仅供娱乐、情绪记录与自我探索参考，不构成医疗、心理咨询、法律、投资等专业建议。';
}

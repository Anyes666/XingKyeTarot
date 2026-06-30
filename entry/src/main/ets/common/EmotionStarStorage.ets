import { PreferenceStore } from '../data/PreferenceStore';

/**
 * 情绪星点亮记录
 */
export interface EmotionStarRecord {
  date: string;        // yyyy-MM-dd
  starName: string;    // 今日星名，例如：关系内耗
  sourceType: string;  // daily_card
  cardName: string;    // 今日抽到的牌名
  createdAt: number;   // 时间戳
}

/**
 * 星钥等级
 */
export interface StarKeyLevel {
  title: string;
  threshold: number;
  description: string;
}

/**
 * 下一等级信息
 */
export interface NextLevelInfo {
  title: string;
  threshold: number;
  daysLeft: number;
  isMaxLevel: boolean;
}

/**
 * 星澜星历 — 情绪星本地存储与等级计算
 *
 * 只做本地持久化，不上传服务器，不引入登录/账号/云同步。
 * 所有统计字段（累计天数、连续天数、等级）均从 records 动态计算。
 */
export class EmotionStarStorage {
  private static readonly KEY_RECORDS: string = 'emotion_star_records';

  // ── 等级常量 ──

  static readonly LEVELS: StarKeyLevel[] = [
    { title: '初见', threshold: 0, description: '星澜在这里，等你来记录第一颗情绪星。' },
    { title: '星火初亮', threshold: 1, description: '第一颗星已经亮起，你开始了。' },
    { title: '七日星轨', threshold: 7, description: '七天，你已经陪自己走过了整整一周。' },
    { title: '月下自省者', threshold: 21, description: '二十一天，你养成了看见自己的习惯。' },
    { title: '星钥守望者', threshold: 30, description: '一个月了，谢谢你一直记得留一点时间给自己。' },
    { title: '星河同行者', threshold: 90, description: '九十天，你已在这条星河中走了很久。' },
    { title: '半年听心者', threshold: 180, description: '半年了，你陪伴自己走过了半个年头。' },
    { title: '长夜星澜', threshold: 365, description: '一年了，你就是星澜一直等待的那个人。' },
  ];

  // ── 读写 records ──

  static async getRecords(context: Context): Promise<EmotionStarRecord[]> {
    try {
      const json: string = await PreferenceStore.getString(EmotionStarStorage.KEY_RECORDS, '[]', context);
      const parsed: Object = JSON.parse(json);
      if (Array.isArray(parsed)) {
        return parsed as EmotionStarRecord[];
      }
      return [];
    } catch (_err) {
      return [];
    }
  }

  static async saveRecords(context: Context, records: EmotionStarRecord[]): Promise<void> {
    try {
      const json: string = JSON.stringify(records);
      await PreferenceStore.putString(EmotionStarStorage.KEY_RECORDS, json, context);
    } catch (_err) {
      // 保存失败静默
    }
  }

  // ── 日期工具 ──

  static todayString(): string {
    const d: Date = new Date();
    const y: string = d.getFullYear().toString();
    const m: string = (d.getMonth() + 1).toString().padStart(2, '0');
    const day: string = d.getDate().toString().padStart(2, '0');
    return y + '-' + m + '-' + day;
  }

  static formatDateString(year: number, month: number, day: number): string {
    const m: string = month.toString().padStart(2, '0');
    const d: string = day.toString().padStart(2, '0');
    return year.toString() + '-' + m + '-' + d;
  }

  // ── 点亮相关 ──

  static async hasLightedToday(context: Context): Promise<boolean> {
    const records: EmotionStarRecord[] = await EmotionStarStorage.getRecords(context);
    const today: string = EmotionStarStorage.todayString();
    for (let i = 0; i < records.length; i++) {
      if (records[i].date === today) {
        return true;
      }
    }
    return false;
  }

  /**
   * 点亮今天。如果今天已点亮返回 false，否则写入成功返回 true。
   */
  static async lightToday(context: Context, record: EmotionStarRecord): Promise<boolean> {
    // 确保 date 强制为今天
    record.date = EmotionStarStorage.todayString();
    record.createdAt = Date.now();

    const records: EmotionStarRecord[] = await EmotionStarStorage.getRecords(context);
    const today: string = EmotionStarStorage.todayString();

    // 检查今天是否已存在
    for (let i = 0; i < records.length; i++) {
      if (records[i].date === today) {
        return false;
      }
    }

    records.push(record);
    await EmotionStarStorage.saveRecords(context, records);
    return true;
  }

  // ── 统计方法（均从 records 动态计算）──

  static getTotalLightDays(records: EmotionStarRecord[]): number {
    return records.length;
  }

  static getMonthRecords(records: EmotionStarRecord[], year: number, month: number): EmotionStarRecord[] {
    const prefix: string = EmotionStarStorage.formatDateString(year, month, 1).substring(0, 7); // "yyyy-MM"
    const result: EmotionStarRecord[] = [];
    for (let i = 0; i < records.length; i++) {
      if (records[i].date.startsWith(prefix)) {
        result.push(records[i]);
      }
    }
    return result;
  }

  /**
   * 计算当前连续点亮天数（从今天往前数）
   */
  static getCurrentStreakDays(records: EmotionStarRecord[]): number {
    if (records.length === 0) {
      return 0;
    }

    // 按日期降序排列
    const sorted: EmotionStarRecord[] = [...records].sort((a: EmotionStarRecord, b: EmotionStarRecord) => {
      if (a.date > b.date) {
        return -1;
      }
      if (a.date < b.date) {
        return 1;
      }
      return 0;
    });

    const today: string = EmotionStarStorage.todayString();

    // 最近一次点亮必须是今天或昨天
    if (sorted[0].date !== today) {
      // 检查是不是昨天
      const yesterday: string = EmotionStarStorage.getDateOffsetString(-1);
      if (sorted[0].date !== yesterday) {
        return 0;
      }
    }

    let streak: number = 0;
    const currentDate: Date = new Date();
    const oneDay: number = 24 * 60 * 60 * 1000;

    // 从今天开始往回逐日检查
    for (let i = 0; i < 366; i++) {
      const checkDate: Date = new Date(currentDate.getTime() - i * oneDay);
      const checkStr: string = EmotionStarStorage.formatDateString(
        checkDate.getFullYear(), checkDate.getMonth() + 1, checkDate.getDate()
      );
      let found: boolean = false;
      for (let j = 0; j < sorted.length; j++) {
        if (sorted[j].date === checkStr) {
          found = true;
          break;
        }
      }
      if (found) {
        streak++;
      } else {
        // 如果今天未点亮，允许从昨天开始计数
        if (i === 0) {
          // 今天未点亮，继续检查昨天
          continue;
        }
        break;
      }
    }
    return streak;
  }

  // ── 等级计算 ──

  static getLevelByTotalDays(totalDays: number): StarKeyLevel {
    let result: StarKeyLevel = EmotionStarStorage.LEVELS[0];
    for (let i = 0; i < EmotionStarStorage.LEVELS.length; i++) {
      if (totalDays >= EmotionStarStorage.LEVELS[i].threshold) {
        result = EmotionStarStorage.LEVELS[i];
      }
    }
    return result;
  }

  static getNextLevelInfo(totalDays: number): NextLevelInfo {
    for (let i = 0; i < EmotionStarStorage.LEVELS.length; i++) {
      if (totalDays < EmotionStarStorage.LEVELS[i].threshold) {
        return {
          title: EmotionStarStorage.LEVELS[i].title,
          threshold: EmotionStarStorage.LEVELS[i].threshold,
          daysLeft: EmotionStarStorage.LEVELS[i].threshold - totalDays,
          isMaxLevel: false,
        };
      }
    }
    // 已到最高等级
    return {
      title: EmotionStarStorage.LEVELS[EmotionStarStorage.LEVELS.length - 1].title,
      threshold: EmotionStarStorage.LEVELS[EmotionStarStorage.LEVELS.length - 1].threshold,
      daysLeft: 0,
      isMaxLevel: true,
    };
  }

  // ── 辅助：偏移天数日期字符串 ──

  private static getDateOffsetString(offsetDays: number): string {
    const d: Date = new Date();
    d.setDate(d.getDate() + offsetDays);
    return EmotionStarStorage.formatDateString(d.getFullYear(), d.getMonth() + 1, d.getDate());
  }

  // ── 记录查询 ──

  /**
   * 按日期 key 查找单条记录
   */
  static getRecordByDate(records: EmotionStarRecord[], date: string): EmotionStarRecord | null {
    for (let i = 0; i < records.length; i++) {
      if (records[i].date === date) {
        return records[i];
      }
    }
    return null;
  }

  // ── 月份/日期比较 ──

  /**
   * 判断给定年月是否为未来月份
   */
  static isFutureMonth(year: number, month: number): boolean {
    const today: Date = new Date();
    const todayYear: number = today.getFullYear();
    const todayMonth: number = today.getMonth() + 1;
    if (year > todayYear) {
      return true;
    }
    if (year === todayYear && month > todayMonth) {
      return true;
    }
    return false;
  }

  /**
   * 判断日期字符串是否为未来日期
   */
  static isFutureDate(date: string): boolean {
    const today: string = EmotionStarStorage.todayString();
    return date > today;
  }

  /**
   * 比较两个年月：
   *   -1  A < B
   *    0  A === B
   *    1  A > B
   */
  static compareYearMonth(yearA: number, monthA: number, yearB: number, monthB: number): number {
    if (yearA < yearB) {
      return -1;
    }
    if (yearA > yearB) {
      return 1;
    }
    if (monthA < monthB) {
      return -1;
    }
    if (monthA > monthB) {
      return 1;
    }
    return 0;
  }

  // ── 格式化 ──

  /**
   * 将时间戳格式化为 "HH:MM" 字符串
   */
  static formatTimeFromTimestamp(timestamp: number): string {
    const d: Date = new Date(timestamp);
    const h: string = d.getHours().toString().padStart(2, '0');
    const m: string = d.getMinutes().toString().padStart(2, '0');
    return h + ':' + m;
  }

  /**
   * 将 yyyy-MM-dd 格式化为 "M月D日"
   */
  static formatMonthDay(dateStr: string): string {
    const parts: string[] = dateStr.split('-');
    if (parts.length !== 3) {
      return dateStr;
    }
    const month: number = parseInt(parts[1]);
    const day: number = parseInt(parts[2]);
    return month.toString() + '月' + day.toString() + '日';
  }

  // ── 日历辅助方法 ──

  /**
   * 获取某年某月的总天数
   */
  static getDaysInMonth(year: number, month: number): number {
    // month: 1-12
    if (month === 2) {
      if ((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0) {
        return 29;
      }
      return 28;
    }
    if (month === 4 || month === 6 || month === 9 || month === 11) {
      return 30;
    }
    return 31;
  }

  /**
   * 获取某年某月第一天是周几（周一=0, 周日=6）
   */
  static getFirstDayOfWeek(year: number, month: number): number {
    // month: 1-12
    const firstDay: Date = new Date(year, month - 1, 1);
    const jsDay: number = firstDay.getDay(); // 0=周日, 1=周一, ... 6=周六
    if (jsDay === 0) {
      return 6; // 周日 → 6
    }
    return jsDay - 1; // 周一→0, 周二→1, ...
  }

  /**
   * 判断某日期是否为今天
   */
  static isToday(year: number, month: number, day: number): boolean {
    const today: Date = new Date();
    return today.getFullYear() === year && (today.getMonth() + 1) === month && today.getDate() === day;
  }
}

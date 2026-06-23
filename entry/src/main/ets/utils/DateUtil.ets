export class DateUtil {
  /**
   * Converts a timestamp (default now) to a date key string: YYYY-MM-DD.
   */
  static toDateKey(timestamp: number = Date.now()): string {
    const date: Date = new Date(timestamp);
    const year: number = date.getFullYear();
    const month: string = `${date.getMonth() + 1}`.padStart(2, '0');
    const day: string = `${date.getDate()}`.padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * Generates a daily seed string from a device key and timestamp.
   * Format: "<deviceKey>-YYYY-MM-DD"
   * Guarantees same result for same device + same date.
   */
  static dailySeed(deviceKey: string, timestamp: number = Date.now()): string {
    return `${deviceKey}-${DateUtil.toDateKey(timestamp)}`;
  }
}

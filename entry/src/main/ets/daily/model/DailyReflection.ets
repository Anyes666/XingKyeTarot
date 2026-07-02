/**
 * 月湖回望快捷选项
 */
export enum ReflectionChoice {
  SMALL_THING = 'small_thing',
  BOUNDARY = 'boundary',
  REST = 'rest',
  HARD_TO_SAY = 'hard_to_say'
}

/**
 * 月湖回望记录
 *
 * 只保存用户主动选择的回望结果，不保存完整聊天或心理推断。
 */
export interface DailyReflection {
  choice: ReflectionChoice;
  note?: string;
  createdAt: number;
}

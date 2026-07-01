# 第5章：功能优先级路线图、合规风险清单与ArkTS数据结构建议

---

## 5.1 交互功能优先级路线图 P0-P3

### P0：可以最快落地，改动小，收益高

| # | 功能 | 开发复杂度 | 内容量要求 | 用户价值 | 合规风险 | 是否需要本地持久化 | 是否影响现有功能 |
|---|------|-----------|-----------|---------|---------|------------------|----------------|
| 1 | 模块1 星澜每日问候 | 低（时间检测+文案池随机） | 50条 | 高 | 低 | 是（上次访问时间、连续天数） | 否（增强入口页） |
| 2 | 模块2 入口页动态文案 | 低（文案池随机+状态判断） | 100条 | 高 | 低 | 是（已点亮状态、连续天数） | 否（增强入口页） |
| 3 | 模块3 短句沉默回应 | 低（扩展DirectReply子类） | 80条 | 高 | 低 | 否 | 否（增强XinglanDirectReplyEngine） |
| 4 | 模块4 关系内耗回应 | 中（新增DirectReply子类） | 60条 | 高 | 中 | 否 | 否（增强XinglanDirectReplyEngine） |
| 5 | 模块5 自我怀疑回应 | 低（扩展DirectReply子类） | 70条 | 高 | 低 | 否 | 否 |
| 6 | 模块7 失眠深夜回应 | 高（危机关键词检测+边界提示） | 60条 | 高 | 高 | 否（夜信可选） | 否（增强XinglanNightLetters） |
| 7 | 模块8 点亮情绪星反馈 | 低（扩展文案池） | 65条 | 高 | 低 | 是（已有星澜星历） | 否（增强现有功能） |
| 8 | 模块9 星钥等级升级文案 | 低（扩展文案池） | 40条 | 高 | 低 | 是（已有星钥等级） | 否（增强现有功能） |
| 9 | 模块10 卡牌结果页互动文案 | 低（文案池随机） | 140条 | 高 | 低 | 否 | 否（增强现有结果页） |
| 10 | 模块11 轻互动（P0部分：7个） | 低（纯文案池） | 100条 | 高 | 低 | 部分 | 否 |

**P0合计**：10个功能，约765条文案，大部分为纯文案池扩展，开发复杂度低-中。

### P1：需要少量状态记录或页面改造

| # | 功能 | 开发复杂度 | 内容量要求 | 用户价值 | 合规风险 | 是否需要本地持久化 | 是否影响现有功能 |
|---|------|-----------|-----------|---------|---------|------------------|----------------|
| 1 | 模块6 学习工作压力回应 | 中 | 80条 | 高 | 中 | 否 | 否 |
| 2 | 模块11 轻互动（P1部分：3个） | 中（需新增存储或组件） | 30条 | 中 | 低 | 是 | 是（需新增组件） |
| 3 | 关系探索入口引导动态化 | 中（需联动用户状态） | 20条 | 中 | 中 | 否 | 是（需改造入口） |
| 4 | 星澜小镜子5主题扩展 | 中（需扩展主题） | 30条 | 中 | 低 | 否 | 是（需改造组件） |
| 5 | 夜信主动推送（需用户授权） | 高（需推送权限） | 15条 | 中 | 低 | 是 | 是（需新增推送） |

**P1合计**：5个功能，约175条文案，需少量状态记录或页面改造。

### P2：需要中长期设计

| # | 功能 | 开发复杂度 | 内容量要求 | 用户价值 | 合规风险 | 是否需要本地持久化 | 是否影响现有功能 |
|---|------|-----------|-----------|---------|---------|------------------|----------------|
| 1 | 结合天气API的问候 | 高（需接入天气API） | 30条 | 中 | 低 | 是 | 是 |
| 2 | 结合节气的问候 | 中（需节气计算） | 50条 | 中 | 低 | 否 | 是 |
| 3 | 星钥等级升级弹窗月光动效 | 中（需动效设计） | 0条 | 中 | 低 | 否 | 是 |
| 4 | 每级称号配专属卡牌 | 中（需卡牌映射） | 0条 | 中 | 低 | 否 | 是 |
| 5 | A/B测试不同文案点击率 | 高（需分析框架） | 0条 | 高 | 低 | 是 | 是 |

**P2合计**：5个功能，约80条文案，需中长期设计。

### P3：不建议当前阶段做

| # | 功能 | 不建议原因 |
|---|------|-----------|
| 1 | 账号系统/云同步 | 当前本地离线定位，云同步需服务器成本和隐私考量 |
| 2 | AI生成文案/解读 | 本地离线无法接入大模型，且可能越界 |
| 3 | 社交分享排行榜 | 制造比较焦虑，违背"不比较"理念 |
| 4 | 付费解锁角色 | 商业化破坏陪伴感 |
| 5 | 推送通知（未授权场景） | 制造打扰感，违背"允许慢"理念 |

---

## 5.2 合规风险清单：星澜文案与互动机制合规边界清单

### 5.2.1 十条铁律

| # | 铁律 | 说明 | 检测方式 |
|---|------|------|---------|
| 1 | 不预测未来 | 不说"明天会""下周会""一定会" | 文案审核+关键词过滤 |
| 2 | 不承诺恋爱结果 | 不说"他一定会回来""复合概率" | 文案审核+关键词过滤 |
| 3 | 不判断对方真实想法 | 不说"他一定爱你/不爱你""他在想什么" | 文案审核+关键词过滤 |
| 4 | 不替用户做重大决定 | 不说"你应该分手/辞职/放弃" | 文案审核+关键词过滤 |
| 5 | 不提供医疗法律金融专业建议 | 不诊断/不开药/不提供法律意见/不提供投资建议 | 文案审核+关键词过滤 |
| 6 | 不制造焦虑 | 不说"再不XX就来不及了""你这样下去会XX" | 文案审核+关键词过滤 |
| 7 | 不使用恐吓式文案 | 不说"不睡会猝死""不XX会倒霉" | 文案审核+关键词过滤 |
| 8 | 不使用博彩赌运开运转运改命表达 | 不说"开运""转运""改命""招桃花" | 文案审核+关键词过滤 |
| 9 | 不引导用户依赖星澜替代现实关系 | 明确"星澜不替代现实关系"，危机时转介 | 文案审核+UI提示 |
| 10 | 不输出高风险心理危机处理的越界建议 | 检测自伤关键词，立即转介专业资源 | 危机关键词检测+边界提示 |

### 5.2.2 危机关键词检测清单

**必须触发边界提示的关键词**：
- "不想活了""不想活""想死""想结束""结束自己""伤害自己""自残""自杀"
- "活着没意思""不如死了""死了算了""想消失""不想存在"
- "撑不下去了"（结合深夜时段，权重提高）
- "没有任何希望""彻底绝望"

**边界提示文案**（见模块7危机风险边界文案5条）：
- 必须包含：现实支持提示+专业热线+星澜陪伴但不替代
- 推荐热线：
  - 24小时心理援助热线：400-161-9995
  - 北京心理危机研究与干预中心：010-82951332
  - 紧急情况：110

### 5.2.3 不建议加入的机制清单（详见第3章模块12）

15类不建议机制已在第3章模块12完整列出，此处不重复。

### 5.2.4 合规文档三层覆盖（已有，保持）

| 层级 | 位置 | 内容 |
|------|------|------|
| 首次启动 | LaunchPage隐私门禁弹窗 | 用户协议+隐私政策确认 |
| 结果页 | 页脚 | 结果仅供娱乐与自我探索参考，不构成任何专业建议。 |
| 分享图 | 底部 | 同上 |

### 5.2.5 新增合规建议

1. **星澜聊天入口页**：底部免责声明微文案轮换显示（见模块2的20条底部免责声明微文案）
2. **危机触发时**：全屏边界提示+热线电话+星澜陪伴文案
3. **关系探索入口**：明确"关系探索不判断对方心意，只陪你看清你的感受"
4. **卡牌结果页**：保持已有免责声明，增加"这张牌不是答案。是陪伴。"

---

## 5.3 ArkTS数据结构建议

### 5.3.1 设计原则

1. **编译期内嵌**：所有文案池以ArkTS常量存储，无需网络
2. **严格类型**：所有对象结构用interface声明，禁止any/匿名对象
3. **场景化分类**：按使用场景分key，便于路由
4. **权重支持**：支持文案权重（高频场景权重高）
5. **随机化**：大部分文案池随机调用
6. **本地状态**：部分功能需记录用户状态（连续天数/已点亮/上次访问）

### 5.3.2 核心数据结构

```typescript
// entry/src/main/ets/data/XinglanCopywritingData.ets

// 文案分类 key
export type CopywritingCategoryKey =
  | 'daily_greeting'        // 每日问候
  | 'entrance_title'        // 入口页标题
  | 'entrance_subtitle'     // 入口页副文案
  | 'entrance_button'       // 入口页按钮文案
  | 'entrance_disclaimer'   // 入口页底部免责声明微文案
  | 'short_reply'           // 短句回应
  | 'silence_companion'     // 沉默陪伴
  | 'light_question'        // 轻追问
  | 'no_need_to_say'        // 不想说也可以
  | 'relationship_drain_a'  // 关系内耗-怀疑对方心意
  | 'relationship_drain_b'  // 关系内耗-自我怀疑
  | 'relationship_drain_c'  // 关系内耗-放不下
  | 'self_doubt_reply'      // 自我怀疑回应
  | 'self_doubt_question'   // 自我怀疑轻追问
  | 'self_doubt_action'     // 自我怀疑行动建议
  | 'study_pressure'        // 学习压力
  | 'work_pressure'         // 工作压力
  | 'procrastination'       // 拖延
  | 'weekend_anxiety'       // 周一/周日焦虑
  | 'late_night_greeting'   // 深夜问候
  | 'insomnia_companion'    // 失眠陪伴
  | 'night_letter'          // 夜信
  | 'sleep_interaction'     // 睡前轻互动
  | 'crisis_boundary'       // 危机风险边界
  | 'star_lit_success'      // 点亮成功
  | 'star_remember'         // 星澜记得
  | 'star_already_lit'      // 已点亮
  | 'star_repeat'           // 重复点亮提示
  | 'star_future'           // 未来日期
  | 'star_past_empty'       // 过去未点亮
  | 'level_up'              // 星钥等级升级
  | 'card_before_draw'      // 抽牌前引导
  | 'card_after_draw'       // 抽牌后第一句
  | 'card_loading'          // 结果页加载
  | 'card_deep_button'      // 深度解读按钮
  | 'card_ask_button'       // 追问按钮
  | 'card_share_button'     // 分享按钮
  | 'card_lit_button'       // 点亮按钮
  | 'paper_note'            // 夜间纸条
  | 'mood_word_reply'       // 心情词回应
  | 'star_mirror'           // 星钥小镜子
  | 'echo_card'             // 情绪回声卡
  | 'one_sentence'          // 今天只听一句
  | 'moon_question'         // 月光小问题
  | 'star_river'            // 星河接住
  | 'silent_minute';        // 安静一分钟

// 情绪标签
export type EmotionTag =
  | 'relation_drain'      // 关系内耗
  | 'self_doubt'          // 自我怀疑
  | 'work_pressure'       // 工作压力
  | 'study_pressure'      // 学习压力
  | 'procrastination'     // 拖延
  | 'insomnia'            // 失眠
  | 'loneliness'          // 孤独
  | 'wronged'             // 委屈
  | 'want_comfort'        // 想被安慰
  | 'cannot_say'          // 不知道怎么说
  | 'silence'             // 短句沉默
  | 'mild_breakdown'      // 轻度崩溃
  | 'sunday_anxiety'      // 周日晚上焦虑
  | 'festival_loneliness' // 节日孤独
  | 'birthday_low'        // 生日低落
  | 'tired'               // 疲惫
  | 'anxious'             // 焦虑
  | 'confused'            // 迷茫
  | 'relieved'            // 释然
  | 'irritated'           // 烦躁
  | 'expectant'           // 期待
  | 'sad'                 // 难过
  | 'calm';               // 平静

// 主题标签
export type ThemeTag =
  | 'relationship'     // 关系
  | 'self'             // 自我
  | 'work'             // 工作
  | 'study'            // 学习
  | 'sleep'            // 睡眠
  | 'loneliness'       // 孤独
  | 'festival'         // 节日
  | 'crisis'           // 危机
  | 'ritual'           // 仪式
  | 'growth'           // 成长
  | 'companion';       // 陪伴

// 使用场景
export type UsageScene =
  | 'home_entrance'          // 首页入口
  | 'chat_entrance'          // 星澜聊天入口页
  | 'chat_page'              // 星澜聊天页
  | 'divination_center'      // 占卜中心
  | 'card_draw'              // 抽牌页
  | 'card_result'            // 卡牌结果页
  | 'star_lit'               // 点亮情绪星
  | 'star_calendar'          // 星澜星历
  | 'my_page'                // 我的页面
  | 'level_up_popup'         // 升级弹窗
  | 'crisis_popup'           // 危机弹窗
  | 'night_letter'           // 夜信页
  | 'mini_interaction';      // 轻互动菜单

// 文案项结构
export interface CopywritingItem {
  id: string;                    // 唯一ID，如 'daily_greeting_001'
  category: CopywritingCategoryKey; // 分类key
  text: string;                  // 文案内容
  emotionTag?: EmotionTag;       // 情绪标签（可选）
  themeTags: ThemeTag[];         // 主题标签
  scene: UsageScene;             // 使用场景
  weight: number;                // 权重（1-10，默认5，高频场景权重高）
  needRandom: boolean;           // 是否需要随机（默认true）
  needLocalState: boolean;       // 是否需要本地状态（默认false）
  entryPoint?: string;           // 对应页面或功能入口（如 'XinglanChatPage'）
  timeRange?: TimeRange;         // 适用时间段（可选）
  crisisLevel?: CrisisLevel;     // 危机等级（仅crisis_boundary类使用）
}

// 时间段
export interface TimeRange {
  startHour: number;   // 0-23
  endHour: number;     // 0-23
  applicableDays?: number[]; // 适用星期，[0,1,2,3,4,5,6]，0=周日
}

// 危机等级
export type CrisisLevel =
  | 'none'        // 无危机
  | 'mild'        // 轻度（如"撑不下去了"）
  | 'moderate'    // 中度（如"不想活了"）
  | 'severe';     // 重度（如"想死""自残"）

// 文案池结构
export interface CopywritingPool {
  category: CopywritingCategoryKey;
  items: CopywritingItem[];
  totalCount: number;
  needRandom: boolean;
}

// 用户状态（本地持久化）
export interface UserCompanionState {
  lastVisitTime: number;          // 上次访问时间戳
  lastVisitDate: string;          // 上次访问日期 YYYY-MM-DD
  consecutiveDays: number;        // 连续回来天数
  totalLitDays: number;           // 累计点亮天数
  todayLit: boolean;              // 今日是否已点亮
  todayMoodWord?: string;         // 今日心情词
  starLevel: StarLevel;           // 星钥等级
  lastLitStarName?: string;       // 上次点亮的星名
  firstVisitDate: string;         // 第一次访问日期
}

// 星钥等级
export type StarLevel =
  | 'first_sight'           // 初见
  | 'spark_lit'             // 星火初亮
  | 'seven_day_orbit'       // 七日星轨
  | 'moon_reflector'        // 月下自省者
  | 'star_watcher'          // 星钥守望者
  | 'river_walker'          // 星河同行者
  | 'half_year_listener'    // 半年听心者
  | 'long_night_star';      // 长夜星澜

// 等级文案
export interface StarLevelCopywriting {
  level: StarLevel;
  obtainText: string;        // 获得文案
  levelDesc: string;         // 等级说明
  blessingText: string;      // 星澜祝语
  myPageText: string;        // 我的页展示短文案
  popupText: string;         // 升级弹窗文案
}
```

### 5.3.3 文案池访问器

```typescript
// entry/src/main/ets/service/CopywritingService.ets

export class CopywritingService {
  private static instance: CopywritingService;

  static getInstance(): CopywritingService {
    if (!CopywritingService.instance) {
      CopywritingService.instance = new CopywritingService();
    }
    return CopywritingService.instance;
  }

  // 随机获取一条文案
  getRandomCopywriting(category: CopywritingCategoryKey): string {
    const pool = XinglanCopywritingData.getPool(category);
    if (pool.items.length === 0) return '';
    const index = Math.floor(Math.random() * pool.items.length);
    return pool.items[index].text;
  }

  // 根据时间段获取文案
  getCopywritingByTime(
    category: CopywritingCategoryKey,
    currentHour: number
  ): string {
    const pool = XinglanCopywritingData.getPool(category);
    const applicable = pool.items.filter(
      (item: CopywritingItem) => {
        if (!item.timeRange) return true;
        return currentHour >= item.timeRange.startHour &&
               currentHour < item.timeRange.endHour;
      }
    );
    if (applicable.length === 0) return this.getRandomCopywriting(category);
    const index = Math.floor(Math.random() * applicable.length);
    return applicable[index].text;
  }

  // 根据情绪标签获取文案
  getCopywritingByEmotion(
    category: CopywritingCategoryKey,
    emotion: EmotionTag
  ): string {
    const pool = XinglanCopywritingData.getPool(category);
    const applicable = pool.items.filter(
      (item: CopywritingItem) => item.emotionTag === emotion
    );
    if (applicable.length === 0) return this.getRandomCopywriting(category);
    const index = Math.floor(Math.random() * applicable.length);
    return applicable[index].text;
  }

  // 根据权重获取文案
  getWeightedCopywriting(category: CopywritingCategoryKey): string {
    const pool = XinglanCopywritingData.getPool(category);
    const totalWeight = pool.items.reduce(
      (sum: number, item: CopywritingItem) => sum + item.weight, 0
    );
    let random = Math.random() * totalWeight;
    for (const item of pool.items) {
      random -= item.weight;
      if (random <= 0) return item.text;
    }
    return pool.items[pool.items.length - 1].text;
  }

  // 获取每日问候（综合时间+状态）
  getDailyGreeting(userState: UserCompanionState): string {
    const currentHour = new Date().getHours();
    const isContinuous = userState.consecutiveDays >= 3;
    const isLongAbsence = this.isLongAbsence(userState);

    if (isLongAbsence) {
      return this.getCopywritingByTime('daily_greeting_long_absence', currentHour);
    }
    if (isContinuous) {
      return this.getCopywritingByTime('daily_greeting_continuous', currentHour);
    }
    return this.getCopywritingByTime('daily_greeting', currentHour);
  }

  private isLongAbsence(userState: UserCompanionState): boolean {
    const lastVisit = new Date(userState.lastVisitDate);
    const today = new Date();
    const diffDays = Math.floor(
      (today.getTime() - lastVisit.getTime()) / (1000 * 60 * 60 * 24)
    );
    return diffDays >= 7;
  }
}
```

### 5.3.4 落地建议

1. **文件位置**：
   - 数据：`entry/src/main/ets/data/XinglanCopywritingData.ets`
   - 服务：`entry/src/main/ets/service/CopywritingService.ets`
   - 类型：`entry/src/main/ets/common/types/CopywritingTypes.ets`

2. **接入方式**：
   - 现有页面import CopywritingService，调用对应方法
   - 不需要修改现有路由和main_pages.json
   - 增量添加文案池，不影响现有功能

3. **本地持久化**：
   - UserCompanionState用Preferences存储
   - Key: `user_companion_state`
   - 已有device_user_id可复用

4. **扩展性**：
   - 后续可新增CopywritingCategoryKey值
   - 支持A/B测试（通过weight调整）
   - 支持时间段/天气/节气扩展（通过timeRange或新增字段）

---

## 5.4 小结

本章给出了完整的落地路线图：
- **P0**：10个功能，765条文案，大部分纯文案池扩展，可快速落地
- **P1**：5个功能，175条文案，需少量状态记录或页面改造
- **P2**：5个功能，80条文案，需中长期设计
- **P3**：5个不建议当前阶段做的功能

合规风险清单明确了10条铁律、危机关键词检测清单、15类不建议机制。ArkTS数据结构建议提供了完整的类型定义和访问器，可直接用于后续开发接入。

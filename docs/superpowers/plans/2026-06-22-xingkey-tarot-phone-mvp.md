# 星钥塔罗手机端 MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 从零实现一款可在手机端运行、可上架前验证的 HarmonyOS NEXT 原生塔罗 App MVP，包含圣三角占卜、每日一占、桌面万能卡片、分享图、合规提示和基础新手引导。

**Architecture:** 采用单 entry 模块的 Stage 模型工程，UI 使用 ArkUI 声明式组件，业务逻辑集中在 service 层，静态牌面与解读数据放在 rawfile，轻量状态使用 Preferences/PersistentStorage。首版不实现碰一碰、跨设备流转、手表、智慧屏、命运回廊、12 种牌阵全量，避免首版工程发散。

**Tech Stack:** HarmonyOS NEXT, ArkTS, ArkUI, Stage Model, Preferences, FormExtensionAbility, rawfile JSON, @ohos.multimedia.image, @ohos.file.fs, system share ability after API verification.

---

## 0. Scope, Assumptions, and Success Criteria

### 0.1 Scope

首版只做手机端 MVP：

- 圣三角 3 张牌占卜：过去、现在、未来。
- 78 张牌模型与正逆位解读数据结构。
- 每日一占：同一自然日结果固定。
- 桌面万能卡片：2×2 卡片展示每日一占摘要。
- 分享图：生成一张竖版结果图并调起系统分享。
- 合规提示：首次启动弹窗，结果页和分享图固定展示「仅供娱乐」声明。
- 新手引导：首次启动后 3 页说明。

明确不做：

- 碰一碰双人占卜。
- 跨设备流转。
- 手表卡片。
- 智慧屏适配。
- 命运回廊剧情。
- 12 种牌阵全量解锁。
- AI 实时解读。
- 登录、账号、云同步、付费。

### 0.2 Aesthetic Direction

采用「中国大众审美友好的新中式星空」：

- 主背景：深蓝紫/墨蓝，避免过黑过哥特。
- 点缀色：温润金色，不用刺眼亮黄。
- 辅助色：青绿极光、淡紫星雾。
- 元素：星图、月相、轻量云纹、金线边框。
- 字体：正文优先 HarmonyOS Sans；标题可用系统可用的中性偏雅字体，不依赖商业字体。
- 气质：神秘但不阴森，精致但不堆料，适合 18-35 岁用户分享。

### 0.3 Success Criteria

- App 能在 DevEco Studio 手机模拟器或真机启动。
- 首次启动展示免责声明，点击「我已了解」后进入新手引导。
- 首页展示今日一占卡片和「开始占卜」主按钮。
- 用户能完成一次圣三角占卜并看到 3 张牌、正逆位、位置说明和解读。
- 每日一占在同一天多次打开结果一致。
- 桌面万能卡片能展示今日牌名和关键词，点击进入每日一占详情页。
- 结果页能生成分享图，分享图包含牌名、关键词、免责声明。
- 运行核心单元测试：随机抽牌、每日一占种子、数据加载、解读匹配。
- P0 功能没有依赖网络、登录、云服务。

---

## 1. Target File Structure

如果当前目录不是 HarmonyOS 工程，先用 DevEco Studio 创建 Empty Ability 工程，工程根目录使用当前工作区。

```text
AppScope/
  app.json5
  resources/base/element/string.json
  resources/base/media/app_icon.png
entry/
  src/main/
    module.json5
    ets/
      entryability/EntryAbility.ets
      pages/
        Index.ets
        OnboardingPage.ets
        DivinationPage.ets
        DivinationResultPage.ets
        DailyFortunePage.ets
      components/
        StarBackground.ets
        TarotCardView.ets
        PrimaryButton.ets
        ComplianceFooter.ets
        InterpretationPanel.ets
        SharePreview.ets
      widget/
        DailyFortuneWidget.ets
      formextensionability/
        DailyFortuneFormAbility.ets
      model/
        TarotCard.ets
        Spread.ets
        DivinationRecord.ets
        DailyFortune.ets
      service/
        TarotDataService.ets
        DivinationService.ets
        DailyFortuneService.ets
        ShareService.ets
      data/
        TarotDataLoader.ets
        PreferenceStore.ets
      common/
        Constants.ets
        Theme.ets
        Routes.ets
        Types.ets
      utils/
        RandomUtil.ets
        DateUtil.ets
        ImageUtil.ets
    resources/base/
      rawfile/
        tarot_data.json
        interpretations.json
      media/
        card_back.png
        bg_starfield.png
        placeholder_card.png
      element/
        string.json
        color.json
      profile/
        form_config.json
  ohosTest/ets/test/
    RandomUtil.test.ets
    TarotDataService.test.ets
    DivinationService.test.ets
    DailyFortuneService.test.ets
```

Design rule: 每个文件只承担一个清晰职责。不要提前创建 P1/P2 文件。

---

## 2. Implementation Order

### Task 1: Create or Normalize HarmonyOS Project Skeleton

**Files:**

- Create or verify: `AppScope/app.json5`
- Create or verify: `entry/src/main/module.json5`
- Create or verify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Create: `entry/src/main/ets/common/Routes.ets`
- Create: `entry/src/main/ets/common/Constants.ets`

- [ ] **Step 1: Create base project**

If no HarmonyOS project exists, create one in DevEco Studio:

```text
Template: Empty Ability
Language: ArkTS
Model: Stage
Device: Phone
Bundle name: com.xingkey.tarot
Module: entry
```

- [ ] **Step 2: Configure routes**

```typescript
export class Routes {
  static readonly ONBOARDING: string = 'pages/OnboardingPage'
  static readonly HOME: string = 'pages/Index'
  static readonly DIVINATION: string = 'pages/DivinationPage'
  static readonly RESULT: string = 'pages/DivinationResultPage'
  static readonly DAILY_FORTUNE: string = 'pages/DailyFortunePage'
}
```

- [ ] **Step 3: Configure constants**

```typescript
export class Constants {
  static readonly APP_NAME: string = '星钥塔罗'
  static readonly COMPLIANCE_TITLE: string = '免责声明'
  static readonly COMPLIANCE_CONTENT: string =
    '本应用提供的塔罗内容仅供娱乐和自我探索参考，不构成心理、医疗、财务、法律等专业建议。请理性看待结果。'
  static readonly COMPLIANCE_FOOTER: string = '仅供娱乐，不构成任何专业建议'
  static readonly DAILY_REFRESH_HOUR: number = 6
  static readonly SHARE_IMAGE_WIDTH: number = 1080
  static readonly SHARE_IMAGE_HEIGHT: number = 1920
}
```

- [ ] **Step 4: Run build**

Run from DevEco Studio or command line:

```powershell
hvigorw assembleHap
```

Expected: entry HAP builds successfully. If `hvigorw` is unavailable in shell, use DevEco Studio Build.

- [ ] **Step 5: Commit if git repository is valid**

```powershell
git status
git add AppScope entry
git commit -m "chore: initialize HarmonyOS tarot app skeleton"
```

If `git status` reports this is not a repository, skip commit and continue.

---

### Task 2: Define Core Types and Static Data Contract

**Files:**

- Create: `entry/src/main/ets/model/TarotCard.ets`
- Create: `entry/src/main/ets/model/Spread.ets`
- Create: `entry/src/main/ets/model/DivinationRecord.ets`
- Create: `entry/src/main/ets/model/DailyFortune.ets`
- Create: `entry/src/main/resources/base/rawfile/tarot_data.json`
- Create: `entry/src/main/resources/base/rawfile/interpretations.json`

- [ ] **Step 1: Define tarot card model**

```typescript
export enum ArcanaType {
  MAJOR = 'major',
  MINOR = 'minor'
}

export enum TarotSuit {
  NONE = 'none',
  WANDS = 'wands',
  CUPS = 'cups',
  SWORDS = 'swords',
  PENTACLES = 'pentacles'
}

export interface TarotCard {
  id: string
  index: number
  nameZh: string
  nameEn: string
  arcana: ArcanaType
  suit: TarotSuit
  image: string
  keywords: string[]
}

export interface CardInterpretation {
  cardId: string
  upright: string
  reversed: string
  uprightKeywords: string[]
  reversedKeywords: string[]
}
```

- [ ] **Step 2: Define spread model**

```typescript
export interface SpreadPosition {
  index: number
  name: string
  meaning: string
}

export interface SpreadTemplate {
  id: string
  name: string
  positions: SpreadPosition[]
}

export const SACRED_TRIANGLE_SPREAD: SpreadTemplate = {
  id: 'sacred_triangle',
  name: '圣三角',
  positions: [
    { index: 0, name: '过去', meaning: '问题的背景与已经发生的影响' },
    { index: 1, name: '现在', meaning: '当下最需要被看见的状态' },
    { index: 2, name: '未来', meaning: '接下来可能展开的趋势' }
  ]
}
```

- [ ] **Step 3: Define drawn card and record models**

```typescript
import { TarotCard } from './TarotCard'
import { SpreadTemplate } from './Spread'

export interface DrawnCard {
  card: TarotCard
  positionIndex: number
  positionName: string
  isReversed: boolean
  interpretation: string
  keywords: string[]
}

export interface DivinationRecord {
  id: string
  questionType: string
  spread: SpreadTemplate
  cards: DrawnCard[]
  createdAt: number
}
```

- [ ] **Step 4: Define daily fortune model**

```typescript
import { TarotCard } from './TarotCard'

export interface DailyFortune {
  dateKey: string
  card: TarotCard
  isReversed: boolean
  keyword: string
  summary: string
  createdAt: number
}
```

- [ ] **Step 5: Create minimum static JSON**

Create `tarot_data.json` with all 78 records before final verification. During early development, use this 3-record seed and expand in Task 10:

```json
[
  {
    "id": "major_00_fool",
    "index": 0,
    "nameZh": "愚者",
    "nameEn": "The Fool",
    "arcana": "major",
    "suit": "none",
    "image": "placeholder_card.png",
    "keywords": ["开始", "自由", "冒险"]
  },
  {
    "id": "major_01_magician",
    "index": 1,
    "nameZh": "魔术师",
    "nameEn": "The Magician",
    "arcana": "major",
    "suit": "none",
    "image": "placeholder_card.png",
    "keywords": ["行动", "创造", "掌控"]
  },
  {
    "id": "major_02_high_priestess",
    "index": 2,
    "nameZh": "女祭司",
    "nameEn": "The High Priestess",
    "arcana": "major",
    "suit": "none",
    "image": "placeholder_card.png",
    "keywords": ["直觉", "安静", "洞察"]
  }
]
```

Create `interpretations.json`:

```json
[
  {
    "cardId": "major_00_fool",
    "upright": "你正站在新的起点。保持好奇心，但也要看清脚下的路。",
    "reversed": "现在适合慢一点。冲动会带来额外消耗，先确认真正想要什么。",
    "uprightKeywords": ["新开始", "轻盈", "探索"],
    "reversedKeywords": ["犹豫", "冲动", "准备不足"]
  },
  {
    "cardId": "major_01_magician",
    "upright": "资源已经在你手中。把想法落到行动，局面会开始被你推动。",
    "reversed": "你可能低估了自己的能力，也可能把精力分散在太多方向。",
    "uprightKeywords": ["创造", "行动", "资源"],
    "reversedKeywords": ["分散", "迟疑", "未启动"]
  },
  {
    "cardId": "major_02_high_priestess",
    "upright": "答案不急着向外寻找。安静下来，你会听见更真实的判断。",
    "reversed": "信息还不完整。先不要被表象带走，给自己一点观察时间。",
    "uprightKeywords": ["直觉", "内在", "观察"],
    "reversedKeywords": ["迷雾", "误读", "隐藏信息"]
  }
]
```

- [ ] **Step 6: Verify JSON validity**

```powershell
Get-Content entry/src/main/resources/base/rawfile/tarot_data.json -Raw | ConvertFrom-Json | Measure-Object
Get-Content entry/src/main/resources/base/rawfile/interpretations.json -Raw | ConvertFrom-Json | Measure-Object
```

Expected: both commands parse JSON and print Count greater than 0.

---

### Task 3: Implement Deterministic Random and Date Utilities

**Files:**

- Create: `entry/src/main/ets/utils/RandomUtil.ets`
- Create: `entry/src/main/ets/utils/DateUtil.ets`
- Test: `entry/ohosTest/ets/test/RandomUtil.test.ets`

- [ ] **Step 1: Write tests for deterministic seed behavior**

```typescript
import { describe, it, expect } from '@ohos/hypium'
import { RandomUtil } from '../../../src/main/ets/utils/RandomUtil'

export default function randomUtilTest() {
  describe('RandomUtil', () => {
    it('returns same sequence for same seed', 0, () => {
      const a = RandomUtil.seededNumbers('2026-06-22-device', 5)
      const b = RandomUtil.seededNumbers('2026-06-22-device', 5)
      expect(JSON.stringify(a)).assertEqual(JSON.stringify(b))
    })

    it('draws unique card indexes', 0, () => {
      const result = RandomUtil.drawUniqueIndexes(10, 3, 'seed')
      expect(result.length).assertEqual(3)
      expect(new Set(result).size).assertEqual(3)
    })
  })
}
```

- [ ] **Step 2: Implement RandomUtil**

```typescript
export class RandomUtil {
  static hashSeed(seed: string): number {
    let hash = 2166136261
    for (let i = 0; i < seed.length; i++) {
      hash ^= seed.charCodeAt(i)
      hash = Math.imul(hash, 16777619)
    }
    return hash >>> 0
  }

  static next(seedValue: number): number {
    let x = seedValue >>> 0
    x ^= x << 13
    x ^= x >>> 17
    x ^= x << 5
    return x >>> 0
  }

  static seededNumbers(seed: string, count: number): number[] {
    const values: number[] = []
    let current = RandomUtil.hashSeed(seed)
    for (let i = 0; i < count; i++) {
      current = RandomUtil.next(current)
      values.push(current / 0xffffffff)
    }
    return values
  }

  static drawUniqueIndexes(total: number, count: number, seed: string): number[] {
    const indexes: number[] = []
    for (let i = 0; i < total; i++) {
      indexes.push(i)
    }
    let current = RandomUtil.hashSeed(seed)
    for (let i = indexes.length - 1; i > 0; i--) {
      current = RandomUtil.next(current)
      const j = current % (i + 1)
      const temp = indexes[i]
      indexes[i] = indexes[j]
      indexes[j] = temp
    }
    return indexes.slice(0, count)
  }

  static booleanFromSeed(seed: string, salt: string): boolean {
    return RandomUtil.seededNumbers(`${seed}-${salt}`, 1)[0] >= 0.5
  }
}
```

- [ ] **Step 3: Implement DateUtil**

```typescript
export class DateUtil {
  static toDateKey(timestamp: number = Date.now()): string {
    const date = new Date(timestamp)
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  static dailySeed(deviceKey: string, timestamp: number = Date.now()): string {
    return `${deviceKey}-${DateUtil.toDateKey(timestamp)}`
  }
}
```

- [ ] **Step 4: Run tests**

```powershell
hvigorw test
```

Expected: RandomUtil tests pass.

---

### Task 4: Implement Data Loading and Validation

**Files:**

- Create: `entry/src/main/ets/data/TarotDataLoader.ets`
- Create: `entry/src/main/ets/service/TarotDataService.ets`
- Test: `entry/ohosTest/ets/test/TarotDataService.test.ets`

- [ ] **Step 1: Write service tests**

```typescript
import { describe, it, expect } from '@ohos/hypium'
import { TarotDataService } from '../../../src/main/ets/service/TarotDataService'

export default function tarotDataServiceTest() {
  describe('TarotDataService', () => {
    it('loads cards and interpretations', 0, async () => {
      const service = TarotDataService.getInstance()
      await service.init()
      expect(service.getAllCards().length).assertLarger(0)
      const card = service.getAllCards()[0]
      expect(service.getInterpretation(card.id, false).length).assertLarger(0)
      expect(service.getInterpretation(card.id, true).length).assertLarger(0)
    })
  })
}
```

- [ ] **Step 2: Implement loader with visible failure**

```typescript
import { resourceManager } from '@kit.LocalizationKit'
import { TarotCard, CardInterpretation } from '../model/TarotCard'

export class TarotDataLoader {
  static async loadJson<T>(fileName: string): Promise<T> {
    const manager = getContext().resourceManager
    const raw = await manager.getRawFileContent(fileName)
    const text = String.fromCharCode(...raw)
    return JSON.parse(text) as T
  }

  static async loadCards(): Promise<TarotCard[]> {
    return TarotDataLoader.loadJson<TarotCard[]>('tarot_data.json')
  }

  static async loadInterpretations(): Promise<CardInterpretation[]> {
    return TarotDataLoader.loadJson<CardInterpretation[]>('interpretations.json')
  }
}
```

If `@kit.LocalizationKit` import does not match the installed SDK, replace with the current official resource manager import and record the exact import in this file. Do not hide JSON parsing failures.

- [ ] **Step 3: Implement TarotDataService**

```typescript
import { TarotCard, CardInterpretation } from '../model/TarotCard'
import { TarotDataLoader } from '../data/TarotDataLoader'

export class TarotDataService {
  private static instance: TarotDataService = new TarotDataService()
  private cards: TarotCard[] = []
  private interpretations: Map<string, CardInterpretation> = new Map()
  private initialized: boolean = false

  static getInstance(): TarotDataService {
    return TarotDataService.instance
  }

  async init(): Promise<void> {
    if (this.initialized) {
      return
    }
    this.cards = await TarotDataLoader.loadCards()
    const list = await TarotDataLoader.loadInterpretations()
    this.interpretations.clear()
    list.forEach((item: CardInterpretation) => this.interpretations.set(item.cardId, item))
    this.validate()
    this.initialized = true
  }

  getAllCards(): TarotCard[] {
    return this.cards
  }

  getInterpretation(cardId: string, isReversed: boolean): string {
    const item = this.interpretations.get(cardId)
    if (!item) {
      throw new Error(`Missing interpretation for card: ${cardId}`)
    }
    return isReversed ? item.reversed : item.upright
  }

  getKeywords(cardId: string, isReversed: boolean): string[] {
    const item = this.interpretations.get(cardId)
    if (!item) {
      throw new Error(`Missing keywords for card: ${cardId}`)
    }
    return isReversed ? item.reversedKeywords : item.uprightKeywords
  }

  private validate(): void {
    if (this.cards.length === 0) {
      throw new Error('No tarot cards loaded')
    }
    this.cards.forEach((card: TarotCard) => {
      if (!this.interpretations.has(card.id)) {
        throw new Error(`Card has no interpretation: ${card.id}`)
      }
    })
  }
}
```

- [ ] **Step 4: Run tests**

```powershell
hvigorw test
```

Expected: data service test passes and JSON errors are visible if data is malformed.

---

### Task 5: Implement Divination and Daily Fortune Services

**Files:**

- Create: `entry/src/main/ets/service/DivinationService.ets`
- Create: `entry/src/main/ets/service/DailyFortuneService.ets`
- Create: `entry/src/main/ets/data/PreferenceStore.ets`
- Test: `entry/ohosTest/ets/test/DivinationService.test.ets`
- Test: `entry/ohosTest/ets/test/DailyFortuneService.test.ets`

- [ ] **Step 1: Implement divination service**

```typescript
import { SACRED_TRIANGLE_SPREAD } from '../model/Spread'
import { DivinationRecord, DrawnCard } from '../model/DivinationRecord'
import { RandomUtil } from '../utils/RandomUtil'
import { TarotDataService } from './TarotDataService'

export class DivinationService {
  static async drawSacredTriangle(questionType: string, seed: string = `${Date.now()}`): Promise<DivinationRecord> {
    const data = TarotDataService.getInstance()
    await data.init()
    const cards = data.getAllCards()
    const indexes = RandomUtil.drawUniqueIndexes(cards.length, 3, seed)

    const drawn: DrawnCard[] = indexes.map((cardIndex: number, positionIndex: number) => {
      const card = cards[cardIndex]
      const isReversed = RandomUtil.booleanFromSeed(seed, `${card.id}-${positionIndex}`)
      return {
        card,
        positionIndex,
        positionName: SACRED_TRIANGLE_SPREAD.positions[positionIndex].name,
        isReversed,
        interpretation: data.getInterpretation(card.id, isReversed),
        keywords: data.getKeywords(card.id, isReversed)
      }
    })

    return {
      id: `record_${Date.now()}`,
      questionType,
      spread: SACRED_TRIANGLE_SPREAD,
      cards: drawn,
      createdAt: Date.now()
    }
  }
}
```

- [ ] **Step 2: Implement preference wrapper**

```typescript
import preferences from '@ohos.data.preferences'

export class PreferenceStore {
  private static store: preferences.Preferences | undefined

  static async getStore(): Promise<preferences.Preferences> {
    if (!PreferenceStore.store) {
      PreferenceStore.store = await preferences.getPreferences(getContext(), 'xingkey_tarot')
    }
    return PreferenceStore.store
  }

  static async putString(key: string, value: string): Promise<void> {
    const store = await PreferenceStore.getStore()
    await store.put(key, value)
    await store.flush()
  }

  static async getString(key: string, defaultValue: string = ''): Promise<string> {
    const store = await PreferenceStore.getStore()
    return await store.get(key, defaultValue) as string
  }

  static async putBoolean(key: string, value: boolean): Promise<void> {
    const store = await PreferenceStore.getStore()
    await store.put(key, value)
    await store.flush()
  }

  static async getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
    const store = await PreferenceStore.getStore()
    return await store.get(key, defaultValue) as boolean
  }
}
```

- [ ] **Step 3: Implement daily fortune service**

```typescript
import { DailyFortune } from '../model/DailyFortune'
import { RandomUtil } from '../utils/RandomUtil'
import { DateUtil } from '../utils/DateUtil'
import { TarotDataService } from './TarotDataService'
import { PreferenceStore } from '../data/PreferenceStore'

export class DailyFortuneService {
  static async getTodayFortune(deviceKey: string = 'local-phone'): Promise<DailyFortune> {
    const dateKey = DateUtil.toDateKey()
    const cacheKey = `daily_fortune_${dateKey}`
    const cached = await PreferenceStore.getString(cacheKey, '')
    if (cached.length > 0) {
      return JSON.parse(cached) as DailyFortune
    }

    const data = TarotDataService.getInstance()
    await data.init()
    const cards = data.getAllCards()
    const seed = DateUtil.dailySeed(deviceKey)
    const index = RandomUtil.drawUniqueIndexes(cards.length, 1, seed)[0]
    const card = cards[index]
    const isReversed = RandomUtil.booleanFromSeed(seed, card.id)
    const keywords = data.getKeywords(card.id, isReversed)
    const fortune: DailyFortune = {
      dateKey,
      card,
      isReversed,
      keyword: keywords[0],
      summary: data.getInterpretation(card.id, isReversed),
      createdAt: Date.now()
    }
    await PreferenceStore.putString(cacheKey, JSON.stringify(fortune))
    return fortune
  }
}
```

- [ ] **Step 4: Test minimum behavior**

Tests must assert:

- Sacred triangle returns exactly 3 cards.
- Cards are unique.
- Each card has position name, interpretation, and keywords.
- Daily fortune returns same result twice in same date.

Run:

```powershell
hvigorw test
```

Expected: all service tests pass.

---

### Task 6: Build Shared UI Components

**Files:**

- Create: `entry/src/main/ets/common/Theme.ets`
- Create: `entry/src/main/ets/components/StarBackground.ets`
- Create: `entry/src/main/ets/components/TarotCardView.ets`
- Create: `entry/src/main/ets/components/PrimaryButton.ets`
- Create: `entry/src/main/ets/components/ComplianceFooter.ets`
- Create: `entry/src/main/ets/components/InterpretationPanel.ets`

- [ ] **Step 1: Define theme tokens**

```typescript
export class Theme {
  static readonly BG: string = '#10172F'
  static readonly BG_DEEP: string = '#080B18'
  static readonly GOLD: string = '#D8B45A'
  static readonly GOLD_SOFT: string = '#F1DFA5'
  static readonly AURORA: string = '#5ED7D2'
  static readonly TEXT_PRIMARY: string = '#F8F3E7'
  static readonly TEXT_SECONDARY: string = '#B8B0C8'
  static readonly CARD_BG: string = '#171D3A'
  static readonly DANGER_SOFT: string = '#F4C7C3'
}
```

- [ ] **Step 2: Build visual components**

Component requirements:

- `StarBackground`: dark gradient, subtle stars, no heavy particle loop in MVP.
- `TarotCardView`: accepts card image, name, reversed flag; reversed uses rotation, not separate image.
- `PrimaryButton`: gold gradient rounded button.
- `ComplianceFooter`: always visible text.
- `InterpretationPanel`: shows position, card name, keywords, interpretation.

- [ ] **Step 3: Manual UI check**

Open a preview page or home page and confirm:

- Text contrast is readable.
- Gold accent is not overused.
- Card edges and buttons look consistent.
- Reversed cards are visually clear.

Expected: UI feels warm, polished, and not overly dark.

---

### Task 7: Implement First Launch, Onboarding, and Home Page

**Files:**

- Create: `entry/src/main/ets/pages/OnboardingPage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`

- [ ] **Step 1: Entry startup behavior**

On ability launch:

- Initialize data service.
- Read `is_compliance_accepted`.
- If false, show modal disclaimer.
- After acceptance, persist `is_compliance_accepted=true`.
- If `is_onboarding_completed=false`, route to onboarding.
- Otherwise route to home.

- [ ] **Step 2: Onboarding content**

Use exactly 3 pages:

1. 「抽一张牌，不是预测命运」：说明产品是自我探索。
2. 「圣三角牌阵」：过去、现在、未来。
3. 「每日一占」：每天一个关键词，适合作为灵感提醒。

Buttons:

- Next: `下一步`
- Finish: `开始体验`
- Skip: `跳过`

- [ ] **Step 3: Home page content**

Home page layout order:

1. App name: 星钥塔罗。
2. 今日一占卡片：牌名、关键词、查看详情。
3. Main CTA: 开始占卜。
4. Secondary text: 「结果仅供娱乐，请理性参考」。

Do not show P1/P2 entries on MVP home page.

- [ ] **Step 4: Manual verification**

Clear app data and relaunch.

Expected:

- Disclaimer appears once.
- Onboarding appears once.
- Home page loads daily fortune.
- Tapping daily fortune opens DailyFortunePage after Task 8 exists.

---

### Task 8: Implement Divination Flow Pages

**Files:**

- Create: `entry/src/main/ets/pages/DivinationPage.ets`
- Create: `entry/src/main/ets/pages/DivinationResultPage.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`

- [ ] **Step 1: Divination page states**

Use these states:

- `idle`: show 3 card backs and instruction.
- `drawing`: user taps cards one by one.
- `revealed`: all 3 cards revealed, show result button.

- [ ] **Step 2: Draw behavior**

When entering DivinationPage:

- Call `DivinationService.drawSacredTriangle(questionType)`.
- Keep result in page state.
- Reveal cards progressively by index.

- [ ] **Step 3: Result page**

Result page must show:

- Title: 圣三角解读。
- Each card: position name, card name, reversed label, keywords, interpretation.
- Footer: compliance text.
- Button: 生成分享图。

- [ ] **Step 4: Manual verification**

Run app:

1. Tap `开始占卜`.
2. Tap 3 card backs.
3. Confirm all cards reveal.
4. Open result.

Expected:

- No duplicate cards.
- Reversed card text and upright card text differ when applicable.
- Page remains readable on common phone viewport.

---

### Task 9: Implement Daily Fortune Page and Widget

**Files:**

- Create: `entry/src/main/ets/pages/DailyFortunePage.ets`
- Create: `entry/src/main/ets/formextensionability/DailyFortuneFormAbility.ets`
- Create: `entry/src/main/ets/widget/DailyFortuneWidget.ets`
- Create: `entry/src/main/resources/base/profile/form_config.json`
- Modify: `entry/src/main/module.json5`

- [ ] **Step 1: Daily fortune page**

Display:

- Date.
- Card name.
- Upright/reversed label.
- Keyword.
- Summary.
- Compliance footer.

- [ ] **Step 2: Widget configuration**

2×2 widget content:

- Header: 今日一占。
- Card name.
- One keyword.
- Text: 点击查看详情。

- [ ] **Step 3: Widget click behavior**

Click should open `DailyFortunePage`.

Implementation note:

- Use FormExtensionAbility according to the installed SDK.
- Keep widget data small and read from Preferences.
- If widget cannot access same helper directly, create a minimal widget-specific read path that reads the cached daily fortune JSON.

- [ ] **Step 4: Manual verification**

On device/emulator:

- Add widget to desktop.
- Confirm 2×2 card displays.
- Tap widget.

Expected:

- Widget opens the App daily fortune detail page.
- Widget remains useful without network.

---

### Task 10: Implement Share Image

**Files:**

- Create: `entry/src/main/ets/service/ShareService.ets`
- Create: `entry/src/main/ets/utils/ImageUtil.ets`
- Create: `entry/src/main/ets/components/SharePreview.ets`
- Modify: `entry/src/main/ets/pages/DivinationResultPage.ets`

- [ ] **Step 1: Share design**

Use one 1080×1920 vertical template:

- Top: 星钥塔罗。
- Middle: 3 cards with position labels.
- Below: 3 short keyword groups.
- Bottom: 「仅供娱乐，不构成任何专业建议」。
- Background: deep blue-purple gradient with light gold border.

- [ ] **Step 2: Generate image**

Implementation path:

- First render a SharePreview component.
- Capture/render to pixel map using the SDK-supported UI capture or image API.
- Save PNG to cache directory.
- Call system share panel with the PNG URI.

- [ ] **Step 3: Failure behavior**

If image generation fails:

- Show visible toast: `分享图生成失败，请稍后重试`。
- Do not silently ignore.
- Keep user on result page.

- [ ] **Step 4: Manual verification**

Run:

1. Complete divination.
2. Tap generate share image.
3. Preview or share panel appears.

Expected:

- Image is readable.
- Disclaimer appears.
- No clipped text.

---

### Task 11: Complete 78-Card Data and Asset Pass

**Files:**

- Modify: `entry/src/main/resources/base/rawfile/tarot_data.json`
- Modify: `entry/src/main/resources/base/rawfile/interpretations.json`
- Add: `entry/src/main/resources/base/media/card_back.png`
- Add: `entry/src/main/resources/base/media/placeholder_card.png`
- Add actual card images when licensed.

- [ ] **Step 1: Complete all card metadata**

Required counts:

- Major arcana: 22.
- Minor arcana: 56.
- Total: 78.

Each record must include:

- id.
- index.
- Chinese name.
- English name.
- arcana.
- suit.
- image.
- 3 keywords.

- [ ] **Step 2: Complete interpretations**

Required counts:

- 78 interpretation records.
- Each record has upright and reversed text.
- Each text is 80-180 Chinese characters.
- Avoid deterministic prediction language such as「一定会」「必然」「注定」。
- Avoid medical, legal, financial,灾祸 claims.

- [ ] **Step 3: Validate data**

Run a local validation script or test asserting:

- `tarot_data.json.length === 78`
- `interpretations.json.length === 78`
- Every card has matching interpretation.
- Every image field points to an existing resource or approved placeholder.

- [ ] **Step 4: Asset quality gate**

Before app-store build:

- Do not ship rough placeholder cards as final if the product promise is high visual quality.
- If original art is not ready, use a consistent public-domain deck only after legal review.
- Keep card image dimensions consistent.

---

### Task 12: Compliance, Polish, Performance, and Release Verification

**Files:**

- Modify only files touched by previous tasks.
- Add screenshots to project notes if the team uses screenshot review.

- [ ] **Step 1: Compliance check**

Verify:

- First launch disclaimer appears.
- Result page footer appears.
- Share image disclaimer appears.
- No wording claims real prediction, medical advice, financial advice, legal advice, or guaranteed outcomes.

- [ ] **Step 2: Visual polish check**

Verify:

- Main color palette remains deep blue-purple + soft gold.
- No page uses more than 2 primary accent colors.
- Buttons have consistent radius and spacing.
- Result page text does not exceed comfortable line length.
- Sharing image looks acceptable in WeChat-style social feed preview.

- [ ] **Step 3: Performance check**

Verify:

- Home page opens without noticeable delay.
- Divination page does not load all large images synchronously if actual card images are heavy.
- Widget reads cached data instead of recomputing complex UI.
- No infinite animation loop runs when page is hidden.

- [ ] **Step 4: Test suite**

```powershell
hvigorw test
hvigorw assembleHap
```

Expected:

- Tests pass.
- HAP builds.
- No visible runtime crash in smoke test.

- [ ] **Step 5: Smoke test script**

Manual test sequence:

1. Clear app data.
2. Launch app.
3. Accept disclaimer.
4. Complete onboarding.
5. View today fortune.
6. Start divination.
7. Reveal 3 cards.
8. Open result page.
9. Generate share image.
10. Add widget.
11. Tap widget into daily fortune page.

Expected:

- Every step completes.
- Failure states are visible.
- App remains usable offline.

---

## 3. Agent Handoff Rules

The implementing Agent must follow these rules:

1. Build P0 only. Do not add P1/P2 features.
2. Read adjacent files before editing.
3. Use the smallest implementation that satisfies the task.
4. Write tests for deterministic logic before implementation.
5. Do not hide JSON/data errors.
6. Do not introduce network or account dependencies.
7. Keep all user-facing text in Chinese.
8. Keep visual style warm, elegant, and mainstream Chinese-friendly.
9. Verify after each task.
10. If SDK imports differ, use the installed official SDK API and update the import in the touched file only.

---

## 4. Recommended Commit Boundaries

If the repository is valid, commit after each boundary:

1. `chore: initialize HarmonyOS tarot app skeleton`
2. `feat: add tarot data models and seed data`
3. `feat: add deterministic draw utilities`
4. `feat: add tarot data loading service`
5. `feat: add divination and daily fortune services`
6. `feat: add shared tarot UI components`
7. `feat: add onboarding and home flow`
8. `feat: add sacred triangle divination flow`
9. `feat: add daily fortune widget`
10. `feat: add share image flow`
11. `chore: complete tarot data and assets`
12. `test: verify phone MVP release flow`

---

## 5. Final Acceptance Checklist

- [ ] Phone app launches.
- [ ] First launch disclaimer works.
- [ ] Onboarding works.
- [ ] Home daily fortune works.
- [ ] Sacred triangle draw works.
- [ ] Result page works.
- [ ] Share image works.
- [ ] 2×2 widget works.
- [ ] Offline use works.
- [ ] All P0 tests pass.
- [ ] Build succeeds.
- [ ] No P1/P2 feature code is included.
- [ ] Chinese visual style is polished enough for a first public build.


# 星钥塔罗 (XingKey Tarot) — 项目永久记忆

## 项目定位
- 塔罗式情绪陪伴 App（HarmonyOS / ArkTS / DevEco Studio）
- 韦特塔罗体系做心理隐喻、情绪疏导、关系/职场/学业/财富决策参考
- **不是算命工具**

## 产品气质
- 黑金星月 / 深蓝星空 / 东方幻想
- 温柔、克制、有边界感
- 虚拟陪伴者：**星澜**

## 核心功能
1. 今日星钥
2. 单牌快占
3. 圣三角
4. 关系探索
5. 历史记录
6. 分享卡
7. 情绪星点 / 7日情绪星图

## 内容底线（铁律）
1. 不写算命承诺 / 必然发生 / 改命转运招桃花 / 强复合
2. 不写疾病、生死、法律、投资结论
3. 所有结果保留免责声明：「结果仅供娱乐与自我探索参考，不构成任何专业建议」

## 工程铁律（最高优先级）

### 编译
- 任何任务完成后必须 `assembleHap`
- ERROR > 0 → 先修 ERROR，禁止扩功能
- WARN 分阶段处理，不为清 WARN 破坏主流程
- 以 `assembleHap` 编译结果为准，`ERROR = 0` 为第一验收标准

### API 调用
- 禁止猜 HarmonyOS API
- 禁止调用当前 SDK 不存在的 API
- 保存图片/相册/权限/组件截图以当前 SDK 编译通过为准
- 功能暂未适配 → 明确提示失败，**绝不假成功**

### 禁止操作
- 一次性大规模重构项目
- 新增未要求的功能
- 重写隐私政策和用户协议
- 删除旧页面
- 改 App 名
- 把「星澜」改回「月见」
- 清空用户历史数据（除非任务明确要求）
- 用 string/any 糊弄编译
- 伪造保存图片成功
- 未真实保存到相册时提示"图片已保存到相册"

## ArkTS 严格类型规则

### 禁止
1. 匿名对象类型 `{ a: string }`
2. `Array<{ ... }>`
3. `Record<string, Object>`
4. `any`
5. `as` 强行类型断言
6. `return { ... }` 直接返回匿名对象
7. `router.pushUrl({ url: xxx, params: { ... } })` 内联匿名
8. `router.replaceUrl({ url: xxx })` 无 RouterOptions
9. UI 闭包（Column/Row/Scroll/Stack）内写 `const`/`let`/赋值
10. UI 闭包内写普通函数裸调用

### 必须
1. 显式 `interface` 或 `class` 声明所有对象结构
2. `return` 前先显式类型变量
3. 路由跳转先声明 `params` 变量，再声明 `router.RouterOptions`
4. router 操作 `try/catch` 或安全封装
5. `getParams` 安全解析
6. `JSON.parse` 后字段校验
7. 新增页面 `@Entry` + `@Component` + `main_pages.json` 注册
8. 新增组件不需要 `main_pages.json`
9. 每个任务只改指定文件，不扩散

## 工作流程
1. 读取相关文件 → 2. 确认根因 → 3. 输出修改计划 → 4. 修改指定文件 → 5. assembleHap → 6. ERROR>0 只修 ERROR → 7. 输出报告

## 修改报告必须包含
1. 修改文件列表 2. 新增文件 3. 删除旧逻辑 4. 是否改路由 5. 是否改 main_pages.json 6. 是否改数据结构 7. 是否改保存图片逻辑 8. 编译结果 9. ERROR数 10. WARN数 11. 功能验收 12. 未完成项及原因

## 关键常量
- COMPANION_NAME = '星澜'
- COMPANION_WATERMARK = '星钥塔罗 · 星澜'
- MOON_WATERMARK = COMPANION_WATERMARK（@deprecated）

## 关键类型
- EmotionTag = '关系内耗' | '关系评估' | '职场疲惫' | '选择纠结' | '能量低落' | '寻求安慰'
- SpreadType = SINGLE | TRIANGLE | RELATION
- EntryMode = FIRST_EXPERIENCE | NORMAL_SINGLE

## 目录约定
- `entry/src/main/ets/pages/` — 页面（需注册 main_pages.json）
- `entry/src/main/ets/components/` — 组件（不需注册）
- `entry/src/main/ets/common/` — 常量/主题/路由/类型
- `entry/src/main/ets/model/` — 数据模型
- `entry/src/main/ets/data/` — 数据仓库
- `entry/src/main/ets/service/` — 服务层

## 首页背景图适配（2025-06-28）
- HomePage.ets: 背景图 `.translate({ y: -80 })` 将星澜人物上移 80vp
- Layer 2 渐变顶部: `rgba(6,10,28,0.92)` 纯净深蓝黑消除红紫脏色
- Layer 2 中下部透明区延至 65%，底部暗区推迟至 85%
- ActionArea 渐变前 15% 完全透明保留湖景，50%处才到 0.55

## 核心原则
**宁可少做一点，也必须稳定可编译。**

# 星钥塔罗 V2：每日星页、占卜、星澜陪伴与 agent 协作详细开发计划

> **项目**：星钥塔罗 / XingKey Tarot  
> **平台**：HarmonyOS / ArkTS  
> **项目路径**：`D:\XingKeyTarot`  
> **用途**：产品规划、交互规范、文案规范、工程拆分、Codex 执行手册与验收标准  
> **计划版本**：V2  
> **当前基线**：UI-Harmony 焕新推进到 `Task UI-5B`；最近已知编译为 `BUILD SUCCESSFUL，ERROR=0`  
> **核心原则**：不预测未来，不制造依赖，不以签到焦虑换留存，不修改确定性抽牌事实

---

# 目录

1. 计划定位  
2. 产品北极星与设计原则  
3. V2 总体体验架构  
4. 每日回访机制：今日星页  
5. 全天体验：口袋微光、午间轻触与月湖回望  
6. 视觉记忆点：月湖抵达、星钥开页、星光归档  
7. 首页与五个 Tab 的 V2 关系  
8. 占卜系统 V2  
9. 星澜情绪陪伴 V2  
10. 星历、情绪星、等级与每周星图  
11. 文案系统与首发内容量  
12. 安全、隐私与反操控设计  
13. HarmonyOS / ArkTS 工程架构  
14. 开发阶段与任务顺序  
15. Codex 推荐使用方法  
16. Codex 通用任务模板  
17. 可直接复制的 Codex 提示词  
18. 测试、验收与发布门槛  
19. 最终交付清单  

---

# 1. 计划定位

现有材料继续保留，各自承担不同作用：

```text
gpt提示词.docx
＝ 第一阶段 UI-Harmony 焕新施工清单

原《占卜与星澜情绪陪伴详细开发计划》
＝ 占卜、星澜、文案、安全与测试的产品蓝图

本 V2 文档
＝ 在前两份材料基础上新增每日回访闭环、品牌级交互，
  并把后续功能拆成可交给 Codex 的独立任务
```

本计划不要求重做已完成 UI。正确顺序：

1. 继续完成既有 `UI-5B → UI-15`；
2. UI-15 后执行一次 V2 差异审计；
3. 再进入本计划的 V2 功能任务；
4. 每个 Codex 窗口只执行一个小任务；
5. 每个任务必须编译并交接。

---

# 2. 产品北极星与设计原则

## 2.1 北极星体验

用户完成占卜后，理想感受不是：

```text
“它替我算出了答案。”
```

而是：

```text
“我好像更清楚自己在意什么了。”
```

用户每日回访后，理想感受不是：

```text
“我不能断签。”
```

而是：

```text
“今天还有一页只属于我自己的小小整理。”
```

## 2.2 北极星指标

```text
完成一次有帮助、无压力的每日自我观察
```

辅助指标：

- 今日星页完成率；
- D1 / D7 自然回访率；
- 月湖回望完成率；
- “感觉轻一点”反馈比例；
- 保存到星历比例；
- “这句话不适合今天”的反馈率；
- 通知关闭率；
- 动效关闭率；
- 安全拦截准确率；
- 依赖风险投诉数。

不把以下指标作为核心目标：

- 最长连续签到；
- 每日聊天消息数量；
- 与星澜的亲密度；
- 夜间停留时长；
- 单次使用时长；
- 用户因焦虑而重复打开的次数。

## 2.3 六条不可突破的设计原则

1. **用户掌控节奏**：用户想说就说，想停就停。
2. **漏一天没有惩罚**：不清零、不提醒即将中断、不售卖补签。
3. **内容可否认**：牌意、星页和星澜回复都允许用户说“不像我”。
4. **帮助归功于用户**：不塑造“只有星澜能让你好起来”。
5. **事实由程序确定**：牌面、正逆位、日期、点亮状态由确定性程序输出。
6. **安全高于沉浸**：高风险场景停止塔罗解释并转向现实支持。

---

# 3. V2 总体体验架构

## 3.1 一日三幕

V2 增加一条跨越全天的轻量体验：

```text
今日星页
→ 口袋微光
→ 月湖回望
```

| 阶段 | 推荐时机 | 用户操作成本 | 用户得到什么 |
|---|---|---:|---|
| 今日星页 | 当天第一次打开 | 20–40 秒 | 一句方向、一个观察点、一个小行动 |
| 口袋微光 | 白天随时查看 | 5–10 秒 | 一句能带进当天的话 |
| 月湖回望 | 晚上或主动结束一天 | 20–60 秒 | 一次无压力复盘与星历记录 |

## 3.2 三套视觉系统串联

```text
B「月湖映心」：用户抵达
→ C「星钥之书」：用户展开今日星页
→ A「星图档案」：今天被归档为星迹
```

品牌叙事：

```text
从月湖抵达，
翻开星页，
最后把这一刻留在星图里。
```

## 3.3 与既有功能的关系

今日星页不是第六个 Tab，也不改变底部五个 Tab。

它作为第一个 Tab“塔罗 / 占卜”顶部的 Hero 模块存在：

```text
今日星页 Hero
→ 快捷入口
→ 占卜模式
→ 最近记录
→ 历史入口
```

星澜聊天继续是独立 Tab，但可以接收：

- 今日方向；
- 今日微光；
- 晚间回望选择；
- 占卜结果上下文。

---

# 4. 每日回访机制：今日星页

## 4.1 用户可见命名

禁止把它叫作“签到”。

使用：

```text
今日星页
点亮今天
今日星迹
我的星轨
```

不使用：

```text
连续签到
补签
断签
签到奖励
今日运势
领取奖励
```

## 4.2 未完成状态

顶部标题：

```text
今日星页
```

主标题：

```text
今天，想怎样站在自己这一边？
```

副文案：

```text
用不到一分钟，
为今天留下一点方向。
```

主按钮：

```text
展开今日星页
```

辅助说明：

```text
不问今天会发生什么。
只看看，你想怎样度过它。
```

## 4.3 第一步：选择今日方向

首发方向建议 8 条，每天展示其中 4 条：

```text
今天想对自己温柔一点
今天想把注意力收回来
今天想少追问一点结果
今天想给自己留一点空白
今天想把一件事慢慢做好
今天想更认真地听见自己
今天想保护好自己的边界
今天想允许自己不那么完美
```

交互要求：

- 单选；
- 默认不选；
- 卡片圆角与按压状态稳定；
- 选中后暖金细边、暖白金文字、极低透明度暖金底；
- 不整块变亮黄；
- 不自动跳转；
- 支持“今天不想选择，直接展开”。

跳过文案：

```text
今天不想选择，直接展开
```

## 4.4 第二步：展开三层内容

每份今日星页由三个部分组成。

### 今日一句

```text
今天不必把所有事情都想清楚。
先照顾最靠近眼前的那一步。
```

### 今日观察

```text
当你再次开始催促自己时，
留意一下：这件事真的需要现在完成吗？
```

### 今日微小行动

```text
把今天最重要的一件事，
缩小成一个十分钟内可以开始的动作。
```

交互：

- 三部分逐层渐显；
- 每层间隔 180–260ms；
- 总动效不超过 1.2 秒；
- 开启“减少动态效果”时直接显示；
- 不强制朗读；
- 不自动触发 BGM。

## 4.5 第三步：确认并点亮

主按钮：

```text
把这一页带进今天
```

确认后：

1. 本地写入今日完成状态；
2. 通过适配层检查今日情绪星是否已点亮；
3. 已点亮则不重复累计；
4. 未点亮则按现有规则完成一次点亮；
5. 生成口袋微光；
6. 更新 Hero 为已完成状态。

完成文案：

```text
今天的星已经点亮。

它不记录完美，
只记录你认真看见过自己。
```

## 4.6 已完成状态

标题：

```text
今天已经点亮
```

正文显示今日一句。

操作：

```text
回看今日微光
和星澜说一句
晚上再来回望
```

“晚上再来回望”不设置强制倒计时，白天也可以进入。

## 4.7 内容不匹配的纠偏

按钮：

```text
这句话不太适合今天
```

点击后：

```text
那就换一个角度。

不必勉强让一句话符合自己。
```

规则：

- 每天最多换一次；
- 换后保持当天内容固定；
- 七天内不重复同一内容；
- 不让用户无限刷文案；
- 不使用“更幸运的一句”等表达。

---

# 5. 全天体验：口袋微光、午间轻触与月湖回望

## 5.1 口袋微光

完成今日星页后自动生成一句 20–40 字短文案。

示例：

```text
今天不急着证明自己。
先把注意力放回能够完成的那一步。
```

操作：

```text
保存到星历
生成分享卡
和星澜聊聊
```

隐私要求：

- 默认不显示具体情绪和关系内容；
- 桌面卡片只展示通用文案；
- 用户可切换“仅图标模式”；
- 锁屏或通知展示需单独授权。

## 5.2 午间轻触

属于 P1 功能，默认关闭。

通知文案：

```text
给今天留十秒钟，看看自己有没有太累。
```

```text
忙到这里，也可以松开一下肩膀。
```

```text
今天的星页还在这里。
不必立刻回来。
```

禁止：

```text
星澜想你了
你今天还没有来看我
不要忘记我们的约定
连续签到马上中断
```

## 5.3 一分钟轻互动

入口：

```text
现在还好
有一点累
脑子很乱
不想回答
```

对应回复：

### 现在还好

```text
那就把这一点轻松留在今天。

不用做什么，
只是记得它出现过。
```

### 有一点累

```text
先把下一件事缩小一点。

今天不需要一直保持满格。
```

### 脑子很乱

```text
先只看一件已经确定的事。

其余的，可以晚一点再处理。
```

### 不想回答

```text
好。

这次停留不需要留下任何记录。
```

## 5.4 月湖回望

标题：

```text
今晚，要回看一下今天吗？
```

主问题：

```text
今天哪一刻，你有一点站回自己这边？
```

快捷选项：

```text
我完成了一件小事
我保护了一次自己的边界
我让自己休息了一会儿
今天有点难，暂时说不出来
```

积极变化：

```text
这一点变化值得被记住。

不是因为今天变得完美，
而是你在某一刻照顾了自己。
```

今天仍然很难：

```text
今天没有轻松下来，也没有关系。

一颗星不只记录好心情，
也记录你认真走过的这一天。
```

操作：

```text
保存这次回望
和星澜说一句
今天到这里
```

---

# 6. 视觉记忆点：月湖抵达、星钥开页、星光归档

## 6.1 月湖抵达

当天第一次打开 App：

1. 深夜蓝黑背景出现；
2. 月湖反光在约 400ms 内渐显；
3. 水面出现一次极弱涟漪；
4. 中央浮现小型星钥；
5. 今日星页从湖面下方缓慢升起；
6. 总时长 1.2–1.8 秒；
7. 开启减少动态效果后只做 200ms 淡入。

文案：

```text
今天的星页已经来到湖面
```

```text
不问未来。
只为今天留一个方向。
```

## 6.2 星钥开页

默认：

```text
按住星钥，展开今天
```

建议长按 500–700ms：

- 暖金细线逐渐闭合；
- 达到阈值后一次轻触觉反馈；
- 星钥小角度旋转；
- 页面轻量展开；
- 不使用复杂 3D。

无障碍替代：

- 支持普通点击；
- 长按不是唯一入口；
- TalkBack 可读文案：“展开今日星页，按钮”。

## 6.3 星光归档

完成后：

- 一颗小星从星页上浮起；
- 沿弧形星轨移动；
- 落入星历入口；
- 星历入口短暂提亮；
- 不出现金币、礼物盒、奖励到账。

文案：

```text
这一页已经被收进你的星图。
```

## 6.4 性能降级

- 取消实时粒子；
- 使用固定图层 + 透明度动画；
- 最大同时动画元素不超过 3 个；
- 动画结束后释放状态；
- 不持续运行背景动画；
- App 进入后台立即暂停。

---

# 7. 首页与五个 Tab 的 V2 关系

## 7.1 塔罗 / 占卜 Tab

顺序：

```text
今日星页 Hero
→ 快捷入口
→ 占卜模式
→ 最近记录
→ 历史入口
```

快捷入口：

```text
只想被安慰
帮我理一理
抽一张牌
回看今天
```

## 7.2 星澜聊天 Tab

新增五种需求方向：

```text
我想说说发生了什么
我现在只想被安慰
帮我把思绪理一理
给我一个很小的建议
我不想说话，安静待一会儿
```

## 7.3 星澜语录 Tab

增加：

- 今日微光入口；
- 收藏过的语录；
- 不显示“解锁稀有语录”；
- 不按连续签到限制阅读。

## 7.4 卡牌总览 Tab

保持牌册定位，不与每日机制强绑定。

可以增加“今天的牌面意象”，但必须是阅读入口，不是每日运势。

## 7.5 我的 Tab

新增入口：

```text
我的星轨
每周星图
今日微光记录
提醒与隐私
减少动态效果
```

---

# 8. 占卜系统 V2

现有链路继续按 `UI-5B → UI-11` 完成视觉焕新。

## 8.1 问心模式真正影响结果文案

### 今天我想被接住

- 先承接；
- 不主动建议；
- 不强行积极；
- 结尾以允许暂停为主。

### 今天我想看见光

- 仍先承接；
- 提供一个可选角度；
- 最多一个微小行动；
- 不变成积极鸡汤。

## 8.2 结果页六层结构

1. 一句话总览；
2. 牌面里的意象；
3. 它可能照见了什么；
4. 星澜陪伴；
5. 用户反馈与纠偏；
6. 下一步操作。

反馈 Chips：

```text
这句话有点像我
有一部分不太像
帮我继续理一理
我只想安静一会儿
给我一个很小的建议
```

## 8.3 “不太像我”

回复：

```text
那就不用勉强把牌意套在自己身上。

牌只是一个角度。
你的真实感受始终比牌面更重要。
```

内部状态：

```typescript
userAcceptedInterpretation: false
```

进入聊天后不得继续强行引用同一解释。

## 8.4 结果进入星澜聊天

```typescript
interface DivinationConversationContext {
  mode: 'single' | 'triangle' | 'relation' | 'wheel';
  cardNames: string[];
  orientations: ('upright' | 'reversed')[];
  positionNames: string[];
  heartMode?: 'held' | 'light';
  heartOptionId?: string;
  coreSummary: string;
  userAcceptedInterpretation?: boolean;
}
```

禁止：

- LLM 重新抽牌；
- LLM 修改正逆位；
- LLM 推断新的牌阵事实；
- 完整聊天默认写入历史。

---

# 9. 星澜情绪陪伴 V2

## 9.1 五种需求方向

| 用户选择 | 内部 Need | 默认策略 |
|---|---|---|
| 我想说说发生了什么 | LISTEN | 承接 + 一次轻追问 |
| 我现在只想被安慰 | COMFORT | 安慰，不分析 |
| 帮我把思绪理一理 | ORGANIZE | 拆分 2–3 个矛盾点 |
| 给我一个很小的建议 | ADVICE | 一个可拒绝的小行动 |
| 我不想说话，安静待一会儿 | QUIET | 纯视觉安静模式 |

## 9.2 十二状态

```text
ENTRY
RECEIVE
CLARIFY
CAUSE_FOCUS
COMFORT
QUIET
ORGANIZE
MICRO_ACTION
CALMING
CLOSE
BOUNDARY
SAFETY
```

关键约束：

- 一轮最多一个问题；
- 情绪承接首轮不提问；
- 同策略连续不超过两轮；
- 连续三轮无新信息，转整理或安静；
- 拒绝建议后四轮不主动建议；
- 选择安静后不自动发送新文本；
- 用户说“你不懂”时停止解释，回退承接；
- 高风险直接进入 SAFETY。

## 9.3 安静陪伴

文案：

```text
不用说什么，也可以。
```

```text
这里没有需要立刻回答的问题。
```

UI：

- 只保留月光、水面、星点；
- 不显示“在线”；
- 不模拟心跳、眨眼或生命体征；
- 默认不震动；
- 三分钟无操作可淡出，但不自动保存；
- 用户随时退出。

按钮：

```text
我想说一句
继续安静
结束这次陪伴
```

## 9.4 情绪降噪

触发：

- 用户主动选择；
- 用户说“太多了”“别说太长”；
- 焦虑强度高；
- 连续发送多条短消息。

表现：

- 每轮 20–50 字；
- 最多两个 Chips；
- 字号略增；
- 行距增加；
- 隐藏非必要入口；
- 减少背景动效；
- 不自动永久改变用户设置。

---

# 10. 星历、情绪星、等级与每周星图

## 10.1 点亮规则

保持现有规则：

- 每天只能点亮一次；
- 未来日期不可点亮；
- 重复操作不累计；
- 等级阈值不变。

推荐解释为累计点亮天数，不强调连续。

## 10.2 漏一天

```text
昨天没有留下记录，也没关系。

星轨不会因为一次停顿而消失。
今天可以从这里继续。
```

## 10.3 每周星图

定义为“累计七次点亮形成一幅小星图”，不要求连续。

进度：

- 第 1 次：一颗星；
- 第 3 次：出现短星线；
- 第 5 次：形成局部图案；
- 第 7 次：完成一幅小星图。

完成文案：

```text
七颗星已经连成了一小段轨迹。

不是因为你从未停下，
而是你总会回来看看自己。
```

奖励：

- 星历边框；
- 星图纹样；
- 书签；
- 新的月湖背景细节；
- 一篇星澜语录；
- 一张可保存的自我探索卡。

禁止货币、抽奖、稀有度、补签卡和付费保连续。


---

# 11. 文案系统与首发内容量

## 11.1 首发建议

- 60 条今日一句；
- 60 条今日观察；
- 60 条微小行动；
- 30 条完成文案；
- 20 条漏一天后文案；
- 30 条月湖回望文案；
- 20 条累计里程碑文案；
- 20 条内容不匹配纠偏文案；
- 30 条口袋微光。

首发不依赖 LLM 实时生成，采用：

```text
本地审核文案
＋ 日期种子
＋ 用户选择方向
＋ 七天去重
```

## 11.2 数据结构

```typescript
export interface DailyLightContent {
  id: string;
  direction: DailyDirection;
  mainLine: string;
  observation: string;
  microAction: string;
  pocketLight: string;
  warmth: 1 | 2 | 3 | 4 | 5;
  suggestionStrength: 1 | 2 | 3;
  sensitive: boolean;
}
```

## 11.3 选择规则

```text
日期种子
＋ 今日方向
＋ 最近七天内容 ID
→ 选择一条未重复内容
```

每天最多换一次。

## 11.4 首批可直接使用的“今日一句”

### 对自己温柔一点

1. `今天不必一直表现得很好。`
2. `先把对自己的要求放轻一点。`
3. `疲惫的时候，慢一点也算前进。`
4. `今天可以少批评自己一次。`
5. `不够完美，也仍然值得被认真对待。`

### 把注意力收回来

1. `先别急着猜别人怎么想。`
2. `把注意力放回你能确认的事实。`
3. `今天先照顾你能控制的那一部分。`
4. `别人的反应，不需要占满你的一整天。`
5. `先听听自己的感受，再看外面的声音。`

### 少追问一点结果

1. `今天不必把所有事情都想清楚。`
2. `答案没有出现时，也可以先过好眼前这一段。`
3. `不确定不等于坏结果。`
4. `可以先停在还不知道的位置。`
5. `有些事情适合观察，不适合催促。`

### 给自己留一点空白

1. `今天不需要把每一分钟都填满。`
2. `空下来，不等于浪费时间。`
3. `先留一点位置给呼吸和停顿。`
4. `不处理事情的时候，你也仍然有价值。`
5. `让今天有一小段不需要完成什么的时间。`

## 11.5 首批“今日观察”

1. `当你再次催促自己时，留意一下：这件事真的需要现在完成吗？`
2. `当你开始猜测别人时，先看看已经发生的真实行为。`
3. `当心里说“我必须”时，试着问：这是现实要求，还是习惯性的压力？`
4. `留意今天哪一刻，你对自己说话比对别人更严厉。`
5. `当你准备答应一件事时，先感受一下自己是否真的愿意。`
6. `留意哪一件小事，让身体突然变得紧绷。`
7. `当脑子开始反复预演最坏结果时，分清事实和猜测。`
8. `留意今天有没有一刻，你其实已经做得足够。`

## 11.6 首批“微小行动”

1. `把最重要的一件事缩小成十分钟内能开始的动作。`
2. `先喝一点水，再决定要不要继续想。`
3. `把最困扰你的那句话写下来，暂时不用回答。`
4. `给自己留五分钟，不处理任何问题。`
5. `把事实和猜测各写一行。`
6. `今天只拒绝一件你并不想承担的小事。`
7. `完成一件最能减少明天压力的事情。`
8. `把手机放远一分钟，让肩膀松下来。`

---

# 12. 安全、隐私与反操控设计

## 12.1 明确不做

- 连续签到清零；
- 补签卡；
- 亲密度；
- 好感度；
- 星澜等待用户；
- 排他文案；
- 随机抽奖；
- 每日运势；
- 连抽；
- 漏签惩罚；
- 情绪越差奖励越多；
- 用通知制造焦虑；
- 依据用户低落自动提高推送频率。

## 12.2 默认不保存

- 完整聊天；
- 高风险原文；
- 推测出的心理类型；
- 关系亲密度；
- 第三方隐私；
- 未授权的长期偏好。

## 12.3 可以保存

- 用户主动保存的今日星页；
- 日期；
- 内容 ID；
- 用户选择的方向；
- 用户主动选择的回望结果；
- 用户主动保存的摘要。

## 12.4 高风险

一旦检测到明确自伤、自杀、他伤或现实危险：

- 停止今日星页或塔罗叙事；
- 不继续给牌义；
- 进入既有 `XinglanSafetyGuard`；
- 提供现实支持；
- 不用月光隐喻弱化危险。

---

# 13. HarmonyOS / ArkTS 工程架构

## 13.1 建议目录

如已有相同职责文件，优先复用，不重复创建。

```text
entry/src/main/ets/daily/
├── model/
│   ├── DailyDirection.ets
│   ├── DailyRitualState.ets
│   ├── DailyLightContent.ets
│   └── DailyReflection.ets
├── data/
│   ├── DailyLightCopyLibrary.ets
│   ├── DailyObservationCopy.ets
│   ├── DailyMicroActionCopy.ets
│   └── DailyMilestoneCopy.ets
├── service/
│   ├── DailyContentSeed.ets
│   ├── DailyLightProvider.ets
│   ├── DailyRitualStore.ets
│   └── EmotionStarDailyAdapter.ets
├── components/
│   ├── DailyLightHeroCard.ets
│   ├── DailyDirectionChip.ets
│   ├── StarKeyReveal.ets
│   ├── DailyLightCard.ets
│   ├── PocketLightCard.ets
│   ├── EveningReflectionCard.ets
│   └── WeeklyConstellationCard.ets
└── pages/
    └── DailyLightPage.ets
```

## 13.2 主要职责

### DailyRitualStore

- 读取当天状态；
- 标记完成；
- 保存今日内容 ID；
- 保存是否已换一次；
- 保存晚间回望；
- 不直接修改星历底层规则。

### EmotionStarDailyAdapter

- 检查今天是否已点亮；
- 复用现有 `EmotionStarStorage`；
- 防止重复累计；
- 不改变未来日期规则；
- 不改变等级阈值。

### DailyLightProvider

- 根据日期和方向选内容；
- 过滤最近七天；
- 执行每天一次换内容；
- 不联网；
- 不调用 LLM。

## 13.3 推荐状态

```typescript
export interface DailyRitualState {
  dateKey: string;
  direction?: DailyDirection;
  contentId?: string;
  completed: boolean;
  replacedOnce: boolean;
  eveningReflection?: DailyReflection;
  savedToCalendar: boolean;
}
```

## 13.4 MainFramePage 约束

`MainFramePage.ets` 是大文件。

只允许：

- 在 `DivinationCenterTabContent` 对应区域引入 Hero；
- 不重构五个 Tab；
- 不改导航；
- 不改变 `selectedIndex`；
- 不修改其他 Tab 内联区域。

---

# 14. 开发阶段与任务顺序

## 阶段 0：完成既有 UI-Harmony

```text
UI-5B
→ UI-6
→ UI-7
→ UI-8
→ UI-9
→ UI-10
→ UI-11
→ UI-12
→ UI-13
→ UI-14
→ UI-15
```

UI-15 完成后执行：

```text
AUDIT-V2-0：现状与 V2 差异审计
```

## 阶段 1：每日星页 P0

### DAILY-1：数据模型与本地存储

创建：

- `DailyDirection.ets`
- `DailyRitualState.ets`
- `DailyLightContent.ets`
- `DailyReflection.ets`
- `DailyRitualStore.ets`

完成标准：

- 当天状态可持久化；
- 次日自动新建；
- 不涉及 UI；
- 不修改 `EmotionStarStorage`；
- 不使用连续签到字段。

### DAILY-2：本地文案库与内容选择

创建：

- `DailyLightCopyLibrary.ets`
- `DailyContentSeed.ets`
- `DailyLightProvider.ets`

完成标准：

- 日期种子稳定；
- 七天去重；
- 每天最多换一次；
- 无联网；
- 有可运行验证。

### DAILY-3：今日星页 Hero

创建：

- `DailyLightHeroCard.ets`
- `DailyDirectionChip.ets`

修改：

- `MainFramePage.ets` 的占卜 Tab 对应区域，或实际承载占卜 Tab 的页面。

完成标准：

- 未完成与已完成两种状态；
- 方向选择；
- 入口跳转；
- 不改变占卜入口逻辑。

### DAILY-4：今日星页页面

创建：

- `DailyLightPage.ets`
- `StarKeyReveal.ets`
- `DailyLightCard.ets`

完成标准：

- 选择方向；
- 展开三层内容；
- 换一次；
- 确认完成；
- 无障碍降级。

### DAILY-5：点亮适配与星光归档

创建：

- `EmotionStarDailyAdapter.ets`

完成标准：

- 复用现有点亮；
- 不重复累计；
- 完成动画；
- 保持所有星历规则。

### DAILY-6：口袋微光

创建：

- `PocketLightCard.ets`

完成标准：

- 今日微光；
- 保存、分享、聊天入口；
- 不新增敏感数据保存。

### DAILY-7：月湖回望

创建：

- `EveningReflectionCard.ets`

完成标准：

- 四个快捷选项；
- 保存回望；
- 不强制晚上；
- 可直接结束。

### DAILY-8：每周星图

创建：

- `WeeklyConstellationCard.ets`

完成标准：

- 累计七次；
- 非连续；
- 纯视觉奖励；
- 不修改等级阈值。

## 阶段 2：占卜与星澜联动

```text
RESULT-1：结果页反馈 Chips
RESULT-2：被接住 / 看见光的文案路由
FLOW-1：占卜结果上下文进入聊天
CHAT-1：五种陪伴方向
CHAT-2：十二状态与策略历史
CHAT-3：安静陪伴
CHAT-4：情绪降噪
SAFE-1：边界与高风险
COPY-1：文案结构化
EVAL-1：自动与人工回归
```

## 阶段 3：P1 增强

- 月湖抵达；
- 午间轻触；
- 通知授权；
- HarmonyOS 服务卡片；
- 隐私显示模式；
- 低性能降级；
- 每周星图完整视觉。

## 阶段 4：实验

- 低刺激语音；
- 用户授权的有限偏好；
- 多设备同步；
- 自动文案评测；
- 更丰富星图。

---

# 15. Codex 推荐使用方法

## 15.1 最推荐的协作方式

```text
一个 Codex 窗口
＝ 一个明确 Task
＝ 一组有限文件
＝ 一次编译
＝ 一份交接摘要
```

不要把 `DAILY-1 → DAILY-8` 一次性丢给同一个窗口。

## 15.2 推荐任务大小

理想任务：

- 1–3 个新文件；
- 0–3 个现有文件；
- 一个明确用户结果；
- 一条主路径；
- 一次完整编译。

错误：

```text
把整个每日星页、星历、聊天和服务卡片全部做完
```

正确：

```text
DAILY-1 数据层
DAILY-2 内容选择
DAILY-3 Hero
DAILY-4 页面
DAILY-5 点亮适配
```

## 15.3 推理速度

| 任务类型 | 建议 |
|---|---|
| 文案、验收、差异审计 | 高 |
| 数据模型、小组件 | 中 |
| MainFramePage 小范围 UI | 中 |
| 状态机、路由、安全 | 高 |
| 复杂结果页、聊天联动 | 高 |
| 单纯样式微调 | 中 |

## 15.4 每个新窗口先读取

```text
AGENTS.md
deliverables/stitch_to_arkui_harmony_refresh_plan.md
deliverables/ui_harmony_refresh_acceptance_criteria.md
deliverables/星钥塔罗_V2详细开发计划与Codex协作指南.md
```

只额外读取本任务相关文件，不要一次打开整个项目。

## 15.5 Git 建议

每个 Epic 使用独立分支：

```text
feature/daily-ritual
feature/xinglan-state-machine
feature/result-feedback
```

每个 Task 一个提交：

```text
feat(daily): add daily ritual state store
feat(daily): add seeded local copy provider
feat(daily): add daily light hero
```

Codex 不应：

- 自动回退现有 dirty 文件；
- 重写无关历史；
- 合并其他分支；
- 未经要求修改签名、包名或权限。

## 15.6 每轮流程

1. 新建 Codex 窗口；
2. 粘贴任务提示词；
3. 让 Codex 先报告读取了什么；
4. 审查它的计划是否扩大范围；
5. 再允许执行；
6. 查看 diff；
7. 执行编译；
8. 真机截图；
9. 保存交接摘要；
10. 执行下一个 Task。

---

# 16. Codex 通用任务模板

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

当前阶段：
[阶段名称]

现在执行：
[Task 编号与名称]

本轮唯一目标：
[只写一个结果]

请先读取：
- deliverables/stitch_to_arkui_harmony_refresh_plan.md
- deliverables/ui_harmony_refresh_acceptance_criteria.md
- deliverables/星钥塔罗_V2详细开发计划与Codex协作指南.md
- [本任务相关文件]

允许创建：
- [文件]

允许修改：
- [文件]

严格禁止修改：
- [文件与模块]

必须保持：
- 抽牌算法不变
- 78 张卡牌数据不变
- 历史记录结构不变
- 分享卡核心逻辑不变
- BGM 不变
- 头像昵称不变
- 星历未来日期与每日一次规则不变
- CompanionBottomNav 不变
- MainFramePage 五个 Tab 结构不变

实现要求：
1. [具体要求]
2. [具体要求]
3. [具体要求]

代码要求：
- 不使用 any
- 不使用 as any
- 不使用 @ts-ignore
- 不引入第三方库
- 不处理无关 WARN
- 不进行无关重构
- 优先复用项目现有组件与样式
- 如果 API 在当前 SDK 不存在，使用项目已采用的等价原生能力

先执行检查：
1. 检查目标文件实际结构。
2. 检查项目是否已有同职责实现。
3. 如存在同职责实现，优先复用。
4. 输出不超过 10 条的实施计划后再修改。

编译命令：
cd D:\XingKeyTarot
node "D:\HarmonyOS\DevEco Studio\tools\hvigor\bin\hvigorw.js" assembleHap --mode module -p module=entry@default -p product=default --no-daemon

目标：
BUILD SUCCESSFUL
ERROR=0

完成后输出：
1. 修改与创建了哪些文件。
2. 每个文件承担什么职责。
3. 本轮完成了什么用户可见行为。
4. 是否修改了禁止范围。
5. 是否使用 any / as any / @ts-ignore。
6. 编译结果。
7. 仍需真机验证的项目。
8. 给下一个 Codex 窗口的交接摘要。
```

---

# 17. 可直接复制的 Codex 提示词

## 17.1 AUDIT-V2-0：UI 完成后的差异审计

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

现在执行 AUDIT-V2-0：V2 功能差异审计。

本轮只读，不修改任何 App 代码。

请读取：
- deliverables/stitch_to_arkui_harmony_refresh_plan.md
- deliverables/ui_harmony_refresh_acceptance_criteria.md
- deliverables/星钥塔罗_V2详细开发计划与Codex协作指南.md
- entry/src/main/ets/pages/MainFramePage.ets
- entry/src/main/ets/pages/XinglanChatEntrancePage.ets
- entry/src/main/ets/pages/XinglanChatPage.ets
- entry/src/main/ets/pages/EmotionStarPage.ets
- entry/src/main/ets/pages/StarCalendarPage.ets
- entry/src/main/ets/common/EmotionStarStorage.ets
- entry/src/main/ets/xinglan/
- entry/src/main/ets/pages/ResultGoldenPage.ets
- entry/src/main/ets/pages/TriangleResultPage.ets
- entry/src/main/ets/pages/RelationResultPage.ets

创建：
deliverables/v2_product_interaction_gap_report.md

报告逐项标记：
- 已完成
- 部分完成
- 尚未开发
- 与现有结构冲突
- 需要确认

重点检查：
1. 今日星页是否存在。
2. 每日一次状态是否存在。
3. 七天去重文案选择是否存在。
4. 月湖回望是否存在。
5. 口袋微光是否存在。
6. 每周星图是否存在。
7. 五种陪伴方向是否存在。
8. 十二状态是否存在。
9. 建议退避是否存在。
10. 安静陪伴是否存在。
11. 情绪降噪是否存在。
12. 结果纠偏 Chips 是否存在。
13. 占卜结果是否能带上下文进入聊天。
14. 依赖与预测边界是否存在。
15. 哪些功能可直接复用现有实现。

严格禁止：
- 不修改代码
- 不删除文件
- 不处理 WARN
- 不凭空假设文件内容

完成后输出：
1. 是否创建报告。
2. P0 / P1 / P2 差异数量。
3. 推荐第一个 V2 开发 Task。
```

## 17.2 DAILY-1：数据模型与本地存储

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

现在执行 DAILY-1：今日星页数据模型与本地存储。

本轮唯一目标：
建立今日星页的纯数据层，使当天状态可以读取、保存和跨重启恢复；不开发任何 UI。

请先读取：
- deliverables/星钥塔罗_V2详细开发计划与Codex协作指南.md
- entry/src/main/ets/common/EmotionStarStorage.ets
- entry/src/main/ets/store/UserProfileStore.ets
- 项目中现有 Preferences / 本地存储相关实现

允许创建：
- entry/src/main/ets/daily/model/DailyDirection.ets
- entry/src/main/ets/daily/model/DailyRitualState.ets
- entry/src/main/ets/daily/model/DailyLightContent.ets
- entry/src/main/ets/daily/model/DailyReflection.ets
- entry/src/main/ets/daily/service/DailyRitualStore.ets

严格禁止修改：
- EmotionStarStorage.ets
- UserProfileStore.ets
- MainFramePage.ets
- Routes.ets
- 任何页面
- 抽牌、聊天、BGM、历史、头像昵称逻辑

数据要求：
1. dateKey 使用本地日期 YYYY-MM-DD。
2. 保存 direction、contentId、completed、replacedOnce、eveningReflection、savedToCalendar。
3. 次日读取时返回新的未完成状态。
4. 不实现连续签到。
5. 不保存完整聊天。
6. 不保存心理推断。
7. 提供可测试的重置能力，不暴露到用户界面。
8. 类型全部明确，不使用 any。
9. Preferences key 使用 daily_ritual_v1 前缀。

完成后编译并输出完整结果。
```

## 17.3 DAILY-2：文案库与稳定选择

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

现在执行 DAILY-2：今日星页本地文案库与稳定选择。

本轮唯一目标：
实现本地审核文案、日期种子、方向匹配、七天去重和每天最多换一次。

请先读取：
- deliverables/星钥塔罗_V2详细开发计划与Codex协作指南.md
- entry/src/main/ets/daily/model/
- entry/src/main/ets/daily/service/DailyRitualStore.ets
- 项目现有静态数据文件写法

允许创建：
- entry/src/main/ets/daily/data/DailyLightCopyLibrary.ets
- entry/src/main/ets/daily/service/DailyContentSeed.ets
- entry/src/main/ets/daily/service/DailyLightProvider.ets

允许修改：
- DailyRitualStore.ets，仅补充最近内容 ID 所需字段

实现要求：
1. 首批每个方向至少 5 条完整内容。
2. 每条包含 mainLine、observation、microAction、pocketLight。
3. 相同 dateKey 与 direction 稳定返回相同内容。
4. 最近七天不重复 contentId。
5. 每天最多换一次。
6. 换后持久化。
7. 不联网，不调用模型。
8. 不使用随机奖池、稀有度或运势词。
9. 文案不得包含红线词。
10. 为 provider 编写最小测试或项目现有等价验证。

完成后输出内容总数、去重规则、换一次规则和编译结果。
```

## 17.4 DAILY-3：占卜 Tab 今日星页 Hero

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

现在执行 DAILY-3：占卜 Tab 今日星页 Hero。

本轮唯一目标：
在占卜 Tab 顶部增加今日星页 Hero，展示未完成与已完成状态，并提供进入今日星页的入口。

请先读取：
- deliverables/stitch_to_arkui_harmony_refresh_plan.md
- deliverables/ui_harmony_refresh_acceptance_criteria.md
- deliverables/星钥塔罗_V2详细开发计划与Codex协作指南.md
- entry/src/main/ets/pages/MainFramePage.ets
- entry/src/main/ets/pages/DivinationCenterPage.ets
- entry/src/main/ets/components/DivinationEntryCard.ets
- entry/src/main/ets/common/Theme.ets
- entry/src/main/ets/daily/

允许创建：
- entry/src/main/ets/daily/components/DailyLightHeroCard.ets

允许修改：
- MainFramePage.ets 中 DivinationCenterTabContent 对应区域
- 或 DivinationCenterPage.ets，依据当前实际入口结构二选一

严格禁止：
- 不重构 MainFramePage
- 不修改其他 Tab
- 不修改底部导航
- 不修改占卜入口点击逻辑
- 不修改抽牌算法
- 不修改 EmotionStarStorage

文案：
未完成：
“今日星页”
“今天，想怎样站在自己这一边？”
“用不到一分钟，为今天留下一点方向。”
按钮：“展开今日星页”

已完成：
“今天已经点亮”
显示今日 mainLine
按钮：“回看今日微光”“和星澜说一句”

视觉：
- C 星钥之书为主，入口处融入 B 月湖映心
- 不大面积金色
- 主按钮圆角稳定
- 小屏可滚动
- 不遮挡现有占卜入口

完成后提供截图验收点与编译结果。
```

## 17.5 DAILY-4：今日星页完整页面

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

现在执行 DAILY-4：今日星页完整页面。

本轮唯一目标：
完成“选择方向 → 展开内容 → 换一次 → 确认完成”的主流程，但暂不接入情绪星点亮。

允许创建：
- entry/src/main/ets/daily/pages/DailyLightPage.ets
- entry/src/main/ets/daily/components/DailyDirectionChip.ets
- entry/src/main/ets/daily/components/StarKeyReveal.ets
- entry/src/main/ets/daily/components/DailyLightCard.ets

允许修改：
- Routes.ets，仅新增 DAILY_LIGHT 路由
- 项目路由注册文件
- DailyLightHeroCard.ets，接入跳转

必须实现：
1. 八个方向中展示四个。
2. 单选与跳过。
3. 星钥开页。
4. 三层内容。
5. 每天最多换一次。
6. 确认后写 DailyRitualStore.completed。
7. 减少动态效果降级。
8. TalkBack 可读。
9. 按钮和 Chip 所有状态圆角一致。
10. 小屏滚动完整。

暂不实现：
- EmotionStarStorage
- 每周星图
- 通知
- 服务卡片
- AI 生成

完成后编译并提供交接摘要。
```

## 17.6 DAILY-5：点亮适配与星光归档

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

现在执行 DAILY-5：今日星页与现有情绪星点亮适配。

本轮唯一目标：
完成今日星页确认后的“每日一次点亮”适配与星光归档动画，严格保持现有星历规则。

请先读取：
- EmotionStarStorage.ets
- EmotionStarPage.ets
- StarCalendarPage.ets
- DailyLightPage.ets
- DailyRitualStore.ets
- 星钥等级相关文件

允许创建：
- entry/src/main/ets/daily/service/EmotionStarDailyAdapter.ets

允许修改：
- DailyLightPage.ets
- DailyLightHeroCard.ets
- 必要的纯视觉组件

严格禁止：
- 不修改 EmotionStarStorage.ets 的规则
- 不改变每天一次
- 不改变未来日期不可点亮
- 不改变重复点亮不累计
- 不改变等级阈值
- 不修改历史记录结构

实现要求：
1. 确认今天是否已点亮。
2. 已点亮时只完成星页，不重复累计。
3. 未点亮时调用现有能力。
4. 成功后播放轻量星光归档。
5. 减少动态效果时只做淡入。
6. 失败时保留星页内容，并给可重试文案。
7. 不出现“奖励到账”。

完成后输出调用链、规则保护确认和编译结果。
```

## 17.7 DAILY-7：月湖回望

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

现在执行 DAILY-7：月湖回望。

本轮唯一目标：
为已完成今日星页的用户提供一次可选、可跳过的日末复盘。

允许创建：
- entry/src/main/ets/daily/components/EveningReflectionCard.ets
- 如项目结构需要，可创建 DailyReflectionPage.ets

允许修改：
- DailyLightHeroCard.ets
- DailyRitualStore.ets，仅保存回望枚举
- StarCalendarPage.ets，仅在用户主动保存时展示摘要入口；范围过大则本轮不修改

快捷选项：
- 我完成了一件小事
- 我保护了一次自己的边界
- 我让自己休息了一会儿
- 今天有点难，暂时说不出来

要求：
1. 不强制晚上才能进入。
2. 不自动通知。
3. 不要求填写长文本。
4. 用户可直接“今天到这里”。
5. 只有主动确认才保存。
6. 不保存完整聊天。
7. 不将“今天很难”标记为失败。
8. 保持 B 月湖映心风格。

完成后编译并给截图验收点。
```

## 17.8 CHAT-2：十二状态与策略退避

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

现在执行 CHAT-2：星澜十二状态与策略历史增量实现。

本轮是核心逻辑任务，请使用高推理。

请先读取：
- deliverables/星钥塔罗_V2详细开发计划与Codex协作指南.md
- entry/src/main/ets/xinglan/engine/
- entry/src/main/ets/xinglan/data/
- XinglanSessionManager
- XinglanRouter
- XinglanAnalyzer
- XinglanComposer
- XinglanInteractionFlowEngine
- XinglanSafetyGuard

本轮必须先输出：
1. 当前真实管线图。
2. 哪些状态已经存在。
3. 最小增量方案。
4. 允许修改的精确文件。

增量加入：
ENTRY、RECEIVE、CLARIFY、CAUSE_FOCUS、COMFORT、QUIET、ORGANIZE、MICRO_ACTION、CALMING、CLOSE、BOUNDARY、SAFETY。

规则：
- 每轮最多一个问题
- 首次承接不提问
- 同策略最多连续两轮
- 三轮无新信息时转整理或安静
- 拒绝建议后四轮退避
- “不想说”后不追问
- “你不懂”后回退承接
- Safety 优先级最高

严格禁止：
- 不删除现有引擎
- 不重写管线
- 不改 UI
- 不修改网络接口
- 不改 BGM
- 不使用 any / as any / @ts-ignore

必须为状态转移和退避规则提供测试或可复现验证。
编译后输出完整交接。
```

## 17.9 FINAL-V2：最终回归

```text
请先读取项目根目录 AGENTS.md，并严格遵守其中所有规则。

项目路径：
D:\XingKeyTarot

现在执行 FINAL-V2：V2 最终回归与上架风险检查。

本轮只修复阻塞问题，不做视觉扩展。

检查：
1. 今日星页首次与重复进入。
2. 次日重置。
3. 每天最多换一次。
4. 七天去重。
5. 情绪星每天一次。
6. 未来日期不可点亮。
7. 漏一天不清零。
8. 月湖回望。
9. 每周星图累计非连续。
10. 五种陪伴方向。
11. 十二状态。
12. 建议退避。
13. 安静陪伴。
14. 情绪降噪。
15. 预测、依赖、医疗与高风险。
16. 占卜结果纠偏。
17. 结果进入聊天。
18. 隐私存储。
19. 减少动态效果。
20. 小屏与大字体。

搜索红线词并区分：
- 用户正向输出
- 安全检测词库

编译目标：
BUILD SUCCESSFUL
ERROR=0

创建：
deliverables/v2_final_acceptance_report.md

按 P0 / P1 / P2 列问题。
未发现阻塞问题时明确写：
“本轮未发现阻塞 V2 上架的 P0 问题。”
```

---

# 18. 测试、验收与发布门槛

## 18.1 今日星页

- 当天内容稳定；
- 次日内容更新；
- 七天内不重复；
- 每天最多换一次；
- 退出重进不丢失；
- 完成后 Hero 更新；
- 已点亮情绪星时不重复累计；
- 漏一天不清零；
- 无网络仍可用。

## 18.2 UI

- 小屏完整滚动；
- 大字体不截断；
- TalkBack 可读；
- 所有按压状态圆角稳定；
- 暖金面积受控；
- 不出现强闪光；
- 动效关闭后流程仍完整；
- 后台不持续运行动画。

## 18.3 文案

- 不预测未来；
- 不出现连续签到压力；
- 不出现排他关系；
- 不暗示星澜等待用户；
- 不使用“亲爱的”“宝贝”；
- 不把负面一天判定为失败；
- 不把完成称为领奖；
- 允许用户否认内容。

## 18.4 编译

每个 Task：

```text
cd D:\XingKeyTarot
node "D:\HarmonyOS\DevEco Studio\tools\hvigor\bin\hvigorw.js" assembleHap --mode module -p module=entry@default -p product=default --no-daemon
```

目标：

```text
BUILD SUCCESSFUL
ERROR=0
```

## 18.5 真机必测

- 首次打开月湖抵达；
- 长按与普通点击开页；
- 返回栈；
- App 重启；
- 日期跨天；
- 时区变化；
- 系统大字体；
- TalkBack；
- 减少动态效果；
- 低性能设备；
- 前后台切换；
- 通知隐私；
- 服务卡片隐私；
- 情绪星重复点亮；
- 星历记录；
- 分享卡保存。

---

# 19. 最终交付清单

## 产品

- 今日星页；
- 口袋微光；
- 月湖回望；
- 每周星图；
- 累计点亮；
- 无惩罚回访；
- 五种星澜方向；
- 十二状态；
- 安静陪伴；
- 情绪降噪；
- 占卜结果纠偏；
- 占卜进入聊天；
- 安全边界。

## 视觉

- 月湖抵达；
- 星钥开页；
- 星光归档；
- A/B/C 三套视觉串联；
- 减少动态效果；
- 性能降级。

## 工程

- Daily 数据模型；
- 本地文案 Provider；
- Daily Store；
- EmotionStar 适配；
- 结构化文案库；
- 状态与策略历史；
- 测试与回归报告。

## Codex 协作

- 一个窗口一个 Task；
- 每轮读取四份核心文档；
- 精确允许修改范围；
- 编译；
- diff 审查；
- 真机验收；
- 交接摘要；
- 每个任务一个提交。

---

# 最终产品判断

星钥塔罗 V2 的留存机制不是：

```text
“今天不来就会失去什么。”
```

而是：

```text
“今天回来，会得到一小段值得带走的东西。”
```

星澜的价值不是：

```text
“让用户依赖她。”
```

而是：

```text
“帮助用户更愿意站回自己这一边。”
```

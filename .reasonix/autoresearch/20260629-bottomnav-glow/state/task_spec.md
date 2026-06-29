# 底部导航毛玻璃胶囊修复与质感优化专项

## Goal
将 CompanionBottomNav.ets 的光影从金色改为月白色，减弱中间星澜按钮阴影，调整光影尺寸。

## Scope
- 仅修改 `entry/src/main/ets/components/CompanionBottomNav.ets`

## Non-goals
- 不改 HomePage.ets
- 不改路由/抽牌/历史/隐私门禁
- 不重构组件结构

## Success criteria
- hvigor assembleHap ERROR=0
- 光影渐变为月白 rgba(235,242,255,0.14)
- 按钮阴影 alpha 从 0.32 降至 0.22
- 5键导航结构不变
- 点击范围不变

## Verification gates
1. 代码改动符合 ArkTS 严格类型规范
2. assembleHap 编译 ERROR=0

# Task Spec: 星钥塔罗 鸿蒙 MVP

## Goal
从零实现可在手机端运行的 HarmonyOS NEXT 原生塔罗 App MVP，包含圣三角占卜、每日一占、桌面万能卡片、分享图、合规提示和基础新手引导。

## Scope (P0 only)
- 圣三角 3 张牌占卜
- 78 张牌模型与正逆位解读
- 每日一占（同一自然日结果固定）
- 桌面万能卡片 2×2
- 分享图生成 + 系统分享
- 合规提示（首次启动弹窗 + 结果页 + 分享图）
- 新手引导 3 页

## Non-Goals
- 碰一碰、跨设备流转、手表、智慧屏
- 命运回廊剧情、12 种牌阵
- AI 解读、登录/账号/云同步/付费

## Tech Stack
- HarmonyOS NEXT, ArkTS, ArkUI, Stage Model
- Preferences 本地存储
- rawfile 静态 JSON 数据
- FormExtensionAbility 万能卡片

## Success Criteria
1. 工程可编译（最终环境验证）
2. 首次启动免责声明 → 新手引导 → 首页流程完整
3. 圣三角占卜 3 张不重复，正逆位正确
4. 每日一占同日同用户结果一致
5. 2×2 桌面卡片显示且点击跳转正确
6. 分享图生成含免责声明
7. 全量单元测试通过
8. 无 P1/P2 功能代码混入

## Verification Gates
- JSON 数据格式校验
- 单元测试逻辑审查
- 文件结构完整性检查
- 代码分层规范审查

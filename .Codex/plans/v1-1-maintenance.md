# v1.1 Maintenance

**Created:** 2026-06-23 00:00
**Status:** done

## Goal

完成星钥塔罗 v1.1 的维护型迭代：优先降低 deprecated API / warning 风险，并让桌面卡片具备稳定的每日刷新能力。

## Context

v1.0 MVP 已上架并可编译通过；v1.1 不扩大功能面，先解决长期维护、SDK 兼容和桌面卡片体验问题。

## Tasks

- [x] 梳理当前编译 warning 和 deprecated API 来源
- [x] 以最小改动修复可确认的 deprecated API / warning
- [x] 检查并完善桌面 2×2 万能卡片每日刷新逻辑
- [x] 验证编译、关键静态检查和改动范围

## Progress Log

| Time | What happened |
|------|---------------|
| 2026-06-23 00:00 | Plan created for v1.1 maintenance work |
| 2026-06-23 00:00 | Removed ArkTS deprecated API warnings for page context, routing, toast, and image packing |
| 2026-06-23 00:00 | Verified widget refresh config: 06:00 scheduled refresh, 48 half-hour duration, 2×2 dimension |
| 2026-06-23 00:00 | `assembleHap` build successful; remaining warnings are DevEco toolchain Unsafe and missing signingConfig |
| 2026-06-23 00:00 | Fixed widget `@Entry(storage)` warning and verified with clean `assembleHap` |

## Decisions

- v1.1 只做维护型迭代：deprecated API / warning 优先，卡片每日刷新其次，不引入账号、云同步、付费或复杂牌阵。
- 页面侧改用 `UIContext` 获取路由、Toast 和宿主 Context；不新增全局导航封装，避免过度抽象。
- 分享兜底服务只负责复制文本，用户提示由页面统一处理，避免重复 Toast。

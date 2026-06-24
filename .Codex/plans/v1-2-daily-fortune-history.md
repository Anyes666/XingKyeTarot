# v1.2 Daily Fortune History

**Created:** 2026-06-23
**Status:** in progress

## Goal

推进 v1.2 的每日一占历史记录能力，让每日运势生成后自动进入本地历史，为后续历史列表、心情记录和连续打卡打基础。

## Success Criteria

- 每日运势生成后自动写入本地历史。
- 同一天重复打开不会产生重复历史记录。
- 可读取最近历史记录，供后续 UI 页面使用。
- 历史损坏时可见日志并重置，不静默返回脏数据。
- `assembleHap --no-daemon` 构建通过。

## Tasks

- [x] 增加每日运势历史 Preferences key 和保留上限。
- [x] 在 `DailyFortuneService.getTodayFortune` 中归档生成结果和缓存命中结果。
- [x] 增加 `getRecentFortunes` 读取 API。
- [x] 增加同日去重测试用例。
- [x] 验证应用构建。
- [x] 在每日一占页增加最近记录入口。
- [ ] 增加心情记录与连续打卡。

## Progress Log

| Time | What happened |
|------|---------------|
| 2026-06-23 | Added local daily fortune history archive in `DailyFortuneService`. |
| 2026-06-23 | Added same-day dedupe test coverage for history archive. |
| 2026-06-23 | Verified `assembleHap --no-daemon` build success. |
| 2026-06-23 | Added a visible recent-history section to `DailyFortunePage`. |

## Decisions

- 本轮先做服务层归档，不直接加历史列表 UI，避免在入口位置和交互未确认时扩大页面改动。
- 历史以完整 `DailyFortune[]` JSON 存在 Preferences 中，当前上限 30 条；这是 v1.2 足够轻量的方案。
- 缓存命中也执行归档，保证升级后当天已有缓存的用户也能补写历史。

## Art Progress

- [x] 22 张大阿卡纳正式牌面已生成并放入 `entry/src/main/resources/base/media/`。
- [x] 大阿卡纳数据已从 `placeholder_card.png` 切换到对应 `tarot_major_*.png`。
- [x] 已生成 `major-arcana-contact-sheet.png` 用于快速视觉 QA。
- [ ] 小阿卡纳 56 张仍使用占位图，后续可按套系分批生成。

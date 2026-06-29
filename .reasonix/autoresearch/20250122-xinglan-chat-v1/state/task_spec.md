# Task Spec: 星澜聊天系统 v1.2

## Goal
实现星澜本地离线陪伴聊天系统（XinglanChat），包括类型层、语料库、关键词匹配引擎、策略路由、文案拼装、安全校验、会话管理、聊天UI页面。

## Scope
- 新增 `xinglan/types/XinglanTypes.ets`
- 新增 `xinglan/data/XinglanCorpus.ets`（首批60-80条）
- 新增 `xinglan/data/XinglanKeywords.ets`
- 新增 `xinglan/data/XinglanTemplates.ets`
- 新增 `xinglan/engine/XinglanSpecialIntentResolver.ets`
- 新增 `xinglan/engine/XinglanAnalyzer.ets`
- 新增 `xinglan/engine/XinglanRouter.ets`
- 新增 `xinglan/engine/XinglanComposer.ets`
- 新增 `xinglan/engine/XinglanSafetyGuard.ets`
- 新增 `xinglan/engine/XinglanSessionManager.ets`
- 新增 `pages/XinglanChatPage.ets`
- 修改 `common/Routes.ets`（新增路由常量）
- 修改 `main_pages.json`（注册新页面）
- 修改 `pages/SettingsPage.ets`（临时测试入口+开关）

## Non-goals
- 不修改 HomePage 星澜按钮行为
- 不修改 CompanionBottomNav 五栏结构
- 不做聊天记录持久化
- 不做打字动画
- 不联网
- 不用AI/ML

## Success Criteria
1. 全部文件编译 ERROR=0
2. 10句固定测试用例输出符合预期
3. 安全边界能短路
4. 输出不含禁用词
5. 连续10轮无重复文案

## Stages
0. 只读现状核对
1. 类型层
2. 语料/关键词/模板
3. SpecialIntentResolver + Analyzer + Router
4. Composer + SafetyGuard + SessionManager
5. ChatPage UI MVP
6. 路由注册 + 临时入口
7. 真机测试与语料调权

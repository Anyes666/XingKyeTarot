# 项目结构整理 — 待人工确认清单

> 整理日期：2026-06-30
> 以下目录本轮未移动，需后续人工确认处理时机。

---

## 1. 沉浸式UI/

**现状**：完整 HarmonyOS 示例参考项目（54 文件：16 json5、15 png、7 txt、6 ets、5 ts）

**暂不移动原因**：
- 完整参考项目，移动后可能影响后续查阅路径
- 含 ets/ts 源码，移动需重新验证内部引用

**后续建议**：App 上架前统一整理到 `reference/immersive-ui/`

---

## 2. Tarot-main/

**现状**：Web 版塔罗参考项目（20 文件：17 js、1 css、1 html、1 md）

**暂不移动原因**：
- 参考代码项目，不在本轮移动范围
- 可能含相对路径引用

**后续建议**：统一放 `reference/tarot-web/`

---

## 3. milk-main/

**现状**：Web 版牛奶参考项目（20 文件：17 js、1 css、1 html、1 md）

**暂不移动原因**：
- 参考代码项目，同 Tarot-main

**后续建议**：统一放 `reference/milk-web/`

---

## 4. xingkey-tarot-website/

**现状**：星钥塔罗官网 Landing Page 项目

**暂不移动原因**：
- 官网项目还在继续设计
- 当前路径可能正在被部署或预览使用
- 贸然移动会影响线上访问

**后续建议**：官网稳定后迁移到 `website/xingkey-tarot-landing/`

---

## 5. hvigor/

**现状**：HarmonyOS 构建工具相关目录（1 json5）

**暂不移动原因**：
- 与构建工具或项目环境有关
- 移动可能导致构建异常，风险过高

**后续建议**：永久保留原位，不移动

---

## 待确认事项汇总

| 目录 | 建议时机 | 建议目标 |
|------|----------|----------|
| 沉浸式UI/ | App 上架前 | reference/immersive-ui/ |
| Tarot-main/ | 后续统一整理 | reference/tarot-web/ |
| milk-main/ | 后续统一整理 | reference/milk-web/ |
| xingkey-tarot-website/ | 官网稳定后 | website/xingkey-tarot-landing/ |
| hvigor/ | 永不移动 | 原位保留 |

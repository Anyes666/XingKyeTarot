# 星钥塔罗 上架提交清单

## 概览

本文档是上架华为应用市场（AppGallery）的完整操作指南，按步骤顺序排列。每完成一步请勾选。

---

## 第一阶段：开发者账号（前置条件）

- [ ] 1. 注册华为开发者账号（https://developer.huawei.com）
- [ ] 2. 完成个人/企业实名认证
  - 个人：身份证正反面 + 实名手机号
  - 企业：营业执照 + 法人身份证 + 对公账户
- [ ] 3. 登录 AppGallery Connect（https://developer.huawei.com/consumer/cn/agconnect/）
- [ ] 4. 在 AGC 创建应用，填写包名 `com.xingkey.tarot`

> **占卜类应用注意**：华为审核对占卜算命类应用有内容合规要求。本应用已内置免责声明（"仅供娱乐，不构成专业建议"），在应用描述中务必强调"娱乐"属性，分类选择"生活服务-休闲娱乐"而非"占卜算命"。

---

## 第二阶段：签名证书配置（关键）

当前 `build-profile.json5` 中 `signingConfigs` 为空，必须配置签名才能发布。

### 2.1 生成本地密钥和 CSR

- [ ] 5. 在 DevEco Studio 中：Build → Generate Key And CSR
- [ ] 6. 填写 Key store 路径、密码、Alias、Alias 密码
- [ ] 7. 填写证书信息（姓名、组织、城市等）
- [ ] 8. 生成 `.p12`（密钥库）和 `.csr`（证书签名请求）文件

### 2.2 在 AGC 申请发布证书

- [ ] 9. 进入 AGC → 用户与访问 → 证书管理
- [ ] 10. 点击"新增证书"，上传 `.csr` 文件，选择"发布证书"
- [ ] 11. 下载生成的 `.cer` 发布证书文件

### 2.3 申请 Profile 文件

- [ ] 12. 进入 AGC → 用户与访问 → Profile 管理
- [ ] 13. 点击"新增 Profile"，选择应用 `com.xingkey.tarot`，选择发布证书
- [ ] 14. 下载生成的 `.p7b` Profile 文件

### 2.4 配置项目签名

- [ ] 15. 修改 `build-profile.json5`，填写签名配置：

```json5
{
  "app": {
    "signingConfigs": [
      {
        "name": "default",
        "type": "HarmonyOS",
        "material": {
          "certpath": "路径/xxx.cer",
          "storePassword": "你的密钥库密码",
          "keyAlias": "你的alias",
          "keyPassword": "你的alias密码",
          "profile": "路径/xxx.p7b",
          "signAlg": "SHA256withECDSA",
          "storeFile": "路径/xxx.p12"
        }
      }
    ],
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compatibleSdkVersion": "5.0.0(12)",
        "runtimeOS": "HarmonyOS",
        "targetSdkVersion": "6.1.1(24)"
      }
    ]
  }
}
```

- [ ] 16. 在 DevEco Studio 中选择 Release 模式编译验证签名是否通过

---

## 第三阶段：代码合规修改（提交前必做）

### 3.1 权限 reason 字段

- [x] 17. ~~修改 `entry/src/main/module.json5`，为权限添加 reason~~ ✅ 已完成
- [x] 18. ~~在 `entry/src/main/resources/base/element/string.json` 中添加 reason 字符串~~ ✅ 已完成

### 3.2 应用版本信息确认

当前配置已正确，确认无需修改：

| 项目 | 当前值 | 状态 |
|------|--------|------|
| bundleName | com.xingkey.tarot | ✅ |
| versionCode | 1000000 | ✅ |
| versionName | 1.0.0 | ✅ |
| app_name | 星钥塔罗 | ✅ |
| deviceTypes | ["phone"] | ✅ |

---

## 第四阶段：编译打包

- [ ] 19. 在 DevEco Studio 中选择 Release 模式
- [ ] 20. 执行 Build → Build Hap(s)/APP(s) → Build APP(s)
- [ ] 21. 确认输出 `.app` 文件（位于 `entry/build/intermediates/release/`）
- [ ] 22. 检查包大小（应远低于 100MB 限制）

---

## 第五阶段：AGC 应用信息填写

### 5.1 基本信息

- [ ] 23. AGC → 我的应用 → 星钥塔罗 → 应用信息
- [ ] 24. 默认语言：简体中文
- [ ] 25. 应用名称：星钥塔罗
- [ ] 26. 一级分类：生活服务
- [ ] 27. 二级分类：休闲娱乐
- [ ] 28. 应用简介（≤80字）：见 `app-description.md` 中的简短描述
- [ ] 29. 应用描述：见 `app-description.md` 中的完整描述
- [ ] 30. 关键词：塔罗,占卜,塔罗牌,每日运势,圣三角,运势,自我探索,桌面卡片

### 5.2 应用图标与素材

- [ ] 31. 应用图标：上传 512×512 PNG（从 `AppScope/resources/base/media/app_icon.png` 重新导出或制作高分辨率版）
- [ ] 32. 应用截图：至少 3 张竖屏截图（详见 `screenshot-guide.md`）
- [ ] 33.（可选）演示视频：≤3分钟 MP4

### 5.3 隐私政策

- [x] 34. 隐私政策已部署到 Gitee Pages ✅ 待手动启用
- [x] 35. AGC 隐私政策链接：**`https://anyes666.gitee.io/xingkey-tarot/privacy-policy.html`**
- [x] 36. 隐私政策摘要：本应用为纯本地离线应用，不收集任何用户个人信息，所有数据存储在设备本地

### 5.4 权限说明

- [ ] 37. 在 AGC 权限说明栏填写：见 `permission-usage.md`

### 5.5 用户协议

- [x] 38. 用户协议链接：**`https://anyes666.gitee.io/xingkey-tarot/user-agreement.html`** ✅ 待启用
- [ ] 39. 在 AGC 用户协议栏填写链接（如有该字段）

---

## 第六阶段：提交审核

- [ ] 40. AGC → 版本管理 → 准备提交版本
- [ ] 41. 上传 `.app` 包文件
- [ ] 42. 填写版本号：1.0.0
- [ ] 43. 填写版本说明：见 `release-notes.md`
- [ ] 44. 上传截图素材
- [ ] 45. 确认隐私政策链接有效（HTTPS 可访问）
- [ ] 46. 提交审核

---

## 第七阶段：审核期间注意事项

### 审核周期
- 通常 1-3 个工作日
- 可在 AGC 后台查看审核进度

### 常见驳回原因及预防

| 风险项 | 本应用状态 | 备注 |
|--------|-----------|------|
| 权限滥用 | ✅ 安全 | 仅 1 个保存图片权限，已提供 reason；无后台常驻权限 |
| 隐私政策缺失 | ✅ 已托管 | https://anyes666.github.io/xingkey-tarot/privacy-policy.html |
| 用户协议/隐私政策/免责声明缺失 | ✅ 已有 | 应用内首次启动弹窗 + 结果页固定展示 |
| 诱导消费 | ✅ 安全 | 无付费功能、无广告 |
| 内容违规 | ✅ 安全 | 塔罗内容为原创，无敏感信息 |
| 图标版权 | ⚠️ 需确认 | 确认 app_icon.png 为原创或已获授权 |
| 字体版权 | ⚠️ 需确认 | 确认未使用未授权商业字体 |

### 审核被驳回怎么办

1. 查看 AGC 后台的驳回原因说明
2. 根据原因修改代码或资料
3. 重新编译打包上传
4. 重新提交审核

---

## 文件清单

上架所需全部资料文件：

```
docs/release/
├── app-description.md      # 应用描述（简短+完整+关键词）
├── privacy-policy.md        # 隐私政策（Markdown 参考版）
├── privacy-policy.html      # 隐私政策（托管用网页版，可直接部署）
├── user-agreement.md        # 用户协议（Markdown 参考版）
├── user-agreement.html      # 用户协议（托管用网页版，可直接部署）
├── index.html               # 导航首页（隐私政策+用户协议入口）
├── permission-usage.md      # 权限使用说明
├── release-notes.md         # 版本说明
├── submission-checklist.md  # 本文件（提交清单）
└── screenshot-guide.md      # 截图拍摄指南
```

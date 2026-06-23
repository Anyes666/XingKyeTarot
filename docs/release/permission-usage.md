# 星钥塔罗 权限使用说明

## 权限清单

本应用仅申请以下 1 项权限：

| 权限名称 | 权限级别 | 申请理由 | 是否涉及用户数据 |
|---------|---------|---------|----------------|
| ohos.permission.KEEP_BACKGROUND_RUNNING | normal | 桌面卡片定时更新 | 否 |

---

## 权限详细说明

### ohos.permission.KEEP_BACKGROUND_RUNNING（后台运行权限）

**申请原因：**
本应用提供"每日一占"桌面卡片功能。为确保桌面卡片能够在每日凌晨6点自动更新运势内容，需要维持应用的后台服务运行。

**具体用途：**
- 桌面卡片（DailyFortuneWidget）按系统调度定时刷新数据
- 应用回到前台时刷新卡片内容

**不涉及的数据：**
- 此权限仅允许应用在后台保持运行状态
- 不读取、不收集、不传输任何用户数据
- 不访问位置、通讯录、存储等敏感信息

**用户可控制：**
- 用户可在系统设置中随时关闭应用的后台运行权限
- 关闭后不影响应用内占卜功能，仅桌面卡片无法自动更新

---

## 未申请的敏感权限（声明）

本应用**不申请**以下任何权限：

| 权限类别 | 未申请权限 |
|---------|-----------|
| 位置 | ohos.permission.LOCATION, APPROXIMATELY_LOCATION |
| 网络 | ohos.permission.INTERNET |
| 相机 | ohos.permission.CAMERA |
| 麦克风 | ohos.permission.MICROPHONE |
| 通讯录 | ohos.permission.READ_CONTACTS |
| 存储 | ohos.permission.READ_MEDIA, WRITE_MEDIA |
| 电话 | ohos.permission.READ_CALL_LOG |
| 短信 | ohos.permission.READ_MESSAGES |
| 日历 | ohos.permission.READ_CALENDAR |
| 健康数据 | ohos.permission.READ_HEALTH_DATA |

本应用为纯本地离线应用，无网络请求功能，不需要 INTERNET 权限。

---

## module.json5 配置参考

当前 `entry/src/main/module.json5` 中的权限声明：

```json5
"requestPermissions": [
  {
    "name": "ohos.permission.KEEP_BACKGROUND_RUNNING"
  }
]
```

> **审核提示**：建议为权限添加 `reason` 字段，向用户说明权限用途。修改如下：
> ```json5
> "requestPermissions": [
>   {
>     "name": "ohos.permission.KEEP_BACKGROUND_RUNNING",
>     "reason": "$string:permission_reason_background",
>     "usedScene": {
>       "abilities": ["DailyFortuneFormAbility"],
>       "when": "always"
>     }
>   }
> ]
> ```
> 并在 `entry/src/main/resources/base/element/string.json` 中添加：
> ```json
> { "name": "permission_reason_background", "value": "用于桌面卡片定时更新每日运势" }
> ```

# 星钥塔罗 权限使用说明

## 权限清单

本应用当前仅申请以下 1 项权限：

| 权限名称 | 权限级别 | 申请理由 | 是否收集用户数据 |
|---------|---------|---------|----------------|
| ohos.permission.WRITE_IMAGEVIDEO | user_grant | 用户主动保存占卜结果分享图片到系统相册 | 否 |

---

## 权限详细说明

### ohos.permission.WRITE_IMAGEVIDEO（保存图片权限）

**申请原因：**

本应用提供“保存分享图片”功能。用户完成占卜后，可主动点击按钮，将占卜结果生成的图片保存到系统相册。

**具体用途：**

- 将用户主动生成的占卜结果图片写入系统相册；
- 保存成功后提示用户“已保存到相册”；
- 如用户拒绝授权或保存失败，应用会降级为剪贴板文字兜底。

**不涉及的行为：**

- 不读取用户相册中的既有图片；
- 不上传、分析或共享相册内容；
- 不在后台自动保存图片；
- 不访问位置、相机、麦克风、通讯录等敏感数据。

**用户可控性：**

- 该权限仅在用户主动保存图片时触发；
- 用户可以拒绝授权，拒绝后不影响占卜、每日一占、桌面卡片等核心功能；
- 用户可在系统设置中管理该权限。

---

## 未申请的敏感权限

本应用不申请以下权限：

| 权限类别 | 未申请权限 |
|---------|-----------|
| 位置 | ohos.permission.LOCATION, APPROXIMATELY_LOCATION |
| 网络 | ohos.permission.INTERNET |
| 相机 | ohos.permission.CAMERA |
| 麦克风 | ohos.permission.MICROPHONE |
| 通讯录 | ohos.permission.READ_CONTACTS |
| 后台常驻 | ohos.permission.KEEP_BACKGROUND_RUNNING |

本应用为本地离线应用，无网络请求功能，不需要 INTERNET 权限。桌面卡片依赖系统 Form 调度与应用前台刷新，不依赖后台常驻权限。

---

## module.json5 当前配置参考

```json5
"requestPermissions": [
  {
    "name": "ohos.permission.WRITE_IMAGEVIDEO",
    "reason": "$string:save_image_reason",
    "usedScene": {
      "abilities": ["EntryAbility"],
      "when": "inuse"
    }
  }
]
```

对应文案：

```json
{ "name": "save_image_reason", "value": "用于将占卜结果图片保存到系统相册" }
```

---

## 审核说明建议

如审核询问该权限用途，可说明：

> 星钥塔罗仅在用户主动点击“保存分享图片”时申请相册写入权限，用于将本地生成的占卜结果图片保存到系统相册。应用不会读取、上传或分析用户相册内容；用户拒绝授权后仍可使用占卜功能，并会降级为剪贴板文字兜底。

# 星钥塔罗 — XingKey Tarot

HarmonyOS NEXT 原生塔罗式情绪陪伴与自我探索应用，使用 ArkTS、ArkUI 和 Stage 模型开发。**本分支为本地离线版本**，没有服务器、账号、联网大模型或 API Key 配置。

## 当前功能与边界

- 单牌快占、圣三角、关系探索、旋转牌轮四种模式。
- 编译期内嵌 78 张塔罗牌、156 条正逆位解读，可查看卡牌详情。
- 规则与模板驱动的离线陪伴引擎：22 类高频直答、40 组回复变体；变体内共 106 个文本片段。片段数不是完整回复数。
- 占卜历史保留最近 50 条，超过上限移除最旧记录；昵称、头像、BGM 偏好存储在本机。
- 分享卡、背景音乐、星历/情绪星、离线互动等功能。
- 首次启动隐私确认、结果页和分享图免责声明、内容规则拦截。

它不是本地大语言模型，不预测未来、不提供专业诊断或决定。规则拦截有边界，不代表法律认证或对所有输入的安全保证。源码构建验证不等于应用商店已上架；商店版本及上架状态需单独核验。

## 拉取后能否使用

可以获取完整离线源码和应用资源。开发者证书、签名文件和口令**不随仓库分发**，默认构建不绑定个人签名。普通电脑可做 Node 源码检查；构建和安装鸿蒙应用需要 DevEco Studio 与 HarmonyOS SDK。

首次使用无需账号或联网聊天服务；分享保存和相册交互仍需要设备授权。仓库含图片、音乐及历史设计资料，下载体积较大，可用浅克隆减少历史下载量：

```bash
git clone --depth 1 https://github.com/Anyes666/XingKyeTarot.git
cd XingKyeTarot
```

仓库名 `XingKyeTarot` 与产品英文名 `XingKey Tarot` 的拼写不同，克隆时请使用上面的实际仓库地址。

## 开发环境

| 工具 | 要求 |
|---|---|
| DevEco Studio | 支持工程 `modelVersion: 6.1.1` 的工具链 |
| HarmonyOS SDK | 工程当前 target/compatible 均为 `5.0.0(12)`；按 IDE 提示安装兼容组件 |
| Node / Hvigor / OHPM | 优先使用 DevEco 随附版本 |
| 设备 | 支持本项目 SDK 的鸿蒙设备或模拟器；实际兼容性需设备验证 |
| Node 检查 | Node.js 18+，npm，锁定的 TypeScript 开发依赖 |

不要把最低兼容版本理解为“全部鸿蒙版本均经过测试”。本项目不生成 Android APK，HarmonyOS 4.x 及以下不在声明范围内。

## 从 DevEco Studio 构建与运行

1. 在 IDE 选择 **Open**，打开包含 `oh-package.json5` 的仓库根目录。
2. 完成 SDK 与依赖同步。根项目、`entry` 是本应用；历史设计目录不是第二个构建入口。
3. 先执行 **Build Hap(s)/APP(s) > Build Hap(s)**。默认配置可生成未签名 HAP。
4. 需要装到手机时，在项目签名设置中生成或选择**自己的 Debug 签名**，并将当前产品关联到该签名。
5. 连接允许 USB 调试的设备，或启动手机模拟器，选择 `entry` 后运行。
6. 首次启动完成隐私确认，再测试抽牌、历史保存、分享和 BGM。

不同 DevEco 版本菜单文字可能有差异。签名通常在 **File > Project Structure > Signing Configs** 配置。该步骤会修改本机 `build-profile.json5`；不要把证书路径和口令提交回公共仓库。

生成包通常在 `entry/build/default/outputs/default/`。**未签名包构建成功不等于能安装**，请用 IDE 完成自己的签名与安装。

## 命令行构建（Windows PowerShell）

提供 `tools/build.ps1`，负责定位工具链、安装 OHPM 依赖和执行 Hvigor，不创建或复制任何签名：

```powershell
# 将路径改为你自己的 DevEco Studio 安装目录
.\tools\build.ps1 -DevEcoHome "D:\HarmonyOS\DevEco Studio" -Target main
.\tools\build.ps1 -DevEcoHome "D:\HarmonyOS\DevEco Studio" -Target test
```

也可设置 `$env:DEVECO_HOME` 后省略 `-DevEcoHome`。脚本以自身位置确定仓库根目录，支持带空格路径；失败会明确报错，并恢复临时设置的环境变量。`-Target test` **只构建测试 HAP，不执行设备测试**。

等价核心步骤是在已配置 DevEco 工具路径的终端运行：

```text
ohpm install --all
hvigorw --mode module -p product=default -p module=entry@default assembleHap --no-daemon
hvigorw --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon
```

## 不依赖设备的源码检查

```bash
npm ci
npm test
```

`npm ci` 只安装验证用的 TypeScript，不替代 `ohpm install`，也不改变应用依赖。

检查分为两层：

1. `tools/test_source.js` 转译并执行实际的纯 ArkTS 数据和意图解析模块，核验 78 张卡牌与解读映射、22 类/40 组直答、历史上限，以及告别优先等意图样例。
2. `tools/xinglan_auto_check.js` 检查源文件指纹，并运行安全分类/输出规则的 **57 个镜像断言**。镜像通过不等于完整 ArkTS 引擎或 UI 已通过设备测试。

指纹统一将 CRLF 转为 LF 后计算，避免 Windows Git 换行转换导致误报。真实源码变化仍会失败。遇到 `SOURCE_DRIFT_DETECTED` 时先审查变更及测试，再执行：

```bash
node tools/xinglan_auto_check.js --update-manifest
npm test
```

不要仅更新指纹来掩盖未经验证的规则变化。特殊意图的真实源码测试已补充告别与问候的优先级；镜像脚本自身并不模拟全部特殊意图。

## 真机 / 模拟器验证

通过 DevEco 为主 HAP 与测试 HAP 配置相同的调试签名，安装两者，然后在 IDE 执行 `entry/src/ohosTest/ets/test/List.test.ets` 对应测试。

发版前还需人工确认：

- 首次隐私确认、拒绝与重启行为。
- 四种抽牌模式、78 张图片和正逆位解读。
- 历史记录写入、超过 50 条后的清理、重启持久化。
- 分享图免责声明、相册权限拒绝和保存成功。
- BGM 开关、切页与前后台恢复。
- 聊天退出/重入、内容规则、危机输入引导。

这些设备行为不能由 Node 转译测试或构建成功代替。2026-09-09 的本次修复验证会分别报告源码测试、主包构建、测试包构建；不沿用历史报告中的设备测试数量作为本次通过结果。

## 数据与隐私

| 内容 | 存储位置/方式 |
|---|---|
| 卡牌与解读 | `entry/src/main/ets/data/` 中的常量 |
| 占卜历史 | Preferences，最近 50 条 |
| 隐私确认 | 本机 Preferences |
| 昵称/头像/BGM 设置 | 应用本地存储与私有文件 |
| 分享图 | 用户操作后写入设备相册 |

本分支不申请 INTERNET 权限，不上传聊天或历史，不需要用户填写服务地址。隐私协议正文在 `LegalDocuments.ets`。若开发其他联网版本，必须另行更新数据流、权限、隐私说明和测试，不能沿用本页的离线承诺。

## 目录与素材

`entry/src/main/ets/pages` 为页面，`data` 为内嵌卡牌，`xinglan` 为离线陪伴引擎，`common` 为存储/配置，`entry/src/ohosTest` 为设备测试，`tools` 为构建与源码验证。`deliverables`、设计目录和旧报告是历史材料，其阶段结论不覆盖当前源码。

背景音乐和图片等素材的权利归各自权利人。公开分发前请按应用中的素材说明逐项核验授权；仓库可下载不等于第三方素材可任意商用。

## 常见问题

| 问题 | 处理 |
|---|---|
| 找不到证书或出现开发者电脑路径 | 使用本分支的无私人签名配置，再在自己电脑上生成 Debug 签名 |
| 未签名 HAP 无法安装 | 在 DevEco 配置自己的签名；不要向他人索要私钥 |
| `ohpm` / `hvigorw` 不在 PATH | 使用 `tools/build.ps1 -DevEcoHome ...` |
| `SOURCE_DRIFT_DETECTED` | 审查指纹涉及的源码变更，验证后更新 manifest |
| 依赖安装失败 | 检查 SDK、OHPM/npm 网络与锁文件，不直接删除锁文件规避问题 |
| 安装签名不一致 | 使用同一签名升级；若决定卸载重装，先确认本地历史会被删除 |
| Node 检查成功但 UI 有问题 | 仍需 DevEco 构建和设备回归 |

开发维护：杨鹏宇。问题反馈请提供版本、复现步骤和去除个人信息的日志，不要提交证书、口令或私人聊天记录。

# 星钥塔罗 协议发布到 Gitee Pages 操作指南

> 目标：把已生成的 3 个 HTML（index.html / privacy-policy.html / user-agreement.html）发布到 Gitee Pages，供应用市场审核访问。
> 本地仓库已 commit 完成，只需创建 Gitee 仓库 + 推送 + 开启 Pages。

---

## 一、前置准备（已完成）

✅ 3 个 HTML 已生成在本地仓库 `D:\XingKeyTarot\.workbuddy\tmp\xingkey-tarot-gh\`
✅ 本地 git commit 已完成（commit 13e9419）
✅ Gitee remote 已添加（指向 `https://gitee.com/Anyes666/xingkey-tarot.git`，用户名可改）

---

## 二、在 Gitee 创建仓库（网页操作，2 分钟）

### 1. 登录 Gitee
打开 https://gitee.com/login，用你的账号登录。
（如果没有账号，点「注册 Gitee」，用 3364153745@qq.com 注册即可）

### 2. 新建仓库
访问 https://gitee.com/projects/new，按以下填写：

| 字段 | 填写内容 |
|------|----------|
| 仓库名称 | `xingkey-tarot` |
| 路径 | `xingkey-tarot`（自动填充） |
| 仓库介绍 | 星钥塔罗 协议中心（用户协议与隐私政策） |
| 开源/私有 | **选「开源」**（Pages 免费版需要开源仓库） |
| 初始化仓库 | **不要勾选**「使用 Readme 文件初始化」（本地已有内容） |
| 分支模型 | 单分支 main 即可 |
| .gitignore | 不选 |
| 开源许可证 | 不选（协议页面不需要） |

点「创建」按钮。

### 3. 确认仓库地址
创建后，仓库地址应为：
```
https://gitee.com/你的用户名/xingkey-tarot
```
如果你的 Gitee 用户名不是 `Anyes666`，需要在本地修改 remote 地址（见下一步）。

---

## 三、推送代码到 Gitee（命令行操作，1 分钟）

### 1. 打开终端
在文件管理器进入 `D:\XingKeyTarot\.workbuddy\tmp\xingkey-tarot-gh`，地址栏输入 `cmd` 回车，打开命令行。

或者用 Git Bash：
```
cd D:/XingKeyTarot/.workbuddy/tmp/xingkey-tarot-gh
```

### 2.（可选）如果你的 Gitee 用户名不是 Anyes666
修改 remote 地址：
```bash
git remote set-url gitee https://gitee.com/你的Gitee用户名/xingkey-tarot.git
```

### 3. 推送到 Gitee
```bash
git push gitee main
```

### 4. 输入账号密码
- **Username**：你的 Gitee 用户名
- **Password**：你的 Gitee 密码（不是令牌，Gitee 支持密码推送）

如果你开启了 Gitee 二次验证或想用令牌更安全：
- 访问 https://gitee.com/profile/personal_access_tokens
- 新建令牌，勾选 `projects` 权限
- 推送时密码栏填令牌

### 5. 推送成功
看到类似 `Writing objects: 100%` 即成功。

### 6. 验证
访问 `https://gitee.com/你的用户名/xingkey-tarot`，应能看到 3 个 HTML 文件 + README.md。

---

## 四、开启 Gitee Pages（网页操作，3 分钟）

### 1. 进入仓库 Pages 设置页
在仓库页面点顶部菜单「**服务**」→「**Gitee Pages**」。

或直接访问：
```
https://gitee.com/你的用户名/xingkey-tarot/pages
```

### 2. 配置 Pages
| 字段 | 选择 |
|------|------|
| 部署分支 | `main` |
| 部署目录 | `/`（根目录） |
| 强制使用 HTTPS | 勾选 |

点「**启动**」按钮。

### 3. 等待部署
通常 30 秒内完成，页面会显示你的 Pages 地址，类似：
```
https://你的用户名.gitee.io/xingkey-tarot
```

### 4. 验证访问
- 首页：https://你的用户名.gitee.io/xingkey-tarot/
- 隐私政策：https://你的用户名.gitee.io/xingkey-tarot/privacy-policy.html
- 用户协议：https://你的用户名.gitee.io/xingkey-tarot/user-agreement.html

---

## 五、提交审核时填写

在应用市场（华为应用市场 / 应用宝 等）的隐私政策链接栏填写：

```
https://你的用户名.gitee.io/xingkey-tarot/privacy-policy.html
```

用户协议链接栏填写：

```
https://你的用户名.gitee.io/xingkey-tarot/user-agreement.html
```

---

## 六、常见问题

### Q1：推送时提示 `remote: Access denied`
- 确认 Gitee 用户名正确
- 确认仓库已创建且为开源
- 确认密码/令牌正确

### Q2：Gitee Pages 提示需要实名认证
- Gitee Pages 服务要求实名认证
- 访问 https://gitee.com/profile/realname 完成认证后重试

### Q3：Pages 启动后访问 404
- 确认部署分支是 `main` 不是 `master`
- 确认部署目录是 `/`（根目录）
- 等 1-2 分钟刷新

### Q4：免费版 Pages 是否够用
- 够用。Gitee Pages 免费版支持开源仓库静态站点，无流量限制
- 每天 100 次构建配额，足够用

### Q5：以后更新协议怎么办
- 本地改 HTML → `git add -A` → `git commit -m "更新协议"` → `git push gitee main`
- Gitee Pages 会自动重新部署，1-2 分钟生效

---

## 七、回退方案

如果 Gitee Pages 也不行，还有两个选择：

1. **腾讯云 COS / 阿里云 OSS 静态网站托管**：上传 3 个 HTML，获得永久访问链接
2. **Vercel / Netlify**：连接 GitHub 仓库（即使 GitHub 推送需要 Token，也可以用网页拖拽上传），自动获得 HTTPS 链接

---

## 附：本地仓库位置（如需重新生成 HTML）

- 源文件：`D:\XingKeyTarot\entry\src\main\ets\common\LegalDocuments.ets`
- 生成脚本：`D:\XingKeyTarot\.workbuddy\tmp\gen_legal_html.py`
- HTML 输出：`D:\XingKeyTarot\.workbuddy\legal-html\`
- git 仓库：`D:\XingKeyTarot\.workbuddy\tmp\xingkey-tarot-gh\`

重新生成命令：
```bash
"C:/Users/pc/.workbuddy/binaries/python/versions/3.13.12/python.exe" "D:/XingKeyTarot/.workbuddy/tmp/gen_legal_html.py"
```

然后复制到仓库目录：
```bash
cp -f D:/XingKeyTarot/.workbuddy/legal-html/*.html D:/XingKeyTarot/.workbuddy/tmp/xingkey-tarot-gh/
cd D:/XingKeyTarot/.workbuddy/tmp/xingkey-tarot-gh
git add -A
git commit -m "更新协议"
git push gitee main
```

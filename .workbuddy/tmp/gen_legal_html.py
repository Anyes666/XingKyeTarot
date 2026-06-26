"""从 LegalDocuments.ets 提取协议正文，生成审核用 HTML 页面"""
import re
import os

SRC = r"D:\XingKeyTarot\entry\src\main\ets\common\LegalDocuments.ets"
OUT_DIR = r"D:\XingKeyTarot\.workbuddy\tmp"
os.makedirs(OUT_DIR, exist_ok=True)

with open(SRC, "r", encoding="utf-8") as f:
    code = f.read()

def extract_field(code: str, field: str) -> str:
    """提取 static readonly FIELD: string = '...' + ... '...'; 的纯文本"""
    # 找到字段开始（后跟另一个 static 字段）
    m = re.search(rf"static readonly {field}: string =\s*(.*?);\s*\n\s*static", code, re.S)
    if not m:
        # 字段后跟 } 结束
        m = re.search(rf"static readonly {field}: string =\s*(.*?);\s*\n\}}", code, re.S)
    if not m:
        raise ValueError(f"未找到字段 {field}")
    body = m.group(1)
    # 收集所有单引号字符串
    parts = re.findall(r"'((?:[^'\\]|\\.)*)'", body)
    # 处理模板变量 ${LegalDocuments.APP_VERSION} → v1.0.0
    text = "".join(parts).replace("${LegalDocuments.APP_VERSION}", "v1.0.0")
    # 还原转义
    text = text.replace("\\n", "\n").replace("\\'", "'").replace('\\"', '"').replace("\\\\", "\\")
    return text

user_text = extract_field(code, "USER_AGREEMENT")
privacy_text = extract_field(code, "PRIVACY_POLICY")

def text_to_html(text: str) -> str:
    """把协议正文转成 HTML：标题行→h2，数字列表→li，普通段落→p"""
    lines = text.split("\n")
    html_blocks = []
    i = 0
    while i < len(lines):
        line = lines[i].rstrip()
        if not line:
            i += 1
            continue
        # 章节标题：一、二、三...
        if re.match(r"^[一二三四五六七八九十]+、", line):
            html_blocks.append(f"<h2>{line}</h2>")
            i += 1
            continue
        # 顶部标题（第一行）
        if i == 0 and ("用户协议" in line or "隐私政策" in line):
            html_blocks.append(f"<h1>{line}</h1>")
            i += 1
            continue
        # 版本/生效日期行
        if line.startswith("版本：") or line.startswith("生效日期："):
            html_blocks.append(f"<p class='meta'>{line}</p>")
            i += 1
            continue
        # 数字列表项
        if re.match(r"^\d+\.\s", line):
            # 收集连续列表项
            items = []
            while i < len(lines) and re.match(r"^\d+\.\s", lines[i].rstrip()):
                items.append(lines[i].rstrip())
                i += 1
            # 单项 → 当作小节标题 h3（第四章 9 个小节标题）
            if len(items) == 1:
                title = re.sub(r"^\d+\.\s*", "", items[0])
                html_blocks.append(f"<h3>{title}</h3>")
            else:
                ul = "<ol>" + "".join(f"<li>{re.sub(r'^\d+\.\s*', '', it)}</li>" for it in items) + "</ol>"
                html_blocks.append(ul)
            continue
        # 普通段落
        html_blocks.append(f"<p>{line}</p>")
        i += 1
    return "\n".join(html_blocks)

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title}</title>
<style>
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    font-family: -apple-system, "PingFang SC", "Microsoft YaHei", "Helvetica Neue", sans-serif;
    background: #0F0F23;
    color: #F8FAFC;
    line-height: 1.8;
    padding: 24px 16px 64px;
    -webkit-font-smoothing: antialiased;
  }}
  .container {{
    max-width: 820px;
    margin: 0 auto;
    background: rgba(26, 26, 46, 0.6);
    border: 1px solid rgba(202, 138, 4, 0.2);
    border-radius: 16px;
    padding: 32px 28px 40px;
    backdrop-filter: blur(8px);
  }}
  h1 {{
    font-size: 26px;
    font-weight: 700;
    color: #E5D9B6;
    text-align: center;
    margin-bottom: 12px;
    letter-spacing: 1px;
  }}
  .meta {{
    text-align: center;
    color: #A0906E;
    font-size: 13px;
    margin-bottom: 4px;
  }}
  h2 {{
    font-size: 18px;
    font-weight: 600;
    color: #CA8A04;
    margin-top: 28px;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(202, 138, 4, 0.18);
  }}
  h3 {{
    font-size: 16px;
    font-weight: 600;
    color: #E5D9B6;
    margin-top: 20px;
    margin-bottom: 10px;
    padding-left: 10px;
    border-left: 3px solid rgba(202, 138, 4, 0.5);
  }}
  p {{
    font-size: 15px;
    color: #E2E8F0;
    margin-bottom: 12px;
    text-align: justify;
  }}
  ol {{
    margin: 12px 0 16px 20px;
    color: #E2E8F0;
    font-size: 15px;
  }}
  li {{ margin-bottom: 8px; }}
  .nav {{
    text-align: center;
    margin-bottom: 24px;
    padding-bottom: 16px;
    border-bottom: 1px solid rgba(202, 138, 4, 0.15);
  }}
  .nav a {{
    color: #CA8A04;
    text-decoration: none;
    font-size: 14px;
    margin: 0 12px;
    padding: 6px 14px;
    border: 1px solid rgba(202, 138, 4, 0.3);
    border-radius: 20px;
    transition: all 0.2s;
  }}
  .nav a:hover {{ background: rgba(202, 138, 4, 0.12); }}
  .footer {{
    text-align: center;
    margin-top: 32px;
    padding-top: 20px;
    border-top: 1px solid rgba(202, 138, 4, 0.15);
    color: #8B7A5C;
    font-size: 12px;
  }}
  @media (max-width: 600px) {{
    body {{ padding: 12px 8px 40px; }}
    .container {{ padding: 20px 16px 28px; }}
    h1 {{ font-size: 22px; }}
    h2 {{ font-size: 16px; }}
    p, li {{ font-size: 14px; }}
  }}
</style>
</head>
<body>
<div class="container">
  <div class="nav">
    <a href="index.html">首页</a>
    <a href="user-agreement.html">用户协议</a>
    <a href="privacy-policy.html">隐私政策</a>
  </div>
{body}
  <div class="footer">
    「星钥塔罗」· 星澜 · 塔罗式情绪陪伴与自我探索工具<br>
    结果仅供娱乐与自我探索参考，不构成任何专业建议
  </div>
</div>
</body>
</html>"""

INDEX_HTML = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>星钥塔罗 · 协议中心</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: -apple-system, "PingFang SC", "Microsoft YaHei", sans-serif;
    background: #0F0F23;
    color: #F8FAFC;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 24px 16px;
  }
  .container {
    max-width: 640px;
    width: 100%;
    text-align: center;
  }
  .brand {
    font-size: 32px;
    font-weight: 700;
    color: #E5D9B6;
    margin-bottom: 8px;
    letter-spacing: 2px;
  }
  .sub {
    color: #A0906E;
    font-size: 14px;
    margin-bottom: 40px;
  }
  .card {
    display: block;
    background: rgba(26, 26, 46, 0.6);
    border: 1px solid rgba(202, 138, 4, 0.25);
    border-radius: 16px;
    padding: 24px 20px;
    margin-bottom: 16px;
    text-decoration: none;
    color: #F8FAFC;
    transition: all 0.25s;
  }
  .card:hover {
    border-color: rgba(202, 138, 4, 0.5);
    background: rgba(26, 26, 46, 0.85);
    transform: translateY(-2px);
  }
  .card-title {
    font-size: 18px;
    font-weight: 600;
    color: #CA8A04;
    margin-bottom: 6px;
  }
  .card-desc {
    font-size: 13px;
    color: #94A3B8;
  }
  .footer {
    margin-top: 40px;
    color: #8B7A5C;
    font-size: 12px;
    line-height: 1.8;
  }
</style>
</head>
<body>
<div class="container">
  <div class="brand">星钥塔罗</div>
  <div class="sub">协议中心 · v1.0.0 · 生效日期 2026年6月26日</div>
  <a class="card" href="user-agreement.html">
    <div class="card-title">用户协议</div>
    <div class="card-desc">查看《星钥塔罗用户协议》全文</div>
  </a>
  <a class="card" href="privacy-policy.html">
    <div class="card-title">隐私政策</div>
    <div class="card-desc">查看《星钥塔罗隐私政策》全文</div>
  </a>
  <div class="footer">
    塔罗式情绪陪伴与自我探索工具<br>
    结果仅供娱乐与自我探索参考，不构成任何专业建议<br>
    开发者：Anyes · 3364153745@qq.com
  </div>
</div>
</body>
</html>"""

# 生成隐私政策 HTML
privacy_html = HTML_TEMPLATE.format(
    title="星钥塔罗 隐私政策",
    body=text_to_html(privacy_text)
)
# 生成用户协议 HTML
user_html = HTML_TEMPLATE.format(
    title="星钥塔罗 用户协议",
    body=text_to_html(user_text)
)

paths = {
    "privacy-policy.html": privacy_html,
    "user-agreement.html": user_html,
    "index.html": INDEX_HTML,
}
for name, content in paths.items():
    p = os.path.join(OUT_DIR, name)
    with open(p, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"OK {name} ({len(content)} bytes)")

# 校验：打印前 300 字符
print("\n--- privacy-policy.html preview ---")
print(privacy_html[:300])
print("\n--- user-agreement.html preview ---")
print(user_html[:300])

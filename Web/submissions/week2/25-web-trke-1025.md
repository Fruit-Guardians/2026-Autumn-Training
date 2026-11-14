# Week-2
+ ID:trke
+ 日期：2026-10-25

## HTTP请求与响应
> 以抓包一个登录表单为例，可以看到原始请求：
>

```http
POST /login.php HTTP/1.1                             -- 请求行：请求方式/请求路径/协议版本（改路径 —— 实现目录穿越、任意文件读取等）
Host: challenge.example.com           -- HOST：目标域名 -- 请求头：从第二行到第一个空行为止（SSRF 和一些越权涉及 Host 头伪造）
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36   -- 客户端身份（题目要求使用指定方式/浏览器访问时可改）
Accept: text/html,application/xhtml+xml
Accept-Language: zh-CN,zh;q=0.9
Referer: http://challenge.example.com/login.php 								 -- 从那个页面跳转的记录（改 Referer 可绕过 Referer 验证，检验跳转前页面）
Content-Type: application/x-www-form-urlencoded  							  	-- 告诉浏览器body的格式（可绕过部分文件类型检验，也可能触发 XXE 等漏洞）
Content-Length: 29
Cookie: PHPSESSID=a1b2c3d4e5f6; role=guest                               -- 携带会话凭证（详见cookie细讲）
Connection: close   
                                                                          -- 空行不能丢（否则可能报错）
username=admin&password=123456												 -- 请求体，只有POST,PUT请求方法有
-- 最常见表单格式：
键=值&键=值,与 Content-Type:application/x-www-form-urlencoded 对应
-- 其他常见格式：
application/json：{"username":"admin"}，而PHP 里 json 格式不走 $_POST，要读 php://input
multipart/form-data：文件上传用的格式，细节见 文件上传 章细讲
```

> 发送到重放器，看到服务器返回的相应：
>

```http
HTTP/1.1 200 OK																					 -- 状态行：协议版本 状态码 状态短语
Date: Wed, 12 Jun 2024 08:00:00 GMT
Server: Apache/2.4.41 (Ubuntu) 													 								 -- 泄露中间件版本
Set-Cookie: role=user; Path=/; HttpOnly											    	-- 下发 cookie 给浏览器
Content-Type: text/html; charset=utf-8 
Content-Length: 512																					   	-- 从状态行到空白行为响应头
                                                                -- location：302 跳转目标
<html><body><h1>Login Failed</h1>...</body></html>
```

> 状态码及其含义：
>

| 状态码 | 含义 | CTF 中的意义 |
| --- | --- | --- |
| 200 | 成功 | <font style="color:rgba(0, 0, 0, 0.87);background-color:rgba(0, 0, 0, 0.035);">正常返回</font> |
| 301/302 | 重定向 | 跳转到新地址，Location 头指向的页面可能没做权限校验 |
| 401 | 未认证 | <font style="color:rgba(0, 0, 0, 0.87);background-color:rgba(0, 0, 0, 0.035);">需要登录，常见于 HTTP Basic Auth</font> |
| 403 | 禁止访问 | 有东西但不让看，可试目录穿越、改 UA/IP 头等绕过 |
| 404 | 不存在 | 看“基准值”，随机不存在路径：页面长度 = 1000 字节（基准） |
| 500 | 服务器错误 | 参数可能打进了危险函数，配合报错信息（如 SQL 注入 的报错注入） |


> 请求方法及其考点：
>

| 请求方法 | 语义 | CTF 考点 |
| --- | --- | --- |
| GET | 获取资源，参数放在 URL 里 | 参数可见可改，注入题常考 |
| POST | 提交数据，参数放在 Body | 表单登录、文件上传；Body 格式由 Content-Type 决定 |
| PUT | 上传 / 替换资源 | 若服务器开启 WebDAV 且配置不当，用PUT请求上传一句话木马直接 getshell |
| DELETE | 删除资源 | 同上，危险的 HTTP 方法应当被禁用 |
| HEAD | 只要响应头，不要 Body | 探测文件是否存在，比 GET 快 |
| OPTIONS | 询问服务器支持哪些方法 | 响应的 Allow 头会暴露可用的方法，信息收集时常用 |


<font style="color:rgba(0, 0, 0, 0.87);">请求方法 CTF 典型考法：若题目对 GET/POST 做了过滤，但代码里用了 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">$_REQUEST</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 函数或允许其他方法，换成 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">PUT</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 或 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">X-HTTP-Method-Override</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 头就能绕过。遇到 " 方法被拦 " 的 405 响应， </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">OPTIONS</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 一下看看还支持什么。</font>

<font style="color:rgba(0, 0, 0, 0.87);"></font>

<font style="color:rgba(0, 0, 0, 0.87);">常见 Header 的 CTF 考点：</font>

### <font style="color:rgba(0, 0, 0, 0.87);">Host</font>
> 改 HOST 头越权访问：`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">Host: admin.internal</font>`
>
> 靠 Host 重置密码投毒：改链接取自的 Host 头，劫持用户 token
>

### <font style="color:rgba(0, 0, 0, 0.87);">User-Agent</font>
> 例如题目：请使用 HAHA 浏览器/手机端 访问此站
>
> <font style="color:rgba(0, 0, 0, 0.87);">思路：网上公开搜索 某某浏览器/搜索引擎爬虫/手机安卓 的 User-Agent 修改即可，比如：</font>
>

```shell
curl -v 'http://challenge.example.com/' -A 'HAHA Browser 1.0'
```

### <font style="color:rgba(0, 0, 0, 0.87);">Referer</font>
> <font style="color:rgba(0, 0, 0, 0.87);">表示请求来源页面</font>
>
> <font style="color:rgba(0, 0, 0, 0.87);">若 题目 有请求来源页面的限制，把 Referer 修改为允许的即可，比如只允许从index.php跳转访问：</font>
>

```shell
curl -v 'http://challenge.example.com/secret.php' \
-H 'Referer: http://challenge.example.com/index.php'
```

### <font style="color:rgba(0, 0, 0, 0.87);">X-Forwarded-For</font>
> <font style="color:rgba(0, 0, 0, 0.87);">后端用 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">$_SERVER['HTTP_X_FORWARDED_FOR']</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 取 IP 来做限制（比如 " 仅允许本地访问"）时，可伪造：</font>
>

```shell
curl -v 'http://challenge.example.com/admin.php' \
-H 'X-Forwarded-For: 127.0.0.1'
```

> 若 X-Forwarded-For 走不通，可用同类头尝试： X-Real-IP、X-Client-IP、Client-IP，甚至可以尝试127.0.0.1的变形127.1，取决于后端的解析方式
>

### <font style="color:rgba(0, 0, 0, 0.87);">Content-Type</font>
> <font style="color:rgba(0, 0, 0, 0.87);">决定服务器如何解析 Body</font>
>
> + **文件上传绕过**：比<font style="color:rgba(0, 0, 0, 0.87);">如把 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">Content-Type</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 从 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">application/octet-stream</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 改成 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">image/png</font>`
> + **<font style="color:rgba(0, 0, 0, 0.87);">XXE 触发</font>**<font style="color:rgba(0, 0, 0, 0.87);">：把 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">Content-Type</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 改成 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">application/xml</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 并提交 XML Body 里的载荷</font>
> + **<font style="color:rgba(0, 0, 0, 0.87);">PHP 解析差异</font>**<font style="color:rgba(0, 0, 0, 0.87);">：</font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">application/json</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 用</font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">file_get_contents('php://input')</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 读取，所以不能写表单</font>`<font style="color:rgba(0, 0, 0, 0.87);">key=value</font>`<font style="color:rgba(0, 0, 0, 0.87);">，应该是标准 JSON 格式</font>
>

例如错误示例❌：

```http
POST /api.php HTTP/1.1
Host: xxx
Content-Type: application/json

id=1&name=test
```

正确格式✔：

```http
POST /api.php HTTP/1.1
Host: xxx
Content-Type: application/json

{"id":1,"name":"test"}
```

### 其他请求头
+ Accept / Accept-Language：偶尔题目要求 " 请使用某国语言"，改 Accept-Language: en-US
+ <font style="color:rgba(0, 0, 0, 0.87);">Authorization：HTTP Basic Auth（基础认证） 用，格式是 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">Basic base64(user:pass)</font>`<font style="color:rgba(0, 0, 0, 0.87);">，拿到账密仅作简单的拼接和 base64 编码，弱口令爆破的对象</font>
+ <font style="color:rgba(0, 0, 0, 0.87);">origin：CORS 相关，部分逻辑漏洞题会考 Origin 校验缺失，比如检验跳转前页面是否以example.com结尾，攻击者设置</font>`<font style="color:rgba(0, 0, 0, 0.87);">Origin: attacker-example.com</font>`<font style="color:rgba(0, 0, 0, 0.87);">即可绕过</font>

### Cookie和Session
+ Cookie 存在客户端，BP 抓包可改；Session 存在数据库，用户只拿钥匙
+ Set-Cookie 是 cookie 的附带属性，是响应头，包含：
1. Path：生效路径，规定在网站的那些路径下可携带
2. HttpOnly 作用：**禁止 JavaScript 读取这个 Cookie**。 普通 Cookie：JS 可以通过`document.cookie`拿到， 如果 Cookie 加了`HttpOnly`：则 document.cookie 被禁止 ，但 CSRF 不受影响
3. Secure 属性：只有 HTTPS 加密连接时才会带上 cookie，HTTP 不会（HTTPS = HTTP + TLS）

```http
# 第一次请求：-c 保存服务器下发的 Cookie 到文件
curl -v -c cookies.txt 'http://challenge.example.com/login.php' \
  -d 'username=admin&password=123456'
# 后续请求：-b 带上保存的 Cookie
curl -v -b cookies.txt 'http://challenge.example.com/profile.php'
```

### 让 Burp 能抓 HTTPS
> 1. <font style="color:rgba(0, 0, 0, 0.87);">浏览器代理指向 Burp（</font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">127.0.0.1:8080</font>`<font style="color:rgba(0, 0, 0, 0.87);">）后，访问 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">http://burp</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 或 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">http://127.0.0.1:8080/cert</font>`<font style="color:rgba(0, 0, 0, 0.87);">，下载 CA 证书 </font>`<font style="color:rgb(54, 70, 78);background-color:rgb(245, 245, 245);">cacert.der</font>`<font style="color:rgba(0, 0, 0, 0.87);">。</font>
> 2. <font style="color:rgba(0, 0, 0, 0.87);">把证书导入浏览器（Firefox：设置 → 隐私与安全 → 查看证书 → 导入，并勾选 " 信任由此证书颁发机构标识的网站"）。</font>
> 3. <font style="color:rgba(0, 0, 0, 0.87);">重新访问 HTTPS 站点，Burp 里即可看到明文。</font>
>

>  已配置 Firefox 浏览器
>

## 正则表达式
> _<font style="color:rgb(51, 51, 51);background-color:rgb(250, 250, 248);">正则表达式是一种用于匹配和操作文本的强大工具，它由普通字符和特殊字符（称为"元字符"）组成，用于描述要匹配的文本模式，正则表达式可以在文本中查找、替换、提取和验证特定的模式。</font>_
>
> _在线正则匹配工具：_[_https://www.jyshare.com/front-end/854/_](https://www.jyshare.com/front-end/854/)
>

### 特殊代码（元字符）
| 语法 | 含义 |
| --- | --- |
| `.` | 匹配除换行符以外的任意字符 |
| `\w` | 匹配 **字母或数字**（多数引擎还包含下划线） |
| `\s` | 匹配 **任意空白符**：空格、Tab、换行等 |
| `\d` | 匹配 **数字** |
| `\b` | 匹配 **单词 **的开始或结束位置 |
| `^``$` | 匹配 **字符串 **的开始和结束位置 |


**例子**

+ `\ba\w*\b`：匹配以字母 `a` 开头的单词。`\b` 是单词边界，`\w*` 是任意数量的字母/数字。
+ `\d+`：匹配一个或多个连续数字。`*` 可以重复 0 次，`+` 至少重复 1 次。
+ `\b\w{6}\b`：匹配刚好 6 个字母/数字的单词。
+ `^\d{5,12}$`：整个字符串必须是 5 到 12 位数字，常用于 QQ 号校验。`^` 和 `$` 把匹配锁定在整串首尾。
+ 多行模式：`^` 和 `$` 改为匹配每一行的开头和结尾。

### 字符转义
| 语法 | 含义 |
| --- | --- |
| `\.` | 匹配 `.` 本身 |
| `\*` | 匹配 `*` 本身 |
| `\\` | 匹配 `\` 本身 |
| `\^` | 匹配 `^` 本身 |


**例子**

+ `deerchao\.cn`：匹配 `deerchao.cn`，这里的 `.` 不再表示任意字符。
+ `c:\\windows`：匹配 `c:\windows`；要匹配反斜杠本身，需要写 `\\`。
+ `2\^8`：匹配 `2^8`。

###  重复（量词）
| 语法 | 含义 |
| --- | --- |
| `*` | 重复次数 ≥ 0 |
| `+` | 重复次数 ≥ 1 |
| `?` | 重复次数 0 & 1 |
| `{n}` | 重复恰好 n 次 |
| `{n,}` | 重复 n 次或更多次 |
| `{n,m}` | 重复 n 到 m 次 |


**例子**

+ `Windows\d+`：匹配 `Windows` 后面跟至少一个数字。
+ `13\d{9}`：匹配以 `13` 开头、后面跟 9 个数字的号码，可用于中国手机号。
+ `^\w+`：匹配字符串（或多行模式下的每一行）的第一个单词。

### 字符类
| 语法 | 含义 |
| --- | --- |
| `[abc]` | 匹配 a、b、c 中的任意一个字符 |
| `[a-z]` | 匹配 a 到 z 范围内的任意字符 |
| `[0-9]` | 匹配任意数字，等价于 `\d` |
| `[a-zA-Z0-9]` | 匹配字母或数字（`\w` 的常见写法；`\w` 通常还含下划线） |
| `[^abc]` | 匹配除 a、b、c 以外的任意字符（见“反义”） |


**例子**

+ `[aeiou]`：匹配任意一个元音字母。
+ `[.?!]`：匹配 `.`、`?`、`!` 中的一个。中括号内的 `.`、`?`、`!` 一般不需要转义；但 `]`、`\`、`^`、`-` 仍需注意。
+ `[0-9]` 与 `\d` 等价；`[a-z0-9A-Z]` 与 `\w` 等价。
+ `\(?0\d{2}[) -]?\d{8}`：匹配 `(010)88886666`、`022-22334455`、`02912345678` 等电话号码格式。  
`[) -]` 表示 `)`、空格、`-` 三者之一；它也会误匹配 `010)12345678` 这类不完整格式，改进见“分支”。

### 反义
| 语法 | 含义 |
| --- | --- |
| `\W` | 匹配任意不是字母和数字的字符 |
| `\S` | 匹配任意不是空白符的字符 |
| `\D` | 匹配任意非数字字符 |
| `\B` | 匹配不是单词开头或结束的位置 |
| `[^x]` | 匹配除了 x 以外的任意字符 |
| `[^aeiou]` | 匹配除了 a、e、i、o、u 以外的任意字符 |


**例子**

+ `\S+`：匹配不包含空白符的字符串。
+ `<a[^>]+>`：匹配用尖括号括起来、以 `a` 开头的字符串，例如 `<a href="...">` 的开头部分。

### 分支 / 替换
| 语法 | 含义 |
| --- | --- |
| `exp1|exp2` | 匹配 exp1 或 exp2；从左到右尝试，先匹配者胜 |
| `exp1|exp2|exp3` | 多个分支，可继续用 `|` 扩展 |


**例子**

+ `0\d{2}-\d{8}|0\d{3}-\d{7}`：匹配“3 位区号 + 8 位号码”或“4 位区号 + 7 位号码”。
+ `\(0\d{2}\)[- ]?\d{8}|0\d{2}[- ]?\d{8}`：匹配 3 位区号号码；区号可带或不带小括号，分隔符可以是 `-`、空格，也可以没有。
+ `\d{5}-\d{4}|\d{5}`：匹配美国邮编（5 位，或 5 位 + 连字符 + 4 位）。
+ 顺序很重要：`\d{5}|\d{5}-\d{4}` 会先匹配前 5 位就停止，导致 9 位邮编只匹配前 5 位。
+ `Windows98|Windows2000|WindowsXP`：分支可以不止两个。

### 分组
| 语法 | 含义 |
| --- | --- |
| `(exp)` | 捕获分组：把 exp 当作一个整体，并保存匹配文本 |
| `(?<name>exp)` | 命名捕获分组：保存到名称 `name` |
| `(?:exp)` | 非捕获分组：只分组，不保存匹配文本 |


**例子**

+ `(\d{1,3}\.){3}\d{1,3}`：简单的 IP 地址匹配——3 段“1 到 3 位数字 + 点”，最后再加 1 到 3 位数字。  
它也会匹配 `256.300.888.999`，因为正则本身不检查每段是否在 0 到 255。
+ 正确的 IPv4 写法：  
`((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)`  
其中 `2[0-4]\d` 覆盖 200–249，`25[0-5]` 覆盖 250–255，`[01]?\d\d?` 覆盖 0–199。
+ `(?:ab)+`：匹配 `abab`，但不会把每次的 `ab` 单独捕获；`(ab)+` 则会捕获最后一组 `ab`。

### 后向引用
| 语法 | 含义 |
| --- | --- |
| `\1` | 引用第 1 个捕获分组匹配到的文本 |
| `\2`、`\3`… | 引用第 2、3…个捕获分组 |
| `(?<name>exp)` | 给分组命名 |
| `\k<name>` | 引用名称为 `name` 的分组 |


**例子**

+ `\b(\w+)\b\s+\1\b`：匹配重复出现的单词，例如 `go go`、`kitty kitty`。`\1` 就是前面 `(\w+)` 捕获到的那个单词。
+ 命名版：`\b(?<Word>\w+)\b\s*\k<Word>\b`（原文写法；把 `\s*` 改成 `\s+` 可要求两个单词间至少有一个空白）。
+ 分组编号规则：按左括号从左到右编号，第一个左括号为第 1 组。

### 位置指定（零宽断言）
| 语法 | 含义 |
| --- | --- |
| `(?=exp)` | 正向先行断言：当前位置的后面能匹配 exp |
| `(?<=exp)` | 正向后行断言：当前位置的前面能匹配 exp |


零宽断言只匹配“位置”，不消耗字符，所以结果中不包含断言里的内容。

**例子**

+ `\b\w+(?=ing\b)`：匹配以 `ing` 结尾的单词的前半部分。  
在 `I'm singing while you're dancing.` 中匹配 `sing` 和 `danc`。
+ `(?<=\bre)\w+\b`：匹配以 `re` 开头的单词的后半部分。  
在 `reading a book` 中匹配 `ading`。
+ `((?<=\d)\d{3})*\b`：从右往左按每三位分组，可用于给长数字添加千位分隔逗号。
+ `(?<=\s)\d+(?=\s)`：匹配被空白符包围的数字，但不包括两边的空白符。

### 负向位置指定
| 语法 | 含义 |
| --- | --- |
| `(?!exp)` | 负向先行断言：当前位置的后面不是 exp |
| `(?<!exp)` | 负向后行断言：当前位置的前面不是 exp |


**例子**

+ `\b\w*q[^u]\w*\b` 想匹配“包含 q、且 q 后面不是 u”的单词，但 `[^u]` 会消耗一个字符，q 在词尾时会误匹配。  
例如在 `Iraq fighting` 中，它会把整个 `Iraq fighting` 当作匹配。
+ 修复：`\b\w*q(?!u)\w*\b`。`(?!u)` 只检查 q 后面不是 u，不消耗字符。
+ `\d{3}(?!\d)`：匹配三位数字，且这三位数字后面不能再是数字。
+ `(?<![a-z])\d{7}`：匹配前面不是小写字母的七位数字（注意区分大小写选项）。
+ `(?<=<(\w+)>).*(?=<\/\1>)`：匹配简单 HTML 标签中的内容，不包含开始/结束标签。  
`(\w+)` 捕获标签名，`\1` 保证结束标签与开始标签同名。  
注意：`.*` 默认不跨行；部分引擎的后行断言要求固定长度，跨引擎使用时要留意。

### 注释与忽略空白
| 语法 | 含义 |
| --- | --- |
| `(?#comment)` | 注释，不影响正则匹配 |
| `(?x)` 或“忽略空白”选项 | 忽略表达式中的空格、Tab、换行，并把 `#` 到行尾当作注释 |


**例子**

+ 行内注释：`\d{3}(?#三位数字)(?!\d)`。
+ 开启 `(?x)` 后，可以把 HTML 标签内容的表达式写成：

```latex
(?x)
(?<=          # 前缀开始，但不包含它
  <(\w+)>     # 捕获尖括号里的标签名
)             # 前缀结束
.*            # 标签之间的内容
(?=           # 后缀开始，但不包含它
  <\/\1>      # 对应的闭合标签
)             # 后缀结束
```

### 贪婪与懒惰
| 语法 | 含义 |
| --- | --- |
| `*?` | 重复任意次，但尽可能少重复 |
| `+?` | 重复 1 次或更多次，但尽可能少重复 |
| `??` | 重复 0 次或 1 次，但尽可能少重复 |
| `{n,m}?` | 重复 n 到 m 次，但尽可能少重复 |
| `{n,}?` | 重复 n 次以上，但尽可能少重复 |


**例子**

+ `a.*b`：贪婪匹配，匹配最长的、以 `a` 开始、以 `b` 结束的字符串。  
对 `aabab` 会匹配整个 `aabab`。
+ `a.*?b`：懒惰匹配，匹配最短的、以 `a` 开始、以 `b` 结束的字符串。  
对 `aabab` 会匹配 `aab` 和 `ab`。

### 其他语法速查
| 语法 | 含义 |
| --- | --- |
| `\a` | 报警字符（响铃） |
| `\b` | 在字符类中表示退格；普通位置表示单词边界 |
| `\t` | 制表符 |
| `\r` | 回车 |
| `\v` | 垂直制表符 |
| `\f` | 换页符 |
| `\n` | 换行符 |
| `\e` | Escape |
| `\0nn` | 八进制 ASCII 字符 |
| `\xnn` | 十六进制 ASCII 字符 |
| `\unnnn` | 十六进制 Unicode 字符 |
| `\cN` | ASCII 控制字符，如 `\cC` 表示 Ctrl+C |
| `\A` | 字符串开头（不受多行选项影响） |
| `\Z` | 字符串结尾或行尾（不受多行选项影响） |
| `\z` | 字符串结尾（不受多行选项影响） |
| `\G` | 当前搜索的开头 |
| `\p{name}` | Unicode 字符类，如 `\p{IsGreek}` |
| `(?>exp)` | 原子/贪婪子表达式 |
| `(?<x>-<y>exp)` | 平衡组（.NET） |
| `(?-<y>exp)` | 平衡组（.NET） |
| `(?im-nsx:exp)` | 在 exp 内临时修改处理选项 |
| `(?im-nsx)` | 修改后面部分的处理选项 |
| `(?(exp)yes|no)` | 条件匹配：exp 能匹配则用 yes，否则用 no |
| `(?(exp)yes)` | 同上，no 为空 |
| `(?(name)yes|no)` | 命名组已捕获内容则用 yes，否则用 no |
| `(?(name)yes)` | 同上，no 为空 |


**例子**

+ `a\tb`：匹配 `a`、制表符、`b`。
+ `\p{IsGreek}+`：匹配一个或多个希腊字母。
+ `(?i)abc`：开启忽略大小写后匹配 `abc`、`ABC`、`AbC` 等。
+ `\Aabc\Z`：匹配整个字符串 `abc`，不受多行模式影响。
+ `(?(1)yes|no)`：如果第 1 个分组已经捕获到内容，则匹配 `yes`，否则匹配 `no`。

> 这一节的语法多与具体引擎有关（尤其平衡组、条件匹配、内联选项），实际使用时以目标语言的文档为准。
>



<font style="color:rgb(51, 51, 51);background-color:rgb(250, 250, 248);"></font>

1. [[0xGame2025]Http的真理，我已解明](https://www.ctfplus.cn/problem-detail/1975492176561311744/description)

#### 思路
打开靶机，看到题目，要求 GET 传参，打开 Burp 进行抓包发送到 重放器 改包测试

<img src="https://github.com/user-attachments/assets/5c75e4fe-ae58-48c1-be6a-033eebd5d92a" width="896" title="" crop="0,0,1,0.8481" id="uce4a1222" class="ne-image">

传入`?hello=web`后点击发送，页面显示要用 POST 传参

<img src="https://github.com/user-attachments/assets/cc4c562d-8d69-4f8b-869c-0be2a66803f4" width="1138" title="" crop="0,0,1,0.7616" id="u46eb640a" class="ne-image">

把 GET 请求改成 POST 请求，写请求体`http=good`，注意不要忘记加上`Content-type：application/x-www-form-urlencoded`，告诉 POST 请求体里面的数据是什么格式

<img src="https://github.com/user-attachments/assets/3ec1984c-65e2-403f-842d-244c651fc80f" width="1151" title="" crop="0,0,1,0.7819" id="uc8cf02d8" class="ne-image">

按照页面提示设置cookie：`Cookie:Sean=god`

<img src="https://github.com/user-attachments/assets/1fa1f266-2cb3-4c65-b2d7-a1548395b5dd" width="1138.1817523966845" title="" crop="0,0,1,1" id="u79401fcf" class="ne-image">

改User-Agent：换客户端类型`User-Agent: Safari`

<img src="https://github.com/user-attachments/assets/60c452b0-a1b1-4eb6-b4df-f829755c052f" width="1154.5453878145283" title="" crop="0,0,1,1" id="u327b6918" class="ne-image">

添加跳转前页面的Referer：`Referer: www.mihoyo.com`

<img src="https://github.com/user-attachments/assets/3b819ef3-5784-49ca-998f-541b714a3efb" width="1136.3635706835908" title="" crop="0,0,1,1" id="ua52c7575" class="ne-image">

Via 设置代理：`Via: clash`,点击发送即可看到 flag

<img src="https://github.com/user-attachments/assets/cc52c0ff-1f73-4d3d-bd31-6617d1426961" width="1152.1211455304033" title="" crop="0,0,1,1" id="u5ced40cf" class="ne-image">

#### 总结
改 POST 请求时一定要加上 Content-type，懂不同请求方法的差异；

用 Via 设置代理，懂各类请求头的含义。



2. [[SWPUCTF 2024 秋季新生赛]http标头](https://www.nssctf.cn/problem/5942/writeups)

#### 思路
打开靶机，看到题目，要求传入正确时间标头，打开 Burp 进行抓包发送到 重放器 改包测试

<img src="https://github.com/user-attachments/assets/5bdf631c-9fd4-4e8a-84f0-31fdf6d0d619" width="1032.121152466216" title="" crop="0,0,1,1" id="u987bb36b" class="ne-image">

添加时间头`Date: Tue, 20 Aug 2024 00:00:00 GMT`，格式为：星期英文缩写, 几号 几月 哪一年 几时:几分:几秒 GMT , 注意不要写错格式，点击发送

<img src="https://github.com/user-attachments/assets/dea30954-5f5b-4772-9691-acb2b39be788" width="1089.0908461431534" title="" crop="0,0,1,1" id="uf9581cf0" class="ne-image">

页面要求使用 BlackMonkey 浏览器，则修改User-Agent为：`BlackMonkey`，点击发送

<img src="https://github.com/user-attachments/assets/1656e47f-08bb-46d5-914a-bbb532728c76" width="1095" title="" crop="0,0,1,0.8803" id="u771891a9" class="ne-image">

Cookie 有曲奇的意思，同时也是 HTTP Cookie 的请求头，因此添加Cookie：`Cookie: cookie:BlackMonkey`

<img src="https://github.com/user-attachments/assets/4e836012-5cdd-429c-ab51-f5befed7a723" width="1083.6363010038722" title="" crop="0,0,1,1" id="uea38a663" class="ne-image">

根据页面提示，需要改 Referer：`Referer: wukong`，点击发送

<img src="https://github.com/user-attachments/assets/3ddbbc5e-fecc-4a3f-a753-2babbe4314b1" width="1054.5453935943722" title="" crop="0,0,1,1" id="cjgBH" class="ne-image">

根据提示，添加本地地址：`X-Forwarded-For: 127.0.0.1`，点击发送，成功拿到 flag

<img src="https://github.com/user-attachments/assets/5306587e-c8f2-43f4-9582-14ae7dc649d7" width="1036.3635764634348" title="" crop="0,0,1,1" id="u9dafe114" class="ne-image">

#### 总结
注意正确的 Date 格式，以及 cookie 在英文里也表示曲奇
1. [[LitCTF 2025]nest_js ](https://www.nssctf.cn/problem/6786)

### 思路
使用 dirsearch 工具扫描未发现隐藏文件，故尝试 BP 抓包爆破

<img src="https://github.com/user-attachments/assets/a6673140-df5f-4cfc-8bd0-ba0bf196aa14" width="1021.8181227586849" title="" crop="0,0,1,1" id="uc41f593c" class="ne-image">

抓包发送到 intruder 尝试爆破密码

<img src="https://github.com/user-attachments/assets/9dd9d8a0-2033-4757-859e-a46e37e31f0d" width="989.0908519229974" title="" crop="0,0,1,1" id="u5a12739d" class="ne-image">

提示弱口令，则将 username 改为 admin ，对密码位置添加 pyload，并导入字典开始攻击

<img src="https://github.com/user-attachments/assets/d66fe2c6-d6de-4a03-a4c5-6f07901032f5" width="1456.36355218809" title="" crop="0,0,1,1" id="ua5eabe1f" class="ne-image">

可见 password 处页面响应为 200 ，尝试登录，成功拿到 flag

<img src="https://github.com/user-attachments/assets/019a6221-2654-42cf-885a-5e128e184a3f" width="1027.2726678979661" title="" crop="0,0,1,1" id="uea60b4c6" class="ne-image">

### 总结
学会使用 dirsearch 扫描，学会用 BP上的 intruder 模块进行爆破

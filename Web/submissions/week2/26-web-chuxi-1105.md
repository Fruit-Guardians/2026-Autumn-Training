2026.11.04修改

# ***<u>贰.信息收集与解加密</u>***

## ***一.弱口令与默认口令***

#### 1.**[[LitCTF 2025]nest_js](https://www.nssctf.cn/problem/6786)**

**打开靶机，进入登录页，输入默认口令：admin / 123456**

![屏幕截图 2026-10-27 131059](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-27%20131059.png)

**用 Burp 抓包，拦截登录页面**

![屏幕截图 2026-10-27 131104](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-27%20131104.png)

![屏幕截图 2026-10-27 131108](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-27%20131108.png)

**发现登录接口是 `POST /api/login`**![屏幕截图 2026-10-27 131133](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-27%20131133.png)

**请求体里2个参数：`username`、`password`**

**发送到 Burp 的 Intruder（攻击器），给 `username` 和 `password` 两个值分别加上 `§payload§` 标记![屏幕截图 2026-10-27 131200](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-27%20131200.png)**

![屏幕截图 2026-10-27 131527](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-27 131527.png)

![屏幕截图 2026-10-27 131312](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-27%20131312.png)

**选择攻击类型。两个位置都要爆破时，用 Pitchfork 或集群炸弹**

![屏幕截图 2026-10-27 132148](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-27%20132148.png)

**在 Payloads 面板里为两个位置导入弱口令字典**

![屏幕截图 2026-10-27 133452](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-27%20133452.png)

**开始攻击。结果里大量 401，隐藏 3xx、4xx、5xx，只留下 200**

![](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图(274).png)

![屏幕截图 2026-10-27 134000](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-27 134000.png)

**发现一条 `admin` / `password`、状态码 200**

**用这组口令登录，页面直接得出 flag**

![屏幕截图 2026-10-27 134019](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-27%20134019.png)

#### 2.**[[SWPUCTF 2025 秋季新生赛]DANGEROUS TRIAL](https://www.nssctf.cn/problem/7208)**

**角色是《转生史莱姆》的利姆鲁**

**利姆鲁的名字是 `Rimuru`，可以作为用户名去试**

**通过dirsearch扫描网站，发现zip文件**并下载

**![屏幕截图 2026-10-28 155553](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-28%20155553.png)**

![屏幕截图 2026-10-27 142527](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-27 142527.png)

![屏幕截图 2026-10-28 160045](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-28%20160045.png)

![屏幕截图 2026-10-28 160141](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-28%20160141.png)

开始攻击后前段都是200通过，忽然就从某一个全部变成了302跳转，第一个疑似为正确密码

![屏幕截图 2026-10-28 165826](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-28 165826.png)

输入后进入下一页面

![屏幕截图 2026-10-28 165900](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-28%20165900.png)

**知识点：弱口令与默认口令**

**1 什么叫弱口令/默认口令**

- 默认口令：产品出厂自带的账号密码，如 `admin/admin`、`admin/123456`、`guest/guest`
- 弱口令：用户自己设置的、能被常见字典猜到的密码，如 `123456`、`password`、`qwerty`
- 本质：**人设置的密码有规律**，攻击者拿“常见密码表”逐个试即可

**2 Burp Intruder 的四种攻击类型**

- **Sniper（狙击手）**：一个 payload 集，逐个位置依次替换
- **Battering ram（碰撞）**：一个 payload 集，同时填到所有位置
- **Pitchfork（叉子）**：每个位置一个 payload 集，并行一一对应取
- **Cluster bomb（集群炸弹）**：每个位置一个 payload 集，穷举所有组合

**3 怎么判断“登录成功”**

- 状态码变化：401/302 → 200
- 响应长度变化：失败页长度固定，成功后长度不同
- 跳转：`Location: /index.php` 一类表示登录成功
- `Set-Cookie`：下发会话 cookie/token 基本就是成功

**4 常用字典与思路**

- 常见口令 Top 榜：`2022passwd-ALL-Top200.txt`、`rockyou-top15000.txt`、SecLists 的 `Passwords/`
- 先手工试默认口令，再上字典
- 用户名也可以从页面提示、报错、源码、历史泄露中收集
## ***二.认识 JWT***

[ctfhub技能树->web进阶->JSON Web Token](https://www.ctfhub.com/#/skilltree)

JWT 全称 JSON Web Token，是“三段式”的令牌
- Header/Payload 只是 **base64url 编码，不是加密**，任何人解码都能看到内容
- Signature 是用密钥对前两段做的签名，用来防篡改
- 题目常见的四种攻击：**敏感信息泄露、无签名（alg=none）、弱密钥爆破、修改签名算法（公钥泄露）**

#### 1.敏感信息泄露

**登录之后，点击F12，从 Cookie/响应里拿到 JWT**

![屏幕截图 2026-10-29 150914](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-29%20150914.png)

**把 JWT 粘到在线解码器（jwt.io 一类）里，得到Header 和 Payload **

![屏幕截图 2026-10-29 150958](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-29%20150958.png)

**Payload 里有 `username`、`password`，还有 `FL` 字段，flag 直接写在里面**

![屏幕截图 2026-10-29 151041](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-29 151041.png)

![屏幕截图 2026-10-29 152329](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-29 152329.png)

**将两段flag直接拼在一起**

**知识点：JWT 的结构**

- 三段：Header（算法 typ/alg）、Payload（声明，如 username/role）、Signature（签名）
- 编码方式：base64url（`+`→`-`、`/`→`_`、去掉 `=` 补位）
- 解码不需要密钥，**看到 token 第一反应就是解码看 Payload**
- 不要把密码、flag、密钥等敏感信息放进 JWT

#### 2.无签名攻击（alg=none）

**先拿到一个普通用户的 token，解码后可以看到 `role: guest`**

![屏幕截图 2026-10-29 152811](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-29%20152811.png)

![屏幕截图 2026-10-29 152923](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-29 152923.png)

页面提示需要把guest改成admin

![屏幕截图 2026-10-29 153113](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-29%20153113.png)

**在在线编码器里把 Header 的 `alg` 改成 `none`，Payload 的 `role` 改成 `admin`，第三段签名留空**

![屏幕截图 2026-10-29 153001](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-29 153001.png)

![屏幕截图 2026-10-29 152952](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-29%20152952.png)

**把生成的无签名 token 写回浏览器 Cookie 里的 `token` 字段**

![屏幕截图 2026-10-29 153048](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-29 153048.png)

![屏幕截图 2026-10-29 153043](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-29%20153043.png)

**刷新页面，身份变成 admin，页面返回 flag**



![屏幕截图 2026-10-29 155155](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-29%20155155.png)

**知识点：alg=none 攻击**

- JWT 规范里 `alg: none` 表示“不签名”
- 如果服务端信任 Header 里的 `alg` 且不校验签名，就接受任意伪造 token
- 利用：改 Header 的 `alg` 为 `none`、改 Payload（如 role=admin）、第三段留空
- jwt_tool 的 `-X n` 就是生成 none 算法 token，`-pc/-pv` 改 payload 键值，`-b` 输出裸 token

#### 3.弱密钥爆破

**先用默认口令登录靶机，服务端下发了一个 `role=guest` 的 HS256 token**

![屏幕截图 2026-10-30 232224](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-30 232224.png)

**对 HMAC 密钥做爆破（a-z，长度 1~5）：拿 token 的前两段重新算签名，和第三段比对，相等即为正确密钥**

![屏幕截图 2026-10-30 233928](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-30%20233928.png)

**命中密钥后，用同一把密钥把 Payload 改成 admin 重新签名**

**把新 token 替换到 Cookie 的 `token` 字段**

![屏幕截图 2026-10-30 234124](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-30%20234124.png)

**刷新页面，页面回显 `Hello admin(admin)` 并给出 flag**

![屏幕截图 2026-10-30 234127](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-30%20234127.png)

**知识点：HS256 与弱密钥**

- HS256 是对称签名：签发和校验用**同一个密钥**
- 密钥如果很短/有规律，可以拿字典离线爆破
- 爆破脚本的逻辑：HMAC-SHA256(key, header.payload)与签名比较
- 命中后就能以任意 Payload 重新签名，实现提权

#### 4.修改签名算法（公钥泄露）

**另一道题的登录页直接暴露了 `publickey.pem` 公钥文件**

![屏幕截图 2026-10-30 234827](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-30%20234827.png)

**把原始 JWT 复制出来，在 jwt.io 里把 Header 改成 HS256、Payload 改成 `{"username":"admin","role":"admin"}`**

**Secret 一栏填公钥内容（`-----BEGIN PUBLIC KEY-----` 整段），重新签名生成伪造 token**

![屏幕截图 2026-10-30 234900](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-30 234900.png)

![屏幕截图 2026-10-30 235447](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-30%20235447.png)

替换原网站token后即可
服务端原本用 RS256（私钥签名、公钥验签）；

- 如果服务端**按 Header 里的 alg 选校验方式**，把 alg 改成 HS256 后，它会拿“公钥”当 HMAC 密钥来验签
- 攻击者知道公钥，就能用公钥当 HS256 密钥自己签名，伪造任意 Payload
## ***三.Git 仓库与 Git 泄露***

#### 1.GitHack 的使用与常见错误

**先用 dirsearch 扫目标**

![屏幕截图 2026-10-31 230801](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-31 230801.png)
发现有git泄漏的可能
使用GitHack
**改成带 `/.git/` 的地址后成功下载并解析 index，恢复了 `50x.html`、`index.html` 两个当前文件**

![屏幕截图 2026-11-04 165340](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-11-04%20165340.png)

**再用 git-dumper 把整个 `.git` 拉下来**

![屏幕截图 2026-11-04 165746](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-11-04%20165746.png)

![屏幕截图 2026-11-04 165756](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-04 165756.png)

**知识点：GitHack / git-dumper**

- GitHack：只解析 `/.git/index`，下载当前 index 里记录的文件 blob，不下载提交历史；
- git-dumper：把 HEAD、refs、reflog、objects 等整个 `.git` 目录拉下来，能恢复完整仓库历史；
- 两个工具的目标参数都要写成“泄露的 `.git/` 目录”地址，例如 `http://target/.git/`；
- `.git/logs/` 返回 403 通常只是禁止目录列表，不代表不能访问里面的文件。

#### 2.Log 题：从提交历史里拿 flag



![屏幕截图 2026-11-04 170012](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-04 170012.png)

**在完整仓库里执行 `git log --all --oneline --reflog`，可以看到 HEAD 最新提交是 `remove flag`，flag 在更早的 `add flag` 提交里**

![屏幕截图 2026-11-04 170909](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-04 170909.png)

**用 `git show 0ed46a6` 查看该提交的 diff，新增文件的内容就是 flag**

![屏幕截图 2026-11-04 171130](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-04 171130.png)

**知识点：git log / git show**

- `git log`：从当前分支 HEAD 往回看提交历史；
- `git log --all --reflog`：把所有 ref 和 reflog 里的提交都列出来（能看到被 reset/删除的提交）；
- `git show <commit>`：查看某个提交的说明和 diff，`git show <commit>:<file>` 可直接看某文件内容。

#### 3.Stash 题：flag 被 git stash 藏起来

**同样先 dirsearch 扫 `.git`**

**用 git-dumper 拉下来后执行 `git log`，只有 `remove flag`、`add flag`、`init` 三个提交**

**看 `add flag` 提交的内容，文件里只有一句 `where is flag`**

![屏幕截图 2026-11-04 171130](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-11-04%20171130.png)

**执行 `git stash list`，发现有一条 `WIP on master: 74314db add flag`**

![屏幕截图 2026-11-04 171219](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-11-04%20171219.png)

**`git stash show -p` 查看 stash 里的改动，占位文字被替换成了真正的 flag**

![](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-04 172300.png)



**知识点：git stash**

- `git stash`：把未提交的修改临时存起来，生成一个挂在 `refs/stash` 下的 WIP 提交
- `git stash list`：列出 stash 栈
- `git stash show -p`：查看 stash 的改动 diff
- `git stash apply` 应用（保留记录）、`git stash pop` 应用并删除记录
- `git log` 默认只沿分支 HEAD 走，看不到 stash；`git log --all` 才会出现 `refs/stash`

**知识点：Git 泄露的三种 flag 藏法**

- **Log**：flag 在历史提交里（被 `remove` 或 `reset` 掉），用 `git log --all --reflog` + `git show` 找
- **Stash**：flag 在 `git stash` 里，用 `git stash list` + `git stash show -p` 找
- **Index**：flag 只在暂存区 `.git/index` 里，提交历史中没有，需要分析 index 或 `git fsck --lost-found` 找悬空对象
- 判断思路：先看 `git log`，再 `git stash list`，最后查 index/悬空对象

## ***四.CVE 漏洞的搜集思维***

#### 1.**[CVE-2021-43798](https://www.nssctf.cn/problem/1139)**

**打开靶机，页面标题是 Grafana；Grafana 有一个未授权的健康检查接口 `/api/health`，直接返回版本**

![屏幕截图 2026-11-04 175803](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-04 175803.png)

**确认版本为 `8.3.0`**
**先拿“组件 + 版本”去漏洞库搜：NVD 搜 `grafana 8.3.0`，可以找到 CVE-2021-43798**

**构造穿越请求：插件目录位于 `/usr/share/grafana/public/app/plugins/panel/alertlist`，往上退 8 层到根目录，再读 `/flag`**

**在 Burp 里把请求行改成：`GET /public/plugins/alertlist/..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2fflag HTTP/1.1`**

![屏幕截图 2026-11-04 180012](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-04 180012.png)

**发出去后返回 200，正文就是 flag**

![屏幕截图 2026-11-04 180009](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-04 180009.png)

**知识点：CVE 漏洞的搜集与利用**

**1 CVE 是什么**

- CVE（Common Vulnerabilities and Exposures）：给公开披露的漏洞发的唯一编号，格式 `CVE-年份-编号`
- 记录内容：漏洞描述、受影响版本、参考链接；NVD 会补充 CVSS 评分、CWE 类型、CPE 版本范围
- 相关概念：CVSS（严重性评分）、CWE（漏洞类型，如 CWE-22 路径穿越）、CISA KEV（已被在野利用的漏洞清单）

**2 搜集流程**

- 指纹：识别组件与版本（标题、特有接口、静态资源、响应头、报错页）
- 检索：NVD、GitHub Advisory、厂商公告/Release Notes、Exploit-DB、Packet Storm、searchsploit、Nuclei 模板
- 匹配：核对受影响版本范围、是否需要认证、是否满足前置条件
- 验证：找 PoC 实测，先读无害文件再读 flag；
- 没有公开 CVE 时：对比版本 diff/changelog、源码审计、通用漏洞 checklist

**3 路径穿越原理**

- 漏洞点：`filepath.Join(插件目录, 用户传入的路径)`，拼接后没有校验结果是否还在插件目录内
- `..` 表示上级目录，退到根目录后再拼 `flag` 就是 `/flag`
- 层数：插件目录在磁盘上有 8 层，8 个 `..` 到根；多写几个也没关系（到根后多余的 `..` 会被折叠）
- WAF 绕过：明文 `../` 被拦时，把 `/` 编码成 `%2f`，服务端解码后仍然还原成路径分隔符

# **知识点总结**
## ***一.信息收集方法论***

**1 指纹识别**

- 看页面标题、favicon、响应头（Server、X-Powered-By）、Cookie 名、报错页、默认路径
- 常见指纹接口：`/api/health`、`/version`、`/actuator/info`、`/phpinfo.php`、`/robots.txt`、`/login`
- 静态资源哈希、JS 里的 API 路径、source map 也能暴露版本和源码
- 工具：Wappalyzer、whatweb、httpx、nmap -sV

**2 目录与文件扫描**

- 目的：找隐藏路径、备份文件、源码包、`.git/.svn`、后台入口、调试接口
- 常见高危文件：`www.zip`、`wwwroot.zip`、`*.bak`、`*.swp`、`.DS_Store`、`.git/`、`phpinfo.php`
- 工具：dirsearch、ffuf、feroxbuster、gobuster + SecLists
- 状态码判断：200 存在、301/302 跳转、403 存在但禁止访问、404 不存在、500 可能报错、429 被限速

**3 源码与备份泄露**

- `.git` 泄露：可恢复源码和历史；工具 GitHack（仅当前文件）、git-dumper（完整仓库）
- `.svn/.hg` 泄露：同理会暴露源码和版本信息
- 备份包泄露：下载解压后直接审计
- 泄露的源码/配置中重点看：账号密码、密钥、token、数据库配置、调试开关、危险函数

**4 信息收集的思维**

- 从一个点出发，把“能用上的信息”都收集起来：版本、路径、账号、源码、注释、历史
- 信息之间可以互相印证：源码里泄露的默认口令可以拿去登录，登录后的 token 又可以继续分析
- 先广后深：先指纹+目录扫一遍，再针对可疑点深入

## ***二.弱口令与默认口令***

**1 常见默认口令**

- `admin/admin`、`admin/123456`、`admin/password`、`guest/guest`、`test/test`、`root/root`
- 用户名常见：admin、administrator、root、test、guest、以及题目主题相关的名称（如本笔记里的 `rimuru`）

**2 爆破要点**

- 先手工试默认口令，再上字典
- Burp Intruder 四种模式要会选：单参数 Sniper、同值 Battering ram、一一对应 Pitchfork、全组合 Cluster bomb
- 判断成功的依据：状态码、响应长度、跳转、Set-Cookie、页面关键字
- 结果太多时用过滤：隐藏 3xx/4xx/5xx，或按长度排序

**3 字典**

- 可以根据题目线索生成专属字典（角色名、年份、站点名 + 常见后缀）

## ***三.JWT 专题***

**1 结构**

- `Header.Payload.Signature` 三段，base64url 编码，用 `.` 分隔
- Header 常见：`{"typ":"JWT","alg":"HS256"}`
- Payload 是声明（claims），常见 `username`、`role`、`exp` 等
- Signature 用密钥对前两段签名，防篡改

**2 攻击矩阵**

- **敏感信息泄露**：Payload 里直接写了密码/flag，解码即得
- **无签名（alg=none）**：把 alg 改成 none、签名留空，服务端不校验签名就接受
- **弱密钥**：HS256 密钥太弱，字典爆破后重新签名
- **算法混淆（RS256→HS256）**：用泄露的公钥当 HMAC 密钥重签
- 其它：`kid` 注入、`jku/x5u` 伪造、过期时间校验缺失等

**3 工具**

- 在线：jwt.io（解码/编码/验签）
- 命令行：jwt_tool（`-X n` none 攻击、`-pc/-pv` 改 payload、`-C` 爆破密钥）
- 自写脚本：`hmac` + `hashlib` 爆破弱密钥、重签 token

**4 防御**

- 服务端固定算法，不信任 Header 的 alg
- 使用强随机密钥
- 不要在 JWT 里放敏感信息
- 校验签名、过期时间、签发者

## ***四.Git 泄露专题***

**1 常用命令**

- `git status`：工作区状态
- `git log` / `git log --all --oneline --reflog`：提交历史（含 reflog）
- `git show <commit>`、`git show <commit>:<file>`：看提交/文件
- `git diff`：工作区与暂存区/提交的差异
- `git stash list` / `git stash show -p`：查看 stash
- `git fsck --lost-found`：找悬空对象

**2 三种子题**

- **Log**：flag 在历史提交中，`git log --all --reflog` 找到提交，`git show` 看 diff
- **Stash**：flag 在 stash 中，`git stash list` 看条目，`git stash show -p` 看内容
- **Index**：flag 只在 `.git/index` 暂存区，提交历史里没有，需要分析 index 或用 `git fsck` 找悬空对象

**3 工具**

- GitHack：解析 `.git/index`，还原当前工作区文件
- git-dumper：把整个 `.git` 拉下来，恢复完整历史
- 目标参数都是 `.git/` 目录地址`/.git/logs/` 返回 403 只是目录列表被禁

**4 防御**

- 部署时不要带上 `.git` 目录
- Web 服务器禁止访问 `.git/`
- 备份文件、源码包不要放在 Web 根目录

## ***五.CVE 专题***

**1 概念**

- CVE：公开漏洞的唯一编号，由 MITRE/CNA 分配
- NVD：在 CVE 基础上加 CVSS、CWE、CPE 等分析数据
- CVSS：0–10 分的严重性评分
- CWE：漏洞类型分类（如 CWE-22 路径穿越、CWE-79 XSS、CWE-89 SQL 注入）
- CISA KEV：已知被在野利用的漏洞清单

**2 搜集渠道**

- NVD、CVE.org、GitHub Security Advisory
- 厂商安全公告、Release Notes、修复 commit
- Exploit-DB、Packet Storm、searchsploit、Nuclei 模板
- Vulners、OSV、CXSecurity 等聚合库
- 国内：CNVD、CNNVD、Seebug 等

**3 利用流程**

- 指纹识别组件和版本
- 按版本匹配受影响范围
- 找 PoC / 自己构造
- 先读无害文件验证，再读 flag / 执行命令
- 遇到 WAF/代理，考虑编码、路径规范化、HTTP 客户端差异

**4 没有 CVE 时**

- 对比修复版本源码/commit diff，反推漏洞点；
- 源码审计：找危险函数和污染路径
- 黑盒按功能测漏洞：SQLi、XSS、SSRF、文件上传/读取、越权、反序列化等
- 关注版本 changelog 里的 “security fix”

## ***六.WAF 与编码绕过***

- 明文 `../` 被拦时：尝试 `..%2f`、`%2e%2e/`、双重编码等，具体看服务端解码次数
- curl 要加 `--path-as-is`，否则客户端会先折叠 `..`
- 浏览器/客户端会规范化路径，测试路径穿越/目录穿越时用 Burp 或 curl 原样发送
- WAF 会对敏感文件名（如 `/etc/passwd`）单独拦截，测试时先用无害文件（`/etc/hostname`、`/flag`）
- 编码要与服务端解码逻辑匹配：单次解码、二次解码、Unicode 编码等
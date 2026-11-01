# Web 方向 week3 作业 · HTTP 请求与响应

| 项目 | 内容 |
| --- | --- |
| ID | gofkurself |
| 年级-方向 | 26-web |
| 周次 | week3（10.26 - 11.1） |
| 完成日期 | 2026-10-27 |
| 任务来源 | [培训文档](https://hnusec-star.feishu.cn/wiki/U2xfwfP39iWhISkZOa4c1UtInxd) · web 技术文档 第三节 HTTP 请求与响应 |
### 3.1 环境与工具

| 工具 | 是否可用 | 版本 / 入口 |
| --- | --- | --- |
| 浏览器开发者工具（F12） | 是 | Chromium 134.0.6998.136 |
| HackBar | 是 | 1.3.0 |
| Burp Suite 或其他抓包工具 | 是 | v2026.9.3 |

### 3.2 请求报文

#### 3.2.1 请求行

- 由哪几部分组成：Method 请求方法, /xxx 请求路径, HTTP/x.x 请求版本
- 三部分各是什么意思：
Method: POST/GET/PUT 告诉服务器客户端要做什么
/xxx: 请求的内容路径
HTTP/x.x: 协议版本
- 常见方法有哪些，区别是什么：
GET: 获取资源
POST: 提交数据
PUT: 上传/替换资源
DELETE: 删除资源
- 我的抓包：
![截图](img/gofkurself/Charles_rHbKS0Aqsr.png)

#### 3.2.2 请求头

- 作用：协商客户端能处理的内容编码格式
- 格式：
Host：目标域名
UA: 客户端身份
Referer: 跳转的起点页面
Cookie: 对话凭证
Content-Type: 请求体的格式
- 请求头字段名大小写敏感吗：标头不区分,cookie,session等严格大小写敏感
- 我的抓包：
![截图](img/gofkurself/java_yQ4uYRi8xI.png)

#### 3.2.3 空行与请求体

- 空行为什么必须有：空行是请求体与头的分界线,不能丢失,如果丢失的话Body会被视为畸形的请求体
- 请求体什么时候才有：POST/PUT
- 我的抓包（一个带 body 的 POST）：
![截图](img/gofkurself/java_j71jbBbUyc.png)

### 3.3 响应报文

#### 3.3.1 状态行

- 由哪几部分组成：协议版本,状态码,状态短语
- 状态码分几类，各代表什么：
200 成功
301/302:重定向
401:未认证
403:禁止访问
404:不存在
- 我遇到过的状态码：403 Forbidden, 429 Too Many Requests

#### 3.3.2 响应头

- 常见响应头有哪些，各管什么：
Content-Type: 内容的格式
Content-Length: 内容的大小
Transfer-Encoding: 传输类型
Set-Cookie: 写入Cookie
- `Content-Length` 和 `Content-Type` 为什么重要：
Content-Length 是服务端校验数据的依据之一
Content-Type 指挥了文件的类型, 可用来做script注入

#### 3.3.3 响应体

- 响应体里放什么：
服务器返回的实际数据
结构化数据,网页代码,多媒体流等
- 和请求体的关系：
二者在协议中是配对的,有请求体必有响应体
但部分响应也可独立存在(GET)

### 3.4 必背的请求头

| 头部 | 作用 |
|---|---|
| `Host` | 一个 IP 挂着多个站时，靠它说清你要访问哪个站 |
| `User-Agent` | 客户端标识，题目说"用 XX 浏览器"就改它 |
| `Referer` | 从哪跳过来的，说"必须从某站跳转"就改它 |
| `Cookie` | 身份凭证，"缺少某 Cookie"就补上 |
| `X-Forwarded-For` | 代理记的客户端 IP，后端一般直接信，说"只允许本机"就伪造它 |
| `Content-Type` | 请求体的格式，写错后端就解析不出参数 |
| `Content-Length` | 请求体的字节数，不是字符数 |

### 3.5 Cookie 与 Session

- Cookie 存在哪、谁发的: 存在客户端里, 由服务器下发
- Session 存在哪、怎么和 Cookie 对应：Session相当于保存在服务器的Cookie, 客户端只保存SessionID




### 3.6 [0xGame2025] Http 的真理，我已解明

#### 步骤 1：
![截图](img/gofkurself/chrome_tmdArM6z4T.png)

- 环境提示GET传递hello=web
- 于是附加参数
![截图](img/gofkurself/java_KprFYEb1Ax.png)
#### 步骤 2：
![截图](img/gofkurself/chrome_i5ZZjFgv9u.png)
- 要求POST传递http=god
- 所以在请求体中附加内容, 别忘了加Content-Type(踩坑了卡了好久)
![截图](img/gofkurself/java_87bnXbukts.png)

#### 步骤 3：
![截图](img/gofkurself/chrome_XihTMbb6Cv.png)
- 要求附加Cookie
- 请求头中附加
![截图](img/gofkurself/java_0HDtuWNM0C.png)

#### 步骤 4:
![截图](img/gofkurself/chrome_q8ebnjoZyh.png)
- 要求使用Safari访问
- 改UA
![截图](img/gofkurself/java_0HDtuWNM0C.png)

#### 步骤 5：
![截图](img/gofkurself/chrome_ENZtQYBJEw.png)
- 要从米游官网访问
- 于是添加Referer
忘记截图了 :(

#### 步骤 6：
![截图](img/gofkurself/chrome_y4A8UTTjcG.png)
- 要求代理
- 添加via参数
![截图](img/gofkurself/java_Clo9YGgzmt.png)

#### 结果
- flag：
![截图](img/gofkurself/chrome_PsjEpXr8fq.png)
- 这题串了哪几个头部：Cookie,UA,Referer,via,Content-Type

### 3.7 [SWPUCTF 2024 秋季新生赛] http标头



#### 步骤 1：
![截图](img/gofkurself/chrome_gwmWnbKmAo.jpg)
- 要求在黑神话发售当天零点访问
- 于是附加Date参数
(忘记截图了)


#### 步骤 2：
![截图](img/gofkurself/chrome_YqrRujAxb1.png)
- 要求使用BlackMonkey浏览器
- 改UA
![截图](img/gofkurself/java_UUIZGqOTRu.png)


#### 步骤 3：
![截图](img/gofkurself/chrome_OhAIA7jUkT.png)
- 要从wukong那里过来
- 加referer
(搞红了没截图)

#### 步骤 4:
![截图](img/gofkurself/chrome_kdxv9xfs0J.png)
- 要本地loopback地址
- 加X-Forwarded-From
![截图](img/gofkurself/java_O0DIHO9WGl.png)

#### 最终请求体
![截图](img/gofkurself/java_FIeyS86fm8.png)
#### 结果

- flag：
![截图](img/gofkurself/chrome_95FvJkF9So.png)

### 3.8 这节的坑

| 现象 | 原因 | 怎么解决的 |
| --- | --- | --- |
| POST传不上去东西 | 没加Content-Type | 加上了继续干的 |
| Date传了没反应 | 搞成timestamp了 | 换成date格式 |

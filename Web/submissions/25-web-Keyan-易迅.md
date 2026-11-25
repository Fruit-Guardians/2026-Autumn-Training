# **<font style="color:rgb(0,0,0);">1 基础认识</font>**
<font style="color:rgb(0,0,0);">在浏览器里输入一个地址，到你看到页面，中间经过四层。每一层都是漏洞可能发生的位置。</font>

| **<font style="color:rgb(0,0,0);">层次</font>** | **<font style="color:rgb(0,0,0);">常见软件</font>** | **<font style="color:rgb(0,0,0);">负责什么</font>** | **<font style="color:rgb(0,0,0);">出问题时的表现</font>** |
| :---: | --- | --- | --- |
| <font style="color:rgb(0,0,0);">浏览器</font> | <font style="color:rgb(0,0,0);">Chrome / Edge</font> | <font style="color:rgb(0,0,0);">发出请求、解析渲染页面</font> | <font style="color:rgb(0,0,0);">前端校验被绕过</font> |
| <font style="color:rgb(0,0,0);">Web </font><font style="color:rgb(0,0,0);">服务器</font> | <font style="color:rgb(0,0,0);">Apache / Nginx</font> | <font style="color:rgb(0,0,0);">接收请求，交给后端程序处理</font> | <font style="color:rgb(0,0,0);">目录遍历、解析规则被利用</font> |
| <font style="color:rgb(0,0,0);">后端程序</font> | <font style="color:rgb(0,0,0);">PHP / Java / Python</font> | <font style="color:rgb(0,0,0);">处理业务、拼</font><font style="color:rgb(0,0,0);"> SQL</font><font style="color:rgb(0,0,0);">、读写文件</font> | <font style="color:rgb(0,0,0);">注入、上传、命令执行</font> |
| <font style="color:rgb(0,0,0);">数据库</font> | <font style="color:rgb(0,0,0);">MySQL</font> | <font style="color:rgb(0,0,0);">存放账号、文章等数据</font> | <font style="color:rgb(0,0,0);">数据被拖走、被篡改</font> |


<font style="color:rgb(0,0,0);">表 1Web 访问的四层结构</font>

# **<font style="color:rgb(0,0,0);">2 网络协议</font>**
## **<font style="color:rgb(0,0,0);">2.1 </font>**HTTP协议
**基础概念**

• 超文本传输协议，是一种用于分布式、协作式和超媒体信息系统的应用层协议。简单来说就是一种发布和接收HTML页面的方法，被用于在Web浏览器和网站服务器之间传递信息。

• HTTP是一种无状态保存协议。HTTP协议自身不对请求和响应之间的通信状态进行保存，也就是说HTTP协议对于发送过的请求或响应都<u>不做持久化处理</u>。

• HTTP 默认工作在 TCP 协议** 80 端口**，用户访问网站 http:// 打头的都是标准 HTTP 服务。

• **HTTP 协议以明文方式发送内容，不提供任何方式的数据加密**，如果攻击者截取了Web浏览器和网站服务器之间的传输报文，就可以直接读懂其中的信息，因此，HTTP协议不适合传输一些敏感信息，比如：信用卡号、密码等支付信息。



**工作流程**

• 地址解析

• 封装HTTP请求数据包

• 分装成TCP包，建立TCP连接(三次握手)

• 客户机发送请求命令

• 服务器响应

• 服务器关闭TCP连接



## 2.2 HTTPS协议
基本概念

• 超文本传输**安全协议**，是一种透过计算机网络进行安全通信的传输协议。HTTPS 经由 HTTP 进行通信，但利用 SSL/TLS 来加密数据包。HTTPS 开发的主要目的，是提供对网站服务器的身份认证，**保护交换数据的隐私与完整性**。

• HTTPS 默认工作在 TCP 协议**443端口**



**工作流程**

• 建立TCP连接(三次握手)

• **客户端验证服务器数字证书**

• DH 算法协商对称加密算法的密钥、hash 算法的密钥

• SSL安全加密隧道协商完成

• 网页以加密的方式传输，用协商的对称加密算法和密钥加密，保证数据机密性；用协商的hash算法进行数据完整性保护，保证数据不被篡改



## 2.3 tcp协议
• 三次握手

在TCP/IP协议中，TCP协议通过三次握手<u>建立一个可靠的连接</u>



• 第一次握手：客户端尝试连接服务器，**向服务器发送 syn 包**（同步序列编号Synchronize Sequence Numbers），syn=j，客户端进入 SYN_SEND 状态等待服务器确认

• 第二次握手：服务器**接收客户端syn包并确认**（ack=j+1），**同时向客户端发送一个 SYN包**（syn=k），即 SYN+ACK 包，此时服务器进入 SYN_RECV 状态

• 第三次握手：第三次握手：**客户端收到服务器的SYN+ACK包，向服务器发送确认包ACK**(ack=k+1），此包发送完毕，客户端和服务器进入ESTABLISHED状态，**完成**三次握手

<img src="https://cdn.nlark.com/yuque/0/2026/png/73997499/1795185896890-c53376ce-2875-4014-832b-790258d29b65.png" width="886.6666666666666" height="330" title="" crop="0,0,1,1" id="u38439e23" class="ne-image">

• 四次挥手

建立TCP连接需要三次握手，<u>终止TCP连接</u>需要四次挥手



• 第一次挥手 **客户端发出连接释放报文**，并且停止发送数据。释放数据报文首部，FIN=1，其序列号为seq=u（等于前面已经传送过来的数据的最后一个字节的序号加1），此时，客户端进入FIN-WAIT-1（终止等待1）状态

• 第二次挥手 服务器端接收到连接释放报文后，**发出确认报文**，ACK=1，ack=u+1，并且带上自己的序列号seq=v，此时，服务端就进入了CLOSE-WAIT 关闭等待状态

• 第三次挥手 客户端接收到服务器端的确认请求后，客户端就会进入FIN-WAIT-2（终止等待2）状态，等待服务器发送连接释放报文，**服务器将最后的数据发送完毕后，就向客户端发送连接释放报文**，服务器就进入了LAST-ACK（最后确认）状态，等待客户端的确认。

• 第四次挥手 客户端收到服务器的连接释放报文后，**必须发出确认**，ACK=1，ack=w+1，而自己的序列号是seq=u+1，此时，客户端就进入了TIME-WAIT（时间等待）状态，但此时TCP连接还未终止，必须要经过2MSL后（最长报文寿命），当客户端撤销相应的TCB后，客户端才会进入CLOSED关闭状态，服务器端接收到确认报文后，会立即进入CLOSED关闭状态，到这里TCP连接就断开了，四次挥手完成

<img src="https://cdn.nlark.com/yuque/0/2026/png/73997499/1795185926554-688b2358-ccb0-4afb-80dd-f88b754624f7.png" width="888" height="329" title="" crop="0,0,1,1" id="ub13df92d" class="ne-image">



## **<font style="color:rgb(0,0,0);">2.4 URL 的五个组成部分</font>**
 **URL：**网上某个资源的地址  

| **<font style="color:rgb(0,0,0);">部分</font>** | **<font style="color:rgb(0,0,0);">在这条地址里是</font>** | **<font style="color:rgb(0,0,0);">含义</font>** |
| :---: | :---: | --- |
| <font style="color:rgb(0,0,0);">协议</font> | <font style="color:rgb(0,0,0);">http</font> | <font style="color:rgb(0,0,0);">明文传输；</font><font style="color:rgb(0,0,0);">https </font><font style="color:rgb(0,0,0);">是加密传输</font> |
| <font style="color:rgb(0,0,0);">主机与端口</font> | <font style="color:rgb(0,0,0);">127.0.0.1:8080</font> | <font style="color:rgb(0,0,0);">本机地址和</font><font style="color:rgb(0,0,0);"> Web </font><font style="color:rgb(0,0,0);">服务监听端口</font> |
| <font style="color:rgb(0,0,0);">路径</font> | <font style="color:rgb(0,0,0);">/pikachu/vul/sqli/sqli_str.php</font> | <font style="color:rgb(0,0,0);">服务器上的具体程序文件</font> |
| <font style="color:rgb(0,0,0);">查询参数</font> | <font style="color:rgb(0,0,0);">?name=v&submit=1</font> | <font style="color:rgb(0,0,0);">键值对，多个用 & 连接 </font> |
| <font style="color:rgb(0,0,0);">锚点</font> | <font style="color:rgb(0,0,0);">#top</font> | <font style="color:rgb(0,0,0);">只在浏览器内部跳转，不发给服务器</font> |


<font style="color:rgb(0,0,0);">表 2URL 结构拆解</font>

**端口：**IP 地址定位到 “哪台机器”，端口定位到 “<u>这台机器上的哪个程序</u>”

  

**<font style="color:rgb(0,0,0);">查询串：</font>**<font style="color:rgb(0,0,0);">URL 里第一个 </font>`<font style="color:rgb(0,0,0);">?</font>`<font style="color:rgb(0,0,0);"> 之后、</font>`<font style="color:rgb(0,0,0);">#</font>`<font style="color:rgb(0,0,0);"> 之前的那一段。 </font>

<font style="color:rgb(0,0,0);">             是GET 参数唯一的来源 → </font>**SQL 注入、XSS、命令注入的注入点最常在这里**

****

** 片段 anchor（也叫 fragment / 锚点）：**URL 里 `#` 之后的全部内容。

改片段不会重新加载页面

前端拿它做路由（hash 路由）  

 它还会截断你的注入 payload  

你在地址栏手打：

?id=1' OR 1=1 -- #

末尾那个 `#` 本来想当注释符，结果在 URL 里它是**片段起点**—— 浏览器认为 “这是锚点”，于是 `#` 连同后面的内容被当锚点处理，而真正的注释符必须是 `<u>-- </u>`<u> 加空格（MySQL 里 </u>`<u>--</u>`<u> 后面必须跟空白）</u>。更常见的失败是 payload 里带 `#`，被当成锚点整段丢弃，发到服务器的只剩 `id=1' OR 1=1 -- `，少了一半。



:::danger
**编码注意：值里的特殊字符必须百分号编码。**`**空格**`**→**`**%20**`**，**`**'**`**→**`**%27**`**，**`**&**`**→**`**%26**`**，**`**=**`**→**`**%3D**`**，**`**+**`**→**`**%2B**`**。**

:::

<font style="color:rgb(0,0,0);"></font>

https://admin:123456@www.example.com:8080/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit#bottom  
└─┬─┘ └────┬────────┘ └──────┬──────└┬──┘└──────────┬──────────────┘└────────┬─────────┘└──┬──┘  
 协议      用户信息        主机(域名) 端口         路径(path)                  查询串       片段

| <font style="color:rgb(0,0,0);">写法</font> | <font style="color:rgb(0,0,0);">含义</font> |
| --- | --- |
| `<font style="color:rgb(0,0,0);">?</font>` | <font style="color:rgb(0,0,0);">查询串的起点，一个 URL 只有一个（第二个 </font>`<font style="color:rgb(0,0,0);">?</font>`<br/><font style="color:rgb(0,0,0);"> 会变成值的一部分）</font> |
| `<font style="color:rgb(0,0,0);">&</font>` | <font style="color:rgb(0,0,0);">多个参数的分隔符</font> |
| `<font style="color:rgb(0,0,0);">=</font>` | <font style="color:rgb(0,0,0);">键与值的连接</font> |
| `<font style="color:rgb(0,0,0);">id=1</font>` | <font style="color:rgb(0,0,0);">参数名 </font>`<font style="color:rgb(0,0,0);">id</font>`<br/><font style="color:rgb(0,0,0);">，值 </font>`<font style="color:rgb(0,0,0);">1</font>` |
| `<font style="color:rgb(0,0,0);">Submit=Submit</font>` | <font style="color:rgb(0,0,0);">参数名 </font>`<font style="color:rgb(0,0,0);">Submit</font>`<br/><font style="color:rgb(0,0,0);">，值 </font>`<font style="color:rgb(0,0,0);">Submit</font>` |
| `<font style="color:rgb(0,0,0);">?a=&b=2</font>` | `<font style="color:rgb(0,0,0);">a</font>`<br/><font style="color:rgb(0,0,0);"> 是空值，仍然算 “有该参数”</font> |
| `<font style="color:rgb(0,0,0);">?flag</font>` | <font style="color:rgb(0,0,0);">只有键没有值，合法写法</font> |
| `<font style="color:rgb(0,0,0);">?tag=1&tag=2</font>` | <font style="color:rgb(0,0,0);">同名键重复，服务端常解析成数组 </font>`<font style="color:rgb(0,0,0);">tag[]</font>` |


<font style="color:rgb(0,0,0);">                                                            表 3 写法及含义</font>

## **<font style="color:rgb(0,0,0);">2.5 请求报文的三个部分</font>**
| **<font style="color:rgb(0,0,0);">部分</font>** | **<font style="color:rgb(0,0,0);">写的是什么</font>** | **<font style="color:rgb(0,0,0);">示例</font>** |
| :---: | --- | --- |
| <font style="color:rgb(0,0,0);">请求行</font> | <font style="color:rgb(0,0,0);">方法</font><font style="color:rgb(0,0,0);"> + </font><font style="color:rgb(0,0,0);">路径 </font><font style="color:rgb(0,0,0);">+ </font><font style="color:rgb(0,0,0);">协议版本</font> | <font style="color:rgb(0,0,0);">GET /vul/sqli/sqli_str.php?name=v HTTP/1.1</font> |
| <font style="color:rgb(0,0,0);">请求头</font> | <font style="color:rgb(0,0,0);">一行一个</font><font style="color:rgb(0,0,0);">“</font><font style="color:rgb(0,0,0);">名称</font><font style="color:rgb(0,0,0);">: </font><font style="color:rgb(0,0,0);">值</font><font style="color:rgb(0,0,0);">”</font> | <font style="color:rgb(0,0,0);">Host</font><font style="color:rgb(0,0,0);">、</font><font style="color:rgb(0,0,0);">Cookie</font><font style="color:rgb(0,0,0);">、</font><font style="color:rgb(0,0,0);">User-Agent</font><font style="color:rgb(0,0,0);">、</font><font style="color:rgb(0,0,0);">Referer</font><font style="color:rgb(0,0,0);">、</font><font style="color:rgb(0,0,0);">Content-Type</font> |
| <font style="color:rgb(0,0,0);">空行</font> | <font style="color:rgb(0,0,0);">固定一个空行</font> | <font style="color:rgb(0,0,0);">—</font> |
| <font style="color:rgb(0,0,0);">请求体</font> | <font style="color:rgb(0,0,0);">POST </font><font style="color:rgb(0,0,0);">提交的数据</font> | <font style="color:rgb(0,0,0);">username=admin&password=123456</font> |


<font style="color:rgb(0,0,0);">                                                        表 4 HTTP 请求的结构</font>

<font style="color:rgb(0,0,0);">GET 和 POST 的区别常被误解，其实核心只有一点：数据放的位置不同。</font>

`<font style="color:rgb(0,0,0);">GET</font>`<font style="color:rgb(0,0,0);"> 取资源、</font>`<font style="color:rgb(0,0,0);">POST</font>`<font style="color:rgb(0,0,0);"> 提交数据</font>

| **<font style="color:rgb(0,0,0);">对比项</font>** | **<font style="color:rgb(0,0,0);">GET</font>** | **<font style="color:rgb(0,0,0);">POST</font>** |
| :---: | --- | --- |
| <font style="color:rgb(0,0,0);">数据位置</font> | <font style="color:rgb(0,0,0);">URL </font><font style="color:rgb(0,0,0);">的查询参数里</font> | <font style="color:rgb(0,0,0);">请求体里</font> |
| <font style="color:rgb(0,0,0);">长度限制</font> | <font style="color:rgb(0,0,0);">受</font><font style="color:rgb(0,0,0);"> URL </font><font style="color:rgb(0,0,0);">长度限制</font> | <font style="color:rgb(0,0,0);">基本不受限</font> |
| <font style="color:rgb(0,0,0);">能否直接重放</font> | <font style="color:rgb(0,0,0);">浏览器地址栏粘贴即可</font> | <font style="color:rgb(0,0,0);">需要用工具或表单重发</font> |
| <font style="color:rgb(0,0,0);">安全性</font> | <font style="color:rgb(0,0,0);">低（明文在地址栏和日志里）</font> | <font style="color:rgb(0,0,0);">同样低，只是不显示在地址栏</font> |


<font style="color:rgb(0,0,0);">表 5 GET 与 POST 的差异</font>

<font style="color:rgb(0,0,0);">很多人以为“POST 比 GET 安全”，这是错的。两者都不加密，只是暴露位置不同；真正的加密来自 HTTPS。对攻击者来说，POST 只是需要多一步抓包而已。</font>



| <font style="color:rgb(0,0,0);">报文位置</font> | <font style="color:rgb(0,0,0);">后端取它的方式</font> | <font style="color:rgb(0,0,0);">对应攻击</font> |
| --- | --- | --- |
| <font style="color:rgb(0,0,0);">请求行里的查询串</font> | `<font style="color:rgb(0,0,0);">$_GET['name']</font>` | **GET 型 SQL 注入**<font style="color:rgb(0,0,0);">、XSS（反射型）</font> |
| <font style="color:rgb(0,0,0);">请求体</font> | `<font style="color:rgb(0,0,0);">$_POST['username']</font>` | **POST 型 SQL 注入**<font style="color:rgb(0,0,0);">、XSS（存储型）</font> |
| <font style="color:rgb(0,0,0);">请求头 </font>`<font style="color:rgb(0,0,0);">Cookie</font>`<font style="color:rgb(0,0,0);"> / </font>`<font style="color:rgb(0,0,0);">User-Agent</font>`<font style="color:rgb(0,0,0);"> / </font>`<font style="color:rgb(0,0,0);">Referer</font>` | `<font style="color:rgb(0,0,0);">$_SERVER['HTTP_USER_AGENT']</font>`<font style="color:rgb(0,0,0);"> 等</font> | <font style="color:rgb(0,0,0);">HTTP 头注入（UA 被存入数据库时）</font> |


<font style="color:rgb(0,0,0);">           表6 这组结构与注入点的关系  </font>

**HTTP 请求 = 请求行 + 请求头 + 空行 + 请求体；“谁说的” 在行里，“补充说明” 在头里，“空行划线”，“真正要交的数据” 在体里**<font style="color:rgb(0,0,0);">。找注入点，就是在这四处可控内容里逐个试。</font>

<font style="color:rgb(0,0,0);"></font>

## **<font style="color:rgb(0,0,0);">2.6 响应报文与状态码</font>**
| **<font style="color:rgb(0,0,0);">状态码</font>** | **<font style="color:rgb(0,0,0);">含义</font>** | **<font style="color:rgb(0,0,0);">安全视角下的意义</font>** |
| :---: | --- | --- |
| <font style="color:rgb(0,0,0);">200</font> | <font style="color:rgb(0,0,0);">请求成功</font> | <font style="color:rgb(0,0,0);">正常返回，可能已经把数据带出来了</font> |
| <font style="color:rgb(0,0,0);">302</font> | <font style="color:rgb(0,0,0);">临时跳转</font> | <font style="color:rgb(0,0,0);">登录成功后跳首页，常伴随</font><font style="color:rgb(0,0,0);"> Set-Cookie</font> |
| <font style="color:rgb(0,0,0);">403</font> | <font style="color:rgb(0,0,0);">禁止访问</font> | <font style="color:rgb(0,0,0);">有资源但没权限，越权测试常撞到这个</font> |
| <font style="color:rgb(0,0,0);">404</font> | <font style="color:rgb(0,0,0);">资源不存在</font> | <font style="color:rgb(0,0,0);">路径探测时用来判断目录结构</font> |
| <font style="color:rgb(0,0,0);">500</font> | <font style="color:rgb(0,0,0);">服务器内部错误</font><font style="color:rgb(0,0,0);">（</font><font style="color:rgb(0,0,0);">服务器崩溃）</font> | <font style="color:rgb(0,0,0);">程序报错，常泄露文件路径和</font><font style="color:rgb(0,0,0);"> SQL </font><font style="color:rgb(0,0,0);">语句</font> |
| <font style="color:rgb(0,0,0);">502</font> | <font style="color:rgb(0,0,0);">网关错误</font> | <font style="color:rgb(0,0,0);">后端服务没起来，搭环境时最常见</font> |


<font style="color:#DF2A3F;background-color:#FBDE28;">表 7  响应状态码</font>

<font style="color:rgb(0,0,0);">特别留意 500：一个构造错误的输入让程序报错，</font>**<font style="color:rgb(0,0,0);">报错页面里经常带着完整路径甚至 SQL 语句</font>**<font style="color:rgb(0,0,0);">，这本身就是重要线索。所谓“</font>**<font style="color:rgb(0,0,0);">报错注入</font>**<font style="color:rgb(0,0,0);">”，就是从这类页面里读出数据。</font>

<font style="color:rgb(0,0,0);"></font>

## **<font style="color:rgb(0,0,0);">2.7 Cookie、Session 与“工牌”</font>**
<font style="color:rgb(0,0,0);">登录的过程可以这样理解：你提交账号密码，服务器验证通过后，在响应头里写一句</font><font style="color:rgb(0,0,0);"> Set-Cookie: PHPSESSID=abc123</font><font style="color:rgb(0,0,0);">，相当于发给你一张工牌。之后你每次请求都在请求头里带着 </font><font style="color:rgb(0,0,0);">Cookie</font><font style="color:rgb(0,0,0);">，服务器靠这张工牌认人，不需要你重复输密码。</font>

<font style="color:rgb(0,0,0);">因为绝大多数漏洞的最终目的，就是“拿到别人的工牌”或者“借用你的工牌”。</font>**<font style="color:rgb(0,0,0);">XSS 偷的是 Cookie，CSRF 借的是 Cookie，会话固定攻击换的也是 Cookie</font>**<font style="color:rgb(0,0,0);">。</font><u><font style="color:rgb(0,0,0);">看到任何一个漏洞，都可以问一句：它最终能不能影响这张工牌。</font></u>

<u><font style="color:rgb(0,0,0);"></font></u>

## **<font style="color:rgb(0,0,0);">2.8 三种必须认识的编码</font>**
| **<font style="color:rgb(0,0,0);">编码</font>** | **<font style="color:rgb(0,0,0);">什么场合出现</font>** | **<font style="color:rgb(0,0,0);">例子</font>** | **<font style="color:rgb(0,0,0);">在漏洞里的作用</font>** |
| :---: | --- | :---: | --- |
| <font style="color:rgb(0,0,0);">URL </font><font style="color:rgb(0,0,0);">编码</font> | <font style="color:rgb(0,0,0);">URL </font><font style="color:rgb(0,0,0);">里的特殊字符</font> | <font style="color:rgb(0,0,0);">%3Cscript%3E</font> | <font style="color:rgb(0,0,0);">绕过关键字过滤</font> |
| <font style="color:rgb(0,0,0);">HTML </font><font style="color:rgb(0,0,0);">实体</font> | <font style="color:rgb(0,0,0);">HTML </font><font style="color:rgb(0,0,0);">文本里表示特殊符号</font> | <font style="color:rgb(0,0,0);"><script></font> | <font style="color:rgb(0,0,0);">既能正常显示，也能被绕过</font> |
| <font style="color:rgb(0,0,0);">Base64</font> | <font style="color:rgb(0,0,0);">传输二进制或隐藏明文</font> | <font style="color:rgb(0,0,0);">PHNjcmlwdD4=</font> | <font style="color:rgb(0,0,0);">隐藏</font><font style="color:rgb(0,0,0);"> payload</font><font style="color:rgb(0,0,0);">、读源码</font> |


<font style="color:rgb(0,0,0);">表8   常见编码及其用途</font>

<font style="color:rgb(0,0,0);">遇到“为什么我输入的被过滤了”，第一反应就是换一种编码形式再试。过滤器认的是字面，服务器最终解码后才执行，中间的差异就是绕过空间。</font>

### <font style="color:rgb(0,0,0);">2.8.1 URL 编码（百分号编码 percent-encoding）</font>
**是什么**<font style="color:rgb(0,0,0);">：URL 里只允许一小部分 ASCII 字符出现，其余字符（以及有语法含义的特殊字符）必须写成 </font>`<font style="color:rgb(0,0,0);">%</font>`<font style="color:rgb(0,0,0);"> + 两位十六进制。</font>

| <font style="color:rgb(0,0,0);">字符</font> | <font style="color:rgb(0,0,0);">编码</font> | <font style="color:rgb(0,0,0);">备注</font> |
| --- | --- | --- |
| <font style="color:rgb(0,0,0);">空格</font> | `<font style="color:rgb(0,0,0);">%20</font>` | <font style="color:rgb(0,0,0);">表单提交里也写作 </font>`<font style="color:rgb(0,0,0);">+</font>` |
| `<font style="color:rgb(0,0,0);">'</font>`<font style="color:rgb(0,0,0);"> 单引号</font> | `<font style="color:rgb(0,0,0);">%27</font>` | <font style="color:rgb(0,0,0);">SQL 注入里天天用</font> |
| `<font style="color:rgb(0,0,0);">"</font>`<font style="color:rgb(0,0,0);"> 双引号</font> | `<font style="color:rgb(0,0,0);">%22</font>` |  |
| `<font style="color:rgb(0,0,0);"><</font>`<font style="color:rgb(0,0,0);"> </font>`<font style="color:rgb(0,0,0);">></font>` | `<font style="color:rgb(0,0,0);">%3C</font>`<font style="color:rgb(0,0,0);"> </font>`<font style="color:rgb(0,0,0);">%3E</font>` | <font style="color:rgb(0,0,0);">XSS 标签</font> |
| `<font style="color:rgb(0,0,0);">/</font>` | `<font style="color:rgb(0,0,0);">%2F</font>` |  |
| `<font style="color:rgb(0,0,0);">&</font>` | `<font style="color:rgb(0,0,0);">%26</font>` | <font style="color:rgb(0,0,0);">不编码会被当成参数分隔符</font> |
| `<font style="color:rgb(0,0,0);">#</font>` | `<font style="color:rgb(0,0,0);">%23</font>` | <font style="color:rgb(0,0,0);">不编码会被当锚点截断</font> |
| <font style="color:rgb(0,0,0);">空字节</font> | `<font style="color:rgb(0,0,0);">%00</font>` | <font style="color:rgb(0,0,0);">旧版 PHP 截断字符串用</font> |
| `<font style="color:rgb(0,0,0);">s</font>` | `<font style="color:rgb(0,0,0);">%73</font>` | **注意字母也能编码**<font style="color:rgb(0,0,0);">，这条最容易被忽略</font> |


表9  URL中编码替换

 **在漏洞里的作用：绕过关键字过滤  **

```plain
if (strpos($input, '<script') !== false) die('过滤了');
```

你传 `%3Cscript%3E` 时，过滤器看到的原始字符串是 `%3Cscript%3E`，里面没有 `<`，于是放行；后端 `urldecode` 之后拼进 HTML，就变成了 `<script>`。

****

**常见误区：**上面那行过滤器仍在查 `script` 这个单词，而 `%3Cscript%3E` 里 script 七个字母仍然原样存在，所以照样会被拦。**只编码尖括号不够，必须把单词里的字母也编码：**

```plain
%3C%73cript%3E        ← s 被编码成 %73，过滤器找不到 "script" 这个字面
```

这就是 “编码绕过” 的真正技巧所在：**要隐藏字符串，得编码会触发规则的那几个字符或字母本身**，并非符号。同理 SQL 里绕过 `select` 关键字，可用 `%53ELECT`、`sel%65ct`。



### 2.8.2. HTML 实体（HTML entity）
**是什么**：HTML 里用 `&名字;` 或 `&#数字;` 表示某个字符，避免它被当作标签解析。

| 字符 | 实体 | 十进制 |
| --- | --- | --- |
| `<` | `&lt;` | `&#60;` |
| `>` | `&gt;` | `&#62;` |
| `"` | `&quot;` | `&#34;` |
| `'` | `&#39;` | `&#039;` / `&apos;` |
| `&` | `&amp;` | `&#38;` |


表10  HTML实体 字符

**正常用途**：让 `<` 之类的字符 “正常显示成字符”，不触发标签解析。论坛里有人贴 `<div>` 代码，页面上显示成字面而不是渲染成一个 div，就是实体在起作用 ——**这本身就是最基本的 XSS 防御（HTML 输出编码）**。

### 2.8.3. Base64
**是什么**：把任意字节用 64 个字符（`A-Z a-z 0-9 + /`）表示，末尾用 `=` 补齐。**它不是加密**，只是编码，任何人都能反解。

**在漏洞里的作用**：

+ **隐藏 payload**：某些接口约定 “参数是 Base64 编码的”，过滤器只看外层字符串，不解码就匹配不到关键字。
+ **绕过关键字黑名单**：`SELECT` 被拦，就把整句 SQL Base64 一下；若后端有 `base64_decode($_GET['x'])` 再执行，则直接生效。
+ **读源码 / 后门常见形态**：`eval(base64_decode(...))` 是一句话木马最经典的写法之一，因为代码被编码后，杀毒 / 人工审计肉眼扫不出来。
+ **注意其局限**：因为**谁都能解**，所以对会解码的 WAF 完全无效。它的价值只是 “让不懂解码的人看不见”，属于障眼，不是加密。判它 “不安全” 也别慌，关键看后端拿到后**做了什么**—— 是解码后当数据，还是解码后当代码执行。

| 开发者的错觉 | 实际情况 |
| --- | --- |
| “我用了 Base64，参数看起来是一堆乱码，别人看不懂” | 解码是公开的，攻击者解开、改掉、再编回去，你毫不知情 |
| “我用了 JSON 格式校验，只接受结构化的数据” | JSON 只保证了**结构合法**，不保证**值安全**。`{"id":"任意 SQL"}` 是完全合规的 JSON |
| “WAF 会拦住恶意参数” | WAF 看到的是 `eyJpZCI6IjEgT1IgMT0xIn0=`，里面没有 `OR`、没有 `union`，根本匹配不到 |


表11  开发者觉得自己做了三件事，其实一件用都没有  



 补充一个开发视角的错误认知：很多人 Base64 编码参数是抱着 “**防篡改**” 的目的，这完全是错觉 —— 编码可逆，攻击者解开、改完、再编回去，一模一样。<u>真正防篡改要靠</u>**<u>签名（HMAC）</u>**<u>，不是编码。 </u> 



:::danger
**URL 编码藏语法字符、HTML 实体藏标签字符、Base64 藏整段明文的可读性；三者的共同本质是 “改变字符串的可见形态而不改变其最终语义”，所以它们既是开发者的工具，也是攻击者绕过过滤器的工具 —— 区别只在解码发生在谁手里。  **

:::

****

# **<font style="color:rgb(0,0,0);">3 漏洞的本质只有一句话</font>**
## **<font style="color:rgb(0,0,0);">3.1 把用户输入当成代码执行</font>**
> <font style="color:rgb(0,0,0);">正常情况：你说“我要看第 1 篇文章”，程序去数据库里查第 1 篇。出问题的情况：你说“我要看第 1 篇文章；顺便把整张用户表删掉”，程序居然照做了。</font>
>
> <font style="color:rgb(0,0,0);">区别在哪里？在于程序是把你说的这句话当成“数据”处理，还是当成“指令”处理。所有漏洞的根子都是同一个：该当数据的地方，被当成了指令。</font>
>

:::danger
**「用户输入越狱，从数据区跑进代码区」= 用户提供的内容，被目标系统当作指令来解释执行了。**<font style="color:rgb(0,0,0);"> 之所以是 “本质”，因为 SQL 注入、XSS、命令注入、反序列化、溢出，全都是这一件事的不同皮相；而所有防御，都是在</font>**把那条被抹掉的边界重新画回去**<font style="color:rgb(0,0,0);">。</font>

:::

## **<font style="color:rgb(0,0,0);">3.2 常见的三种“信任错误”</font>**
| **<font style="color:rgb(0,0,0);">错误类型</font>** | **<font style="color:rgb(0,0,0);">具体表现</font>** | **<font style="color:rgb(0,0,0);">通向哪些漏洞</font>** |
| :---: | --- | --- |
| <font style="color:rgb(0,0,0);">把输入当指令</font> | <font style="color:rgb(0,0,0);">直接拼进</font><font style="color:rgb(0,0,0);"> SQL</font><font style="color:rgb(0,0,0);">、命令、文件路径</font> | <font style="color:rgb(0,0,0);">SQL </font><font style="color:rgb(0,0,0);">注入、命令执行、文件包含</font> |
| <font style="color:rgb(0,0,0);">把输入当标记</font> | <font style="color:rgb(0,0,0);">原样输出到</font><font style="color:rgb(0,0,0);"> HTML </font><font style="color:rgb(0,0,0);">或 </font><font style="color:rgb(0,0,0);">JS </font><font style="color:rgb(0,0,0);">里</font> | <font style="color:rgb(0,0,0);">XSS</font> |
| <font style="color:rgb(0,0,0);">把请求当身份</font> | <font style="color:rgb(0,0,0);">只看参数，不校验</font><font style="color:rgb(0,0,0);">“</font><font style="color:rgb(0,0,0);">这东西是不是你的</font><font style="color:rgb(0,0,0);">”</font> | <font style="color:rgb(0,0,0);">越权、</font><font style="color:rgb(0,0,0);">CSRF</font> |


<font style="color:rgb(0,0,0);">表 12  三类信任错误与对应漏洞</font>

## **<font style="color:rgb(0,0,0);">3.3 防御的四把锁</font>**
| **<font style="color:rgb(0,0,0);">手段</font>** | **<font style="color:rgb(0,0,0);">做法</font>** | **<font style="color:rgb(0,0,0);">挡住什么</font>** |
| :---: | --- | --- |
| <font style="color:rgb(0,0,0);">参数化查询</font> | <font style="color:rgb(0,0,0);">预编译语句，把数据固定为数据</font> | <font style="color:rgb(0,0,0);">SQL </font><font style="color:rgb(0,0,0);">注入</font> |
| <font style="color:rgb(0,0,0);">输出编码</font> | <font style="color:rgb(0,0,0);">按输出位置做对应转义</font> | <font style="color:rgb(0,0,0);">XSS</font> |
| <font style="color:rgb(0,0,0);">白名单校验</font> | <font style="color:rgb(0,0,0);">只接受已知合法的值或格式</font> | <font style="color:rgb(0,0,0);">上传、包含、命令执行</font> |
| <font style="color:rgb(0,0,0);">最小权限</font> | <font style="color:rgb(0,0,0);">数据库账号只读、</font><font style="color:rgb(0,0,0);">Web </font><font style="color:rgb(0,0,0);">运行账号低权限</font> | <font style="color:rgb(0,0,0);">脱库之后继续提权</font> |


<font style="color:rgb(0,0,0);">表 13  四类基础防御手段</font>

<font style="color:rgb(0,0,0);">以后打靶时要养成一个</font>**<font style="color:rgb(0,0,0);">习惯</font>**<font style="color:rgb(0,0,0);">：每打通一关，回头问“</font><u><font style="color:rgb(0,0,0);">这一关如果按上面哪把锁来防，我就打不进去了</font></u><font style="color:rgb(0,0,0);">”。</font>



# <font style="color:rgb(0,0,0);">4 kali常用指令</font>
<font style="color:rgb(0,0,0);">touch :创建文档</font>

<font style="color:rgb(0,0,0);">cat: 提取文档中的文字</font>

<font style="color:rgb(0,0,0);">>>：rm覆盖写入（覆盖原文档中的内容）</font>

<img src="https://cdn.nlark.com/yuque/0/2026/png/73997499/1795180337493-e6670bf1-ba72-4125-a9df-69adf7e3b911.png" width="850.6666666666666" height="311" title="" crop="0,0,1,1" id="u5d38c04d" class="ne-image">

<font style="color:rgb(0,0,0);">>：追加写入（只追加不覆盖）</font>

<img src="https://cdn.nlark.com/yuque/0/2026/png/73997499/1795180263888-bd135b1a-1a93-4a77-8baf-2414ee951eb3.png" width="844.6666666666666" height="115" title="" crop="0,0,1,1" id="u5e605358" class="ne-image">

rm -f：删除文件

mkdir package：创建文件夹

rmdir package： 删除文件夹



<img src="https://cdn.nlark.com/yuque/0/2026/png/73997499/1795180928909-f001e693-7b74-496e-bd83-451944c63319.png" width="836.6666666666666" height="378" title="" crop="0,0,1,1" id="u1cb85310" class="ne-image">

bzip2：压缩文件

bunip2： 解压 （ eg: **bunzip2** demo.txt.**bz2 ）**

<img src="https://cdn.nlark.com/yuque/0/2026/png/73997499/1795181245552-330a698c-5fa0-4f2a-a861-7b2813fdf006.png" width="838.6666666666666" height="266" title="" crop="0,0,1,1" id="u771bb53c" class="ne-image">

另一种压缩&解压指令

gzip：压缩 （ eg:gunzip demo.txt ）

gunzip：解压   （ eg：gunzip demo.txt.gz ）

<img src="https://cdn.nlark.com/yuque/0/2026/png/73997499/1795181630024-04053793-cf35-4937-b148-f37ce42b4bc1.png" width="838.6666666666666" height="256" title="" crop="0,0,1,1" id="u678704eb" class="ne-image">



rar：（ eg ：rar a package.rar package ）

rar x ：（rar x package.rar ）



tar jcvf： 既打包、也压缩  （eg： tar -jcvf demo.bz2 package ）

tar -f：解压查看

tar -tf：  只列出压缩包里的文件清单，不解压   （ eg：tar -tf demo.tar ）

tar -zcvf：压缩 （ tar -zcvf demo.tar.gz package ）

查看 tar -zcvf demo.tar.gz





**gzip 快但压得少，bzip2 压得更紧但慢，两者都只管压缩、多文件要靠 tar 打包；RAR 是闭源的一体化归档格式，自带加密分卷修复，日常跨 Windows/Linux 传文件更方便。  **

[链接](about:blank)

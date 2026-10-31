# 流量分析尝试

## 先讲一些基础知识点：
一、一些翻译前高大上词语和概念

1.IP地址：每台设备在网络中的位置

2.DNS:类似于电话簿，把记好的域名翻译为机器的地址(如Baidu.com) DNS（域名系统），手机里的“通讯录”。~~记不住朋友的一长串手机号~~但是记得住“张三”。DNS就是把“张三”变成“手机号”的系统。CTF考点：DNS 隧道（黑客把要偷的数据编码后，当成域名去请求，从而绕过防火墙）。

3.URL:类似门牌号，指明要访问服务器上的哪个文件或者页面店铺的招牌，详细的快递收货地址。不仅有招牌（域名），还要精确到哪条街、哪个房间、找谁（路径和参数）。
· 专业定义：互联网上用来唯一定位资源位置的字符串（协议://域名:端

4.域名 (Domain Name):比如“老兵烧烤”。由一串用点分隔的名字组成的 Internet 上某一台计算机或计算机组的名称。

5.网络协议：类似于快递公司的运输规定，规定数据怎么打包，怎么传输。其中HTTP协议就是明文传输的快递单，谁都可以看；HTTPS是加密的。恶意HTTP（超文本传输协议）：写在纸上的明文信。向（服务器）要文件，服务器把文件寄给你，快递员（TCP）只负责送，但信里面的内容是公开的，谁截获了都能看，用于从万维网（WWW）服务器传输超文本到本地浏览器的传送协议，明文传输，无状态。CTF考点：GET 请求（我要什么）和 POST 请求（我给你什么）。Webshell 大部分通过 POST 传代码

6.与Wireshark相比，Tshark更适合自动化处理大型文件数据和流量.

7.FTP（文件传输协议）:网吧的共享文件夹。有一个专门的软件/通道用来上传或下载大文件，用于在网络上进行文件传输的一套标准协议，使用 TCP，包含控制端口（21）和数据端口（20）。CTF考点：流量分析中直接提取被 FTP 传输的恶意文件（文件导出）。

8.TCP / UDP（传输层协议）:TCP = 打电话~~要建立连接（喂？能听到吗？听到请回答），保证每句话你都能听清，缺一句都不行（可靠）。~~  UDP = 寄明信片。写上地址直接扔进邮筒，不管对方收没收到，速度快，但不保证不丢件（不可靠）。 TCP（传输控制协议）：面向连接的、可靠的、基于字节流的传输层通信协议。UDP（用户数据报协议）：无连接的、不可靠的、基于数据报的传输层协议。CTF考点：流量分析找 Flag，通常都在 TCP 里面（因为可靠，一定会重传）。DNS、视频流通常用 UDP。

9.TCP 三次握手 / 四次挥手:三次握手（建立连接）=A问“在吗？”（SYN） -> B答“在的，你准备好了吗？”（SYN+ACK） -> A说“好了，发车！”（ACK）;  四次挥手（断开连接）：A说“我没数据发了”（FIN） -> B说“知道了”（ACK） -> B处理完手头的事说“我也没数据发了”（FIN） -> A说“好的再见”（ACK）。TCP 建立连接时确保双方收发能力正常的同步过程；断开连接时确保双方数据均已发送完毕的关闭过程。CTF考点：在 Wireshark 看到的 [SYN]、[ACK] 就是这些。


二、“坑点”与易错点

1. 坑点：搞混协议所在的层
   · 易错点：以为 HTTP 就是 TCP。其实 HTTP 只是包裹里的“信纸内容”，TCP 是“信封”。
   · 避坑：在 Wireshark 抓包时，HTTP 流量必定建立在 TCP 协议之上。
2. 坑点：只看 200 OK，忽略 302 / 404
   · 易错点：做 Web 目录爆破流量题时，只盯着 200 找 Flag。
   · 避坑：黑客可能传了个木马，返回的是 302 Found（重定向，隐藏真实路径）；或者爆破时产生的海量 404，突然夹杂一个 200。
3. 坑点：分不清“域名”和“URL”
   · 易错点：把 baidu.com（域名） 和 https://www.baidu.com/s?wd=ctf（URL） 混为一谈。在分析 DNS 隧道题时，黑客藏在域名前缀里（如 aGVsbG8.baidu.com），而不是后面的参数。
4. 坑点：忽略端口号
   · 易错点：看到 HTTP 就以为一定是 80 端口。
   · 避坑：出题人最喜欢把 Web 服务开在奇葩端口（如 8080, 8888）。在 Wireshark 中一定要看 Destination Port。

---


三、专业词汇扫盲（~~Web手~~）

1. Payload（载荷 / 有效载荷）：
   · 释义：货车里真正装的货。在网络里，就是剔除掉协议头部（快递单）后，真正传输的有用数据。比如木马的代码、密码。
2. Port（端口）：
   · 释义：IP 地址是小区地址，端口就是门牌号。一台服务器可以提供很多服务（Web服务80，数据库3306，远程桌面3389）。
3. HOST（主机头）：
   · 释义：在 HTTP 请求头里，告诉你“我要访问这个服务器上的哪个网站”。一台服务器可以挂几百个网站（虚拟主机），全靠 Host 字段区分。
4. Cookie / Session（会话状态）：
   · 释义：HTTP 是无记忆的。Cookie 是服务器发给你的一张“VIP通行证”（存在你浏览器里），下次你来，出示通行证，服务器就知道你是谁。黑客最喜欢偷 Cookie 来越权。
5. HTTPS / SSL / TLS：
   · 释义：HTTP 加了把锁。把明信片装进防偷窥的密码信封里。TLS 就是负责加密的协议。在流量分析中，遇到 HTTPS 都是乱码，除非你有钥匙（证书私钥）。
6. User-Agent (UA)：
   · 释义：浏览器出示的“身份证”。告诉服务器我是用 Chrome 还是手机微信访问的。黑客用脚本写木马时，往往来不及改这个身份证（比如脚本默认 UA 是 python-requests），这就是抓黑客的破绽。




## 一些关于流量分析具体题目类型的扫盲

什么是流量分析？

专业术语：流量分析主要是根据元数据（不是通信内容本身）识别对手活动。
大白话比喻：想象你是一个黑客警察，现在抓到了罪犯（黑客）作案时的监控录像（流量包 pcap 文件）。

· 通信内容：录像里他们具体聊了什么、传了什么文件。
· 元数据（Metadata）：录像带上的标签。比如：谁寄的、寄给谁（IP地址）、用的什么快递公司（协议）、什么时候寄的、包裹有多大（数据包大小）。
· 网络流（Network Flows）：把同一个寄件人寄给同一个收件人的所有包裹，打包成一次“物流记录”。

Wireshark 打开后，它主要分三块，从上到下看：

1. 最上面（数据包列表）：像 Excel 表格。每一行就是一个“包裹”（数据包）。背景色不同代表不同协议（黑色是TCP错误，红色是HTTP等）。
2. 中间（数据包详细信息）：你看中哪一行，点一下，这里就会把包裹层层剥开给你看。从物理层（网线）到应用层（网页内容），像树状图一样。
3. 最下面（数据包字节流）：最底层的十六进制代码（WinHex 里的那种），右侧是对应的 ASCII 乱码或明文。
![实例](https://github.com/Crimson7928/my-image-picgo/blob/main/Wireshark.png)

核心神技：显示过滤器（对应右侧“显示过滤器”目录）

图右侧列出了 protocol、attr、Comparison operator 等，看着吓人，其实这就是在搜索框里写条件。

~~一打开流量包，里面有几万个数据包，全看会眼瞎。~~过滤器就是关键词搜索，把不要的垃圾包隐藏.

最常用的 :

1. http：只看网页传输的数据（CTF里最常考，找flag明文、找上传的后门）。
2. ip.addr == 192.168.1.10：只看这个IP发出去和收进来的包（锁定嫌疑人）。
3. tcp.port == 80：只看80端口（Web服务默认端口）的流量。
4. http.request.method == "POST"：只看 POST 请求（通常用于登录提交、上传文件、黑客传输指令）。
5. dns：只看域名解析请求（如果发现有人一直在请求很长很奇怪的域名，很可能是在用 DNS 隧道偷偷外传数据）。

---

## 常见题型


一、 基础协议与网络层隐写

1. TCP / UDP / IP 流量分析

· 原理：最基础的网络通信协议，题目通常考察从庞杂的底层流量中提取完整的通信数据（如邮件、网页源码、聊天记录）。
· 解法：
  · 右键目标数据包 -> 追踪流 (Follow Stream) -> TCP/UDP Stream。
  · 过滤语法：tcp、udp、ip.addr == x.x.x.x。
  · 注意重组后常包含明文 Flag 或登录密码。

2. ICMP Length 流量分析

· 原理：利用 ICMP（Ping命令）数据包的 Length（长度）字段隐写。出题人将 Flag 的 ASCII 码转换为十进制，伪装成不同长度的 Ping 包。
· 解法：过滤 icmp。查看每个包的 Length 字段（或 data.len），提取长度数值，去掉固定包头大小后，使用 CyberChef 的 From Decimal 还原成字符。

3. DNS 请求域名分析（DNS 隧道）

· 原理：利用 DNS 查询请求作为隐蔽通道外传数据（C2 通信）。将数据（如 Base64 编码后的 Flag）作为域名的子域名，向恶意 DNS 服务器发起请求。
· 解法：过滤 dns。查看 Queries 字段，提取异常长、无规律、包含大量随机字符的域名前缀，拼接后进行 Base64/Hex 解码。

4. RTP 流量分析

· 原理：实时传输协议（Real-time Transport Protocol），常用于音视频流。将 Flag 或摩斯电码隐蔽在音频数据中。
· 解法：电话 -> VoIP 通话，或过滤 rtp，使用 File -> Export Objects -> RTP 将流提取为音频文件（如 .au 或 .wav），导入 Audacity 查看频谱。

5. FTP-DATA 流量分析

· 原理：文件传输协议，考察如何从明文传输的 FTP 流量中还原被下载/上传的文件。
· 解法：过滤 ftp-data。File -> Export Objects -> FTP-DATA，导出数据流，通常是一个压缩包或图片。

---

二、 Web 攻击与渗透溯源

6. 端口扫描分析

· 原理：攻击者使用 Nmap 等工具对目标进行探测。
· 解法：过滤 tcp.flags.syn == 1 and tcp.flags.ack == 0（SYN 扫描特征）。查看 Destination Port 字段，统计大量被探测的端口，发现其中返回 SYN, ACK 的开放端口。

7. Web 目录爆破分析

· 原理：攻击者使用字典（如 Dirsearch）暴力遍历 Web 路径。
· 解法：过滤 http.request.method == "GET"。查看 http.response.code，大量 404 Not Found 中夹杂的 200 OK 或 302 Found 就是成功爆破出的后门路径。

8. SQL 布尔盲注分析

· 原理：页面无回显，攻击者通过 AND 1=1 与 AND 1=2 使页面返回状态（如大小、内容）发生微小变化，逐个字符猜测数据。
· 解法：查看 http 请求的 http.request.uri，分析条件语句。比对响应包大小 frame.len 或 Length，提取 True/False 状态，编写 Python 脚本还原 ASCII。

9. SQL 时间盲注分析

· 原理：页面无任何回显或长度变化，攻击者通过 SLEEP(5) 等函数强制数据库延迟响应，根据响应时间差判断真伪。
· 解法：看数据包的时间戳（frame.time_delta 或 Time）。若两个请求之间的间隔出现异常的 3秒、5秒等固定延迟，说明触发了延时。

---

三、 黑客工具与远控木马（Webshell）

10. 蚁剑流量分析

· 原理：蚁剑（AntSword）默认使用明文或简单的 Base64 编码传输。参数名通常为特定的随机字符串（如 z0、pass）。
· 解法：过滤 http.request.method == "POST"。追踪流，查看请求体中的指令，或找到上传文件的明文数据包。

11. 冰蝎流量分析

· 原理：冰蝎（Behinder）使用 AES 动态密钥加密，流量高度混淆。不同版本特征不同（如 v3 的请求头带有固定的 User-Agent，v4 使用自定义协议）。
· 解法：抓取特征（如 User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) ...），提取请求体中的密文，利用对应的解密脚本或内存中的 Key 进行解密。

12. 哥斯拉流量分析

· 原理：哥斯拉（Godzilla）支持多种加密方式，流量经过混淆。常见特征是响应包开头有随机 md5 前缀，或 Cookie 中带有长串密文。
· 解法：定位极长的 Cookie 值或 POST 参数，去除前缀后，使用哥斯拉的生成脚本进行反序列化解密。

13. MSF 流量分析

· 原理：Metasploit 生成的 Payload（如 Meterpreter、Shell）。
· 解法：过滤 TCP/UDP 流，寻找反弹 Shell 的交互命令（如 whoami、ls）。Meterpreter 流量特征通常在 TCP 载荷中，呈现二进制加密流。

14. RDP 流量分析

· 原理：远程桌面协议，黑客通过 3389 端口控制受害机。
· 解法：分析 RDP 协商过程，若捕获到键盘或剪贴板数据，需提取 TPKT 或 X.224 协议层中的载荷，还原鼠标键盘操作。

---

四、 数据库与存储协议

15. MySQL / Redis / MongoDB 流量分析

· 原理：考察对数据库协议的明文解析。攻击者通过未授权或弱口令连接数据库。
· 解法：过滤对应的协议（如 mysql）。追踪流，查找 SELECT、INSERT 等 SQL 查询语句，Flag 通常在查询结果（Response）中。

16. SMB3 流量分析

· 原理：Windows 网络文件共享系统。
· 解法：过滤 smb2（SMB 3.0 以上）。使用 File -> Export Objects -> SMB 导出被黑客窃取或上传的恶意文档。

17. Ceph 流量分析

· 原理：开源分布式存储系统，协议复杂，涉及 OSD 认证和数据对象上传。
· 解法：提取 Ceph 协议中的消息帧（MSG），定位数据块载荷，还原对象存储中的文件。

---

五、 硬件层与外设隐写

18. 键盘流量分析 (USB HID)

· 原理：捕获 USB 键盘 HID 数据包。Leftover Capture Data 字段包含按键的扫描码（Scan Code）。
· 解法：过滤 usb.transfer_type == 0x01。提取 usb.capdata（通常为 8 字节），根据 USB HID 键码表（如 04 对应 a）编写 Python 脚本转译。

19. 鼠标运动轨迹分析

· 原理：将 Flag（通常是二维码或文字）的坐标转换为鼠标的 X、Y 轴移动数据。
· 解法：过滤 usb.capdata，提取 X/Y 坐标偏移量，累积计算出绝对坐标，使用 matplotlib 绘制散点图或轨迹。

20. USB 流量分析

· 原理：考察泛 USB 设备（如 U 盘复制文件、串口通信）。
· 解法：捕获 URB_BULK 传输包，提取 Leftover Capture Data，重组为文件（如隐藏的图片或压缩包）。

21. EV3 分析

· 原理：乐高机器人通信协议，数据传输携带控制指令或状态反馈。
· 解法：解析特定控制帧，寻找隐藏在指令参数中的十六进制编码。

22. WIFI / WPA 密钥爆破分析

· 原理：提供了 802.11 协议的抓包（.cap），包含 WPA 四次握手包。
· 解法：使用 aircrack-ng 或 hashcat，配合字典对握手包进行离线爆破，密码即为 Flag。

23. 侧信道流量分析

· 原理：不解密数据，利用流量外部特征（如包长、时间间隔）传递信息（如基于包长度的摩斯电码）。
· 解法：提取每个包的 frame.len 或 Time Delta，分析长短规律（点与划），转换成字符。

---

六、 加密与冷门协议

24. TLS / HTTPS 流量分析

· 原理：加密的 Web 流量。如果不解密，只能看到密文。
· 解法：在 Wireshark 的 首选项 -> Protocols -> TLS 中，导入附件提供的 SSLKEYLOGFILE（密钥日志文件），Wireshark 会自动将 HTTPS 流量解密为明文 HTTP 供你分析。

25. DDCTF 流量分析

· 原理：DDCTF 中的经典实战（如大流量包分析、隐蔽信道）。
· 解法：需结合大流量统计（端点、协议分级），有时会用到 tshark 命令行提取特定字段。需具体题目具体分析。


下面将一些才试过的的题实例分析一下。

### BUUCTF[easycap](https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?returnTo=%2Fdashboard%2Fpractice%3Fview%3Dmy&tab=challenges&challenge=2b82defa-37de-48d8-9775-7ce32824db97)

首先下载打开文件得到一个.pcap格式，使用Wireshark打开，过滤只剩下TCP流量包，点击第四行(根据TCP三次握手原理，前三行仅仅是交代联系，使双方都能正常收发信息，SYN->SYN/ACK->ACK,不包含明文，而第四行[info]列出现了[PSH,ACK],PSH代表推送数据，最关键的length变成了1或者更大的数据，说明里面有数据了。但其实在wireshark中，点击任意行都会得到完全相同的TCP信息，追踪流功能能会把属于这个完整链接的所有数据拼接起来)！[如图](https://github.com/Crimson7928/my-image-picgo/blob/main/easycapwireshark.png)

将底部切换为ASSCII码方便看得到flag![flag](https://github.com/Crimson7928/my-image-picgo/blob/main/EASY.png)


### 之前交的WP有NSCCTF里的流量题，这里就不再写


## 日志分析

一、日志分析考什么？

· Web攻击溯源：识别SQL注入、目录扫描、暴力破解、文件上传等行为。
· 漏洞利用链还原：分析反序列化、源码泄漏等攻击的完整步骤。
· 后门与隐蔽通信：寻找Webshell（如蚁剑、冰蝎）和反弹Shell的痕迹。
· 日志伪造与时间线：判断攻击者是否篡改过日志，或利用时区差异设陷阱。

二、一般解法思路：

· 概览与统计：先看日志类型（如Web的access.log或Windows的evtx）。用命令行统计IP访问频率、状态码分布（大量403/404是扫描特征，200是成功访问）。
· 关键词搜索：用grep搜Flag片段、?user=、password、bash -i等敏感词。
· 解码与还原：日志里的攻击载荷常被编码，如URL编码的%2e（.）或%2f（/），需解码后再看。常结合base64等编码，可用CyberChef处理。
· 提取攻击源：锁定可疑IP、端口或文件名。

三、工具推荐

· 命令行组合：在Linux下用grep、awk、sort、uniq -c处理大文件（我装了linux觉得比记事本好用）
· 编辑器（大文件）：Notepad++、VS Code或EmEditor，适合打开几百MB到几GB的大文件。
· 图形化取证工具：Wireshark分析pcap流量包；LogParser/EvtxECmd分析Windows事件日志；CyberChef进行解码（如From Base64、URL Decode）。
· 辅助脚本：用Python编写脚本进行复杂统计或数据清洗。

四、看看题
 [陇剑杯 2021]日志分析：经典Web日志审计，需从日志中找出源码泄漏文件（如www.zip）和phpinfo页面，涉及PHP反序列化。题解：https://www.nssctf.cn/note/set/12764
 [陇剑杯 2021]简单日志分析：考察参数定位、文件路径读取、反弹Shell识别。日志中隐藏了Base64和URL编码的反弹Shell命令，解码后可得IP和端口（192.168.2.197:8888）。题解：https://www.nssctf.cn/note/set/13135


## 恶意行为分析

一、恶意行为分析考什么？

· 攻击画像：识别攻击者IP、使用的工具、攻击时间线。
· 攻击手法：判断攻击类型，如SQL注入、JWT伪造、文件上传、命令执行等。
· 权限与持久化：分析攻击者是否提权（如获取root权限）、是否留下了后门（如Webshell、恶意PAM模块）。
· C2通信：识别恶意软件与命令控制（C2）服务器之间的隐蔽通信，如DNS隧道、心跳包等。
· 数据窃取与破坏：判断攻击者是否篡改配置、创建文件或窃取敏感数据。

二、怎么做？（以“[陇剑杯 2021]jwt”为例，完整展示了从JWT认证到命令执行、植入后门的全过程。）

1. 概览与过滤：将.pcap文件拖入Wireshark，先用http.request.method == "POST"过滤，快速定位可疑的上传或执行请求。
2. 追踪数据流：右键可疑包选择追踪TCP流，在数据流中寻找Cookie、token、command等关键字。
3. 解码与还原：
   · JWT解码：在Cookie中找到token，复制到jwt.io等在线工具，解码出id和username。
   · 命令执行：在command参数中发现whoami、echo ... | base64 -d等命令，解码Base64可得攻击者执行的完整代码。
4. 提取与关联：在数据流中找到写入文件的完整内容（如C代码），结合上下文判断其用途（如编译成恶意PAM模块）。

三、工具推荐

· 流量分析：Wireshark（核心，使用http、tcp.stream eq 0等过滤器）、Tshark（命令行批量）、PCaptor（自动化威胁检测）。
· 解码：CyberChef（在线“瑞士军刀”）、jwt.io（JWT解码）。
· 恶意样本分析：PE Studio（初始分析）、IDA Pro / Ghidra（逆向）、dnSpy（.NET分析）、strings / binwalk（提取隐藏信息）。
· 内存取证：Volatility（配合malfind、lsadump等插件检测恶意代码和凭证）。
· 综合工具包：dzk（集成多种功能）。
· CyberDefenders - Tomcat Takeover：模拟针对Tomcat服务器的完整攻击链分析，练习从扫描到持久化的全过程追踪。

四、例题与实战（附链接）
-问1 (P272)：https://www.nssctf.cn/problem/272
-问2 (P273)：https://www.nssctf.cn/problem/273
-问3 (P274)：https://www.nssctf.cn/problem/274
-问4 (P275)：https://www.nssctf.cn/problem/275
-问5 (P276)：https://www.nssctf.cn/problem/276
-问6 (P277)：https://www.nssctf.cn/problem/277

（· [陇剑杯 2021]jwt（问1-6）：经典JWT认证绕过与后门植入，涉及识别认证方式、提权、上传文件等。）
这里只跑一道试试，题太多了：选择了问1（P272）

### 思路：

首先题目剧透：JWT(json  web token)
观察流量特征![流量特征](https://github.com/Crimson7928/my-image-picgo/blob/main/jwtwireshark.png):
    第一行，Cookie: PHPSESSID=... 这是传统的 Session 认证。
    但是，光标往下移，看第 7 个数据包（POST /identity），这是一个登录请求。
    登录成功后，服务器返回的响应包里，大概率会在 Set-Cookie 里下发一个以 eyJ... 开头的长字符串。这个字符串就是 JWT (JSON Web Token)。
    后面的攻击者也是通过修改这个 JWT 来实现越权或提权的。
    显然，flag是jwt



## TCP&HTTP

一、 TCP & HTTP 流量分析考什么？

1. TCP 层面：找明文（追踪流直接看密码、Flag）、识别端口扫描（大量 SYN 包）、处理分片重组（大文件切成了多个 TCP 包）。
2. HTTP 层面（重灾区）：识别黑客的攻击载荷（SQL注入、Webshell后门）、找上传的文件/木马、身份伪造（越权）、数据泄露。

---

二、 怎么做？（标准四步法）

1. 全局扫视：打开 Wireshark，看 统计 -> 协议分级，确认 HTTP 流量是否占大头。
2. 精准过滤：在过滤器输入 http，重点看带有绿色和黑色的包（正常请求和错误）。
3. 追踪流（核心）：右键任意 HTTP 包 -> 追踪流 -> TCP/HTTP流，很多明文 Flag 和黑客执行的命令都在这里。
4. 导出文件：文件 -> 导出对象 -> HTTP，一键提取网页里传输的图片、压缩包或后门文件。

---

三、 重点解析：请求方式、请求头、请求体

把一次 HTTP 请求想象成寄快递：

· 请求方式 = 快递类型（是退货、还是寄件）。
· 请求头 = 快递单上的信息（寄件人、电话、身份证）。
· 请求体 = 包裹里实际装的东西（你的货物）。

1. 请求方式 (Request Method)

· GET：要数据。参数直接拼在 URL 后面（如 ?id=1）。*特点：明文、长度有限、不安全。*
· POST：交数据。参数放在“请求体”里（如登录账号密码、上传文件）。*特点：隐蔽、无长度限制。CTF 中 90% 的 Webshell 和注入都在 POST 里。*
· 其他：PUT（上传）、DELETE（删除）、HEAD（只查响应头）。

2. 请求头 (Request Headers) —— 黑客最容易做手脚的地方

在 Wireshark 里，点开一个 HTTP 包，展开 Hypertext Transfer Protocol，你会看到下面这些字段：

· Host：目标网站域名（Host: www.xxx.com）。
· User-Agent (UA)：客户端身份。如果是浏览器，是一大串，如果是黑客工具（如 sqlmap、Python 脚本），可能极其简短或带有特征。考点：识别攻击工具。
· Cookie：身份凭证。考点：黑客偷了管理员 Cookie 伪造登录，或者修改 JWT（如你刚做的题）。
· Referer：从哪个页面跳过来的。考点：绕过某些安全限制（要求必须从后台跳转）。
· X-Forwarded-For (XFF)：伪造真实 IP。考点：黑客伪造内网 IP 绕过白名单。
· Content-Type：告诉服务器我发的是什么数据（见请求体）。

3. 请求体 (Request Body / Payload)

*只有 POST 请求才有请求体。*在 Wireshark 的追踪流里，能看到空行下面的内容就是 Body。

· 表单格式：Content-Type: application/x-www-form-urlencoded。格式类似 username=admin&password=123。常见于弱口令爆破。
· 文件上传：Content-Type: multipart/form-data。里面包含二进制文件流。考点：直接去里面提取木马文件（如 .php 或 .jsp）。
· JSON 格式：Content-Type: application/json。格式类似 {"user":"admin"}。API 接口常用，常见于反序列化漏洞。
· 纯文本：黑客用工具直接连命令执行（如 system("whoami")），或者 SQL 注入的盲注语句就在里面。

---

 四、 好用的工具

· Wireshark / Tshark：主力工具，Tshark 适合写脚本批量提取 HTTP 包。
· CyberChef：神器。遇到***请求体里一堆 URL 编码（%xx）或者 Base64***，直接扔进去一键还原。
· HackBar（浏览器插件）：如果题目给你的是一个在线靶机环境，用它改请求头和 POST 数据非常方便。
· Burp Suite：抓包改包祖师爷（CTF Web 手必备，但不适用离线 pcap 文件）。

---

来个题目看看：
### [BUUCTF]数据包中的线索
[题](https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?returnTo=%2Fdashboard%2Fpractice%3Fview%3Dmy&tab=challenges&challenge=0f93dc12-d8a4-41e8-9642-f426d62da924)

思路：再wireshark中导出所有HTTP文件，发现有特殊文件。！[特殊文件](https://github.com/Crimson7928/my-image-picgo/blob/main/file_found.png),记事本中打开后，拉到末尾发现base64标志性等号![记事本中的文本](https://github.com/Crimson7928/my-image-picgo/blob/main/big_base64.png)，大胆猜测整个文本都是base64加密的文件，于是使用cyberchef再次进行处理，结果发现是base64中隐藏了一份jpg格式的图片![cyberchef](https://github.com/Crimson7928/my-image-picgo/blob/main/cyberchef_found.png),图片渲染打开后发现flag![flag](https://github.com/Crimson7928/my-image-picgo/blob/main/flag_found.png)


## FTP协议

一、 FTP 流量分析考什么？

· 明文账号密码：FTP 默认是明文传输的，抓包能直接看到黑客或者用户登录的账号密码。
· 文件提取：这是最核心的考点。把流量包里传输的图片、压缩包、木马文件原封不动地“偷”出来。
· 匿名登录：识别攻击者是否使用了 anonymous（匿名）账号登录，这是未授权访问的特征。

1. FTP 协议：带前台的快递驿站。你找前台（控制端口）说要寄件，前台登记完，后厨（数据端口）专门负责把包裹送出去。基于 TCP 的应用层协议。它最大的特点是双端口：21 端口用于控制连接（输入账号密码、发指令），20 端口（或随机端口）用于数据连接（传文件）。
· 坑点：在 Wireshark 里追踪 TCP 流时，经常会发现控制流和数据流是分开了。所以千万别只盯着 21 端口看，真正的文件在数据包里！

2. 主动模式 (PORT) vs 被动模式 (PASV)
· 主动模式：你去驿站寄件，驿站说：“我不关门，你自己把包裹塞进来”。客户端开个随机端口，服务器主动连过去
· 被动模式：驿站说：“我关门了，你去旁边那个小窗口把包裹塞进去”。服务器开个随机端口，客户端连过去。（现代网络有防火墙，所以基本都用被动模式）
· 避坑点：在 Wireshark 里看到服务器返回 227 Entering Passive Mode，说明接下来服务器会开个随机端口传数据，不用慌，这是正常的。

---

三、 怎么做？

遇到 FTP 题，直接按这个流程走，一抓一个准：

1. 抓登录凭证（找账号密码）

· 过滤器输入：ftp
· 看 Info 列，寻找包含 USER（用户名）和 PASS（密码）的数据包，明晃晃的明文。

2. 提取传输的文件（核心目的）

· 方法A（最省事）：点击菜单栏 “文件” -> “导出对象” -> “FTP-DATA”。列表里会显示所有传输过的文件，选中一键保存。
· 方法B（追踪流）：过滤器输入 ftp-data，右键任意包 -> 追踪 TCP 流。左边红色是发出去的，右边蓝色是收到的文件。
· 如果是图片/压缩包，下面的“显示数据”选择 原始数据 (Raw)，然后点 “另存为”，存成对应的格式即可。

3. 应对变种（FTP over TLS）
如果端口是 21，但里面的内容全是乱码，说明加密了（FTPS）。这时候需要去 首选项 -> Protocols -> FTP 里配置解密秘钥。

---

四、 好用的工具

· Wireshark：绝对主力，用自带的“导出对象”功能最爽。
· Tshark：如果包特别大，可以用命令 tshark -r 包.pcapng --export-objects ftp-data,./extract_dir 瞬间把文件全抽出来。
· CyberChef：提取出的文件如果被损坏或者藏了东西，扔进去转码。

---

五、练习题

[被偷走的文件](https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?tab=challenges&solved=false&challenge=b7814ebb-eb81-4671-b771-578c19bd9309)
打开下载附件格式是流量包，用wireshark打开，结合题目大概是有人使用FTP偷偷传了文件。![寻找异常](https://github.com/Crimson7928/my-image-picgo/blob/main/documentwireshark.png)

在搜索栏过滤ftp,观察剩余流量中是否隐藏文件![发现明显flag](https://github.com/Crimson7928/my-image-picgo/blob/main/flag_txt.png),导出文件，尝试解压发现需要密码，格式为rar，尝试在ARCHPR中爆破，跑出密码解压即可。
PS：
1. 区分 FTP 的“聊天记录”（RETR flag.rar）和真正的“文件本体”（FTP Data）。
2. Wireshark 的 文件 -> 导出对象 -> FTP-DATA。
3. 手动救援：当文件被切碎或提取失败时，用 tcp.port == 14438 过滤，并通过“追踪流 -> 原始数据”来还原文件



## Webshell流量分析

一、 WebShell 流量分析考什么？

核心本质：黑客通过上传漏洞（如文件上传、RCE）在服务器上留了一个“后门（木马）”。之后黑客用客户端工具（菜刀、蚁剑等）连接这个后门，进行盗取数据、执行系统命令等操作。
考点：在流量包中识别出黑客用了什么工具、连了哪个木马文件、执行了什么指令、偷了哪些文件。

---

二、 攻击工具

1. 中国菜刀 (Caidao)

· 大嗓门。在闹市区（公网）直接喊话，完全不加密。
· 原理：早期工具，流量是明文传输的（或者仅仅是简单的 URL 编码/Base64 编码）。
· 流量特征：
  · ***POST 请求体里必有 z0= 或 z1= 这样的参数。***
  · 如果抓包看到：z0=@eval($_POST['pass']); 或者 z0=system('whoami');，那就是它了。

2. 蚁剑 (AntSword)

· 中国菜刀的升级版，戴了个简易面具。
· 原理：流量大部分依然明文（通过 base64 编码），但为了绕过 WAF，会对代码进行简单的变形。
· 流量特征：
  · ***POST 请求体参数通常是 @ini_set("display_errors","0");... 等 PHP 代码。***
  · User-Agent 带有 antSword 字样（老版本）。

3. 冰蝎 (Behinder)

· 带密码本的秘密特工。每次说话都加密。
· 原理：使用 AES 动态密钥加密。在第一次发包时会通过协商获取一个密钥，后续所有命令都在请求体中加密传输，因此内容全是乱码。
· 流量特征：
  · ***固定 User-Agent：User-Agent: Mozilla/5.0... 后面可能带有一大串特定字符，或者干脆是个空 UA。***
  · Accept 字段异常：***请求头的 Accept 往往非常短，如 Accept: text/html, application/xhtml+xml。***
  · 包里有一堆超长且无规律的二进制乱码。

4. 哥斯拉 (Godzilla)

· 精通易容术的忍者。
· 原理：支持多种加密方式（异或、AES、Base64 嵌套），它把整个请求体和返回体都做了深度混淆。
· 流量特征：
  · Cookie 特征：请求 Cookie 里带有 ;（注意，通常状态保持的 Cookie 是 key=value，哥斯拉经常在 Cookie 最后多加一个分号，或者干脆用无规律的键值对[^1]）。
  · 响应包特征：返回的数据包开头常常带有随机的 md5字符串作为特征，然后再跟加密数据。

---

三、 怎么做？

遇到 WebShell 流量题，按这个套路：

1. 锁定嫌疑包：在 Wireshark 过滤栏输入 http.request.method == "POST"。WebShell 交互几乎全部是 POST。
2. 识别工具：看请求的 URL（通常是一个 .php / .jsp 文件），看 User-Agent，看请求参数名（是 z0 还是密文）。判断它是四大工具里的哪一个。
3. 追踪流看明文：右键包 -> 追踪 TCP 流。
   · 如果是菜刀/蚁剑，直接往下拉，明文命令（如 ls、cat flag）和返回结果全在里面。
   · 如果是冰蝎/哥斯拉，追踪流里是一堆乱码。需要题目给的解密脚本，或者找流量特征（比如文件上传的流量包，文件头 PK 或者 GIF 会暴露未加密的部分）。
4. 找上传的文件：黑客经常用命令执行写文件，或者通过 upload 功能传文件。看请求体里有没有大段的字节流，提取出来。

---

四、 好用工具

· Wireshark：过滤 http，追踪流。这是核心。
· CyberChef：遇到有规律的乱码，扔进去试试 Base64 或 XOR。
· D盾 (D_Safe)：做的是“后门查杀”题（给一个网站源码目录），直接把整个文件夹扔进 D盾 里扫描，一秒揪出隐藏的木马。

---

五、 例题实战


[BUUCTF] 菜刀666
考点：最基础的明文流量。学会过滤 POST，追踪流找 z1 参数里的明文命令。

1.用wireshark打开，发现全是http协议，没有tls加密，直接输入frame contains "flag"追踪搜索结果的数据包，发现FFD8明显的jpg魔数头。

2.将jpg的16进制数据复制，使用010editor保存为jpg文件，修改后缀可以看到图片内容：Th1s_1s_p4sswd_!!!

3.使用工具foremost输入指令：foremost '/home/kali/Desktop/666666.pcapng' 得到压缩包，输入得到的密码即可得到flag。


用wireshark打开，发现全是http协议，没有tls加密，直接输入frame contains "flag"追踪搜索结果的数据包，发现FFD8明显的jpg魔数头。

· 原理剖析：
  · 为什么要搜 frame contains "flag"？ 在CTF流量题中，出题人往往会留下关于 flag 的线索。直接在全局数据帧中搜索 "flag" 这个字符串，可以跳过繁琐的 HTTP 流分析，瞬间锁定最有价值的包。
  · 为什么发现 FFD8 是关键？ FFD8 是 JPEG 图片的十六进制文件头（Magic Number）。在流量包里发现它，意味着这里藏着一张完整的图片。
· 你之前踩的坑对比：
  · 你之前是去追踪蚁剑的 POST 参数（z1, z2），然后在 ASCII 模式下另存为，导致二进制数据丢失，图片变成了纯白。官方解法直接看数据帧的原始 Hex 数据，绝不会丢失字节。

🌟 步骤二：Hex 提取，破解图片密码

题解原话：将jpg的16进制数据复制，使用010editor保存为jpg文件，修改后缀可以看到图片内容：Th1s_1s_p4sswd_!!!

· 原理剖析：
  · 如何正确复制？ 在 Wireshark 找到 FFD8 的数据包，在底部的 Packet bytes（数据包字节流）面板中，右键选择 “复制 (Copy)” -> “...as a Hex Dump” (作为十六进制转储)。
  · 将这一大串 Hex 数据粘贴到 010 Editor 的 Hex 视图里，然后保存为 .jpg 文件。因为复制的是纯正的十六进制（如 FF D8 FF E0...），没有任何编码转换（如 Base64 或 ASCII 乱码），所以图片 100% 完整。
  · 打开完整的图片，上面赫然写着密码：Th1s_1s_p4sswd_!!!。
· 你的收获：以后在流量里看到 FFD8，不要直接去追踪流里复制文字，一定要看 Hex 数据流，或者在 Wireshark 里“导出分组字节流(Export Packet Bytes)”。

🌟 步骤三：Foremost 雕刻，直接提取压缩包

题解原话：使用工具foremost输入指令：foremost '/home/kali/Desktop/666666.pcapng' 得到压缩包，输入得到的密码即可得到flag。用wireshark打开，发现全是http协议，没有tls加密，直接输入frame contains "flag"追踪搜索结果的数据包，发现FFD8明显的jpg魔数头。

· 原理剖析：
  · 为什么要搜 frame contains "flag"？ 在CTF流量题中，出题人往往会留下关于 flag 的线索。直接在全局数据帧中搜索 "flag" 这个字符串，可以跳过繁琐的 HTTP 流分析，瞬间锁定最有价值的包。
  · 为什么发现 FFD8 是关键？ FFD8 是 JPEG 图片的十六进制文件头（Magic Number）。在流量包里发现它，意味着这里藏着一张完整的图片。
· 你之前踩的坑对比：
  · 你之前是去追踪蚁剑的 POST 参数（z1, z2），然后在 ASCII 模式下另存为，导致二进制数据丢失，图片变成了纯白。官方解法直接看数据帧的原始 Hex 数据，绝不会丢失字节。

🌟 步骤二：Hex 提取，破解图片密码

题解原话：将jpg的16进制数据复制，使用010editor保存为jpg文件，修改后缀可以看到图片内容：Th1s_1s_p4sswd_!!!

· 原理剖析：
  · 如何正确复制？ 在 Wireshark 找到 FFD8 的数据包，在底部的 Packet bytes（数据包字节流）面板中，右键选择 “复制 (Copy)” -> “...as a Hex Dump” (作为十六进制转储)。
  · 将这一大串 Hex 数据粘贴到 010 Editor 的 Hex 视图里，然后保存为 .jpg 文件。因为复制的是纯正的十六进制（如 FF D8 FF E0...），没有任何编码转换（如 Base64 或 ASCII 乱码），所以图片 100% 完整。
  · 打开完整的图片，上面赫然写着密码：Th1s_1s_p4sswd_!!!。
· 你的收获：以后在流量里看到 FFD8，不要直接去追踪流里复制文字，一定要看 Hex 数据流，或者在 Wireshark 里“导出分组字节流(Export Packet Bytes)”。

🌟 步骤三：Foremost 雕刻，直接提取压缩包

题解原话：使用工具foremost输入指令：foremost '/home/kali/Desktop/666666.pcapng' 得到压缩包，输入得到的密码即可得到flag。



## SQL注入流量分析

一、考什么

核心能力是从网络流量（.pcapng）或Web日志（access.log）中识别SQL注入攻击的痕迹，并还原攻击者拖取的数据。

二、怎么考

常见三种注入类型的流量特征：

· 时间盲注：请求参数含 sleep(3)、if(...,sleep(3),...) 等。通过Wireshark过滤 http.time >= 3 直接筛选出延时3秒以上的成功包。
· 布尔盲注：大量结构相似的GET/POST请求，参数如 substr((select flag...),1,1)='f'。判断条件为真/假时，服务器返回包大小或状态码有微小差异（如704 vs 720字节）。
· UNION注入：参数中出现 union select ...，返回包直接带出查询结果。

三、怎么解

1. 定位注入流量：Wireshark过滤 http 或 http.request，按包大小/时间排序，找到异常参数。
2. 解码：右键 → 追踪TCP/HTTP流，复制Payload进行URL解码（常见双层编码，需连续解码两次）。
3. 还原数据：
   · 手动：时间盲注看http.time>=3的包；布尔盲注看响应包大小差异。
   · 脚本：从日志或导出的请求列表中，用正则提取每次爆破的字符位置和猜测字符，按位置排序后拼出flag。

三、高效工具与脚本：

Wireshark / tshark：图形化过滤 http.time >= 3 或 http.response.code == 200；命令行批量导出URL：

```bash
tshark -r challenge.pcapng -Y "http.request" -T fields -e http.request.full_uri > urls.txt
```



Python脚本（以陇剑杯问3为例，从access.log提取布尔盲注结果）：

```python
import re, urllib.parse
arr = []
with open("access.log", "r") as f:
    pattern = r'sqli\.flag\),(\d+).+\'(.+)\''
    for line in f:
        m = re.search(pattern, line)
        if m:
            arr.append(m.group(1, 2))
for i in range(len(arr) - 1):
    if arr[i][0] != arr[i + 1][0]:  # 位置变化时输出上一位置的字符
        char = urllib.parse.unquote(arr[i][1]) if '%' in arr[i][1] else arr[i][1]
        print(char, end='')
```

时间盲注可先用 http.time >= 3 筛出成功包，再用正则提取ASCII值。

Hackbar（Web题辅助，非流量题主力）：浏览器F12打开，用于快速构造/修改URL和POST参数、测试注入点、URL编解码等。

四、实战例题链接

陇剑杯问3的flag为 flag{deddcd67-bcfd-487e-b940-1217e668c7db}。（刚刚已经解释了答题思路，就不赘述了）


## USB流量分析

一、考什么

从USB协议流量中还原键盘敲击内容或鼠标移动轨迹，提取隐藏的flag。

二、怎么考

· 键盘流量：数据在 usb.capdata / usbhid.data 域，长度通常为8字节。第三个字节是键码，需查HID键盘映射表（如 0x04=a，0x2a=Backspace）。
· 鼠标流量：数据长度通常为4字节：[按键, dx, dy, 滚轮]。按键 0x01 左键、0x02 右键；dx/dy 为相对位移，累加后可绘制轨迹。实际题目中也有6/7/8字节变体，需去掉尾部无用字节。

三、怎么解

1. 分离流量：Wireshark过滤 usb.src == "2.8.1" 等设备地址，分别导出键盘/鼠标流量。
2. 提取HID数据（tshark）：
   ```bash
   tshark -r usb.pcapng -T fields -e usb.capdata > usbdata.txt
   ```
   高版本Wireshark若显示HID Data而非Leftover Capture Data，改用 -e usbhid.data。
3. 解码：
   · 键盘：取每行第3字节，查HID映射表转字符。注意Caps Lock、Shift、Backspace的影响。
   · 鼠标：累加dx/dy得到坐标序列，用gnuplot或PIL绘制轨迹图。

四、高效工具与脚本

· 键盘解析工具：ctf-usb-keyboard-parser（GitHub）。一键运行：
  ```bash
  tshark -r usb.pcap -Y 'usb.capdata && usb.data_len == 8' -T fields -e usb.capdata | sed 's/../:&/g2' > keystrokes.txt
  python3 usbkeyboard.py keystrokes.txt
  ```
  
· 鼠标轨迹可视化：USB-Mouse-Pcap-Visualizer（WangYihang），直接输入pcap生成鼠标移动/拖拽轨迹图。
· Linux鼠标脚本：usbMiceDataHacker.py，适用于4/8字节流量（6/7字节需先裁剪为4字节）。

五、实战例题链接

· 2022 CISCN ez_usb：大概思路就是：键盘+鼠标综合题，键盘输入得到RAR压缩包，鼠标流量得到解压密码。



~~学的我嘴唇发紫~~



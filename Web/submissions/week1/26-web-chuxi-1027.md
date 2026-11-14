2026.10.27修改

# ***<u>壹.预备知识</u>***

## ***一.基本工具使用与安装***

#### 1.**[[SWPUCTF 2021新生赛]gift_F12](https://www.nssctf.cn/problem/382)**

**打开之后进入网页**

**点击F12打开浏览器开发者模式**

![屏幕截图 2026-10-25 221746](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-25 221746.png>)

**在开发者模式选项中找到元素**

**按下crtl +F 查找flag**

![屏幕截图 2026-10-25 221808](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-25 221808.png>)
**再根据题目意思修改即可**

![屏幕截图 2026-10-25 221902](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-25 221902.png>)

**知识点：浏览器开发者工具（DevTools）**

**1 常用面板**

- **Elements（元素）**：当前页面渲染后的 DOM 结构
- **Console（控制台）**：执行 JS、看报错
- **Sources（源代码）**：调试 JS、看页面加载了哪些文件
- **Network（网络）**：记录每一次请求，看接口、参数、响应头和 Cookie
- **Application（应用）**：管理 Cookie、LocalStorage、SessionStorage

**2 Ctrl+F 搜的是渲染后的 DOM，不是原始源码**

- `Ctrl + U` 看到的是服务器最初返回的 HTML，此时 JS 还没执行
- Elements 里看到的是 JS 执行完之后的真实结构
- 两边都要看：源码里搜不到，不代表页面里没有





#### 2.**[[qsnctf-NO.0902]robots.txt](https://www.qsnctf.com/#/main/driving-range?page=1&category=&difficulty=&keyword=robots.txt)**

**在电脑终端下载python环境并安装dirsearch**

**终端中使用cd找到dirsearch文件所在目录**

**再用dirsearch扫描URL**

![屏幕截图 2026-10-24 155017](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-24 155017.png>)

**发现一条不希望网络爬虫寻找到的robots.txt**

**将robot.txt插入网址后面向服务器发送get请求**



![屏幕截图 2026-10-24 155130](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-24 155130.png>)



**得到用户名和密码**

![屏幕截图 2026-10-24 155259](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-24 155259.png>)

**前往登陆界面输入即可得到flag**



![屏幕截图 2026-10-24 155319](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-24 155319.png>)

**知识点：robots.txt 与目录扫描**

**1 robots.txt 是"给爬虫看的说明书"**

- 放在站点根目录，访问方式：`http://目标域名/robots.txt`。
- 常见语法：
  - `User-agent: *`：对所有爬虫生效
  - `Disallow: /admin/`：不希望被爬取的路径
  - `Allow:`：在 Disallow 范围内开例外
  - `Sitemap:`：站点地图位置

**2 dirsearch 是怎么工作的**

- 原理：拿字典里的路径逐个拼到目标后面请求，再按返回的状态码判断"存不存在"。
- 常用命令：`python3 dirsearch.py -u http://目标/ -e php,html,js,txt`
- 常用参数：`-u` 目标、`-e` 扩展名、`-w` 自定义字典、`-t` 线程数、`--delay` 延迟、`-x` 排除状态码、`--random-agent` 随机 UA。

**3 状态码怎么看**

- `200`：存在
- `301/302`：路径存在，只是跳转（如 `/admin` → `/admin/`）
- `403`：存在但禁止访问，往往很有价值
- `404`：不存在
- `500`：可能存在，但代码报错
- `429`：请求太快被限速，需要降速





#### 3.**[[MoeCTF 2021\]Web安全入门指北—GET](https://www.nssctf.cn/problem/3412)**

**代码提到向服务器发送get请求moe=flag**



![屏幕截图 2026-10-27 215624](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-27 215624.png>)
**在网址后加上/?moe=flag**

![屏幕截图 2026-10-27 215648](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-27 215648.png>)
**跳转后得到flag**

![屏幕截图 2026-10-27 215655](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-27 215655.png>)

**知识点：GET 请求与 URL 传参**

**1 URL 的组成**

- 形如：`http://域名:端口/路径?参数1=值1&参数2=值2#锚点`
- `?` 之后是查询字符串，也就是 GET 参数；多个参数用 `&` 连接
- `#` 之后是锚点，**不会发送给服务器**
- 特殊字符要做 URL 编码：空格是 `%20`，`&` 是 `%26`，中文按 UTF-8 编码

**2 GET 与 POST 的区别**

- 参数位置：GET 在 URL 里，POST 在请求体（body）里

- 是否可见：GET 明文显示在地址栏，还会进日志和历史记录；POST 不会

  长度限制：GET 受浏览器和服务器限制（常见 2~8KB），POST 理论无上限但受服务器配置约束

- 幂等性：GET 幂等，可缓存、可收藏；POST 一般不幂等

**3 后端如何接住这个参数**

- `$_GET['moe']` 取 URL 参数，`$_POST['moe']` 取 body 参数
- 题目代码是 `if ($_GET['moe'] === 'flag')`，用 `?moe=flag` 就能过
- 注意 `==`（弱比较，会做类型转换）和 `===`（强比较）的区别

## ***二.linux操作系统***

#### [[pkwctf2026-Linux之旅]](https://www.ctfplus.cn/problem-detail/2105939188284133376/description)
**按照右侧要求依次输入linux相关指令**

![屏幕截图 2026-10-26 130427](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 130427.png>)

![屏幕截图 2026-10-26 130435](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 130435.png>)

![屏幕截图 2026-10-26 130535](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 130535.png>)

![屏幕截图 2026-10-26 130615](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 130615.png>)

![屏幕截图 2026-10-26 130741](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 130741.png>)

![屏幕截图 2026-10-26 130825](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-10-26%20130825.png>)

![屏幕截图 2026-10-26 130849](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 130849.png>)

![屏幕截图 2026-10-26 131005](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 131005.png>)

![屏幕截图 2026-10-26 131153](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 131153.png>)

![屏幕截图 2026-10-26 131322](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 131322.png>)

![屏幕截图(263)](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图(263).png>)

![屏幕截图 2026-10-26 132020](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 132020.png>)

![屏幕截图 2026-10-26 132025](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 132025.png>)

![屏幕截图 2026-10-26 132035](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 132035.png>)

**知识点：Linux 常用命令**

**1  目录与路径**

- 关键目录：`/etc`（配置）、`/home`（普通用户）、`/root`（root 家目录）、`/tmp`（临时目录，人人可写）、`/var/log`（日志）、`/proc`（进程与内核信息）
- `.` 当前目录、`..` 上级目录、`~` 家目录、`-` 上一次所在目录
- 提示符 `$` 是普通用户，`#` 是 root

**2  最常用的一批命令**

- 目录：`pwd`、`ls -al`、`cd`、`mkdir`、`cp`、`mv`、`rm -rf`
- 看文件：`cat`、`less`、`head`、`tail -f`、`file`、`strings`
- 查找：`find / -name "*.txt"`、`grep -rn "flag" /var/www`、`which`
- 权限：`chmod`、`chown`、`sudo`
- 进程：`ps aux`、`top`、`kill`
- 网络：`ss -tlnp`、`curl`、`wget`、`ping`、`nc`、`ssh`、`scp`
- 其它：`history`、`man`、`whoami`、`id`

**3  `ls -l` 那一行怎么读**

- 例如 `-rwxr-xr--`：第一位是文件类型（`-` 文件、`d` 目录、`l` 链接），后面三组依次是属主 u、属组 g、其他人 o 的权限
- `r`=4、`w`=2、`x`=1，所以 `755` 就是 `rwxr-xr-x`，`644` 就是 `rw-r--r--`。`
- SUID（显示为 `rws`）表示以属主身份执行，是提权的重点

**4 管道与重定向**

- `|` 把上一条命令的输出交给下一条：`ps aux | grep nginx`
- `>` 覆盖写入、`>>` 追加、`2>&1` 合并错误输出、`2>/dev/null` 丢弃报错



## ***三.HTTP请求与响应***

#### 1.**[[0xGame2025\]Http的真理!我已解明](https://www.ctfplus.cn/problem-detail/1975492176561311744/description)**

![屏幕截图 2026-10-26 192013](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 192013.png>)

**直接在浏览器网址后加上/?hello=web**

**然后拦截进入burp**

**发送到repeater如下**

![](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 194406.png>)

**按照response修改get请求为post请求**

![屏幕截图 2026-10-26 200818](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 200818.png>)

**在http请求设置cookie**

![屏幕截图 2026-10-26 200826](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 200826.png>)

**在http请求设置用户代理user-agent为ios浏览器**

![屏幕截图 2026-10-26 201150](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 201150.png>)

**设置来源为米哈游官网**

![屏幕截图 2026-10-26 202408](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 202408.png>)



**设置代理为clash**

![屏幕截图 2026-10-26 202440](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 202440.png>)

**最后就得到了flag**

**知识点：HTTP 报文与可伪造的请求头**

**1 一份完整的 HTTP 请求**

- 请求行：`POST /api/login HTTP/1.1`（方法 + 路径 + 协议版本）
- 请求头：`Host`、`User-Agent`、`Cookie`、`Referer`、`Content-Type`、`Content-Length` ……
- 空行：请求头与请求体的分隔
- 请求体：POST 的参数写在这里

**2 响应报文**

- 状态行：`HTTP/1.1 200 OK`
- 响应头：`Server`、`Date`、`Set-Cookie`、`Content-Type`、`Location` ……
- 响应体：页面内容，题目提示基本都在这里
- 状态码：`200` 成功、`301/302` 重定向、`400` 格式错误、`401` 未认证、`403` 无权限、`404` 不存在、`500` 服务端错误

**3 题目每一项**

- `Cookie`：会话凭证，明文存在客户端，随手可改
- `User-Agent`：客户端身份
- `Referer`：从哪个页面跳过来的，最常被用来伪造来源。
- `Origin`：跨域请求来源，只含协议+域名+端口，不含路径，用于 CORS 校验
- `X-Forwarded-For`：真实客户端 IP，常被用来绕过 IP 白名单
- `Host`：目标主机名，对应 Host 头注入
- `Date`：报文生成时间

**4 Burp 的四个常用模块**

- **Proxy**：拦截和转发流量，HTTP history 可回看
- **Repeater**：手工改包、反复重放
- **Intruder**：自动化爆破
- **Decoder**：Base64、URL、Hex 编解码





#### 2.**[[SWPUCTF 2024 秋季新生赛]http标头](https://www.nssctf.cn/problem/5942)**
**在burp拦截网页**

![屏幕截图 2026-10-26 221930](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 221930.png>)
**观察日期标准格式&修改日期Date**

![屏幕截图 2026-10-26 222426](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 222426.png>)

![屏幕截图 2026-10-26 222512](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 222512.png>)
**设置 cookie为BlackMonkey    曲奇**

![屏幕截图 2026-10-26 222904](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 222904.png>)
**设置来源referer为Wukong**

![屏幕截图 2026-10-26 223256](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 223256.png>)
**在response raw中复制flag**

![屏幕截图 2026-10-26 223501](<https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-10-26 223501.png>)

**知识点：Date 头与响应报文分析**

**1 Date 头的标准格式（RFC 1123）**

- 形如：`Wed, 21 Oct 2015 07:28:00 GMT`
- 按规范源服务器必须发送 `Date` 头

**2 读响应要看的几个地方**

- 状态行：200 还是 302？302 记得跟 `Location` 走
- 响应头：`Set-Cookie` 给了什么凭证、`Server` 是否泄露版本
- 响应体：回显、提示、注释

2026.11.15修改

PHP语言

 函数安全

[[SWPUCTF 2022 新生赛]奇妙的MD5](https://www.nssctf.cn/problem/2638)

**进题是个输入框，让填一个"奇妙的字符串"**

![屏幕截图 2026-11-15 151441](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 151441.png)

**抓一下包能翻到出题人留的 hint：`select * from 'admin' where password=md5($pass,true)`**

**了解到这串代码**

![屏幕截图 2026-11-15 153057](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 153057.png)

**重点在第二个参数 `true`。`md5($str,true)` 返回的是 16 字节原始二进制，`ffifdyop` 的原始 md5 开头正好是 `'or'6`，拼进单引号包住的 SQL 里就成了 `password=''or'6...'`，条件恒真，登录直接过**

**进了第二关，源码里换成两个参数的比较：值不能相等，md5 却要相等**

![屏幕截图 2026-11-15 153355](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 153355.png)

要求两个不同字符串、哈希松散相等

当`0e` 开头的数字，`==` 比较时都会转成 0

![屏幕截图 2026-11-15 154222](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 154222.png)

![屏幕截图 2026-11-15 154244](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 154244.png)

**输入后访问 `/f1na11y.php`**

![屏幕截图 2026-11-15 154800](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 154800.png)

**这一关换成了强比较 `===`，可以使用数组，POST 传 `wqh[]=1&dsy[]=2`，flag 就出来了**

![屏幕截图 2026-11-15 160058](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 160058.png)

![屏幕截图 2026-11-15 160107](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 160107.png)

**知识点：MD5 的三种绕法**

**1 万能字符串 ffifdyop**

- `md5($str, true)` 返回 16 字节二进制，不是十六进制字符，直接用等于拿字符串那套思路就想不通了
- `ffifdyop` 的原始值开头是 `'or'6`，拼进 SQL 后单引号被闭合，变成恒真条件
- 前提是代码写成 `md5($pass,true)` 且结果直接拼进 SQL、外面还用单引号包着
- 这类字符串不止一个，ffifdyop 是最常背的一个

**2 0e 弱比较**

- `0e` 加纯数字组成的 md5，在 `==` 里会被当成科学计数法，值全是 0，所以两个不相等的字符串也"相等"
- 常用的几对：`QNKCDZO`、`240610708`、`aabg7XSs`、`aabC9RqS`，网上有现成的表
- 只对 `==` 有用，`===` 既要类型也要值，过不去

**3 数组绕过**

- `md5(array)` 不是报错退出，而是返回 NULL，`NULL == NULL`、`NULL === NULL` 都成立，强弱比较一起废
- PHP 7 里是警告 + NULL，`error_reporting(0)` 把警告一吞，页面看着一切正常
- PHP 8 起直接抛 TypeError、页面 500，所以用之前先确认版本
- 同样的路子对 `sha1`、`strcmp` 这些函数都成立

[[SWPUCTF 2022 新生赛]funny_php](https://www.nssctf.cn/problem/3083)

**源码直接给出来了，三关都写在同一个文件里，过一关往 session 里记一个标记，三个标记齐了才 include flag.php**

![屏幕截图 2026-11-15 161314](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 161314.png)

**第一关 `strlen($_GET['num'])<=3 && $_GET['num']>999999999`，3 个字符还得比 999999999 大，用科学计数法：`?num=9e9`**

![屏幕截图 2026-11-15 161153](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 161153.png)

![屏幕截图 2026-11-15 161155](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 161155.png)

**第二关 `preg_replace('/NSSCTF/',"",$str)` 之后要严格等于 `NSSCTF`，删掉一次还剩一次，所以写套娃：`?str=NSSNSSCTFCTF`。这关是 `===`，大小写绕过没用（`NssCTF` 不会被替换，但也不等于 `NSSCTF`），只能用双写**

![屏幕截图 2026-11-15 161317](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 161317.png)



![屏幕截图 2026-11-15 161421](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 161421.png)

![屏幕截图 2026-11-15 161419](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 161419.png)

**第三关要两个参数不相等、md5 却相等，外面还套了个 `is_string`，`md5_1[]=1` 这种数组传法会被回一个 `X(`。用 0e 魔术哈希，POST `md5_1=QNKCDZO&md5_2=240610708`**



![屏幕截图 2026-11-15 161329](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 161329.png)

![屏幕截图 2026-11-15 161614](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 161614.png)

![屏幕截图 2026-11-15 161619](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 161619.png)

**知识点：preg_replace 与双写**

- `preg_replace` 是单次替换，从左往右扫，匹配到的部分被吃掉，不会回头再处理
- 所以 `NSSNSSCTFCTF` 里第一个有效匹配在下标 3，删完剩下的 `NSS` + `CTF` 又拼回 `NSSCTF`
- 这招就是"双写绕过"，过滤 `flag` 这类关键字时也是同一个套路：`flflagag` 删完还剩 `flag`
- 大小写绕过要看后面的比较符号，`==` 能混过去，`===` 混不过去
- 防御上别指望一次替换，替换完再查一遍，或者干脆用白名单

**知识点：session 在 CTF 里的坑**

- `session_start()` 之后 `$_SESSION` 存在服务端，浏览器只留一个 `PHPSESSID` 当钥匙
- 换浏览器、开无痕、清 cookie、工具不带 cookie，都会变成新会话，之前的标记全丢
- burp 要开 cookie jar，或者手动把 Cookie 头补齐
- 浏览器控制台里 `fetch` 同源请求默认带 cookie，比分三次手点省事得多

[WEEK1 WEB Begin of PHP](https://buuoj.cn/match/matches/190/challenges#【已停止提交】Begin of PHP)

**打开就是源码。注意 `$flag1`~`$flag4` 都是同一个请求里的局部变量，没有 session 可依赖，所以必须一条请求把 key1~key5 一次带全，分开发第一关就 die 了**

![屏幕截图 2026-11-15 162253](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 162253.png)

**第一关 key1 和 key2 不能相等但 md5 要相等，松比较，用 0e：`?key1=QNKCDZO&key2=240610708`**

![屏幕截图 2026-11-15 162341](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 162341.png)

**第二关 `md5($key3) === sha1($key3)`，md5 是 32 位、sha1 是 40 位，字符串永远不可能严格相等，只能让两个函数都返回 NULL——传数组 `key3[]=1`**

![屏幕截图 2026-11-15 162751](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 162751.png)

**第三关 `strcmp($_GET['key4'], file_get_contents("/flag")) == 0`，flag 内容不知道也照样能过：strcmp 收到数组返回 NULL，`NULL == 0` 成立，比较根本没发生。传 `?key4[]=1`**

![屏幕截图 2026-11-15 163506](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 163506.png)

**第四关 `!is_numeric($key5) && $key5 > 2023`，要"不是数字又大于 2023"，`2024a` 两头都占：is_numeric 不认它，比较的时候前面的 2024 被摘出来。传 `?key5=2024a`**

![屏幕截图 2026-11-15 163811](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-15 163811.png)

**第五关`extract($_POST)` 之后先遍历整个 POST，只要有一个值带字母或数字就 die，然后才判 `$flag5`。两个条件对着卡：值不能有字母数字，又必须为真。`.`（一个点）不是空串、也不等于 `"0"`，还不含字母数字，正好；key3 的数组值丢给 preg_match 也只返回 false，不会 die。所以 POST `key3[]=1&flag5=.`**

**合起来就是：**

```
GET /?key1=QNKCDZO&key2=240610708&key4[]=1&key5=2024a
body: key3[]=1&flag5=.
```



**知识点：这一题五个关卡对应五种类型混淆**

**1 严格相等也能被 NULL 过**

- `md5(x) === sha1(x)` 看着是强比较，实际上 md5 和 sha1 的位数都不一样，正常输入永远不相等
- 唯一出路是让两个函数都失败返回 NULL，`NULL === NULL` 成立
- 所以判断"强比较安全"是不对的，关键看返回值是不是可控

**2 strcmp 的返回值**

- `strcmp` 返回的是三态整数：小于返回负数、等于返回 0、大于返回正数
- 参数类型不对时（PHP 7）直接返回 NULL，函数体不执行，比较根本没发生
- 判断写成 `== 0` 就被 `NULL == 0` 混过去，写成 `=== 0` 就过不去了

**3 is_numeric 与字符串转数字**

- `is_numeric` 认的是整串是不是合法数字，`2024a` 不合法，返回 false
- 但 `>` 比较时 PHP 7 会把字符串开头的数字部分摘出来转成 2024，于是大于 2023
- 一个函数判定"不是数字"、另一个比较却"当数字用"，这就是矛盾点

**4 extract 变量覆盖**

- `extract($_POST)` 会把 POST 的键变成同名变量，`flag5` 变成 `$flag5`，凭空造出题目要的变量
- 它也能覆盖已有的变量，顺序很重要：`extract` 之前的判断不受影响，之后的会被盖掉
- 把用户输入和业务变量塞进同一个数组再用 extract，是很危险的写法

**5 为什么必须一条请求**

- 题目用 `$flag1`、`$flag2` 这种局部变量串联，不是 session，也不是文件，出了这次请求就没了
- 所以 GET 参数和 POST 参数要同时发：URL 放 GET，body 放 POST
- 调的时候先一关一关确认能过，最后再合成一条，不然中间任何一关 die 都看不到后面的提示

# 知识点总结

## ***一.哈希与比较***

**1 MD5 三种绕法**

- 万能字符串：`md5($str, true)` 时用 `ffifdyop`，原始二进制开头是 `'or'6`，能拼出恒真的 SQL 条件
- 0e 弱比较：`0e` 加纯数字的 hash 在 `==` 里都当 0，`QNKCDZO`、`240610708` 是常客
- 数组绕过：`md5(array)` 得到 NULL，`NULL == NULL` 和 `NULL === NULL` 都成立，强弱比较一起废

**2 比较符号**

- `==` 会做类型转换，`"1" == 1`、`"0e1" == "0e2"` 都为真
- `===` 要类型和值都相同，但它挡不住数组，因为两边都是 NULL，类型也一致
- 做题先看条件用的是哪个，再决定打弱比较还是打返回值

**3 版本差异**

- 上面这些数组绕过只在 PHP 7 及更早成立，PHP 8 起内建函数直接抛 TypeError，页面 500
- 先看 `X-Powered-By`，或者故意传个数组看看是报 warning 还是 500
- 同一个知识点换版本就失效，是这类题最容易踩的坑

## ***二.函数返回 NULL 的利用***

**1 为什么会返回 NULL**

- 参数类型不对时，PHP 7 的内建函数发一条 warning 就返回 NULL，函数体根本不执行
- `error_reporting(0)` 把 warning 吞掉，页面看着一切正常，很容易以为参数真的变成了 NULL
- 本质是"调用失败"，不是"值变成 NULL"

**2 经常被这么用的函数**

- `md5(array)`、`sha1(array)`：NULL，配 `===` 也能过
- `strcmp(array, string)`：NULL，配 `== 0` 能过
- `file_get_contents` 失败返回的是 false，不是 NULL，别混
- 遇到 `== 0`、`== false`、`=== NULL` 这种条件，先想"能不能让函数调用失败"

## ***三.正则替换与关键字绕过***

- `preg_replace` 单次替换，套娃双写：`NSSNSSCTFCTF` → `NSSCTF`，`flflagag` → `flag`
- 严格比较时大小写绕过没用，替换区分大小写，比较也区分大小写
- 换行、Tab、注释符在不同解析器里表现不一样，也是绕过空间
- 防御：替换后复查、用白名单、少拿用户输入直接拼规则

## ***四.extract 与变量覆盖***

- `extract($_POST)`、`extract($_GET)` 会把数组键变成变量，能造变量也能盖变量
- 覆盖顺序决定影响范围，放在判断后面就只能影响后面的逻辑
- 变量名别和业务变量撞，能用数组就用 `$_POST['x']` 显式取

## ***五.session 与多次请求***

- 用 session 记状态的题，必须带着同一个 `PHPSESSID` 连着做完
- 换浏览器、无痕、清 cookie、curl 不带 cookie 文件，都会变成新会话
- burp 记得开 cookie jar；浏览器控制台 `fetch` 同源默认带 cookie，比分三次手点省事

## ***六.一条请求打穿多关***

- 关卡用 `$flag1`、`$flag2` 这种局部变量串联时，没有 session 可依赖，必须一条请求全带
- GET 和 POST 可以同时用：URL 放 GET 参数，body 放 POST 参数
- 任何一关 `die` 后面都看不到，先逐关确认能过，再合成一条

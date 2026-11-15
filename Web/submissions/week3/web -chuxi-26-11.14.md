## PHP语言

代码/命令执行(RCE)

[青少年CTF练习平台](https://www.qsnctf.com/#/main/driving-range?page=1&category=&difficulty=&keyword=RCE&user_answer=&user_favorite=&tag_ids=)

### level 1

**`highlight_file(__FILE__)` 直接把源码打印出来
 POST 上去 `a` 会被当成 PHP 代码执行

**用 `system()` 把 `cat /flag` 包成一条完整的 PHP 语句，用 POST 发过去：**

```
curl -X POST -d "a=system('cat /flag');" URL
```

![屏幕截图 2026-11-13 121325](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 121325.png)

**得到flag 

![屏幕截图 2026-11-13 121337](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 121337.png)

**知识点**

- `eval($str)` 把字符串当 PHP 代码执行，最典型的一句话木马就是 `eval($_POST['a']);`
- 等价的危险函数：`assert()`、`create_function()`、`preg_replace` 的 `/e` 修饰符（旧版本）、`call_user_func()`
- 代码执行 vs 命令执行：前者执行 PHP 代码，后者执行系统命令（`system`/`exec`/`shell_exec`/`passthru`/反引号）
- 一句话木马的危害：只要参数可控，攻击者就能在服务器上执行任意代码

### level 2 

**这一关的函数会得到随机函数：**

```php
function start($act){
    $random_func = get_fun();
    if($act == "r"){          // 发送 GET ?action=r 可以重置当前选中的函数
        session_unset();
        session_destroy();
    }
    if ($act == "submit") {
        $user_content = $_POST['content'];
        hello_ctf($random_func, $user_content);
    }
}
```

**如果随机到的不是 eval，就用提示里 `?action=r` 重新抽，直到抽到 eval：**

![屏幕截图 2026-11-13 140228](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-11-13%20140228.png)

**抽到 eval 后，POST `content` 提交代码。注意 `content` 会被拼成 `eval(你的内容)`，所以内容自己要带引号和分号：`'echo $flag;'`。**

![屏幕截图 2026-11-13 141015](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-11-13%20141015.png)

![屏幕截图 2026-11-13 141839](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 141839.png)

![屏幕截图 2026-11-13 141845](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 141845.png)

**知识点：可变函数与回调**

- PHP 支持"变量函数"：`$func($arg)`，`$func` 是什么就调用什么；`call_user_func($func, $arg)` 同理
- 随机函数 + 可重置 session 的本意是"不让你固定利用"，但只要函数池里存在危险函数（`eval`/`system`/`assert`），就能反复抽到
- 防御：函数名不能由用户控制，函数池里不要放危险函数

### level 3 

**`system($_POST['a']);`，把 POST 的 `a` 直接交给 shell。**

**先执行 `cat /etc/passwd`，确认有回显、确认当前权限：**

![屏幕截图 2026-11-13 142346](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 142346.png)

![屏幕截图 2026-11-13 142351](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 142351.png)

**再列根目录，确认 flag 的位置：`ls -la /`**

![屏幕截图 2026-11-13 142430](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 142430.png)

![屏幕截图 2026-11-13 142433](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 142433.png)

**最后 `cat /flag`：**

![屏幕截图 2026-11-13 142453](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 142453.png)

![屏幕截图 2026-11-13 142455](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 142455.png)

**知识点：命令执行函数**

- `system()`：执行命令并直接输出结果，返回最后一行
- `exec()`：执行命令，返回最后一行输出（要自己 echo）
- `shell_exec()`：执行命令，返回完整输出（字符串）
- `passthru()`：执行命令并原样输出（适合二进制）
- 反引号 `` `cmd` `` 等价于 `shell_exec`
- 漏洞本质：用户输入进入 shell 命令字符串，且没有 `escapeshellarg()` 之类的转义

### level 4

**源码：`system("ping -c 1 $ip")`，`ip` 从 GET 取。页面注释把五种 SHELL 运算符都列出来了，是"用运算符改写命令执行流程"。**

![屏幕截图 2026-11-13 142649](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 142649.png)

![屏幕截图 2026-11-13 142653](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 142653.png)

**先用 `;` 在 ping 后面接一条自己的命令验证注入（`;` 不管前一条成败都会执行）：`?ip=8.8.8.8;ls%20/`**

![屏幕截图 2026-11-13 143143](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 143143.png)

**按常规思路 应该加上`?ip=8.8.8.8;cat /flag`，但是浏览器直接"网页无法打开"**

**排查过程：**

- 换成 `;id`、`;ls -l /flag` 都正常返回 200，只有 `cat` 被重置；
- 换同类命令 `tac /flag`、`head /flag`、`base64 /flag` 都能读出来；
- 绕过方式：直接换 `tac /flag`，或者 `cat</flag`（无空格）、`/bin/cat /flag`、`c'a't /flag`、`c\at /flag`。

![屏幕截图 2026-11-13 150425](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 150425.png)

**知识点：SHELL 运算符与返回码**

- `cmd1 ; cmd2`：无条件顺序执行
- `cmd1 && cmd2`：`cmd1` 成功（返回 0）才执行 `cmd2`
- `cmd1 || cmd2`：`cmd1` 失败（返回非 0）才执行 `cmd2`
- `cmd1 & cmd2`：`cmd1` 放后台，立即执行 `cmd2`
- `cmd1 | cmd2`：把 `cmd1` 的 stdout 接到 `cmd2` 的 stdin
- 换行等价于 `;`
- 判断 WAF 在哪一层：返回 `WAF!`/403 是应用层；**连接重置/超时（curl 的 56/28）通常是网络层安全设备**，说明请求还没到 PHP 就被掐了
- 判断"是不是挂了"最简单的方法：先发一条肯定合法的请求（`;id`），能通就说明服务活着，问题在 payload

### level 5 

**源码用 `preg_match("/flag/", $cmd)` 把 `flag` 这个"子串"拦掉，命中就 `die("WAF!")`，之后才 `system($cmd)`。**

**思路：让 PHP 正则看到的字符串里不出现 `flag`，但 shell 执行时能还原成 `/flag`。用 `?` 通配一个字符即可：`?cmd=cat /fla?`**

![屏幕截图 2026-11-13 163252](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 163252.png)

![屏幕截图 2026-11-13 163733](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 163733.png)

**知识点：两个解析器**

- PHP 的 `preg_match` 看的是"**源字符串**"，shell 看的是"**展开后的 token**"，两者对同一串文本的理解不同——这就是所有绕过的空间
- "空字符忽略"：shell 里 `''`、`""` 是空字符串，相邻片段会拼接，`fl''ag` = `flag`，但 PHP 看到的是 `fl''ag`
- 通配符：`?` 匹配一个字符、`*` 匹配任意长度、`[]` 字符类、`{a,b}` 大括号展开（bash 特性）
- URL 编码只在"过滤器位于解码之前"时有用；过滤器在 PHP 里（解码之后）时没用

### level 6 挑战关

**WAF 把字母和大部分字符封了，只剩小写 `a`、数字和 `/ . ? = ! $ ( ) ' , ~` 等**

![屏幕截图 2026-11-13 163953](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 163953.png)

**用八进制把命令拼出来：cat /flag

**知识点：字符黑名单 vs shell 展开**

- 过滤器封的是"**字符**"，shell 执行的是"**展开后的命令**"；只要用合法的源字符能展开出被禁字符，就能过
- ANSI-C 引号 `$'\ooo'` 用八进制写任意字节，源里只有 `$ ' \ 数字`，很隐蔽
- glob 展开成词表后，命令位置取第一个、其余变参数——这也是"为什么用 `?a?` 会多出一堆二进制"的原因

### level 7 

**源码：`preg_match("/flag| /", $cmd)`，同时拦 `flag` 子串和空格。空格被拦就用 `$IFS`（或 TAB `%09`）代替，`flag` 被拦就用 `fla?`，组合起来：`?cmd=cat$IFS/fla?`**

![屏幕截图 2026-11-13 164100](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 164100.png)

![屏幕截图 2026-11-13 152848](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 152848.png)

**知识点：IFS 与词分割**

- shell 拆词的分隔符由 `$IFS` 控制，默认是空格、TAB、换行
- 过滤"空格这个字符"不等于过滤"分隔语义"：TAB、`$IFS`、变量展开都能代替
- 这题和 level 5 的区别：level 5 拦的是子串，level 7 多拦了一个空格，所以要把"关键字绕过 + 分隔符绕过"叠起来

### level 8 重定向

**源码把命令拼成 `system($cmd . ">/dev/null 2>&1")`：`>` 把 stdout 丢进 /dev/null，`2>&1` 把 stderr 也并过去，所以直接执行什么都看不到，看起来像盲打。**

**但重定向只绑定"最后一条命令"。只要在 `cmd` 末尾加一个命令分隔符，那串重定向就变成一条"只有重定向、没有命令"的空命令，回显就回来了：`?cmd=cat /flag;`**

![屏幕截图 2026-11-13 164203](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 164203.png)

![屏幕截图 2026-11-13 164306](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 164306.png)

**知识点：重定向与盲打**

- `>` 覆盖、`>>` 追加、`2>&1` 把 stderr 并到 stdout、`2>/dev/null` 丢弃报错
- 重定向属于"简单命令"，只作用于它所在的那条命令；追加在用户输入后面的重定向，可以被分隔符切断
- 盲执行不等于没执行：写入文件、发起网络请求、时间延迟都是可利用的"副作用"
- 盲打外带三件套：DNS（dnslog）、HTTP（自己的服务器）、时间（sleep）

### DD 加速器（NewStar CTF 2025 Week2 Web）


**页面是一个 ping 连通性测试，`target` 参数会被拼进命令。先注入 `ls /` 看根目录，发现 `/flag` 存在：**

![屏幕截图 2026-11-13 155259](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202026-11-13%20155259.png)

**直接 `cat /flag`，得到的是 `flag{not_here!}`

![屏幕截图 2026-11-13 155320](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 155320.png)

![屏幕截图(317)](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图(317).png)

**把源码读出来（`;cat /var/www/html/*`），能看到 `$maxLen = 28` 的长度限制，以及 `shell_exec("ping -c 1 -W 1 -s $size $host 2>&1")` 的拼接方式。第 28 个字符以外的输入会直接被拒绝**

![屏幕截图 2026-11-13 160111](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 160111.png)

**真 flag 不在 `/flag`：回归终端的动态容器会把真 flag 注入到环境变量 `ICQ_FLAG` 和一个随机命名的隐藏目录里。因为目录名是随机的、直接写会超长度限制，所以用 `/.v*/*` 这种通配符来读：**

![屏幕截图 2026-11-13 160357](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 160357.png)

**最终 payload：`127.0.0.1;cat /.v*/*`**

![屏幕截图 2026-11-13 160300](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 160300.png)

**读到真 flag**

![屏幕截图 2026-11-13 160251](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 160251.png)

**知识点：动态容器与平台**

- 回归终端（Ret2Shell）是西电的 CTF 平台，动态容器题通过 WSRX（TCP over WebSocket）把容器端口映射到本机 `127.0.0.1`
- 平台的真实 flag 会注入到容器里（环境变量 `ICQ_FLAG` + 随机隐藏路径），`/flag` 可能只是出题人放的诱饵
- 长度限制下的短 payload：`;env`、`;ls$IFS/`、`;cat /.v*/*`
- 不知道文件名/路径时，用 glob 让 shell 替你补全
- 动态靶场的环境有倒计时，过期要重新启动

### [SWPUCTF 2021 新生赛]babyrce

**入口页用 Cookie 弱比较，下一关才是命令注入。**

**第一段：入口页源码**

```php
if($_COOKIE['admin']==1){
    include "../next.php";
}else
    echo "小饼干最好吃啦！";
```

**页面提示"小饼干最好吃啦"，就是在说 Cookie。`==` 是弱比较，Cookie 的值永远是字符串，`"1" == 1` 成立，所以只要加 `Cookie: admin=1`。用 Burp 的 Repeater 改 Cookie 重放：**

![屏幕截图 2026-11-13 160837](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 160837.png)

![屏幕截图 2026-11-13 161125](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 161125.png)

**响应从"小饼干最好吃啦！"变成 `rasalghul.php`——这是 `include "../next.php"` 把下一关的文件名吐出来了。**

**第二段：`/rasalghul.php` 的命令注入，只拦空格**

```php
if (isset($_GET['url'])) {
    $ip=$_GET['url'];
    if(preg_match("/ /",$ip)){ die('nonono'); }
    $a = shell_exec($ip);
    echo $a;
}
```

![屏幕截图 2026-11-13 161258](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 161258.png)

**用 `$IFS` 代替空格，先列根目录：`?url=ls$IFS/`**

![屏幕截图 2026-11-13 161500](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 161500.png)

**根目录里是 `flllllaaaaaaggggggg`用通配符读：`?url=cat$IFS/f*`**

![屏幕截图 2026-11-13 161519](https://raw.githubusercontent.com/chuxi-hexisn/chuxi/main/屏幕截图 2026-11-13 161519.png)

**知识点：弱比较与文件包含**

- PHP 弱比较 `==` 会做类型转换，`"1" == 1` 为真；`===` 才是强比较
- Cookie 是客户端可控的明文数据，不要用它做权限判断
- `include` 会把文件内容当 PHP 执行；纯文本文件会被原样输出，常被用来泄露路径/行号
- 空格过滤 + 文件名变形，是命令注入里最常见的组合

---

## 知识点总结

### 一、代码执行与命令执行

- **代码执行**：`eval()`、`assert()`、`create_function()`、`call_user_func()`、`preg_replace /e`
- **命令执行**：`system()`、`exec()`、`shell_exec()`、`passthru()`、反引号
- 本质都是"用户输入进入了代码/命令的语法层"，而不是数据层
- 修复：不要拼接用户输入进代码/命令；命令执行用 `escapeshellarg()`，代码执行用白名单

### 二、SHELL 运算符与返回码

- `;` 无条件顺序执行、`&&` 前一条成功才执行、`||` 前一条失败才执行、`&` 后台、`|` 管道、换行等价于 `;`
- 结合返回码理解 `&&` / `||`：`ping` 通了 `&&` 才会执行后面，`sleep`/失败命令会让 `||` 后面执行
- 命令注入里先用 `;id` 验证"能不能执行"，再想"怎么让整条命令成功/失败"

### 三、通配符、引号与转义（shell 展开层）

- 空引号拼接：`fl''ag`、`fl""ag`
- 反斜杠：`fl\ag`
- glob：`?` 一个字符、`*` 任意长度、`[a-z]` 字符类、`[^a]` 取反、`{a,b}` 大括号（bash 特性，busybox sh 不支持）
- ANSI-C 引号：`$'\143\141\164'` 八进制构造任意字节
- 核心思想：**源字符串里可以不含被禁内容，shell 展开后却是目标内容**

### 四、空格与 IFS

- shell 拆词分隔符由 `$IFS` 控制，默认是空格、TAB、换行
- 绕空格：TAB（`%09`）、`$IFS`、`${IFS}`（注意可能被网络层 WAF 拦）、`<`、换行
- `$IFS` 后要接非字母字符（如 `/`），否则会被当成更长的变量名
- 过滤"空格字符" ≠ 过滤"词分隔语义"

### 五、重定向与盲执行

- `>` 覆盖、`>>` 追加、`2>&1` 合并 stderr、`2>/dev/null` 丢弃报错
- 追加在用户输入后面的重定向只绑定最后一条命令 → 用 `;`、`&&`、`||`、换行、`#`（前有空格）切断
- 盲打不可怕：DNS 外带、HTTP 外带、写文件、时间延迟都能验证/取数据
- "没有回显"不代表"没有执行"

### 六、过滤器的层次与绕过

- **网络层 WAF**（在 PHP 之前）：URL 编码可能有效；拦截表现常是连接重置/超时（curl 56/28）
- **PHP 层过滤**（在 `$_GET/$_POST` 之后）：URL 编码无效，因为已经解码；要在 shell/数据库/模板这一层找变换
- **字符黑名单**：用 shell 展开（引号、通配符、八进制）从合法字符拼出被禁字符
- **关键字黑名单**：用通配符、引号、变量拼接、路径混淆
- **长度限制**：用短命令、`$IFS`、glob、`env`、`/proc` 等
- 判断层级的依据：返回 `WAF!`/403 是应用层；连接重置/超时是网络层；404/500 是路径或代码问题

### 七、PHP 弱比较与类型

- `==` 会做类型转换，`"1" == 1`、`"1e0" == 1`、`"1abc" == 1`（PHP 5/7 早期）都为真
- `===` 强比较，类型和值都要相同
- Cookie/GET/POST 传进来的值永远是字符串，做数字比较时尤其危险
- 相关：`in_array` 不传第三个参数、`strcmp` 数组绕过、`md5` 碰撞/0e 绕过

### 八、动态靶场与平台

- 回归终端（Ret2Shell）：动态容器 + WSRX 反射端口，访问 `127.0.0.1:<端口>`
- 平台的真实 flag 可能注入到环境变量 `ICQ_FLAG` 和随机隐藏路径，`/flag` 可能只是诱饵
- 环境有倒计时，过期要重启；WSRX 断开后浏览器 502，重连即可
- 不要默认 `/flag` 就是 flag，先 `ls /`、`env`、找隐藏文件

### 九、解题方法论

1. **先读源码/提示**：很多靶场会 `highlight_file` 直接给源码，先看 sink 和过滤
2. **确认回显方式**：直接回显、盲打、还是只有报错
3. **先验证最小利用**：`id`、`ls /`、`cat /flag`，确认能执行、确认权限
4. **再处理过滤**：按"过滤器在哪一层"选绕过方式（URL 编码 / shell 展开 / 类型转换）
5. **注意坑**：命令拼写、参数名、引号、变量名连读、重定向不展开 glob、长度限制、诱饵文件
6. **最后才找 flag**：`/flag`、`env`、`ls -la /`、隐藏目录、数据库、配置

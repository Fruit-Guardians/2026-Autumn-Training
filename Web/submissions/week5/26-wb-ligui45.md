# 2026年11月2日
# 学习内容：ctf show web11
# 解题步骤：
1. 开局一个管理员认证页面同时显示出密码加代码![alt text](<屏幕截图 2026-11-02 171752.png>)
2. 题中replaceSpecialChar($strParam)搬掉SQL注入(replaceSpecialChar 函数会过滤掉 select、from、where、union、and、or 等关键词以及空格和逗号。并且通过 strlen 比对过滤前后的长度，一旦长度不一致就直接 die() 退出，彻底封死了 SQL 注入的路子。
· 致命的验证逻辑：if($password == $_SESSION['password'])。这里的漏洞在于，$_SESSION['password'] 初始是 NULL（或者未设置），而 PHP 的松散比较 == 中，NULL == '' 的结果为 True。
3. 知道密码是空的后，直接打开f12开发者工具点击最右侧的 >> 图标（在 Memory 右边）。
 在弹出的下拉菜单里，点击 Application（“应用程序”）。
打开后，在左侧菜单栏找到 Storage（存储） -> Cookies（Cookie）。 点击你当前网站的域名，在右侧列表中找到 PHPSESSID。右键点击它，选择 Delete（删除），
4. 返回页面将密码删掉登录拿到flag
![alt text](<屏幕截图 2026-11-02 173318.png>)
# 学习笔记
1. 漏洞的核心：PHP 的弱类型比较
源码里最关键的一句话是：
```php
if($password == $_SESSION['password']){
    // 输出 Flag
}
```
当服务器第一次接待一个全新访客时，它的会话（Session）是空的，此时 $_SESSION['password'] 的值是 NULL（空值）。
在 PHP 中，使用两个等号 == 进行比较时，属于“弱类型比较”。它会把两边转换成同一种类型再比。NULL == ""（空字符串）的结果是 True。
所以，只要服务器认为你是“全新访客”（Session 为空），并且你提交了一个空密码，这个条件就成立了。
2. 为什么要删掉 PHPSESSID？
PHPSESSID 就是你在这个网站上的“临时身份证”。
· 如果不删： 服务器看你的身份证，发现你之前来过。可能你之前输入过错误的密码，服务器在你的 Session 里记录了那个错误的密码，这时候你提交空密码，"" == "错误的密码" 就不成立了，绕过失败。
· 如果删了： 你的“旧身份证”失效了。当你刷新网页再次访问时，服务器会发给你一张全新的身份证（新的 PHPSESSID），并且分配一个全新的、完全空白的 Session。此时 $_SESSION['password'] 再次变回了 NULL。

# 2026年11月3号
# 学习内容：ctf.show web12
# 解题步骤：
1. 开局一个页面where is the flag?，查看源代码发现<!-- hit:?cmd= -->(cmd：是 command（命令） 的缩写。这是前端传给后端的“参数名”。)可以尝试在网址后面加上 ?cmd=系统命令 来执行代码。”
3. 测试命令：http://challenge-xxxx.ctf.show/?cmd=ls (这个意思是：向服务器发送一个 cmd 参数，值为 ls 命令。ls 是 Linux 系统中用来列出当前目录文件的命令。)没有反应---推测可能是“代码执行”(pHP代码执行--eval 函数)--如果是 eval 接收参数，直接传 ls 会被当成 PHP 代码解析，导致报错
4. 使用cmd=phpinfo();hpinfo() 是 PHP 语言中的一个内置函数。“打印 PHP 的详细信息”。
5. 此时页面变成紫色![alt text](<屏幕截图 2026-11-03 173431.png>)证明了存在代码执行漏洞。
6. 使用?cmd=print_r(scandir("./"));---PHP 中用来列出当前目录下所有文件和文件夹的函数，print_r() 负责把它打印到屏幕上
7. 发现Array ( [0] => . [1] => .. [2] => 903c00105c0141fd37ff47697e916e53616e33a72fb3774ab213b3e2a732f56f.php [3] => index.php )![alt text](<屏幕截图 2026-11-03 173710.png>)
8. 使用https://ec14e93f-2058-4de5-b20d-a301cee24dca.challenge.ctf.show/?cmd=highlight_file("903c00105c0141fd37ff47697e916e53616e33a72fb3774ab213b3e2a732f56f.php");---highlight_file() 也是 PHP 的函数，可以读取文件内容，并且带有高亮格式
9. 拿到flag="ctfshow{1a817a6c-feae-415f-8342-00bf6ab9c8d9}";?>![
](<屏幕截图 2026-11-03 173911.png>)
# 学习笔记
1.  <!-- hit:?cmd= -->：这个注释是在告诉你，这个网站存在命令执行（Command Execution）漏洞。
· 题目暗示你，可以在 URL 地址后面加上参数 ?cmd= 来执行系统命令。
2. 可以执行 PHP 代码。用 PHP 的函数来列目录和读文件：
· 列目录：?cmd=print_r(scandir("./"));
· 读文件：?cmd=highlight_file("flag.php"); 或者 ?cmd=system("cat flag.php");

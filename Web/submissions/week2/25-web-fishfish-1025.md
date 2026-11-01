## php函数基础

> 在 PHP 语言里，**函数的参数必须以字符串（带引号）的形式传递**。
>
> - 在**源码里写死**时，必须显式地用 `'...'` 或 `"..."` 来包装代码。
> - 在**做题（传参）**时，不需要再添加引号，因为 HTTP 请求的数据传给 PHP 变量时，已经是字符串状态了。(这里也解释一下后续做题的疑问)



**文件操作函数**

**1. include()/require()  -->  导入并执行文件**  --> 配置不当可能出现**文件包含漏洞**

- `include('导入文件名')`: 如果文件不存在，程序会 **报一个警告(Warning),但会继续往下执行。**

- `require('导入文件名')` : 如果文件不存在，**程序会产生致命错误（Fatal Error），直接终止运行。**

- `_once` ： 加个 `once` （如 `include_once`），**表示只加载一次**，放置重复加载导致函数/变量重定义报错。



**2. fopen() -> 打开文件, fclose() -> 关闭,fgets() -> 逐行读取,fgetc() -> 逐字符读取,feof() -> 检测文件末尾(EOF)   文件操作函数**

文件打开模式: 

| 模式 | 描述                                                         |
| :--- | :----------------------------------------------------------- |
| r    | 只读。在文件的开头开始。                                     |
| r+   | 读/写。在文件的开头开始。                                    |
| w    | 只写。打开并清空文件的内容；如果文件不存在，则创建新文件。   |
| w+   | 读/写。打开并清空文件的内容；如果文件不存在，则创建新文件。  |
| a    | 追加。打开并向文件末尾进行写操作，如果文件不存在，则创建新文件。 |
| a+   | 读/追加。通过向文件末尾写内容，来保持文件内容。              |
| x    | 只写。创建新文件。如果文件已存在，则返回 FALSE 和一个错误。  |
| x+   | 读/写。创建新文件。如果文件已存在，则返回 FALSE 和一个错误。 |

> fopen("打开文件",打开模式)

```php
<?php
$file=fopen("welcome.txt","r") or exit("无法打开文件!"); // 文件存在就打开
while (!feof($file))  // 判断是否到达文件末尾
{
    echo fgetc($file); // 逐字符读取文件
}
fclose($file);  // 关闭文件
?>
```

**3.** `file_get_contents()` **/** `file_put_contents()` **—— 一键读写字符串**

`fopen` 一行行读太麻烦了，这两个函数是**最常用**的快捷方式：

- **file_get_contents()**：直接把整个文件的内容变成一个字符串。
- **file_put_contents()**：直接把一个字符串写入文件（如果没有该文件就自动创建，有就覆盖）。

```php
<?php
// 1. 一键读取
$content = file_get_contents("test.txt");
echo $content;

// 2. 一键写入
file_put_contents("log.txt", "有人访问了这个页面！"); 
?>
```



**PHP危险函数 (代码执行函数)**

**1. `eval()` ----  字符串代码执行（把括号里的字符串当成真正的 PHP 代码来执行）** 

```php
<?php
$str = '$x = 5; echo "x的值是：" . $x;';
// 执行字符串 $str 里的内容
eval($str); 
// 页面会输出：x的值是：5
?>
```

**2. `assert（）` ---- 调试与检查**   -->  配置不当可能出现**RCE** (PHP 代码执行)

主要用于调试,检查一个条件是否为 `true`。

- 注：在 PHP 7 之前，`assert()` 也会把括号里的字符串当成代码执行,和 `eval()` 一模一样,但在 PHP 7 之后,它默认值接受布尔值,安全性有所提高,但如果服务器配置不当,依然可以被利用.

```php
<?php
$x = 5;
assert($x > 0); // 因为 5>0 为真，程序继续执行，什么都不会发生。
assert($x < 0); // 因为 5<0 为假，程序会报错（Warning）。
?>
```



**3. `system()`, `shell_exec()`, `exec()`, `passthru()`—— 系统命令执行** -->  命令注入

> **进阶:**  `popen()/proc_open()`,`pcntl_exec()` ,`反引号`` `

这四个函数的作用都是: **让 PHP 去调用服务器的系统底层 (如Linux 或 windows), 执行操作系统的命令行指令。**

```php
<?php
// 1. system("命令")：执行命令，并且把结果直接打印在网页上
system("whoami"); // 网页会显示当前服务器是用什么用户身份在运行

// 2. shell_exec("命令")：执行命令，把结果当作一个字符串返回,需要再手动 echo 打印 
$output = shell_exec("ls"); 
echo $output; // 打印当前目录下的所有文件

// 3. exec("命令", 输出数组)：执行命令，把每一行的结果存入数组
exec("ls", $arr);
print_r($arr);

// 4. passthru("命令")：执行命令，直接输出原始数据（常用于二进制文件）
passthru("id");
?>
```



**序列化`serialise()`和反序列化 `unserialise()`**

- `serialize()`：把一个 PHP 对象（Class Instance）压缩成一串字符串，方便存入数据库或通过网络传输。
- `unserialize()`：把这串字符串解压，恢复成一个完整的对象。

**数据库操作函数**：

- `mysql_query()`, `mysqli_query()`: 发送一个 MySQL 查询。例如：`$result = mysql_query("SELECT * FROM users");`

**其他函数**：

- `preg_replace()`: 执行正则表达式搜索和替换。例如：`$newStr = preg_replace("/apple/i", "orange", $str);` 会将 `$str` 中的 "apple" 替换为 "orange"。
- `create_function()`: 创建匿名的 lambda 函数。例如：`$func = create_function('$x', 'return $x + 1;');`





**代码执行概念区分**

- **任意代码执行 (ACE)**：这是最大的概念。指攻击者能在目标机器上运行任意代码。它包括系统层面（脚本、程序）和应用层面（语言内部的函数调用）。

- **远程代码执行 (RCE)**：在 ACE 的基础上，如果攻击者是通过**网络**（比如发 HTTP 请求）触发的，就叫 RCE。这是 Web 渗透的终极目标之一。

- **命令执行 (Command Execution)**：专门指在操作系统层面执行指令（比如 Linux 的 Shell 命令，Windows 的 CMD 命令）。在 PHP 中体现为 `system()`、`shell_exec()` 等函数。

- **代码执行 (Code Execution)**：范围更广，指在特定语言的解释器/编译器层面执行该语言的任意代码。在 PHP 中体现为 `eval()`、`assert()` 等函数。

  

### 代码/命令执行(RCE)  wp

**rce-labs level 0** 的 flag 开启靶场就直接显示在页面了

**rce-labs level 1  --- 一句话木马和代码执行**  是一个文件包含的命令执行的php代码

```php
// 源码如下
<?php 
include ("get_flag.php"); // 页面文件中包含 get_flag.php文件内容
eval($_POST['a']);  // eval() 函数将 post 请求体中 a的值当做 php 代码执行

highlight_file(__FILE__);
?>
```

构造 post 请求体 发包:

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo//20261024231008686.png)

得到 flag

-- -



**rce-labs level 3**   : `system()` 函数的命令执行

```php
// php 源码
<?php
system($_POST['a']); // 用 system()函数 接收 post 请求中 请求体 a 的值
highlight_file(__FILE__);

?>
```

用 hackbar 发包:

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo//20261024232605446.png)

拿下 flag

-- -



**rce-labs level 4 ---  shell运算符**

打开靶场根据提示在页面URL后面接上 `?ip=8.8.8.8` 回车,发现可以 `ping` 通,即命令可以正常执行 

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261024224157690.png)

**linux中我们是支持命令拼接的，如下就是常见的拼接字符**

```bash
;：命令结束后执行下一条

&&：前一个成功再执行后一个

|：管道符

||：前一个失败才执行后一个

&：后台执行
```

这里使用 `;`拼接符查看网站根目录文件,发现一个 flag 文件

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo//20261024225726736.png)

用 `more` 命令输出 /flag 文件内容:

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261024224006774.png)

得到flag

-- -



**rce-labs level 5  ---  命令执行 - 终端特性_空字符忽略和通配符 **

在Shell中，单/双引号 "/' 可以用来定义一个空字符串或保护包含空格或特殊字符的字符串。

例如：`echo "$"a;` 会输出 $a，而 `echo $a;` /`echo '$a';`会输出变量a的值，当只有`""`/`''`(空字符串)时，Shell会忽略它。

**通配符:**

- `*`（星号）: 匹配**零个或多个字符**。例子: `.txt`
- `?`（问号）: 匹配**单个字符**。例子: `file?.txt`
- `[]`（方括号）: 匹配**方括号内的任意一个字符**。例子: `file[1-3].txt`。
- `[^]`（取反方括号）: 匹配**不在方括号内的字符**。例子: `file[^a-c].txt`。
- `{}`（大括号）: 匹配大括号内的**任意一个字符串**。例子: `file{1,2,3}.txt`。

通过组合上述技巧，我们可以用于绕过CTF中一些简单的过滤：

>system("c''at /e't'c/pass?d");

> system("/???/?at /e't'c/pass?d");

> system("/???/?at /e't'c/*ss*");

```php
// 源码
<?php

function hello_shell($cmd){
    if(preg_match("/flag/", $cmd)){ // 正则表达式匹配 $cmd的值是否为 flag
        die("WAF!"); // 正则匹配成功就 输出 WAF! 提示信息并终止脚本
    }
    system($cmd); // system()函数 接收 GET 请求 传参 cmd 的值
}
// 只有当URL参数cmd存在时，才会调用hello_shell函数
isset($_GET['cmd']) ? hello_shell($_GET['cmd']) : null;

highlight_file(__FILE__);
?>
```

- 这里尝试查看本地根目录里的文件:

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo//20261025103822763.png)



- 发现存在 `get_flag.php`文件,尝试打开,这里用了上面提供的一系列通配符在hackbar里尝试都没反应,没有报 `WAF!`也没有什么改变,一直都是原页面,就觉得可能是路径或者什么别的问题,尝试用 `pwd`和 bp抓包改路径

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo//20261025105817030.png)

- 发现当前路径是 `/var/www/html` 之前一直用 `/get_flag.php`或 `get_flag.php`加通配符尝试,bp抓包尝试:

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo//20261025111846494.png)

- 成功读取到 get_flag.php 文件里的内容,说如果 `/flag`文件存在的话就将其里面的内容以 字符串的形式全盘输出,下面又提示根目录下默认存有flag,后面也去看了发现确实存在

重新构造 cmd 传参去读取 `/flag`里的内容

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo//20261025111355863.png)

拿下 flag

-- -



**rce-labs level 6**

这关和第五关代码其实差不多,就是 `preg_match()`函数里用了正则匹配

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo//20261025112209874.png)

这里简单补充一下正则表达式:

**正则表达式 ： **就是**用一段“规则字符串”去描述你想匹配的文本模式. 它可以 查找、替换、验证、提取你想要的信息。**

在 PHP 里，它经常出现在 `preg_match()`、`preg_replace()`、`preg_match_all()` 这些函数里。

- **preg_match()**：在字符串中搜索匹配的模式，只返回第一个匹配项
- **preg_match_all()**：返回所有匹配项，适合提取多个符合条件的子串
- **preg_replace()**：搜索匹配的模式并进行替换

例如这题中的：

```php
preg_match("/[b-zA-Z_@#%^&*:{}\-\+<>\"|`;[\]]/", $cmd)
```

意思为: 

- `[b-zA-Z_@#%^&*:{}\-\+<>\"|`;[\\]]/` 是正则模式;
- `$cmd` 是要检查的字符串;
-  如果 `$cmd`里包含 正则模式 里的内容就返回 `1`,这个程序就会 输出 `WAF!`并退出, 反之则将 `$cmd` 里的内容放到 `system()`函数中执行并于该页面中输出.
- 整体意思是：**只要 $ cmd 里出现正则模式其中任意一个字符，就匹配成功。**

**正则表达式语法:**

1. **分隔符**：通常使用 `/`，也可用 `#` 或 `~`，用于标识模式的开始和结束;  

2. **修饰符:**

- `i`：忽略大小写
- `m`：多行模式
- `s`：点号匹配换行符

3. **最常用的元字符: **

| 符号 | 含义                       | 例子                                |
| ---- | -------------------------- | ----------------------------------- |
| `.`  | 匹配任意一个字符（除换行） | `a.c` 可匹配 `abc`                  |
| `^`  | 匹配字符串开头             | `^abc` 匹配以 `abc` 开头的字符串    |
| `$`  | 匹配字符串结尾             | `abc$` 匹配以 `abc` 结尾的字符串    |
| `*`  | 前一个字符出现 0 次或多次  | `ab*c` 可匹配 `ac`、`abc`、`abbc`   |
| `+`  | 前一个字符出现 1 次或多次  | `ab+c` 可匹配 `abc`、`abbc`         |
| `?`  | 前一个字符出现 0 次或 1 次 | `ab?c` 可匹配 `ac`、`abc`           |
| `[]` | 匹配方括号里的任意一个字符 | `[abc]` 匹配 `a` 或 `b` 或 `c`      |
| `()` | 分组、捕获                 | `(ab)+` 匹配 `ab`、`abab`           |
| `\d` | 匹配数字                   | `\d+` 匹配 `123`                    |
| `\w` | 匹配字母、数字、下划线     | `\w+` 匹配 `hello123`               |
| `\s` | 匹配空白字符               | `\s+` 匹配空格、制表符等            |
| `-`  | 连字符                     | 常用于 `a-z`,`A-Z``0-9`表示连续选取 |

> **注:** 如果正则表达式里想拦截元字符(在正则里符号本身有特殊含义的字符),就必须在它们前面加一个反斜杠 `\` 	  进行“转义”.

4. **量词：**

- `*`：匹配 0 次或多次
- `+`：匹配 1 次或多次
- `?`：匹配 0 次或 1 次
- `{n,m}`：匹配 n 到 m 次

再看这题中的 正则模式: 

```php
/[b-zA-Z_@#%^&*:{}\-\+<>\"|`;[\]]/
```

所以这题拦截了小写字母从 `b~z` 和 大写字母 从 `A~Z` 的所有字符 以及 `_@#%^&*:{}-+<>\"|`;[]`：这些特殊字符



因此这题我们只能从没有被拦截的字符( a , 0-9,?,/,=,' ,\等) 中加上 **通配符** 去构造 Payload 去读取 flag

原则和道理上这样,但我尝试去构造例如这样 `/???/?a? /??a?` ,这样 `?a? /??a?` 等请求时都没有得到什么结果,要么被拦截了,要么页面没什么显示,没什么想法了就去查了查了一下这题的解题  wp

发现 发现 `/???/?a?` 不单指向了 `cat` ,还指向了别的东西 `tar`,所以失败了,但这题是没有对数字进行过滤的,于是可以尝试使用 base64 命令将 文件 `/flag`读取出来

即构造这样的请求参数: 

```bash
?cmd=/???/?a??64 /??a?
// 即用 bin/base64 /flag 读取
```

读取到的base64:

```bash
ZmxhZ3tiMjI3MDJkYS1IMGEzLTRiM2ItOGMyNC1mYTg3MzhmM2MxYjB9Cg==
```

将其惊醒解码即可得flag: `flag{b22702da-81a3-4b3b-8c24-fa8738f3c1b0}`

-- -



-- -



## Docker基础命令 

**镜像（Image）：** 是一个制度的静态模版,包含了运行模格软件所需的所有代码、运行环境、库、环境变量和配置文件。  ----- 》 类比 OOP 里的 “类（class）"/安装光盘，它自己不会跑，只是一堆文件。

**容器（Container）：**是镜像 **运行起来的实体（实例）**，即在镜像之上加了一个可写的存储层。 ---》 类比 `new`出来的 "对象(实例)"/正在运行的电脑

**仓库（Registry）：**用来 **几种存放和分发Docker镜像**的地方。分为公共仓库和私有仓库。--》 就是Docker的“APP Store” / "GitHub".     [Docker官方的仓库](https://hub.docker.com/):  [daocloud国内仓库](https://hub.daocloud.io/):  [网易云镜像中心](https://c.163yun.com/hub#/home)

**常用操作:**

1. **拉取（Pull）**：你从 **仓库（Registry）** 把 **镜像（Image）** 下载到本地。
2. **运行（Run）**：你通过命令，让这个 **镜像（Image）** 变成了一个正在运行的 **容器（Container/实例）**。
3. **修改（Modify）**：你在容器里一顿操作（比如放进了一个木马，或者修复了一个 bug）。
4. **提交（Commit）**：你把修改后的容器，重新打包成一个新的 **镜像（Image）**。
5. **推送（Push）**：你把这个新镜像，上传到你们公司的私有 **仓库（Registry）** 供团队使用。

```powershell
# 1. 从仓库拉取镜像
docker pull ubuntu:20.04

# 2. 查看本地已有的镜像
docker images

# 3. 用镜像启动一个容器实例（-it 分配交互式终端，--name 起个名字）
docker run -it --name my_hacker_box ubuntu:20.04 /bin/bash
# （进去后你就是一个 root 权限的迷你 Linux，退出来用 exit）

# 4. 查看正在运行的容器实例
docker ps

# 5. 查看所有（包括已关闭）的容器实例
docker ps -a

# 6. 启动/停止容器
docker start my_hacker_box
docker stop my_hacker_box

# 7. 进到正在运行的容器里（相当于 SSH 进去）
docker exec -it my_hacker_box /bin/bash

# 8. 删除容器（注意：要先 stop 才能 rm）
docker stop my_hacker_box
docker rm my_hacker_box

# 9. 删除镜像
docker rmi ubuntu:20.04

# 10. 启动docker
# 启动docker
sudo service docker start	/ 	docker desktop restart	/	net start com.docker.service
# 重启docker
sudo service docker restart
# 停止docker
sudo service docker stop
```



**1. 拉取镜像(docker  pull)**

```powershell
# 官方镜像
docker image pull 镜像名称
# 或简写为
docker pull 镜像名称
# 比如
docker pull ubuntu
docker pull ubuntu:16.04

# 个人镜像
docker pull 仓库名称/镜像名称
docker pull xunmi/django

# 第三方仓库拉去
docker pull 第三方仓库地址/仓库名称/镜像名称
docker pull hub.c.163.com/library/mysql:latest
(默认仓库名为library,所有从官方获取镜像相当于`sudo docker image pull library/镜像名称`)
```

**2. 删除镜像(docker rm)**

```powershell
docker image rm 镜像名/镜像ID
docker rmi 镜像名/镜像ID
# 比如
docker rmi hello-world
docker rmi 9e64176cd8a2
```

**3. 加载镜像(docker run)**

`docker run [可选参数] 镜像名 [想启动容器中传入命令]`

**1). 可选参数:**

- `-t`: 在新容器内指定一个伪终端或终端。
- `-i`: 允许你对容器内的标准输入 (STDIN) 进行交互。
- `-d` (detach): 代表后台运行（守护态运行）。
- `--rm`: 新建一个容器并在退出(exit)容器后自动销毁

**2). 想启动容器中传入命令:**

1. **基础的系统命令**
   比如 `ls`、`cat`、`pwd`、`echo`。

- *示例*：`docker run ubuntu:22.04 ls /`（启动后列出根目录，然后容器立刻退出）。

2. **带参数的命令**
   比如 `ping baidu.com`、`sleep 10`。

- *示例*：`docker run -d ubuntu:22.04 sleep infinity`（让它一直睡着，保持后台运行）。

3. **交互式命令行（最常用）**
   比如 `/bin/bash`、`/bin/sh`。

- *示例*：`docker run -it ubuntu:22.04 /bin/bash`（给你一个终端让你敲命令）。

4. **稍微复杂的组合命令**
   如果想把多条命令连起来写，必须用一个 Shell 解释器（`sh -c` 或 `bash -c`）把它包起来。

- *错误写法*：`docker run ubuntu:22.04 cd /tmp && ls`（Docker 不认识 `&&`，会报错）。
- *正确写法*：`docker run ubuntu:22.04 sh -c "cd /tmp && ls"`（告诉系统，把引号里的内容当作一整条 Bash 语句执行）。

5. **你自己的脚本**
   如果你的镜像里有 Python，你可以直接写 `python3 /app/main.py`；如果里面有木马或靶场脚本，也可以直接指定。

```powershell
# 运行交互式的容器
docker run -it ubuntu:22.04 /bin/bash
# 后台运行
docker run -d ubuntu:22.04 sleep infinity
```

**4. 进入容器**

对比一下: `run` vs `exec` vs `start`

1. **docker run**：**建一个新房子并住进去**。（把镜像变成容器，并启动）
2. **docker start**：**把已经建好的空房子重新开张**。（启动一个已经停止的容器，但**不进去**，在后台跑）
3. **docker exec**：**打开已经开张的房子的大门走进去**。（在**正在运行**的容器里执行命令，比如开个终端）

> **docker铁律:** **不能直接 docker exec 进入一个已经停止（Exited）的容器**

```powershell
C:\Users\dashi>docker ps -a
CONTAINER ID   IMAGE          COMMAND                   CREATED         STATUS                        PORTS     NAMES
9e2e61d7f29a   ubuntu:22.04   "/bin/bash -c 'while…"   2 minutes ago   Exited (137) 20 seconds ago             nervous_lichterman
225891dc6c03   ubuntu:22.04   "/bin/bash -c 'while…"   3 minutes ago   Exited (130) 3 minutes ago              silly_heisenberg

225891dc6c03 为 -it 开启:	docker run -it ubuntu:22.04 /bin/bash -c "while true; do echo hello world; sleep 1; done"
9e2e61d7f29a 为 -d 开启:  docker run -d ubuntu:22.04 /bin/bash -c "while true; do echo hello world; sleep 1; done"

# A: 进入一个停止运行的容器
# 1. 先让刚才的容器在后台跑起来
docker start 9e2

# 2. 进入这个正在运行的容器
docker exec -it 9e2 /bin/bash
root@9e2e61d7f29a:/#

# B：重新创建一个前台容器
docker run it --rm ubuntu:22.04 /bin/bash
```

**5. 删除容器**

> **docker铁律 :  正在运行的容器不能直接删除，必须先停止它（或者强制删除）**

```powershell
C:\Users\dashi>docker ps
CONTAINER ID   IMAGE          COMMAND                   CREATED          STATUS          PORTS     NAMES
9e2e61d7f29a   ubuntu:22.04   "/bin/bash -c 'while…"   33 minutes ago   Up 26 minutes             nervous_lichterman
225891dc6c03   ubuntu:22.04   "/bin/bash -c 'while…"   35 minutes ago   Up 10 minutes             silly_heisenberg

# 先停止再删除, 删除时可以使用 ID 删除且只要可以正确匹配就行
docker stop 9 2
docker rm 9 2 

# 强制删除
docker rm -f 9e2 225

# 一键清理所有“死掉”的容器
docker container prune
```










































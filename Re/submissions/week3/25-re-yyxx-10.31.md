# 常见算法识别
## AES（其他算法在上周作业）
1.明文/密文长度固定为128位，     

2.密钥长度可以是128，192，256位，对应的128位循环10轮，192位循环12轮，256位循环24轮

### 加密过程
无论是明文块还是密钥部分都转化成16进制的4*4矩阵表示形式



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793410099077-2c5a7d90-4916-4eab-a228-1c3825603aff.png)



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793410389936-bd0c88d1-745c-4a83-850b-23d9d9fd5618.png)

最后一轮和前面九轮的的区别是没有第三步的列混和

1.初始变换，将明文矩阵和子密钥矩阵进行异或

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793410626378-29c42205-7a6e-41b6-a281-a58567738f06.png)

 

2.字节代换，通过一个s表将输入的数据的字节映射为另一个字节，例如19，相当于第一行的第九列对应s表中d4，a0相当于第a行的第0列

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793410908063-f267b493-220f-4c63-8e16-e141926d05c6.png)

2.行移位

保持第一行不变，第二行向左移动1个字节，第三行向左移动2个字节，第三行向左移动3个字节

3.列混合

将输入的4*4矩阵左乘一个给定的4*4矩阵

但注意的是该处相乘不是普通的矩阵相乘

原来的矩阵相乘是各部分乘完再相加，但在该处加号变成异或

而相乘也不是一般的相乘

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793413474097-94ccdb2a-7207-4024-8017-bf9b6226e460.png)

4.轮密钥加

将前面已经进行完列混合的密文与子密钥矩阵进行异或，异或为每列与每列异或

子密钥矩阵是由原来4*4密钥矩阵经过密钥扩展得到10个子密钥矩阵，来进行十轮循环

5.密钥扩展

将原来的密钥矩阵按列划分，w0,w1,w2,w3，往右边进行扩展行不变假设扩展第i列

需要判断i是不是4的倍数

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793411954774-6c01155e-f177-46da-aa84-7a9c99da86d8.png)

在i是4的倍数时，需要用到T函数

T函数由3部分组成：字循环，字节代换和轮常量异或

（1）字循环，将1个字中的四个字节循环左移1个字节

（2）字节代换，对字循环的结果使用s盒进行字节代换

（3）将前两步结束的结果用轮常量R从[j]进行异或

         若w[i-1]是4的一倍则与Rcon[1]异或

         若w[i-1]是4的二倍则与Rcon[3]异或....以此类推

### 逆向题的AES特征
<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793413786244-96bca94d-f341-471d-891b-40522b3976b7.png)

## MD5
MD5(128位哈希，不可逆，不是加密），将任意长度消息处理后输出16字节摘要
1.消息总长度bit满足=（同余）mod 512
消息末尾补 0x80，然后补零直到长度 ≡ 448 (mod 512)，最后 64 位填入原始消息的 bit 长度（小端序）。填充后总长是 512 的倍数。
2.初始化4个32位寄存器：

```plain
A = 0x67452301
B = 0xEFCDAB89
C = 0x98BADCFE
D = 0x10325476
```

这里用到小端序常量

把字节序列[01,23,45,67]当作小端32位，数值就是0x67452301

3.分组压缩

每一个 512bit 块，都拿上一轮的 ABCD 作为输入，经过四轮运算，算出新的 ABCD：
一共 4轮，每轮 16 次操作，合计 64 步
每一轮对应一个非线性函数：F、G、H、I
第 1 轮：F (X,Y,Z) = (X & Y) | (~X & Z)
第 2 轮：G (X,Y,Z) = (X & Z) | (Y & ~Z)
第 3 轮：H (X,Y,Z) = X ^ Y ^ Z
第 4 轮：I (X,Y,Z) = Y ^ (X | ~Z)
每次运算：函数结果 + 分组内的 32bit 字 M + 固定 T 常数 → 循环左移指定位数 → 和 b 相加
一轮做完，新 ABCD = 旧 ABCD + 本轮计算出来的值（模 2^32 加法）
处理完一块，得到的 ABCD，作为下一个 512 块的初始值
4. 输出结果
全部分组梳理完毕，把A,B,C,D按顺序拼接（小端），转成32位十六进制字符串就是MD5值

# 常用的python库


<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793420069547-877689de-819a-433b-aeaf-e132834c5fb3.png)

## Pycryptodome
用于各种密码算法

下面的部分就是根据学习文档里的代码，熟悉具体的代码块

```plain
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

key = bytes.fromhex("00112233445566778899aabbccddeeff")
iv = bytes(16)
enc = bytes.fromhex("00112233445566778899aabbccddeeff")

cipher = AES.new(key, AES.MODE_CBC, iv)
plain = cipher.decrypt(enc)

try:
    plain = unpad(plain, 16)
except ValueError:
    pass

print(plain)
print(plain.hex())
```

 导入 AES 密码模块；导入unpad，作用是去掉 PKCS7填充，代码让AI解析的过程中提到了EBC，就详细了解了一下，感觉豆包总结挺好的，就直接截过来了

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793420960123-9b24a66a-4326-4a77-8bbb-6d4930484397.png)

## Z3
可以用来求解约束方程，适合处理线性关系、异或关系、字符约束等。

常用函数

```plain
Solver()：创建求解器
s.add(...)：添加约束条件
s.check()：检查是否有解
s.model()：输出模型，也就是变量结果
```



```plain
from z3 import Solver, BitVec

x = [BitVec(f"x{i}", 8) for i in range(4)]
s = Solver()

for ch in x:
    s.add(ch >= 0x20, ch <= 0x7e)

s.add(x[0] ^ 0x12 == 0x74)
s.add(x[1] + 1 == 0x62)
s.add(x[2] == ord('c'))
s.add(x[3] == ord('d'))

if s.check().r == 1:
    m = s.model()
    print(bytes([m[ch].as_long() for ch in x]))
```

首先导入：Solver=求解器对象，BitVec=位向量（这里就是8位，代表1字节）

创建4个8位变量，x0,x1,x2,x3，每个变量占8bit，正好1字节，代表4个字符

新建一个求解实例，用来添加约束条件

约束：每个字节都属于可见ASCII字符

0X20=空格，0X7e=~

后面添加四个约束条件，用来求解x[0],x[1],x[2],x[3].

s.check():检查约束有没有可行解

如果有解，返回sat，.r==1代表存在解。无解返回unsat

m=s.model(),拿到满足所有约束的模型（也就是各个变量的具体值）

最后依次取出x0,x1,x2,x3的数值，转成bytes打印

### wp
[https://www.nssctf.cn/problem/7073](https://www.nssctf.cn/problem/7073)

用ida打开文件

代码逻辑首先检查输入的内容长度是否为18个字符

alloca是在栈上分配内存，是ida生成的栈分配内存，不影响逻辑

v6数组的0到9部分是输入的7到16部分，v6[10]=0

输入的7到16部分也就是NSSCTF{xx}中间的内容



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793423268844-b27c4b91-380e-48f7-ae34-7eb0437133d7.png)

用于判断flag是否正确是用到cul()函数，打开cul函数之后，发现需要求解的是在各种约束下a1[0]~a1[9],即v6[0]~v6[9]

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793423380496-5620a1dc-c1e8-4c7f-9770-fb1724298a4d.png)

由于条件格式不好看，规整一下

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793425058083-f9b84243-dd7f-4ffe-9443-3d4690f169d1.png)

需要使用z3.solver

进行代码撰写



```plain
from z3 import Solver, BitVec

x = [BitVec(f"x{i}", 8) for i in range(10)]
s = Solver()

for ch in x:
    s.add(ch >= 0x20, ch <= 0x7e)

s.add(2*x[0] + 5*x[1] + 6*x[2] + 4*x[3] + 2*x[4] + 8*x[5] + 8*x[6] + 2*x[7] + 1*x[8] + 5*x[9] == 3976)
s.add(3*x[0] + 5*x[1] + 7*x[2] + 9*x[3] + 7*x[4] + 1*x[5] + 4*x[6] + 6*x[7] + 8*x[8] + 5*x[9] == 5265)
s.add(8*x[0] + 3*x[1] + 7*x[2] + 7*x[3] + 6*x[4] + 5*x[5] + 2*x[6] + 4*x[7] + 7*x[8] + 9*x[9] == 5284)
s.add(9*x[0] + 6*x[1] + 4*x[2] + 3*x[3] + 6*x[4] + 5*x[5] + 7*x[6] + 9*x[7] + 8*x[8] + 7*x[9] == 5925)
s.add(3*x[0] + 4*x[1] + 1*x[2] + 2*x[3] + 6*x[4] + 5*x[5] + 8*x[6] + 2*x[7] + 7*x[8] + 3*x[9] == 4048)
s.add(5*x[0] + 8*x[1] + 6*x[2] + 4*x[3] + 4*x[4] + 4*x[5] + 7*x[6] + 9*x[7] + 3*x[8] + 7*x[9] == 5072)
s.add(2*x[0] + 2*x[1] + 3*x[2] + 2*x[3] + 1*x[4] + 7*x[5] + 2*x[6] + 5*x[7] + 3*x[8] + 2*x[9] == 2813)
s.add(1*x[0] + 7*x[1] + 7*x[2] + 8*x[3] + 7*x[4] + 3*x[5] + 7*x[6] + 5*x[7] + 3*x[8] + 6*x[9] == 5004)
s.add(5*x[0] + 9*x[1] + 1*x[2] + 9*x[3] + 5*x[4] + 5*x[5] + 5*x[6] + 5*x[7] + 2*x[8] + 1*x[9] == 4490)
s.add(6*x[0] + 4*x[1] + 8*x[2] + 6*x[3] + 6*x[4] + 8*x[5] + 5*x[6] + 7*x[7] + 6*x[8] + 7*x[9] == 5936)

if s.check().r == 1:
    m = s.model()
    print(bytes([m[ch].as_long() for ch in x]))
```





<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793426408909-1abb9c4e-68ae-4317-b648-56c2a9417d88.png)

从而获得flag:NSSCTF{Z3_solver!}

### wp
题目来源：[https://ctf.xidian.edu.cn/training/22?challenge=880](https://ctf.xidian.edu.cn/training/22?challenge=880)，其中的ez3题

下载完附件并解压之后，发现不是正常的exe文档，我将文件拖入到DIE里经过分析，发现是ELF64(linux64位可执行文件),无法在Windows上打开，但仍然可以拖入ida进行编译



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793498499064-b751e288-a298-4059-85bd-777184b7c715.png)

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793498672552-4a486f74-78b9-4d4d-b598-7701f6f0ce87.png)

感觉代码像是c语言，但同时有参杂好多别的东西，询问了AI

 大量 std::string::xx这是 c++string类函数，不是 C 语言  ,不需要详细的了解

大概的逻辑是先判断用户输入的开头7位是否为moectf{,最后一位是否是}

再将用户输入的中间34位带入check函数

于是点开check函数查看逻辑

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793498994697-984144fa-a368-4786-8598-e0e11c0219e4.png)

可以看出是给了一个异或限制，需要我们在异或限制的条件下求解出b[i]的值

由于我学识浅薄波，有些部分看不懂

check(std::string)::b[i] = 47806 * (*(char *)std::string::operator[](a1, i) + i);

经过对AI的询问

这句代码相当于b[i]=0xbabe*(s[i]+i),即将s[i]+1的结果乘以十六进制0xbabe,赋值给b[i]

std::string::operator[](a1, i),意思是取a1这个string的第i个字符

47806=0xbabe

最后发现需要对比b[i]加密后的内容和a1

进入a1

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793502140805-e31e26ed-2ec1-4577-945c-598c0966e213.png)

知道限制条件之后，调用z3库写代码比运行



```plain
from z3 import *

N = 34

solver = Solver()

a=[45488,22136,32754,41778,41192,13900,11220,51454,19068,24,11236,16708,15270,48780,36734,13816,25002,11082,26664,45982,46402,13292,51160,17548,37648,34824,44500,15554,1942,51520,20018,20014,37450,23388]
s = [BitVec(f's_{i}', 32) for i in range(N)]

for i in range(N):
    solver.add(And(s[i] >= 32, s[i] <= 127))

b = [0] * N
for i in range(N):
    b[i] = (s[i] + i) * 0xbabe
    if (i > 0):
        b[i] ^= b[i - 1] ^ 0x114514
    b[i] %= 0xcafe
    solver.add(b[i] == a[i])

# 检查是否有解
if solver.check() != sat:
    print("无解")
else:
    # 获取第一个解
    while (solver.check() == sat):
        model1 = solver.model()
        print("找到一个解：")
        sol1 = [model1[s[i]].as_long() for i in range(N)]
        print(''.join([chr(c) for c in sol1]))
        
        solver.add(Or([s[i] != model1[s[i]] for i in range(N)]))
```



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793499652961-f946659b-3d15-497f-bcb6-22e06df04f5a.png)

运行完发现有两种解



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793499688787-930667c8-f495-4cac-a46c-6b0a4d939812.png)



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793499700631-b2afd268-ca4c-49a4-82b0-afadecbc1a55.png)

只有一个解满足情况

### wp
这个exe文件在终端运行时窗口一闪而过很奇怪

将文件用ida打开，F5并不在是简单的伪代码，对于我这种新手来说有点难，然后我就让ai帮我分析了一下代码



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793537519704-2ec827b6-21cc-440d-a301-39dc52687cfe.png)

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793537617021-fcd01788-50bd-4516-a09f-e7e4ba0f431f.png)

原来是sleep(1u)导致窗口一闪而过，我就直接在这里下断点，F9运行



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1793537698385-0123cd77-813c-4280-b28e-55ec87b4e629.png)

flag自动显示在屏幕上






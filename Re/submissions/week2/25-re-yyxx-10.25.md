# 基础可逆运算
## 异或XOR
### 概念
 异或是**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">按位二进制运算</font>**，是逆向、简单加密、程序混淆里最常用的运算。  

规则：相同为0，不同为1

即两个bit一样--输出0，两个bit不一样--输出1

### 多字节
逐位单独算，高位与低位不相关，不进行进位

<font style="color:rgb(0, 0, 0);"> </font>

```plain
  0101   (5)
^ 0011   (3)
--------
  0110   (6)
```

### <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">自反性</font>
<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">a⊕k⊕k=a</font>

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">同一个key异或两次，变回原值</font>

### <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">逆向中常见的使用</font>
1. 简单字符串加密：字符串每个字节依次和固定 key 异或，IDA/Ghidra 里非常多见  

```plain
char buf[] = "hello";
char key = 0x23;
for(int i=0;buf[i];i++){
    buf[i] ^= key; // 加密；再跑一遍就是解密
}
```

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">2.花指令、代码混淆，用 xor 修改寄存器值</font>

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">3.内存补丁、简单壳、字节混淆</font>

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">4.交换两个变量，不用临时变量：</font>

```plain
a ^= b;
b ^= a;
a ^= b;
```

## 按位与AND
### 概念
概念：按二进制每一位进行比较，只有两个位置都是 1，结果才是 1

 AND **<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">是不可逆运算</font>**，多对一映射，逆向里只会用来提取、屏蔽、判断 bit，不能用来加密还原数据（和 XOR 不一样）  

### 常见使用
1. 掩码，提取指定的几位  

例如，取低四位

```plain
0xAB → 10101011
&0x0F → 00001111
=0x0B → 00001011
```

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">RE 场景：</font>

+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">拆分一个字节成高低 4bit，自定义编码、简单校验、颜色 RGB565、协议解析</font>
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">从一个 flag 整数里拿出某几个标志位</font>

2.限制结果在1字节范围内

 1 字节 = 8bit，范围 0 ~ 0xFF（0b11111111）  

对应公式：

```plain
result = value & 0xFF;
```

re场景:

+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">把 32 位寄存器（eax）里的值截取成 al（8 位）等效操作</font><font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">汇编：</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">and eax, 0FFh</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">，反编译看到 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">v1 & 0xFF</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">很多自定义加密、校验、CRC、简单哈希都会这么做，保证每次计算结果维持在一字节。</font>
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">防止数值溢出，取字节结果比如：</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">sum = (sum + key) & 0xFF;</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">相当于</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">8 位无字节加法自动截断</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">，等价于 uint8_t 溢出行为</font>

3.模拟c语言无符号整数溢出

 C 语言标准规定：**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">无符号整数的溢出不是 UB（未定义行为），是按模自动取余</font>**。  

`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">uint8_t / uint16_t / uint32_t</font>` 算的时候如果超出它能存的最大值，**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">自动截断、扔掉高位，等价于 </font>**`**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">结果 & 对应全1掩码</font>**`，这就是无符号溢出。  

## 加减运算
### 概念
加减运算要注意是否限制在 1 字节范围内。

```plain
x = (0xff + 1) & 0xff
print(hex(x)) # 0x00
```

1. `<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">0xff</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> = 255（uint8 一字节的最大值）</font>
2. `<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">0xff + 1</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> = 256</font>
3. `<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">256 & 0xff</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> → 只保留低 8bit，高位直接丢弃，结果 = 0</font>

### 需要注意的是：
<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">Python 的整数</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">是无限长的，不会自动溢出截断</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">；但是 C 语言里 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">unsigned char</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">（uint8_t）加法溢出时，会自动丢掉高位、只保留低 8bit。所以我们在 Python 写脚本还原逆向算法的时候，</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">手动加上 </font>**`**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">& 0xff</font>**`**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">，就是模仿 C 的 unsigned char 溢出行为</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">。</font>

## 位移
### 概念
`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"><<</font>` 左移、`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">>></font>` 右移，**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">Python 里是逻辑移位</font>**，配合 `<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">&0xff</font>` = 模拟 C 语言 `<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">unsigned char（1字节8bit）</font>` 的移位，这是逆向写脚本的标准写法。  

```plain
x = 0x91
print(hex((x >> 2) & 0xff))
print(hex((x << 3) & 0xff))
```

右移两位：

 右边两位 `<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">01</font>` 直接被挤出去丢掉了。`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">00100100</font>` = `<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">0x24</font>`

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">左移三位：</font>

`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">0 1 0 0 0 1 0 0</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> = </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">0x44</font>`

## <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">取反与转换</font>
```plain
x = 0x12
print(hex((~x) & 0xff))

a, b = 1, 2
a, b = b, a
```

### 概念
`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">~x</font>` 按位取反（NOT）  

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">先转 8 位二进制：</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">0x12</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> → </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">00010010</font>`

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">单纯按位取反（8bit 视角）：</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">11101101</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> → 这个值是 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">0xED</font>`

### <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">注意:</font>
<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">Python 整数是</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">无限长补码</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">18 的二进制：</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">...00000000 00010010</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">按位全部取反：</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">...11111111 11101101</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">这串补码代表的数就是 </font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">-19</font>**

因此，<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">模拟 C 语言 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">unsigned char</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> 的取反，必须加上 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">&0xff</font>`

# <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">常见算法识别</font>
## base64
### <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">概念：</font>
<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">Base64 </font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">不是加密！只是编码</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">，它只是把二进制数据，转成可打印的 ASCII 字符串，没有密钥，可以直接解码还原。</font>

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">标准 Base64 的字符表一共 64 个字符：</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">A-Z、a-z、0-9、+、/</font>`

`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">=</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> 是填充符，</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">不属于 64 个编码字符</font>**

**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> Base64 是3 字节原始数据 → 4 个 base64 字符为一组。如果原始字节数不是 3 的倍数，末尾就要用</font>**`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">=</font>`**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">补齐到 4 个字符为一组</font>**

+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">剩 1 个原始字节 → 末尾补 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">==</font>`
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">剩 2 个原始字节 → 末尾补 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">=</font>`
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">刚好是 3 的倍数 → 末尾没有等号</font>

python采用base64（自定义表）一般的加密和解密

```plain
import base64
std_table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

def custom_b64_decode(enc, table):
    tmp = ""
    for c in enc:
        if c == '=':
            tmp += '='
        else:
            idx = table.index(c)
            tmp += std_table[idx]
    return base64.b64decode(tmp)

my_table = "zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA9876543210/+"

# 先编码得到合法密文（配套这个my_table）
def custom_b64_encode(data, table):
    tmp = ""
    b64s = base64.b64encode(data).decode()
    for c in b64s:
        if c == '=':
            tmp += '='
        else:
            i = std_table.index(c)
            tmp += table[i]
    return tmp

plain = b"hi"
cipher = custom_b64_encode(plain, my_table)
print("密文：", cipher)
res = custom_b64_decode(cipher, my_table)
print("解码结果：", res)
```

### wp
题目来源：[https://ctf.xidian.edu.cn/training/22?challenge=871](https://ctf.xidian.edu.cn/training/22?challenge=871)

用ida打开，在伪代码界面看到主函数判断输入是否符合的逻辑是将输入与一串东西进行比较，猜测是base64表加密过后的密文



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792837793469-ea75f434-8df7-4fe8-80de-c91036535740.png)

一般是在Strings（字符串窗口）查找base64表

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792837871107-8b5a90d7-b853-47da-81ab-2f19e1beb9ac.png)

发现作者使用的就是最基本的base64表

在这里可以直接使用解密工具，来得到flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792837940377-9ff87e90-d121-4b08-8687-59d5a4612e7b.png)

## RC4 
RC4 是流加密，核心是先打乱一个 256 长度的 S 盒，再生成密钥流和数据异或。

RC4 分两大阶段：KSA + PRGA  

### <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">阶段 1：KSA 密钥调度算法（打乱 S 盒）</font>
<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">S 盒是长度固定 256 的数组，一开始 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">S[0]=0,S[1]=1,...,S[255]=255</font>`

```plain
i从0到255循环：
    j = (j + S[i] + key[i % len(key)]) % 256
    swap(S[i], S[j])   # 交换！就是课件说的交换操作
```

###  阶段 2：PRGA 伪随机生成算法（产出密钥流）  


```plain
i=0,j=0
循环（循环次数 = 明文长度，每次输出1字节密钥流）：
    i = (i + 1) % 256
    j = (j + S[i]) % 256
    swap(S[i], S[j])      # 继续交换S盒元素
    t = (S[i] + S[j]) % 256
    keystream_byte = S[t]
```

 拿到 `<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">keystream_byte</font>`，和输入数据异或，完成加解密  

其中第二阶段产生密钥流的算法是固定的

**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">密钥流需要多少字节，由【要加密 / 解密的数据长度】决定，不是随便自定义的。</font>**

<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">IDA 里 F5 反编译看到下面特征，基本就是 RC4：</font>

1. <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">定义 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">S[256]</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> 数组，先循环赋值 0~255</font>
2. <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">两层循环，循环里面反复出现 </font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">swap 交换两个变量</font>**
3. <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">有 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">i,j</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> 两个索引变量，公式 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">j = j + S[i] + key[...] %256</font>`
4. <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">之后再循环，继续 swap、取出 S [t]，然后异或数据</font>

### wp1
题目来源： [https://www.nssctf.cn/problem/4596](https://www.nssctf.cn/problem/4596)

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792841396974-1a6471be-890e-405a-a348-8738bac570c4.png)

双击rc4_crypt查看函数逻辑

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792841444939-a4620de5-45ce-4844-8086-f976400116cd.png)

其中rc4_init....为RC4的第一阶段获得密钥流，下面的 for 循环 → **<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">PRGA 生成密钥流 + 和数据异或</font>**

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792841302172-16814c6d-e339-4442-a374-b352e14fc134.png)

这部分是对伪代码给出key的疑惑部分

接下来分析完题目进行解密

 C 语言里的 `<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">signed char</font>`（有符号字符），取值范围是 **<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">-128 ~ +127</font>**；但是 RC4 运算、计算机底层存字节的时候，我们需要的是 **<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">unsigned char（无符号字节），范围 0 ~ 255</font>**。  因此需要将data部分的负数+256转化为正数，正数部分不变

转化完之后<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">235,13,97,41,191,155,5,34,243,50,40,151,227,134,77,45,90,42,163,85,170,213,180,108,139,81,177</font>

```plain
def rc4(key: bytes, data: bytes, keylen: int) -> bytes:
    S = list(range(256))
    j = 0
    # KSA rc4_init，这里keylen=0x10=16
    for i in range(256):
        j = (j + S[i] + key[i % keylen]) & 0xff
        S[i], S[j] = S[j], S[i]
    i = j = 0
    out = bytearray()
    for b in data:
        i = (i + 1) & 0xff
        j = (j + S[i]) & 0xff
        S[i], S[j] = S[j], S[i]
        t = (S[i] + S[j]) & 0xff
        ks_byte = S[t]
        out.append(b ^ ks_byte)
    return bytes(out)

cipher = bytes([
235,13,97,41,191,155,5,34,243,50,40,151,227,134,77,45,90,42,163,85,170,213,180,108,139,81,177
])
key = b"wanyuanshenwande"
key_len = 0x10 # 显式写出来，和IDA的0x10u对应
res = rc4(key, cipher, key_len)
print(res.decode("utf-8"))
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792843587858-500c07e9-167f-4fd9-b74f-48d04ffd40a8.png)

运行这个python脚本之后，获得flag

### wp2
题目来源：

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792919074250-3d95fa96-70c0-47ca-943b-acf66a839e1d.png)

rc4-init是RC4的KSA阶段rc4-crypt是加密的第二阶段，根据逻辑判断enc_0[]数组蕴含的数据就是我们需要的密文，点击enc_0之后按shify+E就可以提取密文

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792919256751-a577eb68-468a-41a9-8f03-22c9183d9630.png)

然后需要查看rc4的加密具体方式分别点击两个步骤的函数

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792919956916-1c6b0f37-caa1-4b73-8189-e2a5a69c13c4.png)

发现两个函数里使用数组指针，实在是再难看了，于是问了豆包，我们按下键盘的\键，我们对着miyao按y，输入byte* miyao，a1同理。发现直接转换成正常的伪代码格式，666太厉害了

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792919973768-d80c1031-ad61-45d5-a3c1-7861058144d8.png)

发现只对输入进行一次异或加密，就是最一般的加密情况。代码部分省略跟上一个题差不多，运行之后找到flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792920083289-b61ee097-5a94-4988-b531-003df6e4e9a5.png)

## Tea
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">分组：</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">64bit = 8 字节</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">，一组拆成两个 32 位数 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">v0, v1</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">(需要加密的数据）</font>
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">密钥：</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">128bit = 16 字节</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">，拆成 4 个 32 位数 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">k0,k1,k2,k3</font>`
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">delta 常量：</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">0x9E3779B9</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">（黄金比例常数）</font>
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">标准轮数：</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">32 轮</font>**
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">每一轮核心运算：移位 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"><<4</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">、</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">>>5</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">、加法、异或 ^</font>

### 加密公式
```plain
delta = 0x9E3779B9
sum = 0
循环 32 次：
    sum += delta
    v0 += ((v1 << 4) + k0) ^ (v1 + sum) ^ ((v1 >> 5) + k1)
    v1 += ((v0 << 4) + k2) ^ (v0 + sum) ^ ((v0 >> 5) + k3)
```

### 解密公式
```plain
delta = 0x9E3779B9
sum = delta * 32 & 0xffffffff
循环 32 次：
    v1 -= ((v0 << 4) + k2) ^ (v0 + sum) ^ ((v0 >> 5) + k3)
    v0 -= ((v1 << 4) + k0) ^ (v1 + sum) ^ ((v1 >> 5) + k1)
    sum = (sum-delta) & 0xffffffff
```

### wp
题目来源：[https://ctf.xidian.edu.cn/training/14?challenge=589](https://ctf.xidian.edu.cn/training/14?challenge=589)

程序用ida打开查看伪代码，原本的函数名称非常混乱，此处已经修改了函数名称，观察伪代码的逻辑，函数TEA将用户输入的字符串进行TEA加密并与地址unk_140004080的内容进行比较

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792927698684-61d8b36b-f170-4124-baf3-8ee19aa2350f.png)

点击unk_140004080之后查看相应的密文

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792927959366-c1a56cbf-230b-43c2-a749-50c011bcefd7.png)

然后在查看TEA具体的函数逻辑

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792928069248-55d16096-8d18-4c47-98e6-b97de717a9b9.png)

但在这里使用sum-=1640531527,与正常的加密算法不太一样

1640531527十进制就是0x61C88647。所以减法减正数1640531527，在模2^32中就是加它的补数0x9E3779B9，因此sum-=1640531527等价于sum += 0x9E3779B9,与正常的TEA加密算法一样

```plain
import struct

def tea_dec(v0, v1, k0, k1, k2, k3):
    delta = 0x9E3779B9
    sum_ = (delta * 32) & 0xFFFFFFFF

    for i in range(32):
        v1 = (v1 - (
            ((k3 + (v0 >> 5)) & 0xFFFFFFFF) ^
            ((sum_ + v0) & 0xFFFFFFFF) ^
            ((k2 + ((v0 << 4) & 0xFFFFFFFF)) & 0xFFFFFFFF)
        )) & 0xFFFFFFFF

        v0 = (v0 - (
            ((k1 + (v1 >> 5)) & 0xFFFFFFFF) ^
            ((sum_ + v1) & 0xFFFFFFFF) ^
            ((k0 + ((v1 << 4) & 0xFFFFFFFF)) & 0xFFFFFFFF)
        )) & 0xFFFFFFFF

        sum_ = (sum_ - delta) & 0xFFFFFFFF

    return v0, v1

def bytes2uv(b8):
    return struct.unpack("<II", b8)

def uv2bytes(a, b):
    return struct.pack("<II", a, b)

cipher = bytes([
    0x78, 0x20, 0xF7, 0xB3, 0xC5, 0x42, 0xCE, 0xDA, 0x85, 0x59,
    0x21, 0x1A, 0x26, 0x56, 0x5A, 0x59, 0x29, 0x02, 0x0D, 0xED,
    0x07, 0xA8, 0xB9, 0xEE, 0x36, 0x59, 0x11, 0x87, 0xFD, 0x5C,
    0x23, 0x24
])

key_bytes = b"WelcomeToNewStar"
k0, k1, k2, k3 = struct.unpack("<IIII", key_bytes)

res = b""
for n in range(4):
    blk = cipher[n*8:n*8+8]
    cv0, cv1 = bytes2uv(blk)
    pv0, pv1 = tea_dec(cv0, cv1, k0, k1, k2, k3)
    res += uv2bytes(pv0, pv1)

print(res)
try:
    print(res.decode())
except Exception:
    pass
```

运行之后找到flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792928554017-24547e9d-b089-4f16-a8e9-db634ea0bfd3.png)

## XTEA/XXTEA
 TEA 家族（TEA、XTEA、XXTEA）都是**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">轻量块密码，只使用加减、移位、异或，非常适合逆向 CTF</font>**；公用魔数：`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">delta = 0x9E3779B9</font>`（黄金比例常数，固定），密钥固定都是 **<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">128bit（4 个 uint32[32位]，k [0],k [1],k [2],k [3]）</font>**

### **<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">XTEA</font>**
不是很理解XTEA与TEA的区别，进行查询

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1792921146031-e5485898-4b4e-4125-828f-6d4d41c4f0bf.png)

相应的加密代码

```plain
delta = 0x9E3779B9;
uint32_t sum = 0;
for (int i = 0; i < 32; i++)
{
    v0 += ( ((v1 << 4 ^ v1 >> 5) + v1) ^ (sum + k[ sum & 3 ]) );
    sum += delta;
    v1 += ( ((v0 << 4 ^ v0 >> 5) + v0) ^ (sum + k[ (sum >> 11) & 3 ]) );
}
```

### XXTEA
在XTEA中只能加密64为数据，而XXTEA可以加密任意数量

+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">明文：</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">N 个 uint32（n 可以≥2，任意数量！）</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">，这就是笔记写的：</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">数据块数量可以大于 2</font>**
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">密钥：同样 128bit，4 个 uint32 k [0~3]</font>

 轮数不是固定值！动态公式：`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">rounds = 6 + 52 / n</font>`

+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">n = 数组里面 32bit 元素的个数</font>
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">n 越小，轮数越多；n 越大，轮数越少，保证充分混淆，是 XXTEA 最强识别特征</font>

加密的核心代码

```plain
delta = 0x9E3779B9;
uint32_t sum = 0;
uint32_t rounds = 6 + 52 / n;
for (uint32_t r = 0; r < rounds; r++)
{
    uint32_t e = (sum >> 2) & 3;
    uint32_t p;
    for (p = 0; p < n; p++)
    {
        uint32_t prev = v[(p - 1 + n) % n]; // 重点：p的前一个元素！环形
        v[p] += ( ((prev >> 2 ^ v[p] << 3) + ((v[p] >> 4 ^ prev << 5)) ) ^ (sum + k[(p ^ e) & 3]);
    }
    sum += delta;
}
```

+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">XTEA 永远只有两个变量 v0、v1，互相影响，是固定两点；</font>
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">XXTEA 一整个环上</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">所有 32 位数互相牵连</font>**<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">：每一个元素 </font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">v[p]</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);"> 的加密依赖它环形上的前一个元素。</font><font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">改动任意一个元素，一圈全部都会被慢慢影响扩散，混淆效果更强。</font>
+ <font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">轮数不是固定值：</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">rounds = 6 + 52 / n</font>`<font style="color:rgb(0, 0, 0);background-color:rgba(0, 0, 0, 0);">n 越小（数组越短），轮数越多；n 越大，轮数越少，保证充分搅乱环形上的数据。</font>


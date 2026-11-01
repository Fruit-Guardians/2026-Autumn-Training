# 24\-re\-qiuyu\-1025

# Writeup

- ID:qiuyu

- 方向：Re

- 日期：2026/10/25



# python数据处理准备

我将每一个处理自己尝试了一遍

## **字符和数字互转**

```Plain Text
print(ord('B'))    #输出6
print(chr(66))    #输出B
```

## **数组转字符串**

```Plain Text
data = [0x66, 0x6c, 0x61, 0x67]
print(''.join(chr(x) for x in data))
```

输出的是flag

查询怎么将翻译出的

## **hex 字符串转 bytes**

```Plain Text
s = "666c6167"
data = bytes.fromhex(s)
print(data)
```

输出“b'flag'”

原理：两个十六进制字符 = 一个字节，"66" → 0x66 → f

bytes\.fromhex\(\) 会自动忽略中间的空格

## bytes 转 hex

```Plain Text
data = b"flag"
print(data.hex())
```

输出666c6167将字符转16进制

## **单字节 xor**

```Plain Text
enc = [0x74, 0x7e, 0x73, 0x75]
key = 0x12
print(''.join(chr(x ^ key) for x in enc))
```

输出flag

## **小端序转换**

```Python
data = bytes.fromhex("78563412")
num = int.from_bytes(data, "little")
print(hex(num))  # 0x12345678
```

输出0x12345678

第 1 行：字符串 → bytes

第 2 行：bytes → 整数

第 3 行：整数 → 十六进制形式的字符串

## **多字节循环 key**

```Python
def xor_cycle(data, key):
    return bytes([b ^ key[i % len(key)] for i, b in enumerate(data)])

enc = bytes.fromhex("01020304")
key = b"key"
print(xor_cycle(enc, key).hex())
```

输出6a677a6f

# 基础加密与数据处理

## **位、字节和整数**

flag对应66 6c 61 67

字符串：flag\{test\}
字节数组：66 6c 61 67
C 数组：\{0x66, 0x6c, 0x61, 0x67\}
十六进制字符串：666c6167
32 位整数：0x67616c66

1 byte = 8 bit
1 字节范围 = 0x00 \~ 0xff
十进制范围 = 0 \~ 255
二进制范围 = 00000000 \~ 11111111

## **大小端序**

大端序：高位字节在前。

小端序：低位字节在前。

## 数据填充

1. Zero Padding

原始数据：48 45 4c 4c 4f     （HELLO）

填充后：  48 45 4c 4c 4f 00 00 00

2. 固定字符填充

原始数据：48 45 4c 4c 4f            \(HELLO\)

填充后：  48 45 4c 4c 4f 23 23 23    \(\# 的 ASCII 是 0x23\)

缺陷是当最后一部分正好是\#分不清是填充还是需要的

3. PKCS7（长度填充）

原始数据：48 45 4c 4c 4f            \(5 字节，差 3\)

填充后：  48 45 4c 4c 4f 03 03 03

缺 N 个字节，就补 N 个值为 N 的字节

实战注意事项

# 基础可逆运算

## 异或XOR

A ^ B ^ B = A

## 按位与AND

与运算 同真才真

常见用途：

- 限制结果在 1 字节范围内。

- 取低位。

- 模拟 C 语言无符号整数溢出。

## 加减运算。

```Python
x = (0xff + 1) & 0xff
print(hex(x))  # 0x00
```

\& 0xff 就是只留低 8 位，其余清零

如果 C 代码中使用 `unsigned char`，Python 里通常需要加 `& 0xff` 模拟溢出。

## 位移

\>\> 右移
\<\< 左移

```Plain Text
x = 0x69
print(hex((x >> 2) & 0xff))  #0x1a
print(hex((x << 3) & 0xff))  #0x48
```

0x69 = 105 = 0 1 1 0 1 0 0 1

右移：0 0 0 1 1 0 1 0  1a

左移：0 1 1 0 1 0 0 1 0 0 0    348单字节放不下即0x48

## 取反和交换

```Python
x = 0x12
print(hex((~x) & 0xff))    #0xed

a, b = 1, 2    
a, b = b, a    #2，1
```

# 常见算法识别

## Base64

常见特征：

- 字符串只包含大小写字母、数字、`+`、`/`、`=`。

- 结尾可能有 `=` 或 `==`。

- CTF 中可能出现换表 Base64。

### 关于base64题

1. 第一题

地址：https://www\.nssctf\.cn/problem/2654

环境：win11

工具：IDA

打开ida

搜索flag

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=MGVmMTYxZWNmYjJmMjMwZTAxZDMzNWRiMWQ1MjE4ZmZfYjJkYmYwY2NkMjIyZmU4MzI4NzU5NjUxZjBmMzk5OTNfSUQ6NzcwMDU2ODYxMDMzNTIzMDk2OF8xNzkyOTMwNjU2OjE3OTMwMTcwNTZfVjM)

看到在main函数

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=ZTcxNzY4M2M3ZGU5MzM0Yjc0ZDFhMjc0NTU5NTMzNTBfNDY1YWQzODFhZmI5YjA3NjQzNjgyNGU3NmFhOGExY2ZfSUQ6NzcwMDU2ODkyMzEyMDQ4NzY5OV8xNzkyOTMwNjU2OjE3OTMwMTcwNTZfVjM)

跳转到相应的汇编界面

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=MmZhZWMzZjI3MTFkZjE0YzdiOWFlMmY4NGU4NDA2OGFfYzU2MGNjNzQyMDMzMDJiNTk3MDc1MDVjNjVmYTE1MTJfSUQ6NzcwMDU2OTIxMDI3MDkxMTcyOV8xNzkyOTMwNjU2OjE3OTMwMTcwNTZfVjM)

找到与base64相关的=解码

NSSCTF\{base\_64\_NTWQ4ZGDNC7N\}

2. 第二题

地址：https://www\.nssctf\.cn/problem/3778

环境：win11

工具：IDA upx

打开ida

发现有问题只有5个函数估计有壳

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=YjFjNDgxZGY5NzZlMThhMjlhODhjNGI3MWJiN2ExMDFfZTZhZWU4Y2JkNTdjMGQ5MmE3NGQ5ZDExZTkxMWVkYTNfSUQ6NzcwMDU3MzYxNTY1NzQzODIwOF8xNzkyOTMwNjU2OjE3OTMwMTcwNTZfVjM)

题目写upx脱壳于是我脱完再用ida打开

直接搜索flag

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=ZGRjNWJlZjU3NDUxMjJiNDI4ZWI1YTZkY2MwM2ZjM2RfNWE2MzQ3NjQ3N2Y2ZTk3NTJiYTRiYzcyNGIyZTg4MzZfSUQ6NzcwMDU3NDU4MDg5Mjg5NjQ2MF8xNzkyOTMwNjU2OjE3OTMwMTcwNTZfVjM)

看到"Congratulations\! You get the flag“找对应位置

找上一步

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=MTZhODRhM2JhMzY2NTgyNGRkZmE3OWJlNjUxZGE3MWNfM2Y1MTkxZDU4ZjUyMDAyZDM2M2EyMTA3ZDc5MjBlOTZfSUQ6NzcwMDU3NTAwMTA2NTY1NTIyOF8xNzkyOTMwNjU2OjE3OTMwMTcwNTZfVjM)

看到一串字符进入汇编语句

![Image](https://internal-api-drive-stream.feishu.cn/space/api/box/stream/download/authcode/?code=YmQ3ZDE2ZTNmZTljYmM0NDdiNTgxMGVmN2MwZTMwZjJfOWFhYzA2NzdlNzgzMTExOTBmNDg1OGRjYzU4YmE3MjZfSUQ6NzcwMDU3NjY1OTY2MDkxODAwOV8xNzkyOTMwNjU2OjE3OTMwMTcwNTZfVjM)

用base64解密

HDCTF\{Y0u\_h@v2\_/\\/\\@57er3d\_7he\_r3v3rs3\}






题目来源：[https://ctf.xidian.edu.cn/training/22?challenge=880](https://ctf.xidian.edu.cn/training/22?challenge=880)

## catch
<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1794054085146-d3d16fa1-7f1a-40cf-ad55-d863bdc1fa6b.png)

 容易分析发现 try 里面一定会抛出异常，而sub_114514是一个没有副作用的函数, 也就是说 try 里面相当于什么都没干. 我们可以把 try 和 cleanup 的部分全部 patch 成 nop 再重新反编译, 可以看到真正的逻辑.



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1794055535839-d0e0b08d-33bf-44ca-b618-db9e255bbfd1.png)

nop完之后ida就能正常显示伪代码逻辑

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1794055589426-ffb40cb1-f4b0-4430-ada6-a3297d793290.png)

双击进入solve(void)::hidesuwa，发现他的内容zbrpgs{F4z3_Ge1px_jvgu_@sybjre_qrfhjn}

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1794055667316-7c9f1ae4-f209-4f6d-8c54-2bed7f0c7952.png)

根据已经知道的函数逻辑进行代码编写



```plain
cipher = "zbrpgs{F4z3_Ge1px_jvgu_@sybjre_qrfhjn}"

def decrypt_by_pseudocode(s):
    result = ""
    for char in s:
        c = ord(char)
    
        if 97 <= c <= 122: # islower
            c = (c - 84) % 26 + 97
       
        elif 65 <= c <= 90: # isupper
            c = (c - 52) % 26 + 65
        result += chr(c)
    return result

print(decrypt_by_pseudocode(cipher))
```

执行一下就能显示flag



<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1794055870966-dc50964c-d2b6-4566-a66a-df0470920b45.png)

## UPX
根据题目大概率是被加壳了，拖入到IDE里查看，发现确实被加壳了

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795250749737-00a574ec-0b3c-4536-9cbf-b245def9fd5d.png)

进行脱壳处理

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795251014487-beb365fd-7b85-4ae6-a39f-06fe2bf55b8f.png)

再用ida正常打开

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795251126465-05d4d994-aee7-4571-8d5c-305f015b96e5.png)

根据逻辑发现是将输入的flag进行异或处理并与v10比较

但我对比较的过程不是很清楚，进行相应语法的搜索

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795253027131-2e19d59c-0321-44e6-8905-dd63aefa6ccd.png)

查看v10数组存储的数据，IDA写的这串十六进制，是从高位写到低位，但在实际存储的时候X86内存是小端，低字节放在低地址

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795253113812-e42b0a17-92f8-4c59-9645-673cb9d9cbdd.png)，

在对V10数组进行比较的时候，将V10数组每一组数拆成4个DWORD，并将低字节放在前面

例如:xmmword_1400032B0 xmmword 0A0000001C0000003700000015h

拆成4个DWORD

```plain
D0: 0x00000015
D1: 0x00000037
D2: 0x0000001C
D3: 0x0000000A
```

在程序 .rdata常量端内存排布（地址从低到高）

```plain
0x1400032B0: 15 00 00 00   // D0 (0x00000015) 小端字节
0x1400032B4: 37 00 00 00   // D1 (0x00000037)
0x1400032B8: 1C 00 00 00   // D2 (0x0000001C)
0x1400032BC: 0A 00 00 00   // D3 (0x0000000A)
```

在与V10进行比较是相当于

```plain
v14[0] = dword0 of v10[0]
v14[1] = dword1 of v10[0]
v14[2] = dword2 of v10[0]
v14[3] = dword3 of v10[0]
v14[4] = dword0 of v10[1]
v14[5] = dword1 of v10[1]
...
```

同时需要注意的是，比较的范围V5<35,v5从0开始,而v10一开始固定的是32个数字，但从为代码里可以看出

v11 = 41; v12 = 36; v13 = 86;顺沿这V10最后一个数字继续存储，总共构成了35个数

进而根据伪代码逻辑编写解密脚本

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795254154651-42a4bd68-324e-4d78-9449-01f695bf2387.png)

获取flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795254179665-08650e05-7c6c-44e7-877a-4fb1a402ad4a.png)

## ezandroid
解压完成之后发现不是正常的exe文件，APK文件涉及java代码，需要用jadx打开

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795254257740-f7c5b344-e9ea-448d-82a9-6d4db7a9ea4e.png)

一般来说先进入入口查看main activity，一眼看出用到了base64表，注意到有一串字符符合64表特征，直接进行解密

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795254635388-da4c3003-24c6-43d0-b2b6-29528ea59215.png)

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795254868654-0f7db368-8cb0-42fc-86de-46b74e671c61.png)

## flower
解压完不是正常的exe文件需要用IDE打开

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795255367867-cea968e7-6b2c-4381-b444-fc6a4324f1aa.png)

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795255427821-45769265-681f-4488-af37-274ee2a8087d.png)

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795256605504-57974013-9648-44ce-9768-11857e7cd8f5.png)

按顺序打开check函数查看

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795256668031-0ee0737d-c718-456a-88ef-bca19f8481c7.png)

发现他是检测该程序是否进行了调试，如果没调试则正常继续跑，如果被调试，则程序终止

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795257318618-c358b9ff-a189-442c-a9d4-8af61f468854.png)

然后程序开始检测全局变量是否为0，如果是则抛出异常_cxa_throw，但这些对找出flag感觉没什么关系，单纯了解一下

注意到主函数下面有一个solve（）函数，进行查看

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795257606453-1e7e315c-2344-44d5-b9e4-70bb54c630ae.png)

 在地址 0x4048E9 处，IDA 分析出来栈指针 rsp 比函数入口时更高（栈往上长，出现正向偏移），栈不平衡，反编译器无法生成伪代码  ，一般是花指令和静态分析有问题

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795264435739-a7e1d3f8-5ab7-47cb-9e0a-93e129ada3f0.png)

发现这个程序在动态运行的过程中无论如何都直接跳转到4048EE

所以，4048E9 这里的 call 实际上是永远不会被执行到的死代码。

但是，IDA 是静态分析工具，它在遍历代码时，会傻乎乎地跟着跳过去。由于跳到了指令中间，IDA 强行把后面的字节当成指令解析，导致它把本来正常的或者栈帧操作给解析错了，最终直接导致了sp-analysis failed(栈分析失败) 。

因此将 call    near ptr Label+1，nop掉

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795265181630-cc55c066-7711-486c-9bf8-450898083527.png)

发现报错消失，可以正常进入solve函数

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795265229631-3910d9e8-af89-4b1e-a612-b86b4b262f47.png)

大概分析一下函数逻辑，就是先判断flag的开头和结尾是否是moectf{}，如果是就将中间的部分提取出来，再传入encode函数进行加密，将加密之后的密文与enc[]进行比较

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795265433219-ae04ace7-392d-4008-a3d4-b6bdbfd304d8.png)

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795265454557-9733aed4-4057-465f-81df-b59f66109eee.png)

查看encode函数的逻辑关系，以及enc[],key的值，写完解密脚本运行之后发现有问题，key的值不对，重新查看汇编语言

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795266249118-2da403f5-9481-4f57-8dff-ea4e321fe4b6.png)

发现key和0X0做了异或处理，则key变成0X29，重新撰写机密代码

```plain
#include <stdio.h>

int main() {
    unsigned char enc[32] = {
        0x4F, 0x1A, 0x59, 0x1F, 0x5B, 0x1D, 0x5D, 0x6F,
        0x7B, 0x47, 0x7E, 0x44, 0x6A, 0x07, 0x59, 0x67,
        0x0E, 0x52, 0x08, 0x63, 0x5C, 0x1A, 0x52, 0x1F,
        0x20, 0x7B, 0x21, 0x77, 0x70, 0x25, 0x74, 0x2B
    };
    unsigned int key = 0x29; 
    char flag_inner[33] = {0}; 

    int i; 
    for (i = 0; i < 32; i++) {
        flag_inner[i] = enc[i] ^ key;
        key++; 
    }
    printf("moectf{%s}\n", flag_inner);

    return 0;
}
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795266484887-4164eb3e-eef1-42f3-a312-c39961afb68b.png)

## 2048_master
进入WinMain什么也没发现

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795269260595-963795a4-88a8-44ba-97bc-4a60ca87df3e.png)

查看字符串窗口，发现flag.txt

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795269368848-28d5ba52-fbd5-4805-aac4-e5649be8609d.png)

进入相应位置的伪代码，发现字符串2048master2048ma，进行加以之后与byte_495280[i]进行比较

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795269514938-8902b82e-06bb-4518-b9b4-2513713aac3c.png)

发现加密过程符合XXTEA算法，但与一般XXTEA算法不一样的是detla发生了变化1050114489 = 0x3E9779B9。因此作者给出的detla为0x3E9779B9

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795269656331-18a76c0b-d120-4439-88a6-34d6c96cef2f.png)

找出对比的数组，写出解密代码并运行

```plain
from regadgets import *

data = bytes([0x35, 0x79, 0x77, 0xCC, 0x1B, 0x13, 0x41, 0x34, 0xF9, 0xFF, 0x9F, 0x91, 0xFF, 0x5B, 0x94, 0x78, 0x86, 0x2A, 0xAF, 0xAE, 0xD7, 0x9E, 0x31, 0x4D, 0x7A, 0xC4, 0xA5, 0x51, 0xD1, 0xD9, 0x6E, 0x44, 0x18, 0x52, 0x86, 0x1B, 0x42, 0x8A, 0xC9, 0x63])

flag = xxtea_decrypt(data, b'2048master2048ma', 0x3E9779B9)
print(flag)
```

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/67835331/1795270406237-e84ec7f8-09dc-4108-9e28-1b7a84a8039b.png)


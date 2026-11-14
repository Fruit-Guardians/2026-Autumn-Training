# 新生赛入门题


一、我就是一只讨生活的鼠鼠啊~
[题目网址:sign in~](https://www.nssctf.cn/contest/875/problem)  

初始状态：解压后，得两文件：  
1.![鼠鼠我呀](https://github.com/Crimson7928/my-image-picgo/blob/main/%E9%BC%A0%E9%BC%A0%E6%88%91%E5%91%80.gif)   
2.[无后缀文件](https://github.com/Crimson7928/misc_flag/blob/main/OVO)   

出于谨慎，我先查看文件属性，没有在标签页中发现异常属性和提示。  

随后使用Winhex打开OVO文件，发现文件头为50 4B 03 04，证明是一个ZIP压缩包。重命名，发现其中有一个需要密码打开的音频文件[listen.wav](https://github.com/Crimson7928/misc_flag/blob/main/listen.wav)  

 中途~~不想动脑子~~直接尝试密码爆破，确定是真加密，而不是伪加密。后来了解到伪加密是有其他解法。

 接下来尝试寻找密码，首先确定了文件属性没有藏密码，然后打开Winhex,确认Gif没有zip文件隐藏（也就是没有PK头），然后明显就是在文件中寻找密码。
 
 这里提供几个错误思路：我最开始以为会是图片几个帧中藏有信息。接下来通过线上工具一帧一帧寻找，意外发现第48帧不同于其他帧，有一抹红色(图片找不到了)
 
 
 接下来以为是图片隐写，使用stegsolve翻来覆去，结果没看到破绽 。

 最后老大给了提示：时间隐写。观察动图的帧延迟，出题人将每一帧延迟时间严格限制在了两种取值：10与20.完美符合二进制隐写的特征。

 接下来，将10对应为二进制0，将20对应为1。（这里有个意外，我不断被改动文件格式导致数据损坏，也不要用QQ微信传输,会损害数据。）
 
 接下来我借助ai编写了一段脚本，因为python确实不过关： 

 from PIL import Image

img = Image.open("鼠鼠我呀.gif")
binary_str = ""

try:
    while True:
        # 获取每一帧的延迟时间
        duration = img.info.get('duration', 0)
        
        if duration == 10:
            binary_str += '0'
        elif duration == 20:
            binary_str += '1'
            
        img.seek(img.tell() + 1)
except EOFError:
    pass 

# 将二进制按 8 位一组转成 ASCII 字符
password = ""
for i in range(0, len(binary_str), 8):
    byte = binary_str[i:i+8]
    if len(byte) == 8:
        password += chr(int(byte, 2))

print(f"提取到的密码是: {password}")

提取的文件还有偏移量，![偏移失效](https://github.com/Crimson7928/misc_flag/blob/main/fall.png)  

这是由于暴力二进制提取导致的，补充偏移量测试脚本即可：
# 假设 binary_str 是暴力提取出的 341 位带杂质的二进制串
for offset in range(8):
    temp_str = binary_str[offset:]
    res = ""
    for i in range(0, len(temp_str), 8):
        byte = temp_str[i:i+8]
        if len(byte) == 8:
            char_code = int(byte, 2)
            if 32 <= char_code <= 126:
                res += chr(char_code)
    # 在输出的结果中，找到拼接出 fr4m3_t1m3 的那一组偏移量


    得到密码：fr4m3_t1m3(帧时间)

    接下来解压打开Aduacity,在频谱图中秒解![flag](https://github.com/Crimson7928/misc_flag/blob/main/Aflag.jpg)  






##  第二题：套娃解密题目名称：Unnnnnnnnnnnnzip(在一题链接处)

###解题过程

解压最外层 thepasswordisthefilename.zip（这一层没有密码），得到一个名为 9178595229205563874.zip 的压缩包。

结合附件名 “thepasswordisthefilename”（密码就是文件名），我们可以很自然地推断出解压规律：
下一层压缩包的密码，就是它当前的文件名（不带 .zip 后缀）。

解开 9178595229205563874.zip，需要用 9178595229205563874 作为密码。解开后里面又是一个新的、名字更长的数字压缩包。

思路清晰了，python脚本解码自动化：

由于题目名称叫 Unnnnnnnnnnnnnzip，暗示着这绝对不止几层，手动解压根本不现实。我们直接上 Python 脚本跑循环解压。

1.坑点 1：Python 自带库不支持 AES 加密
一开始使用 Python 自带的 zipfile 库写脚本，跑到第一层时报错：
That compression method is not supported。
这说明出题人用了 AES-256 高级加密，而 zipfile 只能处理基础的 ZipCrypto。因此，我们引入了第三方库 pyzipper 来对付 AES。
(安装命令：pip install pyzipper)!(https://github.com/Crimson7928/misc_flag/blob/main/K1.jpg)

2.坑点 2：文件占用导致中断
在使用 pyzipper 成功解开第一层后，脚本崩溃了，报错：
[WinError 32] 另一个程序正在使用此文件，进程无法访问。
原因是我们代码里写了 os.remove(file_path)（解压完把旧的删掉），但此时可能资源管理器或者杀毒软件正在扫描该文件，导致无法删除。直接在脚本里把删除旧文件这行代码去掉.
!(https://github.com/Crimson7928/misc_flag/blob/main/K2.jpg)
终极解压脚本

替换库并去掉重复代码

```python
import os
import pyzipper # 必须引入这个库对付 AES 加密

# 第一层带密码的压缩包名
current_file = "9178595229205563874.zip" 
folder_path = os.getcwd()

count = 1
print(f"开始无限套娃解压... 当前文件: {current_file}\n")

while True:
    file_path = os.path.join(folder_path, current_file)
    
    # 提取文件名（去掉 .zip 后缀）作为密码
    password = current_file[:-4] if current_file.endswith('.zip') else current_file
    
    try:
        # 使用 pyzipper.AESZipFile 代替 zipfile.ZipFile
        with pyzipper.AESZipFile(file_path, 'r') as z:
            z.setpassword(password.encode('utf-8'))
            names = z.namelist()
            
            if not names:
                print("压缩包空了，结束。")
                break
                
            extracted_name = names[0]
            z.extractall(path=folder_path, pwd=password.encode('utf-8'))
            
            print(f"第 {count} 层: 成功！ -> 提取出 {extracted_name}")
            
            # 注意：这里去掉了 os.remove(file_path)，防止文件被占用报错
            
            # 将新提取出的文件作为下一次循环的目标
            current_file = extracted_name
            count += 1
            
            # 如果提取出的文件不是 .zip 结尾，说明通关了
            if not current_file.endswith('.zip'):
                print(f"\n🎉 终于拨云见日！最终解压出一个非压缩包文件：{current_file}")
                break
                
    except Exception as e:
        print(f"\n❌ 报错停止！在第 {count} 层出错了。")
        print(f"当前处理的文件是: {current_file}")
        print(f"尝试使用的密码是: {password}")
        print(f"错误信息: {e}")
        break
```

第四步拿下 Flag

运行脚本后，命令行开始疯狂刷屏。看着数字从 1 一路飙升到 1000，最终在第 1000 层 时，屏幕上打印出：
第 1000 层: 成功！ -> 提取出 flag.txt!(https://github.com/Crimson7928/misc_flag/blob/main/K3.jpg)
 终于拨云见日！最终解压出一个非压缩包文件：flag.txt
打开即可得到flag。




## shrak_is_cute

 一、 题目概况

· 题目名称：shrak_is_cute
· 题目附件：依然在第一题网址。
· 核心考点：Wireshark 导出 HTTP 对象、流量包中的切片文件提取、CMD 二进制文件拼接。

---

二、错误思路复盘与分析

踩坑 1： binwalk 和搜 PK 头

错误操作：拿到 pcap 包，第一反应是直接搜 tcp contains "PK"，用 binwalk -e challenge.pcap，企图直接分离出一个完整的 ZIP 压缩包。
结果：Wireshark 里搜不到完整的 PK 头；binwalk 只输出了一个光杆表头，啥也没分离出来。
原因：出题人根本没把完整的压缩包塞进流量里，而是把一个文件切成了片（分卷）。文件头被破坏了，binwalk 扫不出来。

踩坑 2：被网页里的“假链接”骗了

错误操作：在追踪 TCP 流时，看到了一段 HTML 源码：<a href="/download/part01.bin">backup part 1</a>。于是在 HTTP 对象过滤器中疯狂找 part01.bin 的下载记录，甚至把整段流另存为了 save.bin。
结果：导出的 save.bin 拖进 010 Editor 一看，全是 GET / HTTP/1.1 这样的网页明文，根本没有数据。
原因：出题人故意在网页里写了个诱饵链接，但服务器根本没有真正下发这个文件，纯纯的障眼法。!(https://github.com/Crimson7928/misc_flag/blob/main/010save.jpg)

踩坑 3：被异常大的 style.css 耗尽耐心

· 错误操作：发现 GET /static/style.css 的响应包竟然有 5920 字节，觉得极其反常。于是去追踪流，把 style.css 导出来，一行行看源码，寻找 Base64 或隐藏 Flag。
· 结果：发现里面只是一堆重复的 body{font-family...} 废话。
· 原因：这是出题人为了混淆视听，故意填充的大量垃圾字符。

---
 三、最后思路

第一步：无差别提取 HTTP 对象

既然单个找找不到，干脆一网打尽。

1. 在 Wireshark 中点击 “文件” -> “导出对象” -> “HTTP”。“全部保存”，将流量包里的所有资产全部导出到一个空文件夹。
发现端倪：
导出的文件列表中，除了正常的 img01.png 等图片，赫然出现了 part01.bin 到 part08.bin 这 8 个切片文件。每个文件大小约 3KB。

第二步：CMD 暴力缝合切片文件

这 8 个 .bin 文件显然是一个大文件被切碎的结果。用 Windows 自带的命令即可拼接：

1. 在存放这 8 个文件的文件夹地址栏输入 cmd 回车。
2. 执行以下命令：
   ```cmd
   copy /b part01.bin+part02.bin+part03.bin+part04.bin+part05.bin+part06.bin+part07.bin+part08.bin merged.bin
   ```
3. 执行完毕后，会生成一个名为 merged.bin 的完整文件。

第三步：查看结果获取 Flag

双击打开或把 merged.bin 拖入图片查看器/010 Editor。这是一个完整的图片！（https://github.com/Crimson7928/misc_flag/blob/main/010.png）
 
 NSSCTF{wireshark_export_http_then_concat}

(注：出题人甚至在 Flag 里把解法都告诉你了：export_http（导出HTTP对象） then_concat（然后拼接）)

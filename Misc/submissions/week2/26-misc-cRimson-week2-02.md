# 几道道隐写题目

## 一.被篡改的图片

### 考点：文件头分析、文件结构修复、gif图片分帧与横向拼接

[网址](https://ctf.bugku.com/challenges/detail/id/220.html)

下载打开后是一个无法打开的png格式文件这里可以考虑怀疑它的真实身份，比如是否修改了格式或者后缀。

我使用了记事本偷窥一下[记事本打开](https://github.com/Crimson7928/my-image-picgo/blob/main/%E8%AE%B0%E4%BA%8B%E6%9C%AC%E5%B0%9D%E8%AF%95.png)

我预设了打开过后会是可读的中英文混合或者表情符号，那可能就会是嵌套的密码，但是打开是完全不可读的乱码。所以换一种思路使用16进制编辑器看真实属性，我使用了Winhex。[winhex尝试]（https://github.com/Crimson7928/my-image-picgo/blob/main/winhex%E5%87%BA%E7%8E%B0gif%E6%A0%87%E5%BF%97.png）

发现出现了gif标志，这个是比较傻的一个一个看找出来的，可以保护眼睛，使用ctrl+f搜索出来。  
同时发现开头的16进制是89 50 4E 47说明它是伪装者，仿造了PNG形式，往下看第三行出现ASCII码的89a，也就是38 39 61加上NETSCAPE2.0，这串英文符是典型的GIF动图循环控制块特征-----也就是说，这是个被篡改了文件头的gif动图。

接下来就是比较清晰的思路：

1.在编辑器中改成GIF的ASCII码----把89 50 4E修改成47 49 46  
2.把留存的38 39 61字段拼接上去，构成完整GIF文件头
3.删掉中间属于png味道的，留下新的：47 49 46 38 39 61  
4.另存一份  
5.使用在线工具分帧工具打开，发现有700多张图。这里也可以使用python脚本或者随波逐流的工具。  
6.随便摘一个在线图片拼接工具，横向拼接，就是flag
(不知道为什么顺序有误，没想好怎么调，因为不大影响找flag)[flag](https://github.com/Crimson7928/my-image-picgo/blob/main/flag.png)
  ~~全是二次元~~

  然后提交flag[结算动画]（https://github.com/Crimson7928/my-image-picgo/blob/main/%E7%BB%93%E7%AE%97%E5%8A%A8%E7%94%BB.png）


总结：
1.文件头是~~大小姐~~是~~浮木~~：不管后缀，前面几个字节永远是真实身份，改后缀无效一定要去偷窥文件头。
### 补充一下几个常用格式的文件头字符：
-png：89 50 4E 47  
-GIF：47 49 46 38
-zip：50 4B 03 04
-jpg：FF D8 FF

2.遇到打不开的图、文件：先找工具看文件头（Winhex或者010 editor之类）然后看看有无隐藏数据（可以用记事本打开看看）

3.观察小图片形状：本题可以发现全是窄窄竖条，类似把一张长方形纸片切成700多条，要把竖条恢复，显然只能排排拼接，竖着拼就成了超长金箍棒。显然，高大于宽，选横拼；宽大于高，选竖拼。还有一种后来了解到的九宫格形式，专门利用python或者拼图软件和flag常见格式去试一试。


## 爱因斯坦的秘密与嵌套文件踩坑实录

### 考点：套娃解压、EXIF元数据隐写、十六进制数据提取。

[题目]（https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?returnTo=%2Fdashboard%2Fpractice%3Fview%3Dmy&tab=challenges&challenge=30c3d5bb-3296-4786-8fac-1a46f759752b）

~~这道题做的血压高~~
先讲讲做的时候各种死法：

1.直接搞后缀  
结果：文件直接损坏
原因：后来我用exiftool去看文件头（50 4B 03 04）是被出题人直接抹除混淆了，解压软件无法识别。  
拓展：后来了解了一下，如果修改后缀能直接打开说明是最简单的追加型嵌套，也就是直接把ZIP文件黏在JPG末尾，打不开就需要用相关十六进制编辑器修复文件头。

2.依赖binwalk，使用命令行尝试提取文件(虽然我现在都没搞懂，为什么事后看其他师傅的WP，他们可以用formost直接把压缩包抓出来，我的binwalk仅仅只运行到表头就停止了)！[失败的运行]（https://github.com/Crimson7928/my-image-picgo/blob/main/failure.png）  

结果：~~给血压造成严重打击~~屏幕上只有表头，下面是空的  
原因：问了一下，可能是binwalk的原理是特征码匹配。出题人篡改了PK头[^1]，binwalk认不出来里面的压缩包。
拓展：binwalk不是万能的，遇到扫不出来的，说明特征码被破坏了，需要查看修改元数据。

3.~~血压爆炸模拟器~~死磕命令行工具（EXIFTOOL/Winhex）
脑溢血操作：文件目录下执行提取命令；拖拽带有括号的工具进入CMD  
结果：操作一报错，“拒绝访问”；操作二报错“不是内部或者外部的命令”  
原因：Windows的C盘/系统盘，目录权限极高，普通cmd没有写入权限。  
CMD命令行遇到括号会解析错误，导致路径被截断，找不到可执行文件。  
拓展：永远不要在带有***中文、空格或者特殊字符的路径***下运行命令行工具，求文件优先在桌面操作。



**最后是正确解法之一**  
binwalk失败以后，在评论区大佬提示下察觉到附件名是一长串SHA256哈希值[^2]但是常规平台MD5没有查到。就直接用网页版EXIF查看器上传了。![查看结果，可以发现有密码](https://github.com/Crimson7928/my-image-picgo/blob/main/exiftool.png)

在XPComment发现了密码：'this_in_not_password'  在Padding(填充数据)字段中发现隐藏了2060 bytes的二进制数据，且开头是1c ea 00 00  

由于之前本地exiftool提取遇到路径和权限问题，决定使用python直接读取文件底层字节，暴力提取
脚本：
import os

# 你的图片名字
image_name = 'misc2.jpg'

# 读取图片的所有二进制数据
with open(image_name, 'rb') as f:
    data = f.read()

# 寻找 ZIP 文件的标志 (PK..)
# 正常是 50 4B 03 04
start_index = data.find(b'\x50\x4b\x03\x04')

if start_index != -1:
    # 截取从 ZIP 头到文件末尾的所有数据
    zip_data = data[start_index:]
    
    # 保存为 hidden.zip
    with open('hidden.zip', 'wb') as f_out:
        f_out.write(zip_data)
    print("提取成功！文件夹里多了一个 hidden.zip，快去解压吧！")
    os.system('pause')
else:
    print("没找到 ZIP 文件头，出题人可能把它加密或混淆了。")
    os.system('pause')

    直接破解。再输入之前的密码，拿下。![胜利宣言](https://github.com/Crimson7928/my-image-picgo/blob/main/%E7%BB%93%E7%AE%97.png)  

    五、 知识点拓展总结

· 嵌套文件（图种）的进阶演变：
  · 初级：直接 copy /b 1.jpg+2.zip 3.jpg。用解压软件能直接打开。
  · 中级：改了后缀，或者去掉了 PK 头（本题）。需要用 WinHex 搜 50 4B 手动提取。
  · 高级：像本题一样，把数据塞进 EXIF 的某个特定字段（如 Padding、Comment）里，必须用特定工具提取。
· EXIF 是宝藏：CTF 里拿到照片，第一反应绝对是看属性、丢进 exiftools 扫一遍，密码和 Flag 有可能就在里面。
· “恶心”的密码：出题人特别喜欢用 this_is_not_password、you_will_never_guess 这种带有嘲讽意味的字符串当密码，千万别被字面意思骗了。 

[PK头]：在计算机的世界里，“PK头”就是 ZIP 压缩包的“身份证”和“起跑线”。

之所以叫“PK”，是因为 ZIP 压缩格式的发明人叫 Phil Katz（菲尔·卡茨），为了纪念他，ZIP 文件的标准开头就被定为了他名字的首字母 PK。

在十六进制（Hex）代码里，一个完整的 ZIP 文件头长这样：
50 4B 03 04 
（在 ASCII 码表里，50 代表 P，4B 代表 K，后面的 03 04 是版本号等基础信息）  
[^2]:
想象你有一台神奇的榨汁机（哈希算法，如 MD5、SHA-256）：
1- 一个苹果（你的文件）扔进去。
2- 榨汁机瞬间吐出一杯固定容量（比如 64 个字母）的果汁（哈希值）。
3- 特点 1（不可逆）：你绝对不可能根据这杯果汁，把原来的苹果复原回来。（这就是为什么你在 cmd5.com 查不到那个文件名的含义，因为它根本没法被“解密”）。
4- 特点 2（唯一性）：哪怕你的苹果上只多了一个极小的虫子洞（文件改了一个标点符号），榨出来的果汁味道也会发生天翻地覆的变化。
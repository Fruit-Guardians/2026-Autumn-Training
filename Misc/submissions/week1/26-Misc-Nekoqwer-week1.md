# Nekoqwer - Misc 组 week1 作业
各位师傅好 新人来试试手了
下面我将完成一些题目 并介绍解题思路 链接相关文章和知识点

## 题目 1 一段神秘字符串 
题目来源: Misc技术文档 - 一段神秘字符串  
类型: 编码
```
ZmxhZzpIbnVDVEZ7SDNyM18xNV95MHVyX2YxcjU3X2ZsNGd9
```
看完文档的编码/现代密码中 发现 base64 和他长得有点像  
比如区分大小写 并且长度为 48 是 4 的倍数  
尝试将其解码得到 flag ```HnuCTF{H3r3_15_y0ur_f1r57_fl4g}``` 完成

## 题目 2 给你点颜色瞧瞧
题目来源: Misc技术文档 - 给你点颜色瞧瞧  
类型: 图片 LSB/MSB 隐写
先拖到 winhex 发现 png IEND 后无数据 将重心移动到图片隐写中   
在隐写术文档中查看前几种方法 不涉及文件嵌套和文本隐写 故将目标转向图片隐写  
Stegsolve 导入图片后下方的方向箭头 看不同位平面仍然无结果 转向 LSB/MSB 隐写  
参考教程 <https://developer.aliyun.com/article/1404037>  
点击 Stegsolve 左上角 -> Analyse -> Data Extract 按照教程勾选 RGB 的 0 通道并按下 Preview  
拉到最上面发现答案 ```HnuCTF{Y0u_f0und_q1ng_g3_n1u_b1_c0l0r5!!}```  
![](https://img.072196110.xyz/hnusec/2026/11/20261102-002220.png)

## 题目 3 爬行的大肥鱼
题目来源: Misc技术文档 - 爬行的大肥鱼  
类型: 动画抽帧
显然答案在部分帧中 通过直接查看这些特殊的帧得到 flag: HnuCTF{F31yu_Go_g0_go!}
![这张图里我重排了这些帧](https://img.072196110.xyz/hnusec/2026/11/20261102-003138-Imagine64.png)

## 题目 4 屁股在树上呢  
题目来源: Misc技术文档 - 屁股在树上呢  
类型: 文件结构和修复
通过 winhex 看 IEND 正常 没有嵌套 但是图片直接打开是损坏的  
于是使用外挂 [aperisolve.com](https://www.aperisolve.com/3f044e821382f41c25bc1aff21e0cdfb)  
其成功修复了图片 得到 flag: ```HnuCTF{y0u_f0und_7h3_8u77!!}```  
但是光靠外挂不好玩, 网站的 Pcrt 条目分析得到以下信息  
```
Error IHDR CRC found at offset 0x1D
Chunk crc: C95C184E, Correct crc: 6F2B13FA
Looking up CRC in database...
No database match found, falling back to exhaustive search...
Found correct dimensions via exhaustive search: 1203x887
```
适当了解得知这里是 png 的 IHDR 头里面的宽错误了   
了解到这种类型的修复方式是 ```在偏移 0x1D 开始的4个字节取到 CRC32 -> 通过修改宽或高在一定范围内遍历, 用 0xC~0x1C 计算 CRC32, 若结果一致 则已寻找到正确分辨率``` 
```*或者就干脆改一下宽高其中之一为大一点的值 但是这种不适用于宽高都变化的情况*```

## 题目 5 嘟嘟哒嘟嘟哒
题目来源: Misc技术文档 - 嘟嘟哒嘟嘟哒  
类型: 音频隐写 莫斯密码
先是检查标签信息 binwalk 等未发现如元数据或者嵌套文件 于是想起文档中的音频隐写  
把得到的骨感音乐丢到 Audacity 里看看波形 发现在 32s 前的波形被切成了一块一块的 ~~是否是某种暗示?~~  
我说实话没看明白 然后就去抄袭 chun 同学 week2 的作业 看到要切到频谱图并在 29s~60s 发现一个摩斯密码  
![](https://img.072196110.xyz/hnusec/2026/11/20261102-013400-Audacity4.png)
```
摩斯密码 .... -. ..- -.-. - ..-. -..-. ....- .-- ...-- ..... ----- -- ...-- ..--.- ..... -.- ..- .-.. .-.. ..--.- -- ----- .-. ..... ...-- ..--.- -.-. ----- -.. ...-- ..--.- -- ..- ..... .---- -.-.
-> 解码为 HNUCTF/4W350M3_5KULL_M0R53_C0D3_MU51C
```

## 题目 6 所以我放弃了贝斯
题目来源: Misc技术文档 - 所以我放弃了贝斯  
类型: 编码 隐藏字符提取
打开压缩包 ~~哦还有小贴纸? 这么温馨的吗~~ 一看一堆 emoji 鉴定为 base100  
果断拿下压缩包密码 ```P@55w0rd_1s_MyG0!```  
使用该密码打开 ```春日影.zip``` 得到一个 ```谱子的秘密.docx```  
看左下角 word 字符统计有一百多个 字数很明显不匹配 但是懒得找隐藏字符在哪了, 直接另存为保存成纯文本  
但是打开文本吓晕了 几万个字符 找到文本底部看到了 ==, 看来是 base64 露出了鸡脚  
于是拖过去解密 看到第一行是一个乱码字符+PNG, 即是 png 二进制, 推测是 base64 编码的 PNG
![](https://img.072196110.xyz/hnusec/2026/11/20261102-015431-kwrite.png)
![](https://img.072196110.xyz/hnusec/2026/11/20261102-015726-firefox.png)
![](https://img.072196110.xyz/hnusec/2026/11/20261102-015739-firefox.png)
图片里面小女孩似乎在呐喊什么 不知道不管她 这个末尾的 = 又出卖了他  
```JBXHKQ2UIZ5VO2DZL42HEM27PEYHKX3QNQ2HSMLOM5PUQNDSOVUDC2ZUM4ZT67I=```  
可是他没有小写 推测为 base32  
解码得到 flag ```HnuCTF{Why_4r3_y0u_pl4y1ng_H4ruh1k4g3?}```

## 题目7 你xx劈我瓜！
题目来源: Misc技术文档 - 你xx劈我瓜！
类型: 压缩包破解

打开压缩包 丢到 winhex 改掉加密标识解压提示数据错误 开始力大飞砖  
爆破得到第一层压缩包 ```瓜.zip``` 密码 7639  
对第二层压缩包 ```郝哥.zip``` 尝试伪加密修改 成功     
得到 flag ```HnuCTF{Hao_ge_Sa_Ren_la!}```  

## 题目 8 BUUCTF-二维码
题目 [BUUCTF-二维码](https://ctf2.dasctf.com/dashboard/practice/b9bbb32f-f186-458f-b90b-12440c0f6aea?returnTo=%2Fdashboard%2Fpractice%3Fview%3Dmy&tab=challenges&challenge=7a44e5a1-beea-4663-9b23-ebe1baf38765)  
类型 文件嵌套 zip枚举数字密码暴力破解  
解压题目压缩到 得到一个名为 `QR_code.png` 的二维码 解码得到 `secret is here`  
丢到 winhex 发现在 png 后面有个 PK, 也就是 zip 的魔术字符  
![](https://img.072196110.xyz/hnusec/2026/11/20261101-230231-WinHex64.png)
所以尝试提取一下这个藏在后面的 zip
![](https://img.072196110.xyz/hnusec/2026/11/20261101-230353-7zFM.png)
得到藏在此后的 `2.zip`, 直接解压提示被加密, 因为也没有其他可能的线索指向密码, 恰好在学习文档中看到了伪加密  
于是拖进 winhex 尝试把 ```50 4B 03 04 14 00``` 和 ```50 4B 01 02 1F 00 14 00``` 后的通用标记为改为 ``00 00``  
解压得到文件损坏 大概是确实存在密码 于是尝试直接爆破力大飞砖  
使用 [ZipCracker](https://github.com/asaotomo/ZipCracker) 暴力破解得到密码 7639, 获取 flag CTF{vjpw_wnoei}  
*其实题目 8 做的比上面的要早, 所以 zip 暴力破解写到这里了*
参考  
[压缩包Zip格式详析（全网最详细）](https://www.cnblogs.com/li-sx/p/17531186.html)  
[CTF——zip伪加密](https://blog.csdn.net/xiaozhaidada/article/details/124538768)

## 小结和碎碎念
初入 CTF 还是比较感觉茫然的  
而且我入群晚 再加上期中考试临近 还是有一些焦虑的  
~~但是这个题目他就像冰啊 口味好劲道足 做着做着感觉上瘾了一样~~  
而且经过上手手感也好了一些  
也希望可以能赶上末班车吧  
最后 感谢你审批我的作业 祝好梦 :)
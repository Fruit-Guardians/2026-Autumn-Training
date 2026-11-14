# 第一周

# 一编：10.24
## 以解出【给你点颜色瞧瞧】为中心目的，展开一些学习
因为题目是图片格式所以先下了stegsolve，在搜索相关信息的时候看见了隐写术这个关键词
### 隐写术：【初步了解参考视频】（https://www.bilibili.com/video/BV1Su411X7vY/?spm_id_from=333.337.search-card.all.click&vd_source=f333adfb3b51318f0108ad35051a8c43）
#### 1.文本格式打开图片，找末尾
（通过CTF^2的某个题解了解到**IEND**是PNG图片格式的标准结束标准字，隐藏信息可能在IEND后）
*鉴于该题题目名字，排除这种方法*
#### 2.LSB隐写
改写像素值最低位，人眼不能区别
将字母用ascii码二进制数表示，然后从第一个像素格子开始依次嵌入最低位

*在用stegsolve不用通道处理过该图片后发现三行类似的黑点点，一开始怀疑是摩斯电码但是试了半天不对，现在来看应该是LBS隐写*
![处理后的图片1](./images/solved1.png)
![处理后的图片2](./images/solved2.png)
(报告！这两张图片不知道为啥上传不成图床)
音频视频LSB同理

**嵌入痕迹**：根据统计学，正常的一张图片0和1的比例是五五开，一旦隐藏了ascii二进制英文字母，则趋于2：3，其他语言不一定，但肯定破坏原本的比例
但嵌入量低的话统计学上就不好检测了，得用**样本对分析法**。不过这个似乎是进阶的东西，我先不打扰了哈，码住以后再看，还有**加减1嵌入隐写**  **GAN网络**，目测是抹去嵌入痕迹加密的好方法
#### 3.调色板隐写 
该视频涉及较浅，有待进一步学习
#### 4.频域隐写（比较不容易在传播中磨损）
该视频涉及较浅，有待进一步学习

本来是用ps打开放大，尝试肉眼判断像素点，但尝试无果，眼要瞎了，遂把图片丢进cyberchef里用LBS，颜色通道用RGB一下就出来了
![处理后的图片3](https://i.imgs.ovh/2026/10/25/8af397a5f03241895001c96950f67dc3.png)
**总结，善用工具，别当原始人**


# 二编 10.25
## （一）学习stegsolve的功能
【参考视频】（https://www.bilibili.com/video/BV1zEc3eWEWf/?share_source=copy_web&vd_source=9a7c6fd4422a51e3aaa4a44ce6dc3776）
【参考网页】（https://blog.csdn.net/weixin_43639682/article/details/113857310?spm=1001.2101.3001.11989&utm_medium=distribute.pc_relevant_t1.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7EPaidSort-1-113857310-blog-149476511.235%5Ev43%5Epc_blog_bottom_relevance_base7.t1_cc&depth_1-utm_source=distribute.pc_relevant_t1.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7EPaidSort-1-113857310-blog-149476511.235%5Ev43%5Epc_blog_bottom_relevance_base7）
### 1.【给你点颜色瞧瞧】另解
原来stegsolve本身就可以解码LBS隐写
![图片](https://i.imgs.ovh/2026/10/25/26613f6d016c22da9e2e5c13cf0197c1.png)
另外save Text可导出文件，做进一步的解码（stegsolve导出的可能是另一段密文也可能是藏了个压缩包（PK）
从该视频里，我了解到一种编码方式：**HTML编码**
该编码方式特征为：*&#开头+十六进制数字+分号隔开*
### 2.stegsolve analyse下分功能
**File Format**: 文件格式，这个主要是查看图片的具体信息
**Data Extract**: 数据抽取，图片中隐藏数据的抽取
**Frame Browser**: 帧浏览器，主要是对GIF之类的动图进行分解，动图变成一张张图片，便于查看
**Steregram Solve**:立体试图 可以左右控制偏移
**Image Combiner**: 拼图，图片拼接
## 【爬行的大肥鱼】
把gif导入剪映然后逐帧看(最新手友好的一集)
HnuCTF{F31yu_Go_g0_go!}
*或者用stegsolve也行*
## CTF^2题目【snake】wp——Foremost以及WInHex使用
[Foremost使用说明](https://blog.csdn.net/2401_89382898/article/details/148052074)
一句话总结就是binary目录下cmd回车，然后以*foremost 文件地址*的格式输入，会生辰一个output文件夹在binary目录中，里面是提取出来的文件
有些图片会藏别的文件
用stegsolve→File Format查看题目图片，发现有*PK*的关键词，合理怀疑藏压缩包了，于是丢到foremost里面提取隐藏文件，提取出来两个文件：key 和ciher
key：
*V2hhdCBpcyBOaWNraSBNaW5haidzIGZhdm9yaXRlIHNvbmcgdGhhdCByZWZlcnMgdG8gc25ha2VzPwo=*
了解到这是base64的加密方式，末尾一般是=
网上找了个解码网站解出：([base64解码网站](https://www.toolhelper.cn/EncodeDecode/Base64))
What is Nicki Minaj's favorite song that refers to snakes?
上网搜了答案是：anaconda
**注意！！！密钥一般是小写**
现在搞ciher，丢进WinHex处理得到一组十六进制数
![卡关实录](https://i.imgs.ovh/2026/10/25/3bd56a6f5b99979d9dad68d5671ec6a0.png)
到这里卡关了，因为知识量不够，所以求助于CTF^2题解
了解到了*serpent*加密
此题snake就是对serpent的一个提示（近义）
[线上serpent解密链接](http://tool.chacuo.net/cryptserpent)
丢进去解密
![](https://i.imgs.ovh/2026/10/25/3535819e96703efaf99e1c67ce6469e5.png)
### 关于 serpent加密
1.密钥的长度只能是16、24、32字节
2.密文通常要先转化为16进制数字再解密
## 【屁股在树上】wp——隐藏图片尺寸
看图片大小比较小，不像是藏了啥文件，所以丢进stegsolve里，file format查看
![图片](https://i.imgs.ovh/2026/10/25/9fc8126cb29281538cce67c72de59e2e.png)
意外地不是乱码，但因为知识量不够所以一筹莫展了，于是把这段信息丢给ai，ai提出：
此图片:
**IHDR CRC 不匹配，是非常经典的 CTF/MISC 考点：常见于“宽高被改”“CRC 隐写”“文件修复”“图片显示不全”等题型**
先尝试修改图片尺寸
[参考方法](https://blog.csdn.net/missmengjin/article/details/99575137#:~:)
**一句话总结，用windex打开图片，第二行前四个数是宽，后四个数是高，修改即可**
由刚才的file format report可知，此图片尺寸为1203x631
![](https://i.imgs.ovh/2026/10/25/7f6d75d670754419551340b09410040d.png)
~~winhex修改后导出是另外的价钱，故换用010editor~~
![](https://i.imgs.ovh/2026/10/26/a31d65f8a2dce01c19c55ba2b8b45585.png)
![](https://i.imgs.ovh/2026/10/26/6b3aac32de4b658d17055260d44876bd.png)
           
多试几个数，把高换成1000刚好能够显示出来   

# 碎碎念：
今天是从晚上七点多搞到凌晨0：16
![](https://i.imgs.ovh/2026/10/26/6cb6e7e1fe08755ebc73fb869234dd1f.png)  
现在我的表情和师爷的表情一模一样。。。做基础题做了五个小时，看来我还是菜得比较出奇，学习进程还道阻且长哈哈哈哈哈。。。
自己总结了一下，时间大部分投入在了信息的检索上：下载各种软件、找各种方法的参考、注册各大网站的账号。。。还有学习md的写法，以及研究图床的使用。。。试错的过程比较多，但是最后拿到flag时还是在心里播了一首we are the champions哈哈哈         ，，，，，，，
类似serpent的一些原理还是看不懂，要学的还有很多。。。misc发散思维还是需要庞大的知识量。。。很显然我没有哈哈哈。。。但我会尽力
以后会尽量加快效率的  
，，，，，，，，
另外刚看到群里说最好不要把笔记写得像日记，坏了，我觉得我写的就像是日记，下次一定会精简内容好好排版的！！！！！
                                                    

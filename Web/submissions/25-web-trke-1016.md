# Week-1
+ ID:trke
+ 日期：2026-10-15

## 前期准备日志
+ 用Steam++加速Github的访问，并Fork仓库到个人GIthub账号
+ 阅读Hun Sec 2026 秋季培训文档
+ 在语雀建立<Web--学习日志>和<Web-WP>知识库
+ 学习Markdown语法，并使用语雀写总结和WP

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/70155640/1792055698737-7d3b6612-7f86-4c2e-b239-4fb97b5977e6.png)

 

## 预备知识学习<font style="color:#F297CC;"></font>
+ **Burp Suite 已安装 -- 用于抓包，改包，发包 **

基本操作：打开Burp Suite , 打开内嵌浏览器 ，输入要抓包的网址 ，开启拦截抓包，发送到repeater进行测试。

+ **Hackbar 插件 已安装 -- 用于网络渗透测试**

基本操作：打开Firefox，按F12进入面板，点击Hackbar图标，切分、修改、发送url  ；base64，url，hex，解码编码 ；MD5，SHA-1，SHA-256，ROT13加密 ；SQL注入,XSSpyload

+ **dirsearch 已安装 -- 用于暴力扫描**

基本操作：打开D:\Sec_tool\Sec_Recon\dirsearch ，输入cmd ，输入相关命令 [dirsearch命令 -- CSDN](https://blog.csdn.net/2301_79518550/article/details/147349972)

+ **python3 + pip 已安装 -- python环境**
+ **vscode -- 已安装 -- 提供各种语言环境**
+ **vmvare + kali虚拟机 + win10靶机已安装 -- 用于学习Linux命令，及攻击测试**

## Linux 操作系统
1. 搭建 Linux 环境：成功下载 VMware+kali

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/70155640/1792123020180-b8ebe34d-6b4b-47e2-9fe8-7bd770ccd884.png)

+ 设置 root 账户密码 -- sudo passwd root，进入root用户：su root
+ 配置国内镜像源

更新软件包索引 apt update --> vim /etc/apt/sources.list --> 编辑软件源列表

```python
deb https://mirrors.aliyun.com/kali kali-rolling main non-free contrib non-free-firmware
```

-->  清理下载包和缓存 apt clean 下载更新apt update 

+ 安装与卸载软件 -- 安装软件 apt install + 软件名； 卸载软件 apt remove + 名 ；查看软件 apt show +名
+ 常用快捷键学习 -- 复制-Ctrl+Shift+C，粘贴-Ctrl+Shift+V，shell清屏-Ctrl+L，停止运行-Ctrl+C，光标移至行尾-Ctrl+E，光标移至行首-Ctrl+A，清除光标至行首所有内容-Ctrl+U，补全命令-Tab键，上一条/下一条命令-方向键，补全提示命令-右键，关闭shell对话-Ctrl+D



2. 学习基本 Linux 命令

[Linux相关命令手册](https://www.runoob.com/linux/linux-command-manual.html)

+ **帮助：**man命令（最全），--help（简要），whatis（查看核心）
+ **查看文件：**ls : 列出当前⽬录内容   ls -a : 查看隐藏⽂件夹  ls -t按文件最近一次修改时间排序

ls -l 文件详细展示 （ls -lh 以字节来展示⽂件）

+ **目录进退**：cd或者cd./ : 进⼊⽬录  cd.. : 退回上一级目录  cd / : 返回到根⽬录
+ **查看内容：**file ：查看⽂件类型   cat : 查看小文件  more（空格键翻页，按q退出）/less（可上下滚动，不一次性加载所有内容，按/键可搜索内容且按n下一个，N上一个） ：查看大文件，head + 文件名 查看前10行，tail + 文件名 查看后10行
+ **创建：**mkdir ：创建⽬录，-p + 多级路径，例如 mkdir -p b/c/d 创建多级目录  touch : 创建⽂件
+ **操作：**cp : 复制⽂件或⽬录  + 要复制的⽂件 + 目标⽬录 例如 cp 1.txt ,复制⽬录要加上 -r 例如 cp -r a b

mv : 移动或者重命名 ，mv + 文件名 + 目标目录，mv + 旧名字 + 新名字

rm : 删除⽂件，rm + 文件名，-f 强制删除，-rf 递归删除文件夹

+ **通配符：*** 指的是任意字符，？ 指的是单个字符，[ ] 指的是范围 例如 [0-9] [a-z]

|：管道符号，管道前的输出作为管道后的输入

+ **查找：find，grep**

第⼀种 是按照⽂件的名字去查找 例如 find . -name '*.txt'（.表示当前目录）

第⼆种 是按照⽂件的类型去查找 例如 find . -type d （-type d找⽬录）

第三种 是按照⽂件的⼤⼩去找 例如 find . -size +1M（表示当前目录大于1M的文件）

文件内查找：grep + “关键字”+ 文件名

+ **编辑：**vim + 文件名，按 i 进入编辑模式，按Esc退出，按：wq保存退出，：q！强制退出
+ **文件压缩**

zip（兼容性好）：压缩：zip -r（表示递归） 压缩包名.zip 需要压缩的文件（多文件用空格隔开）或目录

解压缩：unzip 压缩包名.zip ，-d 加路径，如/a/b

tar（最常用）：-v 显示压缩过程

压缩：tar -czvf 压缩包名.tar.gz 需要压缩的文件（多文件用空格隔开）或目录

解压缩：tar -xzvf 压缩包名.tar.gz , -C 指定路径，如 ./output或/home/ctf/output

查看压缩包内容：tar -tzvf 压缩包名.tar.gz

+ **Linux 网络管理 **

查看网络信息 ： ifconfig 如果提示没有安装，就输入安装命令 apt install net-tools -y

查看所有的网卡信息 Ip addr 

网络连通性测试命令 ping + 网址 #指定ping 4次后停止 ping -c 4 www.baidu.com

测试HTTP访问 #访问目标网站，返回HTML内容 curl https://www.baidu.com 

查看防火墙状态 ufw status ，开启防火墙 ufw enable，关闭防火墙 ufw disable 

+ **Linux 系统资源状态管理 **

Linux 查看进程 ps aux

查看进程 htop 更好用 需要安装 ：apt install htop 

启动服务 systemctl start nginx

停止服务 systemctl stop nginx

重启服务 systemctl restart nginx

查看服务状态 systemctl status nginx 






1. [[SWPUCTF 2021 新生赛]gift_F12](https://www.nssctf.cn/problem/382)

#### 思路 
打开靶机，F12查看源码，Ctrl+F查flag找到flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/70155640/1792085148102-fc904a0c-1b6a-4c13-a7d8-e70d93caba5b.png)

#### EXP
无

#### 总结
有打开题解环境、看源码、查找字段和阅读题意的能力





2. [robots.txt](https://www.qsnctf.com/#/main/driving-range?page=1&category=&difficulty=&keyword=robots.txt)

#### 思路
打开靶机看到登录界面 -- 用dirsearch输出文件扫描隐藏可访问文件，并将结果记录在result.txt文件中。

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/70155640/1792085615302-c31af010-cc5b-44b5-a005-7bee8b17256c.png)

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/70155640/1792085700467-c434f0ac-a29f-4bb3-b35e-8adf39a8dff1.png)

访问隐藏的robots.txt文件，发现secret.php文件，尝试访问

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/70155640/1792085773324-3ad1df3c-e86f-4cfd-80cd-1010a00a653e.png)

发现密码就藏在这里，输入密码登入，获得flag

#### EXP
无

#### 总结
善于运用dirsearch去扫描网址，发现隐藏文件





3. [[MoeCTF 2021]Web安全入门指北—GET](https://www.nssctf.cn/problem/3412)

#### 思路
打开靶机，发现题目利用GET传参来请求数据，由代码可知参数名为moe，对象文件为flag

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/70155640/1792118556913-6782e52e-ceaa-4ae5-b06c-a90a0837aefc.png)

对url实施GET传参：[http://node5.anna.nssctf.cn:28688?moe=flag](http://node5.anna.nssctf.cn:28688/?moe=flag)，获得flag

#### EXP
无

#### 总结
利用HTTP请求的GET方式正确传入参数，拿到隐藏数据

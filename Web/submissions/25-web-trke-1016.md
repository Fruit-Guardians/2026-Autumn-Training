# Week-1
+ ID:trke
+ 日期：2026-10-15

## 前期准备日志
+ 用Steam++加速Github的访问，并Fork仓库到个人GIthub账号
+ 阅读Hun Sec 2026 秋季培训文档
+ 在语雀建立<Web--学习日志>和<Web-WP>知识库
+ 学习Markdown语法，并使用语雀写总结和WP

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/6700c874-6317-4eed-a5de-056894497923)

 

## 预备知识学习<font style="color:#F297CC;"></font>
+ **Burp Suite 已安装 -- 用于抓包，改包，发包**

基本操作：打开Burp Suite , 打开内嵌浏览器 ，输入要抓包的网址 ，开启拦截抓包，发送到repeater进行测试。

+ **Hackbar 插件 已安装 -- 用于网络渗透测试**

基本操作：打开Firefox，按F12进入面板，点击Hackbar图标，切分、修改、发送url  ；base64，url，hex，解码编码 ；MD5，SHA-1，SHA-256，ROT13加密 ；SQL注入,XSSpyload

+ **dirsearch 已安装 -- 用于暴力扫描**

基本操作：打开D:\Sec_tool\Sec_Recon\dirsearch ，输入cmd ，输入相关命令 [dirsearch命令 -- CSDN](https://blog.csdn.net/2301_79518550/article/details/147349972)

+ **python3 + pip 已安装 -- python环境**
+ **vscode -- 已安装 -- 提供各种语言环境**
+ **vmvare + kali虚拟机 + win10靶机已安装 -- 用于学习Linux命令，及攻击测试**

## Linux 操作系统

### 1. 搭建 Linux 环境

已成功下载并安装 VMware + Kali。

<!-- 这是一张图片，ocr 内容为： -->
![](https://github.com/user-attachments/assets/1effce01-3a49-4c35-9396-939e9b327cab)

#### 设置 root 账户与国内镜像源

```bash
# 设置 root 密码
sudo passwd root

# 切换到 root 用户
su root
```

配置国内镜像源：

1. 更新软件包索引：

   ```bash
   apt update
   ```

2. 编辑软件源列表：

   ```bash
   vim /etc/apt/sources.list
   ```

   写入以下内容：

   ```text
   deb https://mirrors.aliyun.com/kali kali-rolling main non-free contrib non-free-firmware
   ```

3. 清理下载包和缓存，然后再次更新：

   ```bash
   apt clean
   apt update
   ```

#### 安装、卸载与查看软件

| 操作 | 命令 |
| --- | --- |
| 安装软件 | `apt install <软件名>` |
| 卸载软件 | `apt remove <软件名>` |
| 查看软件 | `apt show <软件名>` |

#### 常用快捷键

| 快捷键 | 作用 |
| --- | --- |
| `Ctrl+Shift+C` | 复制 |
| `Ctrl+Shift+V` | 粘贴 |
| `Ctrl+L` | 清屏 |
| `Ctrl+C` | 停止运行 |
| `Ctrl+E` | 光标移至行尾 |
| `Ctrl+A` | 光标移至行首 |
| `Ctrl+U` | 清除光标至行首的内容 |
| `Tab` | 补全命令 |
| `↑` / `↓` | 上一条 / 下一条命令 |
| 右键 | 补全提示 |
| `Ctrl+D` | 关闭 shell 会话 |

### 2. 学习基本 Linux 命令

命令手册：[Linux 命令手册（菜鸟教程）](https://www.runoob.com/linux/linux-command-manual.html)

#### 帮助与目录查看

- `man <命令>`：查看完整手册（最全）
- `<命令> --help`：查看简要帮助
- `whatis <命令>`：查看命令的核心说明

查看目录内容：

| 命令 | 作用 |
| --- | --- |
| `ls` | 列出当前目录内容 |
| `ls -a` | 显示隐藏文件 |
| `ls -t` | 按最近修改时间排序 |
| `ls -l` | 详细展示文件信息 |
| `ls -lh` | 以易读单位（KB/MB）展示文件大小 |

#### 目录进出

| 命令 | 作用 |
| --- | --- |
| `cd <目录>` | 进入目录 |
| `cd ./` | 进入当前目录 |
| `cd ..` | 返回上一级目录 |
| `cd /` | 返回根目录 |

#### 查看文件内容

| 命令 | 作用 |
| --- | --- |
| `file <文件>` | 查看文件类型 |
| `cat <文件>` | 查看小文件 |
| `more <文件>` | 分页查看；空格键翻页，按 `q` 退出 |
| `less <文件>` | 可上下滚动，不会一次性加载全部内容；按 `/` 搜索，`n` 下一个，`N` 上一个 |
| `head <文件>` | 查看前 10 行 |
| `tail <文件>` | 查看后 10 行 |

#### 创建、复制、移动与删除

- 创建目录：`mkdir <目录>`
- 创建多级目录：`mkdir -p b/c/d`
- 创建文件：`touch <文件>`
- 复制文件：`cp 1.txt <目标目录>`
- 复制目录：`cp -r a b`（`-r` 表示递归）
- 移动或重命名：`mv <文件> <目标目录>`；`mv <旧名字> <新名字>`
- 删除文件：`rm <文件>`
- 强制删除：`rm -f`
- 递归删除文件夹：`rm -rf <目录>`

#### 通配符与管道

- `*`：匹配任意字符
- `?`：匹配单个字符
- `[ ]`：匹配指定范围，例如 `[0-9]`、`[a-z]`
- `|`：管道，把前一个命令的输出作为后一个命令的输入

#### 查找：find 与 grep

按文件名查找：

```bash
find . -name "*.txt"   # . 表示当前目录
```

按文件类型查找：

```bash
find . -type d   # -type d 表示查找目录
```

按文件大小查找：

```bash
find . -size +1M   # 查找当前目录下大于 1M 的文件
```

在文件内容中查找：

```bash
grep "关键字" 文件名
```

#### 编辑文件：vim

```bash
vim 文件名
```

| 操作 | 按键 |
| --- | --- |
| 进入编辑模式 | `i` |
| 退出编辑模式 | `Esc` |
| 保存并退出 | `:wq` |
| 强制退出 | `:q!` |

#### 文件压缩与解压

**zip（兼容性好）**

压缩：

```bash
zip -r 压缩包名.zip 文件或目录   # -r 表示递归压缩目录；多个文件用空格隔开
```

解压：

```bash
unzip 压缩包名.zip           # 解压到当前目录
unzip 压缩包名.zip -d /a/b   # 解压到指定目录
```

**tar（最常用）**

`-v` 表示显示压缩 / 解压过程；多个文件用空格隔开。

| 操作 | 命令 |
| --- | --- |
| 压缩 | `tar -czvf 压缩包名.tar.gz 文件或目录` |
| 解压 | `tar -xzvf 压缩包名.tar.gz` |
| 解压到指定目录 | `tar -xzvf 压缩包名.tar.gz -C ./output`（也可写 `/home/ctf/output`） |
| 查看压缩包内容 | `tar -tzvf 压缩包名.tar.gz` |

#### Linux 网络管理

| 操作 | 命令 |
| --- | --- |
| 查看网络信息 | `ifconfig`（未安装时执行 `apt install net-tools -y`） |
| 查看所有网卡信息 | `ip addr` |
| 测试网络连通性 | `ping www.baidu.com` |
| 指定 ping 4 次后停止 | `ping -c 4 www.baidu.com` |
| 测试 HTTP 访问（返回 HTML 内容） | `curl https://www.baidu.com` |
| 查看防火墙状态 | `ufw status` |
| 开启防火墙 | `ufw enable` |
| 关闭防火墙 | `ufw disable` |

#### Linux 系统资源与进程管理

| 操作 | 命令 |
| --- | --- |
| 查看进程 | `ps aux` |
| 交互式查看进程（更好用） | `htop`（需安装：`apt install htop`） |
| 启动服务 | `systemctl start nginx` |
| 停止服务 | `systemctl stop nginx` |
| 重启服务 | `systemctl restart nginx` |
| 查看服务状态 | `systemctl status nginx` |




1. [[SWPUCTF 2021 新生赛]gift_F12](https://www.nssctf.cn/problem/382)

#### 思路 
打开靶机，F12查看源码，Ctrl+F查flag找到flag

<img src="https://github.com/user-attachments/assets/7212c41a-0595-428c-9776-0f37def523b9" width="1046.6667406058657" alt="" title="" crop="0,0,1,1" id="u814a4211" class="ne-image">

#### 总结
有打开题解环境、看源码、查找字段和阅读题意的能力





2. [robots.txt](https://www.qsnctf.com/#/main/driving-range?page=1&category=&difficulty=&keyword=robots.txt)

#### 思路
打开靶机看到登录界面 -

<img src="https://github.com/user-attachments/assets/529e0b73-380c-4c1e-b14c-06ce39c7e5c3" width="582" alt="" title="" crop="0,0,1,1" id="ud19edd0b" class="ne-image">

使用 dirsearch 工具输出文件扫描隐藏可访问文件

<img src="https://github.com/user-attachments/assets/46693198-6e5f-4784-94dd-709b2e8f37d1" width="1255.555644251198" alt="" title="" crop="0,0,1,1" id="u6513fe13" class="ne-image">

并将结果记录在result.txt文件中，发现 robots.txt 文件

<img src="https://github.com/user-attachments/assets/c08c73a5-ff45-4774-bf34-2ace744b5406" width="1391.111209382743" alt="" title="" crop="0,0,1,1" id="u1ada8742" class="ne-image">

访问隐藏的robots.txt文件，发现secret.php文件，尝试访问

<img src="https://github.com/user-attachments/assets/27a6ebc2-6524-47b6-a526-189d6b35c2e1" width="1166.6667490829714" alt="" title="" crop="0,0,1,1" id="u86c3e94b" class="ne-image">

发现密码就藏在这里

<img src="https://github.com/user-attachments/assets/439d8b07-894c-4c4d-930c-72fa9f06fd66" width="523.9923706054688" alt="" title="" crop="0,0,1,1" id="u672c49d4" class="ne-image">

输入密码登入，获得flag

<img src="https://github.com/user-attachments/assets/d4fd1355-b5c9-4bb9-b78d-5bd614814442" width="512.9885864257812" alt="" title="" crop="0,0,1,1" id="u905f3ba7" class="ne-image">

<img src="https://github.com/user-attachments/assets/10f0ef11-75d6-4a0b-b17e-fb106d4afb7f" width="514.5454248055299" alt="" title="" crop="0,0,1,1" id="u4001642d" class="ne-image">

#### 总结
善于运用dirsearch去扫描网址，发现隐藏文件





3. [[MoeCTF 2021]Web安全入门指北—GET](https://www.nssctf.cn/problem/3412)

#### 思路
打开靶机，发现题目利用GET传参来请求数据，由代码可知参数名为moe，对象文件为flag

<img src="https://github.com/user-attachments/assets/96de991f-e6de-4e46-b48e-a5c35e3bc3bf" width="637.7778228320244" alt="" title="" crop="0,0,1,1" id="u55dbc059" class="ne-image">

对url实施GET传参：[http://node5.anna.nssctf.cn:28688?moe=flag](http://node5.anna.nssctf.cn:28688/?moe=flag)，获得flag

<img src="https://github.com/user-attachments/assets/7bd92534-0b5c-4155-aeba-2a515deed363" width="480" alt="" title="" crop="0,0,1,1" id="ua02fb1e6" class="ne-image">

#### 总结
利用HTTP请求的GET方式正确传入参数，拿到隐藏数据



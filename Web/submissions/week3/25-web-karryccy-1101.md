# 本周学习总结  
-ID：karryccy
-方向：web
-日期：2026-11-1

---
## 基础工具安装
由于本周刚开始加入学习，首先学习了基础工具的安装：包括加速器，BurpSuite,VScode,Docker,linux虚拟机以及火狐Hackbar插件的安装等等。
![](Pasted%20image%2020261101185609.png)
![](Pasted%20image%2020261101185515.png)
![](Pasted%20image%2020261101185823.png)


---
## Linux 操作系统理论学习
### 理论学习

1. 核心思想：Linux遵循**一切皆文件**，硬件、目录、进程、设备都以文件形式管理，和Windows的设计逻辑不同。
2. 用户体系：分为root超级用户和普通用户；root拥有最高权限，普通用户需要`sudo`临时提权，最小权限原则是安全基础。
3. 文件权限：r（读）、w（写）、x（执行），权限分为属主、属组、其他用户三组，通过`chmod`修改权限，防止越权访问。
4. 目录结构：标准树形目录，`/`是根目录；`/etc`存放配置、`/home`存放用户文件、`/var`存放日志，Web靶场、漏洞经常读取这些路径。
5. 进程基础：程序运行产生进程，系统通过PID标识进程，可查看、终止进程，用于排查服务（Apache、MySQL）运行状态。
6. 安全意义：绝大多数Web服务器、渗透工具运行在Linux，命令注入、本地文件包含等漏洞都依托Linux系统特性，掌握理论才能看懂漏洞效果。
### 后续安排

本次学习大概了解了Linux系统的相关知识，下周利用VirtualBox和Kali Linux 进行实践学习，对比与Windows系统的具体差异。


---

## SQL注入漏洞学习
### 环境依赖
-操作系统：Windows
-靶场：DVWA
-集成环境：phpStudy(Apache+MySQL+PHP)
-工具：PyCharm  

### 学习过程
1.靶场部署
浏览器访问官网https://www.xp.cn/，下载安装phpstudy集成环境，内置Apache 网页服务器，MySQL数据库，PHP运行环境，安装路径务必先选择安装到D盘，文件夹命名不能包含中文、空格，禁止安装到C盘，因为第一次装错导致启动时完全报错。

安装成功后启动Apache和MySQL
![](Pasted%20image%2020261101173247.png)

安装配置DVWA，在GitHub获取安装包源码压缩包，解压压缩包后修改DVWA数据库配置文件，完成后打开浏览器访问http://localhost/DVWA-master/setup.php，来到DVWA界面
![](Pasted%20image%2020261101174018.png)

登录后进入选择SQL Injection。  

2.原理学习
通过“PortSwigger SQL 注入专题”初步学习了漏洞原理，简单概括就是：用户输入未经过滤直接拼接进SQL字符串，导致数据被当成代码执行导致数据库信息泄露。
https://portswigger.net/web-security/sql-injection?spm=5176.28103460.0.0.96a02988VcRE7a
![](Pasted%20image%2020261101175055.png)
1为合法输入，页面正常返回

![](Pasted%20image%2020261101180812.png)
通过字符串拼接，直接把用户输入信息拼接到SQL语句中，获取当前数据库名

![](Pasted%20image%2020261101181031.png)
获取用户名和MD5密码

3.payload构造
用Python编写自动化攻击脚本，用于提高注入效率，从DVWA获取session，作为通行证让脚本直接登录并进行注入。（这里脚本主要是借助AI了，因为代码能力还没那么强）
![](Pasted%20image%2020261101182112.png)

4.三级源码代码设计
low级源码漏洞核心代码
```php
 $id = $_REQUEST[ 'id' ];    // Check database    $query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
```
直接接收了用户传入的参数，没有任何过滤。

medium级源码漏洞核心代码
```php
$id = $_POST[ 'id' ];    $id = mysqli_real_escape_string($GLOBALS["___mysqli_ston"], $id);    $query  = "SELECT first_name, last_name FROM users WHERE user_id = $id;";
```
这里加了转义单引号，但数值型注入不需要单引号，抓包修改POST参数即可注入。

high级源码漏洞核心代码
```php
$id = $_SESSION[ 'id' ];    // Check database    $query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id' LIMIT 1;";
```
从Session拿ID，需要现在别的页面注入，但依旧没有采用impossible级的预编译，字符拼接任可注入。

#### 问题及后期学习
1.Apache一开始由于端口冲突，导致多次启动失败，耗费大量时间；注入闭合符号判断出错；自动化攻击脚本成功，但只能做到漏洞检测，运行后还需手动分析结果。下周将输入研究自动化探测脚本的功能完善性。
2.后续将继续学习DVWA靶场里面XSS, File Upload文件上传漏洞，Command Injection 命令注入等功能。
3.本次探究SQL注入原理详细研读了文献“A Survey of SQL Injection Attack Detection and Prevention”（https://www.scirp.org/journal/paperinformation?paperid=46543），主要讲针对漏洞的攻击与防御技术，对比了正则匹配、输入过滤、预编译等传统防护手段的优势与缺陷；介绍机器学习在注入检测上的应用思路，依靠样本自动学习攻击特征，识别变形、绕过类注入。文章指出单一方案存在短板，提出将机器学习与传统防御手段结合，提升对SQL注入的检测与防护效果。对此，后期将深入实践并进行复现。
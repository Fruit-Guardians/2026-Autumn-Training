# 低加密指数攻击

## 1.数学基础

众所周知，我们解RSA的核心就是找到 $p，q$ ，然后求解 $\varphi(n)$ 来求逆元得到 $d$ ，最后用求解公式反解密文

但是，在Cry的世界里也并非所有的问题都要这么麻烦

比如我们接下来要学习的低加密指数攻击

当 $e$ 等于一个很小的数，比如说3，这个时候你就可以观察一下 $n$ 和 $c$ 的特点，

第一种情况，如果说 $c$ 的大小小于 $n$ ,那么这个时候，**取模就约等于白取**

即

$$
m^e\equiv c\pmod n
$$

等价于

$$
m^e=c
$$

也就是说，只要对这个 $c$ 开三次根号，那么就是直接等于密文 $m$ !

所以只要观察出低加密指数的这种情况，就一定可以直接通过gmpy2下的工具root,is_exact秒杀，连 $p,q$ 都不用求！

具体的例子我会放在最后（*因为官网给的例题没有*）

那么如果是 $n$ 和 $c$ 差不多甚至更小呢

这个时候就需要用到同余的概念了

我们知道，同余的本质是这样的

$$
m^e=kn+c
$$

因为 $e$ 不大，我们就可以爆破 $k$ （*低情商：一个一个试*）来解决这个m

正常这种题目 $k$ 就是10000以内的数（*当然，是对于我们来说，我后面在Cry Wiki了解到一个用python2敲了一个多进程爆破1.3亿个数的脚本，使用了multiprocessing下的工具pool*）

所以使用for语句就能解决

## 2.实操环节

依旧放上题目

```python

import libnum
import gmpy2
import uuid
flag = "flag{" + str(uuid.uuid4()) + "}"
m = libnum.s2n(flag)
print(gmpy2.bit_length(m ** 3))
while True:
    p = libnum.generate_prime(504)
    q = libnum.generate_prime(504)
    n = p * q
    phi_n = (p - 1) * (q - 1)
    e = 3
    if gmpy2.gcd(e, phi_n) == 1 and  phi_n%e !=0:
        break

c = pow(m, e, n)
print("n=", n)
print("e=", e)
print("c=", c)

```

生成了

$n$ = 852452890511677162586395872841427696849700868419388648323723364705683808854484727512610383618167833465035129547513217323817226530311475744903520044539788774026097603188294296832500722927088279924861154761418936415426888721949900139663754726808699652522036697380194395726187007176996347827104436730588953


$e$ = 3


$c$ = 175676150266427336724295891447855298264780959914755126568639429700367828401581796202899146157303703399620563667107897578485495666720379192758585343266307237886135472378523081667781773893074644938666429995467243163037091648094932565002537093720565325996555207093217977543171879924110889414471212861580389

这个题目生成的 $n$ 和 $c$ 好像是大小相近的

所以我就直接使用了第二种情况下的方法

```python

from Crypto.Util.number import long_to_bytes
import gmpy2

#这里是生成的n，e，c

for i in range(0, 10000):
    target = i * n + c
    root, is_exact = gmpy2.iroot(target, e)
    if is_exact:
        print(root)
        print(long_to_bytes(root).decode())
        break
else:
    print("error!")

```

结果长这样

<img width="784" height="52" alt="image" src="https://github.com/user-attachments/assets/5731d71e-b89a-4b05-b3f0-6d446543e9c3" />

符合格式

就是直接用for语句一个一个试就出来了

如果熟悉了运作原理，那这个题型的简单版本也就是手拿把掐

答案就是运作不出来

一直报SyntaxError

查询AI 说是trange是tqdm里的东西，他没有添加

而且后面也不再用（）

另外，参考其他做法后 while true 和 t+=1 的组合好像也行

AI建议我把写的代码用def语法保存下来，保存成一个tool.py文件

正在操作中，但是交作业不会直接引用

## 3.补充

由于没有第一种情况的代码，我让AI给我出了一个小数字的题目

本质上也是一样的，就是直接对c开e次方根

```python

import gmpy2
from Crypto.Util.number import long_to_bytes


n = 40000014400001287
e = 3
c = 19100843355929489


root, is_exact = gmpy2.iroot(c, e)

if is_exact:
    print(f"[+] True")
    
    m = int(root)
    flag = long_to_bytes(m).decode()
    
    print(f"[+]  m = {m}")
    print(f"[+] 最终明文 = {flag}")
else:
    print(f"[-] error！")

```


还有前面提到的多进程，这个我还没看懂

或许等这周的任务结束会去进行这方面的小学习

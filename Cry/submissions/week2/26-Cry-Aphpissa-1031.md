# dp泄露攻击

*最燃尽的一集*

## 一.常规dp攻击

### 1.什么是dp？

dp是**CRT-RSA**中的量，是私钥的一部分

### 2.什么是CRT-RSA？

**CRT-RSA**是根据中国剩余定理（*CRT*）优化的RSA算法，这个算法可以让RSA的解密过程提高3~4倍

具体工作原理如下

我们设：

$$
dp = d \\bmod (p-1)
$$

$$
dq = d \\bmod (q-1)
$$

$$
qinv = p^{-1} \\bmod q
$$

这个环节就相当于把d拆成了两部分

原理就在于根据费马小定理

$$
c^{p=1}\equiv 1\pmod p
$$

而

$$
d\equiv dp\pmod p
$$

$$
q\equiv dq\pmod q
$$

所以

$$
c^{dp}\equiv c^d\pmod p
$$

同理，有

$$
c^{dq}\equiv c^d\pmod q
$$

所以

$$
m_p\equiv c^d\equiv m\pmod p
$$

$$
m_q\equiv c^d\equiv m\pmod q
$$

因而可以用中国剩余定理求解

### 3.持有私钥的解密过程

第一步，先算影子，即先对 $c$ 取 $dp,dq$ 的模

$$
m_p=c^{dp}\pmod p
$$

$$
m_q=c^{dq}\pmod q
$$

那怎么求解这个m呢

我们肯定会想到标准解法

<img width="779" height="344" alt="image" src="https://github.com/user-attachments/assets/a0174bda-7448-429d-b972-d05d2d43da16" />

这个解法肯定可行，但是计算量偏大，要存储的量偏多

这个时候我们就需要用到中国剩余定理的Garner解

就是先配一个满足第一个同余方程的解，再去配另一个同余方程的解

我们可以配出

$$
m=m_p+hp
$$

显然，对于这个 $m$ 来说，它永远满足第一个同余方程

那么接下来我们就要配出基于这个解的第二个同余方程的解

即找出 $h$ 使得

$$
m_q\equiv m_p+hp\pmod q
$$

显然可以找出来

直接进行移项

$$
m_q-m_p\equiv hp\pmod q
$$

然后乘上 $qinv$ 可得

$$
qinv(m_q-m_p)\equiv h\pmod q
$$

这就把 $h$ 给求出来了

至此，解密完成

$$
m=m_p+hp
$$

其中

$$
h\equiv qinv(m_q-m_p)\pmod q
$$

由于把 $d$ 拆成两份的缘故，数字变小，所以这样可以更快解密，比常规快出3~4倍

### 4.dp泄露

在CRT-RSA中， $dp$ （或 $dq$ ）都是需要保护的对象，不然如果 $dp$ （或 $dq$ ）泄露了，那么就和 $d$ 泄露没有什么区别

因为由

$$
ed\equiv 1\bmod (p-1)
$$

根据 $dp$ 的定义可知、

$$
dp=d\bmod (p-1)
$$

相乘可得

$$
eddp\equiv d\bmod (p-1)
$$

消去 $d$ 可得

$$
edp-1\equiv 0\bmod(p-1)
$$

也就是说， $edp-1$ 是 $p-1$ 的 $k$ 倍

也就可以用for循环在 $(0,e)$ 的范围内爆破出来！

### 5.实操环节

送上题目

```python

import gmpy2
import libnum
import uuid

flag = "flag{" + str(uuid.uuid4()) + "}"
print(flag)
m = libnum.s2n(flag)
p = libnum.generate_prime(1024)
q = libnum.generate_prime(1024)
e = 65537
n = p * q
phi = (p - 1) * (q - 1)
d = gmpy2.invert(e, phi)
print("d=",d)
dp = d % (p - 1)
c = pow(m, e, n)
print("n=", n)
print("e=", e)
print("c=", c)
print("dp=", dp)

```

由于这个 $k$ 解出来的数有可能不是 $n$ 的因子，因此需要进行判断

我的解法也贴在这里

```python

from Crypto.Util.number import long_to_bytes
import gmpy2

#依旧生成数

for k in range(1,e):
    if (e * dp - 1)%k==0:
        p=((e*dp-1)//k)+1
        if n%p!=0:
            continue
        q=n//p
        phi=(p-1)*(q-1)
        d=gmpy2.invert(e,phi)
        print(d)
        m=pow(c,d,n)
        print(long_to_bytes(int(m)))
        break
else:
    print("No solution")
```

运行结果符合格式

<img width="328" height="32" alt="image" src="https://github.com/user-attachments/assets/eb288505-b00a-4b55-ae47-2a81f29d3705" />

代码和答案差不多

就是要爆破一个倍数，且满足解出来的数是 $n$ 的因子

## 二.e过大

### 1.dp泄露的另解

当 $e$ 过大的时候，直接遍历在 $(0,e)$ 内的所有数肯定不现实

属于理论可行但CPU不接受理论的那种

因此，我们也可以用费马小定理来找一个其他解法

找一个数 $a$ ，且 $a$ 与 $p$ 互素

这时候就可以根据费马小定理得到

$$
a^{edp}-a\equiv 0\pmod p
$$

放在代码里，就是生成一个质数，代入上面那个式子以后就去和 $n$ 求公因数即可解出 $p$

但是有一个很复杂的点

电脑不可能运行一串超大串的幂运算， $a^{edp}$ 就直接算不出来了

解决方法是加入快速幂pow

快速幂pow可以一直把幂控制在小于10的范围内

且根据欧几里得算法，求公约数的时候如果其中一个数减去或加上另一个数的倍数，那么公约数不变

就可以解决诸如此类的问题

### 2.实操环节

题目

```python

import gmpy2
import libnum
import uuid

flag = "flag{" + str(uuid.uuid4()) + "}"
m = libnum.s2n(flag)
p = libnum.generate_prime(1024)
q = libnum.generate_prime(1024)
e = libnum.generate_prime(128)
n = p * q
phi = (p - 1) * (q - 1)
d = gmpy2.invert(e, phi)

dp = d % (p - 1)
c = pow(m, e, n)
print("n=", n)
print("e=", e)
print("c=", c)
print("dp=", dp)

```

这里采用libnum工具生成 $a$ 来保证 $p$ 与 $a$ 互素

```python

from Crypto.Util.number import getPrime,long_to_bytes
import gmpy2
import libnum

#生成的数

a = libnum.generate_prime(256)
print(a)
mid=pow(a,e*dp,n)-a
p=gmpy2.gcd(n,mid)
q=n//p
phi=(p-1)*(q-1)
d=gmpy2.invert(e,phi)
m=pow(c,d,n)
print(long_to_bytes(int(m)))

```

结果也是成功运行

<img width="286" height="34" alt="image" src="https://github.com/user-attachments/assets/5f088d76-bf9d-4940-861d-31aff2f6e84d" />

就是按照上述思路来的代码

只要有思路，剩下的都是翻译问题

## 三.dp高位泄露

### 1.什么是高位泄露

高位泄露，就是 $dp$ 的前几位泄露了，但是没有泄露完全

与之相对的，有低位泄露，也就是后几位泄露了

### 2.高位泄露怎么攻击

如果为高位泄露，那么我们就需要找到低位来填充整个 $dp$ 

根据上面的求解方法，可以直接把公式代入

设未知低位为 $x$

则有

$$
e(leak+x)-1=k(p-1)
$$

移项化简

$$
e(leak+x)-1+k=kp
$$

对 $p$ 取模就有

$$
e(leak+x)-1+k\equiv 0\pmod p
$$


那么高位泄露攻击的关键，就在于把满足条件的 $x$ 和 $k$ 找出来

但是接下来这个方程有两个未知数，而且 $p$ 未知，我们无从下手

于是就来到了一个新的，比较复杂的密码破解方法

### 3.Coppersmith与格基规约（LLL）

*这个东西我现在也很难讲通，但是试一下吧，理解上已经有眉目了*

这个题目中的方程是一个同余方程，我们还是难解的

特别是在 $p$ 比较大的情况下

所以我们需要使用一个新的东西来帮助我们计算

它就是**Coppersmith算法**

因为我们不知道的 $x$ 和 $k$ 是一个比较小的数

所以这个算法一般是可行的

这个算法的核心在于把难解的同余方程转化为好求的普通方程，然后去求解

这个算法是怎么做到的呢

**生成多项式**

首先，它把我们上面那个多项式转换成了函数

$$
f(x,y)\equiv e(leak+x)-1+y\pmod p
$$

的根

接下来，就可以使用一系列的乘法，将 $f(x,y)$ 进行变形，比如乘上模 $N$ ，又比如说乘上未知数 $x,y,x^2,y^2\dots$

构建一连串的等价多项式

**构建矩阵**

然后按照系数向量来进行排列，就可以得到一个矩阵

矩阵的行对应你造出来的**多项式**，矩阵的列对应**所有的单项式**

列的顺序只能按照单项式次数的字典序排

把多项式展开，按系数填进矩阵

**注入缩放因子**

上面得到的矩阵用LLL是跑不出结果的，因为系数会被高次项拉的越来越长，就找不到最短向量了（这个后面会解释）

因此我们需要对每一个行乘以上界（ $X,Y$ ）

比如说

$x$ 的列就乘 $X$

$y$ 的列就乘 $Y$

$x^iy^j$ 的列，就乘以 $X^iY^j$

就可以得到最终矩阵

**LLL格基规约**

接下来你要做的事情，就是让格基协约的代码对这个矩阵进行一系列的变换，找到最短的向量

格基规约会先看欧几里得长度，也就是把一行里面所有的数的平方加起来，再开根号

$$
\text{长度}=\sqrt{v_0^2+v_1^2+v_2^2+\dots}
$$

如果你前面不加放缩项，那么单看系数，无法消除高次项的误差，就会产生非常多的错解

格基规约的本质，就是在这些矩阵里面做各种变换，找到最短的向量（即 $g(x,y)=0$ )

因为 $g(x,y)$ 是由格基规约组合出来的，那么真实的根代入后一定是模 $N$ 的倍数

加上LLL找到了最短的向量，这意味着 $g(x,y)$ 的绝对值会比模 $N$ 来得小

所以求余被打破，得到线性方程组

$$
g(x,y)=0
$$

后面就可以使用消元法（*一般二元的最短向量不止一个*）来求出 $x,y$

格基规约的具体运作方式可以查看培训文档前置中《公钥密码学的数学基础》最后一章

（*其实是自己太菜了看不懂书上的引理和推导，只知道基本的运行方式*）

### 4.实际操作

破解了 $x$ 和 $k$ 后就是正常的dp泄露操作了

这个东西单用python是没有办法实现的，因此就要使用强大的Sagemath

这里放一个参考答案

```python
from Crypto.Util.number import *
import gmpy2
import itertools

def small_roots(f, bounds, m=1, d=None):
    if not d:
        d = f.degree()
        print(d)
    R = f.base_ring()
    N = R.cardinality()
    f /= f.coefficients().pop(0)
    f = f.change_ring(ZZ)
    G = Sequence([], f.parent())
    for i in range(m + 1):
        base = N ^ (m - i) * f ^ i
        for shifts in itertools.product(range(d), repeat=f.nvariables()):
            g = base * prod(map(power, f.variables(), shifts))
            G.append(g)
    B, monomials = G.coefficient_matrix()
    monomials = vector(monomials)
    factors = [monomial(*bounds) for monomial in monomials]
    for i, factor in enumerate(factors):
        B.rescale_col(i, factor)
    B = B.dense_matrix().LLL()
    B = B.change_ring(QQ)
    for i, factor in enumerate(factors):
        B.rescale_col(i, 1 / factor)
    H = Sequence([], f.parent().change_ring(QQ))
    for h in filter(None, B * monomials):
        H.append(h)
        I = H.ideal()
        if I.dimension() == -1:
            H.pop()
        elif I.dimension() == 0:
            roots = []
            for root in I.variety(ring=ZZ):
                root = tuple(R(root[var]) for var in f.variables())
                roots.append(root)
            return roots
    return []

n = 108867023585283899312601516631596145998654767437612286040742902945694826711187570537876759789643259431350352590412655898964386234903475482280911808566497936037152171435317938413515356868240854632004961172899360272761406519077380255802700944002126599829184693692273637230349297388495886988988512631044494610227
c = 55610391226438079690691299914193010897347055835338032942001645697966587672596937470425142446679815934940962159432814479063990621696064239924347523289515556844359094065042974221093712989000153444928594999529082105262409273370242062803004814801742763253605838374098344711160380314529928211369000469059015996052
e = 14257237624892167181
leak = 2451130625204471881762267484243564297625381377098677997721378436579042927693972537775392209546509688501306219327699327137859174235486735043842710630825984

R.<x,y> = PolynomialRing(Zmod(n))
f = e * (leak + x) + (y - 1)
res = small_roots(f,(2^64,2^64),m=1,d=3)
for root in res:
    dp_low = root[0]
    dp = leak + dp_low
    tmp = pow(2,e*dp,n) - 2
    p = gmpy2.gcd(tmp,n)
    q = n // p
    d = inverse(e,(p-1)*(q-1))
    m = pow(c,d,n)
    print(long_to_bytes(m))
```

在Sagemath（Jupyter）里面运行结果如下

<img width="926" height="604" alt="image" src="https://github.com/user-attachments/assets/597ca5a9-1e57-4446-8865-bcaa2ff0749b" />

无语了，不知道怎么解决

查询AI以后发现原因是里面夹杂了python和sage的混合语言

网页版下不了gmpy2和Crypto就有点

然后要在linux运行就要转换成纯sage

<img width="844" height="409" alt="image" src="https://github.com/user-attachments/assets/2d809405-3f1d-41d4-8bfa-f2afa86c04bb" />

看来好像就是他代码的问题

AI 说是这一行

```python
f /= f.coefficients().pop(0)
```

说f在Zmod(n)上啥的，和环域有关

看来后面要补的数学知识还有很多

毕竟我都没怎么接触过Sagemath，也不会调度工具来进行运算

这就是我以后要努力的方向

以后就自己手搓一个矩阵出来

### 5.补充：低位泄露

低位泄露的话，就要进行移位

因为数据是二进制的，所以具体操作就是在前面加一个 $2^L$ （L是已知泄露的低位比特位数）

而且低位泄露增加 $2^L$ 这个系数符合Coppersmith算法中求小根的思想

一般是二进制，也有可能十进制，十六进制

这个时候底数就要换成对应的数字

具体就是（以二进制为例）

$$
f(x,k)=(e2^L)x+(eleak-1)+k\equiv 0\pmod p
$$

然后拿这个函数用和上面相同的办法生成多项式，构造矩阵求最短向量，消元求x，k

## 四.写在最后

今天的内容我觉得相当难

让我尝到了一整天都在研究一件事情和敲代码，配环境的滋味

Coppersmith和格基规约的内容相当硬核

用Jupyter和linux运行Sagemath更让我血压上升

不过没办法，这就是学习

本来今天还想按照学长说的跑一跑多进程hash的

等后面有时间再说吧

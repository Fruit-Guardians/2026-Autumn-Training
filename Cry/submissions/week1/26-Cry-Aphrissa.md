# RSA基础
*以下内容为本人个人在学习时的感悟*
## 一.数论基础
*这里只展示与这些理论与RSA有关的部分*
### 1.费马小定理
内容：若p为素数，a为整数且a不被p整除，则有：

$$
a^{p-1} \\equiv 1 \\pmod p
$$

### 2.欧拉函数与欧拉定理
内容：欧拉函数 $\varphi(n)$ 表示的是在1，2，3，...，n中，与n互素的正整数个数

**公式**

素数：若p为素数，则有

$$
\varphi(n)=p-1
$$

积性：若 $\gcd(m,n)=1$ ,则

$$
\varphi(mn)=\varphi(m)\varphi(n)
$$

注：**只对互素的两个数成立，不是完全积性**

### 3.中国剩余定理

内容：设 $m_1,m_2.\dots.m_k$ 两两互素，即：

$$
\gcd(m_i,m_j)=1\quad(i\ne j).
$$

考虑同余方程组

$$
\begin{cases}
x\equiv a_1\pmod{m_1}.\\
x\equiv a_2\pmod{m_2}.\\
\vdots\\
x\equiv a_k\pmod{m_k}.
\end{cases}
$$

令

$$
M=m_1m_2\cdots m_k
$$

则方程组在模M下有唯一解

**构造解法**

令

$$
M_i=\frac{M}{m_1}
$$

因为 $m_i$ 与 $M_i$ 互素，所有我们可以求得 $M_i$ 在 $m_i$ 下的逆元

设

$$
t_i\equiv M_i^{-1}\pmod{m_i}
$$

那么一个解是

$$
t_i\equiv\sum_{i=1}^k a_iM_it_i\pmod{M}
$$

直观理解：对第j个方程，当 $i\ne j$ 时， $M_i$ 就有一个含 $m_j$ 的因子，所以 $a_iM_it_i$ 和0对 $m_j$ 同余，而 $a_jM_jt_j$ 和 $a_j$ 对 $m_j$ 同余。因此整体满足所有方程（每个分量相加，就是唯一解）

## 二，RSA算法

### 1.加密与解密

我们知道，文本可以转换成一串大数字来表示，这个数字我们记为m，称为**明文**

先找到两个大素数p，q

接下来**算模数**：计算 $n=p\times q$ （n可以公开，但是p，q必须销毁）

再算欧拉函数 $\varphi(n)=(p-1)\times (q-1)$

选择公钥指数e,满足 $1<e<\varphi(n)$ ,且e和 $\varphi(n)$ 互质（不互质就没有逆元，就无法解密了）

算私钥指数d:求e模 $\varphi(n)$ 的逆元，即 $d=e^{-1}\bmod{\varphi(n)}$

**结果**

公钥为（n，e），可以拿给任何人

私钥为（n，d），自己收着

**公式**

加密： $c=m^e\bmod n$

解密： $m=c^d\bmod n$

**推导**

因为

$$
c^d\equiv(m^e)^d=m^(ed)
$$

而 $ed\equiv\pmod{\varphi(n)}$ ,所以存在整数k，使得

$$
ed=1+\varphi(n)
$$

于是

$$
m^{ed}=m^{1+k\varphi(n)}=m\cdot(m^{\varphi(n)})^k
$$

若 $\gcd(m,n)$ =1 ,由欧拉定理：

$$
m^{\varphi(n)}\equiv1\pmod n
$$

所以

$$
m^{ed}\equiv m\pmod n
$$

且 $\gcd(m,n)\ne1$ 也成立 

我们来看一下这种情况

若 $p\nmid m$ ,由费马小定理：

$$
m^{(p-1)}\equiv1\pmod p
$$

而 $varphi(n)=(p-1)(q-1)$ ,所以

$$
m^{ed}=m^{1+k(p-1)(q-1)}\equiv m\pmod p
$$

若 $p\mid m$ ,则两边都会同余于 $0\pmod p$ 。

因此总有

$$
m^{ed}\equiv m\pmod p
$$

同理

$$
m^{ed}\equiv m\pmod q
$$

由于 $p.q$ 互素，由中国剩余定理：

$$
m^{ed}\equiv m\pmod {pq}
$$

即

$$
m^{ed}\equiv m\pmod n
$$

所以RSA解密的本质是费马小定理和中国剩余定理，欧拉是更直接的表述

##三. RSA在实际python中的表示

在打python的时候，通常要用到下面几个工具

**1.** $pow()$ 这个东西是用来求模运算的

**2.** $gmpy2$ $libnum$ $uuid$ 第一个是数运算工具，第二个是字符串互转工具，第三个是随机字符生成器

需要注意的是，用第一个数字运算出来的东西是高精度的数字类型mpz，要运算要前面补上int

以下是我找AI生成的入门*其实超简单*的RSA题目，我给的解题代码也一起给出来

<img width="319" height="349" alt="image" src="https://github.com/user-attachments/assets/539e9376-b93e-4340-acc7-e71eadfd2fde" />

结果长这样

<img width="197" height="167" alt="image" src="https://github.com/user-attachments/assets/ac29d8c8-3bb1-4a63-b365-3f48ed364ca0" />

*转换的话应该有更方便的办法*

*根据AI的建议选择了for循环来找p，q，不过大数就别用了*

*另外，不要拿AI生成大数的RSA,AI可以把1718378855的三次方算错无数遍*

这就是我对RSA基础内容的自主学习成果了

接下来按各项内容进行学习，并做网站上的相关题目

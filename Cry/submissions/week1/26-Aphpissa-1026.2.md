# 共享素数

```python
import gmpy2
import libnum
import uuid

flag = "flag{" + str(uuid.uuid4()) + "}"
m = libnum.s2n(flag)
p = libnum.generate_prime(1024)
q1 = libnum.generate_prime(1024)
q2 = libnum.generate_prime(1024)
n1 = p * q1
n2 = p * q2
e = 65537
c1 = pow(m, e, n1)
c2 = pow(m, e, n2)
print("n1=", n1)
print("n2=", n2)
print("c1=", c1)
print("c2=", c2)
```

<img width="663" height="392" alt="image" src="https://github.com/user-attachments/assets/73d51172-fb88-407e-9e25-0abd8d231dc8" />

题目长这样

可以看到，题目使用了同一个p去进行运算

对于RSA来说，比较重要的是找到p和q

而这类题型的关键便在于求出 $n_1,n_2$ 的共同因子

也就是求出它们的公因数（可以知道，他们都是由两个素数相乘得来的）

我就直接用了一个纯用python手搓的办法（并非，也是用了gmpy2工具去求了逆元的）

```python
import gmpy2

#这里是生成的 n1,n2,c1,c2

p=gmpy2.gcd(n1,n2)
print(p)

if p==1:
    print("break")
else:
    q1 = n1 // p
    q2 = n2 // p
    print(q1, q2)
    phi1 = (q1 - 1) * (p - 1)
    phi2 = (q2 - 1) * (p - 1)
    d1 = gmpy2.invert(e, phi1)
    d2 = gmpy2.invert(e, phi2)
    print(d1, d2)
    m1 = pow(c1, d1, n1)
    m2 = pow(c2, d2, n2)
    print(m1, m2)
    length1 = (int(m1).bit_length() + 7) // 8
    length2 = (int(m2).bit_length() + 7) // 8
    mid1 = int(m1).to_bytes(length1, 'big')
    mid2 = int(m2).to_bytes(length2, 'big')
    print(mid1, mid2)
    key1 = mid1.decode()
    key2 = mid2.decode()
    print(key1, key2)
```

<img width="366" height="581" alt="image" src="https://github.com/user-attachments/assets/2555f78c-2113-4f50-a55d-8d31a1b37f3f" />

结果长这样


<img width="556" height="37" alt="image" src="https://github.com/user-attachments/assets/3bf5db4d-1005-4ed7-8d19-fdcdadaf75e2" />

*因为你在实战中是看不到题目代码的，所以要进行判定，这也是我第一版犯的错*

可以看到，非常的长

在实际的竞速中没有什么优势，尽管这样子答出来是对的且有一定思路

标准答案中给出了另一种解法

```python
from Crypto.Util.number import long_to_bytes
import gmpy2

#这里是生成的 n1,n2,c1,c2

t = gmpy2.gcd(n1,n2)
if t != 1:
    p = t
    q = n1 // p
    d = gmpy2.invert(e,(p-1)*(q-1))
    print(long_to_bytes(pow(c1,d,n1)))
```

<img width="309" height="257" alt="image" src="https://github.com/user-attachments/assets/3e195777-4450-4c3c-8651-28493efe7840" />

答案调用了Crypto中的库long to bytes

可以把解出来的数直接打包带走变成bytes形式

不过个人觉得，答案应该在pow前面加上一个int

因为调用gmpy2的话经过gmpy2运算过的数是gpz格式，而long to bytes最好使用int

之后会随着学习深入，了解更多工具库及其用法



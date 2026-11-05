# 多进程爆破

这个其实算我在小明文爆破中发现的支线

是一个很好用的工具

有必要学习一下

具体使用方法就是导入multiprocessing中的Pool工具

这里也是直接找到了一道和多进程有关的题目，就拿过来试一试，熟悉一下这个工具

## CryptoHack例题：Marin’s Secret

**解题**

打开txt.看看题目

<img width="939" height="333" alt="image" src="https://github.com/user-attachments/assets/34d89196-ede2-4453-ba05-bb556e861652" />

最想用yahu直接爆破的一集

但是题目也给了py.，我们还是看一眼

```python
#!/usr/bin/env python3

import random
from Crypto.Util.number import bytes_to_long
from secret import secrets, flag


def get_prime(secret):
    prime = 1
    for _ in range(secret):
        prime = prime << 1
    return prime - 1


random.shuffle(secrets)

m = bytes_to_long(flag)
p = get_prime(secrets[0])
q = get_prime(secrets[1])
n = p * q
e = 0x10001
c = pow(m, e, n)

print(f"n = {n}")
print(f"e = {e}")
print(f"c = {c}")
```

好吧，其实我一开始看这个也是一头雾水

后面想起来了，有一行在低位泄露的题目中我看到过

```
   prime = prime << 1
```

何移位

为何移位

你在二进制里面循环移动 $secret$ 位，不就是乘以 $2^{secret}$ 次方吗

那就有点说法了

这个 $p$ 就是 $2^{secret}-1$

也就意味着，我们可以去爆破这个 $secret$ 

**解题**

用for语句肯定不太行，算太慢了而且电脑会不高兴

我直接设置一个函数，然后默写（实则并非默写，还是有点生疏的）多进程脚本爆破

注意这里要使用上次提到的快速幂去爆破，不然你电脑的小风扇就要载着你的电脑上天了

```
def crack(x):
        p=gmpy2.gcd(pow(2,x,n)-1,n)
        if p!=1 and p!=n:
            return p
        return None


if __name__ == '__main__':
    found_p = None
    data_range = range(2, 1000000)

    # 开启多进程
    with Pool() as pool:
        for result in pool.imap_unordered(crack, data_range):
            if result:
                found_p = result
                print("爆破成功！")
                pool.terminate()
                break


    if found_p:
        p = int(found_p)
        q = n // p
        phi = (p - 1) * (q - 1)
        d = inverse(e, phi)
        m = pow(c, d, n)
        print("Flag:", long_to_bytes(int(m)).decode())
    else:
        print("没找到，可能需要扩大范围")
```

也是非常快就运行出来了

<img width="246" height="74" alt="image" src="https://github.com/user-attachments/assets/73955d4c-6097-4943-9657-b413ad7171d8" />

第一个就是定义函数，准备爆破

那个if __name__=='__main__'就是防止无限递归创建子进程的

后面就是基本可以默写的级别

## 意外之喜

在寻找题目的过程中，我还看到了什么平滑数，交互访问，OAEP等等

密码的世界还是太大了

后面每周看看能不能再搞懂一点点像这样的支线任务

包括工具啊，数论啊啥的

后面要期中考了，下周肯定没戏

那就下下周开始吧

## 补充

经高人指点，尝试for语句也可行

抽空编写了代码，如下

```python
from Crypto.Util.number import *
import gmpy2

# 此处n,e,d

for i in range(2, 10000):
    if n % (pow(2, i, n) - 1) == 0:
        print(f"爆破成功,p={pow(2, i, n) - 1}")
        p = pow(2, i, n) - 1
        q = n // p
        phi=(p-1)*(q-1)
        d=gmpy2.invert(e,phi)
        print(f"flag={long_to_bytes(int(pow(c,d,n))).decode()}")
        break
else:
    print("No solution")
```

这个写起来比多进程的简单

但是实战方面的话就可能处理不了大数据了

是我找的题目不够好的原因

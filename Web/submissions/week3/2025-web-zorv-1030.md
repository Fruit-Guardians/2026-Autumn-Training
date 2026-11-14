# 题1
## 题目描述
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793423249019-fea69ff5-5eee-4a5e-90a4-82aee8c62fbb.png)

<font style="color:rgba(0, 0, 0, 0.45);">JWT 的头部和有效载荷这两部分的数据是以明文形式传输的，如果其中包含了敏感信息的话，就会发生敏感信息泄露。试着找出FLAG。格式为 flag{}</font>

## 题目界面
![](https://cdn.nlark.com/yuque/0/2026/jpeg/73090803/1793422154934-f65b4139-3b07-489a-8ae0-33d63ad56937.jpeg)

## 解题思路
根据题目提示，首先我们要得到网页的jwt，从jwt的头部和有效载荷部分找到flag

## 解题步骤
此题比较简单，直接右键，检查，在控制台输入document.cookie 得到token

```bash
document.cookie
```

<font style="color:rgba(0, 0, 0, 0.45);"></font>

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793421985577-11f77828-0018-4c71-aec4-fddbf761f823.png)

将该token复制到jwt.io，就可以得到每一部分的信息 （一开始工具使用不熟练，中间重开了一次环境）

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793422436208-1e516989-f1d4-4377-82dc-13b7f02f9be2.png)

将payload中得到的FL和header中得到的AG进行拼接，就得到flag

# 题2
## 题目描述
<font style="color:rgba(0, 0, 0, 0.45);">一些JWT库也支持none算法，即不使用签名算法。当alg字段为空时，后端将不执行签名验证。尝试找到 flag。</font>

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793423275384-874e152e-612f-48b1-ad5d-45eaa0576ac4.png)

## 题目界面
![](https://cdn.nlark.com/yuque/0/2026/jpeg/73090803/1793422731594-d6a057d1-dd0b-44d1-af9c-6677c19fdf41.jpeg)

## 解题思路
随便输入用户名密码登录一次，从 Cookie 中拿到签发的 JWT token，解码后可看到 header 中 alg 为 RS256（或 HS256）、payload 中 role 为 guest。根据题目提示，后端 JWT 库支持 none 算法，即不执行签名验证，因此只需将 header 改为 {"typ":"JWT","alg":"none"}、payload 改为 {"username":"admin","role":"admin"}，签名段留空，重新拼接成 header.payload. 形式的 token，替换 Cookie 后以 GET 请求访问首页，后端即跳过验签并识别 role 为 admin，返回 flag。

## 解题步骤


同题一，随便输账号密码登录，拿到token复制到jwt.io

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793422824212-c321bea7-9ac3-4fe2-bac4-d9ff612c5bb4.png)

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793422794229-1fb59d07-f23d-423d-9483-6f1f0edda4e9.png)

替换新token后以get请求访问首页，就能跳过验签拿到flag

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793423100333-d6385d6a-dbe0-454d-8258-dc1a1885386c.png)

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793423120152-dc1b8064-769b-440f-9a19-1f60fe306ac2.png)

# 题3
## 题目描述
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793423222505-b5e8ffbb-1b92-42ef-8316-ddbb141b2d7e.png)

## 解题思路
根据题目的提示，得到token后，可以看出该题采用"HS256"对称算法，一开始想到直接用jwt_tool，利用字典直接爆破出密钥，利用disearch进行扫描，没有得到更多信息，经过我的几次尝试，浪费了很多时间，即便跑很大的字典也没能尝试出来，之后利用hashcat进行算法密钥爆破，通过jwt.io得到新的token，替换cookie后以get请求访问，得到token

参考链接：[https://blog.csdn.net/cmdos/article/details/151402898?sharetype=blogdetail&shareId=151402898&sharerefer=APP&sharesource=Zorv1&sharefrom=link](https://blog.csdn.net/cmdos/article/details/151402898?sharetype=blogdetail&shareId=151402898&sharerefer=APP&sharesource=Zorv1&sharefrom=link)

## 解题步骤
同题一题二步骤一样，拿到token后,可以看到是HS256算法



![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793424123223-06cbe891-d96c-48eb-a43b-1319449a0971.png)

用disearch进行扫描

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793424211175-315dcc53-84e6-4ce6-b143-2e96811ebce9.png)

没有得到更多信息

利用hashcat进行爆破

```bash
hashcat -a 3 -m 16500 jwt.txt '?d?d?d?d?d?d' --increment --increment-min=4 --increment-max=6
```

```bash
hashcat -a 3 -m 16500 jwt.txt '?l?d?l?d?l?d' --increment --increment-min=4 --increment-max=6
```

我这里用了小写字母加数字才爆破出来，注意在mac终端使用hashcat？d里的问号会被shell解析会报错，要加上单引号。

![](https://cdn.nlark.com/yuque/0/2026/jpeg/73090803/1793424278618-54fb1dcb-61a3-4abf-b793-aec89072b43b.jpeg)

得到密钥cknd，把"role"后面的"guest"改成"admin",后端依据role字段判定权限，改成admin才能拿到管理员flag,在secret这里输入得到的密钥，复制新的token

![](https://cdn.nlark.com/yuque/0/2026/jpeg/73090803/1793424612309-705f6c4d-d5cc-4e49-978c-3bfc0b63b725.jpeg)

用bp替换掉原来的cookie，右键发送到respect

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793424883003-228ac753-0c2f-4d11-9507-48ba7e29e92b.png)

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793424899189-80a003ea-1c1a-47e1-9152-911027cf41d5.png)

在respect里点击send，从右边的返回结果里得到flag

# 题四
## 题目描述
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793425054555-da3b690a-61ff-4991-a0f1-31588445dce2.png)

考点：jwt算法混淆（RS256——HS256)

## 题目界面


## ![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793426728324-c8c68ed5-bfc4-4e58-801b-11ef802ddb9a.png)解题思路
![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793425210711-67189432-cbcd-460c-af0a-c4ddd1610925.png)

从题目里可以看到php源码，可以看出验签算法完全由 token header 中的 alg 字段决定，并且在该登录页直接有公钥下载链接publickey.pem，以及可以得到命中条件：!empty($_COOKIE['token']) && JWTHelper::decode(...) !== false，且 payload 里 role === 'admin'

所以接下来需要做的：得到token，验证公钥，将公钥采用HS256加密，得到新的token

<font style="color:rgb(77, 77, 77);">JWTHelper::decode($_COOKIE['token'], $PUBLIC_KEY) != false才成立。</font>

## <font style="color:rgb(77, 77, 77);">解题步骤</font>
同前面几题一样，先拿到token，再从网页上下载公钥



![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793427109437-d03679e3-d9ab-42d7-a348-5d36e510e30f.png)



注意：经过试错发现，

1.直接copy公钥到jwt.io不行，网页粘贴的公钥丢失字符，签名对不上，必须保存为文件，通过文件中读取。

2.我的python脚本也一直报错，PyJWT 2.x 有安全保护：它检测到传进去的是一段 -----BEGIN PUBLIC KEY----- 开头的 PEM（非对称密钥材料），直接报错 The specified key is an asymmetric key ... should not be used as an HMAC secret，根本不让签。

为了绕开这两个问题，直接用 Python 标准库 hmac 模块手动算：hmac.new(公钥字节, "header.payload", sha256)，避开PYJWT库

```bash
import base64, hmac, hashlib

pub = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1W2Ik5YoChM72BctRfKm
EtIZTfIaWhB065k67J3nTsUm3y3KZcvcvEldZtp5VkZ9/IGQ3R8jRjyXiDq5UfXV
qvv+hQLsUfovl+qkkvIUxJT87feEx0XzcGQr5vk/HkdcwMPPi+mWHjgdfYjxLaOz
sJ3IH9jBMZXMBno9nd1cLFIRbWu6uepRos+i6N70yosH4Redv2wK8JbmrPqDqZ3m
UwpRfruArHFuIGF2iQYFZihBA+rJKQS1AIJ/wci/hP4T8C+w70uzQ4f8jcy3A/va
3+jxGfzUN7PZYdRwpgZywWmTrXpQvwfG03xSVbDbQYVL4gd/zGaiu6an+rVzyKFp
eQIDAQAB
-----END PUBLIC KEY-----
"""

def b64url(b):
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode()

h = b64url(b'{"typ":"JWT","alg":"HS256"}')
p = b64url(b'{"username":"admin","role":"admin"}')
sig = hmac.new(pub.encode(), f"{h}.{p}".encode(), hashlib.sha256).digest()
print(f"{h}.{p}.{b64url(sig)}")
```

运行后，得到新的token

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793427173358-c7a004fc-f208-41ed-8d14-6428e3abf081.png)

用bp修改cookie并以请求get发送，得到的flag如下

![](https://cdn.nlark.com/yuque/0/2026/png/73090803/1793427240223-e751acd6-4bc1-4299-8393-9b18b40fa42e.png)

# 考点总结
+ JWT HS256弱密钥爆破：算法为HS256，密钥弱，用字典/掩码爆破密钥，拿到密钥后篡改role并重签。
+ none算法绕过：修改header的alg为none，去掉签名部分，部分后端不校验算法、不校验签名直接解析payload。
+ RS256→HS256算法混淆：后端信任token内alg字段，把RSA公钥当作HS256密钥验签；改alg为HS256、改role，用公钥签名伪造token。

# 参考文章
签名算法绕过[https://blog.csdn.net/weixin_54977781/article/details/148293033?sharetype=blogdetail&shareId=148293033&sharerefer=APP&sharesource=Zorv1&sharefrom=link](https://blog.csdn.net/weixin_54977781/article/details/148293033?sharetype=blogdetail&shareId=148293033&sharerefer=APP&sharesource=Zorv1&sharefrom=link)

算法混淆、密钥破解 [https://blog.csdn.net/2402_86373248/article/details/157325858?sharetype=blogdetail&shareId=157325858&sharerefer=APP&sharesource=Zorv1&sharefrom=link](https://blog.csdn.net/2402_86373248/article/details/157325858?sharetype=blogdetail&shareId=157325858&sharerefer=APP&sharesource=Zorv1&sharefrom=link)

密码破解工具hashcat，零基础入门到精通[https://blog.csdn.net/VN520/article/details/143078543?sharetype=blogdetail&shareId=143078543&sharerefer=APP&sharesource=Zorv1&sharefrom=link](https://blog.csdn.net/VN520/article/details/143078543?sharetype=blogdetail&shareId=143078543&sharerefer=APP&sharesource=Zorv1&sharefrom=link)




先是部分比赛题目...(复杂的还没仔细看,捏软柿子中...)       
# ZeroG-零重力CTF
## 小小的 e     
### 题目分析       
![运行情况](https://cdn.jsdelivr.net/gh/mwatson-aprilu/images@main/Week3.f1.png)      
这个题目给出了n,e,c，并且这个e非常小，n远大于c，有 $m^e \equiv c \pmod n$ 那么直接考虑直接开方得到m，我们直接试：          
~~~python
n = Integer(b435a6b2f0f4784e92c05065c35b892ab39e62618a77f4b907b7532425da3c66f78a777c462038eec88b343f46aaf0a425fcffe234b93ae2e13b812e4d291241c00b7a5832ac0194455d4242c47d56760cd0ea0193f563a49c978ed79c8315f22ec47ba0768e86796d5420cb1a6d62d5aaef124482bf9151dcd0c36e34576f6bc1fe744607b4cf34e6b218f27b3692f56e3f66cb9c6c6b06d51527b9453eb1a1e5aee4f028e7093d996d61ff70f10eb265778165750178e197939dfa30c2956599e49ba3434052b3caa041409b101adde35b0cc6b85e1f7521933261edbc1ad324108fc4e99bb811d014b117bfdfe16a9b935d734abc289171e3dc4c5322a1e916)

e = 3
c = Integer(
    "b4570009905c414d36dc1a1b7f5e183088d267944b318a2b671276fb5993fa24a466f3d557"
    "cd2390729f3302512c4e14e653dc21e5cd9e9b0581dbc93ce5533bfe6de8c44c6397c8bf8"
    "a2da8ac91d856d11469cc0365acccc6b0d7a5a07ffa13156831921bffbc15a8a7fcbe7a65e"
    "fbada77c5cf580c2b013412e033947757465",
    16
)

m = c.nth_root(e)
assert m^e == c
print(m)
~~~
最后我们得到了m:      
![运行情况](https://cdn.jsdelivr.net/gh/mwatson-aprilu/images@main/Week3.f2.png)
~~~python
12654036686553401130233894101451865273996171008268171510428441696119666706164909404693365984934821455229
~~~
输入网站中的对话框得到flag     

故而本题目的flag为    
~~~python     
ZeroG{26809129-3a72-4596-8fe2-b2e88ae554ae}
~~~    
## CommonModules   
### 题目        
![运行情况](https://cdn.jsdelivr.net/gh/mwatson-aprilu/images@main/Week3.f4.png)         
~~~python    
n = 70368691555309388686246014163938738193325633005053028952725423254610314696450111488853920284327028222122549032107350551888124201080554781155503917489442529615927210246350205575098017647302372626168772961314853960928522146645641305873773053566675343007864527319328589611978663313778365554848096636825533421207
e1 = 17
e2 = 65537
c1 = 41893900031081973034834358621052105721642522232420337250425681683812650634183601084632111129069630870050775377049678233016535996948129701645401431413413291456988764775617728398542228911735719260413299587574664927299884932985647305161940021474008259356936121317283591581197059727466311374679559889801385428447
c2 = 70268710637525526534590225081008521732449660395607871486566335229949900843688272786407637394058009768803973560513358013981410416926097732444090510792894427231806033106331148768807909461245922898358135729479737202523249392764565289584071665012637097655992926281199180668531006416379618643160743875621372220504
~~~
题目还在下面贴心的给了推理： $flag_1 \equiv m^{e_1} \pmod{n}, \qquad flag_2 \equiv m^{e_2} \pmod{n}$      

由于  $\gcd(e_1, e_2) = 1$  ，利用扩展欧几里得算法（`xgcd`）可以得到  $s_1, s_2$    ，使得：   $s_1 \cdot e_1 + s_2 \cdot e_2 = 1$ 

于是有：

$flag_1^{s_1} \cdot flag_2^{s_2} \equiv m^{e_1 s_1} \cdot m^{e_2 s_2} = m^{s_1 e_1 + s_2 e_2} \equiv m \pmod{n}$           
解题代码：      
~~~python    
from Crypto.Util.number import *
from gmpy2 import invert, gcdext

n = 70368691555309388686246014163938738193325633005053028952725423254610314696450111488853920284327028222122549032107350551888124201080554781155503917489442529615927210246350205575098017647302372626168772961314853960928522146645641305873773053566675343007864527319328589611978663313778365554848096636825533421207
e1 = 17
e2 = 65537

c1 = 41893900031081973034834358621052105721642522232420337250425681683812650634183601084632111129069630870050775377049678233016535996948129701645401431413413291456988764775617728398542228911735719260413299587574664927299884932985647305161940021474008259356936121317283591581197059727466311374679559889801385428447
c2 = 70268710637525526534590225081008521732449660395607871486566335229949900843688272786407637394058009768803973560513358013981410416926097732444090510792894427231806033106331148768807909461245922898358135729479737202523249392764565289584071665012637097655992926281199180668531006416379618643160743875621372220504

g, s1, s2 = gcdext(e1, e2)
assert g == 1

if s1 < 0:
    s1 = -s1
    c1 = invert(c1, n)

if s2 < 0:
    s2 = -s2
    c2 = invert(c2, n)

m = (pow(c1, s1, n) * pow(c2, s2, n)) % n
flag = long_to_bytes(m)
print(flag)
~~~        
最后得到了flag:     
![运行情况](https://cdn.jsdelivr.net/gh/mwatson-aprilu/images@main/Week3.f3.png)       
~~~python      
b'flag{e14dcc45-c91d-4209-b27e-e6f2d09256e4}'
~~~     

## Stage2 身份危机        

### 题目 
跳转到题目界面之后题目给了这些   
![运行情况](https://cdn.jsdelivr.net/gh/mwatson-aprilu/images@main/Week3.f5.png)      
![运行情况](https://cdn.jsdelivr.net/gh/mwatson-aprilu/images@main/Week3.f6.png)     
![运行情况](https://cdn.jsdelivr.net/gh/mwatson-aprilu/images@main/Week3.f8.png)      
已知明文结构，Token 解码后的结构为：    
~~~text
IV || C1 || C2 || C3
~~~
对应的三个明文分组为：
~~~text
P1 = uid=0788552954;#
P2 = auditid=9b758da3
P3 = role=guest;\x05\x05\x05\x05\x05
~~~
目标是把第三组中的 `guest` 改为等长的 `admin`。
### 攻击原理
题目提醒过我们说是AES-CBC，      
AES-CBC 解密满足：
~~~text
P3 = AES_DEC(C3) XOR C2
~~~     
因此，不需要知道 AES 密钥，只需修改 *'C2'* 中与 *'guest'* 对应的 5 个字节：
~~~text
C2'[5:10] = C2[5:10] XOR guest XOR admin
~~~
修改后第三组明文会变成：
~~~text
role=admin;
~~~
第二组 `auditid` 会受到影响，但题目说明该字段不参与授权判断，最后一组的 PKCS#7 填充也不会被破坏。
~~~python
import base64
from operator import xor

token = "2JRDUwfO0DTLr1S1x8o+2m0XdYNVEqBrZOZwI+RtCSFoXITJ4CcVE0gSLvqP436+8Ffy4x3zh2ygFtine0Zu+g=="

raw = bytearray(base64.b64decode(token))

orole = b"guest"
newrole = b"admin"

# raw = IV(16) || C1(16) || C2(16) || C3(16)
# role=guest; 中，guest 在 P3 内的偏移为 5
offset = 16 + 16 + len(b"role=")

for i, (obyte, newbyte) in enumerate(zip(orole, newrole)):
    raw[offset + i] = raw[offset + i]^^(obyte^^newbyte)

forg_token = base64.b64encode(raw).decode()

print(forg_token)
~~~
最终得到了伪造的token        
![运行情况](https://cdn.jsdelivr.net/gh/mwatson-aprilu/images@main/Week3.f7.png)       
~~~text
2JRDUwfO0DTLr1S1x8o+2m0XdYNVEqBrZOZwI+RtCSFoXITJ4CEEG1IILvqP436+8Ffy4x3zh2ygFtine0Zu+g==
~~~     
然后我们去管理员验证台，把得到的假token粘贴进去,得到了flag:     
![运行情况](https://cdn.jsdelivr.net/gh/mwatson-aprilu/images@main/Week3.f9.png)    
~~~text
flag": "ZeroG{05db3959-949d-4eb9-8498-d1aa63083a04}
~~~


**p+1  Attack**的笔记只能下周一补充了...(这个知识点我的理论推理还不扎实...)       

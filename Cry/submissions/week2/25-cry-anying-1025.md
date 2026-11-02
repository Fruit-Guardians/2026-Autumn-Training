# week2进度作业
ID：anying

方向:Cry

日期：26/10/24



## 配置VSCode及其扩展
<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792917479199-18591f3d-c726-477a-9b3b-662c1b4cf34b.png" width="2220" title="" crop="0,0,1,1" id="u2fa38029" class="ne-image">

在Win的VSCode中打开Ubuntu的VSCode:

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792917483508-3b7303ca-6dd5-40d9-98ec-c0886d30935d.png" width="798" title="" crop="0,0,1,1" id="ucd5d5749" class="ne-image">

安装扩展：<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792917717221-d79b45bb-0358-4c8a-be66-9cb1c5369723.png" width="296" title="" crop="0,0,1,1" id="u5b32bf6f" class="ne-image">

重加载窗口后，再选择Python解释器为sage:<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792917827135-f931efc1-af58-4919-a416-bd7c4c2856fe.png" width="2234" title="" crop="0,0,1,1" id="u43d26ca5" class="ne-image">

## 本周RSA的学习
### 一些基本工具和测试
#### RSAtool
安装：

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792923588167-a9939fd9-016d-4917-9076-b80e26e5c54b.png" width="578" title="" crop="0,0,1,1" id="uceb6de70" class="ne-image">

生成私钥：

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792923654946-6d107afe-f3ff-4533-895c-e8d46334d170.png" width="1828" title="" crop="0,0,1,1" id="u9f240cb2" class="ne-image">

一些尝试：

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792924583156-68d8ae89-0fba-49e8-9da7-eff5eb499765.png" width="523" title="" crop="0,0,1,1" id="u3c0538b6" class="ne-image">

#### RSA Converter
网页工具:可根据n,e,d得出p,q或根据给定密钥对生成pem文件。

#### openssl
查看公钥文件：

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792925535446-774d0eec-f737-419b-8f0f-f11fb8e949a3.png" width="402" title="" crop="0,0,1,1" id="ub16ea90e" class="ne-image">

解密：

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792925593122-a71b5518-c314-428d-93a4-e39189b6af44.png" width="410" title="" crop="0,0,1,1" id="u5c37df20" class="ne-image">

细节参考：

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792925725262-d6c883f0-cca7-4e0f-ae88-0802d4fa78df.png" width="408" title="" crop="0,0,1,1" id="uc766baba" class="ne-image">

### 随机抽到的题目1
平台：NSSCTF

题目：<font style="color:rgb(0, 0, 0);">[SWPUCTF 2021 新生赛]ez_rsa</font>

<font style="color:rgb(0, 0, 0);">很直接的描述，思考不多：</font>

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792926912999-774972e3-492b-4bec-b6f2-9c4f0a1e6a39.png" width="333" title="" crop="0,0,1,1" id="u04d42e1c" class="ne-image">

比较直接的解题：

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792927197128-ff799cce-6de7-4f8e-84d7-3f13f36f00aa.png" width="474" title="" crop="0,0,1,1" id="u5d0fcaf6" class="ne-image">

### 随机抽到的题目2
平台：NSSCTF

题目：<font style="color:rgb(0, 0, 0);">[LitCTF 2023]家人们！谁懂啊，RSA签到都不会 (初级)</font>

<font style="color:rgb(0, 0, 0);">附件：</font>

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792928463568-d3ab52bf-45af-45d5-94ae-c0c5b3215bcd.png" width="1844" title="" crop="0,0,1,1" id="u7c444ae1" class="ne-image">

描述很直接，没有陷阱，于是：

<img src="https://cdn.nlark.com/yuque/0/2026/png/73303426/1792929780878-9f8da55a-a98e-4702-be29-845c4f95a366.png" width="430" title="" crop="0,0,1,1" id="u9a79f0b9" class="ne-image">

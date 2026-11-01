# week2进度作业
ID：anying

方向:Cry

日期：26/10/24



## 配置VSCode及其扩展
<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792917479199-18591f3d-c726-477a-9b3b-662c1b4cf34b.png)

在Win的VSCode中打开Ubuntu的VSCode:

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792917483508-3b7303ca-6dd5-40d9-98ec-c0886d30935d.png)

安装扩展：<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792917717221-d79b45bb-0358-4c8a-be66-9cb1c5369723.png)

重加载窗口后，再选择Python解释器为sage:<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792917827135-f931efc1-af58-4919-a416-bd7c4c2856fe.png)

## 本周RSA的学习
### 一些基本工具和测试
#### RSAtool
安装：

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792923588167-a9939fd9-016d-4917-9076-b80e26e5c54b.png)

生成私钥：

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792923654946-6d107afe-f3ff-4533-895c-e8d46334d170.png)

一些尝试：

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792924583156-68d8ae89-0fba-49e8-9da7-eff5eb499765.png)

#### RSA Converter
网页工具:可根据n,e,d得出p,q或根据给定密钥对生成pem文件。

#### openssl
查看公钥文件：

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792925535446-774d0eec-f737-419b-8f0f-f11fb8e949a3.png)

解密：

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792925593122-a71b5518-c314-428d-93a4-e39189b6af44.png)

细节参考：

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792925725262-d6c883f0-cca7-4e0f-ae88-0802d4fa78df.png)

### 随机抽到的题目1
平台：NSSCTF

题目：<font style="color:rgb(0, 0, 0);">[SWPUCTF 2021 新生赛]ez_rsa</font>

<font style="color:rgb(0, 0, 0);">很直接的描述，思考不多：</font>

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792926912999-774972e3-492b-4bec-b6f2-9c4f0a1e6a39.png)

比较直接的解题：

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792927197128-ff799cce-6de7-4f8e-84d7-3f13f36f00aa.png)

### 随机抽到的题目2
平台：NSSCTF

题目：<font style="color:rgb(0, 0, 0);">[LitCTF 2023]家人们！谁懂啊，RSA签到都不会 (初级)</font>

<font style="color:rgb(0, 0, 0);">附件：</font>

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792928463568-d3ab52bf-45af-45d5-94ae-c0c5b3215bcd.png)

描述很直接，没有陷阱，于是：

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/73303426/1792929780878-9f8da55a-a98e-4702-be29-845c4f95a366.png)


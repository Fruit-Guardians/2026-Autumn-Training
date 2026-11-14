## 文章编辑记录
**一编：10月16日**
* **学习内容**：初识CTF-Misc，完成开发环境配置，拿到第一个flag

**二编：10月17日-10月18日**
* **学习内容**：1.图片文件类型以及16进制尾标识
2.使用Aperi'slove进行图片隐写分析
3.使用ezgif抽帧
---
## Base64 解码
### 1. 题目信息
* **题目**：给出字符串 `ZmxhZzplbnVDVEZ7SDNyM18xNV95MHVyX2YxcjU3X2ZsNGd9`，提取隐藏的 flag
### 2. 解题过程
* **思路**：观察到字符串由大小写字母和数字组成，且**末尾带 `=`**，疑似 Base64 编码
* **工具**：CyberChef (在线网页工具)
* **步骤**：
  1. 将字符串粘贴进CyberChef右侧Input框
  2. Output框直接输出明文：
``flag:HnuCTF{H3r3_15_y0ur_f1r57_fl4g}``![CyberChef使用](https://github.com/user-attachments/assets/f6c0367d-e697-44c5-954b-9b695d79f42d)
---
## 图片隐写术
### 1. 题目信息
* **题目**：给出图片，提取隐藏的 flag
### 2. 解题过程
* **思路**：Aperi'slove➡zsteg（本题用到的方法）➡stegslove位平面➡PNG CRC宽高修复
* **工具**：Aperi'slove.com
* **步骤**：
  1. 将图片拖入指定区域分析
  2. zsteg板块输出
``b1,rgb,lsb,xy       .. text: "HnuCTF{Y0u_f0und_q1ng_g3_n1u_b1_c0l0r5!!}"``![Zsteg](https://github.com/user-attachments/assets/207e6b9c-7ae0-4bb9-806a-d3cc8cdda5a3)

**碎碎念：** 刚开始漏看zsteg直接看strings![strings](https://github.com/user-attachments/assets/a866986b-7923-4d75-8e79-997e5c68128a)没找到导致绕了好大一圈回到原地才找到flag，途中又使用HexEd.it检查文件尾标识![HexEd.it](https://github.com/user-attachments/assets/4b1a4344-78ed-4596-aef2-209302c38f64)发现没有问题。回顾与AI的对话发现应该是提示词不太准确导致初始思路复杂，应该提高术语表达准度

---
## gif抽帧
### 1. 题目信息
* **题目**：给出gif，提取隐藏的 flag
### 2. 解题过程
* **思路**：使用抽帧网站或软件实现逐帧分解
* **工具**：ezgif.com
* **步骤**：
  1. 进入ezgif的split界面拖入gif分析
  2. 得到逐帧![ezgif](https://github.com/user-attachments/assets/59b30f7f-8863-4410-abb4-9a5463c72bf1)，拼接信息得到
``HnuCTF{F31yu_Go_g0_go!}``

**碎碎念：** 因为一时图方便使用了在线网站，后续已安装stegsolve学习，正在适应软件

---
## PNG修改高度隐写
### 1. 题目信息
* **题目**：给出高度被人为修改的图片
### 2. 解题过程
* **思路**：修改图片IHDR 高度还原
* **工具**：TweakPNG
* **步骤**：
  1. 拖入图片，双击第一行IHDR**宽 1203，高 631**![TweakPNG](https://github.com/user-attachments/assets/dea0f5be-0edf-406b-9f67-6716b2bdc0ec)并将高度修改为1200，保存新图片
  2. 新图片下方显示
``HnuCTF{y0u_f0und_7h3_8u77!!}``

**碎碎念：** 操作TweakPNG时发现与AI版本不同，没有Recalculate CRC按键，启示与AI沟通时要擅用截图功能









